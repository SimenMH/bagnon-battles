local ADDON, ns = ...
local Util = ns.Util



local ShopWeights = {}
ns.ShopWeights = ShopWeights

ShopWeights.DIRECTED_SHARE = 0.45
ShopWeights.SIGNATURE_MULT = 2
ShopWeights.MISSING_FIT = 0.6

local ABILITY_KINDS = { ability = true, form = true, pet = true, ammo = true }
local GEAR_ROLES = {
  WARRIOR = { arms = { "ap" }, fury = { "ap" }, prot = { "ap", "block" } },
  HUNTER = { bm = { "ap" }, mm = { "ap" }, surv = { "ap", "sp" } },
  DRUID = { balance = { "sp" }, feral = { "ap" }, resto = { "healing" } },
  PALADIN = { holy = { "healing" }, protection = { "sp", "block" }, retribution = { "ap" } },
  ROGUE = { assassination = { "ap" }, combat = { "ap" }, subtlety = { "ap" } },
  PRIEST = { discipline = { "sp", "healing" }, holy = { "healing" }, shadow = { "sp" } },
  SHAMAN = { elemental = { "sp" }, enhancement = { "ap" }, restoration = { "healing" } },
  MAGE = { arcane = { "sp" }, fire = { "sp" }, frost = { "sp" } },
  WARLOCK = { affliction = { "sp" }, demonology = { "sp" }, destruction = { "sp" } },
}

local function positive(value)
  return type(value) == "number" and value == value and value > 0 and value < math.huge
end

local function classSpecs(classKey)
  local class = ns.GetClass(classKey)
  return class and class.specs or {}
end

function ShopWeights.Shares(classKey, talents)
  local shares, total = {}, 0
  for _, spec in ipairs(classSpecs(classKey)) do
    local points = type(talents) == "table" and talents[spec.tag] or 0
    points = positive(points) and points or 0
    shares[spec.tag], total = points, total + points
  end
  if total > 0 then
    for _, spec in ipairs(classSpecs(classKey)) do shares[spec.tag] = shares[spec.tag] / total end
  end
  return shares, total
end

function ShopWeights.BaseWeight(def, classKey)
  local weight = def.shopWeight == nil and 1 or def.shopWeight
  local multiplier = def.shopClassWeights and def.shopClassWeights[classKey] or 1
  assert(positive(weight) and positive(multiplier), "Shop encounter weights must be finite and positive")
  local result = weight * multiplier
  assert(positive(result), "Combined shop encounter weight must be finite and positive")
  return result
end

function ShopWeights.Affinity(def, classKey, spec)
  local authored = def.shopAffinities and def.shopAffinities[classKey]
  if authored then return authored[spec] or 0 end
  local tags = def.tagSet or Util.Set(def.tags or {})
  if ABILITY_KINDS[def.kind] then
    local combatSpec = ns.Mastery.Spec(def)
    if combatSpec then return combatSpec == spec and 1 or 0 end
    local tagged = false
    for _, ownSpec in ipairs(classSpecs(classKey)) do
      if tags[ownSpec.tag] then tagged = true break end
    end
    if tagged then return tags[spec] and 1 or 0 end
    return 0.5
  end
  if tags[spec] then return 1 end
  local roles = GEAR_ROLES[classKey]
  for _, stat in ipairs(roles and roles[spec] or {}) do
    if ((def.stats or {})[stat] or 0) > 0 then return 1 end
  end
  return 0
end

local function addDefinition(def, flags, resources)
  local provides = type(def.provides) == "table" and def.provides or { def.provides }
  for _, flag in ipairs(provides) do flags[flag] = true end
  for resource in pairs(def.grants or {}) do resources[resource] = true end
  if def.kind == "weapon" then
    flags.weapon = true
    flags[ns.IsRangedWeapon(def) and "ranged" or "melee"] = true
    if def.hands == 2 and not ns.IsRangedWeapon(def) then flags.twohand = true end
  elseif def.kind == "shield" then flags.shield = true
  elseif def.kind == "pet" then flags.pet = true
  elseif def.kind == "ammo" then flags.ammo = true end
