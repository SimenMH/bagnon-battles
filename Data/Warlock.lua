local ADDON, ns = ...
local H = ns.H
local S = H.S
local WARLOCK = { "WARLOCK" }
local ability = H.QualityAbilities(WARLOCK)




ability(9001, "corruption", "Corruption", "affliction", "Spell_Shadow_AbominationExplosion", 1, {
  tags = { "affliction", "spell", "shadow", "dot" },
  use = {
    cost = 12, cd = 12, initialDelay = 0, resource = "mana",
    effects = { { type = "dot", key = "corruption", coef = 0.04, tick = 0.5, school = "shadow", duration = 18, preserveTicks = true, rampEvery = 6, rampStacks = 1, stack = true, uncapped = true } },
  },
  shopWeight = 1.6,
})

ability(9002, "curse_of_agony", "Curse of Agony", "affliction", "Spell_Shadow_CurseOfSargeras", 1, {
  tags = { "affliction", "spell", "shadow", "dot", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = {
    cost = 13, cd = 18, initialDelay = 0, resource = "mana",
    effects = {
      { type = "dot", key = "curse_of_agony", coef = 0.025, tick = 0.5, school = "shadow", duration = 24, preserveTicks = true, rampEvery = 3, rampStacks = 1, stack = true, uncapped = true },
    },
  },
  shopWeight = 1.4,
})

ability(9003, "drain_life", "Drain Life", "affliction", "Spell_Shadow_LifeDrain02", 1, {
  tags = { "affliction", "spell", "shadow", "drain", "dot", "channel" },
  use = {
    cost = 18, cd = 7, initialDelay = 1, reactive = true, channel = { key = "drain_life", duration = 5 }, resource = "mana", condition = "injured",
    effects = { { type = "dot", key = "drain_life", coef = 0.125, tick = 1, school = "shadow", duration = 5, preserveTicks = true } },
    rankCosts = { [2] = 24, [3] = 31 },
  },
  triggers = { { on = "dotTick", match = { key = "drain_life" }, effects = { { type = "heal", fixedFraction = true, fromEvent = 1, noCrit = true } } } },
  shopWeight = 1.5,
})

ability(9004, "siphon_life", "Siphon Life", "affliction", "Spell_Shadow_Requiem", 2, {
  tags = { "affliction", "spell", "shadow", "dot", "drain" },
  use = {
    cost = 16, cd = 15, initialDelay = 0, resource = "mana",
    effects = { { type = "dot", key = "siphon_life", coef = 0.025, tick = 0.5, school = "shadow", duration = 21, preserveTicks = true, rampEvery = 9, rampStacks = 1, stack = true, uncapped = true } },
  },
  triggers = { { on = "dotTick", match = { key = "siphon_life" }, effects = { { type = "heal", fixedFraction = true, fromEvent = 1, noCrit = true } } } },
})

ability(9005, "drain_soul", "Drain Soul", "affliction", "Spell_Shadow_Haunting", 2, {
  tags = { "affliction", "spell", "shadow", "drain", "dot", "channel" },
  use = {
    cost = 15, cd = 8, channel = { key = "drain_soul", duration = 6 }, resource = "mana", condition = "enemyBelow50",
    effects = { { type = "dot", key = "drain_soul", coef = 0.2, tick = 1, school = "shadow", duration = 6, preserveTicks = true }, { type = "resource", resource = "mana", amount = 4 } },
    rankCosts = { [2] = 20, [3] = 26 },
  },
})

ability(9006, "drain_mana", "Drain Mana", "affliction", "Spell_Shadow_SiphonMana", 2, {
  tags = { "affliction", "spell", "shadow", "drain", "channel" },
  use = {
    cost = 6, cd = 10, channel = { key = "drain_mana", duration = 4 }, resource = "mana", condition = "enemyMana",
    effects = { { type = "dot", key = "drain_mana", coef = 0.05, tick = 4, school = "shadow", duration = 4, drainResource = "mana", preserveTicks = true, transfer = true } },
    rankCosts = { [2] = 5, [3] = 4 },
  },
})




ability(9007, "improved_corruption", "Improved Corruption", "affliction", "Spell_Shadow_AbominationExplosion", 2, {
  tags = { "affliction", "spell", "shadow" },
  triggers = {
    {
      on = "anyUse", match = { key = "corruption" },
      effects = { { type = "cdr", target = "neighbors", area = { side = "front" }, match = { tag = "drain" }, amount = 1, clampReady = true } },
    },
  },
  shopRequires = { "corruption" }, shopWeight = 0.8,
})

ability(9008, "improved_drain_life", "Improved Drain Life", "affliction", "Spell_Shadow_LifeDrain02", 2, {
  tags = { "affliction", "spell", "shadow" },
  triggers = {
    {
      on = "healed", match = { key = "drain_life" }, everyAmount = 25,
      effects = { { type = "tickDots", target = "neighbors", area = { corners = true }, match = { notTag = "channel", tag = "affliction" } } },
    },
  },
  shopRequires = { "drain_life" }, shopWeight = 0.8,
})

ability(9009, "nightfall", "Nightfall", "affliction", "Spell_Shadow_Twilight", 3, {
  tags = { "affliction", "spell", "shadow" },
  triggers = {
    {
      on = "dotTick", match = { key = "corruption" }, every = 8,
      effects = { { type = "tickDots", match = { notTag = "channel", tag = "affliction" } }, { type = "cast", key = "shadow_bolt", consumeCooldown = true, deferDuringChannel = true } },
    },
  },
})

ability(9010, "amplify_curse", "Amplify Curse", "affliction", "Spell_Shadow_Contagion", 3, {
  tags = { "affliction", "spell", "shadow" },
  use = {
    cost = 12, cd = 20, resource = "mana",
    effects = {
      { type = "buff", key = "amplify_curse", target = "all", match = { key = "curse_of_agony" }, stat = "dmgPct", value = 60, duration = 10, charges = 1 },
      { type = "cdr", target = "all", match = { tag = "curse" }, amount = 6, clampReady = true },
    },
  },
})

ability(9011, "grim_reach", "Grim Reach", "affliction", "Spell_Shadow_CallOfBone", 2, { tags = { "affliction", "spell", "shadow" }, stats = { hp = 25 }, adjacency = { { match = { tag = "affliction" }, mods = { dmgPct = 15 } } }, shopClasses = {} })

ability(9012, "shadow_mastery", "Shadow Mastery", "affliction", "Spell_Shadow_ShadeTrueSight", 4, {
  tags = { "affliction", "spell", "shadow" },
  triggers = {
    {
      on = "dotTick", match = { tag = "shadow" }, every = 4,
      effects = { { type = "buff", key = "shadow_mastery", target = "all", match = { notTag = "channel", tag = "affliction" }, stat = "dmgPct", value = 20, duration = 5 } },
    },
  },
})

ability(9013, "dark_pact", "Dark Pact", "affliction", "Spell_Shadow_DarkRitual", 5, {
  shape = S.one, tags = { "affliction", "spell", "shadow", "mana_recovery" },
  use = {
    cd = 12, initialDelay = 0, reactive = true, requires = "pet", condition = "lowMana",
    effects = { { type = "cdr", target = "neighbors", match = { kind = "pet" }, amount = -4, choose = "first", clampReady = true }, { type = "resource", resource = "mana", amount = 90 } },
    needsNeighbor = { kind = "pet" },
  },
})

ability(9014, "curse_of_exhaustion", "Curse of Exhaustion", "affliction", "Spell_Shadow_GrimWard", 3, {
  tags = { "affliction", "spell", "shadow", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = {
    cost = 12, cd = 12, resource = "mana",
    effects = {
      { type = "debuff", key = "curse_of_exhaustion", stat = "haste", value = 25, duration = 8 },
      { type = "cdr", target = "all", match = { tag = "drain" }, amount = 1.5, clampReady = true },
    },
  },
})

ability(9015, "improved_life_tap", "Improved Life Tap", "affliction", "Spell_Shadow_BurningSpirit", 3, {
  cost = 5, tags = { "affliction", "spell", "shadow" },
  triggers = { { on = "resourceGained", resource = "mana", match = { key = "life_tap" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.25 } } } },
  shopRequires = { "life_tap" },
})

ability(9016, "improved_curse_of_agony", "Improved Curse of Agony", "affliction", "Spell_Shadow_CurseOfSargeras", 4, {
  shape = S.v2, tags = { "affliction", "spell", "shadow" },
  triggers = { { on = "dotTick", match = { key = "curse_of_agony" }, every = 6, effects = { { type = "tickDots", match = { notTag = "channel", tag = "affliction" } } } } },
  shopRequires = { "curse_of_agony" },
})


ability(9020, "summon_imp", "Summon Imp", "demonology", "Spell_Shadow_SummonImp", 1, {
  kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "fire" }, provides = { "warlock_imp" },
  use = { cd = 2, effects = { { type = "damage", coef = 0.4, min = 1, max = 2, school = "fire", pet = true, powerStat = "sp" } } },
  triggers = { { on = "healthSpent", effects = { { type = "cdr", target = "all", match = { key = "summon_imp" }, amount = 1, clampReady = true } } } },
  shopWeight = 1.4,
})

