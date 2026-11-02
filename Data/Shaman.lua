local ADDON, ns = ...
local H = ns.H
local S = H.S
local SHAMAN = { "SHAMAN" }

local ability, passive = H.SchoolAbilities(SHAMAN, "nature")
local function totem(id, key, name, spec, element, icon, quality, use, extra)
  return ability(id, key, name, spec, icon, quality, use, H.Merge({ exclusiveGroup = "shaman_" .. element .. "_totem", exclusiveLabel = element:sub(1, 1):upper() .. element:sub(2) .. " Totem",
    tags = { spec, "totem", element == "fire" and "fire" or "nature" }, shape = S.v2 }, extra))
end
local function imbue(id, key, name, icon, quality, triggers, extra)
  return passive(id, key, name, "enhancement", icon, quality, triggers, H.Merge({ exclusiveGroup = "shaman_imbue", exclusiveLabel = "Weapon Imbue", tags = { "enhancement", "imbue" } }, extra))
end

ability(7000, "lightning_bolt", "Lightning Bolt", "elemental", "spell_nature_lightning", 1,
  { cd = 3.5, cost = 10, resource = "mana", effects = { { type = "damage", min = 9, max = 13, coef = 0.5, school = "nature", spendBank = "shaman_lightning", bankLabel = "stored lightning", noDodge = true } } },
  { cost = 3, triggers = { { on = "dotTick", match = { tag = "fire" }, effects = { { type = "bank", key = "shaman_lightning", fraction = 0.3 } } } } })
ability(7001, "earth_shock", "Earth Shock", "elemental", "spell_nature_earthshock", 1,
  { cd = 7, cost = 13, resource = "mana", effects = { { type = "damage", min = 10, max = 16, coef = 0.38, school = "nature", noDodge = true }, { type = "purge", count = 1 } } },
  { tags = { "elemental", "spell", "nature", "shock" } })
ability(7002, "flame_shock", "Flame Shock", "elemental", "spell_fire_flameshock", 1,
  { cd = 12, cost = 12, resource = "mana", effects = {
    { type = "damage", min = 4, max = 6, coef = 0.15, school = "fire", noDodge = true },
    { type = "dot", key = "flame_shock", school = "fire", tick = 3, coef = 0.1, duration = 12, preserveTicks = true },
  } }, { tags = { "elemental", "spell", "fire", "shock", "dot" } })
ability(7003, "frost_shock", "Frost Shock", "elemental", "spell_frost_frostshock", 2,
  { cd = 8, cost = 12, resource = "mana", effects = {
    { type = "damage", min = 7, max = 11, coef = 0.32, school = "frost", noDodge = true },
    { type = "debuff", stat = "haste", value = 18, duration = 4, key = "frost_shock", name = "Frost Shock", rankScale = false },
  } }, { minRound = 2, tags = { "elemental", "spell", "frost", "shock" } })
ability(7004, "chain_lightning", "Chain Lightning", "elemental", "spell_nature_chainlightning", 3,
  { cd = 8, cost = 24, resource = "mana", effects = {
    { type = "damage", min = 15, max = 21, coef = 0.55, school = "nature", spendBank = "shaman_lightning", bankLabel = "stored lightning", noDodge = true },
    { type = "damage", min = 5, max = 8, coef = 0.18, school = "nature", cond = "enemyHas:flame_shock", noDodge = true },
  } }, { minRound = 3, shape = S.L })
passive(7005, "elemental_focus", "Elemental Focus", "elemental", "spell_shadow_manaburn", 2, {
  { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "buff", stat = "none", value = 0, free = true, match = { tag = "spell" }, charges = 1, duration = 10, key = "shaman_clearcasting", name = "Elemental Focus" } } },
}, { minRound = 2 })
passive(7006, "elemental_fury", "Elemental Fury", "elemental", "spell_fire_volcano", 5, {},
  { minRound = 9, adjacency = { { match = { tag = "spell" }, mods = { dmgPct = 15, crit = 5 } } }, stats = { critDamage = 15 } })
passive(7007, "convection", "Convection", "elemental", "spell_nature_wispsplode", 1, {},
  { shape = S.one, adjacency = { { match = { tag = "elemental" }, mods = { costPct = -15 } } } })
