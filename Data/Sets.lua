local ADDON, ns = ...
local H = ns.H

ns.RegisterSet{ key = "feralheart", name = "Feralheart Raiment",
  bonuses = {
    [2] = { triggers = { { on = "anyUse", match = { tag = "feral", anyTag = { "strike" } }, effects = { { type = "dot", key = "rake", school = "physical", tick = 3, coef = 0.08, duration = 9 } } } }, text = "Feral strikes apply Rake's bleed." },
    [4] = { triggers = {
      { on = "anyCrit", match = { tag = "finisher" }, effects = { { type = "resource", resource = "combo", amount = 3 } } },
      { on = "anyCrit", healing = false, match = { key = "maul" }, effects = { { type = "resource", resource = "rage", amount = 8 } } },
    }, text = "Finisher crits restore 3 combo points. Maul crits restore 8 Rage." },
  } }
ns.RegisterSet{ key = "cenarion", name = "Cenarion Raiment",
  bonuses = {
    [2] = { triggers = { { on = "anyUse", match = { tag = "spell" }, condition = "enemyHas:moonfire", effects = { { type = "refresh", key = "moonfire" } } } }, text = "Every spell cast refreshes Moonfire." },
    [4] = { triggers = { { on = "anyCrit", match = { tag = "spell" }, effects = { { type = "resource", resource = "mana", amount = 20 } } } }, text = "Spell crits refund 20 mana." },
    [6] = { free = { tag = "spell" }, mods = { match = { tag = "balance" }, cdPct = 40 }, text = "Spells cost nothing and Balance spells recharge 40% faster." },
  } }
ns.RegisterSet{ key = "stormrage", name = "Stormrage Raiment",
  bonuses = {
    [2] = { triggers = { { on = "healed", icd = 3, effects = { { type = "absorb", amount = 10, coef = 0.3 } } } }, text = "Your heals also shield you." },
    [4] = { triggers = { { on = "anyUse", match = { key = "swiftmend" }, effects = { { type = "cast", key = "rejuvenation", ignoreCondition = true }, { type = "cast", key = "regrowth", ignoreCondition = true } } } }, text = "Swiftmend casts your Rejuvenation and Regrowth for free." },
    [6] = { flags = { "revive" }, mods = { match = { tag = "heal" }, healPct = 100 }, text = "Heals are doubled, and once per battle you return to full health instead of dying." },
  } }

ns.RegisterSet{ key = "heroism", name = "Battlegear of Heroism",
  bonuses = {
    [2] = { triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "buff", stat = "haste", value = 20, duration = 5, key = "heroism_2", name = "Battlegear of Heroism" } } } }, text = "Every 30 rage spent grants 20% haste for 5 seconds." },
    [4] = { stats = { ap = 30, haste = 10 } },
  } }
ns.RegisterSet{ key = "might", name = "Battlegear of Might",
  bonuses = {
    [2] = { triggers = { { on = "block", effects = { { type = "resource", resource = "rage", amount = 4 } } } }, text = "Blocking generates 4 rage." },
    [4] = { stats = { block = 20, blockChance = 15 } },
    [6] = { triggers = { { on = "block", icd = 2, effects = { { type = "cast", key = "shield_slam" } } } }, stats = { block = 30, dr = 25 }, text = "Blocks trigger your Shield Slam for free (2s cooldown)." },
  } }
ns.RegisterSet{ key = "wrath", name = "Battlegear of Wrath",
  bonuses = {
    [2] = { triggers = { { on = "anyUse", match = { tag = "strike" }, effects = { { type = "tickDots", match = { tag = "bleed" } } } } }, text = "Using a strike immediately ticks your bleeds." },
    [4] = { stats = { crit = 10, critDamage = 25 } },
    [6] = { double = { tag = "strike" }, stats = { crit = 25, critDamage = 75 }, text = "Strikes hit twice." },
  } }

ns.RegisterSet{ key = "beastmaster", name = "Beastmaster Armor",
  bonuses = {
    [2] = { triggers = { { on = "anyUse", match = { tag = "pet" }, icd = 2, effects = { { type = "heal", min = 0, max = 0, pctMax = 0.0125 } } } }, text = "Pet abilities heal you for 1.25% maximum Health." },
    [4] = { triggers = { { on = "resourceSpent", resource = "focus", everyAmount = 35, effects = { { type = "buff", stat = "petPct", value = 25, duration = 6, key = "beastmaster_4", name = "Beastmaster Armor" } } } }, text = "Every 35 Focus spent grants 25% pet damage for 6s." },
  } }
