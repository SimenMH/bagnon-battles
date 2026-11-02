local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local HUNTER = { "HUNTER" }
local RANGED = { "bow", "gun", "crossbow" }

H.Ability{ id = 2012, key = "quiver", spec = "shared", name = "Light Quiver", icon = I("INV_Misc_Quiver_09"), quality = 1, cost = 3, classes = HUNTER, shape = S.one, tags = { "ranged" }, passiveTriggers = true,
  adjacency = {
    { match = { anyWeaponType = RANGED }, mods = { haste = 10 } },
    { match = { kind = "ammo" }, mods = { ammoEffectPct = 50 } },
  } }

H.Weapon{ id = 1450, key = "worn_shortbow", name = "Worn Shortbow", icon = I("inv_weapon_bow_05"), quality = 1, cost = 3, weaponType = "bow", classes = HUNTER, weaponMin = 12, weaponMax = 15, speed = 2.4, noShop = true, starter = true }
H.Weapon{ id = 1452, key = "heavy_crossbow", name = "Heavy Crossbow", icon = I("inv_weapon_crossbow_03"), quality = 2, minRound = 2, weaponType = "crossbow", classes = HUNTER, weaponMin = 18, weaponMax = 24, speed = 3.0, coef = 0.30,
  triggers = { { on = "hit", chance = 25, effects = { { type = "debuff", stat = "armor", value = 5, duration = 6, key = "heavy_bolt", name = "Heavy Crossbow", stack = true, maxStacks = 3 } } } } }
H.Weapon{ id = 1453, key = "blackcrow", name = "Blackcrow", icon = I("inv_weapon_crossbow_04"), quality = 3, minRound = 5, weaponType = "crossbow", classes = HUNTER, weaponMin = 20, weaponMax = 26, speed = 2.6, stats = { crit = 1 },
  triggers = { { on = "hit", condition = "enemyStunned", effects = { { type = "resource", resource = "mana", amount = 5 } } } } }
H.Weapon{ id = 1454, key = "carapace_spine_crossbow", name = "Carapace Spine Crossbow", icon = I("inv_weapon_crossbow_04"), quality = 3, minRound = 6, weaponType = "crossbow", classes = HUNTER, weaponMin = 22, weaponMax = 29, speed = 3.0, stats = { ap = 6 }, tags = { "poison" },
  triggers = { { on = "hit", chance = 25, effects = { { type = "dot", key = "carapace_venom", school = "nature", tick = 3, coef = 0.04, duration = 6 } } } } }
H.Weapon{ id = 1455, key = "dwarven_hand_cannon", name = "Dwarven Hand Cannon", icon = I("inv_weapon_rifle_09"), quality = 3, minRound = 7, weaponType = "gun", classes = HUNTER, weaponMin = 23, weaponMax = 30, speed = 3.2, coef = 0.30,
  triggers = { { on = "hit", chance = 15, icd = 4, effects = { { type = "stun", duration = 0.5 } } } } }
H.Weapon{ id = 1456, key = "rhokdelar", name = "Rhok'delar, Longbow of the Ancient Keepers", icon = I("inv_weapon_bow_01"), quality = 4, minRound = 11, weaponType = "bow", classes = HUNTER, weaponMin = 28, weaponMax = 36, speed = 2.9, stats = { crit = 2, ap = 8 },
  triggers = { { on = "crit", effects = { { type = "cdr", target = "all", match = { tag = "shot" }, amount = 1.0 } } } } }
H.Weapon{ id = 1457, key = "ashjrethul", name = "Ashjre'thul, Crossbow of Smiting", icon = I("inv_weapon_crossbow_09"), quality = 4, minRound = 13, weaponType = "crossbow", classes = HUNTER, weaponMin = 30, weaponMax = 38, speed = 3.2, stats = { ap = 10 },
  use = { cd = 3.2, effects = { { type = "damage", weaponSelf = true, coef = 0.30, school = "physical", ranged = true, critIf = "enemyStunned" } } } }
H.Weapon{ id = 1458, key = "core_marksman_rifle", name = "Core Marksman Rifle", icon = I("inv_weapon_rifle_05"), quality = 4, minRound = 12, weaponType = "gun", classes = HUNTER, weaponMin = 26, weaponMax = 34, speed = 2.8, stats = { crit = 3 },
  triggers = { { on = "crit", effects = { { type = "damage", min = 10, max = 14, school = "fire", noDodge = true } } } } }

