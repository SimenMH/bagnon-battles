local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S

ns.RegisterItem{ id = 300, key = "bindings_left", name = "Left Half of Bindings of the Windseeker", icon = I("spell_ice_lament"), kind = "material", quality = 5, cost = 14, minRound = 12, shape = S.one, unique = true, classes = H.ALL_SWORD,
  shopClasses = H.PHYSICAL_SWORD, flavor = "Thunderaan the Windseeker's power, bound in half." }
ns.RegisterItem{ id = 301, key = "bindings_right", name = "Right Half of Bindings of the Windseeker", icon = I("spell_ice_lament"), kind = "material", quality = 5, cost = 14, minRound = 12, shape = S.one, unique = true, classes = H.ALL_SWORD,
  shopClasses = H.PHYSICAL_SWORD, flavor = "Place both halves next to an Elementium Bar." }
ns.RegisterItem{ id = 302, key = "elementium_bar", name = "Elementium Bar", icon = I("inv_ingot_thorium"), kind = "material", quality = 5, cost = 12, minRound = 12, shape = S.one, unique = true, classes = H.ALL_SWORD,
  shopClasses = H.PHYSICAL_SWORD, flavor = "Forged from the essence of the Firelord's enemies." }
H.Weapon{ id = 303, key = "thunderfury", name = "Thunderfury, Blessed Blade of the Windseeker", icon = I("INV_Sword_39"), quality = 5, cost = 40, craftedCost = 40, minRound = 12, noShop = true, craftable = true, unique = true,
  weaponType = "sword", classes = H.ALL_SWORD, weaponMin = 36, weaponMax = 52, speed = 1.9, stats = { ap = 30, crit = 5 },
  triggers = { { on = "hit", chance = 25, effects = {
    { type = "damage", min = 35, max = 45, school = "nature", noDodge = true },
    { type = "debuff", stat = "haste", value = 35, duration = 6, key = "thunderfury_slow" },
    { type = "debuff", stat = "armor", value = 20, duration = 12, key = "thunderfury_armor", stack = true, maxStacks = 5 },
  } } },
  flavor = "Did someone say..." }

H.Weapon{ id = 304, key = "sulfuron_hammer", name = "Sulfuron Hammer", icon = I("INV_Hammer_Unique_Sulfuras"), quality = 4, cost = 20, minRound = 12, weaponType = "mace", hands = 2, classes = H.ALL_MACE, shape = S.r23, unique = true,
  weaponMin = 26, weaponMax = 36, speed = 3.7, stats = { hp = 40, ap = 20 },
  triggers = { { on = "hit", chance = 20, effects = { { type = "damage", min = 12, max = 18, school = "fire", noDodge = true } } } } }
ns.RegisterItem{ id = 305, key = "eye_of_sulfuras", name = "Eye of Sulfuras", icon = I("inv_misc_gem_pearl_05"), kind = "material", quality = 5, cost = 16, minRound = 14, shape = S.one, unique = true, classes = H.ALL_MACE,
  shopClasses = H.PHYSICAL_MACE, flavor = "Ragnaros's gaze, trapped in stone." }
H.Weapon{ id = 306, key = "sulfuras", name = "Sulfuras, Hand of Ragnaros", icon = I("INV_Hammer_Unique_Sulfuras"), quality = 5, cost = 36, craftedCost = 36, minRound = 14, noShop = true, craftable = true, unique = true,
  weaponType = "mace", hands = 2, classes = H.ALL_MACE, shape = S.r23, weaponMin = 60, weaponMax = 85, speed = 3.7, stats = { hp = 160, ap = 50, thorns = 18 },
  triggers = { { on = "hit", chance = 30, effects = {
    { type = "damage", min = 45, max = 60, school = "fire", noDodge = true },
    { type = "dot", key = "sulfuras_immolate", school = "fire", tick = 8, duration = 10 },
  } } },
  flavor = "By fire be purged!" }

ns.RegisterRecipe{ inputs = { "bindings_left", "bindings_right", "elementium_bar" }, output = "thunderfury" }
ns.RegisterRecipe{ inputs = { "sulfuron_hammer", "eye_of_sulfuras" }, output = "sulfuras" }
