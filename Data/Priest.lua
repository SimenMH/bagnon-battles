local ADDON, ns = ...
local H = ns.H
local S = H.S
local PRIEST = { "PRIEST" }

local ability = H.RoundAbilities(PRIEST)

ability(6000, "smite", "Smite", "holy", "Spell_Holy_HolySmite", 1, 1, {
  tags = { "holy", "spell" },
  use = { cd = 3, cost = 12, resource = "mana", effects = { { type = "damage", min = 8, max = 12, coef = 0.4, school = "holy", spendBank = "discipline_aegis", bankLabel = "stored absorbed damage" } } } })
ability(6001, "power_word_shield", "Power Word: Shield", "discipline", "Spell_Holy_PowerWordShield", 1, 1, {
  tags = { "discipline", "spell", "defensive" },
  use = { cd = 9, initialDelay = 1, cost = 16, resource = "mana", effects = { { type = "absorb", amount = 18, coef = 0.5 } } },
  triggers = { { on = "absorbed", effects = { { type = "bank", key = "discipline_aegis", fraction = 0.35, cap = { flat = 35, healing = 0.7 } } } } } })
ability(6002, "power_word_fortitude", "Power Word: Fortitude", "discipline", "Spell_Holy_WordFortitude", 1, 1, { stats = { hp = 20, hpPct = 8 } })
ability(6003, "inner_fire", "Inner Fire", "discipline", "Spell_Holy_InnerFire", 1, 1, { stats = { armor = 24, ap = 8 },
  triggers = { { on = "regularHit", match = { tag = "melee" }, effects = { { type = "resource", resource = "mana", amount = 2 } } } } })
ability(6004, "inner_focus", "Inner Focus", "discipline", "Spell_Frost_WindWalkOn", 3, 4, {
  use = { cd = 20, initialDelay = 1, effects = { { type = "buff", stat = "none", value = 0, free = true, match = { tag = "spell" }, charges = 1, duration = 8, key = "priest_inner_focus_free", name = "Inner Focus" }, { type = "buff", target = "all", match = { tag = "spell" }, stat = "crit", value = 25, charges = 1, duration = 8, key = "priest_inner_focus_crit", name = "Inner Focus" } } } })
ability(6005, "meditation", "Meditation", "discipline", "Spell_Nature_Sleep", 2, 2, {
  triggers = { { on = "absorbed", effects = { { type = "resource", resource = "mana", fromEvent = 0.18 } } } } })
ability(6006, "mental_agility", "Mental Agility", "discipline", "Ability_Hibernation", 2, 3, {
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "absorb", amount = 8, coef = 0.12 } } } } })
ability(6007, "mental_strength", "Mental Strength", "discipline", "Spell_Nature_EnchantArmor", 2, 2, { stats = { mana = 40, regen = 1 }, shopClasses = {} })
ability(6008, "divine_spirit", "Divine Spirit", "discipline", "Spell_Holy_DivineSpirit", 3, 4, {
  stats = { healing = 14, regen = 1 },
  triggers = { { on = "hotTick", everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 5 } } } } })
ability(6009, "power_infusion", "Power Infusion", "discipline", "Spell_Holy_PowerInfusion", 5, 9, {
  shape = S.L, use = { cd = 24, cost = 20, resource = "mana", effects = { { type = "buff", stat = "spellPct", value = 30, duration = 8, key = "power_infusion_damage", name = "Power Infusion" }, { type = "buff", stat = "healPct", value = 30, duration = 8, key = "power_infusion_heal", name = "Power Infusion" } } } })
ability(6010, "improved_power_word_shield", "Improved Power Word: Shield", "discipline", "Spell_Holy_PowerWordShield", 2, 2, {
  shopRequires = { "power_word_shield" },
  triggers = { { on = "anyUse", match = { key = "power_word_shield" }, effects = { { type = "absorb", amount = 8, coef = 0.2 } } } } })
