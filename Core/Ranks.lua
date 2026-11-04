local ADDON, ns = ...
local Util = ns.Util

local Ranks = {}
ns.Ranks = Ranks

Ranks.SCALE = { [2] = { mult = 1.6, power = 1.25, cost = 1.8, offensiveMana = 1.4 }, [3] = { mult = 2.4, power = 1.5, cost = 3.0, offensiveMana = 1.875 } }
Ranks.TRAINING = { [2] = { minRound = 4 }, [3] = { minRound = 7 } }
Ranks.LEGACY_TRAINING = { [2] = 4, [3] = 11 }
Ranks.ID_OFFSET = { [2] = 10000, [3] = 20000 }

local SCALED = { min = true, max = true, tick = true, amount = true, flat = true, coef = true, pctMax = true, blockScale = true, value = true, perPoint = true, perPointPctMax = true }
local DECIMAL = { coef = true, pctMax = true, blockScale = true, perPoint = true, perPointPctMax = true }
local POWER = { coef = true, blockScale = true, perPoint = true }
local OUTPUT = { damage = true, dot = true, hot = true, heal = true, absorb = true, buff = true, debuff = true }
local DERIVED = { "rots", "distinctRots", "cellCount", "tagSet", "classSet", "ranks", "rankable", "rankIds" }
local ABILITY_KINDS = { ability = true, form = true, pet = true, ammo = true }










local PROFILE_KEYS = { maxRank = true, ranks = true }
local RULE_KEYS = { id = true, minRound = true, trainingCost = true, scale = true,
  resourceCost = true, overrides = true, caps = true }
local SCALE_KEYS = { mult = true, power = true, cost = true, offensiveMana = true }
local EFFECT_FIELDS = { min = true, max = true, tick = true, amount = true, flat = true,
  coef = true, pctMax = true, blockScale = true, value = true, perPoint = true,
  perPointPctMax = true, weaponPct = true, duration = true, count = true, gearCoef = true, gearCap = true, fromEvent = true,
  damagePerResource = true, controlChance = true, fraction = true, healCoef = true, healAmount = true, fromPaid = true,
  durationPerPoint = true, valuePerPoint = true, charges = true, bankScale = true, stacksFromEvent = true }
local TRIGGER_FIELDS = { chance = true, every = true, everyAmount = true, icd = true }

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function integer(value, low, high)
  return finite(value) and value == math.floor(value) and value >= low and (not high or value <= high)
end

local function resourceCapacity(base)
  local cap
  for _, key in ipairs(base.classes or {}) do
    local class = ns.GetClass(key)
    local resource = class and class.resources and class.resources[base.use.resource]
    if not resource and base.rankProfile then resource = base.grants and base.grants[base.use.resource] end
    if resource then
      local limit = resource.rankCostCap or resource.max
      cap = math.min(cap or limit, limit)
    end
  end
  if not cap and base.rankProfile then
    local grant = base.grants and base.grants[base.use.resource]
    if grant then cap = grant.rankCostCap or grant.max end
  end
  return cap or 100
end

local function configuredMaximum(base)
  if base and base.rankProfile and base.rankProfile.maxRank ~= nil then return base.rankProfile.maxRank end
  local maximum = 1
  for rank in pairs(Ranks.TRAINING) do if rank > maximum then maximum = rank end end
  return maximum
end

