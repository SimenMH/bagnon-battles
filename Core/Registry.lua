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

local VALID_KINDS = Util.Set{ "bag", "weapon", "shield", "armor", "ring", "trinket", "neck", "relic",
  "cloak", "ability", "form", "pet", "ammo", "material", "consumable" }

ns.RANGED_WEAPON_TYPES = Util.Set{ "bow", "gun", "crossbow", "wand" }

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

function ns.RegisterItem(def)
  assert(type(def.id) == "number", "item needs numeric id")
  assert(type(def.key) == "string", "item needs key")
  assert(not ns.Items[def.id], "duplicate item id " .. def.id .. " (" .. def.key .. ")")
  assert(not ns.ItemsByKey[def.key], "duplicate item key " .. def.key)
  assert(VALID_KINDS[def.kind], "unknown kind " .. tostring(def.kind) .. " for " .. def.key)
  assert(def.shape, "item " .. def.key .. " needs a shape")

  def.name     = def.name or def.key
  def.quality  = def.quality or 1
  def.minRound = def.minRound or 1
  def.tags     = def.tags or {}
  def.tagSet   = Util.Set(def.tags)
  def.stats    = def.stats or {}
  def.icon     = def.icon or "Interface\\Icons\\INV_Misc_QuestionMark"
  def.rots, def.distinctRots = ns.BuildRotations(def.shape)
  def.cellCount = #def.rots[1].cells
  def.cost     = def.cost or ns.DefaultCost(def)
  if def.classes then
    def.classSet = Util.Set(def.classes)
  end
  if def.shopClasses then def.shopClassSet = Util.Set(def.shopClasses) end
  if def.kind == "bag" then
    def.bagType = def.bagType or "bag"
  end
  if def.use then
    def.use.cd = def.use.cd or 2.0
    def.use.effects = def.use.effects or {}
  end
  def.triggers  = def.triggers or {}
  def.adjacency = def.adjacency or {}
  if not def.use and #def.triggers > 0 then def.passiveTriggers = true end

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

