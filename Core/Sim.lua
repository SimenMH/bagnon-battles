local ADDON, ns = ...
local Util = ns.Util

local Sim = {}
ns.Sim = Sim

Sim.TICK = 0.1
Sim.MAX_TIME = 90
Sim.FATIGUE_START = 45
Sim.BASE_CRIT = 5
Sim.BASE_DODGE = 5
Sim.MAX_EVENTS = 64000
Sim.MAX_CHAIN_PROCS = 128
Sim.RAGE_PER_DAMAGE_DEALT = 0.5
Sim.RAGE_PER_DAMAGE_TAKEN = 0.2

local STAT_KEYS = { "hp", "hpPct", "armor", "ap", "sp", "crit", "critDamage", "haste", "dodge", "block", "blockChance", "thorns",
  "lifesteal", "healing", "mana", "regen", "dr", "dmgPct", "healPct", "petPct", "rangedPct", "meleePct", "spellPct",
  "ragePct", "rageTakenPct", "rageOnCrit" }
Sim.STAT_KEYS = STAT_KEYS

local MOD_KEYS = { "dmgPct", "healPct", "crit", "haste", "costPct", "cdPct", "flat", "ammoEffectPct" }
Sim.MOD_KEYS = MOD_KEYS

Sim.EFFECT_TYPES = Util.Set{ "tickDots", "tickHots", "damage", "heal", "dot", "hot", "refresh", "buff", "debuff", "resource", "bank",
  "charge", "sacrificePet", "extraAttack", "cast", "absorb", "stun", "clearControl", "cdr", "cleanse", "purge", "drain" }
Sim.ITEM_KEY_EFFECTS = Util.Set{ "cast", "charge" }

Sim.TRIGGER_EVENTS = Util.Set{ "battleStart", "use", "anyUse", "adjacentUse", "hit", "anyHit", "adjacentHit", "crit", "anyCrit",
  "adjacentCrit", "regularHit", "extraHit", "damaged", "block", "absorbed", "armorPrevented", "targetDodged", "dodged", "healed",
  "hotTick", "dotTick", "healthSpent", "resourceGained", "resourceSpent", "resourceOverflow", "below40", "lowHealth", "stunned",
  "enemyStunned" }

local floor, max, min = math.floor, math.max, math.min

function Sim.InitialCooldown(use, maximum)
  maximum = maximum or use.cd
  if use.once then return use.initialDelay or use.cd end
  if use.initialDelay then return math.min(maximum, use.initialDelay) end
  if use.reactive then return 0 end
  if use.initialPct then return maximum * use.initialPct end
  return math.min(maximum, 3 + 0.25 * maximum)
end

