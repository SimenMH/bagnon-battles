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
    tier(2, "Holy abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Healing crits restore 6 Mana.", { triggers = { { on = "anyCrit", healing = true, match = { tag = "holy" }, effects = { { type = "resource", resource = "mana", amount = 6 } } } } }),
    tier(8, "Every 30 effective Holy healing grants an absorb equal to 25% of that healing.", { triggers = { { on = "healed", match = { tag = "holy" }, everyAmount = 30, effects = { { type = "absorb", fromEvent = 0.25 } } } } })),
  protection = tree("Protection", "Spell_Holy_DevotionAura",
    tier(2, "Gain 4 Block Value while a shield is equipped.", { stats = { block = 4 } }),
    tier(5, "On block: Restore 3 Mana.", { triggers = { { on = "block", effects = { { type = "resource", resource = "mana", amount = 3 } } } } }),
    tier(8, "On block: Deal Holy damage equal to 30% of the damage blocked.", { triggers = { { on = "block", effects = { { type = "damage", school = "holy", fromEvent = 0.3, noCrit = true, noDodge = true } } } } })),
  retribution = tree("Retribution", "Spell_Holy_AuraOfLight",
    tier(2, "Retribution abilities gain 8% Critical Strike.", { mods = { crit = 8 } }),
    tier(5, "Melee auto-attacks advance Judgement by 0.3s.", { triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "cdr", target = "all", match = { key = "judgement" }, amount = 0.3, clampReady = true } } } } }),
    tier(8, "Every 3 paid Judgements: Make an extra melee auto-attack.", { triggers = { { on = "resourceSpent", resource = "mana", match = { key = "judgement" }, every = 3, effects = { { type = "extraAttack", count = 1 } } } } })),
}

trees.ROGUE = {
  assassination = tree("Assassination", "Ability_Rogue_Eviscerate",
    tier(2, "Assassination abilities gain 8% Critical Strike.", { mods = { crit = 8 } }),
    tier(5, "Every 3 poison ticks restore 5 Energy.", { triggers = { { on = "dotTick", match = { tag = "poison" }, every = 3, effects = { { type = "resource", resource = "energy", amount = 5 } } } } }),
    tier(8, "Paid finishers immediately tick your poisons.", { triggers = { { on = "resourceSpent", resource = "combo", match = { tag = "finisher" }, effects = { { type = "tickDots", match = { tag = "poison" } } } } } })),
  combat = tree("Combat", "Ability_BackStab",
    tier(2, "Combat abilities cost 10% less Energy.", { mods = { costPct = -10 } }),
    tier(5, "Every 4 melee auto-attacks restore 8 Energy.", { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 4, effects = { { type = "resource", resource = "energy", amount = 8 } } } } }),
    tier(8, "Every 6 melee auto-attacks grant an extra melee auto-attack.", { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 6, effects = { { type = "extraAttack", count = 1 } } } } })),
  subtlety = tree("Subtlety", "Ability_Stealth",
    tier(2, "Subtlety ability cooldowns are reduced by 15%.", { mods = { cdPct = 15 } }),
    tier(5, "When you stun the enemy: Gain 1 Combo Point.", { triggers = { { on = "enemyStunned", effects = { { type = "resource", resource = "combo", amount = 1 } } } } }),
    tier(8, "Paid finishers advance your control abilities by 2s.", { triggers = { { on = "resourceSpent", resource = "combo", match = { tag = "finisher" }, effects = { { type = "cdr", target = "all", match = { tag = "control" }, amount = 2, clampReady = true } } } } })),
}

