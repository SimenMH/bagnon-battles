local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local CASTER_STAFF = { "DRUID", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }
local CASTER_MACE = { "DRUID", "PALADIN", "PRIEST", "SHAMAN" }
local CASTERS = { "DRUID", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }
local SPELL_USERS = { "DRUID", "HUNTER", "PALADIN", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }
local EARLY_ARMOR = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }
local PHYSICAL_JEWELRY = { "WARRIOR", "HUNTER", "DRUID" }

H.Weapon{ id = 105, key = "battle_axe", name = "Battle Axe", icon = I("inv_throwingaxe_05"), quality = 2, minRound = 2, weaponType = "axe", hands = 2, classes = H.ALL_AXE, weaponMin = 13, weaponMax = 19, speed = 3.4,
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", weapon = true, weaponPct = 0.5, school = "physical" } } } } }
H.Weapon{ id = 106, key = "claymore", name = "Claymore", icon = I("inv_sword_40"), quality = 2, minRound = 2, weaponType = "sword", hands = 2, classes = H.ALL_SWORD, weaponMin = 12, weaponMax = 19, speed = 3.2,
  triggers = { { on = "crit", effects = { { type = "dot", key = "claymore_cut", school = "physical", tick = 2, coef = 0.04, duration = 6 } } } } }
H.Weapon{ id = 107, key = "war_hammer", name = "War Hammer", icon = I("inv_hammer_03"), quality = 2, minRound = 2, weaponType = "mace", hands = 2, classes = H.ALL_MACE, weaponMin = 13, weaponMax = 20, speed = 3.6,
  triggers = { { on = "hit", chance = 15, icd = 4, effects = { { type = "stun", duration = 0.5 } } } } }
H.Weapon{ id = 108, key = "cruel_barb", name = "Cruel Barb", icon = I("inv_sword_24"), quality = 2, minRound = 3, weaponType = "sword", classes = H.ALL_SWORD, weaponMin = 5, weaponMax = 8, speed = 1.8, stats = { ap = 10 }, tags = { "poison" },
  triggers = { { on = "hit", effects = { { type = "dot", key = "barb_poison", school = "nature", tick = 1, duration = 6, stack = true, maxStacks = 5 } } } } }
H.Weapon{ id = 109, key = "staff_of_jordan", name = "Staff of Jordan", icon = I("INV_Staff_13"), quality = 2, minRound = 3, weaponType = "staff", hands = 2, classes = CASTER_STAFF, weaponMin = 10, weaponMax = 16, speed = 3.0, stats = { sp = 12, healing = 12 },
  triggers = { { on = "anyUse", match = { tag = "spell" }, chance = 20, effects = { { type = "resource", resource = "mana", amount = 8 } } } } }
H.Weapon{ id = 110, key = "shadowfang", name = "Shadowfang", icon = I("inv_sword_13"), quality = 3, minRound = 4, weaponType = "sword", classes = H.ALL_SWORD, weaponMin = 6, weaponMax = 11, speed = 2.0,
  triggers = { { on = "hit", chance = 20, effects = { { type = "dot", key = "shadowfang", school = "shadow", tick = 3, duration = 5 } } } } }
H.Weapon{ id = 111, key = "ironfoe", name = "Ironfoe", icon = I("spell_frost_frostbrand"), quality = 3, minRound = 5, weaponType = "mace", classes = H.ALL_MACE, weaponMin = 7, weaponMax = 13, speed = 2.4,
  triggers = { { on = "hit", chance = 12, effects = { { type = "extraAttack", count = 2 } } } } }
H.Weapon{ id = 112, key = "ravager", name = "Ravager", icon = I("inv_weapon_halberd_05"), quality = 3, minRound = 6, weaponType = "axe", hands = 2, classes = H.ALL_AXE, weaponMin = 16, weaponMax = 25, speed = 3.5,
  triggers = { { on = "hit", chance = 10, effects = { { type = "buff", stat = "haste", value = 60, duration = 4, key = "ravager_whirl", name = "Bladestorm" } } } } }
H.Weapon{ id = 113, key = "bonebiter", name = "Bonebiter", icon = I("inv_axe_04"), quality = 3, minRound = 6, weaponType = "axe", hands = 2, classes = H.ALL_AXE, weaponMin = 18, weaponMax = 28, speed = 3.4, stats = { ap = 18 } }
H.Weapon{ id = 114, key = "nightblade", name = "Nightblade", icon = I("inv_sword_02"), quality = 3, minRound = 5, weaponType = "sword", classes = H.ALL_SWORD, weaponMin = 7, weaponMax = 12, speed = 2.1,
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", min = 6, max = 9, school = "shadow", coef = 0.1, noDodge = true } } } } }
H.Weapon{ id = 115, key = "smites_mighty_hammer", name = "Smite's Mighty Hammer", icon = I("inv_hammer_09"), quality = 3, minRound = 4, weaponType = "mace", hands = 2, classes = H.ALL_MACE, weaponMin = 14, weaponMax = 22, speed = 3.6, stats = { hp = 8 } }
H.Weapon{ id = 116, key = "dalrends_sacred_charge", name = "Dal'Rend's Sacred Charge", icon = I("INV_Sword_43"), quality = 3, minRound = 5, weaponType = "sword", classes = H.ALL_SWORD, weaponMin = 10, weaponMax = 17, speed = 2.3, set = "dalrend", stats = { crit = 1, ap = 16 } }
H.Weapon{ id = 117, key = "obsidian_edged_blade", name = "Obsidian Edged Blade", icon = I("inv_sword_28"), quality = 4, minRound = 11, weaponType = "sword", hands = 2, classes = H.ALL_SWORD, weaponMin = 26, weaponMax = 38, speed = 3.4, stats = { ap = 28 } }
H.Weapon{ id = 118, key = "hand_of_edward_the_odd", name = "Hand of Edward the Odd", icon = I("inv_mace_14"), quality = 4, minRound = 9, weaponType = "mace", classes = CASTER_MACE, weaponMin = 8, weaponMax = 15, speed = 2.5, stats = { sp = 18, healing = 18 },
  triggers = { { on = "hit", chance = 15, effects = { { type = "cdr", target = "all", match = { tag = "spell" }, amount = 1.5 } } } } }
H.Weapon{ id = 119, key = "staff_of_dominance", name = "Staff of Dominance", icon = I("inv_staff_13"), quality = 4, minRound = 10, weaponType = "staff", hands = 2, classes = CASTER_STAFF, weaponMin = 14, weaponMax = 22, speed = 3.0, stats = { sp = 32, crit = 3 } }
H.Weapon{ id = 120, key = "staff_of_the_shadow_flame", name = "Staff of the Shadow Flame", icon = I("inv_staff_06"), quality = 4, minRound = 12, weaponType = "staff", hands = 2, classes = CASTER_STAFF, weaponMin = 16, weaponMax = 24, speed = 2.9, stats = { sp = 48, crit = 5 } }
H.Weapon{ id = 121, key = "blackblade_of_shahram", name = "Blackblade of Shahram", icon = I("inv_sword_29"), quality = 4, minRound = 10, weaponType = "sword", hands = 2, classes = H.ALL_SWORD, weaponMin = 22, weaponMax = 34, speed = 3.3,
  triggers = { { on = "hit", chance = 12, effects = { { type = "buff", stat = "ap", value = 15, duration = 10, key = "shahram", name = "Curse of Shahram" } } } } }
H.Weapon{ id = 122, key = "perditions_blade", name = "Perdition's Blade", icon = I("inv_sword_48"), quality = 4, minRound = 11, weaponType = "dagger", classes = H.ALL_DAGGER, weaponMin = 7, weaponMax = 13, speed = 1.8,
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", min = 8, max = 12, school = "fire", noDodge = true } } } } }

ns.RegisterItem{ id = 130, key = "wooden_shield", name = "Wooden Shield", icon = I("INV_Shield_09"), kind = "shield", quality = 1, shape = S.sq, classes = H.ALL_SHIELD, stats = { armor = 12, block = 6, blockChance = 25 }, tags = { "shield", "defensive" } }
ns.RegisterItem{ id = 132, key = "crest_of_retribution", name = "Crest of Retribution", icon = I("inv_shield_19"), kind = "shield", quality = 3, minRound = 6, shape = S.sq, classes = H.ALL_SHIELD, stats = { armor = 26, block = 14, blockChance = 30, thorns = 2, hp = 20 }, tags = { "shield", "defensive" } }
ns.RegisterItem{ id = 133, key = "drillborer_disk", name = "Drillborer Disk", icon = I("inv_shield_10"), kind = "shield", quality = 4, minRound = 10, shape = S.sq, classes = H.ALL_SHIELD, stats = { armor = 36, block = 20, blockChance = 35, thorns = 4, hp = 25 }, tags = { "shield", "defensive" } }
ns.RegisterItem{ id = 134, key = "elementium_reinforced_bulwark", name = "Elementium Reinforced Bulwark", icon = I("inv_shield_17"), kind = "shield", quality = 4, minRound = 13, shape = S.sq, classes = H.ALL_SHIELD, stats = { armor = 46, block = 26, blockChance = 40, hp = 40 }, tags = { "shield", "defensive" } }

H.Jewel{ id = 250, key = "mark_of_the_chosen", name = "Mark of the Chosen", icon = I("inv_jewelry_talisman_08"), kind = "trinket", quality = 3, minRound = 4, stats = {},
  triggers = { { on = "damaged", chance = 10, icd = 5, effects = {
    { type = "buff", stat = "ap", value = 60, duration = 6, key = "mark_chosen", name = "Mark of the Chosen" },
    { type = "buff", stat = "sp", value = 24, duration = 6, key = "mark_chosen_spell", name = "Mark of the Chosen" },
    { type = "buff", stat = "armor", value = 20, duration = 6, key = "mark_chosen_armor", name = "Mark of the Chosen" },
  } } } }
H.Jewel{ id = 252, key = "hand_of_justice", name = "Hand of Justice", icon = I("INV_Jewelry_Talisman_01"), kind = "trinket", quality = 3, minRound = 5, stats = { ap = 6 },
  triggers = { { on = "resourceSpent", everyAmount = 30, effects = { { type = "cdr", target = "neighbors", match = { tag = "autoattack" }, amount = 1.0 } } } } }
H.Jewel{ id = 254, key = "talisman_of_ephemeral_power", name = "Talisman of Ephemeral Power", icon = I("inv_misc_stonetablet_11"), kind = "trinket", quality = 4, minRound = 9, classes = CASTERS, stats = {},
  use = { cd = 25, initialPct = 0.1, effects = { { type = "buff", stat = "sp", value = 60, duration = 12, key = "ephemeral", name = "Ephemeral Power" } } }, tags = { "spell" } }
H.Jewel{ id = 255, key = "earthstrike", name = "Earthstrike", icon = I("spell_nature_abolishmagic"), kind = "trinket", quality = 4, minRound = 10, stats = {}, shopClasses = H.PHYSICAL,
  use = { cd = 25, initialPct = 0.1, effects = { { type = "buff", stat = "ap", value = 60, duration = 12, key = "earthstrike", name = "Earthstrike" } } }, tags = { "melee" } }
H.Jewel{ id = 257, key = "second_wind", name = "Second Wind", icon = I("inv_jewelry_talisman_06"), kind = "trinket", quality = 3, minRound = 6, stats = {},
  use = { reactive = true, cd = 15, condition = "below50", effects = { { type = "heal", pctMax = 0.15 } } }, tags = { "heal" } }
H.Jewel{ id = 258, key = "darkmoon_card_heroism", name = "Darkmoon Card: Heroism", icon = I("inv_misc_ticket_tarot_heroism_01"), kind = "trinket", quality = 4, minRound = 11, stats = { hp = 10 },
  triggers = { { on = "adjacentHit", match = { tag = "autoattack" }, chance = 25, icd = 2, effects = { { type = "heal", min = 6, max = 8 } } } } }

H.Jewel{ id = 259, key = "diamond_flask", name = "Diamond Flask", icon = I("INV_Drink_01"), kind = "trinket", quality = 3, minRound = 3, classes = { "WARRIOR" }, tags = { "heal", "melee" }, unique = true,
  triggers = { { on = "healed", effects = { { type = "bank", key = "flask", fraction = 0.25 } } }, { on = "regularHit", detail = true, match = { tag = "melee" }, effects = { { type = "damage", school = "physical", spendBank = "flask", noCrit = true, noDodge = true } } } } }

H.Weapon{ id = 350, key = "worn_dagger", name = "Worn Dagger", icon = I("inv_weapon_shortblade_05"), quality = 1, cost = 3, weaponType = "dagger", classes = H.ALL_DAGGER, weaponMin = 3, weaponMax = 5, speed = 1.7, stats = { ap = 4 } }
H.Weapon{ id = 351, key = "walking_stick", name = "Walking Stick", icon = I("inv_staff_08"), quality = 1, cost = 4, weaponType = "staff", hands = 2, classes = CASTER_STAFF, weaponMin = 6, weaponMax = 9, speed = 3.2, stats = { sp = 8, healing = 6 } }
H.Weapon{ id = 352, key = "hunting_bow", name = "Hunting Bow", icon = I("inv_weapon_bow_03"), quality = 1, cost = 4, weaponType = "bow", classes = { "HUNTER" }, weaponMin = 14, weaponMax = 17, speed = 2.6, stats = { ap = 6 } }
H.Armor{ id = 353, key = "tanned_leather_jerkin", name = "Tanned Leather Jerkin", icon = I("inv_chest_wolf"), quality = 1, cost = 4, armorType = "leather", slot = "chest", classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, stats = { ap = 10, armor = 12, hp = 15 } }
H.Armor{ id = 354, key = "thin_cloth_armor", name = "Thin Cloth Armor", icon = I("inv_shirt_red_01"), quality = 1, cost = 3, armorType = "cloth", slot = "chest", classes = EARLY_ARMOR, stats = { hp = 60, armor = 18 } }
H.Armor{ id = 355, key = "simple_robe", name = "Simple Robe", icon = I("inv_chest_cloth_18"), quality = 1, cost = 4, armorType = "cloth", slot = "chest", classes = CASTERS, stats = { sp = 10, healing = 6, hp = 15 } }
H.Weapon{ id = 356, key = "arcanite_reaper", name = "Arcanite Reaper", icon = I("inv_axe_09"), quality = 3, cost = 10, minRound = 6, weaponType = "axe", hands = 2, classes = H.ALL_AXE, weaponMin = 23, weaponMax = 33, speed = 3.8, stats = { ap = 30, hp = 35 } }
H.Weapon{ id = 357, key = "zinrokh_destroyer_of_worlds", name = "Zin'rokh, Destroyer of Worlds", icon = I("inv_sword_55"), quality = 4, cost = 14, minRound = 11, weaponType = "sword", hands = 2, classes = H.ALL_SWORD, weaponMin = 34, weaponMax = 48, speed = 3.8, stats = { ap = 50, hp = 80 } }
H.Armor{ id = 358, key = "edgemasters_handguards", name = "Edgemaster's Handguards", icon = I("inv_gauntlets_30"), quality = 4, cost = 10, minRound = 7, armorType = "mail", slot = "hands", classes = { "WARRIOR", "HUNTER", "PALADIN", "SHAMAN" }, stats = { ap = 40, haste = 12, armor = 12 } }
H.Jewel{ id = 359, key = "lifegiving_gem", name = "Lifegiving Gem", icon = I("inv_misc_gem_pearl_05"), kind = "trinket", quality = 4, cost = 10, minRound = 8, classes = { "WARRIOR" }, stats = { hp = 80 }, tags = { "heal" },
  use = { reactive = true, cd = 25, condition = "below35", effects = { { type = "heal", pctMax = 0.3 } } } }
ns.RegisterItem{ id = 360, key = "skullflame_shield", name = "Skullflame Shield", icon = I("inv_shield_01"), kind = "shield", quality = 4, cost = 11, minRound = 9, shape = S.sq, classes = H.ALL_SHIELD, stats = { armor = 32, block = 18, blockChance = 35, hp = 30 }, tags = { "shield", "heal" },
  triggers = { { on = "block", effects = { { type = "heal", min = 6, max = 9 }, { type = "damage", min = 4, max = 6, school = "fire", noDodge = true } } } } }
H.Jewel{ id = 361, key = "briarwood_reed", name = "Briarwood Reed", icon = I("inv_misc_root_02"), kind = "trinket", quality = 3, cost = 9, minRound = 6, classes = SPELL_USERS, stats = { sp = 24, hp = 20 } }

H.Jewel{ id = 370, key = "mark_of_fordring", name = "Mark of Fordring", icon = I("inv_jewelry_talisman_07"), kind = "neck", quality = 3, cost = 7, minRound = 4, classes = PHYSICAL_JEWELRY, stats = { ap = 28, crit = 5 } }
H.Jewel{ id = 371, key = "medallion_of_grand_marshal_morris", name = "Medallion of Grand Marshal Morris", icon = I("inv_jewelry_talisman_08"), kind = "neck", quality = 3, cost = 7, minRound = 4, classes = PHYSICAL_JEWELRY, stats = { hp = 75, armor = 12, dodge = 3 } }
H.Jewel{ id = 372, key = "onyxia_tooth_pendant", name = "Onyxia Tooth Pendant", icon = I("inv_jewelry_necklace_09"), kind = "neck", quality = 4, cost = 11, minRound = 9, classes = PHYSICAL_JEWELRY, stats = { ap = 48, crit = 7, hp = 30 } }
H.Jewel{ id = 373, key = "cape_of_the_brotherhood", name = "Cape of the Brotherhood", icon = I("inv_misc_cape_08"), kind = "cloak", quality = 3, cost = 5, minRound = 2, classes = PHYSICAL_JEWELRY, shape = S.h2, stats = { ap = 14, crit = 3, armor = 6, hp = 20 } }
H.Jewel{ id = 374, key = "spritecaster_cape", name = "Spritecaster Cape", icon = I("inv_misc_cape_20"), kind = "cloak", quality = 3, cost = 7, minRound = 5, classes = { "HUNTER", "DRUID" }, shape = S.h2, stats = { sp = 20, healing = 12, crit = 3 } }
H.Jewel{ id = 375, key = "hide_of_the_wild", name = "Hide of the Wild", icon = I("inv_misc_cape_01"), kind = "cloak", quality = 4, cost = 11, minRound = 8, classes = { "DRUID" }, shape = S.h2, stats = { healing = 44, hp = 60, dr = 4 } }
H.Jewel{ id = 376, key = "seal_of_wrynn", name = "Seal of Wrynn", icon = I("inv_jewelry_ring_05"), kind = "ring", quality = 3, cost = 6, minRound = 2, stats = { hp = 20, ap = 6, sp = 6, healing = 6, mana = 10, crit = 1 } }
H.Jewel{ id = 377, key = "blackstone_ring", name = "Blackstone Ring", icon = I("inv_jewelry_ring_17"), kind = "ring", quality = 3, cost = 7, minRound = 4, classes = PHYSICAL_JEWELRY, stats = { ap = 24, crit = 5, hp = 20 } }
H.Jewel{ id = 378, key = "songstone_of_ironforge", name = "Songstone of Ironforge", icon = I("inv_jewelry_ring_05"), kind = "ring", quality = 3, cost = 7, minRound = 4, classes = { "HUNTER", "DRUID" }, stats = { sp = 22, healing = 16, mana = 20 } }
H.Jewel{ id = 379, key = "ring_of_fury", name = "Ring of Fury", icon = I("inv_jewelry_ring_ahnqiraj_04"), kind = "ring", quality = 3, cost = 6, minRound = 2, classes = { "WARRIOR" }, stats = { hp = 40, ap = 12 }, tags = { "heal" },
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "heal", pctMax = 0.05 } } } } }