function Sim.RageDamageScale(side)
  if side.provides and side.provides.bearform then
    local curve = ns.Economy.RAGE_REFERENCE_HEALTH
    local round = Util.Clamp(side.round or 1, 1, #curve)
    return math.min(0.65, math.sqrt(curve[1] / curve[round]))
  end
  return 1
end

function Sim.ArmorReduction(armor)
  armor = max(0, armor or 0)
  return min(0.6, armor / (armor + 200))
end

function Sim.CritChance(bonus)
  return Util.Clamp(Sim.BASE_CRIT + bonus, 0, 100)
end

function Sim.DodgeChance(bonus)
  return Util.Clamp(Sim.BASE_DODGE + bonus, 0, 100)
end

local function talentSourceKey(classKey, tag, points)
  return "talent:" .. classKey .. ":" .. tag .. ":" .. points
end
Sim.TalentSourceKey = talentSourceKey

local function setSourceKey(setKey, threshold)
  return setKey .. "_" .. threshold, "set:" .. setKey .. ":" .. threshold
end

local function displayDefinition(key, name, icon, quality, bonus)
  return { key = key, name = name, icon = icon or "Interface\\Icons\\INV_Misc_QuestionMark", kind = "ability", passiveTriggers = true,
    quality = quality, stats = bonus.stats or {}, triggers = bonus.triggers or {}, adjacency = {}, tagSet = {}, tags = {} }
end

function Sim.SourceDefinition(key)
  if ns.ItemsByKey[key] then return ns.ItemsByKey[key] end
  if type(key) ~= "string" then return nil end
  local class, spec, points = key:match("^talent:([A-Z]+):([a-z]+):(%d+)$")
  local tree = class and ns.Mastery.Definition(class, spec)
  if tree then
    points = tonumber(points)
    for _, tier in ipairs(tree.tiers) do
      if tier.points == points then
        return displayDefinition(key, string.format(ns.L["%s talents (%d points)"], tree.name, points), tree.icon, 3, tier)
      end
    end
    return nil
  end
  local setKey, threshold = key:match("^(.+)_(%d+)$")
  threshold = tonumber(threshold)
  local set = setKey and ns.Sets[setKey]
  local bonus = set and set.bonuses[threshold]
  if not bonus then return nil end
  local first = ns.SetPieces(setKey)[1]
  local def = displayDefinition(key, string.format(ns.L["%s (%d pieces)"], set.name, threshold), first and first.icon,
    first and first.quality or 2, bonus)
  def.set, def.setThreshold = setKey, threshold
  return def
end

local function newStats()
  local s = {}
  for i = 1, #STAT_KEYS do s[STAT_KEYS[i]] = 0 end
  return s
end

local function newMods()
  local m = {}
  for i = 1, #MOD_KEYS do m[MOD_KEYS[i]] = 0 end
  return m
end

local function addTriggerSource(side, uid, def)
  def.passiveTriggers, def.tags, def.tagSet, def.stats, def.adjacency = true, {}, {}, {}, {}
  local it = { uid = uid, order = #side.items + 1, def = def, mods = newMods(), fired = 0, dmg = 0, heal = 0, enabled = true,
    trigIcd = {}, trigProgress = {}, neighbors = {} }
  side.items[#side.items + 1] = it
  side.byUid[uid] = it
  return it
end
Sim.AddTriggerSource = addTriggerSource

local function ammoEffectScale(it)
  if not it or it.def.kind ~= "ammo" then return 1 end
  return max(0, 1 + (it.mods.ammoEffectPct or 0) / 100)
end

local function addStats(target, source, mult)
  if not source then return end
  mult = mult or 1
  for k, v in pairs(source) do
    if type(v) == "number" then target[k] = (target[k] or 0) + v * mult end
  end
end

local function ownerStat(side, stat)
  if (stat == "block" or stat == "blockChance") and not (side.shield and side.shield.equipped) then return 0 end
  local v = side.stats[stat] or 0
  local strongest
  for i = 1, #side.buffs do
    local b = side.buffs[i]
    if b.stat == stat and not b.itemMatch and not b.paidOnly and not (stat == "dr" and (b.damageSchool or b.rangedOnly)) then
      local value = b.value
      if b.missingHealth then value = value * max(0, 1 - side.hp / side.hpMax) end
      if b.exclusiveGroup and value < 0 then
        strongest = strongest or {}
        local previous = strongest[b.exclusiveGroup] or 0
        if value < previous then
          v = v + value - previous
          strongest[b.exclusiveGroup] = value
        end
      else
        v = v + value
      end
    end
  end
  return v
end
Sim.OwnerStat = ownerStat

local function scopedDamageReduction(side, school, ranged)
  local total = 0
  for _, buff in ipairs(side.buffs) do
    if buff.stat == "dr" and not buff.itemMatch and (buff.damageSchool or buff.rangedOnly)
      and (not buff.rangedOnly or ranged)
      and (not buff.damageSchool or buff.damageSchool == school or buff.damageSchool == "magic" and school and school ~= "physical") then
      local value = buff.value
      if buff.missingHealth then value = value * max(0, 1 - side.hp / side.hpMax) end
      total = total + value
    end
  end
  return total
end

local function mitigateDamage(side, amount, school, ranged)
  local reduction = ownerStat(side, "dr") + scopedDamageReduction(side, school, ranged)
  amount = amount * (1 - min(0.9, reduction / 100))
  local absorbed = min(side.absorb, amount)
  side.absorb = side.absorb - absorbed
  return amount - absorbed, absorbed
end

local function bankLimit(side, cap)
  local value = cap.flat or 0
  for stat, scale in pairs(cap) do
    if stat ~= "flat" then value = value + ownerStat(side, stat) * scale end
  end
  return max(0, value)
end

local function itemStat(side, it, stat)
  local value = ownerStat(side, stat)
  for _, buff in ipairs(side.buffs) do
    local paid = not buff.paidOnly or side.itemActivation and side.itemActivation.item == it
      and side.itemActivation.paidBuffs and side.itemActivation.paidBuffs[buff]
    if buff.stat == stat and buff.itemMatch and Util.MatchDef(it.def, buff.itemMatch)
      and (not buff.itemUids or buff.itemUids[it.uid]) and paid then
      local amount = buff.paidOnly and paid.value or buff.value
      if buff.missingHealth then amount = amount * max(0, 1 - side.hp / side.hpMax) end
      value = value + amount
    end
  end
  return value
end

local function cooldownSpeed(side, it)
  return max(0.25, 1 + (itemStat(side, it, "haste") + it.mods.haste) / 100)
end

local function newTrace(sim, parent)
  sim.traceSequence = (sim.traceSequence or 0) + 1
  local id = sim.traceSequence
  return { rootId = parent and parent.rootId or id, nodeId = id,
    parentNodeId = parent and parent.nodeId, depth = parent and parent.depth + 1 or 0 }
end

local function traced(fn)
  return function(sim, ...)
    local previous = sim.trace
    if not previous then sim.trace = newTrace(sim) end
    local result = fn(sim, ...)
    sim.trace = previous
    return result
  end
end

local function pushEvent(sim, ev)
  if #sim.events < Sim.MAX_EVENTS then
    local trace = sim.trace or newTrace(sim)
    ev.rootId, ev.nodeId, ev.parentNodeId, ev.depth = trace.rootId, trace.nodeId, trace.parentNodeId, trace.depth
    sim.events[#sim.events + 1] = ev
  end
end

local function pushCooldown(sim, side, it, t, paused, speed)
  speed = speed or cooldownSpeed(side, it)
  local remaining = it.def.use.once and it.fired > 0 and 0 or max(0, it.cd / speed)
  pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "cooldown", cd = remaining, duration = it.cdMax / speed, paused = paused })
end

local function ownerOccupied(side)
  return side.channel ~= nil or side.deferredReleasing == true
end

local function advanceCooldown(sim, side, it, amount, t, clampReady)
  if side.stunUntil > t then return end
  local speed = cooldownSpeed(side, it)
  it.cd = it.cd - amount * speed
  if clampReady or ownerOccupied(side) and it.def.kind ~= "pet" then it.cd = max(0, it.cd) end
  if it.def.use then pushCooldown(sim, side, it, t, false, speed) end
end

local checkRevive, tickStatus

local function syncCooldowns(sim, side, t)
  for _, it in ipairs(side.actOrder or {}) do
    if it.enabled then
      local speed = cooldownSpeed(side, it)
      local paused = side.stunUntil > t
      if it.cooldownSpeed ~= speed or it.cooldownPaused ~= paused then
        it.cooldownSpeed, it.cooldownPaused = speed, paused
        pushCooldown(sim, side, it, t, paused, speed)
      end
    end
  end
end

local function weaponAverage(def)
  return ((def.weaponMin or 0) + (def.weaponMax or 0)) / 2 / (def.use and def.use.cd or 2)
end

local function placementOrder(a, b)
  if a.x ~= b.x then return a.x < b.x end
  if a.y ~= b.y then return a.y < b.y end
  if a.id ~= b.id then return a.id < b.id end
  return (a.rot or 0) < (b.rot or 0)
end

local function buildSide(sim, id, fighter)
  local classDef = ns.GetClass(fighter.classKey)
  if ns.Mastery then
    local valid, err = ns.Mastery.Validate(fighter.classKey, fighter.round, fighter.talents)
    assert(valid, err)
  end
  local side = {
    id = id, name = fighter.name or id, classKey = fighter.classKey, classDef = classDef,
    round = fighter.round, grid = fighter.grid,
    stats = newStats(), gearStats = {}, res = {}, items = {}, byUid = {}, statuses = {}, buffs = {}, banks = {}, bankCaps = {},
    absorb = 0, provides = {}, flags = {}, stunUntil = 0, lowHealthFired = false, below40Fired = false,
    dmgDone = 0, healDone = 0, dmgTaken = 0, setCounts = {}, doubleMatches = {}, freeMatches = {},
  }
  side.stats.armor = classDef.baseArmor or 0
  side.stats.ap = classDef.baseAP or 0
  if classDef.resources then
    for res, cfg in pairs(classDef.resources) do
      side.res[res] = { cur = cfg.start or 0, max = cfg.max, regen = cfg.regen or 0 }
    end
  end
  side.primary = classDef.primary

  local grid = fighter.grid
  local placements = {}
  for i, p in ipairs(grid.items) do placements[i] = p end
  table.sort(placements, placementOrder)
  for i, p in ipairs(placements) do
    local def = ns.Items[p.id]
    local it = {
      uid = p.uid, order = i, def = def, placement = p, mods = newMods(), fired = 0, dmg = 0, heal = 0,
      enabled = true, reason = nil, trigIcd = {}, trigProgress = {},
    }
    side.items[#side.items + 1] = it
    side.byUid[p.uid] = it
  end

  local melee, ranged, pets, shields, forms = {}, {}, {}, {}, {}
  local exclusive = {}
  for _, it in ipairs(side.items) do
    local def = it.def
    if def.exclusiveGroup then
      if exclusive[def.exclusiveGroup] then
        it.enabled, it.suppressed, it.reason = false, true, "exclusive"
      else
        exclusive[def.exclusiveGroup] = it
      end
    end
    if def.kind == "weapon" then
      if ns.IsRangedWeapon(def) then ranged[#ranged + 1] = it else melee[#melee + 1] = it end
    elseif def.kind == "shield" then
      shields[#shields + 1] = it
    elseif def.kind == "pet" then
      pets[#pets + 1] = it
    elseif def.kind == "form" then
      local slot = ns.Grid.EquipmentSlot(def)
      forms[slot] = forms[slot] or {}
      forms[slot][#forms[slot] + 1] = it
    end
  end
  local function byPower(a, b)
    local pa, pb = weaponAverage(a.def), weaponAverage(b.def)
    if pa ~= pb then return pa > pb end
    return a.order < b.order
  end
  table.sort(melee, byPower)
  table.sort(ranged, byPower)
  table.sort(shields, function(a, b)
    for _, stat in ipairs({ "armor", "block", "blockChance", "hp", "dr", "dodge" }) do
      local av, bv = a.def.stats[stat] or 0, b.def.stats[stat] or 0
      if av ~= bv then return av > bv end
    end
    return a.order < b.order
  end)
  side.weaponMelee, side.weaponRanged = melee[1], ranged[1]
  if not melee[1] or melee[1].def.hands ~= 2 then side.shield = shields[1] end
  for _, it in ipairs(shields) do
    it.equipped = it == side.shield
    it.suppressed = not it.equipped
    it.enabled = it.equipped
  end
  local activeWeapons = {}
  if melee[1] then
    activeWeapons[melee[1]] = true
    if classDef.dualWield and melee[1].def.hands == 1 and not side.shield then
      for i = 2, #melee do
        if melee[i].def.hands == 1 then activeWeapons[melee[i]] = true break end
      end
    end
  end
  if ranged[1] then activeWeapons[ranged[1]] = true end
  side.provides.twohand = melee[1] and melee[1].def.hands == 2 or false
  local activeMelee = 0
  for _, weapon in ipairs(melee) do if activeWeapons[weapon] then activeMelee = activeMelee + 1 end end
  side.provides.dualwield = activeMelee == 2
  for _, weapons in ipairs({ melee, ranged }) do
    for _, it in ipairs(weapons) do
      it.equipped = activeWeapons[it] == true
      if not it.equipped then it.enabled, it.suppressed, it.reason = false, true, "hands" end
    end
  end
  side.activePet = pets[1]
  for i = 2, #pets do pets[i].enabled = false pets[i].suppressed = true pets[i].reason = "onepet" end
  for slot, list in pairs(forms) do
    for i = 2, #list do list[i].enabled = false list[i].suppressed = true list[i].reason = "one" .. slot end
  end

  for _, it in ipairs(side.items) do
    local def = it.def
    if not it.suppressed then
      if def.provides then
        local list = type(def.provides) == "table" and def.provides or { def.provides }
        for _, flag in ipairs(list) do side.provides[flag] = true end
      end
      if def.grants then
        for res, cfg in pairs(def.grants) do
          if not side.res[res] then side.res[res] = { cur = cfg.start or 0, max = cfg.max, regen = cfg.regen or 0 }
          else
            side.res[res].cur = max(side.res[res].cur, cfg.start or 0)
            side.res[res].max = max(side.res[res].max, cfg.max)
            side.res[res].regen = max(side.res[res].regen, cfg.regen or 0)
          end
        end
      end
      if def.kind == "weapon" then
        side.provides.weapon = true
        if ns.IsRangedWeapon(def) then side.provides.ranged = true else side.provides.melee = true end
      elseif def.kind == "shield" then side.provides.shield = true
      elseif def.kind == "pet" then side.provides.pet = true
      end
      if def.set then
        side.setCounts[def.set] = side.setCounts[def.set] or {}
        side.setCounts[def.set][def.key] = true
      end
      if def.double then side.doubleMatches[#side.doubleMatches + 1] = def.double end
      addStats(side.stats, def.stats)
      -- Printed equipment stats only. Class bases, talents, sets, temporary
      -- effects and ability buffs cannot amplify a gear-derived buff.
      if def.kind == "weapon" and activeWeapons[it] or def.kind == "shield" and it.equipped
        or def.kind == "armor" or def.kind == "ring" or def.kind == "trinket" or def.kind == "neck"
        or def.kind == "cloak" or def.kind == "relic" then addStats(side.gearStats, def.stats) end
    end
  end

  side.setBonuses = {}
  for _, setKey in ipairs(Util.SortedKeys(side.setCounts)) do
    local pieces = side.setCounts[setKey]
    local setDef = ns.Sets[setKey]
    local count = Util.Count(pieces)
    if setDef then
      for _, threshold in ipairs(setDef.thresholds) do
        if count >= threshold then
          local bonus = setDef.bonuses[threshold]
          side.setBonuses[#side.setBonuses + 1] = { set = setKey, pieces = threshold }
          addStats(side.stats, bonus.stats)
          if bonus.flags then for _, f in ipairs(bonus.flags) do side.flags[f] = true end end
          if bonus.double then side.doubleMatches[#side.doubleMatches + 1] = bonus.double end
          if bonus.free then side.freeMatches[#side.freeMatches + 1] = bonus.free end
          if bonus.triggers then
            local first = ns.SetPieces(setKey)[1]
            local key, uid = setSourceKey(setKey, threshold)
            addTriggerSource(side, uid, { key = key, name = setDef.name, icon = first and first.icon, kind = "set", triggers = bonus.triggers })
          end
          if bonus.mods then
            for _, it in ipairs(side.items) do
              if Util.MatchDef(it.def, bonus.mods.match) then
                for _, k in ipairs(MOD_KEYS) do
                  if bonus.mods[k] then it.mods[k] = it.mods[k] + bonus.mods[k] end
                end
              end
            end
          end
        end
      end
    end
  end

  for _, it in ipairs(side.items) do
    local adjacent = it.placement and not it.suppressed and grid:EffectNeighbors(it.placement) or {}
    local neighbors = {}
    for _, placement in ipairs(adjacent) do
      local other = side.byUid[placement.uid]
      if other and not other.suppressed then neighbors[#neighbors + 1] = placement end
    end
    table.sort(neighbors, placementOrder)
    it.neighbors = neighbors
  end

  local function ruleNeighbors(it, rule)
    if not rule.side and not rule.corners and not rule.empty then return it.neighbors end
    if not it.placement or it.suppressed then return {}, 0 end
    local resolved = grid:ResolveEffect(it.placement, rule)
    if rule.empty then return {}, resolved.count end
    local neighbors = {}
    for _, placement in ipairs(resolved.neighbors) do
      local other = side.byUid[placement.uid]
      if other and not other.suppressed then neighbors[#neighbors + 1] = placement end
    end
    table.sort(neighbors, placementOrder)
    return neighbors
  end

  for _, it in ipairs(side.items) do
    for _, rule in ipairs(it.def.adjacency) do
      if rule.mods and rule.mods.ammoEffectPct or rule.selfMods and rule.selfMods.ammoEffectPct then
        local neighbors, emptyCount = ruleNeighbors(it, rule)
        local matches = emptyCount or 0
        for _, np in ipairs(neighbors) do
          local other = side.byUid[np.uid]
          if other and Util.MatchDef(other.def, rule.match) then
            matches = matches + 1
            if other.def.kind == "ammo" and rule.mods and rule.mods.ammoEffectPct then
              other.mods.ammoEffectPct = other.mods.ammoEffectPct + rule.mods.ammoEffectPct
            end
            if rule.once then break end
          end
        end
        if matches > 0 and it.def.kind == "ammo" and rule.selfMods and rule.selfMods.ammoEffectPct then
          local times = rule.once and 1 or matches
          it.mods.ammoEffectPct = it.mods.ammoEffectPct + rule.selfMods.ammoEffectPct * times
        end
      end
    end
    if it.def.kind == "ammo" and it.placement and not it.suppressed then
      for _, bagP in ipairs(grid:AdjacentBags(it.placement)) do
        for _, rule in ipairs(ns.Items[bagP.id].adjacency or {}) do
          if rule.mods and rule.mods.ammoEffectPct and Util.MatchDef(it.def, rule.match)
            and (not rule.inside or grid:ItemInsideBag(it.placement, bagP)) then
            it.mods.ammoEffectPct = it.mods.ammoEffectPct + rule.mods.ammoEffectPct
          end
        end
      end
    end
  end

  for _, it in ipairs(side.items) do
    local scale = ammoEffectScale(it)
    for _, rule in ipairs(it.def.adjacency) do
      local neighbors, emptyCount = ruleNeighbors(it, rule)
      local matches = emptyCount or 0
      for _, np in ipairs(neighbors) do
        local other = side.byUid[np.uid]
        if other and Util.MatchDef(other.def, rule.match) then
          matches = matches + 1
          if rule.mods then
            for _, k in ipairs(MOD_KEYS) do
              if k ~= "ammoEffectPct" and rule.mods[k] then other.mods[k] = other.mods[k] + rule.mods[k] * scale end
            end
          end
          if rule.once and matches >= 1 then break end
        end
      end
      if matches > 0 then
        local times = rule.once and 1 or matches
        if rule.selfMods then
          for _, k in ipairs(MOD_KEYS) do
            if k ~= "ammoEffectPct" and rule.selfMods[k] then it.mods[k] = it.mods[k] + rule.selfMods[k] * times * scale end
          end
        end
        if rule.stats then addStats(side.stats, rule.stats, times * scale) end
      end
    end
    local bags = it.placement and not it.suppressed and grid:AdjacentBags(it.placement) or {}
    table.sort(bags, placementOrder)
    for _, bagP in ipairs(bags) do
      local bagDef = ns.Items[bagP.id]
      for _, rule in ipairs(bagDef.adjacency or {}) do
        local applies = Util.MatchDef(it.def, rule.match)
        if applies and rule.inside and not grid:ItemInsideBag(it.placement, bagP) then applies = false end
        if applies then
          if rule.mods then
            for _, k in ipairs(MOD_KEYS) do
              if k ~= "ammoEffectPct" and rule.mods[k] then it.mods[k] = it.mods[k] + rule.mods[k] end
            end
          end
          if rule.stats then addStats(side.stats, rule.stats) end
        end
      end
    end
  end

  if ns.Mastery then ns.Mastery.Apply(side, fighter.talents) end
  side.provides.shield = side.shield ~= nil
  if not side.shield then side.stats.block, side.stats.blockChance = 0, 0 end
  side.hpMax = ns.Economy.BaseHealth(side.round) + side.stats.hp
  if side.stats.hpPct ~= 0 then side.hpMax = Util.Round(side.hpMax * max(0, 1 + side.stats.hpPct / 100)) end
  side.hp = side.hpMax
  if side.res.mana then
    side.res.mana.max = side.res.mana.max + side.stats.mana
    side.res.mana.regen = side.res.mana.regen + side.stats.regen
    side.res.mana.cur = side.res.mana.max
  end
  for _, it in ipairs(side.items) do
    local use = it.def.use
    if use then
      local req = use.requires
      if req and it.enabled then
        local list = type(req) == "table" and req or { req }
        for _, flag in ipairs(list) do
          if not side.provides[flag] then
            it.enabled = false
            it.reason = flag
            break
          end
        end
      end
      if it.enabled and use.resource and not side.res[use.resource] then
        it.enabled = false
        it.reason = use.resource
      end
      it.cdMax = use.cd * max(0.2, 1 - it.mods.cdPct / 100)
      it.cd = Sim.InitialCooldown(use, it.cdMax)
    else
      it.enabled = false
    end
  end
  local formAttack
  for _, it in ipairs(side.items) do
    if it.enabled and it.def.use and it.def.replacesWeapon then
      if formAttack then it.noAct = true else formAttack = it end
    end
  end
  side.formAttack = formAttack
  side.actOrder = {}
  local wand = side.weaponRanged and side.weaponRanged.def.weaponType == "wand"
  for _, it in ipairs(side.items) do
    local meleeWeapon = it.def.kind == "weapon" and not ns.IsRangedWeapon(it.def)
    it.statStick = (formAttack or wand) and meleeWeapon and it.equipped or nil
    local skip = it.noAct or ((formAttack or wand) and meleeWeapon)
    if it.def.use and not skip then side.actOrder[#side.actOrder + 1] = it end
  end
  table.sort(side.actOrder, function(a, b)
    local pa, pb = a.def.use.priority or a.def.use.cd, b.def.use.priority or b.def.use.cd
    if pa ~= pb then return pa > pb end
    local ca, cb = a.def.use.cost or 0, b.def.use.cost or 0
    if ca ~= cb then return ca > cb end
    return a.order < b.order
  end)
  for _, it in ipairs(side.actOrder) do
    it.cooldownSpeed = cooldownSpeed(side, it)
    it.cooldownPaused = false
  end
  return side
end

local function indexOf(list, value)
  for index, current in ipairs(list) do
    if current == value then return index end
  end
end

local function statusTick(sim, side, t)
  for _, st in ipairs(Util.ShallowCopy(side.statuses)) do
    if indexOf(side.statuses, st) then
      local expired = st.expiresAt and t > st.expiresAt + 1e-6
      if not expired and st.nextTick <= t + 1e-6 then
        st.nextTick = st.nextTick + 1
        st.remaining = st.remaining - 1
        tickStatus(sim, side, st, t)
      end
      if expired or not st.expiresAt and st.remaining <= 0 then
        local index = indexOf(side.statuses, st)
        if index then table.remove(side.statuses, index) end
      end
    end
  end
end

local function expireBuffs(sim, side, dt, t)
  local i = 1
  local hasteExpired = false
  while i <= #side.buffs do
    local b = side.buffs[i]
    b.remaining = b.remaining - dt
    if b.remaining <= 0 then
      hasteExpired = hasteExpired or b.stat == "haste"
      table.remove(side.buffs, i)
    else i = i + 1 end
  end
  if hasteExpired then syncCooldowns(sim, side, t) end
end

local function regen(side, dt)
  for res, pool in pairs(side.res) do
    local rate = pool.regen
    if res == "mana" then rate = rate + ownerStat(side, "regen") - (side.stats.regen or 0) end
    if rate > 0 then
      pool.cur = min(pool.max, pool.cur + rate * dt)
    end
  end
end

local function hasStatus(side, kind, key)
  for _, st in ipairs(side.statuses) do
    if st.kind == kind and (not key or st.key == key) then return true end
  end
  return false
end

local CONDITIONS = {
  dualwield = function(side) return side.provides.dualwield == true end,
  injured = function(side) return side.hp < side.hpMax * 0.9 end,
  below50 = function(side) return side.hp < side.hpMax * 0.5 end,
  below35 = function(side) return side.hp < side.hpMax * 0.35 end,
  enemyBelow20 = function(_, enemy) return enemy.hp < enemy.hpMax * 0.2 end,
  enemyBelow50 = function(_, enemy) return enemy.hp < enemy.hpMax * 0.5 end,
  injuredWithHot = function(side) return side.hp < side.hpMax * 0.9 and hasStatus(side, "hot") end,
  enemyBleeding = function(_, enemy)
    for _, st in ipairs(enemy.statuses) do
      if st.kind == "dot" and st.school == "physical" then return true end
    end
    return false
  end,
  enemyPoisoned = function(side, enemy)
    for _, st in ipairs(enemy.statuses) do
      local source = side.byUid[st.srcUid]
      if st.kind == "dot" and st.srcSide == side.id and source and source.def.tagSet.poison then return true end
    end
    return false
  end,
  noAbsorb = function(side) return side.absorb <= 0 end,
  lowMana = function(side) return side.res.mana and side.res.mana.cur < side.res.mana.max * 0.3 end,
  hasDot = function(side) return hasStatus(side, "dot") end,
  enemyStunned = function(_, enemy, t) return enemy.stunUntil > t end,
}

local PREFIXED_CONDITIONS = {
  resourceAtLeast = function(side, _, _, resource, minimum) return side.res[resource] and side.res[resource].cur >= minimum or false end,
  provides = function(side, _, _, flag) return side.provides[flag] == true end,
  enemyHas = function(_, enemy, _, key) return hasStatus(enemy, "dot", key) end,
  buff = function(side, _, _, key)
    for _, b in ipairs(side.buffs) do if b.key == key then return true end end
    return false
  end,
}

local function parseCondition(cond)
  if type(cond) ~= "string" then return nil end
  if CONDITIONS[cond] then return CONDITIONS[cond] end
  local resource, minimum = cond:match("^resourceAtLeast:([^:]+):([%d%.]+)$")
  if resource then
    minimum = tonumber(minimum)
    if minimum then return PREFIXED_CONDITIONS.resourceAtLeast, resource, minimum end
    return nil
  end
  local prefix, arg = cond:match("^(%a+):(.+)$")
  if prefix ~= "resourceAtLeast" and PREFIXED_CONDITIONS[prefix] then return PREFIXED_CONDITIONS[prefix], arg end
end

function Sim.ValidCondition(cond)
  return cond == nil or parseCondition(cond) ~= nil
end

local function conditionMet(cond, side, enemy, t)
  if not cond then return true end
  local check, a, b = parseCondition(cond)
  if not check then return true end
  return check(side, enemy, t, a, b)
end

local applyEffect
local runTriggers
local fireItem
local applyHealing
local changeResource
local reactToDamage
local beginChannel, finishChannel, updateChannel, releaseDeferred, deferCast

local function beginChain(sim)
  if sim.chain then return false end
  sim.chain = { active = {}, count = 0, extraAttack = false, pending = {}, nextAttack = 1 }
  return true
end

local function finishChain(sim, owner)
  if not owner then return end
  local chain = sim.chain
  while chain.nextAttack <= #chain.pending and chain.count < Sim.MAX_CHAIN_PROCS do
    local entry = chain.pending[chain.nextAttack]
    chain.nextAttack = chain.nextAttack + 1
    chain.extraAttack = entry.weapon ~= nil
    for i = 1, entry.count do
      if entry.side.hp <= 0 or entry.enemy.hp <= 0 or chain.count >= Sim.MAX_CHAIN_PROCS then
        if entry.deferredRelease then entry.side.deferredReleasing = nil end
        break
      end
      if entry.side.stunUntil > entry.t or entry.side.channel or entry.side.deferredReleasing and not entry.deferredRelease then
        if entry.item and (entry.deferredRelease or entry.deferDuringChannel and (entry.side.channel or entry.side.stunUntil > entry.t)) then deferCast(entry.side, entry) end
        if entry.deferredRelease then entry.side.deferredReleasing = nil end
        break
      end
      if entry.deferredRelease then entry.side.deferredReleasing = nil end
      chain.count = chain.count + 1
      local previous = sim.trace
      sim.trace = newTrace(sim, entry.parentTrace)
      if entry.item then
        if entry.item.enabled and (entry.ignoreCondition or conditionMet(entry.item.def.use.condition, entry.side, entry.enemy, entry.t)) then
          if entry.consumeCooldown then entry.item.cd = entry.item.cdMax end
          fireItem(sim, entry.side, entry.enemy, entry.item, entry.t, { points = 0, freeCast = true, caster = entry.source,
            masteryFollowup = entry.masteryFollowup, masteryName = entry.masteryName })
          if entry.consumeCooldown then pushCooldown(sim, entry.side, entry.item, entry.t, entry.side.stunUntil > entry.t) end
        end
      else
        for _, effect in ipairs(entry.weapon.def.use.effects) do
          applyEffect(sim, entry.side, entry.enemy, entry.weapon, effect, entry.t, { extraAttack = true, autoAttack = true, bonusAttackPowerPct = entry.bonusAttackPowerPct })
        end
      end
      sim.trace = previous
    end
    chain.extraAttack = false
  end
  for index = chain.nextAttack, #chain.pending do
    local entry = chain.pending[index]
    if entry.deferredRelease then
      entry.side.deferredReleasing = nil
      deferCast(entry.side, entry)
    end
  end
  if sim.audit then sim.chainPeaks = max(sim.chainPeaks or 0, chain.count) end
  sim.chain = nil
end

deferCast = function(side, entry)
  if not side.deferredCast then side.deferredCast = entry end
end

beginChannel = function(sim, side, enemy, it, t)
  local config = it.def.use.channel
  if not config or ownerOccupied(side) then return end
  local channel = { uid = it.uid, key = config.key or it.def.baseKey or it.def.key, target = enemy.id,
    startedAt = t, endsAt = t + config.duration, duration = config.duration, starting = true }
  side.channel = channel
  for _, target in ipairs(side.actOrder) do
    if target.def.kind ~= "pet" then target.cd = max(0, target.cd) end
  end
  pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "channel", phase = "start", key = channel.key,
    target = enemy.id, duration = channel.duration, startedAt = t, endsAt = channel.endsAt })
  return channel
end

finishChannel = function(sim, side, t, phase, reason)
  local channel = side.channel
  if not channel then return end
  side.channel = nil
  local holder = sim.sides[channel.target]
  if holder then
    for index = #holder.statuses, 1, -1 do
      local status = holder.statuses[index]
      if status.kind == "dot" and status.key == channel.key and status.srcSide == side.id and status.srcUid == channel.uid then
        table.remove(holder.statuses, index)
        pushEvent(sim, { t = t, side = side.id, uid = channel.uid, type = "statusRemoved", kind = "dot", key = channel.key, target = holder.id })
      end
    end
  end
  pushEvent(sim, { t = t, side = side.id, uid = channel.uid, type = "channel", phase = phase, key = channel.key,
    target = channel.target, duration = channel.duration, startedAt = channel.startedAt, endsAt = channel.endsAt, reason = reason })
end

updateChannel = function(sim, side, t)
  local channel = side.channel
  if not channel or channel.starting then return end
  local holder = sim.sides[channel.target]
  for _, status in ipairs(holder and holder.statuses or {}) do
    if status.kind == "dot" and status.key == channel.key and status.srcSide == side.id and status.srcUid == channel.uid then
      if t + 1e-6 >= channel.endsAt and status.nextTick > channel.endsAt + 1e-6 then finishChannel(sim, side, t, "end") end
      return
    end
  end
  finishChannel(sim, side, t, "interrupt", "missing")
end

releaseDeferred = function(sim, side, enemy, t)
  if ownerOccupied(side) or side.stunUntil > t or side.hp <= 0 or enemy.hp <= 0 or not side.deferredCast then return end
  local entry = side.deferredCast
  side.deferredCast, side.deferredReleasing = nil, true
  entry.t, entry.deferredRelease = t, true
  local owner = beginChain(sim)
  sim.chain.pending[#sim.chain.pending + 1] = entry
  finishChain(sim, owner)
end

local function masteryEvent(sim, side, enemy, event, it, t, ctx)
  if not side.mastery or side.mastery.total == 0 then return end
  ctx = ctx or {}
  local points = side.talents
  local spec = it and it.masterySpec
  local family = it and (it.def.baseKey or it.def.key)
  local function advance(key, amount, clampReady)
    for _, target in ipairs(side.items) do
      if target.enabled and target.def.use and (target.def.baseKey or target.def.key) == key then advanceCooldown(sim, side, target, amount, t, clampReady) end
    end
  end
  local function every(key, count)
    local progress = (side.mastery.progress[key] or 0) + 1
    side.mastery.progress[key] = progress % count
    return progress >= count
  end
  local function cast(key, name, preferred)
    if side.stunUntil > t or ownerOccupied(side) then return false end
    for _, target in ipairs(preferred and { preferred } or side.items) do
      if target.enabled and target.def.use and (target.def.baseKey or target.def.key) == key
        and conditionMet(target.def.use.condition, side, enemy, t) then
        local owner = beginChain(sim)
        sim.chain.pending[#sim.chain.pending + 1] = { side = side, enemy = enemy, item = target, source = it, count = 1, t = t,
          masteryFollowup = true, masteryName = name, parentTrace = sim.trace }
        finishChain(sim, owner)
        return true
      end
    end
    return false
  end
  if event == "dodged" then
    if (points.surv or 0) >= 8 and every("surv_dodge", 3) then cast("raptor_strike", "Survival") end
  elseif not it then return
  elseif event == "hit" then
    local meleeAuto = ctx.autoAttack ~= false and it.def.kind == "weapon" and it.def.tagSet.melee and it.def.tagSet.autoattack
    if meleeAuto then
      if (points.fury or 0) >= 5 then
        advance("bloodthirst", 0.5)
        for _, target in ipairs(side.items) do
          if target.enabled and (target.def.baseKey or target.def.key) ~= "bloodthirst"
            and target.def.use and target.def.use.resource == "rage"
            and Util.MatchDef(target.def, { kind = "ability", tag = "melee", anyTag = { "strike" }, damaging = "direct" }) then
            advanceCooldown(sim, side, target, 0.25, t)
          end
        end
      end
    end
    if ctx.crit then
      if spec == "mm" and it.def.tagSet.shot and (points.mm or 0) >= 5 then changeResource(sim, side, enemy, it, "mana", 5, t) end
      if spec == "balance" and it.def.tagSet.spell and (points.balance or 0) >= 5 then advance("starfire", 1) end
      if spec == "feral" and it.def.kind == "ability" and not ctx.freeCast and (points.feral or 0) >= 8 then
        for _, target in ipairs(side.actOrder) do
          if target.enabled and target.def.replacesWeapon and not target.noAct then advance(target.def.baseKey or target.def.key, 1, true) break end
        end
      end
    end
  elseif event == "use" then
    if it.def.kind == "pet" then
      for attack = 1, ctx.petLandedAttacks or 0 do
        if (points.bm or 0) >= 5 then changeResource(sim, side, enemy, it, "focus", 4, t) end
        if (points.bm or 0) >= 8 and every("bm", 3) then
          if not cast("bite", "Beast Mastery") then cast("claw_pet", "Beast Mastery") end
        end
      end
    end
    if spec == "prot" and (points.prot or 0) >= 8 and (ctx.spent or 0) > 0 and not ctx.freeCast
      and Util.MatchDef(it.def, { tag = "strike", damaging = "direct" }) then
      applyEffect(sim, side, enemy, it, { type = "absorb", coef = 0.75, powerStat = "block" }, t)
    end
    if not ctx.freeCast then
      if spec == "mm" and it.def.tagSet.shot and (points.mm or 0) >= 8 and every("mm", 3) then cast("aimed_shot", "Marksmanship") end
      if spec == "balance" and it.def.tagSet.spell and (points.balance or 0) >= 8 and every("balance", 3) then advance("starfire", 4) end
    end
    if spec == "surv" and it.def.tagSet.trap and (points.surv or 0) >= 8 then cast("serpent_sting", "Survival") end
    if spec == "feral" and (points.feral or 0) >= 5 then
      local finisher = it.def.tagSet.finisher and (ctx.points or 0) > 0
      local bearStrike = it.def.tagSet.melee and it.def.use and it.def.use.resource == "rage"
      if finisher then applyHealing(sim, side, it, side.hpMax * 0.02, t) end
      if bearStrike and (ctx.spent or 0) > 0 then
        side.masteryCounters = side.masteryCounters or {}
        local paid = (side.masteryCounters.feralRage or 0) + ctx.spent
        local times = floor((paid + 1e-9) / 30)
        side.masteryCounters.feralRage = max(0, paid - times * 30)
        if times > 0 then applyHealing(sim, side, it, side.hpMax * 0.02 * times, t) end
      end
    end
  elseif event == "healed" and spec == "resto" and ctx.amount > 0 then
    if ctx.hot and (points.resto or 0) >= 5 then advance("swiftmend", 0.25) end
    if (points.resto or 0) >= 8 then applyEffect(sim, side, enemy, it, { type = "absorb", amount = ctx.amount * 0.35 }, t) end
  end
end

local function checkLowHealth(sim, side, enemy, t)
  if side.hp > 0 and not side.below40Fired and side.hp < side.hpMax * 0.4 then
    side.below40Fired = true
    runTriggers(sim, side, enemy, nil, "below40", t, {})
  end
  if side.hp > 0 and not side.lowHealthFired and side.hp < side.hpMax * 0.35 then
    side.lowHealthFired = true
    runTriggers(sim, side, enemy, nil, "lowHealth", t, {})
  end
end

checkRevive = function(sim, side, t)
  if side.hp <= 0 and side.flags.revive and not side.revived then
    local previous = sim.trace
    sim.trace = newTrace(sim, previous)
    side.revived = true
    side.hp = side.hpMax
    side.below40Fired = false
    side.absorb = 0
    side.statuses = {}
    pushEvent(sim, { t = t, side = side.id, type = "heal", amount = side.hpMax, target = side.id, revive = true })
    pushEvent(sim, { t = t, side = side.id, type = "revive", target = side.id })
    sim.trace = previous
  end
end

local function anyMatch(list, def)
  for _, m in ipairs(list) do
    if Util.MatchDef(def, m) then return true end
  end
  return false
end

local function attackRange(it, e)
  if e.pet or it.def.kind == "pet" then return "pet" end
  if e.ranged or it.def.kind == "ammo" or ns.IsRangedWeapon(it.def) then return "ranged" end
  return "melee"
end

local function damageMultiplier(side, it, e)
  local mult = 1 + (itemStat(side, it, "dmgPct") + it.mods.dmgPct) / 100
  if side.classKey == "SHAMAN" and e.weaponSelf and it.def.kind == "weapon" and not ns.IsRangedWeapon(it.def) then
    mult = mult + (side.talents.enhancement or 0) * ns.Mastery.SPEC_BONUS_PCT / 100
  end
  local range = attackRange(it, e)
  if range == "pet" then mult = mult + itemStat(side, it, "petPct") / 100 end
  if (e.school or "physical") == "physical" then
    if range == "ranged" then mult = mult + itemStat(side, it, "rangedPct") / 100
    elseif range == "melee" then mult = mult + itemStat(side, it, "meleePct") / 100 end
  else
    mult = mult + itemStat(side, it, "spellPct") / 100
  end
  return max(0, mult)
end

local function healingPenalty(side, it)
  local reduction = min(0, side.stats.healPct or 0) + min(0, it and it.mods.healPct or 0)
  for _, buff in ipairs(side.buffs) do
    if buff.stat == "healPct" and buff.value < 0 and (not buff.itemMatch or it and Util.MatchDef(it.def, buff.itemMatch)
      and (not buff.itemUids or buff.itemUids[it.uid])) then
      local value = buff.value
      if buff.missingHealth then value = value * max(0, 1 - side.hp / side.hpMax) end
      reduction = reduction + value
    end
  end
  return reduction
end

local function healingMultiplier(side, it)
  return max(0, 1 + (itemStat(side, it, "healPct") + it.mods.healPct - healingPenalty(side, it)) / 100)
end

applyHealing = traced(function(sim, side, it, amount, t, options)
  options = options or {}
  if side.hp <= 0 then return 0 end
  amount = max(0, Util.Round(amount * max(0, 1 + healingPenalty(side, it) / 100)))
  local healed = min(amount, max(0, side.hpMax - side.hp))
  side.hp = side.hp + healed
  if side.hp >= side.hpMax * 0.4 then side.below40Fired = false end
  side.healDone = side.healDone + healed
  if it then it.heal = it.heal + healed end
  pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = options.hot and "hot" or "heal", amount = healed,
    crit = options.crit, key = options.key, target = side.id, lifesteal = options.lifesteal })
  local enemy = sim.sides[side.id == "A" and "B" or "A"] or side
  local ctx = { amount = healed, source = it, healing = true, crit = options.crit }
  masteryEvent(sim, side, enemy, "healed", it, t, { amount = healed, hot = options.hot })
  if healed > 0 then runTriggers(sim, side, enemy, nil, "healed", t, ctx) end
  if options.hot then runTriggers(sim, side, enemy, nil, "hotTick", t, ctx) end
  if options.crit and it then
    runTriggers(sim, side, enemy, it, "crit", t, ctx)
    for _, other in ipairs(side.items) do
      if other ~= it then runTriggers(sim, side, enemy, other, "anyCrit", t, ctx) end
    end
    for _, np in ipairs(it.neighbors or {}) do
      local other = side.byUid[np.uid]
      if other then runTriggers(sim, side, enemy, other, "adjacentCrit", t, ctx) end
    end
  end
  return healed
end)

changeResource = traced(function(sim, side, enemy, it, resource, amount, t)
  local pool = side.res[resource]
  if not pool then return 0 end
  local before = pool.cur
  local overflow = max(0, before + max(0, amount) - pool.max)
  pool.cur = Util.Clamp(before + amount, 0, pool.max)
  local actual = pool.cur - before
  if sim.audit then
    local flows = sim.audit[side.id].flows
    local flow = flows[resource] or { gained = 0, spent = 0, overflow = 0 }
    flows[resource] = flow
    flow.gained = flow.gained + max(0, actual)
    flow.spent = flow.spent + max(0, -actual)
    flow.overflow = flow.overflow + overflow
  end
  local chainOwner = beginChain(sim)
  if actual ~= 0 then
    if it and actual > 0 then
      it.resourceGains = it.resourceGains or {}
      it.resourceGains[resource] = (it.resourceGains[resource] or 0) + actual
    end
    pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "resource", resource = resource, amount = actual, target = side.id })
    runTriggers(sim, side, enemy, nil, actual > 0 and "resourceGained" or "resourceSpent", t,
      { source = it, resource = resource, amount = math.abs(actual) })
  end
  if overflow > 0 then
    pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "resourceOverflow", resource = resource, amount = overflow, target = side.id })
    runTriggers(sim, side, enemy, nil, "resourceOverflow", t, { source = it, resource = resource, amount = overflow })
  end
  finishChain(sim, chainOwner)
  return actual
end)

local function statusMatches(side, st, filter)
  if not filter then return true end
  if filter.tag == "bleed" and st.school == "physical" then return true end
  local source = side.byUid[st.srcUid]
  return source and Util.MatchDef(source.def, filter) or false
end

local function stackIncrement(effect, ctx)
  if effect.stacksFromEvent then
    local amount = effect.fromCriticalDamage and (ctx and ctx.criticalDamage or 0) or (ctx and ctx.amount or 0)
    amount = max(0, amount)
    if amount <= 0 then return 0 end
    return max(1, floor(amount * effect.stacksFromEvent))
  end
  return max(1, floor(effect.stacks or 1))
end

local function remainingDotDamage(status)
  if not status.decayStacks and not status.rampStacks then return status.perTick * status.remaining end
  local total, stacks, progress = 0, status.stacks or 1, status.rampTicks or 0
  for tick = 1, max(0, floor(status.remaining)) do
    if stacks <= 0 then break end
    total = total + stacks * status.perStack
    if status.decayStacks then stacks = max(0, stacks - status.decayStacks) end
    if status.rampStacks then
      progress = progress + 1
      if progress >= status.rampEvery then
        progress = 0
        stacks = min(status.maxStacks, stacks + status.rampStacks)
      end
    end
  end
  return total
end

local function consumeDots(sim, side, enemy, rule, t)
  local fraction = min(1, max(0, rule.fraction or 1))
  local total = 0
  for i = #enemy.statuses, 1, -1 do
    local st = enemy.statuses[i]
    if st.kind == "dot" and st.srcSide == side.id and st.remaining > 0 and statusMatches(side, st, rule.match) then
      local remaining = max(0, st.pool or remainingDotDamage(st))
      local taken = remaining * fraction
      total = total + taken
      st.pool = remaining - taken
      if not st.rolling then st.harvested = true end
      if st.pool <= 1e-9 then
        pushEvent(sim, { t = t, side = side.id, uid = st.srcUid, type = "statusRemoved", key = st.key, kind = "dot", target = enemy.id })
        table.remove(enemy.statuses, i)
      end
    end
  end
  return total
end

local dealDamage = traced(function(sim, side, enemy, it, e, t, ctx)
  if side.hp <= 0 or enemy.hp <= 0 then return 0 end
  if it.statStick and e.weaponSelf then return 0 end
  if not ctx or not ctx.activationId then
    ctx = Util.ShallowCopy(ctx or {})
    sim.activationSequence = (sim.activationSequence or 0) + 1
    ctx.activationId = sim.activationSequence
  end
  local autoAttack = it.def.tagSet.autoattack and (not ctx or ctx.autoAttack ~= false) or false
  local rng = sim.rng
  local school = e.school or "physical"
  local base = 0
  if e.min then base = rng:Range(e.min, e.max or e.min) end
  if e.weaponSelf then
    base = base + rng:Range(it.def.weaponMin or 1, it.def.weaponMax or 1)
  elseif e.weapon then
    local w = e.ranged and side.weaponRanged or side.weaponMelee
    if w then base = base + rng:Range(w.def.weaponMin or 1, w.def.weaponMax or 1) * (e.weaponPct or 1) end
  end
  if e.fromEvent then base = base + (ctx and ctx.amount or 0) * e.fromEvent end
  if e.perPoint then base = base + (ctx and ctx.points or 0) * e.perPoint end
  if e.consumeDebuff then
    local stacks = 0
    for index = #enemy.buffs, 1, -1 do
      local debuff = enemy.buffs[index]
      if debuff.key == e.consumeDebuff and debuff.srcSide == side.id then
        stacks = stacks + (debuff.stacks or 1)
        table.remove(enemy.buffs, index)
        pushEvent(sim, { t = t, side = side.id, uid = debuff.srcUid, type = "statusRemoved", kind = "debuff", key = debuff.key, target = enemy.id })
      end
    end
    if stacks <= 0 and not e.min and not e.weapon and not e.weaponSelf then return 0 end
    base = base + stacks * (e.perDebuffStack or 1)
  end
  if e.spendBank then
    local stored = side.banks[e.spendBank] or 0
    local cap = side.bankCaps and side.bankCaps[e.spendBank]
    if cap then stored = min(stored, bankLimit(side, cap)) end
    side.banks[e.spendBank] = 0
    base = base + stored * (e.bankScale or 1)
    if stored > 0 and e.spendBank == "blocked" and (it.def.baseKey or it.def.key) == "shield_slam" and (side.talents and side.talents.prot or 0) >= 8 then
      applyEffect(sim, side, enemy, it, { type = "absorb", amount = stored * 0.5 }, t)
    end
    if stored <= 0 and not e.min and not e.weapon and not e.weaponSelf then return 0 end
  end
  local powerStat = e.powerStat or (school == "physical" and "ap" or "sp")
  local stat = itemStat(side, it, powerStat)
  if powerStat == "ap" and e.weaponSelf and it.def.kind == "weapon" and it.def.tagSet.melee
    and autoAttack and ctx and ctx.extraAttack and ctx.bonusAttackPowerPct then
    stat = stat * (1 + ctx.bonusAttackPowerPct / 100)
  end
  local amount = (base + (e.coef or 0) * stat) * damageMultiplier(side, it, e) + it.mods.flat
  if e.weaponSelf and it.def.kind == "weapon" and it.def.tagSet.melee and side.provides.dualwield and side.weaponMelee ~= it then amount = amount * 0.5 end
  if e.blockScale then amount = amount + e.blockScale * ownerStat(side, "block") end
  if e.scaleMissing then amount = amount * (1 + e.scaleMissing * (1 - enemy.hp / enemy.hpMax)) end
  if e.perStatus then
    local n = 0
    for _, st in ipairs(enemy.statuses) do if st.kind == "dot" then n = n + 1 end end
    amount = amount * (1 + e.perStatus * n)
  end
  if e.perCombo and ctx and ctx.points then amount = amount * (1 + e.perCombo * ctx.points) end
  amount = max(0, amount * ammoEffectScale(it))

  local range = attackRange(it, e)
  if school == "physical" and not e.noDodge then
    if rng:Chance(Sim.DodgeChance(ownerStat(enemy, "dodge"))) then
      pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "dodge", target = enemy.id })
      runTriggers(sim, side, enemy, nil, "targetDodged", t, { source = it, attacker = it, autoAttack = autoAttack })
      runTriggers(sim, enemy, side, nil, "dodged", t, { source = it, attacker = it, autoAttack = autoAttack })
      masteryEvent(sim, enemy, side, "dodged", nil, t, { source = it })
      return 0
    end
  end

  if ctx then ctx.landed = true end
  local critChance = Sim.CritChance(itemStat(side, it, "crit") + it.mods.crit + (e.critBonus or 0))
  if e.critIf and conditionMet(e.critIf, side, enemy, t) then critChance = 100 end
  local crit = not e.noCrit and rng:Chance(critChance)
  if crit then amount = amount * (school == "physical" and 2 or 1.5) * max(0, 1 + (itemStat(side, it, "critDamage") + (it.masteryCritDamage or 0)) / 100) end
  local criticalShare = crit and 1 or 0
  if e.consumeDots then
    local direct = amount
    amount = amount + consumeDots(sim, side, enemy, e.consumeDots, t)
    criticalShare = crit and amount > 0 and direct / amount or 0
  end

  local armorPrevented = 0
  if school == "physical" then
    local reduction = Sim.ArmorReduction(ownerStat(enemy, "armor"))
    armorPrevented = amount * reduction
    amount = amount * (1 - reduction)
    local blockChance = ownerStat(enemy, "blockChance")
    if blockChance > 0 and rng:Chance(blockChance) then
      local blocked = min(amount * 0.5, ownerStat(enemy, "block"))
      amount = amount - blocked
      pushEvent(sim, { t = t, side = enemy.id, type = "block", amount = Util.Round(blocked), target = enemy.id })
      if blocked > 0 then runTriggers(sim, enemy, side, nil, "block", t, { amount = blocked, attacker = it, source = it, autoAttack = autoAttack }) end
      if blocked > 0 and (enemy.talents and enemy.talents.prot or 0) >= 5 then changeResource(sim, enemy, side, enemy.shield, "rage", 3, t) end
    end
  end
  local absorbed
  amount, absorbed = mitigateDamage(enemy, amount, school, range == "ranged")
  local absorbedDamage = absorbed
  amount = Util.Round(amount)
  absorbed = Util.Round(absorbed)
  enemy.hp = enemy.hp - amount
  enemy.dmgTaken = enemy.dmgTaken + amount
  side.dmgDone = side.dmgDone + amount
  it.dmg = it.dmg + amount
  if ctx and ctx.extraAttack then it.extraHits = (it.extraHits or 0) + 1 end
  pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "damage", amount = amount, absorbed = absorbed, crit = crit, school = school, target = enemy.id,
    extraAttack = ctx and ctx.extraAttack or nil, autoAttack = autoAttack })
  checkRevive(sim, enemy, t)
  if absorbedDamage > 0 then runTriggers(sim, enemy, side, nil, "absorbed", t, { amount = absorbedDamage, source = it, attacker = it, school = school, autoAttack = autoAttack }) end

  local lifesteal = ownerStat(side, "lifesteal")
  if lifesteal > 0 and amount > 0 then
    applyHealing(sim, side, it, amount * lifesteal / 100, t, { lifesteal = true })
  end
  if side.res.rage then
    local gain = 0
    if e.weaponSelf or e.generatesRage then gain = amount * Sim.RAGE_PER_DAMAGE_DEALT * (1 + ownerStat(side, "ragePct") / 100) * Sim.RageDamageScale(side) end
    if crit and e.weaponSelf then gain = gain + ownerStat(side, "rageOnCrit") end
    if gain > 0 then changeResource(sim, side, enemy, it, "rage", gain, t) end
  end
  if enemy.res.rage and amount > 0 then
    changeResource(sim, enemy, side, nil, "rage", amount * Sim.RAGE_PER_DAMAGE_TAKEN * (1 + ownerStat(enemy, "rageTakenPct") / 100) * Sim.RageDamageScale(enemy), t)
  end
  if armorPrevented > 0 then
    pushEvent(sim, { t = t, side = enemy.id, type = "armorPrevented", amount = armorPrevented, school = "physical", target = enemy.id,
      sourceSide = side.id, sourceUid = it.uid })
    runTriggers(sim, enemy, side, nil, "armorPrevented", t, { amount = armorPrevented, source = it, attacker = it, autoAttack = autoAttack })
  end
  if amount > 0 then reactToDamage(sim, enemy, side, t) end
  if ctx and ctx.regularAttack and not (sim.chain and sim.chain.extraAttack) then
    runTriggers(sim, side, enemy, nil, "regularHit", t, { source = it, amount = amount, crit = crit, autoAttack = autoAttack })
  end
  if ctx and ctx.extraAttack and it.def.kind == "weapon" and e.weaponSelf and autoAttack then
    runTriggers(sim, side, enemy, nil, "extraHit", t, { source = it, amount = amount, crit = crit, autoAttack = autoAttack })
  end
  if school == "physical" and range == "melee" then
    local thorns = ownerStat(enemy, "thorns")
    if thorns > 0 then
      thorns = Util.Round(thorns * (1 - min(0.9, scopedDamageReduction(side, "nature", false) / 100)))
      side.hp = side.hp - thorns
      side.dmgTaken = side.dmgTaken + thorns
      enemy.dmgDone = enemy.dmgDone + thorns
      pushEvent(sim, { t = t, side = enemy.id, type = "thorns", amount = thorns, school = "nature", target = side.id })
      checkRevive(sim, side, t)
      if thorns > 0 then reactToDamage(sim, side, enemy, t) end
      checkLowHealth(sim, side, enemy, t)
    end
  end

  local hitContext = { source = it, amount = amount, criticalDamage = amount * criticalShare, crit = crit, autoAttack = autoAttack, healing = false,
    activationId = ctx.activationId, caster = ctx.caster }
  if not e.noOwnTriggers then
    runTriggers(sim, side, enemy, it, "hit", t, hitContext)
    if crit then runTriggers(sim, side, enemy, it, "crit", t, hitContext) end
  end
  for _, other in ipairs(side.items) do
    if other ~= it and (other.enabled or other.def.passiveTriggers) then
      runTriggers(sim, side, enemy, other, "anyHit", t, hitContext)
      if crit then runTriggers(sim, side, enemy, other, "anyCrit", t, hitContext) end
    end
  end
  for _, np in ipairs(it.neighbors or {}) do
    local n = side.byUid[np.uid]
    if n then
      runTriggers(sim, side, enemy, n, "adjacentHit", t, hitContext)
      if crit then runTriggers(sim, side, enemy, n, "adjacentCrit", t, hitContext) end
    end
  end
  if amount > 0 then runTriggers(sim, enemy, side, nil, "damaged", t, { amount = amount, attacker = it, autoAttack = autoAttack, crit = crit }) end
  local masteryContext = Util.ShallowCopy(ctx or {})
  masteryContext.crit = crit
  masteryContext.autoAttack = autoAttack
  masteryEvent(sim, side, enemy, "hit", it, t, masteryContext)
  checkLowHealth(sim, enemy, side, t)
  return amount
end)

local heal = traced(function(sim, side, it, e, t, ctx)
  if e.fixedFraction then
    return applyHealing(sim, side, it, max(0, ctx and ctx.amount or 0) * (e.fromEvent or 0), t)
  end
  local base = 0
  if e.min then base = sim.rng:Range(e.min, e.max or e.min) end
  if e.fromEvent then base = base + (ctx and ctx.amount or 0) * e.fromEvent end
  if e.perPoint then base = base + (ctx and ctx.points or 0) * e.perPoint end
  local consumed = 0
  if e.consumeHots then
    for i = #side.statuses, 1, -1 do
      local st = side.statuses[i]
      if st.kind == "hot" then
        consumed = consumed + st.perTick * max(0, st.remaining)
        pushEvent(sim, { t = t, side = side.id, uid = st.srcUid, type = "statusRemoved", key = st.key, kind = "hot", target = side.id })
        table.remove(side.statuses, i)
      end
    end
  end
  base = base + side.hpMax * ((e.pctMax or 0) + (e.perPointPctMax or 0) * (ctx and ctx.points or 0))
  local amount = (base + (e.coef or 0) * itemStat(side, it, e.powerStat or "healing")) * healingMultiplier(side, it)
  local crit = not e.noCrit and sim.rng:Chance(Sim.CritChance(itemStat(side, it, "crit") + it.mods.crit))
  if crit then amount = amount * 1.5 end
  amount = amount + consumed
  return applyHealing(sim, side, it, amount, t, { crit = crit })
end)

local function addStatus(sim, holder, srcSide, it, e, t, kind, ctx)
  local key = e.key or it.def.baseKey or it.def.key
  local added = e.stack and stackIncrement(e, ctx) or 1
  if added <= 0 then return end
  local perTick
  if kind == "dot" then
    local school = e.school or "physical"
    local stat = itemStat(srcSide, it, e.powerStat or (school == "physical" and "ap" or "sp"))
    perTick = ((e.tick or 0) + (e.coef or 0) * stat) * damageMultiplier(srcSide, it, e)
  else
    perTick = ((e.tick or 0) + (e.coef or 0) * itemStat(srcSide, it, e.powerStat or "healing")) * healingMultiplier(srcSide, it)
  end
  local incoming = (ctx and ctx.amount or 0) * (e.fromEvent or 0)
  if e.rolling then perTick = perTick + incoming / e.duration end
  if e.perCombo and ctx and ctx.points then perTick = perTick * (1 + e.perCombo * ctx.points) end
  if kind == "dot" then perTick = perTick * ammoEffectScale(it) end
  perTick = max(0, perTick)
  for _, st in ipairs(holder.statuses) do
    if st.kind == kind and st.key == key and st.srcSide == srcSide.id and st.srcUid == it.uid then
      local debt = (e.uncapped or e.decayStacks) and st.pool and max(0, remainingDotDamage(st) - st.pool) or 0
      st.remaining = e.duration
      st.expiresAt = e.preserveTicks and t + e.duration or nil
      if not e.rolling then st.pool = nil st.harvested = nil end
      st.rolling = e.rolling
      st.decayStacks, st.perStack = e.decayStacks, perTick
      st.rampStacks, st.rampEvery, st.maxStacks = e.rampStacks, max(1, floor(e.rampEvery or 1)), e.uncapped and math.huge or e.maxStacks or 5
      if e.rolling then
        st.pool = max(0, st.pool or 0) + perTick * e.duration
        st.perTick = st.pool / e.duration
      elseif e.stack then
        if not e.preserveTicks then st.nextTick = t + 1 end
        st.stacks = min(e.uncapped and math.huge or e.maxStacks or 5, (st.stacks or 1) + added)
        st.perTick = perTick * st.stacks
        if e.preserveTicks then st.remaining = max(0, floor(t + e.duration - st.nextTick + 1e-6) + 1) end
      elseif ctx and ctx.activationId and st.activationId == ctx.activationId and (ctx.activationPass or 1) > 1 then
        st.perTick = st.perTick + perTick
      elseif e.preserveTicks then
        st.perTick = perTick
        st.remaining = max(0, floor(t + e.duration - st.nextTick + 1e-6) + 1)
      else
        st.nextTick = t + 1
        st.perTick = perTick
      end
      if debt > 0 then
        st.pool = max(0, remainingDotDamage(st) - debt)
        st.harvested = true
      end
      st.activationId = ctx and ctx.activationId
      pushEvent(sim, { t = t, side = srcSide.id, uid = it.uid, type = "status", kind = kind, key = key, refresh = true, target = holder.id, stacks = st.stacks,
        duration = e.duration, icon = it.def.icon, name = it.def.name, school = e.school })
      return st
    end
  end
  local stacks = e.stack and min(e.uncapped and math.huge or e.maxStacks or 5, added) or 1
  local st = { kind = kind, key = key, school = e.school, perTick = perTick * stacks, perStack = perTick, decayStacks = e.decayStacks,
    rampStacks = e.rampStacks, rampEvery = max(1, floor(e.rampEvery or 1)), rampTicks = 0, maxStacks = e.uncapped and math.huge or e.maxStacks or 5,
    remaining = e.duration, duration = e.duration, nextTick = t + 1,
    srcSide = srcSide.id, srcUid = it.uid, stacks = stacks, icon = it.def.icon, name = it.def.name, rolling = e.rolling, activationId = ctx and ctx.activationId,
    expiresAt = e.preserveTicks and t + e.duration or nil }
  if e.rolling then st.pool = perTick * e.duration end
  holder.statuses[#holder.statuses + 1] = st
  pushEvent(sim, { t = t, side = srcSide.id, uid = it.uid, type = "status", kind = kind, key = key, target = holder.id, stacks = stacks,
    duration = e.duration, icon = it.def.icon, name = it.def.name, school = e.school })
  return st
end

local function addBuff(sim, holder, srcSide, it, e, t, negative, ctx)
  local key = e.key or (it and it.def.key or "buff") .. ":" .. tostring(e.stat)
  local added = e.stack and stackIncrement(e, ctx) or 1
  if added <= 0 then return end
  local srcUid = it and it.uid
  local itemMatch, itemUids = e.target and e.match or nil
  if e.target == "neighbors" then
    itemUids = {}
    for _, neighbor in ipairs(it and it.neighbors or {}) do itemUids[neighbor.uid] = true end
  end
  local gearValue = (e.gearCoef or 0) * max(0, srcSide.gearStats[e.gearStat or e.stat] or 0)
  if e.gearCap then gearValue = min(e.gearCap, gearValue) end
  local value = ((e.value or 0) + gearValue + (e.fromEvent or 0) * (ctx and ctx.amount or 0)) * (negative and -1 or 1) * ammoEffectScale(it)
  for index, b in ipairs(holder.buffs) do
    if b.key == key and b.srcSide == srcSide.id and b.srcUid == srcUid then
      if e.charges and e.charges <= 0 then
        table.remove(holder.buffs, index)
        pushEvent(sim, { t = t, side = srcSide.id, uid = srcUid, type = "statusRemoved", kind = b.kind or "buff", key = key, target = holder.id })
        if b.stat == "haste" then syncCooldowns(sim, holder, t) end
        return
      end
      b.remaining = e.duration
      b.missingHealth = e.missingHealth
      b.damageSchool, b.rangedOnly = e.damageSchool, e.rangedOnly
      b.exclusiveGroup = negative and e.exclusiveGroup or nil
      b.itemMatch, b.itemUids, b.paidOnly = itemMatch, itemUids, e.paidOnly
      b.charges, b.chargeVersion = e.charges, (b.chargeVersion or 0) + 1
      b.kind, b.match, b.double, b.free = negative and "debuff" or "buff", e.match, e.double, e.free
      if e.stack then
        b.stacks = min(e.uncapped and math.huge or e.maxStacks or 5, (b.stacks or 1) + added)
        b.value = value * b.stacks
      else
        b.value = value
      end
      pushEvent(sim, { t = t, side = srcSide.id, uid = it and it.uid, type = negative and "debuff" or "buff", key = key, stat = e.stat, value = b.value, target = holder.id,
        duration = e.duration, icon = b.icon, name = b.name, stacks = b.stacks, charges = b.charges, damageSchool = e.damageSchool, rangedOnly = e.rangedOnly, refresh = true })
      if e.stat == "haste" then syncCooldowns(sim, holder, t) end
      return b
    end
  end
  if e.charges and e.charges <= 0 then return end
  local stacks = e.stack and min(e.uncapped and math.huge or e.maxStacks or 5, added) or 1
  local b = { key = key, stat = e.stat, value = value * stacks, remaining = e.duration, stacks = stacks, srcSide = srcSide.id, srcUid = srcUid,
    kind = negative and "debuff" or "buff", charges = e.charges, chargeVersion = 1,
    icon = it and it.def.icon, name = e.name or (it and it.def.name),
    free = e.free, match = e.match, double = e.double, missingHealth = e.missingHealth, itemMatch = itemMatch, itemUids = itemUids, paidOnly = e.paidOnly,
    damageSchool = e.damageSchool, rangedOnly = e.rangedOnly, exclusiveGroup = negative and e.exclusiveGroup or nil }
  holder.buffs[#holder.buffs + 1] = b
  pushEvent(sim, { t = t, side = srcSide.id, uid = it and it.uid, type = negative and "debuff" or "buff", key = key, stat = e.stat, value = b.value, target = holder.id,
    duration = e.duration, icon = b.icon, name = b.name, stacks = stacks, charges = b.charges, damageSchool = e.damageSchool, rangedOnly = e.rangedOnly })
  if e.stat == "haste" then syncCooldowns(sim, holder, t) end
  return b
end

tickStatus = traced(function(sim, holder, st, t)
  if st.kind == "dot" then
    if holder.hp <= 0 then return end
    if st.pool and st.pool <= 1e-9 then return end
    local amount = st.perTick
    if st.pool then
      amount = min(amount, st.pool)
      st.pool = max(0, st.pool - amount)
      if st.pool <= 1e-9 then st.remaining = 0 end
    end
    local absorbed
    amount, absorbed = mitigateDamage(holder, amount, st.school, false)
    amount = Util.Round(amount)
    holder.hp = holder.hp - amount
    holder.dmgTaken = holder.dmgTaken + amount
    local src = sim.sides[st.srcSide]
    src.dmgDone = src.dmgDone + amount
    local srcItem = src.byUid[st.srcUid]
    if srcItem then srcItem.dmg = srcItem.dmg + amount end
    pushEvent(sim, { t = t, side = st.srcSide, uid = st.srcUid, type = "dot", amount = amount, absorbed = absorbed, school = st.school, key = st.key, target = holder.id })
    if st.decayStacks or st.rampStacks then
      local before = st.stacks
      if st.decayStacks then st.stacks = max(0, st.stacks - st.decayStacks) end
      if st.rampStacks then
        st.rampTicks = (st.rampTicks or 0) + 1
        if st.rampTicks >= st.rampEvery then
          st.rampTicks = 0
          st.stacks = min(st.maxStacks, st.stacks + st.rampStacks)
        end
      end
      st.perTick = st.perStack * st.stacks
      if st.stacks <= 0 or st.pool and st.pool <= 1e-9 then
        local index = indexOf(holder.statuses, st)
        if index then table.remove(holder.statuses, index) end
        pushEvent(sim, { t = t, side = st.srcSide, uid = st.srcUid, type = "statusRemoved", kind = "dot", key = st.key, target = holder.id })
      elseif st.stacks ~= before then
        pushEvent(sim, { t = t, side = st.srcSide, uid = st.srcUid, type = "status", kind = "dot", key = st.key, target = holder.id,
          stacks = st.stacks, duration = st.remaining, icon = st.icon, name = st.name, school = st.school, refresh = true })
      end
    end
    checkRevive(sim, holder, t)
    if absorbed > 0 then runTriggers(sim, holder, src, nil, "absorbed", t, { amount = absorbed, source = srcItem, attacker = srcItem, school = st.school, key = st.key }) end
    if amount > 0 then reactToDamage(sim, holder, src, t) end
    checkLowHealth(sim, holder, src, t)
    if srcItem then runTriggers(sim, src, holder, nil, "dotTick", t, { source = srcItem, amount = amount, key = st.key, school = st.school }) end
    if src.channel and src.channel.uid == st.srcUid and src.channel.key == st.key and t + 1e-6 >= src.channel.endsAt then
      finishChannel(sim, src, t, "end")
      releaseDeferred(sim, src, holder, t)
    end
  elseif st.kind == "hot" then
    applyHealing(sim, holder, holder.byUid[st.srcUid], st.perTick, t, { hot = true, key = st.key })
  end
end)

applyEffect = traced(function(sim, side, enemy, it, e, t, ctx)
  local kind = e.type
  if e.cond and not conditionMet(e.cond, side, enemy, t) then return 0 end
  if kind == "tickDots" then
    for _, st in ipairs(Util.ShallowCopy(enemy.statuses)) do
      if st.kind == "dot" and st.srcSide == side.id and st.remaining > 0 and indexOf(enemy.statuses, st) and statusMatches(side, st, e.match) then
        tickStatus(sim, enemy, st, t)
      end
    end
    return 0
  end
  if kind == "tickHots" then
    for _, st in ipairs(Util.ShallowCopy(side.statuses)) do
      if st.kind == "hot" and st.srcSide == side.id and st.remaining > 0 and indexOf(side.statuses, st) and statusMatches(side, st, e.match) then
        tickStatus(sim, side, st, t)
      end
    end
    return 0
  end
  if kind == "damage" then
    local total = 0
    local repeats = e.repeatPaidCharges and 1 + (ctx and ctx.empoweredHits or 0) or 1
    for hit = 1, repeats do total = total + dealDamage(sim, side, enemy, it, e, t, ctx) end
    return total
  elseif kind == "heal" then
    return heal(sim, side, it, e, t, ctx)
  elseif kind == "dot" then
    addStatus(sim, enemy, side, it, e, t, "dot", ctx)
  elseif kind == "hot" then
    addStatus(sim, side, side, it, e, t, "hot", ctx)
  elseif kind == "refresh" then
    for _, st in ipairs(enemy.statuses) do
      if st.kind == "dot" and st.srcSide == side.id and (e.key and st.key == e.key or e.match and statusMatches(side, st, e.match)) then
        local debt = 0
        if st.pool and not st.rolling then
          local forecast = Util.ShallowCopy(st)
          if st.expiresAt then forecast.remaining = max(0, floor(st.expiresAt - st.nextTick + 1e-6) + 1) end
          debt = max(0, remainingDotDamage(forecast) - st.pool)
        end
        st.remaining = st.duration or st.remaining
        if st.expiresAt then
          st.expiresAt = t + st.remaining
          st.remaining = max(0, floor(st.expiresAt - st.nextTick + 1e-6) + 1)
        end
        if st.pool and not st.rolling then st.pool = max(0, remainingDotDamage(st) - debt) end
        pushEvent(sim, { t = t, side = st.srcSide, uid = st.srcUid, type = "status", kind = "dot", key = st.key, refresh = true, target = enemy.id, stacks = st.stacks,
          duration = st.remaining, icon = st.icon, name = st.name, school = st.school })
      end
    end
    for _, st in ipairs(side.statuses) do
      if st.kind == "hot" and st.srcSide == side.id and (e.key and st.key == e.key or e.match and statusMatches(side, st, e.match)) then
        st.remaining = st.duration or st.remaining
        if st.expiresAt then
          st.expiresAt = t + st.remaining
          st.remaining = max(0, floor(st.expiresAt - st.nextTick + 1e-6) + 1)
        end
        pushEvent(sim, { t = t, side = st.srcSide, uid = st.srcUid, type = "status", kind = "hot", key = st.key, refresh = true, target = side.id, stacks = st.stacks,
          duration = st.remaining, icon = st.icon, name = st.name })
      end
    end
  elseif kind == "buff" then
    addBuff(sim, side, side, it, e, t, false, ctx)
  elseif kind == "debuff" then
    addBuff(sim, enemy, side, it, e, t, true, ctx)
  elseif kind == "resource" then
    local amount = (e.amount or 0) + (e.fromEvent or 0) * (ctx and ctx.amount or 0)
    changeResource(sim, side, enemy, it, e.resource, amount, t)
  elseif kind == "bank" then
    local amount = max(0, e.amount or (ctx and ctx.amount or 0) * (e.fraction or 1))
    side.bankCaps = side.bankCaps or {}
    side.bankCaps[e.key] = e.cap or side.bankCaps[e.key]
    local value = (side.banks[e.key] or 0) + amount
    if side.bankCaps[e.key] then value = min(value, bankLimit(side, side.bankCaps[e.key])) end
    side.banks[e.key] = value
  elseif kind == "charge" then
    local before = side.banks[e.key] or 0
    local value = min(max(0, floor(e.max or 3)), max(0, before + (e.amount or 1)))
    side.banks[e.key] = value
    if value ~= before then
      pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "charge", key = e.key, amount = value - before, stacks = value, target = side.id })
    end
  elseif kind == "sacrificePet" then
    local pet = side.activePet
    if pet and not pet.suppressed then
      pet.enabled, pet.suppressed, pet.reason = false, true, "sacrificed"
      side.provides.pet = false
      for _, command in ipairs(side.items) do
        local req = command.def.use and command.def.use.requires
        for _, flag in ipairs(type(req) == "table" and req or { req }) do
          if flag == "pet" and command ~= it then command.enabled, command.reason = false, "pet" end
        end
      end
      pushEvent(sim, { t = t, side = side.id, uid = pet.uid, type = "sacrifice", key = pet.def.key, target = side.id })
    end
  elseif kind == "extraAttack" then
    local chainOwner = beginChain(sim)
    local attack = side.formAttack or side.weaponMelee
    if side.stunUntil <= t and not ownerOccupied(side) and attack and attack.enabled and not attack.statStick then
      local pending = sim.chain.pending
      pending[#pending + 1] = { side = side, enemy = enemy, weapon = attack, count = e.count or 1, bonusAttackPowerPct = e.bonusAttackPowerPct, t = t, parentTrace = sim.trace }
    end
    finishChain(sim, chainOwner)
  elseif kind == "cast" then
    local chainOwner = beginChain(sim)
    local function enqueue(target)
      if not target or not target.enabled or target.statStick or not target.def.use then return end
      if not e.ignoreCondition and not conditionMet(target.def.use.condition, side, enemy, t) then return end
      local entry = { side = side, enemy = enemy, item = target, source = it, count = 1, t = t,
        ignoreCondition = e.ignoreCondition, parentTrace = sim.trace, deferDuringChannel = e.deferDuringChannel, consumeCooldown = e.consumeCooldown,
        masteryFollowup = it and it.def.kind == "talent" or nil,
        masteryName = it and it.def.kind == "talent" and it.def.name or nil }
      if ownerOccupied(side) or side.stunUntil > t then
        if e.deferDuringChannel and (side.channel or side.stunUntil > t) then deferCast(side, entry) end
        return
      end
      local pending = sim.chain.pending
      pending[#pending + 1] = entry
    end
    if e.target == "source" then
      enqueue(ctx and ctx.source)
    elseif e.key then
      for _, target in ipairs(side.items) do
        if (target.def.baseKey or target.def.key) == e.key then enqueue(target) break end
      end
    elseif e.target == "neighbors" and it then
      for _, placement in ipairs(it.neighbors or {}) do
        local target = side.byUid[placement.uid]
        if target and Util.MatchDef(target.def, e.match) then enqueue(target) end
      end
    elseif e.target == "all" then
      local targets = {}
      for _, target in ipairs(side.items) do
        if target.enabled and not target.statStick and target.def.use and Util.MatchDef(target.def, e.match) then targets[#targets + 1] = target end
      end
      if e.choose == "random" and #targets > 0 then enqueue(targets[sim.rng:Range(1, #targets)])
      else for _, target in ipairs(targets) do enqueue(target) end end
    end
    finishChain(sim, chainOwner)
  elseif kind == "absorb" then
    local amount = (e.amount or 0) + (e.coef or 0) * ownerStat(side, e.powerStat or "healing") + (e.fromEvent or 0) * (ctx and ctx.amount or 0)
    local before = side.absorb
    side.absorb = min(side.hpMax, side.absorb + Util.Round(amount))
    if it then it.shieldGained = (it.shieldGained or 0) + side.absorb - before end
    pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "absorb", amount = side.absorb - before, target = side.id })
  elseif kind == "stun" then
    local duration = e.duration
    if enemy.stunDRUntil and t < enemy.stunDRUntil then duration = duration * 0.5 end
    enemy.stunDRUntil = t + 12
    local previous = enemy.stunUntil
    if not enemy.controls then
      enemy.controls = {}
      if previous > t then enemy.controls[1] = { controlType = "stun", endsAt = previous } end
    end
    for index = #enemy.controls, 1, -1 do
      if enemy.controls[index].endsAt <= t then table.remove(enemy.controls, index) end
    end
    enemy.controls[#enemy.controls + 1] = { controlType = e.controlType or "stun", endsAt = t + duration }
    enemy.stunUntil = max(previous, t + duration)
    if enemy.stunUntil > t then finishChannel(sim, enemy, t, "interrupt", "stun") end
    local extension = enemy.stunUntil - max(t, previous)
    if extension > 0 then
      for _, target in ipairs(enemy.items) do
        for index, deadline in pairs(target.trigIcd) do
          if deadline > t then target.trigIcd[index] = deadline + extension end
        end
      end
    end
    syncCooldowns(sim, enemy, t)
    pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "stun", duration = duration, controlType = e.controlType, target = enemy.id })
    runTriggers(sim, enemy, side, nil, "stunned", t, { duration = e.duration, controlType = e.controlType or "stun" })
    runTriggers(sim, side, enemy, nil, "enemyStunned", t, { source = it, duration = duration })
  elseif kind == "clearControl" then
    if not side.controls then return 0 end
    local types, remaining, removed = {}, t, 0
    for _, controlType in ipairs(e.types or {}) do types[controlType] = true end
    for index = #side.controls, 1, -1 do
      local control = side.controls[index]
      if control.endsAt <= t then
        table.remove(side.controls, index)
      elseif not e.types or types[control.controlType] then
        removed = removed + 1
        table.remove(side.controls, index)
      else
        remaining = max(remaining, control.endsAt)
      end
    end
    if removed == 0 then return 0 end
    local shortened = max(0, side.stunUntil - remaining)
    side.stunUntil = remaining
    if shortened > 0 then
      for _, target in ipairs(side.items) do
        for index, deadline in pairs(target.trigIcd) do
          if deadline > t then target.trigIcd[index] = max(t, deadline - shortened) end
        end
      end
    end
    syncCooldowns(sim, side, t)
    pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "controlBreak", target = side.id, amount = removed, remaining = remaining - t })
    return removed
  elseif kind == "cdr" then
    if e.target == "neighbors" and it then
      for _, np in ipairs(it.neighbors or {}) do
        local n = side.byUid[np.uid]
        if n and n.enabled and Util.MatchDef(n.def, e.match) then advanceCooldown(sim, side, n, e.amount, t, e.clampReady) end
      end
    elseif e.target == "all" then
      for _, n in ipairs(side.items) do
        if n.enabled and Util.MatchDef(n.def, e.match) then advanceCooldown(sim, side, n, e.amount, t, e.clampReady) end
      end
    elseif it then
      advanceCooldown(sim, side, it, e.amount, t, e.clampReady)
    end
  elseif kind == "cleanse" then
    local i = 1
    local removed = 0
    while i <= #side.statuses and removed < (e.count or 1) do
      if side.statuses[i].kind == "dot" then
        local status = table.remove(side.statuses, i)
        removed = removed + 1
        pushEvent(sim, { t = t, side = status.srcSide, uid = status.srcUid, type = "statusRemoved", kind = "dot", key = status.key, target = side.id })
        local source = sim.sides[status.srcSide]
        if source and source.channel and source.channel.uid == status.srcUid and source.channel.key == status.key then
          finishChannel(sim, source, t, "interrupt", "cleanse")
        end
      else i = i + 1 end
    end
    if removed > 0 then pushEvent(sim, { t = t, side = side.id, uid = it and it.uid, type = "cleanse", amount = removed, target = side.id }) end
  elseif kind == "purge" then
    local i = 1
    local removed = 0
    local hasteRemoved = false
    while i <= #enemy.buffs and removed < (e.count or 1) do
      if enemy.buffs[i].value > 0 then
        local buff = table.remove(enemy.buffs, i)
        hasteRemoved = hasteRemoved or buff.stat == "haste"
        removed = removed + 1
        pushEvent(sim, { t = t, side = buff.srcSide, uid = buff.srcUid, type = "statusRemoved", kind = buff.kind or "buff", key = buff.key, target = enemy.id })
      else i = i + 1 end
    end
    if hasteRemoved then syncCooldowns(sim, enemy, t) end
  elseif kind == "drain" then
    local pool = enemy.res[e.resource]
    if pool then
      local before = pool.cur
      pool.cur = max(0, pool.cur - e.amount)
      local actual = before - pool.cur
      if actual > 0 then
        pushEvent(sim, { t = t, side = enemy.id, type = "resource", resource = e.resource, amount = -actual, target = enemy.id, drain = true })
        if e.transfer then changeResource(sim, side, enemy, it, e.resource, actual, t) end
      end
    end
  end
end)

