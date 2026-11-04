local ADDON, ns = ...
local H = ns.H
local S = H.S
local SHAMAN = { "SHAMAN" }
local ability = H.QualityAbilities(SHAMAN)




ability(7000, "lightning_bolt", "Lightning Bolt", "elemental", "spell_nature_lightning", 1, {
  tags = { "elemental", "spell", "nature", "lightning" },
  use = {
    cost = 10, cd = 3.5, resource = "mana",
    effects = { { type = "damage", coef = 0.8, min = 4, max = 6, school = "nature", bankLabel = "stored lightning", bankScale = 1, noDodge = true, spendBank = "shaman_lightning" } },
  },
  triggers = { { on = "dotTick", match = { tag = "fire" }, effects = { { type = "bank", key = "shaman_lightning", fraction = 0.3 } } } },
  shopWeight = 2,
})

ability(7001, "earth_shock", "Earth Shock", "elemental", "spell_nature_earthshock", 1, {
  tags = { "elemental", "spell", "nature", "shock" },
  use = { cost = 13, cd = 7, resource = "mana", effects = { { type = "damage", coef = 0.6, min = 3, max = 5, school = "nature", noDodge = true }, { type = "purge", count = 1 } } },
  shopWeight = 1.5,
})

ability(7002, "flame_shock", "Flame Shock", "elemental", "spell_fire_flameshock", 1, {
  tags = { "elemental", "spell", "fire", "shock", "dot" },
  use = {
    cost = 12, cd = 12, resource = "mana",
    effects = {
      { type = "damage", coef = 0.2, min = 1, max = 2, school = "fire", noDodge = true },
      { type = "dot", key = "flame_shock", coef = 0.15, tick = 1, school = "fire", duration = 12, preserveTicks = true },
    },
  },
  shopWeight = 1.5,
})

ability(7003, "frost_shock", "Frost Shock", "elemental", "spell_frost_frostshock", 2, {
  tags = { "elemental", "spell", "frost", "shock" },
  use = {
    cost = 12, cd = 8, resource = "mana",
    effects = {
      { type = "damage", coef = 0.5, min = 2, max = 4, school = "frost", noDodge = true },
      { type = "debuff", key = "frost_shock", name = "Frost Shock", exclusiveGroup = "shaman_slow", stat = "haste", value = 20, duration = 4, rankScale = false },
    },
  },
})

ability(7004, "chain_lightning", "Chain Lightning", "elemental", "spell_nature_chainlightning", 3, {
  minRound = 3, shape = S.L, tags = { "elemental", "spell", "nature", "lightning" },
  use = {
    cost = 24, cd = 8, resource = "mana",
    effects = {
      { type = "damage", coef = 0.85, min = 3, max = 5, school = "nature", bankLabel = "stored periodic Fire damage", bankScale = 1.5, noDodge = true, spendBank = "shaman_chain_lightning" },
      { type = "damage", coef = 0.3, min = 1, max = 2, school = "nature", cond = "enemyHas:flame_shock", noDodge = true },
    },
  },
  triggers = { { on = "dotTick", match = { tag = "fire" }, effects = { { type = "bank", key = "shaman_chain_lightning", bankTarget = "Chain Lightning", fraction = 0.5 } } } },
})

ability(7005, "elemental_focus", "Elemental Focus", "elemental", "spell_shadow_manaburn", 2, {
  shape = S.v2, tags = { "elemental", "spell", "nature" },
  triggers = {
    {
      on = "anyCrit", match = { damaging = true, tag = "elemental" },
      effects = {
        {
          type = "buff", key = "shaman_clearcasting", name = "Elemental Focus", match = { damaging = true, tag = "elemental" }, stat = "none",
          value = 0, duration = 10, charges = 1, free = true,
        },
      },
      healing = false,
    },
  },
  rankable = false,
})

ability(7006, "elemental_fury", "Elemental Fury", "elemental", "spell_fire_volcano", 5, {
  minRound = 9, shape = S.v2, tags = { "elemental", "spell", "nature" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        {
          type = "buff", key = "elemental_fury", name = "Elemental Fury", target = "all",
          match = { anyTag = { "elemental" }, damaging = "direct", tag = "spell" }, stat = "critDamage", value = 35, duration = 120,
        },
      },
    },
    {
      on = "anyCrit", match = { anyTag = { "elemental" }, damaging = "direct", tag = "spell" }, icd = 2,
      effects = { { type = "tickDots", target = "neighbors", match = { tag = "fire" } } }, effective = true, healing = false, oncePerActivation = true,
      paidOnly = true,
    },
  },
  adjacency = { { match = { tag = "spell" }, mods = { crit = 5, dmgPct = 15 } } }, rankable = false, shopWeight = 0.65,
})

ability(7007, "convection", "Convection", "elemental", "spell_nature_wispsplode", 1, { tags = { "elemental", "spell", "nature" }, adjacency = { { match = { anyTag = { "lightning", "shock" } }, mods = { costPct = -15 } } }, passiveTriggers = true })

ability(7008, "concussion", "Concussion", "elemental", "spell_fire_fireball", 1, {
  tags = { "elemental", "spell", "nature" },
  adjacency = { { match = { anyTag = { "lightning", "shock" }, damaging = "direct" }, mods = { dmgPct = 15 }, side = "front" } },
  passiveTriggers = true,
})

