local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S
local DRUID = { "DRUID" }
local ability = H.QualityAbilities(DRUID)




ability(1000, "wrath", "Wrath", "balance", "Spell_Nature_AbolishMagic", 1, {
  tags = { "balance", "spell", "nature", "druid_nuke", "druid_response" },
  use = { cost = 8, cd = 1.5, resource = "mana", effects = { { type = "damage", coef = 0.6, min = 3, max = 5, school = "nature" } } }, shopWeight = 2,
})



ability(1001, "starfire", "Starfire", "balance", "Spell_Arcane_StarFire", 2, {
  cost = 5, shape = S.sq, tags = { "balance", "spell", "arcane", "druid_nuke" },
  use = {
    cost = 28, cd = 12, initialDelay = 6, resource = "mana",
    effects = { { type = "damage", coef = 1.75, min = 6, max = 8, school = "arcane", consumeDots = { match = { tag = "spell" }, fraction = 0.35 } } },
  },
  shopWeight = 1.7,
})

ability(1002, "moonfire", "Moonfire", "balance", "Spell_Nature_StarFall", 1, {
  tags = { "balance", "spell", "arcane", "dot", "druid_nuke" },
  use = {
    cost = 12, cd = 9, resource = "mana",
    effects = {
      { type = "damage", coef = 0.2, min = 1, max = 2, school = "arcane" },
      { type = "dot", key = "moonfire", coef = 0.075, tick = 1, school = "arcane", duration = 9, preserveTicks = true },
    },
  },
  shopWeight = 1.6,
})


ability(1003, "insect_swarm", "Insect Swarm", "resto", "Spell_Nature_InsectSwarm", 2, {
  tags = { "resto", "spell", "nature", "dot" },
  use = {
    cost = 10, cd = 12, resource = "mana",
    effects = {
      { type = "dot", key = "insect_swarm", coef = 0.1, tick = 1, school = "nature", duration = 12, preserveTicks = true },
      { type = "debuff", key = "insect_swarm_distraction", name = "Insect Swarm", stat = "meleePct", value = 10, duration = 12, physicalOnly = true },
    },
  },
  shopAffinities = { DRUID = { balance = 0.7, resto = 1 } },
})

ability(1004, "hurricane", "Hurricane", "balance", "Spell_Nature_Cyclone", 4, {
  shape = S.T, tags = { "balance", "spell", "nature", "dot", "channel" },
  use = {
    cost = 28, cd = 16, channel = { key = "hurricane", duration = 6 }, resource = "mana",
    effects = {
      { type = "dot", key = "hurricane", coef = 0.75, tick = 1, school = "nature", duration = 6 },
      { type = "debuff", key = "hurricane_slow", name = "Hurricane", stat = "haste", value = 25, duration = 6 },
    },
  },
  shopWeight = 0.75,
})

ability(1005, "natures_grace", "Nature's Grace", "balance", "Spell_Nature_NaturesBlessing", 2, {
  shape = S.v2, tags = { "balance", "resto" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "spell" }, icd = 1,
      effects = { { type = "cdr", target = "neighbors", area = { side = "front" }, match = { notTag = "channel", tag = "spell" }, amount = 0.5, clampReady = true } },
    },
  },
})



ability(1006, "moonkin_form", "Moonkin Form", "balance", "Spell_Nature_ForceOfNature", 5, {
  cost = 15, kind = "form", shape = S.sq, tags = { "balance", "form" }, stats = { armor = 30, crit = 5 }, provides = "moonkin",
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "moonkin_item_armor", name = "Moonkin Form", stat = "armor", value = 0, duration = 120, gearCoef = 0.5, gearStat = "armor", rankScale = false } },
    },
    {
      on = "dotTick", match = { tag = "spell" }, icd = 1, everyAmount = 40,
      effects = {
        {
          type = "buff", key = "moonkin_fury", name = "Moonkin Form", target = "neighbors", area = { corners = true }, match = { tag = "druid_nuke" },
          stat = "crit", value = 5, duration = 6, maxStacks = 4, rankScale = false, stack = true,
        },
      },
    },
  },
  shopWeight = 0.6,
})

ability(1007, "faerie_fire", "Faerie Fire", "shared", "Spell_Nature_FaerieFire", 1, {
  tags = { "balance", "spell", "nature" },
  use = {
    cost = 5, cd = 20, resource = "mana",
    effects = { { type = "debuff", key = "faerie_fire", name = "Faerie Fire", exclusiveGroup = "druid_faerie_fire", stat = "armor", value = 35, duration = 20 } },
  },
})

ability(1008, "entangling_roots", "Entangling Roots", "shared", "Spell_Nature_StrangleVines", 1, {
  tags = { "balance", "spell", "nature", "dot", "druid_response" },
  use = { cost = 12, cd = 12, resource = "mana", effects = { { type = "stun", duration = 1 }, { type = "dot", key = "entangling_roots", tick = 2, school = "nature", duration = 6 } } },
})



