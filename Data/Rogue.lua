local ADDON, ns = ...
local H = ns.H
local S = H.S
local ROGUE = { "ROGUE" }
local ability = H.QualityAbilities(ROGUE)



ability(4000, "sinister_strike", "Sinister Strike", "combat", "Spell_Shadow_RitualOfSacrifice", 1, {
  tags = { "combat", "melee", "strike", "builder", "cold_blood_attack" },
  use = {
    cost = 35, cd = 3, resource = "energy", requires = "melee",
    effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1 }, { type = "resource", resource = "combo", amount = 1 } },
  },
  shopWeight = 2,
})


ability(4001, "eviscerate", "Eviscerate", "assassination", "Ability_Rogue_Eviscerate", 1, {
  tags = { "assassination", "melee", "finisher", "cold_blood_attack" },
  use = {
    cost = 3, cd = 7, initialDelay = 0.1, resource = "combo", requires = "melee",
    effects = { { type = "damage", coef = 0.5, min = 2, max = 4, school = "physical", consumeDots = { match = { tag = "poison" }, fraction = 0.25 }, perCombo = 0.2, perPoint = 2 } },
    spendAll = true,
  },
  shopWeight = 1.75,
})

ability(4002, "rupture", "Rupture", "assassination", "Ability_Rogue_Rupture", 1, {
  tags = { "assassination", "melee", "finisher", "bleed", "dot" },
  use = {
    cost = 3, cd = 10, initialDelay = 0.1, resource = "combo", requires = "melee",
    effects = { { type = "dot", key = "rupture", coef = 0.075, tick = 1, school = "physical", duration = 12, perCombo = 0.5, rolling = true } },
    spendAll = true,
  },
  shopWeight = 1.5,
})

ability(4003, "slice_and_dice", "Slice and Dice", "assassination", "Ability_Rogue_SliceDice", 2, {
  tags = { "assassination", "finisher" },
  use = {
    cost = 2, cd = 10, initialDelay = 0.1, resource = "combo", condition = "buffNeeds:slice_and_dice:1",
    effects = { { type = "buff", key = "slice_and_dice", name = "Slice and Dice", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 30, duration = 4, durationPerPoint = 2 } },
    spendAll = true,
  },
  shopWeight = 1.5,
})



ability(4004, "kidney_shot", "Kidney Shot", "assassination", "Ability_Rogue_KidneyShot", 2, {
  minRound = 3, tags = { "assassination", "finisher", "control" },
  use = {
    cost = 3, cd = 15, initialDelay = 0.1, resource = "combo", requires = "melee", condition = "readyStrike",
    effects = {
      { type = "stun", duration = 2, rankScale = false },
      { type = "buff", key = "kidney_opening", name = "Kidney Shot", target = "all", match = { tag = "builder" }, stat = "crit", value = 30, duration = 5, charges = 1 },
    },
    spendAll = true,
  },
  shopWeight = 1.25,
})



ability(4005, "instant_poison", "Instant Poison", "assassination", "Ability_Poisons", 1, {
  shape = S.v2, tags = { "assassination", "poison", "nature" },
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 35, effects = { { type = "damage", coef = 0.2, min = 1, max = 2, school = "nature", noDodge = true, powerStat = "ap" } } } },
  coating = true, shopFitRequires = { "melee" }, shopWeight = 1.4,
})

ability(4006, "deadly_poison", "Deadly Poison", "assassination", "Ability_Rogue_DualWeild", 1, {
  shape = S.v2, tags = { "assassination", "poison", "nature", "dot" },
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" }, chance = 45,
      effects = { { type = "dot", key = "deadly_poison", coef = 0.025, tick = 1, school = "nature", duration = 12, maxStacks = 5, powerStat = "ap", preserveTicks = true, stack = true } },
    },
  },
  coating = true, shopFitRequires = { "melee" }, shopWeight = 1.4,
})



ability(4007, "wound_poison", "Wound Poison", "assassination", "INV_Misc_Herb_16", 2, {
  minRound = 3, shape = S.v2, tags = { "assassination", "poison", "nature" },
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" }, chance = 35,
      effects = {
        { type = "damage", coef = 0.15, min = 1, max = 2, school = "nature", noDodge = true, powerStat = "ap" },
        { type = "debuff", key = "wound_poison", name = "Wound Poison", exclusiveGroup = "healing_reduction", stat = "healPct", value = 15, duration = 8, maxStacks = 3, stack = true },
      },
    },
  },
  coating = true, shopFitRequires = { "melee" },
})

