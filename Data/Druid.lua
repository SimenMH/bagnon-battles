local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local DRUID = { "DRUID" }

H.Weapon{ id = 1090, key = "gnarled_staff", name = "Gnarled Staff", icon = I("inv_staff_10"), quality = 1, cost = 3, weaponType = "staff", hands = 2, classes = DRUID, weaponMin = 5, weaponMax = 8, speed = 3.0, noShop = true, starter = true, stats = { sp = 1, healing = 1 } }

H.Ability{ id = 1000, key = "wrath", spec = "balance", name = "Wrath", icon = I("Spell_Nature_AbolishMagic"), quality = 1, cost = 3, classes = DRUID, shape = S.v2, tags = { "balance", "spell", "nature" },
  use = { cd = 1.5, cost = 8, resource = "mana", effects = { { type = "damage", min = 4, max = 6, school = "nature", coef = 0.4 } } },
  triggers = { { on = "use", effects = { { type = "cdr", target = "neighbors", match = { tag = "spell" }, amount = 0.5 } } } } }
H.Ability{ id = 1001, key = "starfire", spec = "balance", name = "Starfire", icon = I("Spell_Arcane_StarFire"), quality = 2, cost = 5, minRound = 2, classes = DRUID, shape = S.sq, tags = { "balance", "spell", "arcane" },
  use = { cd = 12, initialDelay = 12, cost = 28, resource = "mana", effects = { { type = "damage", min = 36, max = 48, school = "arcane", coef = 1.4, consumeDots = { match = { tag = "spell" }, fraction = 0.35 } } } } }
H.Ability{ id = 1002, key = "moonfire", spec = "balance", name = "Moonfire", icon = I("Spell_Nature_StarFall"), quality = 1, cost = 3, classes = DRUID, shape = S.v2, tags = { "balance", "spell", "arcane", "dot" },
  use = { cd = 9, cost = 12, resource = "mana", effects = { { type = "damage", min = 3, max = 5, school = "arcane", coef = 0.15 }, { type = "dot", key = "moonfire", school = "arcane", tick = 2, coef = 0.05, duration = 9, stack = true, maxStacks = 3 } } } }
H.Ability{ id = 1003, key = "insect_swarm", spec = "resto", name = "Insect Swarm", icon = I("Spell_Nature_InsectSwarm"), quality = 2, minRound = 2, classes = DRUID, shape = S.v2, tags = { "resto", "spell", "nature", "dot" },
  use = { cd = 12, cost = 10, resource = "mana", effects = { { type = "dot", key = "insect_swarm", school = "nature", tick = 2, coef = 0.08, duration = 12, stack = true, maxStacks = 3 } } },
  triggers = { { on = "dotTick", match = { key = "insect_swarm" }, effects = { { type = "heal", fromEvent = 0.4 } } } } }
H.Ability{ id = 1004, key = "hurricane", spec = "balance", name = "Hurricane", icon = I("Spell_Nature_Cyclone"), quality = 4, cost = 11, minRound = 7, classes = DRUID, shape = S.T, tags = { "balance", "spell", "nature", "dot" },
  use = { cd = 16, cost = 28, resource = "mana", effects = { { type = "dot", key = "hurricane", school = "nature", tick = 10, coef = 0.2, duration = 8 }, { type = "debuff", stat = "haste", value = 30, duration = 8, key = "hurricane_slow", name = "Hurricane" } } } }
H.Ability{ id = 1005, key = "natures_grace", spec = "balance", name = "Nature's Grace", icon = I("Spell_Nature_NaturesBlessing"), quality = 2, minRound = 2, classes = DRUID, shape = S.v2, tags = { "balance", "resto" },
  triggers = { { on = "anyCrit", match = { tag = "spell" }, effects = { { type = "cdr", target = "neighbors", match = { tag = "spell" }, amount = 1.0 } } } } }
