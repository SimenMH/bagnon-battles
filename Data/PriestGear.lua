local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local PRIEST = { "PRIEST" }

H.Weapon{ id = 6400, key = "acolytes_staff", name = "Bent Staff", icon = I("INV_Staff_08"), quality = 1, cost = 3, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 3, weaponMax = 5, speed = 2.9, stats = { sp = 4, healing = 4 }, noShop = true, starter = true }
H.Weapon{ id = 6401, key = "crested_scepter", name = "Crested Scepter", icon = I("INV_Mace_03"), quality = 2, cost = 5, minRound = 2, classes = PRIEST, weaponType = "mace", weaponMin = 5, weaponMax = 8, speed = 2.2, stats = { healing = 18, mana = 15 } }
H.Weapon{ id = 6402, key = "illusionary_rod", name = "Illusionary Rod", icon = I("INV_Staff_01"), quality = 2, cost = 6, minRound = 2, classes = { "PRIEST", "DRUID" }, weaponType = "staff", hands = 2, weaponMin = 6, weaponMax = 10, speed = 2.8, stats = { sp = 16, healing = 16, mana = 25 } }
H.Weapon{ id = 6403, key = "trindlehaven_staff", name = "Trindlehaven Staff", icon = I("INV_Staff_13"), quality = 3, cost = 9, minRound = 5, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 10, weaponMax = 16, speed = 2.8, stats = { sp = 24, healing = 30, hp = 35, mana = 35 } }
H.Weapon{ id = 6404, key = "hammer_of_grace", name = "Hammer of Grace", icon = I("INV_Hammer_20"), quality = 3, cost = 8, minRound = 4, classes = PRIEST, weaponType = "mace", weaponMin = 7, weaponMax = 12, speed = 2.2, stats = { healing = 36, mana = 20 } }
H.Weapon{ id = 6405, key = "priest_benediction", name = "Benediction", icon = I("INV_Staff_41"), quality = 4, cost = 13, minRound = 9, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 16, weaponMax = 24, speed = 3, stats = { healing = 64, crit = 6, mana = 40, hp = 45 },
  triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, every = 3,
    effects = { { type = "tickHots", match = { key = "renew" } } } } } }
H.Weapon{ id = 6406, key = "anathema", name = "Anathema", icon = I("INV_Staff_41"), quality = 4, cost = 13, minRound = 9, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 16, weaponMax = 24, speed = 3, stats = { sp = 58, mana = 40, hp = 45 },
  triggers = { { on = "dotTick", match = { tag = "shadow" }, everyAmount = 50, effects = { { type = "cdr", target = "all", match = { key = "mind_blast" }, amount = 1, clampReady = true } } } } }
H.Weapon{ id = 6407, key = "lokamir_il_romathis", name = "Lok'amir il Romathis", icon = I("INV_Hammer_19"), quality = 4, cost = 14, minRound = 11, classes = PRIEST, weaponType = "mace", weaponMin = 15, weaponMax = 22, speed = 2.1, stats = { healing = 58, sp = 40, mana = 35, hp = 35 } }
H.Weapon{ id = 6408, key = "lesser_magic_wand", name = "Lesser Magic Wand", icon = I("INV_Wand_07"), quality = 1, cost = 4, classes = { "PRIEST", "MAGE", "WARLOCK" }, weaponType = "wand", weaponMin = 3, weaponMax = 5, speed = 1.8, tags = { "wand", "spell", "ranged" },
  use = { cd = 1.8, effects = { { type = "damage", weaponSelf = true, coef = 0.12, school = "arcane", ranged = true, noDodge = true } } } }
H.Weapon{ id = 6409, key = "greater_magic_wand", name = "Greater Magic Wand", icon = I("INV_Wand_07"), quality = 2, cost = 6, minRound = 2, classes = { "PRIEST", "MAGE", "WARLOCK" }, weaponType = "wand", weaponMin = 5, weaponMax = 8, speed = 1.8, tags = { "wand", "spell", "ranged" }, stats = { sp = 6 },
  use = { cd = 1.8, effects = { { type = "damage", weaponSelf = true, coef = 0.15, school = "arcane", ranged = true, noDodge = true } } } }