ability(4008, "crippling_poison", "Crippling Poison", "assassination", "Ability_PoisonSting", 2, {
  shape = S.v2, tags = { "assassination", "poison", "nature", "control" },
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" }, chance = 30,
      effects = {
        { type = "debuff", key = "crippling_poison", name = "Crippling Poison", stat = "haste", value = 20, duration = 5 },
        { type = "cdr", target = "all", match = { tag = "finisher" }, amount = 0.5, clampReady = true },
      },
    },
  },
  coating = true, shopFitRequires = { "melee" },
})



ability(4009, "cold_blood", "Cold Blood", "assassination", "Spell_Ice_Lament", 4, {
  tags = { "assassination" },
  use = {
    cd = 18, initialDelay = 0,
    effects = {
      {
        type = "buff", key = "cold_blood", name = "Cold Blood", target = "neighbors", area = { side = "front" },
        match = { damaging = "direct", tag = "cold_blood_attack" }, stat = "crit", value = 100, duration = 120, charges = 1, paidOnly = true,
      },
    },
  },
  shopWeight = 0.65,
})

ability(4010, "seal_fate", "Seal Fate", "assassination", "Spell_Shadow_ChillTouch", 3, {
  shape = S.v2, tags = { "assassination" },
  triggers = { { on = "anyCrit", match = { tag = "builder" }, effects = { { type = "resource", resource = "combo", amount = 1 } }, healing = false, oncePerActivation = true } },
})

ability(4011, "relentless_strikes", "Relentless Strikes", "assassination", "Ability_Warrior_DecisiveStrike", 2, { shape = S.v2, tags = { "assassination" }, triggers = { { on = "resourceSpent", resource = "combo", effects = { { type = "resource", resource = "energy", fromEvent = 4 } } } } })

ability(4012, "ruthlessness", "Ruthlessness", "assassination", "Ability_Druid_Disembowel", 2, {
  shape = S.v2, tags = { "assassination" },
  triggers = { { on = "resourceSpent", resource = "combo", match = { tag = "finisher" }, chance = 60, effects = { { type = "resource", resource = "combo", amount = 1 } } } },
})

ability(4013, "malice", "Malice", "assassination", "Ability_Racial_BloodRage", 1, { shape = S.v2, tags = { "assassination" }, stats = { crit = 6 }, passiveTriggers = true, shopClasses = {} })

ability(4014, "lethality", "Lethality", "assassination", "Ability_CriticalStrike", 3, {
  shape = S.v2, tags = { "assassination" },
  triggers = { { on = "anyCrit", match = { tag = "melee" }, icd = 2, effects = { { type = "tickDots", match = { tag = "poison" } } }, healing = false } },
  adjacency = { { match = { tag = "builder" }, corners = true, mods = { dmgPct = 15 } } },
})

ability(4015, "improved_poisons", "Improved Poisons", "assassination", "Ability_Poisons", 3, {
  shape = S.v2, tags = { "assassination" },
  triggers = { { on = "dotTick", match = { tag = "poison" }, icd = 1, every = 3, effects = { { type = "resource", resource = "energy", amount = 5 } } } },
})

ability(4016, "vile_poisons", "Vile Poisons", "assassination", "Ability_Rogue_FeignDeath", 4, {
  shape = S.v2, tags = { "assassination" },
  triggers = { { on = "resourceSpent", resource = "combo", match = { tag = "finisher" }, icd = 1, effects = { { type = "tickDots", match = { tag = "poison" } } } } },
  adjacency = { { match = { tag = "poison" }, mods = { dmgPct = 25 }, side = "back" } },
})

ability(4017, "backstab", "Backstab", "combat", "Ability_BackStab", 2, {
  tags = { "combat", "melee", "strike", "builder", "cold_blood_attack" },
  use = {
    cost = 50, cd = 5, resource = "energy", requires = "dagger",
    effects = {
      { type = "damage", weaponType = "dagger", coef = 0.55, min = 1, max = 3, school = "physical", critIf = "enemyStunned", weapon = true, weaponPct = 1.7 },
      { type = "resource", resource = "combo", amount = 1 },
    },
  },
  shopWeight = 1.75,
})

