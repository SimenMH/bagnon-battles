local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local SHAMAN = { "SHAMAN" }

H.Weapon{ id = 7400, key = "shaman_crescent_staff", name = "Crescent Staff", icon = I("inv_staff_04"), quality = 3, cost = 6, minRound = 2, classes = SHAMAN, weaponType = "staff", hands = 2, weaponMin = 8, weaponMax = 13, speed = 3.0, stats = { sp = 14, healing = 12, hp = 25 } }
H.Weapon{ id = 7401, key = "shaman_emberstone_staff", name = "Emberstone Staff", icon = I("inv_staff_13"), quality = 3, cost = 7, minRound = 3, classes = SHAMAN, weaponType = "staff", hands = 2, weaponMin = 9, weaponMax = 15, speed = 2.9, stats = { sp = 24, mana = 25 } }
H.Weapon{ id = 7402, key = "fist_of_omokk", name = "Fist of Omokk", icon = I("inv_hammer_04"), quality = 3, cost = 9, minRound = 5, classes = SHAMAN, weaponType = "mace", hands = 2, weaponMin = 21, weaponMax = 31, speed = 3.6, stats = { ap = 28, hp = 45 } }
H.Weapon{ id = 7403, key = "shaman_earthshaker", name = "Earthshaker", icon = I("inv_hammer_04"), quality = 4, cost = 12, minRound = 9, classes = SHAMAN, weaponType = "mace", hands = 2, weaponMin = 27, weaponMax = 39, speed = 3.5, stats = { ap = 36, crit = 4 },
  triggers = { { on = "hit", chance = 12, effects = { { type = "stun", duration = 0.7 } } } } }