ability(1009, "omen_of_clarity", "Omen of Clarity", "balance", "Spell_Nature_CrystalBall", 2, {
  minRound = 3, shape = S.v2, tags = { "feral", "balance" },
  triggers = {
    {
      on = "adjacentHit", match = { anyTag = { "melee" }, tag = "autoattack" }, chance = 15, icd = 1,
      effects = {
        { type = "buff", key = "clearcasting", name = "Clearcasting", match = { anyTag = { "spell", "strike", "finisher", "opener" } }, stat = "none", value = 0, duration = 10, free = true },
      },
    },
  },
})

ability(1010, "innervate", "Innervate", "shared", "Spell_Nature_Lightning", 4, {
  tags = { "balance", "resto", "spell" },
  use = {
    cost = 7, cd = 20, resource = "mana", condition = "lowMana",
    effects = { { type = "buff", key = "innervate", name = "Innervate", stat = "regen", value = 12, duration = 6, gearCoef = 1, gearStat = "regen", rankScale = false } },
  },
  rankIds = { [2] = 13293, [3] = 23293 },
})

ability(1011, "cat_form", "Cat Form", "shared", "Ability_Druid_CatForm", 1, {
  cost = 3, kind = "form", shape = S.sq, tags = { "feral", "form", "autoattack", "melee" }, stats = { ap = 8, crit = 3 },
  provides = { "catform", "feralform" }, grants = { combo = { max = 5, regen = 0, start = 0 }, energy = { max = 100, regen = 10, start = 60 } },
  replacesWeapon = true, use = { cd = 1, effects = { { type = "damage", coef = 0.2, min = 1, max = 2, school = "physical" } } }, shopWeight = 1.8,
})



ability(1012, "claw", "Claw", "feral", "Ability_Druid_Rake", 1, {
  tags = { "feral", "melee", "strike", "builder", "druid_ferocity_attack" },
  use = {
    cost = 40, cd = 4, resource = "energy", requires = "catform",
    effects = {
      { type = "damage", coef = 0.65, min = 1, max = 3, school = "physical" }, { type = "resource", resource = "combo", amount = 1 },
      { type = "resource", resource = "combo", amount = 1, cond = "enemyBleeding" },
    },
  },
  shopWeight = 1.7,
})

ability(1013, "rake", "Rake", "feral", "Ability_Druid_Disembowel", 2, {
  tags = { "feral", "melee", "bleed", "dot", "strike", "builder", "druid_ferocity_attack" },
  use = {
    cost = 35, cd = 9, resource = "energy", requires = "catform",
    effects = {
      { type = "damage", coef = 0.15, min = 1, max = 2, school = "physical" },
      { type = "dot", key = "rake", coef = 0.1, tick = 1, school = "physical", duration = 9, rolling = true },
      { type = "resource", resource = "combo", amount = 1 },
    },
  },
  triggers = { { on = "dotTick", match = { key = "rake" }, icd = 1, effects = { { type = "resource", resource = "energy", amount = 2 } } } },
  shopWeight = 1.5,
})

ability(1014, "shred", "Shred", "feral", "Spell_Shadow_VampiricAura", 3, {
  shape = S.L, tags = { "feral", "melee", "strike", "builder" },
  use = {
    cost = 60, cd = 4, initialDelay = 1, resource = "energy", requires = "catform",
    effects = { { type = "damage", coef = 1, min = 2, max = 4, school = "physical", critIf = "enemyStunned" }, { type = "resource", resource = "combo", amount = 2 } },
  },
})


ability(1015, "rip", "Rip", "feral", "Ability_GhoulFrenzy", 2, {
  minRound = 3, tags = { "feral", "melee", "bleed", "dot", "finisher" },
  use = {
    cost = 30, cd = 12, initialDelay = 0.1, priority = 60, resource = "energy", requires = "catform", condition = "enemyNeeds:rip:1",
    effects = { { type = "dot", key = "rip", coef = 0.1, tick = 1, school = "physical", duration = 12, perCombo = 0.4, preserveTicks = true, rolling = true } },
    comboCost = 3, spendCombo = true,
  },
  rankIds = { [2] = 31015, [3] = 41015 },
})

ability(1016, "ferocious_bite", "Ferocious Bite", "feral", "Ability_Druid_FerociousBite", 3, {
  minRound = 5, shape = S.sq, tags = { "feral", "melee", "finisher" },
  use = {
    cost = 35, cd = 6, initialDelay = 0.1, resource = "energy", requires = "catform",
    effects = { { type = "damage", coef = 0.85, min = 3, max = 5, school = "physical", perCombo = 0.4, scaleMissing = 0.5 } }, comboCost = 3,
    spendCombo = true,
  },
  rankIds = { [2] = 31016, [3] = 41016 },
})