ability(4018, "gouge", "Gouge", "combat", "Ability_Gouge", 1, {
  tags = { "combat", "melee", "builder", "control" },
  use = {
    cost = 20, cd = 12, resource = "energy", requires = "melee", condition = "resourceAtMost:energy:60",
    effects = {
      { type = "damage", coef = 0.1, min = 2, max = 4, school = "physical" },
      { type = "stun", duration = 1.2, breakOnDamage = true, controlType = "incapacitate", holdWeapons = true, rankScale = false },
      { type = "resource", resource = "combo", amount = 1 },
    },
  },
})

ability(4019, "riposte", "Riposte", "combat", "Ability_Warrior_Challange", 2, {
  minRound = 3, tags = { "combat", "melee", "strike", "builder" }, stats = { dodge = 5 },
  use = {
    cost = 10, cd = 6, resource = "energy", requires = "melee", condition = "buff:rogue_riposte",
    effects = {
      { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1.5 },
      { type = "resource", resource = "combo", amount = 1 },
      { type = "debuff", key = "riposte_disarm", name = "Riposte", stat = "meleePct", value = 15, duration = 4 },
    },
  },
  triggers = {
    { on = "dodged", effects = { { type = "buff", key = "rogue_riposte", name = "Riposte", stat = "none", value = 0, duration = 4 } } },
    { on = "damaged", chance = 20, icd = 5, effects = { { type = "buff", key = "rogue_riposte", name = "Riposte", stat = "none", value = 0, duration = 4 } } },
  },
})


ability(4020, "blade_flurry", "Blade Flurry", "combat", "Ability_Warrior_PunishingBlow", 4, {
  tags = { "combat" },
  use = {
    cost = 20, cd = 22, initialDelay = 3, resource = "energy",
    effects = {
      { type = "buff", key = "blade_flurry_haste", name = "Blade Flurry", target = "all", match = { tag = "melee" }, stat = "haste", value = 25, duration = 7 },
      { type = "buff", key = "blade_flurry", name = "Blade Flurry", stat = "none", value = 0, duration = 7, double = { tag = "builder" } },
    },
  },
})

ability(4021, "adrenaline_rush", "Adrenaline Rush", "combat", "Spell_Shadow_ShadowWordDominate", 5, {
  minRound = 9, shape = S.L, tags = { "combat" },
  use = {
    cd = 24, initialDelay = 2, condition = "resourceAtMost:energy:70",
    effects = {
      { type = "buff", key = "adrenaline_rush", name = "Adrenaline Rush", target = "all", match = { tag = "builder" }, stat = "haste", value = 40, duration = 8 },
      {
        type = "buff", key = "adrenaline_recovery", name = "Adrenaline Rush", stat = "none", value = 0, duration = 8,
        periodic = { every = 1, effects = { { type = "resource", resource = "energy", amount = 10 } } },
      },
    },
  },
  shopWeight = 0.65,
})

ability(4022, "dual_wield_specialization_rogue", "Dual Wield Specialization", "combat", "Ability_DualWield", 2, {
  shape = S.v2, tags = { "combat" },
  triggers = { { on = "regularHit", condition = "dualwield", match = { tag = "melee" }, every = 3, effects = { { type = "resource", resource = "energy", amount = 7 } } } },
})

ability(4023, "sword_specialization_rogue", "Sword Specialization", "combat", "INV_Sword_27", 3, { minRound = 5, shape = S.v2, tags = { "combat" }, triggers = { { on = "anyHit", match = { weaponType = "sword" }, chance = 8, icd = 2, effects = { { type = "extraAttack" } } } } })

ability(4024, "dagger_specialization", "Dagger Specialization", "combat", "INV_Weapon_ShortBlade_05", 2, {
  shape = S.v2, tags = { "combat" },
  triggers = { { on = "anyCrit", match = { weaponType = "dagger" }, effects = { { type = "cdr", target = "all", match = { tag = "builder" }, amount = 0.5, clampReady = true } }, healing = false } },
  adjacency = { { match = { weaponType = "dagger" }, mods = { crit = 10 }, side = "front" } },
})

