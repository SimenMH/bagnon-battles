local ADDON, ns = ...
local H = ns.H
local S = H.S
local ROGUE = { "ROGUE" }

local ability = H.RoundAbilities(ROGUE)

ability(4000, "sinister_strike", "Sinister Strike", "combat", "Spell_Shadow_RitualOfSacrifice", 1, 1, {
  tags = { "combat", "melee", "strike", "builder" },
  use = { cd = 3, cost = 35, resource = "energy", requires = "melee", effects = { { type = "damage", weapon = true, min = 5, max = 8, coef = 0.22, school = "physical" }, { type = "resource", resource = "combo", amount = 1 } } } })
ability(4001, "eviscerate", "Eviscerate", "assassination", "Ability_Rogue_Eviscerate", 1, 1, {
  tags = { "assassination", "melee", "finisher" },
  use = { cd = 7, initialDelay = 0.1, cost = 3, spendAll = true, resource = "combo", requires = "melee", effects = { { type = "damage", min = 8, max = 12, perPoint = 8, coef = 0.45, school = "physical", consumeDots = { match = { tag = "poison" }, fraction = 0.25 } } } } })
ability(4002, "rupture", "Rupture", "assassination", "Ability_Rogue_Rupture", 1, 1, {
  tags = { "assassination", "melee", "finisher", "bleed", "dot" },
  use = { cd = 10, initialDelay = 0.1, cost = 3, spendAll = true, resource = "combo", requires = "melee", effects = { { type = "dot", key = "rupture", tick = 2, coef = 0.05, school = "physical", duration = 12, rolling = true, perCombo = 0.5 } } } })
ability(4003, "slice_and_dice", "Slice and Dice", "assassination", "Ability_Rogue_SliceDice", 2, 2, {
  tags = { "assassination", "finisher" },
  use = { cd = 10, initialDelay = 0.1, cost = 2, spendAll = true, resource = "combo", effects = { { type = "buff", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 35, duration = 8, key = "slice_and_dice", name = "Slice and Dice" } } } })
ability(4004, "kidney_shot", "Kidney Shot", "assassination", "Ability_Rogue_KidneyShot", 2, 3, {
  tags = { "assassination", "finisher", "control" },
  use = { cd = 15, initialDelay = 0.1, cost = 3, spendAll = true, resource = "combo", requires = "melee", effects = { { type = "stun", duration = 2, rankScale = false }, { type = "buff", target = "all", match = { tag = "builder" }, stat = "crit", value = 30, charges = 1, duration = 5, key = "kidney_opening", name = "Kidney Shot" } } } })
ability(4005, "instant_poison", "Instant Poison", "assassination", "Ability_Poisons", 1, 1, {
  tags = { "assassination", "poison", "nature" }, rankable = true,
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 35, effects = { { type = "damage", min = 4, max = 6, coef = 0.16, powerStat = "ap", school = "nature", noDodge = true } } } } })
ability(4006, "deadly_poison", "Deadly Poison", "assassination", "Ability_Rogue_DualWeild", 1, 1, {
  tags = { "assassination", "poison", "nature", "dot" }, rankable = false,
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 45, effects = { { type = "dot", key = "deadly_poison", tick = 1, coef = 0.02, powerStat = "ap", school = "nature", duration = 12, stack = true, uncapped = true, preserveTicks = true } } } } })
ability(4007, "wound_poison", "Wound Poison", "assassination", "INV_Misc_Herb_16", 2, 3, {
  tags = { "assassination", "poison", "nature" },
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 35, effects = { { type = "damage", min = 3, max = 5, coef = 0.1, powerStat = "ap", school = "nature", noDodge = true }, { type = "debuff", stat = "healPct", value = 15, duration = 8, stack = true, maxStacks = 3, key = "wound_poison", name = "Wound Poison" } } } } })
ability(4008, "crippling_poison", "Crippling Poison", "assassination", "Ability_PoisonSting", 2, 2, {
  tags = { "assassination", "poison", "nature", "control" },
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 30, effects = { { type = "debuff", stat = "haste", value = 18, duration = 5, key = "crippling_poison", name = "Crippling Poison" }, { type = "cdr", target = "all", match = { tag = "finisher" }, amount = 0.5, clampReady = true } } } } })
ability(4009, "cold_blood", "Cold Blood", "assassination", "Spell_Ice_Lament", 4, 7, {
  use = { cd = 18, initialDelay = 1, effects = { { type = "buff", target = "all", match = { tag = "finisher" }, stat = "crit", value = 100, charges = 1, duration = 8, key = "cold_blood", name = "Cold Blood" } } } })
