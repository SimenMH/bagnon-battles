local ADDON, ns = ...
local H = ns.H
local S = H.S
local WARLOCK = { "WARLOCK" }
local ability = H.QualityAbilities(WARLOCK, "shadow")
local damage = H.Damage

ability(9001, "corruption", "Corruption", "affliction", "Spell_Shadow_AbominationExplosion", 1, { tags = { "affliction", "spell", "shadow", "dot" },
  use = { initialDelay = 0, cd = 12, cost = 12, resource = "mana", effects = { { type = "dot", key = "corruption", school = "shadow", tick = 1, coef = 0.04, stack = true, uncapped = true, rampStacks = 1, rampEvery = 6, duration = 18, preserveTicks = true } } } })
ability(9002, "curse_of_agony", "Curse of Agony", "affliction", "Spell_Shadow_CurseOfSargeras", 1, { tags = { "affliction", "spell", "shadow", "dot", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = { initialDelay = 0, cd = 18, cost = 13, resource = "mana", effects = { { type = "dot", key = "curse_of_agony", school = "shadow", tick = 1, coef = 0.01, stack = true, uncapped = true, rampStacks = 1, rampEvery = 3, duration = 24, preserveTicks = true } } } })
ability(9003, "drain_life", "Drain Life", "affliction", "Spell_Shadow_LifeDrain02", 1, { tags = { "affliction", "spell", "shadow", "drain", "dot", "channel" },
  use = { reactive = true, initialDelay = 1, condition = "injured", cd = 7, channel = { duration = 5, key = "drain_life" }, cost = 18, rankCosts = { [2] = 24, [3] = 31 }, resource = "mana", effects = { { type = "dot", key = "drain_life", school = "shadow", tick = 3, coef = 0.08, duration = 5, preserveTicks = true } } },
  triggers = { { on = "dotTick", match = { key = "drain_life" }, effects = { { type = "heal", fromEvent = 1.0, fixedFraction = true, noCrit = true } } } } })
ability(9004, "siphon_life", "Siphon Life", "affliction", "Spell_Shadow_Requiem", 2, { tags = { "affliction", "spell", "shadow", "dot", "drain" },
  use = { initialDelay = 0, cd = 15, cost = 16, resource = "mana", effects = { { type = "dot", key = "siphon_life", school = "shadow", tick = 1, rankTicks = { [2] = 2, [3] = 3 }, coef = 0.02, stack = true, uncapped = true, rampStacks = 1, rampEvery = 9, duration = 21, preserveTicks = true } } },
  triggers = { { on = "dotTick", match = { key = "siphon_life" }, effects = { { type = "heal", fromEvent = 1.0, fixedFraction = true, noCrit = true } } } } })
ability(9005, "drain_soul", "Drain Soul", "affliction", "Spell_Shadow_Haunting", 2, { tags = { "affliction", "spell", "shadow", "drain", "dot", "channel" },
  use = { condition = "enemyBelow50", cd = 8, channel = { duration = 6, key = "drain_soul" }, cost = 15, rankCosts = { [2] = 20, [3] = 26 }, resource = "mana", effects = { { type = "dot", key = "drain_soul", school = "shadow", tick = 2, coef = 0.06, duration = 6, preserveTicks = true }, { type = "resource", resource = "mana", amount = 4 } } } })
ability(9006, "drain_mana", "Drain Mana", "affliction", "Spell_Shadow_SiphonMana", 2, { tags = { "affliction", "spell", "shadow", "drain" },
  use = { cd = 10, cost = 6, rankCosts = { [2] = 5, [3] = 4 }, resource = "mana", effects = { { type = "drain", resource = "mana", amount = 18, transfer = true } } } })
ability(9007, "improved_corruption", "Improved Corruption", "affliction", "Spell_Shadow_AbominationExplosion", 2, { shopRequires = { "corruption" },
  adjacency = { { match = { key = "corruption" }, mods = { dmgPct = 20, cdPct = 20 } } },
  triggers = { { on = "anyUse", match = { key = "corruption" }, effects = { { type = "cdr", target = "all", match = { tag = "drain" }, amount = 1, clampReady = true } } } } })
ability(9008, "improved_drain_life", "Improved Drain Life", "affliction", "Spell_Shadow_LifeDrain02", 2, { shopRequires = { "drain_life" },
  adjacency = { { match = { key = "drain_life" }, mods = { dmgPct = 25 } } },
  triggers = { { on = "healed", match = { key = "drain_life" }, everyAmount = 25, effects = { { type = "tickDots", match = { tag = "affliction", notTag = "channel" } } } } } })
ability(9009, "nightfall", "Nightfall", "affliction", "Spell_Shadow_Twilight", 3, {
  triggers = { { on = "dotTick", match = { key = "corruption" }, every = 8, effects = { { type = "tickDots", match = { tag = "affliction", notTag = "channel" } }, { type = "cast", key = "shadow_bolt", deferDuringChannel = true, consumeCooldown = true } } } } })
ability(9010, "amplify_curse", "Amplify Curse", "affliction", "Spell_Shadow_Contagion", 3, {
  use = { cd = 20, cost = 12, resource = "mana", effects = { { type = "buff", key = "amplify_curse", stat = "dmgPct", value = 60, charges = 1, duration = 10, target = "all", match = { tag = "curse" } }, { type = "cdr", target = "all", match = { tag = "curse" }, amount = 6, clampReady = true } } } })
ability(9011, "grim_reach", "Grim Reach", "affliction", "Spell_Shadow_CallOfBone", 2, { shopClasses = {},
  adjacency = { { match = { tag = "affliction" }, mods = { dmgPct = 15 } } }, stats = { hp = 25 } })
ability(9012, "shadow_mastery", "Shadow Mastery", "affliction", "Spell_Shadow_ShadeTrueSight", 4, {
  triggers = { { on = "dotTick", match = { tag = "shadow" }, every = 4, effects = { { type = "buff", key = "shadow_mastery", stat = "dmgPct", value = 20, duration = 5, target = "all", match = { tag = "affliction", notTag = "channel" } } } } } })
ability(9013, "dark_pact", "Dark Pact", "affliction", "Spell_Shadow_DarkRitual", 5, {
  triggers = { { on = "anyHit", match = { kind = "pet" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.25 } } } },
  adjacency = { { match = { kind = "pet" }, mods = { haste = 20 } } } })