H.Ability{ id = 1006, key = "moonkin_form", spec = "balance", name = "Moonkin Form", icon = I("Spell_Nature_ForceOfNature"), kind = "form", quality = 5, cost = 15, minRound = 10, classes = DRUID, shape = S.sq, tags = { "balance", "form" },
  provides = "moonkin", stats = { armor = 30, crit = 5, sp = 18 },
  triggers = {
    { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "tickDots", match = { tag = "spell" } } } },
    { on = "dotTick", match = { tag = "spell" }, everyAmount = 40, effects = { { type = "buff", stat = "crit", value = 5, duration = 6, stack = true, maxStacks = 4, key = "moonkin_fury", name = "Moonkin Form" } } },
  } }
H.Ability{ id = 1007, key = "faerie_fire", spec = "shared", name = "Faerie Fire", icon = I("Spell_Nature_FaerieFire"), quality = 1, classes = DRUID, shape = S.v2, tags = { "balance", "spell", "nature" },
  use = { cd = 20, cost = 5, resource = "mana", effects = { { type = "debuff", stat = "armor", value = 35, duration = 20 } } } }
H.Ability{ id = 1008, key = "entangling_roots", spec = "shared", name = "Entangling Roots", icon = I("Spell_Nature_StrangleVines"), quality = 1, cost = 3, classes = DRUID, shape = S.v2, tags = { "balance", "spell", "nature", "dot" },
  use = { cd = 14, cost = 12, resource = "mana", effects = { { type = "stun", duration = 1.0 }, { type = "dot", key = "entangling_roots", school = "nature", tick = 2, duration = 6 } } } }