ability(9021, "summon_voidwalker", "Summon Voidwalker", "demonology", "Spell_Shadow_SummonVoidWalker", 2, {
  minRound = 1, kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "physical", "defensive" }, provides = { "warlock_voidwalker" },
  use = { cd = 2.8, effects = { { type = "damage", coef = 0.4, min = 1, max = 2, school = "physical", pet = true, powerStat = "sp" } } },
  triggers = { { on = "hit", effects = { { type = "absorb", fromEvent = 0.4 } } } }, shopWeight = 1.3,
})

ability(9022, "summon_succubus", "Summon Succubus", "demonology", "Spell_Shadow_SummonSuccubus", 2, {
  kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "physical" }, provides = { "warlock_succubus" },
  use = { cd = 2.4, effects = { { type = "damage", coef = 0.4, min = 1, max = 2, school = "physical", critIf = "enemyStunned", pet = true, powerStat = "sp" } } },
  triggers = { { on = "crit", effects = { { type = "cdr", target = "all", match = { tag = "spell" }, amount = 0.5, clampReady = true } } } },
  shopWeight = 1.1,
})

ability(9023, "summon_felhunter", "Summon Felhunter", "demonology", "Spell_Shadow_SummonFelHunter", 3, {
  kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "physical" }, provides = { "warlock_felhunter" },
  use = { cd = 2.6, effects = { { type = "damage", coef = 0.4, min = 1, max = 2, school = "physical", pet = true, powerStat = "sp" } } },
  triggers = { { on = "hit", every = 3, effects = { { type = "drain", resource = "mana", amount = 8, transfer = true } } } }, shopWeight = 1.1,
})