passive(7008, "concussion", "Concussion", "elemental", "spell_fire_fireball", 1, {}, { stats = { sp = 18 }, shape = S.one })
passive(7009, "call_of_flame", "Call of Flame", "elemental", "spell_fire_immolation", 2, {
  { on = "anyUse", match = { tag = "shock" }, effects = { { type = "tickDots", match = { tag = "fire" } } } },
}, { minRound = 2, adjacency = { { match = { tag = "totem" }, mods = { dmgPct = 10 } } } })
passive(7010, "reverberation", "Reverberation", "elemental", "spell_frost_frostward", 2, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "cdr", target = "all", match = { tag = "shock" }, amount = 0.5 } } },
}, { minRound = 3 })
passive(7011, "lightning_mastery", "Lightning Mastery", "elemental", "spell_lightning_lightningbolt01", 4, {
  { on = "resourceSpent", resource = "mana", everyAmount = 30, effects = { { type = "cdr", target = "all", match = { key = "lightning_bolt" }, amount = 1 }, { type = "cdr", target = "all", match = { key = "chain_lightning" }, amount = 1 } } },
}, { minRound = 6 })
ability(7012, "elemental_mastery", "Elemental Mastery", "elemental", "spell_nature_wispheal", 4,
  { cd = 24, cost = 12, resource = "mana", effects = {
    { type = "buff", target = "all", match = { tag = "elemental", damaging = "direct" }, stat = "crit", value = 100, charges = 1, duration = 10, key = "elemental_mastery", name = "Elemental Mastery", rankScale = false },
    { type = "buff", stat = "none", value = 0, free = true, match = { tag = "elemental", damaging = "direct" }, duration = 10, key = "elemental_mastery_free", name = "Elemental Mastery", rankScale = false },
  } }, { minRound = 7, rankable = false })
passive(7013, "elemental_devastation", "Elemental Devastation", "elemental", "classic_spell_fire_elementaldevastation", 3, {
  { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "buff", target = "all", match = { tag = "melee" }, stat = "crit", value = 25, duration = 6, key = "elemental_devastation", name = "Elemental Devastation" } } },
}, { minRound = 3 })

imbue(7020, "rockbiter_weapon", "Rockbiter Weapon", "spell_nature_rockbiter", 1, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "bank", key = "shaman_stormstrike", fraction = 0.25, bankTarget = "Stormstrike or shock" } } },
  { on = "resourceSpent", resource = "mana", match = { tag = "shock" }, effects = { { type = "damage", school = "nature", spendBank = "shaman_stormstrike", bankLabel = "stored weapon damage", noDodge = true, noOwnTriggers = true } } },
}, { stats = { ap = 14 } })
imbue(7021, "flametongue_weapon", "Flametongue Weapon", "spell_fire_flametounge", 1, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "damage", min = 2, max = 3, coef = 0.15, school = "fire", fromEvent = 0.25, noDodge = true, noOwnTriggers = true } } },
}, { tags = { "enhancement", "imbue", "fire" } })
imbue(7022, "frostbrand_weapon", "Frostbrand Weapon", "spell_frost_frostbrand", 2, {
  { on = "regularHit", match = { tag = "melee" }, chance = 30, effects = {
    { type = "damage", min = 5, max = 8, coef = 0.2, school = "frost", noDodge = true, noOwnTriggers = true },
    { type = "debuff", stat = "haste", value = 20, duration = 5, key = "frostbrand", name = "Frostbrand Weapon" },
  } },
}, { minRound = 2 })
imbue(7023, "windfury_weapon", "Windfury Weapon", "spell_nature_cyclone", 3, {
  { on = "regularHit", match = { tag = "melee" }, chance = 20, effects = { { type = "extraAttack", count = 2 } } },
  { on = "extraHit", match = { kind = "weapon", tag = "melee", anyTag = { "autoattack" } }, chance = 5, effects = { { type = "extraAttack", count = 2 } } },
}, { minRound = 3, stats = { ap = 10 } })
ability(7024, "stormstrike", "Stormstrike", "enhancement", "spell_holy_sealofmight", 3,
  { cd = 9, cost = 18, resource = "mana", requires = "melee", effects = {
    { type = "damage", weapon = true, weaponPct = 1.25, min = 5, max = 8, coef = 0.6, school = "physical", spendBank = "shaman_stormstrike", bankLabel = "stored weapon damage" },
    { type = "buff", target = "all", match = { tag = "nature", damaging = "direct" }, stat = "dmgPct", value = 25, charges = 2, duration = 8, key = "stormstrike_nature", name = "Stormstrike", rankScale = false },
  } }, { minRound = 3, tags = { "enhancement", "melee", "strike" }, shape = S.L, triggers = {
    { on = "anyHit", match = { kind = "weapon", tag = "melee", anyTag = { "autoattack" } }, effects = { { type = "bank", key = "shaman_stormstrike", fraction = 0.2 } } },
  } })
