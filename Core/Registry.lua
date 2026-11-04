local ADDON, ns = ...
local Util = ns.Util

ns.Items       = {}
ns.ItemsByKey  = {}
ns.ItemList    = {}
ns.Sets        = {}
ns.Classes     = {}
ns.ClassList   = {}
ns.ClassesById = {}
ns.Recipes     = {}

local DEFAULT_COST = { 3, 5, 7, 10, 15 }
local VALID_KINDS = Util.Set{ "bag", "weapon", "shield", "armor", "ring", "trinket", "neck", "relic",
  "cloak", "ability", "form", "pet", "ammo", "material", "consumable" }

ns.RANGED_WEAPON_TYPES = Util.Set{ "bow", "gun", "crossbow", "wand" }

function ns.DefaultCost(def)
  if def.kind == "bag" then
    if def.cellCount <= 8 then return def.cellCount end
    return math.floor(def.cellCount * 1.25 + 0.5)
  end
  local cost = DEFAULT_COST[def.quality] or 3
  if def.cellCount >= 4 then cost = cost + 1 end
  if def.cellCount >= 6 then cost = cost + 1 end
  if def.kind == "weapon" and def.hands == 2 then cost = cost + 1 end
  return cost
end

local function cellsFromRows(rows)
  local cells = {}
  for y = 1, #rows do
    local row = rows[y]
    for x = 1, #row do
      if row:sub(x, x) == "1" then cells[#cells + 1] = { x - 1, y - 1 } end
    end
  end
  return cells
end

local function normalise(cells)
  local minX, minY = math.huge, math.huge
  for i = 1, #cells do
    if cells[i][1] < minX then minX = cells[i][1] end
    if cells[i][2] < minY then minY = cells[i][2] end
  end
  local out, maxX, maxY = {}, 0, 0
  for i = 1, #cells do
    local x, y = cells[i][1] - minX, cells[i][2] - minY
    out[#out + 1] = { x, y }
    if x > maxX then maxX = x end
    if y > maxY then maxY = y end
  end
  table.sort(out, function(a, b)
    if a[2] ~= b[2] then return a[2] < b[2] end
    return a[1] < b[1]
  end)
  local sig = {}
  for i = 1, #out do sig[i] = out[i][1] .. ":" .. out[i][2] end
  return { cells = out, w = maxX + 1, h = maxY + 1, sig = table.concat(sig, ",") }
end

local function rotateOnce(rot)
  local cells = {}
  for i = 1, #rot.cells do
    local x, y = rot.cells[i][1], rot.cells[i][2]
    cells[#cells + 1] = { rot.h - 1 - y, x }
  end
  return normalise(cells)
end

function ns.BuildRotations(rows)
  local rots = {}
  rots[1] = normalise(cellsFromRows(rows))
  for r = 2, 4 do rots[r] = rotateOnce(rots[r - 1]) end
  local distinct = {}
  for r = 1, 4 do
    rots[r].distinct = true
    for p = 1, r - 1 do
      if rots[p].sig == rots[r].sig then rots[r].distinct = false break end
    end
    if rots[r].distinct then distinct[#distinct + 1] = r - 1 end
  end
  return rots, distinct
end

function ns.NextRotation(def, rot)
  for step = 1, 4 do
    local candidate = (rot + step) % 4
    if def.rots[candidate + 1].distinct then return candidate end
  end
  return rot
end

function ns.RotationCells(def, rot)
  return def.rots[(rot % 4) + 1]
end

function ns.IsRangedWeapon(def)
  return def.kind == "weapon" and ns.RANGED_WEAPON_TYPES[def.weaponType] == true
end

local function insertSorted(list, def)
  local lo, hi = 1, #list
  while lo <= hi do
    local mid = math.floor((lo + hi) / 2)
    if list[mid].id < def.id then lo = mid + 1 else hi = mid - 1 end
  end
  table.insert(list, lo, def)
end


function ns.EffectRules(def)
  local rules = {}
  for _, rule in ipairs(def and def.adjacency or {}) do rules[#rules + 1] = rule end
  if def and def.coating then rules[#rules + 1] = { match = { kind = "weapon", tag = "melee" }, coating = true, activeSource = true } end
  local function effects(list)
    for _, effect in ipairs(list or {}) do
      if effect.target == "neighbors" then
        local area = effect.area or {}
        local match = effect.match
        if effect.type == "cdr" or effect.type == "cast" then
          match = Util.ShallowCopy(match or {})
          match.usable = true
        end
        rules[#rules + 1] = { side = area.side, corners = area.corners, match = match }
      end
      if effect.effects then effects(effect.effects) end
    end
  end
  effects(def and def.use and def.use.effects)
  for _, trigger in ipairs(def and def.triggers or {}) do
    if trigger.on and trigger.on:find("^adjacent") then rules[#rules + 1] = { match = trigger.match,
      activeSource = trigger.on == "adjacentHit" or trigger.on == "adjacentCrit" } end
    effects(trigger.effects)
  end
  return rules
end



function ns.ResolveCoatings(grid, suppressed, inactiveActors)
  local candidates, sources, conflicts = {}, {}, {}
  for _, source in ipairs(grid.items) do
    local def = ns.Items[source.id]
    if def.coating and not (suppressed and suppressed[source.uid]) then
      sources[source.uid] = {}
      for _, weapon in ipairs(grid:EffectNeighbors(source)) do
        local wd = ns.Items[weapon.id]
        if wd.kind == "weapon" and wd.tagSet.melee and not (suppressed and suppressed[weapon.uid])
          and not (inactiveActors and inactiveActors[weapon.uid]) then
          candidates[weapon.uid] = candidates[weapon.uid] or {}
          candidates[weapon.uid][#candidates[weapon.uid] + 1] = source.uid
        end
      end
    end
  end
  for weapon, coatings in pairs(candidates) do
    if #coatings == 1 then sources[coatings[1]][weapon] = true
    else for _, source in ipairs(coatings) do conflicts[source] = conflicts[source] or {} conflicts[source][weapon] = true end end
  end
  return sources, conflicts
end

function ns.RefreshItemSpatialMetadata(def)
  def.rots, def.distinctRots = ns.BuildRotations(def.shape)
  def.cellCount = #def.rots[1].cells

  def.facing = nil
  for _, rule in ipairs(ns.EffectRules(def)) do
    if type(rule) == "table" and rule.side then
      def.facing = true
      def.distinctRots = { 0, 1, 2, 3 }
      for _, rotation in ipairs(def.rots) do rotation.distinct = true end
      break
    end
  end
end

function ns.RefreshItemMetadata(def)
  def.tagSet = Util.Set(def.tags or {})
  def.classSet = def.classes and Util.Set(def.classes) or nil
  def.shopClassSet = def.shopClasses and Util.Set(def.shopClasses) or nil
  if not def.use and #(def.triggers or {}) > 0 then def.passiveTriggers = true end
  ns.RefreshItemSpatialMetadata(def)
end

function ns.RegisterItem(def)
  assert(type(def.id) == "number", "item needs numeric id")
  assert(type(def.key) == "string", "item needs key")
  assert(not ns.Items[def.id], "duplicate item id " .. def.id .. " (" .. def.key .. ")")
  assert(not ns.ItemsByKey[def.key], "duplicate item key " .. def.key)
  assert(VALID_KINDS[def.kind], "unknown kind " .. tostring(def.kind) .. " for " .. def.key)
  assert(def.shape, "item " .. def.key .. " needs a shape")

  def.name     = def.name or def.key
  def.quality  = def.quality or 1
  if def.shopWeight == nil then def.shopWeight = 1 end
  def.minRound = def.minRound or 1
  def.tags     = def.tags or {}
  def.stats    = def.stats or {}
  def.icon     = def.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
  if def.kind == "bag" then
    def.bagType = def.bagType or "bag"
  end
  if def.use then
    def.use.cd = def.use.cd or 2.0
    def.use.effects = def.use.effects or {}
  end
  def.triggers  = def.triggers or {}
  def.adjacency = def.adjacency or {}
  ns.RefreshItemMetadata(def)
  def.cost = def.cost or ns.DefaultCost(def)

  ns.Items[def.id] = def
  ns.ItemsByKey[def.key] = def
  insertSorted(ns.ItemList, def)
  return def
end

function ns.ItemAllowedForClass(def, classKey)
  if not def.classSet then return true end
  return def.classSet[classKey] == true
end

function ns.ItemOfferedForClass(def, classKey)
  return ns.ItemAllowedForClass(def, classKey) and (not def.shopClassSet or def.shopClassSet[classKey] == true)
end

function ns.GetShopPool(classKey, round)
  local pool = {}
  for i = 1, #ns.ItemList do
    local def = ns.ItemList[i]
    if not def.noShop and def.minRound <= round and ns.ItemOfferedForClass(def, classKey) then
      pool[#pool + 1] = def
    end
  end
  return pool
end

function ns.RegisterSet(def)
  assert(def.key and def.name, "set needs key and name")
  def.bonuses = def.bonuses or {}
  def.thresholds = {}
  for n in pairs(def.bonuses) do def.thresholds[#def.thresholds + 1] = n end
  table.sort(def.thresholds)
  ns.Sets[def.key] = def
  return def
end

function ns.SetPieces(setKey)
  local pieces = {}
  for i = 1, #ns.ItemList do
    if ns.ItemList[i].set == setKey then pieces[#pieces + 1] = ns.ItemList[i] end
  end
  return pieces
end

function ns.RegisterClass(def)
  assert(def.key and def.id and def.name, "class needs key, id, name")
  def.specs = def.specs or {}
  ns.Classes[def.key] = def
  ns.ClassesById[def.id] = def
  ns.ClassList[#ns.ClassList + 1] = def
  table.sort(ns.ClassList, function(a, b) return a.order < b.order end)
  return def
end

function ns.GetClass(keyOrId)
  if type(keyOrId) == "number" then return ns.ClassesById[keyOrId] end
  return ns.Classes[keyOrId]
end

function ns.StarterValue(classDef)
  local total = 0
  for _, entry in ipairs(classDef.starter or {}) do
    local def = ns.ItemsByKey[entry.key]
    if def then total = total + def.cost end
  end
  return total
end

function ns.PlayableClasses()
  local out = {}
  for i = 1, #ns.ClassList do
    if ns.ClassList[i].playable then out[#out + 1] = ns.ClassList[i] end
  end
  return out
end

function ns.RegisterRecipe(def)
  assert(def.inputs and def.output, "recipe needs inputs and output")
  ns.Recipes[#ns.Recipes + 1] = def
  return def
end