ability(9024, "health_funnel", "Health Funnel", "demonology", "Spell_Shadow_LifeDrain", 1, {
  tags = { "demonology", "spell", "defensive" },
  use = {
    cd = 9, requires = "pet",
    effects = {
      { type = "buff", key = "health_funnel", target = "all", match = { kind = "pet" }, stat = "dmgPct", value = 30, duration = 6 },
      { type = "absorb", coef = 0.25, amount = 2, powerStat = "sp" },
    },
    healthCostPct = 0.03,
  },
})



ability(9025, "improved_imp", "Improved Imp", "demonology", "Spell_Shadow_SummonImp", 2, {
  tags = { "demonology", "spell", "shadow" },
  triggers = {
    { on = "anyHit", match = { key = "summon_imp" }, every = 4, effects = { { type = "tickDots", match = { tag = "fire" } } } },
    {
      on = "adjacentUse", condition = { "provides:pet", "provides:warlock_imp" }, match = { kind = "ability", tag = "fire" }, icd = 1,
      effects = { { type = "cdr", target = "all", match = { key = "summon_imp" }, amount = 0.5, clampReady = true } },
    },
  },
  shopRequires = { "summon_imp" }, shopWeight = 0.85,
})

ability(9026, "demonic_embrace", "Demonic Embrace", "demonology", "Spell_Shadow_Metamorphosis", 1, { tags = { "demonology", "spell", "shadow" }, stats = { hpPct = 10, regen = -1 } })

