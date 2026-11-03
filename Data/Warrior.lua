local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local WARRIOR = { "WARRIOR" }

H.Weapon{ id = 1290, key = "worn_axe", name = "Worn Axe", icon = I("inv_axe_11"), quality = 1, cost = 3, weaponType = "axe", classes = WARRIOR, weaponMin = 5, weaponMax = 9, speed = 2.4, noShop = true, starter = true }

H.Ability{ id = 1200, key = "heroic_strike", spec = "shared", name = "Heroic Strike", icon = I("Ability_Rogue_Ambush"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "arms", "fury", "melee", "strike" },
  use = { cd = 2.8, cost = 10, resource = "rage", requires = "melee", effects = { { type = "damage", weapon = true, min = 3, max = 5, school = "physical", coef = 0.16 } } } }
H.Ability{ id = 1201, key = "rend", spec = "arms", name = "Rend", icon = I("Ability_Gouge"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "arms", "melee", "bleed", "dot" },
  use = { cd = 9, cost = 5, resource = "rage", requires = "melee", effects = { { type = "dot", key = "rend", school = "physical", tick = 3, coef = 0.06, duration = 9, preserveTicks = true } } } }
H.Ability{ id = 1203, key = "overpower", spec = "arms", name = "Overpower", icon = I("Ability_MeleeDamage"), quality = 2, minRound = 2, classes = WARRIOR, shape = S.v2, tags = { "arms", "melee", "strike" }, rankable = true,
  triggers = { { on = "targetDodged", effects = { { type = "damage", weapon = true, min = 5, max = 8, school = "physical", coef = 0.2, critBonus = 25, noDodge = true } } } } }
H.Ability{ id = 1204, key = "mortal_strike", spec = "arms", name = "Mortal Strike", icon = I("Ability_Warrior_SavageBlow"), quality = 3, cost = 7, minRound = 3, classes = WARRIOR, shape = S.L, tags = { "arms", "melee", "strike" },
  use = { cd = 7, cost = 25, rankCosts = { [2] = 35, [3] = 50 }, resource = "rage", requires = "melee", effects = { { type = "damage", weapon = true, weaponPct = 1.7, min = 14, max = 18, school = "physical", coef = 0.4, perStatus = 0.1 }, { type = "debuff", stat = "healPct", value = 50, duration = 6, key = "mortal_wound", name = "Mortal Wound", rankScale = false } } } }
H.Ability{ id = 1205, key = "execute", spec = "shared", name = "Execute", icon = I("INV_Sword_48"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "arms", "fury", "melee", "finisher" },
  use = { cd = 2, cost = 15, resource = "rage", spendAll = true, requires = "melee", condition = "enemyBelow20", effects = { { type = "damage", min = 22, max = 28, school = "physical", coef = 0.65, perCombo = 0.03 } } } }
H.Ability{ id = 1208, key = "bloodthirst", spec = "fury", name = "Bloodthirst", icon = I("Spell_Nature_BloodLust"), quality = 3, cost = 7, minRound = 3, classes = WARRIOR, shape = S.L, tags = { "fury", "melee", "strike", "heal" },
  use = { cd = 6, cost = 20, resource = "rage", requires = "melee", effects = { { type = "damage", min = 17, max = 21, school = "physical", coef = 0.55 }, { type = "heal", min = 6, max = 8, pctMax = 0.015 } } } }
H.Ability{ id = 1209, key = "whirlwind", spec = "shared", name = "Whirlwind", icon = I("Ability_Whirlwind"), quality = 3, cost = 8, minRound = 4, classes = WARRIOR, shape = S.sq, tags = { "fury", "melee", "strike" },
  use = { cd = 5, cost = 20, resource = "rage", requires = "melee", effects = { { type = "damage", weapon = true, weaponPct = 0.85, min = 4, max = 6, school = "physical", coef = 0.16 }, { type = "damage", weapon = true, weaponPct = 0.85, min = 4, max = 6, school = "physical", coef = 0.16 } } } }
