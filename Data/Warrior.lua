local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local WARRIOR = { "WARRIOR" }
local ability = H.QualityAbilities(WARRIOR)



ability(1200, "heroic_strike", "Heroic Strike", "shared", "Ability_Rogue_Ambush", 1, {
  tags = { "arms", "fury", "melee", "strike" },
  use = { cost = 10, cd = 2.8, resource = "rage", requires = "melee", effects = { { type = "damage", coef = 0.25, min = 2, max = 3, school = "physical", weapon = true, weaponPct = 0.8 } } },
})

ability(1201, "rend", "Rend", "arms", "Ability_Gouge", 1, {
  tags = { "arms", "melee", "bleed", "dot" },
  use = { cost = 5, cd = 9, resource = "rage", requires = "melee", effects = { { type = "dot", key = "rend", coef = 0.1, tick = 1, school = "physical", duration = 9, preserveTicks = true } } },
  shopWeight = 1.4,
})

ability(1203, "overpower", "Overpower", "arms", "Ability_MeleeDamage", 2, {
  shape = S.v2, tags = { "arms", "melee", "strike" },
  triggers = { { on = "targetDodged", effects = { { type = "damage", coef = 0.3, min = 1, max = 3, school = "physical", critBonus = 25, noDodge = true, weapon = true, weaponPct = 0.8 } } } },
})

ability(1204, "mortal_strike", "Mortal Strike", "arms", "Ability_Warrior_SavageBlow", 3, {
  minRound = 3, shape = S.L, tags = { "arms", "melee", "strike" },
  use = {
    cost = 25, cd = 7, resource = "rage", requires = "melee",
    effects = {
      { type = "damage", coef = 0.6, min = 3, max = 5, school = "physical", perStatus = 0.1, weapon = true, weaponPct = 1.2 },
      { type = "debuff", key = "mortal_wound", name = "Mortal Wound", stat = "healPct", value = 50, duration = 6, rankScale = false },
    },
    rankCosts = { [2] = 35, [3] = 50 },
  },
  shopWeight = 2,
})

ability(1205, "execute", "Execute", "shared", "INV_Sword_48", 3, {
  tags = { "arms", "fury", "melee", "finisher" },
  use = {
    cost = 15, cd = 2, resource = "rage", requires = "melee", condition = "enemyBelow20",
    effects = { { type = "damage", coef = 0.95, min = 4, max = 6, school = "physical", perCombo = 0.03 } }, spendAll = true,
  },
})

ability(1208, "bloodthirst", "Bloodthirst", "fury", "Spell_Nature_BloodLust", 3, {
  minRound = 3, shape = S.L, tags = { "fury", "melee", "strike", "heal" },
  use = {
    cost = 20, cd = 6, resource = "rage", requires = "melee",
    effects = { { type = "damage", coef = 0.6, min = 2, max = 4, school = "physical" }, { type = "heal", coef = 0.05, min = 1, max = 2, pctMax = 0.0075, powerStat = "ap" } },
  },
  shopWeight = 2.2,
})

ability(1209, "whirlwind", "Whirlwind", "shared", "Ability_Whirlwind", 3, {
  shape = S.sq, tags = { "fury", "melee", "strike" },
  use = {
    cost = 20, cd = 5, resource = "rage", requires = "melee",
    effects = {
      { type = "damage", coef = 0.2, min = 1, max = 2, school = "physical", weapon = true, weaponPct = 0.65 },
      { type = "damage", coef = 0.2, min = 1, max = 2, school = "physical", weapon = true, weaponPct = 0.65 },
    },
  },
})

ability(1211, "bloodrage", "Bloodrage", "shared", "Ability_Racial_BloodRage", 1, {
  tags = { "fury", "arms", "prot" },
  use = { cd = 10, initialDelay = 1, effects = { { type = "resource", resource = "rage", amount = 22 } }, healthCostPct = 0.06 }, rankable = false,
  shopWeight = 1.4,
})