H.Weapon{ id = 6410, key = "gravestone_scepter", name = "Gravestone Scepter", icon = I("INV_Wand_04"), quality = 3, cost = 8, minRound = 4, classes = { "PRIEST", "MAGE", "WARLOCK" }, weaponType = "wand", weaponMin = 9, weaponMax = 14, speed = 1.8, tags = { "wand", "spell", "ranged", "shadow" }, stats = { sp = 12, hp = 20 },
  use = { cd = 1.8, effects = { { type = "damage", weaponSelf = true, coef = 0.18, school = "shadow", ranged = true, noDodge = true } } } }
H.Weapon{ id = 6411, key = "skuls_ghastly_touch", name = "Skul's Ghastly Touch", icon = I("INV_Wand_12"), quality = 3, cost = 9, minRound = 6, classes = { "PRIEST", "MAGE", "WARLOCK" }, weaponType = "wand", weaponMin = 12, weaponMax = 18, speed = 1.8, tags = { "wand", "spell", "ranged", "shadow" }, stats = { sp = 24 },
  use = { cd = 1.8, effects = { { type = "damage", weaponSelf = true, coef = 0.2, school = "shadow", ranged = true, noDodge = true } } } }

H.Armor{ id = 6420, key = "barbaric_linen_vest_priest", name = "Barbaric Linen Vest", icon = I("INV_Chest_Cloth_14"), quality = 1, cost = 4, classes = PRIEST, armorType = "cloth", slot = "chest", stats = { healing = 14, sp = 8, hp = 20, armor = 6 } }
H.Armor{ id = 6421, key = "gray_woolen_robe", name = "Gray Woolen Robe", icon = I("INV_Chest_Cloth_13"), quality = 2, cost = 6, minRound = 2, classes = PRIEST, armorType = "cloth", slot = "chest", stats = { sp = 20, healing = 20, hp = 30, mana = 25, armor = 8 } }
H.Armor{ id = 6422, key = "truefaith_vestments", name = "Truefaith Vestments", icon = I("INV_Chest_Cloth_31"), quality = 4, cost = 12, minRound = 8, classes = PRIEST, armorType = "cloth", slot = "chest", stats = { healing = 72, hp = 65, regen = 2, armor = 16 } }
H.Armor{ id = 6423, key = "robes_of_the_exalted", name = "Robes of the Exalted", icon = I("INV_Chest_Cloth_30"), quality = 3, cost = 9, minRound = 3, classes = PRIEST, armorType = "cloth", slot = "chest", stats = { healing = 50, mana = 35, hp = 40, armor = 12 } }
H.Armor{ id = 6424, key = "hands_of_the_exalted_herald", name = "Hands of the Exalted Herald", icon = I("INV_Gauntlets_14"), quality = 3, cost = 6, minRound = 4, classes = PRIEST, armorType = "cloth", slot = "hands", stats = { healing = 28, crit = 3, mana = 20, armor = 5 } }
H.Armor{ id = 6425, key = "shadoweave_gloves_priest", name = "Shadoweave Gloves", icon = I("INV_Gauntlets_09"), quality = 2, cost = 5, minRound = 2, classes = PRIEST, armorType = "cloth", slot = "hands", stats = { sp = 22, hp = 15, armor = 4 } }
H.Armor{ id = 6426, key = "shadoweave_mask_priest", name = "Shadoweave Mask", icon = I("INV_Helmet_27"), quality = 3, cost = 7, minRound = 4, classes = { "PRIEST", "DRUID" }, armorType = "cloth", slot = "head", stats = { sp = 30, mana = 25, hp = 30, armor = 6 } }
H.Armor{ id = 6427, key = "whitemanes_chapeau", name = "Whitemane's Chapeau", icon = I("INV_Helmet_25"), quality = 2, cost = 5, minRound = 2, classes = PRIEST, armorType = "cloth", slot = "head", stats = { healing = 24, sp = 12, mana = 20, armor = 5 } }
H.Armor{ id = 6428, key = "burial_shawl", name = "Burial Shawl", icon = I("INV_Shoulder_02"), quality = 3, cost = 7, minRound = 4, classes = { "PRIEST", "DRUID" }, armorType = "cloth", slot = "shoulder", stats = { healing = 24, sp = 20, mana = 20, armor = 5 } }
H.Armor{ id = 6429, key = "abyssal_cloth_pants_priest", name = "Padre's Trousers", icon = I("INV_Pants_07"), quality = 2, cost = 6, minRound = 2, classes = PRIEST, armorType = "cloth", slot = "legs", stats = { healing = 22, mana = 25, hp = 20, armor = 7 } }
H.Armor{ id = 6430, key = "wolfrunner_shoes", name = "Wolfrunner Shoes", icon = I("INV_Boots_05"), quality = 2, cost = 5, minRound = 2, classes = PRIEST, armorType = "cloth", slot = "feet", stats = { healing = 16, sp = 12, hp = 20, armor = 4 } }
H.Armor{ id = 6431, key = "dawnspire_cord", name = "Dawnspire Cord", icon = I("INV_Belt_11"), quality = 3, cost = 6, minRound = 4, classes = PRIEST, armorType = "cloth", slot = "waist", stats = { healing = 24, mana = 20, regen = 1, armor = 5 } }
H.Armor{ id = 6432, key = "bracers_of_prosperity_priest", name = "Bracers of Prosperity", icon = I("INV_Bracer_09"), quality = 3, cost = 6, minRound = 4, classes = PRIEST, armorType = "cloth", slot = "wrist", stats = { healing = 22, mana = 20, crit = 2, armor = 4 } }
H.Jewel{ id = 6440, key = "royal_seal_priest", name = "Royal Seal of Eldre'Thalas", icon = I("INV_Jewelry_Talisman_06"), kind = "trinket", quality = 3, cost = 7, minRound = 3, classes = PRIEST, stats = { healing = 28, regen = 1 } }
H.Jewel{ id = 6441, key = "blessed_prayer_beads", name = "Blessed Prayer Beads", icon = I("INV_Jewelry_Necklace_11"), kind = "trinket", quality = 3, cost = 8, minRound = 5, classes = PRIEST, stats = { healing = 10 },
  use = { cd = 24, initialDelay = 2, effects = { { type = "buff", stat = "healing", value = 45, duration = 8, key = "blessed_prayer_beads", name = "Blessed Prayer Beads" } } } }
