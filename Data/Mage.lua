local ADDON, ns = ...
local H = ns.H
local S = H.S
local MAGE = { "MAGE" }
local ability = H.QualityAbilities(MAGE)



ability(8001, "arcane_missiles", "Arcane Missiles", "arcane", "Spell_Nature_StarFall", 1, {
  tags = { "arcane", "spell", "channel" },
  use = {
    cost = 18, cd = 6, channel = { key = "arcane_missiles", duration = 3 }, resource = "mana",
    effects = { { type = "dot", key = "arcane_missiles", coef = 0.35, tick = 1, school = "arcane", duration = 3, directTicks = true } },
    rankCosts = { [2] = 26, [3] = 32 },
  },
  triggers = {
    {
      on = "channelComplete", match = { key = "arcane_missiles" },
      effects = {
        {
          type = "buff", key = "missiles_explosion", name = "Arcane Missiles", target = "all",
          match = { key = "arcane_explosion", damaging = "direct" }, stat = "dmgPct", value = 40, duration = 8, charges = 1, paidOnly = true,
        },
      },
    },
  },
  shopWeight = 1.6,
})

ability(8002, "arcane_explosion", "Arcane Explosion", "arcane", "Spell_Nature_WispSplode", 1, {
  use = {
    cost = 24, cd = 2.5, resource = "mana",
    effects = { { type = "damage", coef = 0.6, min = 2, max = 4, school = "arcane", bankLabel = "stored Mana power", spendBank = "arcane_resonance" } },
    rankCosts = { [2] = 30, [3] = 36 },
  },
  shopWeight = 1.3,
})

ability(8003, "arcane_intellect", "Arcane Intellect", "arcane", "Spell_Holy_MagicalSentry", 1, {
  stats = { mana = 20 },
  triggers = {
    {
      on = "battleStart",
      effects = {
        {
          type = "buff", key = "intellect_opening", name = "Arcane Intellect", target = "neighbors", area = { side = "front" },
          match = { kind = "ability", damaging = "direct", tag = "spell" }, stat = "dmgPct", value = 20, duration = 120, charges = 1, paidOnly = true,
        },
      },
    },
  },
  shopWeight = 1.15,
})

ability(8004, "arcane_concentration", "Arcane Concentration", "arcane", "Spell_Shadow_ManaBurn", 2, {
  triggers = {
    {
      on = "anyHit", match = { kind = "ability", damaging = true, tag = "spell" }, chance = 12,
      effects = {
        {
          type = "buff", key = "mage_clearcasting", target = "neighbors", area = { side = "back" },
          match = { kind = "ability", damaging = true, tag = "spell" }, stat = "none", value = 0, duration = 8, charges = 1, free = true,
        },
      },
    },
  },
})

ability(8005, "arcane_meditation", "Arcane Meditation", "arcane", "Spell_Shadow_SiphonMana", 2, {
  triggers = { { on = "regularHit", condition = "resourceIdle:mana:3", match = { kind = "weapon", weaponType = "wand" }, icd = 1, effects = { { type = "resource", resource = "mana", amount = 6 } } } },
})

ability(8006, "arcane_mind", "Arcane Mind", "arcane", "Spell_Shadow_Charm", 2, { gearBonuses = { { coef = 0.2, stat = "mana", gearStat = "mana" } } })

ability(8007, "counterspell", "Counterspell", "arcane", "Spell_Frost_IceShock", 2, { use = { cost = 12, cd = 14, resource = "mana", effects = { { type = "stun", duration = 1.2 }, { type = "drain", resource = "mana", amount = 12 } } } })

ability(8008, "evocation", "Evocation", "arcane", "Spell_Nature_Purge", 3, {
  tags = { "arcane", "spell", "mana_recovery" },
  use = {
    cd = 24, initialDelay = 0, priority = 90, reactive = true, channel = { key = "evocation", kind = "buff", duration = 3, self = true },
    condition = "lowMana",
    effects = { { type = "buff", key = "evocation", stat = "none", value = 0, duration = 3, periodic = { every = 1, effects = { { type = "resource", resource = "mana", amount = 20 } } } } },
  },
})

