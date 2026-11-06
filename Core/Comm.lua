local ADDON, ns = ...
local Util = ns.Util
local Peers = ns.CommPeers

local Comm = {}
ns.Comm = Comm
LibStub("AceComm-3.0"):Embed(Comm)

Comm.peers = Peers.records
Comm.SelfNames = Peers.SelfNames
Comm.PeerCount = Peers.PeerCount
Comm.PresentCount = Peers.PresentCount
Comm.IsOnline = Peers.IsOnline
Comm.InGuild = Peers.InGuild
Comm.channelIndex = nil
Comm.started = false
Comm.SAMPLE_SIZE = 10
Comm.THIN_THRESHOLD = 12
Comm.RATE_WINDOW = 60
Comm.RATE_LIMIT = 30
Comm.REQUEST_WINDOW = 60
Comm.HELLO_FANOUT = 8
Comm.PUSH_FANOUT = 10
Comm.PULL_INTERVAL = 180
Comm.HELLO_COOLDOWN = 600
Comm.FANOUT_COOLDOWN = 60
Comm.WHISPER_WINDOW = 60
Comm.session = string.format("%08x", math.random(0, 0x7fffffff))

local CHANNEL_EVENTS = { "CHAT_MSG_CHANNEL_JOIN", "CHAT_MSG_CHANNEL_LEAVE", "CHAT_MSG_CHANNEL_LIST", "CHAT_MSG_CHANNEL_NOTICE" }

local inbound = {}
local whispered = {}
local lastHello = 0
local lastRequest = 0
local lastFanout = 0
local lastJoined = 0
local generation = 0
local pendingRequest
local filtersInstalled = false
local fanoutGeneration
local ticker

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

local function route()
  local override = settings().route
  if override == "whisper" or override == "channel" then return override end
  return ns.IS_FOREVER and "whisper" or "channel"
end

local function channelStatus(index)
  local regional = "unknown"
  if index and C_ChatInfo and type(C_ChatInfo.IsChannelRegional) == "function" then
    local ok, value = pcall(C_ChatInfo.IsChannelRegional, index)
    if ok and type(value) == "boolean" then regional = tostring(value) end
  end
  local channel = index and "Joined channel " .. readable(index) .. "." or "Not joined."
  return channel .. " Regional flag: " .. regional .. ". Route: " .. route() .. "."
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

local function timer(delay, fn)
  local current = generation
  local function run()
    if current == generation and settings().share then fn() end
  end
  if C_Timer and C_Timer.After then C_Timer.After(delay, run) else run() end
end

function Comm.Route()
  return route()
end

function Comm.ChannelIndex()
  return Comm.channelIndex
end

local function hideChannelFromChat()
  local remove = ChatFrameUtil and ChatFrameUtil.RemoveChannel or ChatFrame_RemoveChannel
  if not remove then return end
  for i = 1, NUM_CHAT_WINDOWS or 10 do
    local frame = _G["ChatFrame" .. i]
    if frame then pcall(remove, frame, ns.CHANNEL) end
  end
end

local function hideChannelLine(_, _, ...)
  if select(9, ...) == ns.CHANNEL then return true end
end

local function offlineTarget(message)
  local template = ERR_CHAT_PLAYER_NOT_FOUND_S
  if type(message) ~= "string" or type(template) ~= "string" then return end
  local now = Util.Now()
  for name, at in pairs(whispered) do
    if now - at > Comm.WHISPER_WINDOW then
      whispered[name] = nil
    elseif message == string.format(template, name) then
      return name
    end
  end
end

local function hideOfflineLine(_, _, message)
  if offlineTarget(message) then return true end
end

local function installFilters()
  if filtersInstalled then return end
  local add = ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter or ChatFrame_AddMessageEventFilter
  if not add then return end
  filtersInstalled = true
  for _, event in ipairs(CHANNEL_EVENTS) do add(event, hideChannelLine) end
  add("CHAT_MSG_SYSTEM", hideOfflineLine)
end