H.Ability{ id = 1009, key = "omen_of_clarity", spec = "balance", name = "Omen of Clarity", icon = I("Spell_Nature_CrystalBall"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, tags = { "feral", "balance" },
  triggers = { { on = "adjacentHit", match = { tag = "autoattack" }, chance = 20, effects = { { type = "buff", key = "clearcasting", stat = "none", value = 0, free = true, match = { anyTag = { "spell", "strike", "finisher" } }, duration = 10, name = "Clearcasting" } } } } }
H.Ability{ id = 1010, key = "innervate", spec = "shared", name = "Innervate", icon = I("Spell_Nature_Lightning"), quality = 4, cost = 10, minRound = 7, classes = DRUID, shape = S.v2, tags = { "balance", "resto", "spell" },
  use = { cd = 20, condition = "lowMana", effects = { { type = "resource", resource = "mana", amount = 60 } } } }

H.Ability{ id = 1011, key = "cat_form", spec = "shared", name = "Cat Form", icon = I("Ability_Druid_CatForm"), kind = "form", quality = 1, cost = 3, classes = DRUID, shape = S.sq, tags = { "feral", "form", "autoattack", "melee" },
  provides = "catform", replacesWeapon = true, grants = { energy = { max = 100, start = 60, regen = 10 }, combo = { max = 5, start = 0, regen = 0 } }, stats = { ap = 8, crit = 3 },
  use = { cd = 1.0, effects = { { type = "damage", min = 3, max = 5, school = "physical", coef = 0.12 } } } }
H.Ability{ id = 1012, key = "claw", spec = "feral", name = "Claw", icon = I("Ability_Druid_Rake"), quality = 1, classes = DRUID, shape = S.v2, tags = { "feral", "melee", "strike" },
  use = { cd = 4, cost = 40, resource = "energy", requires = "catform", effects = { { type = "damage", weapon = true, min = 6, max = 9, school = "physical", coef = 0.25 }, { type = "resource", resource = "combo", amount = 1 }, { type = "resource", resource = "combo", amount = 1, cond = "enemyBleeding" } } } }
H.Ability{ id = 1013, key = "rake", spec = "feral", name = "Rake", icon = I("Ability_Druid_Disembowel"), quality = 2, minRound = 2, classes = DRUID, shape = S.v2, tags = { "feral", "melee", "bleed", "dot", "strike" },
  use = { cd = 9, cost = 35, resource = "energy", requires = "catform", effects = { { type = "damage", min = 3, max = 5, school = "physical", coef = 0.1 }, { type = "dot", key = "rake", school = "physical", tick = 3, coef = 0.08, duration = 9, rolling = true }, { type = "resource", resource = "combo", amount = 1 } } },
  triggers = { { on = "dotTick", match = { key = "rake" }, effects = { { type = "resource", resource = "energy", amount = 2 } } } } }
H.Ability{ id = 1014, key = "shred", spec = "feral", name = "Shred", icon = I("Spell_Shadow_VampiricAura"), quality = 3, minRound = 4, classes = DRUID, shape = S.L, tags = { "feral", "melee", "strike" },
  use = { cd = 6, cost = 60, resource = "energy", requires = "catform", effects = { { type = "damage", weapon = true, weaponPct = 2.25, min = 6, max = 10, school = "physical", coef = 0.3, perStatus = 0.1, critIf = "enemyStunned" }, { type = "resource", resource = "combo", amount = 2 } } } }
H.Ability{ id = 1015, key = "rip", spec = "feral", name = "Rip", icon = I("Ability_GhoulFrenzy"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, rankIds = { [2] = 31015, [3] = 41015 }, tags = { "feral", "melee", "bleed", "dot", "finisher" },
  use = { cd = 12, initialDelay = 0.1, cost = 3, resource = "combo", spendAll = true, requires = "catform", effects = { { type = "dot", key = "rip", school = "physical", tick = 5, coef = 0.08, duration = 12, perCombo = 0.4, rolling = true } } } }
H.Ability{ id = 1016, key = "ferocious_bite", spec = "feral", name = "Ferocious Bite", icon = I("Ability_Druid_FerociousBite"), quality = 3, minRound = 5, classes = DRUID, shape = S.sq, rankIds = { [2] = 31016, [3] = 41016 }, tags = { "feral", "melee", "finisher" },
  use = { cd = 6, initialDelay = 0.1, cost = 3, resource = "combo", spendAll = true, requires = "catform", effects = { { type = "damage", min = 18, max = 24, school = "physical", coef = 0.4, scaleMissing = 0.5, perCombo = 0.4, consumeDots = { match = { tag = "bleed" }, fraction = 0.35 } } } } }
H.Ability{ id = 1017, key = "tigers_fury", spec = "feral", name = "Tiger's Fury", icon = I("Ability_Mount_JungleTiger"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, tags = { "feral" },
  use = { cd = 10, initialDelay = 2, cost = 25, resource = "energy", requires = "catform", effects = { { type = "buff", stat = "ap", value = 20, duration = 4, key = "tigers_fury", name = "Tiger's Fury" } } },
  triggers = { { on = "anyHit", match = { kind = "form" }, condition = "buff:tigers_fury", effects = { { type = "resource", resource = "combo", amount = 1 } } } } }
H.Ability{ id = 1018, key = "bear_form", spec = "shared", name = "Bear Form", icon = I("Ability_Racial_BearForm"), kind = "form", quality = 1, cost = 3, classes = DRUID, shape = S.sq, tags = { "bear", "feral", "form", "defensive", "autoattack", "melee" },
  provides = "bearform", replacesWeapon = true, grants = { rage = { max = 100, start = 10, regen = 0 } }, stats = { armor = 40, hpPct = 25 },
  use = { cd = 2.5, effects = { { type = "damage", weapon = true, min = 2, max = 4, school = "physical", coef = 0.3, generatesRage = true } } } }
H.Ability{ id = 1019, key = "maul", spec = "feral", name = "Maul", icon = I("Ability_Druid_Maul"), quality = 1, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "melee", "strike" },
  use = { cd = 3, cost = 10, resource = "rage", spendMax = 40, requires = "bearform", effects = { { type = "damage", weapon = true, min = 4, max = 8, school = "physical", coef = 0.25, perPoint = 0.4, pointResource = "rage", spendBank = "maul" } } },
  triggers = { { on = "damaged", effects = { { type = "bank", key = "maul", fraction = 0.15, cap = { flat = 40, ap = 1.2, armor = 0.2 } } } } } }
H.Ability{ id = 1020, key = "swipe", spec = "feral", name = "Swipe", icon = I("INV_Misc_MonsterClaw_03"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "melee" },
  use = { cd = 6, cost = 20, resource = "rage", requires = "bearform", empower = { key = "primal_fury", cost = 10, max = 3 }, effects = { { type = "damage", min = 8, max = 12, school = "physical", coef = 0.5, repeatPaidCharges = true }, { type = "debuff", stat = "armor", value = 20, duration = 4, key = "swipe_exposed", name = "Swipe" } } } }
H.Ability{ id = 1021, key = "enrage_druid", spec = "shared", shopRequires = { "bear_form" }, name = "Enrage", icon = I("Ability_Druid_Enrage"), quality = 1, cost = 2, classes = DRUID, shape = S.v2, tags = { "bear", "feral" }, rankable = false,
  use = { cd = 20, healthCostPct = 0.05, requires = "bearform", effects = { { type = "resource", resource = "rage", amount = 35 } } } }
H.Ability{ id = 1022, key = "frenzied_regeneration", spec = "feral", name = "Frenzied Regeneration", icon = I("Ability_BullRush"), quality = 3, minRound = 5, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "defensive", "heal" },
  use = { reactive = true, cd = 15, cost = 20, resource = "rage", spendMax = 50, requires = "bearform", condition = "below50", effects = { { type = "heal", perPointPctMax = 0.004, pointResource = "rage" } } } }
H.Ability{ id = 1023, key = "demoralizing_roar", spec = "shared", name = "Demoralizing Roar", icon = I("Ability_Druid_DemoralizingRoar"), quality = 1, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "defensive" },
  use = { cd = 12, cost = 10, resource = "rage", requires = "bearform", effects = { { type = "debuff", stat = "ap", value = 16, duration = 10 }, { type = "debuff", stat = "dmgPct", value = 8, duration = 10 } } } }
