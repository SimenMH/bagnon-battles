local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local HUNTER = { "HUNTER" }
local ability = H.QualityAbilities(HUNTER)



ability(1400, "aimed_shot", "Aimed Shot", "mm", "INV_Spear_07", 3, {
  shape = S.L, tags = { "mm", "shot", "ranged" },
  use = {
    cost = 20, cd = 5, resource = "mana", requires = "ranged",
    effects = {
      {
        type = "damage", coef = 0.65, min = 3, max = 5, school = "physical", consumeDots = { match = { tag = "poison" }, fraction = 0.35 },
        critIf = "enemyStunned", ranged = true, weapon = true, weaponPct = 1.25,
      },
    },
  },
  shopWeight = 1.8,
})

ability(1401, "multi_shot", "Multi-Shot", "mm", "Ability_UpgradeMoonGlaive", 2, {
  tags = { "mm", "shot", "ranged" },
  use = {
    cost = 16, cd = 8, resource = "mana", requires = "ranged",
    effects = {
      { type = "damage", coef = 0.2, min = 1, max = 3, school = "physical", ranged = true, weapon = true, weaponPct = 0.65 },
      { type = "damage", coef = 0.2, min = 1, max = 3, school = "physical", ranged = true, weapon = true, weaponPct = 0.65 },
      { type = "damage", coef = 0.2, min = 1, max = 3, school = "physical", cond = "enemyPoisoned", ranged = true, weapon = true, weaponPct = 0.65 },
    },
  },
  shopWeight = 1.4,
})

ability(1402, "arcane_shot", "Arcane Shot", "mm", "Ability_ImpalingBolt", 1, {
  tags = { "mm", "shot", "ranged", "arcane" },
  use = { cost = 10, cd = 6, resource = "mana", requires = "ranged", effects = { { type = "damage", coef = 0.65, min = 2, max = 4, school = "arcane", noDodge = true, ranged = true } } },
  triggers = { { on = "resourceSpent", resource = "mana", match = { key = "arcane_shot" }, effects = { { type = "resource", resource = "focus", fromEvent = 0.5 } } } },
  shopAffinities = { HUNTER = { bm = 0.6, mm = 1, surv = 0.4 } }, shopWeight = 1.6,
})

ability(1403, "serpent_sting", "Serpent Sting", "surv", "Ability_Hunter_Quickshot", 1, {
  tags = { "surv", "sting", "poison", "ranged", "dot", "nature" },
  use = {
    cost = 12, cd = 15, initialDelay = 1.5, resource = "mana", requires = "ranged",
    effects = { { type = "dot", key = "serpent_sting", coef = 0.075, tick = 0, school = "nature", duration = 15, maxStacks = 5, preserveTicks = true, stack = true } },
  },
  shopWeight = 1.5,
})



ability(1404, "concussive_shot", "Concussive Shot", "mm", "Spell_Frost_Stun", 2, {
  minRound = 3, tags = { "mm", "shot", "ranged" },
  use = {
    cost = 10, cd = 10, resource = "mana", requires = "ranged",
    effects = {
      { type = "damage", min = 2, max = 3, school = "physical", ranged = true }, { type = "stun", duration = 1 },
      { type = "buff", key = "concussive_opening", name = "Concussive Shot", target = "all", match = { kind = "pet" }, stat = "crit", value = 100, duration = 6, charges = 1 },
    },
  },
})

ability(1405, "scatter_shot", "Scatter Shot", "mm", "Ability_GolemStormBolt", 3, {
  minRound = 5, tags = { "surv", "mm", "shot", "ranged" },
  use = {
    cost = 15, cd = 20, resource = "mana", requires = "ranged",
    effects = { { type = "damage", coef = 0.1, school = "physical", ranged = true, weapon = true, weaponPct = 0.5 }, { type = "stun", duration = 2 } },
  },
})

ability(1406, "rapid_fire", "Rapid Fire", "mm", "Ability_Hunter_RunningShot", 4, {
  tags = { "mm" },
  use = {
    cost = 20, cd = 25, initialDelay = 4, resource = "mana",
    effects = { { type = "buff", key = "rapid_fire", name = "Rapid Fire", target = "all", match = { tag = "ranged" }, stat = "haste", value = 50, duration = 8 } },
  },
})

ability(1407, "hunters_mark", "Hunter's Mark", "mm", "Ability_Hunter_SniperShot", 1, {
  shape = S.v2, tags = { "mm" },
  triggers = {
    { on = "battleStart", effects = { { type = "buff", name = "Hunter's Mark", stat = "rangedPct", value = 10, duration = 120 } } },
    {
      on = "regularHit", match = { anyWeaponType = { "bow", "gun", "crossbow" } },
      effects = { { type = "debuff", key = "hunters_mark", name = "Hunter's Mark", stat = "armor", value = 4, duration = 12, maxStacks = 5, stack = true } },
    },
  },
})



