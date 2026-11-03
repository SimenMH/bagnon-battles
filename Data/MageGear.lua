local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local MAGE = { "MAGE" }

H.Weapon{ id = 8400, key = "bent_staff", name = "Bent Staff", icon = I("INV_Staff_08"), quality = 1, cost = 3, classes = MAGE, weaponType = "staff", hands = 2, weaponMin = 3, weaponMax = 5, speed = 3, stats = { sp = 4 }, noShop = true, starter = true }
H.Weapon{ id = 8401, key = "hypnotic_blade", name = "Hypnotic Blade", icon = I("INV_Weapon_ShortBlade_07"), quality = 3, cost = 7, minRound = 3, classes = { "MAGE", "WARLOCK", "SHAMAN", "DRUID" }, weaponType = "dagger", weaponMin = 4, weaponMax = 7, speed = 1.8, stats = { sp = 22, mana = 25 } }
H.Weapon{ id = 8402, key = "rod_of_the_ogre_magi", name = "Rod of the Ogre Magi", icon = I("INV_Staff_29"), quality = 3, cost = 8, minRound = 5, classes = { "MAGE", "DRUID" }, weaponType = "staff", hands = 2, weaponMin = 8, weaponMax = 12, speed = 3, stats = { sp = 29, crit = 4, mana = 30 } }
H.Weapon{ id = 8403, key = "azuresong_mageblade", name = "Azuresong Mageblade", icon = I("INV_Sword_12"), quality = 4, cost = 11, minRound = 8, classes = MAGE, weaponType = "sword", weaponMin = 9, weaponMax = 14, speed = 2.4, stats = { sp = 48, crit = 5, mana = 30 } }

H.Weapon{ id = 8404, key = "caster_scrimshaw_dagger", name = "Scrimshaw Dagger", icon = I("INV_Weapon_ShortBlade_01"), quality = 1, cost = 4, classes = { "MAGE", "WARLOCK", "SHAMAN", "DRUID" }, weaponType = "dagger", weaponMin = 4, weaponMax = 7, speed = 1.8, stats = { sp = 6, mana = 10 } }
H.Weapon{ id = 8405, key = "caster_sacrificial_kris", name = "Sacrificial Kris", icon = I("INV_Weapon_ShortBlade_03"), quality = 2, cost = 5, minRound = 2, classes = { "MAGE", "WARLOCK", "SHAMAN", "DRUID" }, weaponType = "dagger", weaponMin = 5, weaponMax = 8, speed = 1.7, stats = { sp = 14, hp = 20 } }
H.Weapon{ id = 8406, key = "witchblade", name = "Witchblade", icon = I("INV_Weapon_ShortBlade_25"), quality = 3, cost = 8, minRound = 5, classes = { "MAGE", "WARLOCK" }, weaponType = "dagger", weaponMin = 6, weaponMax = 10, speed = 1.6, stats = { sp = 25, crit = 3 } }
H.Weapon{ id = 8407, key = "sorcerous_dagger", name = "Sorcerous Dagger", icon = I("INV_Weapon_ShortBlade_07"), quality = 4, cost = 9, minRound = 7, classes = { "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 7, weaponMax = 12, speed = 1.8, stats = { sp = 40, mana = 45 } }

local function armor(id, key, name, icon, slot, quality, round, stats, classes)
  H.Armor{ id = id, key = key, name = name, icon = I(icon), classes = classes or MAGE, armorType = "cloth", slot = slot, quality = quality, minRound = round, stats = stats }
end
armor(8410, "azure_silk_hood", "Azure Silk Hood", "INV_Helmet_29", "head", 1, 1, { sp = 8, mana = 15, hp = 8 }, { "MAGE", "DRUID" })
armor(8411, "azure_silk_vest", "Azure Silk Vest", "INV_Chest_Cloth_37", "chest", 1, 1, { sp = 15, mana = 25, hp = 13 })
armor(8412, "azure_silk_gloves", "Azure Silk Gloves", "INV_Gauntlets_05", "hands", 1, 1, { sp = 6, crit = 2 }, { "MAGE", "DRUID" })
armor(8413, "azure_silk_pants", "Azure Silk Pants", "INV_Pants_08", "legs", 1, 1, { sp = 9, mana = 20 }, { "MAGE", "DRUID" })
armor(8414, "azure_silk_belt", "Azure Silk Belt", "INV_Belt_22", "waist", 2, 2, { sp = 11, regen = 1 }, { "MAGE", "DRUID" })
armor(8415, "spidersilk_boots", "Spidersilk Boots", "INV_Boots_Fabric_01", "feet", 2, 2, { sp = 9, hp = 35, healing = 10 }, { "MAGE", "DRUID" })
armor(8416, "silver_thread_cuffs", "Silver-thread Cuffs", "INV_Bracer_07", "wrist", 2, 2, { sp = 9, mana = 20 }, { "MAGE", "DRUID" })
armor(8417, "silver_thread_amice", "Silver-thread Amice", "INV_Shoulder_05", "shoulder", 2, 2, { sp = 11, healing = 12, armor = 10 }, { "MAGE", "DRUID" })
armor(8418, "robe_of_the_archmage", "Robe of the Archmage", "INV_Chest_Cloth_38", "chest", 4, 7, { sp = 72, mana = 60, crit = 6 })
armor(8419, "hands_of_power", "Hands of Power", "INV_Gauntlets_06", "hands", 3, 5, { sp = 24, healing = 18, crit = 3 }, { "MAGE", "DRUID" })
H.Jewel{ id = 8420, key = "fire_ruby", name = "Fire Ruby", icon = I("INV_Misc_Gem_Bloodstone_02"), kind = "trinket", quality = 3, minRound = 4, classes = MAGE, stats = { sp = 9 },
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "buff", key = "fire_ruby", stat = "crit", value = 100, charges = 1, duration = 10, target = "all", match = { tag = "fire", damaging = "direct" } } } } } }
H.Jewel{ id = 8421, key = "mind_quickening_gem", name = "Mind Quickening Gem", icon = I("Spell_Nature_WispHeal"), kind = "trinket", quality = 4, minRound = 8, classes = MAGE,
  use = { cd = 24, effects = { { type = "buff", key = "mind_quickening_gem", stat = "haste", value = 40, duration = 8, target = "all", match = { tag = "spell" } } } } }