ns.RegisterItem{ id = 1445, key = "rough_arrows", name = "Rough Arrows", icon = I("inv_ammo_arrow_02"), kind = "ammo", spec = "shared", quality = 1, cost = 2, classes = HUNTER, shape = S.one, tags = { "ammo" }, starter = true,
  adjacency = { { match = { anyWeaponType = RANGED }, mods = { flat = 2 } } } }
ns.RegisterItem{ id = 1447, key = "razor_arrows", name = "Razor Arrows", icon = I("inv_ammo_arrow_02"), kind = "ammo", spec = "shared", quality = 3, cost = 4, minRound = 6, classes = HUNTER, shape = S.one, tags = { "ammo" },
  adjacency = { { match = { anyWeaponType = RANGED }, mods = { flat = 5 } } },
  triggers = { { on = "adjacentCrit", match = { anyWeaponType = RANGED }, effects = { { type = "dot", key = "razor_bleed", school = "physical", tick = 3, coef = 0.04, duration = 6 } } } } }
ns.RegisterItem{ id = 1448, key = "thorium_headed_arrows", name = "Thorium Headed Arrows", icon = I("inv_ammo_arrow_02"), kind = "ammo", spec = "shared", quality = 3, cost = 5, minRound = 9, classes = HUNTER, shape = S.one, tags = { "ammo" },
  adjacency = { { match = { anyWeaponType = RANGED }, mods = { flat = 6 } } },
  triggers = { { on = "adjacentHit", match = { anyWeaponType = RANGED }, effects = { { type = "debuff", stat = "armor", value = 6, duration = 10, key = "thorium_sunder", name = "Thorium Headed Arrows", stack = true, maxStacks = 5 } } } } }
ns.RegisterItem{ id = 1449, key = "ice_threaded_arrows", name = "Ice Threaded Arrows", icon = I("spell_frost_iceshard"), kind = "ammo", spec = "shared", quality = 4, cost = 6, minRound = 12, classes = HUNTER, shape = S.one, tags = { "ammo" },
  adjacency = { { match = { anyWeaponType = RANGED }, mods = { flat = 8 } } },
  triggers = { { on = "adjacentHit", match = { anyWeaponType = RANGED }, effects = { { type = "debuff", stat = "haste", value = 5, duration = 6, key = "ice_chill", name = "Ice Threaded Arrows", stack = true, maxStacks = 4 } } } } }

H.Ability{ id = 1400, key = "aimed_shot", spec = "mm", name = "Aimed Shot", icon = I("INV_Spear_07"), quality = 3, minRound = 4, classes = HUNTER, shape = S.L, tags = { "mm", "shot", "ranged" },
  use = { cd = 5, cost = 20, resource = "mana", requires = "ranged", effects = { { type = "damage", weapon = true, ranged = true, min = 26, max = 34, school = "physical", coef = 0.4, consumeDots = { match = { tag = "poison" }, fraction = 0.35 }, critIf = "enemyStunned" } } } }
H.Ability{ id = 1401, key = "multi_shot", spec = "mm", name = "Multi-Shot", icon = I("Ability_UpgradeMoonGlaive"), quality = 2, minRound = 2, classes = HUNTER, shape = S.v2, tags = { "mm", "shot", "ranged" },
  use = { cd = 8, cost = 16, resource = "mana", requires = "ranged", effects = { { type = "damage", weapon = true, ranged = true, min = 6, max = 8, school = "physical", coef = 0.18 }, { type = "damage", weapon = true, ranged = true, min = 6, max = 8, school = "physical", coef = 0.18 }, { type = "damage", weapon = true, ranged = true, min = 6, max = 8, school = "physical", coef = 0.18, cond = "enemyPoisoned" } } } }
H.Ability{ id = 1402, key = "arcane_shot", spec = "mm", name = "Arcane Shot", icon = I("Ability_ImpalingBolt"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "mm", "shot", "ranged", "arcane" },
  use = { cd = 6, cost = 10, resource = "mana", requires = "ranged", effects = { { type = "damage", min = 8, max = 12, school = "arcane", ranged = true, coef = 0.3, noDodge = true } } },
  triggers = { { on = "resourceSpent", resource = "mana", match = { key = "arcane_shot" }, effects = { { type = "resource", resource = "focus", fromEvent = 0.5 } } } } }
H.Ability{ id = 1403, key = "serpent_sting", spec = "surv", name = "Serpent Sting", icon = I("Ability_Hunter_Quickshot"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "surv", "sting", "poison", "ranged", "dot", "nature" },
  use = { cd = 15, initialDelay = 1.5, cost = 12, resource = "mana", requires = "ranged", effects = { { type = "dot", key = "serpent_sting", school = "nature", tick = 3, coef = 0.06, duration = 15, stack = true, maxStacks = 5 } } } }