ability(4010, "seal_fate", "Seal Fate", "assassination", "Spell_Shadow_ChillTouch", 3, 4, {
  triggers = { { on = "anyCrit", healing = false, match = { tag = "builder" }, oncePerActivation = true, effects = { { type = "resource", resource = "combo", amount = 1 } } } } })
ability(4011, "relentless_strikes", "Relentless Strikes", "assassination", "Ability_Warrior_DecisiveStrike", 2, 2, {
  triggers = { { on = "resourceSpent", resource = "combo", effects = { { type = "resource", resource = "energy", fromEvent = 5 } } } } })
ability(4012, "ruthlessness", "Ruthlessness", "assassination", "Ability_Druid_Disembowel", 2, 2, {
  triggers = { { on = "anyUse", match = { tag = "finisher" }, chance = 60, effects = { { type = "resource", resource = "combo", amount = 1 } } } } })
ability(4013, "malice", "Malice", "assassination", "Ability_Racial_BloodRage", 1, 1, { stats = { crit = 6 }, shopClasses = {} })
ability(4014, "lethality", "Lethality", "assassination", "Ability_CriticalStrike", 3, 4, {
  adjacency = { { match = { tag = "builder" }, mods = { dmgPct = 18 } } },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "tickDots", match = { tag = "poison" } } } } } })
ability(4015, "improved_poisons", "Improved Poisons", "assassination", "Ability_Poisons", 3, 4, {
  shopRequires = { "deadly_poison" },
  triggers = { { on = "dotTick", match = { tag = "poison" }, every = 3, effects = { { type = "resource", resource = "energy", amount = 5 } } } } })
ability(4016, "vile_poisons", "Vile Poisons", "assassination", "Ability_Rogue_FeignDeath", 4, 7, {
  adjacency = { { match = { tag = "poison" }, mods = { dmgPct = 35 } } },
  triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "tickDots", match = { tag = "poison" } } } } } })
ability(4017, "backstab", "Backstab", "combat", "Ability_BackStab", 2, 2, {
  tags = { "combat", "melee", "strike", "builder" },
  use = { cd = 5, cost = 50, resource = "energy", requires = "melee", effects = { { type = "damage", weapon = true, weaponPct = 1.6, min = 6, max = 10, coef = 0.32, school = "physical", critIf = "enemyStunned" }, { type = "resource", resource = "combo", amount = 1 } } } })
ability(4018, "gouge", "Gouge", "combat", "Ability_Gouge", 1, 1, {
  tags = { "combat", "melee", "builder", "control" },
  use = { cd = 12, cost = 20, resource = "energy", requires = "melee", effects = { { type = "damage", min = 2, max = 4, coef = 0.08, school = "physical" }, { type = "stun", duration = 1.2, rankScale = false }, { type = "resource", resource = "combo", amount = 1 } } } })
