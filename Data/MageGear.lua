local ADDON, ns = ...
local H = ns.H
local I = H.I
local MAGE = { "MAGE" }

H.Weapon{ id = 8400, key = "bent_staff", name = "Bent Staff", icon = I("INV_Staff_08"), quality = 1, cost = 3, classes = MAGE, weaponType = "staff", hands = 2, weaponMin = 3, weaponMax = 5, speed = 3, stats = { sp = 4 }, noShop = true, starter = true }

local function armor(id, key, name, icon, slot, quality, round, stats, classes)
  H.Armor{ id = id, key = key, name = name, icon = I(icon), classes = classes or MAGE, armorType = "cloth", slot = slot, quality = quality, minRound = round, stats = stats }
end
armor(8418, "robe_of_the_archmage", "Robe of the Archmage", "INV_Chest_Cloth_38", "chest", 4, 7, { sp = 72, mana = 60, crit = 6 })
H.Jewel{ id = 8420, key = "fire_ruby", name = "Fire Ruby", icon = I("INV_Misc_Gem_Bloodstone_02"), kind = "trinket", quality = 3, minRound = 4, classes = MAGE, stats = { sp = 9 },
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "buff", key = "fire_ruby", stat = "crit", value = 100, charges = 1, duration = 10, target = "all", match = { tag = "fire", damaging = "direct" } } } } } }
H.Jewel{ id = 8421, key = "mind_quickening_gem", name = "Mind Quickening Gem", icon = I("Spell_Nature_WispHeal"), kind = "trinket", quality = 4, minRound = 8, classes = MAGE,
  use = { cd = 24, effects = { { type = "buff", key = "mind_quickening_gem", stat = "haste", value = 40, duration = 8, target = "all", match = { tag = "spell" } } } } }

ns.RegisterSet{ key = "magister", name = "Magister's Regalia", bonuses = {
  [2] = { stats = { mana = 30, regen = 2 } },
  [4] = { triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 45, effects = { { type = "cast", key = "arcane_missiles", deferDuringChannel = true } } } }, text = "Consuming 45 Mana casts your Arcane Missiles without consuming additional Mana." },
} }
ns.RegisterSet{ key = "sorcerer", name = "Sorcerer's Regalia", bonuses = {
  [2] = { triggers = { { on = "enemyStunned", match = { kind = "ability", tag = "frost" }, effects = { { type = "absorb", amount = 12, coef = 0.2 } } } }, text = "Freezing an enemy with a Frost ability grants a shield that absorbs 12 damage plus 20% of your Healing Power." },
} }
ns.RegisterSet{ key = "arcanist", name = "Arcanist Regalia", bonuses = {
  [2] = { triggers = { { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "arcane_resonance", fraction = 0.25, cap = { flat = 50, sp = 1 } } } } }, text = "Consuming Mana stores 25% of the amount consumed as bonus damage for your next Arcane Explosion." },
  [4] = { triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "cast", key = "arcane_missiles", deferDuringChannel = true } } } }, text = "Consuming 40 Mana casts your Arcane Missiles without consuming additional Mana." },
  [6] = { double = { tag = "arcane" }, free = { tag = "arcane" }, mods = { match = { tag = "arcane" }, cdPct = 30 }, text = "Your Arcane spells take effect twice, consume no Mana, and have their cooldowns reduced by 30%." },
} }
ns.RegisterSet{ key = "netherwind", name = "Netherwind Regalia", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { tag = "fire" }, effects = { { type = "tickDots", match = { tag = "burn" } } } } }, text = "Casting a Fire spell causes each of your active burns to deal one additional tick of damage." },
  [4] = { triggers = { { on = "dotTick", match = { tag = "burn" }, every = 6, effects = { { type = "cast", key = "pyroblast" } } } }, text = "After every 6 ticks of damage from your burns, cast your Pyroblast without consuming Mana." },
  [6] = { double = { tag = "fire" }, stats = { crit = 30, critDamage = 50 }, text = "Your Fire spells take effect twice whenever you cast them." },
} }
ns.RegisterSet{ key = "frostfire", name = "Frostfire Regalia", bonuses = {
  [2] = { triggers = { { on = "enemyStunned", match = { kind = "ability", tag = "frost" }, effects = { { type = "absorb", amount = 20, coef = 0.35 } } } }, text = "Freezing an enemy with a Frost ability grants a shield that absorbs 20 damage plus 35% of your Healing Power." },
  [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "frost" }, effects = { { type = "cdr", target = "all", match = { tag = "frost" }, amount = 0.5, clampReady = true } } } }, text = "Your Frost critical strikes reduce the remaining cooldowns of your Frost abilities by 0.5 seconds." },
  [6] = { double = { tag = "frost" }, flags = { "revive" }, text = "Your Frost spells take effect twice whenever you cast them. Once per battle, lethal damage restores you to full Health." },
} }