H.Ability{ id = 1025, key = "leader_of_the_pack", spec = "feral", name = "Leader of the Pack", icon = I("Spell_Nature_UnyeildingStamina"), quality = 5, cost = 15, minRound = 10, classes = DRUID, shape = S.sq, tags = { "feral" },
  stats = { crit = 8, ap = 15 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "feral" }, oncePerActivation = true, icd = 1,
    effects = { { type = "cdr", target = "neighbors", match = { kind = "form", tag = "autoattack" }, amount = 1, clampReady = true } } } } }
H.Ability{ id = 1036, key = "savage_fury", spec = "feral", name = "Savage Fury", icon = I("Ability_Druid_Ravage"), quality = 4, cost = 10, minRound = 7, classes = DRUID, shape = S.v2, tags = { "feral" },
  triggers = {
    { on = "resourceSpent", resource = "energy", everyAmount = 60, effects = { { type = "buff", stat = "ap", value = 8, duration = 120, stack = true, maxStacks = 15, key = "savage_fury", name = "Savage Fury" } } },
    { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "buff", stat = "ap", value = 8, duration = 120, stack = true, maxStacks = 15, key = "savage_fury", name = "Savage Fury" } } },
  } }
H.Ability{ id = 1037, key = "feral_charge", spec = "feral", name = "Feral Charge", icon = I("Ability_Hunter_Pet_Bear"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, tags = { "bear", "feral" },
  use = { cd = 15, initialDelay = 2, requires = "bearform", effects = { { type = "damage", min = 8, max = 12, school = "physical", coef = 0.15 }, { type = "stun", duration = 1.25 } } } }

H.Ability{ id = 1026, key = "rejuvenation", spec = "resto", name = "Rejuvenation", icon = I("Spell_Nature_Rejuvenation"), quality = 1, classes = DRUID, shape = S.v2, tags = { "resto", "spell", "heal", "hot", "nature" },
  use = { reactive = true, cd = 12, cost = 12, resource = "mana", condition = "injured", effects = { { type = "hot", key = "rejuvenation", tick = 3, coef = 0.1, duration = 12 } } },
  triggers = { { on = "anyHit", match = { tag = "autoattack" }, chance = 25, effects = { { type = "refresh", key = "rejuvenation" } } } } }
H.Ability{ id = 1027, key = "regrowth", spec = "resto", name = "Regrowth", icon = I("Spell_Nature_ResistNature"), quality = 2, minRound = 2, classes = DRUID, shape = S.v2, tags = { "resto", "spell", "heal", "hot", "nature" },
  use = { reactive = true, cd = 4, cost = 18, resource = "mana", condition = "injured", effects = { { type = "heal", min = 10, max = 14, coef = 0.3 }, { type = "hot", key = "regrowth", tick = 2, coef = 0.05, duration = 9 } } },
  triggers = { { on = "crit", healing = true, effects = { { type = "tickHots" } } } } }
H.Ability{ id = 1028, key = "healing_touch", spec = "resto", name = "Healing Touch", icon = I("Spell_Nature_HealingTouch"), quality = 1, cost = 3, classes = DRUID, shape = S.sq, tags = { "resto", "spell", "heal", "nature" },
  use = { reactive = true, cd = 3.5, cost = 22, resource = "mana", condition = "injured", effects = { { type = "heal", min = 12, max = 18, coef = 0.7 } } },
  triggers = { { on = "healed", match = { key = "healing_touch" }, effects = { { type = "tickHots" } } } } }
H.Ability{ id = 1029, key = "swiftmend", spec = "resto", name = "Swiftmend", icon = I("INV_Relics_IdolofRejuvenation"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "resto", "spell", "heal", "nature" },
  use = { reactive = true, cd = 15, cost = 12, resource = "mana", condition = "injuredWithHot", effects = { { type = "heal", min = 18, max = 22, coef = 0.4, consumeHots = true } } } }
H.Ability{ id = 1030, key = "natures_swiftness", spec = "resto", name = "Nature's Swiftness", icon = I("Spell_Nature_RavenForm"), quality = 5, cost = 15, minRound = 11, classes = DRUID, shape = S.sq, tags = { "resto", "balance" },
  triggers = { { on = "adjacentCrit", healing = true, match = { tag = "spell" }, effects = { { type = "buff", stat = "none", value = 0, duration = 3, key = "natures_swiftness", name = "Nature's Swiftness", double = { tag = "heal" } }, { type = "cdr", target = "neighbors", match = { tag = "heal" }, amount = 1.5 } } } } }
H.Ability{ id = 1031, key = "tranquility", spec = "resto", name = "Tranquility", icon = I("Spell_Nature_Tranquility"), quality = 4, cost = 11, minRound = 7, classes = DRUID, shape = S.T, tags = { "resto", "spell", "heal", "hot", "nature" },
  use = { reactive = true, cd = 24, cost = 32, resource = "mana", condition = "below50", effects = { { type = "hot", key = "tranquility", tick = 12, coef = 0.3, duration = 8 } } },
  triggers = { { on = "hotTick", match = { key = "tranquility" }, effects = { { type = "dot", key = "tranquility_bloom", school = "nature", tick = 0, fromEvent = 0.35, duration = 4, rolling = true } } } } }
H.Ability{ id = 1032, key = "barkskin", spec = "shared", name = "Barkskin", icon = I("Spell_Nature_StoneClawTotem"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, tags = { "resto", "defensive", "spell" },
  use = { reactive = true, cd = 20, cost = 10, resource = "mana", condition = "below50", effects = { { type = "buff", stat = "dr", value = 20, duration = 8 } } } }
H.Ability{ id = 1033, key = "thorns", spec = "balance", name = "Thorns", icon = I("Spell_Nature_Thorns"), quality = 1, classes = DRUID, shape = S.v2, tags = { "balance", "nature", "spell" }, rankable = true,
  triggers = {
    { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "bank", key = "thorns", fraction = 0.35 } } },
    { on = "damaged", matchAttacker = { tag = "melee" }, effects = { { type = "damage", min = 3, max = 5, school = "nature", coef = 0.4, noDodge = true, spendBank = "thorns" } } },
  } }