ability(9027, "fel_intellect", "Fel Intellect", "demonology", "Spell_Holy_MagicalSentry", 2, { tags = { "demonology", "spell", "shadow" }, stats = { mana = 35 }, adjacency = { { match = { kind = "pet" }, mods = { dmgPct = 15 } } }, shopClasses = {} })

ability(9028, "fel_stamina", "Fel Stamina", "demonology", "Spell_Shadow_AntiShadow", 2, { tags = { "demonology", "spell", "shadow" }, triggers = { { on = "healthSpent", effects = { { type = "absorb", fromEvent = 0.35 } } } } })

ability(9029, "unholy_power", "Unholy Power", "demonology", "Spell_Shadow_ShadowWordDominate", 3, {
  tags = { "demonology", "spell", "shadow" },
  triggers = {
    {
      on = "resourceSpent", resource = "mana", icd = 2, everyAmount = 30,
      effects = { { type = "buff", key = "unholy_power", target = "all", match = { kind = "pet" }, stat = "crit", value = 100, duration = 8, charges = 1 } },
    },
  },
})

ability(9030, "master_demonologist", "Master Demonologist", "demonology", "Spell_Shadow_ShadowPact", 4, {
  tags = { "demonology", "spell", "shadow" },
  triggers = {
    {
      on = "anyCrit", match = { kind = "pet" },
      effects = { { type = "buff", key = "master_demonologist", target = "all", match = { tag = "spell" }, stat = "dmgPct", value = 20, duration = 6 } },
      healing = false,
    },
  },
})

ability(9031, "soul_link", "Soul Link", "demonology", "Spell_Shadow_GatherShadows", 5, {
  shape = S.L, tags = { "demonology", "spell", "shadow" },
  use = {
    cost = 20, cd = 18, resource = "mana", requires = "pet",
    effects = {
      { type = "buff", key = "soul_link", stat = "dr", value = 20, duration = 12 },
      { type = "buff", key = "soul_link_pet", target = "all", match = { kind = "pet" }, stat = "dmgPct", value = 20, duration = 12 },
    },
  },
  triggers = { { on = "damaged", condition = "provides:pet", effects = { { type = "cdr", target = "all", match = { kind = "pet" }, amount = 0.15, clampReady = true } } } },
})







ability(9032, "demonic_sacrifice", "Demonic Sacrifice", "demonology", "Spell_Shadow_PsychicScream", 4, {
  cost = 7, tags = { "demonology", "spell", "shadow" },
  use = {
    cd = 3, initialDelay = 3, once = true, requires = "pet",
    effects = {
      { type = "buff", key = "demonic_sacrifice_imp", stat = "dmgPct", value = 30, duration = 120, cond = "provides:warlock_imp", damageSchool = "fire" },
      { type = "buff", key = "demonic_sacrifice_succubus", stat = "dmgPct", value = 20, duration = 120, cond = "provides:warlock_succubus", damageSchool = "shadow" },
      { type = "hot", key = "demonic_sacrifice_voidwalker", coef = 0.05, tick = 1, duration = 120, cond = "provides:warlock_voidwalker", noCrit = true, powerStat = "sp" },
      { type = "buff", key = "demonic_sacrifice_felhunter", stat = "regen", value = 1, duration = 120, cond = "provides:warlock_felhunter", gearCoef = 0.005, gearStat = "mana" },
      { type = "sacrificePet" },
    },
  },
  shopAffinities = { WARLOCK = { affliction = 1, demonology = 0.75, destruction = 1 } },
})



ability(9033, "improved_voidwalker", "Improved Voidwalker", "demonology", "Spell_Shadow_SummonVoidWalker", 3, {
  cost = 5, tags = { "demonology", "spell", "shadow" },
  triggers = { { on = "anyHit", match = { key = "summon_voidwalker" }, effects = { { type = "absorb", fromEvent = 0.3 } } } },
  shopRequires = { "summon_voidwalker" },
})

ability(9034, "master_summoner", "Master Summoner", "demonology", "Spell_Shadow_ImpPhaseShift", 3, {
  tags = { "demonology", "spell", "shadow" },
  triggers = { { on = "healthSpent", condition = "provides:pet", icd = 1, everyAmount = 25, effects = { { type = "cdr", target = "all", match = { kind = "pet" }, amount = 1, clampReady = true } } } },
})

