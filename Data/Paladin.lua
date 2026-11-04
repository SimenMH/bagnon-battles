local ADDON, ns = ...
local H = ns.H
local S = H.S
local PALADIN = { "PALADIN" }
local ability = H.QualityAbilities(PALADIN)

ability(5000, "seal_of_righteousness", "Seal of Righteousness", "holy", "ability_thunderbolt", 1, {
  kind = "form", shape = S.v2, tags = { "holy", "seal", "holy" }, provides = "seal",
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" },
      effects = { { type = "damage", coef = 0.25, min = 1, max = 1, school = "holy", noDodge = true, noOwnTriggers = true }, { type = "bank", key = "paladin_seal", fraction = 1 } },
    },
  },
})




ability(5001, "judgement", "Judgement", "retribution", "spell_holy_righteousfury", 1, {
  tags = { "retribution", "spell", "holy", "judgement", "paladin_holy_attack" }, exclusiveGroup = "paladin_judgement", exclusiveLabel = "Judgement",
  use = {
    cost = 10, cd = 8, resource = "mana",
    effects = {
      { type = "damage", coef = 0.6, min = 2, max = 4, school = "holy", bankLabel = "stored seal energy", bankScale = 1, critIf = "enemyStunned", noDodge = true, spendBank = "paladin_seal" },
    },
  },
  shopAffinities = { PALADIN = { holy = 0.75, protection = 0.75, retribution = 1 } }, shopWeight = 1.5,
})

ability(5002, "holy_light", "Holy Light", "holy", "spell_holy_holybolt", 1, {
  tags = { "holy", "spell", "heal", "paladin_direct_heal" },
  use = { cost = 20, cd = 5, resource = "mana", condition = "injured", effects = { { type = "heal", coef = 0.9, min = 4, max = 6 } } },
  triggers = { { on = "healed", match = { key = "holy_light" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.3 } } } },
  shopWeight = 1.5,
})

ability(5003, "flash_of_light", "Flash of Light", "holy", "spell_holy_flashheal", 1, {
  shape = S.one, tags = { "holy", "spell", "heal", "paladin_direct_heal" },
  use = { cost = 9, cd = 2.8, resource = "mana", condition = "injured", effects = { { type = "heal", coef = 0.45, min = 1, max = 3 } } },
  shopWeight = 1.5,
})

ability(5004, "consecration", "Consecration", "holy", "spell_holy_innerfire", 2, {
  shape = S.sq, tags = { "holy", "spell", "dot", "paladin_holy_attack" },
  use = {
    cost = 20, cd = 10, resource = "mana",
    effects = {
      { type = "damage", coef = 0.3, min = 1, max = 2, school = "holy", bankLabel = "stored prevented damage", bankScale = 0.6, noDodge = true, spendBank = "paladin_sanctuary" },
      { type = "dot", key = "consecration", coef = 0.15, tick = 1, school = "holy", duration = 8 },
    },
  },
  shopAffinities = { PALADIN = { holy = 1, protection = 1, retribution = 0.75 } }, shopWeight = 1.5,
})

ability(5005, "holy_shock", "Holy Shock", "holy", "spell_holy_searinglight", 3, {
  minRound = 3, shape = S.L, tags = { "holy", "spell", "heal", "paladin_direct_heal", "paladin_holy_attack" },
  use = {
    cost = 18, cd = 9, resource = "mana",
    effects = {
      { type = "damage", coef = 0.65, min = 2, max = 4, school = "holy", bankLabel = "stored healing", bankScale = 1, noDodge = true, spendBank = "paladin_holy" },
      { type = "heal", coef = 0.35, min = 1, max = 3, cond = "injured" },
    },
  },
  triggers = { { on = "healed", effects = { { type = "bank", key = "paladin_holy", fraction = 0.15 } } } },
})

ability(5006, "illumination", "Illumination", "holy", "spell_holy_greaterheal", 2, {
  shape = S.v2, tags = { "holy", "spell", "holy" },
  triggers = {
    {
      on = "anyCrit", match = { tag = "paladin_direct_heal" }, icd = 1, effects = { { type = "resource", resource = "mana", fromPaid = 0.5 } },
      effective = true, healing = true, oncePerActivation = true, paidOnly = true,
    },
  },
})

ability(5007, "divine_favor", "Divine Favor", "holy", "spell_holy_heal", 4, {
  minRound = 6, tags = { "holy", "spell", "holy" },
  use = {
    cost = 8, cd = 20, resource = "mana",
    effects = {
      {
        type = "buff", key = "divine_favor", name = "Divine Favor", target = "all", match = { tag = "paladin_direct_heal" }, stat = "crit",
        value = 100, duration = 12, charges = 1, paidOnly = true, rankScale = false,
      },
    },
  },
  rankable = false,
})