local function send(tbl, distribution, target)
  local summary = messageSummary(tbl)
  if not settings().share then traffic("Skipped " .. summary .. ". Sharing is off.") return false end
  tbl.k = Comm.session
  tbl.d = tbl.d or ns.DATA_VERSION
  tbl.m = math.max(ns.MIN_DATA_VERSION, tbl.m or 0)
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
    if state.failed then
      traffic("Send failed: " .. description .. " Result " .. resultSummary(state.result) .. ".")
    else
      traffic("Sent " .. description .. " Result " .. resultSummary(state.result) .. ".")
    end
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
  if distribution == "WHISPER" then whispered[target] = Util.Now() end
  local priority = distribution == "CHANNEL" and tbl.t == "B" and "NORMAL" or "BULK"
  local ok = pcall(Comm.SendCommMessage, Comm, ns.PREFIX, payload, distribution, target, priority, callback, state)
  if not ok then
    state.finished = true
    traffic("Send failed: " .. description .. " Send call failed.")
    return false
  end
  traffic("Queued " .. description)
  state.ready = true
  if state.finished then report() end
  return not state.failed
end

local function hello(target)
  return { t = "H", p = ns.PROTOCOL_VERSION, d = ns.DATA_VERSION, a = ns.VERSION, c = ns.Pool.Counts(), n = ns.PlayerName(), i = Peers.Introductions(target) }
end

local function requestRounds()
  local rounds = ns.Pool.ThinRounds(Comm.THIN_THRESHOLD)
  if #rounds > 0 then return rounds end
  for r = 1, ns.Economy.ROUNDS do rounds[r] = r end
  return rounds
end

local function request(since)
  local id = Util.HashHex(ns.PlayerName() .. Util.Now() .. math.random(0, 0x7fffffff))
  return { t = "R", p = ns.PROTOCOL_VERSION, r = requestRounds(), id = id, s = since }, id
end

function Comm.SendHello()
  if not settings().share or not Comm.channelIndex or route() ~= "channel" then return end
  local now = Util.Now()
  if now - lastHello < 60 then return end
  if send(hello(), "CHANNEL", Comm.channelIndex) then lastHello = now end
end

function Comm.SendRequest()
  if not settings().share or not Comm.channelIndex or route() ~= "channel" then return end
  local now = Util.Now()
  if now - lastRequest < 120 then return end
  local tbl, id = request(lastRequest)
  if send(tbl, "CHANNEL", Comm.channelIndex) then
    lastRequest = now
    pendingRequest = { id = id, time = now, responders = {} }
  end
end

function Comm.HelloFanout()
  if not settings().share or route() ~= "whisper" then return end
  local now = Util.Now()
  if now - lastFanout < Comm.FANOUT_COOLDOWN then return end
  local names = Peers.Targets(Comm.HELLO_FANOUT, function(rec)
    return not rec.hello or now - rec.hello >= Comm.HELLO_COOLDOWN
  end, true)
  if #names == 0 then traffic("Hello skipped. Nobody to greet.") return end
  for _, name in ipairs(names) do
    if send(hello(name), "WHISPER", name) then
      Peers.Get(name).hello, lastFanout = now, now
    end
  end
end

local function scheduleFanout()
  if fanoutGeneration == generation or route() ~= "whisper" then return end
  local current = generation
  fanoutGeneration = current
  timer(3, function()
    if fanoutGeneration ~= current then return end
    fanoutGeneration = nil
    Comm.HelloFanout()
  end)
end

local function pullTarget()
  local now = Util.Now()
  local mine = Comm.SelfNames()
  local best, bestPulled
  for name, rec in pairs(Comm.peers) do
    if not mine[name] and rec.compatible == true and rec.seen and Peers.Available(rec, now) then
      local pulled = rec.pulled or 0
      if not best or pulled < bestPulled then best, bestPulled = name, pulled end
    end
  end
  return best or Peers.Targets(1)[1]
end

function Comm.Pull()
  if not settings().share then return end
  if route() == "channel" then Comm.SendRequest() return end
  local name = pullTarget()
  if not name then traffic("Pull skipped. No peers known.") return end
  local rec = Peers.Get(name)
  local now = Util.Now()
  local tbl, id = request(rec.pulled or 0)
  if send(tbl, "WHISPER", name) then
    rec.pulled = now
    pendingRequest = { id = id, time = now, responders = {} }
  end
