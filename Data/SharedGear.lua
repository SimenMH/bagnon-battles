local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local CASTERS = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }
local HEALERS = { "PALADIN", "PRIEST", "SHAMAN", "DRUID" }
local STAFF_USERS = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }
local PHYSICAL_DAGGERS = { "WARRIOR", "HUNTER", "DRUID", "ROGUE", "SHAMAN" }
local MAIL_USERS = { "WARRIOR", "PALADIN", "HUNTER", "SHAMAN" }







local function legacyStockCopy(fields)
  local def = ns.Util.DeepCopy(assert(ns.ItemsByKey[fields.stockKey]))
  for key, value in pairs(fields) do if key ~= "omit" then def[key] = value end end
  for _, key in ipairs(fields.omit or {}) do def[key] = nil end
  return ns.RegisterItem(def)
end

H.Weapon{
  id = 105, key = "battle_axe", name = "Battle Axe", icon = I("inv_throwingaxe_05"), quality = 2, minRound = 2, classes = H.ALL_AXE,
  weaponType = "axe", hands = 2, weaponMin = 13, weaponMax = 19, speed = 3.4,
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", school = "physical", weapon = true, weaponPct = 0.5 } } } },
}

H.Weapon{
  id = 106, key = "claymore", name = "Claymore", icon = I("inv_sword_40"), quality = 2, minRound = 2, classes = H.ALL_SWORD, weaponType = "sword",
  hands = 2, weaponMin = 12, weaponMax = 19, speed = 3.2,
  triggers = { { on = "crit", effects = { { type = "dot", key = "claymore_cut", coef = 0.04, tick = 2, school = "physical", duration = 6 } } } },
}

H.Weapon{
  id = 107, key = "war_hammer", name = "War Hammer", icon = I("inv_hammer_03"), quality = 2, minRound = 2, classes = H.ALL_MACE, weaponType = "mace",
  hands = 2, weaponMin = 13, weaponMax = 20, speed = 3.6,
  triggers = { { on = "hit", chance = 15, icd = 4, effects = { { type = "stun", duration = 0.5 } } } },
}

H.Weapon{
  id = 108, key = "cruel_barb", name = "Cruel Barb", icon = I("inv_sword_24"), quality = 2, minRound = 3, classes = H.ALL_SWORD, tags = { "poison" },
  weaponType = "sword", weaponMin = 5, weaponMax = 8, speed = 1.8, stats = { ap = 10 },
  triggers = { { on = "hit", effects = { { type = "dot", key = "barb_poison", tick = 1, school = "nature", duration = 6, maxStacks = 5, stack = true } } } },
}