H.Jewel{ id = 6442, key = "hazzarahs_charm_of_healing", name = "Hazza'rah's Charm of Healing", icon = I("INV_Jewelry_Necklace_19"), kind = "trinket", quality = 4, cost = 10, minRound = 7, classes = PRIEST, stats = { healing = 14 },
  use = { cd = 24, initialDelay = 3, effects = { { type = "buff", target = "all", match = { tag = "heal" }, stat = "haste", value = 35, duration = 8, key = "hazzarah_healing", name = "Hazza'rah's Charm of Healing" }, { type = "resource", resource = "mana", amount = 20 } } } }
H.Jewel{ id = 6443, key = "scarab_brooch_priest", name = "Scarab Brooch", icon = I("INV_Misc_AhnQirajTrinket_06"), kind = "trinket", quality = 4, cost = 11, minRound = 8, classes = PRIEST, stats = { healing = 16 },
  triggers = { { on = "healed", effects = { { type = "absorb", fromEvent = 0.15 } } } } }
H.Jewel{ id = 6444, key = "mindtap_talisman_priest", name = "Mindtap Talisman", icon = I("INV_Jewelry_Talisman_11"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = PRIEST, stats = { mana = 30, regen = 2 } }
H.Jewel{ id = 6445, key = "animated_chain_necklace_priest", name = "Animated Chain Necklace", icon = I("INV_Jewelry_Necklace_09"), kind = "neck", quality = 3, cost = 7, minRound = 4, classes = PRIEST, stats = { healing = 26, mana = 25, hp = 20 } }
H.Jewel{ id = 6446, key = "band_of_mending_priest", name = "Band of Mending", icon = I("INV_Jewelry_Ring_09"), kind = "ring", quality = 3, cost = 7, minRound = 4, classes = PRIEST, stats = { healing = 26, crit = 3, hp = 20 } }
H.Jewel{ id = 6447, key = "maiden_circle_priest", name = "Maiden's Circle", icon = I("INV_Jewelry_Ring_12"), kind = "ring", quality = 3, cost = 7, minRound = 4, classes = PRIEST, stats = { sp = 26, mana = 20, hp = 20 } }
H.Jewel{ id = 6448, key = "hide_of_the_wild_priest", name = "Hide of the Wild", icon = I("INV_Misc_Cape_01"), kind = "cloak", quality = 4, cost = 10, minRound = 8, classes = PRIEST, shape = S.h2, stats = { healing = 42, hp = 50, armor = 8 } }
H.Jewel{ id = 6449, key = "blackflame_cape_priest", name = "Blackflame Cape", icon = I("INV_Misc_Cape_18"), kind = "cloak", quality = 3, cost = 7, minRound = 4, classes = PRIEST, shape = S.h2, stats = { sp = 26, mana = 20, armor = 4 } }

H.Weapon{ id = 6450, key = "chanting_blade_priest", name = "Chanting Blade", icon = I("inv_weapon_shortblade_25"), quality = 1, cost = 4, classes = PRIEST, weaponType = "dagger", weaponMin = 3, weaponMax = 5, speed = 1.7, stats = { sp = 6, healing = 4, mana = 10 } }
H.Weapon{ id = 6451, key = "sacrificial_kris_priest", name = "Sacrificial Kris", icon = I("inv_weapon_shortblade_03"), quality = 2, cost = 6, minRound = 2, classes = PRIEST, weaponType = "dagger", weaponMin = 5, weaponMax = 8, speed = 2, stats = { sp = 12, healing = 10, mana = 15 } }

H.Armor{ id = 6452, key = "greenweave_gloves_priest", name = "Greenweave Gloves", icon = I("inv_gauntlets_18"), quality = 1, cost = 3, classes = PRIEST, armorType = "cloth", slot = "hands", stats = { sp = 6, healing = 10, armor = 2 } }
H.Armor{ id = 6453, key = "greenweave_sash_priest", name = "Greenweave Sash", icon = I("inv_belt_05"), quality = 1, cost = 3, classes = PRIEST, armorType = "cloth", slot = "waist", stats = { sp = 6, healing = 8, mana = 10 } }
H.Armor{ id = 6454, key = "simple_britches_priest", name = "Simple Britches", icon = I("inv_pants_06"), quality = 1, cost = 4, classes = PRIEST, armorType = "cloth", slot = "legs", stats = { sp = 8, healing = 12, hp = 15 } }

ns.RegisterSet{ key = "devout", name = "Vestments of the Devout", bonuses = {
  [2] = { stats = { healing = 20, mana = 20 } },
  [4] = { triggers = { { on = "healed", everyAmount = 35, effects = { { type = "absorb", amount = 8, coef = 0.15 } } } }, text = "Every 35 effective healing grants an absorb of 8 + 15% Healing Power." },
} }
ns.RegisterSet{ key = "prophecy", name = "Vestments of Prophecy", bonuses = {
  [2] = { triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, everyAmount = 60,
    effects = { { type = "resource", resource = "mana", amount = 6 } } } }, text = "Every 60 Mana spent on Holy healing spells restores 6 Mana." },
  [4] = { triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, every = 4,
    effects = { { type = "cast", key = "renew", consumeCooldown = true } } } }, text = "Every 4 paid Holy healing spells cast Renew for free and start its cooldown." },
  [6] = { double = { tag = "heal" }, flags = { "revive" }, text = "Healing spells activate twice. Once per battle, return to full Health instead of dying." },
} }
ns.RegisterSet{ key = "transcendence", name = "Vestments of Transcendence", bonuses = {
  [2] = { mods = { match = { tag = "shadow" }, dmgPct = 20 }, text = "Shadow abilities deal 20% more damage." },
  [4] = { triggers = { { on = "dotTick", match = { tag = "shadow" }, everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 8 }, { type = "absorb", amount = 8, coef = 0.1 } } } }, text = "Every 40 Shadow periodic damage restores 8 Mana and grants an absorb of 8 + 10% Healing Power." },
  [6] = { double = { tag = "shadow" }, triggers = { { on = "anyCrit", healing = false, match = { tag = "shadow" }, effects = { { type = "tickDots", match = { tag = "shadow" } } } } }, text = "Shadow spells activate twice. Shadow spell crits immediately tick your Shadow effects." },
} }
ns.RegisterSet{ key = "faith", name = "Vestments of Faith", bonuses = {
  [2] = { stats = { healing = 20, armor = 15 } },
  [4] = { triggers = { { on = "absorbed", everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 8 }, { type = "cdr", target = "all", match = { key = "smite" }, amount = 1, clampReady = true } } } }, text = "Every 30 damage absorbed restores 8 Mana and advances Smite by 1s." },
  [6] = { double = { key = "power_word_shield" }, triggers = { { on = "absorbed", everyAmount = 30, effects = { { type = "cast", key = "smite" } } } }, text = "Power Word: Shield activates twice. Every 30 damage absorbed casts your Smite for free." },
} }