ability(4025, "precision", "Precision", "combat", "Ability_Marksmanship", 1, { shape = S.v2, tags = { "combat" }, adjacency = { { match = { damaging = "direct", tag = "strike" }, corners = true, mods = { dmgPct = 10 } } }, passiveTriggers = true })

ability(4026, "aggression", "Aggression", "combat", "Ability_Racial_Avatar", 3, {
  shape = S.v2, tags = { "combat" },
  triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 50, effects = { { type = "cdr", target = "all", match = { tag = "autoattack" }, amount = 1, clampReady = true } } } },
})

ability(4027, "lightning_reflexes_rogue", "Lightning Reflexes", "combat", "Spell_Nature_Invisibilty", 1, { shape = S.v2, tags = { "combat" }, stats = { dodge = 7 }, passiveTriggers = true, shopClasses = {} })

ability(4028, "stealth", "Stealth", "subtlety", "Ability_Stealth", 1, {
  tags = { "subtlety" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        { type = "buff", key = "rogue_stealth", name = "Stealth", stat = "none", value = 0, duration = 8 },
        { type = "buff", key = "stealth_opening", name = "Stealth", target = "all", match = { tag = "opener" }, stat = "crit", value = 20, duration = 8 },
      },
    },
  },
  shopWeight = 1.5,
})



ability(4029, "ambush", "Ambush", "subtlety", "Ability_Rogue_Ambush", 2, {
  tags = { "subtlety", "melee", "strike", "builder", "opener", "cold_blood_attack" },
  use = {
    cost = 55, cd = 12, initialDelay = 0.5, resource = "energy", requires = "dagger", condition = "buff:rogue_stealth",
    effects = {
      { type = "damage", weaponType = "dagger", coef = 0.7, min = 2, max = 4, school = "physical", weapon = true, weaponPct = 2 },
      { type = "resource", resource = "combo", amount = 2 },
      { type = "buff", key = "rogue_stealth", stat = "none", value = 0, duration = 0, anySource = true, charges = 0 },
    },
  },
  shopRequires = { "stealth" }, shopWeight = 1.4,
})

ability(4030, "garrote", "Garrote", "subtlety", "Ability_Rogue_Garrote", 1, {
  tags = { "subtlety", "melee", "builder", "opener", "bleed", "dot" },
  use = {
    cost = 40, cd = 12, initialDelay = 0.5, resource = "energy", requires = "melee", condition = "buff:rogue_stealth",
    effects = {
      { type = "dot", key = "garrote", coef = 0.1, tick = 1, school = "physical", duration = 12, rolling = true },
      { type = "resource", resource = "combo", amount = 1 },
      { type = "buff", key = "rogue_stealth", stat = "none", value = 0, duration = 0, anySource = true, charges = 0 },
    },
  },
  triggers = { { on = "dotTick", match = { key = "garrote" }, effects = { { type = "resource", resource = "energy", amount = 2 } } } },
  shopRequires = { "stealth" }, shopWeight = 1.4,
})

ability(4031, "cheap_shot", "Cheap Shot", "subtlety", "Ability_CheapShot", 2, {
  minRound = 3, tags = { "subtlety", "builder", "opener", "control" },
  use = {
    cost = 35, cd = 15, initialDelay = 0.2, resource = "energy", requires = "melee", condition = "buff:rogue_stealth",
    effects = {
      { type = "stun", duration = 1.5, rankScale = false }, { type = "resource", resource = "combo", amount = 2 },
      { type = "cdr", target = "all", match = { key = "backstab" }, amount = 3, clampReady = true },
      { type = "buff", key = "rogue_stealth", stat = "none", value = 0, duration = 0, anySource = true, charges = 0 },
    },
    rankCosts = { [2] = 28, [3] = 23 },
  },
  shopRequires = { "stealth" },
})

ability(4032, "hemorrhage", "Hemorrhage", "subtlety", "Spell_Shadow_LifeDrain", 1, {
  tags = { "subtlety", "melee", "strike", "builder" },
  use = {
    cost = 30, cd = 4, resource = "energy", requires = "melee",
    effects = {
      { type = "damage", coef = 0.35, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1 },
      { type = "debuff", key = "hemorrhage", name = "Hemorrhage", stat = "armor", value = 12, duration = 8 },
      { type = "resource", resource = "combo", amount = 1 },
    },
  },
  triggers = { { on = "dotTick", match = { tag = "bleed" }, every = 4, effects = { { type = "resource", resource = "combo", amount = 1 } } } },
  shopWeight = 1.5,
})