ability(9035, "fel_domination", "Fel Domination", "demonology", "Spell_Nature_RemoveCurse", 4, {
  tags = { "demonology", "spell", "shadow" },
  use = {
    cost = 18, cd = 24, resource = "mana", requires = "pet",
    effects = {
      { type = "cast", target = "all", match = { kind = "pet" } },
      { type = "buff", key = "fel_domination", target = "all", match = { kind = "pet" }, stat = "haste", value = 40, duration = 6 },
      { type = "absorb", coef = 0.3, amount = 15, powerStat = "sp" },
    },
  },
})

ability(9040, "shadow_bolt", "Shadow Bolt", "destruction", "Spell_Shadow_ShadowBolt", 1, {
  tags = { "destruction", "spell", "shadow" },
  use = { cost = 13, cd = 3.5, resource = "mana", effects = { { type = "damage", coef = 0.65, min = 3, max = 5, school = "shadow" } }, rankCosts = { [2] = 17, [3] = 22 } },
  shopWeight = 1.6,
})

ability(9041, "immolate", "Immolate", "destruction", "Spell_Fire_Immolation", 1, {
  tags = { "destruction", "spell", "fire", "dot", "burn" },
  use = {
    cost = 16, cd = 12, resource = "mana",
    effects = { { type = "damage", coef = 0.25, min = 1, max = 3, school = "fire" }, { type = "dot", key = "immolate", coef = 0.1, tick = 1, school = "fire", duration = 12, preserveTicks = true } },
    rankCosts = { [2] = 21, [3] = 27 },
  },
  shopWeight = 1.5,
})

ability(9042, "searing_pain", "Searing Pain", "destruction", "Spell_Fire_SoulBurn", 1, {
  tags = { "destruction", "spell", "fire" },
  use = { cost = 12, cd = 3, resource = "mana", effects = { { type = "damage", coef = 0.55, min = 3, max = 5, school = "fire", critBonus = 10 } }, rankCosts = { [2] = 16, [3] = 20 } },
  shopWeight = 1.3,
})

ability(9043, "shadowburn", "Shadowburn", "destruction", "Spell_Shadow_ScourgeBuild", 3, {
  tags = { "destruction", "spell", "shadow" },
  use = { cost = 18, cd = 10, resource = "mana", effects = { { type = "damage", coef = 0.9, min = 3, max = 5, school = "shadow", scaleMissing = 0.8 } } },
})

ability(9044, "conflagrate", "Conflagrate", "destruction", "Spell_Fire_Fireball", 3, {
  tags = { "destruction", "spell", "fire" },
  use = {
    cost = 18, cd = 10, resource = "mana", condition = "enemyHas:immolate",
    effects = { { type = "damage", coef = 0.75, min = 3, max = 5, school = "fire", consumeDots = { match = { tag = "burn" }, fraction = 0.5 } } },
  },
})



ability(9045, "rain_of_fire", "Rain of Fire", "destruction", "Spell_Shadow_RainOfFire", 2, {
  shape = S.sq, tags = { "destruction", "spell", "fire", "dot", "burn", "channel" },
  use = {
    cost = 25, cd = 14, channel = { key = "rain_of_fire", duration = 6 }, resource = "mana",
    effects = { { type = "dot", key = "rain_of_fire", coef = 0.3, tick = 1, school = "fire", duration = 6, preserveTicks = true } },
  },
})

ability(9046, "hellfire", "Hellfire", "destruction", "Spell_Fire_Incinerate", 2, {
  shape = S.sq, tags = { "destruction", "spell", "fire", "dot", "burn", "channel" },
  use = {
    cost = 15, cd = 12, channel = { key = "hellfire", duration = 6 }, resource = "mana",
    effects = { { type = "dot", key = "hellfire", coef = 0.4, tick = 1, school = "fire", duration = 6, preserveTicks = true } }, healthCostPct = 0.05,
  },
})