ability(1215, "flurry", "Flurry", "fury", "Ability_GhoulFrenzy", 2, {
  shape = S.v2, tags = { "fury" }, stats = { crit = 4 },
  triggers = {
    {
      on = "anyCrit", match = { tag = "melee" },
      effects = { { type = "buff", key = "flurry", name = "Flurry", target = "all", match = { kind = "weapon", anyTag = { "autoattack" }, tag = "melee" }, stat = "haste", value = 25, duration = 4 } },
      healing = false,
    },
  },
})

ability(1217, "death_wish", "Death Wish", "fury", "Spell_Shadow_DeathPact", 3, {
  shape = S.v2, tags = { "fury" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        { type = "buff", key = "death_wish", name = "Death Wish", stat = "dmgPct", value = 75, duration = 120, missingHealth = true },
        { type = "buff", key = "death_wish_risk", name = "Death Wish", stat = "dr", value = -20, duration = 120 },
      },
    },
  },
})

ability(1218, "recklessness", "Recklessness", "fury", "Ability_CriticalStrike", 4, {
  tags = { "fury" },
  use = {
    cd = 18, initialDelay = 2,
    effects = {
      { type = "buff", key = "recklessness", name = "Recklessness", stat = "crit", value = 60, duration = 6 },
      { type = "buff", key = "recklessness_damage", name = "Recklessness", stat = "critDamage", value = 30, duration = 6 },
      { type = "buff", key = "recklessness_risk", name = "Recklessness", stat = "dr", value = -15, duration = 6 },
    },
  },
  rankable = false,
})

ability(1219, "shield_block", "Shield Block", "prot", "Ability_Defend", 1, {
  tags = { "prot", "defensive" },
  use = {
    cost = 10, cd = 8, reactive = true, resource = "rage", requires = "shield",
    effects = { { type = "buff", key = "shield_block", name = "Shield Block", stat = "blockChance", value = 40, duration = 5 } },
  },
  shopWeight = 1.4,
})

ability(1220, "shield_slam", "Shield Slam", "prot", "INV_Shield_05", 3, {
  minRound = 3, shape = S.L, tags = { "prot", "melee", "strike" },
  use = {
    cost = 20, cd = 7, resource = "rage", requires = "shield",
    effects = { { type = "damage", coef = 0.6, min = 2, max = 4, school = "physical", bankScale = 1, blockScale = 3, spendBank = "blocked" } },
  },
  triggers = { { on = "block", effects = { { type = "bank", key = "blocked", cap = { block = 2, hp = 0.25 }, fraction = 1 } } } }, shopWeight = 1.8,
})

ability(1221, "revenge", "Revenge", "prot", "Ability_Warrior_Revenge", 1, {
  shape = S.v2, tags = { "prot", "melee", "strike" },
  triggers = {
    { on = "block", icd = 2, effects = { { type = "damage", coef = 0.3, min = 1, max = 3, school = "physical", blockScale = 0.4 } } },
    { on = "dodged", icd = 2, effects = { { type = "damage", coef = 0.3, min = 1, max = 3, school = "physical", blockScale = 0.4 } } },
  },
})

ability(1222, "sunder_armor", "Sunder Armor", "shared", "Ability_Warrior_Sunder", 1, {
  tags = { "prot", "arms", "melee" },
  use = {
    cost = 10, cd = 5, resource = "rage", requires = "melee",
    effects = { { type = "debuff", key = "sunder", name = "Sunder Armor", stat = "armor", value = 12, duration = 20, maxStacks = 5, stack = true } },
  },
  adjacency = { { match = { kind = "ability", damaging = "direct", tag = "strike" }, mods = { haste = 12.5 }, side = "front" } },
})

ability(1231, "deep_wounds", "Deep Wounds", "arms", "Ability_BackStab", 1, {
  shape = S.v2, tags = { "arms", "bleed" }, stats = { crit = 5 },
  triggers = { { on = "anyCrit", match = { tag = "melee" }, effects = { { type = "dot", key = "deep_wounds", school = "physical", duration = 6, fromEvent = 0.3, rolling = true } }, healing = false } },
})


