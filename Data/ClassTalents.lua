local ADDON, ns = ...
local trees = ns.Mastery.TREES

local function tier(points, text, effects)
  effects.points, effects.text = points, text
  return effects
end

local function tree(name, icon, early, middle, deep)
  return { name = name, icon = ns.icon(icon), tiers = { early, middle, deep } }
end

trees.PALADIN = {
  holy = tree("Holy", "Spell_Holy_HolyBolt",
    tier(2, "Your Holy abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Your Holy healing critical strikes restore 20% of the Mana spent on the spell when they provide effective healing. This can occur once per cast.", { triggers = { { on = "anyCrit", healing = true,
      effective = true, paidOnly = true, oncePerActivation = true, match = { tag = "holy" },
      effects = { { type = "resource", resource = "mana", fromPaid = 0.2 } } } } }),
    tier(8, "Your effective Holy healing shields you for 25% of the health restored.", { triggers = { { on = "healed", match = { tag = "holy" }, effects = { { type = "absorb", fromEvent = 0.25 } } } } })),
  protection = tree("Protection", "Spell_Holy_DevotionAura",
    tier(2, "Increases your Block Value by 4 while a shield is equipped.", { stats = { block = 4 } }),
    tier(5, "Blocking an attack restores 3 Mana.", { triggers = { { on = "block", effects = { { type = "resource", resource = "mana", amount = 3 } } } } }),
    tier(8, "Blocking an attack deals Holy damage equal to 30% of the damage blocked.", { triggers = { { on = "block", effects = { { type = "damage", school = "holy", fromEvent = 0.3, noCrit = true, noDodge = true } } } } })),
  retribution = tree("Retribution", "Spell_Holy_AuraOfLight",
    tier(2, "Increases the critical strike chance of your Retribution abilities by 8%.", { mods = { crit = 8 } }),
    tier(5, "Your regular melee auto-attack hits reduce Judgement's cooldown by 0.3 sec.", { triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "cdr", target = "all", match = { tag = "judgement" }, amount = 0.3, clampReady = true } } } } }),
    tier(8, "Every third Judgement that spends Mana grants an extra melee attack.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "judgement" }, every = 3, effects = { { type = "extraAttack", count = 1 } } } } })),
}

trees.ROGUE = {
  assassination = tree("Assassination", "Ability_Rogue_Eviscerate",
    tier(2, "Increases the critical strike chance of your Assassination abilities by 8%.", { mods = { crit = 8 } }),
    tier(5, "Every third successful poison application restores 5 Energy.", { triggers = { { on = "coatingApplied", every = 3,
      effects = { { type = "resource", resource = "energy", amount = 5 } } } } }),
    tier(8, "Every 5 Combo Points you spend on finishing moves applies each active poison once more.", { triggers = { { on = "resourceSpent", resource = "combo",
      match = { tag = "finisher" }, everyAmount = 5, effects = { { type = "reapplyCoatings" } } } } })),
  combat = tree("Combat", "Ability_BackStab",
    tier(2, "Your Combat abilities cost 10% less Energy.", { mods = { costPct = -10 } }),
    tier(5, "Every fourth regular melee auto-attack hit restores 8 Energy.", { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 4, effects = { { type = "resource", resource = "energy", amount = 8 } } } } }),
    tier(8, "Every sixth regular melee auto-attack hit grants an extra melee attack.", { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 6, effects = { { type = "extraAttack", count = 1 } } } } })),
  subtlety = tree("Subtlety", "Ability_Stealth",
    tier(2, "Reduces the cooldowns of your Subtlety abilities by 15%.", { mods = { cdPct = 15 } }),
    tier(5, "Your crowd control effects grant 1 Combo Point when they stop the enemy.", { triggers = { { on = "enemyStunned", effects = { { type = "resource", resource = "combo", amount = 1 } } } } }),
    tier(8, "Finishing moves that spend Combo Points reduce the cooldowns of your crowd control abilities by 2 sec.", { triggers = { { on = "resourceSpent", resource = "combo", match = { tag = "finisher" }, effects = { { type = "cdr", target = "all", match = { tag = "control" }, amount = 2, clampReady = true } } } } })),
}

