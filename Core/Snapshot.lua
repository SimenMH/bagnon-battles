local ADDON, ns = ...
local Util = ns.Util

local Snapshot = {}
ns.Snapshot = Snapshot

Snapshot.MAX_CHANNEL_PAYLOAD = 4000
Snapshot.MAX_SERIALIZED = 262144

local FIELDS = { v = true, d = true, c = true, r = true, w = true, l = true, s = true,
  n = true, g = true, i = true, b = true, p = true, bot = true }

local function libs()
  local LibStub = _G.LibStub
  if not LibStub then return nil end
  return LibStub("LibSerialize", true), LibStub("LibDeflate", true)
end

function Snapshot.FromRun(run, who, now)
  local g, i, home = run.grid:Serialize()
  local classDef = ns.GetClass(run.class)
  return {
    v = ns.PROTOCOL_VERSION, d = ns.DATA_VERSION,
    c = classDef.id, r = run.round, w = run.wins, l = run.losses,
    s = now or Util.Now(), n = who or run.who or "Unknown",
    g = g, i = i, b = home, p = ns.Mastery.Pack(run.class, run.talents),
  }
end

function Snapshot.Canonical(tbl)
  local parts = { tostring(tbl.c), tostring(tbl.r), tostring(tbl.n or "") }
  parts[#parts + 1] = tostring(tbl.b and tbl.b[1]) .. "," .. tostring(tbl.b and tbl.b[2])
  local class = ns.ClassesById[tbl.c]
  local talents = class and ns.Mastery.Unpack(class.key, tbl.r, tbl.p)
  parts[#parts + 1] = table.concat(class and ns.Mastery.Pack(class.key, talents) or { 0, 0, 0 }, ",")
  local g = tbl.g or {}
  for n = 1, #g do parts[#parts + 1] = tostring(g[n]) end
  parts[#parts + 1] = "|"
  local items = {}
  local i = tbl.i or {}
  for n = 1, #i, 4 do items[#items + 1] = { i[n], i[n + 1], i[n + 2], i[n + 3] } end
  table.sort(items, function(a, b)
    if a[2] ~= b[2] then return a[2] < b[2] end
    if a[3] ~= b[3] then return a[3] < b[3] end
    if a[1] ~= b[1] then return a[1] < b[1] end
    return a[4] < b[4]
  end)
  for _, it in ipairs(items) do
    parts[#parts + 1] = table.concat({ tostring(it[1]), tostring(it[2]), tostring(it[3]), tostring(it[4]) }, ",")
  end
  return table.concat(parts, ";")
end

function Snapshot.Hash(tbl)
  return Util.HashHex(Snapshot.Canonical(tbl))
end

local function isInt(v, lo, hi)
  if type(v) ~= "number" or v ~= v or v == math.huge or v == -math.huge or v ~= math.floor(v) then return false end
  if lo and v < lo then return false end
  if hi and v > hi then return false end
  return true
end

local function placementArray(value, limit)
  if type(value) ~= "table" then return false end
  local count, last = 0, 0
  for index, entry in pairs(value) do
    if not isInt(index, 1, limit) or not isInt(entry, 0) then return false end
    count = count + 1
    last = math.max(last, index)
  end
  return count == last and count % 4 == 0
end

local function validAuthor(name)
  if type(name) ~= "string" or #name == 0 or #name > 64 then return false end
  local index, visible = 1, false
  while index <= #name do
    local first = name:byte(index)
    local length = first < 128 and 1 or first >= 194 and first <= 223 and 2
      or first >= 224 and first <= 239 and 3 or first >= 240 and first <= 244 and 4
    if not length or index + length - 1 > #name then return false end
    local code = first % (2 ^ (8 - length - (length > 1 and 1 or 0)))
    for offset = 1, length - 1 do
      local byte = name:byte(index + offset)
      if byte < 128 or byte > 191 then return false end
      code = code * 64 + byte - 128
    end
    if length == 3 and code < 2048 or length == 4 and code < 65536
      or code >= 55296 and code <= 57343 or code > 1114111
      or code < 32 or code >= 127 and code <= 159 or code == 124 then return false end
    local space = code == 32 or code == 160 or code == 5760 or code >= 8192 and code <= 8202
      or code == 8232 or code == 8233 or code == 8239 or code == 8287 or code == 12288 or code == 65279
    if not space then visible = true end
    index = index + length
  end
  return visible
end

function Snapshot.Validate(tbl, now)
  if type(tbl) ~= "table" then return false, "not a table" end
  for key in pairs(tbl) do if not FIELDS[key] then return false, "unknown snapshot field" end end
  if not isInt(tbl.v) or tbl.v ~= ns.PROTOCOL_VERSION then return false, "protocol version" end
  if not isInt(tbl.d, ns.MIN_DATA_VERSION, ns.DATA_VERSION) then return false, "data version" end
  if not isInt(tbl.c, 1) then return false, "unknown class" end
  local classDef = ns.ClassesById[tbl.c]
  if not classDef or not classDef.playable then return false, "unknown class" end
  if not isInt(tbl.r, 1, ns.Economy.ROUNDS) then return false, "round" end
  local talents, talentError = ns.Mastery.Unpack(classDef.key, tbl.r, tbl.p)
  if not talents then return false, talentError end
  if not isInt(tbl.s, 0) then return false, "timestamp" end
  if now == nil then now = Util.Now() end
  if type(now) ~= "number" or now ~= now or now == math.huge or now == -math.huge then return false, "timestamp" end
  if tbl.s > now + 600 then return false, "timestamp in the future" end
  if not validAuthor(tbl.n) then return false, "author" end
  if tbl.bot ~= nil and type(tbl.bot) ~= "boolean" then return false, "bot flag" end
  if not placementArray(tbl.g, ns.MAX_BAGS * 4) then return false, "bag data" end
  if not placementArray(tbl.i, ns.GRID_W * ns.GRID_H * 4) then return false, "item data" end
  if not ns.Grid.ValidHome(tbl.b) then return false, "backpack position" end
  local grid, err = ns.Grid.Deserialize(tbl.g, tbl.i, classDef.key, tbl.b)
  if not grid then return false, err end
  local reachable, reason = ns.BuildValidation.Check(classDef, tbl.r, grid, tbl)
  if not reachable then return false, reason end
  return true, nil, grid
end

function Snapshot.Encode(tbl)
  local LibSerialize, LibDeflate = libs()
  if not LibSerialize or not LibDeflate then return nil, "libraries missing" end
  local serialized = LibSerialize:Serialize(tbl)
  local compressed = LibDeflate:CompressDeflate(serialized, { level = 6 })
  return LibDeflate:EncodeForWoWAddonChannel(compressed)
end

function Snapshot.Decode(str)
  local LibSerialize, LibDeflate = libs()
  if not LibSerialize or not LibDeflate then return nil, "libraries missing" end
  if type(str) ~= "string" or #str == 0 or #str > Snapshot.MAX_CHANNEL_PAYLOAD then return nil, "bad payload" end
  local compressed = LibDeflate:DecodeForWoWAddonChannel(str)
  if not compressed then return nil, "decode failed" end
  local serialized = LibDeflate:DecompressDeflate(compressed)
  if not serialized or #serialized > Snapshot.MAX_SERIALIZED then return nil, "decompress failed" end
  local ok, tbl = LibSerialize:Deserialize(serialized)
  if not ok or type(tbl) ~= "table" then return nil, "deserialize failed" end
  return tbl
end