ability(8009, "magic_absorption", "Magic Absorption", "arcane", "Spell_Nature_AstralRecalGroup", 3, { triggers = { { on = "absorbed", matchAttacker = { tag = "spell" }, icd = 2, effects = { { type = "resource", resource = "mana", amount = 0, pctMax = 0.02 } } } } })

ability(8010, "arcane_resilience", "Arcane Resilience", "arcane", "Spell_Arcane_ArcaneResilience", 2, { cost = 4, gearBonuses = { { coef = 0.2, stat = "armor", gearStat = "mana" } } })

ability(8011, "arcane_instability", "Arcane Instability", "arcane", "Spell_Shadow_Teleport", 4, { triggers = { { on = "anyCrit", match = { tag = "spell" }, effects = { { type = "bank", key = "arcane_resonance", cap = { flat = 50, sp = 1 }, fraction = 0.3 } }, healing = false } } })

ability(8012, "presence_of_mind", "Presence of Mind", "arcane", "Spell_Nature_EnchantArmor", 5, {
  use = {
    cost = 18, cd = 22, initialDelay = 0, resource = "mana",
    effects = {
      { type = "cdr", target = "neighbors", area = { side = "front" }, match = { kind = "ability", prepared = true }, amount = 1000, choose = "first", clampReady = true },
      {
        type = "buff", key = "presence_of_mind", target = "neighbors", area = { side = "front" }, match = { kind = "ability", prepared = true },
        stat = "prepareFlat", value = -10, duration = 8, charges = 1, paidOnly = true, rankScale = false,
      },
    },
    minRecovering = 0.5,
  },
})

ability(8013, "arcane_power", "Arcane Power", "arcane", "Spell_Nature_Lightning", 5, {
  use = {
    cost = 35, cd = 26, resource = "mana",
    effects = {
      { type = "buff", key = "arcane_power", target = "all", match = { damaging = true, tag = "spell" }, stat = "dmgPct", value = 50, duration = 8 },
      { type = "buff", key = "arcane_power_cost", target = "all", match = { damaging = true, tag = "spell" }, stat = "costPct", value = 50, duration = 8 },
    },
  },
})



ability(8014, "improved_arcane_missiles", "Improved Arcane Missiles", "arcane", "Spell_Nature_StarFall", 3, { adjacency = { { match = { key = "arcane_missiles" }, mods = { dmgPct = 20 }, side = "front" } }, passiveTriggers = true, shopRequires = { "arcane_missiles" } })

ability(8015, "magic_attunement", "Magic Attunement", "arcane", "Spell_Nature_AbolishMagic", 4, {
  shape = S.v2,
  triggers = {
    {
      on = "absorbed", everyAmount = 20,
      effects = {
        { type = "bank", key = "arcane_resonance", cap = { flat = 50, sp = 1 }, fraction = 0.5 },
        { type = "cdr", target = "all", match = { key = "arcane_explosion" }, amount = 0.5, clampReady = true },
      },
    },
  },
  shopWeight = 0.65,
})

ability(8016, "improved_counterspell", "Improved Counterspell", "arcane", "Spell_Frost_IceShock", 4, {
  shape = S.v2,
  triggers = {
    {
      on = "anyUse", match = { key = "counterspell" },
      effects = {
        {
          type = "buff", key = "improved_counterspell", target = "all", match = { kind = "ability", damaging = "direct", tag = "spell" },
          stat = "crit", value = 100, duration = 5, charges = 1,
        },
      },
    },
  },
  shopRequires = { "counterspell" }, shopWeight = 0.7,
})

ability(8020, "fireball", "Fireball", "fire", "Spell_Fire_FlameBolt", 1, {
  tags = { "fire", "spell", "burn" },
  use = {
    cost = 14, cd = 3.5, resource = "mana",
    effects = {
      { type = "damage", coef = 0.6, min = 3, max = 5, school = "fire" },
      { type = "dot", key = "fireball_burn", coef = 0.04, tick = 1, school = "fire", duration = 6, preserveTicks = true },
    },
    rankCosts = { [2] = 20, [3] = 25 },
  },
  shopWeight = 1.5,
})

