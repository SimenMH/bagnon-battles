local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local PALADIN = { "PALADIN" }

H.Weapon{ id = 5400, key = "worn_mace", name = "Worn Mace", icon = I("INV_Mace_01"), quality = 1, cost = 3, noShop = true, starter = true, classes = PALADIN, weaponType = "mace", weaponMin = 4, weaponMax = 6, speed = 2.4 }
H.Weapon{ id = 5401, key = "verigans_fist", name = "Verigan's Fist", icon = I("inv_hammer_05"), quality = 3, cost = 7, minRound = 3, classes = PALADIN, weaponType = "mace", hands = 2, weaponMin = 13, weaponMax = 20, speed = 3.2, stats = { ap = 18, sp = 12, mana = 20 } }
H.Weapon{ id = 5402, key = "paladin_hammer_of_the_grand_crusader", name = "Hammer of the Grand Crusader", icon = I("inv_hammer_06"), quality = 3, cost = 9, minRound = 5, classes = PALADIN, weaponType = "mace", hands = 2, weaponMin = 18, weaponMax = 28, speed = 3.5, stats = { healing = 28, sp = 20, hp = 30 } }
H.Armor{ id = 5408, key = "paladin_enchanted_thorium_breastplate", name = "Enchanted Thorium Breastplate", icon = I("inv_chest_plate10"), quality = 3, cost = 9, minRound = 5, classes = PALADIN, armorType = "plate", slot = "chest", stats = { armor = 60, hp = 90, block = 8 } }
H.Armor{ id = 5409, key = "paladin_stockade_pauldrons", name = "Stockade Pauldrons", icon = I("inv_shoulder_20"), quality = 4, cost = 10, minRound = 7, classes = PALADIN, armorType = "plate", slot = "shoulder", stats = { armor = 35, hp = 70, blockChance = 7 } }
H.Armor{ id = 5410, key = "paladin_ornate_mithril_gloves", name = "Ornate Mithril Gloves", icon = I("inv_gauntlets_31"), quality = 2, cost = 5, minRound = 2, classes = PALADIN, armorType = "plate", slot = "hands", stats = { armor = 12, ap = 22, crit = 3 } }
H.Armor{ id = 5411, key = "paladin_peacekeeper_boots", name = "Peacekeeper Boots", icon = I("inv_boots_plate_03"), quality = 3, cost = 7, minRound = 4, classes = PALADIN, armorType = "plate", slot = "feet", stats = { armor = 22, hp = 45, sp = 14, healing = 14 } }
H.Jewel{ id = 5412, key = "libram_of_divinity", name = "Libram of Divinity", icon = I("inv_relics_libramofhope"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = PALADIN, stats = { healing = 12 },
  triggers = { { on = "battleStart", effects = { { type = "buff", target = "all", match = { key = "flash_of_light" }, stat = "healPct", value = 12, duration = 90, key = "libram_of_divinity_healing", name = "Libram of Divinity" } } } } }
H.Jewel{ id = 5413, key = "libram_of_hope", name = "Libram of Hope", icon = I("inv_relics_libramofhope"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = PALADIN, stats = { regen = 2 },
  triggers = { { on = "anyUse", match = { key = "judgement" }, effects = { { type = "resource", resource = "mana", amount = 6 } } } } }
H.Jewel{ id = 5414, key = "libram_of_truth", name = "Libram of Truth", icon = I("inv_relics_libramoftruth"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = PALADIN, stats = { armor = 16 },
  triggers = { { on = "block", every = 3, effects = { { type = "cast", key = "judgement" } } } } }
H.Jewel{ id = 5415, key = "libram_of_grace", name = "Libram of Grace", icon = I("inv_relics_libramofgrace"), kind = "relic", quality = 4, cost = 10, minRound = 8, classes = PALADIN, stats = { healing = 24 },
  triggers = { { on = "anyUse", match = { key = "cleanse_paladin" }, effects = { { type = "heal", min = 12, max = 18, coef = 0.45 } } } } }
H.Jewel{ id = 5416, key = "libram_of_light", name = "Libram of Light", icon = I("inv_relics_libramofgrace"), kind = "relic", quality = 4, cost = 11, minRound = 10, classes = PALADIN, stats = { sp = 16 },
  triggers = { { on = "battleStart", effects = { { type = "buff", target = "all", match = { key = "flash_of_light" }, stat = "healPct", value = 20, duration = 90, key = "libram_of_light_healing", name = "Libram of Light" } } } } }
H.Jewel{ id = 5420, key = "paladin_pendant_of_the_fallen_dragon", name = "Pendant of the Fallen Dragon", icon = I("inv_jewelry_necklace_12"), kind = "neck", quality = 4, cost = 10, minRound = 8, classes = PALADIN, stats = { hp = 60, healing = 32, regen = 2 } }

local SHARED_GEAR = {
  { build = H.Weapon, ids = { PALADIN = 5403, SHAMAN = 7405 }, key = "%s_aurastone_hammer", name = "Aurastone Hammer", icon = "inv_hammer_05", quality = 4, cost = 11, minRound = 8, weaponType = "mace", weaponMin = 10, weaponMax = 16, speed = 2.5, stats = { healing = 42, regen = 3, sp = 16 } },
  { build = H.Weapon, ids = { PALADIN = 5404, SHAMAN = 7406 }, key = "%s_lokamir_il_romathis", name = "Lok'amir il Romathis", icon = "inv_mace_06", quality = 4, cost = 13, minRound = 11, weaponType = "mace", weaponMin = 12, weaponMax = 18, speed = 2.2, stats = { healing = 52, sp = 30, mana = 40 } },
  { build = ns.RegisterItem, ids = { PALADIN = 5405, SHAMAN = 7408 }, key = "%s_draconian_deflector", name = "Draconian Deflector", icon = "inv_shield_20", kind = "shield", quality = 3, cost = 8, minRound = 5, shape = S.sq, stats = { armor = 34, block = 18, blockChance = 32, hp = 45 } },
  { build = H.Armor, ids = { PALADIN = 5406, SHAMAN = 7409 }, key = "%s_copper_chain_vest", name = "Copper Chain Vest", icon = "inv_chest_chain", quality = 1, cost = 4, armorType = "mail", slot = "chest", stats = { armor = 18, hp = 35, sp = 6 } },
  { build = H.Armor, ids = { PALADIN = 5407, SHAMAN = 7410 }, key = "%s_green_iron_hauberk", name = "Green Iron Hauberk", icon = "inv_chest_chain", quality = 3, cost = 6, minRound = 3, armorType = "mail", slot = "chest", stats = { armor = 30, hp = 50, healing = 14 } },
  { build = H.Jewel, ids = { PALADIN = 5417, SHAMAN = 7419 }, key = "royal_seal_of_eldre_thalas_%s", name = "Royal Seal of Eldre'Thalas", icon = "inv_jewelry_talisman_10", kind = "trinket", quality = 3, cost = 7, minRound = 4, stats = { healing = 28, mana = 25, crit = 3 } },
  { build = H.Jewel, ids = { PALADIN = 5418, SHAMAN = 7422 }, key = "%s_shroud_of_pure_thought", name = "Shroud of Pure Thought", icon = "inv_misc_cape_16", kind = "cloak", quality = 4, cost = 10, minRound = 8, shape = S.h2, stats = { healing = 40, regen = 3, hp = 40 } },
  { build = H.Jewel, ids = { PALADIN = 5419, SHAMAN = 7421 }, key = "%s_ring_of_spell_power", name = "Ring of Spell Power", icon = "inv_jewelry_ring_38", kind = "ring", quality = 4, cost = 10, minRound = 8, stats = { sp = 38, mana = 30, crit = 3 } },
  { build = H.Jewel, ids = { PALADIN = 5421, SHAMAN = 7423 }, key = "%s_emberfury_talisman", name = "Emberfury Talisman", icon = "inv_jewelry_necklace_05", quality = 3, cost = 7, minRound = 4, kind = "neck", stats = { ap = 28, crit = 5, hp = 20 } },
  { build = H.Jewel, ids = { PALADIN = 5422, SHAMAN = 7424 }, key = "%s_star_of_mystaria", name = "Star of Mystaria", icon = "inv_jewelry_talisman_08", quality = 3, cost = 7, minRound = 4, kind = "neck", stats = { sp = 24, mana = 25, crit = 3 } },
  { build = H.Jewel, ids = { PALADIN = 5423, SHAMAN = 7425 }, key = "%s_animated_chain_necklace", name = "Animated Chain Necklace", icon = "inv_jewelry_necklace_01", quality = 3, cost = 7, minRound = 4, kind = "neck", stats = { healing = 36, hp = 35 } },
  { build = H.Jewel, ids = { PALADIN = 5424, SHAMAN = 7426 }, key = "%s_painweaver_band", name = "Painweaver Band", icon = "inv_jewelry_ring_18", quality = 3, cost = 7, minRound = 4, kind = "ring", stats = { ap = 26, crit = 5, hp = 25 } },
  { build = H.Jewel, ids = { PALADIN = 5425, SHAMAN = 7427 }, key = "%s_rosewine_circle", name = "Rosewine Circle", icon = "inv_jewelry_ring_22", quality = 3, cost = 7, minRound = 5, kind = "ring", stats = { healing = 30, regen = 2, mana = 20 } },
  { build = H.Jewel, ids = { PALADIN = 5426, SHAMAN = 7428 }, key = "%s_linen_cloak", name = "Linen Cloak", icon = "inv_misc_cape_14", quality = 1, cost = 3, minRound = 1, kind = "cloak", shape = S.h2, stats = { hp = 15, sp = 6, healing = 6 } },
  { build = H.Jewel, ids = { PALADIN = 5427, SHAMAN = 7429 }, key = "%s_dark_leather_cloak", name = "Dark Leather Cloak", icon = "inv_misc_cape_10", quality = 2, cost = 4, minRound = 2, kind = "cloak", shape = S.h2, stats = { ap = 14, crit = 3, hp = 20 } },
  { build = H.Armor, ids = { PALADIN = 5428, SHAMAN = 7430 }, key = "%s_green_iron_leggings", name = "Green Iron Leggings", icon = "inv_pants_05", quality = 2, cost = 6, minRound = 2, armorType = "mail", slot = "legs", stats = { ap = 24, armor = 18, hp = 25 } },
  { build = H.Armor, ids = { PALADIN = 5429, SHAMAN = 7431 }, key = "%s_azure_silk_pants", name = "Azure Silk Pants", icon = "inv_pants_08", quality = 2, cost = 6, minRound = 2, armorType = "cloth", slot = "legs", stats = { sp = 20, healing = 14, mana = 20, hp = 25 } },
  { build = H.Armor, ids = { PALADIN = 5430, SHAMAN = 7432 }, key = "%s_bright_belt", name = "Bright Belt", icon = "inv_belt_11", quality = 2, cost = 4, minRound = 2, armorType = "cloth", slot = "waist", stats = { healing = 16, sp = 6, mana = 20, hp = 15 } },
  { build = H.Jewel, ids = { PALADIN = 5431, SHAMAN = 7433 }, key = "%s_silver_thread_cloak", name = "Silver-thread Cloak", icon = "inv_misc_cape_02", kind = "cloak", quality = 2, cost = 4, minRound = 2, shape = S.h2, stats = { sp = 16, healing = 10, hp = 20 } },
}
for _, class in ipairs({ "PALADIN", "SHAMAN" }) do
  for _, entry in ipairs(SHARED_GEAR) do
    local def = ns.Util.DeepCopy(entry)
    def.build, def.ids = nil, nil
    def.id, def.key, def.icon, def.classes = entry.ids[class], entry.key:format(class:lower()), I(entry.icon), { class }
    entry.build(def)
  end
end

ns.RegisterSet{ key = "lightforge", name = "Lightforge Armor", bonuses = {
  [2] = { stats = { ap = 20, armor = 12 } },
  [4] = { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 3, effects = { { type = "buff", stat = "sp", value = 28, duration = 6, key = "lightforge_power", name = "Lightforge Armor" } } } }, text = "Every third melee weapon hit grants 28 Spell Power for 6s." },
} }
ns.RegisterSet{ key = "lawbringer", name = "Lawbringer Armor", bonuses = {
  [2] = { stats = { blockChance = 10, block = 8 } },
  [4] = { triggers = { { on = "block", effects = { { type = "absorb", fromEvent = 0.4 }, { type = "cdr", target = "all", match = { key = "holy_shield" }, amount = 0.5 } } } }, text = "Blocks shield you for 40% of the damage blocked and advance Holy Shield by 0.5s." },
  [6] = { triggers = { { on = "block", effects = { { type = "cast", key = "judgement" }, { type = "heal", fromEvent = 0.5 } } } }, stats = { block = 20 }, text = "Blocking casts Judgement for free and heals 50% of the damage blocked." },
} }
ns.RegisterSet{ key = "judgement_armor", name = "Judgement Armor", bonuses = {
  [2] = { triggers = { { on = "anyUse", match = { key = "judgement" }, effects = { { type = "extraAttack", count = 1 } } } }, text = "Judgement grants an extra melee attack." },
  [4] = { triggers = { { on = "anyCrit", healing = false, match = { tag = "holy" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.6 } } } }, text = "Holy crits store 60% of their damage for Judgement." },
  [6] = { double = { tag = "judgement" }, stats = { crit = 15, critDamage = 50 }, text = "Judgement hits twice." },
} }
ns.RegisterSet{ key = "redemption", name = "Redemption Armor", bonuses = {
  [2] = { triggers = { { on = "healed", effects = { { type = "bank", key = "paladin_holy", fraction = 0.1 } } } }, text = "Store 10% of effective healing for Holy Shock." },
  [4] = { triggers = { { on = "anyCrit", healing = true, effects = { { type = "cdr", target = "all", match = { key = "holy_shock" }, amount = 2 }, { type = "resource", resource = "mana", amount = 10 } } } }, text = "Healing crits advance Holy Shock by 2s and restore 10 Mana." },
  [6] = { flags = { "revive" }, triggers = { { on = "anyUse", match = { key = "holy_shock" }, effects = { { type = "cast", key = "holy_light" } } } }, text = "Holy Shock casts Holy Light for free. Once per battle, return to full health instead of dying." },
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