ability(1409, "volley", "Volley", "mm", "Ability_Marksmanship", 2, {
  minRound = 4, shape = S.sq, tags = { "mm", "ranged", "arcane", "dot", "channel" },
  use = {
    cost = 30, cd = 14, channel = { key = "volley", duration = 6 }, resource = "mana", requires = "ranged",
    effects = { { type = "dot", key = "volley", coef = 0.75, tick = 1, school = "arcane", duration = 6, preserveTicks = true } },
  },
})


ability(1410, "aspect_of_the_hawk", "Aspect of the Hawk", "mm", "Spell_Nature_RavenForm", 1, {
  kind = "form", shape = S.v2, tags = { "aspect", "mm" }, provides = { "aspect", "hawk" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        {
          type = "buff", key = "aspect_hawk", name = "Aspect of the Hawk", target = "all", match = { tag = "ranged" }, stat = "ap", value = 4,
          duration = 90, gearCoef = 0.2, gearStat = "ap",
        },
      },
    },
    { on = "anyCrit", match = { anyWeaponType = { "bow", "gun", "crossbow" } }, effects = { { type = "resource", resource = "mana", fromEvent = 0.15 } }, healing = false },
  },
})

ability(1411, "aspect_of_the_monkey", "Aspect of the Monkey", "shared", "Ability_Hunter_AspectOfTheMonkey", 1, {
  kind = "form", shape = S.v2, tags = { "aspect", "surv", "defensive" }, stats = { dodge = 8 }, provides = "aspect",
  triggers = { { on = "dodged", effects = { { type = "resource", resource = "focus", amount = 8 } } } },
})

ability(1412, "aspect_of_the_beast", "Aspect of the Beast", "shared", "Ability_Mount_PinkTiger", 2, {
  kind = "form", shape = S.v2, tags = { "aspect", "bm", "surv" }, stats = { meleePct = 10, petPct = 10 }, provides = "aspect",
  triggers = { { on = "resourceSpent", resource = "focus", effects = { { type = "resource", resource = "mana", fromEvent = 0.15 } } } },
})

ability(1413, "bestial_wrath", "Bestial Wrath", "bm", "Ability_Druid_FerociousBite", 5, {
  minRound = 9, shape = S.L, tags = { "bm" },
  use = {
    cost = 32, cd = 24, initialDelay = 6, resource = "mana", requires = "pet",
    effects = {
      { type = "buff", key = "bestial_wrath_power", name = "Bestial Wrath", stat = "petPct", value = 60, duration = 8 },
      { type = "buff", key = "bestial_wrath", name = "Bestial Wrath", stat = "none", value = 0, duration = 8, double = { kind = "pet" } },
      { type = "resource", resource = "focus", amount = 40 },
    },
  },
})

ability(1414, "intimidation", "Intimidation", "bm", "Ability_Devour", 3, {
  tags = { "bm" },
  use = {
    cost = 18, cd = 18, resource = "mana", requires = "pet",
    effects = { { type = "stun", duration = 2 }, { type = "buff", key = "intimidation", name = "Intimidation", target = "all", match = { kind = "pet" }, stat = "crit", value = 35, duration = 3 } },
  },
})

ability(1415, "bestial_discipline", "Bestial Discipline", "bm", "Spell_Nature_AbolishMagic", 2, { minRound = 3, shape = S.v2, tags = { "bm" }, grants = { focus = { max = 100, regen = 8, start = 20 } } })

ability(1416, "frenzy", "Frenzy", "bm", "INV_Misc_MonsterClaw_03", 4, {
  shape = S.v2, tags = { "bm" },
  triggers = {
    {
      on = "anyCrit", match = { kind = "pet" },
      effects = { { type = "buff", key = "frenzy", name = "Frenzy", target = "all", match = { kind = "pet" }, stat = "haste", value = 10, duration = 8, maxStacks = 5, stack = true } },
      healing = false,
    },
  },
})

ability(1419, "pet_wolf", "Pet: Wolf", "bm", "Ability_Hunter_Pet_Wolf", 2, {
  minRound = 1, kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm" }, provides = "wolf",
  grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 2, effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", pet = true } } },
  triggers = {
    { on = "hit", effects = { { type = "bank", key = "wolf_howl", cap = { hp = 0.2 }, fraction = 0.35 } } },
    { on = "regularHit", match = { kind = "weapon" }, effects = { { type = "damage", school = "physical", noCrit = true, noDodge = true, noOwnTriggers = true, spendBank = "wolf_howl" } } },
  },
  shopWeight = 1.2,
})

ability(1420, "pet_cat", "Pet: Cat", "bm", "Ability_Hunter_Pet_Cat", 1, {
  kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm" }, provides = "cat", grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 1.6, effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", critBonus = 10, pet = true } } },
  triggers = { { on = "resourceSpent", resource = "focus", everyAmount = 25, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } },
  shopWeight = 1.4,
})

ability(1421, "pet_bear", "Pet: Bear", "bm", "Ability_Hunter_Pet_Bear", 2, {
  kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm", "defensive" }, stats = { armor = 10, hp = 35 },
  grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 2.4, effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", pet = true } } },
  triggers = { { on = "hit", effects = { { type = "absorb", fromEvent = 0.25 } } } },
})