ability(6011, "improved_inner_fire", "Improved Inner Fire", "discipline", "Spell_Holy_InnerFire", 2, 3, {
  shopRequires = { "inner_fire" }, stats = { armor = 16 },
  triggers = { { on = "armorPrevented", everyAmount = 25, effects = { { type = "absorb", amount = 6, coef = 0.08 } } } } })
ability(6012, "force_of_will", "Force of Will", "discipline", "Spell_Nature_SlowingTotem", 4, 7, {
  adjacency = { { match = { tag = "spell", damaging = true }, mods = { crit = 8, dmgPct = 12 } } },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "cdr", target = "all", match = { key = "power_word_shield" }, amount = 0.75, clampReady = true } } } } })
ability(6013, "lesser_heal", "Lesser Heal", "holy", "Spell_Holy_LesserHeal", 1, 1, {
  tags = { "holy", "spell", "heal" },
  use = { cd = 4, cost = 12, resource = "mana", condition = "injured", effects = { { type = "heal", min = 10, max = 16, coef = 0.6 } } } })
ability(6014, "renew", "Renew", "holy", "Spell_Holy_Renew", 1, 1, {
  tags = { "holy", "spell", "heal", "hot" },
  use = { cd = 12, initialDelay = 1, cost = 15, resource = "mana", effects = { { type = "hot", key = "renew", tick = 3, coef = 0.07, duration = 12 } } },
  triggers = { { on = "healed", effects = { { type = "bank", key = "holy_grace", fraction = 0.2, cap = { flat = 30, healing = 0.7 } } } } } })
ability(6015, "heal_priest", "Heal", "holy", "Spell_Holy_Heal", 2, 2, {
  tags = { "holy", "spell", "heal" },
  use = { cd = 6, cost = 20, resource = "mana", condition = "injured", effects = { { type = "heal", min = 20, max = 28, coef = 0.8 }, { type = "tickHots" } } } })
ability(6016, "flash_heal", "Flash Heal", "holy", "Spell_Holy_FlashHeal", 2, 3, {
  tags = { "holy", "spell", "heal" },
  use = { cd = 3, cost = 22, resource = "mana", condition = "below50", effects = { { type = "heal", min = 15, max = 22, coef = 0.55 } } } })
ability(6017, "greater_heal", "Greater Heal", "holy", "Spell_Holy_GreaterHeal", 3, 4, {
  tags = { "holy", "spell", "heal" }, shape = S.L,
  use = { cd = 8, cost = 30, resource = "mana", condition = "below50", effects = { { type = "heal", min = 30, max = 42, coef = 1.0 }, { type = "tickHots" } } } })
ability(6018, "holy_fire", "Holy Fire", "holy", "Spell_Holy_SearingLight", 1, 1, {
  tags = { "holy", "spell", "dot" },
  use = { cd = 8, cost = 18, resource = "mana", effects = { { type = "damage", min = 10, max = 15, coef = 0.45, school = "holy", spendBank = "holy_grace", bankLabel = "stored healing" }, { type = "dot", key = "holy_fire", tick = 2, coef = 0.04, duration = 8, school = "holy" } } } })
ability(6019, "holy_nova", "Holy Nova", "holy", "Spell_Holy_HolyNova", 3, 4, {
  tags = { "holy", "spell", "heal" }, shape = S.L,
  use = { cd = 9, cost = 25, resource = "mana", effects = { { type = "damage", min = 10, max = 14, coef = 0.2, school = "holy" }, { type = "heal", min = 10, max = 14, coef = 0.3 }, { type = "tickHots" } } } })
ability(6020, "prayer_of_healing", "Prayer of Healing", "holy", "Spell_Holy_PrayerOfHealing02", 4, 7, {
  tags = { "holy", "spell", "heal" }, shape = S.sq,
  use = { cd = 14, cost = 30, resource = "mana", condition = "below50", effects = { { type = "heal", min = 24, max = 34, coef = 0.8 }, { type = "hot", key = "prayer_of_healing", tick = 2, coef = 0.05, duration = 8 } } } })