ability(1238, "blood_craze", "Blood Craze", "fury", "Spell_Shadow_SummonImp", 1, {
  shape = S.v2, tags = { "fury", "heal", "hot" },
  triggers = { { on = "damaged", icd = 6, effects = { { type = "hot", key = "blood_craze", coef = 0.1, tick = 1, duration = 4, powerStat = "ap", preserveTicks = true } }, critical = true } },
})

ability(1239, "impale", "Impale", "arms", "Ability_SearingArrow", 3, {
  shape = S.v2, tags = { "arms", "bleed" },
  triggers = {
    {
      on = "dotTick", match = { tag = "bleed" }, icd = 4, every = 3,
      effects = { { type = "buff", key = "impale_opening", name = "Impale", target = "all", match = { tag = "strike" }, stat = "critDamage", value = 30, duration = 5, charges = 1, paidOnly = true } },
    },
  },
})


ability(1250, "battle_shout", "Battle Shout", "shared", "ability_warrior_battleshout", 2, {
  tags = { "arms", "fury", "shout", "prot" },
  use = { cost = 10, cd = 15, resource = "rage", effects = { { type = "buff", key = "battle_shout", name = "Battle Shout", stat = "ap", value = 0, duration = 12, gearCoef = 0.2 } } },
})

ability(1251, "unbridled_wrath", "Unbridled Wrath", "fury", "spell_nature_stoneclawtotem", 3, {
  shape = S.v2, tags = { "fury" },
  triggers = { { on = "anyCrit", match = { tag = "autoattack" }, effects = { { type = "resource", resource = "rage", amount = 8 } }, healing = false } },
  rankable = false,
})

ability(1252, "improved_execute", "Improved Execute", "fury", "inv_sword_48", 3, {
  cost = 8, minRound = 5, shape = S.L, tags = { "arms", "fury" },
  triggers = { { on = "anyCrit", condition = "resourceAtLeast:rage:60", match = { tag = "strike" }, effects = { { type = "cast", key = "execute" } }, healing = false } },
  rankable = false, shopRequires = { "execute" }, shopWeight = 0.7,
})

ability(1253, "concussion_blow", "Concussion Blow", "prot", "ability_thunderbolt", 3, {
  cost = 8, minRound = 6, shape = S.L, tags = { "prot", "melee" },
  use = {
    cost = 20, cd = 10, resource = "rage", requires = "melee",
    effects = {
      { type = "stun", duration = 1.5 },
      { type = "buff", key = "concussion_blow", name = "Concussion Blow", match = { tag = "strike" }, stat = "none", value = 0, duration = 8, cond = "enemyBleeding", free = true },
    },
  },
  rankable = false,
})

ability(1254, "sword_specialization", "Sword Specialization", "arms", "inv_sword_27", 4, {
  shape = S.L, tags = { "arms", "fury" },
  triggers = { { on = "anyHit", match = { weaponType = "sword" }, chance = 20, effects = { { type = "extraAttack", count = 2 } } } }, rankable = false,
  shopWeight = 0.7,
})

ability(1255, "anger_management", "Anger Management", "arms", "spell_holy_blessingofstamina", 4, {
  shape = S.v3, tags = { "arms", "fury", "heal" },
  triggers = { { on = "resourceOverflow", resource = "rage", icd = 1, everyAmount = 20, effects = { { type = "heal", pctMax = 0.005 } } } },
  rankable = false,
})

ability(1256, "retaliation", "Retaliation", "shared", "ability_warrior_challange", 4, {
  minRound = 8, shape = S.sq, tags = { "arms", "prot", "melee" },
  use = { cost = 30, cd = 20, resource = "rage", requires = "melee", effects = { { type = "buff", key = "retaliation", name = "Retaliation", stat = "none", value = 0, duration = 6 } } },
  triggers = { { on = "damaged", condition = "buff:retaliation", matchAttacker = { tag = "melee" }, icd = 0.1, effects = { { type = "cast", key = "heroic_strike" } } } },
  rankable = false, shopRequires = { "heroic_strike" },
})