ability(1017, "tigers_fury", "Tiger's Fury", "feral", "Ability_Mount_JungleTiger", 2, {
  minRound = 3, tags = { "feral" },
  use = {
    cost = 25, cd = 10, initialDelay = 2, resource = "energy", requires = "catform",
    effects = { { type = "buff", key = "tigers_fury", name = "Tiger's Fury", stat = "ap", value = 0, duration = 4, gearCoef = 0.25, gearStat = "ap", rankScale = false } },
  },
  triggers = { { on = "anyHit", condition = "buff:tigers_fury", match = { key = "cat_form" }, icd = 1, effects = { { type = "resource", resource = "combo", amount = 1 } } } },
})



ability(1018, "bear_form", "Bear Form", "shared", "Ability_Racial_BearForm", 1, {
  cost = 3, kind = "form", shape = S.sq, tags = { "bear", "feral", "form", "defensive", "autoattack", "melee", "primal_generator" },
  stats = { armor = 20, hpPct = 25 }, provides = { "bearform", "feralform" }, grants = { rage = { max = 100, regen = 0, start = 10 } },
  replacesWeapon = true,
  use = { cd = 2.5, effects = { { type = "damage", coef = 0.6, min = 2, max = 4, school = "physical", generatesRage = true } } },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "bear_item_armor", name = "Bear Form", stat = "armor", value = 0, duration = 120, gearCoef = 0.3, gearStat = "armor", rankScale = false } },
    },
  },
  shopWeight = 1.8,
})

ability(1019, "maul", "Maul", "feral", "Ability_Druid_Maul", 1, {
  tags = { "bear", "feral", "melee", "strike", "primal_generator", "druid_ferocity_attack" },
  use = {
    cost = 15, cd = 2.5, resource = "rage", requires = "bearform",
    effects = { { type = "damage", coef = 1, min = 2, max = 4, school = "physical", perPoint = 0.4, pointResource = "rage", spendBank = "maul" } },
    spendMax = 40,
  },
  triggers = { { on = "damaged", effects = { { type = "bank", key = "maul", cap = { ap = 1.2, armor = 0.2, flat = 40 }, fraction = 0.15 } } } },
  shopWeight = 1.8,
})

ability(1020, "swipe", "Swipe", "feral", "INV_Misc_MonsterClaw_03", 2, {
  minRound = 3, tags = { "bear", "feral", "melee", "strike", "druid_ferocity_attack" },
  use = {
    cost = 20, cd = 6, resource = "rage", requires = "bearform",
    effects = {
      { type = "damage", coef = 0.65, min = 2, max = 4, school = "physical", repeatPaidCharges = true },
      { type = "debuff", key = "swipe_exposed", name = "Swipe", stat = "armor", value = 20, duration = 4 },
    },
    empower = { key = "primal_fury", cost = 10, max = 3 },
  },
  shopWeight = 1.5,
})



ability(1021, "enrage_druid", "Enrage", "shared", "Ability_Druid_Enrage", 1, {
  cost = 2, tags = { "bear", "feral" },
  use = {
    cd = 20, initialDelay = 0.1, requires = "bearform",
    effects = {
      { type = "buff", key = "enrage_rage", name = "Enrage", stat = "rageRegen", value = 5, duration = 4 },
      { type = "buff", key = "enrage_armor", name = "Enrage", stat = "armor", value = -20, duration = 4 },
    },
  },
  rankable = false, shopRequires = { "bear_form" }, shopWeight = 1.5,
})

ability(1022, "frenzied_regeneration", "Frenzied Regeneration", "feral", "Ability_BullRush", 3, {
  minRound = 5, tags = { "bear", "feral", "defensive", "heal" },
  use = {
    cost = 20, cd = 15, reactive = true, resource = "rage", requires = "bearform", condition = "below50",
    effects = { { type = "heal", perPointPctMax = 0.0025, pointResource = "rage" } }, spendMax = 50,
  },
})

ability(1023, "demoralizing_roar", "Demoralizing Roar", "shared", "Ability_Druid_DemoralizingRoar", 1, {
  tags = { "bear", "feral", "defensive" },
  use = {
    cost = 10, cd = 12, resource = "rage", requires = "bearform",
    effects = { { type = "debuff", stat = "ap", value = 16, duration = 10 }, { type = "debuff", stat = "dmgPct", value = 8, duration = 10 } },
  },
})

ability(1025, "leader_of_the_pack", "Leader of the Pack", "feral", "Spell_Nature_UnyeildingStamina", 5, {
  cost = 15, shape = S.sq, tags = { "feral" },
  triggers = {
    {
      on = "battleStart", condition = "provides:feralform",
      effects = { { type = "buff", key = "leader_of_the_pack", name = "Leader of the Pack", target = "all", match = { tag = "melee" }, stat = "crit", value = 7.5, duration = 120 } },
    },
    {
      on = "anyCrit", condition = "provides:feralform", match = { kind = "ability", damaging = "direct", tag = "feral" }, icd = 2,
      effects = { { type = "cast", target = "neighbors", match = { kind = "form", tag = "autoattack" }, choose = "first" } }, effective = true,
      healing = false, oncePerActivation = true, paidOnly = true,
    },
  },
})