ability(5008, "healing_light", "Healing Light", "holy", "spell_holy_holybolt", 1, {
  tags = { "holy", "spell", "holy" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "healing_light", name = "Healing Light", target = "all", match = { tag = "paladin_direct_heal" }, stat = "healPct", value = 15, duration = 90 } },
    },
  },
})

ability(5009, "spiritual_focus", "Spiritual Focus", "holy", "spell_arcane_blink", 2, {
  shape = S.v2, tags = { "holy", "spell", "holy" },
  triggers = {
    {
      on = "damaged", icd = 1, everyAmount = 30,
      effects = { { type = "cdr", target = "neighbors", area = { side = "front" }, match = { tag = "paladin_direct_heal" }, amount = 0.6, clampReady = true } },
    },
  },
})

ability(5010, "divine_intellect", "Divine Intellect", "holy", "spell_nature_sleep", 1, { tags = { "holy", "spell", "holy" }, gearBonuses = { { coef = 0.2, stat = "mana", gearStat = "mana" } }, passiveTriggers = true })

ability(5011, "divine_strength", "Divine Strength", "holy", "ability_golemthunderclap", 1, { tags = { "holy", "melee" }, stats = { ap = 16 }, passiveTriggers = true, rankable = false, shopClasses = {} })

ability(5012, "improved_seal_of_righteousness", "Improved Seal of Righteousness", "holy", "ability_thunderbolt", 2, {
  minRound = 3, shape = S.v2, tags = { "holy", "spell", "holy" }, stats = { sp = 8 },
  triggers = { { on = "anyHit", match = { key = "seal_of_righteousness" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.6 } } } },
  rankable = false, shopRequires = { "seal_of_righteousness" },
})

ability(5013, "lasting_judgement", "Lasting Judgement", "holy", "spell_holy_healingaura", 1, {
  minRound = 2, shape = S.v2, tags = { "holy", "judgement_support" },
  triggers = {
    {
      on = "anyHit", match = { damaging = "direct", tag = "judgement" }, icd = 1,
      effects = { { type = "hot", key = "lasting_judgement", tick = 0, duration = 4, finite = true, fixedFraction = true, fromEvent = 0.25, rankScale = false } },
      effective = true, oncePerActivation = true, paidOnly = true,
    },
  },
  adjacency = { { match = { tag = "maintained_judgement" }, mods = { durationPct = 50 }, side = "back" } },
})

ability(5014, "improved_blessing_of_wisdom", "Improved Blessing of Wisdom", "holy", "spell_holy_sealofwisdom", 2, {
  minRound = 3, shape = S.v2, tags = { "holy", "spell", "holy" },
  triggers = { { on = "resourceGained", resource = "mana", match = { key = "blessing_of_wisdom" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.5 } } } },
  shopRequires = { "blessing_of_wisdom" },
})

ability(5015, "improved_lay_on_hands", "Improved Lay on Hands", "holy", "spell_holy_layonhands", 3, {
  cost = 6, minRound = 7, shape = S.v2, tags = { "holy", "spell", "holy" },
  triggers = {
    {
      on = "anyUse", match = { key = "lay_on_hands" },
      effects = {
        { type = "buff", key = "improved_lay_on_hands", name = "Improved Lay on Hands", stat = "armor", value = 0, duration = 12, gearCoef = 0.2 },
        { type = "resource", resource = "mana", fromPaid = 0.2 },
      },
    },
  },
  shopRequires = { "lay_on_hands" },
})



ability(5016, "holy_power", "Holy Power", "holy", "spell_holy_power", 5, {
  minRound = 9, shape = S.v2, tags = { "holy", "spell", "holy" },
  triggers = {
    { on = "anyCrit", match = { tag = "holy" }, every = 3, effects = { { type = "cast", key = "holy_shock" } }, effective = true, healing = true, oncePerActivation = true, paidOnly = true },
  },
  adjacency = { { match = { tag = "paladin_direct_heal" }, corners = true, mods = { crit = 8 } } }, rankable = false, shopRequires = { "holy_shock" },
})

ability(5020, "holy_shield", "Holy Shield", "protection", "classic_spell_holy_blessingofprotection", 3, {
  minRound = 3, tags = { "protection", "spell", "holy", "paladin_holy_attack" },
  use = {
    cost = 16, cd = 10, resource = "mana", requires = "shield", condition = "buffNeeds:holy_shield:0.1",
    effects = { { type = "buff", key = "holy_shield", name = "Holy Shield", stat = "blockChance", value = 30, duration = 7, charges = 4, consumeOn = "block", rankScale = false } },
  },
  triggers = { { on = "block", condition = "buff:holy_shield", effects = { { type = "damage", coef = 0.25, min = 1, max = 2, school = "holy", fromEvent = 0.5, noDodge = true } } } },
  rankTriggers = true,
})

