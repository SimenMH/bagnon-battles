local ADDON, ns = ...
local Util = {}
ns.Util = Util

local floor, max, min = math.floor, math.max, math.min

local RNG = {}
RNG.__index = RNG
local MODULUS = 2147483647
local MULT    = 16807

function Util.NewRNG(seed)
  seed = floor(math.abs(tonumber(seed) or 1)) % MODULUS
  if seed == 0 then seed = 1 end
  return setmetatable({ state = seed }, RNG)
end

function RNG:Next()
  self.state = (self.state * MULT) % MODULUS
  return (self.state - 1) / (MODULUS - 1)
end

function RNG:Range(lo, hi)
  if hi <= lo then return lo end
  return lo + floor(self:Next() * (hi - lo + 1))
end

function RNG:Chance(pct)
  return self:Next() * 100 < pct
end

function RNG:Pick(list)
  if #list == 0 then return nil end
  return list[self:Range(1, #list)]
end

function RNG:PickWeighted(entries)
  local total = 0
  for i = 1, #entries do total = total + (entries[i].weight or 0) end
  if total <= 0 then return nil end
  local roll = self:Next() * total
  local acc = 0
  for i = 1, #entries do
    acc = acc + (entries[i].weight or 0)
    if roll < acc then return entries[i].value, i end
  end
  return entries[#entries].value, #entries
end

function RNG:Shuffle(list)
  for i = #list, 2, -1 do
    local j = self:Range(1, i)
    list[i], list[j] = list[j], list[i]
  end
  return list
end

local TWO32 = 4294967296
function Util.Hash32(str)
  local h = 5381
  for i = 1, #str do
    h = (h * 33 + string.byte(str, i)) % TWO32
  end
  return h
end

function Util.HashHex(str)
  local h = Util.Hash32(str)
  return string.format("%04x%04x", floor(h / 65536), h % 65536)
end

function Util.DeepCopy(value, seen)
  if type(value) ~= "table" then return value end
  seen = seen or {}
  if seen[value] then return seen[value] end
  local out = {}
  seen[value] = out
  for k, v in pairs(value) do out[Util.DeepCopy(k, seen)] = Util.DeepCopy(v, seen) end
  return setmetatable(out, getmetatable(value))
end

function Util.ShallowCopy(t)
  local out = {}
  for k, v in pairs(t) do out[k] = v end
  return out
end

function Util.SortedKeys(t)
  local keys = {}
  for k in pairs(t) do keys[#keys + 1] = k end
  table.sort(keys, function(a, b)
    local ta, tb = type(a), type(b)
    if ta == tb then return a < b end
    return ta < tb
  end)
  return keys
end

function Util.Count(t)
  local n = 0
  for _ in pairs(t) do n = n + 1 end
  return n
end

function Util.Set(list)
  local s = {}
  for i = 1, #list do s[list[i]] = true end
  return s
end

function Util.Clamp(v, lo, hi)
  return max(lo, min(hi, v))
end

function Util.Round(v)
  return floor(v + 0.5)
end

function Util.Trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

Util.MATCH_FIELDS = Util.Set{ "hands", "kind", "key", "tag", "notTag", "damaging", "anyTag", "weaponType", "anyWeaponType",
  "slot", "set", "quality", "minQuality", "notKind" }

function Util.MatchDef(def, filter)
  if not filter then return true end
  if filter.hands and def.hands ~= filter.hands then return false end
  if filter.kind and def.kind ~= filter.kind then return false end
  if filter.key and def.key ~= filter.key and def.baseKey ~= filter.key then return false end
  if filter.tag and not (def.tagSet and def.tagSet[filter.tag]) then return false end
  if filter.notTag and def.tagSet and def.tagSet[filter.notTag] then return false end
  if filter.damaging then
    local damaging = false
    for _, effect in ipairs(def.use and def.use.effects or {}) do
      if effect.type == "damage" or (effect.type == "dot" and filter.damaging ~= "direct") then damaging = true break end
    end
    if not damaging then return false end
  end
  if filter.anyTag then
    local ok = false
    for i = 1, #filter.anyTag do
      if def.tagSet and def.tagSet[filter.anyTag[i]] then ok = true break end
    end
    if not ok then return false end
  end
  if filter.weaponType and def.weaponType ~= filter.weaponType then return false end
  if filter.anyWeaponType then
    local ok = false
    for i = 1, #filter.anyWeaponType do
      if def.weaponType == filter.anyWeaponType[i] then ok = true break end
    end
    if not ok then return false end
  end
  if filter.slot and def.slot ~= filter.slot then return false end
  if filter.set and def.set ~= filter.set then return false end
  if filter.quality and def.quality ~= filter.quality then return false end
  if filter.minQuality and (def.quality or 1) < filter.minQuality then return false end
  if filter.notKind and def.kind == filter.notKind then return false end
  return true
end

function Util.Now()
  if GetServerTime then return GetServerTime() end
  return os.time()
end

function Util.FormatPct(n)
  if n == floor(n) then return string.format("%d%%", n) end
  return (string.format("%.2f", n):gsub("0+$", ""):gsub("%.$", "")) .. "%"
end