trees.PRIEST = {
  discipline = tree("Discipline", "Spell_Holy_PowerWordShield",
    tier(2, "Your Discipline abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 20 damage you absorb restores 3 Mana.", { triggers = { { on = "absorbed", everyAmount = 20, effects = { { type = "resource", resource = "mana", amount = 3 } } } } }),
    tier(8, "Every 20 damage you absorb reduces Smite's cooldown by 1 sec. It also reduces your wand's attack cooldown by 0.5 sec, up to once per second.", { triggers = {
      { on = "absorbed", everyAmount = 20, effects = { { type = "cdr", target = "all", match = { key = "smite" }, amount = 1, clampReady = true } } },
      { on = "absorbed", everyAmount = 20, icd = 1, effects = { { type = "cdr", target = "all", match = { kind = "weapon", weaponType = "wand" }, amount = 0.5, clampReady = true } } },
    } })),
  holy = tree("Holy", "Spell_Holy_SearingLight",
    tier(2, "Increases the critical strike chance of your Holy abilities by 8%.", { mods = { crit = 8 } }),
    tier(5, "Your Holy healing critical strikes restore 6 Mana.", { triggers = { { on = "anyCrit", healing = true, match = { tag = "holy" }, effects = { { type = "resource", resource = "mana", amount = 6 } } } } }),
    tier(8, "Every 60 Mana you spend on Holy healing spells grants a shield that absorbs 20 damage plus 15% of your Healing Power.", { triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "holy", anyTag = { "heal" } }, everyAmount = 60,
      effects = { { type = "absorb", amount = 20, coef = 0.15 } } } } })),
  shadow = tree("Shadow", "Spell_Shadow_ShadowWordPain",
    tier(2, "Your Shadow abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every third tick of your Shadow damage over time restores 4 Mana.", { triggers = { { on = "dotTick", match = { tag = "shadow" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }),
    tier(8, "Every fourth tick of your Shadow damage over time reduces Mind Blast's cooldown by 2 sec. It also reduces Mind Flay's cooldown by 0.5 sec and Devouring Plague's cooldown by 1 sec, up to once per second.", { triggers = {
      { on = "dotTick", match = { tag = "shadow" }, every = 4, effects = { { type = "cdr", target = "all", match = { key = "mind_blast" }, amount = 2, clampReady = true } } },
      { on = "dotTick", match = { tag = "shadow" }, every = 4, icd = 1, effects = {
        { type = "cdr", target = "all", match = { key = "mind_flay" }, amount = 0.5, clampReady = true },
        { type = "cdr", target = "all", match = { key = "devouring_plague" }, amount = 1, clampReady = true },
      } },
    } })),
}

trees.SHAMAN = {
  elemental = tree("Elemental", "Spell_Nature_Lightning",
    tier(2, "Increases the critical strike chance of your Elemental abilities by 8%.", { mods = { crit = 8 } }),
    tier(5, "Your Elemental spell critical strikes restore 5 Mana.", { triggers = { { on = "anyCrit", healing = false, match = { tag = "elemental" }, effects = { { type = "resource", resource = "mana", amount = 5 } } } } }),
    tier(8, "Every third Elemental spell critical strike causes each of your Fire damage over time effects to deal an additional tick of damage.", { triggers = { { on = "anyCrit", healing = false, match = { tag = "elemental" }, every = 3, effects = { { type = "tickDots", match = { tag = "fire" } } } } } })),
  enhancement = tree("Enhancement", "Spell_Nature_LightningShield",
    tier(2, "Your Enhancement abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every third regular melee auto-attack hit restores 5 Mana.", { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 5 } } } } }),
    tier(8, "Every 30 Mana you spend on shocks reduces your melee auto-attack cooldowns by 1 sec.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "shock" }, everyAmount = 30, effects = { { type = "cdr", target = "all", match = { tag = "melee", anyTag = { "autoattack" } }, amount = 1, clampReady = true } } } } })),
  restoration = tree("Restoration", "Spell_Nature_MagicImmunity",
    tier(2, "Your Restoration abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 40 Mana you spend on Restoration healing spells restores 8 Mana.", { triggers = { { on = "resourceSpent", resource = "mana", match = { kind = "ability", tag = "restoration", anyTag = { "heal" } }, everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 8 } } } } }),
    tier(8, "For every 80 points of effective Restoration healing, you gain a shield that absorbs 7 damage and reduce your damaging totems' cooldowns by 1 sec. This can occur once per second.", { triggers = { { on = "healed", match = { tag = "restoration" }, everyAmount = 80, icd = 1, effects = { { type = "absorb", amount = 7 }, { type = "cdr", target = "all", match = { tag = "damaging_totem" }, amount = 1, clampReady = true } } } } })),
}