ability(9047, "improved_shadow_bolt", "Improved Shadow Bolt", "destruction", "Spell_Shadow_ShadowBolt", 2, {
  tags = { "destruction", "spell", "shadow" },
  triggers = {
    {
      on = "anyCrit", match = { key = "shadow_bolt" },
      effects = { { type = "buff", key = "improved_shadow_bolt", target = "all", match = { tag = "shadow" }, stat = "dmgPct", value = 25, duration = 10, charges = 3 } },
      healing = false,
    },
  },
  shopRequires = { "shadow_bolt" },
})

ability(9048, "bane", "Bane", "destruction", "Spell_Shadow_DeathPact", 2, { tags = { "destruction", "spell", "shadow" }, adjacency = { { match = { damaging = "direct", notTag = "channel", tag = "destruction" }, corners = true, mods = { cdPct = 15 } } } })



ability(9049, "devastation", "Devastation", "destruction", "Spell_Fire_FlameShock", 2, {
  tags = { "destruction", "spell", "shadow" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "devastation", target = "all", match = { damaging = "direct", tag = "destruction" }, stat = "crit", value = 5, duration = 120 } },
    },
  },
})

ability(9050, "ruin", "Ruin", "destruction", "Spell_Shadow_ShadowWordPain", 4, {
  tags = { "destruction", "spell", "shadow" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "destruction" },
      effects = { { type = "damage", school = "shadow", fromEvent = 0.3, noCrit = true, noDodge = true, noOwnTriggers = true } }, healing = false,
    },
  },
})

ability(9051, "emberstorm", "Emberstorm", "destruction", "Spell_Fire_Volcano", 4, {
  tags = { "destruction", "spell", "shadow" },
  triggers = { { on = "dotTick", match = { tag = "fire" }, every = 4, effects = { { type = "cdr", target = "all", match = { key = "conflagrate" }, amount = 1, clampReady = true } } } },
  adjacency = { { match = { anyTag = { "dot" }, tag = "fire" }, corners = true, mods = { dmgPct = 15 } } },
})

ability(9052, "soul_fire", "Soul Fire", "destruction", "Spell_Fire_Fireball02", 5, {
  cost = 9, shape = S.L, tags = { "destruction", "spell", "fire" },
  use = {
    cost = 32, cd = 16, resource = "mana",
    effects = { { type = "damage", coef = 1.5, min = 5, max = 7, school = "fire", bankLabel = "stored health spent", bankScale = 2, spendBank = "warlock_soul_fire" } },
  },
  triggers = { { on = "healthSpent", effects = { { type = "bank", key = "warlock_soul_fire", bankTarget = "Soul Fire", cap = { sp = 1 }, fraction = 1 } }, effective = true } },
})


ability(9053, "improved_immolate", "Improved Immolate", "destruction", "Spell_Fire_Immolation", 3, {
  tags = { "destruction", "spell", "shadow" },
  triggers = {
    {
      on = "anyUse", match = { key = "immolate" },
      effects = {
        {
          type = "buff", key = "improved_immolate", target = "neighbors", area = { side = "front" },
          match = { damaging = "direct", notTag = "dot", tag = "fire" }, stat = "dmgPct", value = 20, duration = 5, charges = 1,
        },
      },
    },
  },
  shopRequires = { "immolate" }, shopWeight = 0.8,
})

ability(9054, "intensity", "Intensity", "destruction", "Spell_Fire_LavaSpawn", 3, {
  tags = { "destruction", "spell", "shadow" },
  triggers = {
    {
      on = "healthSpent",
      effects = {
        { type = "absorb", fromEvent = 0.25 },
        { type = "buff", key = "intensity", target = "all", match = { damaging = "direct", tag = "destruction" }, stat = "crit", value = 15, duration = 8, charges = 1 },
      },
    },
  },
})

ability(9055, "pyroclasm", "Pyroclasm", "destruction", "Spell_Fire_Volcano", 4, {
  shape = S.v2, tags = { "destruction", "spell", "shadow" },
  triggers = { { on = "dotTick", match = { tag = "fire" }, icd = 3, every = 5, effects = { { type = "stun", duration = 0.6 } } } },
})

ability(9060, "life_tap", "Life Tap", "shared", "Spell_Shadow_BurningSpirit", 1, {
  tags = { "spell", "mana_recovery" },
  use = { cd = 7, reactive = true, condition = "lowMana", effects = { { type = "resource", resource = "mana", amount = 35 } }, healthCostPct = 0.05 },
  shopWeight = 1.5,
})