ability(5021, "redoubt", "Redoubt", "protection", "ability_defend", 1, {
  shape = S.v2, tags = { "protection", "spell", "holy" }, stats = { block = 3 },
  triggers = {
    { on = "damaged", effects = { { type = "buff", key = "redoubt", name = "Redoubt", stat = "blockChance", value = 20, duration = 5, charges = 5, consumeOn = "block" } }, critical = true },
  },
  rankable = false,
})

ability(5022, "reckoning", "Reckoning", "protection", "spell_holy_blessingofstrength", 3, {
  shape = S.v2, tags = { "protection", "spell", "holy" },
  triggers = {
    { on = "damaged", chance = 50, effects = { { type = "charge", key = "reckoning", max = 4 } }, critical = true },
    { on = "regularHit", match = { kind = "weapon", tag = "melee" }, effects = { { type = "extraAttack", count = 1, spendCharge = "reckoning" } } },
  },
})

ability(5023, "blessing_of_sanctuary", "Blessing of Sanctuary", "protection", "spell_nature_lightningshield", 2, {
  shape = S.v2, tags = { "protection", "spell", "holy" }, exclusiveGroup = "paladin_blessing", exclusiveLabel = "Blessing",
  triggers = { { on = "block", icd = 1, effects = { { type = "bank", key = "paladin_sanctuary", fraction = 1 }, { type = "resource", resource = "mana", amount = 3 } } } },
})

ability(5024, "righteous_fury", "Righteous Fury", "protection", "spell_holy_sealoffury", 1, {
  shape = S.v2, tags = { "protection", "spell", "holy" }, stats = { armor = 10 },
  triggers = {
    { on = "armorPrevented", effects = { { type = "bank", key = "paladin_sanctuary", fraction = 0.25 } } },
    {
      on = "regularHit", match = { tag = "melee" },
      effects = { { type = "damage", school = "holy", bankLabel = "stored prevented damage", bankScale = 0.5, noCrit = true, noDodge = true, noOwnTriggers = true, spendBank = "paladin_sanctuary" } },
    },
  },
  rankable = false,
})



ability(5025, "paladin_toughness", "Toughness", "protection", "spell_holy_devotion", 1, {
  tags = { "protection", "spell", "holy" },
  triggers = { { on = "battleStart", effects = { { type = "buff", key = "paladin_toughness", name = "Toughness", stat = "armor", value = 0, duration = 90, gearCoef = 0.3 } } } },
})

ability(5026, "paladin_shield_specialization", "Shield Specialization", "protection", "inv_shield_06", 2, {
  tags = { "protection", "spell", "holy" },
  triggers = {
    { on = "block", condition = "provides:shield", effects = { { type = "absorb", fromEvent = 0.3 } } },
    {
      on = "battleStart", condition = "provides:shield",
      effects = {
        { type = "buff", key = "paladin_shield_specialization", name = "Shield Specialization", stat = "block", value = 2, duration = 90, gearCoef = 0.25 },
        { type = "buff", key = "paladin_shield_specialization_chance", name = "Shield Specialization", stat = "blockChance", value = 10, duration = 90 },
      },
    },
  },
})

ability(5027, "anticipation_paladin", "Anticipation", "protection", "spell_nature_mirrorimage", 2, { tags = { "protection", "spell", "holy" }, stats = { armor = 8, dodge = 6 }, passiveTriggers = true, rankable = false, shopClasses = {} })

ability(5028, "improved_devotion_aura", "Improved Devotion Aura", "protection", "spell_holy_devotionaura", 2, {
  minRound = 3, shape = S.v2, tags = { "protection", "spell", "holy" },
  triggers = { { on = "armorPrevented", icd = 1, everyAmount = 20, effects = { { type = "absorb", coef = 0.1, amount = 1 } } } },
  shopRequires = { "devotion_aura" },
})

ability(5029, "improved_righteous_fury", "Improved Righteous Fury", "protection", "spell_holy_sealoffury", 3, {
  shape = S.v2, tags = { "protection", "spell", "holy" }, stats = { dr = 5 },
  triggers = { { on = "armorPrevented", everyAmount = 25, effects = { { type = "cdr", target = "all", match = { key = "holy_shield" }, amount = 1, clampReady = true } } } },
  rankable = false, shopRequires = { "righteous_fury" },
})