local function scalarTarget(base, path)
  if type(path) ~= "string" then return nil end
  local revival = path:match("^revive%.(health)$") or path:match("^revive%.(mana)$")
  if revival and base.revive and type(base.revive[revival]) == "number" then return { "revive", revival }, "reviveFraction" end
  if path == "use.cd" and base.use and type(base.use.cd) == "number" then return { "use", "cd" }, "cd" end
  if path == "wardReflection.chance" and base.wardReflection and type(base.wardReflection.chance) == "number" then return { "wardReflection", "chance" }, "chance" end
  local gearIndex = path:match("^gearBonuses%.([1-9]%d*)%.coef$")
  if gearIndex and base.gearBonuses and base.gearBonuses[tonumber(gearIndex)] and type(base.gearBonuses[tonumber(gearIndex)].coef) == "number" then
    return { "gearBonuses", tonumber(gearIndex), "coef" }, "coef"
  end
  local adjacencyIndex, group, modifier = path:match("^adjacency%.([1-9]%d*)%.([%a][%w_]*)%.([%a][%w_]*)$")
  if adjacencyIndex and (group == "mods" or group == "selfMods" or group == "stats") then
    local keys = group == "stats" and ns.Sim.STAT_KEYS or ns.Sim.MOD_KEYS
    local valid = false
    for _, key in ipairs(keys) do if key == modifier then valid = true break end end
    local rule = base.adjacency and base.adjacency[tonumber(adjacencyIndex)]
    if valid and rule and rule[group] and type(rule[group][modifier]) == "number" then
      return { "adjacency", tonumber(adjacencyIndex), group, modifier }, modifier
    end
    return nil
  end
  local stat = path:match("^stats%.([%a][%w_]*)$")
  if stat then
    local valid = false
    for _, key in ipairs(ns.Sim and ns.Sim.STAT_KEYS or {}) do if stat == key then valid = true break end end
    if valid and base.stats and type(base.stats[stat]) == "number" then return { "stats", stat }, stat end
    return nil
  end
  local windowIndex, periodicIndex, periodicField = path:match("^use%.effects%.([1-9]%d*)%.periodic%.effects%.([1-9]%d*)%.([%a][%w_]*)$")
  if windowIndex and EFFECT_FIELDS[periodicField] then
    local window = base.use and base.use.effects[tonumber(windowIndex)]
    local effect = window and window.periodic and window.periodic.effects[tonumber(periodicIndex)]
    if effect and type(effect[periodicField]) == "number" then
      return { "use", "effects", tonumber(windowIndex), "periodic", "effects", tonumber(periodicIndex), periodicField }, periodicField, effect
    end
    return nil
  end
  local effectIndex, field = path:match("^use%.effects%.([1-9]%d*)%.([%a][%w_]*)$")
  if effectIndex and EFFECT_FIELDS[field] then
    local effects = base.use and base.use.effects
    local effect = effects and effects[tonumber(effectIndex)]
    if effect and type(effect[field]) == "number" then return { "use", "effects", tonumber(effectIndex), field }, field, effect end
    return nil
  end
  local triggerIndex, triggerEffect, triggerField = path:match("^triggers%.([1-9]%d*)%.effects%.([1-9]%d*)%.([%a][%w_]*)$")
  if triggerIndex and EFFECT_FIELDS[triggerField] then
    local trigger = base.triggers and base.triggers[tonumber(triggerIndex)]
    local effect = trigger and trigger.effects and trigger.effects[tonumber(triggerEffect)]
    if effect and type(effect[triggerField]) == "number" then
      return { "triggers", tonumber(triggerIndex), "effects", tonumber(triggerEffect), triggerField }, triggerField, effect
    end
    return nil
  end
  triggerIndex, field = path:match("^triggers%.([1-9]%d*)%.([%a][%w_]*)$")
  if triggerIndex and TRIGGER_FIELDS[field] then
    local trigger = base.triggers and base.triggers[tonumber(triggerIndex)]
    if trigger and type(trigger[field]) == "number" then return { "triggers", tonumber(triggerIndex), field }, field end
  end
end

local function validScalar(field, value, effect)
  if not finite(value) then return false end
  if field == "reviveFraction" then return value >= 0 and value <= 1 end
  if field == "fromPaid" then return value >= 0 and value <= 1 end
  if field == "charges" then return effect and effect.type == "buff" and integer(value, 0, 20) end
  if field == "bankScale" then return effect and effect.type == "damage" and value >= 0 end
  if field == "stacksFromEvent" then return effect and (effect.type == "buff" or effect.type == "debuff") and effect.stack == true and value > 0 end
  if field == "pctMax" and effect and effect.type == "resource" then return value >= 0 and value <= 1 end
  if field == "cd" then return value > 0 end
  if effect and effect.stat == "dr" and field == "value" and value > 90 then return false end
  if field == "chance" then return value >= 0 and value <= 100 end
  if field == "controlChance" then return value >= 0 and value <= 100 end
  if field == "damagePerResource" then return value > 0 end
  if field == "healCoef" or field == "healAmount" then return value >= 0 end
  if field == "every" then return integer(value, 1) end
  if field == "everyAmount" then return value > 0 end
  if field == "count" then return integer(value, 0) end
  if field == "duration" or field == "icd" or field == "min" or field == "max" or field == "tick"
    or field == "amount" or field == "coef" or field == "pctMax" or field == "perPointPctMax"
    or field == "weaponPct" or field == "gearCoef" or field == "gearCap" or field == "fromEvent" or field == "fraction" then return value >= 0 end
  return true
end