H.SetPieces{ key = "magister", firstId = 8450, tag = "arcane", classes = MAGE, armorType = "cloth", quality = 3, rounds = { 3, 4, 5, 6 }, statScale = { sp = 0.9 },
  slots = { "head", "chest", "hands", "feet" }, stats = { sp = 12, mana = 16, hp = 15 },
  names = { "Magister's Crown", "Magister's Robes", "Magister's Gloves", "Magister's Boots" },
  icons = { "INV_Crown_02", "INV_Chest_Cloth_28", "INV_Gauntlets_17", "INV_Boots_02" } }
H.SetPieces{ key = "sorcerer", firstId = 8454, tag = "frost", classes = MAGE, armorType = "cloth", quality = 3, rounds = { 3, 4 }, statScale = { sp = 0.9 },
  slots = { "wrist", "waist" }, stats = { sp = 16, healing = 12, hp = 20 },
  names = { "Sorcerer's Bindings", "Sorcerer's Belt" },
  icons = { "INV_Jewelry_Ring_23", "INV_Belt_08" } }
H.SetPieces{ key = "arcanist", firstId = 8460, tag = "arcane", classes = MAGE, armorType = "cloth", quality = 4, rounds = { 3, 5, 7, 9, 10, 12 },
  stats = { sp = 16, mana = 20, hp = 20 },
  names = { "Arcanist Crown", "Arcanist Mantle", "Arcanist Robes", "Arcanist Gloves", "Arcanist Leggings", "Arcanist Boots" },
  icons = { "INV_Helmet_53", "INV_Shoulder_02", "INV_Chest_Cloth_03", "INV_Gauntlets_14", "INV_Pants_08", "INV_Boots_07" } }
H.SetPieces{ key = "netherwind", firstId = 8470, tag = "fire", classes = MAGE, armorType = "cloth", quality = 4, rounds = { 4, 6, 8, 9, 11, 13 },
  stats = { sp = 18, crit = 3, hp = 20 },
  names = { "Netherwind Crown", "Netherwind Mantle", "Netherwind Robes", "Netherwind Gloves", "Netherwind Pants", "Netherwind Boots" },
  icons = { "INV_Helmet_70", "INV_Shoulder_32", "INV_Chest_Cloth_03", "INV_Gauntlets_14", "INV_Pants_08", "INV_Boots_07" } }
H.SetPieces{ key = "frostfire", firstId = 8480, tag = "frost", classes = MAGE, armorType = "cloth", quality = 4, rounds = { 5, 6, 8, 10, 12, 14 },
  stats = { sp = 14, healing = 14, hp = 30, armor = 10 },
  names = { "Frostfire Circlet", "Frostfire Shoulderpads", "Frostfire Robe", "Frostfire Gloves", "Frostfire Leggings", "Frostfire Sandals" },
  icons = { "INV_Crown_01", "INV_Shoulder_25", "INV_Chest_Cloth_43", "INV_Gauntlets_17", "INV_Pants_Cloth_05", "INV_Boots_Fabric_01" } }