ability(7009, "call_of_flame", "Call of Flame", "elemental", "spell_fire_immolation", 2, {
  shape = S.v2, tags = { "elemental", "spell", "nature" },
  triggers = { { on = "anyUse", match = { tag = "shock" }, effects = { { type = "tickDots", match = { tag = "fire" } } } } },
  adjacency = { { match = { tag = "damaging_totem" }, mods = { dmgPct = 10 } } }, rankable = false,
})

ability(7010, "reverberation", "Reverberation", "elemental", "spell_frost_frostward", 2, {
  minRound = 3, shape = S.v2, tags = { "elemental", "spell", "nature" },
  triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "cdr", target = "all", match = { tag = "shock" }, amount = 0.5, clampReady = true } } } },
  rankable = false,
})

ability(7011, "lightning_mastery", "Lightning Mastery", "elemental", "spell_lightning_lightningbolt01", 4, {
  minRound = 6, shape = S.v2, tags = { "elemental", "spell", "nature" },
  triggers = {
    {
      on = "resourceSpent", resource = "mana", everyAmount = 30,
      effects = {
        { type = "cdr", target = "all", match = { key = "lightning_bolt" }, amount = 1, clampReady = true },
        { type = "cdr", target = "all", match = { key = "chain_lightning" }, amount = 1, clampReady = true },
      },
    },
  },
  rankable = false,
})

ability(7012, "elemental_mastery", "Elemental Mastery", "elemental", "spell_nature_wispheal", 4, {
  tags = { "elemental", "spell", "nature" },
  use = {
    cost = 12, cd = 24, resource = "mana",
    effects = {
      {
        type = "buff", key = "elemental_mastery", name = "Elemental Mastery", target = "all", match = { damaging = "direct", tag = "elemental" },
        stat = "crit", value = 100, duration = 10, charges = 1, rankScale = false,
      },
      {
        type = "buff", key = "elemental_mastery_free", name = "Elemental Mastery", match = { damaging = "direct", tag = "elemental" }, stat = "none",
        value = 0, duration = 10, charges = 1, free = true, rankScale = false,
      },
    },
  },
  rankable = false,
})

ability(7013, "elemental_devastation", "Elemental Devastation", "elemental", "classic_spell_fire_elementaldevastation", 3, {
  minRound = 3, shape = S.v2, tags = { "elemental", "spell", "nature" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "spell" },
      effects = { { type = "buff", key = "elemental_devastation", name = "Elemental Devastation", target = "all", match = { tag = "melee" }, stat = "crit", value = 15, duration = 6 } },
      healing = false,
    },
  },
})

ability(7020, "rockbiter_weapon", "Rockbiter Weapon", "enhancement", "spell_nature_rockbiter", 1, {
  shape = S.v2, tags = { "enhancement", "imbue" }, stats = { ap = 14 }, exclusiveGroup = "shaman_imbue", exclusiveLabel = "Weapon Imbue",
  triggers = {
    { on = "regularHit", match = { tag = "melee" }, effects = { { type = "bank", key = "shaman_stormstrike", bankTarget = "Stormstrike or shock", fraction = 0.25 } } },
    {
      on = "resourceSpent", resource = "mana", match = { tag = "shock" },
      effects = { { type = "damage", school = "nature", bankLabel = "stored weapon damage", noDodge = true, noOwnTriggers = true, spendBank = "shaman_stormstrike" } },
    },
  },
  rankable = false,
})


ability(7021, "flametongue_weapon", "Flametongue Weapon", "enhancement", "spell_fire_flametounge", 1, {
  shape = S.v2, tags = { "enhancement", "imbue", "fire" }, exclusiveGroup = "shaman_imbue", exclusiveLabel = "Weapon Imbue",
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" },
      effects = { { type = "damage", coef = 0.15, min = 2, max = 3, school = "fire", fromEvent = 0.25, noDodge = true, noOwnTriggers = true } },
    },
  },
  shopAffinities = { SHAMAN = { elemental = 0.5, enhancement = 1 } }, shopWeight = 1.3,
})

ability(7022, "frostbrand_weapon", "Frostbrand Weapon", "enhancement", "spell_frost_frostbrand", 2, {
  shape = S.v2, tags = { "enhancement", "imbue" }, exclusiveGroup = "shaman_imbue", exclusiveLabel = "Weapon Imbue",
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" }, chance = 30,
      effects = {
        { type = "damage", coef = 0.2, min = 5, max = 8, school = "frost", noDodge = true, noOwnTriggers = true },
        { type = "debuff", key = "frostbrand", name = "Frostbrand Weapon", exclusiveGroup = "shaman_slow", stat = "haste", value = 20, duration = 5 },
      },
    },
  },
})