ability(7025, "lightning_shield", "Lightning Shield", "enhancement", "spell_nature_lightningshield", 1,
  { cd = 12, initialDelay = 0, cost = 12, resource = "mana", effects = { { type = "buff", stat = "none", value = 0, duration = 12, key = "lightning_shield", name = "Lightning Shield" } } },
  { rankTriggers = true, triggers = {
    { on = "damaged", condition = "buff:lightning_shield", icd = 1.5, effects = { { type = "damage", min = 3, max = 5, coef = 0.2, school = "nature", spendBank = "shaman_tidal", bankLabel = "stored healing", noDodge = true, noCrit = true } } },
    { on = "healed", effects = { { type = "bank", key = "shaman_tidal", fraction = 0.25 } } },
    { on = "resourceSpent", resource = "mana", match = { tag = "spell", anyTag = { "nature", "shock" }, damaging = "direct" }, effects = {
      { type = "debuff", stat = "none", value = 0, stack = true, uncapped = true, stacksFromEvent = 0.75, key = "shaman_lightning_charge", name = "Lightning Charge", duration = 12, rankScale = false },
    } },
    { on = "regularHit", match = { tag = "melee" }, effects = {
      { type = "damage", school = "nature", consumeDebuff = "shaman_lightning_charge", perDebuffStack = 1, noCrit = true, noDodge = true, noOwnTriggers = true, rankScale = false },
    } },
  } })
passive(7026, "shaman_flurry", "Flurry", "enhancement", "ability_ghoulfrenzy", 2, {
  { on = "anyCrit", healing = false, match = { tag = "melee" }, effects = { { type = "buff", target = "all", match = { tag = "melee" }, stat = "haste", value = 25, charges = 3, duration = 7, key = "shaman_flurry", name = "Flurry" } } },
}, { minRound = 2, stats = { crit = 3 } })
passive(7027, "thundering_strikes", "Thundering Strikes", "enhancement", "ability_thunderbolt", 1, {},
  { shape = S.one, adjacency = { { match = { tag = "melee" }, mods = { crit = 10 } } } })
passive(7028, "elemental_weapons", "Elemental Weapons", "enhancement", "spell_fire_flametounge", 4, {
  { on = "regularHit", match = { tag = "melee" }, effects = { { type = "bank", key = "shaman_stormstrike", fraction = 0.15 } } },
}, { minRound = 6, stats = { ap = 10, sp = 8 } })
passive(7029, "improved_lightning_shield", "Improved Lightning Shield", "enhancement", "spell_nature_lightningshield", 2, {
  { on = "anyHit", match = { key = "lightning_shield" }, effects = { { type = "resource", resource = "mana", fromEvent = 0.25 } } },
}, { shopRequires = { "lightning_shield" }, minRound = 3 })
passive(7030, "shaman_weapon_mastery", "Weapon Mastery", "enhancement", "ability_hunter_swiftstrike", 5, {},
  { minRound = 9, stats = { ap = 28 }, adjacency = { { match = { tag = "melee" }, mods = { dmgPct = 12 } } } })
passive(7031, "shaman_toughness", "Toughness", "enhancement", "spell_holy_devotion", 1, {}, { stats = { armor = 24 }, shape = S.one })
passive(7032, "anticipation_shaman", "Anticipation", "enhancement", "spell_nature_mirrorimage", 1, {}, { stats = { dodge = 5 }, shape = S.one, shopClasses = {} })