ability(4019, "riposte", "Riposte", "combat", "Ability_Warrior_Challange", 2, 3, {
  tags = { "combat", "melee", "strike", "builder" }, stats = { dodge = 5 },
  triggers = { { on = "dodged", effects = { { type = "buff", stat = "none", value = 0, duration = 4, key = "rogue_riposte", name = "Riposte" } } }, { on = "damaged", chance = 20, icd = 5, effects = { { type = "buff", stat = "none", value = 0, duration = 4, key = "rogue_riposte", name = "Riposte" } } } },
  use = { cd = 6, cost = 10, resource = "energy", requires = "melee", condition = "buff:rogue_riposte", effects = { { type = "damage", weapon = true, weaponPct = 1.5, min = 4, max = 7, coef = 0.25, school = "physical" }, { type = "resource", resource = "combo", amount = 1 }, { type = "debuff", stat = "meleePct", value = 15, duration = 4, key = "riposte_disarm", name = "Riposte" } } } })
ability(4020, "blade_flurry", "Blade Flurry", "combat", "Ability_Warrior_PunishingBlow", 4, 7, {
  use = { cd = 22, cost = 20, resource = "energy", effects = { { type = "buff", target = "all", match = { tag = "melee" }, stat = "haste", value = 25, duration = 7, key = "blade_flurry_haste", name = "Blade Flurry" }, { type = "buff", stat = "none", value = 0, double = { tag = "builder" }, duration = 7, key = "blade_flurry", name = "Blade Flurry" } } } })
ability(4021, "adrenaline_rush", "Adrenaline Rush", "combat", "Spell_Shadow_ShadowWordDominate", 5, 9, {
  shape = S.L, use = { cd = 24, initialDelay = 2, effects = { { type = "resource", resource = "energy", amount = 70 }, { type = "buff", target = "all", match = { tag = "builder" }, stat = "haste", value = 40, duration = 6, key = "adrenaline_rush", name = "Adrenaline Rush" } } } })
ability(4022, "dual_wield_specialization_rogue", "Dual Wield Specialization", "combat", "Ability_DualWield", 2, 2, {
  triggers = { { on = "regularHit", match = { tag = "melee" }, condition = "dualwield", every = 3, effects = { { type = "resource", resource = "energy", amount = 7 } } } } })
ability(4023, "sword_specialization_rogue", "Sword Specialization", "combat", "INV_Sword_27", 3, 5, {
  triggers = { { on = "anyHit", match = { weaponType = "sword" }, chance = 8, effects = { { type = "extraAttack" } } } } })
ability(4024, "dagger_specialization", "Dagger Specialization", "combat", "INV_Weapon_ShortBlade_05", 2, 2, {
  adjacency = { { match = { weaponType = "dagger" }, mods = { crit = 12 } } },
  triggers = { { on = "anyCrit", healing = false, match = { weaponType = "dagger" }, effects = { { type = "cdr", target = "all", match = { tag = "builder" }, amount = 0.5, clampReady = true } } } } })
ability(4025, "precision", "Precision", "combat", "Ability_Marksmanship", 1, 1, { stats = { ap = 12 }, adjacency = { { match = { tag = "melee" }, mods = { dmgPct = 10 } } } })
ability(4026, "aggression", "Aggression", "combat", "Ability_Racial_Avatar", 3, 4, {
  triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 50, effects = { { type = "cdr", target = "all", match = { tag = "autoattack" }, amount = 1, clampReady = true } } } } })
ability(4027, "lightning_reflexes_rogue", "Lightning Reflexes", "combat", "Spell_Nature_Invisibilty", 1, 1, { stats = { dodge = 7 }, shopClasses = {} })
ability(4028, "stealth", "Stealth", "subtlety", "Ability_Stealth", 1, 1, {
  shape = S.one, triggers = { { on = "battleStart", effects = { { type = "buff", stat = "none", value = 0, duration = 8, key = "rogue_stealth", name = "Stealth" }, { type = "buff", target = "all", match = { tag = "opener" }, stat = "crit", value = 20, duration = 8, key = "stealth_opening", name = "Stealth" } } } } })