H.Ability{ id = 1038, key = "natures_focus", spec = "resto", name = "Nature's Focus", icon = I("spell_nature_healingwavegreater"), quality = 2, minRound = 4, classes = DRUID, shape = S.v2, tags = { "resto" },
  stats = { healing = 4 },
  triggers = { { on = "healed", everyAmount = 35, effects = { { type = "absorb", amount = 8, coef = 0.15 } } } } }
H.Ability{ id = 1041, key = "vengeance", spec = "balance", name = "Vengeance", icon = I("Spell_Nature_Purge"), quality = 4, cost = 10, minRound = 7, classes = DRUID, shape = S.v2, tags = { "balance" },
  stats = { crit = 3 },
  triggers = { { on = "anyCrit", match = { tag = "spell" }, effects = { { type = "buff", key = "clearcasting", stat = "none", value = 0, free = true, match = { tag = "spell" }, duration = 8, name = "Clearcasting" } } } } }
H.Ability{ id = 1045, key = "pounce", spec = "feral", name = "Pounce", icon = I("Ability_Druid_SupriseAttack"), quality = 2, minRound = 3, classes = DRUID, shape = S.v2, tags = { "feral", "bleed", "dot" },
  use = { cd = 20, initialDelay = 2, requires = "catform", effects = { { type = "stun", duration = 2.0 }, { type = "dot", key = "pounce", school = "physical", tick = 3, coef = 0.05, duration = 8 }, { type = "resource", resource = "combo", amount = 2 } } } }