H.Ability{ id = 1404, key = "concussive_shot", spec = "mm", name = "Concussive Shot", icon = I("Spell_Frost_Stun"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "mm", "shot", "ranged" },
  use = { cd = 12, cost = 10, resource = "mana", requires = "ranged", effects = { { type = "damage", min = 2, max = 3, school = "physical", ranged = true }, { type = "stun", duration = 1.0 }, { type = "buff", target = "all", match = { kind = "pet" }, stat = "crit", value = 100, charges = 1, duration = 6, key = "concussive_opening", name = "Concussive Shot" } } } }
H.Ability{ id = 1405, key = "scatter_shot", spec = "mm", name = "Scatter Shot", icon = I("Ability_GolemStormBolt"), quality = 3, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "surv", "mm", "shot", "ranged" },
  use = { cd = 20, cost = 15, resource = "mana", requires = "ranged", effects = { { type = "damage", weapon = true, weaponPct = 0.5, ranged = true, school = "physical", coef = 0.1 }, { type = "stun", duration = 2.0 } } } }
H.Ability{ id = 1406, key = "rapid_fire", spec = "mm", name = "Rapid Fire", icon = I("Ability_Hunter_RunningShot"), quality = 4, cost = 10, minRound = 7, classes = HUNTER, shape = S.v2, tags = { "mm" },
  use = { cd = 25, cost = 20, resource = "mana", effects = { { type = "buff", target = "all", match = { tag = "ranged" }, stat = "haste", value = 50, duration = 8, key = "rapid_fire", name = "Rapid Fire" } } } }
H.Ability{ id = 1407, key = "hunters_mark", spec = "mm", name = "Hunter's Mark", icon = I("Ability_Hunter_SniperShot"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "mm" },
  triggers = { { on = "battleStart", effects = { { type = "buff", stat = "rangedPct", value = 10, duration = 120, name = "Hunter's Mark" } } }, { on = "regularHit", match = { anyWeaponType = RANGED }, effects = { { type = "debuff", stat = "armor", value = 4, duration = 12, stack = true, maxStacks = 5, key = "hunters_mark", name = "Hunter's Mark" } } } } }
H.Ability{ id = 1409, key = "volley", spec = "mm", name = "Volley", icon = I("Ability_Marksmanship"), quality = 2, minRound = 4, classes = HUNTER, shape = S.sq, tags = { "mm", "ranged", "arcane", "dot" },
  use = { cd = 14, cost = 30, resource = "mana", requires = "ranged", effects = { { type = "dot", key = "volley", school = "arcane", tick = 6, coef = 0.15, duration = 6 }, { type = "buff", target = "all", match = { anyWeaponType = RANGED }, stat = "haste", value = 30, duration = 6, key = "volley", name = "Volley" } } } }
H.Ability{ id = 1410, key = "aspect_of_the_hawk", spec = "mm", name = "Aspect of the Hawk", icon = I("Spell_Nature_RavenForm"), kind = "form", quality = 1, classes = HUNTER, shape = S.v2, tags = { "aspect", "mm" },
  provides = "aspect", stats = { ap = 12 },
  triggers = { { on = "anyCrit", healing = false, match = { anyWeaponType = RANGED }, effects = { { type = "resource", resource = "mana", fromEvent = 0.15 } } } } }
H.Ability{ id = 1411, key = "aspect_of_the_monkey", spec = "shared", name = "Aspect of the Monkey", icon = I("Ability_Hunter_AspectOfTheMonkey"), kind = "form", quality = 1, classes = HUNTER, shape = S.v2, tags = { "aspect", "surv", "defensive" },
  provides = "aspect", stats = { dodge = 8 },
  triggers = { { on = "dodged", effects = { { type = "resource", resource = "focus", amount = 8 } } } } }
H.Ability{ id = 1412, key = "aspect_of_the_beast", spec = "shared", name = "Aspect of the Beast", icon = I("Ability_Mount_PinkTiger"), kind = "form", quality = 2, minRound = 2, classes = HUNTER, shape = S.v2, tags = { "aspect", "bm", "surv" },
  provides = "aspect", stats = { meleePct = 10, petPct = 10 },
  triggers = { { on = "resourceSpent", resource = "focus", effects = { { type = "resource", resource = "mana", fromEvent = 0.15 } } } } }