ability(4029, "ambush", "Ambush", "subtlety", "Ability_Rogue_Ambush", 2, 2, {
  tags = { "subtlety", "melee", "strike", "builder", "opener" }, shopRequires = { "stealth" },
  use = { cd = 12, initialDelay = 0.5, cost = 55, resource = "energy", requires = "melee", condition = "buff:rogue_stealth", effects = { { type = "damage", weapon = true, weaponPct = 2, min = 10, max = 16, coef = 0.45, school = "physical" }, { type = "resource", resource = "combo", amount = 2 } } } })
ability(4030, "garrote", "Garrote", "subtlety", "Ability_Rogue_Garrote", 1, 1, {
  tags = { "subtlety", "melee", "builder", "opener", "bleed", "dot" }, shopRequires = { "stealth" },
  use = { cd = 12, initialDelay = 0.5, cost = 40, resource = "energy", requires = "melee", condition = "buff:rogue_stealth", effects = { { type = "dot", key = "garrote", tick = 3, coef = 0.07, duration = 12, school = "physical", rolling = true }, { type = "resource", resource = "combo", amount = 1 } } },
  triggers = { { on = "dotTick", match = { key = "garrote" }, effects = { { type = "resource", resource = "energy", amount = 2 } } } } })
ability(4031, "cheap_shot", "Cheap Shot", "subtlety", "Ability_CheapShot", 2, 3, {
  tags = { "subtlety", "builder", "opener", "control" }, shopRequires = { "stealth" },
  use = { cd = 15, initialDelay = 0.2, cost = 35, rankCosts = { [2] = 28, [3] = 23 }, resource = "energy", requires = "melee", condition = "buff:rogue_stealth", effects = { { type = "stun", duration = 1.5, rankScale = false }, { type = "resource", resource = "combo", amount = 2 } } } })
ability(4032, "hemorrhage", "Hemorrhage", "subtlety", "Spell_Shadow_LifeDrain", 1, 1, {
  tags = { "subtlety", "melee", "strike", "builder" },
  use = { cd = 4, cost = 30, resource = "energy", requires = "melee", effects = { { type = "damage", weapon = true, min = 3, max = 6, coef = 0.18, school = "physical" }, { type = "debuff", stat = "armor", value = 12, duration = 8, key = "hemorrhage", name = "Hemorrhage" }, { type = "resource", resource = "combo", amount = 1 } } },
  triggers = { { on = "dotTick", match = { tag = "bleed" }, every = 4, effects = { { type = "resource", resource = "combo", amount = 1 } } } } })
ability(4033, "ghostly_strike", "Ghostly Strike", "subtlety", "Spell_Shadow_Curse", 2, 2, {
  tags = { "subtlety", "melee", "strike", "builder" },
  use = { cd = 10, cost = 30, resource = "energy", requires = "melee", effects = { { type = "damage", weapon = true, weaponPct = 1.25, min = 3, max = 5, coef = 0.22, school = "physical" }, { type = "resource", resource = "combo", amount = 1 }, { type = "buff", stat = "dodge", value = 15, duration = 5, key = "ghostly_strike", name = "Ghostly Strike" } } } })
ability(4034, "vanish", "Vanish", "subtlety", "Ability_Vanish", 3, 4, {
  shopRequires = { "stealth" }, use = { cd = 18, initialDelay = 9, cost = 15, resource = "energy", effects = { { type = "buff", stat = "none", value = 0, duration = 6, key = "rogue_stealth", name = "Vanish" }, { type = "buff", stat = "dodge", value = 30, duration = 3, key = "vanish_evasion", name = "Vanish" }, { type = "cdr", target = "all", match = { tag = "opener" }, amount = 8, clampReady = true } } } })
ability(4035, "preparation", "Preparation", "subtlety", "Spell_Shadow_AntiShadow", 4, 7, {
  use = { cd = 28, initialDelay = 12, effects = { { type = "cdr", target = "all", match = { key = "vanish" }, amount = 18, clampReady = true }, { type = "cdr", target = "all", match = { key = "evasion" }, amount = 18, clampReady = true }, { type = "cdr", target = "all", match = { key = "sprint" }, amount = 18, clampReady = true }, { type = "cdr", target = "all", match = { key = "blind" }, amount = 18, clampReady = true }, { type = "resource", resource = "energy", amount = 30 } } } })