ability(8021, "fire_blast", "Fire Blast", "fire", "Spell_Fire_Fireball", 1, {
  use = { cost = 18, cd = 7, resource = "mana", effects = { { type = "damage", coef = 0.65, min = 2, max = 4, school = "fire", perStatus = 0.1 } }, rankCosts = { [2] = 26, [3] = 32 } },
  shopWeight = 1.4,
})

ability(8022, "scorch", "Scorch", "fire", "Spell_Fire_SoulBurn", 1, {
  use = {
    cost = 10, cd = 3, resource = "mana",
    effects = {
      { type = "damage", coef = 0.45, min = 2, max = 3, school = "fire" },
      { type = "buff", key = "scorch_heat", target = "all", match = { tag = "fire" }, stat = "crit", value = 5, duration = 8 },
    },
    rankCosts = { [2] = 17, [3] = 21 },
  },
  shopWeight = 1.4,
})



ability(8023, "ignite", "Ignite", "fire", "Spell_Fire_Incinerate", 2, {
  tags = { "fire", "spell", "burn", "dot" },
  triggers = { { on = "anyCrit", match = { tag = "fire" }, effects = { { type = "dot", key = "ignite", tick = 0, school = "fire", duration = 4, fromEvent = 0.3, rolling = true } }, healing = false } },
})

ability(8024, "pyroblast", "Pyroblast", "fire", "Spell_Fire_Fireball02", 3, {
  shape = S.L, tags = { "fire", "spell", "burn" },
  use = {
    cost = 24, cd = 12, prepare = 2, resource = "mana",
    effects = {
      { type = "damage", coef = 3, min = 3, max = 5, school = "fire" },
      { type = "dot", key = "pyroblast_burn", coef = 0.125, tick = 1, school = "fire", duration = 4, preserveTicks = true },
    },
  },
  shopWeight = 1.05,
})

ability(8025, "flamestrike", "Flamestrike", "fire", "Spell_Fire_SelfDestruct", 2, {
  shape = S.sq, tags = { "fire", "spell", "burn", "dot" },
  use = {
    cost = 24, cd = 11, resource = "mana",
    effects = { { type = "damage", coef = 0.55, min = 3, max = 5, school = "fire" }, { type = "dot", key = "flamestrike", coef = 0.125, tick = 1, school = "fire", duration = 8 } },
    rankCosts = { [2] = 37, [3] = 47 },
  },
})

ability(8026, "blast_wave", "Blast Wave", "fire", "Spell_Holy_Excorcism_02", 3, {
  use = {
    cost = 20, cd = 15, resource = "mana",
    effects = {
      { type = "damage", coef = 0.8, min = 2, max = 4, school = "fire", consumeDots = { match = { key = "flamestrike" }, fraction = 0.5 } },
      { type = "stun", duration = 1.2 }, { type = "tickDots", match = { tag = "burn" } },
    },
  },
})

ability(8027, "impact", "Impact", "fire", "Spell_Fire_MeteorStorm", 2, { triggers = { { on = "anyHit", match = { tag = "fire" }, chance = 12, icd = 3, effects = { { type = "stun", duration = 0.8 } } } } })

ability(8028, "improved_scorch", "Improved Scorch", "fire", "Spell_Fire_SoulBurn", 2, {
  triggers = {
    {
      on = "anyUse", match = { key = "scorch" },
      effects = { { type = "buff", key = "improved_scorch", target = "all", match = { tag = "fire" }, stat = "dmgPct", value = 5, duration = 12, maxStacks = 5, stack = true } },
    },
  },
  shopRequires = { "scorch" },
})