H.Ability{ id = 1413, key = "bestial_wrath", spec = "bm", name = "Bestial Wrath", icon = I("Ability_Druid_FerociousBite"), quality = 5, cost = 15, minRound = 9, classes = HUNTER, shape = S.L, tags = { "bm" },
  use = { cd = 24, cost = 32, resource = "mana", requires = "pet", effects = { { type = "buff", stat = "petPct", value = 60, duration = 8, key = "bestial_wrath_power", name = "Bestial Wrath" }, { type = "buff", stat = "none", value = 0, duration = 8, key = "bestial_wrath", name = "Bestial Wrath", double = { kind = "pet" } }, { type = "resource", resource = "focus", amount = 40 } } } }
H.Ability{ id = 1414, key = "intimidation", spec = "bm", name = "Intimidation", icon = I("Ability_Devour"), quality = 3, minRound = 4, classes = HUNTER, shape = S.v2, tags = { "bm" },
  use = { cd = 18, cost = 18, resource = "mana", requires = "pet", effects = { { type = "stun", duration = 2.0 }, { type = "buff", target = "all", match = { kind = "pet" }, stat = "crit", value = 35, duration = 3, key = "intimidation", name = "Intimidation" } } } }
H.Ability{ id = 1416, key = "frenzy", spec = "bm", name = "Frenzy", icon = I("INV_Misc_MonsterClaw_03"), quality = 4, cost = 10, minRound = 7, classes = HUNTER, shape = S.v2, tags = { "bm" },
  triggers = { { on = "anyCrit", healing = false, match = { kind = "pet" }, effects = { { type = "buff", target = "all", match = { kind = "pet" }, stat = "haste", value = 15, duration = 8, key = "frenzy", name = "Frenzy", stack = true, maxStacks = 5 } } } } }
H.Ability{ id = 1415, key = "bestial_discipline", spec = "bm", name = "Bestial Discipline", icon = I("Spell_Nature_AbolishMagic"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "bm" },
  grants = { focus = { max = 100, start = 20, regen = 8 } } }

H.Ability{ id = 1419, key = "pet_wolf", spec = "bm", name = "Pet: Wolf", icon = I("Ability_Hunter_Pet_Wolf"), kind = "pet", quality = 2, minRound = 1, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm" },
  grants = { focus = { max = 100, start = 50, regen = 4 } },
  use = { cd = 2.0, effects = { { type = "damage", min = 7, max = 10, school = "physical", coef = 0.32, pet = true } } },
  triggers = { { on = "hit", effects = { { type = "bank", key = "wolf_howl", fraction = 0.35 } } }, { on = "regularHit", match = { kind = "weapon" }, effects = { { type = "damage", school = "physical", spendBank = "wolf_howl", noCrit = true, noDodge = true, noOwnTriggers = true } } } } }
H.Ability{ id = 1420, key = "pet_cat", spec = "bm", name = "Pet: Cat", icon = I("Ability_Hunter_Pet_Cat"), kind = "pet", quality = 1, minRound = 1, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm" },
  grants = { focus = { max = 100, start = 50, regen = 4 } },
  use = { cd = 1.6, effects = { { type = "damage", min = 6, max = 8, school = "physical", coef = 0.32, pet = true, critBonus = 10 } } },
  triggers = { { on = "resourceSpent", resource = "focus", everyAmount = 25, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } } }
H.Ability{ id = 1421, key = "pet_bear", spec = "bm", name = "Pet: Bear", icon = I("Ability_Hunter_Pet_Bear"), kind = "pet", quality = 2, minRound = 2, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm", "defensive" },
  grants = { focus = { max = 100, start = 50, regen = 4 } }, stats = { hp = 35, armor = 10 },
  use = { cd = 2.4, effects = { { type = "damage", min = 8, max = 11, school = "physical", coef = 0.32, pet = true } } },
  triggers = { { on = "hit", effects = { { type = "absorb", fromEvent = 0.25 } } } } }
H.Ability{ id = 1422, key = "pet_boar", spec = "bm", name = "Pet: Boar", icon = I("Ability_Hunter_Pet_Boar"), kind = "pet", quality = 1, minRound = 1, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm" },
  grants = { focus = { max = 100, start = 50, regen = 4 } },
  use = { cd = 2.0, effects = { { type = "damage", min = 6, max = 8, school = "physical", coef = 0.32, pet = true } } },
  triggers = { { on = "dodged", effects = { { type = "damage", min = 4, max = 6, school = "physical", coef = 0.2, pet = true, noDodge = true }, { type = "stun", duration = 0.75 } } } } }
