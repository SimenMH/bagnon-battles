local ADDON, ns = ...
local H = ns.H
local S = H.S
local PRIEST = { "PRIEST" }
local ability = H.QualityAbilities(PRIEST)



ability(6000, "smite", "Smite", "holy", "Spell_Holy_HolySmite", 1, {
  use = {
    cost = 12, cd = 3, resource = "mana",
    effects = { { type = "damage", coef = 0.5, min = 5, max = 7, school = "holy", bankLabel = "stored absorbed damage", spendBank = "discipline_aegis" } },
  },
  shopWeight = 1.5,
})

ability(6001, "power_word_shield", "Power Word: Shield", "discipline", "Spell_Holy_PowerWordShield", 1, {
  tags = { "discipline", "spell", "defensive" },
  use = { cost = 16, cd = 9, initialDelay = 1, resource = "mana", effects = { { type = "absorb", coef = 0.75, amount = 5 } } },
  triggers = { { on = "absorbed", effects = { { type = "bank", key = "discipline_aegis", cap = { flat = 35, healing = 0.7 }, fraction = 0.35 } } } },
  shopWeight = 1.8,
})

ability(6002, "power_word_fortitude", "Power Word: Fortitude", "discipline", "Spell_Holy_WordFortitude", 1, { shape = S.v2, tags = { "discipline" }, stats = { hp = 20, hpPct = 5 }, passiveTriggers = true, shopWeight = 1.25 })

ability(6003, "inner_fire", "Inner Fire", "discipline", "Spell_Holy_InnerFire", 1, {
  shape = S.v2, tags = { "discipline" }, stats = { ap = 8, armor = 24 },
  triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "resource", resource = "mana", amount = 2 } } } },
})

ability(6004, "inner_focus", "Inner Focus", "discipline", "Spell_Frost_WindWalkOn", 3, {
  tags = { "discipline" },
  use = {
    cd = 20, initialDelay = 1,
    effects = {
      {
        type = "buff", key = "priest_inner_focus", name = "Inner Focus", target = "neighbors", area = { side = "front" }, match = { tag = "spell" },
        stat = "crit", value = 25, duration = 8, charges = 1, free = true,
      },
    },
  },
})

ability(6005, "meditation", "Meditation", "discipline", "Spell_Nature_Sleep", 2, { shape = S.v2, tags = { "discipline" }, triggers = { { on = "absorbed", icd = 1, effects = { { type = "resource", resource = "mana", fromEvent = 0.1 } } } } })

ability(6006, "mental_agility", "Mental Agility", "discipline", "Ability_Hibernation", 2, {
  minRound = 3, shape = S.v2, tags = { "discipline" },
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "absorb", coef = 0.1, amount = 2 } } } },
})

ability(6007, "mental_strength", "Mental Strength", "discipline", "Spell_Nature_EnchantArmor", 2, { shape = S.v2, tags = { "discipline" }, stats = { mana = 40, regen = 1 }, passiveTriggers = true, shopClasses = {} })

ability(6008, "divine_spirit", "Divine Spirit", "discipline", "Spell_Holy_DivineSpirit", 3, {
  shape = S.v2, tags = { "discipline" }, stats = { regen = 1 },
  triggers = { { on = "hotTick", icd = 1, everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 5 } } } },
})

ability(6009, "power_infusion", "Power Infusion", "discipline", "Spell_Holy_PowerInfusion", 5, {
  minRound = 9, shape = S.L, tags = { "discipline" },
  use = {
    cost = 20, cd = 24, resource = "mana",
    effects = {
      { type = "buff", key = "power_infusion_damage", name = "Power Infusion", stat = "spellPct", value = 30, duration = 8 },
      { type = "buff", key = "power_infusion_heal", name = "Power Infusion", stat = "healPct", value = 30, duration = 8 },
    },
  },
  triggers = {
    {
      on = "anyUse", condition = "buff:power_infusion_damage", match = { key = "power_word_shield" }, icd = 1,
      effects = { { type = "cast", key = "smite" } }, oncePerActivation = true, paidOnly = true,
    },
  },
})