ability(7040, "healing_wave", "Healing Wave", "restoration", "spell_nature_magicimmunity", 1,
  { cd = 5, cost = 20, resource = "mana", condition = "injured", effects = { { type = "heal", min = 18, max = 26, coef = 0.75 }, { type = "tickHots", match = { tag = "totem" } } } },
  { tags = { "restoration", "spell", "nature", "heal" } })
ability(7041, "lesser_healing_wave", "Lesser Healing Wave", "restoration", "spell_nature_healingwavelesser", 1,
  { cd = 2.8, cost = 11, resource = "mana", condition = "injured", effects = { { type = "heal", min = 8, max = 13, coef = 0.4 } } },
  { tags = { "restoration", "spell", "nature", "heal" }, shape = S.one })
ability(7042, "chain_heal", "Chain Heal", "restoration", "spell_nature_healingwavegreater", 3,
  { cd = 7, cost = 22, resource = "mana", condition = "injured", effects = {
    { type = "heal", min = 14, max = 20, coef = 0.55 },
    { type = "heal", min = 7, max = 10, coef = 0.25 },
    { type = "tickHots", match = { tag = "totem" } },
  } }, { minRound = 3, tags = { "restoration", "spell", "nature", "heal" }, shape = S.L })
passive(7043, "ancestral_healing", "Ancestral Healing", "restoration", "spell_nature_undyingstrength", 2, {
  { on = "anyCrit", healing = true, effects = { { type = "buff", stat = "armor", value = 24, duration = 8, key = "ancestral_healing", name = "Ancestral Healing" }, { type = "absorb", fromEvent = 0.2 } } },
}, { minRound = 2 })
passive(7044, "healing_way", "Healing Way", "restoration", "classic_spell_nature_healingway", 2, {
  { on = "anyUse", match = { key = "healing_wave" }, effects = { { type = "buff", stat = "healPct", value = 10, stack = true, maxStacks = 3, duration = 12, key = "healing_way", name = "Healing Way" } } },
}, { minRound = 2, shopRequires = { "healing_wave" } })
passive(7045, "tidal_focus", "Tidal Focus", "restoration", "spell_frost_manarecharge", 1, {},
  { shape = S.one, adjacency = { { match = { tag = "heal" }, mods = { costPct = -15 } } } })
passive(7046, "tidal_mastery", "Tidal Mastery", "restoration", "spell_nature_tranquility", 2, {}, { stats = { crit = 6, healing = 8 }, minRound = 2, shape = S.one })
passive(7047, "purification", "Purification", "restoration", "spell_frost_wizardmark", 3, {}, { stats = { healing = 30 }, minRound = 4, shape = S.one, shopClasses = {} })
passive(7048, "restorative_totems", "Restorative Totems", "restoration", "spell_nature_manaregentotem", 2, {
  { on = "hotTick", match = { tag = "totem" }, effects = { { type = "resource", resource = "mana", amount = 2 } } },
}, { minRound = 3, adjacency = { { match = { tag = "totem" }, mods = { healPct = 20 } } } })
ability(7049, "natures_swiftness_shaman", "Nature's Swiftness", "restoration", "spell_nature_ravenform", 4,
  { cd = 24, cost = 10, resource = "mana", condition = "below50", effects = {
    { type = "cdr", target = "all", match = { tag = "heal" }, amount = 5, clampReady = true },
    { type = "buff", stat = "none", value = 0, free = true, match = { tag = "heal" }, duration = 8, key = "shaman_swiftness", name = "Nature's Swiftness", rankScale = false },
  } }, { minRound = 6, rankable = false })
passive(7050, "healing_grace", "Healing Grace", "restoration", "spell_nature_healingtouch", 2, {
  { on = "healed", everyAmount = 25, effects = { { type = "cdr", target = "neighbors", match = { tag = "totem" }, amount = 0.8 } } },
}, { minRound = 3, stats = { healing = 6 } })
passive(7051, "healing_focus_shaman", "Healing Focus", "restoration", "spell_nature_healingwavelesser", 3, {
  { on = "damaged", everyAmount = 40, effects = { { type = "cdr", target = "all", match = { tag = "heal" }, amount = 1, clampReady = true } } },
}, { minRound = 4, stats = { healing = 8 } })
passive(7052, "totemic_mastery", "Totemic Mastery", "restoration", "spell_nature_nullward", 5, {
  { on = "hotTick", match = { tag = "totem" }, every = 4, effects = {
    { type = "heal", pctMax = 0.02 },
    { type = "cdr", target = "all", match = { tag = "totem" }, amount = 0.5, clampReady = true },
  } },
}, { minRound = 9, shopRequires = { "healing_stream_totem" }, stats = { healing = 14 } })