H.Ability{ id = 1423, key = "pet_raptor", spec = "bm", name = "Pet: Raptor", icon = I("Ability_Hunter_Pet_Raptor"), kind = "pet", quality = 3, minRound = 4, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm" },
  grants = { focus = { max = 100, start = 50, regen = 4 } }, stats = { crit = 2 },
  use = { cd = 1.8, effects = { { type = "damage", min = 6, max = 9, school = "physical", coef = 0.42, pet = true } } },
  triggers = { { on = "crit", effects = { { type = "dot", key = "raptor_bleed", school = "physical", tick = 0, duration = 6, rolling = true, fromEvent = 0.3 } } }, { on = "dotTick", match = { tag = "bleed" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.2 } } } } }
H.Ability{ id = 1424, key = "pet_scorpid", spec = "bm", name = "Pet: Scorpid", icon = I("Ability_Hunter_Pet_Scorpid"), kind = "pet", quality = 2, minRound = 3, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm", "poison", "nature" },
  grants = { focus = { max = 100, start = 50, regen = 4 } },
  use = { cd = 2.0, effects = { { type = "damage", min = 4, max = 6, school = "physical", coef = 0.32, pet = true }, { type = "dot", key = "scorpid_poison", school = "nature", tick = 1, coef = 0.025, duration = 10, stack = true, maxStacks = 5 } } },
  triggers = { { on = "dotTick", match = { anyTag = { "sting", "poison" } }, everyAmount = 10, effects = { { type = "resource", resource = "focus", amount = 3 } } }, { on = "resourceSpent", resource = "focus", everyAmount = 25, effects = { { type = "tickDots", match = { tag = "poison" } } } } } }
H.Ability{ id = 1425, key = "pet_wind_serpent", spec = "bm", name = "Pet: Wind Serpent", icon = I("Ability_Hunter_Pet_WindSerpent"), kind = "pet", quality = 3, minRound = 5, classes = HUNTER, shape = S.sq, tags = { "pet", "autoattack", "bm" },
  grants = { focus = { max = 100, start = 50, regen = 4 } },
  use = { cd = 2.4, effects = { { type = "damage", min = 8, max = 12, school = "nature", coef = 0.4, spendBank = "wind_serpent", pet = true, noDodge = true } } },
  triggers = { { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "wind_serpent", fraction = 0.75 } } } } }
H.Ability{ id = 1426, key = "bite", spec = "bm", name = "Bite", icon = I("Ability_Racial_Cannibalize"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "pet", "bm" },
  use = { cd = 5, cost = 25, spendAll = true, resource = "focus", requires = "pet", effects = { { type = "damage", min = 10, max = 14, school = "physical", coef = 0.4, perPoint = 0.35, pointResource = "focus", pet = true } } } }
H.Ability{ id = 1427, key = "claw_pet", spec = "bm", name = "Claw", icon = I("Ability_Druid_Rake"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "pet", "bm" },
  use = { cd = 3, cost = 25, resource = "focus", requires = "pet", effects = { { type = "damage", min = 6, max = 9, school = "physical", coef = 0.3, pet = true } } } }
H.Ability{ id = 1428, key = "screech", spec = "bm", name = "Screech", icon = I("Ability_Hunter_Pet_Bat"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "pet", "bm" },
  use = { cd = 6, cost = 20, resource = "focus", requires = "pet", effects = { { type = "debuff", stat = "ap", value = 6, duration = 8, stack = true, maxStacks = 3, key = "screech" } } } }

H.Ability{ id = 1429, key = "raptor_strike", spec = "surv", name = "Raptor Strike", icon = I("Ability_MeleeDamage"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "surv", "melee", "strike" },
  use = { cd = 6, cost = 15, resource = "mana", requires = "melee", effects = { { type = "damage", weapon = true, min = 6, max = 8, school = "physical", coef = 0.2 } } },
  triggers = { { on = "resourceSpent", resource = "mana", match = { key = "raptor_strike" }, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } } }
H.Ability{ id = 1430, key = "mongoose_bite", spec = "surv", name = "Mongoose Bite", icon = I("Ability_Hunter_SwiftStrike"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "surv", "melee" },
  rankable = true, triggers = { { on = "dodged", effects = { { type = "damage", min = 16, max = 20, school = "physical", coef = 0.35, noDodge = true } } }, { on = "hit", effects = { { type = "resource", resource = "focus", fromEvent = 0.2 } } } } }