trees.PRIEST = {
  discipline = tree("Discipline", "Spell_Holy_PowerWordShield",
    tier(2, "Discipline abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 20 damage absorbed restores 3 Mana.", { triggers = { { on = "absorbed", everyAmount = 20, effects = { { type = "resource", resource = "mana", amount = 3 } } } } }),
    tier(8, "Every 20 damage absorbed advances Smite by 1s.", { triggers = { { on = "absorbed", everyAmount = 20, effects = { { type = "cdr", target = "all", match = { key = "smite" }, amount = 1, clampReady = true } } } } })),
  holy = tree("Holy", "Spell_Holy_SearingLight",
    tier(2, "Holy abilities gain 8% Critical Strike.", { mods = { crit = 8 } }),
    tier(5, "Holy healing crits restore 6 Mana.", { triggers = { { on = "anyCrit", healing = true, match = { tag = "holy" }, effects = { { type = "resource", resource = "mana", amount = 6 } } } } }),
    tier(8, "Every 40 effective Holy healing advances Holy Fire by 2s.", { triggers = { { on = "healed", match = { tag = "holy" }, everyAmount = 40, effects = { { type = "cdr", target = "all", match = { key = "holy_fire" }, amount = 2, clampReady = true } } } } })),
  shadow = tree("Shadow", "Spell_Shadow_ShadowWordPain",
    tier(2, "Shadow abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 3 Shadow damage ticks restore 4 Mana.", { triggers = { { on = "dotTick", match = { tag = "shadow" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }),
    tier(8, "Every 4 Shadow damage ticks advance Mind Blast by 2s.", { triggers = { { on = "dotTick", match = { tag = "shadow" }, every = 4, effects = { { type = "cdr", target = "all", match = { key = "mind_blast" }, amount = 2, clampReady = true } } } } })),
}

trees.SHAMAN = {
  elemental = tree("Elemental", "Spell_Nature_Lightning",
    tier(2, "Elemental abilities gain 8% Critical Strike.", { mods = { crit = 8 } }),
    tier(5, "Elemental spell crits restore 5 Mana.", { triggers = { { on = "anyCrit", healing = false, match = { tag = "elemental" }, effects = { { type = "resource", resource = "mana", amount = 5 } } } } }),
    tier(8, "Every 3 Elemental spell crits immediately tick your burns.", { triggers = { { on = "anyCrit", healing = false, match = { tag = "elemental" }, every = 3, effects = { { type = "tickDots", match = { tag = "fire" } } } } } })),
  enhancement = tree("Enhancement", "Spell_Nature_LightningShield",
    tier(2, "Enhancement abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 3 melee auto-attacks restore 5 Mana.", { triggers = { { on = "regularHit", match = { tag = "melee" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 5 } } } } }),
    tier(8, "Every 30 Mana spent on shocks advances your melee auto-attacks by 1s.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "shock" }, everyAmount = 30, effects = { { type = "cdr", target = "all", match = { tag = "melee", anyTag = { "autoattack" } }, amount = 1, clampReady = true } } } } })),
  restoration = tree("Restoration", "Spell_Nature_MagicImmunity",
    tier(2, "Restoration abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 40 effective Restoration healing restores 3 Mana.", { triggers = { { on = "healed", match = { tag = "restoration" }, everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 3 } } } } }),
    tier(8, "Every 40 effective Restoration healing grants 7 absorb and advances damaging totems by 1s.", { triggers = { { on = "healed", match = { tag = "restoration" }, everyAmount = 40, effects = { { type = "absorb", amount = 7 }, { type = "cdr", target = "all", match = { tag = "totem", damaging = true }, amount = 1, clampReady = true } } } } })),
}

trees.MAGE = {
  arcane = tree("Arcane", "Spell_Holy_MagicalSentry",
    tier(2, "Arcane abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Every 30 Mana spent on Arcane abilities advances them by 1s.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "arcane" }, everyAmount = 30, effects = { { type = "cdr", target = "all", match = { tag = "arcane" }, amount = 1, clampReady = true } } } } }),
    tier(8, "Every 60 Mana spent on Arcane abilities casts your Arcane Missiles for free.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "arcane" }, everyAmount = 60, effects = { { type = "cast", key = "arcane_missiles" } } } } })),
  fire = tree("Fire", "Spell_Fire_FireBolt02",
    tier(2, "Fire abilities gain 8% Critical Strike.", { mods = { crit = 8 } }),
    tier(5, "Fire spell crits restore 4 Mana.", { triggers = { { on = "anyCrit", healing = false, match = { kind = "ability", tag = "fire" }, effects = { { type = "resource", resource = "mana", amount = 4 } } } } }),
    tier(8, "Every 3 Fire spell crits immediately tick your burns.", { triggers = { { on = "anyCrit", healing = false, match = { kind = "ability", tag = "fire" }, every = 3, effects = { { type = "tickDots", match = { tag = "fire" } } } } } })),
  frost = tree("Frost", "Spell_Frost_FrostBolt02",
    tier(2, "Frost ability cooldowns are reduced by 15%.", { mods = { cdPct = 15 } }),
    tier(5, "When you freeze the enemy: Your next direct Frost spell gains 30% Critical Strike for 6s.", { triggers = { { on = "enemyStunned", match = { tag = "frost" }, effects = { { type = "buff", target = "all", match = { tag = "frost", damaging = "direct" }, stat = "crit", value = 30, charges = 1, duration = 6, key = "frost_talent", name = "Frost" } } } } }),
    tier(8, "Every 3 Frost ability casts advance Frost Nova by 3s.", { triggers = { { on = "anyUse", match = { kind = "ability", tag = "frost" }, every = 3, effects = { { type = "cdr", target = "all", match = { key = "frost_nova" }, amount = 3, clampReady = true } } } } })),
}

trees.WARLOCK = {
  affliction = tree("Affliction", "Spell_Shadow_DeathCoil",
    tier(2, "Affliction abilities cost 10% less Mana.", { mods = { costPct = -10 } }),
    tier(5, "Corruption, Curse of Agony and Siphon Life heal you for 10% of their damage.", { triggers = { { on = "dotTick", match = { tag = "affliction", notTag = "channel" }, effects = { { type = "heal", fromEvent = 0.1, fixedFraction = true, noCrit = true } } } } }),
    tier(8, "Every 9 Corruption, Curse of Agony or Siphon Life ticks restore 6 Mana and trigger an extra tick of those effects.", { triggers = { { on = "dotTick", match = { tag = "affliction", notTag = "channel" }, every = 9, effects = { { type = "resource", resource = "mana", amount = 6 }, { type = "tickDots", match = { tag = "affliction", notTag = "channel" } } } } } })),
  demonology = tree("Demonology", "Spell_Shadow_SummonImp",
    tier(2, "Demonology abilities deal 10% more damage.", { mods = { dmgPct = 10 } }),
    tier(5, "Spending health advances your demon attack by 1s.", { triggers = { { on = "healthSpent", condition = "provides:pet", effects = { { type = "cdr", target = "all", match = { kind = "pet" }, amount = 1, clampReady = true } } } } }),
    tier(8, "Demon crits heal you for 30% of the damage dealt.", { triggers = { { on = "anyCrit", healing = false, match = { kind = "pet" }, condition = "provides:pet", effects = { { type = "heal", fromEvent = 0.3 } } } } })),
  destruction = tree("Destruction", "Spell_Shadow_RainOfFire",
    tier(2, "Destruction abilities gain 8% Critical Strike.", { mods = { crit = 8 } }),
    tier(5, "Destruction spell crits advance Conflagrate by 1s.", { triggers = { { on = "anyCrit", healing = false, match = { tag = "destruction" }, effects = { { type = "cdr", target = "all", match = { key = "conflagrate" }, amount = 1, clampReady = true } } } } }),
    tier(8, "Every 60 Mana spent on Destruction abilities casts your Shadowburn for free.", { triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "destruction" }, everyAmount = 60, effects = { { type = "cast", key = "shadowburn" } } } } })),
}
