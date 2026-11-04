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
    arms = definition("Arms", "Ability_Warrior_SavageBlow", "Increases the critical strike chance of your Arms abilities and Heroic Strike by 10%.", "Your Arms abilities and Heroic Strike deal 25% additional critical strike damage.", "Every 60 Rage you spend on Arms strikes and Heroic Strike grants an extra melee attack."),
    fury = definition("Fury", "Spell_Nature_BloodLust", "Your Fury abilities cost 10% less Rage.", "Melee auto-attack hits reduce Bloodthirst's cooldown by 0.5 sec and other melee strike cooldowns by 0.25 sec.", "Every 40 Rage spent on melee abilities makes your next strike within 8 sec deal 20% more damage."),
    prot = definition("Protection", "Ability_Defend", "Increases the Block Value of your equipped shield by 4.", "Blocking an attack restores 3 Rage.", "Protection strikes that spend Rage grant a shield that absorbs damage equal to 75% of your Block Value. Shield Slam also shields you for 50% of the stored blocked damage it consumes."),
  },
  HUNTER = {
    bm = definition("Beast Mastery", "Ability_Hunter_BeastTaming", "Your Beast Mastery abilities cost 10% less Focus.", "Your pet's auto-attack hits restore 4 Focus.", "Every third pet auto-attack hit casts a free Bite, or Claw if Bite is unavailable."),
    mm = definition("Marksmanship", "Ability_Marksmanship", "Increases the critical strike chance of your Marksmanship shots by 8%.", "Your Marksmanship shot critical strikes restore 5 Mana.", "Every third Marksmanship shot fires a free Aimed Shot. Every eighth ranged auto-attack hit reduces that weapon's attack cooldown by 1 sec."),
    surv = definition("Survival", "Ability_Hunter_SwiftStrike", "Reduces your trap cooldowns by 15% and increases the critical strike chance of your Survival melee abilities by 8%.", "Your Survival abilities deal 25% more damage.", "Using a trap casts Serpent Sting at no Mana cost. Every third dodge grants a Raptor Strike at no Mana cost."),
  },
  DRUID = {
    balance = definition("Balance", "Spell_Nature_StarFall", "Your Balance spells cost 10% less Mana.", "Balance spell critical strikes reduce that spell's cooldown by 1 sec. Once per second.", "Every third Balance spell reduces its own cooldown by 4 sec."),
    feral = definition("Feral Combat", "Ability_Druid_CatForm", "Your Feral abilities cost 10% less Energy and Rage.", "Finishing moves heal 2% of your maximum health. Every 30 Rage spent on Bear attacks heals another 2%.", "Feral ability critical strikes reduce your form attack cooldown by 1 sec."),
    resto = definition("Restoration", "Spell_Nature_HealingTouch", "Your Restoration spells cost 10% less Mana.", "Restoration healing ticks reduce Swiftmend's cooldown by 0.25 sec.", "Restoration healing shields you for 35% of the health restored."),
  },
}

Mastery.TREES.WARRIOR.fury.tiers[2].detailText = "Only direct strikes that cost Rage benefit from the 0.25 sec reduction."
Mastery.TREES.WARRIOR.fury.tiers[3].detailText = "Only direct melee strikes that spend Rage benefit. Does not stack."
Mastery.TREES.HUNTER.mm.tiers[3].detailText = "Only shots that spend Mana count. Extra attacks do not count toward the auto-attack bonus."
Mastery.TREES.DRUID.balance.tiers[3].detailText = "Only spells that spend Mana count."
Mastery.TREES.DRUID.feral.tiers[2].detailText = "Finishing moves must spend Combo Points."
Mastery.TREES.DRUID.feral.tiers[3].detailText = "Free casts granted by other effects do not trigger this bonus."
Mastery.TREES.DRUID.resto.tiers[2].detailText = "Overhealing does not count."
Mastery.TREES.DRUID.resto.tiers[3].detailText = "Overhealing does not contribute to the shield."

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

function Mastery.Lines(classKey, tag, points, details)
  local def = Mastery.Definition(classKey, tag)
  if not def then return {} end
  points = points or 0
  local text = string.format("%s abilities deal %d%% more damage and healing.", def.name, points * Mastery.SPEC_BONUS_PCT)
  if classKey == "WARRIOR" and tag == "arms" then
    text = string.format("Increases damage and healing from Arms abilities and Heroic Strike by %d%%.", points * Mastery.SPEC_BONUS_PCT)
  end
  if classKey == "SHAMAN" and tag == "enhancement" then
    text = text .. string.format(" Your melee auto-attacks deal %d%% more damage.", points * Mastery.SPEC_BONUS_PCT)
  end
  local out = { { text = text, active = points > 0, points = 0 } }
  for _, tier in ipairs(def.tiers) do
    local text = tier.text .. (details and tier.detailText and " " .. tier.detailText or "")
    out[#out + 1] = { text = text, active = points >= tier.points, points = tier.points, hasDetails = tier.detailText ~= nil }
  end
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