ability(5030, "blessing_of_kings", "Blessing of Kings", "protection", "spell_magic_magearmor", 3, {
  minRound = 5, shape = S.one, tags = { "protection", "spell", "holy" }, exclusiveGroup = "paladin_blessing", exclusiveLabel = "Blessing",
  use = {
    cost = 12, cd = 20, initialDelay = 0, resource = "mana",
    effects = {
      { type = "buff", key = "kings_ap", name = "Blessing of Kings", stat = "ap", value = 0, duration = 20, gearCoef = 0.1 },
      { type = "buff", key = "kings_sp", name = "Blessing of Kings", stat = "sp", value = 0, duration = 20, gearCoef = 0.1 },
      { type = "buff", key = "kings_healing", name = "Blessing of Kings", stat = "healing", value = 0, duration = 20, gearCoef = 0.1 },
    },
  },
})

ability(5031, "improved_hammer_of_justice", "Improved Hammer of Justice", "protection", "spell_holy_sealofmight", 2, {
  minRound = 3, shape = S.v2, tags = { "protection", "spell", "holy" },
  triggers = { { on = "block", effects = { { type = "cdr", target = "all", match = { key = "hammer_of_justice" }, amount = 0.8, clampReady = true } } } },
  rankable = false, shopRequires = { "hammer_of_justice" },
})

ability(5032, "precision_paladin", "Precision", "protection", "ability_rogue_ambush", 2, {
  cost = 4, minRound = 3, tags = { "protection", "spell", "holy" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "precision_paladin", name = "Precision", target = "all", match = { tag = "melee" }, stat = "dodgeIgnore", value = 5, duration = 90 } },
    },
  },
})

ability(5033, "guardians_favor", "Guardian's Favor", "protection", "spell_holy_sealofprotection", 2, {
  cost = 4, minRound = 3, shape = S.v2, tags = { "protection", "spell", "holy" },
  triggers = { { on = "block", every = 4, effects = { { type = "absorb", coef = 0.2, amount = 4, powerStat = "armor", rankScale = false } }, effective = true } },
  adjacency = { { match = { key = "blessing_of_protection" }, corners = true, mods = { cdPct = 20 } } },
})

ability(5034, "improved_concentration_aura", "Improved Concentration Aura", "protection", "spell_holy_mindsooth", 4, {
  shape = S.v2, tags = { "protection", "spell", "holy" }, stats = { healing = 10 },
  triggers = { { on = "stunned", icd = 10, effects = { { type = "absorb", coef = 0.25, amount = 18 }, { type = "cdr", target = "all", match = { tag = "heal" }, amount = 2, clampReady = true } } } },
  rankable = false,
})

ability(5035, "one_handed_weapon_specialization_paladin", "One-Handed Weapon Specialization", "protection", "inv_sword_20", 5, {
  minRound = 9, shape = S.v2, tags = { "protection", "spell", "holy" },
  triggers = { { on = "block", condition = { "owns:reckoning", "provides:shield" }, icd = 2, effects = { { type = "charge", key = "reckoning", max = 4 } }, effective = true } },
  adjacency = { { match = { kind = "weapon", hands = 1, tag = "melee" }, mods = { dmgPct = 25 }, side = "front" } },
})

ability(5040, "seal_of_command", "Seal of Command", "retribution", "ability_warrior_innerrage", 2, {
  kind = "form", shape = S.v2, tags = { "retribution", "seal", "holy" }, provides = "seal",
  triggers = {
    {
      on = "regularHit", match = { tag = "melee" }, chance = 30,
      effects = { { type = "damage", coef = 0.15, school = "holy", fromEvent = 0.7, noDodge = true, noOwnTriggers = true }, { type = "bank", key = "paladin_seal", fraction = 3 } },
    },
  },
})

ability(5041, "seal_of_the_crusader", "Seal of the Crusader", "retribution", "spell_holy_holysmite", 1, {
  kind = "form", shape = S.v2, tags = { "retribution", "seal", "holy" }, stats = { haste = 10 }, provides = "seal",
  triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.6 } } } },
})

ability(5042, "vengeance_paladin", "Vengeance", "retribution", "ability_racial_avatar", 2, {
  shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = {
    { on = "anyCrit", effects = { { type = "buff", key = "paladin_vengeance", name = "Vengeance", stat = "dmgPct", value = 5, duration = 6, maxStacks = 3, stack = true } }, healing = false },
  },
})

ability(5043, "benediction", "Benediction", "retribution", "spell_frost_windwalkon", 1, {
  tags = { "retribution", "spell", "holy" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "benediction", name = "Benediction", target = "all", match = { tag = "paladin_holy_attack", usable = true }, stat = "costPct", value = -15, duration = 90 } },
    },
  },
})



ability(5044, "improved_judgement", "Improved Judgement", "retribution", "spell_holy_righteousfury", 2, {
  shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "cdr", target = "all", match = { tag = "judgement" }, amount = 0.5, clampReady = true } } } },
  rankable = false,
})

