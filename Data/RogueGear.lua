local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local ROGUE = { "ROGUE" }

H.Jewel{ id = 4430, key = "royal_seal_rogue", name = "Royal Seal of Eldre'Thalas", icon = I("INV_Jewelry_Talisman_06"), kind = "trinket", quality = 3, cost = 7, minRound = 4, classes = ROGUE, stats = { ap = 24, crit = 5 } }
H.Jewel{ id = 4431, key = "renatakis_charm_of_trickery", name = "Renataki's Charm of Trickery", icon = I("INV_Jewelry_Necklace_19"), kind = "trinket", quality = 4, cost = 10, minRound = 7, classes = ROGUE,
  use = { cd = 22, initialDelay = 2, condition = "resourceAtLeast:combo:1", effects = { { type = "resource", resource = "energy", amount = 60 } } } }
H.Jewel{ id = 4433, key = "cloak_of_veiled_shadows", name = "Cloak of Veiled Shadows", icon = I("INV_Misc_Cape_18"), kind = "cloak", quality = 3, cost = 8, minRound = 5, classes = ROGUE, shape = S.h2, stats = { ap = 24, dodge = 5, armor = 8 },
  triggers = { { on = "anyUse", match = { key = "vanish" }, effects = { { type = "heal", pctMax = 0.05 } } } } }
H.Jewel{ id = 4436, key = "royal_seal_of_alexis", name = "Royal Seal of Alexis", icon = I("INV_Jewelry_Ring_31"), kind = "ring", quality = 3, cost = 7, minRound = 5, classes = ROGUE, stats = { ap = 18, sp = 12, hp = 35 }, tags = { "poison" },
  triggers = { { on = "dotTick", match = { tag = "poison" }, every = 5, effects = { { type = "resource", resource = "energy", amount = 5 } } } } }

ns.RegisterSet{ key = "shadowcraft", name = "Shadowcraft Armor", bonuses = {
  [2] = { stats = { ap = 18, crit = 4 } },
  [4] = { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 4, effects = { { type = "resource", resource = "energy", amount = 20 } } } }, text = "Every fourth melee auto-attack that hits restores 20 Energy." },
} }
ns.RegisterSet{ key = "nightslayer", name = "Nightslayer Armor", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { tag = "opener" }, effects = { { type = "resource", resource = "energy", amount = 15 } } } }, text = "Using an opener restores 15 Energy." },
  [4] = { triggers = { { on = "dodged", effects = { { type = "resource", resource = "combo", amount = 1 }, { type = "cdr", target = "all", match = { key = "vanish" }, amount = 1, clampReady = true } } } }, text = "Dodging an attack grants 1 Combo Point and reduces the remaining cooldown of Vanish by 1 second." },
  [6] = { triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "cast", key = "vanish" }, { type = "heal", pctMax = 0.06 } } } }, text = "Using a finishing move casts your Vanish at no cost and heals you for 6% of your maximum Health." },
} }
ns.RegisterSet{ key = "bloodfang", name = "Bloodfang Armor", bonuses = {
  [2] = { mods = { match = { tag = "poison" }, dmgPct = 25 }, text = "Increases the damage of your poisons by 25%." },
  [4] = { triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "tickDots", match = { tag = "poison" } } } } }, text = "Using a finishing move causes each of your active poisons to deal one additional tick of damage." },
  [6] = { double = { tag = "finisher" }, triggers = { { on = "dotTick", match = { tag = "poison" }, effects = { { type = "heal", fromEvent = 0.3, noCrit = true } } } }, text = "Your finishing moves take effect twice. Periodic damage from your poisons heals you for 30% of the damage dealt." },
} }
ns.RegisterSet{ key = "bonescythe", name = "Bonescythe Armor", bonuses = {
  [2] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "builder" }, effects = { { type = "resource", resource = "energy", amount = 5 } } } }, text = "Critical strikes from your Combo Point generating abilities restore 5 Energy." },
  [4] = { triggers = { { on = "resourceSpent", resource = "combo", effects = { { type = "buff", target = "all", match = { tag = "builder" }, stat = "crit", value = 100, charges = 1, duration = 6, key = "bonescythe_opening", name = "Bonescythe Armor" } } } }, text = "Consuming Combo Points guarantees that your next Combo Point generating ability critically strikes within 6 seconds." },
  [6] = { double = { tag = "autoattack" }, triggers = { { on = "resourceSpent", resource = "energy", everyAmount = 60, effects = { { type = "cast", key = "sinister_strike" } } } }, text = "Your auto-attacks hit twice. Consuming 60 Energy casts your Sinister Strike without consuming Energy." },
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