H.Ability{ id = 1431, key = "wing_clip", spec = "surv", name = "Wing Clip", icon = I("Ability_Rogue_Trip"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "surv", "melee" },
  use = { cd = 10, cost = 10, resource = "mana", requires = "melee", effects = { { type = "damage", min = 2, max = 4, school = "physical" }, { type = "debuff", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 15, duration = 10 } } } }
H.Ability{ id = 1432, key = "counterattack", spec = "surv", name = "Counterattack", icon = I("Ability_Warrior_Challange"), quality = 3, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "surv", "melee" },
  rankable = true, triggers = { { on = "dodged", icd = 5, effects = { { type = "damage", min = 18, max = 22, school = "physical", coef = 0.3, noDodge = true }, { type = "stun", duration = 1.5 } } } } }
H.Ability{ id = 1433, key = "deterrence", spec = "surv", name = "Deterrence", icon = I("Ability_Whirlwind"), quality = 4, cost = 10, minRound = 7, classes = HUNTER, shape = S.v2, tags = { "surv", "defensive" },
  use = { reactive = true, cd = 24, condition = "below50", effects = { { type = "buff", stat = "dodge", value = 45, duration = 8, key = "deterrence", name = "Deterrence" } } } }
H.Ability{ id = 1434, key = "immolation_trap", spec = "surv", name = "Immolation Trap", icon = I("Spell_Fire_FlameShock"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "surv", "trap", "fire", "dot" },
  use = { cd = 25, initialDelay = 2, effects = { { type = "dot", key = "immolation_trap", school = "fire", tick = 3, coef = 0.05, duration = 10, rolling = true } } },
  triggers = { { on = "resourceSpent", resource = "focus", condition = "enemyHas:immolation_trap", effects = { { type = "dot", key = "immolation_trap", school = "fire", tick = 0, fromEvent = 0.5, duration = 10, rolling = true } } } } }
H.Ability{ id = 1435, key = "explosive_trap", spec = "surv", name = "Explosive Trap", icon = I("Spell_Fire_SelfDestruct"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "surv", "trap", "fire", "dot" },
  use = { cd = 25, initialDelay = 2, effects = { { type = "damage", min = 10, max = 14, school = "fire", coef = 0.2, consumeDots = { match = { tag = "fire" }, fraction = 0.35 }, noDodge = true }, { type = "dot", key = "explosive_trap", school = "fire", tick = 2, coef = 0.06, duration = 10 } } } }
H.Ability{ id = 1436, key = "freezing_trap", spec = "surv", name = "Freezing Trap", icon = I("Spell_Frost_ChainsOfIce"), quality = 2, minRound = 2, classes = HUNTER, shape = S.v2, tags = { "surv", "trap", "frost" },
  use = { cd = 30, initialDelay = 2, effects = { { type = "stun", duration = 3.0 }, { type = "debuff", stat = "dr", value = 20, duration = 3, key = "freezing_trap", name = "Freezing Trap" } } } }
H.Ability{ id = 1440, key = "wyvern_sting", spec = "surv", name = "Wyvern Sting", icon = I("INV_Spear_02"), quality = 5, cost = 15, minRound = 10, classes = HUNTER, shape = S.L, tags = { "surv", "sting", "poison", "ranged", "nature", "dot" },
  use = { cd = 24, cost = 32, resource = "mana", requires = "ranged", effects = { { type = "stun", duration = 3.0, controlType = "sleep" }, { type = "dot", key = "wyvern_sting", school = "nature", tick = 8, coef = 0.12, duration = 12 }, { type = "tickDots", match = { tag = "poison" } } } },
  triggers = { { on = "dotTick", match = { tag = "poison" }, everyAmount = 50, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } } }
H.Ability{ id = 1442, key = "mortal_shots", spec = "mm", name = "Mortal Shots", icon = I("Ability_PierceDamage"), quality = 3, minRound = 4, classes = HUNTER, shape = S.v2, tags = { "mm" },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shot" }, effects = { { type = "damage", school = "physical", ranged = true, fromEvent = 0.25, noCrit = true, noDodge = true } } } } }
H.Ability{ id = 1462, key = "feed_pet", spec = "shared", name = "Feed Pet", icon = I("Ability_Hunter_BeastTraining"), quality = 1, classes = HUNTER, shape = S.v2, tags = { "bm", "pet" },
  use = { cd = 10, requires = "pet", effects = { { type = "resource", resource = "focus", amount = 20 } } } }
H.Ability{ id = 1463, key = "spirit_bond", spec = "bm", name = "Spirit Bond", icon = I("classic_ability_druid_demoralizingroar"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "bm" },
  triggers = { { on = "anyHit", match = { kind = "pet" }, effects = { { type = "heal", min = 0, max = 0, pctMax = 0.02 } } } } }
H.Ability{ id = 1464, key = "entrapment", spec = "surv", name = "Entrapment", icon = I("Spell_Nature_StrangleVines"), quality = 2, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "surv" },
  triggers = { { on = "anyUse", match = { tag = "trap" }, every = 2, effects = { { type = "stun", duration = 1.0 } } } } }
