local ADDON, ns = ...

local Mastery = {}
ns.Mastery = Mastery

Mastery.MAX_POINTS = 10
Mastery.THRESHOLDS = { 2, 5, 8 }
Mastery.SPEC_BONUS_PCT = 2

local ABILITY_KINDS = { ability = true, form = true, pet = true, ammo = true }
local SPEC_TAGS = { arms = true, fury = true, prot = true, bm = true, mm = true, surv = true, balance = true, feral = true, resto = true,
  holy = true, protection = true, retribution = true, assassination = true, combat = true, subtlety = true,
  discipline = true, shadow = true, elemental = true, enhancement = true, restoration = true,
  arcane = true, fire = true, frost = true, affliction = true, demonology = true, destruction = true }

local function definition(name, icon, early, middle, deep)
  return {
    name = name, icon = ns.icon(icon),
    tiers = { { points = 2, text = early }, { points = 5, text = middle }, { points = 8, text = deep } },
  }
end

Mastery.TREES = {
  WARRIOR = {
    arms = definition("Arms", "Ability_Warrior_SavageBlow", "Arms abilities and Heroic Strike gain 10% Critical Strike.", "Arms abilities and Heroic Strike gain 25% Critical Strike Damage.", "Every 60 Rage spent on Arms strikes and Heroic Strike: Make an extra melee auto-attack."),
    fury = definition("Fury", "Spell_Nature_BloodLust", "Fury abilities cost 10% less Rage.", "On melee auto-attack hit: Advance Bloodthirst by 0.5s and other Rage-using melee strikes by 0.25s.", "Every 40 Rage spent on melee abilities: Your next paid direct melee strike deals 20% more damage within 8s. Does not stack."),
    prot = definition("Protection", "Ability_Defend", "Your equipped shield gains 4 Block Value.", "On block: Restore 3 Rage.", "Paid Protection strikes grant an absorb equal to 75% of Block Value. Shield Slam also absorbs 50% of its stored blocked damage."),
  },
  HUNTER = {
    bm = definition("Beast Mastery", "Ability_Hunter_BeastTaming", "Beast Mastery abilities cost 10% less Focus.", "On pet auto-attack hit: Restore 4 Focus.", "Every 3 pet auto-attack hits: Cast Bite for free, or Claw if you have no Bite."),
    mm = definition("Marksmanship", "Ability_Marksmanship", "Marksmanship shots gain 8% Critical Strike.", "On Marksmanship shot crit: Restore 5 Mana.", "Every 3 normal Marksmanship shots: Cast Aimed Shot for free."),
    surv = definition("Survival", "Ability_Hunter_SwiftStrike", "Trap cooldowns are 15% shorter. Survival melee abilities gain 8% Critical Strike.", "Survival abilities deal 25% more damage.", "On trap cast: Cast Serpent Sting for free. Every 3 dodges: Cast Raptor Strike for free."),
  },
  DRUID = {
    balance = definition("Balance", "Spell_Nature_StarFall", "Balance spells cost 10% less Mana.", "On Balance spell crit: Advance Starfire by 1s.", "Every 3 paid Balance spells: Advance Starfire by 4s."),
    feral = definition("Feral Combat", "Ability_Druid_CatForm", "Feral abilities cost 10% less Energy and Rage.", "Finishers heal 2% maximum health. Every 30 Rage spent on Bear attacks heals 2% maximum health.", "On paid Feral ability crit: Reduce your form attack cooldown by 1s."),
    resto = definition("Restoration", "Spell_Nature_HealingTouch", "Restoration spells cost 10% less Mana.", "On effective Restoration healing tick: Advance Swiftmend by 0.25s.", "Effective Restoration healing grants an absorb equal to 35% of the healing."),
  },
}