H.Jewel{ id = 8422, key = "freezing_band", name = "Freezing Band", icon = I("INV_Jewelry_Ring_14"), kind = "ring", quality = 4, minRound = 7, classes = MAGE, stats = { sp = 24, healing = 16 },
  triggers = { { on = "absorbed", everyAmount = 35, effects = { { type = "stun", duration = 0.8 } } } } }
H.Jewel{ id = 8423, key = "choker_of_the_fire_lord", name = "Choker of the Fire Lord", icon = I("INV_Jewelry_Necklace_11"), kind = "neck", quality = 4, minRound = 8, classes = { "MAGE", "DRUID" }, stats = { sp = 42, mana = 30, crit = 3 } }
H.Jewel{ id = 8424, key = "mage_silver_thread_cloak", name = "Silver-thread Cloak", icon = I("INV_Misc_Cape_02"), kind = "cloak", quality = 2, minRound = 2, classes = MAGE, shape = S.h2, stats = { sp = 14, hp = 20, healing = 10 } }
H.Jewel{ id = 8425, key = "mage_ring_of_spell_power", name = "Ring of Spell Power", icon = I("INV_Jewelry_Ring_13"), kind = "ring", quality = 3, minRound = 5, classes = MAGE, stats = { sp = 25, mana = 25 } }

ns.RegisterSet{ key = "magister", name = "Magister's Regalia", bonuses = {
  [2] = { stats = { mana = 30, regen = 2 } },
  [4] = { triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 45, effects = { { type = "cast", key = "arcane_missiles" } } } }, text = "Every 45 Mana spent casts your Arcane Missiles for free." },
} }
ns.RegisterSet{ key = "sorcerer", name = "Sorcerer's Regalia", bonuses = {
  [2] = { triggers = { { on = "enemyStunned", match = { kind = "ability", tag = "frost" }, effects = { { type = "absorb", amount = 12, coef = 0.2 } } } }, text = "Your Frost abilities freezing the enemy grant an absorb of 12 + 20% Healing Power." },
} }
ns.RegisterSet{ key = "arcanist", name = "Arcanist Regalia", bonuses = {
  [2] = { triggers = { { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "arcane_resonance", fraction = 0.25, cap = { flat = 50, sp = 1 } } } } }, text = "Store 25% of Mana spent for Arcane Explosion." },
  [4] = { triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "cast", key = "arcane_missiles" } } } }, text = "Every 40 Mana spent casts your Arcane Missiles for free." },
  [6] = { double = { tag = "arcane" }, free = { tag = "arcane" }, mods = { match = { tag = "arcane" }, cdPct = 30 }, text = "Arcane spells cast twice, cost no Mana and recharge 30% faster." },
} }
ns.RegisterSet{ key = "netherwind", name = "Netherwind Regalia", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { tag = "fire" }, effects = { { type = "tickDots", match = { tag = "burn" } } } } }, text = "Fire casts immediately tick your burns." },
  [4] = { triggers = { { on = "dotTick", match = { tag = "burn" }, every = 6, effects = { { type = "cast", key = "pyroblast" } } } }, text = "Every 6 burn ticks cast your Pyroblast for free." },
  [6] = { double = { tag = "fire" }, stats = { crit = 30, critDamage = 50 }, text = "Fire spells cast twice. Gain 30% Critical Strike and 50% Critical Strike Damage." },
} }
ns.RegisterSet{ key = "frostfire", name = "Frostfire Regalia", bonuses = {
  [2] = { triggers = { { on = "enemyStunned", match = { kind = "ability", tag = "frost" }, effects = { { type = "absorb", amount = 20, coef = 0.35 } } } }, text = "Your Frost abilities freezing the enemy grant an absorb of 20 + 35% Healing Power." },
  [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "frost" }, effects = { { type = "cdr", target = "all", match = { tag = "frost" }, amount = 0.5, clampReady = true } } } }, text = "Frost crits reduce Frost cooldowns by 0.5s." },
  [6] = { double = { tag = "frost" }, flags = { "revive" }, text = "Frost spells cast twice. Once per battle, return to full Health instead of dying." },
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

H.Weapon{ id = 8426, key = "wand_of_biting_cold", name = "Wand of Biting Cold", icon = I("INV_Wand_01"), quality = 3, cost = 8, minRound = 4, classes = MAGE, weaponType = "wand", weaponMin = 10, weaponMax = 15, speed = 1.8, tags = { "wand", "spell", "ranged", "frost" }, stats = { sp = 18, crit = 3 },
  use = { cd = 1.8, effects = { { type = "damage", weaponSelf = true, coef = 0.18, school = "frost", ranged = true, noDodge = true, critIf = "enemyStunned" } } } }