local function matchesEventSource(source, filter, autoAttack)
  if not source then return false end
  local def = source.def
  if autoAttack == false and def.tagSet.autoattack then
    if not source.nonAutoDef then
      source.nonAutoDef = Util.ShallowCopy(def)
      source.nonAutoDef.tagSet = Util.ShallowCopy(def.tagSet)
      source.nonAutoDef.tagSet.autoattack = nil
    end
    def = source.nonAutoDef
  end
  return Util.MatchDef(def, filter)
end

local function cooldownWouldChange(side, target, effect, t)
  if side.stunUntil > t then return false end
  local after = target.cd - effect.amount * cooldownSpeed(side, target)
  if effect.clampReady or ownerOccupied(side) and target.def.kind ~= "pet" then after = max(0, after) end
  return after ~= target.cd
end

local function emptyResourceTrigger(side, trigger)
  if trigger.chance or #trigger.effects == 0 then return false end
  for _, effect in ipairs(trigger.effects) do
    if effect.type ~= "resource" or side.res[effect.resource] then return false end
  end
  return true
end

local function emptyCooldownTrigger(side, item, trigger, t)
  if trigger.chance or #trigger.effects == 0 then return false end
  for _, effect in ipairs(trigger.effects) do
    if effect.type ~= "cdr" then return false end
    if effect.target == "neighbors" then
      for _, neighbor in ipairs(item.neighbors or {}) do
        local target = side.byUid[neighbor.uid]
        if target and target.enabled and Util.MatchDef(target.def, effect.match) and cooldownWouldChange(side, target, effect, t) then return false end
      end
    elseif effect.target == "all" then
      for _, target in ipairs(side.items) do
        if target.enabled and Util.MatchDef(target.def, effect.match) and cooldownWouldChange(side, target, effect, t) then return false end
      end
    elseif item and cooldownWouldChange(side, item, effect, t) then
      return false
    end
  end
  return true