H.Ability{ id = 1046, key = "ravage", spec = "feral", name = "Ravage", icon = I("Ability_Druid_Ravage"), quality = 3, minRound = 5, classes = DRUID, shape = S.v2, tags = { "feral", "melee", "strike" },
  use = { cd = 2, initialDelay = 2, priority = 90, once = true, cost = 60, resource = "energy", requires = "catform", condition = "enemyStunned", effects = { { type = "damage", weapon = true, weaponPct = 3.0, min = 12, max = 18, school = "physical", coef = 0.5, critBonus = 20 }, { type = "resource", resource = "combo", amount = 2 } } } }
H.Ability{ id = 1047, key = "blood_frenzy", spec = "feral", name = "Blood Frenzy", icon = I("Ability_GhoulFrenzy"), quality = 4, cost = 10, minRound = 7, classes = DRUID, shape = S.v2, tags = { "feral" },
  triggers = { { on = "dotTick", match = { tag = "bleed" }, everyAmount = 25, effects = { { type = "resource", resource = "combo", amount = 1 } } } } }
H.Ability{ id = 1048, key = "furor", spec = "resto", name = "Furor", icon = I("Spell_Holy_BlessingOfStamina"), quality = 2, minRound = 2, classes = DRUID, shape = S.v2, tags = { "feral" },
  triggers = { { on = "healed", everyAmount = 25, effects = { { type = "resource", resource = "energy", amount = 8 }, { type = "resource", resource = "rage", amount = 4 } } } } }

H.Ability{ id = 2100, key = "improved_wrath", spec = "balance", shopRequires = { "wrath" }, name = "Improved Wrath", icon = I("spell_nature_abolishmagic"), quality = 1, cost = 3, classes = DRUID, shape = S.v2, tags = { "balance" },
  adjacency = { { match = { key = "wrath" }, mods = { cdPct = 20 } } },
  triggers = { { on = "anyCrit", healing = false, match = { key = "wrath" }, effects = { { type = "cdr", target = "neighbors", match = { tag = "spell" }, amount = 0.5 } } } } }
