local ADDON, ns = ...
local I = ns.icon
local startX, startY = ns.START_X, ns.START_Y

ns.RegisterClass{
  key = "WARRIOR", id = 1, order = 1, name = "Warrior", armor = "plate", playable = true,
  color = { r = 0.78, g = 0.61, b = 0.43 }, icon = I("ClassIcon_Warrior"),
  primary = "rage", resources = { rage = { max = 100, start = 0, regen = 0 } }, baseArmor = 14, baseAP = 35, dualWield = true,
  specs = { { tag = "arms", name = "Arms", signature = "mortal_strike" }, { tag = "fury", name = "Fury", signature = "bloodthirst" }, { tag = "prot", name = "Protection", signature = "shield_slam" } },
  starter = { { key = "worn_axe", x = startX, y = startY, rot = 0 }, { key = "heroic_strike", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Warriors fight in melee with swords, axes and maces, or with a sword and shield. They gain rage from dealing and taking damage, which they spend on their abilities.",
}

ns.RegisterClass{
  key = "PALADIN", id = 2, order = 2, name = "Paladin", armor = "plate", playable = true,
  color = { r = 0.96, g = 0.55, b = 0.73 }, icon = I("ClassIcon_Paladin"),
  primary = "mana", resources = { mana = { max = 80, regen = 4 } }, baseArmor = 20,
  specs = { { tag = "holy", name = "Holy", signature = "holy_shock" }, { tag = "protection", name = "Protection", signature = "holy_shield" }, { tag = "retribution", name = "Retribution", signature = "repentance" } },
  starter = { { key = "worn_mace", x = startX, y = startY, rot = 0 }, { key = "seal_of_righteousness", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Paladins fight with swords, axes and maces, or with a weapon and shield. They use seals, blessings and auras to support their attacks, and can heal themselves with Holy magic.",
}

ns.RegisterClass{
  key = "HUNTER", id = 3, order = 3, name = "Hunter", armor = "mail", playable = true,
  color = { r = 0.67, g = 0.83, b = 0.45 }, icon = I("ClassIcon_Hunter"),
  primary = "mana", resources = { mana = { max = 80, regen = 6 } }, baseArmor = 12, dualWield = true,
  specs = { { tag = "bm", name = "Beast Mastery", signature = "bestial_wrath" }, { tag = "mm", name = "Marksmanship", signature = "aimed_shot" }, { tag = "surv", name = "Survival", signature = "wyvern_sting" } },
  starter = { { key = "worn_shortbow", x = startX, y = startY, rot = 0 }, { key = "rough_arrows", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Hunters attack from range with bows and guns and bring a pet into battle that fights alongside them. They can also lay traps and apply stings that deal damage over time.",
}

ns.RegisterClass{
  key = "ROGUE", id = 4, order = 4, name = "Rogue", armor = "leather", playable = true,
  color = { r = 1.00, g = 0.96, b = 0.41 }, icon = I("ClassIcon_Rogue"),
  primary = "energy", resources = { energy = { max = 100, start = 100, regen = 10 }, combo = { max = 5, start = 0, regen = 0 } }, baseArmor = 6, dualWield = true,
  specs = { { tag = "assassination", name = "Assassination", signature = "cold_blood" }, { tag = "combat", name = "Combat", signature = "adrenaline_rush" }, { tag = "subtlety", name = "Subtlety", signature = "premeditation" } },
  starter = { { key = "worn_dagger", x = startX, y = startY, rot = 0 }, { key = "sinister_strike", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Rogues fight with two weapons and use energy to build combo points for finishing moves. They can coat their weapons with poisons and use stealth to open with attacks like Ambush.",
}

ns.RegisterClass{
  key = "PRIEST", id = 5, order = 5, name = "Priest", armor = "cloth", playable = true,
  color = { r = 1.00, g = 1.00, b = 1.00 }, icon = I("ClassIcon_Priest"),
  primary = "mana", resources = { mana = { max = 90, regen = 5 } }, baseArmor = 2,
  specs = { { tag = "discipline", name = "Discipline", signature = "power_infusion" }, { tag = "holy", name = "Holy", signature = "holy_nova" }, { tag = "shadow", name = "Shadow", signature = "shadowform" } },
  starter = { { key = "acolytes_staff", x = startX, y = startY, rot = 0 }, { key = "smite", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Priests use Holy magic to heal and shield themselves, or Shadow magic to wear down their opponent. They can drain health and mana, and use wands between spells.",
}

ns.RegisterClass{
  key = "SHAMAN", id = 7, order = 6, name = "Shaman", armor = "mail", playable = true,
  color = { r = 0.00, g = 0.44, b = 0.87 }, icon = I("ClassIcon_Shaman"),
  primary = "mana", resources = { mana = { max = 80, regen = 4 } }, baseArmor = 12,
  specs = { { tag = "elemental", name = "Elemental", signature = "elemental_mastery" }, { tag = "enhancement", name = "Enhancement", signature = "stormstrike" }, { tag = "restoration", name = "Restoration", signature = "mana_tide_totem" } },
  starter = { { key = "worn_dagger", x = startX, y = startY, rot = 0 }, { key = "lightning_bolt", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Shamans fight with elemental spells, weapon enchantments and totems. They can focus on lightning and shocks, melee attacks with Windfury, or healing.",
}

ns.RegisterClass{
  key = "MAGE", id = 8, order = 7, name = "Mage", armor = "cloth", playable = true,
  color = { r = 0.25, g = 0.78, b = 0.92 }, icon = I("ClassIcon_Mage"),
  primary = "mana", resources = { mana = { max = 100, regen = 5 } }, baseArmor = 2,
  specs = { { tag = "arcane", name = "Arcane", signature = "arcane_power" }, { tag = "fire", name = "Fire", signature = "combustion" }, { tag = "frost", name = "Frost", signature = "ice_barrier" } },
  starter = { { key = "bent_staff", x = startX, y = startY, rot = 0 }, { key = "fireball", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Mages use Arcane, Fire and Frost spells to deal damage. They can burn their opponent over time, freeze them to set up an attack, and protect themselves with magical shields.",
}

ns.RegisterClass{
  key = "WARLOCK", id = 9, order = 8, name = "Warlock", armor = "cloth", playable = true,
  color = { r = 0.53, g = 0.53, b = 0.93 }, icon = I("ClassIcon_Warlock"),
  primary = "mana", resources = { mana = { max = 90, regen = 4 } }, baseArmor = 2,
  specs = { { tag = "affliction", name = "Affliction", signature = "dark_pact" }, { tag = "demonology", name = "Demonology", signature = "soul_link" }, { tag = "destruction", name = "Destruction", signature = "conflagrate" } },
  starter = { { key = "warlock_worn_dirk", x = startX, y = startY, rot = 0 }, { key = "shadow_bolt", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Warlocks use curses, damage over time spells and summoned demons. They can drain health from their opponent and trade some of their own health for mana.",
}

ns.RegisterClass{
  key = "DRUID", id = 11, order = 9, name = "Druid", armor = "leather", playable = true,
  color = { r = 1.00, g = 0.49, b = 0.04 }, icon = I("ClassIcon_Druid"),
  primary = "mana", resources = { mana = { max = 90, regen = 6 } }, baseArmor = 8,
  specs = { { tag = "balance", name = "Balance", signature = "starfire" }, { tag = "feral", name = "Feral Combat", signature = "ferocious_bite" }, { tag = "resto", name = "Restoration", signature = "swiftmend" } },
  starter = { { key = "gnarled_staff", x = startX, y = startY, rot = 0 }, { key = "wrath", x = startX + 1, y = startY, rot = 0 } },
  blurb = "Druids can be played as a spellcaster, as a healer, or in cat and bear form. Each form comes with its own set of abilities.",
}