H.Weapon{ id = 380, key = "spiked_club", name = "Spiked Club", icon = I("inv_mace_14"), quality = 1, cost = 4, weaponType = "mace", hands = 2, classes = H.ALL_MACE, weaponMin = 6, weaponMax = 9, speed = 3.2, stats = { ap = 8, hp = 10 } }
H.Weapon{ id = 381, key = "oak_mallet", name = "Oak Mallet", icon = I("inv_hammer_15"), quality = 2, cost = 6, minRound = 2, weaponType = "mace", hands = 2, classes = H.ALL_MACE, weaponMin = 10, weaponMax = 14, speed = 3.5, stats = { ap = 12, armor = 18, hp = 15 } }
H.Weapon{ id = 382, key = "carving_knife", name = "Carving Knife", icon = I("inv_weapon_shortblade_01"), quality = 2, cost = 5, minRound = 2, weaponType = "dagger", classes = H.ALL_DAGGER, weaponMin = 4, weaponMax = 6, speed = 1.8, stats = { ap = 14, crit = 3 } }
H.Armor{ id = 383, key = "fine_leather_gloves", name = "Fine Leather Gloves", icon = I("inv_gauntlets_05"), quality = 1, cost = 3, armorType = "leather", slot = "hands", classes = { "DRUID", "HUNTER" }, stats = { healing = 8, mana = 15, armor = 4 } }
H.Armor{ id = 384, key = "prospectors_cuffs", name = "Prospector's Cuffs", icon = I("inv_bracer_07"), quality = 2, cost = 4, minRound = 2, armorType = "leather", slot = "wrist", classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, stats = { ap = 10, crit = 2, armor = 4, hp = 8 } }
H.Armor{ id = 385, key = "fine_leather_boots", name = "Fine Leather Boots", icon = I("inv_boots_06"), quality = 1, cost = 3, armorType = "leather", slot = "feet", classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, stats = { armor = 10, hp = 15 } }
H.Armor{ id = 386, key = "fine_leather_belt", name = "Fine Leather Belt", icon = I("inv_belt_04"), quality = 2, cost = 4, minRound = 2, armorType = "leather", slot = "waist", classes = { "WARRIOR", "HUNTER", "DRUID", "PALADIN", "ROGUE", "SHAMAN" }, stats = { ap = 8, armor = 4, hp = 10 } }