ability(7023, "windfury_weapon", "Windfury Weapon", "enhancement", "spell_nature_cyclone", 3, {
  minRound = 3, shape = S.v2, tags = { "enhancement", "imbue" }, stats = { ap = 10 }, exclusiveGroup = "shaman_imbue", exclusiveLabel = "Weapon Imbue",
  triggers = {
    { on = "regularHit", match = { tag = "melee" }, chance = 20, effects = { { type = "extraAttack", bonusAttackPowerPct = 150, count = 2 } } },
    { on = "extraHit", match = { kind = "weapon", anyTag = { "autoattack" }, tag = "melee" }, chance = 5, effects = { { type = "extraAttack", bonusAttackPowerPct = 150, count = 2 } } },
    { on = "anyHit", match = { key = "stormstrike", kind = "ability", tag = "melee" }, chance = 20, effects = { { type = "extraAttack", bonusAttackPowerPct = 150, count = 2 } } },
  },
  rankable = false,
})

ability(7024, "stormstrike", "Stormstrike", "enhancement", "spell_holy_sealofmight", 3, {
  minRound = 3, shape = S.L, tags = { "enhancement", "melee", "strike" },
  use = {
    cost = 18, cd = 9, resource = "mana", requires = "melee",
    effects = {
      { type = "damage", coef = 0.7, min = 1, max = 3, school = "physical", weapon = true, weaponPct = 1.5 },
      {
        type = "buff", key = "stormstrike_nature", name = "Stormstrike", target = "all", match = { damaging = "direct", tag = "nature" },
        stat = "dmgPct", value = 25, duration = 8, charges = 2, rankScale = false,
      },
    },
  },
  shopWeight = 2,
})

ability(7025, "lightning_shield", "Lightning Shield", "enhancement", "spell_nature_lightningshield", 1, {
  tags = { "enhancement", "spell", "nature" },
  use = {
    cost = 12, cd = 12, initialDelay = 0, resource = "mana", condition = "buffNeeds:lightning_shield:0.1",
    effects = { { type = "buff", key = "lightning_shield", name = "Lightning Shield", stat = "none", value = 0, duration = 12 } },
  },
  triggers = {
    { on = "damaged", condition = "buff:lightning_shield", icd = 1.5, effects = { { type = "damage", coef = 0.3, min = 1, max = 2, school = "nature", noCrit = true, noDodge = true } } },
    {
      on = "resourceSpent", resource = "mana", condition = "buff:lightning_shield",
      match = { anyTag = { "nature", "shock" }, damaging = "direct", tag = "spell" },
      effects = {
        {
          type = "debuff", key = "shaman_lightning_charge", name = "Lightning Charge", stat = "none", value = 0, duration = 12, rankScale = false,
          stack = true, stacksFromEvent = 0.75, uncapped = true,
        },
      },
    },
    {
      on = "regularHit", condition = "buff:lightning_shield", match = { tag = "melee" },
      effects = { { type = "damage", school = "nature", consumeDebuff = "shaman_lightning_charge", noCrit = true, noDodge = true, noOwnTriggers = true, perDebuffStack = 1, rankScale = false } },
    },
  },
  rankTriggers = true, shopAffinities = { SHAMAN = { elemental = 0.4, enhancement = 1, restoration = 0.6 } }, shopWeight = 1.5,
})

ability(7026, "shaman_flurry", "Flurry", "enhancement", "ability_ghoulfrenzy", 2, {
  shape = S.v2, tags = { "enhancement", "spell", "nature" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "melee" },
      effects = { { type = "buff", key = "shaman_flurry", name = "Flurry", target = "all", match = { tag = "melee" }, stat = "haste", value = 20, duration = 7, charges = 3 } },
      healing = false,
    },
  },
})

ability(7027, "thundering_strikes", "Thundering Strikes", "enhancement", "ability_thunderbolt", 1, { tags = { "enhancement", "spell", "nature" }, adjacency = { { match = { tag = "melee" }, mods = { crit = 10 } } }, passiveTriggers = true })

ability(7028, "elemental_weapons", "Elemental Weapons", "enhancement", "spell_fire_flametounge", 3, {
  cost = 5, shape = S.v2, tags = { "enhancement", "spell", "nature" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        { type = "buff", key = "elemental_weapons_rockbiter", target = "all", match = { key = "rockbiter_weapon" }, stat = "bankPct", value = 25, duration = 120, rankScale = false },
        { type = "buff", key = "elemental_weapons_flametongue", target = "all", match = { key = "flametongue_weapon" }, stat = "dmgPct", value = 20, duration = 120, rankScale = false },
        { type = "buff", key = "elemental_weapons_frostbrand", target = "all", match = { key = "frostbrand_weapon" }, stat = "dmgPct", value = 20, duration = 120, rankScale = false },
        {
          type = "buff", key = "elemental_weapons_windfury", target = "all", match = { key = "windfury_weapon" }, stat = "extraAttackBonusPct",
          value = 25, duration = 120, rankScale = false,
        },
      },
    },
  },
})

ability(7029, "improved_lightning_shield", "Improved Lightning Shield", "enhancement", "spell_nature_lightningshield", 2, {
  minRound = 3, shape = S.v2, tags = { "enhancement", "spell", "nature" },
  triggers = { { on = "anyHit", match = { key = "lightning_shield" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.15 } } } },
  shopRequires = { "lightning_shield" },
})