ability(9061, "demon_skin", "Demon Skin", "shared", "Spell_Shadow_RagingScream", 1, {
  kind = "form", tags = { "armor", "defensive" }, stats = { armor = 10 },
  triggers = { { on = "healthSpent", effects = { { type = "hot", key = "demon_skin", coef = 0.025, tick = 1, duration = 6, noCrit = true, powerStat = "sp", preserveTicks = true } } } },
})

ability(9062, "demon_armor", "Demon Armor", "shared", "Spell_Shadow_RagingScream", 2, {
  kind = "form", tags = { "armor", "defensive" }, stats = { armor = 20 },
  triggers = { { on = "healthSpent", effects = { { type = "hot", key = "demon_armor", coef = 0.04, tick = 1, duration = 6, noCrit = true, powerStat = "sp", preserveTicks = true } } } },
})

ability(9063, "fear", "Fear", "shared", "Spell_Shadow_Possession", 2, { tags = { "spell", "shadow", "control" }, use = { cost = 14, cd = 16, resource = "mana", effects = { { type = "stun", duration = 2, controlType = "fear" } } } })

ability(9064, "death_coil", "Death Coil", "shared", "Spell_Shadow_DeathCoil", 3, {
  tags = { "spell", "shadow", "drain", "defensive" },
  use = {
    cost = 20, cd = 18, reactive = true, resource = "mana", condition = "below50",
    effects = { { type = "damage", coef = 0.65, min = 3, max = 5, school = "shadow" }, { type = "stun", duration = 1, controlType = "horror" } },
    interruptChannel = true,
  },
  triggers = { { on = "hit", effects = { { type = "heal", fixedFraction = true, fromEvent = 1, noCrit = true } } } },
})

ability(9070, "healthstone", "Healthstone", "demonology", "INV_Stone_04", 2, {
  tags = { "demonology", "conjured", "heal", "defensive" },
  use = {
    cost = 10, cd = 30, initialDelay = 0, reactive = true, once = true, resource = "mana", condition = "below35",
    effects = { { type = "heal", noCrit = true, pctMax = 0.18 } }, interruptChannel = true,
  },
})