local function checkMatch(problems, owner, match)
  if match == nil then return end
  if type(match) ~= "table" then problems[#problems + 1] = owner .. " has an invalid match" return end
  for field in pairs(match) do
    if not Util.MATCH_FIELDS[field] then problems[#problems + 1] = owner .. " matches unknown field " .. tostring(field) end
  end
  if match.key ~= nil and not ns.ItemsByKey[match.key] then problems[#problems + 1] = owner .. " matches unknown item " .. tostring(match.key) end
  if match.set ~= nil and not ns.Sets[match.set] then problems[#problems + 1] = owner .. " matches unknown set " .. tostring(match.set) end
end

local function checkCondition(problems, owner, condition)
  if condition ~= nil and not ns.Sim.ValidCondition(condition) then
    problems[#problems + 1] = owner .. " has unknown condition " .. tostring(condition)
  end
end

local function checkEffects(problems, owner, effects)
  for _, e in ipairs(effects or {}) do
    if not ns.Sim.EFFECT_TYPES[e.type] then problems[#problems + 1] = owner .. " has unknown effect type " .. tostring(e.type) end
    checkCondition(problems, owner, e.cond)
    checkCondition(problems, owner, e.critIf)
    checkMatch(problems, owner, e.match)
    if ns.Sim.ITEM_KEY_EFFECTS[e.type] and e.key ~= nil and not ns.ItemsByKey[e.key] then
      problems[#problems + 1] = owner .. " targets unknown item " .. tostring(e.key)
    end
    if e.effects then checkEffects(problems, owner, e.effects) end
  end
end

local function checkTriggers(problems, owner, triggers)
  for _, trigger in ipairs(triggers or {}) do
    if not ns.Sim.TRIGGER_EVENTS[trigger.on] then problems[#problems + 1] = owner .. " has unknown trigger " .. tostring(trigger.on) end
    checkCondition(problems, owner, trigger.condition)
    checkMatch(problems, owner, trigger.match)
    checkEffects(problems, owner, trigger.effects)
  end
end

local function checkBotPlans(problems)
  for _, classKey in ipairs(Util.SortedKeys(ns.Bots.ARCHETYPES)) do
    for _, plan in ipairs(ns.Bots.ARCHETYPES[classKey]) do
      local lists = {}
      for _, field in ipairs({ "core", "support", "train", "payoff", "equipment" }) do
        if plan[field] then lists[#lists + 1] = plan[field] end
      end
      for _, options in ipairs(plan.weapons or {}) do lists[#lists + 1] = options end
      for _, options in ipairs(plan.gear or {}) do lists[#lists + 1] = options end
      for _, list in ipairs(lists) do
        for key in list:gmatch("%S+") do
          local def = ns.ItemsByKey[key]
          if not def then
            problems[#problems + 1] = "bot plan " .. tostring(plan.id) .. " uses unknown item " .. key
          elseif not ns.ItemAllowedForClass(def, classKey) then
            problems[#problems + 1] = "bot plan " .. tostring(plan.id) .. " uses " .. key .. " unavailable to " .. classKey
          end
        end
      end
    end
  end
end

function ns.ValidateRegistry()
  local problems = {}
  local abilityKinds = { ability = true, form = true, pet = true, ammo = true }
  for i = 1, #ns.ItemList do
    local def = ns.ItemList[i]
    if def.use then
      checkCondition(problems, def.key, def.use.condition)
      checkEffects(problems, def.key, def.use.effects)
    end
    checkTriggers(problems, def.key, def.triggers)
    for _, rule in ipairs(def.adjacency) do checkMatch(problems, def.key, rule.match) end
    for _, c in ipairs(def.shopClasses or {}) do
      if not ns.Classes[c] then problems[#problems + 1] = def.key .. " is offered to unknown class " .. tostring(c) end
    end
    if ns.RETIRED_IDS and ns.RETIRED_IDS[def.id] then
      problems[#problems + 1] = def.key .. " reuses retired id " .. def.id
    end
    if def.set and not ns.Sets[def.set] then
      problems[#problems + 1] = def.key .. " references unknown set " .. def.set
    end
    if def.classes then
      for _, c in ipairs(def.classes) do
        if not ns.Classes[c] then problems[#problems + 1] = def.key .. " references unknown class " .. c end
      end
    end
    if def.shopRequires ~= nil then
      local requires = def.shopRequires
      if type(requires) ~= "table" or #requires == 0 then
        problems[#problems + 1] = def.key .. " has invalid shop prerequisites"
      else
        local seen = {}
        for index in pairs(requires) do
          if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > #requires then
            problems[#problems + 1] = def.key .. " has malformed shop prerequisites"
          end
        end
        for index = 1, #requires do
          local key = requires[index]
          local target = type(key) == "string" and ns.ItemsByKey[key]
          if not target then
            problems[#problems + 1] = def.key .. " references unknown shop prerequisite " .. tostring(key)
          elseif not abilityKinds[target.kind] or target.rank then
            problems[#problems + 1] = def.key .. " requires a base ability family for " .. key
          elseif key == (def.baseKey or def.key) then
            problems[#problems + 1] = def.key .. " requires itself in the shop"
          elseif seen[key] then
            problems[#problems + 1] = def.key .. " repeats shop prerequisite " .. key
          else
            for _, class in ipairs(ns.ClassList) do
              if ns.ItemAllowedForClass(def, class.key) and not ns.ItemAllowedForClass(target, class.key) then
                problems[#problems + 1] = def.key .. " requires " .. key .. " unavailable to " .. class.key
              end
            end
          end
          if type(key) == "string" then seen[key] = true end
        end
      end
    end
  end
  local visited = {}
  local function visit(def)
    if visited[def.key] == 1 then
      problems[#problems + 1] = def.key .. " has a shop prerequisite cycle"
      return
    end
    if visited[def.key] == 2 then return end
    visited[def.key] = 1
    for _, key in ipairs(type(def.shopRequires) == "table" and def.shopRequires or {}) do
      local target = type(key) == "string" and ns.ItemsByKey[key]
      if target and not target.rank then visit(target) end
    end
    visited[def.key] = 2
  end
  for _, def in ipairs(ns.ItemList) do if not def.rank then visit(def) end end
  for _, recipe in ipairs(ns.Recipes) do
    for _, key in ipairs(recipe.inputs) do
      if not ns.ItemsByKey[key] then problems[#problems + 1] = "recipe input missing: " .. key end
    end
    if not ns.ItemsByKey[recipe.output] then problems[#problems + 1] = "recipe output missing: " .. recipe.output end
  end
  for _, class in ipairs(ns.ClassList) do
    for _, entry in ipairs(class.starter or {}) do
      if not ns.ItemsByKey[entry.key] then problems[#problems + 1] = class.key .. " starts with unknown item " .. tostring(entry.key) end
    end
    for _, spec in ipairs(class.specs) do
      if spec.signature and not ns.ItemsByKey[spec.signature] then
        problems[#problems + 1] = class.key .. " " .. spec.tag .. " has unknown signature " .. spec.signature
      end
      local tree = ns.Mastery.Definition(class.key, spec.tag)
      for _, tier in ipairs(tree and tree.tiers or {}) do checkTriggers(problems, class.key .. " " .. spec.tag .. " talents", tier.triggers) end
    end
  end
  for _, key in ipairs(Util.SortedKeys(ns.Sets)) do
    local set, pieces = ns.Sets[key], #ns.SetPieces(key)
    for _, threshold in ipairs(set.thresholds) do
      if threshold > pieces then problems[#problems + 1] = key .. " has a " .. threshold .. "-piece bonus but " .. pieces .. " pieces" end
      checkTriggers(problems, key .. " set bonus", set.bonuses[threshold].triggers)
    end
  end
  checkBotPlans(problems)
  return problems
end