ns.RegisterSet{ key = "giantstalker", name = "Giantstalker Armor",
  bonuses = {
    [2] = { triggers = { { on = "anyUse", match = { key = "aimed_shot" }, effects = { { type = "debuff", stat = "armor", value = 15, duration = 8, key = "giantstalker_2", name = "Giantstalker Armor" } } } }, text = "Aimed Shot strips 15 armor." },
    [4] = { triggers = { { on = "anyCrit", match = { tag = "shot" }, icd = 3, effects = { { type = "buff", key = "clearcasting", stat = "none", value = 0, free = true, match = { tag = "shot" }, duration = 6, name = "Giantstalker Armor" } } } }, text = "Shot crits make the next shot free." },
    [6] = { double = { tag = "shot" }, triggers = { { on = "battleStart", effects = { { type = "cdr", target = "all", match = { tag = "shot" }, amount = 60 } } } }, text = "Shots fire twice and start ready." },
  } }
ns.RegisterSet{ key = "dragonstalker", name = "Dragonstalker Armor",
  bonuses = {
    [2] = { double = { key = "serpent_sting" }, text = "Serpent Sting applies two stacks at once." },
    [4] = { triggers = { { on = "anyUse", match = { tag = "trap" }, effects = { { type = "resource", resource = "mana", amount = 12 } } }, { on = "dotTick", match = { key = "serpent_sting" }, chance = 15, icd = 2, effects = { { type = "stun", duration = 0.5 } } } }, text = "Traps restore 12 Mana. Sting ticks can stagger the enemy." },
    [6] = { double = { anyTag = { "trap", "sting" } }, flags = { "revive" }, text = "Traps and stings apply twice, and once per battle you return to full health instead of dying." },
  } }

ns.RegisterSet{ key = "dreadnaught", name = "Dreadnaught's Battlegear",
  bonuses = {
    [2] = { triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 40, effects = { { type = "cdr", target = "all", match = { tag = "autoattack" }, amount = 1 } } } }, text = "Every 40 Rage spent advances auto-attacks by 1s." },
    [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "autoattack", anyTag = { "melee" } }, icd = 0.5, effects = { { type = "cdr", target = "all", match = { kind = "ability", tag = "strike", anyTag = { "melee" }, damaging = "direct" }, amount = 0.35, clampReady = true } } } }, text = "Melee auto-attack crits advance your direct melee strikes by 0.35s (0.5s cooldown)." },
    [6] = { double = { tag = "autoattack" }, stats = { lifesteal = 15 }, text = "Auto-attacks hit twice." },
  } }
ns.RegisterSet{ key = "cryptstalker", name = "Cryptstalker Armor",
  bonuses = {
    [2] = { triggers = { { on = "resourceSpent", resource = "focus", everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Every 30 Focus spent restores 8 Mana." },
    [4] = { mods = { match = { tag = "pet" }, cdPct = 30 }, text = "Pet ability cooldowns are 30% shorter." },
    [6] = { double = { tag = "pet" }, triggers = { { on = "anyHit", match = { tag = "pet" }, effects = { { type = "heal", fromEvent = 0.25 } } } }, text = "Pet abilities fire twice. Pet hits heal you for 25% of their damage." },
  } }
ns.RegisterSet{ key = "dreamwalker", name = "Dreamwalker Raiment",
  bonuses = {
    [2] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "feral" }, effects = { { type = "heal", pctMax = 0.02 } } } }, text = "Feral crits heal 2% maximum Health." },
    [4] = { mods = { match = { tag = "feral" }, dmgPct = 30 }, text = "Feral abilities deal 30% more damage." },
    [6] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "feral" }, effects = { { type = "resource", resource = "energy", amount = 40 }, { type = "resource", resource = "rage", amount = 20 }, { type = "cdr", target = "all", match = { tag = "feral" }, amount = 2 } } } }, text = "Feral crits restore 40 Energy and 20 Rage. Advance all Feral abilities by 2s." },
  } }
ns.RegisterSet{ key = "dalrend", name = "Dal'Rend's Arms",
  bonuses = { [2] = { stats = { ap = 30, haste = 10 } } } }
ns.RegisterSet{ key = "devilsaur", name = "Devilsaur Armor",
  bonuses = { [2] = { stats = { crit = 8 } } } }

H.SetPieces{ key = "feralheart", ids = { 1106, 1107, 1108, 1111 }, tag = "feral", classes = { "DRUID" }, armorType = "leather", quality = 3, qualities = { 2, 3, 3, 3 }, rounds = { 3, 3, 5, 6 },
  slots = { "head", "shoulder", "chest", "feet" }, stats = { hp = 20, armor = 10, ap = 18, healing = 4 },
  names = { "Feralheart Cowl", "Feralheart Spaulders", "Feralheart Vest", "Feralheart Boots" },
  icons = { "inv_helmet_27", "inv_shoulder_01", "inv_chest_plate06", "inv_boots_08" } }