ability(1422, "pet_boar", "Pet: Boar", "bm", "Ability_Hunter_Pet_Boar", 1, {
  kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm" }, grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 2, effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", pet = true } } },
  triggers = { { on = "dodged", effects = { { type = "damage", coef = 0.2, min = 4, max = 6, school = "physical", noDodge = true, pet = true }, { type = "stun", duration = 0.75 } } } },
  shopWeight = 1.2,
})

ability(1423, "pet_raptor", "Pet: Raptor", "bm", "Ability_Hunter_Pet_Raptor", 3, {
  kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm" }, stats = { crit = 2 }, grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", pet = true } } },
  triggers = {
    { on = "crit", effects = { { type = "dot", key = "raptor_bleed", tick = 0, school = "physical", duration = 6, fromEvent = 0.3, rolling = true } } },
    { on = "dotTick", match = { tag = "bleed" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.2 } } },
  },
})



ability(1424, "pet_scorpid", "Pet: Scorpid", "bm", "Ability_Hunter_Pet_Scorpid", 2, {
  minRound = 3, kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm", "poison", "nature" },
  grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = {
    cd = 2,
    effects = {
      { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", pet = true },
      { type = "dot", key = "scorpid_poison", coef = 0.025, tick = 1, school = "nature", duration = 10, maxStacks = 5, stack = true },
    },
  },
  triggers = {
    { on = "dotTick", match = { anyTag = { "sting", "poison" } }, icd = 1, everyAmount = 10, effects = { { type = "resource", resource = "focus", amount = 3 } } },
    { on = "resourceSpent", resource = "focus", everyAmount = 25, effects = { { type = "tickDots", match = { tag = "poison" } } } },
  },
})

ability(1425, "pet_wind_serpent", "Pet: Wind Serpent", "bm", "Ability_Hunter_Pet_WindSerpent", 3, {
  minRound = 5, kind = "pet", shape = S.sq, tags = { "pet", "autoattack", "bm" }, grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 2.4, effects = { { type = "damage", coef = 0.55, min = 1, max = 3, school = "nature", noDodge = true, pet = true, spendBank = "wind_serpent" } } },
  triggers = { { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "wind_serpent", fraction = 0.75 } } } },
})

ability(1426, "bite", "Bite", "bm", "Ability_Racial_Cannibalize", 1, {
  tags = { "pet", "bm" }, actor = "pet",
  use = {
    cost = 25, cd = 5, resource = "focus", requires = "pet",
    effects = { { type = "damage", coef = 0.55, min = 1, max = 3, school = "physical", perPoint = 0.1, pet = true, pointResource = "focus" } },
    spendAll = true,
  },
  shopWeight = 1.5,
})

ability(1427, "claw_pet", "Claw", "bm", "Ability_Druid_Rake", 1, {
  tags = { "pet", "bm" }, actor = "pet",
  use = { cost = 25, cd = 3, resource = "focus", requires = "pet", effects = { { type = "damage", coef = 0.45, min = 1, max = 3, school = "physical", pet = true } } },
  shopWeight = 1.4,
})

ability(1428, "screech", "Screech", "bm", "Ability_Hunter_Pet_Bat", 2, {
  minRound = 3, tags = { "pet", "bm" }, actor = "pet",
  use = {
    cost = 20, cd = 6, resource = "focus", requires = "pet",
    effects = { { type = "debuff", key = "screech", exclusiveGroup = "attack_power_reduction", stat = "ap", value = 12, duration = 8, maxStacks = 3, stack = true } },
  },
})

ability(1429, "raptor_strike", "Raptor Strike", "surv", "Ability_MeleeDamage", 1, {
  tags = { "surv", "melee", "strike" },
  use = { cost = 15, cd = 6, resource = "mana", requires = "melee", effects = { { type = "damage", coef = 0.4, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1.25 } } },
  triggers = { { on = "resourceSpent", resource = "mana", match = { key = "raptor_strike" }, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } },
  shopAffinities = { HUNTER = { bm = 0.5, surv = 1 } }, shopWeight = 1.6,
})

ability(1430, "mongoose_bite", "Mongoose Bite", "surv", "Ability_Hunter_SwiftStrike", 2, {
  minRound = 3, shape = S.v2, tags = { "surv", "melee" },
  triggers = {
    { on = "dodged", condition = "provides:melee", icd = 2, effects = { { type = "damage", coef = 0.6, min = 2, max = 4, school = "physical", noDodge = true } } },
    { on = "hit", effects = { { type = "resource", resource = "focus", fromEvent = 0.2 } } },
  },
})

ability(1431, "wing_clip", "Wing Clip", "surv", "Ability_Rogue_Trip", 1, {
  tags = { "surv", "melee" },
  use = {
    cost = 10, cd = 10, resource = "mana", requires = "melee",
    effects = { { type = "damage", min = 2, max = 4, school = "physical" }, { type = "debuff", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 15, duration = 10 } },
  },
})

ability(1432, "counterattack", "Counterattack", "surv", "Ability_Warrior_Challange", 3, {
  minRound = 5, shape = S.v2, tags = { "surv", "melee" },
  triggers = {
    {
      on = "dodged", condition = "provides:melee", icd = 5,
      effects = { { type = "damage", coef = 0.65, min = 2, max = 4, school = "physical", noDodge = true }, { type = "stun", duration = 1.5 } },
    },
  },
})