ability(7030, "shaman_weapon_mastery", "Weapon Mastery", "enhancement", "ability_hunter_swiftstrike", 5, {
  minRound = 9, shape = S.v2, tags = { "enhancement", "spell", "nature" },
  triggers = { { on = "adjacentHit", match = { kind = "weapon", tag = "melee" }, every = 3, effects = { { type = "reapplyImbue" } }, effective = true, regularAttackOnly = true } },
  adjacency = { { match = { kind = "weapon", tag = "melee" }, mods = { dmgPct = 12 } } }, rankable = false, shopWeight = 0.65,
})

ability(7031, "shaman_toughness", "Toughness", "enhancement", "spell_holy_devotion", 1, { tags = { "enhancement", "spell", "nature" }, gearBonuses = { { coef = 0.2, stat = "armor", gearStat = "armor" } }, passiveTriggers = true })

ability(7032, "anticipation_shaman", "Anticipation", "enhancement", "spell_nature_mirrorimage", 1, { tags = { "enhancement", "spell", "nature" }, stats = { dodge = 5 }, passiveTriggers = true, rankable = false, shopClasses = {} })



ability(7040, "healing_wave", "Healing Wave", "restoration", "spell_nature_magicimmunity", 1, {
  tags = { "restoration", "spell", "nature", "heal" },
  use = {
    cost = 24, cd = 5, resource = "mana", condition = "below75",
    effects = { { type = "heal", coef = 0.4, min = 4, max = 6, pctMax = 0.02 }, { type = "tickHots", match = { tag = "totem" } } },
  },
  shopWeight = 1.6,
})

ability(7041, "lesser_healing_wave", "Lesser Healing Wave", "restoration", "spell_nature_healingwavelesser", 1, {
  shape = S.one, tags = { "restoration", "spell", "nature", "heal" },
  use = { cost = 15, cd = 2.8, resource = "mana", condition = "injured", effects = { { type = "heal", coef = 0.35, min = 3, max = 5 } } },
  shopWeight = 1.4,
})

ability(7042, "chain_heal", "Chain Heal", "restoration", "spell_nature_healingwavegreater", 3, {
  minRound = 3, shape = S.L, tags = { "restoration", "spell", "nature", "heal" },
  use = {
    cost = 30, cd = 7, resource = "mana", condition = "below75",
    effects = {
      { type = "heal", coef = 0.6, min = 3, max = 5 }, { type = "heal", coef = 0.25, min = 1, max = 2 },
      { type = "cdr", target = "neighbors", area = { corners = true }, match = { notTag = "mana_totem", tag = "totem" }, amount = 2, clampReady = true, rankScale = false },
      { type = "tickHots", target = "neighbors", area = { corners = true }, match = { notTag = "mana_totem", tag = "totem" } },
      { type = "tickDots", target = "neighbors", area = { corners = true }, match = { notTag = "mana_totem", tag = "totem" } },
    },
  },
})

ability(7043, "ancestral_healing", "Ancestral Healing", "restoration", "spell_nature_undyingstrength", 2, {
  shape = S.v2, tags = { "restoration", "spell", "nature" },
  triggers = {
    {
      on = "anyCrit",
      effects = {
        { type = "buff", key = "ancestral_healing", name = "Ancestral Healing", stat = "armor", value = 0, duration = 8, gearCoef = 0.15, gearStat = "armor", rankScale = false },
        { type = "absorb", fromEvent = 0.15, rankScale = false },
      },
      healing = true,
    },
  },
})

ability(7044, "healing_way", "Healing Way", "restoration", "classic_spell_nature_healingway", 2, {
  cost = 3, shape = S.v2, tags = { "restoration", "spell", "nature" },
  triggers = {
    {
      on = "anyUse", match = { key = "healing_wave" },
      effects = {
        {
          type = "buff", key = "healing_way", name = "Healing Way", target = "all", match = { key = "healing_wave" }, stat = "healPct", value = 10,
          duration = 12, maxStacks = 3, stack = true,
        },
      },
    },
  },
  shopRequires = { "healing_wave" },
})

ability(7045, "tidal_focus", "Tidal Focus", "restoration", "spell_frost_manarecharge", 1, { tags = { "restoration", "spell", "nature" }, adjacency = { { match = { tag = "heal" }, mods = { costPct = -15 } } }, passiveTriggers = true })

ability(7046, "tidal_mastery", "Tidal Mastery", "restoration", "spell_nature_tranquility", 2, {
  tags = { "restoration", "spell", "nature" }, adjacency = { { match = { anyTag = { "heal", "lightning" } }, corners = true, mods = { crit = 10 } } },
  passiveTriggers = true, shopAffinities = { SHAMAN = { elemental = 0.7, restoration = 1 } },
})

ability(7047, "purification", "Purification", "restoration", "spell_frost_wizardmark", 3, { tags = { "restoration", "spell", "nature" }, stats = { healing = 30 }, passiveTriggers = true, rankable = false, shopClasses = {} })

ability(7048, "restorative_totems", "Restorative Totems", "restoration", "spell_nature_manaregentotem", 2, {
  minRound = 3, shape = S.v2, tags = { "restoration", "spell", "nature" },
  triggers = { { on = "healed", match = { tag = "totem" }, effects = { { type = "resource", resource = "mana", amount = 1, rankScale = false } } } },
  adjacency = { { match = { tag = "totem" }, mods = { healPct = 15 }, side = "back" } },
})