ability(1257, "enrage", "Enrage", "fury", "spell_shadow_unholyfrenzy", 4, {
  minRound = 8, shape = S.v3, tags = { "fury" },
  use = { cd = 3, condition = "resourceAtLeast:rage:60", effects = { { type = "buff", key = "enrage", name = "Enrage", stat = "dmgPct", value = 50, duration = 4 } } },
  rankable = false,
})

ability(1258, "sweeping_strikes", "Sweeping Strikes", "arms", "ability_rogue_slicedice", 5, {
  cost = 15, minRound = 9, shape = S.sq, tags = { "arms", "fury" },
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 40, effects = { { type = "cast", target = "neighbors", match = { tag = "strike" } } } } },
  rankable = false, shopWeight = 0.65,
})

ability(1259, "last_stand", "Last Stand", "prot", "spell_holy_ashestoashes", 5, {
  cost = 14, shape = S.L, tags = { "prot", "fury", "heal" },
  lethalSave = { duration = 5, effects = { { type = "resource", resource = "rage", amount = 100 }, { type = "extraAttack", count = 3 } }, health = 0.5 },
  rankable = false,
})

ability(1260, "slam", "Slam", "arms", "ability_warrior_decisivestrike", 2, {
  shape = S.v3, tags = { "arms", "melee", "strike" },
  use = {
    cost = 20, cd = 6, resource = "rage", requires = { "melee", "twohand" },
    effects = { { type = "damage", coef = 0.3, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1.7 } },
  },
  shopWeight = 1.5,
})

ability(1261, "improved_slam", "Improved Slam", "fury", "ability_warrior_decisivestrike", 3, { shape = S.v2, tags = { "fury" }, adjacency = { { match = { key = "slam" }, mods = { costPct = -25, haste = 30 } } }, passiveTriggers = true, shopRequires = { "slam" } })

ability(1262, "tactical_mastery", "Tactical Mastery", "arms", "spell_nature_enchantarmor", 4, {
  shape = S.v2, tags = { "arms" },
  triggers = {
    {
      on = "resourceOverflow", resource = "rage", icd = 1, everyAmount = 20,
      effects = { { type = "buff", key = "tactical_mastery", name = "Tactical Mastery", match = { tag = "strike" }, stat = "none", duration = 8, free = true } },
    },
  },
})

ability(1263, "piercing_howl", "Piercing Howl", "fury", "spell_shadow_deathscream", 2, {
  minRound = 3, tags = { "fury", "shout" },
  use = { cost = 10, cd = 8, resource = "rage", effects = { { type = "debuff", key = "piercing_howl", name = "Piercing Howl", stat = "haste", value = 25, duration = 4 } } },
  rankable = false,
})

ability(1264, "berserker_rage", "Berserker Rage", "fury", "spell_nature_ancestralguardian", 1, {
  tags = { "fury" },
  use = {
    cd = 14, initialDelay = 2,
    effects = { { type = "resource", resource = "rage", amount = 18 }, { type = "buff", key = "berserker_rage", name = "Berserker Rage", stat = "rageTakenPct", value = 50, duration = 5 } },
  },
  rankable = false,
})

ability(1265, "dual_wield_specialization", "Dual Wield Specialization", "fury", "ability_dualwield", 3, {
  shape = S.v2, tags = { "fury" },
  triggers = {
    {
      on = "battleStart", condition = "dualwield",
      effects = {
        {
          type = "buff", key = "dual_wield_specialization", name = "Dual Wield Specialization", target = "all",
          match = { kind = "weapon", anyTag = { "autoattack" }, tag = "melee" }, stat = "haste", value = 20, duration = 120,
        },
      },
    },
  },
})

ability(1266, "shield_wall", "Shield Wall", "prot", "ability_warrior_shieldwall", 4, {
  shape = S.L, tags = { "prot", "defensive" },
  use = {
    cost = 15, cd = 20, reactive = true, resource = "rage", requires = "shield", condition = "below50",
    effects = { { type = "buff", key = "shield_wall", name = "Shield Wall", stat = "dr", value = 40, duration = 5 } },
  },
  rankable = false,
})

H.Weapon{
  id = 1290, key = "worn_axe", name = "Worn Axe", icon = I("inv_axe_11"), quality = 1, classes = WARRIOR, weaponType = "axe", weaponMin = 5,
  weaponMax = 9, speed = 2.4, noShop = true, starter = true,
}