ability(5045, "conviction", "Conviction", "retribution", "spell_holy_retributionaura", 1, {
  tags = { "retribution", "spell", "holy" },
  triggers = {
    {
      on = "resourceSpent", resource = "mana", match = { tag = "judgement" },
      effects = { { type = "buff", key = "conviction", name = "Conviction", target = "all", match = { kind = "weapon", tag = "melee" }, stat = "crit", value = 10, duration = 5 } },
    },
  },
})

ability(5046, "sanctity_aura", "Sanctity Aura", "retribution", "spell_holy_mindvision", 3, {
  shape = S.v2, tags = { "retribution", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  adjacency = { { match = { tag = "holy" }, mods = { dmgPct = 15 } } }, passiveTriggers = true,
})

ability(5047, "two_handed_weapon_specialization_paladin", "Two-Handed Weapon Specialization", "retribution", "inv_axe_09", 2, {
  minRound = 3, shape = S.v2, tags = { "retribution", "melee" },
  triggers = { { on = "regularHit", match = { hands = 2 }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.3 } } } },
  adjacency = { { match = { kind = "weapon", hands = 2, tag = "melee" }, mods = { dmgPct = 15 }, side = "back" } },
})

ability(5048, "pursuit_of_justice", "Pursuit of Justice", "retribution", "spell_holy_persuitofjustice", 2, {
  minRound = 3, shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = { { on = "enemyStunned", effects = { { type = "buff", key = "pursuit_of_justice", name = "Pursuit of Justice", stat = "haste", value = 20, duration = 4 } } } },
})

ability(5049, "eye_for_an_eye", "Eye for an Eye", "retribution", "spell_holy_eyeforaneye", 3, {
  shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = { { on = "damaged", matchAttacker = { tag = "spell" }, effects = { { type = "damage", school = "holy", fromEvent = 0.25, noCrit = true, noDodge = true } } } },
  rankable = false,
})

ability(5050, "improved_retribution_aura", "Improved Retribution Aura", "retribution", "spell_holy_auraoflight", 2, {
  minRound = 3, shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = { { on = "damaged", matchAttacker = { tag = "melee" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.2 } } } },
  rankable = false, shopRequires = { "retribution_aura" },
})

ability(5051, "repentance", "Repentance", "retribution", "spell_holy_prayerofhealing", 4, {
  tags = { "retribution", "spell", "holy" },
  use = { cost = 18, cd = 22, resource = "mana", effects = { { type = "stun", duration = 2.5 }, { type = "cdr", target = "all", match = { tag = "judgement" }, amount = 3, clampReady = true } } },
  rankable = false,
})

ability(5052, "deflection_paladin", "Deflection", "retribution", "ability_parry", 3, {
  shape = S.v2, tags = { "retribution", "spell", "holy" }, stats = { dodge = 5 },
  triggers = { { on = "dodged", icd = 1, effects = { { type = "cdr", target = "all", match = { tag = "judgement" }, amount = 0.5, clampReady = true } } } },
})

ability(5053, "vindication", "Vindication", "retribution", "spell_holy_vindication", 4, {
  minRound = 6, shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 30, effects = { { type = "debuff", key = "vindication", name = "Vindication", stat = "dmgPct", value = 15, duration = 6 } } } },
  rankable = false,
})

ability(5054, "improved_seal_of_the_crusader", "Improved Seal of the Crusader", "retribution", "spell_holy_holysmite", 5, {
  minRound = 9, shape = S.v2, tags = { "retribution", "spell", "holy" },
  triggers = {
    { on = "regularHit", condition = "owns:seal_of_the_crusader", match = { tag = "melee" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.75 } } },
    {
      on = "anyUse", condition = "owns:seal_of_the_crusader", match = { key = "judgement" },
      effects = { { type = "buff", key = "improved_crusader", name = "Improved Seal of the Crusader", target = "all", match = { tag = "holy" }, stat = "dmgPct", value = 20, duration = 6 } },
    },
  },
  rankable = false, shopRequires = { "seal_of_the_crusader", "judgement" },
})

ability(5060, "seal_of_light", "Seal of Light", "shared", "spell_holy_healingaura", 2, {
  kind = "form", shape = S.v2, tags = { "seal", "holy", "heal" }, provides = "seal",
  triggers = {
    { on = "regularHit", match = { tag = "melee" }, effects = { { type = "heal", coef = 0.15, min = 1, max = 1, noCrit = true } } },
    { on = "healed", effects = { { type = "bank", key = "paladin_seal", fraction = 0.1 } } },
  },
})