ability(1026, "rejuvenation", "Rejuvenation", "resto", "Spell_Nature_Rejuvenation", 1, {
  tags = { "resto", "spell", "heal", "hot", "nature", "druid_hot" },
  use = {
    cost = 12, cd = 12, reactive = true, resource = "mana", condition = "injured",
    effects = { { type = "hot", key = "rejuvenation", coef = 0.1, tick = 1, duration = 12, preserveTicks = true } },
  },
  shopWeight = 1.8,
})

ability(1027, "regrowth", "Regrowth", "resto", "Spell_Nature_ResistNature", 2, {
  tags = { "resto", "spell", "heal", "hot", "nature", "druid_hot", "druid_response" },
  use = {
    cost = 18, cd = 4, reactive = true, resource = "mana", condition = "injured",
    effects = { { type = "heal", coef = 0.5, min = 3, max = 5 }, { type = "hot", key = "regrowth", coef = 0.075, tick = 1, duration = 9, preserveTicks = true } },
  },
  triggers = {
    {
      on = "crit", icd = 2, effects = { { type = "tickHots", target = "neighbors", area = { corners = true }, match = { tag = "druid_hot" } } },
      effective = true, healing = true, oncePerActivation = true, paidOnly = true,
    },
  },
  shopWeight = 1.4,
})

ability(1028, "healing_touch", "Healing Touch", "resto", "Spell_Nature_HealingTouch", 1, {
  cost = 3, shape = S.sq, tags = { "resto", "spell", "heal", "nature", "druid_tranquil", "druid_response" },
  use = { cost = 22, cd = 3.5, reactive = true, resource = "mana", condition = "injured", effects = { { type = "heal", coef = 0.9, min = 4, max = 6 } } },
  triggers = {
    {
      on = "healed", match = { key = "healing_touch" },
      effects = { { type = "tickHots", target = "neighbors", area = { corners = true }, match = { tag = "druid_hot" } } }, effective = true,
    },
  },
  shopWeight = 1.6,
})

ability(1029, "swiftmend", "Swiftmend", "resto", "INV_Relics_IdolofRejuvenation", 3, {
  tags = { "resto", "spell", "heal", "nature" },
  use = {
    cost = 12, cd = 15, reactive = true, resource = "mana", condition = "below50",
    effects = { { type = "heal", coef = 0, target = "neighbors", area = {}, match = { tag = "druid_hot" }, min = 0, max = 0, consumeHots = { match = { tag = "druid_hot" }, full = true } } },
    interruptChannel = true,
  },
  shopWeight = 1.6,
})

ability(1030, "natures_swiftness", "Nature's Swiftness", "resto", "Spell_Nature_RavenForm", 5, {
  cost = 15, minRound = 11, shape = S.sq, tags = { "resto", "balance" },
  triggers = {
    {
      on = "anyCrit", icd = 6,
      effects = { { type = "cast", target = "neighbors", area = { side = "front" }, match = { notTag = "channel", tag = "druid_response" }, choose = "first", consumeCooldown = true } },
      effective = true, healing = true, oncePerActivation = true, paidOnly = true,
    },
  },
})

ability(1031, "tranquility", "Tranquility", "resto", "Spell_Nature_Tranquility", 4, {
  shape = S.T, tags = { "resto", "spell", "heal", "hot", "nature", "channel", "druid_tranquil" },
  use = {
    cost = 32, cd = 24, priority = 80, reactive = true, channel = { key = "tranquility", kind = "hot", duration = 6, self = true }, resource = "mana",
    condition = "below75", effects = { { type = "hot", key = "tranquility", coef = 0.75, tick = 2, duration = 6 } },
  },
  triggers = {
    {
      on = "hotTick", match = { key = "tranquility" }, icd = 1,
      effects = { { type = "dot", key = "tranquility_bloom", tick = 0, school = "nature", duration = 4, fromEvent = 0.35, rolling = true } },
    },
  },
  shopWeight = 0.75,
})

ability(1032, "barkskin", "Barkskin", "shared", "Spell_Nature_StoneClawTotem", 2, {
  minRound = 3, tags = { "resto", "defensive", "spell" },
  use = {
    cost = 10, cd = 20, priority = 100, reactive = true, resource = "mana", condition = "below75",
    effects = { { type = "buff", stat = "dr", value = 20, duration = 8, damageSchool = "physical" } },
  },
})

ability(1033, "thorns", "Thorns", "balance", "Spell_Nature_Thorns", 1, {
  shape = S.v2, tags = { "balance", "nature", "spell" },
  triggers = {
    {
      on = "anyCrit", match = { damaging = "direct", tag = "druid_nuke" }, icd = 1, effects = { { type = "bank", key = "thorns", fraction = 0.35 } },
      effective = true, healing = false, oncePerActivation = true, paidOnly = true,
    },
    { on = "damaged", matchAttacker = { tag = "melee" }, icd = 0.5, effects = { { type = "damage", coef = 0.1, min = 1, max = 2, school = "nature", noDodge = true, spendBank = "thorns" } } },
  },
  shopAffinities = { DRUID = { balance = 1, feral = 0.6, resto = 0.4 } },
})

