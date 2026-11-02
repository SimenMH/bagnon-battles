local ADDON, ns = ...
local H = ns.H
local I = H.I
local DRUID = { "DRUID" }

H.Jewel{ id = 1043, key = "idol_of_ferocity", name = "Idol of Ferocity", icon = I("INV_Relics_IdolofFerocity"), kind = "relic", quality = 3, minRound = 7, classes = DRUID, tags = { "feral" },
  triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "resource", resource = "combo", amount = 1 } } } } }

H.Weapon{ id = 2240, key = "manual_crowd_pummeler", name = "Manual Crowd Pummeler", icon = I("inv_mace_14"), quality = 3, cost = 8, minRound = 4, classes = DRUID, weaponType = "mace", hands = 2, weaponMin = 8, weaponMax = 12, speed = 2.0, stats = { ap = 24, crit = 3 }, passiveTriggers = true,
  triggers = { { on = "battleStart", effects = { { type = "buff", stat = "haste", value = 50, duration = 12, target = "all", match = { tag = "autoattack" }, key = "crowd_pummeler", name = "Manual Crowd Pummeler" } } } } }
H.Weapon{ id = 2241, key = "warden_staff", name = "Warden Staff", icon = I("inv_staff_29"), quality = 4, cost = 11, minRound = 8, classes = DRUID, weaponType = "staff", hands = 2, weaponMin = 12, weaponMax = 18, speed = 2.4, stats = { armor = 80, hp = 80, ap = 20 } }
H.Weapon{ id = 2242, key = "staff_of_the_blessed_seer", name = "Staff of the Blessed Seer", icon = I("inv_staff_31"), quality = 3, cost = 5, minRound = 2, classes = DRUID, weaponType = "staff", hands = 2, weaponMin = 6, weaponMax = 10, speed = 3.0, stats = { healing = 28, mana = 20 } }
H.Armor{ id = 2243, key = "bracers_of_prosperity", name = "Bracers of Prosperity", icon = I("inv_bracer_12"), quality = 3, cost = 6, minRound = 4, classes = DRUID, armorType = "leather", slot = "wrist", stats = { healing = 28, mana = 20, hp = 30 } }
H.Armor{ id = 2244, key = "bracers_of_the_eclipse", name = "Bracers of the Eclipse", icon = I("inv_bracer_07"), quality = 3, cost = 7, minRound = 4, classes = DRUID, armorType = "leather", slot = "wrist", stats = { ap = 28, crit = 4, armor = 10, hp = 25 } }
H.Armor{ id = 2245, key = "whipvine_cord", name = "Whipvine Cord", icon = I("inv_belt_17"), quality = 3, cost = 7, minRound = 5, classes = DRUID, armorType = "cloth", slot = "waist", stats = { healing = 32, regen = 2, mana = 25 } }
H.Jewel{ id = 2246, key = "animated_chain_necklace", name = "Animated Chain Necklace", icon = I("inv_jewelry_necklace_01"), kind = "neck", quality = 3, cost = 7, minRound = 4, classes = DRUID, stats = { healing = 36, hp = 35 } }
H.Jewel{ id = 2247, key = "orb_of_the_darkmoon", name = "Orb of the Darkmoon", icon = I("inv_jewelry_necklace_16"), kind = "neck", quality = 4, cost = 10, minRound = 8, classes = DRUID, stats = { sp = 32, healing = 24, hp = 40 } }
H.Jewel{ id = 2248, key = "idol_of_rejuvenation", name = "Idol of Rejuvenation", icon = I("inv_relics_idolofrejuvenation"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = DRUID, stats = { healing = 8 },
  triggers = { { on = "hotTick", every = 5, effects = { { type = "buff", stat = "none", value = 0, double = { tag = "heal" }, charges = 1, duration = 15, key = "idol_of_rejuvenation", name = "Idol of Rejuvenation" } } } } }
H.Jewel{ id = 2249, key = "idol_of_the_moon", name = "Idol of the Moon", icon = I("inv_relics_idolofrejuvenation"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = DRUID, stats = { sp = 8 },
  triggers = { { on = "dotTick", match = { tag = "spell" }, every = 5, effects = { { type = "buff", stat = "crit", value = 100, target = "all", match = { tag = "spell", damaging = "direct" }, charges = 1, duration = 15, key = "idol_of_the_moon", name = "Idol of the Moon" } } } } }
H.Jewel{ id = 2250, key = "idol_of_brutality", name = "Idol of Brutality", icon = I("inv_relics_idolofferocity"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = DRUID, stats = { armor = 12 },
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "cdr", target = "all", match = { kind = "form", tag = "autoattack" }, amount = 1, clampReady = true } } } } }
H.Jewel{ id = 2251, key = "naglering", name = "Naglering", icon = I("inv_jewelry_ring_05"), kind = "ring", quality = 3, cost = 6, minRound = 4, classes = DRUID, stats = { armor = 18, hp = 40, thorns = 4 } }