ability(6010, "improved_power_word_shield", "Improved Power Word: Shield", "discipline", "Spell_Holy_PowerWordShield", 2, {
  shape = S.v2, tags = { "discipline" },
  triggers = { { on = "anyUse", match = { key = "power_word_shield" }, effects = { { type = "absorb", coef = 0.15, amount = 2 } } } },
  shopRequires = { "power_word_shield" },
})

ability(6011, "improved_inner_fire", "Improved Inner Fire", "discipline", "Spell_Holy_InnerFire", 2, {
  minRound = 3, shape = S.v2, tags = { "discipline" }, stats = { armor = 16 },
  triggers = { { on = "armorPrevented", icd = 1, everyAmount = 25, effects = { { type = "absorb", coef = 0.08, amount = 2 } } } },
  shopRequires = { "inner_fire" },
})

ability(6012, "force_of_will", "Force of Will", "discipline", "Spell_Nature_SlowingTotem", 4, {
  shape = S.v2, tags = { "discipline" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "spell" }, icd = 2,
      effects = { { type = "cdr", target = "all", match = { key = "power_word_shield" }, amount = 0.5, clampReady = true } }, healing = false,
    },
  },
  adjacency = { { match = { damaging = true, tag = "spell" }, corners = true, mods = { crit = 5, dmgPct = 10 } } }, shopWeight = 0.7,
})

ability(6013, "lesser_heal", "Lesser Heal", "holy", "Spell_Holy_LesserHeal", 1, {
  tags = { "holy", "spell", "heal", "patient_heal" },
  use = { cost = 12, cd = 4, resource = "mana", condition = "injured", effects = { { type = "heal", coef = 0.8, min = 4, max = 6 } } },
  shopWeight = 1.3,
})

ability(6014, "renew", "Renew", "holy", "Spell_Holy_Renew", 1, {
  tags = { "holy", "spell", "heal", "hot" },
  use = { cost = 15, cd = 12, initialDelay = 1, resource = "mana", effects = { { type = "hot", key = "renew", coef = 0.1, tick = 1, duration = 12, preserveTicks = true } } },
  shopWeight = 1.5,
})

ability(6015, "heal_priest", "Heal", "holy", "Spell_Holy_Heal", 2, {
  tags = { "holy", "spell", "heal", "patient_heal" },
  use = {
    cost = 20, cd = 6, resource = "mana", condition = "injured",
    effects = { { type = "heal", coef = 1.05, min = 5, max = 7 }, { type = "tickHots", target = "neighbors", area = { side = "front" }, match = { tag = "hot" } } },
  },
})

ability(6016, "flash_heal", "Flash Heal", "holy", "Spell_Holy_FlashHeal", 2, {
  minRound = 3, tags = { "holy", "spell", "heal" },
  use = { cost = 20, cd = 3, reactive = true, resource = "mana", condition = "below35", effects = { { type = "heal", coef = 0.75, min = 3, max = 5 } }, interruptChannel = true },
})

ability(6017, "greater_heal", "Greater Heal", "holy", "Spell_Holy_GreaterHeal", 3, {
  shape = S.L, tags = { "holy", "spell", "heal", "patient_heal" },
  use = { cost = 28, cd = 8, reactive = true, prepare = 1.5, resource = "mana", condition = "below75", effects = { { type = "heal", coef = 1.75, min = 6, max = 8 } } },
})

ability(6018, "holy_fire", "Holy Fire", "holy", "Spell_Holy_SearingLight", 1, {
  tags = { "holy", "spell", "dot" },
  use = {
    cost = 18, cd = 8, resource = "mana",
    effects = { { type = "damage", coef = 0.6, min = 3, max = 5, school = "holy" }, { type = "dot", key = "holy_fire", coef = 0.05, tick = 1, school = "holy", duration = 8 } },
  },
})