ability(4033, "ghostly_strike", "Ghostly Strike", "subtlety", "Spell_Shadow_Curse", 2, {
  tags = { "subtlety", "melee", "strike", "builder" },
  use = {
    cost = 30, cd = 10, resource = "energy", requires = "melee",
    effects = {
      { type = "damage", coef = 0.4, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1.25 },
      { type = "resource", resource = "combo", amount = 1 },
      { type = "buff", key = "ghostly_strike", name = "Ghostly Strike", stat = "dodge", value = 15, duration = 5 },
    },
  },
})

ability(4034, "vanish", "Vanish", "subtlety", "Ability_Vanish", 3, {
  tags = { "subtlety" },
  use = {
    cost = 15, cd = 18, initialDelay = 9, resource = "energy",
    effects = {
      { type = "buff", key = "rogue_stealth", name = "Vanish", stat = "none", value = 0, duration = 6 },
      { type = "buff", key = "vanish_evasion", name = "Vanish", stat = "dodge", value = 30, duration = 3 },
      { type = "cdr", target = "all", match = { tag = "opener" }, amount = 8, clampReady = true },
    },
  },
  shopRequires = { "stealth" },
})

ability(4035, "preparation", "Preparation", "subtlety", "Spell_Shadow_AntiShadow", 4, {
  tags = { "subtlety" },
  use = {
    cd = 28, initialDelay = 12,
    effects = {
      { type = "cdr", target = "all", match = { key = "vanish" }, amount = 18, clampReady = true },
      { type = "cdr", target = "all", match = { key = "evasion" }, amount = 18, clampReady = true },
      { type = "cdr", target = "all", match = { key = "sprint" }, amount = 18, clampReady = true },
      { type = "cdr", target = "all", match = { key = "blind" }, amount = 18, clampReady = true },
      { type = "resource", resource = "energy", amount = 30 },
    },
  },
})

ability(4036, "premeditation", "Premeditation", "subtlety", "Spell_Shadow_Possession", 5, {
  minRound = 9, shape = S.v2, tags = { "subtlety" },
  triggers = {
    { on = "battleStart", effects = { { type = "resource", resource = "combo", amount = 2 } } },
    { on = "anyUse", match = { key = "vanish" }, effects = { { type = "resource", resource = "combo", amount = 2 } } },
    {
      on = "resourceSpent", resource = "combo", match = { tag = "finisher" }, icd = 1, everyAmount = 5,
      effects = { { type = "cdr", target = "all", match = { key = "vanish" }, amount = 4, clampReady = true } },
    },
  },
  shopWeight = 0.65,
})

ability(4037, "initiative", "Initiative", "subtlety", "Spell_Shadow_Fumble", 2, {
  shape = S.v2, tags = { "subtlety" },
  triggers = {
    {
      on = "resourceSpent", resource = "energy", match = { tag = "opener" }, icd = 1,
      effects = { { type = "resource", resource = "combo", amount = 1 }, { type = "resource", resource = "energy", amount = 8 } },
    },
  },
})

ability(4038, "serrated_blades", "Serrated Blades", "subtlety", "INV_Sword_17", 3, {
  shape = S.v2, tags = { "subtlety" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "melee" }, icd = 1,
      effects = { { type = "dot", key = "serrated_blades", tick = 0, school = "physical", duration = 6, fromEvent = 0.15, rolling = true } },
      effective = true, healing = false, oncePerActivation = true,
    },
  },
})

ability(4039, "setup", "Setup", "subtlety", "Spell_Nature_MirrorImage", 2, {
  shape = S.v2, tags = { "subtlety" },
  triggers = { { on = "dodged", icd = 1, effects = { { type = "resource", resource = "combo", amount = 1 }, { type = "resource", resource = "energy", amount = 5 } } } },
})