end

runTriggers = function(sim, side, enemy, it, on, t, ctx)
  local chainOwner = beginChain(sim)
  local chain = sim.chain
  ctx = ctx or {}
  local list = it and { it } or side.items
  for _, item in ipairs(list) do
    if not item.suppressed and (item.enabled or item.def.passiveTriggers) then
      for idx, trig in ipairs(item.def.triggers) do
        if trig.on == on then
          local ok = true
          local key = side.id .. ":" .. tostring(item.uid) .. ":" .. idx
          if chain.active[key] or chain.count >= Sim.MAX_CHAIN_PROCS then ok = false end
          local activation = trig.oncePerActivation and ctx.activationId
          if ok and activation and chain.activationTriggers and chain.activationTriggers[key] and chain.activationTriggers[key][activation] then ok = false end
          if ok and trig.match then
            local matches = matchesEventSource(ctx.source, trig.match, ctx.autoAttack)
            if on == "dotTick" and trig.match.tag == "bleed" and ctx.school == "physical" then matches = true end
            if not matches then ok = false end
          end
          if ok and trig.matchAttacker and not matchesEventSource(ctx.attacker, trig.matchAttacker, ctx.autoAttack) then ok = false end
          if ok and trig.resource and trig.resource ~= ctx.resource then ok = false end
          if ok and trig.controlTypes then
            local matches = false
            for _, controlType in ipairs(trig.controlTypes) do
              if controlType == ctx.controlType then matches = true break end
            end
            if not matches then ok = false end
          end
          if ok and trig.healing ~= nil and trig.healing ~= (not not ctx.healing) then ok = false end
          if ok and trig.critical ~= nil and trig.critical ~= (not not ctx.crit) then ok = false end
          if ok and trig.icd and (item.trigIcd[idx] or -1) > t then ok = false end
          if ok and trig.condition and not conditionMet(trig.condition, side, enemy, t) then ok = false end
          local times = 1
          if ok and trig.every then
            if type(trig.every) ~= "number" or trig.every < 1 or trig.every ~= floor(trig.every) or trig.everyAmount then ok = false end
            if ok and trig.chance and not sim.rng:Chance(trig.chance) then ok = false end
            if ok then
              item.trigCount = item.trigCount or {}
              local progress = (item.trigCount[idx] or 0) + 1
              times = floor(progress / trig.every)
              item.trigCount[idx] = progress - times * trig.every
            end
          elseif ok and trig.everyAmount then
            item.trigProgress = item.trigProgress or {}
            local progress = (item.trigProgress[idx] or 0) + max(0, ctx.amount or 0)
            times = floor(progress / trig.everyAmount)
            item.trigProgress[idx] = progress - times * trig.everyAmount
          end
          if ok and not trig.every and trig.chance and not sim.rng:Chance(trig.chance) then ok = false end
          if ok and times > 0 then
            if activation then
              chain.activationTriggers = chain.activationTriggers or {}
              chain.activationTriggers[key] = chain.activationTriggers[key] or {}
              chain.activationTriggers[key][activation] = true
            end
            if trig.icd then
              -- A single resource event can cross many thresholds. An internal
              -- cooldown permits one response, including within that event.
              times = min(times, 1)
              item.trigIcd[idx] = t + trig.icd + max(0, side.stunUntil - t)
            end
            chain.active[key] = true
            local attempts = (emptyCooldownTrigger(side, item, trig, t) or emptyResourceTrigger(side, trig)) and 0 or min(times, Sim.MAX_CHAIN_PROCS - chain.count)
            for pass = 1, attempts do
              if chain.count >= Sim.MAX_CHAIN_PROCS or emptyCooldownTrigger(side, item, trig, t) or emptyResourceTrigger(side, trig) then break end
              chain.count = chain.count + 1
              local previous = sim.trace
              sim.trace = newTrace(sim, previous)
              if on ~= "use" and on ~= "battleStart" then item.procs = (item.procs or 0) + 1 end
              pushEvent(sim, { t = t, side = side.id, uid = item.uid, type = "proc", on = on, target = side.id,
                sourceKey = ctx.source and ctx.source.def.key })
              local effectCtx = ctx
              if trig.everyAmount then
                effectCtx = Util.ShallowCopy(ctx)
                effectCtx.amount = trig.everyAmount
              end
              for _, e in ipairs(trig.effects) do
                local appliedCtx = effectCtx
                if e.type == "damage" then
                  appliedCtx = Util.ShallowCopy(effectCtx)
                  appliedCtx.autoAttack = e.weaponSelf == true
                end
                local repeats = e.type == "damage" and not item.def.use and anyMatch(side.doubleMatches, item.def) and 2 or 1
                for repeatIndex = 1, repeats do applyEffect(sim, side, enemy, item, e, t, appliedCtx) end
              end
              sim.trace = previous
            end
            chain.active[key] = nil
          end
        end
      end
    end
  end
  finishChain(sim, chainOwner)
