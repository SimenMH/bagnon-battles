local ADDON, ns = ...
local Util = ns.Util

local Peers = {}
ns.CommPeers = Peers

Peers.records = {}
Peers.OFFLINE_WINDOW = 600
Peers.KNOWN_WINDOW = 2 * 60 * 60
Peers.INTRODUCTIONS = 5

local guild = {}
local selfNameSeen = false
local rosterRequest

local function online(rec, now)
  return rec.compatible == true and rec.seen ~= nil and now - rec.seen < ns.Pool.LIVE_WINDOW
    and not (rec.offline and rec.offline >= rec.seen)
end

local function displayChannel(channelNumber)
  if type(channelNumber) ~= "number" or channelNumber <= 0 or not GetNumDisplayChannels or not GetChannelDisplayInfo then return nil end
  for index = 1, GetNumDisplayChannels() do
    local _, header, _, number, count = GetChannelDisplayInfo(index)
    if not header and number == channelNumber then return index, count or 0 end
  end
end

local function channelIdentity(index)
  if index == 0 then return { empty = true } end
  if not index or not GetChannelDisplayInfo then return nil end
  local name, header, _, number, _, _, category, kind = GetChannelDisplayInfo(index)
  if not name then return nil end
  return { name = name, header = header, number = number, category = category, kind = kind }
end

local function sameChannel(a, b)
  return a and b and a.name == b.name and a.header == b.header and a.category == b.category and a.kind == b.kind
end

local function findChannel(identity)
  if identity.empty then return 0 end
  local fallback
  for index = 1, GetNumDisplayChannels() do
    local current = channelIdentity(index)
    if sameChannel(current, identity) then
      if current.number == identity.number then return index end
      fallback = index
    end
  end
  return fallback
end

local function selectedChannel()
  return GetSelectedDisplayChannel and channelIdentity(GetSelectedDisplayChannel())
end

local function restoreRoster(request)
  if rosterRequest ~= request then return end
  rosterRequest = nil
  local selected = selectedChannel()
  if request.previous and sameChannel(selected, request.target) and not sameChannel(selected, request.previous) then
    local previous = findChannel(request.previous)
    if previous ~= nil then pcall(SetSelectedDisplayChannel, previous) end
  end
end

local function activateRoster(request)
  local index = displayChannel(request.number)
  if not index or request.active then return end
  request.active = true
  if C_Timer and C_Timer.After then C_Timer.After(10, function() restoreRoster(request) end) end
  if GetSelectedDisplayChannel and SetSelectedDisplayChannel then
    request.previous, request.target = selectedChannel(), channelIdentity(index)
    local ok = pcall(SetSelectedDisplayChannel, index)
    if not ok then restoreRoster(request) end
  end
end

function Peers.FullName(sender)
  if type(sender) ~= "string" or sender == "" then return "Unknown" end
  if not ns.IS_FOREVER and not sender:find("-", 1, true) then
    local realm = GetNormalizedRealmName and GetNormalizedRealmName() or ""
    if realm ~= "" then return sender .. "-" .. realm end
  end
  return sender
end