ability(1700, "charge", "Charge", "shared", "ability_warrior_charge", 2, {
  shape = S.v2, tags = { "arms", "fury", "prot" },
  triggers = { { on = "battleStart", effects = { { type = "resource", resource = "rage", amount = 25 }, { type = "cdr", target = "neighbors", match = { tag = "strike" }, amount = 2 } } } },
  rankable = false,
})

ability(1701, "cleave", "Cleave", "arms", "ability_warrior_cleave", 2, {
  shape = S.L, tags = { "arms", "fury", "melee", "strike" },
  use = { cost = 20, cd = 7, resource = "rage", requires = "melee", effects = { { type = "damage", coef = 0.3, min = 2, max = 4, school = "physical", weapon = true, weaponPct = 1.25 } } },
  adjacency = { { empty = true, selfMods = { dmgPct = 10 }, side = "left" }, { empty = true, selfMods = { dmgPct = 10 }, side = "right" } },
  shopAffinities = { WARRIOR = { arms = 0.8, fury = 1 } }, shopWeight = 1.4,
})

ability(1702, "disarm", "Disarm", "shared", "ability_warrior_disarm", 3, {
  tags = { "arms", "prot", "defensive" },
  use = { cost = 15, cd = 16, resource = "rage", requires = "melee", effects = { { type = "debuff", key = "disarm", name = "Disarm", stat = "meleePct", value = 35, duration = 6 } } },
  rankable = false,
})

ability(1703, "shield_bash", "Shield Bash", "prot", "ability_warrior_shieldbash", 2, {
  tags = { "prot", "melee", "strike" },
  use = {
    cost = 10, cd = 10, resource = "rage", requires = "shield",
    effects = { { type = "damage", coef = 0.25, min = 1, max = 3, school = "physical", blockScale = 2 }, { type = "purge", count = 1 } },
  },
  shopWeight = 1.5,
})


ability(1900, "hamstring", "Hamstring", "arms", "ability_shockwave", 1, {
  tags = { "arms", "melee", "strike" },
  use = {
    cost = 8, cd = 8, resource = "rage", requires = "melee",
    effects = {
      { type = "damage", coef = 0.15, min = 1, max = 2, school = "physical" },
      { type = "debuff", key = "hamstring", name = "Hamstring", stat = "haste", value = 15, duration = 8 },
      { type = "buff", key = "hamstring_opening", name = "Hamstring", stat = "crit", value = 8, duration = 8, cond = "enemyBleeding" },
    },
  },
})

ability(1901, "mace_specialization", "Mace Specialization", "arms", "inv_mace_01", 3, { shape = S.v2, tags = { "arms" }, triggers = { { on = "anyHit", match = { weaponType = "mace" }, chance = 15, effects = { { type = "stun", duration = 1 } } } }, rankable = false })

ability(1902, "axe_specialization", "Axe Specialization", "arms", "inv_axe_06", 3, {
  minRound = 5, shape = S.v2, tags = { "arms" },
  triggers = { { on = "anyCrit", match = { weaponType = "axe" }, effects = { { type = "tickDots", match = { tag = "bleed" } } }, healing = false } },
  rankable = false,
})



ability(1903, "improved_overpower", "Improved Overpower", "arms", "inv_sword_05", 4, {
  shape = S.L, tags = { "arms" },
  triggers = { { on = "anyCrit", match = { key = "overpower" }, icd = 2, effects = { { type = "cast", key = "mortal_strike" } }, healing = false } },
  rankable = false, shopRequires = { "overpower", "mortal_strike" },
})

ability(1904, "improved_rend", "Improved Rend", "arms", "ability_gouge", 2, {
  minRound = 3, shape = S.v2, tags = { "arms" },
  triggers = {
    {
      on = "dotTick", match = { tag = "bleed" }, everyAmount = 18,
      effects = { { type = "resource", resource = "rage", amount = 3 }, { type = "cdr", target = "all", match = { key = "slam" }, amount = 1 } },
    },
  },
  rankable = false, shopRequires = { "rend" },
})

