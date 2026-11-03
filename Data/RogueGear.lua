local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local ROGUE = { "ROGUE" }

H.Weapon{ id = 4400, key = "small_dagger", name = "Small Dagger", icon = I("INV_Weapon_ShortBlade_05"), quality = 1, cost = 4, classes = ROGUE, weaponType = "dagger", weaponMin = 4, weaponMax = 6, speed = 1.6, stats = { ap = 6 } }
H.Weapon{ id = 4401, key = "assassins_blade", name = "Assassin's Blade", icon = I("INV_Weapon_ShortBlade_05"), quality = 2, cost = 6, minRound = 2, classes = ROGUE, weaponType = "dagger", weaponMin = 6, weaponMax = 10, speed = 1.8, stats = { crit = 5, ap = 8 } }
H.Weapon{ id = 4402, key = "barman_shanker", name = "Barman Shanker", icon = I("INV_Weapon_ShortBlade_15"), quality = 3, cost = 9, minRound = 5, classes = ROGUE, weaponType = "dagger", weaponMin = 10, weaponMax = 16, speed = 2.0, stats = { ap = 20 },
  tags = { "bleed" }, triggers = { { on = "crit", effects = { { type = "dot", key = "barman_wound", tick = 0, duration = 6, school = "physical", rolling = true, fromEvent = 0.3 } } } } }
H.Weapon{ id = 4403, key = "distracting_dagger", name = "Distracting Dagger", icon = I("INV_Weapon_ShortBlade_23"), quality = 3, cost = 8, minRound = 4, classes = ROGUE, weaponType = "dagger", weaponMin = 7, weaponMax = 10, speed = 1.3, stats = { ap = 16, dodge = 3 } }
H.Weapon{ id = 4404, key = "gut_ripper", name = "Gut Ripper", icon = I("INV_Weapon_ShortBlade_16"), quality = 3, cost = 9, minRound = 5, classes = ROGUE, weaponType = "dagger", weaponMin = 10, weaponMax = 15, speed = 1.8, stats = { ap = 24, crit = 4 } }
H.Weapon{ id = 4405, key = "thrash_blade", name = "Thrash Blade", icon = I("INV_Sword_36"), quality = 3, cost = 9, minRound = 5, classes = H.PHYSICAL_SWORD, weaponType = "sword", weaponMin = 11, weaponMax = 17, speed = 2.4,
  triggers = { { on = "hit", chance = 12, effects = { { type = "extraAttack" } } } } }
