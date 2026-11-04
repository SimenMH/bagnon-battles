local ADDON, ns = ...
local H = ns.H
local I = H.I
local HUNTER = { "HUNTER" }

H.Jewel{ id = 2205, key = "royal_seal_hunter", name = "Royal Seal of Eldre'Thalas", icon = I("inv_jewelry_talisman_10"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = HUNTER, stats = { ap = 48 } }
H.Jewel{ id = 2206, key = "devilsaur_tooth", name = "Devilsaur Tooth", icon = I("inv_misc_bone_07"), kind = "trinket", quality = 3, cost = 8, minRound = 5, classes = HUNTER, stats = { petPct = 15 },
  triggers = { { on = "resourceSpent", resource = "focus", every = 2, effects = { { type = "buff", stat = "crit", value = 100, target = "all", match = { kind = "pet" }, charges = 1, duration = 10, key = "devilsaur_tooth", name = "Devilsaur Tooth" } } } } }
H.Jewel{ id = 2207, key = "devilsaur_eye", name = "Devilsaur Eye", icon = I("inv_misc_eye_01"), kind = "trinket", quality = 3, cost = 8, minRound = 5, classes = HUNTER, stats = { ap = 12, crit = 3 },
  use = { cd = 20, initialPct = 0.1, effects = { { type = "buff", stat = "ap", value = 40, duration = 8, key = "devilsaur_eye", name = "Devilsaur Eye" } } } }
H.Jewel{ id = 2208, key = "renatakis_charm_of_beasts", name = "Renataki's Charm of Beasts", icon = I("inv_jewelry_necklace_19"), kind = "trinket", quality = 4, cost = 12, minRound = 9, classes = HUNTER, stats = { mana = 30 },
  use = { cd = 25, initialPct = 0.35, effects = { { type = "cdr", target = "all", match = { tag = "shot" }, amount = 60 } } } }
H.Weapon{ id = 2210, key = "lokdelar", name = "Lok'delar, Stave of the Ancient Keepers", icon = I("inv_staff_21"), quality = 4, cost = 12, minRound = 9, classes = HUNTER, weaponType = "staff", hands = 2, weaponMin = 18, weaponMax = 26, speed = 3.2, stats = { ap = 40, sp = 24, mana = 30, crit = 4 } }