local fire = { "elemental", "spell", "totem", "fire" }
totem(7060, "searing_totem", "Searing Totem", "elemental", "fire", "spell_fire_searingtotem", 1,
  { cd = 2.5, cost = 3, resource = "mana", effects = { { type = "damage", min = 3, max = 5, coef = 0.17, school = "fire", noDodge = true } } }, { tags = fire })
totem(7061, "magma_totem", "Magma Totem", "elemental", "fire", "spell_fire_selfdestruct", 2,
  { cd = 10, cost = 16, resource = "mana", effects = { { type = "dot", key = "magma_totem", school = "fire", tick = 4, coef = 0.13, duration = 8 } } },
  { minRound = 3, tags = { "elemental", "spell", "totem", "fire", "dot" } })
totem(7062, "fire_nova_totem", "Fire Nova Totem", "elemental", "fire", "spell_fire_sealoffire", 3,
  { cd = 11, cost = 20, resource = "mana", effects = { { type = "damage", min = 16, max = 22, coef = 0.5, school = "fire", consumeDots = { match = { tag = "fire" }, fraction = 0.35 }, noDodge = true } } },
  { minRound = 4, shape = S.L, tags = fire })
totem(7063, "strength_of_earth_totem", "Strength of Earth Totem", "enhancement", "earth", "spell_nature_earthbindtotem", 1, nil,
  { stats = { ap = 18 }, shape = S.one, passiveTriggers = true, shopClasses = {} })
totem(7064, "stoneskin_totem", "Stoneskin Totem", "enhancement", "earth", "spell_nature_stoneskintotem", 1, nil,
  { stats = { armor = 24, block = 4 }, shape = S.one, passiveTriggers = true, shopClasses = {} })
totem(7065, "earthbind_totem", "Earthbind Totem", "enhancement", "earth", "spell_nature_strengthofearthtotem02", 2,
  { cd = 12, cost = 8, resource = "mana", effects = { { type = "debuff", stat = "haste", value = 20, duration = 7, key = "earthbind", name = "Earthbind Totem", rankScale = false } } }, { minRound = 2, rankable = false })
totem(7066, "stoneclaw_totem", "Stoneclaw Totem", "enhancement", "earth", "spell_nature_stoneclawtotem", 2,
  { cd = 12, cost = 12, resource = "mana", condition = "noAbsorb", effects = { { type = "absorb", amount = 18, coef = 0.35 } } }, { minRound = 3 })
totem(7067, "windfury_totem", "Windfury Totem", "enhancement", "air", "spell_nature_windfury", 4, nil,
  { minRound = 6, triggers = { { on = "regularHit", match = { tag = "melee" }, chance = 12, effects = { { type = "extraAttack", count = 1 } } } } })
totem(7068, "grace_of_air_totem", "Grace of Air Totem", "enhancement", "air", "spell_nature_invisibilitytotem", 2, nil,
  { minRound = 3, passiveTriggers = true, stats = { crit = 5, dodge = 4 }, shape = S.one, shopClasses = {} })
totem(7069, "grounding_totem", "Grounding Totem", "enhancement", "air", "spell_nature_groundingtotem", 3, nil,
  { minRound = 4, triggers = { { on = "damaged", matchAttacker = { tag = "spell" }, icd = 7, effects = { { type = "absorb", fromEvent = 0.65, amount = 8, coef = 0.2 } } } } })
totem(7070, "healing_stream_totem", "Healing Stream Totem", "restoration", "water", "inv_spear_04", 1,
  { cd = 10, cost = 10, resource = "mana", effects = { { type = "hot", key = "healing_stream_totem", tick = 3, coef = 0.12, duration = 10, preserveTicks = true } } },
  { tags = { "restoration", "nature", "totem", "heal" } })
