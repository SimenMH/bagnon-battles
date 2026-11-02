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

function Ranks.Base(def)
  return def and (def.baseKey and ns.ItemsByKey[def.baseKey] or def) or nil
end

function Ranks.FamilyKey(def)
  if def and def.kind == "ability" then return def.baseKey or def.key end
end

function Ranks.Definition(base, rank)
  base = Ranks.Base(base)
  if not base then return nil end
  if rank == 1 then return base end
  return base.ranks and ns.ItemsByKey[base.ranks[rank]] or nil
end

function Ranks.TrainingCost(base, rank)
  base = Ranks.Base(base)
  if not base then return nil end
  if rank == 2 then return base.quality + 1 end
  if rank == 3 then return base.quality * 2 + 1 end
end

function Ranks.Investment(base, rank)
  base = Ranks.Base(base)
  local value = base.cost
  for nextRank = 2, rank do value = value + Ranks.TrainingCost(base, nextRank) end
  return value
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
          if DECIMAL[key] then
            local precision = key == "perPointPctMax" and 100000 or 100
            e[key] = math.floor(value * factor * precision + 0.5) / precision
          else e[key] = math.floor(value * factor + 0.5) end
        end
      end
      if e.rankTicks and e.rankTicks[rank] then e.tick = e.rankTicks[rank] end
      if e.type == "damage" and (e.weapon or e.weaponSelf) then e.weaponPct = math.floor((e.weaponPct or 1) * scale.power * 20 + 0.5) / 20 end
      if (e.type == "buff" or e.type == "debuff") and e.stat == "dr" then e.value = math.min(90, e.value) end
      if e.type == "buff" and e.stat == "none" and e.double then e.duration = math.floor(e.duration * mult + 0.5) end
    elseif e.type == "stun" and e.rankScale ~= false then
      e.duration = math.floor(e.duration * mult * 10 + 0.5) / 10
    end
  end
end

local function resourceCapacity(base)
  local cap
  for _, key in ipairs(base.classes or {}) do
    local class = ns.GetClass(key)
    local resource = class and class.resources and class.resources[base.use.resource]
    if resource then cap = math.min(cap or resource.max, resource.max) end
  end
  return cap or 100
end

local function damagingEffects(effects)
  for _, effect in ipairs(effects or {}) do
    if effect.type == "damage" or effect.type == "dot" then return true end
  end
  return false
end

function Ranks.Register(base, rank)
  local def = Util.DeepCopy(base)
  for _, key in ipairs(DERIVED) do def[key] = nil end
  def.id = base.rankIds and base.rankIds[rank] or base.id + Ranks.ID_OFFSET[rank]
  def.key = base.key .. "_r" .. rank
  def.rank = rank
  def.baseKey = base.key
  def.noShop = true
  def.minRound = math.max(base.minRound, Ranks.TRAINING[rank].minRound)
  def.cost = Ranks.Investment(base, rank)
  local scale = Ranks.SCALE[rank]
  if def.use then
    scaleEffects(def.use.effects, scale, rank)
    if base.use.resource ~= "combo" then
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
      def.use.cost = math.min(cost, resourceCapacity(base) - (3 - rank))
    end
    if base.use.spendMax then
      def.use.spendMax = math.min(resourceCapacity(base), math.max(def.use.cost or 0, base.use.spendMax + 10 * (rank - 1)))
    end
  end
  if not def.use or def.rankTriggers then
    for _, trigger in ipairs(def.triggers) do scaleEffects(trigger.effects, scale, rank) end
  end
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
    if def.kind == "ability" and not def.noShop and not def.rank and (paid or triggered) then
      bases[#bases + 1] = def
    end
  end
  for _, base in ipairs(bases) do
    Ranks.Register(base, 2)
    Ranks.Register(base, 3)
  end
end