ability(1433, "deterrence", "Deterrence", "surv", "Ability_Whirlwind", 4, {
  tags = { "surv", "defensive" },
  use = { cd = 24, reactive = true, condition = "below50", effects = { { type = "buff", key = "deterrence", name = "Deterrence", stat = "dodge", value = 45, duration = 8 } } },
})

ability(1434, "immolation_trap", "Immolation Trap", "surv", "Spell_Fire_FlameShock", 1, {
  tags = { "surv", "trap", "fire", "dot" },
  use = { cd = 25, initialDelay = 2, effects = { { type = "dot", key = "immolation_trap", coef = 0.1, tick = 1, school = "fire", duration = 10, rolling = true } } },
  triggers = {
    {
      on = "resourceSpent", resource = "focus", condition = "enemyHas:immolation_trap",
      effects = { { type = "dot", key = "immolation_trap", tick = 0, school = "fire", duration = 10, fromEvent = 0.5, rolling = true } },
    },
  },
})

ability(1435, "explosive_trap", "Explosive Trap", "surv", "Spell_Fire_SelfDestruct", 2, {
  minRound = 3, tags = { "surv", "trap", "fire", "dot" },
  use = {
    cd = 25, initialDelay = 2,
    effects = {
      { type = "damage", coef = 0.45, min = 2, max = 4, school = "fire", consumeDots = { match = { tag = "fire" }, fraction = 0.35 }, noDodge = true },
      { type = "dot", key = "explosive_trap", coef = 0.1, tick = 1, school = "fire", duration = 10 },
    },
  },
})

ability(1436, "freezing_trap", "Freezing Trap", "surv", "Spell_Frost_ChainsOfIce", 2, {
  tags = { "surv", "trap", "frost" },
  use = { cd = 30, initialDelay = 2, effects = { { type = "stun", duration = 3 }, { type = "debuff", key = "freezing_trap", name = "Freezing Trap", stat = "dr", value = 20, duration = 3 } } },
})

ability(1440, "wyvern_sting", "Wyvern Sting", "surv", "INV_Spear_02", 5, {
  shape = S.L, tags = { "surv", "sting", "poison", "ranged", "nature", "dot" },
  use = {
    cost = 32, cd = 24, initialDelay = 4, resource = "mana", requires = "ranged",
    effects = {
      { type = "stun", duration = 3, controlType = "sleep" },
      { type = "dot", key = "wyvern_sting", coef = 0.12, tick = 8, school = "nature", duration = 12 },
      { type = "tickDots", match = { tag = "poison" } },
    },
  },
  triggers = { { on = "dotTick", match = { tag = "poison" }, icd = 1, everyAmount = 50, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } },
})

ability(1442, "mortal_shots", "Mortal Shots", "mm", "Ability_PierceDamage", 3, {
  shape = S.v2, tags = { "mm" },
  triggers = { { on = "anyCrit", match = { tag = "shot" }, effects = { { type = "damage", school = "physical", fromEvent = 0.25, noCrit = true, noDodge = true, ranged = true } }, healing = false } },
})

ability(1445, "rough_arrows", "Rough Arrows", "shared", "inv_ammo_arrow_02", 1, { cost = 2, kind = "ammo", tags = { "ammo" }, adjacency = { { match = { anyWeaponType = { "bow", "gun", "crossbow" } }, mods = { flat = 2 } } }, starter = true })

ability(1447, "razor_arrows", "Razor Arrows", "shared", "inv_ammo_arrow_02", 3, {
  cost = 4, minRound = 6, kind = "ammo", tags = { "ammo" },
  triggers = {
    {
      on = "adjacentCrit", match = { anyWeaponType = { "bow", "gun", "crossbow" } },
      effects = { { type = "dot", key = "razor_bleed", coef = 0.04, tick = 3, school = "physical", duration = 6 } },
    },
  },
  adjacency = { { match = { anyWeaponType = { "bow", "gun", "crossbow" } }, mods = { flat = 5 } } },
})

ability(1448, "thorium_headed_arrows", "Thorium Headed Arrows", "shared", "inv_ammo_arrow_02", 3, {
  cost = 5, minRound = 9, kind = "ammo", tags = { "ammo" },
  triggers = {
    {
      on = "adjacentHit", match = { anyWeaponType = { "bow", "gun", "crossbow" } },
      effects = { { type = "debuff", key = "thorium_sunder", name = "Thorium Headed Arrows", stat = "armor", value = 6, duration = 10, maxStacks = 5, stack = true } },
    },
  },
  adjacency = { { match = { anyWeaponType = { "bow", "gun", "crossbow" } }, mods = { flat = 6 } } },
})