ability(9014, "curse_of_exhaustion", "Curse of Exhaustion", "affliction", "Spell_Shadow_GrimWard", 3, { tags = { "affliction", "spell", "shadow", "curse" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = { cd = 12, cost = 12, resource = "mana", effects = { { type = "debuff", key = "curse_of_exhaustion", stat = "haste", value = 25, duration = 8 }, { type = "cdr", target = "all", match = { tag = "drain" }, amount = 1.5, clampReady = true } } } })

ability(9020, "summon_imp", "Summon Imp", "demonology", "Spell_Shadow_SummonImp", 1, { kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "fire" },
  use = { cd = 2, effects = { damage(4, 7, 0.32, "fire", { pet = true }) } },
  triggers = { { on = "healthSpent", effects = { { type = "cdr", target = "all", match = { key = "summon_imp" }, amount = 1, clampReady = true } } } } })
ability(9021, "summon_voidwalker", "Summon Voidwalker", "demonology", "Spell_Shadow_SummonVoidWalker", 2, { kind = "pet", minRound = 1, shape = S.sq, tags = { "demonology", "pet", "autoattack", "shadow", "defensive" },
  use = { cd = 2.8, effects = { damage(4, 7, 0.28, "physical", { pet = true, powerStat = "sp" }) } },
  triggers = { { on = "hit", effects = { { type = "absorb", fromEvent = 0.4 } } } } })
ability(9022, "summon_succubus", "Summon Succubus", "demonology", "Spell_Shadow_SummonSuccubus", 2, { kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "shadow" },
  use = { cd = 2.4, effects = { damage(5, 8, 0.35, "shadow", { pet = true, critIf = "enemyStunned" }) } },
  triggers = { { on = "crit", effects = { { type = "cdr", target = "all", match = { tag = "spell" }, amount = 0.5, clampReady = true } } } } })
ability(9023, "summon_felhunter", "Summon Felhunter", "demonology", "Spell_Shadow_SummonFelHunter", 3, { kind = "pet", shape = S.sq, tags = { "demonology", "pet", "autoattack", "shadow" },
  use = { cd = 2.6, effects = { damage(6, 9, 0.35, "shadow", { pet = true }) } },
  triggers = { { on = "hit", every = 3, effects = { { type = "purge", count = 1 }, { type = "drain", resource = "mana", amount = 8, transfer = true } } } } })
ability(9024, "health_funnel", "Health Funnel", "demonology", "Spell_Shadow_LifeDrain", 1, { tags = { "demonology", "spell", "defensive" },
  use = { cd = 9, healthCostPct = 0.03, requires = "pet", effects = { { type = "buff", key = "health_funnel", stat = "dmgPct", value = 30, duration = 6, target = "all", match = { kind = "pet" } }, { type = "absorb", amount = 12, coef = 0.2 } } } })