ability(8029, "master_of_elements", "Master of Elements", "fire", "Spell_Fire_MasterOfElements", 3, {
  triggers = {
    {
      on = "anyCrit", match = { kind = "ability", anyTag = { "fire", "frost" }, damaging = true, tag = "spell" },
      effects = { { type = "resource", resource = "mana", amount = 5 } }, healing = false,
    },
  },
})

ability(8030, "fire_power", "Fire Power", "fire", "Spell_Fire_Immolation", 4, {
  triggers = { { on = "dotTick", match = { tag = "burn" }, every = 5, effects = { { type = "cdr", target = "all", match = { key = "pyroblast" }, amount = 1.5, clampReady = true } } } },
  adjacency = { { match = { tag = "fire" }, mods = { dmgPct = 20 }, side = "front" } },
})

ability(8031, "combustion", "Combustion", "fire", "Spell_Fire_SealOfFire", 5, {
  use = {
    cost = 25, cd = 28, resource = "mana",
    effects = { { type = "buff", key = "combustion", target = "all", match = { damaging = "direct", tag = "fire" }, stat = "crit", value = 100, duration = 8, charges = 3, rankScale = false } },
  },
})

ability(8032, "improved_fireball", "Improved Fireball", "fire", "Spell_Fire_FlameBolt", 3, {
  triggers = { { on = "anyUse", match = { key = "fireball" }, every = 2, effects = { { type = "tickDots", match = { tag = "burn" } } } } },
  adjacency = { { match = { key = "fireball" }, mods = { cdPct = 15 } } }, shopRequires = { "fireball" },
})

ability(8033, "incinerate", "Incinerate", "fire", "Spell_Fire_FlameShock", 3, {
  triggers = {
    { on = "adjacentCrit", match = { tag = "fire" }, icd = 1, effects = { { type = "cdr", target = "all", match = { key = "fire_blast" }, amount = 1, clampReady = true } }, healing = false },
  },
  adjacency = { { match = { damaging = "direct", tag = "fire" }, mods = { crit = 10 } } },
})

ability(8034, "critical_mass", "Critical Mass", "fire", "Spell_Nature_WispHeal", 4, {
  shape = S.v2,
  triggers = {
    {
      on = "anyCrit", match = { tag = "fire" }, every = 2,
      effects = {
        { type = "buff", key = "critical_mass", target = "all", match = { damaging = "direct", tag = "fire" }, stat = "critDamage", value = 35, duration = 6, charges = 1 },
        { type = "cdr", target = "all", match = { key = "pyroblast" }, amount = 1, clampReady = true },
      },
      healing = false,
    },
  },
  shopWeight = 0.75,
})

ability(8035, "burning_soul", "Burning Soul", "fire", "Spell_Fire_Fire", 4, {
  shape = S.v2,
  triggers = {
    {
      on = "damaged", icd = 2, everyAmount = 40,
      effects = {
        {
          type = "buff", key = "burning_soul", name = "Burning Soul", target = "neighbors", area = { corners = true },
          match = { kind = "ability", damaging = "direct", tag = "fire" }, stat = "dmgPct", value = 30, duration = 6, charges = 1, paidOnly = true,
        },
      },
    },
  },
})

ability(8040, "frostbolt", "Frostbolt", "frost", "Spell_Frost_FrostBolt02", 1, {
  use = {
    cost = 13, cd = 3.5, initialDelay = 2, resource = "mana",
    effects = {
      { type = "damage", coef = 0.6, min = 3, max = 5, school = "frost" },
      { type = "debuff", key = "frostbolt_chill", exclusiveGroup = "frost_chill", stat = "haste", value = 10, duration = 4, rankScale = false },
    },
    rankCosts = { [2] = 19, [3] = 23 },
  },
  shopWeight = 1.6,
})

ability(8041, "frost_nova", "Frost Nova", "frost", "Spell_Frost_FrostNova", 1, {
  use = {
    cost = 18, cd = 12, initialDelay = 1, resource = "mana",
    effects = { { type = "damage", coef = 0.15, min = 1, max = 3, school = "frost" }, { type = "stun", duration = 1.5, controlType = "freeze", rankScale = false } },
  },
  shopWeight = 1.25,
})

