local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local WARLOCK = { "WARLOCK" }

H.Weapon{ id = 9400, key = "soul_harvester", name = "Soul Harvester", icon = I("INV_Sword_48"), quality = 3, cost = 8, minRound = 3, classes = WARLOCK, weaponType = "staff", hands = 2, weaponMin = 8, weaponMax = 12, speed = 3, stats = { sp = 29, hp = 35, crit = 3 } }
H.Weapon{ id = 9401, key = "blade_of_eternal_darkness", name = "Blade of Eternal Darkness", icon = I("INV_Weapon_ShortBlade_09"), quality = 4, cost = 11, minRound = 8, classes = WARLOCK, weaponType = "dagger", weaponMin = 6, weaponMax = 10, speed = 1.8, stats = { sp = 24 }, passiveTriggers = true,
  triggers = { { on = "anyHit", match = { tag = "spell" }, every = 6, effects = { { type = "resource", resource = "mana", amount = 15 }, { type = "damage", min = 8, max = 12, coef = 0.2, school = "shadow", noCrit = true } } } } }
H.Weapon{ id = 9402, key = "kris_of_unspoken_names", name = "Kris of Unspoken Names", icon = I("INV_Weapon_ShortBlade_27"), quality = 4, cost = 10, minRound = 8, classes = WARLOCK, weaponType = "dagger", weaponMin = 7, weaponMax = 11, speed = 1.8, stats = { sp = 46, hp = 45, mana = 35 } }

H.Weapon{ id = 9403, key = "warlock_worn_dirk", name = "Worn Dagger", icon = I("INV_Weapon_ShortBlade_05"), quality = 1, cost = 3, classes = WARLOCK, weaponType = "dagger", weaponMin = 3, weaponMax = 5, speed = 1.7, stats = { sp = 4 }, noShop = true, starter = true }

local function armor(id, key, name, icon, slot, quality, round, stats)
  H.Armor{ id = id, key = key, name = name, icon = I(icon), classes = WARLOCK, armorType = "cloth", slot = slot, quality = quality, minRound = round, stats = stats }
end
armor(9410, "shadoweave_mask", "Shadoweave Mask", "INV_Helmet_27", "head", 1, 1, { sp = 8, hp = 15 })
armor(9411, "shadoweave_robe", "Shadoweave Robe", "INV_Chest_Cloth_28", "chest", 1, 1, { sp = 15, hp = 23 })
armor(9412, "shadoweave_gloves", "Shadoweave Gloves", "INV_Gauntlets_05", "hands", 1, 1, { sp = 6, hp = 10 })
armor(9413, "shadoweave_pants", "Shadoweave Pants", "INV_Pants_09", "legs", 1, 1, { sp = 9, hp = 15 })
armor(9414, "shadoweave_shoulders", "Shadoweave Shoulders", "INV_Shoulder_25", "shoulder", 2, 2, { sp = 14, hp = 25 })
armor(9415, "shadoweave_boots", "Shadoweave Boots", "INV_Boots_05", "feet", 2, 2, { sp = 12, armor = 12, hp = 25 })
armor(9416, "sanguine_cuffs", "Sanguine Cuffs", "INV_Bracer_03", "wrist", 2, 2, { healing = 20, hp = 20, sp = 6 })
armor(9417, "sanguine_belt", "Sanguine Belt", "INV_Belt_04", "waist", 2, 2, { hp = 40, healing = 18, mana = 15 })
armor(9418, "robe_of_the_void", "Robe of the Void", "INV_Chest_Cloth_07", "chest", 4, 7, { sp = 60, hp = 120, healing = 24 })
armor(9419, "deathmist_mantle", "Deathmist Mantle", "INV_Shoulder_25", "shoulder", 3, 5, { sp = 20, healing = 16, hp = 45 })
H.Jewel{ id = 9420, key = "abyss_shard", name = "Abyss Shard", icon = I("INV_Misc_Gem_02"), kind = "trinket", quality = 3, minRound = 4, classes = WARLOCK, stats = { hp = 25 },
  triggers = { { on = "healthSpent", everyAmount = 35, condition = "provides:pet", effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } } }
H.Jewel{ id = 9421, key = "the_black_book", name = "The Black Book", icon = I("INV_Misc_Book_06"), kind = "trinket", quality = 4, minRound = 8, classes = WARLOCK,
  use = { cd = 24, requires = "pet", effects = { { type = "buff", key = "the_black_book", stat = "dmgPct", value = 60, duration = 8, target = "all", match = { kind = "pet" } }, { type = "buff", key = "the_black_book_haste", stat = "haste", value = 25, duration = 8, target = "all", match = { kind = "pet" } } } } }
H.Jewel{ id = 9422, key = "royal_seal_warlock", name = "Royal Seal of Eldre'Thalas", icon = I("INV_Jewelry_Talisman_10"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = WARLOCK, stats = { sp = 29, hp = 40 } }
H.Jewel{ id = 9423, key = "frostwolf_advisors_pendant", name = "Frostwolf Advisor's Pendant", icon = I("INV_Jewelry_Necklace_07"), kind = "neck", quality = 3, minRound = 4, classes = WARLOCK, stats = { sp = 22, hp = 40, mana = 25 } }
H.Jewel{ id = 9424, key = "sanguine_cape", name = "Sanguine Cape", icon = I("INV_Misc_Cape_02"), kind = "cloak", quality = 2, minRound = 2, classes = WARLOCK, shape = S.h2, stats = { hp = 35, healing = 15, sp = 9 } }
H.Jewel{ id = 9425, key = "band_of_dark_dominion", name = "Band of Dark Dominion", icon = I("INV_Jewelry_Ring_24"), kind = "ring", quality = 4, minRound = 8, classes = WARLOCK, stats = { sp = 34, hp = 50, crit = 3 } }
H.Jewel{ id = 9426, key = "band_of_rumination", name = "Band of Rumination", icon = I("INV_Jewelry_Ring_16"), kind = "ring", quality = 3, minRound = 4, classes = WARLOCK, stats = { mana = 45, regen = 2, sp = 11 } }

ns.RegisterSet{ key = "dreadmist", name = "Dreadmist Raiment", bonuses = {
  [2] = { stats = { hp = 45, sp = 15 } },
  [4] = { triggers = { { on = "dotTick", every = 6, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Every 6 damage-over-time ticks restore 8 Mana." },
} }
ns.RegisterSet{ key = "deathmist", name = "Deathmist Raiment", bonuses = {
  [2] = { triggers = { { on = "healthSpent", effects = { { type = "absorb", fromEvent = 0.5 } } } }, text = "Spending Health grants an absorb equal to 50% of the Health paid." },
} }
ns.RegisterSet{ key = "felheart", name = "Felheart Raiment", bonuses = {
  [2] = { triggers = { { on = "anyHit", match = { kind = "pet" }, effects = { { type = "resource", resource = "mana", amount = 2 } } } }, text = "Demon hits restore 2 Mana." },
  [4] = { triggers = { { on = "healthSpent", condition = "provides:pet", effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } }, text = "Spending Health grants your demon an extra attack." },
  [6] = { double = { kind = "pet" }, stats = { petPct = 60 }, triggers = { { on = "anyHit", match = { kind = "pet" }, effects = { { type = "absorb", fromEvent = 0.4 } } } }, text = "Demons attack twice. Their hits shield you for 40% of damage dealt." },
} }
ns.RegisterSet{ key = "nemesis", name = "Nemesis Raiment", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { key = "shadow_bolt" }, effects = { { type = "tickDots", match = { tag = "fire" } } } } }, text = "Shadow Bolt immediately ticks your Fire damage-over-time effects." },
  [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "destruction" }, effects = { { type = "resource", resource = "mana", amount = 6 }, { type = "cdr", target = "all", match = { key = "soul_fire" }, amount = 1, clampReady = true } } } }, text = "Destruction crits restore 6 Mana and reduce Soul Fire's cooldown by 1s." },
  [6] = { double = { tag = "destruction" }, free = { tag = "destruction" }, text = "Destruction spells cast twice and cost no Mana." },
} }
ns.RegisterSet{ key = "plagueheart", name = "Plagueheart Raiment", bonuses = {
  [2] = { triggers = { { on = "dotTick", match = { tag = "affliction" }, every = 6, effects = { { type = "heal", pctMax = 0.02, noCrit = true } } } }, text = "Every 6 Affliction ticks heal 2% maximum Health." },
  [4] = { triggers = { { on = "healed", icd = 1, effects = { { type = "cdr", target = "all", match = { tag = "affliction" }, amount = 0.5, clampReady = true } } } }, text = "Effective healing reduces Affliction cooldowns by 0.5s, once per second." },
  [6] = { double = { tag = "affliction" }, flags = { "revive" }, stats = { healing = 50 }, text = "Affliction spells cast twice. Return to full Health once instead of dying." },
} }