ability(6019, "holy_nova", "Holy Nova", "holy", "Spell_Holy_HolyNova", 3, {
  shape = S.L, tags = { "holy", "spell", "heal" },
  use = {
    cost = 24, cd = 3.5, resource = "mana", condition = "injured",
    effects = { { type = "damage", coef = 0.5, min = 2, max = 4, school = "holy" }, { type = "heal", coef = 0.6, min = 2, max = 4 } },
  },
})

ability(6020, "prayer_of_healing", "Prayer of Healing", "holy", "Spell_Holy_PrayerOfHealing02", 4, {
  shape = S.sq, tags = { "holy", "spell", "heal", "hot" },
  use = {
    cost = 28, cd = 14, resource = "mana", condition = "below50",
    effects = { { type = "heal", coef = 3, min = 5, max = 7 }, { type = "hot", key = "prayer_of_healing", coef = 0.1, tick = 1, duration = 8 } },
  },
})

ability(6021, "spiritual_healing", "Spiritual Healing", "holy", "Spell_Nature_MoonGlow", 3, {
  shape = S.v2, tags = { "holy" },
  triggers = { { on = "battleStart", effects = { { type = "buff", key = "spiritual_healing", name = "Spiritual Healing", stat = "healPct", value = 20, duration = 90, missingHealth = true } } } },
})

ability(6022, "inspiration", "Inspiration", "holy", "Spell_Holy_LayOnHands", 2, {
  shape = S.v2, tags = { "holy" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "heal" }, icd = 1,
      effects = { { type = "buff", key = "inspiration", name = "Inspiration", stat = "armor", value = 0, duration = 6, gearCoef = 0.2, gearStat = "armor" } },
      healing = true,
    },
  },
})

ability(6023, "searing_light", "Searing Light", "holy", "Spell_Holy_SearingLightPriest", 2, {
  shape = S.v2, tags = { "holy" },
  triggers = { { on = "anyCrit", match = { tag = "holy" }, icd = 2, effects = { { type = "tickHots", target = "neighbors", area = { corners = true }, match = { tag = "hot" } } }, healing = false } },
  adjacency = { { match = { damaging = true, tag = "holy" }, corners = true, mods = { dmgPct = 15 } } },
})

ability(6024, "divine_fury", "Divine Fury", "holy", "Spell_Holy_SealOfWrath", 2, {
  minRound = 3, shape = S.v2, tags = { "holy" },
  adjacency = { { match = { tag = "holy" }, mods = { cdPct = 12.5 }, side = "back" }, { match = { prepared = true, tag = "holy" }, mods = { prepareFlat = -0.25 }, side = "back" } },
  passiveTriggers = true,
})

ability(6025, "lightwell", "Lightwell", "holy", "Spell_Holy_SummonLightwell", 5, {
  minRound = 9, shape = S.sq, tags = { "holy", "spell", "heal", "hot" },
  use = {
    cost = 24, cd = 22, initialDelay = 1, resource = "mana", condition = "injured",
    effects = { { type = "hot", key = "lightwell", coef = 1, tick = 2, duration = 5, breakDamagePctMax = 0.2, breakOnDamage = true, preserveTicks = true } },
  },
  shopWeight = 0.5,
})

ability(6026, "shadow_word_pain", "Shadow Word: Pain", "shadow", "Spell_Shadow_ShadowWordPain", 1, {
  tags = { "shadow", "spell", "dot" },
  use = {
    cost = 14, cd = 12, initialDelay = 1, priority = 60, resource = "mana", condition = "enemyNeeds:shadow_word_pain:1",
    effects = { { type = "dot", key = "shadow_word_pain", coef = 0.1, tick = 1, school = "shadow", duration = 12, preserveTicks = true } },
  },
  shopWeight = 1.6,
})

ability(6027, "mind_blast", "Mind Blast", "shadow", "Spell_Shadow_UnholyFrenzy", 1, {
  use = { cost = 18, cd = 7, resource = "mana", effects = { { type = "damage", coef = 0.65, min = 4, max = 6, school = "shadow", consumeDots = { match = { tag = "shadow" }, fraction = 0.2 } } } },
  shopWeight = 1.4,
})