ability(7049, "natures_swiftness_shaman", "Nature's Swiftness", "restoration", "spell_nature_ravenform", 4, {
  minRound = 6, tags = { "restoration", "spell", "nature" },
  use = {
    cost = 10, cd = 24, initialDelay = 0, resource = "mana", condition = "below50",
    effects = {
      { type = "cdr", target = "all", match = { tag = "heal" }, amount = 5, clampReady = true },
      { type = "buff", key = "shaman_swiftness", name = "Nature's Swiftness", match = { tag = "heal" }, stat = "none", value = 0, duration = 8, charges = 1, free = true, rankScale = false },
    },
  },
  rankable = false,
})



ability(7050, "healing_grace", "Healing Grace", "restoration", "spell_nature_healingtouch", 2, {
  minRound = 3, shape = S.v2, tags = { "restoration", "spell", "nature" }, stats = { healing = 6 },
  triggers = { { on = "healed", everyAmount = 25, effects = { { type = "cdr", target = "neighbors", match = { notTag = "mana_totem", tag = "totem" }, amount = 0.8, clampReady = true } } } },
  rankable = false,
})

ability(7051, "healing_focus_shaman", "Healing Focus", "restoration", "spell_nature_healingwavelesser", 3, {
  shape = S.v2, tags = { "restoration", "spell", "nature" }, stats = { healing = 8 },
  triggers = { { on = "damaged", icd = 1, everyAmount = 40, effects = { { type = "cdr", target = "all", match = { tag = "heal" }, amount = 1, clampReady = true } } } },
  rankable = false,
})

ability(7052, "totemic_mastery", "Totemic Mastery", "restoration", "spell_nature_nullward", 5, {
  minRound = 9, shape = S.v2, tags = { "restoration", "spell", "nature" },
  triggers = {
    {
      on = "hotTick", match = { tag = "totem" }, icd = 4, every = 4,
      effects = { { type = "heal", pctMax = 0.025 }, { type = "cast", target = "neighbors", match = { notTag = "mana_totem", tag = "totem" }, choose = "first", consumeCooldown = true } },
      effective = true,
    },
  },
  rankable = false, shopRequires = { "healing_stream_totem" }, shopWeight = 0.65,
})

ability(7060, "searing_totem", "Searing Totem", "elemental", "spell_fire_searingtotem", 1, {
  tags = { "elemental", "spell", "totem", "fire", "damaging_totem", "damaging_totem" }, exclusiveGroup = "shaman_fire_totem",
  exclusiveLabel = "Fire Totem",
  use = { cost = 3, cd = 2.5, resource = "mana", effects = { { type = "damage", coef = 0.25, min = 1, max = 2, school = "fire", noDodge = true } } },
  shopWeight = 1.4,
})

ability(7061, "magma_totem", "Magma Totem", "elemental", "spell_fire_selfdestruct", 2, {
  minRound = 3, tags = { "elemental", "spell", "totem", "fire", "dot", "damaging_totem" }, exclusiveGroup = "shaman_fire_totem",
  exclusiveLabel = "Fire Totem",
  use = {
    cost = 16, cd = 10, resource = "mana", condition = "enemyNeeds:magma_totem:0.1",
    effects = { { type = "dot", key = "magma_totem", coef = 0.2, tick = 1, school = "fire", duration = 8, preserveTicks = true } },
  },
})

ability(7062, "fire_nova_totem", "Fire Nova Totem", "elemental", "spell_fire_sealoffire", 3, {
  shape = S.L, tags = { "elemental", "spell", "totem", "fire", "damaging_totem", "damaging_totem" }, exclusiveGroup = "shaman_fire_totem",
  exclusiveLabel = "Fire Totem",
  use = {
    cost = 20, cd = 11, initialDelay = 5, delay = 4, resource = "mana",
    effects = { { type = "damage", coef = 1.25, min = 3, max = 5, school = "fire", consumeDots = { match = { tag = "fire" }, fraction = 0.35 }, noDodge = true } },
  },
})

ability(7063, "strength_of_earth_totem", "Strength of Earth Totem", "enhancement", "spell_nature_earthbindtotem", 1, { tags = { "enhancement", "totem", "nature" }, stats = { ap = 18 }, exclusiveGroup = "shaman_earth_totem", exclusiveLabel = "Earth Totem", passiveTriggers = true, shopClasses = {} })

ability(7064, "stoneskin_totem", "Stoneskin Totem", "enhancement", "spell_nature_stoneskintotem", 1, {
  tags = { "enhancement", "totem", "nature" }, stats = { armor = 24, block = 4 }, exclusiveGroup = "shaman_earth_totem",
  exclusiveLabel = "Earth Totem", passiveTriggers = true, shopClasses = {},
})

ability(7065, "earthbind_totem", "Earthbind Totem", "enhancement", "spell_nature_strengthofearthtotem02", 2, {
  tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_earth_totem", exclusiveLabel = "Earth Totem",
  use = {
    cost = 8, cd = 12, resource = "mana",
    effects = { { type = "debuff", key = "earthbind", name = "Earthbind Totem", exclusiveGroup = "shaman_slow", stat = "haste", value = 20, duration = 7, rankScale = false } },
  },
  rankable = false,
})