ability(9025, "improved_imp", "Improved Imp", "demonology", "Spell_Shadow_SummonImp", 2, { shopRequires = { "summon_imp" },
  adjacency = { { match = { key = "summon_imp" }, mods = { dmgPct = 30 } } },
  triggers = { { on = "anyHit", match = { key = "summon_imp" }, every = 4, effects = { { type = "tickDots", match = { tag = "fire" } } } } } })
ability(9026, "demonic_embrace", "Demonic Embrace", "demonology", "Spell_Shadow_Metamorphosis", 1, { stats = { hp = 25, hpPct = 12, armor = 10 } })
ability(9027, "fel_intellect", "Fel Intellect", "demonology", "Spell_Holy_MagicalSentry", 2, { shopClasses = {}, stats = { mana = 35 },
  adjacency = { { match = { kind = "pet" }, mods = { dmgPct = 15 } } } })
ability(9028, "fel_stamina", "Fel Stamina", "demonology", "Spell_Shadow_AntiShadow", 2, { stats = { hp = 35 },
  triggers = { { on = "healthSpent", effects = { { type = "absorb", fromEvent = 0.35 } } } } })
ability(9029, "unholy_power", "Unholy Power", "demonology", "Spell_Shadow_ShadowWordDominate", 3, {
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 30, effects = { { type = "buff", key = "unholy_power", stat = "crit", value = 100, charges = 1, duration = 8, target = "all", match = { kind = "pet" } } } } } })
ability(9030, "master_demonologist", "Master Demonologist", "demonology", "Spell_Shadow_ShadowPact", 4, {
  triggers = { { on = "anyCrit", healing = false, match = { kind = "pet" }, effects = { { type = "buff", key = "master_demonologist", stat = "dmgPct", value = 25, duration = 6, target = "all", match = { tag = "spell" } } } } } })
ability(9031, "soul_link", "Soul Link", "demonology", "Spell_Shadow_GatherShadows", 5, { shape = S.L,
  use = { cd = 18, cost = 20, resource = "mana", requires = "pet", effects = { { type = "buff", key = "soul_link", stat = "dr", value = 20, duration = 12 }, { type = "buff", key = "soul_link_pet", stat = "dmgPct", value = 25, duration = 12, target = "all", match = { kind = "pet" } } } },
  triggers = { { on = "damaged", condition = "provides:pet", effects = { { type = "cdr", target = "all", match = { kind = "pet" }, amount = 0.15, clampReady = true } } } } })
ability(9032, "demonic_sacrifice", "Demonic Sacrifice", "demonology", "Spell_Shadow_PsychicScream", 4, {
  use = { once = true, cd = 3, initialDelay = 3, requires = "pet", effects = { { type = "sacrificePet" }, { type = "buff", key = "demonic_sacrifice", stat = "spellPct", value = 25, duration = 120 }, { type = "buff", key = "demonic_sacrifice_regen", stat = "regen", value = 3, duration = 120 } } } })

ability(9040, "shadow_bolt", "Shadow Bolt", "destruction", "Spell_Shadow_ShadowBolt", 1, { cost = 3,
  use = { cd = 3.5, cost = 13, rankCosts = { [2] = 17, [3] = 22 }, resource = "mana", effects = { damage(8, 12, 0.45, "shadow") } } })
ability(9041, "immolate", "Immolate", "destruction", "Spell_Fire_Immolation", 1, { tags = { "destruction", "spell", "fire", "dot", "burn" },
  use = { cd = 12, cost = 16, rankCosts = { [2] = 21, [3] = 27 }, resource = "mana", effects = { damage(7, 10, 0.22, "fire"), { type = "dot", key = "immolate", school = "fire", tick = 3, coef = 0.1, duration = 12, preserveTicks = true } } } })
ability(9042, "searing_pain", "Searing Pain", "destruction", "Spell_Fire_SoulBurn", 1, { tags = { "destruction", "spell", "fire" },
  use = { cd = 3, cost = 12, rankCosts = { [2] = 16, [3] = 20 }, resource = "mana", effects = { damage(7, 11, 0.35, "fire", { critBonus = 10 }) } } })
ability(9043, "shadowburn", "Shadowburn", "destruction", "Spell_Shadow_ScourgeBuild", 3, {
  use = { cd = 10, cost = 18, resource = "mana", effects = { damage(20, 28, 0.6, "shadow", { scaleMissing = 0.8 }) } } })