ability(6028, "mind_flay", "Mind Flay", "shadow", "Spell_Shadow_SiphonMana", 2, {
  tags = { "shadow", "spell", "dot", "control", "channel" },
  use = {
    cost = 16, cd = 6, channel = { key = "mind_flay", duration = 3 }, resource = "mana",
    effects = {
      { type = "dot", key = "mind_flay", coef = 0.175, tick = 1, school = "shadow", duration = 3, preserveTicks = true },
      { type = "debuff", key = "mind_flay_slow", name = "Mind Flay", stat = "haste", value = 15, duration = 3 },
    },
  },
  triggers = { { on = "dotTick", match = { key = "mind_flay" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 4 } } } },
  shopWeight = 1.2,
})

ability(6029, "vampiric_embrace", "Vampiric Embrace", "shadow", "Spell_Shadow_UnsummonBuilding", 2, {
  shape = S.v2, tags = { "shadow" },
  triggers = {
    { on = "anyHit", match = { tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.1, noCrit = true } } },
    { on = "dotTick", match = { tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.1, noCrit = true } } },
  },
})

ability(6030, "shadow_weaving", "Shadow Weaving", "shadow", "Spell_Shadow_BlackPlague", 2, {
  minRound = 3, shape = S.v2, tags = { "shadow" },
  triggers = {
    {
      on = "dotTick", match = { tag = "shadow" }, every = 3,
      effects = {
        { type = "buff", key = "shadow_weaving", name = "Shadow Weaving", target = "all", match = { tag = "shadow" }, stat = "dmgPct", value = 3, duration = 8, maxStacks = 5, stack = true },
      },
      counterKey = "priest_shadow_weaving", effective = true,
    },
    {
      on = "anyHit", match = { kind = "ability", tag = "shadow" }, every = 3,
      effects = {
        { type = "buff", key = "shadow_weaving", name = "Shadow Weaving", target = "all", match = { tag = "shadow" }, stat = "dmgPct", value = 3, duration = 8, maxStacks = 5, stack = true },
      },
      counterKey = "priest_shadow_weaving", effective = true,
    },
  },
})

ability(6031, "shadowform", "Shadowform", "shadow", "Spell_Shadow_Shadowform", 5, {
  minRound = 9, kind = "form", shape = S.sq, tags = { "shadow" }, provides = "shadowform",
  triggers = {
    {
      on = "battleStart",
      effects = {
        { type = "buff", key = "shadowform_defense", name = "Shadowform", stat = "dr", value = 15, duration = 90, damageSchool = "physical" },
        { type = "buff", key = "shadowform_damage", name = "Shadowform", target = "all", match = { tag = "shadow" }, stat = "dmgPct", value = 25, duration = 90 },
      },
    },
  },
  blockUses = { { damaging = true, tag = "holy" }, { healing = true, tag = "holy" } }, rankable = false,
  useRestrictionText = "You cannot cast Holy damage or healing spells while in Shadowform.",
})

ability(6032, "spirit_tap", "Spirit Tap", "shadow", "Spell_Shadow_Requiem", 1, {
  shape = S.v2, tags = { "shadow" },
  triggers = { { on = "dotTick", match = { tag = "shadow" }, icd = 1, everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 5 } } } },
})

ability(6033, "darkness", "Darkness", "shadow", "Spell_Shadow_Twilight", 1, { shape = S.v2, tags = { "shadow" }, adjacency = { { match = { tag = "shadow" }, mods = { dmgPct = 15 }, side = "front" } }, passiveTriggers = true })

ability(6034, "improved_shadow_word_pain", "Improved Shadow Word: Pain", "shadow", "Spell_Shadow_ShadowWordPain", 2, {
  shape = S.v2, tags = { "shadow" },
  triggers = { { on = "anyCrit", match = { tag = "shadow" }, effects = { { type = "refresh", key = "shadow_word_pain" } }, healing = false } },
  shopRequires = { "shadow_word_pain" },
})