ability(5061, "seal_of_wisdom", "Seal of Wisdom", "shared", "spell_holy_righteousnessaura", 2, {
  minRound = 3, kind = "form", shape = S.v2, tags = { "shared", "seal", "holy" }, provides = "seal",
  triggers = {
    { on = "regularHit", match = { tag = "melee" }, icd = 1.5, effects = { { type = "resource", resource = "mana", amount = 4 } } },
    { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "paladin_seal", fraction = 0.4 } } },
  },
})

ability(5062, "hammer_of_justice", "Hammer of Justice", "shared", "spell_holy_sealofmight", 1, { tags = { "shared", "spell", "holy" }, use = { cost = 12, cd = 14, resource = "mana", effects = { { type = "stun", duration = 1.5 } } }, rankable = false })

ability(5063, "hammer_of_wrath", "Hammer of Wrath", "shared", "ability_thunderclap", 3, {
  minRound = 5, tags = { "shared", "spell", "holy", "paladin_holy_attack" },
  use = { cost = 14, cd = 5, resource = "mana", condition = "enemyBelow20", effects = { { type = "damage", coef = 1, min = 3, max = 5, school = "holy", noDodge = true } } },
})

ability(5064, "blessing_of_might", "Blessing of Might", "shared", "spell_holy_fistofjustice", 1, {
  shape = S.one, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_blessing", exclusiveLabel = "Blessing",
  use = {
    cost = 8, cd = 20, initialDelay = 0, resource = "mana",
    effects = { { type = "buff", key = "blessing_of_might", name = "Blessing of Might", stat = "ap", value = 0, duration = 20, gearCoef = 0.2 } },
  },
})

ability(5065, "blessing_of_wisdom", "Blessing of Wisdom", "shared", "spell_holy_sealofwisdom", 1, {
  shape = S.one, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_blessing", exclusiveLabel = "Blessing",
  use = { cost = 0, cd = 8, initialDelay = 0, reactive = true, resource = "mana", condition = "lowMana", effects = { { type = "resource", resource = "mana", amount = 12 } } },
})

ability(5066, "devotion_aura", "Devotion Aura", "shared", "spell_holy_devotionaura", 1, {
  tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  triggers = { { on = "battleStart", effects = { { type = "buff", key = "devotion_aura", name = "Devotion Aura", stat = "armor", value = 4, duration = 90, gearCoef = 0.2 } } } },
})

ability(5067, "retribution_aura", "Retribution Aura", "shared", "spell_holy_auraoflight", 1, {
  shape = S.v2, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  triggers = { { on = "damaged", matchAttacker = { tag = "melee" }, icd = 0.5, effects = { { type = "damage", coef = 0.15, min = 1, max = 1, school = "holy", noCrit = true, noDodge = true } } } },
})

ability(5068, "cleanse_paladin", "Cleanse", "shared", "spell_holy_renew", 2, {
  minRound = 3, shape = S.one, tags = { "shared", "spell", "holy" },
  use = { cost = 10, cd = 10, initialDelay = 0, reactive = true, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 2, debuffs = true } } },
})

ability(5069, "divine_shield", "Divine Shield", "shared", "spell_holy_divineintervention", 4, {
  minRound = 6, shape = S.L, tags = { "shared", "spell", "holy" },
  use = {
    cost = 20, cd = 30, initialDelay = 0, reactive = true, once = true, resource = "mana", condition = { "below35", "notBuff:paladin_forbearance" },
    effects = {
      { type = "buff", key = "divine_shield", name = "Divine Shield", stat = "dr", value = 90, duration = 5, rankScale = false },
      { type = "buff", key = "divine_shield_weapon", name = "Divine Shield", target = "all", match = { kind = "weapon", tag = "melee" }, stat = "haste", value = -50, duration = 5 },
      { type = "buff", key = "paladin_forbearance", name = "Forbearance", stat = "none", value = 0, duration = 12 },
      { type = "cleanse", count = 4, debuffs = true },
    },
  },
  rankable = false,
})

ability(5070, "lay_on_hands", "Lay on Hands", "shared", "spell_holy_layonhands", 4, {
  shape = S.L, tags = { "heal", "holy", "spell" },
  use = {
    cost = 0, cd = 40, initialDelay = 0, reactive = true, once = true, resource = "mana", condition = "below35",
    effects = { { type = "heal", coef = 1.2, noCrit = true, pctMax = 0.65 } }, spendAll = true,
  },
  rankable = false,
})



ability(5080, "seal_of_justice", "Seal of Justice", "shared", "spell_holy_sealofwrath", 2, {
  cost = 3, kind = "form", shape = { "10", "01" }, tags = { "shared", "seal", "holy" }, provides = "seal",
  triggers = { { on = "regularHit", match = { kind = "weapon", tag = "melee" }, chance = 25, icd = 6, effects = { { type = "stun", duration = 0.5 } } } },
  shopAffinities = { PALADIN = { protection = 1, retribution = 1 } }, shopWeight = 0.8,
})