H.Ability{ id = 1211, key = "bloodrage", spec = "shared", name = "Bloodrage", icon = I("Ability_Racial_BloodRage"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "fury", "arms", "prot" }, rankable = false,
  use = { cd = 10, initialDelay = 1, healthCostPct = 0.06, effects = { { type = "resource", resource = "rage", amount = 22 } } } }
H.Ability{ id = 1215, key = "flurry", spec = "fury", name = "Flurry", icon = I("Ability_GhoulFrenzy"), quality = 2, minRound = 2, classes = WARRIOR, shape = S.v2, tags = { "fury" }, stats = { crit = 4 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "buff", stat = "haste", value = 25, duration = 4, target = "all", match = { kind = "weapon", tag = "melee", anyTag = { "autoattack" } }, key = "flurry", name = "Flurry" } } } } }
H.Ability{ id = 1217, key = "death_wish", spec = "fury", name = "Death Wish", icon = I("Spell_Shadow_DeathPact"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "fury" },
  triggers = { { on = "battleStart", effects = { { type = "buff", stat = "dmgPct", value = 100, missingHealth = true, duration = 120, key = "death_wish", name = "Death Wish" }, { type = "buff", stat = "dr", value = -20, duration = 120, key = "death_wish_risk", name = "Death Wish" } } } } }
H.Ability{ id = 1218, key = "recklessness", spec = "fury", name = "Recklessness", icon = I("Ability_CriticalStrike"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.v2, tags = { "fury" }, rankable = false,
  use = { cd = 18, initialDelay = 2, effects = { { type = "buff", stat = "crit", value = 60, duration = 6, key = "recklessness", name = "Recklessness" }, { type = "buff", stat = "critDamage", value = 30, duration = 6, key = "recklessness_damage", name = "Recklessness" }, { type = "buff", stat = "dr", value = -15, duration = 6, key = "recklessness_risk", name = "Recklessness" } } } }
H.Ability{ id = 1219, key = "shield_block", spec = "prot", name = "Shield Block", icon = I("Ability_Defend"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "prot", "defensive" },
  use = { reactive = true, cd = 8, cost = 10, resource = "rage", requires = "shield", effects = { { type = "buff", stat = "blockChance", value = 40, duration = 5, key = "shield_block", name = "Shield Block" } } } }
H.Ability{ id = 1220, key = "shield_slam", spec = "prot", name = "Shield Slam", icon = I("INV_Shield_05"), quality = 3, cost = 7, minRound = 3, classes = WARRIOR, shape = S.L, tags = { "prot", "melee", "strike" },
  use = { cd = 7, cost = 20, resource = "rage", requires = "shield", effects = { { type = "damage", min = 16, max = 20, school = "physical", coef = 0.3, spendBank = "blocked", bankScale = 1.5 } } },
  triggers = { { on = "block", effects = { { type = "bank", key = "blocked", fraction = 1 } } } } }
H.Ability{ id = 1221, key = "revenge", spec = "prot", name = "Revenge", icon = I("Ability_Warrior_Revenge"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "prot", "melee", "strike" }, rankable = true,
  triggers = { { on = "block", icd = 2, effects = { { type = "damage", min = 6, max = 9, school = "physical", coef = 0.2 } } }, { on = "dodged", icd = 2, effects = { { type = "damage", min = 6, max = 9, school = "physical", coef = 0.2 } } } } }
H.Ability{ id = 1222, key = "sunder_armor", spec = "shared", name = "Sunder Armor", icon = I("Ability_Warrior_Sunder"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "prot", "arms", "melee" },
  use = { cd = 5, cost = 10, resource = "rage", requires = "melee", effects = { { type = "debuff", stat = "armor", value = 12, duration = 20, stack = true, maxStacks = 5, key = "sunder", name = "Sunder Armor" } } },
  triggers = { { on = "use", effects = { { type = "cdr", target = "neighbors", match = { tag = "strike" }, amount = 0.5 } } } } }
H.Ability{ id = 1231, key = "deep_wounds", spec = "arms", name = "Deep Wounds", icon = I("Ability_BackStab"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "arms", "bleed" }, stats = { crit = 5 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "dot", key = "deep_wounds", school = "physical", duration = 6, rolling = true, fromEvent = 0.3 } } } } }
H.Ability{ id = 1238, key = "blood_craze", spec = "fury", name = "Blood Craze", icon = I("Spell_Shadow_SummonImp"), quality = 1, classes = WARRIOR, shape = S.v2, tags = { "fury", "heal", "hot" },
  triggers = { { on = "below40", effects = { { type = "hot", key = "blood_craze", tick = 6, coef = 0.06, duration = 4, preserveTicks = true } } } } }
