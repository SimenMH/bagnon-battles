local ADDON, ns = ...
local H = ns.H
local I = H.I
local WARLOCK = { "WARLOCK" }

H.Weapon{ id = 9400, key = "soul_harvester", name = "Soul Harvester", icon = I("INV_Sword_48"), quality = 3, cost = 8, minRound = 3, classes = WARLOCK, weaponType = "staff", hands = 2, weaponMin = 8, weaponMax = 12, speed = 3, stats = { sp = 29, hp = 35, crit = 3 } }
H.Weapon{ id = 9402, key = "kris_of_unspoken_names", name = "Kris of Unspoken Names", icon = I("INV_Weapon_ShortBlade_27"), quality = 4, cost = 10, minRound = 8, classes = WARLOCK, weaponType = "dagger", weaponMin = 7, weaponMax = 11, speed = 1.8, stats = { sp = 46, hp = 45, mana = 35 } }

H.Weapon{ id = 9403, key = "warlock_worn_dirk", name = "Worn Dagger", icon = I("INV_Weapon_ShortBlade_05"), quality = 1, cost = 3, classes = WARLOCK, weaponType = "dagger", weaponMin = 3, weaponMax = 5, speed = 1.7, stats = { sp = 4 }, noShop = true, starter = true }

local function armor(id, key, name, icon, slot, quality, round, stats)
  H.Armor{ id = id, key = key, name = name, icon = I(icon), classes = WARLOCK, armorType = "cloth", slot = slot, quality = quality, minRound = round, stats = stats }
end
armor(9418, "robe_of_the_void", "Robe of the Void", "INV_Chest_Cloth_07", "chest", 4, 7, { sp = 60, hp = 120, healing = 24 })
H.Jewel{ id = 9420, key = "abyss_shard", name = "Abyss Shard", icon = I("INV_Misc_Gem_02"), kind = "trinket", quality = 3, minRound = 4, classes = WARLOCK, stats = { hp = 25 },
  triggers = { { on = "healthSpent", everyAmount = 35, condition = "provides:pet", effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } } }
H.Jewel{ id = 9421, key = "the_black_book", name = "The Black Book", icon = I("INV_Misc_Book_06"), kind = "trinket", quality = 4, minRound = 8, classes = WARLOCK,
  use = { cd = 24, requires = "pet", effects = { { type = "buff", key = "the_black_book", stat = "dmgPct", value = 60, duration = 8, target = "all", match = { kind = "pet" } }, { type = "buff", key = "the_black_book_haste", stat = "haste", value = 25, duration = 8, target = "all", match = { kind = "pet" } } } } }
H.Jewel{ id = 9422, key = "royal_seal_warlock", name = "Royal Seal of Eldre'Thalas", icon = I("INV_Jewelry_Talisman_10"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = WARLOCK, stats = { sp = 29, hp = 40 } }

ns.RegisterSet{ key = "dreadmist", name = "Dreadmist Raiment", bonuses = {
  [2] = { stats = { hp = 45, sp = 15 } },
  [4] = { triggers = { { on = "dotTick", every = 6, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Every sixth tick of your damage over time effects restores 8 Mana." },
} }
ns.RegisterSet{ key = "deathmist", name = "Deathmist Raiment", bonuses = {
  [2] = { triggers = { { on = "healthSpent", effects = { { type = "absorb", fromEvent = 0.5 } } } }, text = "Consuming Health grants a shield equal to 50% of the Health consumed." },
} }
ns.RegisterSet{ key = "felheart", name = "Felheart Raiment", bonuses = {
  [2] = { triggers = { { on = "anyHit", match = { kind = "pet" }, effects = { { type = "resource", resource = "mana", amount = 2 } } } }, text = "Your demon's hits restore 2 Mana." },
  [4] = { triggers = { { on = "healthSpent", condition = "provides:pet", effects = { { type = "cast", target = "all", match = { kind = "pet" } } } } }, text = "Consuming Health causes your active demon to attack again." },
  [6] = { double = { kind = "pet" }, stats = { petPct = 60 }, triggers = { { on = "anyHit", match = { kind = "pet" }, effects = { { type = "absorb", fromEvent = 0.4 } } } }, text = "Your demon's attacks take effect twice. Its hits grant a shield equal to 40% of the damage dealt." },
} }
ns.RegisterSet{ key = "nemesis", name = "Nemesis Raiment", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { key = "shadow_bolt" }, effects = { { type = "tickDots", match = { tag = "fire" } } } } }, text = "Casting Shadow Bolt causes each of your active Fire damage over time effects to deal one additional tick of damage." },
  [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "destruction" }, effects = { { type = "resource", resource = "mana", amount = 6 }, { type = "cdr", target = "all", match = { key = "soul_fire" }, amount = 1, clampReady = true } } } }, text = "Your Destruction critical strikes restore 6 Mana and reduce the remaining cooldown of Soul Fire by 1 second." },
  [6] = { double = { tag = "destruction" }, free = { tag = "destruction" }, text = "Your Destruction spells take effect twice and consume no Mana." },
} }
ns.RegisterSet{ key = "plagueheart", name = "Plagueheart Raiment", bonuses = {
  [2] = { triggers = { { on = "dotTick", match = { tag = "affliction" }, every = 6, effects = { { type = "heal", pctMax = 0.02, noCrit = true } } } }, text = "Every sixth tick of periodic Affliction damage heals you for 2% of your maximum Health." },
  [4] = { triggers = { { on = "healed", icd = 1, effects = { { type = "cdr", target = "all", match = { tag = "affliction" }, amount = 0.5, clampReady = true } } } }, text = "Restoring Health reduces the remaining cooldowns of your Affliction abilities by 0.5 seconds. This can occur once per second." },
  [6] = { double = { tag = "affliction" }, flags = { "revive" }, stats = { healing = 50 }, text = "Your Affliction spells take effect twice. Once per battle, lethal damage restores you to full Health." },
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
