local ADDON, ns = ...
local H = ns.H
local I = H.I
local PALADIN = { "PALADIN" }

H.Jewel{
  id = 5417, key = "royal_seal_of_eldre_thalas_paladin", name = "Royal Seal of Eldre'Thalas", icon = I("inv_jewelry_talisman_10"), quality = 3,
  minRound = 4, kind = "trinket", classes = PALADIN, stats = { crit = 3, healing = 28, mana = 25 },
}

H.Weapon{ id = 5400, key = "worn_mace", name = "Worn Mace", icon = I("INV_Mace_01"), quality = 1, cost = 3, noShop = true, starter = true, classes = PALADIN, weaponType = "mace", weaponMin = 4, weaponMax = 6, speed = 2.4 }
H.Weapon{ id = 5401, key = "verigans_fist", name = "Verigan's Fist", icon = I("inv_hammer_05"), quality = 3, cost = 7, minRound = 3, classes = PALADIN, weaponType = "mace", hands = 2, weaponMin = 13, weaponMax = 20, speed = 3.2, stats = { ap = 18, sp = 12, mana = 20 } }
H.Armor{ id = 5411, key = "paladin_peacekeeper_boots", name = "Peacekeeper Boots", icon = I("inv_boots_plate_03"), quality = 3, cost = 7, minRound = 4, classes = PALADIN, armorType = "plate", slot = "feet", stats = { armor = 22, hp = 45, sp = 14, healing = 14 } }
H.Jewel{ id = 5412, key = "libram_of_divinity", name = "Libram of Divinity", icon = I("inv_relics_libramofhope"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = PALADIN, stats = { healing = 12 },
  triggers = { { on = "battleStart", effects = { { type = "buff", target = "all", match = { key = "flash_of_light" }, stat = "healPct", value = 12, duration = 90, key = "libram_of_divinity_healing", name = "Libram of Divinity" } } } } }
H.Jewel{ id = 5413, key = "libram_of_hope", name = "Libram of Hope", icon = I("inv_relics_libramofhope"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = PALADIN, stats = { regen = 2 },
  triggers = { { on = "anyUse", match = { key = "judgement" }, effects = { { type = "resource", resource = "mana", amount = 6 } } } } }
H.Jewel{ id = 5414, key = "libram_of_truth", name = "Libram of Truth", icon = I("inv_relics_libramoftruth"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = PALADIN, stats = { armor = 16 },
  triggers = { { on = "block", every = 3, effects = { { type = "cast", key = "judgement" } } } } }
H.Jewel{ id = 5415, key = "libram_of_grace", name = "Libram of Grace", icon = I("inv_relics_libramofgrace"), kind = "relic", quality = 4, cost = 10, minRound = 8, classes = PALADIN, stats = { healing = 24 },
  triggers = { { on = "anyUse", match = { key = "cleanse_paladin" }, effects = { { type = "heal", min = 12, max = 18, coef = 0.45 } } } } }
H.Jewel{ id = 5416, key = "libram_of_light", name = "Libram of Light", icon = I("inv_relics_libramofgrace"), kind = "relic", quality = 4, cost = 11, minRound = 10, classes = PALADIN, stats = { healing = 24 },
  triggers = { { on = "battleStart", effects = { { type = "buff", target = "all", match = { key = "holy_light" }, stat = "healPct", value = 25, duration = 90, key = "libram_of_light_healing", name = "Libram of Light" } } } } }

ns.RegisterSet{ key = "lightforge", name = "Lightforge Armor", bonuses = {
  [2] = { stats = { ap = 20, armor = 12 } },
  [4] = { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 3, effects = { { type = "buff", stat = "sp", value = 28, duration = 6, key = "lightforge_power", name = "Lightforge Armor" } } } }, text = "Every third melee auto-attack that hits grants 28 Spell Power for 6 seconds." },
} }
ns.RegisterSet{ key = "lawbringer", name = "Lawbringer Armor", bonuses = {
  [2] = { stats = { blockChance = 10, block = 8 } },
  [4] = { triggers = { { on = "block", effects = { { type = "absorb", fromEvent = 0.4 }, { type = "cdr", target = "all", match = { key = "holy_shield" }, amount = 0.5 } } } }, text = "Blocking an attack grants a shield equal to 40% of the damage blocked and reduces the remaining cooldown of Holy Shield by 0.5 seconds." },
  [6] = { triggers = { { on = "block", icd = 2, effects = { { type = "cast", key = "judgement" }, { type = "heal", fromEvent = 0.5 } } } }, stats = { block = 20 }, text = "Blocking an attack casts your Judgement without consuming Mana and heals you for 50% of the damage blocked. This can occur once every 2 seconds." },
} }
ns.RegisterSet{ key = "judgement_armor", name = "Judgement Armor", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { key = "judgement" }, effects = { { type = "extraAttack", count = 1 } } } }, text = "Casting Judgement grants an extra melee auto-attack." },
  [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "holy" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.6 } } } }, text = "Your Holy critical strikes store 60% of their damage as bonus damage for your next Judgement." },
  [6] = { double = { tag = "judgement" }, stats = { crit = 15, critDamage = 50 }, text = "Your Judgement abilities take effect twice whenever you cast them." },
} }
ns.RegisterSet{ key = "redemption", name = "Redemption Armor", bonuses = {
  [2] = { triggers = { { on = "healed", effects = { { type = "bank", key = "paladin_holy", fraction = 0.1 } } } }, text = "Restoring Health stores 10% of the Health restored as bonus damage for your next Holy Shock." },
  [4] = { triggers = { { on = "anyCrit", healing = true, effects = { { type = "cdr", target = "all", match = { key = "holy_shock" }, amount = 2 }, { type = "resource", resource = "mana", amount = 10 } } } }, text = "Your critical heals restore 10 Mana and reduce the remaining cooldown of Holy Shock by 2 seconds." },
  [6] = { flags = { "revive" }, triggers = { { on = "anyUse", match = { key = "holy_shock" }, icd = 4, effects = { { type = "cast", key = "holy_light" } } } }, text = "Casting Holy Shock also casts your Holy Light without consuming Mana. This can occur once every 4 seconds. Once per battle, lethal damage restores you to full Health." },
} }