ability(1449, "ice_threaded_arrows", "Ice Threaded Arrows", "shared", "spell_frost_iceshard", 4, {
  cost = 6, minRound = 12, kind = "ammo", tags = { "ammo" },
  triggers = {
    {
      on = "adjacentHit", match = { anyWeaponType = { "bow", "gun", "crossbow" } },
      effects = { { type = "debuff", key = "ice_chill", name = "Ice Threaded Arrows", stat = "haste", value = 5, duration = 6, maxStacks = 4, stack = true } },
    },
  },
  adjacency = { { match = { anyWeaponType = { "bow", "gun", "crossbow" } }, mods = { flat = 8 } } },
})

H.Weapon{
  id = 1450, key = "worn_shortbow", name = "Worn Shortbow", icon = I("inv_weapon_bow_05"), quality = 1, cost = 3, classes = HUNTER, weaponType = "bow",
  weaponMin = 12, weaponMax = 15, speed = 2.4, noShop = true, starter = true,
}

H.Weapon{
  id = 1452, key = "heavy_crossbow", name = "Heavy Crossbow", icon = I("inv_weapon_crossbow_03"), quality = 2, minRound = 2, classes = HUNTER,
  weaponType = "crossbow", weaponMin = 18, weaponMax = 24, speed = 3,
  triggers = { { on = "hit", chance = 25, effects = { { type = "debuff", key = "heavy_bolt", name = "Heavy Crossbow", stat = "armor", value = 5, duration = 6, maxStacks = 3, stack = true } } } },
}

H.Weapon{
  id = 1453, key = "blackcrow", name = "Blackcrow", icon = I("inv_weapon_crossbow_04"), quality = 3, minRound = 5, classes = HUNTER,
  weaponType = "crossbow", weaponMin = 20, weaponMax = 26, speed = 2.6, stats = { crit = 1 },
  triggers = { { on = "hit", condition = "enemyStunned", effects = { { type = "resource", resource = "mana", amount = 5 } } } },
}

H.Weapon{
  id = 1454, key = "carapace_spine_crossbow", name = "Carapace Spine Crossbow", icon = I("inv_weapon_crossbow_04"), quality = 3, minRound = 6,
  classes = HUNTER, tags = { "poison" }, weaponType = "crossbow", weaponMin = 22, weaponMax = 29, speed = 3, stats = { ap = 6 },
  triggers = { { on = "hit", chance = 25, effects = { { type = "dot", key = "carapace_venom", coef = 0.04, tick = 3, school = "nature", duration = 6 } } } },
}

H.Weapon{
  id = 1455, key = "dwarven_hand_cannon", name = "Dwarven Hand Cannon", icon = I("inv_weapon_rifle_09"), quality = 3, minRound = 7, classes = HUNTER,
  weaponType = "gun", weaponMin = 23, weaponMax = 30, speed = 3.2,
  triggers = { { on = "hit", chance = 15, icd = 4, effects = { { type = "stun", duration = 0.5 } } } },
}

H.Weapon{
  id = 1456, key = "rhokdelar", name = "Rhok'delar, Longbow of the Ancient Keepers", icon = I("inv_weapon_bow_01"), quality = 4, minRound = 11,
  classes = HUNTER, weaponType = "bow", weaponMin = 28, weaponMax = 36, speed = 2.9, stats = { ap = 8, crit = 2 },
  triggers = { { on = "crit", effects = { { type = "cdr", target = "all", match = { tag = "shot" }, amount = 1 } } } },
}

H.Weapon{
  id = 1457, key = "ashjrethul", name = "Ashjre'thul, Crossbow of Smiting", icon = I("inv_weapon_crossbow_09"), quality = 4, minRound = 13,
  classes = HUNTER, weaponType = "crossbow", weaponMin = 30, weaponMax = 38, speed = 3.2, stats = { ap = 10 },
  use = { cd = 3.2, effects = { { type = "damage", coef = 0.48, school = "physical", critIf = "enemyStunned", ranged = true, weaponSelf = true } } },
}

H.Weapon{
  id = 1458, key = "core_marksman_rifle", name = "Core Marksman Rifle", icon = I("inv_weapon_rifle_05"), quality = 4, minRound = 12, classes = HUNTER,
  weaponType = "gun", weaponMin = 26, weaponMax = 34, speed = 2.8, stats = { crit = 3 },
  triggers = { { on = "crit", effects = { { type = "damage", min = 10, max = 14, school = "fire", noDodge = true } } } },
}

ability(1462, "feed_pet", "Feed Pet", "shared", "Ability_Hunter_BeastTraining", 1, { tags = { "bm", "pet" }, use = { cd = 10, requires = "pet", effects = { { type = "resource", resource = "focus", amount = 20 } } } })

ability(1463, "spirit_bond", "Spirit Bond", "bm", "classic_ability_druid_demoralizingroar", 2, {
  minRound = 3, shape = S.v2, tags = { "bm" },
  triggers = { { on = "anyHit", match = { kind = "pet" }, icd = 2, effects = { { type = "heal", min = 0, max = 0, noCrit = true, pctMax = 0.0125 } } } },
})

ability(1464, "entrapment", "Entrapment", "surv", "Spell_Nature_StrangleVines", 2, { minRound = 3, shape = S.v2, tags = { "surv" }, triggers = { { on = "dotTick", match = { tag = "trap" }, chance = 15, icd = 4, effects = { { type = "stun", duration = 1 } } } } })