ability(1036, "savage_fury", "Savage Fury", "feral", "Ability_Druid_Ravage", 4, {
  cost = 8, shape = S.v2, tags = { "feral" },
  triggers = {
    {
      on = "resourceSpent", resource = "energy", everyAmount = 60,
      effects = { { type = "buff", key = "savage_fury", name = "Savage Fury", target = "all", match = { tag = "feral" }, stat = "dmgPct", value = 5, duration = 8, maxStacks = 3, stack = true } },
      counterKey = "savage_fury",
    },
    {
      on = "resourceSpent", resource = "rage", everyAmount = 30,
      effects = { { type = "buff", key = "savage_fury", name = "Savage Fury", target = "all", match = { tag = "feral" }, stat = "dmgPct", value = 5, duration = 8, maxStacks = 3, stack = true } },
      counterKey = "savage_fury",
    },
  },
})



ability(1037, "feral_charge", "Feral Charge", "feral", "Ability_Hunter_Pet_Bear", 2, {
  minRound = 3, tags = { "bear", "feral" },
  use = { cd = 15, initialDelay = 2, requires = "bearform", effects = { { type = "damage", coef = 0.35, min = 1, max = 3, school = "physical" }, { type = "stun", duration = 1.25 } } },
  rankIds = { [2] = 13290, [3] = 23290 },
})

ability(1038, "natures_focus", "Nature's Focus", "resto", "spell_nature_healingwavegreater", 2, {
  minRound = 4, shape = S.v2, tags = { "resto" },
  triggers = {
    {
      on = "adjacentUse", match = { channeled = true, tag = "nature" },
      effects = { { type = "buff", key = "druid_channel_focus", name = "Nature's Focus", stat = "none", value = 0, duration = 3, controlCharges = 1, controlTypes = { "stun", "fear" } } },
    },
  },
})

ability(1041, "vengeance", "Vengeance", "balance", "Spell_Nature_Purge", 3, {
  minRound = 7, shape = S.v2, tags = { "balance" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "druid_vengeance", name = "Vengeance", target = "all", match = { tag = "druid_nuke" }, stat = "critDamage", value = 50, duration = 120 } },
    },
  },
})

ability(1045, "pounce", "Pounce", "feral", "Ability_Druid_SupriseAttack", 2, {
  minRound = 3, tags = { "feral", "bleed", "dot", "builder", "opener" },
  use = {
    cost = 50, cd = 20, initialDelay = 0.1, priority = 100, once = true, resource = "energy", requires = "catform", condition = "buff:druid_prowl",
    effects = {
      { type = "stun", duration = 2 }, { type = "dot", key = "pounce", coef = 0.075, tick = 1, school = "physical", duration = 8 },
      { type = "resource", resource = "combo", amount = 1 },
      { type = "buff", key = "druid_prowl", stat = "none", value = 0, duration = 0, anySource = true, charges = 0 },
    },
  },
  rankIds = { [2] = 13291, [3] = 23291 }, shopRequires = { "prowl_druid" },
})

ability(1046, "ravage", "Ravage", "feral", "Ability_Druid_Ravage", 3, {
  minRound = 5, tags = { "feral", "melee", "strike", "builder", "opener" },
  use = {
    cost = 60, cd = 2, initialDelay = 0.1, priority = 90, once = true, resource = "energy", requires = "catform", condition = "buff:druid_prowl",
    effects = {
      { type = "damage", coef = 2.5, min = 3, max = 5, school = "physical" }, { type = "resource", resource = "combo", amount = 1 },
      { type = "buff", key = "druid_prowl", stat = "none", value = 0, duration = 0, anySource = true, charges = 0 },
    },
  },
  shopRequires = { "prowl_druid" },
})

ability(1047, "blood_frenzy", "Blood Frenzy", "feral", "Ability_GhoulFrenzy", 2, {
  cost = 4, minRound = 3, shape = S.v2, tags = { "feral" },
  triggers = {
    {
      on = "anyCrit", condition = "provides:catform", match = { tag = "builder" }, chance = 50,
      effects = { { type = "resource", resource = "combo", amount = 1 } }, healing = false, oncePerActivation = true,
    },
  },
})

ability(1048, "furor", "Furor", "resto", "Spell_Holy_BlessingOfStamina", 2, {
  cost = 3, shape = S.v2, tags = { "feral" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "resource", resource = "energy", amount = 40, cond = "provides:catform" }, { type = "resource", resource = "rage", amount = 10, cond = "provides:bearform" } },
    },
    {
      on = "healed", match = { healing = true }, icd = 4,
      effects = { { type = "resource", resource = "energy", amount = 8, cond = "provides:catform" }, { type = "resource", resource = "rage", amount = 4, cond = "provides:bearform" } },
      effective = true, oncePerActivation = true, paidOnly = true,
    },
  },
})