ability(1905, "demoralizing_shout", "Demoralizing Shout", "fury", "ability_warrior_warcry", 1, {
  tags = { "fury", "shout" },
  use = {
    cost = 10, cd = 12, resource = "rage",
    effects = {
      { type = "debuff", key = "demoralizing_shout", name = "Demoralizing Shout", stat = "ap", value = 16, duration = 10 },
      { type = "debuff", key = "demoralizing_shout_damage", name = "Demoralizing Shout", stat = "dmgPct", value = 10, duration = 8 },
    },
  },
})

ability(1906, "cruelty", "Cruelty", "fury", "ability_rogue_eviscerate", 3, {
  shape = S.v2, tags = { "fury", "heal" },
  triggers = { { on = "anyCrit", condition = "enemyBleeding", match = { tag = "melee" }, effects = { { type = "heal", fromEvent = 0.15 } }, healing = false } },
  rankable = false,
})

ability(1907, "pummel", "Pummel", "fury", "inv_gauntlets_04", 4, {
  tags = { "fury", "melee", "strike" },
  use = {
    cost = 15, cd = 9, resource = "rage", requires = "melee",
    effects = {
      { type = "damage", coef = 0.2, min = 1, max = 3, school = "physical" }, { type = "drain", resource = "mana", amount = 15 },
      { type = "debuff", key = "pummel", name = "Pummel", stat = "spellPct", value = 20, duration = 5 },
    },
  },
})

ability(1908, "improved_berserker_rage", "Improved Berserker Rage", "fury", "spell_nature_ancestralguardian", 5, {
  cost = 15, shape = S.sq, tags = { "fury" },
  triggers = { { on = "resourceGained", resource = "rage", condition = "buff:berserker_rage", everyAmount = 25, effects = { { type = "extraAttack", count = 1 } } } },
  rankable = false, shopRequires = { "berserker_rage" },
})

ability(1909, "thunder_clap", "Thunder Clap", "prot", "spell_nature_thunderclap", 2, {
  tags = { "prot", "melee", "spell" },
  use = {
    cost = 12, cd = 8, resource = "rage",
    effects = {
      { type = "damage", coef = 0.3, min = 1, max = 3, school = "physical", noDodge = true },
      { type = "debuff", key = "thunder_clap", name = "Thunder Clap", stat = "haste", value = 20, duration = 6 },
    },
  },
})

ability(1910, "defensive_stance", "Defensive Stance", "prot", "ability_warrior_defensivestance", 1, {
  shape = S.v2, tags = { "prot", "defensive" }, stats = { dmgPct = -10, dr = 10 }, exclusiveGroup = "warrior_stance", exclusiveLabel = "Stance",
  adjacency = { { match = { tag = "defensive" }, corners = true, mods = { costPct = -20 } } },
})

ability(1911, "defiance", "Defiance", "prot", "ability_warrior_innerrage", 3, {
  shape = S.v2, tags = { "prot" },
  triggers = { { on = "block", effects = { { type = "buff", key = "defiance", name = "Defiance", stat = "ap", value = 0, duration = 6, fromEvent = 0.75, maxStacks = 5, stack = true } } } },
  rankable = false,
})

ability(1912, "improved_shield_block", "Improved Shield Block", "prot", "ability_defend", 2, {
  minRound = 3, shape = S.v2, tags = { "prot" },
  triggers = {
    {
      on = "block", condition = "buff:shield_block",
      effects = { { type = "resource", resource = "rage", amount = 4 }, { type = "cdr", target = "all", match = { key = "shield_slam" }, amount = 0.5 } },
    },
  },
  rankable = false, shopRequires = { "shield_block" },
})

ability(1913, "improved_revenge", "Improved Revenge", "prot", "ability_warrior_revenge", 3, {
  minRound = 5, shape = S.v2, tags = { "prot" },
  triggers = { { on = "anyHit", match = { key = "revenge" }, chance = 25, effects = { { type = "stun", duration = 1 } } } }, rankable = false,
  shopRequires = { "revenge" },
})