end

function Comm.SendBuild(build)
  if not settings().share then traffic("Skipped Build. Sharing is off.") return false end
  if InCombatLockdown and InCombatLockdown() then traffic("Skipped Build. In combat.") return false end
  local tbl = { t = "B", p = ns.PROTOCOL_VERSION, b = build }
  if route() == "channel" then
    if not Comm.channelIndex then traffic("Skipped Build. Channel not joined.") return false end
    return send(tbl, "CHANNEL", Comm.channelIndex)
  end
  local names = Peers.Targets(Comm.PUSH_FANOUT)
  if #names == 0 then traffic("Skipped Build. No peers known.") return false end
  local sent = false
  for _, name in ipairs(names) do
    if send(tbl, "WHISPER", name) then sent = true end
  end
  return sent
end

local function onJoined(index)
  local now = Util.Now()
  if Comm.channelIndex == index and now - lastJoined < 30 then return end
  Comm.channelIndex, lastJoined = index, now
  hideChannelFromChat()
  traffic(channelStatus(index))
  ns.Debug("joined channel", index)
  if route() == "whisper" then
    Peers.RequestRoster(index)
    scheduleFanout()
    timer(6, Comm.Pull)
  else
    Comm.SendHello()
    Comm.SendRequest()
  end
end

function Comm.JoinChannel()
  if not settings().share then traffic("Channel join skipped. Sharing off.") return false end
  local id = GetChannelName(ns.CHANNEL)
  if id and id > 0 then
    onJoined(id)
    return true
  end
  traffic("Joining channel " .. readable(ns.CHANNEL) .. ".")
  if JoinTemporaryChannel then
    JoinTemporaryChannel(ns.CHANNEL)
  elseif JoinChannelByName then
    JoinChannelByName(ns.CHANNEL)
  end
  timer(2, function()
    local index = GetChannelName(ns.CHANNEL)
    if index and index > 0 then
      onJoined(index)
    else
      traffic("Channel not joined yet.")
      ns.Debug("channel join pending")
    end
  end)
  return false
end

local function registerEvents()
  local addon = ns.Addon
  addon:RegisterEvent("ADDON_LOADED", function() ns.CommTransport.EnsureInstalled() end)
  addon:RegisterEvent("CHAT_MSG_SYSTEM", function(_, message)
    local name = offlineTarget(message)
    if not name then return end
    Peers.MarkOffline(name)
    traffic("Whisper target " .. readable(name) .. " is offline.")
  end)
  addon:RegisterEvent("CHAT_MSG_CHANNEL_NOTICE", function(_, kind, _, _, _, _, _, _, _, channelName)
    if channelName ~= ns.CHANNEL then return end
    if kind == "YOU_LEFT" then
      Peers.CancelRoster()
      Comm.channelIndex = nil
      traffic("Left channel.")
    elseif kind == "YOU_JOINED" or kind == "YOU_CHANGED" then
      local index = settings().share and GetChannelName(ns.CHANNEL)
      if index and index > 0 then onJoined(index) end
    else
      traffic("Channel notice " .. readable(kind, 32) .. ".")
    end
  end)
  addon:RegisterEvent("CHAT_MSG_CHANNEL_JOIN", function(_, _, name, _, _, _, _, _, _, channelName)
    if channelName ~= ns.CHANNEL then return end
    if Peers.Joined(name) then scheduleFanout() end
  end)
  addon:RegisterEvent("CHAT_MSG_CHANNEL_LEAVE", function(_, _, name, _, _, _, _, _, _, channelName)
    if channelName ~= ns.CHANNEL then return end
    Peers.Left(name)
  end)
  local function rosterFound(count)
    if count > 0 then
      traffic("Channel roster lists " .. count .. " others.")
      scheduleFanout()
    end
  end
  local function rosterUpdated(_, displayIndex)
    if not settings().share or route() ~= "whisper" then return end
    rosterFound(Peers.ReadRoster(Comm.channelIndex, displayIndex))
  end
  addon:RegisterEvent("CHANNEL_ROSTER_UPDATE", rosterUpdated)
  addon:RegisterEvent("CHANNEL_UI_UPDATE", function()
    if settings().share and route() == "whisper" then rosterFound(Peers.RefreshRoster(Comm.channelIndex)) end
  end)
  addon:RegisterEvent("GUILD_ROSTER_UPDATE", Peers.ReadGuild)
  addon:RegisterEvent("PLAYER_GUILD_UPDATE", Peers.RequestGuild)