end

fireItem = traced(function(sim, side, enemy, it, t, ctx)
  if it.statStick then return end
  local use = it.def.use
  if use.once and it.fired > 0 then return end
  ctx = ctx or {}
  if use.channel then
    if ctx.channelState then
      if side.channel ~= ctx.channelState then return end
    else
      ctx.channelState = beginChannel(sim, side, enemy, it, t)
      if not ctx.channelState then return end
    end
  end
  local chainOwner = beginChain(sim)
  local previousActivation = side.itemActivation
  side.itemActivation = { item = it, paidBuffs = not ctx.freeCast and ctx.paidBuffs or nil }
  local charged = {}
  local function matches(buff)
    return (not buff.itemMatch or Util.MatchDef(it.def, buff.itemMatch))
      and (not buff.match or Util.MatchDef(it.def, buff.match))
      and (not buff.itemUids or buff.itemUids[it.uid])
  end
  for _, buff in ipairs(side.buffs) do
    local paid = not buff.paidOnly or side.itemActivation.paidBuffs and side.itemActivation.paidBuffs[buff]
    if buff.charges and buff.charges > 0 and not buff.free and matches(buff) and paid
      and (not buff.double or Util.MatchDef(it.def, buff.double)) then
      charged[buff] = buff.paidOnly and paid.version or buff.chargeVersion or 0
    end
  end
  if ctx.freeCast then ctx.points, ctx.spent, ctx.empoweredHits = 0, 0, 0 end
  sim.activationSequence = (sim.activationSequence or 0) + 1
  ctx.activationId = sim.activationSequence
  ctx.source = it
  it.fired = it.fired + 1
  pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "fire", key = it.def.key, freeCast = ctx.freeCast, masteryName = ctx.masteryName,
    sourceKey = ctx.caster and ctx.caster.def.key })
  if use.once then pushCooldown(sim, side, it, t, side.stunUntil > t) end
  local times = anyMatch(side.doubleMatches, it.def) and 2 or 1
  if times == 1 then
    for _, b in ipairs(side.buffs) do
      if b.double and matches(b) and Util.MatchDef(it.def, b.double) then times = 2 break end
    end
  end
  ctx.petLandedAttacks = 0
  for pass = 1, times do
    ctx.activationPass = pass
    ctx.landed = false
    for _, e in ipairs(use.effects) do
      applyEffect(sim, side, enemy, it, e, t, ctx)
    end
    if ctx.landed then ctx.petLandedAttacks = ctx.petLandedAttacks + 1 end
  end
  if ctx.channelState and side.channel == ctx.channelState then
    side.channel.starting = false
    updateChannel(sim, side, t)
  end
  masteryEvent(sim, side, enemy, "use", it, t, ctx)
  runTriggers(sim, side, enemy, it, "use", t, ctx)
  for _, other in ipairs(side.items) do
    if other ~= it and (other.enabled or other.def.passiveTriggers) then
      runTriggers(sim, side, enemy, other, "anyUse", t, { source = it, points = ctx.points })
    end
  end
  for _, np in ipairs(it.neighbors or {}) do
    local n = side.byUid[np.uid]
    if n then runTriggers(sim, side, enemy, n, "adjacentUse", t, { source = it }) end
  end
  local hasteConsumed = false
  for index = #side.buffs, 1, -1 do
    local buff = side.buffs[index]
    if charged[buff] ~= nil and charged[buff] == (buff.chargeVersion or 0) then
      buff.charges = buff.charges - 1
      if buff.charges <= 0 then
        table.remove(side.buffs, index)
        hasteConsumed = hasteConsumed or buff.stat == "haste"
        pushEvent(sim, { t = t, side = buff.srcSide, uid = buff.srcUid, type = "statusRemoved", kind = buff.kind or "buff", key = buff.key, target = side.id })
      else
        pushEvent(sim, { t = t, side = buff.srcSide, uid = buff.srcUid, type = buff.kind or "buff", key = buff.key, stat = buff.stat,
          value = buff.value, duration = buff.remaining, icon = buff.icon, name = buff.name, stacks = buff.stacks, charges = buff.charges, target = side.id, refresh = true })
      end
    end
  end
  if hasteConsumed then syncCooldowns(sim, side, t) end
  side.itemActivation = previousActivation
  finishChain(sim, chainOwner)
