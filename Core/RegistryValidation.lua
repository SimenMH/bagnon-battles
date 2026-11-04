local ADDON, ns = ...
local Util = ns.Util
local Sim = ns.Sim

local STAT_FIELDS = Util.Set(Sim.STAT_KEYS)
local MOD_FIELDS = Util.Set(Sim.MOD_KEYS)

local function checkMatch(problems, owner, match)
  if match == nil then return end
  if type(match) ~= "table" then problems[#problems + 1] = owner .. " has an invalid match" return end
  for _, field in ipairs({ "usable", "prepared", "channeled", "healing" }) do
    if match[field] ~= nil and type(match[field]) ~= "boolean" then problems[#problems + 1] = owner .. " has invalid " .. field .. " match" end
  end
  for field in pairs(match) do
    if not Util.MATCH_FIELDS[field] then problems[#problems + 1] = owner .. " matches unknown field " .. tostring(field) end
  end
  if match.key ~= nil and not ns.ItemsByKey[match.key] then problems[#problems + 1] = owner .. " matches unknown item " .. tostring(match.key) end
  if match.set ~= nil and not ns.Sets[match.set] then problems[#problems + 1] = owner .. " matches unknown set " .. tostring(match.set) end
end

local function checkCondition(problems, owner, condition)
  if condition ~= nil and not Sim.ValidCondition(condition) then
    problems[#problems + 1] = owner .. " has unknown condition " .. tostring(condition)
  end
end

local function checkEffects(problems, owner, effects)
  for _, e in ipairs(effects or {}) do
    if not Sim.EFFECT_TYPES[e.type] then problems[#problems + 1] = owner .. " has unknown effect type " .. tostring(e.type) end
    checkCondition(problems, owner, e.cond)
    checkCondition(problems, owner, e.critIf)
    if e.multIf ~= nil then
      local rule = e.multIf
      if e.type ~= "damage" or type(rule) ~= "table" or type(rule.mult) ~= "number" or rule.mult ~= rule.mult
        or rule.mult <= 0 or rule.mult > 3 or not rule.condition then problems[#problems + 1] = owner .. " has invalid conditional damage multiplier"
      else checkCondition(problems, owner, rule.condition) end
    end
    if e.controlKey ~= nil and (e.type ~= "debuff" or not ns.ItemsByKey[e.controlKey]) then
      problems[#problems + 1] = owner .. " has invalid control-bound debuff"
    end
    if e.spendCharge ~= nil and (e.type ~= "extraAttack" or not ns.ItemsByKey[e.spendCharge]) then
      problems[#problems + 1] = owner .. " has invalid queued attack charge"
    end
    if e.holdWeapons ~= nil and (e.type ~= "stun" or e.holdWeapons ~= true or not e.breakOnDamage) then
      problems[#problems + 1] = owner .. " has invalid weapon hold"
    end
    if e.holdDirect ~= nil and (e.type ~= "stun" or e.holdDirect ~= true or not e.breakOnDamage) then problems[#problems + 1] = owner .. " has invalid damage hold" end
    if e.healPctPerSecond ~= nil and (e.type ~= "stun" or not e.breakOnDamage or type(e.healPctPerSecond) ~= "number"
      or e.healPctPerSecond ~= e.healPctPerSecond or e.healPctPerSecond <= 0 or e.healPctPerSecond > 0.25) then
      problems[#problems + 1] = owner .. " has invalid recovery during control"
    end
    checkMatch(problems, owner, e.match)
    if e.consumeOn ~= nil and (e.consumeOn ~= "block" or e.type ~= "buff" or e.stat ~= "blockChance"
      or type(e.charges) ~= "number" or e.charges ~= math.floor(e.charges) or e.charges < 1 or e.charges > 8
      or e.free or e.double or e.paidOnly or e.target) then problems[#problems + 1] = owner .. " has invalid block-consumed charges" end
    if e.consumeHots ~= nil and type(e.consumeHots) ~= "boolean" then
      local selection = e.consumeHots
      if e.type ~= "heal" or type(selection) ~= "table" or selection.full ~= nil and type(selection.full) ~= "boolean" then
        problems[#problems + 1] = owner .. " has invalid healing-over-time consumption"
      elseif selection then checkMatch(problems, owner, selection.match) end
    end
    if e.finite ~= nil and (e.type ~= "hot" or type(e.finite) ~= "boolean") then
      problems[#problems + 1] = owner .. " has invalid finite healing budget"
    end
    if e.periodic ~= nil then
      local periodic = e.periodic
      local valid = e.type == "buff" and type(periodic) == "table" and type(periodic.every) == "number"
        and periodic.every >= Sim.TICK and periodic.every <= Sim.MAX_TIME
        and type(e.duration) == "number" and e.duration > 0 and type(periodic.effects) == "table" and #periodic.effects > 0
      for _, effect in ipairs(type(periodic) == "table" and type(periodic.effects) == "table" and periodic.effects or {}) do
        if effect.type ~= "cleanse" and effect.type ~= "resource" then valid = false end
      end
      if not valid then problems[#problems + 1] = owner .. " has invalid periodic recovery window"
      else checkEffects(problems, owner, periodic.effects) end
    end
    if e.type == "hot" and e.fixedFraction and not e.finite then problems[#problems + 1] = owner .. " fraction recovery requires a finite budget" end
    for _, field in ipairs({ "durationPerPoint", "valuePerPoint" }) do
      if e[field] ~= nil and ((e.type ~= "buff" and e.type ~= "debuff") or type(e[field]) ~= "number"
        or e[field] ~= e[field] or e[field] < 0 or e[field] == math.huge) then
        problems[#problems + 1] = owner .. " has invalid " .. field
      end
    end
    if e.weaponType ~= nil and (e.type ~= "damage" or not e.weapon or type(e.weaponType) ~= "string") then
      problems[#problems + 1] = owner .. " has invalid weapon damage source"
    end
    if e.fromPaid ~= nil and (e.type ~= "resource" or type(e.fromPaid) ~= "number" or e.fromPaid ~= e.fromPaid
      or e.fromPaid < 0 or e.fromPaid > 1 or not ns.RESOURCE_NAMES[e.resource]) then
      problems[#problems + 1] = owner .. " has invalid paid-resource fraction"
    end
    if e.choose ~= nil and not ((e.type == "cast" or e.type == "cdr")
      and (e.target == "neighbors" or e.target == "all")
      and (e.choose == "first" or e.type == "cast" and e.target == "all" and e.choose == "random")) then
      problems[#problems + 1] = owner .. " has invalid recipient selection"
    end
    if e.type == "resource" and e.pctMax ~= nil and (type(e.pctMax) ~= "number" or e.pctMax ~= e.pctMax
      or e.pctMax < 0 or e.pctMax > 1 or not ns.RESOURCE_NAMES[e.resource]) then
      problems[#problems + 1] = owner .. " has invalid maximum-resource fraction"
    end
    if e.area ~= nil then
      local valid = e.target == "neighbors" and type(e.area) == "table" and ns.Grid.ValidateEffectRule(e.area)
      for field in pairs(type(e.area) == "table" and e.area or {}) do
        if field ~= "side" and field ~= "corners" then valid = false end
      end
      if not valid then problems[#problems + 1] = owner .. " has invalid effect area" end
    end
    if e.stat and Sim.ITEM_STATS[e.stat] and (e.type ~= "buff" or not e.target or not e.match) then
      problems[#problems + 1] = owner .. " item modifier requires a matched buff"
    end
    if e.powerStat ~= nil and not STAT_FIELDS[e.powerStat] then problems[#problems + 1] = owner .. " has unknown powerStat" end
    if e.breakOnDamage ~= nil and ((e.type ~= "hot" and e.type ~= "stun") or type(e.breakOnDamage) ~= "boolean") then
      problems[#problems + 1] = owner .. " breakOnDamage requires a healing-over-time or control effect"
    end
    if e.breakDamagePctMax ~= nil and (e.type ~= "hot" or e.breakOnDamage ~= true or type(e.breakDamagePctMax) ~= "number"
      or e.breakDamagePctMax ~= e.breakDamagePctMax or e.breakDamagePctMax <= 0 or e.breakDamagePctMax > 1) then
      problems[#problems + 1] = owner .. " has invalid breakable healing damage budget"
    end
    if e.drainResource ~= nil and (e.type ~= "dot" or not ns.RESOURCE_NAMES[e.drainResource]) then
      problems[#problems + 1] = owner .. " has invalid periodic resource drain"
    end
    if e.directTicks ~= nil and (e.type ~= "dot" or type(e.directTicks) ~= "boolean" or e.drainResource) then
      problems[#problems + 1] = owner .. " has invalid direct channel ticks"
    end
    if e.type == "absorb" and e.damageSchool then
      if not (ns.SCHOOL_COLORS[e.damageSchool] or e.damageSchool == "magic") or type(e.duration) ~= "number" or e.duration <= 0 or e.duration > Sim.MAX_TIME then
        problems[#problems + 1] = owner .. " school-specific absorb requires a school and finite duration"
      end
    end
    if e.debuffs ~= nil and (e.type ~= "cleanse" or e.debuffs ~= true) then
      problems[#problems + 1] = owner .. " debuff cleansing requires a cleanse effect"
    end
    if e.anySource ~= nil and (e.type ~= "buff" or e.charges ~= 0 or e.anySource ~= true or type(e.key) ~= "string") then
      problems[#problems + 1] = owner .. " anySource requires an explicit zero-charge buff removal"
    end
    if e.controlTypes ~= nil or e.controlCharges ~= nil or e.controlChance ~= nil then
      local valid = (e.type == "buff" or e.type == "debuff") and type(e.controlTypes) == "table" and #e.controlTypes > 0
      if e.controlCharges ~= nil then
        valid = valid and type(e.controlCharges) == "number" and e.controlCharges == math.floor(e.controlCharges)
          and e.controlCharges >= 1 and e.controlCharges < math.huge
      elseif e.controlChance == nil then valid = false end
      if e.controlChance ~= nil then
        valid = valid and type(e.controlChance) == "number" and e.controlChance == e.controlChance
          and e.controlChance >= 0 and e.controlChance <= 100
      end
      for _, controlType in ipairs(type(e.controlTypes) == "table" and e.controlTypes or {}) do
        if controlType ~= "stun" and controlType ~= "fear" and controlType ~= "incapacitate" and controlType ~= "horror" then valid = false end
      end
      if not valid then problems[#problems + 1] = owner .. " has invalid control ward" end
    end
    for _, field in ipairs({ "healCoef", "healAmount" }) do
      local value = e[field]
      if value ~= nil and (e.type ~= "purge" or type(value) ~= "number" or value ~= value or value < 0 or value == math.huge) then
        problems[#problems + 1] = owner .. " has invalid successful-purge healing"
      end
    end
    if e.damagePerResource ~= nil then
      if e.type ~= "drain" or type(e.damagePerResource) ~= "number" or e.damagePerResource ~= e.damagePerResource
        or e.damagePerResource <= 0 or e.damagePerResource == math.huge then
        problems[#problems + 1] = owner .. " has invalid drain damage conversion"
      end
    end
    if e.gearCoef ~= nil then
      if e.type ~= "buff" or not STAT_FIELDS[e.stat] or not STAT_FIELDS[e.gearStat or e.stat] or type(e.gearCoef) ~= "number"
        or e.gearCoef ~= e.gearCoef or e.gearCoef < 0 or e.gearCoef == math.huge then
        problems[#problems + 1] = owner .. " has invalid gear-derived buff"
      end
      if e.gearCap ~= nil and (type(e.gearCap) ~= "number" or e.gearCap ~= e.gearCap or e.gearCap < 0 or e.gearCap == math.huge) then
        problems[#problems + 1] = owner .. " gear-derived buff has an invalid gearCap"
      end
    elseif e.gearStat ~= nil or e.gearCap ~= nil then problems[#problems + 1] = owner .. " gear source requires gearCoef" end
    if e.paidOnly ~= nil and (e.paidOnly ~= true or e.type ~= "buff" or not e.target or not e.match or e.free or e.double) then
      problems[#problems + 1] = owner .. " paidOnly requires a matched stat buff"
    end
    if Sim.ITEM_KEY_EFFECTS[e.type] and e.key ~= nil and not ns.ItemsByKey[e.key] then
      problems[#problems + 1] = owner .. " targets unknown item " .. tostring(e.key)
    end
    if e.effects then checkEffects(problems, owner, e.effects) end
  end
end

local function checkTriggers(problems, owner, triggers)
  for _, trigger in ipairs(triggers or {}) do
    if trigger.counterKey ~= nil and (type(trigger.counterKey) ~= "string" or not trigger.counterKey:match("^[%a_][%w_]*$")) then
      problems[#problems + 1] = owner .. " has invalid shared trigger counter"
    end
    for _, field in ipairs({ "effective", "paidOnly", "oncePerActivation", "onlyRecovering", "regularAttackOnly" }) do
      if trigger[field] ~= nil and type(trigger[field]) ~= "boolean" then problems[#problems + 1] = owner .. " has invalid " .. field end
    end
    if not Sim.TRIGGER_EVENTS[trigger.on] then problems[#problems + 1] = owner .. " has unknown trigger " .. tostring(trigger.on) end
    if trigger.critical ~= nil and type(trigger.critical) ~= "boolean" then problems[#problems + 1] = owner .. " has invalid critical trigger filter" end
    checkCondition(problems, owner, trigger.condition)
    checkMatch(problems, owner, trigger.match)
    checkEffects(problems, owner, trigger.effects)
  end
end

local function checkBotPlans(problems)
  for _, classKey in ipairs(Util.SortedKeys(ns.Bots.ARCHETYPES)) do
    for _, plan in ipairs(ns.Bots.ARCHETYPES[classKey]) do
      local lists = {}
      for _, field in ipairs({ "core", "support", "train", "supportTrain", "payoff", "equipment" }) do
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

local function positiveWeight(value)
  return type(value) == "number" and value == value and value > 0 and value < math.huge
end

local function checkShopWeights(problems, def)
  local function problem(message) problems[#problems + 1] = def.key .. " " .. message end
  if not positiveWeight(def.shopWeight) then problem("has an invalid shopWeight") end
  if def.shopFitRequires ~= nil then
    local requires = def.shopFitRequires
    if type(requires) ~= "table" or #requires < 1 or #requires > 4 then
      problem("shopFitRequires must contain one to four equipment or provider flags")
    else
      for index, flag in pairs(requires) do
        if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > #requires
          or type(flag) ~= "string" or not flag:match("^[%w_]+$") then
          problem("has malformed shopFitRequires")
        end
      end
    end
  end
  if def.shopClassWeights ~= nil then
    if type(def.shopClassWeights) ~= "table" then problem("shopClassWeights must be a class map")
    else
      for classKey, weight in pairs(def.shopClassWeights) do
        if not ns.Classes[classKey] then problem("has shopClassWeights for unknown class " .. tostring(classKey)) end
        if not positiveWeight(weight) or positiveWeight(def.shopWeight) and not positiveWeight(weight * def.shopWeight) then
          problem("has an invalid shopClassWeights value for " .. tostring(classKey))
        end
      end
    end
  end
  if def.shopAffinities ~= nil then
    if type(def.shopAffinities) ~= "table" then problem("shopAffinities must be a class/spec map")
    else
      for classKey, affinities in pairs(def.shopAffinities) do
        local class, known = ns.Classes[classKey], {}
        for _, spec in ipairs(class and class.specs or {}) do known[spec.tag] = true end
        if not class then problem("has shopAffinities for unknown class " .. tostring(classKey)) end
        if type(affinities) ~= "table" then problem("shopAffinities entry must be a spec map")
        else
          for spec, weight in pairs(affinities) do
            if not known[spec] then problem("has shopAffinities for unknown spec " .. tostring(classKey) .. ":" .. tostring(spec)) end
            if not positiveWeight(weight) then problem("has an invalid shopAffinities value for " .. tostring(spec)) end
          end
        end
      end
    end
  end
end

local function checkSpatialPayload(problems, def, rule)
  local function problem(message) problems[#problems + 1] = def.key .. " spatial rule " .. message end
  for _, field in ipairs({ "once", "inside" }) do
    if rule[field] ~= nil and type(rule[field]) ~= "boolean" then problem(field .. " must be boolean") end
  end
  if rule.empty and not rule.selfMods and not rule.stats then problem("empty cells require a selfMods or stats payload") end
  for _, field in ipairs({ "mods", "selfMods", "stats" }) do
    local values = rule[field]
    if values ~= nil then
      if type(values) ~= "table" then problem(field .. " must be a table")
      else
        local allowed = field == "stats" and STAT_FIELDS or MOD_FIELDS
        for key, value in pairs(values) do
          if not allowed[key] then problem("has unknown " .. field .. " field " .. tostring(key)) end
          if type(value) ~= "number" or value ~= value or value <= -math.huge or value >= math.huge then
            problem(field .. "." .. tostring(key) .. " must be finite")
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
    if not def.use and #def.triggers > 0 and not def.passiveTriggers then
      problems[#problems + 1] = def.key .. " has inactive passive triggers"
    end
    checkShopWeights(problems, def)
    if def.spellIntercept ~= nil then
      local rule = def.spellIntercept
      if type(rule) ~= "table" or type(rule.cooldown) ~= "number" or rule.cooldown ~= rule.cooldown
        or rule.cooldown < Sim.TICK or rule.cooldown > Sim.MAX_TIME then
        problems[#problems + 1] = def.key .. " has invalid spell interception"
      end
    end
    if def.wardReflection ~= nil then
      local rule = def.wardReflection
      if type(rule) ~= "table" or not ns.ItemsByKey[rule.key] or not ({ fire = true, frost = true, nature = true, arcane = true, shadow = true, holy = true, magic = true })[rule.school]
        or type(rule.chance) ~= "number" or rule.chance ~= rule.chance or rule.chance < 0 or rule.chance > 100
        or type(rule.charges) ~= "number" or rule.charges ~= math.floor(rule.charges) or rule.charges < 1 or rule.charges > 3 then
        problems[#problems + 1] = def.key .. " has invalid ward reflection"
      end
    end
    for _, filter in ipairs(def.blockUses or {}) do checkMatch(problems, def.key, filter) end
    if def.useRestrictionText ~= nil and type(def.useRestrictionText) ~= "string" then problems[#problems + 1] = def.key .. " has invalid ability restriction text" end
    for _, bonus in ipairs(def.gearBonuses or {}) do
      if type(bonus) ~= "table" or not STAT_FIELDS[bonus.stat] or not STAT_FIELDS[bonus.gearStat] or type(bonus.coef) ~= "number"
        or bonus.coef ~= bonus.coef or bonus.coef < 0 or bonus.coef == math.huge then problems[#problems + 1] = def.key .. " has invalid equipped stat scaling" end
    end
    if def.coating ~= nil and (type(def.coating) ~= "boolean" or def.coating and def.kind ~= "ability") then
      problems[#problems + 1] = def.key .. " has invalid weapon coating"
    end
    if def.trainingMaxRank ~= nil and (type(def.trainingMaxRank) ~= "number" or def.trainingMaxRank ~= math.floor(def.trainingMaxRank)
      or def.trainingMaxRank < 1 or def.trainingMaxRank > ns.Ranks.MaxRank(def)) then problems[#problems + 1] = def.key .. " has invalid trainable rank maximum" end
    if not def.rank and ns.Ranks and ns.Ranks.ValidateProfile then
      for _, problem in ipairs(ns.Ranks.ValidateProfile(def)) do problems[#problems + 1] = problem end
    end
    if def.use then
      checkCondition(problems, def.key, def.use.condition)
      checkMatch(problems, def.key, def.use.needsNeighbor)
      if def.use.recoverUsed ~= nil and (type(def.use.recoverUsed) ~= "boolean" or not def.use.minRecovering) then
        problems[#problems + 1] = def.key .. " has invalid used-spell recovery requirement"
      end
      if def.use.minRecovering ~= nil and (type(def.use.minRecovering) ~= "number" or def.use.minRecovering ~= def.use.minRecovering
        or def.use.minRecovering <= 0 or def.use.minRecovering > 1) then problems[#problems + 1] = def.key .. " has invalid recovery threshold" end
      if def.use.prefer ~= nil then
        local preference = def.use.prefer
        if type(preference) ~= "table" or type(preference.wait) ~= "number" or preference.wait <= 0 or preference.wait > 3
          or not preference.condition then problems[#problems + 1] = def.key .. " has invalid activation preference"
        else checkCondition(problems, def.key, preference.condition) end
      end
      if def.use.comboCost ~= nil and (def.use.resource ~= "energy" or type(def.use.comboCost) ~= "number"
        or def.use.comboCost ~= math.floor(def.use.comboCost) or def.use.comboCost < 1 or def.use.comboCost > 5
        or def.use.spendAll or def.use.spendMax or def.use.empower) then
        problems[#problems + 1] = def.key .. " has invalid secondary Combo Point cost"
      end
      if def.use.spendCombo ~= nil and (type(def.use.spendCombo) ~= "boolean" or not def.use.comboCost) then
        problems[#problems + 1] = def.key .. " has invalid Combo Point spending"
      end
      for _, field in ipairs({ "prepare", "delay" }) do
        local value = def.use[field]
        if value ~= nil and (type(value) ~= "number" or value ~= value or value <= 0 or value > Sim.MAX_TIME
          or def.use.channel or field == "prepare" and def.use.delay) then
          problems[#problems + 1] = def.key .. " has invalid " .. field
        end
      end
      checkEffects(problems, def.key, def.use.effects)
    end
    if def.actor ~= nil then
      local requiresPet = def.use and def.use.requires == "pet"
      for _, flag in ipairs(def.use and type(def.use.requires) == "table" and def.use.requires or {}) do
        requiresPet = requiresPet or flag == "pet"
      end
      if def.actor ~= "pet" or not requiresPet or def.use.prepare or def.use.channel then
        problems[#problems + 1] = def.key .. " has invalid pet actor"
      end
    end
    checkTriggers(problems, def.key, def.triggers)
    for _, rule in ipairs(def.adjacency) do
      local valid, reason = ns.Grid.ValidateEffectRule(rule)
      if not valid then problems[#problems + 1] = def.key .. " " .. reason end
      if type(rule) == "table" then
        checkMatch(problems, def.key, rule.match)
        checkSpatialPayload(problems, def, rule)
        if def.kind == "bag" and (rule.side or rule.corners or rule.empty) then
          problems[#problems + 1] = def.key .. " bag effects do not support item spatial selectors"
        end
      end
    end
    for _, c in ipairs(def.shopClasses or {}) do
      if not ns.Classes[c] then problems[#problems + 1] = def.key .. " is offered to unknown class " .. tostring(c) end
    end
    if ns.RETIRED_IDS and ns.RETIRED_IDS[def.id] then
      problems[#problems + 1] = def.key .. " reuses retired id " .. def.id
    end
    if def.set and not ns.Sets[def.set] then
      problems[#problems + 1] = def.key .. " references unknown set " .. def.set
    end
    if def.stockKey ~= nil then
      local shared = ns.ItemsByKey[def.stockKey]
      if type(def.stockKey) ~= "string" or not shared or shared == def or shared.stockKey
        or shared.kind ~= def.kind or shared.rank or def.rank then
        problems[#problems + 1] = def.key .. " has invalid shared stock family"
      end
    end
    if def.revive ~= nil then
      local revive = def.revive
      local valid = type(revive) == "table" and type(revive.health) == "number"
        and revive.health > 0 and revive.health <= 1
      if type(revive) == "table" then
        for key, value in pairs(revive) do
          if key ~= "health" and key ~= "mana" or type(value) ~= "number" or value ~= value or value <= 0 or value > 1 then valid = false end
        end
      end
      if not valid then problems[#problems + 1] = def.key .. " has invalid revival fractions" end
    end
    if def.lethalSave ~= nil then
      local save = def.lethalSave
      if type(save) ~= "table" or type(save.health) ~= "number" or save.health <= 0 or save.health > 1
        or type(save.duration) ~= "number" or save.duration <= 0 or save.duration > Sim.MAX_TIME then
        problems[#problems + 1] = def.key .. " has invalid lethal safeguard"
      else checkEffects(problems, def.key .. " lethal safeguard", save.effects) end
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