ability(7066, "stoneclaw_totem", "Stoneclaw Totem", "enhancement", "spell_nature_stoneclawtotem", 2, {
  minRound = 3, tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_earth_totem", exclusiveLabel = "Earth Totem",
  use = { cost = 12, cd = 12, resource = "mana", condition = "noAbsorb", effects = { { type = "absorb", coef = 0.65, amount = 3 } } },
})

ability(7067, "windfury_totem", "Windfury Totem", "enhancement", "spell_nature_windfury", 4, {
  minRound = 6, shape = S.v2, tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_air_totem", exclusiveLabel = "Air Totem",
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 12, effects = { { type = "extraAttack", count = 1 } } } },
})

ability(7068, "grace_of_air_totem", "Grace of Air Totem", "enhancement", "spell_nature_invisibilitytotem", 2, {
  minRound = 3, tags = { "enhancement", "totem", "nature" }, stats = { crit = 5, dodge = 4 }, exclusiveGroup = "shaman_air_totem",
  exclusiveLabel = "Air Totem", passiveTriggers = true, shopClasses = {},
})

ability(7069, "grounding_totem", "Grounding Totem", "enhancement", "spell_nature_groundingtotem", 3, { shape = S.v2, tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_air_totem", exclusiveLabel = "Air Totem", spellIntercept = { cooldown = 10 } })

ability(7070, "healing_stream_totem", "Healing Stream Totem", "restoration", "inv_spear_04", 1, {
  tags = { "restoration", "nature", "totem", "heal" }, exclusiveGroup = "shaman_water_totem", exclusiveLabel = "Water Totem",
  use = {
    cost = 10, cd = 10, resource = "mana", condition = "hotNeeds:healing_stream_totem:0.1",
    effects = { { type = "hot", key = "healing_stream_totem", coef = 0.2, tick = 1, duration = 10, preserveTicks = true } },
  },
  shopWeight = 1.4,
})

ability(7071, "mana_spring_totem", "Mana Spring Totem", "restoration", "spell_nature_manaregentotem", 1, {
  shape = S.one, tags = { "restoration", "nature", "totem", "mana_totem" }, exclusiveGroup = "shaman_water_totem", exclusiveLabel = "Water Totem",
  use = { cost = 0, cd = 4, resource = "mana", effects = { { type = "resource", resource = "mana", amount = 6 } } },
})

ability(7072, "mana_tide_totem", "Mana Tide Totem", "restoration", "spell_frost_summonwaterelemental", 4, {
  tags = { "restoration", "nature", "totem", "mana_totem" }, exclusiveGroup = "shaman_water_totem", exclusiveLabel = "Water Totem",
  use = {
    cost = 0, cd = 20, resource = "mana", condition = "lowMana",
    effects = { { type = "buff", key = "mana_tide_totem", stat = "none", value = 0, duration = 3, periodic = { every = 1, effects = { { type = "resource", resource = "mana", pctMax = 0.15 } } } } },
  },
})

ability(7073, "purge", "Purge", "shared", "spell_nature_purge", 2, { shape = S.one, tags = { "shared", "spell", "nature" }, use = { cost = 8, cd = 10, resource = "mana", effects = { { type = "purge", count = 2 } } }, rankable = false })

ability(7074, "cure_poison_shaman", "Cure Poison", "shared", "spell_nature_nullifypoison", 1, {
  cost = 1, shape = S.one, tags = { "shared", "spell", "nature" },
  use = { cost = 8, cd = 9, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 1, debuffs = true } } },
  rankable = false,
})

ability(7075, "ancestral_knowledge", "Ancestral Knowledge", "enhancement", "spell_shadow_grimward", 1, { tags = { "enhancement", "spell", "nature" }, stats = { mana = 30 }, passiveTriggers = true, rankable = false, shopClasses = {} })


ability(7080, "flametongue_totem", "Flametongue Totem", "enhancement", "spell_nature_guardianward", 2, {
  shape = { "11", "01" }, tags = { "enhancement", "totem", "fire", "damaging_totem" }, exclusiveGroup = "shaman_fire_totem",
  exclusiveLabel = "Fire Totem",
  use = {
    cost = 8, cd = 12, initialDelay = 0, resource = "mana", requires = "melee", condition = "buffNeeds:flametongue_totem:0.1",
    effects = { { type = "buff", key = "flametongue_totem", name = "Flametongue Totem", stat = "none", value = 0, duration = 8, rankScale = false } },
  },
  triggers = {
    {
      on = "regularHit", condition = "buff:flametongue_totem", match = { kind = "weapon", tag = "melee" },
      effects = { { type = "damage", coef = 0.35, min = 1, max = 1, school = "fire", fromEvent = 0.1, noCrit = true, noDodge = true, noOwnTriggers = true, rankScale = false } },
    },
  },
  rankTriggers = true, shopAffinities = { SHAMAN = { elemental = 0.6, enhancement = 1 } },
})

ability(7081, "totemic_focus", "Totemic Focus", "restoration", "spell_nature_moonglow", 1, {
  shape = S.L, tags = { "restoration", "spell", "nature" }, adjacency = { { match = { tag = "totem" }, corners = true, mods = { costPct = -15 } } },
  passiveTriggers = true, shopAffinities = { SHAMAN = { elemental = 0.8, enhancement = 0.8, restoration = 1 } }, shopClasses = {},
})

