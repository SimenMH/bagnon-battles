local ADDON, ns = ...
local Util = ns.Util

local Comm = {}
ns.Comm = Comm
LibStub("AceComm-3.0"):Embed(Comm)

Comm.peers = {}
Comm.channelIndex = nil
Comm.started = false
Comm.SAMPLE_SIZE = 10
Comm.THIN_THRESHOLD = 12
Comm.RATE_WINDOW = 60
Comm.RATE_LIMIT = 30
Comm.REQUEST_WINDOW = 60
Comm.session = string.format("%08x", math.random(0, 0x7fffffff))

local inbound = {}
local lastHello = 0
local lastRequest = 0
local generation = 0
local pendingRequest
local selfNameSeen = false

local function settings()
  return ns.db and ns.db.global.settings or { share = true }
end

local function readable(value, limit)
  if type(value) ~= "string" and type(value) ~= "number" then return "Unknown" end
  local text = tostring(value):gsub("[%c|]", " "):gsub("%s+", " "):match("^%s*(.-)%s*$")
  if text == "" then return "Unknown" end
  limit = limit or 64
  if #text > limit then text = text:sub(1, limit) .. "..." end
  return text
end

local function traffic(text)
  if settings().traffic then ns.Print("[traffic]", text) end
end

local function channelStatus(index)
  local regional = "unknown"
  if index and C_ChatInfo and type(C_ChatInfo.IsChannelRegional) == "function" then
    local ok, value = pcall(C_ChatInfo.IsChannelRegional, index)
    if ok and type(value) == "boolean" then regional = tostring(value) end
  end
  local channel = index and "Joined channel " .. readable(index) .. "." or "Not joined."
  return channel .. " Regional flag: " .. regional .. "."
end

function Comm.SetTraffic(enabled)
  local config = settings()
  config.traffic = enabled == true
  local state = config.traffic and "Logging on. " or "Logging off. "
  if not config.share then state = state .. "Sharing off. " end
  ns.Print("[traffic]", state .. channelStatus(Comm.channelIndex))
  return config.traffic
end

local function buildSummary(build)
  build = type(build) == "table" and build or {}
  local class = ns.ClassesById[build.c]
  return "Build " .. readable(build.n) .. " (" .. readable(class and class.name or "Unknown class") .. ", round " .. readable(build.r, 12) .. ")"
end