end)

local function findFreeBuff(side, def)
  for _, b in ipairs(side.buffs) do
    if b.free and (not b.match or Util.MatchDef(def, b.match)) then return b end
  end
end

local function releaseClaim(claimed, it)
  local claim = claimed.items and claimed.items[it]
  if not claim then return end
  claimed[claim.resource] = max(0, (claimed[claim.resource] or 0) - claim.amount)
  claimed.items[it] = nil
end

local function activationAdmission(side, enemy, it, claimed, t)
  local use = it.def.use
  if ownerOccupied(side) and it.def.kind ~= "pet" and not (side.channel and use.interruptChannel) then
    releaseClaim(claimed, it)
    return nil, "channel"
  end
  if not it.enabled or side.hp <= 0 or enemy.hp <= 0 then releaseClaim(claimed, it) return end
  if use.once and it.fired > 0 then releaseClaim(claimed, it) return end
  if not conditionMet(use.condition, side, enemy, t) then releaseClaim(claimed, it) return end
  local payment = { cost = 0, healthCost = max(0, Util.Round((use.healthCost or 0) + side.hpMax * (use.healthCostPct or 0))) }
  if payment.healthCost > 0 and side.hp <= payment.healthCost then releaseClaim(claimed, it) return end
  if use.resource then
    payment.pool = side.res[use.resource]
    payment.cost = (use.cost or 0) * max(0, 1 + it.mods.costPct / 100)
    if payment.cost > 0 and not use.spendAll then
      if anyMatch(side.freeMatches, it.def) then payment.cost = 0
      else
        payment.freeBuff = findFreeBuff(side, it.def)
        if payment.freeBuff then payment.cost = 0 end
      end
    end
    local claim = claimed.items and claimed.items[it]
    local own = claim and claim.resource == use.resource and claim.amount or 0
    local available = (payment.pool and payment.pool.cur or 0) - (claimed[use.resource] or 0) + own
    if not payment.pool or (payment.cost > 0 and available < payment.cost) then
      if payment.pool and payment.cost > 0 then
        releaseClaim(claimed, it)
        claimed.items = claimed.items or {}
        claimed.items[it] = { resource = use.resource, amount = payment.cost }
        claimed[use.resource] = (claimed[use.resource] or 0) + payment.cost
      end
      return nil, "resource"
    end
    if payment.cost > 0 and use.spendMax then
      payment.total = min(available, max(payment.cost, use.spendMax))
    end
    if payment.cost > 0 and use.empower then
      local rule = use.empower
      local base = payment.total or payment.cost
      local charges = min(max(0, floor(side.banks[rule.key] or 0)), rule.max or 3)
      local extra = max(0, available - base)
      payment.empoweredHits = (rule.cost or 0) > 0 and min(charges, floor(extra / rule.cost)) or 0
      payment.total = base + payment.empoweredHits * (rule.cost or 0)
    end
  end
  releaseClaim(claimed, it)
  return payment