trees.MAGE = {
  arcane = tree("Arcane", "Spell_Holy_MagicalSentry",
    tier(2, "Your Arcane abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 30 Mana you spend on Arcane abilities reduces their cooldowns by 1 sec.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "arcane" }, everyAmount = 30, effects = { { type = "cdr", target = "all", match = { tag = "arcane" }, amount = 1, clampReady = true } } } } }),
    tier(8, "Every 60 Mana you spend on Arcane abilities casts Arcane Missiles at no Mana cost. If you cannot act, one free cast waits until you can.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "arcane" }, everyAmount = 60, effects = { { type = "cast", key = "arcane_missiles", deferDuringChannel = true } } } } })),
  fire = tree("Fire", "Spell_Fire_FireBolt02",
    tier(2, "Increases the critical strike chance of your Fire abilities by 8%.", { mods = { crit = 8 } }),
    tier(5, "Your Fire spell critical strikes restore 4 Mana.", { triggers = { { on = "anyCrit", healing = false, match = { kind = "ability", tag = "fire" }, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }),
    tier(8, "Every third Fire spell critical strike causes each of your Fire damage over time effects to deal an additional tick of damage.", { triggers = { { on = "anyCrit", healing = false, match = { kind = "ability", tag = "fire" }, every = 3, effects = { { type = "tickDots", match = { tag = "fire" } } } } } })),
  frost = tree("Frost", "Spell_Frost_FrostBolt02",
    tier(2, "Reduces the cooldowns of your Frost abilities by 15%.", { mods = { cdPct = 15 } }),
    tier(5, "Freezing the enemy increases the critical strike chance of your next direct Frost spell by 30% for 6 sec.", { triggers = { { on = "enemyStunned", match = { tag = "frost" }, effects = { { type = "buff", target = "all", match = { tag = "frost", damaging = "direct" }, stat = "crit", value = 30, charges = 1, duration = 6, key = "frost_talent", name = "Frost" } } } } }),
    tier(8, "Every third Frost ability you cast reduces Frost Nova's cooldown by 3 sec.", { triggers = { { on = "anyUse", match = { kind = "ability", tag = "frost" }, every = 3, effects = { { type = "cdr", target = "all", match = { key = "frost_nova" }, amount = 3, clampReady = true } } } } })),
}

trees.WARLOCK = {
  affliction = tree("Affliction", "Spell_Shadow_DeathCoil",
    tier(2, "Your Affliction abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Corruption, Curse of Agony and Siphon Life heal you for 10% of the damage they deal.", { triggers = { { on = "dotTick", match = { tag = "affliction", notTag = "channel" }, effects = { { type = "heal", fromEvent = 0.1, fixedFraction = true, noCrit = true } } } } }),
    tier(8, "Every ninth damage tick from Corruption, Curse of Agony or Siphon Life restores 6 Mana and causes each of those active effects to deal an additional tick of damage.", { triggers = { { on = "dotTick", match = { tag = "affliction", notTag = "channel" }, every = 9, effects = { { type = "resource", resource = "mana", amount = 6 }, { type = "tickDots", match = { tag = "affliction", notTag = "channel" } } } } } })),
  demonology = tree("Demonology", "Spell_Shadow_SummonImp",
    tier(2, "Your Demonology abilities deal 10% more damage.", { mods = { dmgPct = 10 } }),
    tier(5, "While your demon is active, spending Health reduces its attack cooldown by 1 sec.", { triggers = { { on = "healthSpent", condition = "provides:pet", effects = { { type = "cdr", target = "all", match = { kind = "pet" }, amount = 1, clampReady = true } } } } }),
    tier(8, "Your demon's critical strikes heal you for 30% of the damage dealt.", { triggers = { { on = "anyCrit", healing = false, match = { kind = "pet" }, condition = "provides:pet", effects = { { type = "heal", fromEvent = 0.3 } } } } })),
  destruction = tree("Destruction", "Spell_Shadow_RainOfFire",
    tier(2, "Increases the critical strike chance of your Destruction abilities by 8%.", { mods = { crit = 8 } }),
    tier(5, "Your Destruction spell critical strikes reduce Conflagrate's cooldown by 1 sec.", { triggers = { { on = "anyCrit", healing = false, match = { tag = "destruction" }, effects = { { type = "cdr", target = "all", match = { key = "conflagrate" }, amount = 1, clampReady = true } } } } }),
    tier(8, "Every 60 Mana you spend on Destruction abilities casts Shadowburn at no Mana cost. If you cannot act, one free cast waits until you can.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "destruction" }, everyAmount = 60, effects = { { type = "cast", key = "shadowburn", deferDuringChannel = true } } } } })),
}