Mastery.TREES.WARRIOR.arms.tiers[3].triggers = {
  { on = "resourceSpent", resource = "rage", match = { kind = "ability", tag = "arms", anyTag = { "strike" }, damaging = "direct" },
    everyAmount = 60, effects = { { type = "extraAttack", count = 1 } } },
}
Mastery.TREES.WARRIOR.fury.tiers[3].triggers = {
  { on = "resourceSpent", resource = "rage", match = { kind = "ability", tag = "melee" }, everyAmount = 40,
    effects = { { type = "buff", key = "fury_spending", name = "Fury", target = "all",
      match = { kind = "ability", tag = "melee", anyTag = { "strike" }, damaging = "direct" },
      paidOnly = true, stat = "dmgPct", value = 20, charges = 1, duration = 8 } } },
}

function Mastery.Budget(round)
  round = math.floor(tonumber(round) or 1)
  if round >= 12 then return Mastery.MAX_POINTS end
  if round >= 9 then return 8 end
  if round >= 6 then return 5 end
  if round >= 3 then return 2 end
  return 0
end

function Mastery.Empty(classKey)
  local out = {}
  local class = ns.GetClass(classKey)
  for _, spec in ipairs(class and class.specs or {}) do out[spec.tag] = 0 end
  return out
end

function Mastery.Normalize(classKey, allocation)
  local out = Mastery.Empty(classKey)
  for key in pairs(out) do out[key] = type(allocation) == "table" and allocation[key] or 0 end
  return out
end

function Mastery.Validate(classKey, round, allocation)
  local allowed = Mastery.Empty(classKey)
  if not ns.GetClass(classKey) then return false, "Unknown class." end
  if allocation == nil then return true end
  if type(allocation) ~= "table" then return false, "Invalid talent allocation." end
  for key in pairs(allocation) do
    if allowed[key] == nil then return false, "Unknown talent tree." end
  end
  local total = 0
  for _, value in pairs(allocation) do
    if type(value) ~= "number" or value ~= math.floor(value) or value < 0 or value > Mastery.MAX_POINTS then return false, "Invalid talent points." end
    total = total + value
  end
  if total > Mastery.Budget(round) then return false, "Talent point budget exceeded." end
  return true
end