ability(8042, "cone_of_cold", "Cone of Cold", "frost", "Spell_Frost_Glacier", 2, {
  use = {
    cost = 19, cd = 8, resource = "mana",
    effects = {
      { type = "damage", coef = 0.75, min = 2, max = 4, school = "frost" },
      { type = "debuff", key = "cone_of_cold", exclusiveGroup = "frost_chill", stat = "haste", value = 15, duration = 5, rankScale = false },
    },
    rankCosts = { [2] = 28, [3] = 36 },
  },
})

ability(8043, "blizzard", "Blizzard", "frost", "Spell_Frost_IceStorm", 2, {
  shape = S.sq, tags = { "frost", "spell", "dot", "channel" },
  use = {
    cost = 24, cd = 12, channel = { key = "blizzard", duration = 6 }, resource = "mana",
    effects = { { type = "dot", key = "blizzard", coef = 0.3, tick = 1, school = "frost", duration = 6 } }, rankCosts = { [2] = 40, [3] = 51 },
  },
  triggers = {
    {
      on = "channelComplete", match = { key = "blizzard" },
      effects = { { type = "dot", key = "blizzard_afterstorm", name = "Blizzard", coef = 0.15, tick = 0, school = "frost", duration = 4, preserveTicks = true } },
    },
  },
  shopWeight = 1.1,
})

ability(8044, "frostbite", "Frostbite", "frost", "Spell_Frost_FrostArmor", 2, { triggers = { { on = "anyHit", match = { tag = "frost" }, chance = 15, icd = 3, effects = { { type = "stun", duration = 1, controlType = "freeze" } } } } })

ability(8045, "shatter", "Shatter", "frost", "Spell_Frost_FrostShock", 3, {
  triggers = {
    {
      on = "enemyStunned",
      effects = {
        { type = "buff", key = "shatter", target = "all", match = { kind = "ability", damaging = "direct", tag = "spell" }, stat = "crit", value = 50, duration = 5, charges = 1 },
        {
          type = "buff", key = "shatter_damage", target = "all",
          match = { kind = "ability", anyTag = { "frost" }, damaging = "direct", tag = "spell" }, stat = "critDamage", value = 30, duration = 5,
          charges = 1,
        },
      },
    },
  },
})

ability(8046, "ice_shards", "Ice Shards", "frost", "Spell_Frost_IceShard", 2, {
  triggers = {
    { on = "anyCrit", match = { tag = "frost" }, effects = { { type = "damage", school = "frost", fromEvent = 0.3, noCrit = true, noDodge = true, noOwnTriggers = true } }, healing = false },
  },
})

ability(8047, "frost_channeling", "Frost Channeling", "frost", "Spell_Frost_Stun", 2, { adjacency = { { match = { tag = "frost" }, mods = { costPct = -15 }, side = "back" } } })

ability(8048, "winters_chill", "Winter's Chill", "frost", "Spell_Frost_ChillingBlast", 4, {
  triggers = {
    {
      on = "anyHit", match = { tag = "frost" },
      effects = { { type = "buff", key = "winters_chill", target = "all", match = { tag = "frost" }, stat = "crit", value = 3, duration = 10, maxStacks = 5, stack = true } },
    },
  },
})

ability(8049, "ice_barrier", "Ice Barrier", "frost", "Spell_Ice_Lament", 3, {
  use = { cost = 18, cd = 12, reactive = true, resource = "mana", condition = "noAbsorb", effects = { { type = "absorb", coef = 0.75, amount = 5, powerStat = "sp" } } },
  triggers = { { on = "absorbed", everyAmount = 25, effects = { { type = "cdr", target = "all", match = { key = "frost_nova" }, amount = 0.5, clampReady = true } } } },
  shopWeight = 1.2,
})