H.Weapon{
  id = 109, key = "staff_of_jordan", name = "Staff of Jordan", icon = I("INV_Staff_13"), quality = 2, minRound = 3,
  classes = { "DRUID", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, weaponType = "staff", hands = 2, weaponMin = 10, weaponMax = 16, speed = 3,
  stats = { healing = 12, sp = 12 },
  triggers = { { on = "anyUse", match = { tag = "spell" }, chance = 20, effects = { { type = "resource", resource = "mana", amount = 8 } } } },
}

H.Weapon{
  id = 110, key = "shadowfang", name = "Shadowfang", icon = I("inv_sword_13"), quality = 3, minRound = 4, classes = H.ALL_SWORD, weaponType = "sword",
  weaponMin = 6, weaponMax = 11, speed = 2,
  triggers = { { on = "hit", chance = 20, effects = { { type = "dot", key = "shadowfang", tick = 3, school = "shadow", duration = 5 } } } },
}

H.Weapon{
  id = 111, key = "ironfoe", name = "Ironfoe", icon = I("spell_frost_frostbrand"), quality = 3, minRound = 5, classes = H.ALL_MACE,
  weaponType = "mace", weaponMin = 7, weaponMax = 13, speed = 2.4,
  triggers = { { on = "hit", chance = 12, effects = { { type = "extraAttack", count = 2 } } } },
}

H.Weapon{
  id = 112, key = "ravager", name = "Ravager", icon = I("inv_weapon_halberd_05"), quality = 3, minRound = 6, classes = H.ALL_AXE, weaponType = "axe",
  hands = 2, weaponMin = 16, weaponMax = 25, speed = 3.5,
  triggers = { { on = "hit", chance = 10, effects = { { type = "buff", key = "ravager_whirl", name = "Bladestorm", stat = "haste", value = 60, duration = 4 } } } },
}

H.Weapon{
  id = 113, key = "bonebiter", name = "Bonebiter", icon = I("inv_axe_04"), quality = 3, minRound = 6, classes = H.ALL_AXE, weaponType = "axe",
  hands = 2, weaponMin = 18, weaponMax = 28, speed = 3.4, stats = { ap = 18 },
}

H.Weapon{
  id = 114, key = "nightblade", name = "Nightblade", icon = I("inv_sword_02"), quality = 3, minRound = 5, classes = H.ALL_SWORD, weaponType = "sword",
  weaponMin = 7, weaponMax = 12, speed = 2.1,
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", coef = 0.1, min = 6, max = 9, school = "shadow", noDodge = true } } } },
}

H.Weapon{
  id = 115, key = "smites_mighty_hammer", name = "Smite's Mighty Hammer", icon = I("inv_hammer_09"), quality = 3, minRound = 4, classes = H.ALL_MACE,
  weaponType = "mace", hands = 2, weaponMin = 14, weaponMax = 22, speed = 3.6, stats = { hp = 8 },
}

H.Weapon{
  id = 116, key = "dalrends_sacred_charge", name = "Dal'Rend's Sacred Charge", icon = I("INV_Sword_43"), quality = 3, minRound = 5,
  classes = H.ALL_SWORD, weaponType = "sword", weaponMin = 10, weaponMax = 17, speed = 2.3, set = "dalrend", stats = { ap = 16, crit = 1 },
}

H.Weapon{
  id = 117, key = "obsidian_edged_blade", name = "Obsidian Edged Blade", icon = I("inv_sword_28"), quality = 4, minRound = 11, classes = H.ALL_SWORD,
  weaponType = "sword", hands = 2, weaponMin = 26, weaponMax = 38, speed = 3.4, stats = { ap = 28 },
}

H.Weapon{
  id = 118, key = "hand_of_edward_the_odd", name = "Hand of Edward the Odd", icon = I("inv_mace_14"), quality = 4, minRound = 9,
  classes = { "DRUID", "PALADIN", "PRIEST", "SHAMAN" }, weaponType = "mace", weaponMin = 8, weaponMax = 15, speed = 2.5,
  stats = { healing = 18, sp = 18 },
  triggers = { { on = "hit", chance = 15, effects = { { type = "cdr", target = "all", match = { tag = "spell" }, amount = 1.5 } } } },
}

H.Weapon{
  id = 119, key = "staff_of_dominance", name = "Staff of Dominance", icon = I("inv_staff_13"), quality = 4, minRound = 10,
  classes = { "DRUID", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, weaponType = "staff", hands = 2, weaponMin = 14, weaponMax = 22, speed = 3,
  stats = { crit = 3, sp = 32 },
}

H.Weapon{
  id = 120, key = "staff_of_the_shadow_flame", name = "Staff of the Shadow Flame", icon = I("inv_staff_06"), quality = 4, minRound = 12,
  classes = { "DRUID", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, weaponType = "staff", hands = 2, weaponMin = 16, weaponMax = 24, speed = 2.9,
  stats = { crit = 5, sp = 48 },
}

H.Weapon{
  id = 121, key = "blackblade_of_shahram", name = "Blackblade of Shahram", icon = I("inv_sword_29"), quality = 4, minRound = 10, classes = H.ALL_SWORD,
  weaponType = "sword", hands = 2, weaponMin = 22, weaponMax = 34, speed = 3.3,
  triggers = { { on = "hit", chance = 12, effects = { { type = "buff", key = "shahram", name = "Curse of Shahram", stat = "ap", value = 15, duration = 10 } } } },
}

H.Weapon{
  id = 122, key = "perditions_blade", name = "Perdition's Blade", icon = I("inv_sword_48"), quality = 4, minRound = 11, classes = H.ALL_DAGGER,
  weaponType = "dagger", weaponMin = 7, weaponMax = 13, speed = 1.8,
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", min = 8, max = 12, school = "fire", noDodge = true } } } },
}

ns.RegisterItem{
  id = 130, key = "wooden_shield", name = "Wooden Shield", icon = I("INV_Shield_09"), quality = 1, kind = "shield", classes = H.ALL_SHIELD,
  shape = S.sq, tags = { "shield", "defensive" }, stats = { armor = 12, block = 6, blockChance = 25 },
}

ns.RegisterItem{
  id = 132, key = "crest_of_retribution", name = "Crest of Retribution", icon = I("inv_shield_19"), quality = 3, minRound = 6, kind = "shield",
  classes = H.ALL_SHIELD, shape = S.sq, tags = { "shield", "defensive" }, stats = { armor = 26, block = 14, blockChance = 30, hp = 20, thorns = 2 },
}

ns.RegisterItem{
  id = 133, key = "drillborer_disk", name = "Drillborer Disk", icon = I("inv_shield_10"), quality = 4, minRound = 10, kind = "shield",
  classes = H.ALL_SHIELD, shape = S.sq, tags = { "shield", "defensive" }, stats = { armor = 36, block = 20, blockChance = 35, hp = 25, thorns = 4 },
}

ns.RegisterItem{
  id = 134, key = "elementium_reinforced_bulwark", name = "Elementium Reinforced Bulwark", icon = I("inv_shield_17"), quality = 4, minRound = 13,
  kind = "shield", classes = H.ALL_SHIELD, shape = S.sq, tags = { "shield", "defensive" },
  stats = { armor = 46, block = 26, blockChance = 40, hp = 40 },
}

H.Jewel{
  id = 250, key = "mark_of_the_chosen", name = "Mark of the Chosen", icon = I("inv_jewelry_talisman_08"), quality = 3, minRound = 4, kind = "trinket",
  triggers = {
    {
      on = "damaged", chance = 10, icd = 5,
      effects = {
        { type = "buff", key = "mark_chosen", name = "Mark of the Chosen", stat = "ap", value = 60, duration = 6 },
        { type = "buff", key = "mark_chosen_spell", name = "Mark of the Chosen", stat = "sp", value = 24, duration = 6 },
        { type = "buff", key = "mark_chosen_armor", name = "Mark of the Chosen", stat = "armor", value = 20, duration = 6 },
      },
    },
  },
}

H.Jewel{
  id = 252, key = "hand_of_justice", name = "Hand of Justice", icon = I("INV_Jewelry_Talisman_01"), quality = 3, minRound = 5, kind = "trinket",
  stats = { ap = 6 },
  triggers = { { on = "resourceSpent", everyAmount = 30, effects = { { type = "cdr", target = "neighbors", match = { tag = "autoattack" }, amount = 1 } } } },
}

H.Jewel{
  id = 254, key = "talisman_of_ephemeral_power", name = "Talisman of Ephemeral Power", icon = I("inv_misc_stonetablet_11"), quality = 4, minRound = 9,
  kind = "trinket", classes = { "DRUID", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, tags = { "spell" },
  use = { cd = 25, initialPct = 0.1, effects = { { type = "buff", key = "ephemeral", name = "Ephemeral Power", stat = "sp", value = 60, duration = 12 } } },
}

H.Jewel{
  id = 255, key = "earthstrike", name = "Earthstrike", icon = I("spell_nature_abolishmagic"), quality = 4, minRound = 10, kind = "trinket",
  tags = { "melee" },
  use = { cd = 25, initialPct = 0.1, effects = { { type = "buff", key = "earthstrike", name = "Earthstrike", stat = "ap", value = 60, duration = 12 } } },
  shopClasses = H.PHYSICAL,
}

H.Jewel{
  id = 257, key = "second_wind", name = "Second Wind", icon = I("inv_jewelry_talisman_06"), quality = 3, minRound = 6, kind = "trinket",
  tags = { "heal" }, use = { cd = 15, reactive = true, condition = "below50", effects = { { type = "heal", pctMax = 0.15 } } },
}

H.Jewel{
  id = 258, key = "darkmoon_card_heroism", name = "Darkmoon Card: Heroism", icon = I("inv_misc_ticket_tarot_heroism_01"), quality = 4, minRound = 11,
  kind = "trinket", stats = { hp = 10 },
  triggers = { { on = "adjacentHit", match = { tag = "autoattack" }, chance = 25, icd = 2, effects = { { type = "heal", min = 6, max = 8 } } } },
}

H.Jewel{
  id = 259, key = "diamond_flask", name = "Diamond Flask", icon = I("INV_Drink_01"), quality = 3, minRound = 3, kind = "trinket",
  classes = { "WARRIOR" }, tags = { "heal", "melee" },
  triggers = {
    { on = "healed", effects = { { type = "bank", key = "flask", fraction = 0.25 } } },
    { on = "regularHit", match = { tag = "melee" }, effects = { { type = "damage", school = "physical", noCrit = true, noDodge = true, spendBank = "flask" } }, detail = true },
  },
  unique = true,
}

H.Weapon{
  id = 350, key = "worn_dagger", name = "Worn Dagger", icon = I("inv_weapon_shortblade_05"), quality = 1, classes = H.ALL_DAGGER,
  weaponType = "dagger", weaponMin = 3, weaponMax = 5, speed = 1.7, stats = { ap = 4 },
}

H.Weapon{
  id = 351, key = "walking_stick", name = "Walking Stick", icon = I("inv_staff_08"), quality = 1, cost = 4,
  classes = { "DRUID", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, weaponType = "staff", hands = 2, weaponMin = 6, weaponMax = 9, speed = 3.2,
  stats = { healing = 6, sp = 8 },
}

H.Weapon{
  id = 352, key = "hunting_bow", name = "Hunting Bow", icon = I("inv_weapon_bow_03"), quality = 1, classes = { "HUNTER" }, weaponType = "bow",
  weaponMin = 14, weaponMax = 17, speed = 2.6, stats = { ap = 6 },
}

H.Armor{
  id = 353, key = "tanned_leather_jerkin", name = "Tanned Leather Jerkin", icon = I("inv_chest_wolf"), quality = 1, cost = 4,
  classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, armorType = "leather", slot = "chest",
  stats = { ap = 10, armor = 12, hp = 15 },
}

H.Armor{
  id = 354, key = "thin_cloth_armor", name = "Thin Cloth Armor", icon = I("inv_shirt_red_01"), quality = 1, cost = 3,
  classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, armorType = "cloth", slot = "chest",
  stats = { armor = 18, hp = 60 },
}

H.Armor{
  id = 355, key = "simple_robe", name = "Simple Robe", icon = I("inv_chest_cloth_18"), quality = 1, cost = 4,
  classes = { "DRUID", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, armorType = "cloth", slot = "chest",
  stats = { healing = 6, hp = 15, sp = 10 },
}

H.Weapon{
  id = 356, key = "arcanite_reaper", name = "Arcanite Reaper", icon = I("inv_axe_09"), quality = 3, cost = 10, minRound = 6, classes = H.ALL_AXE,
  weaponType = "axe", hands = 2, weaponMin = 23, weaponMax = 33, speed = 3.8, stats = { ap = 30, hp = 35 },
}

H.Weapon{
  id = 357, key = "zinrokh_destroyer_of_worlds", name = "Zin'rokh, Destroyer of Worlds", icon = I("inv_sword_55"), quality = 4, cost = 14,
  minRound = 11, classes = H.ALL_SWORD, weaponType = "sword", hands = 2, weaponMin = 34, weaponMax = 48, speed = 3.8, stats = { ap = 50, hp = 80 },
}

H.Armor{
  id = 358, key = "edgemasters_handguards", name = "Edgemaster's Handguards", icon = I("inv_gauntlets_30"), quality = 4, minRound = 7,
  classes = H.ALL_AXE, armorType = "mail", slot = "hands", stats = { ap = 40, armor = 12, haste = 12 },
}

H.Jewel{
  id = 359, key = "lifegiving_gem", name = "Lifegiving Gem", icon = I("inv_misc_gem_pearl_05"), quality = 4, minRound = 8, kind = "trinket",
  classes = { "WARRIOR" }, tags = { "heal" }, stats = { hp = 80 },
  use = { cd = 25, reactive = true, condition = "below35", effects = { { type = "heal", pctMax = 0.3 } } },
}

ns.RegisterItem{
  id = 360, key = "skullflame_shield", name = "Skullflame Shield", icon = I("inv_shield_01"), quality = 4, minRound = 9, kind = "shield",
  classes = H.ALL_SHIELD, shape = S.sq, tags = { "shield", "heal" }, stats = { armor = 32, block = 18, blockChance = 35, hp = 30 },
  triggers = { { on = "block", effects = { { type = "heal", min = 6, max = 9 }, { type = "damage", min = 4, max = 6, school = "fire", noDodge = true } } } },
}

H.Jewel{
  id = 361, key = "briarwood_reed", name = "Briarwood Reed", icon = I("inv_misc_root_02"), quality = 3, cost = 9, minRound = 6, kind = "trinket",
  classes = { "DRUID", "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, stats = { hp = 20, sp = 24 },
}

H.Jewel{
  id = 370, key = "mark_of_fordring", name = "Mark of Fordring", icon = I("inv_jewelry_talisman_07"), quality = 3, minRound = 4, kind = "neck",
  classes = H.PHYSICAL, stats = { ap = 28, crit = 5 },
}

H.Jewel{
  id = 371, key = "medallion_of_grand_marshal_morris", name = "Medallion of Grand Marshal Morris", icon = I("inv_jewelry_talisman_08"), quality = 3,
  minRound = 4, kind = "neck", classes = H.PHYSICAL, stats = { armor = 12, dodge = 3, hp = 75 },
}

H.Jewel{
  id = 372, key = "onyxia_tooth_pendant", name = "Onyxia Tooth Pendant", icon = I("inv_jewelry_necklace_09"), quality = 4, cost = 11, minRound = 9,
  kind = "neck", classes = H.PHYSICAL, stats = { ap = 48, crit = 7, hp = 30 },
}

H.Jewel{
  id = 373, key = "cape_of_the_brotherhood", name = "Cape of the Brotherhood", icon = I("inv_misc_cape_08"), quality = 3, cost = 5, minRound = 2,
  kind = "cloak", classes = H.PHYSICAL, shape = S.h2, stats = { ap = 14, armor = 6, crit = 3, hp = 20 },
}

H.Jewel{
  id = 374, key = "spritecaster_cape", name = "Spritecaster Cape", icon = I("inv_misc_cape_20"), quality = 3, minRound = 5, kind = "cloak",
  classes = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, shape = S.h2, stats = { crit = 3, healing = 12, sp = 20 },
  shopClassWeights = { MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" },
}

H.Jewel{
  id = 375, key = "hide_of_the_wild", name = "Hide of the Wild", icon = I("inv_misc_cape_01"), quality = 4, cost = 11, minRound = 8, kind = "cloak",
  classes = HEALERS, shape = S.h2, stats = { dr = 4, healing = 44, hp = 60 }, shopClassWeights = { PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = HEALERS,
}

H.Jewel{
  id = 376, key = "seal_of_wrynn", name = "Seal of Wrynn", icon = I("inv_jewelry_ring_05"), quality = 3, cost = 6, minRound = 2, kind = "ring",
  stats = { ap = 6, crit = 1, healing = 6, hp = 20, mana = 10, sp = 6 },
}

H.Jewel{
  id = 377, key = "blackstone_ring", name = "Blackstone Ring", icon = I("inv_jewelry_ring_17"), quality = 3, minRound = 4, kind = "ring",
  classes = H.PHYSICAL, stats = { ap = 24, crit = 5, hp = 20 },
}

H.Jewel{
  id = 378, key = "songstone_of_ironforge", name = "Songstone of Ironforge", icon = I("inv_jewelry_ring_05"), quality = 3, minRound = 4, kind = "ring",
  classes = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, stats = { healing = 16, mana = 20, sp = 22 },
  shopClassWeights = { MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" },
}

H.Jewel{
  id = 379, key = "ring_of_fury", name = "Ring of Fury", icon = I("inv_jewelry_ring_ahnqiraj_04"), quality = 3, cost = 6, minRound = 2, kind = "ring",
  classes = { "WARRIOR" }, tags = { "heal" }, stats = { ap = 12, hp = 40 },
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "heal", pctMax = 0.015 } } } },
}

H.Weapon{
  id = 380, key = "spiked_club", name = "Spiked Club", icon = I("inv_mace_14"), quality = 1, cost = 4, classes = H.ALL_MACE, weaponType = "mace",
  hands = 2, weaponMin = 6, weaponMax = 9, speed = 3.2, stats = { ap = 8, hp = 10 },
}

H.Weapon{
  id = 381, key = "oak_mallet", name = "Oak Mallet", icon = I("inv_hammer_15"), quality = 2, cost = 6, minRound = 2, classes = H.ALL_MACE,
  weaponType = "mace", hands = 2, weaponMin = 10, weaponMax = 14, speed = 3.5, stats = { ap = 12, armor = 18, hp = 15 },
}

H.Weapon{
  id = 382, key = "carving_knife", name = "Carving Knife", icon = I("inv_weapon_shortblade_01"), quality = 2, minRound = 2, classes = H.ALL_DAGGER,
  weaponType = "dagger", weaponMin = 4, weaponMax = 6, speed = 1.8, stats = { ap = 14, crit = 3 },
}

H.Armor{
  id = 383, key = "fine_leather_gloves", name = "Fine Leather Gloves", icon = I("inv_gauntlets_05"), quality = 1, classes = { "DRUID", "HUNTER" },
  armorType = "leather", slot = "hands", stats = { armor = 4, healing = 8, mana = 15 },
}

H.Armor{
  id = 384, key = "prospectors_cuffs", name = "Prospector's Cuffs", icon = I("inv_bracer_07"), quality = 2, cost = 4, minRound = 2,
  classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, armorType = "leather", slot = "wrist",
  stats = { ap = 10, armor = 4, crit = 2, hp = 8 },
}

H.Armor{
  id = 385, key = "fine_leather_boots", name = "Fine Leather Boots", icon = I("inv_boots_06"), quality = 1,
  classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, armorType = "leather", slot = "feet", stats = { armor = 10, hp = 15 },
}

H.Armor{
  id = 386, key = "fine_leather_belt", name = "Fine Leather Belt", icon = I("inv_belt_04"), quality = 2, cost = 4, minRound = 2,
  classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, armorType = "leather", slot = "waist",
  stats = { ap = 8, armor = 4, hp = 10 },
}

H.Weapon{
  id = 400, key = "hand_axe", name = "Hand Axe", icon = I("inv_axe_11"), quality = 1, classes = H.ALL_AXE, shape = S.L, weaponType = "axe",
  weaponMin = 5, weaponMax = 8, speed = 2.5, stats = { ap = 4 }, shopWeight = 1.8,
}

H.Weapon{
  id = 401, key = "twin_tomahawk", name = "Twin Tomahawk", icon = I("inv_throwingaxe_03"), quality = 2, minRound = 2, classes = H.ALL_AXE, shape = S.L,
  weaponType = "axe", weaponMin = 5, weaponMax = 8, speed = 1.8, stats = { ap = 8, crit = 3 },
  shopAffinities = { WARRIOR = { arms = 0.5, fury = 1.5, prot = 0.75 } }, shopWeight = 1.2,
}

H.Weapon{
  id = 402, key = "crescent_axe", name = "Crescent Axe", icon = I("inv_axe_03"), quality = 3, cost = 8, minRound = 4, classes = H.ALL_AXE, shape = S.L,
  weaponType = "axe", weaponMin = 11, weaponMax = 17, speed = 2.6, stats = { ap = 20, hp = 15 },
}

H.Weapon{
  id = 403, key = "deathbringer", name = "Deathbringer", icon = I("inv_axe_15"), quality = 4, cost = 12, minRound = 8, classes = H.ALL_AXE,
  shape = S.L, weaponType = "axe", weaponMin = 17, weaponMax = 25, speed = 2.9, stats = { ap = 28, crit = 4 }, shopWeight = 0.6,
}

H.Weapon{
  id = 404, key = "ironwood_mace", name = "Ironwood Mace", icon = I("inv_mace_01"), quality = 1, classes = H.ALL_MACE, weaponType = "mace",
  weaponMin = 5, weaponMax = 7, speed = 2.6, stats = { ap = 4, armor = 6 }, shopWeight = 1.8,
}

H.Weapon{
  id = 405, key = "skullcrusher", name = "Skullcrusher", icon = I("inv_mace_04"), quality = 2, minRound = 2, classes = H.ALL_MACE, shape = S.L,
  weaponType = "mace", weaponMin = 7, weaponMax = 11, speed = 2.5, stats = { ap = 10, armor = 10 }, shopWeight = 1.2,
}

H.Weapon{
  id = 406, key = "castigator", name = "Castigator", icon = I("inv_mace_26"), quality = 4, cost = 12, minRound = 8, classes = H.ALL_MACE, shape = S.T,
  weaponType = "mace", weaponMin = 16, weaponMax = 23, speed = 2.6, stats = { ap = 28, armor = 15 }, shopWeight = 0.6,
}

H.Armor{
  id = 407, key = "bulwark_gauntlets", name = "Bulwark Gauntlets", icon = I("inv_gauntlets_29"), quality = 2, minRound = 2, classes = H.PLATE,
  armorType = "plate", slot = "hands", stats = { armor = 12, block = 6, hp = 25 },
  shopAffinities = { PALADIN = { holy = 0.5, protection = 1.5, retribution = 0.5 }, WARRIOR = { arms = 0.5, fury = 0.5, prot = 1.5 } },
  shopWeight = 1.2,
}

H.Armor{
  id = 408, key = "fleetfoot_boots", name = "Fleetfoot Boots", icon = I("inv_boots_05"), quality = 2, minRound = 3, classes = H.PHYSICAL,
  armorType = "leather", slot = "feet", stats = { ap = 14, armor = 6, haste = 4, hp = 10 },
}

H.Jewel{
  id = 409, key = "tempered_band", name = "Tempered Band", icon = I("inv_jewelry_ring_03"), quality = 2, minRound = 2, kind = "ring",
  classes = H.PHYSICAL, stats = { ap = 12, hp = 15 }, shopWeight = 1.2,
}

H.Jewel{
  id = 410, key = "bloodguard_emblem", name = "Bloodguard Emblem", icon = I("inv_jewelry_talisman_01"), quality = 3, cost = 8, minRound = 5,
  kind = "trinket", classes = H.PHYSICAL, stats = { ap = 8, hp = 30 },
  use = {
    cd = 30, initialDelay = 0, reactive = true, once = true, condition = "below35",
    effects = {
      { type = "buff", key = "bloodguard_emblem_haste", name = "Bloodguard Emblem", stat = "haste", value = 18, duration = 8 },
      { type = "buff", key = "bloodguard_emblem_lifesteal", name = "Bloodguard Emblem", stat = "lifesteal", value = 6, duration = 8 },
    },
  },
  shopWeight = 0.5,
}

ns.RegisterItem{
  id = 411, key = "duelists_buckler", name = "Duelist's Buckler", icon = I("inv_shield_04"), quality = 2, cost = 5, minRound = 3, kind = "shield",
  classes = H.ALL_SHIELD, shape = S.T, tags = { "shield", "defensive" }, stats = { ap = 8, armor = 14, block = 6, blockChance = 25, dodge = 5 },
  shopWeight = 0.8,
}

ns.RegisterItem{
  id = 412, key = "dense_sharpening_stone", name = "Dense Sharpening Stone", icon = I("inv_stone_sharpeningstone_05"), quality = 2, cost = 4,
  minRound = 2, kind = "consumable", classes = H.PHYSICAL, shape = S.one,
  adjacency = { { once = true, match = { kind = "weapon", anyWeaponType = { "axe", "sword", "dagger" }, tag = "melee" }, mods = { flat = 4 }, side = "front" } },
  shopAffinities = {
    DRUID = { balance = 0.15, feral = 0.35, resto = 0.15 }, HUNTER = { bm = 0.25, mm = 0.25, surv = 1 },
    PALADIN = { holy = 0.25, protection = 0.75, retribution = 1 }, ROGUE = { assassination = 0.8, combat = 1, subtlety = 0.8 },
    SHAMAN = { elemental = 0.2, enhancement = 1, restoration = 0.2 }, WARRIOR = { arms = 1, fury = 1, prot = 0.8 },
  },
  shopClassWeights = { DRUID = 0.4, HUNTER = 0.65 }, shopWeight = 0.9,
}

H.Jewel{
  id = 413, key = "styleens_impeding_scarab", name = "Styleen's Impeding Scarab", icon = I("inv_misc_ahnqirajtrinket_01"), quality = 3, minRound = 5,
  kind = "trinket", classes = H.ALL_SHIELD, shape = S.L,
  adjacency = { { stats = { block = 8, blockChance = 5 }, once = true, match = { kind = "shield" }, corners = true } },
  shopAffinities = { PALADIN = { holy = 0.25, protection = 1, retribution = 0.25 }, SHAMAN = { elemental = 0.35, enhancement = 0.8, restoration = 0.35 }, WARRIOR = { arms = 0.3, fury = 0.2, prot = 1 } },
  shopWeight = 0.65,
}

ns.RegisterItem{
  id = 414, key = "dark_rune", name = "Dark Rune", icon = I("spell_shadow_sealofkings"), quality = 3, minRound = 5, kind = "consumable",
  classes = { "DRUID", "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }, shape = S.one,
  use = { cd = 18, initialDelay = 4, condition = "lowMana", effects = { { type = "resource", resource = "mana", amount = 35 } }, healthCostPct = 0.05 },
  adjacency = { { once = true, empty = true, selfMods = { haste = 25 }, side = "back" } },
  shopAffinities = {
    DRUID = { balance = 1, feral = 0.35, resto = 1 }, HUNTER = { bm = 0.35, mm = 1, surv = 0.75 }, MAGE = { arcane = 1, fire = 1, frost = 1 },
    PALADIN = { holy = 1, protection = 1, retribution = 0.75 }, PRIEST = { discipline = 1, holy = 1, shadow = 1 },
    SHAMAN = { elemental = 1, enhancement = 0.5, restoration = 1 }, WARLOCK = { affliction = 0.75, demonology = 0.5, destruction = 1 },
  },
  shopClassWeights = { HUNTER = 0.65, WARLOCK = 0.8 }, shopWeight = 0.5,
}


H.Weapon{
  id = 420, key = "bloody_brass_knuckles", name = "Bloody Brass Knuckles", icon = I("INV_Gauntlets_04"), quality = 1, cost = 4,
  classes = PHYSICAL_DAGGERS, shape = S.h2, weaponType = "fist", weaponMin = 4, weaponMax = 7, speed = 1.6, stats = { ap = 4 }, shopWeight = 0.8,
}

H.Weapon{
  id = 421, key = "iron_knuckles", name = "Iron Knuckles", icon = I("INV_Gauntlets_04"), quality = 3, cost = 8, minRound = 4,
  classes = PHYSICAL_DAGGERS, shape = S.L, weaponType = "fist", weaponMin = 8, weaponMax = 12, speed = 1.7, stats = { ap = 12 },
  triggers = { { on = "hit", chance = 10, icd = 5, effects = { { type = "stun", duration = 0.5 } } } }, shopWeight = 0.65,
}

H.Weapon{
  id = 422, key = "claw_of_the_black_drake", name = "Claw of the Black Drake", icon = I("INV_Weapon_ShortBlade_27"), quality = 4, cost = 12,
  minRound = 9, classes = PHYSICAL_DAGGERS, shape = { "11", "10" }, weaponType = "fist", weaponMin = 18, weaponMax = 27, speed = 2.6,
  stats = { ap = 44, crit = 7, hp = 35 }, shopWeight = 0.5,
}

H.Weapon{
  id = 423, key = "short_spear", name = "Short Spear", icon = I("INV_Spear_05"), quality = 1, classes = { "WARRIOR", "HUNTER", "PALADIN" },
  weaponType = "polearm", hands = 2, weaponMin = 14, weaponMax = 20, speed = 3.3, stats = { ap = 8 }, shopWeight = 0.8,
}

H.Weapon{
  id = 424, key = "impaling_harpoon", name = "Impaling Harpoon", icon = I("INV_Spear_05"), quality = 2, cost = 6, minRound = 3,
  classes = { "WARRIOR", "HUNTER", "PALADIN" }, weaponType = "polearm", hands = 2, weaponMin = 15, weaponMax = 22, speed = 2.4,
  stats = { ap = 8, dodge = 2 }, shopWeight = 0.7,
}

H.Weapon{
  id = 425, key = "grimloks_charge", name = "Grimlok's Charge", icon = I("INV_Spear_05"), quality = 3, minRound = 6,
  classes = { "WARRIOR", "HUNTER", "PALADIN" }, shape = { "10", "10", "11" }, weaponType = "polearm", hands = 2, weaponMin = 20, weaponMax = 29,
  speed = 2.7, stats = { ap = 20, crit = 3, hp = 30 }, shopWeight = 0.65,
}

H.Weapon{
  id = 426, key = "halberd_of_smiting", name = "Halberd of Smiting", icon = I("INV_Spear_05"), quality = 4, cost = 13, minRound = 10,
  classes = { "WARRIOR", "HUNTER", "PALADIN" }, weaponType = "polearm", hands = 2, weaponMin = 25, weaponMax = 36, speed = 3.5,
  stats = { ap = 24, hp = 20 },
  triggers = { { on = "hit", chance = 10, icd = 2, effects = { { type = "damage", coef = 0.5, min = 1, max = 3, school = "physical", noCrit = true, noOwnTriggers = true } } } },
  shopWeight = 0.4,
}

H.Weapon{
  id = 427, key = "hunters_boomstick", name = "Hunter's Boomstick", icon = I("INV_Weapon_Rifle_09"), quality = 1, cost = 4, classes = { "HUNTER" },
  shape = S.L, weaponType = "gun", weaponMin = 9, weaponMax = 12, speed = 2.1, shopWeight = 0.9,
}

H.Weapon{
  id = 428, key = "large_bore_blunderbuss", name = "Large Bore Blunderbuss", icon = I("INV_Weapon_Rifle_09"), quality = 2, cost = 5, minRound = 2,
  classes = { "HUNTER" }, shape = { "11", "01", "01" }, weaponType = "gun", weaponMin = 14, weaponMax = 20, speed = 2.5, stats = { ap = 6, crit = 2 },
  shopWeight = 0.8,
}

H.Weapon{
  id = 429, key = "fine_light_crossbow", name = "Fine Light Crossbow", icon = I("INV_Weapon_Crossbow_03"), quality = 1, classes = { "HUNTER" },
  shape = { "11", "10", "10" }, weaponType = "crossbow", weaponMin = 14, weaponMax = 17, speed = 2.7, stats = { ap = 4 }, shopWeight = 0.8,
}



H.Weapon{
  id = 430, key = "hurricane_bow", name = "Hurricane", icon = I("INV_Weapon_Bow_13"), quality = 4, cost = 12, minRound = 9, classes = { "HUNTER" },
  shape = { "11", "01", "11" }, weaponType = "bow", weaponMin = 12, weaponMax = 18, speed = 1.6, stats = { ap = 10, crit = 2 },
  triggers = { { on = "hit", chance = 15, icd = 2, effects = { { type = "damage", coef = 0.15, min = 1, max = 3, school = "frost", noCrit = true, noOwnTriggers = true } } } },
  shopAffinities = { HUNTER = { bm = 0.6, mm = 1.5, surv = 0.6 } }, shopWeight = 0.55,
}

H.Armor{
  id = 2200, key = "dreamweave_gloves", name = "Dreamweave Gloves", icon = I("inv_gauntlets_18"), quality = 3, cost = 6, minRound = 3,
  classes = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, armorType = "cloth", slot = "hands",
  stats = { armor = 6, mana = 20, sp = 24 }, shopClasses = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, shopWeight = 0.5,
}

H.Armor{
  id = 2201, key = "dreamers_belt", name = "Dreamer's Belt", icon = I("inv_belt_04"), quality = 2, cost = 4, minRound = 2,
  classes = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, armorType = "cloth", slot = "waist",
  stats = { mana = 30, regen = 1, sp = 10 }, shopClasses = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, shopWeight = 0.75,
}

H.Armor{
  id = 2202, key = "warpwood_binding", name = "Warpwood Binding", icon = I("inv_belt_34"), quality = 3, minRound = 4, classes = MAIL_USERS,
  armorType = "mail", slot = "waist", stats = { ap = 28, armor = 14, crit = 5, mana = 20 },
  shopClassWeights = { PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = MAIL_USERS,
}

H.Armor{
  id = 2203, key = "primalists_linked_waistguard", name = "Primalist's Linked Waistguard", icon = I("inv_belt_21"), quality = 4, minRound = 8,
  classes = MAIL_USERS, armorType = "mail", slot = "waist", stats = { ap = 24, armor = 18, mana = 30, sp = 36 },
  shopClassWeights = { PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = MAIL_USERS,
}

H.Armor{
  id = 2204, key = "wristguards_of_true_flight", name = "Wristguards of True Flight", icon = I("inv_bracer_02"), quality = 4, cost = 9, minRound = 7,
  classes = MAIL_USERS, armorType = "mail", slot = "wrist", stats = { ap = 36, armor = 16, crit = 6, mana = 15 },
  shopClassWeights = { PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = MAIL_USERS,
}

H.Jewel{
  id = 2209, key = "tooth_of_gnarr", name = "Tooth of Gnarr", icon = I("inv_jewelry_necklace_09"), quality = 3, cost = 6, minRound = 4, kind = "neck",
  classes = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, stats = { hp = 40, mana = 40, regen = 2 },
  shopClasses = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, shopWeight = 0.75,
}

H.Jewel{
  id = 2211, key = "cloak_of_consumption", name = "Cloak of Consumption", icon = I("inv_misc_cape_22"), quality = 4, minRound = 8, kind = "cloak",
  classes = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, shape = S.h2, stats = { crit = 4, mana = 20, sp = 32 },
  shopClasses = { "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID", "HUNTER" }, shopWeight = 0.5,
}

H.Weapon{
  id = 2240, key = "manual_crowd_pummeler", name = "Manual Crowd Pummeler", icon = I("inv_mace_14"), quality = 3, cost = 8, minRound = 4,
  classes = H.PHYSICAL_MACE, weaponType = "mace", hands = 2, weaponMin = 8, weaponMax = 12, speed = 2, stats = { ap = 24, crit = 3 },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "crowd_pummeler", name = "Manual Crowd Pummeler", target = "all", match = { tag = "autoattack" }, stat = "haste", value = 50, duration = 12 } },
    },
  },
  passiveTriggers = true, shopClassWeights = { PALADIN = 0.35, SHAMAN = 0.35, WARRIOR = 0.35 },
}

H.Weapon{
  id = 2241, key = "warden_staff", name = "Warden Staff", icon = I("inv_staff_29"), quality = 4, cost = 11, minRound = 8,
  classes = { "WARRIOR", "HUNTER", "SHAMAN", "DRUID" }, weaponType = "staff", hands = 2, weaponMin = 12, weaponMax = 18, speed = 2.4,
  stats = { ap = 20, armor = 80, hp = 80 }, shopClassWeights = { HUNTER = 0.35, SHAMAN = 0.35, WARRIOR = 0.35 },
}

H.Weapon{
  id = 2242, key = "staff_of_the_blessed_seer", name = "Staff of the Blessed Seer", icon = I("inv_staff_31"), quality = 3, cost = 5, minRound = 2,
  classes = STAFF_USERS, weaponType = "staff", hands = 2, weaponMin = 6, weaponMax = 10, speed = 3, stats = { healing = 28, mana = 20 },
  shopWeight = 0.75,
}

H.Armor{
  id = 2243, key = "bracers_of_prosperity", name = "Bracers of Prosperity", icon = I("inv_bracer_12"), quality = 3, cost = 6, minRound = 4,
  classes = { "PALADIN", "HUNTER", "SHAMAN", "DRUID" }, armorType = "leather", slot = "wrist", stats = { healing = 28, hp = 30, mana = 20 },
  shopClassWeights = { HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5 }, shopClasses = { "PALADIN", "HUNTER", "SHAMAN", "DRUID" },
}

H.Armor{
  id = 2244, key = "bracers_of_the_eclipse", name = "Bracers of the Eclipse", icon = I("inv_bracer_07"), quality = 3, minRound = 4,
  classes = H.PHYSICAL, armorType = "leather", slot = "wrist", stats = { ap = 28, armor = 10, crit = 4, hp = 25 },
  shopClassWeights = { HUNTER = 0.5, PALADIN = 0.5, ROGUE = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 2245, key = "whipvine_cord", name = "Whipvine Cord", icon = I("inv_belt_17"), quality = 3, minRound = 5, classes = HEALERS, armorType = "cloth",
  slot = "waist", stats = { healing = 32, mana = 25, regen = 2 }, shopClasses = HEALERS, shopWeight = 0.5,
}


H.Jewel{
  id = 2246, key = "animated_chain_necklace", name = "Animated Chain Necklace", icon = I("inv_jewelry_necklace_01"), quality = 3, minRound = 4,
  kind = "neck", classes = HEALERS, stats = { healing = 36, hp = 35 }, shopClasses = HEALERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 5423, key = "paladin_animated_chain_necklace", classes = { "PALADIN" }, shopClasses = {}, shopWeight = 1, stockKey = "animated_chain_necklace" }

legacyStockCopy{ id = 7425, key = "shaman_animated_chain_necklace", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "animated_chain_necklace" }

H.Jewel{
  id = 2247, key = "orb_of_the_darkmoon", name = "Orb of the Darkmoon", icon = I("inv_jewelry_necklace_16"), quality = 4, minRound = 8, kind = "neck",
  classes = CASTERS, stats = { healing = 24, hp = 40, sp = 32 }, shopClasses = CASTERS, shopWeight = 0.75,
}

H.Jewel{
  id = 2251, key = "naglering", name = "Naglering", icon = I("inv_jewelry_ring_05"), quality = 3, cost = 6, minRound = 4, kind = "ring",
  classes = H.PHYSICAL, stats = { armor = 18, hp = 40, thorns = 4 }, shopClasses = H.PHYSICAL, shopWeight = 0.75,
}



H.Weapon{
  id = 4400, key = "small_dagger", name = "Small Dagger", icon = I("INV_Weapon_ShortBlade_05"), quality = 1, cost = 4, classes = PHYSICAL_DAGGERS,
  weaponType = "dagger", weaponMin = 4, weaponMax = 6, speed = 1.6, stats = { ap = 6 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4401, key = "assassins_blade", name = "Assassin's Blade", icon = I("INV_Weapon_ShortBlade_05"), quality = 2, cost = 6, minRound = 2,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 6, weaponMax = 10, speed = 1.8, stats = { ap = 8, crit = 5 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4402, key = "barman_shanker", name = "Barman Shanker", icon = I("INV_Weapon_ShortBlade_15"), quality = 3, cost = 9, minRound = 5,
  classes = PHYSICAL_DAGGERS, tags = { "bleed" }, weaponType = "dagger", weaponMin = 10, weaponMax = 16, speed = 2, stats = { ap = 20 },
  triggers = { { on = "crit", effects = { { type = "dot", key = "barman_wound", tick = 0, school = "physical", duration = 6, fromEvent = 0.3, rolling = true } } } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4403, key = "distracting_dagger", name = "Distracting Dagger", icon = I("INV_Weapon_ShortBlade_23"), quality = 3, cost = 8, minRound = 4,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 7, weaponMax = 10, speed = 1.3, stats = { ap = 16, dodge = 3 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4404, key = "gut_ripper", name = "Gut Ripper", icon = I("INV_Weapon_ShortBlade_16"), quality = 3, cost = 9, minRound = 5,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 10, weaponMax = 15, speed = 1.8, stats = { ap = 24, crit = 4 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4405, key = "thrash_blade", name = "Thrash Blade", icon = I("INV_Sword_36"), quality = 3, cost = 9, minRound = 5, classes = H.PHYSICAL_SWORD,
  weaponType = "sword", weaponMin = 11, weaponMax = 17, speed = 2.4,
  triggers = { { on = "hit", chance = 12, effects = { { type = "extraAttack" } } } },
}

H.Weapon{
  id = 4406, key = "krol_blade", name = "Krol Blade", icon = I("INV_Sword_18"), quality = 4, cost = 12, minRound = 8, classes = H.PHYSICAL_SWORD,
  weaponType = "sword", weaponMin = 15, weaponMax = 23, speed = 2.8, stats = { ap = 32, crit = 6 },
}

H.Weapon{
  id = 4408, key = "core_hound_tooth", name = "Core Hound Tooth", icon = I("INV_Weapon_ShortBlade_25"), quality = 4, cost = 12, minRound = 9,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 12, weaponMax = 18, speed = 1.6, stats = { ap = 36, crit = 6, hp = 25 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4409, key = "dragonfang_blade", name = "Dragonfang Blade", icon = I("INV_Weapon_ShortBlade_28"), quality = 4, cost = 14, minRound = 11,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 17, weaponMax = 25, speed = 1.8, stats = { ap = 44, crit = 7, hp = 35 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4410, key = "the_lobotomizer", name = "The Lobotomizer", icon = I("INV_Weapon_ShortBlade_32"), quality = 4, cost = 13, minRound = 10,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 15, weaponMax = 24, speed = 1.8, stats = { crit = 5 },
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", coef = 0.2, min = 12, max = 18, school = "shadow", noDodge = true }, { type = "drain", resource = "mana", amount = 6 } } } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Weapon{
  id = 4411, key = "death_sting", name = "Death's Sting", icon = I("INV_Weapon_ShortBlade_35"), quality = 4, cost = 16, minRound = 13,
  classes = PHYSICAL_DAGGERS, weaponType = "dagger", weaponMin = 22, weaponMax = 32, speed = 1.8, stats = { ap = 60, crit = 9 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 },
}

H.Armor{
  id = 4420, key = "blackened_defias_armor", name = "Blackened Defias Armor", icon = I("INV_Chest_Leather_05"), quality = 2, cost = 6, minRound = 2,
  classes = H.PHYSICAL, armorType = "leather", slot = "chest", stats = { ap = 24, armor = 16, hp = 30 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4421, key = "dark_leather_tunic", name = "Dark Leather Tunic", icon = I("INV_Chest_Leather_03"), quality = 1, cost = 4, classes = H.PHYSICAL,
  armorType = "leather", slot = "chest", stats = { ap = 12, armor = 12, dodge = 3 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4422, key = "dark_leather_gloves", name = "Dark Leather Gloves", icon = I("INV_Gauntlets_05"), quality = 1, classes = H.PHYSICAL,
  armorType = "leather", slot = "hands", stats = { ap = 8, armor = 4, crit = 3 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4423, key = "dark_leather_boots", name = "Dark Leather Boots", icon = I("INV_Boots_05"), quality = 1, classes = H.PHYSICAL,
  armorType = "leather", slot = "feet", stats = { ap = 8, armor = 6, dodge = 4 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4424, key = "nightscape_headband", name = "Nightscape Headband", icon = I("INV_Misc_Bandana_03"), quality = 2, cost = 5, minRound = 2,
  classes = H.PHYSICAL, armorType = "leather", slot = "head", stats = { ap = 18, armor = 8, crit = 4, hp = 20 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4425, key = "blackmist_armguards", name = "Blackmist Armguards", icon = I("INV_Bracer_07"), quality = 3, cost = 6, minRound = 3,
  classes = H.PHYSICAL, armorType = "leather", slot = "wrist", stats = { ap = 20, armor = 6, crit = 4 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4426, key = "belt_of_the_preserved_heads", name = "Belt of Preserved Heads", icon = I("INV_Belt_17"), quality = 3, minRound = 5,
  classes = H.PHYSICAL, armorType = "leather", slot = "waist", stats = { ap = 24, armor = 8, crit = 4, hp = 30 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4427, key = "truestrike_shoulders", name = "Truestrike Shoulders", icon = I("INV_Shoulder_07"), quality = 3, minRound = 5, classes = H.PHYSICAL,
  armorType = "leather", slot = "shoulder", stats = { ap = 32, armor = 10, crit = 5 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4428, key = "leggings_of_the_fang", name = "Leggings of the Fang", icon = I("INV_Pants_02"), quality = 2, cost = 5, minRound = 2,
  classes = H.PHYSICAL, armorType = "leather", slot = "legs", stats = { ap = 18, armor = 12, hp = 25 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Armor{
  id = 4429, key = "cadaverous_armor", name = "Cadaverous Armor", icon = I("INV_Chest_Leather_08"), quality = 3, minRound = 3, classes = H.PHYSICAL,
  armorType = "leather", slot = "chest", stats = { ap = 48, armor = 24, hp = 45 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Jewel{
  id = 4432, key = "rogue_blackhands_breadth", name = "Blackhand's Breadth", icon = I("INV_Misc_Gem_Bloodstone_01"), quality = 3, minRound = 4,
  kind = "trinket", classes = H.PHYSICAL, stats = { ap = 12, crit = 9 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Jewel{
  id = 4434, key = "band_of_veiled_shadows", name = "Band of Veiled Shadows", icon = I("INV_Jewelry_Ring_24"), quality = 3, minRound = 4,
  kind = "ring", classes = H.PHYSICAL, stats = { ap = 24, crit = 4, hp = 20 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Jewel{
  id = 4435, key = "pendant_of_celerity", name = "Pendant of Celerity", icon = I("INV_Jewelry_Necklace_18"), quality = 3, minRound = 4, kind = "neck",
  classes = H.PHYSICAL, stats = { ap = 22, haste = 8, hp = 20 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, SHAMAN = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Weapon{
  id = 4490, key = "toxic_revenger", name = "Toxic Revenger", icon = I("inv_weapon_shortblade_02"), quality = 2, cost = 6, minRound = 2,
  classes = { "ROGUE", "HUNTER", "SHAMAN", "DRUID" }, tags = { "poison", "nature" }, weaponType = "dagger", weaponMin = 5, weaponMax = 8, speed = 1.9,
  stats = { ap = 6, sp = 10 },
  triggers = { { on = "hit", chance = 25, effects = { { type = "dot", key = "toxic_revenger", coef = 0.05, tick = 1, school = "nature", duration = 6, maxStacks = 5, stack = true } } } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5 },
}

H.Armor{
  id = 4491, key = "venomshroud_belt_rogue", name = "Venomshroud Belt", icon = I("inv_belt_25"), quality = 1,
  classes = { "ROGUE", "HUNTER", "SHAMAN", "DRUID" }, armorType = "cloth", slot = "waist", stats = { ap = 4, hp = 10, sp = 8 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5 }, shopClasses = { "ROGUE", "HUNTER", "SHAMAN", "DRUID" },
}

H.Armor{
  id = 4492, key = "venomshroud_mitts_rogue", name = "Venomshroud Mitts", icon = I("inv_gauntlets_23"), quality = 2, minRound = 2,
  classes = { "ROGUE", "HUNTER", "SHAMAN", "DRUID" }, armorType = "cloth", slot = "hands", stats = { ap = 6, armor = 2, sp = 14 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, SHAMAN = 0.5 }, shopClasses = { "ROGUE", "HUNTER", "SHAMAN", "DRUID" },
}

H.Weapon{
  id = 5402, key = "paladin_hammer_of_the_grand_crusader", name = "Hammer of the Grand Crusader", icon = I("inv_hammer_06"), quality = 3, minRound = 5,
  classes = H.PHYSICAL_MACE, weaponType = "mace", hands = 2, weaponMin = 18, weaponMax = 28, speed = 3.5, stats = { healing = 28, hp = 30, sp = 20 },
  shopClassWeights = { DRUID = 0.35, SHAMAN = 0.35, WARRIOR = 0.35 }, shopClasses = H.PHYSICAL_MACE,
}

H.Weapon{
  id = 5403, key = "paladin_aurastone_hammer", name = "Aurastone Hammer", icon = I("inv_hammer_05"), quality = 4, cost = 11, minRound = 8,
  classes = HEALERS, weaponType = "mace", weaponMin = 10, weaponMax = 16, speed = 2.5, stats = { healing = 42, regen = 3, sp = 16 }, shopWeight = 0.75,
}

legacyStockCopy{ id = 7405, key = "shaman_aurastone_hammer", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_aurastone_hammer" }

H.Weapon{
  id = 5404, key = "paladin_lokamir_il_romathis", name = "Lok'amir il Romathis", icon = I("inv_mace_06"), quality = 4, cost = 13, minRound = 11,
  classes = HEALERS, weaponType = "mace", weaponMin = 12, weaponMax = 18, speed = 2.2, stats = { healing = 52, mana = 40, sp = 30 }, shopWeight = 0.75,
}

legacyStockCopy{ id = 7406, key = "shaman_lokamir_il_romathis", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_lokamir_il_romathis" }

ns.RegisterItem{
  id = 5405, key = "paladin_draconian_deflector", name = "Draconian Deflector", icon = I("inv_shield_20"), quality = 3, minRound = 5, kind = "shield",
  classes = H.ALL_SHIELD, shape = S.sq, stats = { armor = 34, block = 18, blockChance = 32, hp = 45 }, shopClasses = H.ALL_SHIELD, shopWeight = 0.75,
}

legacyStockCopy{ id = 7408, key = "shaman_draconian_deflector", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_draconian_deflector" }

H.Armor{
  id = 5406, key = "paladin_copper_chain_vest", name = "Copper Chain Vest", icon = I("inv_chest_chain"), quality = 1, cost = 4,
  classes = { "PALADIN", "SHAMAN", "HUNTER" }, armorType = "mail", slot = "chest", stats = { armor = 18, hp = 35, sp = 6 },
  shopClasses = { "PALADIN", "SHAMAN", "HUNTER" }, shopWeight = 0.75,
}

legacyStockCopy{ id = 7409, key = "shaman_copper_chain_vest", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_copper_chain_vest" }

H.Armor{
  id = 5407, key = "paladin_green_iron_hauberk", name = "Green Iron Hauberk", icon = I("inv_chest_chain"), quality = 3, cost = 6, minRound = 3,
  classes = { "PALADIN", "SHAMAN", "HUNTER" }, armorType = "mail", slot = "chest", stats = { armor = 30, healing = 14, hp = 50 },
  shopClasses = { "PALADIN", "SHAMAN", "HUNTER" }, shopWeight = 0.75,
}

legacyStockCopy{ id = 7410, key = "shaman_green_iron_hauberk", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_green_iron_hauberk" }

H.Armor{
  id = 5408, key = "paladin_enchanted_thorium_breastplate", name = "Enchanted Thorium Breastplate", icon = I("inv_chest_plate10"), quality = 3,
  minRound = 5, classes = H.PLATE, armorType = "plate", slot = "chest", stats = { armor = 60, block = 8, hp = 90 },
  shopClassWeights = { WARRIOR = 0.5 }, shopClasses = H.PLATE,
}

H.Armor{
  id = 5409, key = "paladin_stockade_pauldrons", name = "Stockade Pauldrons", icon = I("inv_shoulder_20"), quality = 4, minRound = 7,
  classes = H.PLATE, armorType = "plate", slot = "shoulder", stats = { armor = 35, blockChance = 7, hp = 70 }, shopClassWeights = { WARRIOR = 0.5 },
  shopClasses = H.PLATE,
}

H.Armor{
  id = 5410, key = "paladin_ornate_mithril_gloves", name = "Ornate Mithril Gloves", icon = I("inv_gauntlets_31"), quality = 2, minRound = 2,
  classes = H.PLATE, armorType = "plate", slot = "hands", stats = { ap = 22, armor = 12, crit = 3 }, shopClassWeights = { WARRIOR = 0.5 },
  shopClasses = H.PLATE,
}

H.Jewel{
  id = 5418, key = "paladin_shroud_of_pure_thought", name = "Shroud of Pure Thought", icon = I("inv_misc_cape_16"), quality = 4, minRound = 8,
  kind = "cloak", classes = HEALERS, shape = S.h2, stats = { healing = 40, hp = 40, regen = 3 }, shopClasses = HEALERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7422, key = "shaman_shroud_of_pure_thought", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_shroud_of_pure_thought" }

H.Jewel{
  id = 5419, key = "paladin_ring_of_spell_power", name = "Ring of Spell Power", icon = I("inv_jewelry_ring_38"), quality = 4, minRound = 8,
  kind = "ring", classes = CASTERS, stats = { crit = 3, mana = 30, sp = 38 }, shopClasses = CASTERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7421, key = "shaman_ring_of_spell_power", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_ring_of_spell_power" }

H.Jewel{
  id = 5420, key = "paladin_pendant_of_the_fallen_dragon", name = "Pendant of the Fallen Dragon", icon = I("inv_jewelry_necklace_12"), quality = 4,
  minRound = 8, kind = "neck", classes = HEALERS, stats = { healing = 32, hp = 60, regen = 2 },
  shopClassWeights = { DRUID = 0.5, PRIEST = 0.5, SHAMAN = 0.5 }, shopClasses = HEALERS,
}

H.Jewel{
  id = 5421, key = "paladin_emberfury_talisman", name = "Emberfury Talisman", icon = I("inv_jewelry_necklace_05"), quality = 3, minRound = 4,
  kind = "neck", classes = H.PHYSICAL, stats = { ap = 28, crit = 5, hp = 20 }, shopClasses = H.PHYSICAL, shopWeight = 0.75,
}

legacyStockCopy{ id = 7423, key = "shaman_emberfury_talisman", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_emberfury_talisman" }

H.Jewel{
  id = 5422, key = "paladin_star_of_mystaria", name = "Star of Mystaria", icon = I("inv_jewelry_talisman_08"), quality = 3, minRound = 4,
  kind = "neck", classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, stats = { crit = 3, mana = 25, sp = 24 },
  shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } }, shopClassWeights = { HUNTER = 0.35 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, shopWeight = 0.75,
}

legacyStockCopy{
  id = 7424, key = "shaman_star_of_mystaria", classes = { "SHAMAN" }, omit = { "shopAffinities", "shopClassWeights" }, shopClasses = {},
  shopWeight = 1, stockKey = "paladin_star_of_mystaria",
}

H.Jewel{
  id = 5424, key = "paladin_painweaver_band", name = "Painweaver Band", icon = I("inv_jewelry_ring_18"), quality = 3, minRound = 4, kind = "ring",
  classes = H.PHYSICAL, stats = { ap = 26, crit = 5, hp = 25 }, shopClasses = H.PHYSICAL, shopWeight = 0.75,
}

legacyStockCopy{ id = 7426, key = "shaman_painweaver_band", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_painweaver_band" }

H.Jewel{
  id = 5425, key = "paladin_rosewine_circle", name = "Rosewine Circle", icon = I("inv_jewelry_ring_22"), quality = 3, minRound = 5, kind = "ring",
  classes = HEALERS, stats = { healing = 30, mana = 20, regen = 2 }, shopClasses = HEALERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7427, key = "shaman_rosewine_circle", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_rosewine_circle" }

H.Jewel{
  id = 5426, key = "paladin_linen_cloak", name = "Linen Cloak", icon = I("inv_misc_cape_14"), quality = 1, kind = "cloak", classes = CASTERS,
  shape = S.h2, stats = { healing = 6, hp = 15, sp = 6 }, shopClasses = CASTERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7428, key = "shaman_linen_cloak", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_linen_cloak" }

H.Jewel{
  id = 5427, key = "paladin_dark_leather_cloak", name = "Dark Leather Cloak", icon = I("inv_misc_cape_10"), quality = 2, cost = 4, minRound = 2,
  kind = "cloak", classes = H.PHYSICAL, shape = S.h2, stats = { ap = 14, crit = 3, hp = 20 }, shopClasses = H.PHYSICAL, shopWeight = 0.75,
}

legacyStockCopy{ id = 7429, key = "shaman_dark_leather_cloak", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_dark_leather_cloak" }

H.Armor{
  id = 5428, key = "paladin_green_iron_leggings", name = "Green Iron Leggings", icon = I("inv_pants_05"), quality = 2, minRound = 2,
  classes = MAIL_USERS, armorType = "mail", slot = "legs", stats = { ap = 24, armor = 18, hp = 25 }, shopClassWeights = { WARRIOR = 0.5 },
  shopClasses = MAIL_USERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7430, key = "shaman_green_iron_leggings", classes = { "SHAMAN" }, omit = { "shopClassWeights" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_green_iron_leggings" }

H.Armor{
  id = 5429, key = "paladin_azure_silk_pants", name = "Azure Silk Pants", icon = I("inv_pants_08"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "legs",
  stats = { healing = 14, hp = 25, mana = 20, sp = 20 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35 }, shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, shopWeight = 0.75,
}

legacyStockCopy{
  id = 7431, key = "shaman_azure_silk_pants", classes = { "SHAMAN" }, omit = { "shopAffinities", "shopClassWeights" }, shopClasses = {},
  shopWeight = 1, stockKey = "paladin_azure_silk_pants",
}

H.Armor{
  id = 5430, key = "paladin_bright_belt", name = "Bright Belt", icon = I("inv_belt_11"), quality = 2, cost = 4, minRound = 2, classes = HEALERS,
  armorType = "cloth", slot = "waist", stats = { healing = 16, hp = 15, mana = 20, sp = 6 }, shopClasses = HEALERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7432, key = "shaman_bright_belt", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_bright_belt" }

H.Jewel{
  id = 5431, key = "paladin_silver_thread_cloak", name = "Silver-thread Cloak", icon = I("inv_misc_cape_02"), quality = 2, cost = 4, minRound = 2,
  kind = "cloak", classes = CASTERS, shape = S.h2, stats = { healing = 10, hp = 20, sp = 16 }, shopClasses = CASTERS, shopWeight = 0.75,
}

legacyStockCopy{ id = 7433, key = "shaman_silver_thread_cloak", classes = { "SHAMAN" }, shopClasses = {}, shopWeight = 1, stockKey = "paladin_silver_thread_cloak" }


H.Weapon{
  id = 6401, key = "crested_scepter", name = "Crested Scepter", icon = I("INV_Mace_03"), quality = 2, minRound = 2, classes = HEALERS,
  weaponType = "mace", weaponMin = 5, weaponMax = 8, speed = 2.2, stats = { healing = 18, mana = 15 }, shopWeight = 0.75,
}

H.Weapon{
  id = 6402, key = "illusionary_rod", name = "Illusionary Rod", icon = I("INV_Staff_01"), quality = 2, cost = 6, minRound = 2, classes = STAFF_USERS,
  weaponType = "staff", hands = 2, weaponMin = 6, weaponMax = 10, speed = 2.8, stats = { healing = 16, mana = 25, sp = 16 }, shopWeight = 0.75,
}

H.Weapon{
  id = 6403, key = "trindlehaven_staff", name = "Trindlehaven Staff", icon = I("INV_Staff_13"), quality = 3, minRound = 5, classes = STAFF_USERS,
  weaponType = "staff", hands = 2, weaponMin = 10, weaponMax = 16, speed = 2.8, stats = { healing = 30, hp = 35, mana = 35, sp = 24 },
  shopWeight = 0.75,
}

H.Weapon{
  id = 6404, key = "hammer_of_grace", name = "Hammer of Grace", icon = I("INV_Hammer_20"), quality = 3, cost = 8, minRound = 4, classes = HEALERS,
  weaponType = "mace", weaponMin = 7, weaponMax = 12, speed = 2.2, stats = { healing = 36, mana = 20 }, shopWeight = 0.75,
}

H.Weapon{
  id = 6407, key = "lokamir_il_romathis", name = "Lok'amir il Romathis", icon = I("INV_Hammer_19"), quality = 4, cost = 14, minRound = 11,
  classes = HEALERS, weaponType = "mace", weaponMin = 15, weaponMax = 22, speed = 2.1, stats = { healing = 58, hp = 35, mana = 35, sp = 40 },
  shopClassWeights = { DRUID = 0.5, PALADIN = 0.5, SHAMAN = 0.5 },
}

H.Weapon{
  id = 6408, key = "lesser_magic_wand", name = "Lesser Magic Wand", icon = I("INV_Wand_07"), quality = 1, cost = 4,
  classes = { "PRIEST", "MAGE", "WARLOCK" }, tags = { "wand", "spell", "ranged" }, weaponType = "wand", weaponMin = 3, weaponMax = 5, speed = 1.8,
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.12, school = "arcane", noDodge = true, ranged = true, weaponSelf = true } } },
}

H.Weapon{
  id = 6409, key = "greater_magic_wand", name = "Greater Magic Wand", icon = I("INV_Wand_07"), quality = 2, cost = 6, minRound = 2,
  classes = { "PRIEST", "MAGE", "WARLOCK" }, tags = { "wand", "spell", "ranged" }, weaponType = "wand", weaponMin = 5, weaponMax = 8, speed = 1.8,
  stats = { sp = 6 },
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.15, school = "arcane", noDodge = true, ranged = true, weaponSelf = true } } },
}

H.Weapon{
  id = 6410, key = "gravestone_scepter", name = "Gravestone Scepter", icon = I("INV_Wand_04"), quality = 3, cost = 8, minRound = 4,
  classes = { "PRIEST", "MAGE", "WARLOCK" }, tags = { "wand", "spell", "ranged", "shadow" }, weaponType = "wand", weaponMin = 9, weaponMax = 14,
  speed = 1.8, stats = { hp = 20, sp = 12 },
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.18, school = "shadow", noDodge = true, ranged = true, weaponSelf = true } } },
}

H.Weapon{
  id = 6411, key = "skuls_ghastly_touch", name = "Skul's Ghastly Touch", icon = I("INV_Wand_12"), quality = 3, cost = 9, minRound = 6,
  classes = { "PRIEST", "MAGE", "WARLOCK" }, tags = { "wand", "spell", "ranged", "shadow" }, weaponType = "wand", weaponMin = 12, weaponMax = 18,
  speed = 1.8, stats = { sp = 24 },
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.2, school = "shadow", noDodge = true, ranged = true, weaponSelf = true } } },
}

H.Armor{
  id = 6420, key = "barbaric_linen_vest_priest", name = "Barbaric Linen Vest", icon = I("INV_Chest_Cloth_14"), quality = 1, cost = 4,
  classes = CASTERS, armorType = "cloth", slot = "chest", stats = { armor = 6, healing = 14, hp = 20, sp = 8 }, shopClasses = CASTERS,
  shopWeight = 0.5,
}

H.Armor{
  id = 6421, key = "gray_woolen_robe", name = "Gray Woolen Robe", icon = I("INV_Chest_Cloth_13"), quality = 2, cost = 6, minRound = 2,
  classes = CASTERS, armorType = "cloth", slot = "chest", stats = { armor = 8, healing = 20, hp = 30, mana = 25, sp = 20 }, shopClasses = CASTERS,
  shopWeight = 0.5,
}

H.Armor{
  id = 6423, key = "robes_of_the_exalted", name = "Robes of the Exalted", icon = I("INV_Chest_Cloth_30"), quality = 3, minRound = 3, classes = HEALERS,
  armorType = "cloth", slot = "chest", stats = { armor = 12, healing = 50, hp = 40, mana = 35 }, shopClasses = HEALERS, shopWeight = 0.5,
}

H.Armor{
  id = 6424, key = "hands_of_the_exalted_herald", name = "Hands of the Exalted Herald", icon = I("INV_Gauntlets_14"), quality = 3, cost = 6,
  minRound = 4, classes = HEALERS, armorType = "cloth", slot = "hands", stats = { armor = 5, crit = 3, healing = 28, mana = 20 },
  shopClasses = HEALERS, shopWeight = 0.5,
}

H.Armor{
  id = 6425, key = "shadoweave_gloves_priest", name = "Shadoweave Gloves", icon = I("INV_Gauntlets_09"), quality = 2, minRound = 2, classes = CASTERS,
  armorType = "cloth", slot = "hands", stats = { armor = 4, hp = 15, sp = 22 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Armor{
  id = 6426, key = "shadoweave_mask_priest", name = "Shadoweave Mask", icon = I("INV_Helmet_27"), quality = 3, cost = 7, minRound = 4,
  classes = CASTERS, armorType = "cloth", slot = "head", stats = { armor = 6, hp = 30, mana = 25, sp = 30 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Armor{
  id = 6427, key = "whitemanes_chapeau", name = "Whitemane's Chapeau", icon = I("INV_Helmet_25"), quality = 2, cost = 5, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "head",
  stats = { armor = 5, healing = 24, mana = 20, sp = 12 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35 }, shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, shopWeight = 0.5,
}

H.Armor{
  id = 6428, key = "burial_shawl", name = "Burial Shawl", icon = I("INV_Shoulder_02"), quality = 3, minRound = 4, classes = CASTERS,
  armorType = "cloth", slot = "shoulder", stats = { armor = 5, healing = 24, mana = 20, sp = 20 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Armor{
  id = 6429, key = "abyssal_cloth_pants_priest", name = "Padre's Trousers", icon = I("INV_Pants_07"), quality = 2, minRound = 2, classes = HEALERS,
  armorType = "cloth", slot = "legs", stats = { armor = 7, healing = 22, hp = 20, mana = 25 }, shopClasses = HEALERS, shopWeight = 0.5,
}

H.Armor{
  id = 6430, key = "wolfrunner_shoes", name = "Wolfrunner Shoes", icon = I("INV_Boots_05"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "DRUID" }, armorType = "cloth", slot = "feet",
  stats = { armor = 4, healing = 16, hp = 20, sp = 12 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35 }, shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "DRUID" }, shopWeight = 0.5,
}

H.Armor{
  id = 6431, key = "dawnspire_cord", name = "Dawnspire Cord", icon = I("INV_Belt_11"), quality = 3, cost = 6, minRound = 4, classes = HEALERS,
  armorType = "cloth", slot = "waist", stats = { armor = 5, healing = 24, mana = 20, regen = 1 }, shopClasses = HEALERS, shopWeight = 0.5,
}

H.Armor{
  id = 6432, key = "bracers_of_prosperity_priest", name = "Bracers of Prosperity", icon = I("INV_Bracer_09"), quality = 3, cost = 6, minRound = 4,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "DRUID" }, armorType = "cloth", slot = "wrist",
  stats = { armor = 4, crit = 2, healing = 22, mana = 20 }, shopAffinities = { HUNTER = { bm = 1, mm = 0.25, surv = 0.5 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.3, PALADIN = 0.5, SHAMAN = 0.5 }, shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "DRUID" },
}

H.Jewel{
  id = 6443, key = "scarab_brooch_priest", name = "Scarab Brooch", icon = I("INV_Misc_AhnQirajTrinket_06"), quality = 4, cost = 11, minRound = 8,
  kind = "trinket", classes = HEALERS, stats = { healing = 16 }, triggers = { { on = "healed", effects = { { type = "absorb", fromEvent = 0.15 } } } },
  shopClassWeights = { DRUID = 0.35, PALADIN = 0.35, SHAMAN = 0.35 }, shopClasses = HEALERS,
}

H.Jewel{
  id = 6444, key = "mindtap_talisman_priest", name = "Mindtap Talisman", icon = I("INV_Jewelry_Talisman_11"), quality = 3, minRound = 4,
  kind = "trinket", classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "DRUID" }, stats = { mana = 30, regen = 2 },
  shopAffinities = { HUNTER = { bm = 1, mm = 0.25, surv = 0.5 } }, shopClassWeights = { DRUID = 0.5, HUNTER = 0.3, PALADIN = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "DRUID" },
}

H.Jewel{
  id = 6445, key = "animated_chain_necklace_priest", name = "Animated Chain Necklace", icon = I("INV_Jewelry_Necklace_09"), quality = 3, minRound = 4,
  kind = "neck", classes = HEALERS, stats = { healing = 26, hp = 20, mana = 25 }, shopClassWeights = { DRUID = 0.5, PALADIN = 0.5, SHAMAN = 0.5 },
  shopClasses = HEALERS,
}

H.Jewel{
  id = 6446, key = "band_of_mending_priest", name = "Band of Mending", icon = I("INV_Jewelry_Ring_09"), quality = 3, minRound = 4, kind = "ring",
  classes = HEALERS, stats = { crit = 3, healing = 26, hp = 20 }, shopClasses = HEALERS, shopWeight = 0.5,
}

H.Jewel{
  id = 6447, key = "maiden_circle_priest", name = "Maiden's Circle", icon = I("INV_Jewelry_Ring_12"), quality = 3, minRound = 4, kind = "ring",
  classes = CASTERS, stats = { hp = 20, mana = 20, sp = 26 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Jewel{
  id = 6448, key = "hide_of_the_wild_priest", name = "Hide of the Wild", icon = I("INV_Misc_Cape_01"), quality = 4, minRound = 8, kind = "cloak",
  classes = HEALERS, shape = S.h2, stats = { armor = 8, healing = 42, hp = 50 }, shopClasses = HEALERS, shopWeight = 0.5,
}

H.Jewel{
  id = 6449, key = "blackflame_cape_priest", name = "Blackflame Cape", icon = I("INV_Misc_Cape_18"), quality = 3, minRound = 4, kind = "cloak",
  classes = CASTERS, shape = S.h2, stats = { armor = 4, mana = 20, sp = 26 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Weapon{
  id = 6450, key = "chanting_blade_priest", name = "Chanting Blade", icon = I("inv_weapon_shortblade_25"), quality = 1, cost = 4,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 3, weaponMax = 5, speed = 1.7,
  stats = { healing = 4, mana = 10, sp = 6 }, shopClassWeights = { DRUID = 0.5, MAGE = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
}

H.Weapon{
  id = 6451, key = "sacrificial_kris_priest", name = "Sacrificial Kris", icon = I("inv_weapon_shortblade_03"), quality = 2, cost = 6, minRound = 2,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 5, weaponMax = 8, speed = 2,
  stats = { healing = 10, mana = 15, sp = 12 }, shopClassWeights = { DRUID = 0.5, MAGE = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
}

H.Armor{
  id = 6452, key = "greenweave_gloves_priest", name = "Greenweave Gloves", icon = I("inv_gauntlets_18"), quality = 1, classes = CASTERS,
  armorType = "cloth", slot = "hands", stats = { armor = 2, healing = 10, sp = 6 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Armor{
  id = 6453, key = "greenweave_sash_priest", name = "Greenweave Sash", icon = I("inv_belt_05"), quality = 1, classes = CASTERS, armorType = "cloth",
  slot = "waist", stats = { healing = 8, mana = 10, sp = 6 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Armor{
  id = 6454, key = "simple_britches_priest", name = "Simple Britches", icon = I("inv_pants_06"), quality = 1, classes = CASTERS, armorType = "cloth",
  slot = "legs", stats = { healing = 12, hp = 15, sp = 8 }, shopClasses = CASTERS, shopWeight = 0.5,
}

H.Weapon{
  id = 7400, key = "shaman_crescent_staff", name = "Crescent Staff", icon = I("inv_staff_04"), quality = 3, cost = 6, minRound = 2,
  classes = STAFF_USERS, weaponType = "staff", hands = 2, weaponMin = 8, weaponMax = 13, speed = 3, stats = { healing = 12, hp = 25, sp = 14 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, MAGE = 0.5, PRIEST = 0.5, WARLOCK = 0.5 },
}

H.Weapon{
  id = 7401, key = "shaman_emberstone_staff", name = "Emberstone Staff", icon = I("inv_staff_13"), quality = 3, cost = 7, minRound = 3,
  classes = STAFF_USERS, weaponType = "staff", hands = 2, weaponMin = 9, weaponMax = 15, speed = 2.9, stats = { mana = 25, sp = 24 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, MAGE = 0.5, PRIEST = 0.5, WARLOCK = 0.5 },
}

H.Weapon{
  id = 7402, key = "fist_of_omokk", name = "Fist of Omokk", icon = I("inv_hammer_04"), quality = 3, minRound = 5, classes = H.PHYSICAL_MACE,
  weaponType = "mace", hands = 2, weaponMin = 21, weaponMax = 31, speed = 3.6, stats = { ap = 28, hp = 45 },
}

H.Weapon{
  id = 7403, key = "shaman_earthshaker", name = "Earthshaker", icon = I("inv_hammer_04"), quality = 4, minRound = 9, classes = H.PHYSICAL_MACE,
  weaponType = "mace", hands = 2, weaponMin = 27, weaponMax = 39, speed = 3.5, stats = { ap = 36, crit = 4 },
  triggers = { { on = "hit", chance = 12, effects = { { type = "stun", duration = 0.7 } } } },
}

H.Weapon{
  id = 7404, key = "shaman_spinal_reaper", name = "Spinal Reaper", icon = I("inv_axe_09"), quality = 4, cost = 13, minRound = 11, classes = H.ALL_AXE,
  weaponType = "axe", hands = 2, weaponMin = 30, weaponMax = 44, speed = 3.8, stats = { ap = 45, crit = 5 },
}

ns.RegisterItem{
  id = 7407, key = "shaman_redbeard_crest", name = "Redbeard Crest", icon = I("inv_shield_02"), quality = 2, cost = 5, minRound = 2, kind = "shield",
  classes = H.ALL_SHIELD, shape = S.sq, stats = { armor = 20, block = 9, blockChance = 26, hp = 25 },
}

H.Armor{
  id = 7411, key = "shaman_turtle_scale_gloves", name = "Turtle Scale Gloves", icon = I("inv_gauntlets_05"), quality = 2, minRound = 2,
  classes = { "PALADIN", "SHAMAN", "HUNTER" }, armorType = "mail", slot = "hands", stats = { armor = 10, healing = 18, mana = 20 },
  shopClassWeights = { HUNTER = 0.5, PALADIN = 0.5 }, shopClasses = { "PALADIN", "SHAMAN", "HUNTER" },
}

H.Armor{
  id = 7412, key = "shaman_black_dragonscale_breastplate", name = "Black Dragonscale Breastplate", icon = I("inv_chest_plate06"), quality = 3,
  minRound = 5, classes = MAIL_USERS, armorType = "mail", slot = "chest", stats = { ap = 52, armor = 30, crit = 5, hp = 45 },
  shopClassWeights = { HUNTER = 0.5, PALADIN = 0.5, WARRIOR = 0.5 }, shopClasses = MAIL_USERS,
}

H.Armor{
  id = 7413, key = "shaman_green_dragonscale_breastplate", name = "Green Dragonscale Breastplate", icon = I("inv_chest_chain_06"), quality = 3,
  cost = 8, minRound = 4, classes = { "PALADIN", "SHAMAN", "HUNTER" }, armorType = "mail", slot = "chest",
  stats = { armor = 22, healing = 46, hp = 40, regen = 3 }, shopClassWeights = { HUNTER = 0.5, PALADIN = 0.5 },
  shopClasses = { "PALADIN", "SHAMAN", "HUNTER" },
}

H.Jewel{
  id = 7420, key = "shaman_rune_of_the_guard_captain", name = "Rune of the Guard Captain", icon = I("inv_misc_rune_07"), quality = 3, minRound = 4,
  kind = "trinket", classes = H.PHYSICAL, stats = { ap = 32, crit = 4 },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.5, PALADIN = 0.5, ROGUE = 0.5, WARRIOR = 0.5 }, shopClasses = H.PHYSICAL,
}

H.Weapon{
  id = 8401, key = "hypnotic_blade", name = "Hypnotic Blade", icon = I("INV_Weapon_ShortBlade_07"), quality = 3, minRound = 3,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 4, weaponMax = 7, speed = 1.8,
  stats = { mana = 25, sp = 22 }, shopClassWeights = { PRIEST = 0.5 },
}

H.Weapon{
  id = 8402, key = "rod_of_the_ogre_magi", name = "Rod of the Ogre Magi", icon = I("INV_Staff_29"), quality = 3, cost = 8, minRound = 5,
  classes = STAFF_USERS, weaponType = "staff", hands = 2, weaponMin = 8, weaponMax = 12, speed = 3, stats = { crit = 4, mana = 30, sp = 29 },
  shopClassWeights = { HUNTER = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
}

H.Weapon{
  id = 8403, key = "azuresong_mageblade", name = "Azuresong Mageblade", icon = I("INV_Sword_12"), quality = 4, cost = 11, minRound = 8,
  classes = { "HUNTER", "PALADIN", "MAGE", "WARLOCK" }, weaponType = "sword", weaponMin = 9, weaponMax = 14, speed = 2.4,
  stats = { crit = 5, mana = 30, sp = 48 }, shopClassWeights = { HUNTER = 0.3, PALADIN = 0.5, WARLOCK = 0.5 },
}



H.Weapon{
  id = 8404, key = "caster_scrimshaw_dagger", name = "Scrimshaw Dagger", icon = I("INV_Weapon_ShortBlade_01"), quality = 1, cost = 4,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 4, weaponMax = 7, speed = 1.8,
  stats = { mana = 10, sp = 6 }, shopClassWeights = { PRIEST = 0.5 },
}

H.Weapon{
  id = 8405, key = "caster_sacrificial_kris", name = "Sacrificial Kris", icon = I("INV_Weapon_ShortBlade_03"), quality = 2, minRound = 2,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 5, weaponMax = 8, speed = 1.7,
  stats = { hp = 20, sp = 14 }, shopClassWeights = { PRIEST = 0.5 },
}

H.Weapon{
  id = 8406, key = "witchblade", name = "Witchblade", icon = I("INV_Weapon_ShortBlade_25"), quality = 3, cost = 8, minRound = 5,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 6, weaponMax = 10, speed = 1.6,
  stats = { crit = 3, sp = 25 }, shopClassWeights = { DRUID = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
}

H.Weapon{
  id = 8407, key = "sorcerous_dagger", name = "Sorcerous Dagger", icon = I("INV_Weapon_ShortBlade_07"), quality = 4, cost = 9, minRound = 7,
  classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 7, weaponMax = 12, speed = 1.8,
  stats = { mana = 45, sp = 40 }, shopClassWeights = { PRIEST = 0.5, SHAMAN = 0.5 },
}



H.Armor{
  id = 8410, key = "azure_silk_hood", name = "Azure Silk Hood", icon = I("INV_Helmet_29"), quality = 1,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "head",
  stats = { hp = 8, mana = 15, sp = 8 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 8411, key = "azure_silk_vest", name = "Azure Silk Vest", icon = I("INV_Chest_Cloth_37"), quality = 1,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "chest",
  stats = { hp = 13, mana = 25, sp = 15 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 8412, key = "azure_silk_gloves", name = "Azure Silk Gloves", icon = I("INV_Gauntlets_05"), quality = 1, classes = CASTERS, armorType = "cloth",
  slot = "hands", stats = { crit = 2, sp = 6 }, shopClassWeights = { PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 }, shopClasses = CASTERS,
}

H.Armor{
  id = 8413, key = "azure_silk_pants", name = "Azure Silk Pants", icon = I("INV_Pants_08"), quality = 1,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "legs", stats = { mana = 20, sp = 9 },
  shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 8414, key = "azure_silk_belt", name = "Azure Silk Belt", icon = I("INV_Belt_22"), quality = 2, minRound = 2, classes = CASTERS,
  armorType = "cloth", slot = "waist", stats = { regen = 1, sp = 11 }, shopClassWeights = { PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = CASTERS,
}

H.Armor{
  id = 8415, key = "spidersilk_boots", name = "Spidersilk Boots", icon = I("INV_Boots_Fabric_01"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "feet",
  stats = { healing = 10, hp = 35, sp = 9 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 8416, key = "silver_thread_cuffs", name = "Silver-thread Cuffs", icon = I("INV_Bracer_07"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "wrist",
  stats = { mana = 20, sp = 9 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 8417, key = "silver_thread_amice", name = "Silver-thread Amice", icon = I("INV_Shoulder_05"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "shoulder",
  stats = { armor = 10, healing = 12, sp = 11 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 8419, key = "hands_of_power", name = "Hands of Power", icon = I("INV_Gauntlets_06"), quality = 3, minRound = 5,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "hands",
  stats = { crit = 3, healing = 18, sp = 24 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { HUNTER = 0.35, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Jewel{
  id = 8422, key = "freezing_band", name = "Freezing Band", icon = I("INV_Jewelry_Ring_14"), quality = 4, minRound = 7, kind = "ring",
  classes = CASTERS, stats = { healing = 16, sp = 24 },
  triggers = { { on = "absorbed", icd = 4, everyAmount = 35, effects = { { type = "stun", duration = 0.8 } } } },
  shopClassWeights = { DRUID = 0.35, PALADIN = 0.35, PRIEST = 0.35, SHAMAN = 0.35, WARLOCK = 0.35 }, shopClasses = CASTERS,
}

H.Jewel{
  id = 8423, key = "choker_of_the_fire_lord", name = "Choker of the Fire Lord", icon = I("INV_Jewelry_Necklace_11"), quality = 4, minRound = 8,
  kind = "neck", classes = CASTERS, stats = { crit = 3, mana = 30, sp = 42 },
  shopClassWeights = { PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 }, shopClasses = CASTERS,
}

H.Jewel{
  id = 8424, key = "mage_silver_thread_cloak", name = "Silver-thread Cloak", icon = I("INV_Misc_Cape_02"), quality = 2, minRound = 2, kind = "cloak",
  classes = CASTERS, shape = S.h2, stats = { healing = 10, hp = 20, sp = 14 },
  shopClassWeights = { DRUID = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 }, shopClasses = CASTERS,
}

H.Jewel{
  id = 8425, key = "mage_ring_of_spell_power", name = "Ring of Spell Power", icon = I("INV_Jewelry_Ring_13"), quality = 3, minRound = 5, kind = "ring",
  classes = CASTERS, stats = { mana = 25, sp = 25 }, shopClassWeights = { DRUID = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5, WARLOCK = 0.5 },
  shopClasses = CASTERS,
}

H.Weapon{
  id = 8426, key = "wand_of_biting_cold", name = "Wand of Biting Cold", icon = I("INV_Wand_01"), quality = 3, cost = 8, minRound = 4,
  classes = { "PRIEST", "MAGE", "WARLOCK" }, tags = { "wand", "spell", "ranged", "frost" }, weaponType = "wand", weaponMin = 10, weaponMax = 15,
  speed = 1.8, stats = { crit = 3, sp = 18 },
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.18, school = "frost", critIf = "enemyStunned", noDodge = true, ranged = true, weaponSelf = true } } },
  shopWeight = 0.75,
}

H.Weapon{
  id = 9401, key = "blade_of_eternal_darkness", name = "Blade of Eternal Darkness", icon = I("INV_Weapon_ShortBlade_09"), quality = 4, cost = 11,
  minRound = 8, classes = { "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, weaponType = "dagger", weaponMin = 6, weaponMax = 10, speed = 1.8,
  stats = { sp = 24 },
  triggers = {
    {
      on = "anyHit", match = { tag = "spell" }, every = 6,
      effects = { { type = "resource", resource = "mana", amount = 15 }, { type = "damage", coef = 0.2, min = 8, max = 12, school = "shadow", noCrit = true } },
    },
  },
  passiveTriggers = true, shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
}

H.Armor{
  id = 9410, key = "shadoweave_mask", name = "Shadoweave Mask", icon = I("INV_Helmet_27"), quality = 1,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "head", stats = { hp = 15, sp = 8 },
  shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 9411, key = "shadoweave_robe", name = "Shadoweave Robe", icon = I("INV_Chest_Cloth_28"), quality = 1,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "chest", stats = { hp = 23, sp = 15 },
  shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 9412, key = "shadoweave_gloves", name = "Shadoweave Gloves", icon = I("INV_Gauntlets_05"), quality = 1, classes = CASTERS, armorType = "cloth",
  slot = "hands", stats = { hp = 10, sp = 6 }, shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = CASTERS,
}

H.Armor{
  id = 9413, key = "shadoweave_pants", name = "Shadoweave Pants", icon = I("INV_Pants_09"), quality = 1,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "legs", stats = { hp = 15, sp = 9 },
  shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 9414, key = "shadoweave_shoulders", name = "Shadoweave Shoulders", icon = I("INV_Shoulder_25"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "shoulder",
  stats = { hp = 25, sp = 14 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 9415, key = "shadoweave_boots", name = "Shadoweave Boots", icon = I("INV_Boots_05"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "feet",
  stats = { armor = 12, hp = 25, sp = 12 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 9416, key = "sanguine_cuffs", name = "Sanguine Cuffs", icon = I("INV_Bracer_03"), quality = 2, minRound = 2,
  classes = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" }, armorType = "cloth", slot = "wrist",
  stats = { healing = 20, hp = 20, sp = 6 }, shopAffinities = { HUNTER = { bm = 0.35, mm = 0.75, surv = 1 } },
  shopClassWeights = { DRUID = 0.5, HUNTER = 0.35, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = { "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK", "DRUID" },
}

H.Armor{
  id = 9417, key = "sanguine_belt", name = "Sanguine Belt", icon = I("INV_Belt_04"), quality = 2, minRound = 2, classes = CASTERS, armorType = "cloth",
  slot = "waist", stats = { healing = 18, hp = 40, mana = 15 },
  shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 }, shopClasses = CASTERS,
}

H.Armor{
  id = 9419, key = "deathmist_mantle", name = "Deathmist Mantle", icon = I("INV_Shoulder_25"), quality = 3, minRound = 5, classes = CASTERS,
  armorType = "cloth", slot = "shoulder", stats = { healing = 16, hp = 45, sp = 20 },
  shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 }, shopClasses = CASTERS,
}

H.Jewel{
  id = 9423, key = "frostwolf_advisors_pendant", name = "Frostwolf Advisor's Pendant", icon = I("INV_Jewelry_Necklace_07"), quality = 3, minRound = 4,
  kind = "neck", classes = CASTERS, stats = { hp = 40, mana = 25, sp = 22 },
  shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 }, shopClasses = CASTERS,
}

H.Jewel{
  id = 9424, key = "sanguine_cape", name = "Sanguine Cape", icon = I("INV_Misc_Cape_02"), quality = 2, minRound = 2, kind = "cloak", classes = CASTERS,
  shape = S.h2, stats = { healing = 15, hp = 35, sp = 9 }, shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = CASTERS,
}

H.Jewel{
  id = 9425, key = "band_of_dark_dominion", name = "Band of Dark Dominion", icon = I("INV_Jewelry_Ring_24"), quality = 4, minRound = 8, kind = "ring",
  classes = CASTERS, stats = { crit = 3, hp = 50, sp = 34 }, shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 },
  shopClasses = CASTERS,
}

H.Jewel{
  id = 9426, key = "band_of_rumination", name = "Band of Rumination", icon = I("INV_Jewelry_Ring_16"), quality = 3, minRound = 4, kind = "ring",
  classes = CASTERS, stats = { mana = 45, regen = 2, sp = 11 },
  shopClassWeights = { DRUID = 0.5, MAGE = 0.5, PALADIN = 0.5, PRIEST = 0.5, SHAMAN = 0.5 }, shopClasses = CASTERS,
}

H.Weapon{
  id = 9427, key = "touch_of_chaos", name = "Touch of Chaos", icon = I("INV_Wand_09"), quality = 4, minRound = 8,
  classes = { "PRIEST", "MAGE", "WARLOCK" }, tags = { "wand", "spell", "ranged", "shadow" }, weaponType = "wand", weaponMin = 14, weaponMax = 21,
  speed = 1.8, stats = { hp = 30, sp = 28 },
  use = { cd = 1.8, effects = { { type = "damage", coef = 0.2, school = "shadow", noDodge = true, ranged = true, weaponSelf = true } } },
  shopWeight = 0.75,
}
