local ADDON, ns = ...
local H = ns.H
local S = H.S
local PALADIN = { "PALADIN" }

local ability, passive = H.SchoolAbilities(PALADIN, "holy")
local function seal(id, key, name, spec, icon, quality, triggers, extra)
  return passive(id, key, name, spec, icon, quality, triggers, H.Merge({ kind = "form", provides = "seal", tags = { spec, "seal", "holy" }, shape = S.v2 }, extra))
end

seal(5000, "seal_of_righteousness", "Seal of Righteousness", "holy", "ability_thunderbolt", 1, {
  { on = "regularHit", match = { tag = "melee" }, effects = {
    { type = "damage", min = 2, max = 3, coef = 0.16, school = "holy", noDodge = true, noOwnTriggers = true },
    { type = "bank", key = "paladin_seal", fraction = 1 },
  } },
}, { cost = 3 })
ability(5001, "judgement", "Judgement", "retribution", "spell_holy_righteousfury", 1,
  { cd = 8, cost = 10, resource = "mana", effects = { { type = "damage", min = 12, max = 18, coef = 0.45, school = "holy", spendBank = "paladin_seal", bankLabel = "stored seal energy", noDodge = true, critIf = "enemyStunned" } } },
  { tags = { "retribution", "spell", "holy", "judgement" } })
ability(5002, "holy_light", "Holy Light", "holy", "spell_holy_holybolt", 1,
  { cd = 5, cost = 20, resource = "mana", condition = "injured", effects = { { type = "heal", min = 18, max = 26, coef = 0.75 } } },
  { tags = { "holy", "spell", "heal" }, triggers = {
    { on = "crit", healing = true, effects = { { type = "resource", resource = "mana", amount = 8 } } },
    { on = "healed", match = { key = "holy_light" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.3 } } },
  } })
ability(5003, "flash_of_light", "Flash of Light", "holy", "spell_holy_flashheal", 1,
  { cd = 2.8, cost = 9, resource = "mana", condition = "injured", effects = { { type = "heal", min = 8, max = 12, coef = 0.34 } } },
  { tags = { "holy", "spell", "heal" }, shape = S.one })
ability(5004, "consecration", "Consecration", "holy", "spell_holy_innerfire", 2,
  { cd = 10, cost = 20, resource = "mana", effects = {
    { type = "damage", min = 2, max = 3, coef = 0.12, school = "holy", spendBank = "paladin_sanctuary", bankLabel = "stored prevented damage", bankScale = 0.6, noDodge = true },
    { type = "dot", key = "consecration", school = "holy", tick = 3, coef = 0.08, duration = 8 },
  } }, { minRound = 2, shape = S.sq, tags = { "holy", "spell", "dot" } })
ability(5005, "holy_shock", "Holy Shock", "holy", "spell_holy_searinglight", 3,
  { cd = 9, cost = 18, resource = "mana", effects = {
    { type = "damage", min = 14, max = 20, coef = 0.45, school = "holy", spendBank = "paladin_holy", bankLabel = "stored healing", noDodge = true },
    { type = "heal", min = 8, max = 12, coef = 0.3, cond = "injured" },
  } }, { minRound = 3, shape = S.L, tags = { "holy", "spell", "heal" }, triggers = {
    { on = "healed", effects = { { type = "bank", key = "paladin_holy", fraction = 0.3 } } },
  } })
passive(5006, "illumination", "Illumination", "holy", "spell_holy_greaterheal", 2, {
  { on = "anyCrit", healing = true, match = { tag = "heal" }, effects = { { type = "resource", resource = "mana", amount = 10 } } },
}, { minRound = 2 })
ability(5007, "divine_favor", "Divine Favor", "holy", "spell_holy_heal", 4,
  { cd = 20, cost = 8, resource = "mana", effects = { { type = "buff", target = "all", match = { tag = "heal" }, stat = "crit", value = 100, charges = 1, duration = 12, key = "divine_favor", name = "Divine Favor", rankScale = false } } }, { minRound = 6, rankable = false })