function Mastery.Pack(classKey, allocation)
  local out = {}
  local values = Mastery.Normalize(classKey, allocation)
  for _, spec in ipairs(ns.GetClass(classKey).specs or {}) do out[#out + 1] = values[spec.tag] end
  return out
end

function Mastery.Unpack(classKey, round, packed)
  if packed == nil then return Mastery.Empty(classKey) end
  local class = ns.GetClass(classKey)
  if not class or type(packed) ~= "table" then return nil, "Invalid talent allocation." end
  local out = {}
  local count = #(class.specs or {})
  for key in pairs(packed) do
    if type(key) ~= "number" or key ~= math.floor(key) or key < 1 or key > count then return nil, "Invalid talent allocation." end
  end
  for index, spec in ipairs(class.specs or {}) do
    if packed[index] == nil then return nil, "Missing talent points." end
    out[spec.tag] = packed[index]
  end
  local valid, err = Mastery.Validate(classKey, round, out)
  if not valid then return nil, err end
  return out
end

function Mastery.Spec(def)
  if not def or not ABILITY_KINDS[def.kind] then return nil end
  if def.spec ~= nil then return SPEC_TAGS[def.spec] and def.spec or nil end
  local found
  for _, tag in ipairs(def.tags or {}) do
    if SPEC_TAGS[tag] then
      if found and found ~= tag then return nil end
      found = tag
    end
  end
  return found
end

function Mastery.Definition(classKey, tag)
  return Mastery.TREES[classKey] and Mastery.TREES[classKey][tag]
end

function Mastery.Lines(classKey, tag, points)
  local def = Mastery.Definition(classKey, tag)
  if not def then return {} end
  points = points or 0
  local text = string.format("Spec abilities gain %d%% damage and healing.", points * Mastery.SPEC_BONUS_PCT)
  if classKey == "WARRIOR" and tag == "arms" then
    text = string.format("Arms abilities and Heroic Strike gain %d%% damage and healing.", points * Mastery.SPEC_BONUS_PCT)
  end
  if classKey == "SHAMAN" and tag == "enhancement" then
    text = text .. string.format(" Melee auto-attacks deal %d%% more damage.", points * Mastery.SPEC_BONUS_PCT)
  end
  local out = { { text = text, active = points > 0, points = 0 } }
  for _, tier in ipairs(def.tiers) do out[#out + 1] = { text = tier.text, active = points >= tier.points, points = tier.points } end
  return out
end

function Mastery.Apply(side, allocation)
  side.talents = Mastery.Normalize(side.classKey, allocation)
  local total = 0
  for _, points in pairs(side.talents) do total = total + points end
  side.mastery = { progress = {}, total = total }
  for _, it in ipairs(side.items) do
    local spec = Mastery.Spec(it.def)
    if not spec and side.classKey == "WARRIOR" and (side.talents.arms or 0) > 0
      and (it.def.baseKey or it.def.key) == "heroic_strike" then spec = "arms" end
    local points = spec and side.talents[spec] or 0
    it.masterySpec = spec
    if points > 0 then
      it.mods.dmgPct = it.mods.dmgPct + points * Mastery.SPEC_BONUS_PCT
      it.mods.healPct = it.mods.healPct + points * Mastery.SPEC_BONUS_PCT
      if spec == "arms" then
        if points >= 2 then it.mods.crit = it.mods.crit + 10 end
        if points >= 5 then it.masteryCritDamage = 25 end
      elseif spec == "fury" then
        if points >= 2 and it.def.use and it.def.use.resource == "rage" then it.mods.costPct = it.mods.costPct - 10 end
      elseif spec == "bm" then
        if points >= 2 and it.def.use and it.def.use.resource == "focus" then it.mods.costPct = it.mods.costPct - 10 end
      elseif spec == "mm" then
        if points >= 2 and it.def.tagSet.shot then it.mods.crit = it.mods.crit + 8 end
      elseif spec == "surv" then
        if points >= 2 and it.def.tagSet.trap then it.mods.cdPct = it.mods.cdPct + 15 end
        if points >= 2 and it.def.tagSet.melee then it.mods.crit = it.mods.crit + 8 end
        if points >= 5 then it.mods.dmgPct = it.mods.dmgPct + 25 end
      elseif spec == "balance" or spec == "resto" then
        if points >= 2 and it.def.use and it.def.use.resource == "mana" then it.mods.costPct = it.mods.costPct - 10 end
      elseif spec == "feral" then
        local resource = it.def.use and it.def.use.resource
        if points >= 2 and (resource == "energy" or resource == "rage") then it.mods.costPct = it.mods.costPct - 10 end
      end
    end
  end
  if (side.talents.prot or 0) >= 2 and side.shield then side.stats.block = side.stats.block + 4 end
  local class = ns.GetClass(side.classKey)
  for _, spec in ipairs(class.specs) do
    local tree = Mastery.Definition(side.classKey, spec.tag)
    local points = side.talents[spec.tag] or 0
    for _, tier in ipairs(tree and tree.tiers or {}) do
      if points >= tier.points then
        for stat, amount in pairs(tier.stats or {}) do side.stats[stat] = (side.stats[stat] or 0) + amount end
        if tier.mods then
          for _, it in ipairs(side.items) do
            if it.masterySpec == spec.tag then
              for stat, amount in pairs(tier.mods) do it.mods[stat] = (it.mods[stat] or 0) + amount end
            end
          end
        end
        if tier.triggers then
          local key = ns.Sim.TalentSourceKey(side.classKey, spec.tag, tier.points)
          ns.Sim.AddTriggerSource(side, key, { key = key, name = tree.name, icon = tree.icon, kind = "talent", triggers = tier.triggers })
        end
      end
    end
  end
end