H.SetPieces{ key = "cenarion", firstId = 1112, tag = "balance", classes = { "DRUID" }, armorType = "leather", quality = 4, rounds = { 4, 10, 6, 4, 12, 7 },
  stats = { hp = 20, armor = 8, sp = 14, healing = 6 },
  names = { "Cenarion Helm", "Cenarion Spaulders", "Cenarion Vestments", "Cenarion Gloves", "Cenarion Leggings", "Cenarion Boots" },
  icons = { "INV_Helmet_09", "inv_shoulder_07", "inv_chest_cloth_06", "inv_gauntlets_07", "inv_pants_06", "inv_boots_08" } }
H.SetPieces{ key = "stormrage", firstId = 1118, tag = "resto", classes = { "DRUID" }, armorType = "leather", quality = 4, rounds = { 5, 11, 8, 5, 13, 9 },
  stats = { hp = 24, armor = 10, healing = 18, sp = 4, regen = 1 },
  names = { "Stormrage Cover", "Stormrage Pauldrons", "Stormrage Chestguard", "Stormrage Handguards", "Stormrage Legguards", "Stormrage Boots" },
  icons = { "inv_helmet_09", "inv_shoulder_07", "inv_chest_chain_16", "inv_gauntlets_25", "inv_pants_06", "INV_Boots_08" } }

H.SetPiece{ id = 1306, key = "heroism_head", name = "Helm of Heroism", icon = H.I("inv_helmet_02"), quality = 2, minRound = 3, classes = { "WARRIOR" }, armorType = "plate", slot = "head", set = "heroism", tags = { "fury" }, stats = { armor = 14, ap = 10, crit = 5 },
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 25, effects = { { type = "cdr", target = "neighbors", match = { tag = "autoattack" }, amount = 0.8 } } } } }
H.SetPiece{ id = 1309, key = "heroism_hands", name = "Gauntlets of Heroism", icon = H.I("inv_gauntlets_26"), quality = 2, minRound = 3, classes = { "WARRIOR" }, armorType = "plate", slot = "hands", set = "heroism", tags = { "fury" }, stats = { armor = 8, ap = 12 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "resource", resource = "rage", amount = 4 } } } } }
H.SetPiece{ id = 1312, key = "might_head", name = "Helm of Might", icon = H.I("inv_helmet_09"), quality = 4, minRound = 3, classes = { "WARRIOR" }, armorType = "plate", slot = "head", set = "might", tags = { "prot", "defensive" }, stats = { armor = 26, hp = 40 },
  triggers = { { on = "block", icd = 1, effects = { { type = "absorb", amount = 8 } } } } }
H.SetPiece{ id = 1315, key = "might_hands", name = "Gauntlets of Might", icon = H.I("INV_Gauntlets_10"), quality = 4, minRound = 4, classes = { "WARRIOR" }, armorType = "plate", slot = "hands", set = "might", tags = { "prot", "defensive" }, stats = { armor = 12, block = 8 },
  triggers = { { on = "block", effects = { { type = "buff", stat = "block", value = 2, duration = 6, stack = true, maxStacks = 4, key = "might_grip", name = "Gauntlets of Might" } } } } }
H.SetPiece{ id = 1318, key = "wrath_head", name = "Helm of Wrath", icon = H.I("inv_helmet_71"), quality = 4, minRound = 4, classes = { "WARRIOR" }, armorType = "plate", slot = "head", set = "wrath", tags = { "arms", "bleed" }, stats = { armor = 18, ap = 14, crit = 7 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "dot", key = "wrath_wound", school = "physical", duration = 4, rolling = true, fromEvent = 0.15 } } } } }
H.SetPiece{ id = 1321, key = "wrath_hands", name = "Gauntlets of Wrath", icon = H.I("inv_gauntlets_10"), quality = 4, minRound = 3, classes = { "WARRIOR" }, armorType = "plate", slot = "hands", set = "wrath", tags = { "arms" }, stats = { armor = 8, ap = 12 },
  triggers = { { on = "dotTick", match = { tag = "bleed" }, everyAmount = 12, effects = { { type = "cdr", target = "neighbors", match = { tag = "strike" }, amount = 0.8 } } } } }