ability(6035, "shadow_reach", "Shadow Reach", "shadow", "Spell_Shadow_ChillTouch", 3, { shape = S.v2, tags = { "shadow" }, triggers = { { on = "anyUse", match = { key = "mind_blast" }, effects = { { type = "tickDots", match = { key = "shadow_word_pain" } } } } } })

ability(6036, "silence", "Silence", "shadow", "Spell_Shadow_ImpPhaseShift", 3, {
  tags = { "shadow", "spell", "control" },
  use = {
    cost = 15, cd = 15, resource = "mana",
    effects = { { type = "stun", duration = 1.4, rankScale = false }, { type = "cdr", target = "all", match = { key = "mind_blast" }, amount = 2, clampReady = true } },
    rankCosts = { [2] = 12, [3] = 10 },
  },
})

ability(6037, "psychic_scream", "Psychic Scream", "shadow", "Spell_Shadow_PsychicScream", 2, {
  tags = { "shadow", "spell", "control", "defensive" },
  use = {
    cost = 18, cd = 18, resource = "mana", condition = "below50",
    effects = { { type = "stun", duration = 2, controlType = "fear", rankScale = false }, { type = "tickDots", match = { tag = "shadow" } } },
    rankCosts = { [2] = 14, [3] = 12 },
  },
})

ability(6038, "dispel_magic", "Dispel Magic", "discipline", "Spell_Holy_DispelMagic", 2, { use = { cost = 12, cd = 12, resource = "mana", effects = { { type = "cleanse", count = 1, debuffs = true }, { type = "purge", count = 1 } } } })

ability(6039, "abolish_disease", "Abolish Disease", "holy", "Spell_Nature_NullifyDisease", 2, {
  tags = { "holy", "spell", "defensive" },
  use = {
    cost = 12, cd = 10, resource = "mana", condition = { "hasHarmful", "notBuff:priest_abolish_disease" },
    effects = {
      { type = "cleanse", count = 1, debuffs = true },
      {
        type = "buff", key = "priest_abolish_disease", name = "Abolish Disease", stat = "none", value = 1, duration = 8,
        periodic = { every = 2, effects = { { type = "cleanse", count = 1, debuffs = true } } },
      },
    },
  },
  shopClasses = {},
})

ability(6040, "fade", "Fade", "shared", "Spell_Magic_LesserInvisibilty", 1, { tags = { "defensive" }, use = { cd = 18, initialDelay = 4, effects = { { type = "buff", key = "fade", name = "Fade", stat = "dodge", value = 20, duration = 4 } } } })

ability(6041, "shackle_undead", "Shackle Undead", "shared", "Spell_Nature_Slow", 2, {
  minRound = 3, tags = { "spell", "control" },
  use = { cost = 15, cd = 16, resource = "mana", effects = { { type = "stun", duration = 1.5, rankScale = false }, { type = "absorb", coef = 0.15, amount = 8 } } },
})

ability(6042, "desperate_prayer", "Desperate Prayer", "holy", "Spell_Holy_Restoration", 4, {
  tags = { "holy", "spell", "heal", "defensive" },
  use = { cd = 24, initialDelay = 0, reactive = true, once = true, condition = "below35", effects = { { type = "heal", coef = 1.1, min = 5, max = 7 } }, interruptChannel = true },
})

ability(6043, "wand_specialization_priest", "Wand Specialization", "discipline", "INV_Wand_01", 1, {
  shape = S.v2, tags = { "discipline" },
  triggers = { { on = "regularHit", match = { weaponType = "wand" }, every = 4, effects = { { type = "resource", resource = "mana", amount = 3 } } } },
  adjacency = { { match = { weaponType = "wand" }, mods = { dmgPct = 15 }, side = "front" } },
})

