local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local HUNTER = { "HUNTER" }

H.Armor{ id = 2200, key = "dreamweave_gloves", name = "Dreamweave Gloves", icon = I("inv_gauntlets_18"), quality = 3, cost = 6, minRound = 3, classes = HUNTER, armorType = "cloth", slot = "hands", stats = { sp = 24, mana = 20, armor = 6 } }
H.Armor{ id = 2201, key = "dreamers_belt", name = "Dreamer's Belt", icon = I("inv_belt_04"), quality = 2, cost = 4, minRound = 2, classes = HUNTER, armorType = "cloth", slot = "waist", stats = { mana = 30, regen = 1, sp = 10 } }
H.Armor{ id = 2202, key = "warpwood_binding", name = "Warpwood Binding", icon = I("inv_belt_34"), quality = 3, cost = 7, minRound = 4, classes = HUNTER, armorType = "mail", slot = "waist", stats = { ap = 28, crit = 5, mana = 20, armor = 14 } }
H.Armor{ id = 2203, key = "primalists_linked_waistguard", name = "Primalist's Linked Waistguard", icon = I("inv_belt_21"), quality = 4, cost = 10, minRound = 8, classes = HUNTER, armorType = "mail", slot = "waist", stats = { sp = 36, ap = 24, mana = 30, armor = 18 } }
H.Armor{ id = 2204, key = "wristguards_of_true_flight", name = "Wristguards of True Flight", icon = I("inv_bracer_02"), quality = 4, cost = 9, minRound = 7, classes = HUNTER, armorType = "mail", slot = "wrist", stats = { ap = 36, crit = 6, mana = 15, armor = 16 } }

H.Jewel{ id = 2205, key = "royal_seal_hunter", name = "Royal Seal of Eldre'Thalas", icon = I("inv_jewelry_talisman_10"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = HUNTER, stats = { ap = 48 } }
H.Jewel{ id = 2206, key = "devilsaur_tooth", name = "Devilsaur Tooth", icon = I("inv_misc_bone_07"), kind = "trinket", quality = 3, cost = 8, minRound = 5, classes = HUNTER, stats = { petPct = 15 },
  triggers = { { on = "resourceSpent", resource = "focus", every = 2, effects = { { type = "buff", stat = "crit", value = 100, target = "all", match = { kind = "pet" }, charges = 1, duration = 10, key = "devilsaur_tooth", name = "Devilsaur Tooth" } } } } }
H.Jewel{ id = 2207, key = "devilsaur_eye", name = "Devilsaur Eye", icon = I("inv_misc_eye_01"), kind = "trinket", quality = 3, cost = 8, minRound = 5, classes = HUNTER, stats = { ap = 12, crit = 3 },
  use = { cd = 20, initialPct = 0.1, effects = { { type = "buff", stat = "ap", value = 40, duration = 8, key = "devilsaur_eye", name = "Devilsaur Eye" } } } }
H.Jewel{ id = 2208, key = "renatakis_charm_of_beasts", name = "Renataki's Charm of Beasts", icon = I("inv_jewelry_necklace_19"), kind = "trinket", quality = 4, cost = 12, minRound = 9, classes = HUNTER, stats = { mana = 30 },
  use = { cd = 25, initialPct = 0.35, effects = { { type = "cdr", target = "all", match = { tag = "shot" }, amount = 60 } } } }
H.Jewel{ id = 2209, key = "tooth_of_gnarr", name = "Tooth of Gnarr", icon = I("inv_jewelry_necklace_09"), kind = "neck", quality = 3, cost = 6, minRound = 4, classes = HUNTER, stats = { mana = 40, regen = 2, hp = 40 } }
H.Weapon{ id = 2210, key = "lokdelar", name = "Lok'delar, Stave of the Ancient Keepers", icon = I("inv_staff_21"), quality = 4, cost = 12, minRound = 9, classes = HUNTER, weaponType = "staff", hands = 2, weaponMin = 18, weaponMax = 26, speed = 3.2, stats = { ap = 40, sp = 24, mana = 30, crit = 4 } }
H.Jewel{ id = 2211, key = "cloak_of_consumption", name = "Cloak of Consumption", icon = I("inv_misc_cape_22"), kind = "cloak", quality = 4, cost = 10, minRound = 8, classes = HUNTER, shape = S.h2, stats = { sp = 32, mana = 20, crit = 4 } }