H.Weapon{
  id = 1090, key = "gnarled_staff", name = "Gnarled Staff", icon = I("inv_staff_10"), quality = 1, cost = 3, classes = DRUID, weaponType = "staff",
  hands = 2, weaponMin = 5, weaponMax = 8, speed = 3, stats = { healing = 1, sp = 1 }, noShop = true, starter = true,
}

ability(2100, "improved_wrath", "Improved Wrath", "balance", "spell_nature_abolishmagic", 1, { shape = S.v2, tags = { "balance" }, adjacency = { { match = { key = "wrath" }, mods = { cdPct = 20 } } }, passiveTriggers = true, shopRequires = { "wrath" } })

ability(2101, "improved_moonfire", "Improved Moonfire", "balance", "spell_nature_starfall", 2, {
  minRound = 4, shape = S.v2, tags = { "balance" }, adjacency = { { match = { key = "moonfire" }, mods = { crit = 20, dmgPct = 20 } } },
  passiveTriggers = true, shopRequires = { "moonfire" },
})

ability(2102, "improved_starfire", "Improved Starfire", "balance", "spell_arcane_starfire", 4, {
  shape = S.L, tags = { "balance" },
  triggers = {
    {
      on = "anyCrit", match = { key = "starfire" },
      effects = { { type = "stun", duration = 0.75 }, { type = "cast", key = "moonfire", consumeCooldown = true } }, healing = false,
      oncePerActivation = true,
    },
  },
  adjacency = { { match = { key = "starfire" }, mods = { crit = 15 } } }, shopRequires = { "starfire" },
})

ability(2103, "moonglow", "Moonglow", "balance", "spell_nature_sentinal", 2, { cost = 3, shape = S.v2, tags = { "balance", "resto" }, adjacency = { { match = { notTag = "channel", tag = "spell" }, mods = { costPct = -10 } } }, passiveTriggers = true })

ability(2104, "moonfury", "Moonfury", "balance", "spell_nature_moonglow", 2, {
  minRound = 8, shape = S.v2, tags = { "balance" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "druid_moonfury", name = "Moonfury", target = "all", match = { tag = "druid_nuke" }, stat = "dmgPct", value = 15, duration = 120 } },
    },
  },
})

ability(2105, "natural_shapeshifter", "Natural Shapeshifter", "balance", "spell_nature_wispsplode", 3, {
  minRound = 5, shape = S.v2, tags = { "balance", "feral" },
  triggers = {
    { on = "adjacentHit", match = { kind = "form" }, icd = 1, effects = { { type = "resource", resource = "mana", amount = 2 } } },
    { on = "adjacentUse", match = { tag = "spell" }, effects = { { type = "cdr", target = "neighbors", match = { kind = "form" }, amount = 0.5, clampReady = true } } },
  },
})

ability(2106, "natures_grasp", "Nature's Grasp", "balance", "spell_nature_natureswrath", 2, {
  minRound = 3, tags = { "balance", "defensive" },
  use = { cost = 6, cd = 18, initialDelay = 0.1, resource = "mana", effects = { { type = "buff", key = "natures_grasp_ready", name = "Nature's Grasp", stat = "none", value = 0, duration = 18 } } },
  triggers = {
    {
      on = "damaged", condition = { "buff:natures_grasp_ready", "below75" }, matchAttacker = { tag = "melee" }, chance = 35,
      effects = {
        { type = "buff", key = "natures_grasp_ready", stat = "none", value = 0, duration = 0, anySource = true, charges = 0 },
        { type = "stun", duration = 2 }, { type = "dot", key = "natures_grasp_root", coef = 0.075, tick = 1, school = "nature", duration = 6 },
      },
    },
  },
  rankable = false,
})

ability(2107, "heart_of_the_wild", "Heart of the Wild", "feral", "spell_holy_blessingofagility", 5, {
  cost = 15, minRound = 11, shape = S.sq, tags = { "feral", "resto" }, stats = { hp = 40 },
  triggers = {
    { on = "resourceSpent", resource = "energy", icd = 2, everyAmount = 60, effects = { { type = "cast", key = "healing_touch" } } },
    { on = "resourceSpent", resource = "rage", icd = 2, everyAmount = 30, effects = { { type = "cast", key = "healing_touch" } } },
  },
  shopRequires = { "healing_touch" }, shopWeight = 0.65,
})

ability(2108, "reflection", "Reflection", "resto", "spell_frost_windwalkon", 2, {
  minRound = 4, shape = S.v2, tags = { "resto" },
  triggers = {
    {
      on = "anyUse", match = { anyTag = { "heal" }, tag = "spell" },
      effects = { { type = "buff", key = "druid_reflection", name = "Reflection", stat = "regen", value = 2, duration = 6 } }, paidOnly = true,
    },
  },
})