ability(1465, "surefooted", "Surefooted", "surv", "Ability_Kick", 3, { minRound = 5, shape = S.v2, tags = { "surv" }, stats = { dodge = 5 }, triggers = { { on = "dodged", effects = { { type = "resource", resource = "mana", amount = 10 } } } } })

ability(1470, "improved_stings", "Improved Serpent Sting", "surv", "Ability_Hunter_Quickshot", 3, {
  minRound = 5, shape = S.v2, tags = { "surv", "sting", "poison", "nature", "dot" },
  triggers = {
    {
      on = "dotTick", match = { key = "serpent_sting" }, chance = 25, icd = 1,
      effects = { { type = "dot", key = "serpent_sting", coef = 0.06, tick = 3, school = "nature", duration = 15, maxStacks = 5, stack = true } },
    },
  },
  shopRequires = { "serpent_sting" },
})

ability(1471, "clever_traps", "Clever Traps", "surv", "spell_nature_timestop", 4, {
  minRound = 8, shape = S.L, tags = { "surv" },
  triggers = {
    {
      on = "lowHealth",
      effects = { { type = "cdr", target = "neighbors", area = { corners = true }, match = { tag = "trap" }, amount = 60, clampReady = true }, { type = "resource", resource = "mana", amount = 25 } },
    },
  },
  adjacency = { { match = { damaging = true, tag = "trap" }, corners = true, mods = { dmgPct = 15 } } },
})

ability(1472, "efficiency", "Efficiency", "mm", "spell_frost_wizardmark", 3, {
  minRound = 5, shape = S.v2, tags = { "mm" },
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 5 }, { type = "resource", resource = "focus", amount = 5 } } } },
})

ability(1473, "killer_instinct", "Killer Instinct", "surv", "spell_holy_blessingofstamina", 3, {
  minRound = 5, shape = S.v2, tags = { "surv" },
  triggers = {
    { on = "dodged", effects = { { type = "buff", key = "killer_instinct", name = "Killer Instinct", target = "all", match = { tag = "melee" }, stat = "crit", value = 20, duration = 5 } } },
  },
})

ability(1474, "unleashed_fury", "Unleashed Fury", "bm", "ability_bullrush", 3, {
  minRound = 5, shape = S.v2, tags = { "bm", "mm" },
  triggers = { { on = "anyCrit", match = { tag = "shot" }, effects = { { type = "resource", resource = "focus", amount = 15 } }, healing = false } },
})

ability(2000, "ferocity", "Ferocity", "bm", "inv_misc_monsterclaw_04", 1, {
  tags = { "bm" },
  triggers = { { on = "anyCrit", match = { kind = "pet" }, icd = 1, effects = { { type = "resource", resource = "mana", amount = 8 } }, healing = false } },
  adjacency = { { match = { kind = "pet" }, mods = { crit = 10 }, side = "front" } },
})

ability(2001, "bestial_swiftness", "Bestial Swiftness", "bm", "ability_druid_dash", 4, {
  minRound = 8, shape = S.L, tags = { "bm" },
  triggers = { { on = "resourceSpent", resource = "focus", chance = 25, effects = { { type = "cast", target = "source" } } } }, shopWeight = 0.65,
})

ability(2002, "improved_arcane_shot", "Improved Arcane Shot", "mm", "ability_impalingbolt", 3, {
  minRound = 5, shape = S.v2, tags = { "mm", "arcane" },
  triggers = {
    {
      on = "anyUse", match = { key = "arcane_shot" },
      effects = { { type = "buff", key = "arcane_pet", name = "Improved Arcane Shot", target = "all", match = { kind = "pet" }, stat = "dmgPct", value = 35, duration = 6, charges = 1 } },
    },
  },
  shopRequires = { "arcane_shot" },
})

ability(2003, "improved_concussive_shot", "Improved Concussive Shot", "mm", "spell_frost_stun", 4, {
  minRound = 8, shape = S.v2, tags = { "mm" },
  triggers = {
    {
      on = "resourceSpent", resource = "mana", match = { key = "concussive_shot" },
      effects = { { type = "buff", key = "concussive_clearcasting", name = "Improved Concussive Shot", match = { tag = "shot" }, stat = "none", value = 0, duration = 6, charges = 1, free = true } },
    },
  },
  shopRequires = { "concussive_shot" },
})

ability(2004, "lethal_shots", "Lethal Shots", "mm", "ability_searingarrow", 4, {
  minRound = 8, shape = S.L, tags = { "mm" },
  triggers = {
    { on = "anyCrit", match = { tag = "shot" }, effects = { { type = "bank", key = "lethal_shots", fraction = 0.5 } }, healing = false },
    {
      on = "regularHit", match = { anyWeaponType = { "bow", "gun", "crossbow" } },
      effects = { { type = "damage", school = "physical", noCrit = true, noDodge = true, ranged = true, spendBank = "lethal_shots" } },
    },
  },
})