ability(8050, "ice_block", "Ice Block", "frost", "Spell_Frost_Frost", 4, {
  use = {
    cost = 18, cd = 24, initialDelay = 0, reactive = true, channel = { key = "ice_block", kind = "buff", duration = 3, self = true },
    resource = "mana", condition = "below35",
    effects = { { type = "buff", key = "ice_block", stat = "dr", value = 80, duration = 3 }, { type = "cleanse", count = 3, debuffs = true } },
    interruptChannel = true,
  },
})

ability(8051, "cold_snap", "Cold Snap", "frost", "Spell_Frost_WizardMark", 5, {
  tags = { "frost", "spell", "cooldown_reset" },
  use = {
    cost = 25, cd = 30, initialDelay = 0, reactive = true, once = true, resource = "mana", condition = "below50",
    effects = { { type = "cdr", target = "neighbors", area = { corners = true }, match = { kind = "ability", notTag = "cooldown_reset", tag = "frost" }, amount = 1000, clampReady = true } },
    minRecovering = 0.5, recoverUsed = true,
  },
  trainingMaxRank = 1,
})

ability(8052, "permafrost", "Permafrost", "frost", "Spell_Frost_Wisp", 1, {
  triggers = {
    {
      on = "anyHit", match = { tag = "frost" },
      effects = { { type = "debuff", key = "permafrost", exclusiveGroup = "frost_chill", stat = "haste", value = 3, duration = 4, maxStacks = 4, stack = true } },
    },
  },
})

ability(8053, "improved_frostbolt", "Improved Frostbolt", "frost", "Spell_Frost_FrostBolt02", 3, {
  triggers = {
    {
      on = "anyCrit", condition = "enemyStunned", match = { key = "frostbolt" },
      effects = { { type = "cdr", target = "neighbors", match = { kind = "ability", damaging = "direct", tag = "frost" }, amount = 1, choose = "first", clampReady = true } },
      healing = false, oncePerActivation = true, paidOnly = true,
    },
  },
  adjacency = { { match = { key = "frostbolt" }, mods = { cdPct = 15 } } }, shopRequires = { "frostbolt" },
})

ability(8054, "piercing_ice", "Piercing Ice", "frost", "Spell_Frost_FrostBolt", 3, {
  triggers = {
    { on = "anyCrit", match = { tag = "frost" }, effects = { { type = "bank", key = "piercing_ice", cap = { flat = 30, sp = 0.5 }, fraction = 0.25 } }, healing = false },
    {
      on = "anyHit", match = { key = "cone_of_cold" },
      effects = { { type = "damage", school = "frost", bankLabel = "stored Frost damage", noCrit = true, noDodge = true, noOwnTriggers = true, spendBank = "piercing_ice" } },
    },
  },
})

ability(8055, "frost_warding", "Frost Warding", "frost", "Spell_Frost_FrostWard", 4, {
  cost = 5,
  triggers = {
    {
      on = "absorbed", icd = 1, everyAmount = 30,
      effects = { { type = "buff", key = "frost_warding", target = "all", match = { damaging = "direct", tag = "frost" }, stat = "dmgPct", value = 20, duration = 8, charges = 1 } },
    },
  },
})

ability(8060, "mana_shield", "Mana Shield", "shared", "Spell_Shadow_DetectLesserInvisibility", 1, {
  tags = { "spell", "defensive" },
  use = { cost = 14, cd = 9, reactive = true, resource = "mana", condition = "noAbsorb", effects = { { type = "absorb", coef = 0.55, amount = 3, powerStat = "sp" } } },
  shopWeight = 1.3,
})

ability(8061, "blink", "Blink", "shared", "Spell_Arcane_Blink", 2, {
  tags = { "spell", "defensive", "blink" },
  use = {
    cost = 12, cd = 15, resource = "mana",
    effects = {
      { type = "buff", key = "blink", stat = "dodge", value = 50, duration = 2 },
      { type = "cdr", target = "all", match = { notTag = "blink", tag = "defensive" }, amount = 1, clampReady = true },
    },
  },
})