ability(4040, "dirty_deeds", "Dirty Deeds", "subtlety", "Spell_Shadow_SummonSuccubus", 3, {
  minRound = 5, shape = S.v2, tags = { "subtlety" },
  triggers = { { on = "enemyStunned", icd = 2, effects = { { type = "tickDots", match = { tag = "bleed" } } } } },
  adjacency = { { match = { tag = "opener" }, corners = true, mods = { costPct = -20 } } },
})

ability(4041, "evasion", "Evasion", "shared", "Spell_Shadow_ShadowWard", 2, { tags = { "defensive" }, use = { cd = 22, initialDelay = 4, effects = { { type = "buff", key = "evasion", name = "Evasion", stat = "dodge", value = 40, duration = 5 } } } })

ability(4042, "sprint", "Sprint", "shared", "Ability_Rogue_Sprint", 1, {
  tags = { "shared" },
  use = {
    cost = 15, cd = 18, initialDelay = 2, resource = "energy",
    effects = { { type = "buff", key = "sprint", name = "Sprint", target = "all", match = { tag = "melee" }, stat = "haste", value = 20, duration = 5 } },
  },
})

ability(4043, "kick", "Kick", "shared", "Ability_Kick", 2, {
  tags = { "melee", "control" },
  use = {
    cost = 15, cd = 12, resource = "energy", requires = "melee",
    effects = { { type = "damage", coef = 0.15, min = 1, max = 2, school = "physical" }, { type = "stun", duration = 0.8, rankScale = false } },
  },
})


ability(4044, "blind", "Blind", "shared", "Spell_Shadow_MindSteal", 3, {
  tags = { "control", "defensive" },
  use = {
    cost = 20, cd = 20, resource = "energy", condition = "resourceAtMost:energy:60",
    effects = { { type = "stun", duration = 2, breakOnDamage = true, controlType = "incapacitate", holdWeapons = true, rankScale = false } },
  },
})

ability(4045, "expose_armor", "Expose Armor", "assassination", "Ability_Warrior_Riposte", 2, {
  tags = { "assassination", "finisher" },
  use = {
    cost = 2, cd = 12, initialDelay = 0.1, resource = "combo", condition = "enemyNeeds:expose_armor:1",
    effects = { { type = "debuff", key = "expose_armor", name = "Expose Armor", stat = "armor", value = 0, duration = 12, valuePerPoint = 12.5 } },
    spendAll = true,
  },
  triggers = { { on = "use", match = { key = "expose_armor" }, icd = 1, effects = { { type = "tickDots", match = { tag = "bleed" } } }, oncePerActivation = true, paidOnly = true } },
})

ability(4046, "vigor", "Vigor", "assassination", "Spell_Nature_EarthBindTotem", 5, {
  minRound = 9, shape = S.L, tags = { "assassination" }, grants = { energy = { max = 140, regen = 10, start = 140 } },
  triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 70, effects = { { type = "resource", resource = "energy", amount = 20 } } } },
})

ability(4047, "deflection_rogue", "Deflection", "combat", "Ability_Parry", 3, {
  shape = S.v2, tags = { "combat" }, stats = { dodge = 5 },
  triggers = {
    {
      on = "dodged",
      effects = {
        { type = "buff", key = "rogue_riposte", name = "Riposte", stat = "none", value = 0, duration = 4 },
        { type = "cdr", target = "all", match = { key = "riposte" }, amount = 2, clampReady = true },
      },
    },
  },
})

ability(4048, "endurance_rogue", "Endurance", "combat", "Spell_Shadow_ShadowWard", 2, {
  shape = S.v2, tags = { "combat" },
  triggers = {
    {
      on = "resourceSpent", resource = "energy", icd = 1, everyAmount = 60,
      effects = {
        { type = "cdr", target = "all", match = { key = "evasion" }, amount = 1, clampReady = true },
        { type = "cdr", target = "all", match = { key = "sprint" }, amount = 1, clampReady = true },
      },
    },
  },
})

ability(4049, "mace_specialization_rogue", "Mace Specialization", "combat", "INV_Mace_01", 3, {
  minRound = 5, shape = S.v2, tags = { "combat" },
  triggers = { { on = "regularHit", match = { weaponType = "mace" }, chance = 15, icd = 3, effects = { { type = "stun", duration = 0.8, rankScale = false } } } },
  adjacency = { { match = { weaponType = "mace" }, corners = true, mods = { dmgPct = 15 } } },
})