ability(2109, "improved_rejuvenation", "Improved Rejuvenation", "resto", "spell_nature_rejuvenation", 2, { shape = S.v2, tags = { "resto" }, adjacency = { { match = { key = "rejuvenation" }, mods = { healPct = 25 } } }, passiveTriggers = true, shopRequires = { "rejuvenation" } })

ability(2110, "improved_regrowth", "Improved Regrowth", "resto", "spell_nature_resistnature", 3, { shape = S.v2, tags = { "resto", "balance" }, adjacency = { { match = { key = "regrowth" }, mods = { crit = 20 } } }, passiveTriggers = true, shopRequires = { "regrowth" } })

ability(2111, "improved_healing_touch", "Improved Healing Touch", "resto", "spell_nature_healingtouch", 2, {
  cost = 4, minRound = 4, shape = S.v2, tags = { "resto" }, adjacency = { { match = { key = "healing_touch" }, mods = { cdPct = 20 } } },
  passiveTriggers = true, shopRequires = { "healing_touch" },
})

ability(2112, "gift_of_nature", "Gift of Nature", "resto", "spell_nature_protectionformnature", 4, {
  minRound = 8, shape = S.v2, tags = { "resto", "balance" },
  triggers = {
    {
      on = "healed", icd = 1, everyAmount = 40,
      effects = {
        {
          type = "buff", key = "gift_of_nature", name = "Gift of Nature", target = "all", match = { anyTag = { "dot" }, tag = "spell" }, stat = "sp",
          value = 0, duration = 8, gearCoef = 0.025, gearStat = "healing", maxStacks = 5, rankScale = false, stack = true,
        },
      },
    },
  },
})

ability(2113, "tranquil_spirit", "Tranquil Spirit", "resto", "spell_holy_elunesgrace", 3, { minRound = 5, shape = S.v2, tags = { "resto" }, adjacency = { { match = { tag = "druid_tranquil" }, mods = { costPct = -25 } } }, passiveTriggers = true })

ability(2114, "abolish_poison", "Abolish Poison", "resto", "spell_nature_nullifypoison_02", 1, {
  shape = S.one, tags = { "resto", "spell", "heal", "nature" },
  use = {
    cost = 10, cd = 10, reactive = true, resource = "mana", condition = "injuredOrHarmful",
    effects = { { type = "cleanse", count = 1, debuffs = true }, { type = "heal", coef = 0.25, min = 2, max = 4 } },
  },
})

ability(2115, "mark_of_the_wild", "Mark of the Wild", "shared", "spell_nature_regeneration", 1, {
  tags = { "nature", "defensive" }, stats = { ap = 4, armor = 8, healing = 4, hp = 20, sp = 4 },
  gearBonuses = {
    { coef = 0.05, stat = "hp", gearStat = "hp" }, { coef = 0.05, stat = "armor", gearStat = "armor" }, { coef = 0.05, stat = "ap", gearStat = "ap" },
    { coef = 0.05, stat = "sp", gearStat = "sp" }, { coef = 0.05, stat = "healing", gearStat = "healing" },
  },
})

ability(2120, "thick_hide", "Thick Hide", "feral", "inv_misc_pelt_bear_03", 2, {
  minRound = 3, shape = S.v2, tags = { "bear", "feral", "defensive" },
  triggers = { { on = "armorPrevented", condition = "provides:bearform", effects = { { type = "bank", key = "maul", cap = { ap = 1.2, armor = 0.2, flat = 40 }, fraction = 0.25 } } } },
  shopRequires = { "maul" },
})

ability(2121, "primal_fury", "Primal Fury", "feral", "ability_racial_cannibalize", 3, {
  cost = 5, shape = S.v2, tags = { "bear", "feral" },
  triggers = {
    {
      on = "anyCrit", condition = "provides:bearform", match = { tag = "primal_generator" },
      effects = { { type = "charge", key = "primal_fury", max = 3, amount = 1 } }, healing = false, oncePerActivation = true,
    },
  },
  rankable = false, shopRequires = { "bear_form" },
})

ability(2122, "bash", "Bash", "feral", "ability_druid_bash", 3, {
  tags = { "bear", "feral", "melee", "strike", "control" },
  use = {
    cost = 25, cd = 12, initialDelay = 2, resource = "rage", requires = "bearform",
    effects = { { type = "damage", coef = 0.6, min = 1, max = 3, school = "physical" }, { type = "stun", duration = 1.5, rankScale = false } },
  },
})

ability(2123, "brutal_impact", "Brutal Impact", "feral", "ability_druid_bash", 4, {
  shape = S.v2, tags = { "bear", "feral", "control" },
  triggers = {
    {
      on = "enemyStunned", condition = "provides:bearform",
      effects = {
        { type = "buff", key = "brutal_impact", name = "Brutal Impact", target = "all", match = { damaging = "direct", tag = "bear" }, stat = "crit", value = 100, duration = 5, charges = 1 },
      },
    },
  },
  shopRequires = { "bash" },
})