ability(8062, "frost_armor", "Frost Armor", "shared", "Spell_Frost_FrostArmor02", 1, {
  kind = "form", tags = { "armor", "frost", "defensive" }, stats = { armor = 12 },
  triggers = {
    {
      on = "damaged", matchAttacker = { tag = "melee" }, icd = 2,
      effects = { { type = "debuff", key = "frost_armor", target = "all", match = { anyTag = { "autoattack" }, tag = "melee" }, stat = "haste", value = 20, duration = 4 } },
    },
  },
})

ability(8063, "ice_armor", "Ice Armor", "shared", "Spell_Frost_FrostArmor02", 2, {
  kind = "form", tags = { "armor", "frost", "defensive" }, stats = { armor = 20 },
  triggers = { { on = "damaged", matchAttacker = { tag = "melee" }, icd = 3, effects = { { type = "stun", duration = 0.5, controlType = "freeze" } } } },
})

ability(8064, "mage_armor", "Mage Armor", "shared", "Spell_MageArmor", 2, { kind = "form", tags = { "armor", "defensive" }, stats = { armor = 6, mana = 20, regen = 2 } })

ability(8065, "remove_lesser_curse", "Remove Lesser Curse", "shared", "Spell_Nature_RemoveCurse", 1, { tags = { "spell", "defensive" }, use = { cost = 6, cd = 10, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 1, debuffs = true } } } })

ability(8070, "mana_agate", "Mana Agate", "arcane", "INV_Misc_Gem_Emerald_01", 1, {
  tags = { "conjured", "mana_recovery" },
  use = { cd = 30, initialDelay = 0, reactive = true, once = true, condition = "lowMana", effects = { { type = "resource", resource = "mana", amount = 35 } } },
})

ability(8071, "dampen_magic", "Dampen Magic", "arcane", "Spell_Nature_AbolishMagic", 2, {
  tags = { "arcane", "spell", "defensive" },
  use = {
    cost = 10, cd = 18, reactive = true, resource = "mana", condition = "injured",
    effects = {
      { type = "buff", key = "dampen_magic", stat = "dr", value = 20, duration = 6, damageSchool = "magic", rankScale = false },
      { type = "buff", key = "dampen_magic_healing", stat = "healPct", value = -20, duration = 6, rankScale = false },
    },
  },
})



ability(8080, "fire_ward", "Fire Ward", "shared", "Spell_Fire_FireArmor", 2, {
  shape = S.L, tags = { "spell", "defensive", "fire", "ward" },
  use = {
    cost = 12, cd = 18, initialDelay = 0, reactive = true, resource = "mana", condition = "injured",
    effects = {
      { type = "absorb", key = "fire_ward", coef = 0.75, amount = 5, duration = 8, damageSchool = "magic", powerStat = "sp" },
      { type = "absorb", key = "fire_ward_flame", coef = 0.25, amount = 0, duration = 8, damageSchool = "fire", powerStat = "sp" },
    },
  },
  shopAffinities = { MAGE = { arcane = 1, fire = 0.5, frost = 0.5 } }, shopWeight = 0.65,
})

ability(8081, "frost_ward", "Frost Ward", "shared", "Spell_Frost_FrostWard", 2, {
  shape = { "111" }, tags = { "spell", "defensive", "frost", "ward" },
  use = {
    cost = 12, cd = 18, initialDelay = 0, reactive = true, resource = "mana", condition = "injured",
    effects = { { type = "absorb", key = "frost_ward", coef = 0.9, amount = 5, duration = 8, damageSchool = "frost", powerStat = "sp" } },
  },
  shopAffinities = { MAGE = { arcane = 0.5, fire = 0.5, frost = 1 } }, shopClasses = {}, shopWeight = 0.65,
})



ability(8083, "improved_mana_shield", "Improved Mana Shield", "arcane", "Spell_Shadow_DetectLesserInvisibility", 2, {
  cost = 3,
  triggers = { { on = "anyUse", match = { key = "mana_shield" }, icd = 1, effects = { { type = "resource", resource = "mana", amount = 0, fromPaid = 0.3 } }, paidOnly = true } },
  shopWeight = 1.1,
})