ability(7082, "improved_fire_totems", "Improved Fire Totems", "elemental", "spell_fire_sealoffire", 2, {
  cost = 2, minRound = 3, tags = { "elemental", "spell", "nature" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_fire_totems", target = "all", match = { key = "fire_nova_totem" }, stat = "delayFlat", value = -1, duration = 120, rankScale = false } },
    },
  },
})

ability(7083, "fire_resistance_totem", "Fire Resistance Totem", "shared", "spell_fireresistancetotem_01", 1, {
  minRound = 2, shape = S.h2, tags = { "shared", "totem", "fire", "defensive" }, exclusiveGroup = "shaman_water_totem", exclusiveLabel = "Water Totem",
  use = {
    cost = 8, cd = 16, initialDelay = 0, resource = "mana", condition = "buffNeeds:fire_resistance_totem:0.1",
    effects = { { type = "buff", key = "fire_resistance_totem", name = "Fire Resistance Totem", stat = "dr", value = 25, duration = 16, damageSchool = "fire", rankScale = false } },
  },
  shopWeight = 0.35,
})

ability(7084, "nature_resistance_totem", "Nature Resistance Totem", "shared", "spell_nature_natureresistancetotem", 1, {
  minRound = 2, shape = S.h2, tags = { "shared", "totem", "nature", "defensive" }, exclusiveGroup = "shaman_air_totem", exclusiveLabel = "Air Totem",
  use = {
    cost = 8, cd = 16, initialDelay = 0, resource = "mana", condition = "buffNeeds:nature_resistance_totem:0.1",
    effects = { { type = "buff", key = "nature_resistance_totem", name = "Nature Resistance Totem", stat = "dr", value = 25, duration = 16, damageSchool = "nature", rankScale = false } },
  },
  shopWeight = 0.35,
})

ability(7085, "poison_cleansing_totem", "Poison Cleansing Totem", "restoration", "spell_nature_poisoncleansingtotem", 2, {
  cost = 4, shape = S.T, tags = { "restoration", "totem", "nature", "defensive" }, exclusiveGroup = "shaman_water_totem",
  exclusiveLabel = "Water Totem",
  use = { cost = 3, cd = 5, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 1, debuffs = true, rankScale = false } } },
  rankable = false, shopWeight = 0.6,
})

ability(7086, "reincarnation", "Reincarnation", "shared", "spell_nature_reincarnation", 3, {
  cost = 7, minRound = 6, shape = { "10", "10", "11" }, tags = { "shared", "spell", "nature" }, passiveTriggers = true, rankable = false,
  revive = { health = 0.2, mana = 0.2 }, shopWeight = 0.35,
})

ability(7087, "earths_grasp", "Earth's Grasp", "enhancement", "spell_nature_stoneclawtotem", 2, {
  cost = 4, minRound = 3, shape = S.T, tags = { "enhancement", "spell", "nature" },
  triggers = { { on = "anyUse", match = { key = "stoneclaw_totem" }, icd = 10, effects = { { type = "absorb", coef = 0.25, amount = 0, rankScale = false } }, oncePerActivation = true } },
  shopAffinities = { SHAMAN = { enhancement = 1, restoration = 0.8 } }, shopClasses = {}, shopRequires = { "stoneclaw_totem" },
})


ability(7088, "shaman_shield_specialization", "Shield Specialization", "enhancement", "inv_shield_06", 1, {
  minRound = 2, shape = S.h2, tags = { "enhancement", "spell", "nature" },
  triggers = {
    {
      on = "battleStart", condition = "provides:shield",
      effects = { { type = "buff", key = "shaman_shield_specialization", stat = "block", value = 0, duration = 120, gearCoef = 0.25, gearStat = "block", rankScale = false } },
    },
  },
  adjacency = { { stats = { blockChance = 10 }, once = true, match = { kind = "shield" }, side = "front" } },
  shopAffinities = { SHAMAN = { elemental = 0.3, enhancement = 1, restoration = 0.5 } }, shopFitRequires = { "shield" },
})

ability(7089, "improved_healing_wave", "Improved Healing Wave", "restoration", "spell_nature_magicimmunity", 1, {
  minRound = 2, tags = { "restoration", "spell", "nature" },
  triggers = {
    { on = "battleStart", effects = { { type = "cdr", target = "all", match = { key = "healing_wave" }, amount = 1, clampReady = true } } },
    {
      on = "anyUse", match = { key = "healing_wave" }, icd = 0.5,
      effects = { { type = "cdr", target = "all", match = { key = "healing_wave" }, amount = 1, clampReady = true } }, oncePerActivation = true,
    },
  },
  rankable = false,
})