local function messageSummary(tbl)
  if tbl.t == "B" then return buildSummary(tbl.b) end
  if tbl.t == "H" then return "Hello" end
  if tbl.t == "R" then return "Request for " .. tostring(type(tbl.r) == "table" and #tbl.r or 0) .. " rounds" end
  if tbl.t == "S" then return "Sample of " .. tostring(type(tbl.b) == "table" and #tbl.b or 0) .. " builds" end
  return "Unknown message"
end

local function destination(distribution, target)
  if distribution == "CHANNEL" then return "channel " .. readable(target) end
  if distribution == "WHISPER" then return "whisper to " .. readable(target) end
  return readable(distribution) .. " " .. readable(target)
end

local function resultSummary(result)
  if result == true then return "Success" end
  if result == false then return "Failed" end
  local values = Enum and Enum.SendAddonMessageResult
  if type(values) == "table" then
    for key, value in pairs(values) do
      if value == result then return readable(key) .. " (" .. readable(result, 16) .. ")" end
    end
  end
  return readable(result, 24)
end

local function fullName(sender)
  if not sender then return "Unknown" end
  if not ns.IS_FOREVER and not sender:find("-", 1, true) then
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or ""
    if realm ~= "" then return sender .. "-" .. realm end
  end
  return sender
end

local function rememberSelfName(name)
  if selfNameSeen or not ns.db then return end
  selfNameSeen = true
  local localName = ns.PlayerName()
  ns.db.global.selfNames[localName] = name ~= localName and name or nil
end

function Comm.SelfName(who)
  local names = ns.db and ns.db.global.selfNames
  return names and names[who]
end

local function timer(delay, fn)
  local current = generation
  local function run()
    if current == generation and settings().share then fn() end
  end
  if C_Timer and C_Timer.After then C_Timer.After(delay, run) else run() end
end

function Comm.ChannelIndex()
  return Comm.channelIndex
end

function Comm.PeerCount()
  local n = 0
  local now = Util.Now()
  for _, seen in pairs(Comm.peers) do
    if now - seen < ns.Pool.LIVE_WINDOW then n = n + 1 end
  end
  return n
end

function Comm.IsOnline(name)
  local seen = Comm.peers[name]
  return seen ~= nil and (Util.Now() - seen) < ns.Pool.LIVE_WINDOW
end

local function hideChannelFromChat()
  for i = 1, NUM_CHAT_WINDOWS or 10 do
    local frame = _G["ChatFrame" .. i]
    if frame and ChatFrame_RemoveChannel then ChatFrame_RemoveChannel(frame, ns.CHANNEL) end
  end
end

function Comm.JoinChannel()
  if not settings().share then traffic("Channel join skipped. Sharing off.") return end
  local id = GetChannelName(ns.CHANNEL)
  if id and id > 0 then
    Comm.channelIndex = id
    hideChannelFromChat()
    traffic(channelStatus(id))
    return true
  end
  traffic("Joining channel " .. readable(ns.CHANNEL) .. ".")
  if JoinTemporaryChannel then
    JoinTemporaryChannel(ns.CHANNEL)
  elseif JoinChannelByName then
    JoinChannelByName(ns.CHANNEL)
  end
  timer(2, function()
    local idx = GetChannelName(ns.CHANNEL)
    if idx and idx > 0 then
      Comm.channelIndex = idx
      hideChannelFromChat()
      traffic(channelStatus(idx))
      ns.Debug("joined channel", idx)
      Comm.SendHello()
      Comm.SendRequest()
    else
      traffic("Channel not joined yet.")
      ns.Debug("channel join pending")
    end
  end)
  return false
end

function Comm.Start()
  if Comm.started then
    if Comm.JoinChannel() then
      Comm.SendHello()
      Comm.SendRequest()
    end
    return
  end
  Comm.started = true
  Comm:RegisterComm(ns.PREFIX, "OnCommReceived")
  timer(8, function()
    if Comm.JoinChannel() then
      Comm.SendHello()
      Comm.SendRequest()
    end
  end)
  if ns.Addon then
    ns.Addon:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", function(_, kind, _, _, _, _, _, _, _, channelName)
      if channelName ~= ns.CHANNEL then return end
      if kind == "YOU_LEFT" then Comm.channelIndex = nil return end
      if settings().share and (kind == "YOU_JOINED" or kind == "YOU_CHANGED") then
        local idx = GetChannelName(ns.CHANNEL)
        if idx and idx > 0 then
          if Comm.channelIndex ~= idx then traffic(channelStatus(idx)) end
          Comm.channelIndex = idx
          hideChannelFromChat()
          Comm.SendHello()
          Comm.SendRequest()
        end
      end
    end)
  end
end

function Comm.SetSharing(enabled)
  local config = settings()
  enabled = enabled == true
  if config.share ~= enabled then
    generation = generation + 1
    lastHello, lastRequest, pendingRequest = 0, 0, nil
  end
  config.share = enabled
  if enabled then Comm.Start() end
  return enabled
end

local function send(tbl, distribution, target, prio)
  local summary = messageSummary(tbl)
  if not settings().share then traffic("Skipped " .. summary .. ". Sharing is off.") return false end
  tbl.k = Comm.session
  local encoded, payload = pcall(ns.Snapshot.Encode, tbl)
  if not encoded or type(payload) ~= "string" then
    traffic("Skipped " .. summary .. ". Encoding failed.")
    return false
  end
  if #payload > ns.Snapshot.MAX_CHANNEL_PAYLOAD then
    traffic("Skipped " .. summary .. ". Payload too large (" .. #payload .. " bytes).")
    return false
  end
  local description = summary .. " to " .. destination(distribution, target) .. ", " .. #payload .. " bytes."
  local state = { ready = false, finished = false }
  local function report()
    if state.failed then traffic("Send failed: " .. description .. " Result " .. resultSummary(state.result) .. ".")
    else traffic("Sent " .. description .. " Result " .. resultSummary(state.result) .. ".") end
  end
  local function callback(_, sent, total, result)
    if state.finished or result == nil then return end
    local success = Enum and Enum.SendAddonMessageResult and Enum.SendAddonMessageResult.Success or 0
    if type(result) ~= "number" and type(result) ~= "boolean" then return end
    if result == false or (result ~= true and result ~= success and result ~= 0) then
      state.failed, state.result, state.finished = true, result, true
    elseif type(sent) == "number" and type(total) == "number" and total > 0 and sent >= total then
      state.result, state.finished = result, true
    end
    if state.ready and state.finished then report() end
  end
  local ok = pcall(Comm.SendCommMessage, Comm, ns.PREFIX, payload, distribution, target, prio or "NORMAL", callback, state)
  if not ok then
    state.finished = true
    traffic("Send failed: " .. description .. " Send call failed.")
    return false
  end
  traffic("Queued " .. description)
  state.ready = true
  if state.finished then report() end
  return true
end

function Comm.SendBuild(build)
  if not settings().share then traffic("Skipped Build. Sharing is off.") return false end
  if not Comm.channelIndex then traffic("Skipped Build. Channel not joined.") return false end
  if InCombatLockdown and InCombatLockdown() then traffic("Skipped Build. In combat.") return false end
  return send({ t = "B", p = ns.PROTOCOL_VERSION, b = build }, "CHANNEL", Comm.channelIndex, "NORMAL")
end

function Comm.SendHello()
  if not settings().share or not Comm.channelIndex then return end
  local now = Util.Now()
  if now - lastHello < 60 then return end
  lastHello = now
  send({ t = "H", p = ns.PROTOCOL_VERSION, d = ns.DATA_VERSION, c = ns.Pool.Counts(), n = ns.PlayerName() }, "CHANNEL", Comm.channelIndex, "BULK")
end

function Comm.SendRequest()
  if not settings().share or not Comm.channelIndex then return end
  local now = Util.Now()
  if now - lastRequest < 120 then return end
  local rounds = ns.Pool.ThinRounds(Comm.THIN_THRESHOLD)
  if #rounds == 0 then return end
  lastRequest = now
  local id = Util.HashHex(ns.PlayerName() .. now)
  if send({ t = "R", p = ns.PROTOCOL_VERSION, d = ns.DATA_VERSION, r = rounds, id = id }, "CHANNEL", Comm.channelIndex, "BULK") then
    pendingRequest = { id = id, time = now, responders = {} }
  end
end

local function requestId(id)
  if type(id) == "string" and #id > 0 and #id <= 16 then return id end
end

local function solicited(distribution, sender, id, now)
  local request = pendingRequest
  if distribution ~= "WHISPER" or not request or id ~= request.id or now - request.time > Comm.REQUEST_WINDOW
    or request.responders[sender] then return false end
  request.responders[sender] = true
  return true
end

local function requestedRounds(rounds)
  if type(rounds) ~= "table" then return nil end
  local count, last, unique, seen = 0, 0, {}, {}
  for index, round in pairs(rounds) do
    if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > ns.Economy.ROUNDS
      or type(round) ~= "number" or round ~= math.floor(round) or round < 1 or round > ns.Economy.ROUNDS then return nil end
    count, last = count + 1, math.max(last, index)
  end
  if count == 0 or count ~= last then return nil end
  for _, round in ipairs(rounds) do
    if not seen[round] then unique[#unique + 1], seen[round] = round, true end
  end
  return unique
end

local function compatibleData(version)
  return type(version) == "number" and version == math.floor(version) and version >= ns.MIN_DATA_VERSION and version <= ns.DATA_VERSION
end

local function respondToRequest(sender, rounds, id)
  local peerCount = math.max(1, Comm.PeerCount())
  local chance = math.min(1, 3 / peerCount)
  if math.random() > chance then return end
  local delay = math.random() * 5
  timer(delay, function()
    local rng = Util.NewRNG(Util.Hash32(sender .. ":" .. ns.PlayerName() .. ":" .. tostring(Util.Now())))
    rng:Shuffle(rounds)
    local builds = {}
    local perRound = math.max(1, math.floor(Comm.SAMPLE_SIZE / math.max(1, #rounds)))
    for _, r in ipairs(rounds) do
      if #builds >= Comm.SAMPLE_SIZE then break end
      if type(r) == "number" and r >= 1 and r <= ns.Economy.ROUNDS then
        for _, b in ipairs(ns.Pool.Sample(r, perRound, rng)) do
          if #builds < Comm.SAMPLE_SIZE then builds[#builds + 1] = b end
        end
      end
    end
    if #builds == 0 then return end
    send({ t = "S", p = ns.PROTOCOL_VERSION, id = id, b = builds }, "WHISPER", sender, "BULK")
    ns.Debug("prepared sample of", #builds, "to", sender)
  end)
end

local function rateOk(sender)
  local now = Util.Now()
  local rec = inbound[sender]
  if not rec or now - rec.start > Comm.RATE_WINDOW then
    rec = { start = now, count = 0 }
    inbound[sender] = rec
  end
  rec.count = rec.count + 1
  return rec.count <= Comm.RATE_LIMIT
end

function Comm:OnCommReceived(prefix, text, distribution, sender)
  if prefix ~= ns.PREFIX or not settings().share then return end
  local senderFull = fullName(sender)
  local source = " from " .. readable(senderFull) .. " via " .. readable(distribution, 16) .. ", " .. tostring(type(text) == "string" and #text or 0) .. " bytes."
  if not rateOk(senderFull) then traffic("Rejected message" .. source .. " Rate limited.") return end
  local decoded, tbl = pcall(ns.Snapshot.Decode, text)
  if not decoded or type(tbl) ~= "table" then traffic("Rejected message" .. source .. " Malformed message.") return end
  if tbl.k == Comm.session then
    rememberSelfName(senderFull)
    traffic("Ignored own echo" .. source)
    return
  end
  if tbl.p ~= ns.PROTOCOL_VERSION then traffic("Rejected message" .. source .. " Protocol version mismatch.") return end
  local now = Util.Now()
  if tbl.t == "B" and type(tbl.b) == "table" then
    tbl.b.n = senderFull
    tbl.b.bot = nil
    local added, why = ns.Pool.Add(tbl.b, { firsthand = distribution ~= "WHISPER", now = now })
    if added or why == "duplicate" then Comm.peers[senderFull] = now end
    local outcome = added and "Stored." or why == "duplicate" and "Duplicate." or "Rejected: " .. readable(why, 96) .. "."
    traffic("Received " .. buildSummary(tbl.b) .. source .. " " .. outcome)
    ns.Debug("build from", senderFull, added and "stored" or why)
    if added and ns.UI.Main and ns.UI.Main.OnPoolChanged then ns.UI.Main.OnPoolChanged() end
  elseif tbl.t == "H" then
    if not compatibleData(tbl.d) then traffic("Rejected Hello" .. source .. " Data version mismatch.") return end
    Comm.peers[senderFull] = now
    traffic("Received Hello" .. source)
    ns.Debug("hello from", senderFull)
  elseif tbl.t == "R" and type(tbl.r) == "table" then
    if not compatibleData(tbl.d) then traffic("Rejected Request" .. source .. " Data version mismatch.") return end
    local rounds = requestedRounds(tbl.r)
    if not rounds then traffic("Rejected Request" .. source .. " Invalid rounds.") return end
    Comm.peers[senderFull] = now
    traffic("Received " .. messageSummary(tbl) .. source)
    respondToRequest(senderFull, rounds, requestId(tbl.id))
  elseif tbl.t == "S" and type(tbl.b) == "table" then
    if not solicited(distribution, senderFull, tbl.id, now) then traffic("Rejected Sample" .. source .. " Not a reply to our request.") return end
    local stored, duplicate, rejected = 0, 0, math.max(0, #tbl.b - Comm.SAMPLE_SIZE)
    for i = 1, math.min(#tbl.b, Comm.SAMPLE_SIZE) do
      local b = tbl.b[i]
      if type(b) == "table" then
        b.bot = nil
        local added, why = ns.Pool.Add(b, { firsthand = false, now = now })
        if added then stored = stored + 1
        elseif why == "duplicate" then duplicate = duplicate + 1
        else rejected = rejected + 1 end
      else rejected = rejected + 1 end
    end
    if stored > 0 or duplicate > 0 then Comm.peers[senderFull] = now end
    traffic("Received " .. messageSummary(tbl) .. source .. " Stored " .. stored .. ", duplicate " .. duplicate .. ", rejected " .. rejected .. ".")
    ns.Debug("sample from", senderFull, "stored", stored)
    if stored > 0 and ns.UI.Main and ns.UI.Main.OnPoolChanged then ns.UI.Main.OnPoolChanged() end
  else
    traffic("Rejected message" .. source .. " Malformed message.")
  end
end