passive(5008, "healing_light", "Healing Light", "holy", "spell_holy_holybolt", 1, {}, { stats = { healing = 18 }, shape = S.one })
passive(5009, "spiritual_focus", "Spiritual Focus", "holy", "spell_arcane_blink", 2, {
  { on = "damaged", everyAmount = 30, effects = { { type = "cdr", target = "neighbors", match = { tag = "heal" }, amount = 0.6 } } },
}, { minRound = 2, stats = { healing = 6 } })
passive(5010, "divine_intellect", "Divine Intellect", "holy", "spell_nature_sleep", 1, {}, { stats = { mana = 30 }, shape = S.one })
passive(5011, "divine_strength", "Divine Strength", "holy", "ability_golemthunderclap", 1, {}, { stats = { ap = 16 }, shape = S.one, tags = { "holy", "melee" }, shopClasses = {} })
passive(5012, "improved_seal_of_righteousness", "Improved Seal of Righteousness", "holy", "ability_thunderbolt", 2, {
  { on = "anyHit", match = { key = "seal_of_righteousness" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.6 } } },
}, { shopRequires = { "seal_of_righteousness" }, minRound = 3, stats = { sp = 8 } })
passive(5013, "lasting_judgement", "Lasting Judgement", "holy", "spell_holy_healingaura", 3, {
  { on = "anyUse", match = { key = "judgement" }, effects = { { type = "hot", key = "lasting_judgement", tick = 3, coef = 0.12, duration = 8 } } },
}, { shopRequires = { "judgement" }, minRound = 4, tags = { "holy", "heal" } })
passive(5014, "improved_blessing_of_wisdom", "Improved Blessing of Wisdom", "holy", "spell_holy_sealofwisdom", 2, {
  { on = "resourceGained", match = { key = "blessing_of_wisdom" }, resource = "mana", effects = { { type = "absorb", fromEvent = 0.75 } } },
}, { shopRequires = { "blessing_of_wisdom" }, minRound = 3 })
passive(5015, "improved_lay_on_hands", "Improved Lay on Hands", "holy", "spell_holy_layonhands", 4, {
  { on = "anyUse", match = { key = "lay_on_hands" }, effects = {
    { type = "buff", stat = "armor", value = 70, duration = 12, key = "improved_lay_on_hands", name = "Improved Lay on Hands" },
    { type = "resource", resource = "mana", amount = 15 },
  } },
}, { minRound = 7, shopRequires = { "lay_on_hands" } })
passive(5016, "holy_power", "Holy Power", "holy", "spell_holy_power", 5, {
  { on = "anyCrit", healing = true, match = { tag = "holy" }, every = 3, effects = { { type = "cast", key = "holy_shock" } } },
}, { minRound = 9, shopRequires = { "holy_shock" }, stats = { healing = 14 },
  adjacency = { { match = { tag = "holy" }, mods = { crit = 8 } } } })

ability(5020, "holy_shield", "Holy Shield", "protection", "classic_spell_holy_blessingofprotection", 3,
  { cd = 10, cost = 16, resource = "mana", requires = "shield", effects = { { type = "buff", stat = "blockChance", value = 30, duration = 7, key = "holy_shield", name = "Holy Shield", rankScale = false } } },
  { minRound = 3, rankTriggers = true, triggers = {
    { on = "block", condition = "buff:holy_shield", effects = { { type = "damage", min = 4, max = 6, coef = 0.2, school = "holy", fromEvent = 0.5, noDodge = true } } },
  } })