ability(9071, "curse_of_tongues", "Curse of Tongues", "affliction", "Spell_Shadow_CurseOfTounges", 2, {
  tags = { "affliction", "spell", "shadow", "curse", "control" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = {
    cost = 10, cd = 16, initialDelay = 1, resource = "mana",
    effects = { { type = "debuff", key = "curse_of_tongues", target = "all", match = { kind = "ability", tag = "spell" }, stat = "haste", value = 30, duration = 8, rankScale = false } },
    rankCosts = { [2] = 8, [3] = 6 },
  },
})



ability(9080, "curse_of_the_elements", "Curse of the Elements", "affliction", "Spell_Shadow_ChillTouch", 2, {
  shape = S.L, tags = { "affliction", "spell", "shadow", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = { cost = 10, cd = 16, initialDelay = 0, resource = "mana", effects = { { type = "debuff", key = "curse_of_the_elements", stat = "none", value = 0, duration = 12 } } },
  triggers = {
    {
      on = "anyHit", condition = "enemyBuff:curse_of_the_elements", match = { kind = "ability", damaging = "direct", tag = "fire", usable = true },
      icd = 2, effects = { { type = "tickDots", match = { tag = "shadow" } } }, counterKey = "curse_elements_bridge", effective = true,
      oncePerActivation = true, paidOnly = true,
    },
    {
      on = "anyHit", condition = "enemyBuff:curse_of_the_elements", match = { kind = "ability", damaging = "direct", tag = "shadow", usable = true },
      icd = 2, effects = { { type = "tickDots", match = { tag = "burn" } } }, counterKey = "curse_elements_bridge", effective = true,
      oncePerActivation = true, paidOnly = true,
    },
  },
  shopAffinities = { WARLOCK = { affliction = 1, destruction = 1 } }, shopWeight = 0.85,
})

ability(9081, "curse_of_shadow", "Curse of Shadow", "affliction", "Spell_Shadow_CurseOfAchimonde", 2, {
  minRound = 3, shape = S.v3, tags = { "affliction", "spell", "shadow", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = {
    cost = 10, cd = 16, initialDelay = 0, resource = "mana",
    effects = {
      { type = "debuff", key = "curse_shadow_shadow", stat = "dr", value = 10, duration = 12, damageSchool = "shadow" },
      { type = "debuff", key = "curse_shadow_arcane", stat = "dr", value = 10, duration = 12, damageSchool = "arcane" },
    },
  },
  shopAffinities = { WARLOCK = { affliction = 1, destruction = 1 } }, shopWeight = 0.85,
})

ability(9082, "curse_of_recklessness", "Curse of Recklessness", "affliction", "Spell_Shadow_UnholyStrength", 2, {
  shape = S.h2, tags = { "affliction", "spell", "shadow", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = {
    cost = 10, cd = 16, initialDelay = 0, resource = "mana",
    effects = {
      { type = "debuff", key = "curse_reckless_vulnerability", stat = "dr", value = 15, duration = 12 },
      { type = "debuff", key = "curse_reckless_power", stat = "dmgPct", value = -10, duration = 12 },
      { type = "debuff", key = "curse_reckless_fear", stat = "none", value = 0, duration = 12, controlChance = 100, controlTypes = { "fear", "horror" } },
    },
  },
  shopAffinities = { WARLOCK = { affliction = 1, demonology = 1.5 } }, shopWeight = 0.8,
})

ability(9083, "sacrifice_voidwalker", "Sacrifice", "demonology", "Spell_Shadow_SacrificialShield", 3, {
  cost = 7, shape = { "10", "10", "11" }, tags = { "demonology", "spell", "shadow", "defensive", "pet_command" },
  use = {
    cd = 100, initialDelay = 0, reactive = true, once = true, requires = { "pet", "warlock_voidwalker" }, condition = "below35",
    effects = { { type = "sacrificePet" }, { type = "absorb", coef = 3, amount = 4, powerStat = "sp" } }, interruptChannel = true,
  },
  shopWeight = 0.75,
})



ability(9084, "devour_magic", "Devour Magic", "demonology", "Spell_Nature_Purge", 3, {
  cost = 6, minRound = 3, shape = { "11", "10" }, tags = { "demonology", "spell", "shadow", "defensive", "pet_command" },
  triggers = {
    {
      on = "anyHit", condition = { "provides:pet", "provides:warlock_felhunter", "resourceAtLeast:mana:8", "enemyBeneficialBuff" },
      match = { key = "summon_felhunter" }, icd = 8, every = 3,
      effects = { { type = "resource", resource = "mana", amount = -8 }, { type = "purge", count = 1, healAmount = 0, healCoef = 0.4, powerStat = "sp" } },
    },
  },
  shopFitRequires = { "warlock_felhunter" }, shopWeight = 0.75,
})

ability(9085, "lash_of_pain", "Lash of Pain", "demonology", "Spell_Shadow_Curse", 2, {
  shape = { "01", "11" }, tags = { "demonology", "spell", "shadow", "pet_command" },
  triggers = {
    {
      on = "anyHit", condition = { "provides:pet", "provides:warlock_succubus", "resourceAtLeast:mana:6" }, match = { key = "summon_succubus" },
      icd = 6, every = 3,
      effects = {
        { type = "resource", resource = "mana", amount = -6 },
        { type = "damage", coef = 0.75, min = 1, max = 2, school = "shadow", noCrit = true, noDodge = true, noOwnTriggers = true, pet = true },
      },
    },
  },
  shopAffinities = { WARLOCK = { demonology = 1.5, destruction = 1 } }, shopFitRequires = { "warlock_succubus" },
})



ability(9086, "soulstone", "Soulstone", "demonology", "Spell_Shadow_SoulGem", 3, {
  shape = { "010", "111", "010" }, tags = { "demonology", "conjured", "defensive", "soulstone" }, revive = { health = 0.25, mana = 0.2 },
  shopAffinities = { WARLOCK = { affliction = 1, demonology = 1, destruction = 1 } }, shopWeight = 0.65,
})