function Peers.Canonical(name)
  if type(name) ~= "string" or name == "" then return nil end
  if not ns.IS_FOREVER then return Peers.FullName(name) end
  local realm = GetNormalizedRealmName and GetNormalizedRealmName() or ""
  if realm ~= "" and name:sub(-(#realm + 1)) == "-" .. realm then return name:sub(1, -(#realm + 2)) end
  return name
end

function Peers.RememberSelfName(name)
  if selfNameSeen or not ns.db then return end
  selfNameSeen = true
  local localName = ns.PlayerName()
  ns.db.global.selfNames[localName] = name ~= localName and name or nil
end

function Peers.SelfNames(who)
  local names = ns.db and ns.db.global.selfNames
  local excluded = {}
  local function add(name)
    if type(name) ~= "string" or name == "" then return end
    excluded[name] = true
    local alias = names and names[name]
    if alias then excluded[alias] = true end
  end
  add(who)
  add(ns.PlayerName())
  if ns.IS_FOREVER then
    add(GetUnitName and GetUnitName("player"))
    add(UnitName and UnitName("player"))
    local first, surname = UnitFullName("player")
    if first and surname and surname ~= "" then add(first .. "-" .. surname) end
  end
  return excluded
end

function Peers.Get(name)
  local rec = Peers.records[name]
  if not rec then
    rec = {}
    Peers.records[name] = rec
  end
  return rec
end

function Peers.Heard(name, now)
  local rec = Peers.Get(name)
  rec.seen, rec.offline, rec.compatible = now, nil, true
end

function Peers.SetCompatible(name, compatible)
  Peers.Get(name).compatible = compatible == true
end

function Peers.Available(rec, now)
  local last = math.max(rec.seen or 0, rec.present or 0, rec.introduced or 0)
  if last == 0 or now - last >= Peers.KNOWN_WINDOW then return false end
  return not (rec.offline and rec.offline >= last and now - rec.offline < Peers.OFFLINE_WINDOW)
end

function Peers.Targets(limit, accept, discovery)
  local now, mine = Util.Now(), Peers.SelfNames()
  local tiers = { {}, {}, {}, {}, {}, {} }
  for name, rec in pairs(Peers.records) do
    if not mine[name] and Peers.Available(rec, now) and (discovery or rec.compatible ~= false)
      and (not accept or accept(rec, now)) then
      local offset = not discovery and rec.compatible ~= true and 3 or 0
      local tier = tiers[offset + (guild[name] and 1 or online(rec, now) and 2 or 3)]
      tier[#tier + 1] = name
    end
  end
  local rng = Util.NewRNG(Util.Hash32(ns.PlayerName() .. tostring(now) .. tostring(GetTime and GetTime() or 0)))
  local out = {}
  for _, tier in ipairs(tiers) do
    rng:Shuffle(tier)
    for _, name in ipairs(tier) do
      if #out >= limit then return out end
      out[#out + 1] = name
    end
  end
  return out
end

function Peers.Introductions(exclude)
  local now, mine, out = Util.Now(), Peers.SelfNames(), {}
  for name, rec in pairs(Peers.records) do
    if #out >= Peers.INTRODUCTIONS then break end
    if name ~= exclude and not mine[name] and online(rec, now) then out[#out + 1] = name end
  end
  return out
end

function Peers.PeerCount()
  local count, now = 0, Util.Now()
  for _, rec in pairs(Peers.records) do
    if online(rec, now) then count = count + 1 end
  end
  return count
end

function Peers.PresentCount()
  local count, now = 0, Util.Now()
  for _, rec in pairs(Peers.records) do
    if rec.present and now - rec.present < Peers.KNOWN_WINDOW then count = count + 1 end
  end
  return count
end

function Peers.IsOnline(name)
  local rec = Peers.records[name]
  return rec ~= nil and online(rec, Util.Now())
end

function Peers.InGuild(name)
  return guild[name] == true
end

function Peers.ReadGuild()
  guild = {}
  if not IsInGuild or not IsInGuild() or not GetNumGuildMembers or not GetGuildRosterInfo then return end
  for i = 1, GetNumGuildMembers() do
    local name = Peers.Canonical((GetGuildRosterInfo(i)))
    if name then guild[name] = true end
  end
end

function Peers.RequestGuild()
  if C_GuildInfo and C_GuildInfo.GuildRoster then
    C_GuildInfo.GuildRoster()
  elseif GuildRoster then
    GuildRoster()
  end
  Peers.ReadGuild()
end

function Peers.ReadRoster(channelNumber, eventIndex)
  if not C_ChatInfo or not C_ChatInfo.GetChannelRosterInfo then return 0 end
  local index, total = displayChannel(channelNumber)
  if not index or eventIndex and eventIndex ~= index then return 0 end
  local now, mine, count, loaded = Util.Now(), Peers.SelfNames(), 0, 0
  for i = 1, total do
    local name = Peers.Canonical((C_ChatInfo.GetChannelRosterInfo(index, i)))
    if name then
      loaded = loaded + 1
      if not mine[name] then
        Peers.Get(name).present = now
        count = count + 1
      end
    end
  end
  local request = rosterRequest
  if request and request.number == channelNumber and loaded == total and (total > 0 or eventIndex == index) then
    restoreRoster(request)
  end
  return count
end

function Peers.RequestRoster(channelNumber)
  Peers.CancelRoster()
  local count = Peers.ReadRoster(channelNumber)
  if type(channelNumber) ~= "number" or channelNumber <= 0 then return count end
  local request = { number = channelNumber }
  rosterRequest = request
  activateRoster(request)
  return count
end

function Peers.RefreshRoster(channelNumber)
  local request = rosterRequest
  if not request or request.number ~= channelNumber then return 0 end
  if request.active and request.target and not sameChannel(selectedChannel(), request.target) then
    restoreRoster(request)
    return 0
  end
  activateRoster(request)
  return Peers.ReadRoster(channelNumber)
end

function Peers.CancelRoster()
  local request = rosterRequest
  if request then restoreRoster(request) end
end

function Peers.NoteIntroductions(list, now)
  if type(list) ~= "table" then return end
  local mine = Peers.SelfNames()
  for index, name in ipairs(list) do
    if index > Peers.INTRODUCTIONS then break end
    if type(name) == "string" and #name > 0 and #name <= 64 and not name:find("[%c|]") then
      name = Peers.Canonical(name)
      if name and not mine[name] then Peers.Get(name).introduced = now end
    end
  end
end

function Peers.Joined(name)
  name = Peers.Canonical(name)
  if not name or Peers.SelfNames()[name] then return false end
  local rec = Peers.Get(name)
  rec.present, rec.offline, rec.compatible, rec.hello = Util.Now(), nil, nil, nil
  return true
end

function Peers.Left(name)
  local rec = Peers.records[Peers.Canonical(name)]
  if rec then rec.present = nil end
end

function Peers.MarkOffline(name)
  local rec = Peers.records[name]
  if rec then rec.offline = Util.Now() end
end