totem(7071, "mana_spring_totem", "Mana Spring Totem", "restoration", "water", "spell_nature_manaregentotem", 1,
  { cd = 4, cost = 0, resource = "mana", effects = { { type = "resource", resource = "mana", amount = 6 } } }, { shape = S.one, rankable = false })
totem(7072, "mana_tide_totem", "Mana Tide Totem", "restoration", "water", "spell_frost_summonwaterelemental", 4,
  { cd = 20, cost = 0, resource = "mana", condition = "lowMana", effects = { { type = "resource", resource = "mana", amount = 45 } } },
  { minRound = 7, rankable = false })
ability(7073, "purge", "Purge", "shared", "spell_nature_purge", 2,
  { cd = 10, cost = 8, resource = "mana", effects = { { type = "purge", count = 2 } } }, { minRound = 2, shape = S.one, rankable = false })
ability(7074, "cure_poison_shaman", "Cure Poison", "shared", "spell_nature_nullifypoison", 1,
  { cd = 9, cost = 8, resource = "mana", condition = "hasDot", effects = { { type = "cleanse", count = 1 } } }, { shape = S.one, rankable = false })
passive(7075, "ancestral_knowledge", "Ancestral Knowledge", "enhancement", "spell_shadow_grimward", 1, {}, { stats = { mana = 30 }, shape = S.one, shopClasses = {} })

totem(7160, "strength_of_earth_totem_active", "Strength of Earth Totem", "enhancement", "earth", "spell_nature_earthbindtotem", 1,
  { cd = 12, initialDelay = 0, cost = 8, resource = "mana", effects = {
    { type = "buff", stat = "ap", value = 30, duration = 8, key = "strength_of_earth_active", name = "Strength of Earth Totem" },
  } }, { rankable = false })
totem(7161, "stoneskin_totem_active", "Stoneskin Totem", "enhancement", "earth", "spell_nature_stoneskintotem", 1,
  { cd = 14, initialDelay = 0, cost = 8, resource = "mana", effects = {
    { type = "buff", stat = "dr", value = 20, damageSchool = "physical", duration = 8, key = "stoneskin_active", name = "Stoneskin Totem" },
  } }, { rankable = false })
totem(7162, "grace_of_air_totem_active", "Grace of Air Totem", "enhancement", "air", "spell_nature_invisibilitytotem", 2,
  { cd = 14, initialDelay = 0, cost = 10, resource = "mana", effects = {
    { type = "buff", stat = "crit", value = 10, duration = 8, key = "grace_of_air_crit", name = "Grace of Air Totem" },
    { type = "buff", stat = "dodge", value = 8, duration = 8, key = "grace_of_air_dodge", name = "Grace of Air Totem" },
  } }, { minRound = 3, rankable = false })
totem(7163, "windwall_totem", "Windwall Totem", "enhancement", "air", "spell_nature_earthbind", 1,
  { cd = 16, initialDelay = 0, cost = 8, resource = "mana", effects = {
    { type = "buff", stat = "dr", value = 25, damageSchool = "physical", rangedOnly = true, duration = 8, key = "windwall_totem", name = "Windwall Totem" },
  } }, { rankable = false })
totem(7164, "frost_resistance_totem", "Frost Resistance Totem", "enhancement", "fire", "spell_frostresistancetotem_01", 1,
  { cd = 16, initialDelay = 0, cost = 8, resource = "mana", effects = {
    { type = "buff", stat = "dr", value = 25, damageSchool = "frost", duration = 8, key = "frost_resistance_totem", name = "Frost Resistance Totem" },
  } }, { rankable = false, tags = { "enhancement", "totem", "frost" } })
totem(7165, "tremor_totem", "Tremor Totem", "restoration", "earth", "spell_nature_tremortotem", 3,
  { cd = 18, initialDelay = 0, cost = 10, resource = "mana", effects = {
    { type = "buff", stat = "none", value = 0, duration = 10, key = "tremor_totem", name = "Tremor Totem" },
  } }, { minRound = 4, rankable = false, triggers = {
    { on = "stunned", controlTypes = { "fear", "charm", "sleep" }, condition = "buff:tremor_totem", effects = { { type = "clearControl", types = { "fear", "charm", "sleep" } } } },
  } })