ability(1914, "improved_shield_wall", "Improved Shield Wall", "prot", "ability_warrior_shieldwall", 4, {
  minRound = 8, shape = S.v2, tags = { "prot", "heal" },
  triggers = { { on = "anyUse", match = { key = "shield_wall" }, effects = { { type = "heal", pctMax = 0.2 }, { type = "cleanse", count = 2, debuffs = true } } } },
  rankable = false, shopRequires = { "shield_wall" },
})

ability(1915, "shield_specialization", "Shield Specialization", "prot", "inv_shield_06", 5, {
  cost = 15, minRound = 11, shape = S.sq, tags = { "prot", "melee" },
  triggers = { { on = "block", effects = { { type = "cast", key = "shield_block" }, { type = "damage", school = "physical", fromEvent = 0.75, noCrit = true, noDodge = true } } } },
  rankable = false, shopWeight = 0.65,
})

ability(1916, "iron_will", "Iron Will", "prot", "spell_magic_magearmor", 4, {
  shape = S.v2, tags = { "prot", "defensive" },
  triggers = { { on = "stunned", effects = { { type = "buff", key = "iron_will", name = "Iron Will", stat = "dr", value = 50, duration = 3 }, { type = "resource", resource = "rage", amount = 15 } } } },
  rankable = false,
})

ability(1917, "warrior_anticipation", "Anticipation", "prot", "spell_nature_mirrorimage", 2, {
  shape = S.v2, tags = { "prot", "defensive" }, stats = { blockChance = 5, dodge = 3 },
  triggers = { { on = "dodged", icd = 2, effects = { { type = "cdr", target = "all", match = { kind = "ability", damaging = "direct", tag = "strike" }, amount = 0.75, clampReady = true } } } },
})


ability(1923, "berserker_stance", "Berserker Stance", "fury", "ability_racial_avatar", 3, {
  shape = S.v3, tags = { "fury", "stance" }, stats = { dr = -10 }, exclusiveGroup = "warrior_stance", exclusiveLabel = "Stance",
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "berserker_stance", name = "Berserker Stance", stat = "crit", value = 3, duration = 120, gearCoef = 0.25, gearStat = "crit", rankScale = false } },
    },
  },
  shopWeight = 0.6,
})

ability(1930, "battle_stance", "Battle Stance", "shared", "ability_warrior_offensivestance", 2, {
  shape = S.L, tags = { "arms", "fury", "stance" }, exclusiveGroup = "warrior_stance", exclusiveLabel = "Stance",
  triggers = {
    {
      on = "targetDodged", match = { kind = "weapon", anyTag = { "autoattack" }, tag = "melee" }, icd = 2,
      effects = {
        { type = "resource", resource = "rage", amount = 4, rankScale = false },
        { type = "cdr", target = "all", match = { kind = "ability", anyTag = { "strike" }, damaging = "direct", tag = "melee" }, amount = 0.5 },
      },
    },
  },
  shopWeight = 0.8,
})



ability(1931, "intercept", "Intercept", "fury", "ability_rogue_sprint", 2, {
  minRound = 3, shape = S.h2, tags = { "arms", "fury", "melee", "strike", "control" },
  use = {
    cost = 15, cd = 14, resource = "rage", requires = "melee",
    effects = { { type = "damage", coef = 0.35, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1 }, { type = "stun", duration = 0.5, rankScale = false } },
  },
  adjacency = { { empty = true, selfMods = { dmgPct = 10 }, side = "front" } }, shopAffinities = { WARRIOR = { arms = 0.8, fury = 1, prot = 0.4 } },
  shopWeight = 1.2,
})

ability(1932, "intimidating_shout", "Intimidating Shout", "shared", "ability_golemthunderclap", 3, {
  cost = 7, shape = { "10", "10", "11" }, tags = { "arms", "fury", "prot", "shout", "defensive", "control" },
  use = { cost = 20, cd = 18, reactive = true, resource = "rage", condition = "below50", effects = { { type = "stun", duration = 1, controlType = "fear", rankScale = false } } },
  shopWeight = 0.8,
})