ability(6044, "martyrdom", "Martyrdom", "discipline", "Spell_Nature_Tranquility", 4, {
  shape = S.v2, tags = { "discipline" },
  triggers = {
    {
      on = "damaged", icd = 8, everyAmount = 50,
      effects = { { type = "buff", key = "martyrdom", name = "Martyrdom", match = { tag = "heal" }, stat = "none", value = 0, duration = 6, charges = 1, free = true } },
    },
  },
  shopWeight = 0.65,
})

ability(6045, "unbreakable_will", "Unbreakable Will", "discipline", "Spell_Magic_MageArmor", 3, {
  shape = S.v2, tags = { "discipline" },
  triggers = { { on = "stunned", icd = 3, effects = { { type = "absorb", coef = 0.25, amount = 12 }, { type = "resource", resource = "mana", amount = 8 } } } },
})

ability(6046, "blackout", "Blackout", "shadow", "Spell_Shadow_GatherShadows", 3, {
  shape = S.v2, tags = { "shadow" },
  triggers = { { on = "anyHit", match = { kind = "ability", tag = "shadow" }, chance = 15, icd = 4, effects = { { type = "stun", duration = 0.8, rankScale = false } } } },
})

ability(6047, "devouring_plague", "Devouring Plague", "shadow", "Spell_Shadow_BlackPlague", 3, {
  minRound = 5, tags = { "shadow", "spell", "dot", "heal", "disease" },
  use = { cost = 22, cd = 18, resource = "mana", effects = { { type = "dot", key = "devouring_plague", coef = 0.08, tick = 1, school = "shadow", duration = 10 } } },
  triggers = { { on = "dotTick", match = { key = "devouring_plague" }, effects = { { type = "heal", fromEvent = 1, noCrit = true } } } },
})

ability(6048, "shadow_affinity", "Shadow Affinity", "shadow", "Spell_Shadow_ShadowWard", 4, {
  shape = S.v2, tags = { "shadow" },
  triggers = {
    {
      on = "dotTick", match = { kind = "ability", tag = "shadow" }, everyAmount = 45,
      effects = {
        { type = "buff", key = "shadow_affinity", name = "Shadow Affinity", stat = "dodge", value = 12, duration = 5 },
        { type = "cdr", target = "all", match = { key = "fade" }, amount = 2, clampReady = true },
      },
    },
  },
})

ability(6049, "improved_vampiric_embrace", "Improved Vampiric Embrace", "shadow", "Spell_Shadow_ImprovedVampiricEmbrace", 4, {
  shape = S.v2, tags = { "shadow" },
  triggers = {
    { on = "anyHit", match = { kind = "ability", tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.1, noCrit = true } } },
    { on = "dotTick", match = { kind = "ability", tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.1, noCrit = true } } },
  },
  shopRequires = { "vampiric_embrace" }, shopWeight = 0.7,
})

ability(6060, "elunes_grace", "Elune's Grace", "discipline", "Spell_Holy_ElunesGrace", 2, {
  tags = { "discipline", "spell", "defensive" },
  use = {
    cost = 12, cd = 20, reactive = true, resource = "mana", condition = "below50",
    effects = {
      { type = "buff", key = "elunes_grace_ranged", name = "Elune's Grace", stat = "dr", value = 25, duration = 6, damageSchool = "physical", rangedOnly = true, rankScale = false },
      { type = "buff", key = "elunes_grace_dodge", name = "Elune's Grace", stat = "dodge", value = 10, duration = 6, rankScale = false },
    },
    rankCosts = { [2] = 10, [3] = 8 },
  },
})



ability(6080, "mana_burn", "Mana Burn", "discipline", "Spell_Shadow_ManaBurn", 2, {
  shape = { "111" }, tags = { "discipline", "spell", "shadow", "drain" },
  use = {
    cost = 14, cd = 12, resource = "mana",
    effects = { { type = "drain", coef = 0.2, resource = "mana", amount = 20, school = "shadow", damagePerResource = 0.5, noCrit = true, powerStat = "sp" } },
  },
  shopWeight = 1.3,
})