H.Ability{ id = 1239, key = "impale", spec = "arms", name = "Impale", icon = I("Ability_SearingArrow"), quality = 3, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "arms" }, passiveTriggers = true,
  stats = { critDamage = 25 } }

H.Ability{ id = 1250, key = "battle_shout", spec = "shared", name = "Battle Shout", icon = I("ability_warrior_battleshout"), quality = 2, cost = 5, minRound = 2, classes = WARRIOR, shape = S.v2, tags = { "arms", "fury", "shout" },
  use = { cd = 15, cost = 10, resource = "rage", effects = { { type = "buff", stat = "ap", value = 24, duration = 12, key = "battle_shout", name = "Battle Shout" } } } }
H.Ability{ id = 1251, key = "unbridled_wrath", spec = "fury", name = "Unbridled Wrath", icon = I("spell_nature_stoneclawtotem"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "fury" }, rankable = false,
  triggers = { { on = "anyCrit", healing = false, match = { tag = "autoattack" }, effects = { { type = "resource", resource = "rage", amount = 8 } } } } }
H.Ability{ id = 1252, key = "improved_execute", spec = "fury", shopRequires = { "execute" }, name = "Improved Execute", icon = I("inv_sword_48"), quality = 3, cost = 8, minRound = 5, classes = WARRIOR, shape = S.L, tags = { "arms", "fury" }, rankable = false,
  triggers = { { on = "anyCrit", healing = false, match = { tag = "strike" }, condition = "resourceAtLeast:rage:60", effects = { { type = "cast", key = "execute" } } } } }
H.Ability{ id = 1253, key = "concussion_blow", spec = "prot", name = "Concussion Blow", icon = I("ability_thunderbolt"), quality = 3, cost = 8, minRound = 6, classes = WARRIOR, shape = S.L, tags = { "prot", "melee" }, rankable = false,
  use = { cd = 10, cost = 20, resource = "rage", requires = "melee", effects = { { type = "stun", duration = 1.5 }, { type = "buff", stat = "none", value = 0, free = true, match = { tag = "strike" }, duration = 8, key = "concussion_blow", name = "Concussion Blow", cond = "enemyBleeding" } } } }