ability(2005, "barrage", "Barrage", "mm", "ability_upgrademoonglaive", 5, {
  minRound = 11, shape = S.L, tags = { "mm" },
  triggers = {
    { on = "regularHit", match = { anyWeaponType = { "bow", "gun", "crossbow" } }, chance = 25, effects = { { type = "cast", target = "all", match = { tag = "shot" }, choose = "random" } } },
  },
  shopWeight = 0.6,
})

ability(2006, "trueshot_aura", "Trueshot Aura", "mm", "ability_trueshot", 5, {
  shape = S.L, tags = { "mm" }, stats = { ap = 10 },
  triggers = { { on = "anyCrit", match = { tag = "shot" }, icd = 2, effects = { { type = "cast", target = "all", match = { kind = "pet" } } }, healing = false } },
  gearBonuses = { { coef = 0.25, stat = "ap", gearStat = "ap" } }, shopWeight = 0.65,
})

ability(2007, "frost_trap", "Frost Trap", "surv", "spell_frost_freezingbreath", 3, {
  tags = { "surv", "trap", "frost" },
  use = {
    cost = 12, cd = 18, initialDelay = 2, resource = "mana",
    effects = {
      { type = "debuff", key = "frost_trap", name = "Frost Trap", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 25, duration = 8 },
      { type = "refresh", match = { tag = "poison" } },
    },
  },
})

ability(2008, "trap_mastery", "Trap Mastery", "surv", "ability_ensnare", 4, {
  shape = S.L, tags = { "surv" },
  triggers = {
    {
      on = "anyUse", match = { tag = "trap" },
      effects = { { type = "tickDots", match = { tag = "poison" } }, { type = "debuff", key = "trap_mastery", name = "Trap Mastery", stat = "armor", value = 15, duration = 6 } },
    },
  },
})

ability(2009, "mend_pet", "Mend Pet", "shared", "ability_hunter_mendpet", 1, {
  tags = { "heal", "hot", "pet" },
  use = {
    cost = 15, cd = 12, reactive = true, resource = "mana", requires = "pet", condition = "injured",
    effects = { { type = "heal", coef = 0.4, min = 2, max = 4 }, { type = "hot", coef = 0.1, tick = 1, duration = 4 } },
  },
  triggers = { { on = "healed", match = { key = "mend_pet" }, effects = { { type = "resource", resource = "focus", fromEvent = 0.25 } } } },
  shopWeight = 1.2,
})

ability(2010, "feign_death", "Feign Death", "shared", "ability_rogue_feigndeath", 2, {
  minRound = 3, tags = { "defensive" },
  use = {
    cost = 12, cd = 24, reactive = true, resource = "mana", condition = "below50",
    effects = { { type = "buff", key = "feign_death", name = "Feign Death", stat = "dodge", value = 35, duration = 4 }, { type = "cleanse", count = 2, debuffs = true } },
  },
  rankable = false,
})

ability(2011, "tranquilizing_shot", "Tranquilizing Shot", "shared", "spell_nature_drowsy", 3, {
  tags = { "shot", "ranged" },
  use = {
    cost = 10, cd = 12, resource = "mana", requires = "ranged",
    effects = {
      { type = "damage", coef = 0.12, min = 4, max = 6, school = "physical", ranged = true, weapon = true, weaponPct = 0.5 },
      { type = "purge", count = 1 }, { type = "resource", resource = "focus", amount = 10 },
    },
  },
  rankable = false,
})

ability(2012, "quiver", "Light Quiver", "shared", "INV_Misc_Quiver_09", 1, {
  tags = { "ranged" },
  adjacency = {
    { match = { kind = "weapon", anyWeaponType = { "bow", "gun", "crossbow" } }, corners = "back", mods = { haste = 10 }, side = "front" },
    { match = { kind = "ammo" }, corners = "back", mods = { ammoEffectPct = 50 }, side = "front" },
  },
  passiveTriggers = true,
})


ability(3080, "scorpid_sting", "Scorpid Sting", "surv", "Ability_Hunter_CriticalShot", 2, {
  cost = 3, shape = { "10", "01" }, tags = { "surv", "sting", "poison", "nature", "ranged" }, exclusiveGroup = "hunter_utility_sting",
  exclusiveLabel = "utility sting",
  use = {
    cost = 10, cd = 14, resource = "mana", requires = "ranged",
    effects = { { type = "debuff", key = "scorpid_sting", name = "Scorpid Sting", exclusiveGroup = "attack_power_reduction", stat = "ap", value = 15, duration = 10 } },
  },
  shopAffinities = { HUNTER = { mm = 0.6, surv = 1 } }, shopWeight = 0.8,
})

ability(3081, "aspect_of_the_wild", "Aspect of the Wild", "shared", "Spell_Nature_ProtectionformNature", 2, {
  minRound = 3, kind = "form", shape = S.h2, tags = { "aspect", "defensive" }, provides = "aspect",
  triggers = { { on = "battleStart", effects = { { type = "buff", key = "aspect_wild", name = "Aspect of the Wild", stat = "dr", value = 15, duration = 90, damageSchool = "magic" } } } },
  shopWeight = 0.7,
})