H.Ability{ id = 2101, key = "improved_moonfire", spec = "balance", shopRequires = { "moonfire" }, name = "Improved Moonfire", icon = I("spell_nature_starfall"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "balance" },
  adjacency = { { match = { key = "moonfire" }, mods = { crit = 20, dmgPct = 20 } } },
  triggers = { { on = "dotTick", match = { key = "moonfire" }, everyAmount = 20, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }
H.Ability{ id = 2102, key = "improved_starfire", spec = "balance", shopRequires = { "starfire" }, name = "Improved Starfire", icon = I("spell_arcane_starfire"), quality = 4, cost = 10, minRound = 7, classes = DRUID, shape = S.L, tags = { "balance" },
  adjacency = { { match = { key = "starfire" }, mods = { crit = 15 } } },
  triggers = { { on = "anyCrit", healing = false, match = { key = "starfire" }, effects = { { type = "stun", duration = 0.75 }, { type = "cast", key = "moonfire" } } } } }
H.Ability{ id = 2103, key = "moonglow", spec = "balance", name = "Moonglow", icon = I("spell_nature_sentinal"), quality = 2, cost = 5, minRound = 2, classes = DRUID, shape = S.v2, tags = { "balance", "resto" },
  triggers = { { on = "anyCrit", match = { tag = "spell" }, effects = { { type = "resource", resource = "mana", amount = 6 } } } } }
H.Ability{ id = 2104, key = "moonfury", spec = "balance", name = "Moonfury", icon = I("spell_nature_moonglow"), quality = 4, cost = 10, minRound = 8, classes = DRUID, shape = S.v2, tags = { "balance" }, stats = { critDamage = 25 },
  adjacency = { { match = { tag = "spell" }, mods = { crit = 10 } } } }
H.Ability{ id = 2105, key = "natural_shapeshifter", spec = "balance", name = "Natural Shapeshifter", icon = I("spell_nature_wispsplode"), quality = 3, cost = 7, minRound = 5, classes = DRUID, shape = S.v2, tags = { "balance", "feral" },
  triggers = {
    { on = "adjacentHit", match = { kind = "form" }, effects = { { type = "resource", resource = "mana", amount = 2 } } },
    { on = "adjacentUse", match = { tag = "spell" }, effects = { { type = "cdr", target = "neighbors", match = { kind = "form" }, amount = 0.5 } } },
  } }
H.Ability{ id = 2106, key = "natures_grasp", spec = "balance", shopRequires = { "entangling_roots" }, name = "Nature's Grasp", icon = I("spell_nature_natureswrath"), quality = 2, cost = 5, minRound = 3, classes = DRUID, shape = S.v2, tags = { "balance", "defensive" },
  triggers = { { on = "damaged", chance = 30, icd = 6, effects = { { type = "cast", key = "entangling_roots" } } } } }

H.Ability{ id = 2107, key = "heart_of_the_wild", spec = "feral", shopRequires = { "healing_touch" }, name = "Heart of the Wild", icon = I("spell_holy_blessingofagility"), quality = 5, cost = 15, minRound = 11, classes = DRUID, shape = S.sq, tags = { "feral", "resto" }, stats = { hp = 40, healing = 18 },
  triggers = {
    { on = "resourceSpent", resource = "energy", everyAmount = 60, effects = { { type = "cast", key = "healing_touch" } } },
    { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "cast", key = "healing_touch" } } },
  } }