end

local function activateItem(sim, side, enemy, it, t, payment)
  local previous = sim.trace
  sim.trace = newTrace(sim, previous)
  local chainOwner = beginChain(sim)
  local use = it.def.use
  if use.interruptChannel then finishChannel(sim, side, t, "interrupt", "ability") end
  local ctx = { regularAttack = it.def.kind == "weapon" }
  if use.channel then ctx.channelState = beginChannel(sim, side, enemy, it, t) end
  local spent = payment.pool and (use.spendAll and payment.pool.cur or payment.total or payment.cost) or 0
  if use.resource then ctx.freeCast = spent <= 0 or nil end
  if use.spendAll and payment.pool then ctx.points = floor(payment.pool.cur) end
  if use.spendMax then ctx.points = spent end
  ctx.spent, ctx.empoweredHits = spent, payment.empoweredHits or 0
  if spent > 0 then
    -- Payment can grant a next-strike charge. Only charges owned before paying
    -- apply to this strike; refreshed versions remain available for the next.
    ctx.paidBuffs = {}
    for _, buff in ipairs(side.buffs) do
      if buff.paidOnly then ctx.paidBuffs[buff] = { value = buff.value, version = buff.chargeVersion or 0 } end
    end
  end
  if use.empower and ctx.empoweredHits > 0 then
    side.banks[use.empower.key] = max(0, (side.banks[use.empower.key] or 0) - ctx.empoweredHits)
  end
  if it.cd < -it.cdMax then it.cd = 0 end
  it.cd = it.cd + it.cdMax
  if spent > 0 then changeResource(sim, side, enemy, it, use.resource, -spent, t) end
  if payment.healthCost > 0 then
    side.hp = side.hp - payment.healthCost
    pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "healthCost", amount = payment.healthCost, target = side.id })
    runTriggers(sim, side, enemy, nil, "healthSpent", t, { source = it, amount = payment.healthCost })
    checkLowHealth(sim, side, enemy, t)
  end
  if payment.freeBuff then
    local index = indexOf(side.buffs, payment.freeBuff)
    local buff = index and table.remove(side.buffs, index)
    pushEvent(sim, { t = t, side = side.id, uid = it.uid, type = "free", target = side.id })
    if buff then
      pushEvent(sim, { t = t, side = buff.srcSide, uid = buff.srcUid, type = "statusRemoved", kind = buff.kind or "buff", key = buff.key, target = side.id })
      if buff.stat == "haste" then syncCooldowns(sim, side, t) end
    end
  end
  fireItem(sim, side, enemy, it, t, ctx)
  if not use.once then pushCooldown(sim, side, it, t, side.stunUntil > t) end
  finishChain(sim, chainOwner)
  sim.trace = previous