ability(5081, "judgement_of_light", "Judgement of Light", "shared", "spell_holy_healingaura", 2, {
  shape = S.L, tags = { "judgement", "holy", "spell", "heal", "maintained_judgement", "paladin_holy_attack" }, exclusiveGroup = "paladin_judgement",
  exclusiveLabel = "Judgement",
  use = {
    cost = 10, cd = 8, initialDelay = 0, resource = "mana", requires = "melee", condition = "buffNeeds:judgement_of_light:0.1",
    effects = { { type = "buff", key = "judgement_of_light", name = "Judgement of Light", stat = "none", value = 0, duration = 8 } },
  },
  triggers = {
    {
      on = "anyHit", condition = "buff:judgement_of_light", match = { kind = "weapon", tag = "autoattack" }, icd = 1,
      effects = { { type = "heal", coef = 0.15, min = 1, max = 1, noCrit = true } },
    },
  },
  rankTriggers = true, shopAffinities = { PALADIN = { holy = 1, protection = 1, retribution = 0.5 } }, shopWeight = 0.8,
})

ability(5082, "judgement_of_wisdom", "Judgement of Wisdom", "shared", "spell_holy_righteousnessaura", 2, {
  minRound = 3, shape = S.T, tags = { "judgement", "holy", "spell", "maintained_judgement", "paladin_holy_attack" },
  exclusiveGroup = "paladin_judgement", exclusiveLabel = "Judgement",
  use = {
    cost = 6, cd = 8, initialDelay = 0, resource = "mana", condition = "buffNeeds:judgement_of_wisdom:0.1",
    effects = { { type = "buff", key = "judgement_of_wisdom", name = "Judgement of Wisdom", stat = "none", value = 0, duration = 8 } },
  },
  triggers = {
    {
      on = "anyHit", condition = "buff:judgement_of_wisdom", match = { anyTag = { "autoattack", "spell" }, damaging = "direct" }, icd = 1.5,
      effects = { { type = "resource", resource = "mana", amount = 3 } },
    },
  },
  rankTriggers = true, shopAffinities = { PALADIN = { holy = 1, protection = 0.5, retribution = 1 } }, shopWeight = 0.8,
})

ability(5083, "blessing_of_light", "Blessing of Light", "shared", "spell_holy_prayerofhealing02", 2, {
  shape = { "111" }, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_blessing", exclusiveLabel = "Blessing",
  use = {
    cost = 10, cd = 20, initialDelay = 0, resource = "mana",
    effects = {
      { type = "buff", key = "blessing_light_holy", name = "Blessing of Light", target = "all", match = { key = "holy_light" }, stat = "healing", value = 0, duration = 20, gearCoef = 0.25 },
      {
        type = "buff", key = "blessing_light_flash", name = "Blessing of Light", target = "all", match = { key = "flash_of_light" }, stat = "healing",
        value = 0, duration = 20, gearCoef = 0.2,
      },
    },
  },
  shopAffinities = { PALADIN = { holy = 1, protection = 0.5 } }, shopWeight = 0.8,
})

ability(5084, "blessing_of_protection", "Blessing of Protection", "shared", "spell_holy_sealofprotection", 3, {
  cost = 6, tags = { "holy", "spell", "defensive" }, exclusiveGroup = "paladin_blessing", exclusiveLabel = "Blessing",
  use = {
    cost = 12, cd = 24, initialDelay = 0, reactive = true, resource = "mana", condition = { "below50", "notBuff:paladin_forbearance" },
    effects = {
      { type = "buff", key = "blessing_of_protection", name = "Blessing of Protection", stat = "dr", value = 70, duration = 3, damageSchool = "physical" },
      { type = "buff", key = "blessing_of_protection_pacify", name = "Blessing of Protection", stat = "dmgPct", value = -100, duration = 3, damageSchool = "physical" },
      { type = "buff", key = "paladin_forbearance", name = "Forbearance", stat = "none", value = 0, duration = 12 },
    },
  },
  shopAffinities = { PALADIN = { holy = 1, protection = 1 } },
})

ability(5085, "unyielding_faith", "Unyielding Faith", "holy", "spell_holy_unyieldingfaith", 2, {
  minRound = 3, tags = { "holy", "spell", "holy" },
  triggers = {
    {
      on = "battleStart",
      effects = { { type = "buff", key = "unyielding_faith", name = "Unyielding Faith", stat = "none", value = 0, duration = 90, controlChance = 15, controlTypes = { "fear", "incapacitate" } } },
    },
  },
  shopAffinities = { PALADIN = { holy = 1, protection = 0.5, retribution = 0.5 } },
})