ability(3280, "faerie_fire_feral", "Faerie Fire (Feral)", "feral", "Spell_Nature_FaerieFire", 1, {
  cost = 4, minRound = 2, shape = S.h2, tags = { "feral", "nature" },
  use = {
    cd = 12, initialDelay = 1, requires = "feralform",
    effects = { { type = "debuff", key = "faerie_fire_feral", name = "Faerie Fire", exclusiveGroup = "druid_faerie_fire", stat = "armor", value = 25, duration = 12 } },
  },
})

ability(3281, "improved_enrage", "Improved Enrage", "resto", "Ability_Druid_Enrage", 1, {
  cost = 2, minRound = 2, tags = { "feral", "bear" },
  triggers = { { on = "anyUse", condition = "provides:bearform", match = { key = "enrage_druid" }, effects = { { type = "resource", resource = "rage", amount = 5 } } } },
  shopAffinities = { DRUID = { feral = 1 } },
})

ability(3282, "improved_shred", "Improved Shred", "feral", "Spell_Shadow_VampiricAura", 1, {
  minRound = 3, tags = { "feral" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_shred", name = "Improved Shred", target = "all", match = { key = "shred" }, stat = "costFlat", value = -10, duration = 120 } },
    },
  },
})

ability(3283, "feral_aggression", "Feral Aggression", "feral", "Ability_Druid_DemoralizingRoar", 2, {
  cost = 5, minRound = 3, shape = { "110", "011" }, tags = { "feral" },
  triggers = {
    {
      on = "anyHit", match = { key = "ferocious_bite" },
      effects = { { type = "damage", min = 0, max = 0, school = "physical", fromEvent = 0.35, noCrit = true, noDodge = true, noOwnTriggers = true } },
    },
    {
      on = "anyUse", match = { key = "demoralizing_roar" },
      effects = { { type = "debuff", key = "feral_aggression_roar", name = "Feral Aggression", stat = "ap", value = 8, duration = 10 } },
    },
  },
  shopWeight = 0.8,
})

ability(3284, "improved_thorns", "Improved Thorns", "balance", "Spell_Nature_Thorns", 1, {
  minRound = 3, tags = { "balance", "nature" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "improved_thorns", name = "Improved Thorns", target = "all", match = { key = "thorns" }, stat = "dmgPct", value = 50, duration = 120 } },
    },
  },
  shopWeight = 0.7,
})

ability(3285, "druid_ferocity", "Ferocity", "feral", "Ability_Hunter_Pet_Hyena", 1, {
  shape = S.h2, tags = { "feral" },
  triggers = {
    {
      on = "anyUse", match = { tag = "druid_ferocity_attack" }, every = 3,
      effects = {
        {
          type = "buff", key = "druid_ferocity", name = "Ferocity", target = "neighbors", match = { tag = "druid_ferocity_attack" }, stat = "dmgPct",
          value = 0, duration = 12, charges = 1, free = true,
        },
      },
      paidOnly = true,
    },
  },
})

ability(3286, "remove_curse_druid", "Remove Curse", "shared", "Spell_Holy_RemoveCurse", 2, {
  cost = 1, shape = S.one, tags = { "resto", "spell", "nature" },
  use = { cost = 0, cd = 10, reactive = true, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 1, debuffs = true } } },
  shopClasses = {}, shopWeight = 0.25, trainingMaxRank = 1,
})





ability(3287, "prowl_druid", "Prowl", "feral", "Ability_Druid_SupriseAttack", 1, {
  cost = 2, tags = { "feral", "preparation" },
  triggers = { { on = "battleStart", condition = "provides:catform", effects = { { type = "buff", key = "druid_prowl", name = "Prowl", stat = "none", value = 0, duration = 12 } } } },
  rankable = false,
})

ability(3288, "improved_natures_grasp", "Improved Nature's Grasp", "balance", "Spell_Nature_NaturesWrath", 1, {
  minRound = 3, tags = { "balance", "resto", "defensive" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        {
          type = "buff", key = "improved_natures_grasp", name = "Improved Nature's Grasp", target = "all", match = { key = "natures_grasp" },
          stat = "procChance", value = 65, duration = 120,
        },
      },
    },
  },
  rankable = false, shopRequires = { "natures_grasp" },
})


ability(3289, "cure_poison_druid", "Cure Poison", "shared", "Spell_Nature_NullifyPoison", 1, {
  cost = 1, shape = S.one, tags = { "resto", "spell", "nature" },
  use = { cost = 0, cd = 10, reactive = true, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 1, debuffs = true } } },
  shopClasses = {}, shopWeight = 0.25, trainingMaxRank = 1,
})

ability(3292, "natural_weapons_druid", "Natural Weapons", "balance", "INV_Staff_01", 2, {
  cost = 4, minRound = 3, shape = { "11", "10" }, tags = { "balance", "feral" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        {
          type = "buff", key = "natural_weapons_druid", name = "Natural Weapons", target = "all", match = { anyTag = { "autoattack" }, tag = "melee" },
          stat = "dmgPct", value = 50, duration = 120,
        },
      },
    },
  },
})