ability(4036, "premeditation", "Premeditation", "subtlety", "Spell_Shadow_Possession", 5, 9, {
  triggers = { { on = "battleStart", effects = { { type = "resource", resource = "combo", amount = 2 } } }, { on = "anyUse", match = { key = "vanish" }, effects = { { type = "resource", resource = "combo", amount = 2 } } } } })
ability(4037, "initiative", "Initiative", "subtlety", "Spell_Shadow_Fumble", 2, 2, {
  triggers = { { on = "anyUse", match = { tag = "opener" }, effects = { { type = "resource", resource = "combo", amount = 1 }, { type = "resource", resource = "energy", amount = 10 } } } } })
ability(4038, "serrated_blades", "Serrated Blades", "subtlety", "INV_Sword_17", 3, 4, {
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "dot", key = "serrated_blades", tick = 0, school = "physical", duration = 6, rolling = true, fromEvent = 0.15 } } } } })
ability(4039, "setup", "Setup", "subtlety", "Spell_Nature_MirrorImage", 2, 2, {
  triggers = { { on = "dodged", effects = { { type = "resource", resource = "combo", amount = 1 }, { type = "resource", resource = "energy", amount = 5 } } } } })
ability(4040, "dirty_deeds", "Dirty Deeds", "subtlety", "Spell_Shadow_SummonSuccubus", 3, 5, {
  adjacency = { { match = { tag = "opener" }, mods = { costPct = -25 } } },
  triggers = { { on = "enemyStunned", effects = { { type = "tickDots", match = { tag = "bleed" } } } } } })
ability(4041, "evasion", "Evasion", "shared", "Spell_Shadow_ShadowWard", 2, 2, {
  tags = { "defensive" }, use = { cd = 22, initialDelay = 4, effects = { { type = "buff", stat = "dodge", value = 40, duration = 5, key = "evasion", name = "Evasion" } } } })
ability(4042, "sprint", "Sprint", "shared", "Ability_Rogue_Sprint", 1, 1, {
  use = { cd = 18, initialDelay = 2, cost = 15, resource = "energy", effects = { { type = "buff", target = "all", match = { tag = "melee" }, stat = "haste", value = 25, duration = 5, key = "sprint", name = "Sprint" } } } })
ability(4043, "kick", "Kick", "shared", "Ability_Kick", 2, 2, {
  tags = { "melee", "control" }, use = { cd = 12, cost = 15, resource = "energy", requires = "melee", effects = { { type = "damage", min = 3, max = 5, coef = 0.1, school = "physical" }, { type = "stun", duration = 0.8, rankScale = false } } } })
ability(4044, "blind", "Blind", "shared", "Spell_Shadow_MindSteal", 3, 4, {
  tags = { "control", "defensive" }, use = { cd = 20, cost = 20, rankCosts = { [2] = 16, [3] = 13 }, resource = "energy", effects = { { type = "stun", duration = 2, rankScale = false }, { type = "cleanse", count = 1 } } } })
ability(4045, "expose_armor", "Expose Armor", "assassination", "Ability_Warrior_Riposte", 2, 2, {
  tags = { "assassination", "finisher" }, use = { cd = 12, initialDelay = 0.1, cost = 2, spendAll = true, resource = "combo", effects = { { type = "debuff", stat = "armor", value = 30, duration = 12, key = "expose_armor", name = "Expose Armor" }, { type = "tickDots", match = { tag = "bleed" } } } } })
ability(4046, "vigor", "Vigor", "assassination", "Spell_Nature_EarthBindTotem", 5, 9, {
  shape = S.L, grants = { energy = { max = 110, start = 110, regen = 10 } },
  triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 70, effects = { { type = "resource", resource = "energy", amount = 10 } } } } })