end

reactToDamage = function(sim, side, enemy, t)
  if side.hp <= 0 or enemy.hp <= 0 or side.stunUntil > t then return end
  updateChannel(sim, side, t)
  releaseDeferred(sim, side, enemy, t)
  if side.hp <= 0 or enemy.hp <= 0 or side.stunUntil > t then return end
  local owner = beginChain(sim)
  local chain = sim.chain
  chain.reactions = chain.reactions or {}
  chain.reactions[#chain.reactions + 1] = { side = side, enemy = enemy, t = t, parentTrace = sim.trace }
  if chain.reacting then return end
  chain.reacting = true
  chain.nextReaction = chain.nextReaction or 1
  while chain.nextReaction <= #chain.reactions and chain.count < Sim.MAX_CHAIN_PROCS do
    local entry = chain.reactions[chain.nextReaction]
    chain.nextReaction = chain.nextReaction + 1
    local holder, attacker = entry.side, entry.enemy
    local claimed = holder.activationClaims or {}
    if holder.hp > 0 and attacker.hp > 0 and holder.stunUntil <= entry.t then
      for _, it in ipairs(holder.actOrder) do
        if chain.count >= Sim.MAX_CHAIN_PROCS or holder.hp <= 0 or attacker.hp <= 0 or holder.stunUntil > entry.t then break end
        if it.enabled and it.def.use.reactive and it.cd <= 0 then
          local payment = activationAdmission(holder, attacker, it, claimed, entry.t)
          if payment then
            chain.count = chain.count + 1
            local previous = sim.trace
            sim.trace = entry.parentTrace
            activateItem(sim, holder, attacker, it, entry.t, payment)
            sim.trace = previous
          end
        end
      end
    end
  end
  chain.reacting = nil
  finishChain(sim, owner)
end

local function actItems(sim, side, enemy, t, dt)
  updateChannel(sim, side, t)
  releaseDeferred(sim, side, enemy, t)
  syncCooldowns(sim, side, t)
  local claimed = {}
  local previousClaims = side.activationClaims
  side.activationClaims = claimed
  for _, it in ipairs(side.actOrder) do
    if it.enabled and side.hp > 0 and enemy.hp > 0 and side.stunUntil <= t then
      it.cd = it.cd - dt * cooldownSpeed(side, it)
      if it.cd <= 0 then
        local payment, reason = activationAdmission(side, enemy, it, claimed, t)
        if payment then activateItem(sim, side, enemy, it, t, payment)
        else
          it.cd = 0
          if sim.audit and reason == "channel" then
            local own = sim.audit[side.id]
            own.channelWaits = own.channelWaits or {}
            local family = it.def.baseKey or it.def.key
            own.channelWaits[family] = (own.channelWaits[family] or 0) + dt
          end
          if sim.audit and reason == "resource" then
            local waits = sim.audit[side.id].waits
            local family = it.def.baseKey or it.def.key
            waits[family] = (waits[family] or 0) + dt
          end
        end
      end
    end
  end
  side.activationClaims = previousClaims
end

local function summarise(side)
  local items = {}
  for _, it in ipairs(side.items) do
    items[it.uid] = { key = it.def.key, fired = it.fired, dmg = it.dmg, heal = it.heal, enabled = it.enabled, suppressed = it.suppressed or false, reason = it.reason,
      procs = it.procs or 0, extraHits = it.extraHits or 0, shield = it.shieldGained or 0, resources = Util.ShallowCopy(it.resourceGains or {}) }
  end
  local resources = {}
  for res, pool in pairs(side.res) do resources[res] = pool.max end
  return {
    name = side.name, classKey = side.classKey, hpMax = side.hpMax, hpEnd = max(0, Util.Round(side.hp)),
    dmgDone = side.dmgDone, healDone = side.healDone, dmgTaken = side.dmgTaken, items = items,
    setBonuses = side.setBonuses, stats = side.stats, resources = resources, primary = side.primary, talents = Util.ShallowCopy(side.talents or {}),
  }
end

function Sim.Run(fighterA, fighterB, seed, options)
  local sim = { rng = Util.NewRNG(seed or 1), events = {}, timeline = {}, sides = {} }
  if options and options.audit then
    sim.audit = { A = { waits = {}, flows = {} }, B = { waits = {}, flows = {} } }
    sim.chainPeaks = 0
  end
  local A = buildSide(sim, "A", fighterA)
  local B = buildSide(sim, "B", fighterB)
  sim.sides.A, sim.sides.B = A, B
  local dt = Sim.TICK
  local t = 0
  local function resSnapshot(side)
    local out = {}
    for res, pool in pairs(side.res) do out[res] = pool.cur end
    return out
  end
  local function snapshot()
    return {
      t = t, hpA = max(0, A.hp), hpB = max(0, B.hp), absA = A.absorb, absB = B.absorb,
      resA = resSnapshot(A), resB = resSnapshot(B),
    }
  end
  local initial = snapshot()
  for _, side in ipairs({ A, B }) do
    for _, it in ipairs(side.actOrder) do
      if it.enabled and it.cd > 0 then pushCooldown(sim, side, it, 0, false) end
    end
  end
  runTriggers(sim, A, B, nil, "battleStart", 0, {})
  runTriggers(sim, B, A, nil, "battleStart", 0, {})
  syncCooldowns(sim, A, 0)
  syncCooldowns(sim, B, 0)
  local lastFatigue = Sim.FATIGUE_START
  local winner, endTime
  local tick = 0
  local function record()
    sim.timeline[#sim.timeline + 1] = snapshot()
  end
  record()
  while t < Sim.MAX_TIME do
    tick = tick + 1
    t = tick * dt
    local first, second = A, B
    if tick % 2 == 0 then first, second = B, A end
    for _, side in ipairs({ first, second }) do
      local enemy = side == A and B or A
      regen(side, dt)
      expireBuffs(sim, side, dt, t)
      statusTick(sim, side, t)
      if side.hp > 0 and enemy.hp > 0 then actItems(sim, side, enemy, t, dt) end
    end
    if t >= lastFatigue + 1 - 1e-6 then
      lastFatigue = lastFatigue + 1
      local amount = floor(2 + (t - Sim.FATIGUE_START) * 0.6)
      amount = max(amount, floor(ns.Economy.BaseHealth(min(A.round, B.round)) * (0.01 + (t - Sim.FATIGUE_START) * 0.003)))
      A.hp = A.hp - amount
      B.hp = B.hp - amount
      local previous = sim.trace
      sim.trace = newTrace(sim)
      pushEvent(sim, { t = t, type = "fatigue", amount = amount })
      checkRevive(sim, A, t)
      checkRevive(sim, B, t)
      local chainOwner = beginChain(sim)
      checkLowHealth(sim, first, second, t)
      checkLowHealth(sim, second, first, t)
      finishChain(sim, chainOwner)
      sim.trace = previous
    end
    record()
    if A.hp <= 0 or B.hp <= 0 then
      if A.hp <= 0 and B.hp <= 0 then winner = "draw"
      elseif A.hp <= 0 then winner = "B"
      else winner = "A" end
      endTime = t
      break
    end
  end
  if not winner then
    local fa, fb = A.hp / A.hpMax, B.hp / B.hpMax
    if fa > fb then winner = "A" elseif fb > fa then winner = "B" else winner = "draw" end
    endTime = t
  end
  return {
    winner = winner, time = endTime, seed = seed, events = sim.events, timeline = sim.timeline, initial = initial,
    A = summarise(A), B = summarise(B),
    audit = sim.audit, chainPeaks = sim.chainPeaks,
  }
end

function Sim.PreviewStats(fighter)
  local sim = { rng = Util.NewRNG(1), events = {}, timeline = {}, sides = {} }
  local side = buildSide(sim, "A", fighter)
  return side
end