ability(4050, "weapon_expertise_rogue", "Weapon Expertise", "combat", "Spell_Holy_BlessingOfStrength", 4, {
  shape = S.v2, tags = { "combat" },
  triggers = {
    {
      on = "resourceSpent", resource = "combo", match = { tag = "finisher" },
      effects = {
        { type = "buff", key = "weapon_expertise", name = "Weapon Expertise", target = "all", match = { tag = "autoattack" }, stat = "crit", value = 35, duration = 6, charges = 1 },
        { type = "cdr", target = "all", match = { tag = "autoattack" }, amount = 1, clampReady = true },
      },
    },
  },
})

ability(4051, "camouflage", "Camouflage", "subtlety", "Ability_Stealth", 1, {
  shape = S.v2, tags = { "subtlety" },
  triggers = {
    { on = "anyUse", match = { key = "vanish" }, effects = { { type = "resource", resource = "energy", amount = 12 } } },
    { on = "anyUse", match = { tag = "opener" }, effects = { { type = "buff", key = "camouflage", name = "Camouflage", stat = "dodge", value = 8, duration = 4 } } },
  },
})

ability(4052, "opportunity", "Opportunity", "subtlety", "Ability_Warrior_WarCry", 3, {
  shape = S.v2, tags = { "subtlety" },
  triggers = {
    {
      on = "enemyStunned", icd = 2,
      effects = {
        { type = "cdr", target = "all", match = { key = "backstab" }, amount = 0.75, clampReady = true },
        { type = "cdr", target = "all", match = { tag = "opener" }, amount = 0.75, clampReady = true },
      },
    },
  },
  adjacency = { { match = { tag = "opener" }, mods = { dmgPct = 20 }, side = "front" } },
})

ability(4053, "elusiveness", "Elusiveness", "subtlety", "Spell_Magic_LesserInvisibilty", 4, {
  shape = S.v2, tags = { "subtlety" },
  triggers = {
    {
      on = "dodged", icd = 1,
      effects = {
        { type = "cdr", target = "all", match = { key = "vanish" }, amount = 1, clampReady = true },
        { type = "cdr", target = "all", match = { key = "blind" }, amount = 1, clampReady = true },
      },
    },
  },
})

ability(4060, "mind_numbing_poison", "Mind-numbing Poison", "assassination", "Spell_Nature_NullifyDisease", 1, {
  shape = S.v2, tags = { "assassination", "poison", "nature", "control" },
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" }, chance = 20,
      effects = {
        {
          type = "debuff", key = "mind_numbing_poison", name = "Mind-numbing Poison", target = "all", match = { kind = "ability", tag = "spell" },
          stat = "haste", value = 25, duration = 6, rankScale = false,
        },
      },
    },
  },
  coating = true, rankable = false, shopFitRequires = { "melee" },
})

ability(4061, "feint", "Feint", "combat", "Ability_Rogue_Feint", 1, {
  tags = { "combat", "melee", "defensive" },
  use = {
    cost = 20, cd = 14, reactive = true, resource = "energy", requires = "melee", condition = "below50",
    effects = { { type = "debuff", key = "feint", name = "Feint", stat = "meleePct", value = 20, duration = 4, rankScale = false } },
  },
})



ability(4080, "sap", "Sap", "subtlety", "Ability_Sap", 2, {
  cost = 3, shape = { "10", "01" }, tags = { "subtlety", "opener", "control" },
  use = {
    cost = 10, cd = 90, initialDelay = 0.1, once = true, resource = "energy", requires = "melee",
    condition = { "buff:rogue_stealth", "enemyHumanoid" },
    effects = { { type = "stun", duration = 2.5, breakOnDamage = true, controlType = "incapacitate", holdDirect = true, holdWeapons = true, rankScale = false } },
  },
  triggers = { { on = "use", effects = { { type = "resource", resource = "combo", amount = 1 } }, oncePerActivation = true, paidOnly = true } },
  rankable = false, shopRequires = { "stealth" }, shopWeight = 0.75,
})