H.Ability{ id = 1254, key = "sword_specialization", spec = "arms", name = "Sword Specialization", icon = I("inv_sword_27"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.L, tags = { "arms", "fury" }, rankable = false,
  triggers = { { on = "anyHit", match = { weaponType = "sword" }, chance = 20, effects = { { type = "extraAttack", count = 2 } } } } }
H.Ability{ id = 1255, key = "anger_management", spec = "arms", name = "Anger Management", icon = I("spell_holy_blessingofstamina"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.v3, tags = { "arms", "fury", "heal" }, rankable = false,
  triggers = { { on = "resourceOverflow", resource = "rage", everyAmount = 20, effects = { { type = "heal", pctMax = 0.005 } } } } }
H.Ability{ id = 1256, key = "retaliation", spec = "shared", shopRequires = { "heroic_strike" }, name = "Retaliation", icon = I("ability_warrior_challange"), quality = 4, cost = 11, minRound = 8, classes = WARRIOR, shape = S.sq, tags = { "arms", "prot", "melee" }, rankable = false,
  use = { cd = 20, cost = 30, resource = "rage", requires = "melee", effects = { { type = "buff", stat = "none", value = 0, duration = 6, key = "retaliation", name = "Retaliation" } } },
  triggers = { { on = "damaged", matchAttacker = { tag = "melee" }, condition = "buff:retaliation", effects = { { type = "cast", key = "heroic_strike" } } } } }
H.Ability{ id = 1257, key = "enrage", spec = "fury", name = "Enrage", icon = I("spell_shadow_unholyfrenzy"), quality = 4, cost = 10, minRound = 8, classes = WARRIOR, shape = S.v3, tags = { "fury" }, rankable = false,
  use = { cd = 3, condition = "resourceAtLeast:rage:60", effects = { { type = "buff", stat = "dmgPct", value = 50, duration = 4, key = "enrage", name = "Enrage" } } } }
H.Ability{ id = 1258, key = "sweeping_strikes", spec = "arms", name = "Sweeping Strikes", icon = I("ability_rogue_slicedice"), quality = 5, cost = 15, minRound = 9, classes = WARRIOR, shape = S.sq, tags = { "arms", "fury" }, rankable = false,
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 40, effects = { { type = "cast", target = "neighbors", match = { tag = "strike" } } } } } }
H.Ability{ id = 1259, key = "last_stand", spec = "prot", name = "Last Stand", icon = I("spell_holy_ashestoashes"), quality = 5, cost = 14, minRound = 10, classes = WARRIOR, shape = S.L, tags = { "prot", "fury", "heal" }, rankable = false,
  triggers = { { on = "lowHealth", effects = { { type = "heal", pctMax = 0.5 }, { type = "resource", resource = "rage", amount = 100 }, { type = "extraAttack", count = 3 } } } } }

H.Ability{ id = 1260, key = "slam", spec = "arms", name = "Slam", icon = I("ability_warrior_decisivestrike"), quality = 2, cost = 5, minRound = 2, classes = WARRIOR, shape = S.v3, tags = { "arms", "melee", "strike" },
  use = { cd = 6, cost = 20, resource = "rage", requires = { "melee", "twohand" }, effects = { { type = "damage", weapon = true, weaponPct = 2.2, min = 4, max = 6, school = "physical", coef = 0.15 } } } }
H.Ability{ id = 1261, key = "improved_slam", spec = "fury", shopRequires = { "slam" }, name = "Improved Slam", icon = I("ability_warrior_decisivestrike"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "fury" }, passiveTriggers = true,
  adjacency = { { match = { key = "slam" }, mods = { haste = 30, costPct = -25 } } } }