end

function Comm.Start()
  ns.CommTransport.SetEnabled(settings().share)
  if Comm.started then
    Comm.JoinChannel()
    return
  end
  Comm.started = true
  Comm:RegisterComm(ns.PREFIX, "OnCommReceived")
  installFilters()
  Peers.RequestGuild()
  if ns.Addon then registerEvents() end
  timer(8, Comm.JoinChannel)
  if not ticker and C_Timer and C_Timer.NewTicker then
    ticker = C_Timer.NewTicker(Comm.PULL_INTERVAL, Comm.Pull)
  end
end

local function resetSync()
  Peers.CancelRoster()
  generation = generation + 1
  lastHello, lastRequest, lastFanout, lastJoined = 0, 0, 0, 0
  pendingRequest, fanoutGeneration = nil, nil
end

function Comm.SetSharing(enabled)
  local config = settings()
  enabled = enabled == true
  if config.share ~= enabled then resetSync() end
  config.share = enabled
  ns.CommTransport.SetEnabled(enabled)
  if enabled then Comm.Start() end
  return enabled
end

function Comm.SetRoute(mode)
  if mode ~= "auto" and mode ~= "channel" and mode ~= "whisper" then return false end
  local config = settings()
  if config.route ~= mode then
    config.route = mode
    resetSync()
    if config.share then Comm.JoinChannel() end
  end
  return true
end

function Comm.SetTraffic(enabled)
  local config = settings()
  config.traffic = enabled == true
  local state = config.traffic and "Logging on. " or "Logging off. "
  if not config.share then state = state .. "Sharing off. " end
  ns.Print("[traffic]", state .. channelStatus(Comm.channelIndex))
  return config.traffic
end

local function requestId(id)
  if type(id) == "string" and #id > 0 and #id <= 16 then return id end
end

local function solicited(distribution, sender, id, now)
  local pending = pendingRequest
  if distribution ~= "WHISPER" or not pending or id ~= pending.id or now - pending.time > Comm.REQUEST_WINDOW
    or pending.responders[sender] then return false end
  pending.responders[sender] = true
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

local function sinceTime(value)
  if type(value) == "number" and value >= 0 and value == math.floor(value) then return value end
  return 0
end