ability(6081, "feedback", "Feedback", "discipline", "Spell_Shadow_RitualOfSacrifice", 3, {
  cost = 7, shape = { "110", "011" }, tags = { "discipline", "spell", "shadow", "defensive" },
  use = { cost = 14, cd = 20, resource = "mana", effects = { { type = "buff", key = "feedback", name = "Feedback", stat = "none", value = 1, duration = 8, rankScale = false } } },
  triggers = {
    {
      on = "damaged", condition = "buff:feedback", matchAttacker = { tag = "spell" }, icd = 2,
      effects = { { type = "drain", coef = 0.1, resource = "mana", amount = 10, school = "shadow", damagePerResource = 1, noCrit = true, powerStat = "sp" } },
    },
  },
  shopAffinities = { PRIEST = { discipline = 1, shadow = 0.65 } }, shopWeight = 0.65,
})

ability(6082, "fear_ward", "Fear Ward", "shared", "Spell_Holy_Excorcism", 2, {
  cost = 4, shape = S.one, tags = { "spell", "holy", "defensive" },
  use = {
    cost = 12, cd = 24, initialDelay = 0, resource = "mana",
    effects = { { type = "buff", key = "fear_ward", name = "Fear Ward", stat = "none", value = 1, duration = 20, controlCharges = 1, controlTypes = { "fear" }, rankScale = false } },
  },
  shopWeight = 0.8,
})

ability(6083, "starshards", "Starshards", "shared", "Spell_Arcane_StarFire", 2, {
  cost = 5, shape = { "10", "10", "11" }, tags = { "spell", "arcane", "channel", "dot" },
  use = {
    cost = 16, cd = 8, channel = { key = "starshards", duration = 4 }, resource = "mana",
    effects = { { type = "dot", key = "starshards", coef = 0.55, tick = 1, school = "arcane", duration = 4, preserveTicks = true } },
  },
  adjacency = { { empty = true, selfMods = { dmgPct = 10 }, side = "front" } },
  shopAffinities = { PRIEST = { discipline = 1, holy = 1, shadow = 0.35 } }, shopWeight = 0.8,
})

ability(6084, "hex_of_weakness", "Hex of Weakness", "shadow", "Spell_Shadow_FingerOfDeath", 2, {
  cost = 4, shape = S.L, tags = { "shadow", "spell", "defensive", "curse" },
  use = {
    cost = 10, cd = 16, resource = "mana",
    effects = {
      {
        type = "debuff", key = "hex_of_weakness_damage", name = "Hex of Weakness", exclusiveGroup = "priest_physical_weakness", stat = "dmgPct",
        value = 10, duration = 8, damageSchool = "physical", rankScale = false,
      },
      { type = "debuff", key = "hex_of_weakness_healing", name = "Hex of Weakness", exclusiveGroup = "healing_reduction", stat = "healPct", value = 15, duration = 8 },
    },
  },
  shopAffinities = { PRIEST = { discipline = 0.5, holy = 0.35, shadow = 1 } },
})

ability(6085, "touch_of_weakness", "Touch of Weakness", "shadow", "Spell_Shadow_DeadofNight", 2, {
  minRound = 3, shape = S.h2, tags = { "shadow", "spell", "defensive" },
  use = {
    cost = 10, cd = 12, initialDelay = 1, resource = "mana",
    effects = { { type = "buff", key = "touch_of_weakness", name = "Touch of Weakness", stat = "none", value = 1, duration = 10, rankScale = false } },
  },
  triggers = {
    {
      on = "damaged", condition = "buff:touch_of_weakness", matchAttacker = { tag = "melee" },
      effects = {
        { type = "damage", coef = 0.35, min = 1, max = 2, school = "shadow", noCrit = true, noDodge = true },
        {
          type = "debuff", key = "touch_of_weakness_damage", name = "Touch of Weakness", exclusiveGroup = "priest_physical_weakness", stat = "dmgPct",
          value = 10, duration = 5, damageSchool = "physical", rankScale = false,
        },
        { type = "buff", key = "touch_of_weakness", name = "Touch of Weakness", stat = "none", value = 0, duration = 0, charges = 0, rankScale = false },
      },
    },
  },
  shopWeight = 0.8,
})