H.Ability{ id = 1262, key = "tactical_mastery", spec = "arms", name = "Tactical Mastery", icon = I("spell_nature_enchantarmor"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.v2, tags = { "arms" },
  triggers = { { on = "resourceOverflow", resource = "rage", everyAmount = 20, effects = { { type = "buff", stat = "none", free = true, match = { tag = "strike" }, duration = 8, key = "tactical_mastery", name = "Tactical Mastery" } } } } }
H.Ability{ id = 1263, key = "piercing_howl", spec = "fury", name = "Piercing Howl", icon = I("spell_shadow_deathscream"), quality = 2, cost = 5, minRound = 3, classes = WARRIOR, shape = S.v2, tags = { "fury", "shout" }, rankable = false,
  use = { cd = 8, cost = 10, resource = "rage", effects = { { type = "debuff", stat = "haste", value = 25, duration = 4, key = "piercing_howl", name = "Piercing Howl" } } } }
H.Ability{ id = 1264, key = "berserker_rage", spec = "fury", name = "Berserker Rage", icon = I("spell_nature_ancestralguardian"), quality = 1, cost = 3, classes = WARRIOR, shape = S.v2, tags = { "fury" }, rankable = false,
  use = { cd = 14, initialDelay = 2, effects = { { type = "resource", resource = "rage", amount = 18 }, { type = "buff", stat = "rageTakenPct", value = 50, duration = 5, key = "berserker_rage", name = "Berserker Rage" } } } }
H.Ability{ id = 1265, key = "dual_wield_specialization", spec = "fury", name = "Dual Wield Specialization", icon = I("ability_dualwield"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "fury" },
  triggers = { { on = "battleStart", condition = "dualwield", effects = { { type = "buff", stat = "haste", value = 20, duration = 120, target = "all", match = { kind = "weapon", tag = "melee", anyTag = { "autoattack" } }, key = "dual_wield_specialization", name = "Dual Wield Specialization" } } } } }
H.Ability{ id = 1266, key = "shield_wall", spec = "prot", name = "Shield Wall", icon = I("ability_warrior_shieldwall"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.L, tags = { "prot", "defensive" }, rankable = false,
  use = { reactive = true, cd = 20, cost = 15, resource = "rage", requires = "shield", condition = "below50", effects = { { type = "buff", stat = "dr", value = 40, duration = 5, key = "shield_wall", name = "Shield Wall" } } } }
H.Ability{ id = 1700, key = "charge", spec = "shared", name = "Charge", icon = I("ability_warrior_charge"), quality = 2, cost = 5, minRound = 2, classes = WARRIOR, shape = S.v2, tags = { "arms", "fury", "prot" }, rankable = false,
  triggers = { { on = "battleStart", effects = { { type = "resource", resource = "rage", amount = 25 }, { type = "cdr", target = "neighbors", match = { tag = "strike" }, amount = 2 } } } } }
H.Ability{ id = 1701, key = "cleave", spec = "arms", name = "Cleave", icon = I("ability_warrior_cleave"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.L, tags = { "arms", "fury", "melee", "strike" },
  use = { cd = 7, cost = 30, resource = "rage", requires = "melee", effects = { { type = "damage", weapon = true, weaponPct = 1.4, min = 8, max = 12, school = "physical", coef = 0.2 }, { type = "damage", weapon = true, weaponPct = 1.4, min = 8, max = 12, school = "physical", coef = 0.2, cond = "enemyBleeding" } } } }
H.Ability{ id = 1702, key = "disarm", spec = "shared", name = "Disarm", icon = I("ability_warrior_disarm"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "arms", "prot", "defensive" }, rankable = false,
  use = { cd = 16, cost = 15, resource = "rage", requires = "melee", effects = { { type = "debuff", stat = "meleePct", value = 35, duration = 6, key = "disarm", name = "Disarm" } } } }
H.Ability{ id = 1703, key = "shield_bash", spec = "prot", name = "Shield Bash", icon = I("ability_warrior_shieldbash"), quality = 3, cost = 7, minRound = 5, classes = WARRIOR, shape = S.v2, tags = { "prot", "melee", "strike" },
  use = { cd = 10, cost = 10, resource = "rage", requires = "shield", effects = { { type = "damage", min = 8, max = 12, school = "physical", coef = 0.15, blockScale = 1.2 }, { type = "purge", count = 1 } } } }

H.Ability{ id = 1900, key = "hamstring", spec = "arms", name = "Hamstring", icon = I("ability_shockwave"), quality = 1, cost = 3, classes = WARRIOR, shape = S.v2, tags = { "arms", "melee", "strike" },
  use = { cd = 8, cost = 8, resource = "rage", requires = "melee", effects = { { type = "damage", min = 2, max = 4, school = "physical", coef = 0.1 }, { type = "debuff", stat = "haste", value = 15, duration = 8, key = "hamstring", name = "Hamstring" }, { type = "buff", stat = "crit", value = 8, duration = 8, key = "hamstring_opening", name = "Hamstring", cond = "enemyBleeding" } } } }
H.Ability{ id = 1901, key = "mace_specialization", spec = "arms", name = "Mace Specialization", icon = I("inv_mace_01"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "arms" }, rankable = false,
  triggers = { { on = "anyHit", match = { weaponType = "mace" }, chance = 15, effects = { { type = "stun", duration = 1 } } } } }
H.Ability{ id = 1902, key = "axe_specialization", spec = "arms", name = "Axe Specialization", icon = I("inv_axe_06"), quality = 3, cost = 7, minRound = 5, classes = WARRIOR, shape = S.v2, tags = { "arms" }, rankable = false,
  triggers = { { on = "anyCrit", healing = false, match = { weaponType = "axe" }, effects = { { type = "tickDots", match = { tag = "bleed" } } } } } }
H.Ability{ id = 1903, key = "improved_overpower", spec = "arms", shopRequires = { "overpower", "mortal_strike" }, name = "Improved Overpower", icon = I("inv_sword_05"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.L, tags = { "arms" }, rankable = false,
  triggers = { { on = "anyCrit", healing = false, match = { key = "overpower" }, effects = { { type = "cast", key = "mortal_strike" } } } } }
H.Ability{ id = 1904, key = "improved_rend", spec = "arms", shopRequires = { "rend" }, name = "Improved Rend", icon = I("ability_gouge"), quality = 2, cost = 5, minRound = 3, classes = WARRIOR, shape = S.v2, tags = { "arms" }, rankable = false,
  triggers = { { on = "dotTick", match = { tag = "bleed" }, everyAmount = 18, effects = { { type = "resource", resource = "rage", amount = 3 }, { type = "cdr", target = "all", match = { key = "slam" }, amount = 1 } } } } }

H.Ability{ id = 1905, key = "demoralizing_shout", spec = "fury", name = "Demoralizing Shout", icon = I("ability_warrior_warcry"), quality = 1, cost = 3, classes = WARRIOR, shape = S.v2, tags = { "fury", "shout" },
  use = { cd = 12, cost = 10, resource = "rage", effects = { { type = "debuff", stat = "ap", value = 16, duration = 10, key = "demoralizing_shout", name = "Demoralizing Shout" }, { type = "debuff", stat = "dmgPct", value = 12, duration = 8, key = "demoralizing_shout_damage", name = "Demoralizing Shout" } } } }
H.Ability{ id = 1906, key = "cruelty", spec = "fury", name = "Cruelty", icon = I("ability_rogue_eviscerate"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "fury", "heal" }, rankable = false,
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, condition = "enemyBleeding", effects = { { type = "heal", fromEvent = 0.15 } } } } }
H.Ability{ id = 1907, key = "pummel", spec = "fury", name = "Pummel", icon = I("inv_gauntlets_04"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.v2, tags = { "fury", "melee", "strike" },
  use = { cd = 9, cost = 15, resource = "rage", requires = "melee", effects = { { type = "damage", min = 6, max = 9, school = "physical", coef = 0.12 }, { type = "drain", resource = "mana", amount = 15 }, { type = "debuff", stat = "spellPct", value = 20, duration = 5, key = "pummel", name = "Pummel" } } } }
H.Ability{ id = 1908, key = "improved_berserker_rage", spec = "fury", shopRequires = { "berserker_rage" }, name = "Improved Berserker Rage", icon = I("spell_nature_ancestralguardian"), quality = 5, cost = 15, minRound = 10, classes = WARRIOR, shape = S.sq, tags = { "fury" }, rankable = false,
  triggers = { { on = "resourceGained", resource = "rage", condition = "buff:berserker_rage", everyAmount = 25, effects = { { type = "extraAttack", count = 1 } } } } }

H.Ability{ id = 1909, key = "thunder_clap", spec = "prot", name = "Thunder Clap", icon = I("spell_nature_thunderclap"), quality = 2, cost = 5, minRound = 2, classes = WARRIOR, shape = S.v2, tags = { "prot", "melee", "spell" },
  use = { cd = 8, cost = 12, resource = "rage", effects = { { type = "damage", min = 4, max = 6, school = "physical", coef = 0.15, noDodge = true }, { type = "debuff", stat = "haste", value = 20, duration = 6, key = "thunder_clap", name = "Thunder Clap" } } } }
H.Ability{ id = 1910, key = "defensive_stance", spec = "prot", name = "Defensive Stance", icon = I("ability_warrior_defensivestance"), quality = 1, cost = 3, classes = WARRIOR, shape = S.v2, tags = { "prot", "defensive" }, rankable = false,
  stats = { dr = 12, dmgPct = -8 } }
H.Ability{ id = 1911, key = "defiance", spec = "prot", name = "Defiance", icon = I("ability_warrior_innerrage"), quality = 3, cost = 7, minRound = 4, classes = WARRIOR, shape = S.v2, tags = { "prot" }, rankable = false,
  triggers = { { on = "block", effects = { { type = "buff", stat = "ap", value = 0, fromEvent = 0.75, duration = 6, key = "defiance", name = "Defiance", stack = true, maxStacks = 5 } } } } }
H.Ability{ id = 1912, key = "improved_shield_block", spec = "prot", shopRequires = { "shield_block" }, name = "Improved Shield Block", icon = I("ability_defend"), quality = 2, cost = 5, minRound = 3, classes = WARRIOR, shape = S.v2, tags = { "prot" }, rankable = false,
  triggers = { { on = "block", condition = "buff:shield_block", effects = { { type = "resource", resource = "rage", amount = 4 }, { type = "cdr", target = "all", match = { key = "shield_slam" }, amount = 0.5 } } } } }
H.Ability{ id = 1913, key = "improved_revenge", spec = "prot", shopRequires = { "revenge" }, name = "Improved Revenge", icon = I("ability_warrior_revenge"), quality = 3, cost = 7, minRound = 5, classes = WARRIOR, shape = S.v2, tags = { "prot" }, rankable = false,
  triggers = { { on = "anyHit", match = { key = "revenge" }, chance = 25, effects = { { type = "stun", duration = 1 } } } } }
H.Ability{ id = 1914, key = "improved_shield_wall", spec = "prot", shopRequires = { "shield_wall" }, name = "Improved Shield Wall", icon = I("ability_warrior_shieldwall"), quality = 4, cost = 10, minRound = 8, classes = WARRIOR, shape = S.v2, tags = { "prot", "heal" }, rankable = false,
  triggers = { { on = "anyUse", match = { key = "shield_wall" }, effects = { { type = "heal", pctMax = 0.2 }, { type = "cleanse", count = 2 } } } } }
H.Ability{ id = 1915, key = "shield_specialization", spec = "prot", name = "Shield Specialization", icon = I("inv_shield_06"), quality = 5, cost = 15, minRound = 11, classes = WARRIOR, shape = S.sq, tags = { "prot", "melee" }, rankable = false,
  triggers = { { on = "block", effects = { { type = "cast", key = "shield_block" }, { type = "damage", school = "physical", fromEvent = 0.75, noDodge = true, noCrit = true } } } } }
H.Ability{ id = 1916, key = "iron_will", spec = "prot", name = "Iron Will", icon = I("spell_magic_magearmor"), quality = 4, cost = 10, minRound = 7, classes = WARRIOR, shape = S.v2, tags = { "prot", "defensive" }, rankable = false,
  triggers = { { on = "stunned", effects = { { type = "buff", stat = "dr", value = 50, duration = 3, key = "iron_will", name = "Iron Will" }, { type = "resource", resource = "rage", amount = 15 } } } } }
H.Ability{ id = 1917, key = "warrior_anticipation", spec = "prot", name = "Anticipation", icon = I("spell_nature_mirrorimage"), quality = 2, cost = 5, minRound = 2, classes = WARRIOR, shape = S.v2, tags = { "prot", "defensive" }, rankable = false,
  stats = { dodge = 3, blockChance = 5 },
  triggers = { { on = "dodged", effects = { { type = "cdr", target = "all", match = { key = "revenge" }, amount = 1, clampReady = true } } } } }