H.Ability{ id = 1465, key = "surefooted", spec = "surv", name = "Surefooted", icon = I("Ability_Kick"), quality = 3, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "surv" },
  stats = { dodge = 5 },
  triggers = { { on = "dodged", effects = { { type = "resource", resource = "mana", amount = 10 } } } } }
H.Ability{ id = 1472, key = "efficiency", spec = "mm", name = "Efficiency", icon = I("spell_frost_wizardmark"), quality = 3, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "mm" },
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 5 }, { type = "resource", resource = "focus", amount = 5 } } } } }
H.Ability{ id = 1473, key = "killer_instinct", spec = "surv", name = "Killer Instinct", icon = I("spell_holy_blessingofstamina"), quality = 3, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "surv" }, stats = { crit = 3 },
  triggers = { { on = "dodged", effects = { { type = "buff", target = "all", match = { tag = "melee" }, stat = "crit", value = 20, duration = 5, key = "killer_instinct", name = "Killer Instinct" } } } } }
H.Ability{ id = 1474, key = "unleashed_fury", spec = "bm", name = "Unleashed Fury", icon = I("ability_bullrush"), quality = 3, cost = 7, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "bm", "mm" },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shot" }, effects = { { type = "resource", resource = "focus", amount = 15 } } } } }
H.Ability{ id = 1470, key = "improved_stings", spec = "surv", shopRequires = { "serpent_sting" }, name = "Improved Serpent Sting", icon = I("Ability_Hunter_Quickshot"), quality = 3, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "surv", "sting", "poison", "nature", "dot" },
  triggers = { { on = "dotTick", match = { key = "serpent_sting" }, chance = 25, icd = 1, effects = { { type = "dot", key = "serpent_sting", school = "nature", tick = 3, coef = 0.06, duration = 15, stack = true, maxStacks = 5 } } } } }
H.Ability{ id = 1471, key = "clever_traps", spec = "surv", name = "Clever Traps", icon = I("spell_nature_timestop"), quality = 4, cost = 10, minRound = 8, classes = HUNTER, shape = S.L, tags = { "surv" },
  triggers = { { on = "lowHealth", effects = { { type = "cdr", target = "all", match = { tag = "trap" }, amount = 60 }, { type = "resource", resource = "mana", amount = 25 } } } } }

H.Ability{ id = 2000, key = "ferocity", spec = "bm", name = "Ferocity", icon = I("inv_misc_monsterclaw_04"), quality = 1, cost = 3, classes = HUNTER, shape = S.one, tags = { "bm" },
  adjacency = { { match = { kind = "pet" }, mods = { crit = 10 } } },
  triggers = { { on = "anyCrit", healing = false, match = { kind = "pet" }, effects = { { type = "resource", resource = "mana", amount = 8 } } } } }
H.Ability{ id = 2001, key = "bestial_swiftness", spec = "bm", name = "Bestial Swiftness", icon = I("ability_druid_dash"), quality = 4, cost = 10, minRound = 8, classes = HUNTER, shape = S.L, tags = { "bm" },
  triggers = { { on = "resourceSpent", resource = "focus", chance = 25, effects = { { type = "cast", target = "source" } } } } }
H.Ability{ id = 2002, key = "improved_arcane_shot", spec = "mm", shopRequires = { "arcane_shot" }, name = "Improved Arcane Shot", icon = I("ability_impalingbolt"), quality = 3, cost = 7, minRound = 5, classes = HUNTER, shape = S.v2, tags = { "mm", "arcane" }, stats = { sp = 12 },
  triggers = { { on = "anyUse", match = { key = "arcane_shot" }, effects = { { type = "buff", target = "all", match = { kind = "pet" }, stat = "dmgPct", value = 35, charges = 1, duration = 6, key = "arcane_pet", name = "Improved Arcane Shot" } } } } }