ability(6086, "improved_healing_priest", "Improved Healing", "holy", "Spell_Holy_Heal02", 2, { minRound = 3, shape = S.L, tags = { "holy" }, adjacency = { { match = { tag = "patient_heal" }, corners = true, mods = { costPct = -20 } } }, passiveTriggers = true })

ability(6087, "improved_renew", "Improved Renew", "holy", "Spell_Holy_Renew", 2, { cost = 4, tags = { "holy" }, adjacency = { { match = { key = "renew" }, mods = { healPct = 15 }, side = "front" } }, passiveTriggers = true, shopWeight = 1.1 })



ability(6088, "blessed_recovery", "Blessed Recovery", "holy", "Spell_Holy_BlessedRecovery", 2, {
  cost = 4, minRound = 3, shape = S.h2, tags = { "holy", "heal", "hot", "defensive" },
  triggers = {
    {
      on = "damaged", matchAttacker = { anyTag = { "melee", "ranged" } }, icd = 6,
      effects = { { type = "hot", key = "blessed_recovery", tick = 0, duration = 6, finite = true, fixedFraction = true, fromEvent = 0.15, rolling = true } },
      critical = true,
    },
  },
  shopWeight = 0.8,
})

ability(6089, "shadowguard", "Shadowguard", "shadow", "Spell_Nature_LightningShield", 2, {
  shape = { "11", "01" }, tags = { "shadow", "spell", "defensive" },
  use = {
    cost = 12, cd = 12, initialDelay = 1, resource = "mana", condition = "notBuff:priest_shadowguard",
    effects = {
      { type = "buff", key = "priest_shadowguard", name = "Shadowguard", stat = "none", value = 1, duration = 18, rankScale = false },
      { type = "charge", key = "shadowguard", max = 3, amount = 3 },
    },
  },
  triggers = {
    {
      on = "damaged", condition = { "buff:priest_shadowguard", "chargesAtLeast:shadowguard:1" },
      matchAttacker = { anyTag = { "melee", "ranged", "spell" } }, icd = 3,
      effects = {
        { type = "charge", key = "shadowguard", max = 3, amount = -1 },
        { type = "damage", coef = 0.35, min = 1, max = 2, school = "shadow", noCrit = true, noDodge = true, noOwnTriggers = true },
        { type = "buff", key = "priest_shadowguard", stat = "none", value = 0, duration = 0, charges = 0, cond = "chargesAtMost:shadowguard:0" },
      },
    },
  },
  shopAffinities = { PRIEST = { discipline = 0.5, holy = 0.5, shadow = 1 } }, shopWeight = 0.75,
})

ability(6090, "spell_warding", "Spell Warding", "holy", "Spell_Holy_SpellWarding", 1, {
  tags = { "holy", "defensive" },
  triggers = {
    {
      on = "battleStart",
      effects = {
        { type = "buff", key = "priest_spell_warding_holy", name = "Spell Warding", stat = "dr", value = 5, duration = 90, damageSchool = "holy" },
        { type = "buff", key = "priest_spell_warding_fire", name = "Spell Warding", stat = "dr", value = 5, duration = 90, damageSchool = "fire" },
        { type = "buff", key = "priest_spell_warding_nature", name = "Spell Warding", stat = "dr", value = 5, duration = 90, damageSchool = "nature" },
        { type = "buff", key = "priest_spell_warding_frost", name = "Spell Warding", stat = "dr", value = 5, duration = 90, damageSchool = "frost" },
        { type = "buff", key = "priest_spell_warding_shadow", name = "Spell Warding", stat = "dr", value = 5, duration = 90, damageSchool = "shadow" },
        { type = "buff", key = "priest_spell_warding_arcane", name = "Spell Warding", stat = "dr", value = 5, duration = 90, damageSchool = "arcane" },
      },
    },
  },
  shopWeight = 0.8,
})