ability(8084, "improved_fire_blast", "Improved Fire Blast", "fire", "Spell_Fire_Fireball", 2, {
  cost = 4, shape = S.h2,
  triggers = { { on = "anyUse", match = { key = "fire_blast" }, icd = 4, effects = { { type = "cdr", target = "all", match = { key = "fire_blast" }, amount = 1, clampReady = true } } } },
})



ability(8085, "improved_frost_nova", "Improved Frost Nova", "frost", "Spell_Frost_FrostNova", 2, {
  cost = 4, minRound = 3,
  triggers = { { on = "anyUse", match = { key = "frost_nova" }, icd = 8, effects = { { type = "cdr", target = "all", match = { key = "frost_nova" }, amount = 1.5, clampReady = true } } } },
  shopWeight = 0.8,
})



ability(8086, "improved_blizzard", "Improved Blizzard", "frost", "Spell_Frost_IceStorm", 2, {
  minRound = 3, shape = { "11", "01" },
  triggers = {
    { on = "anyUse", match = { key = "blizzard" }, effects = { { type = "debuff", key = "improved_blizzard", exclusiveGroup = "frost_chill", stat = "haste", value = 20, duration = 6 } } },
    {
      on = "channelComplete", match = { key = "blizzard" },
      effects = { { type = "debuff", key = "improved_blizzard", exclusiveGroup = "frost_chill", stat = "haste", value = 20, duration = 6 } },
    },
  },
})



ability(8087, "improved_arcane_explosion", "Improved Arcane Explosion", "arcane", "Spell_Nature_WispSplode", 3, {
  cost = 5,
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_arcane_explosion", target = "all", match = { key = "arcane_explosion", damaging = "direct" }, stat = "crit", value = 15, duration = 999 } },
    },
  },
})

ability(8088, "improved_flamestrike", "Improved Flamestrike", "fire", "Spell_Fire_SelfDestruct", 3, {
  cost = 5,
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_flamestrike", target = "all", match = { key = "flamestrike", damaging = "direct" }, stat = "crit", value = 30, duration = 999 } },
    },
  },
  shopWeight = 0.8,
})

ability(8089, "improved_cone_of_cold", "Improved Cone of Cold", "frost", "Spell_Frost_Glacier", 3, {
  cost = 5,
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_cone_of_cold", target = "all", match = { key = "cone_of_cold", damaging = "direct" }, stat = "dmgPct", value = 20, duration = 999 } },
    },
  },
})

ability(8090, "improved_fire_ward", "Improved Fire Ward", "fire", "Spell_Fire_FireArmor", 3, { cost = 5, shopWeight = 0.6, wardReflection = { key = "fire_ward", chance = 20, school = "magic", charges = 1 } })

ability(8091, "polymorph", "Polymorph", "shared", "Spell_Nature_Polymorph", 3, {
  cost = 3, shape = { "01", "10" }, tags = { "arcane", "spell", "defensive", "control" },
  use = {
    cost = 8, cd = 24, initialDelay = 0, priority = 100, reactive = true, resource = "mana", condition = "lowMana",
    effects = { { type = "stun", duration = 3, breakOnDamage = true, controlType = "incapacitate", healPctPerSecond = 0.02, holdDirect = true, rankScale = false } },
  },
})

ability(8092, "amplify_magic", "Amplify Magic", "shared", "Spell_Holy_FlashHeal", 2, {
  minRound = 3, shape = { "111" }, tags = { "arcane", "spell", "debuff" },
  use = {
    cost = 12, cd = 16, resource = "mana",
    effects = {
      { type = "debuff", key = "amplify_magic_damage", name = "Amplify Magic", stat = "dr", value = 20, duration = 8, damageSchool = "magic" },
      { type = "debuff", key = "amplify_magic_healing", name = "Amplify Magic", stat = "healPct", value = -20, duration = 8 },
    },
  },
  shopWeight = 0.8,
})