ability(5086, "shadow_resistance_aura", "Shadow Resistance Aura", "shared", "spell_shadow_sealofkings", 2, {
  minRound = 3, shape = S.L, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  triggers = {
    { on = "battleStart", effects = { { type = "buff", key = "shadow_resistance_aura", name = "Shadow Resistance Aura", stat = "dr", value = 20, duration = 90, damageSchool = "shadow" } } },
  },
  shopWeight = 0.5,
})

ability(5087, "frost_resistance_aura", "Frost Resistance Aura", "shared", "spell_frost_wizardmark", 2, {
  minRound = 3, shape = { "111" }, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  triggers = { { on = "battleStart", effects = { { type = "buff", key = "frost_resistance_aura", name = "Frost Resistance Aura", stat = "dr", value = 20, duration = 90, damageSchool = "frost" } } } },
  shopWeight = 0.5,
})

ability(5088, "fire_resistance_aura", "Fire Resistance Aura", "shared", "spell_fire_sealoffire", 2, {
  minRound = 3, shape = S.L, tags = { "shared", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  triggers = { { on = "battleStart", effects = { { type = "buff", key = "fire_resistance_aura", name = "Fire Resistance Aura", stat = "dr", value = 20, duration = 90, damageSchool = "fire" } } } },
  shopWeight = 0.5,
})



ability(5089, "judgement_of_the_crusader", "Judgement of the Crusader", "shared", "spell_holy_holysmite", 2, {
  shape = { "101", "010" }, tags = { "judgement", "holy", "spell", "maintained_judgement", "paladin_holy_attack" },
  exclusiveGroup = "paladin_judgement", exclusiveLabel = "Judgement",
  use = {
    cost = 8, cd = 8, initialDelay = 0, resource = "mana", condition = "buffNeeds:judgement_of_the_crusader:0.1",
    effects = { { type = "buff", key = "judgement_of_the_crusader", name = "Judgement of the Crusader", stat = "dmgPct", value = 20, duration = 8, damageSchool = "holy" } },
  },
  shopAffinities = { PALADIN = { holy = 1, protection = 1, retribution = 0.75 } },
})

ability(5090, "judgement_of_command", "Judgement of Command", "retribution", "ability_warrior_innerrage", 2, {
  shape = { "100", "010", "001" }, tags = { "judgement", "holy", "spell", "paladin_holy_attack" }, exclusiveGroup = "paladin_judgement",
  exclusiveLabel = "Judgement",
  use = {
    cost = 12, cd = 8, initialDelay = 0, resource = "mana",
    effects = { { type = "damage", coef = 1, min = 2, max = 4, school = "holy", multIf = { condition = "enemyControlled:stun,incapacitate", mult = 2 }, noDodge = true } },
    prefer = { condition = "enemyControlled:stun,incapacitate", wait = 2 },
  },
  shopAffinities = { PALADIN = { holy = 0.75, protection = 0.75, retribution = 1 } },
})

ability(5091, "purify", "Purify", "shared", "spell_holy_purify", 1, {
  cost = 1, shape = S.one, tags = { "holy", "spell", "cleanse" },
  use = { cost = 4, cd = 6, initialDelay = 0, resource = "mana", condition = "hasHarmful", effects = { { type = "cleanse", count = 1, debuffs = true } } },
  noShop = true, rankable = false, shopClasses = {},
})

ability(5160, "concentration_aura", "Concentration Aura", "holy", "spell_holy_mindsooth", 1, {
  tags = { "holy", "spell", "holy" }, exclusiveGroup = "paladin_aura", exclusiveLabel = "Aura",
  use = {
    cost = 10, cd = 18, initialDelay = 0, resource = "mana",
    effects = { { type = "buff", key = "concentration_aura", name = "Concentration Aura", stat = "none", value = 0, duration = 8 } },
  },
  triggers = { { on = "damaged", condition = "buff:concentration_aura", icd = 1, effects = { { type = "cdr", target = "all", match = { tag = "spell" }, amount = 0.3, clampReady = true } } } },
})

ability(5161, "divine_protection", "Divine Protection", "protection", "spell_holy_restoration", 2, {
  tags = { "protection", "spell", "holy" },
  use = {
    cost = 12, cd = 18, initialDelay = 0, reactive = true, resource = "mana", condition = { "below50", "notBuff:paladin_forbearance" },
    effects = {
      { type = "buff", key = "divine_protection", name = "Divine Protection", stat = "dr", value = 45, duration = 3 },
      { type = "buff", key = "divine_protection_melee", name = "Divine Protection", target = "all", match = { tag = "melee" }, stat = "dmgPct", value = -50, duration = 3 },
      { type = "buff", key = "paladin_forbearance", name = "Forbearance", stat = "none", value = 0, duration = 12 },
    },
  },
})