ability(9044, "conflagrate", "Conflagrate", "destruction", "Spell_Fire_Fireball", 3, { tags = { "destruction", "spell", "fire" },
  use = { cd = 10, cost = 18, resource = "mana", condition = "enemyHas:immolate", effects = { damage(18, 25, 0.5, "fire", { consumeDots = { match = { tag = "burn" }, fraction = 0.5 } }) } } })
ability(9045, "rain_of_fire", "Rain of Fire", "destruction", "Spell_Shadow_RainOfFire", 2, { tags = { "destruction", "spell", "fire", "dot", "burn" }, shape = S.sq,
  use = { cd = 14, cost = 25, resource = "mana", effects = { { type = "dot", key = "rain_of_fire", school = "fire", tick = 5, coef = 0.16, duration = 6 } } } })
ability(9046, "hellfire", "Hellfire", "destruction", "Spell_Fire_Incinerate", 2, { tags = { "destruction", "spell", "fire", "dot", "burn" }, shape = S.sq,
  use = { cd = 12, cost = 15, resource = "mana", healthCostPct = 0.05, effects = { { type = "dot", key = "hellfire", school = "fire", tick = 6, coef = 0.18, duration = 6 } } } })
ability(9047, "improved_shadow_bolt", "Improved Shadow Bolt", "destruction", "Spell_Shadow_ShadowBolt", 2, { shopRequires = { "shadow_bolt" },
  triggers = { { on = "anyCrit", healing = false, match = { key = "shadow_bolt" }, effects = { { type = "buff", key = "improved_shadow_bolt", stat = "dmgPct", value = 25, charges = 3, duration = 10, target = "all", match = { tag = "shadow" } } } } } })
ability(9048, "bane", "Bane", "destruction", "Spell_Shadow_DeathPact", 2, {
  adjacency = { { match = { tag = "destruction" }, mods = { cdPct = 15 } } } })
ability(9049, "devastation", "Devastation", "destruction", "Spell_Fire_FlameShock", 2, {
  adjacency = { { match = { tag = "destruction" }, mods = { crit = 10 } } } })
ability(9050, "ruin", "Ruin", "destruction", "Spell_Shadow_ShadowWordPain", 4, {
  triggers = { { on = "anyCrit", healing = false, match = { tag = "destruction" }, effects = { { type = "damage", school = "shadow", fromEvent = 0.4, noCrit = true, noDodge = true, noOwnTriggers = true } } } } })
ability(9051, "emberstorm", "Emberstorm", "destruction", "Spell_Fire_Volcano", 4, {
  triggers = { { on = "dotTick", match = { tag = "fire" }, every = 4, effects = { { type = "cdr", target = "all", match = { key = "conflagrate" }, amount = 1, clampReady = true } } } },
  adjacency = { { match = { tag = "fire" }, mods = { dmgPct = 15 } } } })
ability(9052, "soul_fire", "Soul Fire", "destruction", "Spell_Fire_Fireball02", 5, { tags = { "destruction", "spell", "fire" }, shape = S.L,
  use = { cd = 16, cost = 32, resource = "mana", effects = { damage(40, 55, 1.0, "fire", { consumeDots = { match = { tag = "fire" }, fraction = 0.35 } }) } } })

ability(9060, "life_tap", "Life Tap", "shared", "Spell_Shadow_BurningSpirit", 1, { tags = { "spell", "mana_recovery" },
  use = { reactive = true, condition = "lowMana", cd = 7, healthCostPct = 0.05, effects = { { type = "resource", resource = "mana", amount = 35 } } } })
ability(9061, "demon_skin", "Demon Skin", "shared", "Spell_Shadow_RagingScream", 1, { kind = "form", tags = { "armor", "defensive" }, stats = { armor = 18, healing = 8 },
  triggers = { { on = "healthSpent", effects = { { type = "hot", key = "demon_skin", tick = 1, coef = 0.06, duration = 6, preserveTicks = true } } } } })
ability(9062, "demon_armor", "Demon Armor", "shared", "Spell_Shadow_RagingScream", 2, { kind = "form", tags = { "armor", "defensive" }, stats = { armor = 35, hp = 30, healing = 12 },
  triggers = { { on = "healthSpent", effects = { { type = "hot", key = "demon_armor", tick = 2, coef = 0.08, duration = 6, preserveTicks = true } } } } })
ability(9063, "fear", "Fear", "shared", "Spell_Shadow_Possession", 2, { tags = { "spell", "shadow", "control" },
  use = { cd = 16, cost = 14, resource = "mana", effects = { { type = "stun", controlType = "fear", duration = 2 } } } })