ability(4081, "improved_sap", "Improved Sap", "subtlety", "Ability_Sap", 2, {
  minRound = 3, shape = S.h2, tags = { "subtlety" },
  triggers = { { on = "anyUse", match = { key = "sap" }, chance = 50, effects = { { type = "buff", key = "rogue_stealth", name = "Improved Sap", stat = "none", value = 0, duration = 3 } } } },
  shopClasses = {}, shopRequires = { "sap" }, shopWeight = 0.6,
})



ability(4082, "improved_sinister_strike", "Improved Sinister Strike", "combat", "Spell_Shadow_RitualOfSacrifice", 1, {
  shape = { "111" }, tags = { "combat" }, adjacency = { { match = { tag = "builder" }, mods = { costPct = -10 }, side = "front" } },
  passiveTriggers = true, shopClasses = {}, shopWeight = 1.2,
})

ability(4083, "improved_backstab", "Improved Backstab", "combat", "Ability_BackStab", 2, {
  shape = { "110", "011" }, tags = { "combat" },
  adjacency = { { match = { damaging = "direct", tag = "strike" }, corners = true, mods = { crit = 15 } } }, passiveTriggers = true, shopClasses = {},
})

ability(4084, "improved_ambush", "Improved Ambush", "subtlety", "Ability_Rogue_Ambush", 2, {
  minRound = 3, shape = { "10", "10", "11" }, tags = { "subtlety" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_ambush", name = "Improved Ambush", target = "all", match = { key = "ambush" }, stat = "crit", value = 20, duration = 8 } },
    },
    {
      on = "anyUse", match = { key = "vanish" },
      effects = { { type = "buff", key = "improved_ambush", name = "Improved Ambush", target = "all", match = { key = "ambush" }, stat = "crit", value = 20, duration = 8 } },
    },
  },
  shopClasses = {}, shopRequires = { "ambush" }, shopWeight = 0.75,
})

ability(4085, "improved_eviscerate", "Improved Eviscerate", "assassination", "Ability_Rogue_Eviscerate", 2, {
  minRound = 3, shape = { "11", "10" }, tags = { "assassination" },
  adjacency = { { match = { damaging = "direct", tag = "finisher" }, mods = { dmgPct = 15 }, side = "back" } }, passiveTriggers = true,
  shopClasses = {},
})



ability(4086, "improved_slice_and_dice", "Improved Slice and Dice", "assassination", "Ability_Rogue_SliceDice", 1, {
  minRound = 2, tags = { "assassination" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        {
          type = "buff", key = "improved_slice_and_dice", name = "Improved Slice and Dice", target = "all", match = { key = "slice_and_dice" },
          stat = "durationPct", value = 15, duration = 120,
        },
      },
    },
  },
  shopRequires = { "slice_and_dice" }, shopWeight = 0.9,
})

ability(4087, "improved_kidney_shot", "Improved Kidney Shot", "assassination", "Ability_Rogue_KidneyShot", 2, {
  cost = 5, minRound = 3, shape = S.T, tags = { "assassination" },
  triggers = {
    {
      on = "enemyStunned", match = { key = "kidney_shot" },
      effects = {
        {
          type = "debuff", key = "improved_kidney_window", name = "Improved Kidney Shot", exclusiveGroup = "kidney_vulnerability", stat = "dr",
          value = 20, duration = 10, controlKey = "kidney_shot",
        },
      },
    },
  },
  shopRequires = { "kidney_shot" }, shopWeight = 0.75,
})

ability(4088, "improved_backstab_classic", "Improved Backstab", "combat", "Ability_BackStab", 2, {
  cost = 4, shape = S.h2, tags = { "combat" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_backstab_classic", name = "Improved Backstab", target = "all", match = { key = "backstab" }, stat = "crit", value = 10, duration = 120 } },
    },
  },
  shopFitRequires = { "dagger" }, shopRequires = { "backstab" }, shopWeight = 0.9,
})

ability(4090, "improved_sprint", "Improved Sprint", "combat", "Ability_Rogue_Sprint", 2, {
  cost = 3, tags = { "combat", "defensive" },
  triggers = { { on = "anyUse", match = { key = "sprint" }, icd = 1, effects = { { type = "cleanse", count = 1, debuffs = true } }, oncePerActivation = true, paidOnly = true } },
  shopRequires = { "sprint" }, shopWeight = 0.8,
})