ability(6021, "spiritual_healing", "Spiritual Healing", "holy", "Spell_Nature_MoonGlow", 3, 4, {
  stats = { healing = 14 },
  triggers = { { on = "healed", everyAmount = 40, effects = { { type = "cdr", target = "all", match = { key = "holy_fire" }, amount = 1, clampReady = true } } } } })
ability(6022, "inspiration", "Inspiration", "holy", "Spell_Holy_LayOnHands", 2, 2, {
  triggers = { { on = "anyCrit", healing = true, match = { tag = "heal" }, effects = { { type = "buff", stat = "armor", value = 25, duration = 6, key = "inspiration", name = "Inspiration" }, { type = "absorb", fromEvent = 0.2 } } } } })
ability(6023, "searing_light", "Searing Light", "holy", "Spell_Holy_SearingLightPriest", 2, 2, {
  adjacency = { { match = { tag = "holy", damaging = true }, mods = { dmgPct = 20 } } },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "holy" }, effects = { { type = "tickHots" } } } } })
ability(6024, "divine_fury", "Divine Fury", "holy", "Spell_Holy_SealOfWrath", 2, 3, {
  adjacency = { { match = { tag = "holy" }, mods = { cdPct = 15 } } } })
ability(6025, "lightwell", "Lightwell", "holy", "Spell_Holy_SummonLightwell", 5, 9, {
  tags = { "holy", "spell", "heal", "hot" }, shape = S.sq,
  use = { cd = 22, cost = 28, resource = "mana", condition = "injured", effects = { { type = "hot", key = "lightwell", tick = 6, coef = 0.13, duration = 10 }, { type = "absorb", amount = 12, coef = 0.35 } } } })
ability(6026, "shadow_word_pain", "Shadow Word: Pain", "shadow", "Spell_Shadow_ShadowWordPain", 1, 1, {
  tags = { "shadow", "spell", "dot" },
  use = { cd = 12, initialDelay = 1, cost = 14, resource = "mana", effects = { { type = "dot", key = "shadow_word_pain", tick = 3, coef = 0.075, duration = 12, school = "shadow", preserveTicks = true } } } })
ability(6027, "mind_blast", "Mind Blast", "shadow", "Spell_Shadow_UnholyFrenzy", 1, 1, {
  tags = { "shadow", "spell" },
  use = { cd = 7, cost = 18, resource = "mana", effects = { { type = "damage", min = 13, max = 19, coef = 0.5, school = "shadow", consumeDots = { match = { tag = "shadow" }, fraction = 0.2 } } } } })
ability(6028, "mind_flay", "Mind Flay", "shadow", "Spell_Shadow_SiphonMana", 2, 2, {
  tags = { "shadow", "spell", "dot", "control" },
  use = { cd = 6, cost = 18, resource = "mana", effects = { { type = "dot", key = "mind_flay", tick = 5, coef = 0.12, duration = 3, school = "shadow" }, { type = "debuff", stat = "haste", value = 15, duration = 3, key = "mind_flay_slow", name = "Mind Flay" } } },
  triggers = { { on = "dotTick", match = { key = "mind_flay" }, every = 3, effects = { { type = "resource", resource = "mana", amount = 4 } } } } })
ability(6029, "vampiric_embrace", "Vampiric Embrace", "shadow", "Spell_Shadow_UnsummonBuilding", 2, 2, {
  triggers = { { on = "anyHit", match = { tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.15, noCrit = true } } }, { on = "dotTick", match = { tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.15, noCrit = true } } } } })
ability(6030, "shadow_weaving", "Shadow Weaving", "shadow", "Spell_Shadow_BlackPlague", 2, 3, {
  triggers = { { on = "dotTick", match = { tag = "shadow" }, every = 3, effects = { { type = "buff", target = "all", match = { tag = "shadow" }, stat = "dmgPct", value = 5, duration = 8, stack = true, maxStacks = 5, key = "shadow_weaving", name = "Shadow Weaving" } } } } })