passive(5021, "redoubt", "Redoubt", "protection", "ability_defend", 1, {
  { on = "damaged", chance = 25, effects = { { type = "buff", stat = "blockChance", value = 20, duration = 5, key = "redoubt", name = "Redoubt" } } },
}, { stats = { block = 3 } })
passive(5022, "reckoning", "Reckoning", "protection", "spell_holy_blessingofstrength", 3, {
  { on = "damaged", chance = 25, effects = { { type = "bank", key = "paladin_reckoning_damage", fraction = 0.7 } } },
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "damage", school = "holy", spendBank = "paladin_reckoning_damage", bankLabel = "stored damage taken", noDodge = true, noOwnTriggers = true } } },
}, { minRound = 4 })
passive(5023, "blessing_of_sanctuary", "Blessing of Sanctuary", "protection", "spell_nature_lightningshield", 2, {
  { on = "block", effects = { { type = "bank", key = "paladin_sanctuary", fraction = 1 }, { type = "resource", resource = "mana", amount = 3 } } },
}, { minRound = 2, stats = { armor = 12 } })
passive(5024, "righteous_fury", "Righteous Fury", "protection", "spell_holy_sealoffury", 1, {
  { on = "armorPrevented", effects = { { type = "bank", key = "paladin_sanctuary", fraction = 0.25 } } },
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "damage", school = "holy", spendBank = "paladin_sanctuary", bankLabel = "stored prevented damage", bankScale = 0.5, noCrit = true, noDodge = true, noOwnTriggers = true } } },
}, { stats = { armor = 10 } })
passive(5025, "paladin_toughness", "Toughness", "protection", "spell_holy_devotion", 1, {}, { stats = { armor = 24 }, shape = S.one })
passive(5026, "paladin_shield_specialization", "Shield Specialization", "protection", "inv_shield_06", 2, {}, { stats = { block = 10 }, minRound = 2, shape = S.one })
passive(5027, "anticipation_paladin", "Anticipation", "protection", "spell_nature_mirrorimage", 2, {}, { stats = { dodge = 6, armor = 8 }, shape = S.one, minRound = 2, shopClasses = {} })
passive(5028, "improved_devotion_aura", "Improved Devotion Aura", "protection", "spell_holy_devotionaura", 2, {
  { on = "armorPrevented", everyAmount = 20, effects = { { type = "absorb", amount = 4, coef = 0.08 } } },
}, { shopRequires = { "devotion_aura" }, minRound = 3 })
passive(5029, "improved_righteous_fury", "Improved Righteous Fury", "protection", "spell_holy_sealoffury", 3, {
  { on = "armorPrevented", everyAmount = 25, effects = { { type = "cdr", target = "all", match = { key = "holy_shield" }, amount = 1 } } },
}, { shopRequires = { "righteous_fury" }, minRound = 4, stats = { dr = 5 } })
ability(5030, "blessing_of_kings", "Blessing of Kings", "protection", "spell_magic_magearmor", 3,
  { cd = 20, initialDelay = 0, cost = 15, resource = "mana", effects = {
    { type = "buff", stat = "ap", value = 16, duration = 20, key = "kings_ap", name = "Blessing of Kings" },
    { type = "buff", stat = "sp", value = 12, duration = 20, key = "kings_sp", name = "Blessing of Kings" },
    { type = "buff", stat = "healing", value = 12, duration = 20, key = "kings_healing", name = "Blessing of Kings" },
  } }, { minRound = 5, shape = S.one })
passive(5031, "improved_hammer_of_justice", "Improved Hammer of Justice", "protection", "spell_holy_sealofmight", 2, {
  { on = "block", effects = { { type = "cdr", target = "all", match = { key = "hammer_of_justice" }, amount = 0.8 } } },
}, { shopRequires = { "hammer_of_justice" }, minRound = 3 })
passive(5032, "precision_paladin", "Precision", "protection", "ability_rogue_ambush", 3, {},
  { minRound = 4, stats = { crit = 4 }, adjacency = { { match = { kind = "weapon", hands = 1 }, mods = { crit = 6 } } } })
passive(5033, "guardians_favor", "Guardian's Favor", "protection", "spell_holy_sealofprotection", 4, {
  { on = "block", every = 4, effects = { { type = "absorb", amount = 12, coef = 0.2 } } },
}, { minRound = 6 })
passive(5034, "improved_concentration_aura", "Improved Concentration Aura", "protection", "spell_holy_mindsooth", 4, {
  { on = "stunned", icd = 10, effects = {
    { type = "absorb", amount = 18, coef = 0.25 },
    { type = "cdr", target = "all", match = { tag = "heal" }, amount = 2, clampReady = true },
  } },
}, { minRound = 7, stats = { healing = 10 } })
passive(5035, "one_handed_weapon_specialization_paladin", "One-Handed Weapon Specialization", "protection", "inv_sword_20", 5, {
  { on = "block", effects = { { type = "bank", key = "paladin_reckoning_damage", fraction = 1 } } },
}, { minRound = 9, shopRequires = { "reckoning" }, stats = { ap = 12 },
  adjacency = { { match = { kind = "weapon", hands = 1 }, mods = { dmgPct = 25 } } } })

seal(5040, "seal_of_command", "Seal of Command", "retribution", "ability_warrior_innerrage", 2, {
  { on = "regularHit", match = { tag = "melee" }, chance = 30, effects = {
    { type = "damage", fromEvent = 0.7, coef = 0.18, school = "holy", noDodge = true, noOwnTriggers = true },
    { type = "bank", key = "paladin_seal", fraction = 3 },
  } },
}, { minRound = 2 })
seal(5041, "seal_of_the_crusader", "Seal of the Crusader", "retribution", "spell_holy_holysmite", 1, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.6 } } },
}, { stats = { haste = 12, ap = 10 } })
passive(5042, "vengeance_paladin", "Vengeance", "retribution", "ability_racial_avatar", 2, {
  { on = "anyCrit", healing = false, effects = { { type = "buff", stat = "dmgPct", value = 8, duration = 6, stack = true, maxStacks = 3, key = "paladin_vengeance", name = "Vengeance" } } },
}, { minRound = 2 })
passive(5043, "benediction", "Benediction", "retribution", "spell_frost_windwalkon", 1, {},
  { adjacency = { { match = { anyTag = { "seal", "judgement" } }, mods = { costPct = -20, dmgPct = 10 } } }, shape = S.one })