H.Ability{ id = 2108, key = "reflection", spec = "resto", name = "Reflection", icon = I("spell_frost_windwalkon"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "resto" },
  triggers = { { on = "hotTick", everyAmount = 20, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }
H.Ability{ id = 2109, key = "improved_rejuvenation", spec = "resto", shopRequires = { "rejuvenation" }, name = "Improved Rejuvenation", icon = I("spell_nature_rejuvenation"), quality = 2, cost = 5, minRound = 2, classes = DRUID, shape = S.v2, tags = { "resto" },
  adjacency = { { match = { key = "rejuvenation" }, mods = { healPct = 25 } } },
  triggers = { { on = "hotTick", match = { key = "rejuvenation" }, everyAmount = 20, effects = { { type = "cdr", target = "neighbors", match = { tag = "heal" }, amount = 0.5 } } } } }
H.Ability{ id = 2110, key = "improved_regrowth", spec = "resto", shopRequires = { "regrowth" }, name = "Improved Regrowth", icon = I("spell_nature_resistnature"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "resto", "balance" },
  adjacency = { { match = { key = "regrowth" }, mods = { crit = 25 } } },
  triggers = { { on = "anyCrit", healing = true, match = { key = "regrowth" }, effects = { { type = "tickDots", match = { tag = "spell" } } } } } }
H.Ability{ id = 2111, key = "improved_healing_touch", spec = "resto", shopRequires = { "healing_touch" }, name = "Improved Healing Touch", icon = I("spell_nature_healingtouch"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "resto" },
  adjacency = { { match = { key = "healing_touch" }, mods = { healPct = 30, costPct = -20 } } },
  triggers = { { on = "anyUse", match = { key = "healing_touch" }, effects = { { type = "refresh", match = { tag = "hot" } } } } } }
H.Ability{ id = 2112, key = "gift_of_nature", spec = "resto", name = "Gift of Nature", icon = I("spell_nature_protectionformnature"), quality = 4, cost = 10, minRound = 8, classes = DRUID, shape = S.v2, tags = { "resto", "balance" }, stats = { healing = 12 },
  triggers = { { on = "healed", everyAmount = 40, effects = { { type = "buff", stat = "sp", value = 3, target = "all", match = { tag = "spell", anyTag = { "dot" } }, duration = 120, stack = true, maxStacks = 15, key = "gift_of_nature", name = "Gift of Nature" } } } } }
H.Ability{ id = 2113, key = "tranquil_spirit", spec = "resto", name = "Tranquil Spirit", icon = I("spell_holy_elunesgrace"), quality = 3, cost = 7, minRound = 5, classes = DRUID, shape = S.v2, tags = { "resto" },
  adjacency = { { match = { tag = "heal" }, mods = { costPct = -20 } } },
  triggers = { { on = "adjacentCrit", healing = true, effects = { { type = "resource", resource = "mana", amount = 8 } } } } }
H.Ability{ id = 2114, key = "abolish_poison", spec = "resto", name = "Abolish Poison", icon = I("spell_nature_nullifypoison_02"), quality = 1, cost = 3, classes = DRUID, shape = S.one, tags = { "resto", "spell", "heal", "nature" },
  use = { cd = 10, cost = 10, resource = "mana", condition = "hasDot", effects = { { type = "cleanse", count = 1, countPerRank = 1 }, { type = "heal", min = 6, max = 8, coef = 0.2 } } } }
H.Ability{ id = 2115, key = "mark_of_the_wild", spec = "shared", name = "Mark of the Wild", icon = I("spell_nature_regeneration"), quality = 1, cost = 3, classes = DRUID, shape = S.one, tags = { "nature", "defensive" }, stats = { hp = 20, armor = 8, ap = 4, sp = 4, healing = 4 } }

H.Ability{ id = 2120, key = "thick_hide", spec = "feral", shopRequires = { "maul" }, name = "Thick Hide", icon = I("inv_misc_pelt_bear_03"), quality = 2, cost = 5, minRound = 3, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "defensive" },
  triggers = { { on = "armorPrevented", condition = "provides:bearform", effects = { { type = "bank", key = "maul", fraction = 0.35, cap = { flat = 40, ap = 1.2, armor = 0.2 } } } } } }
H.Ability{ id = 2121, key = "primal_fury", spec = "feral", shopRequires = { "swipe" }, name = "Primal Fury", icon = I("ability_racial_cannibalize"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "bear", "feral" },
  triggers = { { on = "anyCrit", healing = false, match = { key = "bear_form", tag = "autoattack" }, condition = "provides:bearform", effects = { { type = "charge", key = "primal_fury", amount = 1, max = 3 } } } } }
H.Ability{ id = 2122, key = "bash", spec = "feral", name = "Bash", icon = I("ability_druid_bash"), quality = 3, cost = 7, minRound = 4, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "melee", "strike", "control" },
  use = { cd = 12, initialDelay = 2, cost = 25, resource = "rage", requires = "bearform", effects = { { type = "damage", weapon = true, weaponPct = 1.1, min = 8, max = 12, school = "physical", coef = 0.25 }, { type = "stun", duration = 1.5, rankScale = false } } } }
H.Ability{ id = 2123, key = "brutal_impact", spec = "feral", shopRequires = { "bash" }, name = "Brutal Impact", icon = I("ability_druid_bash"), quality = 4, cost = 10, minRound = 7, classes = DRUID, shape = S.v2, tags = { "bear", "feral", "control" },
  triggers = { { on = "enemyStunned", condition = "provides:bearform", effects = { { type = "buff", key = "brutal_impact", name = "Brutal Impact", stat = "crit", value = 100, charges = 1, duration = 5, target = "all", match = { tag = "bear", damaging = "direct" } } } } } }
