local ADDON, ns = ...
local H = ns.H
local I = H.I
local PRIEST = { "PRIEST" }

H.Weapon{ id = 6400, key = "acolytes_staff", name = "Bent Staff", icon = I("INV_Staff_08"), quality = 1, cost = 3, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 3, weaponMax = 5, speed = 2.9, stats = { sp = 4, healing = 4 }, noShop = true, starter = true }
H.Weapon{ id = 6405, key = "priest_benediction", name = "Benediction", icon = I("INV_Staff_41"), quality = 4, cost = 13, minRound = 9, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 16, weaponMax = 24, speed = 3, stats = { healing = 64, crit = 6, mana = 40, hp = 45 },
  triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, every = 3,
    effects = { { type = "tickHots", match = { key = "renew" } } } } } }
H.Weapon{ id = 6406, key = "anathema", name = "Anathema", icon = I("INV_Staff_41"), quality = 4, cost = 13, minRound = 9, classes = PRIEST, weaponType = "staff", hands = 2, weaponMin = 16, weaponMax = 24, speed = 3, stats = { sp = 58, mana = 40, hp = 45 },
  triggers = { { on = "dotTick", match = { tag = "shadow" }, everyAmount = 50, effects = { { type = "cdr", target = "all", match = { key = "mind_blast" }, amount = 1, clampReady = true } } } } }

H.Armor{ id = 6422, key = "truefaith_vestments", name = "Truefaith Vestments", icon = I("INV_Chest_Cloth_31"), quality = 4, cost = 12, minRound = 8, classes = PRIEST, armorType = "cloth", slot = "chest", stats = { healing = 72, hp = 65, regen = 2, armor = 16 } }
H.Jewel{ id = 6440, key = "royal_seal_priest", name = "Royal Seal of Eldre'Thalas", icon = I("INV_Jewelry_Talisman_06"), kind = "trinket", quality = 3, cost = 7, minRound = 3, classes = PRIEST, stats = { healing = 28, regen = 1 } }
H.Jewel{ id = 6441, key = "blessed_prayer_beads", name = "Blessed Prayer Beads", icon = I("INV_Jewelry_Necklace_11"), kind = "trinket", quality = 3, cost = 8, minRound = 5, classes = PRIEST, stats = { healing = 10 },
  use = { cd = 24, initialDelay = 2, effects = { { type = "buff", stat = "healing", value = 45, duration = 8, key = "blessed_prayer_beads", name = "Blessed Prayer Beads" } } } }
H.Jewel{ id = 6442, key = "hazzarahs_charm_of_healing", name = "Hazza'rah's Charm of Healing", icon = I("INV_Jewelry_Necklace_19"), kind = "trinket", quality = 4, cost = 10, minRound = 7, classes = PRIEST, stats = { healing = 14 },
  use = { cd = 24, initialDelay = 3, effects = { { type = "buff", target = "all", match = { tag = "heal" }, stat = "haste", value = 35, duration = 8, key = "hazzarah_healing", name = "Hazza'rah's Charm of Healing" }, { type = "resource", resource = "mana", amount = 20 } } } }