end


local function weaponPower(def)
  return ((def.weaponMin or 0) + (def.weaponMax or 0)) / 2 / (def.use and def.use.cd or 2)
end

function ShopWeights.Context(classKey, grid, stash, ownedCounts, formPreference)
  local class = assert(ns.GetClass(classKey), "Unknown shop class: " .. tostring(classKey))
  local context = { classKey = classKey, active = {}, owned = {}, resources = {}, activeResources = {},
    activeKnown = grid ~= nil, formPreference = formPreference }
  for resource in pairs(class.resources or {}) do
    context.resources[resource], context.activeResources[resource] = true, true
  end
  local ownedDefinitions, oneHands = {}, 0
  local function own(id, amount)
    local def = ns.Items[id]
    if not def or ownedDefinitions[id] or not (amount == true or positive(amount)) then return end
    ownedDefinitions[id] = true
    addDefinition(def, context.owned, context.resources)
    if def.kind == "weapon" and not ns.IsRangedWeapon(def) and def.hands == 1 then oneHands = oneHands + 1 end
  end
  for id, amount in pairs(ownedCounts or {}) do own(id, amount) end
  for _, placement in ipairs(grid and grid.items or {}) do own(placement.id, 1) end
  for _, id in ipairs(stash or {}) do own(id, 1) end
  context.owned.dualwield = class.dualWield == true and oneHands >= 2



  local placements = {}
  for _, placement in ipairs(grid and grid.items or {}) do placements[#placements + 1] = placement end
  table.sort(placements, Util.PlacementLess)
  local exclusive, forms, melee, shields = {}, {}, {}, {}
  for _, placement in ipairs(placements) do
    local def = ns.Items[placement.id]
    if def then
      local suppressed = def.exclusiveGroup and exclusive[def.exclusiveGroup]
      if def.exclusiveGroup then exclusive[def.exclusiveGroup] = true end
      if def.kind == "form" then
        local slot = ns.Grid.EquipmentSlot(def)
        if slot then suppressed = suppressed or forms[slot] forms[slot] = true end
      end
      if not suppressed then
        addDefinition(def, context.active, context.activeResources)
        if def.kind == "weapon" and not ns.IsRangedWeapon(def) then melee[#melee + 1] = { def = def, order = #melee + 1 } end
        if def.kind == "shield" then shields[#shields + 1] = def end
      end
    end
  end
  table.sort(melee, function(a, b)
    if weaponPower(a.def) ~= weaponPower(b.def) then return weaponPower(a.def) > weaponPower(b.def) end
    return a.order < b.order
  end)
  local main = melee[1] and melee[1].def
  context.active.twohand = main ~= nil and main.hands == 2
  context.active.shield = #shields > 0 and not context.active.twohand
  local activeOneHands = 0
  for _, entry in ipairs(melee) do if entry.def.hands == 1 then activeOneHands = activeOneHands + 1 end end
  context.active.dualwield = class.dualWield == true and not context.active.shield
    and not context.active.twohand and activeOneHands >= 2
  if context.formPreference == nil and ns.Economy.FormPreference then
    context.formPreference = ns.Economy.FormPreference(grid, stash)
  end
  return context
end

local function matchesForm(def, form)
  local tag = form == "bearform" and "bear" or form == "catform" and "cat"
  return def.use and def.use.requires == form or tag and (def.tagSet or Util.Set(def.tags or {}))[tag]
end

function ShopWeights.Fit(def, context)
  if not context then return 1 end
  local mismatch, use = false, def.use
  local owned = context.owned or {}
  if use then
    local requirements = type(use.requires) == "table" and use.requires or { use.requires }
    for _, flag in ipairs(requirements) do if not owned[flag] then mismatch = true end end
    if use.resource and not (context.resources or {})[use.resource] and not (def.grants or {})[use.resource] then mismatch = true end
  end
  for _, flag in ipairs(def.shopFitRequires or {}) do
    if not owned[flag] then mismatch = true end
  end
  if def.kind == "ammo" and not owned.ranged then mismatch = true end
  local active = context.active or {}
  if def.kind == "shield" and active.twohand then mismatch = true end
  if def.kind == "weapon" and not ns.IsRangedWeapon(def) and def.hands == 2 and active.shield then mismatch = true end
  local preference = context.formPreference
  if preference and ns.Mastery.Spec(def) == "feral" then
    local opposite = preference == "bearform" and "catform" or "bearform"
    if matchesForm(def, opposite) and not matchesForm(def, preference) then mismatch = true end
  end
  return mismatch and ShopWeights.MISSING_FIT or 1
end



function ShopWeights.GearAffinity(def, classKey, talents)
  local shares = ShopWeights.Shares(classKey, talents)
  local relevant = 0
  for _, spec in ipairs(classSpecs(classKey)) do
    relevant = relevant + shares[spec.tag] * math.min(1, ShopWeights.Affinity(def, classKey, spec.tag))
  end
  return 1 + 1.5 * relevant
end

local function normalise(values)
  local maximum = 0
  for _, value in ipairs(values) do if value > maximum then maximum = value end end
  if maximum <= 0 then return nil end
  local total, out = 0, {}
  for index, value in ipairs(values) do


    out[index] = value > 0 and math.max(1e-300, value / maximum) or 0
    total = total + out[index]
  end
  for index, value in ipairs(out) do out[index] = value / total end
  return out
end

function ShopWeights.Distribution(candidates, classKey, talents, context)
  local broadRaw, signatures = {}, {}
  for _, spec in ipairs(classSpecs(classKey)) do signatures[spec.tag] = spec.signature end
  for index, def in ipairs(candidates) do broadRaw[index] = ShopWeights.BaseWeight(def, classKey) * ShopWeights.Fit(def, context) end
  local broad = normalise(broadRaw)
  local shares, spent = ShopWeights.Shares(classKey, talents)
  local directed = spent > 0 and ShopWeights.DIRECTED_SHARE or 0
  local metadata = { directedShare = directed, shares = shares, directedShares = {}, unavailableShares = {},
    fallbackShare = 0, broadShare = 1 - directed, lanes = {} }
  if not broad then return {}, metadata end
  local probabilities = {}
  for index, weight in ipairs(broad) do probabilities[index] = (1 - directed) * weight end
  for _, spec in ipairs(classSpecs(classKey)) do
    local mass = directed * shares[spec.tag]
    metadata.directedShares[spec.tag] = mass
    if mass > 0 then
      local raw, affinities, maximumAffinity = {}, {}, 0
      for index, def in ipairs(candidates) do
        local affinity = ShopWeights.Affinity(def, classKey, spec.tag)
        assert(affinity >= 0 and affinity < math.huge, "Directed shop affinity must be finite")
        affinities[index] = affinity
        if affinity > maximumAffinity then maximumAffinity = affinity end
      end
      for index, def in ipairs(candidates) do
        local affinity = affinities[index]
        local signature = signatures[spec.tag] == (def.baseKey or def.key)
        raw[index] = maximumAffinity > 0 and broad[index] * (affinity / maximumAffinity)
          * (signature and 1 or 1 / ShopWeights.SIGNATURE_MULT) or 0
      end
      local lane = normalise(raw)
      metadata.lanes[spec.tag] = { share = mass, available = lane ~= nil, weights = lane }
      if not lane then
        metadata.unavailableShares[spec.tag] = mass
        metadata.fallbackShare = metadata.fallbackShare + mass
        lane = broad
      end
      for index, weight in ipairs(lane) do probabilities[index] = probabilities[index] + mass * weight end
    end
  end
  metadata.broadShare = metadata.broadShare + metadata.fallbackShare
  local entries = {}
  for index, def in ipairs(candidates) do entries[index] = { value = def, weight = probabilities[index] } end
  return entries, metadata
end

function ShopWeights.Pick(rng, candidates, classKey, talents, context, trace)
  local entries, metadata = ShopWeights.Distribution(candidates, classKey, talents, context)
  local def, index = rng:PickWeighted(entries)
  if trace then trace(metadata, def, index) end
  return def
end

return ShopWeights