H.SetPieces{ key = "lightforge", firstId = 5450, tag = "retribution", classes = PALADIN, armorType = "plate", quality = 3, rounds = { 3, 3, 5, 6 },
  slots = { "head", "shoulder", "chest", "feet" }, stats = { hp = 18, armor = 12, ap = 12, sp = 6 },
  names = { "Lightforge Helm", "Lightforge Spaulders", "Lightforge Breastplate", "Lightforge Boots" },
  icons = { "inv_helmet_08", "inv_shoulder_10", "inv_chest_plate03", "inv_boots_plate_03" } }
H.SetPieces{ key = "lawbringer", firstId = 5460, tag = "protection", classes = PALADIN, armorType = "plate", quality = 4, rounds = { 4, 5, 7, 9, 11, 12 },
  stats = { hp = 26, armor = 24, block = 3, sp = 8 },
  names = { "Lawbringer Helm", "Lawbringer Spaulders", "Lawbringer Chestguard", "Lawbringer Gauntlets", "Lawbringer Legplates", "Lawbringer Boots" },
  icons = { "inv_helmet_05", "inv_shoulder_20", "inv_chest_plate03", "inv_gauntlets_29", "inv_pants_04", "inv_boots_plate_09" } }
H.SetPieces{ key = "judgement_armor", firstId = 5470, tag = "retribution", classes = PALADIN, armorType = "plate", quality = 4, rounds = { 5, 6, 8, 10, 12, 13 },
  stats = { hp = 22, armor = 14, ap = 20, sp = 14, crit = 2 },
  names = { "Judgement Crown", "Judgement Spaulders", "Judgement Breastplate", "Judgement Gauntlets", "Judgement Legplates", "Judgement Sabatons" },
  icons = { "inv_helmet_74", "inv_shoulder_37", "inv_chest_plate03", "inv_gauntlets_29", "inv_pants_04", "inv_boots_plate_09" } }
H.SetPieces{ key = "redemption", firstId = 5480, tag = "holy", classes = PALADIN, armorType = "plate", quality = 4, rounds = { 6, 7, 9, 11, 13, 14 },
  stats = { hp = 24, armor = 14, healing = 24, mana = 12, crit = 2 },
  names = { "Redemption Headpiece", "Redemption Spaulders", "Redemption Tunic", "Redemption Handguards", "Redemption Legguards", "Redemption Boots" },
  icons = { "inv_helmet_15", "inv_shoulder_14", "inv_chest_chain_15", "inv_gauntlets_25", "inv_pants_mail_15", "inv_boots_chain_05" } }