local function applyScalars(def, base, values, cap)
  for path, value in pairs(values or {}) do
    local target = assert(scalarTarget(base, path), "Invalid rank scalar path: " .. tostring(path))
    local holder = def
    for index = 1, #target - 1 do holder = holder[target[index]] end
    local key = target[#target]
    holder[key] = cap and math.min(holder[key], value) or value
  end
end

function Ranks.ValidateProfile(base)
  if base and base.baseKey then base = ns.ItemsByKey[base.baseKey] or base end
  local problems, profile = {}, base and base.rankProfile
  if profile == nil then return problems end
  local function problem(message) problems[#problems + 1] = tostring(base.key) .. " rank profile " .. message end
  if type(profile) ~= "table" then problem("must be a table") return problems end
  for key in pairs(profile) do if not PROFILE_KEYS[key] then problem("has unknown field " .. tostring(key)) end end
  local maximum = profile.maxRank
  if not integer(maximum, 1, 20) then problem("maxRank must be an integer from 1 to 20") return problems end
  if profile.ranks ~= nil and type(profile.ranks) ~= "table" then problem("ranks must be a table") return problems end
  local rules = profile.ranks or {}
  local ids, previousRound = {}, base.minRound or 1
  for rank in pairs(rules) do
    if not integer(rank, 2, maximum) then problem("has an invalid rank key " .. tostring(rank)) end
  end
  for rank = 2, maximum do
    local rule = rules[rank]
    if rule ~= nil and type(rule) ~= "table" then problem(tostring(rank) .. " must be a table")
    else
      rule = rule or {}
      for key in pairs(rule) do if not RULE_KEYS[key] then problem(tostring(rank) .. " has unknown field " .. tostring(key)) end end
      local globalTraining, globalScale = Ranks.TRAINING[rank], Ranks.SCALE[rank]
      if rule.minRound ~= nil and not integer(rule.minRound, 1, ns.Economy.ROUNDS) then problem(tostring(rank) .. " minRound is invalid") end
      if not globalTraining and rule.minRound == nil then problem(tostring(rank) .. " requires minRound") end
      local round = rule.minRound or globalTraining and globalTraining.minRound
      if finite(round) then
        round = math.max(base.minRound or 1, round)
        if round < previousRound then problem(tostring(rank) .. " minRound precedes an earlier rank") end
        previousRound = round
      end
      if rule.trainingCost ~= nil and not integer(rule.trainingCost, 0) then problem(tostring(rank) .. " trainingCost is invalid") end
      if rank > 3 and rule.trainingCost == nil then problem(tostring(rank) .. " requires trainingCost") end
      local id = rule.id or base.rankIds and base.rankIds[rank]
      if rule.id ~= nil and not integer(rule.id, 1) then problem(tostring(rank) .. " id is invalid") end
      if not Ranks.ID_OFFSET[rank] and id == nil then problem(tostring(rank) .. " requires an explicit id") end
      id = id or Ranks.ID_OFFSET[rank] and base.id + Ranks.ID_OFFSET[rank]
      if id then
        if not integer(id, 1) then problem(tostring(rank) .. " resolved id is invalid")
        elseif ids[id] then problem(tostring(rank) .. " reuses a rank id")
        elseif ns.Items[id] and (ns.Items[id].key ~= base.key .. "_r" .. rank
          or ns.Items[id].baseKey ~= base.key or ns.Items[id].rank ~= rank) then
          problem(tostring(rank) .. " id collides with " .. ns.Items[id].key)
        end
        ids[id] = true
      end
      if rule.resourceCost ~= nil and (not integer(rule.resourceCost, 0) or not base.use or not base.use.resource) then
        problem(tostring(rank) .. " resourceCost requires a paid resource definition and nonnegative integer")
      elseif rule.resourceCost ~= nil and rule.resourceCost > resourceCapacity(base) then
        problem(tostring(rank) .. " resourceCost exceeds resource capacity")
      end
      if rule.scale ~= nil and type(rule.scale) ~= "table" then problem(tostring(rank) .. " scale must be a table")
      else
        for key, value in pairs(rule.scale or {}) do
          if not SCALE_KEYS[key] or not finite(value) or value <= 0 then problem(tostring(rank) .. " has invalid scale " .. tostring(key)) end
        end
        if not globalScale then
          for key in pairs(SCALE_KEYS) do if not rule.scale or rule.scale[key] == nil then problem(tostring(rank) .. " requires scale." .. key) end end
        end
      end
      for _, name in ipairs({ "overrides", "caps" }) do
        if rule[name] ~= nil and type(rule[name]) ~= "table" then problem(tostring(rank) .. " " .. name .. " must be a table")
        else
          for path, value in pairs(rule[name] or {}) do
            local _, field, effect = scalarTarget(base, path)
            if not field or not validScalar(field, value, effect) then problem(tostring(rank) .. " has invalid " .. name .. " path/value " .. tostring(path)) end
          end
        end
      end
    end
  end
  return problems
end

function Ranks.Base(def)
  return def and (def.baseKey and ns.ItemsByKey[def.baseKey] or def) or nil
end

function Ranks.FamilyKey(def)
  if def and ABILITY_KINDS[def.kind] then return def.baseKey or def.key end
end

function Ranks.Definition(base, rank)
  base = Ranks.Base(base)
  if not base then return nil end
  if rank == 1 then return base end
  return base.ranks and ns.ItemsByKey[base.ranks[rank]] or nil
end

function Ranks.MaxRank(base)
  base = Ranks.Base(base)
  local maximum = 1
  for rank, key in pairs(base and base.ranks or {}) do
    if integer(rank, 2) and ns.ItemsByKey[key] and rank > maximum then maximum = rank end
  end
  return maximum
end

function Ranks.NextRank(base, learned)
  base = Ranks.Base(base)
  if not base then return nil end
  learned = learned or 1
  if not integer(learned, 1) then return nil end
  for rank = learned + 1, Ranks.TrainableMaxRank(base) do
    if Ranks.Definition(base, rank) then return rank end
  end
end

function Ranks.TrainableMaxRank(base)
  base = Ranks.Base(base)
  return math.min(Ranks.MaxRank(base), base and base.trainingMaxRank or math.huge)
end

function Ranks.Page(base, page, size, focusRank)
  base = Ranks.Base(base)
  size = integer(size, 1) and size or 3
  local ranks, focus = {}, nil
  if base then
    local visibleMaximum = math.max(Ranks.TrainableMaxRank(base), focusRank or 1)
    for rank = 1, math.min(Ranks.MaxRank(base), visibleMaximum) do
      if Ranks.Definition(base, rank) then
        ranks[#ranks + 1] = rank
        if rank == focusRank then focus = #ranks end
      end
    end
  end
  local pages = math.max(1, math.ceil(#ranks / size))
  if page == nil then page = focus and math.ceil(focus / size) or 1 end
  page = finite(page) and math.floor(page) or 1
  page = math.max(1, math.min(pages, page))
  local visible = {}
  for index = (page - 1) * size + 1, math.min(#ranks, page * size) do visible[#visible + 1] = ranks[index] end
  return visible, page, pages
end

function Ranks.TrainingRule(base, rank)
  base = Ranks.Base(base)
  if not base or not integer(rank, 2, configuredMaximum(base)) then return nil end
  local authored = base.rankProfile and base.rankProfile.ranks and base.rankProfile.ranks[rank]
  local global = Ranks.TRAINING[rank]
  if not authored and not global then return nil end
  local rule = Util.DeepCopy(global or {})
  for key, value in pairs(authored or {}) do rule[key] = Util.DeepCopy(value) end
  local scale = Util.DeepCopy(Ranks.SCALE[rank] or {})
  for key, value in pairs(authored and authored.scale or {}) do scale[key] = value end
  rule.scale = scale
  return rule
end

function Ranks.TrainingCost(base, rank)
  base = Ranks.Base(base)
  if not base then return nil end
  local rule = Ranks.TrainingRule(base, rank)
  if not rule then return nil end
  if rule.trainingCost ~= nil then return rule.trainingCost end
  if rank == 2 then return base.quality + 1 end
  if rank == 3 then return base.quality * 2 + 1 end
end

function Ranks.Investment(base, rank)
  base = Ranks.Base(base)
  if not base or not integer(rank, 1, configuredMaximum(base)) then return nil end
  local value = base.cost
  for nextRank = 2, rank do
    local price = Ranks.TrainingCost(base, nextRank)
    if price == nil then return nil end
    value = value + price
  end
  return value
end




function Ranks.LegacyTrainingCost(base, rank)
  base = Ranks.Base(base)
  local investment = base and Ranks.Investment(base, rank)
  if not investment then return nil end
  if not base.rankProfile and Ranks.LEGACY_TRAINING[rank] then return Ranks.LEGACY_TRAINING[rank] end
  return investment - base.cost
end

local function scaleEffects(effects, scale, rank)
  local mult = scale.mult
  for _, e in ipairs(effects or {}) do
    if e.countPerRank and e.rankScale ~= false then e.count = (e.count or 0) + e.countPerRank * (rank - 1) end
    if OUTPUT[e.type] and e.rankScale ~= false then
      for key in pairs(SCALED) do
        local value = e[key]
        if type(value) == "number" then
          local power = (e.type == "damage" or e.type == "dot") and POWER[key]
            or (e.type == "heal" or e.type == "hot") and (key == "pctMax" or key == "perPointPctMax")
          local factor = power and scale.power or mult
          if factor == 1 then
            e[key] = value
          elseif DECIMAL[key] then
            local precision = key == "perPointPctMax" and 100000 or 100
            e[key] = math.floor(value * factor * precision + 0.5) / precision
          else e[key] = math.floor(value * factor + 0.5) end
        end
      end
      if e.rankTicks and e.rankTicks[rank] then e.tick = e.rankTicks[rank] end
      if e.type == "damage" and (e.weapon or e.weaponSelf) then e.weaponPct = math.floor((e.weaponPct or 1) * scale.power * 20 + 0.5) / 20 end
      if (e.type == "buff" or e.type == "debuff") and e.stat == "dr" then e.value = math.min(90, e.value) end
      if e.type == "buff" and e.stat == "none" and e.double then e.duration = math.floor(e.duration * mult + 0.5) end
    elseif e.type == "stun" and e.rankScale ~= false and mult ~= 1 then
      e.duration = math.floor(e.duration * mult * 10 + 0.5) / 10
    end
  end
end

local function damagingEffects(effects)
  for _, effect in ipairs(effects or {}) do
    if effect.type == "damage" or effect.type == "dot" then return true end
  end
  return false
end

function Ranks.Register(base, rank)
  local problems = Ranks.ValidateProfile(base)
  assert(#problems == 0, table.concat(problems, "; "))
  local rule = assert(Ranks.TrainingRule(base, rank), "Missing training rule for rank " .. tostring(rank))
  local def = Util.DeepCopy(base)
  for _, key in ipairs(DERIVED) do def[key] = nil end
  def.id = rule.id or base.rankIds and base.rankIds[rank] or base.id + Ranks.ID_OFFSET[rank]
  def.key = base.key .. "_r" .. rank
  def.rank = rank
  def.baseKey = base.key
  def.noShop = true
  def.minRound = math.max(base.minRound, rule.minRound)
  def.cost = Ranks.Investment(base, rank)
  local scale = rule.scale
  if def.use then
    scaleEffects(def.use.effects, scale, rank)
    if base.use.resource and base.use.resource ~= "combo" and type(base.use.cost) == "number" then
      local costScale = scale.cost
      if base.use.resource == "mana" then
        if damagingEffects(base.use.effects) then costScale = scale.offensiveMana end
        if base.rankTriggers then
          for _, trigger in ipairs(base.triggers) do
            if damagingEffects(trigger.effects) then costScale = scale.offensiveMana break end
          end
        end
      end
      local fixedEnergy = base.use.resource == "energy" and damagingEffects(base.use.effects)
      local cost = fixedEnergy and base.use.cost or math.max(base.use.cost + rank - 1, math.floor(base.use.cost * costScale + 0.5))
      if base.use.rankCosts and base.use.rankCosts[rank] ~= nil then cost = base.use.rankCosts[rank] end
      local reserve = base.rankProfile and 0 or 3 - rank
      def.use.cost = math.min(cost, resourceCapacity(base) - reserve)
    end
    if rule.resourceCost ~= nil then def.use.cost = rule.resourceCost end
    if base.use.spendMax and not base.rankProfile then
      def.use.spendMax = math.min(resourceCapacity(base), math.max(def.use.cost or 0, base.use.spendMax + 10 * (rank - 1)))
    end
  end
  if not def.use or def.rankTriggers then
    for _, trigger in ipairs(def.triggers) do scaleEffects(trigger.effects, scale, rank) end
  end
  applyScalars(def, base, rule.overrides, false)
  applyScalars(def, base, rule.caps, true)
  ns.RegisterItem(def)
  base.ranks = base.ranks or {}
  base.ranks[rank] = def.key
  base.rankable = true
  return def
end

function Ranks.RegisterAll()
  local bases = {}
  for _, def in ipairs(ns.ItemList) do
    local use = def.use
    local paid = use and use.resource and (use.cost or 0) > 0 and not def.passiveTriggers and def.rankable ~= false
    local triggered = not use and def.rankable == true and #def.triggers > 0
    local legacy = def.kind == "ability" and (paid or triggered)
    local authored = ABILITY_KINDS[def.kind] and def.rankProfile and def.rankable == true
    if not def.noShop and not def.rank and (legacy or authored) then
      bases[#bases + 1] = def
    end
  end
  for _, base in ipairs(bases) do
    local problems = Ranks.ValidateProfile(base)
    assert(#problems == 0, table.concat(problems, "; "))
    for rank = 2, configuredMaximum(base) do Ranks.Register(base, rank) end
  end
end
