local ADDON, ns = ...
local H = ns.H
local I = H.I
local SHAMAN = { "SHAMAN" }

H.Jewel{
  id = 7419, key = "royal_seal_of_eldre_thalas_shaman", name = "Royal Seal of Eldre'Thalas", icon = I("inv_jewelry_talisman_10"), quality = 3,
  minRound = 4, kind = "trinket", classes = SHAMAN, stats = { crit = 3, healing = 28, mana = 25 },
}

H.Jewel{ id = 7414, key = "totem_of_rage", name = "Totem of Rage", icon = I("inv_relics_totemofrage"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = SHAMAN, stats = { sp = 12 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shock" }, effects = { { type = "tickDots", match = { tag = "fire" } } } } } }
H.Jewel{ id = 7415, key = "totem_of_rebirth", name = "Totem of Rebirth", icon = I("inv_relics_totemofrebirth"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = SHAMAN, stats = { healing = 12 },
  triggers = { { on = "healed", everyAmount = 30, effects = { { type = "cdr", target = "all", match = { key = "stoneclaw_totem" }, amount = 1, clampReady = true } } },
    { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "heal" }, everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }
H.Jewel{ id = 7416, key = "totem_of_sustaining", name = "Totem of Sustaining", icon = I("inv_relics_totemoflife"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = SHAMAN, stats = { healing = 14 },
  triggers = { { on = "healed", match = { tag = "totem" }, every = 4, effects = { { type = "absorb", amount = 8, coef = 0.15 } } } } }
H.Jewel{ id = 7417, key = "totem_of_life", name = "Totem of Life", icon = I("inv_relics_totemoflife"), kind = "relic", quality = 4, cost = 10, minRound = 8, classes = SHAMAN, stats = { healing = 24 },
  triggers = { { on = "anyCrit", healing = true, effects = { { type = "cast", key = "healing_stream_totem" } } } } }
H.Jewel{ id = 7418, key = "totem_of_flowing_water", name = "Totem of Flowing Water", icon = I("inv_relics_totemoflife"), kind = "relic", quality = 4, cost = 11, minRound = 10, classes = SHAMAN, stats = { regen = 3, healing = 16 },
  triggers = { { on = "anyUse", match = { key = "chain_heal" }, effects = { { type = "cast", target = "neighbors", match = { tag = "totem", notTag = "mana_totem" } } } } } }

ns.RegisterSet{ key = "the_elements", name = "The Elements", bonuses = {
  [2] = { stats = { sp = 16, mana = 25 } },
  [4] = { triggers = { { on = "anyUse", match = { tag = "shock" }, effects = { { type = "resource", resource = "mana", amount = 5 } } } }, text = "Casting a shock restores 5 Mana." },
} }
ns.RegisterSet{ key = "earthfury", name = "The Earthfury", bonuses = {
  [2] = { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Every third melee auto-attack that hits restores 8 Mana." },
  [4] = { triggers = { { on = "anyUse", match = { key = "stormstrike" }, effects = { { type = "cast", key = "earth_shock" } } } }, text = "Using Stormstrike also casts your Earth Shock without consuming Mana." },
  [6] = { double = { tag = "melee" }, stats = { lifesteal = 15, ap = 30 }, text = "Your melee attacks hit twice." },
} }
ns.RegisterSet{ key = "ten_storms", name = "The Ten Storms", bonuses = {
  [2] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "resource", resource = "mana", amount = 8 } } } }, text = "Your damaging spell critical strikes restore 8 Mana." },
  [4] = { triggers = { { on = "dotTick", match = { tag = "fire" }, every = 3, effects = { { type = "cdr", target = "all", match = { key = "chain_lightning" }, amount = 1 } } } }, text = "Every third tick of periodic Fire damage reduces the remaining cooldown of Chain Lightning by 1 second." },
  [6] = { double = { tag = "elemental" }, free = { tag = "elemental" }, text = "Your Elemental spells take effect twice and consume no Mana." },
} }
ns.RegisterSet{ key = "earthshatter", name = "The Earthshatterer", bonuses = {
  [2] = { triggers = { { on = "healed", match = { tag = "totem" }, effects = { { type = "resource", resource = "mana", amount = 3 } } } }, text = "Whenever one of your totems restores Health, you regain 3 Mana." },
  [4] = { triggers = { { on = "healed", effects = { { type = "absorb", fromEvent = 0.3 } } } }, text = "Restoring Health grants a shield equal to 30% of the Health restored." },
  [6] = { double = { tag = "heal" }, flags = { "revive" }, triggers = { { on = "healed", everyAmount = 50, icd = 1, effects = { { type = "cast", key = "lightning_bolt" } } } }, text = "Your healing spells take effect twice. Restoring 50 Health casts your Lightning Bolt without consuming Mana, at most once per second. Once per battle, lethal damage restores you to full Health." },
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