local function sampleFor(sender, rounds, since)
  local rng = Util.NewRNG(Util.Hash32(sender .. ":" .. ns.PlayerName() .. ":" .. tostring(Util.Now())))
  local records = ns.Pool.ShareSample(rounds, since, Comm.SAMPLE_SIZE, rng, sender)
  local builds, floor = {}, ns.MIN_DATA_VERSION
  for _, rec in ipairs(records) do
    builds[#builds + 1] = Util.DeepCopy(rec.b)
    if rec.m then floor = math.max(floor, rec.m) end
  end
  return builds, floor
end

local function respondToRequest(sender, rounds, id, since, direct)
  if not direct then
    local chance = math.min(1, 3 / math.max(1, Comm.PeerCount()))
    if math.random() > chance then return end
  end
  timer(math.random() * 5, function()
    local builds, floor = sampleFor(sender, rounds, since)
    if #builds == 0 then traffic("Nothing to send " .. readable(sender) .. ".") return end
    send({ t = "S", p = ns.PROTOCOL_VERSION, id = id, b = builds, m = floor }, "WHISPER", sender)
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
  local senderFull = Peers.FullName(sender)
  local source = " from " .. readable(senderFull) .. " via " .. readable(distribution, 16) .. ", " .. tostring(type(text) == "string" and #text or 0) .. " bytes."
  if not rateOk(senderFull) then traffic("Rejected message" .. source .. " Rate limited.") return end
  local decoded, tbl = pcall(ns.Snapshot.Decode, text)
  if not decoded or type(tbl) ~= "table" then traffic("Rejected message" .. source .. " Malformed message.") return end
  if tbl.k == Comm.session then
    Peers.RememberSelfName(senderFull)
    traffic("Ignored own echo" .. source)
    return
  end
  if tbl.p ~= ns.PROTOCOL_VERSION then
    Peers.SetCompatible(senderFull, false)
    traffic("Rejected message" .. source .. " Protocol version mismatch.")
    return
  end
  local now = Util.Now()
  if tbl.t == "B" and type(tbl.b) == "table" then
    tbl.b.n = senderFull
    tbl.b.bot = nil
    local added, why = ns.Pool.Add(tbl.b, { firsthand = true, now = now, floor = tbl.m })
    if added or why == "duplicate" then Peers.Heard(senderFull, now) end
    if why == "data version" then Peers.SetCompatible(senderFull, false) end
    local outcome = added and "Stored." or why == "duplicate" and "Duplicate." or "Rejected: " .. readable(why, 96) .. "."
    traffic("Received " .. buildSummary(tbl.b) .. source .. " " .. outcome)
    ns.Debug("build from", senderFull, added and "stored" or why)
    if added and ns.UI.Main and ns.UI.Main.OnPoolChanged then ns.UI.Main.OnPoolChanged() end
  elseif tbl.t == "H" then
    ns.CommVersion.Note(tbl.a)
    if not ns.Snapshot.DataCompatible(tbl.d, tbl.m) then
      Peers.SetCompatible(senderFull, false)
      traffic("Rejected Hello" .. source .. " Data version mismatch.")
      return
    end
    Peers.Heard(senderFull, now)
    Peers.NoteIntroductions(tbl.i, now)
    traffic("Received Hello" .. source)
    ns.Debug("hello from", senderFull)
    if distribution == "WHISPER" then
      local rec = Peers.Get(senderFull)
      if not rec.hello or now - rec.hello >= 60 then
        if send(hello(senderFull), "WHISPER", senderFull) then rec.hello = now end
      end
    end
  elseif tbl.t == "R" and type(tbl.r) == "table" then
    if not ns.Snapshot.DataCompatible(tbl.d, tbl.m) then
      Peers.SetCompatible(senderFull, false)
      traffic("Rejected Request" .. source .. " Data version mismatch.")
      return
    end
    local rounds = requestedRounds(tbl.r)
    if not rounds then traffic("Rejected Request" .. source .. " Invalid rounds.") return end
    Peers.Heard(senderFull, now)
    traffic("Received " .. messageSummary(tbl) .. source)
    respondToRequest(senderFull, rounds, requestId(tbl.id), sinceTime(tbl.s), distribution == "WHISPER")
  elseif tbl.t == "S" and type(tbl.b) == "table" then
    if not solicited(distribution, senderFull, tbl.id, now) then traffic("Rejected Sample" .. source .. " Not a reply to our request.") return end
    local mine = Comm.SelfNames()
    local stored, duplicate, own, rejected = 0, 0, 0, math.max(0, #tbl.b - Comm.SAMPLE_SIZE)
    for i = 1, math.min(#tbl.b, Comm.SAMPLE_SIZE) do
      local b = tbl.b[i]
      if type(b) ~= "table" then
        rejected = rejected + 1
      elseif mine[b.n] then
        own = own + 1
      else
        b.bot = nil
        local added, why = ns.Pool.Add(b, { firsthand = false, now = now, floor = tbl.m })
        if added then stored = stored + 1
        elseif why == "duplicate" then duplicate = duplicate + 1
        else rejected = rejected + 1 end
      end
    end
    if stored > 0 or duplicate > 0 or own > 0 then Peers.Heard(senderFull, now) end
    traffic("Received " .. messageSummary(tbl) .. source .. " Stored " .. stored .. ", duplicate " .. duplicate .. ", own " .. own .. ", rejected " .. rejected .. ".")
    ns.Debug("sample from", senderFull, "stored", stored)
    if stored > 0 and ns.UI.Main and ns.UI.Main.OnPoolChanged then ns.UI.Main.OnPoolChanged() end
  else
    traffic("Rejected message" .. source .. " Malformed message.")
  end
end