H.SetPiece{ id = 1331, key = "heroism_chest", name = "Breastplate of Heroism", icon = H.I("INV_Chest_Plate03"), quality = 3, cost = 9, minRound = 5, classes = { "WARRIOR" }, armorType = "plate", slot = "chest", set = "heroism", tags = { "fury" }, stats = { ap = 40, armor = 30, hp = 45 } }
H.SetPiece{ id = 1332, key = "might_shoulder", name = "Pauldrons of Might", icon = H.I("INV_Shoulder_15"), quality = 4, cost = 6, minRound = 4, classes = { "WARRIOR" }, armorType = "plate", slot = "shoulder", set = "might", tags = { "prot", "defensive" }, stats = { armor = 20, block = 6, hp = 25 } }
H.SetPiece{ id = 1333, key = "might_chest", name = "Breastplate of Might", icon = H.I("INV_Chest_Plate16"), quality = 4, cost = 10, minRound = 6, classes = { "WARRIOR" }, armorType = "plate", slot = "chest", set = "might", tags = { "prot", "defensive" }, stats = { armor = 60, block = 14, hp = 90 } }
H.SetPiece{ id = 1334, key = "wrath_feet", name = "Sabatons of Wrath", icon = H.I("INV_Boots_Plate_04"), quality = 4, cost = 7, minRound = 5, classes = { "WARRIOR" }, armorType = "plate", slot = "feet", set = "wrath", tags = { "arms" }, stats = { ap = 20, crit = 4, armor = 12 } }
H.SetPiece{ id = 1335, key = "wrath_chest", name = "Breastplate of Wrath", icon = H.I("INV_Chest_Plate16"), quality = 4, cost = 12, minRound = 8, classes = { "WARRIOR" }, armorType = "plate", slot = "chest", set = "wrath", tags = { "arms" }, stats = { ap = 60, crit = 10, armor = 36, hp = 60 } }
H.SetPiece{ id = 1337, key = "heroism_feet", name = "Boots of Heroism", icon = H.I("inv_boots_plate_03"), quality = 3, cost = 8, minRound = 6, classes = { "WARRIOR" }, armorType = "plate", slot = "feet", set = "heroism", tags = { "fury" }, stats = { ap = 24, lifesteal = 5, armor = 12 } }
H.SetPiece{ id = 1338, key = "might_legs", name = "Legplates of Might", icon = H.I("inv_pants_04"), quality = 4, cost = 10, minRound = 10, classes = { "WARRIOR" }, armorType = "plate", slot = "legs", set = "might", tags = { "prot", "defensive" }, stats = { armor = 40, block = 18, hp = 60 } }
H.SetPiece{ id = 1339, key = "might_feet", name = "Sabatons of Might", icon = H.I("inv_boots_plate_04"), quality = 4, cost = 10, minRound = 12, classes = { "WARRIOR" }, armorType = "plate", slot = "feet", set = "might", tags = { "prot", "defensive" }, stats = { armor = 20, blockChance = 12, hp = 45 } }
H.SetPiece{ id = 1340, key = "wrath_shoulder", name = "Pauldrons of Wrath", icon = H.I("inv_shoulder_34"), quality = 4, cost = 10, minRound = 10, classes = { "WARRIOR" }, armorType = "plate", slot = "shoulder", set = "wrath", tags = { "arms" }, stats = { ap = 24, crit = 5, armor = 18 } }
H.SetPiece{ id = 1341, key = "wrath_legs", name = "Legplates of Wrath", icon = H.I("inv_pants_04"), quality = 4, cost = 12, minRound = 12, classes = { "WARRIOR" }, armorType = "plate", slot = "legs", set = "wrath", tags = { "arms" }, stats = { ap = 40, crit = 8, armor = 28, hp = 40 } }

H.SetPieces{ key = "beastmaster", ids = { 1506, 1507, 1508, 1511 }, tag = "bm", classes = { "HUNTER" }, armorType = "mail", quality = 3, qualities = { 2, 3, 3, 3 }, rounds = { 3, 3, 5, 6 },
  slots = { "head", "shoulder", "chest", "feet" }, stats = { hp = 20, armor = 12, ap = 14, crit = 1 },
  names = { "Beastmaster's Cap", "Beastmaster's Mantle", "Beastmaster's Tunic", "Beastmaster's Boots" },
  icons = { "inv_helmet_24", "inv_shoulder_10", "inv_chest_chain_03", "inv_boots_plate_07" } }