H.Weapon{ id = 4406, key = "krol_blade", name = "Krol Blade", icon = I("INV_Sword_18"), quality = 4, cost = 12, minRound = 8, classes = H.PHYSICAL_SWORD, weaponType = "sword", weaponMin = 15, weaponMax = 23, speed = 2.8, stats = { ap = 32, crit = 6 } }
H.Weapon{ id = 4408, key = "core_hound_tooth", name = "Core Hound Tooth", icon = I("INV_Weapon_ShortBlade_25"), quality = 4, cost = 12, minRound = 9, classes = ROGUE, weaponType = "dagger", weaponMin = 12, weaponMax = 18, speed = 1.6, stats = { ap = 36, crit = 6, hp = 25 } }
H.Weapon{ id = 4409, key = "dragonfang_blade", name = "Dragonfang Blade", icon = I("INV_Weapon_ShortBlade_28"), quality = 4, cost = 14, minRound = 11, classes = ROGUE, weaponType = "dagger", weaponMin = 17, weaponMax = 25, speed = 1.8, stats = { ap = 44, crit = 7, hp = 35 } }
H.Weapon{ id = 4410, key = "the_lobotomizer", name = "The Lobotomizer", icon = I("INV_Weapon_ShortBlade_32"), quality = 4, cost = 13, minRound = 10, classes = ROGUE, weaponType = "dagger", weaponMin = 15, weaponMax = 24, speed = 1.8, stats = { crit = 5 },
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", min = 12, max = 18, coef = 0.2, school = "shadow", noDodge = true }, { type = "drain", resource = "mana", amount = 6 } } } } }
H.Weapon{ id = 4411, key = "death_sting", name = "Death's Sting", icon = I("INV_Weapon_ShortBlade_35"), quality = 4, cost = 16, minRound = 13, classes = ROGUE, weaponType = "dagger", weaponMin = 22, weaponMax = 32, speed = 1.8, stats = { ap = 60, crit = 9 } }

H.Armor{ id = 4420, key = "blackened_defias_armor", name = "Blackened Defias Armor", icon = I("INV_Chest_Leather_05"), quality = 2, cost = 6, minRound = 2, classes = ROGUE, armorType = "leather", slot = "chest", stats = { ap = 24, hp = 30, armor = 16 } }
H.Armor{ id = 4421, key = "dark_leather_tunic", name = "Dark Leather Tunic", icon = I("INV_Chest_Leather_03"), quality = 1, cost = 4, classes = ROGUE, armorType = "leather", slot = "chest", stats = { ap = 12, armor = 12, dodge = 3 } }
H.Armor{ id = 4422, key = "dark_leather_gloves", name = "Dark Leather Gloves", icon = I("INV_Gauntlets_05"), quality = 1, cost = 3, classes = ROGUE, armorType = "leather", slot = "hands", stats = { ap = 8, crit = 3, armor = 4 } }
H.Armor{ id = 4423, key = "dark_leather_boots", name = "Dark Leather Boots", icon = I("INV_Boots_05"), quality = 1, cost = 3, classes = { "ROGUE", "SHAMAN" }, armorType = "leather", slot = "feet", stats = { ap = 8, dodge = 4, armor = 6 } }
H.Armor{ id = 4424, key = "nightscape_headband", name = "Nightscape Headband", icon = I("INV_Misc_Bandana_03"), quality = 2, cost = 5, minRound = 2, classes = { "ROGUE", "SHAMAN" }, armorType = "leather", slot = "head", stats = { ap = 18, crit = 4, hp = 20, armor = 8 } }
H.Armor{ id = 4425, key = "blackmist_armguards", name = "Blackmist Armguards", icon = I("INV_Bracer_07"), quality = 3, cost = 6, minRound = 3, classes = ROGUE, armorType = "leather", slot = "wrist", stats = { ap = 20, crit = 4, armor = 6 } }
H.Armor{ id = 4426, key = "belt_of_the_preserved_heads", name = "Belt of Preserved Heads", icon = I("INV_Belt_17"), quality = 3, cost = 7, minRound = 5, classes = ROGUE, armorType = "leather", slot = "waist", stats = { ap = 24, crit = 4, hp = 30, armor = 8 } }
H.Armor{ id = 4427, key = "truestrike_shoulders", name = "Truestrike Shoulders", icon = I("INV_Shoulder_07"), quality = 3, cost = 7, minRound = 5, classes = { "ROGUE", "SHAMAN" }, armorType = "leather", slot = "shoulder", stats = { ap = 32, crit = 5, armor = 10 } }
H.Armor{ id = 4428, key = "leggings_of_the_fang", name = "Leggings of the Fang", icon = I("INV_Pants_02"), quality = 2, cost = 5, minRound = 2, classes = ROGUE, armorType = "leather", slot = "legs", stats = { ap = 18, hp = 25, armor = 12 } }
H.Armor{ id = 4429, key = "cadaverous_armor", name = "Cadaverous Armor", icon = I("INV_Chest_Leather_08"), quality = 3, cost = 9, minRound = 3, classes = ROGUE, armorType = "leather", slot = "chest", stats = { ap = 48, hp = 45, armor = 24 } }
H.Jewel{ id = 4430, key = "royal_seal_rogue", name = "Royal Seal of Eldre'Thalas", icon = I("INV_Jewelry_Talisman_06"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = ROGUE, stats = { ap = 24, crit = 5 } }
H.Jewel{ id = 4431, key = "renatakis_charm_of_trickery", name = "Renataki's Charm of Trickery", icon = I("INV_Jewelry_Necklace_19"), kind = "trinket", quality = 4, cost = 10, minRound = 7, classes = ROGUE,
  use = { cd = 22, initialDelay = 2, condition = "resourceAtLeast:combo:1", effects = { { type = "resource", resource = "energy", amount = 60 } } } }
H.Jewel{ id = 4432, key = "rogue_blackhands_breadth", name = "Blackhand's Breadth", icon = I("INV_Misc_Gem_Bloodstone_01"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = ROGUE, stats = { crit = 9, ap = 12 } }
H.Jewel{ id = 4433, key = "cloak_of_veiled_shadows", name = "Cloak of Veiled Shadows", icon = I("INV_Misc_Cape_18"), kind = "cloak", quality = 3, cost = 8, minRound = 5, classes = ROGUE, shape = S.h2, stats = { ap = 24, dodge = 5, armor = 8 },
  triggers = { { on = "anyUse", match = { key = "vanish" }, effects = { { type = "heal", pctMax = 0.05 } } } } }
H.Jewel{ id = 4434, key = "band_of_veiled_shadows", name = "Band of Veiled Shadows", icon = I("INV_Jewelry_Ring_24"), kind = "ring", quality = 3, cost = 7, minRound = 4, classes = ROGUE, stats = { ap = 24, crit = 4, hp = 20 } }
H.Jewel{ id = 4435, key = "pendant_of_celerity", name = "Pendant of Celerity", icon = I("INV_Jewelry_Necklace_18"), kind = "neck", quality = 3, cost = 7, minRound = 4, classes = ROGUE, stats = { ap = 22, haste = 8, hp = 20 } }
H.Jewel{ id = 4436, key = "royal_seal_of_alexis", name = "Royal Seal of Alexis", icon = I("INV_Jewelry_Ring_31"), kind = "ring", quality = 3, cost = 7, minRound = 5, classes = ROGUE, stats = { ap = 18, sp = 12, hp = 35 }, tags = { "poison" },
  triggers = { { on = "dotTick", match = { tag = "poison" }, every = 5, effects = { { type = "resource", resource = "energy", amount = 5 } } } } }

H.Weapon{ id = 4490, key = "toxic_revenger", name = "Toxic Revenger", icon = I("inv_weapon_shortblade_02"), quality = 2, cost = 6, minRound = 2, classes = ROGUE, weaponType = "dagger", weaponMin = 5, weaponMax = 8, speed = 1.9, stats = { ap = 6, sp = 10 }, tags = { "poison", "nature" },
  triggers = { { on = "hit", chance = 25, effects = { { type = "dot", key = "toxic_revenger", tick = 1, coef = 0.05, duration = 6, school = "nature", stack = true, maxStacks = 5 } } } } }
H.Armor{ id = 4491, key = "venomshroud_belt_rogue", name = "Venomshroud Belt", icon = I("inv_belt_25"), quality = 1, cost = 3, classes = ROGUE, armorType = "cloth", slot = "waist", stats = { sp = 8, ap = 4, hp = 10 } }
H.Armor{ id = 4492, key = "venomshroud_mitts_rogue", name = "Venomshroud Mitts", icon = I("inv_gauntlets_23"), quality = 2, cost = 5, minRound = 2, classes = ROGUE, armorType = "cloth", slot = "hands", stats = { sp = 14, ap = 6, armor = 2 } }

ns.RegisterSet{ key = "shadowcraft", name = "Shadowcraft Armor", bonuses = {
  [2] = { stats = { ap = 18, crit = 4 } },
  [4] = { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 4, effects = { { type = "resource", resource = "energy", amount = 20 } } } }, text = "Every 4 melee auto-attacks restore 20 Energy." },
} }
ns.RegisterSet{ key = "nightslayer", name = "Nightslayer Armor", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { tag = "opener" }, effects = { { type = "resource", resource = "energy", amount = 15 } } } }, text = "Openers restore 15 Energy." },
  [4] = { triggers = { { on = "dodged", effects = { { type = "resource", resource = "combo", amount = 1 }, { type = "cdr", target = "all", match = { key = "vanish" }, amount = 1, clampReady = true } } } }, text = "Dodges grant 1 Combo Point and advance Vanish by 1s." },
  [6] = { triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "cast", key = "vanish" }, { type = "heal", pctMax = 0.06 } } } }, text = "Finishers cast your Vanish for free and heal 6% maximum Health." },
} }
ns.RegisterSet{ key = "bloodfang", name = "Bloodfang Armor", bonuses = {
  [2] = { mods = { match = { tag = "poison" }, dmgPct = 25 }, text = "Poisons deal 25% more damage." },
  [4] = { triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "tickDots", match = { tag = "poison" } } } } }, text = "Finishers immediately tick your poisons." },
  [6] = { double = { tag = "finisher" }, triggers = { { on = "dotTick", match = { tag = "poison" }, effects = { { type = "heal", fromEvent = 0.3, noCrit = true } } } }, text = "Finishers activate twice. Poison damage heals you for 30% of its damage." },
} }
ns.RegisterSet{ key = "bonescythe", name = "Bonescythe Armor", bonuses = {
  [2] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "builder" }, effects = { { type = "resource", resource = "energy", amount = 5 } } } }, text = "Builder crits restore 5 Energy." },
  [4] = { triggers = { { on = "resourceSpent", resource = "combo", effects = { { type = "buff", target = "all", match = { tag = "builder" }, stat = "crit", value = 100, charges = 1, duration = 6, key = "bonescythe_opening", name = "Bonescythe Armor" } } } }, text = "Spending Combo Points makes your next builder a guaranteed crit." },
  [6] = { double = { tag = "autoattack" }, triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 60, effects = { { type = "cast", key = "sinister_strike" } } } }, text = "Auto-attacks hit twice. Every 60 Energy spent casts your Sinister Strike for free." },
} }