H.Ability{ id = 2003, key = "improved_concussive_shot", spec = "mm", shopRequires = { "concussive_shot" }, name = "Improved Concussive Shot", icon = I("spell_frost_stun"), quality = 4, cost = 10, minRound = 8, classes = HUNTER, shape = S.v2, tags = { "mm" },
  triggers = { { on = "resourceSpent", resource = "mana", match = { key = "concussive_shot" }, effects = { { type = "buff", key = "concussive_clearcasting", stat = "none", value = 0, free = true, match = { tag = "shot" }, duration = 6, name = "Improved Concussive Shot" } } } } }
H.Ability{ id = 2004, key = "lethal_shots", spec = "mm", name = "Lethal Shots", icon = I("ability_searingarrow"), quality = 4, cost = 10, minRound = 8, classes = HUNTER, shape = S.L, tags = { "mm" },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shot" }, effects = { { type = "bank", key = "lethal_shots", fraction = 0.5 } } }, { on = "regularHit", match = { anyWeaponType = RANGED }, effects = { { type = "damage", school = "physical", ranged = true, spendBank = "lethal_shots", noCrit = true, noDodge = true } } } } }
H.Ability{ id = 2005, key = "barrage", spec = "mm", name = "Barrage", icon = I("ability_upgrademoonglaive"), quality = 5, cost = 15, minRound = 11, classes = HUNTER, shape = S.L, tags = { "mm" },
  triggers = { { on = "regularHit", match = { anyWeaponType = RANGED }, chance = 25, effects = { { type = "cast", target = "all", match = { tag = "shot" }, choose = "random" } } } } }
H.Ability{ id = 2006, key = "trueshot_aura", spec = "mm", name = "Trueshot Aura", icon = I("ability_trueshot"), quality = 5, cost = 15, minRound = 10, classes = HUNTER, shape = S.L, tags = { "mm" }, stats = { ap = 48 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shot" }, effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } } }
H.Ability{ id = 2007, key = "frost_trap", spec = "surv", name = "Frost Trap", icon = I("spell_frost_freezingbreath"), quality = 3, cost = 7, minRound = 4, classes = HUNTER, shape = S.v2, tags = { "surv", "trap", "frost" },
  use = { cd = 18, initialDelay = 2, cost = 12, resource = "mana", effects = { { type = "debuff", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 25, duration = 8, key = "frost_trap", name = "Frost Trap" }, { type = "refresh", match = { tag = "poison" } } } } }
H.Ability{ id = 2008, key = "trap_mastery", spec = "surv", name = "Trap Mastery", icon = I("ability_ensnare"), quality = 4, cost = 10, minRound = 7, classes = HUNTER, shape = S.L, tags = { "surv" },
  triggers = { { on = "anyUse", match = { tag = "trap" }, effects = { { type = "tickDots", match = { tag = "poison" } }, { type = "debuff", stat = "armor", value = 15, duration = 6, key = "trap_mastery", name = "Trap Mastery" } } } } }
H.Ability{ id = 2009, key = "mend_pet", spec = "shared", name = "Mend Pet", icon = I("ability_hunter_mendpet"), quality = 1, cost = 3, classes = HUNTER, shape = S.v2, tags = { "heal", "hot", "pet" },
  use = { reactive = true, cd = 12, cost = 15, resource = "mana", requires = "pet", condition = "injured", effects = { { type = "heal", min = 12, max = 16, coef = 0.25 }, { type = "hot", tick = 4, coef = 0.08, duration = 4 } } },
  triggers = { { on = "healed", match = { key = "mend_pet" }, effects = { { type = "resource", resource = "focus", fromEvent = 0.25 } } } } }
H.Ability{ id = 2010, key = "feign_death", spec = "shared", name = "Feign Death", icon = I("ability_rogue_feigndeath"), quality = 2, cost = 5, minRound = 3, classes = HUNTER, shape = S.v2, tags = { "defensive" }, rankable = false,
  use = { reactive = true, cd = 24, cost = 12, resource = "mana", condition = "below50", effects = { { type = "buff", stat = "dodge", value = 35, duration = 4, key = "feign_death", name = "Feign Death" }, { type = "cleanse", count = 2 } } } }
H.Ability{ id = 2011, key = "tranquilizing_shot", spec = "shared", name = "Tranquilizing Shot", icon = I("spell_nature_drowsy"), quality = 3, cost = 7, minRound = 4, classes = HUNTER, shape = S.v2, tags = { "shot", "ranged" }, rankable = false,
  use = { cd = 12, cost = 10, resource = "mana", requires = "ranged", effects = { { type = "damage", weapon = true, weaponPct = 0.5, ranged = true, min = 4, max = 6, school = "physical", coef = 0.12 }, { type = "purge", count = 1 }, { type = "resource", resource = "focus", amount = 10 } } } }