passive(5044, "improved_judgement", "Improved Judgement", "retribution", "spell_holy_righteousfury", 2, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "cdr", target = "all", match = { key = "judgement" }, amount = 0.5 } } },
}, { shopRequires = { "judgement" }, minRound = 2 })
passive(5045, "conviction", "Conviction", "retribution", "spell_holy_retributionaura", 1, {}, { stats = { crit = 6 }, shape = S.one })
passive(5046, "sanctity_aura", "Sanctity Aura", "retribution", "spell_holy_mindvision", 3, {},
  { minRound = 4, adjacency = { { match = { tag = "holy" }, mods = { dmgPct = 20 } } }, stats = { sp = 10 } })
passive(5047, "two_handed_weapon_specialization_paladin", "Two-Handed Weapon Specialization", "retribution", "inv_axe_09", 2, {
  { on = "regularHit", match = { hands = 2 }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.3 } } },
}, { minRound = 3, adjacency = { { match = { hands = 2 }, mods = { dmgPct = 15 } } }, tags = { "retribution", "melee" } })
passive(5048, "pursuit_of_justice", "Pursuit of Justice", "retribution", "spell_holy_persuitofjustice", 2, {
  { on = "enemyStunned", effects = { { type = "buff", stat = "haste", value = 25, duration = 4, key = "pursuit_of_justice", name = "Pursuit of Justice" } } },
}, { minRound = 3, stats = { dodge = 3 } })
passive(5049, "eye_for_an_eye", "Eye for an Eye", "retribution", "spell_holy_eyeforaneye", 3, {
  { on = "damaged", matchAttacker = { tag = "spell" }, effects = { { type = "damage", school = "holy", fromEvent = 0.25, noCrit = true, noDodge = true } } },
}, { minRound = 4 })
passive(5050, "improved_retribution_aura", "Improved Retribution Aura", "retribution", "spell_holy_auraoflight", 2, {
  { on = "damaged", matchAttacker = { tag = "melee" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.2 } } },
}, { shopRequires = { "retribution_aura" }, minRound = 3 })
ability(5051, "repentance", "Repentance", "retribution", "spell_holy_prayerofhealing", 4,
  { cd = 22, cost = 18, resource = "mana", effects = { { type = "stun", duration = 2.5 }, { type = "cdr", target = "all", match = { key = "judgement" }, amount = 3 } } }, { minRound = 7, rankable = false })
passive(5052, "deflection_paladin", "Deflection", "retribution", "ability_parry", 3, {
  { on = "dodged", effects = { { type = "cdr", target = "all", match = { key = "judgement" }, amount = 0.5, clampReady = true } } },
}, { minRound = 4, stats = { dodge = 5 } })
passive(5053, "vindication", "Vindication", "retribution", "spell_holy_vindication", 4, {
  { on = "regularHit", match = { tag = "melee" }, chance = 30, effects = {
    { type = "debuff", stat = "ap", value = 20, duration = 6, key = "vindication_ap", name = "Vindication" },
    { type = "debuff", stat = "sp", value = 12, duration = 6, key = "vindication_sp", name = "Vindication" },
  } },
}, { minRound = 6 })
passive(5054, "improved_seal_of_the_crusader", "Improved Seal of the Crusader", "retribution", "spell_holy_holysmite", 5, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "bank", key = "paladin_seal", fraction = 0.75 } } },
  { on = "anyUse", match = { key = "judgement" }, effects = {
    { type = "buff", target = "all", match = { tag = "holy" }, stat = "dmgPct", value = 20, duration = 6, key = "improved_crusader", name = "Improved Seal of the Crusader" },
  } },
}, { minRound = 9, shopRequires = { "seal_of_the_crusader", "judgement" } })

seal(5060, "seal_of_light", "Seal of Light", "shared", "spell_holy_healingaura", 2, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "heal", min = 3, max = 5, coef = 0.1 } } },
  { on = "healed", effects = { { type = "bank", key = "paladin_seal", fraction = 0.4 } } },
}, { minRound = 2, tags = { "seal", "holy", "heal" } })
seal(5061, "seal_of_wisdom", "Seal of Wisdom", "shared", "spell_holy_righteousnessaura", 2, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "resource", resource = "mana", amount = 4 } } },
  { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "paladin_seal", fraction = 0.4 } } },
}, { minRound = 3 })
ability(5062, "hammer_of_justice", "Hammer of Justice", "shared", "spell_holy_sealofmight", 1,
  { cd = 14, cost = 12, resource = "mana", effects = { { type = "stun", duration = 1.5 } } }, { rankable = false })