ability(3082, "improved_aspect_of_the_hawk", "Improved Aspect of the Hawk", "bm", "Spell_Nature_RavenForm", 2, {
  tags = { "bm" },
  triggers = {
    {
      on = "regularHit", condition = "provides:hawk", match = { kind = "weapon", anyWeaponType = { "bow", "gun", "crossbow" } }, chance = 10, icd = 3,
      effects = {
        {
          type = "buff", key = "improved_hawk", name = "Improved Aspect of the Hawk", target = "all",
          match = { kind = "weapon", anyWeaponType = { "bow", "gun", "crossbow" } }, stat = "haste", value = 20, duration = 8,
        },
      },
    },
  },
  shopAffinities = { HUNTER = { bm = 1, mm = 1 } },
})

ability(3084, "improved_mend_pet", "Improved Mend Pet", "bm", "Ability_Hunter_MendPet", 2, {
  cost = 4, tags = { "bm" },
  triggers = { { on = "healed", match = { key = "mend_pet" }, chance = 25, icd = 1, effects = { { type = "cleanse", count = 1, debuffs = true } } } },
  shopAffinities = { HUNTER = { bm = 1, surv = 0.7 } }, shopWeight = 0.8,
})

ability(3085, "pet_turtle", "Pet: Turtle", "bm", "Ability_Hunter_Pet_Turtle", 2, {
  cost = 3, kind = "pet", shape = { "10", "10", "11" }, tags = { "pet", "autoattack", "bm", "defensive" }, provides = "turtle",
  grants = { focus = { max = 100, regen = 4, start = 50 } },
  use = { cd = 2.4, effects = { { type = "damage", coef = 0.35, min = 1, max = 3, school = "physical", pet = true } } }, shopWeight = 0.8,
})

ability(3086, "shell_shield", "Shell Shield", "bm", "Ability_Hunter_Pet_Turtle", 3, {
  shape = { "100", "001" }, tags = { "pet", "bm", "defensive" }, actor = "pet",
  use = {
    cost = 10, cd = 18, reactive = true, resource = "focus", requires = { "pet", "turtle" }, condition = "below50",
    effects = {
      { type = "buff", key = "shell_shield", name = "Shell Shield", stat = "dr", value = 50, duration = 4 },
      { type = "buff", key = "shell_shield_slow", name = "Shell Shield", target = "all", match = { key = "pet_turtle", kind = "pet" }, stat = "haste", value = -30, duration = 4 },
    },
  },
  shopAffinities = { HUNTER = { bm = 1, surv = 0.7 } }, shopWeight = 0.6,
})

ability(3087, "prowl_pet", "Prowl", "bm", "Ability_Druid_SupriseAttack", 2, {
  cost = 3, shape = S.one, tags = { "pet", "bm" }, actor = "pet",
  use = {
    cost = 25, cd = 90, initialDelay = 0, once = true, resource = "focus", requires = { "pet", "cat" },
    effects = {
      {
        type = "buff", key = "prowl_pet", name = "Prowl", target = "all", match = { key = "pet_cat", kind = "pet" }, stat = "dmgPct", value = 100,
        duration = 8, charges = 1, damageSchool = "physical",
      },
      { type = "buff", key = "prowl_pet_critical", name = "Prowl", target = "all", match = { key = "pet_cat", kind = "pet" }, stat = "crit", value = 100, duration = 8, charges = 1 },
    },
  },
  shopWeight = 0.7,
})

ability(3088, "furious_howl", "Furious Howl", "bm", "Ability_Hunter_Pet_Wolf", 2, {
  shape = { "111" }, tags = { "pet", "bm" }, actor = "pet",
  use = {
    cost = 20, cd = 10, initialDelay = 0, resource = "focus", requires = { "pet", "wolf" },
    effects = {
      {
        type = "buff", key = "furious_howl_owner", name = "Furious Howl", target = "neighbors", area = { side = "front" }, match = { kind = "weapon" },
        stat = "dmgPct", value = 100, duration = 6, charges = 1, damageSchool = "physical",
      },
      {
        type = "buff", key = "furious_howl_pet", name = "Furious Howl", target = "all", match = { key = "pet_wolf", kind = "pet" }, stat = "dmgPct",
        value = 100, duration = 6, charges = 1, damageSchool = "physical",
      },
    },
  },
  shopAffinities = { HUNTER = { bm = 1, mm = 0.7, surv = 0.7 } }, shopWeight = 0.8,
})


ability(3089, "viper_sting", "Viper Sting", "surv", "Ability_Hunter_AimedShot", 2, {
  minRound = 3, shape = { "101", "010" }, tags = { "surv", "sting", "poison", "nature", "ranged" }, exclusiveGroup = "hunter_utility_sting",
  exclusiveLabel = "utility sting",
  use = {
    cost = 10, cd = 14, initialDelay = 1.5, resource = "mana", requires = "ranged", condition = "enemyMana",
    effects = { { type = "dot", key = "viper_sting", coef = 0.15, tick = 2, school = "nature", duration = 8, drainResource = "mana", preserveTicks = true } },
  },
  shopAffinities = { HUNTER = { mm = 0.8, surv = 1 } }, shopWeight = 0.75,
})