ability(6031, "shadowform", "Shadowform", "shadow", "Spell_Shadow_Shadowform", 5, 9, {
  kind = "form", shape = S.sq, provides = "shadowform", stats = { dr = 12, sp = 16 },
  adjacency = { { match = { tag = "shadow" }, mods = { dmgPct = 20 } } },
  triggers = { { on = "healed", everyAmount = 30, effects = { { type = "tickDots", match = { tag = "shadow" } } } } } })
ability(6032, "spirit_tap", "Spirit Tap", "shadow", "Spell_Shadow_Requiem", 1, 1, {
  triggers = { { on = "dotTick", match = { tag = "shadow" }, everyAmount = 30, effects = { { type = "resource", resource = "mana", amount = 5 } } } } })
ability(6033, "darkness", "Darkness", "shadow", "Spell_Shadow_Twilight", 1, 1, {
  stats = { sp = 10 }, adjacency = { { match = { tag = "shadow" }, mods = { dmgPct = 10 } } } })
ability(6034, "improved_shadow_word_pain", "Improved Shadow Word: Pain", "shadow", "Spell_Shadow_ShadowWordPain", 2, 2, {
  shopRequires = { "shadow_word_pain" },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "shadow" }, effects = { { type = "refresh", key = "shadow_word_pain" } } } } })
ability(6035, "shadow_reach", "Shadow Reach", "shadow", "Spell_Shadow_ChillTouch", 3, 4, {
  triggers = { { on = "anyUse", match = { key = "mind_blast" }, effects = { { type = "tickDots", match = { key = "shadow_word_pain" } } } } } })
ability(6036, "silence", "Silence", "shadow", "Spell_Shadow_ImpPhaseShift", 3, 4, {
  tags = { "shadow", "spell", "control" },
  use = { cd = 15, cost = 15, rankCosts = { [2] = 12, [3] = 10 }, resource = "mana", effects = { { type = "stun", duration = 1.4, rankScale = false }, { type = "cdr", target = "all", match = { key = "mind_blast" }, amount = 2, clampReady = true } } } })
ability(6037, "psychic_scream", "Psychic Scream", "shadow", "Spell_Shadow_PsychicScream", 2, 2, {
  tags = { "shadow", "spell", "control", "defensive" },
  use = { cd = 18, cost = 18, rankCosts = { [2] = 14, [3] = 12 }, resource = "mana", condition = "below50", effects = { { type = "stun", controlType = "fear", duration = 2, rankScale = false }, { type = "tickDots", match = { tag = "shadow" } } } } })
ability(6038, "dispel_magic", "Dispel Magic", "discipline", "Spell_Holy_DispelMagic", 2, 2, {
  tags = { "discipline", "spell" }, use = { cd = 12, cost = 12, resource = "mana", effects = { { type = "cleanse", count = 1, countPerRank = 1 }, { type = "purge", count = 1, countPerRank = 1 } } } })
ability(6039, "abolish_disease", "Abolish Disease", "holy", "Spell_Nature_NullifyDisease", 2, 2, {
  tags = { "holy", "spell", "defensive" },
  use = { cd = 10, cost = 12, resource = "mana", condition = "hasDot", effects = { { type = "cleanse", count = 2 }, { type = "heal", min = 4, max = 7, coef = 0.2 } } } })
ability(6040, "fade", "Fade", "shared", "Spell_Magic_LesserInvisibilty", 1, 1, {
  tags = { "defensive" }, use = { cd = 18, initialDelay = 4, effects = { { type = "buff", stat = "dodge", value = 20, duration = 4, key = "fade", name = "Fade" } } } })
ability(6041, "shackle_undead", "Shackle Undead", "shared", "Spell_Nature_Slow", 2, 3, {
  tags = { "spell", "control" }, use = { cd = 16, cost = 15, resource = "mana", effects = { { type = "stun", duration = 1.5, rankScale = false }, { type = "absorb", amount = 8, coef = 0.15 } } } })