ability(9064, "death_coil", "Death Coil", "shared", "Spell_Shadow_DeathCoil", 3, { tags = { "spell", "shadow", "drain", "defensive" },
  use = { reactive = true, interruptChannel = true, condition = "below50", cd = 18, cost = 20, resource = "mana", effects = { damage(15, 22, 0.5, "shadow"), { type = "stun", controlType = "horror", duration = 1 } } },
  triggers = { { on = "hit", effects = { { type = "heal", fromEvent = 1.0, noCrit = true } } } } })

ability(9015, "improved_life_tap", "Improved Life Tap", "affliction", "Spell_Shadow_BurningSpirit", 3, { shopRequires = { "life_tap" },
  triggers = { { on = "healthSpent", match = { key = "life_tap" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.2 }, { type = "absorb", fromEvent = 0.2 } } } } })
ability(9016, "improved_curse_of_agony", "Improved Curse of Agony", "affliction", "Spell_Shadow_CurseOfSargeras", 4, { shape = S.v2, shopRequires = { "curse_of_agony" },
  triggers = { { on = "dotTick", match = { key = "curse_of_agony" }, every = 6, effects = { { type = "tickDots", match = { tag = "affliction", notTag = "channel" } } } } } })
ability(9033, "improved_voidwalker", "Improved Voidwalker", "demonology", "Spell_Shadow_SummonVoidWalker", 3, { shopRequires = { "summon_voidwalker" },
  triggers = { { on = "anyHit", match = { key = "summon_voidwalker" }, effects = { { type = "absorb", amount = 4, coef = 0.25 }, { type = "resource", resource = "mana", fromEvent = 0.5 } } } } })
ability(9034, "master_summoner", "Master Summoner", "demonology", "Spell_Shadow_ImpPhaseShift", 3, { stats = { sp = 8 },
  triggers = { { on = "healthSpent", everyAmount = 25, condition = "provides:pet", effects = { { type = "cdr", target = "all", match = { kind = "pet" }, amount = 1, clampReady = true } } } } })
ability(9035, "fel_domination", "Fel Domination", "demonology", "Spell_Nature_RemoveCurse", 4, { shape = S.v2,
  use = { cd = 24, cost = 18, resource = "mana", requires = "pet", effects = { { type = "cast", target = "all", match = { kind = "pet" } }, { type = "buff", key = "fel_domination", stat = "haste", value = 40, duration = 6, target = "all", match = { kind = "pet" } }, { type = "absorb", amount = 15, coef = 0.3 } } } })
ability(9053, "improved_immolate", "Improved Immolate", "destruction", "Spell_Fire_Immolation", 3, { shopRequires = { "immolate" },
  adjacency = { { match = { key = "immolate" }, mods = { dmgPct = 20 } } },
  triggers = { { on = "anyUse", match = { key = "immolate" }, effects = { { type = "buff", key = "improved_immolate", stat = "dmgPct", value = 20, charges = 1, duration = 5, target = "all", match = { tag = "fire", damaging = "direct" } } } } } })
ability(9054, "intensity", "Intensity", "destruction", "Spell_Fire_LavaSpawn", 3, {
  triggers = { { on = "healthSpent", effects = { { type = "absorb", fromEvent = 0.25 }, { type = "buff", key = "intensity", stat = "crit", value = 15, charges = 1, duration = 8, target = "all", match = { tag = "destruction", damaging = "direct" } } } } } })
ability(9055, "pyroclasm", "Pyroclasm", "destruction", "Spell_Fire_Volcano", 4, { shape = S.v2,
  triggers = { { on = "dotTick", match = { tag = "fire" }, every = 5, icd = 3, effects = { { type = "stun", duration = 0.6 } } } } })

ability(9070, "healthstone", "Healthstone", "demonology", "INV_Stone_04", 2, { tags = { "demonology", "conjured", "heal", "defensive" },
  use = { once = true, reactive = true, interruptChannel = true, initialDelay = 0, condition = "below35", cd = 30, cost = 10, resource = "mana", effects = { { type = "heal", pctMax = 0.18, noCrit = true } } } })
ability(9071, "curse_of_tongues", "Curse of Tongues", "affliction", "Spell_Shadow_CurseOfTounges", 2, { tags = { "affliction", "spell", "shadow", "curse", "control" }, exclusiveGroup = "warlock_curse", exclusiveLabel = "Curse",
  use = { initialDelay = 1, cd = 16, cost = 10, rankCosts = { [2] = 8, [3] = 6 }, resource = "mana", effects = {
    { type = "debuff", key = "curse_of_tongues", stat = "haste", value = 30, duration = 8, target = "all", match = { kind = "ability", tag = "spell" }, rankScale = false },
  } } })