H.SetPieces{ key = "giantstalker", firstId = 1512, tag = "mm", classes = { "HUNTER" }, armorType = "mail", quality = 4, rounds = { 4, 10, 6, 4, 12, 7 },
  stats = { hp = 18, armor = 14, ap = 18, crit = 2 },
  names = { "Giantstalker's Helmet", "Giantstalker's Epaulets", "Giantstalker's Breastplate", "Giantstalker's Gloves", "Giantstalker's Leggings", "Giantstalker's Boots" },
  icons = { "inv_helmet_05", "inv_shoulder_10", "inv_chest_chain_03", "inv_gauntlets_10", "inv_pants_mail_03", "inv_boots_chain_13" } }
H.SetPieces{ key = "dragonstalker", firstId = 1518, tag = "surv", classes = { "HUNTER" }, armorType = "mail", quality = 4, rounds = { 5, 11, 8, 5, 13, 9 },
  stats = { hp = 24, armor = 14, ap = 16, sp = 12, dodge = 2, mana = 8 },
  names = { "Dragonstalker's Helm", "Dragonstalker's Spaulders", "Dragonstalker's Breastplate", "Dragonstalker's Gauntlets", "Dragonstalker's Legguards", "Dragonstalker's Greaves" },
  icons = { "inv_helmet_05", "inv_shoulder_10", "inv_chest_chain_03", "inv_gauntlets_10", "inv_pants_03", "inv_boots_plate_07" } }

H.SetPieces{ key = "dreadnaught", firstId = 1800, tag = "fury", classes = { "WARRIOR" }, armorType = "plate", quality = 4, rounds = { 5, 10, 8, 5, 13, 9 },
  stats = { hp = 18, armor = 10, ap = 16, haste = 1.5 },
  names = { "Dreadnaught Helmet", "Dreadnaught Pauldrons", "Dreadnaught Breastplate", "Dreadnaught Gauntlets", "Dreadnaught Legplates", "Dreadnaught Sabatons" },
  icons = { "inv_helmet_58", "inv_shoulder_29", "inv_chest_plate02", "inv_gauntlets_28", "inv_pants_plate_05", "inv_boots_plate_06" } }
H.SetPieces{ key = "cryptstalker", firstId = 1806, tag = "bm", classes = { "HUNTER" }, armorType = "mail", quality = 4, rounds = { 5, 10, 8, 5, 13, 9 },
  stats = { hp = 20, armor = 10, ap = 14, sp = 8, petPct = 6 },
  names = { "Cryptstalker Headpiece", "Cryptstalker Spaulders", "Cryptstalker Tunic", "Cryptstalker Handguards", "Cryptstalker Legguards", "Cryptstalker Boots" },
  icons = { "inv_helmet_15", "inv_shoulder_14", "inv_chest_chain_15", "inv_gauntlets_25", "inv_pants_mail_15", "inv_boots_chain_05" } }
H.SetPieces{ key = "dreamwalker", firstId = 1812, tag = "feral", classes = { "DRUID" }, armorType = "leather", quality = 4, rounds = { 5, 10, 8, 5, 13, 9 },
  stats = { hp = 20, armor = 10, ap = 18, crit = 2, healing = 6 },
  names = { "Dreamwalker Headpiece", "Dreamwalker Spaulders", "Dreamwalker Tunic", "Dreamwalker Handguards", "Dreamwalker Legguards", "Dreamwalker Boots" },
  icons = { "inv_helmet_15", "inv_shoulder_14", "inv_chest_chain_15", "inv_gauntlets_25", "inv_pants_mail_15", "inv_boots_chain_05" } }

H.SetPiece{ id = 1818, key = "devilsaur_hands", name = "Devilsaur Gauntlets", icon = H.I("inv_gauntlets_26"), quality = 3, cost = 6, minRound = 4, classes = { "HUNTER", "DRUID", "ROGUE" }, armorType = "leather", slot = "hands", set = "devilsaur", tags = { "feral", "mm" }, stats = { ap = 20, crit = 3, armor = 8 } }
H.SetPiece{ id = 1819, key = "devilsaur_legs", name = "Devilsaur Leggings", icon = H.I("inv_pants_wolf"), quality = 3, cost = 7, minRound = 6, classes = { "HUNTER", "DRUID", "ROGUE" }, armorType = "leather", slot = "legs", set = "devilsaur", tags = { "feral", "mm" }, stats = { ap = 28, armor = 12, hp = 20 } }
H.Weapon{ id = 1820, key = "dalrends_tribal_guardian", name = "Dal'Rend's Tribal Guardian", icon = H.I("inv_sword_40"), quality = 3, cost = 6, minRound = 5, classes = H.ALL_SWORD, weaponType = "sword", set = "dalrend", weaponMin = 7, weaponMax = 11, speed = 2.0, stats = { ap = 8, armor = 12 } }