local SET_ICONS = { head = "INV_Helmet_24", shoulder = "INV_Shoulder_02", chest = "INV_Chest_Cloth_03", hands = "INV_Gauntlets_14", legs = "INV_Pants_07", feet = "INV_Boots_05", wrist = "INV_Bracer_09", waist = "INV_Belt_11" }

H.SetPieces{ key = "devout", firstId = 6460, tag = "holy", classes = PRIEST, armorType = "cloth", quality = 3, cost = 6, rounds = { 4, 4, 4, 4 },
  slots = { "wrist", "waist", "hands", "feet" }, stats = { healing = 18, sp = 6, hp = 15, mana = 12, armor = 3 }, icons = SET_ICONS,
  names = { "Devout Bracers", "Devout Belt", "Devout Gloves", "Devout Sandals" } }
H.SetPieces{ key = "prophecy", firstId = 6470, tag = "holy", classes = PRIEST, armorType = "cloth", quality = 4, cost = 10, rounds = { 4, 5, 7, 9, 11, 12 },
  stats = { healing = 26, sp = 8, hp = 18, mana = 14, armor = 4 }, icons = SET_ICONS,
  names = { "Circlet of Prophecy", "Mantle of Prophecy", "Robes of Prophecy", "Gloves of Prophecy", "Pants of Prophecy", "Boots of Prophecy" } }
H.SetPieces{ key = "transcendence", firstId = 6480, tag = "shadow", classes = PRIEST, armorType = "cloth", quality = 4, cost = 10, rounds = { 5, 6, 8, 10, 12, 13 },
  stats = { sp = 26, healing = 10, hp = 20, mana = 16, armor = 4 }, icons = SET_ICONS,
  names = { "Halo of Transcendence", "Pauldrons of Transcendence", "Robes of Transcendence", "Handguards of Transcendence", "Leggings of Transcendence", "Boots of Transcendence" } }
H.SetPieces{ key = "faith", firstId = 6490, tag = "discipline", classes = PRIEST, armorType = "cloth", quality = 4, cost = 10, rounds = { 6, 7, 9, 11, 13, 14 },
  stats = { healing = 28, sp = 12, hp = 24, mana = 18, armor = 6 }, icons = SET_ICONS,
  names = { "Circlet of Faith", "Shoulderpads of Faith", "Robe of Faith", "Gloves of Faith", "Leggings of Faith", "Sandals of Faith" } }