ability(4047, "deflection_rogue", "Deflection", "combat", "Ability_Parry", 3, 4, {
  stats = { dodge = 5 },
  triggers = { { on = "dodged", effects = { { type = "buff", stat = "none", value = 0, duration = 4, key = "rogue_riposte", name = "Riposte" }, { type = "cdr", target = "all", match = { key = "riposte" }, amount = 2, clampReady = true } } } } })
ability(4048, "endurance_rogue", "Endurance", "combat", "Spell_Shadow_ShadowWard", 2, 2, {
  stats = { hp = 20 },
  triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 60, effects = { { type = "cdr", target = "all", match = { key = "evasion" }, amount = 1, clampReady = true }, { type = "cdr", target = "all", match = { key = "sprint" }, amount = 1, clampReady = true } } } } })
ability(4049, "mace_specialization_rogue", "Mace Specialization", "combat", "INV_Mace_01", 3, 5, {
  adjacency = { { match = { weaponType = "mace" }, mods = { dmgPct = 20 } } },
  triggers = { { on = "regularHit", match = { weaponType = "mace" }, chance = 15, icd = 3, effects = { { type = "stun", duration = 0.8, rankScale = false } } } } })
ability(4050, "weapon_expertise_rogue", "Weapon Expertise", "combat", "Spell_Holy_BlessingOfStrength", 4, 7, {
  triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "buff", target = "all", match = { tag = "autoattack" }, stat = "crit", value = 35, charges = 1, duration = 6, key = "weapon_expertise", name = "Weapon Expertise" }, { type = "cdr", target = "all", match = { tag = "autoattack" }, amount = 1, clampReady = true } } } } })
ability(4051, "camouflage", "Camouflage", "subtlety", "Ability_Stealth", 1, 1, {
  stats = { dodge = 3 },
  triggers = { { on = "anyUse", match = { key = "vanish" }, effects = { { type = "resource", resource = "energy", amount = 12 } } }, { on = "anyUse", match = { tag = "opener" }, effects = { { type = "buff", stat = "dodge", value = 8, duration = 4, key = "camouflage", name = "Camouflage" } } } } })
ability(4052, "opportunity", "Opportunity", "subtlety", "Ability_Warrior_WarCry", 3, 4, {
  adjacency = { { match = { tag = "opener" }, mods = { dmgPct = 20 } } },
  triggers = { { on = "enemyStunned", icd = 2, effects = { { type = "cdr", target = "all", match = { key = "backstab" }, amount = 1, clampReady = true }, { type = "cdr", target = "all", match = { tag = "opener" }, amount = 1, clampReady = true } } } } })
ability(4053, "elusiveness", "Elusiveness", "subtlety", "Spell_Magic_LesserInvisibilty", 4, 7, {
  triggers = { { on = "dodged", icd = 1, effects = { { type = "cdr", target = "all", match = { key = "vanish" }, amount = 1, clampReady = true }, { type = "cdr", target = "all", match = { key = "blind" }, amount = 1, clampReady = true } } } } })

ability(4060, "mind_numbing_poison", "Mind-numbing Poison", "assassination", "Spell_Nature_NullifyDisease", 1, 1, {
  tags = { "assassination", "poison", "nature", "control" }, rankable = false,
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 20, effects = { { type = "debuff", target = "all", match = { kind = "ability", tag = "spell" }, stat = "haste", value = 25, duration = 6, key = "mind_numbing_poison", name = "Mind-numbing Poison", rankScale = false } } } } })
ability(4061, "feint", "Feint", "combat", "Ability_Rogue_Feint", 1, 1, {
  tags = { "combat", "melee", "defensive" },
  use = { cd = 14, cost = 20, rankCosts = { [2] = 16, [3] = 13 }, resource = "energy", requires = "melee", condition = "below50", reactive = true,
    effects = { { type = "debuff", stat = "meleePct", value = 20, duration = 4, key = "feint", name = "Feint", rankScale = false } } } })