ns.RegisterSet{ key = "devout", name = "Vestments of the Devout", bonuses = {
  [2] = { stats = { healing = 20, mana = 20 } },
  [4] = { triggers = { { on = "healed", everyAmount = 35, effects = { { type = "absorb", amount = 8, coef = 0.15 } } } }, text = "Restoring 35 Health grants a shield that absorbs 8 damage plus 15% of your Healing Power." },
} }
ns.RegisterSet{ key = "prophecy", name = "Vestments of Prophecy", bonuses = {
  [2] = { triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, everyAmount = 60,
    effects = { { type = "resource", resource = "mana", amount = 6 } } } }, text = "Consuming 60 Mana with Holy healing spells restores 6 Mana." },
  [4] = { triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, every = 4,
    effects = { { type = "cast", key = "renew", consumeCooldown = true } } } }, text = "After every 4 Holy healing spells that consume Mana, cast your Renew without consuming Mana and begin its normal cooldown." },
  [6] = { double = { tag = "heal" }, flags = { "revive" }, text = "Your healing spells take effect twice whenever you cast them. Once per battle, lethal damage restores you to full Health." },
} }
ns.RegisterSet{ key = "transcendence", name = "Vestments of Transcendence", bonuses = {
  [2] = { mods = { match = { tag = "shadow" }, dmgPct = 20 }, text = "Increases the damage of your Shadow abilities by 20%." },
  [4] = { triggers = { { on = "dotTick", match = { tag = "shadow" }, everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 8 }, { type = "absorb", amount = 8, coef = 0.1 } } } }, text = "Dealing 40 periodic Shadow damage restores 8 Mana and grants a shield that absorbs 8 damage plus 10% of your Healing Power." },
  [6] = { double = { tag = "shadow" }, triggers = { { on = "anyCrit", healing = false, match = { tag = "shadow" }, effects = { { type = "tickDots", match = { tag = "shadow" } } } } }, text = "Your Shadow spells take effect twice whenever you cast them. Your Shadow critical strikes cause each of your active Shadow damage over time effects to deal one additional tick of damage." },
} }
ns.RegisterSet{ key = "faith", name = "Vestments of Faith", bonuses = {
  [2] = { stats = { healing = 20, armor = 15 } },
  [4] = { triggers = { { on = "absorbed", everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 8 }, { type = "cdr", target = "all", match = { key = "smite" }, amount = 1, clampReady = true } } } }, text = "Absorbing 30 damage restores 8 Mana and reduces the remaining cooldown of Smite by 1 second." },
  [6] = { double = { key = "power_word_shield" }, triggers = { { on = "absorbed", everyAmount = 30, effects = { { type = "cast", key = "smite" } } } }, text = "Power Word: Shield grants its absorb twice. Absorbing 30 damage casts your Smite without consuming Mana." },
} }

local SET_ICONS = { head = "INV_Helmet_24", shoulder = "INV_Shoulder_02", chest = "INV_Chest_Cloth_03", hands = "INV_Gauntlets_14", legs = "INV_Pants_07", feet = "INV_Boots_05", wrist = "INV_Bracer_09", waist = "INV_Belt_11" }

H.SetPieces{ key = "devout", firstId = 6460, tag = "holy", classes = PRIEST, armorType = "cloth", quality = 3, cost = 6, rounds = { 4, 4, 4, 4 },
  slots = { "wrist", "waist", "hands", "feet" }, stats = { healing = 18, sp = 6, hp = 15, mana = 12, armor = 3 }, icons = SET_ICONS,
  names = { "Devout Bracers", "Devout Belt", "Devout Gloves", "Devout Sandals" } }
H.SetPieces{ key = "prophecy", firstId = 6470, tag = "holy", classes = PRIEST, armorType = "cloth", quality = 4, cost = 10, rounds = { 4, 5, 7, 9, 11, 12 },
  stats = { healing = 26, sp = 8, hp = 18, mana = 14, armor = 4 }, icons = SET_ICONS,
  names = { "Circlet of Prophecy", "Mantle of Prophecy", "Robes of Prophecy", "Gloves of Prophecy", "Pants of Prophecy", "Boots of Prophecy" } }
H.SetPieces{ key = "transcendence", firstId = 6480, tag = "shadow", classes = PRIEST, armorType = "cloth", quality = 4, cost = 10, rounds = { 5, 6, 8, 10, 12, 13 },
  stats = { sp = 26, healing = 10, hp = 20, mana = 16, armor = 4 }, icons = SET_ICONS,
  names = { "Halo of Transcendence", "Pauldrons of Transcendence", "Robes of Transcendence", "Handguards of Transcendence", "Leggings of Transcendence", "Boots of Transcendence" } }
H.SetPieces{ key = "faith", firstId = 6490, tag = "discipline", classes = PRIEST, armorType = "cloth", quality = 4, cost = 10, rounds = { 6, 7, 9, 11, 13, 14 },
  stats = { healing = 28, sp = 12, hp = 24, mana = 18, armor = 6 }, icons = SET_ICONS,
  names = { "Circlet of Faith", "Shoulderpads of Faith", "Robe of Faith", "Gloves of Faith", "Leggings of Faith", "Sandals of Faith" } }