ability(1933, "one_handed_weapon_specialization", "One-Handed Weapon Specialization", "prot", "inv_sword_20", 2, {
  minRound = 3, shape = S.L, tags = { "prot", "fury" },
  adjacency = { { match = { kind = "weapon", hands = 1, tag = "melee" }, corners = true, mods = { dmgPct = 12.5 } } }, rankable = false,
  shopAffinities = { WARRIOR = { arms = 0.3, fury = 0.8, prot = 1 } }, shopWeight = 0.9,
})

ability(1934, "two_handed_weapon_specialization", "Two-Handed Weapon Specialization", "arms", "inv_axe_09", 2, {
  minRound = 3, shape = { "111" }, tags = { "arms", "fury" },
  adjacency = { { match = { kind = "weapon", hands = 2, tag = "melee" }, mods = { dmgPct = 25 }, side = "back" } }, rankable = false,
  shopAffinities = { WARRIOR = { arms = 1, fury = 0.8 } }, shopWeight = 0.9,
})

ability(1935, "deflection", "Deflection", "arms", "ability_parry", 2, {
  tags = { "arms", "prot", "defensive" },
  triggers = { { on = "dodged", icd = 2, effects = { { type = "cdr", target = "all", match = { kind = "weapon", tag = "melee" }, amount = 0.25, clampReady = true } } } },
  adjacency = { { stats = { dodge = 5 }, once = true, match = { kind = "weapon", tag = "melee" }, side = "front" } },
  shopAffinities = { WARRIOR = { arms = 0.8, fury = 0.4, prot = 1 } },
})

ability(1936, "booming_voice", "Booming Voice", "fury", "spell_nature_purge", 2, {
  cost = 5, shape = S.T, tags = { "fury", "support" },
  adjacency = { { match = { notTag = "control", tag = "shout" }, mods = { haste = 12.5 }, side = "front" } }, rankable = false,
  shopAffinities = { WARRIOR = { arms = 0.6, fury = 1, prot = 0.6 } }, shopWeight = 0.8,
})



ability(1937, "improved_cleave", "Improved Cleave", "fury", "ability_warrior_cleave", 2, {
  minRound = 3, shape = S.L, tags = { "fury", "arms", "melee" },
  triggers = {
    {
      on = "anyHit", match = { key = "cleave" },
      effects = { { type = "damage", school = "physical", noCrit = true, noDodge = true, noOwnTriggers = true, weapon = true, weaponPct = 0.75 } },
      healing = false,
    },
  },
  shopRequires = { "cleave" }, shopWeight = 0.9,
})

ability(1938, "improved_bloodrage", "Improved Bloodrage", "prot", "ability_racial_bloodrage", 2, {
  cost = 4, tags = { "prot", "arms", "fury" },
  triggers = { { on = "anyUse", match = { key = "bloodrage" }, effects = { { type = "resource", resource = "rage", amount = 4 } } } },
  shopAffinities = { WARRIOR = { arms = 0.8, fury = 1, prot = 0.6 } }, shopRequires = { "bloodrage" }, shopWeight = 0.9,
})


ability(1939, "toughness", "Toughness", "prot", "spell_holy_devotion", 2, {
  cost = 5, minRound = 3, shape = S.T, tags = { "prot", "defensive" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "toughness", name = "Toughness", stat = "armor", value = 0, duration = 120, gearCoef = 0.125, gearStat = "armor", rankScale = false } },
    },
  },
  shopAffinities = { WARRIOR = { arms = 0.6, fury = 0.3, prot = 1 } },
})

ability(1940, "improved_shield_bash", "Improved Shield Bash", "prot", "ability_warrior_shieldbash", 3, {
  cost = 7, shape = { "110", "011" }, tags = { "prot", "defensive", "support" },
  triggers = {
    {
      on = "anyHit", match = { key = "shield_bash" }, icd = 8,
      effects = { { type = "debuff", key = "improved_shield_bash", name = "Improved Shield Bash", stat = "spellPct", value = 25, duration = 3, rankScale = false } },
      healing = false,
    },
  },
  shopRequires = { "shield_bash" }, shopWeight = 0.9,
})