ability(6042, "desperate_prayer", "Desperate Prayer", "holy", "Spell_Holy_Restoration", 4, 7, {
  tags = { "holy", "spell", "heal", "defensive" },
  use = { cd = 24, once = true, initialDelay = 0, condition = "below35", effects = { { type = "heal", min = 30, max = 40, coef = 0.9 } } } })
ability(6043, "wand_specialization_priest", "Wand Specialization", "discipline", "INV_Wand_01", 1, 1, {
  adjacency = { { match = { weaponType = "wand" }, mods = { dmgPct = 15 } } },
  triggers = { { on = "regularHit", match = { weaponType = "wand" }, every = 4, effects = { { type = "resource", resource = "mana", amount = 3 } } } } })
ability(6044, "martyrdom", "Martyrdom", "discipline", "Spell_Nature_Tranquility", 4, 7, {
  triggers = { { on = "damaged", everyAmount = 50, effects = { { type = "buff", stat = "none", value = 0, free = true, match = { tag = "heal" }, charges = 1, duration = 6, key = "martyrdom", name = "Martyrdom" } } } } })
ability(6045, "unbreakable_will", "Unbreakable Will", "discipline", "Spell_Magic_MageArmor", 3, 4, {
  triggers = { { on = "stunned", icd = 3, effects = { { type = "absorb", amount = 12, coef = 0.25 }, { type = "resource", resource = "mana", amount = 8 } } } } })
ability(6046, "blackout", "Blackout", "shadow", "Spell_Shadow_GatherShadows", 3, 4, {
  triggers = { { on = "anyHit", match = { kind = "ability", tag = "shadow" }, chance = 15, icd = 4, effects = { { type = "stun", duration = 0.8, rankScale = false } } } } })
ability(6047, "devouring_plague", "Devouring Plague", "shadow", "Spell_Shadow_BlackPlague", 3, 5, {
  tags = { "shadow", "spell", "dot", "heal" },
  use = { cd = 18, cost = 24, resource = "mana", effects = { { type = "dot", key = "devouring_plague", tick = 3, coef = 0.06, duration = 10, school = "shadow" } } },
  triggers = { { on = "dotTick", match = { key = "devouring_plague" }, effects = { { type = "heal", fromEvent = 1, noCrit = true } } } } })
ability(6048, "shadow_affinity", "Shadow Affinity", "shadow", "Spell_Shadow_ShadowWard", 4, 7, {
  triggers = { { on = "dotTick", match = { kind = "ability", tag = "shadow" }, everyAmount = 45, effects = { { type = "buff", stat = "dodge", value = 12, duration = 5, key = "shadow_affinity", name = "Shadow Affinity" }, { type = "cdr", target = "all", match = { key = "fade" }, amount = 2, clampReady = true } } } } })
ability(6049, "improved_vampiric_embrace", "Improved Vampiric Embrace", "shadow", "Spell_Shadow_ImprovedVampiricEmbrace", 4, 7, {
  shopRequires = { "vampiric_embrace" },
  triggers = { { on = "anyHit", match = { kind = "ability", tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.1, noCrit = true } } }, { on = "dotTick", match = { kind = "ability", tag = "shadow" }, effects = { { type = "heal", fromEvent = 0.1, noCrit = true } } } } })

ability(6060, "elunes_grace", "Elune's Grace", "discipline", "Spell_Holy_ElunesGrace", 2, 2, {
  tags = { "discipline", "spell", "defensive" },
  use = { cd = 20, cost = 12, rankCosts = { [2] = 10, [3] = 8 }, resource = "mana", condition = "below50", reactive = true,
    effects = { { type = "buff", stat = "dr", value = 25, damageSchool = "physical", rangedOnly = true, duration = 6, key = "elunes_grace_ranged", name = "Elune's Grace", rankScale = false },
      { type = "buff", stat = "dodge", value = 10, duration = 6, key = "elunes_grace_dodge", name = "Elune's Grace", rankScale = false } } } })