ability(5063, "hammer_of_wrath", "Hammer of Wrath", "shared", "ability_thunderclap", 3,
  { cd = 5, cost = 14, resource = "mana", condition = "enemyBelow20", effects = { { type = "damage", min = 25, max = 35, coef = 0.6, school = "holy", noDodge = true } } }, { minRound = 5 })
ability(5064, "blessing_of_might", "Blessing of Might", "shared", "spell_holy_fistofjustice", 1,
  { cd = 20, initialDelay = 0, cost = 8, resource = "mana", effects = { { type = "buff", stat = "ap", value = 18, duration = 20, key = "blessing_of_might", name = "Blessing of Might" } } }, { shape = S.one })
ability(5065, "blessing_of_wisdom", "Blessing of Wisdom", "shared", "spell_holy_sealofwisdom", 1,
  { cd = 5, cost = 0, resource = "mana", effects = { { type = "resource", resource = "mana", amount = 6 } } }, { shape = S.one, rankable = false })
passive(5066, "devotion_aura", "Devotion Aura", "shared", "spell_holy_devotionaura", 1, {}, { stats = { armor = 22 }, shape = S.one })
passive(5067, "retribution_aura", "Retribution Aura", "shared", "spell_holy_auraoflight", 1, {
  { on = "damaged", matchAttacker = { tag = "melee" }, effects = { { type = "damage", min = 2, max = 3, coef = 0.1, school = "holy", noDodge = true, noCrit = true } } },
})
ability(5068, "cleanse_paladin", "Cleanse", "shared", "spell_holy_renew", 2,
  { cd = 10, cost = 10, resource = "mana", condition = "hasDot", effects = { { type = "cleanse", count = 2 } } }, { minRound = 3, rankable = false, shape = S.one })
ability(5069, "divine_shield", "Divine Shield", "shared", "spell_holy_divineintervention", 4,
  { cd = 30, cost = 20, resource = "mana", condition = "below35", once = true, effects = { { type = "buff", stat = "dr", value = 90, duration = 5, key = "divine_shield", name = "Divine Shield", rankScale = false }, { type = "cleanse", count = 4 } } },
  { minRound = 6, rankable = false, shape = S.L })
ability(5070, "lay_on_hands", "Lay on Hands", "shared", "spell_holy_layonhands", 4,
  { cd = 40, cost = 40, resource = "mana", condition = "below35", once = true, effects = { { type = "heal", pctMax = 0.65, coef = 1.2 } } },
  { minRound = 7, rankable = false, tags = { "heal", "holy", "spell" }, shape = S.L })

ability(5160, "concentration_aura", "Concentration Aura", "holy", "spell_holy_mindsooth", 1,
  { cd = 18, initialDelay = 0, cost = 10, resource = "mana", effects = {
    { type = "buff", stat = "none", value = 0, duration = 8, key = "concentration_aura", name = "Concentration Aura" },
  } }, { rankable = false, triggers = {
    { on = "damaged", condition = "buff:concentration_aura", icd = 1, effects = { { type = "cdr", target = "all", match = { tag = "spell" }, amount = 0.4, clampReady = true } } },
  } })
ability(5161, "divine_protection", "Divine Protection", "protection", "spell_holy_restoration", 2,
  { reactive = true, cd = 18, initialDelay = 0, cost = 12, resource = "mana", condition = "below50", effects = {
    { type = "buff", stat = "dr", value = 45, duration = 3, key = "divine_protection", name = "Divine Protection" },
    { type = "buff", target = "all", match = { tag = "melee" }, stat = "dmgPct", value = -50, duration = 3, key = "divine_protection_melee", name = "Divine Protection" },
  } }, { minRound = 2, rankable = false })

for _, key in ipairs({ "devotion_aura", "retribution_aura", "sanctity_aura", "concentration_aura" }) do
  local def = ns.ItemsByKey[key]
  def.exclusiveGroup, def.exclusiveLabel = "paladin_aura", "Aura"
end
for _, key in ipairs({ "blessing_of_might", "blessing_of_wisdom", "blessing_of_sanctuary", "blessing_of_kings" }) do
  local def = ns.ItemsByKey[key]
  def.exclusiveGroup, def.exclusiveLabel = "paladin_blessing", "Blessing"
end