local SET_ICONS = { head = "INV_Helmet_41", shoulder = "INV_Shoulder_25", chest = "INV_Chest_Leather_03", hands = "INV_Gauntlets_21", legs = "INV_Pants_06", feet = "INV_Boots_08", wrist = "INV_Bracer_07", waist = "INV_Belt_17" }

H.SetPieces{ key = "shadowcraft", firstId = 4450, tag = "combat", classes = ROGUE, armorType = "leather", quality = 3, cost = 6, rounds = { 4, 4, 4, 4 },
  slots = { "wrist", "waist", "hands", "feet" }, stats = { ap = 16, hp = 15, armor = 6, crit = 2 }, icons = SET_ICONS,
  names = { "Shadowcraft Bracers", "Shadowcraft Belt", "Shadowcraft Gloves", "Shadowcraft Boots" } }
H.SetPieces{ key = "nightslayer", firstId = 4460, tag = "subtlety", classes = ROGUE, armorType = "leather", quality = 4, cost = 10, rounds = { 4, 5, 7, 9, 11, 12 },
  stats = { ap = 22, hp = 18, armor = 8, dodge = 2 }, icons = SET_ICONS,
  names = { "Nightslayer Cover", "Nightslayer Shoulder Pads", "Nightslayer Chestpiece", "Nightslayer Gloves", "Nightslayer Pants", "Nightslayer Boots" } }
H.SetPieces{ key = "bloodfang", firstId = 4470, tag = "assassination", classes = ROGUE, armorType = "leather", quality = 4, cost = 10, rounds = { 5, 6, 8, 10, 12, 13 },
  stats = { ap = 20, sp = 8, hp = 18, armor = 8, crit = 2 }, icons = SET_ICONS,
  names = { "Bloodfang Hood", "Bloodfang Spaulders", "Bloodfang Chestpiece", "Bloodfang Gloves", "Bloodfang Pants", "Bloodfang Boots" } }
H.SetPieces{ key = "bonescythe", firstId = 4480, tag = "combat", classes = ROGUE, armorType = "leather", quality = 4, cost = 10, rounds = { 6, 7, 9, 11, 13, 14 },
  stats = { ap = 26, hp = 20, armor = 9, crit = 3 }, icons = SET_ICONS,
  names = { "Bonescythe Helmet", "Bonescythe Pauldrons", "Bonescythe Breastplate", "Bonescythe Gauntlets", "Bonescythe Legplates", "Bonescythe Sabatons" } }