H.Weapon{ id = 7404, key = "shaman_spinal_reaper", name = "Spinal Reaper", icon = I("inv_axe_09"), quality = 4, cost = 13, minRound = 11, classes = SHAMAN, weaponType = "axe", hands = 2, weaponMin = 30, weaponMax = 44, speed = 3.8, stats = { ap = 45, crit = 5 } }
ns.RegisterItem{ id = 7407, key = "shaman_redbeard_crest", name = "Redbeard Crest", icon = I("inv_shield_02"), kind = "shield", quality = 2, cost = 5, minRound = 2, classes = SHAMAN, shape = S.sq, stats = { armor = 20, block = 9, blockChance = 26, hp = 25 } }
H.Armor{ id = 7411, key = "shaman_turtle_scale_gloves", name = "Turtle Scale Gloves", icon = I("inv_gauntlets_05"), quality = 2, cost = 5, minRound = 2, classes = SHAMAN, armorType = "mail", slot = "hands", stats = { armor = 10, healing = 18, mana = 20 } }
H.Armor{ id = 7412, key = "shaman_black_dragonscale_breastplate", name = "Black Dragonscale Breastplate", icon = I("inv_chest_plate06"), quality = 3, cost = 9, minRound = 5, classes = SHAMAN, armorType = "mail", slot = "chest", stats = { ap = 52, crit = 5, armor = 30, hp = 45 } }
H.Armor{ id = 7413, key = "shaman_green_dragonscale_breastplate", name = "Green Dragonscale Breastplate", icon = I("inv_chest_chain_06"), quality = 3, cost = 8, minRound = 4, classes = SHAMAN, armorType = "mail", slot = "chest", stats = { healing = 46, regen = 3, armor = 22, hp = 40 } }
H.Jewel{ id = 7414, key = "totem_of_rage", name = "Totem of Rage", icon = I("inv_relics_totemofrage"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = SHAMAN, stats = { sp = 12 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shock" }, effects = { { type = "tickDots", match = { tag = "fire" } } } } } }
H.Jewel{ id = 7415, key = "totem_of_rebirth", name = "Totem of Rebirth", icon = I("inv_relics_totemofrebirth"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = SHAMAN, stats = { healing = 12 },
  triggers = { { on = "healed", everyAmount = 30, effects = { { type = "cdr", target = "all", match = { key = "lightning_shield" }, amount = 1 } } },
    { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "heal" }, everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }
H.Jewel{ id = 7416, key = "totem_of_sustaining", name = "Totem of Sustaining", icon = I("inv_relics_totemoflife"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = SHAMAN, stats = { healing = 14 },
  triggers = { { on = "hotTick", match = { tag = "totem" }, every = 4, effects = { { type = "absorb", amount = 8, coef = 0.15 } } } } }
H.Jewel{ id = 7417, key = "totem_of_life", name = "Totem of Life", icon = I("inv_relics_totemoflife"), kind = "relic", quality = 4, cost = 10, minRound = 8, classes = SHAMAN, stats = { healing = 24 },
  triggers = { { on = "anyCrit", healing = true, effects = { { type = "cast", key = "healing_stream_totem" } } } } }
H.Jewel{ id = 7418, key = "totem_of_flowing_water", name = "Totem of Flowing Water", icon = I("inv_relics_totemoflife"), kind = "relic", quality = 4, cost = 11, minRound = 10, classes = SHAMAN, stats = { regen = 3, healing = 16 },
  triggers = { { on = "anyUse", match = { key = "chain_heal" }, effects = { { type = "cast", target = "neighbors", match = { tag = "totem" } } } } } }
H.Jewel{ id = 7420, key = "shaman_rune_of_the_guard_captain", name = "Rune of the Guard Captain", icon = I("inv_misc_rune_07"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = SHAMAN, stats = { ap = 32, crit = 4 } }

ns.RegisterSet{ key = "the_elements", name = "The Elements", bonuses = {
  [2] = { stats = { sp = 16, mana = 25 } },
  [4] = { triggers = { { on = "anyUse", match = { tag = "shock" }, effects = { { type = "resource", resource = "mana", amount = 5 } } } }, text = "Shocks restore 5 Mana." },
} }
ns.RegisterSet{ key = "earthfury", name = "The Earthfury", bonuses = {
  [2] = { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Every third melee weapon hit restores 8 Mana." },
  [4] = { triggers = { { on = "anyUse", match = { key = "stormstrike" }, effects = { { type = "cast", key = "earth_shock" } } } }, text = "Stormstrike casts Earth Shock for free." },
  [6] = { double = { tag = "melee" }, stats = { lifesteal = 15, ap = 30 }, text = "Melee attacks hit twice. Gain 30 Attack Power and 15% Lifesteal." },
} }
ns.RegisterSet{ key = "ten_storms", name = "The Ten Storms", bonuses = {
  [2] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Spell crits restore 8 Mana." },
  [4] = { triggers = { { on = "dotTick", match = { tag = "fire" }, every = 3, effects = { { type = "cdr", target = "all", match = { key = "chain_lightning" }, amount = 1 } } } }, text = "Every third Fire damage tick advances Chain Lightning by 1s." },
  [6] = { double = { tag = "elemental" }, free = { tag = "elemental" }, text = "Elemental spells hit twice and cost nothing." },
} }
ns.RegisterSet{ key = "earthshatter", name = "The Earthshatterer", bonuses = {
  [2] = { triggers = { { on = "hotTick", match = { tag = "totem" }, effects = { { type = "resource", resource = "mana", amount = 3 } } } }, text = "Totem healing ticks restore 3 Mana." },
  [4] = { triggers = { { on = "healed", effects = { { type = "absorb", fromEvent = 0.3 } } } }, text = "Effective healing shields you for 30% of its value." },
  [6] = { double = { tag = "heal" }, flags = { "revive" }, triggers = { { on = "healed", everyAmount = 50, effects = { { type = "cast", key = "lightning_bolt" } } } }, text = "Heals activate twice. Every 50 effective healing casts Lightning Bolt for free. Once per battle, return to full health instead of dying." },
} }

H.SetPieces{ key = "the_elements", firstId = 7450, tag = "elemental", classes = SHAMAN, armorType = "mail", quality = 3, rounds = { 3, 3, 5, 6 },
  slots = { "head", "shoulder", "chest", "feet" }, stats = { hp = 18, armor = 10, sp = 12, healing = 6 },
  names = { "Coif of Elements", "Pauldrons of Elements", "Vest of Elements", "Boots of Elements" },
  icons = { "inv_helmet_04", "inv_shoulder_29", "inv_chest_chain_11", "inv_boots_wolf" } }
H.SetPieces{ key = "earthfury", firstId = 7460, tag = "enhancement", classes = SHAMAN, armorType = "mail", quality = 4, rounds = { 4, 5, 7, 9, 11, 12 },
  stats = { hp = 24, armor = 16, ap = 22, sp = 10, crit = 2 },
  names = { "Earthfury Helmet", "Earthfury Epaulets", "Earthfury Vestments", "Earthfury Gauntlets", "Earthfury Legguards", "Earthfury Boots" },
  icons = { "inv_helmet_09", "inv_shoulder_29", "inv_chest_chain_11", "inv_gauntlets_11", "inv_pants_03", "inv_boots_plate_06" } }
H.SetPieces{ key = "ten_storms", firstId = 7470, tag = "elemental", classes = SHAMAN, armorType = "mail", quality = 4, rounds = { 5, 6, 8, 10, 12, 13 },
  stats = { hp = 22, armor = 12, sp = 24, mana = 12, crit = 2 },
  names = { "Helmet of Ten Storms", "Epaulets of Ten Storms", "Breastplate of Ten Storms", "Gauntlets of Ten Storms", "Legplates of Ten Storms", "Greaves of Ten Storms" },
  icons = { "inv_helmet_69", "inv_shoulder_33", "inv_chest_chain_11", "inv_gauntlets_11", "inv_pants_03", "inv_boots_plate_06" } }
H.SetPieces{ key = "earthshatter", firstId = 7480, tag = "restoration", classes = SHAMAN, armorType = "mail", quality = 4, rounds = { 6, 7, 9, 11, 13, 14 },
  stats = { hp = 24, armor = 12, healing = 26, mana = 12, regen = 1 },
  names = { "Earthshatter Headpiece", "Earthshatter Spaulders", "Earthshatter Tunic", "Earthshatter Handguards", "Earthshatter Legguards", "Earthshatter Boots" },
  icons = { "inv_helmet_15", "inv_shoulder_14", "inv_chest_chain_15", "inv_gauntlets_25", "inv_pants_mail_15", "inv_boots_chain_05" } }