H.SetPieces{ key = "dreadmist", firstId = 9450, tag = "affliction", classes = WARLOCK, armorType = "cloth", quality = 3, rounds = { 3, 4, 5, 6 }, statScale = { sp = 0.9 },
  slots = { "head", "shoulder", "chest", "feet" }, stats = { sp = 12, hp = 25, mana = 10 },
  names = { "Dreadmist Mask", "Dreadmist Mantle", "Dreadmist Robe", "Dreadmist Sandals" },
  icons = { "INV_Helmet_29", "INV_Shoulder_02", "INV_Chest_Cloth_49", "INV_Boots_05" } }
H.SetPieces{ key = "deathmist", firstId = 9454, tag = "demonology", classes = WARLOCK, armorType = "cloth", quality = 3, rounds = { 3, 4 }, statScale = { sp = 0.9 },
  slots = { "wrist", "waist" }, stats = { sp = 12, healing = 12, hp = 25 },
  names = { "Deathmist Bracers", "Deathmist Belt" },
  icons = { "INV_Bracer_13", "INV_Belt_03" } }
H.SetPieces{ key = "felheart", firstId = 9460, tag = "demonology", classes = WARLOCK, armorType = "cloth", quality = 4, rounds = { 3, 5, 7, 9, 10, 12 },
  stats = { sp = 14, hp = 30, crit = 2 },
  names = { "Felheart Horns", "Felheart Shoulder Pads", "Felheart Robes", "Felheart Gloves", "Felheart Pants", "Felheart Slippers" },
  icons = { "INV_Helmet_08", "INV_Shoulder_23", "INV_Chest_Cloth_09", "INV_Gauntlets_19", "INV_Pants_Cloth_14", "INV_Boots_Cloth_05" } }
H.SetPieces{ key = "nemesis", firstId = 9470, tag = "destruction", classes = WARLOCK, armorType = "cloth", quality = 4, rounds = { 4, 6, 8, 9, 11, 13 },
  stats = { sp = 18, hp = 20, crit = 3 },
  names = { "Nemesis Skullcap", "Nemesis Spaulders", "Nemesis Robes", "Nemesis Gloves", "Nemesis Leggings", "Nemesis Boots" },
  icons = { "INV_Helmet_08", "INV_Shoulder_19", "INV_Chest_Leather_01", "INV_Gauntlets_19", "INV_Pants_07", "INV_Boots_08" } }
H.SetPieces{ key = "plagueheart", firstId = 9480, tag = "affliction", classes = WARLOCK, armorType = "cloth", quality = 4, rounds = { 5, 6, 8, 10, 12, 14 },
  stats = { sp = 14, healing = 12, hp = 30 },
  names = { "Plagueheart Circlet", "Plagueheart Shoulderpads", "Plagueheart Robe", "Plagueheart Gloves", "Plagueheart Leggings", "Plagueheart Sandals" },
  icons = { "INV_Crown_01", "INV_Shoulder_25", "INV_Chest_Cloth_43", "INV_Gauntlets_17", "INV_Pants_Cloth_05", "INV_Boots_Fabric_01" } }

H.Weapon{ id = 9427, key = "touch_of_chaos", name = "Touch of Chaos", icon = I("INV_Wand_09"), quality = 4, cost = 10, minRound = 8, classes = WARLOCK, weaponType = "wand", weaponMin = 14, weaponMax = 21, speed = 1.8, tags = { "wand", "spell", "ranged", "shadow" }, stats = { sp = 28, hp = 30 },
  use = { cd = 1.8, effects = { { type = "damage", weaponSelf = true, coef = 0.2, school = "shadow", ranged = true, noDodge = true } } } }