ability(7090, "guardian_totems", "Guardian Totems", "enhancement", "spell_nature_stoneskintotem", 2, {
  cost = 3, minRound = 3, tags = { "enhancement", "spell", "nature" },
  triggers = {
    {
      on = "anyUse", match = { key = "stoneskin_totem_active" }, icd = 1,
      effects = { { type = "buff", key = "guardian_stoneskin", stat = "dr", value = 10, duration = 8, damageSchool = "physical", rankScale = false } },
      oncePerActivation = true,
    },
    {
      on = "anyUse", match = { key = "windwall_totem" }, icd = 1,
      effects = { { type = "buff", key = "guardian_windwall", stat = "dr", value = 10, duration = 8, damageSchool = "physical", rangedOnly = true, rankScale = false } },
      oncePerActivation = true,
    },
  },
  rankable = false, shopAffinities = { SHAMAN = { elemental = 0.4, enhancement = 1, restoration = 0.6 } }, shopWeight = 0.6,
})

ability(7091, "elemental_warding", "Elemental Warding", "elemental", "spell_nature_spiritarmor", 1, {
  minRound = 2, tags = { "elemental", "spell", "nature" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        { type = "buff", key = "elemental_warding_fire", stat = "dr", value = 10, duration = 120, damageSchool = "fire", rankScale = false },
        { type = "buff", key = "elemental_warding_frost", stat = "dr", value = 10, duration = 120, damageSchool = "frost", rankScale = false },
        { type = "buff", key = "elemental_warding_nature", stat = "dr", value = 10, duration = 120, damageSchool = "nature", rankScale = false },
      },
    },
  },
  rankable = false, shopWeight = 0.6,
})





ability(7160, "strength_of_earth_totem_active", "Strength of Earth Totem", "enhancement", "spell_nature_earthbindtotem", 1, {
  tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_earth_totem", exclusiveLabel = "Earth Totem",
  use = {
    cost = 8, cd = 12, initialDelay = 0, resource = "mana", condition = "buffNeeds:strength_of_earth_active:0.1",
    effects = { { type = "buff", key = "strength_of_earth_active", name = "Strength of Earth Totem", stat = "ap", value = 6, duration = 8, gearCoef = 0.15, gearStat = "ap", rankScale = false } },
    rankCosts = { [2] = 10, [3] = 12 },
  },
})

ability(7161, "stoneskin_totem_active", "Stoneskin Totem", "enhancement", "spell_nature_stoneskintotem", 1, {
  tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_earth_totem", exclusiveLabel = "Earth Totem",
  use = {
    cost = 8, cd = 14, initialDelay = 0, resource = "mana", condition = "buffNeeds:stoneskin_active:0.1",
    effects = { { type = "buff", key = "stoneskin_active", name = "Stoneskin Totem", stat = "dr", value = 20, duration = 8, damageSchool = "physical" } },
  },
})

ability(7162, "grace_of_air_totem_active", "Grace of Air Totem", "enhancement", "spell_nature_invisibilitytotem", 2, {
  minRound = 3, tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_air_totem", exclusiveLabel = "Air Totem",
  use = {
    cost = 10, cd = 14, initialDelay = 0, resource = "mana", condition = "buffNeeds:grace_of_air_crit:0.1",
    effects = {
      { type = "buff", key = "grace_of_air_crit", name = "Grace of Air Totem", stat = "crit", value = 5, duration = 8, gearCoef = 0.25, gearStat = "crit", rankScale = false },
      { type = "buff", key = "grace_of_air_dodge", name = "Grace of Air Totem", stat = "dodge", value = 8, duration = 8 },
    },
  },
})

ability(7163, "windwall_totem", "Windwall Totem", "enhancement", "spell_nature_earthbind", 1, {
  tags = { "enhancement", "totem", "nature" }, exclusiveGroup = "shaman_air_totem", exclusiveLabel = "Air Totem",
  use = {
    cost = 8, cd = 16, initialDelay = 0, resource = "mana", condition = "buffNeeds:windwall_totem:0.1",
    effects = { { type = "buff", key = "windwall_totem", name = "Windwall Totem", stat = "dr", value = 25, duration = 8, damageSchool = "physical", rangedOnly = true } },
  },
})

ability(7164, "frost_resistance_totem", "Frost Resistance Totem", "enhancement", "spell_frostresistancetotem_01", 1, {
  tags = { "enhancement", "totem", "frost" }, exclusiveGroup = "shaman_fire_totem", exclusiveLabel = "Fire Totem",
  use = {
    cost = 8, cd = 16, initialDelay = 0, resource = "mana", condition = "buffNeeds:frost_resistance_totem:0.1",
    effects = { { type = "buff", key = "frost_resistance_totem", name = "Frost Resistance Totem", stat = "dr", value = 25, duration = 16, damageSchool = "frost" } },
  },
  shopWeight = 0.35,
})

ability(7165, "tremor_totem", "Tremor Totem", "restoration", "spell_nature_tremortotem", 3, {
  tags = { "restoration", "totem", "nature" }, exclusiveGroup = "shaman_earth_totem", exclusiveLabel = "Earth Totem",
  use = {
    cost = 10, cd = 18, initialDelay = 0, resource = "mana", condition = "buffNeeds:tremor_totem:0.1",
    effects = { { type = "buff", key = "tremor_totem", name = "Tremor Totem", stat = "none", value = 0, duration = 10 } },
  },
  triggers = { { on = "stunned", condition = "buff:tremor_totem", effects = { { type = "clearControl", types = { "fear", "charm", "sleep" } } }, controlTypes = { "fear", "charm", "sleep" } } },
  rankable = false,
})
