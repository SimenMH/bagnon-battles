local ADDON, ns = ...
local H = ns.H
local S = H.S
local MAGE = { "MAGE" }
local ability = H.QualityAbilities(MAGE)
local damage = H.Damage
local function buff(key, stat, value, duration, match)
  return { type = "buff", key = key, stat = stat, value = value, duration = duration, target = match and "all", match = match }
end

ability(8001, "arcane_missiles", "Arcane Missiles", "arcane", "Spell_Nature_StarFall", 1, {
  use = { cd = 4, cost = 20, rankCosts = { [2] = 26, [3] = 32 }, resource = "mana", effects = { damage(2, 3, 0.13, "arcane"), damage(2, 3, 0.13, "arcane"), damage(2, 3, 0.13, "arcane") } } })
ability(8002, "arcane_explosion", "Arcane Explosion", "arcane", "Spell_Nature_WispSplode", 1, {
  use = { cd = 7, cost = 21, rankCosts = { [2] = 27, [3] = 34 }, resource = "mana", effects = { damage(7, 11, 0.32, "arcane", { spendBank = "arcane_resonance", bankLabel = "stored Mana power" }) } },
  triggers = { { on = "resourceSpent", resource = "mana", effects = { { type = "bank", key = "arcane_resonance", fraction = 0.5, cap = { flat = 50, sp = 1 } } } } } })
ability(8003, "arcane_intellect", "Arcane Intellect", "arcane", "Spell_Holy_MagicalSentry", 1, { shopClasses = {}, stats = { mana = 30, sp = 6 } })
ability(8004, "arcane_concentration", "Arcane Concentration", "arcane", "Spell_Shadow_ManaBurn", 2, {
  triggers = { { on = "anyHit", match = { kind = "ability", tag = "spell", damaging = true }, chance = 12, effects = { { type = "buff", key = "mage_clearcasting", stat = "none", value = 0, free = true, charges = 1, duration = 8, match = { kind = "ability", tag = "spell", damaging = true } } } } } })
ability(8005, "arcane_meditation", "Arcane Meditation", "arcane", "Spell_Shadow_SiphonMana", 2, { stats = { regen = 2 },
  triggers = { { on = "resourceSpent", resource = "mana", everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 8 } } } } })
ability(8006, "arcane_mind", "Arcane Mind", "arcane", "Spell_Shadow_Charm", 2, { stats = { mana = 45 },
  adjacency = { { match = { tag = "arcane" }, mods = { dmgPct = 15 } } } })
ability(8007, "counterspell", "Counterspell", "arcane", "Spell_Frost_IceShock", 2, {
  use = { cd = 14, cost = 12, resource = "mana", effects = { { type = "stun", duration = 1.2 }, { type = "drain", resource = "mana", amount = 12 } } } })
ability(8008, "evocation", "Evocation", "arcane", "Spell_Nature_Purge", 3, { tags = { "arcane", "spell", "mana_recovery" },
  use = { reactive = true, condition = "lowMana", cd = 24, effects = { { type = "resource", resource = "mana", amount = 65 } } } })
ability(8009, "magic_absorption", "Magic Absorption", "arcane", "Spell_Nature_AstralRecalGroup", 3, {
  triggers = { { on = "absorbed", effects = { { type = "resource", resource = "mana", fromEvent = 0.25 } } } } })
ability(8010, "arcane_resilience", "Arcane Resilience", "arcane", "Spell_Arcane_ArcaneResilience", 2, { shopClasses = {}, stats = { armor = 30, mana = 20 } })
ability(8011, "arcane_instability", "Arcane Instability", "arcane", "Spell_Shadow_Teleport", 4, { stats = { crit = 5 },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "spell" }, effects = { { type = "bank", key = "arcane_resonance", fraction = 0.3, cap = { flat = 50, sp = 1 } } } } } })
ability(8012, "presence_of_mind", "Presence of Mind", "arcane", "Spell_Nature_EnchantArmor", 5, {
  use = { cd = 22, cost = 18, rankCosts = { [2] = 15, [3] = 12 }, resource = "mana", effects = { { type = "cast", target = "all", match = { kind = "ability", tag = "spell", damaging = "direct" }, choose = "random" }, { type = "buff", key = "presence_of_mind", stat = "crit", value = 100, charges = 1, duration = 8, rankScale = false, target = "all", match = { kind = "ability", tag = "spell", damaging = "direct" } } } } })
ability(8013, "arcane_power", "Arcane Power", "arcane", "Spell_Nature_Lightning", 5, {
  use = { cd = 26, cost = 35, resource = "mana", effects = { buff("arcane_power", "dmgPct", 50, 8, { tag = "spell" }) } },
  triggers = { { on = "resourceSpent", resource = "mana", condition = "buff:arcane_power", effects = { { type = "bank", key = "arcane_resonance", fraction = 0.75, cap = { flat = 50, sp = 1 } } } } } })

ability(8020, "fireball", "Fireball", "fire", "Spell_Fire_FlameBolt", 1, { cost = 3, tags = { "fire", "spell", "burn" },
  use = { cd = 3.5, cost = 16, rankCosts = { [2] = 20, [3] = 25 }, resource = "mana", effects = { damage(8, 12, 0.4, "fire"), { type = "dot", key = "fireball_burn", school = "fire", tick = 1, coef = 0.04, duration = 6, preserveTicks = true } } } })
ability(8021, "fire_blast", "Fire Blast", "fire", "Spell_Fire_Fireball", 1, {
  use = { cd = 7, cost = 20, rankCosts = { [2] = 26, [3] = 32 }, resource = "mana", effects = { damage(12, 17, 0.42, "fire", { perStatus = 0.08 }) } } })
ability(8022, "scorch", "Scorch", "fire", "Spell_Fire_SoulBurn", 1, {
  use = { cd = 3, cost = 14, rankCosts = { [2] = 17, [3] = 21 }, resource = "mana", effects = { damage(6, 9, 0.3, "fire"), buff("scorch_heat", "crit", 3, 8, { tag = "fire" }) } } })
ability(8023, "ignite", "Ignite", "fire", "Spell_Fire_Incinerate", 2, { rankable = true, tags = { "fire", "spell", "burn", "dot" },
  triggers = { { on = "anyCrit", healing = false, match = { tag = "fire" }, effects = { { type = "dot", key = "ignite", school = "fire", tick = 1, rankTicks = { [2] = 1.6, [3] = 2.4 }, duration = 12, stack = true, stacksFromEvent = 0.1, fromCriticalDamage = true, uncapped = true, decayStacks = 5, preserveTicks = true } } } } })
ability(8024, "pyroblast", "Pyroblast", "fire", "Spell_Fire_Fireball02", 3, { shape = S.L,
  use = { cd = 12, cost = 26, resource = "mana", effects = { damage(30, 42, 0.9, "fire", { consumeDots = { match = { tag = "burn" }, fraction = 0.35 } }) } } })
ability(8025, "flamestrike", "Flamestrike", "fire", "Spell_Fire_SelfDestruct", 2, { tags = { "fire", "spell", "burn", "dot" }, shape = S.sq,
  use = { cd = 11, cost = 28, rankCosts = { [2] = 37, [3] = 47 }, resource = "mana", effects = { damage(10, 15, 0.35, "fire"), { type = "dot", key = "flamestrike", school = "fire", tick = 3, coef = 0.1, duration = 8 } } } })
ability(8026, "blast_wave", "Blast Wave", "fire", "Spell_Holy_Excorcism_02", 3, {
  use = { cd = 15, cost = 22, resource = "mana", effects = { damage(17, 24, 0.5, "fire"), { type = "stun", duration = 1.2 }, { type = "tickDots", match = { tag = "burn" } } } } })
ability(8027, "impact", "Impact", "fire", "Spell_Fire_MeteorStorm", 2, {
  triggers = { { on = "anyHit", match = { tag = "fire" }, chance = 12, icd = 3, effects = { { type = "stun", duration = 0.8 } } } } })
ability(8028, "improved_scorch", "Improved Scorch", "fire", "Spell_Fire_SoulBurn", 2, { shopRequires = { "scorch" },
  triggers = { { on = "anyUse", match = { key = "scorch" }, effects = { { type = "buff", key = "improved_scorch", stat = "dmgPct", value = 5, duration = 12, stack = true, maxStacks = 5, target = "all", match = { tag = "fire" } } } } } })
ability(8029, "master_of_elements", "Master of Elements", "fire", "Spell_Fire_MasterOfElements", 3, {
  triggers = { { on = "anyCrit", healing = false, match = { kind = "ability", tag = "spell", damaging = true, anyTag = { "fire", "frost" } }, effects = { { type = "resource", resource = "mana", amount = 5 } } } } })
ability(8030, "fire_power", "Fire Power", "fire", "Spell_Fire_Immolation", 4, {
  adjacency = { { match = { tag = "fire" }, mods = { dmgPct = 25 } } },
  triggers = { { on = "dotTick", match = { tag = "burn" }, every = 5, effects = { { type = "cdr", target = "all", match = { key = "pyroblast" }, amount = 1.5, clampReady = true } } } } })
ability(8031, "combustion", "Combustion", "fire", "Spell_Fire_SealOfFire", 5, {
  use = { cd = 28, cost = 25, rankCosts = { [2] = 20, [3] = 16 }, resource = "mana", effects = { { type = "buff", key = "combustion", stat = "crit", value = 100, charges = 3, duration = 8, rankScale = false, target = "all", match = { tag = "fire", damaging = "direct" } } } } })

ability(8040, "frostbolt", "Frostbolt", "frost", "Spell_Frost_FrostBolt02", 1, {
  use = { cd = 3.5, initialDelay = 2, cost = 15, rankCosts = { [2] = 19, [3] = 23 }, resource = "mana", effects = { damage(7, 10, 0.38, "frost"), { type = "debuff", key = "frostbolt_chill", exclusiveGroup = "frost_chill", stat = "haste", value = 8, duration = 4, rankScale = false } } } })
ability(8041, "frost_nova", "Frost Nova", "frost", "Spell_Frost_FrostNova", 1, {
  use = { cd = 12, initialDelay = 1, cost = 18, rankCosts = { [2] = 23, [3] = 29 }, resource = "mana", effects = { damage(3, 5, 0.12, "frost"), { type = "stun", controlType = "freeze", duration = 1.5, rankScale = false } } } })
ability(8042, "cone_of_cold", "Cone of Cold", "frost", "Spell_Frost_Glacier", 2, {
  use = { cd = 8, cost = 22, rankCosts = { [2] = 28, [3] = 36 }, resource = "mana", effects = { damage(15, 21, 0.5, "frost"), { type = "debuff", key = "cone_of_cold", exclusiveGroup = "frost_chill", stat = "haste", value = 12, duration = 5, rankScale = false } } } })
ability(8043, "blizzard", "Blizzard", "frost", "Spell_Frost_IceStorm", 2, { tags = { "frost", "spell", "dot" }, shape = S.sq,
  use = { cd = 12, cost = 30, rankCosts = { [2] = 40, [3] = 51 }, resource = "mana", effects = { { type = "dot", key = "blizzard", school = "frost", tick = 4, coef = 0.13, duration = 6 }, { type = "debuff", key = "blizzard_chill", exclusiveGroup = "frost_chill", stat = "haste", value = 15, duration = 6, rankScale = false } } } })
ability(8044, "frostbite", "Frostbite", "frost", "Spell_Frost_FrostArmor", 2, {
  triggers = { { on = "anyHit", match = { tag = "frost" }, chance = 15, icd = 3, effects = { { type = "stun", controlType = "freeze", duration = 1 } } } } })
ability(8045, "shatter", "Shatter", "frost", "Spell_Frost_FrostShock", 3, {
  triggers = { { on = "enemyStunned", effects = { { type = "buff", key = "shatter", stat = "crit", value = 50, charges = 1, duration = 5, target = "all", match = { tag = "spell", damaging = "direct" } }, { type = "buff", key = "shatter_damage", stat = "critDamage", value = 30, charges = 1, duration = 5, target = "all", match = { tag = "frost", damaging = "direct" } } } } } })
ability(8046, "ice_shards", "Ice Shards", "frost", "Spell_Frost_IceShard", 2, {
  triggers = { { on = "anyCrit", healing = false, match = { tag = "frost" }, effects = { { type = "damage", school = "frost", fromEvent = 0.3, noCrit = true, noDodge = true, noOwnTriggers = true } } } } })
ability(8047, "frost_channeling", "Frost Channeling", "frost", "Spell_Frost_Stun", 2, {
  adjacency = { { match = { tag = "frost" }, mods = { costPct = -20 } } }, stats = { regen = 1 } })
ability(8048, "winters_chill", "Winter's Chill", "frost", "Spell_Frost_ChillingBlast", 4, {
  triggers = { { on = "anyHit", match = { tag = "frost" }, effects = { { type = "buff", key = "winters_chill", stat = "crit", value = 3, duration = 10, stack = true, maxStacks = 5, target = "all", match = { tag = "frost" } } } } } })
ability(8049, "ice_barrier", "Ice Barrier", "frost", "Spell_Ice_Lament", 3, {
  use = { reactive = true, condition = "noAbsorb", cd = 12, cost = 20, resource = "mana", effects = { { type = "absorb", amount = 35, coef = 0.5 } } },
  triggers = { { on = "absorbed", everyAmount = 25, effects = { { type = "cdr", target = "all", match = { key = "frost_nova" }, amount = 0.5, clampReady = true } } } } })
ability(8050, "ice_block", "Ice Block", "frost", "Spell_Frost_Frost", 4, {
  use = { reactive = true, condition = "below35", cd = 24, cost = 18, rankCosts = { [2] = 24, [3] = 20 }, resource = "mana", effects = { { type = "buff", key = "ice_block", stat = "dr", value = 80, duration = 3 }, { type = "cleanse", count = 3 } } } })
ability(8051, "cold_snap", "Cold Snap", "frost", "Spell_Frost_WizardMark", 5, { tags = { "frost", "spell", "cooldown_reset" },
  use = { cd = 30, initialDelay = 10, cost = 25, rankCosts = { [2] = 20, [3] = 16 }, resource = "mana", effects = { { type = "cdr", target = "all", match = { tag = "frost", notTag = "cooldown_reset" }, amount = 15, clampReady = true } } } })

ability(8060, "mana_shield", "Mana Shield", "shared", "Spell_Shadow_DetectLesserInvisibility", 1, { tags = { "spell", "defensive" },
  use = { reactive = true, condition = "noAbsorb", cd = 9, cost = 16, resource = "mana", effects = { { type = "absorb", amount = 25, coef = 0.35 } } } })
ability(8061, "blink", "Blink", "shared", "Spell_Arcane_Blink", 2, { tags = { "spell", "defensive", "blink" },
  use = { cd = 15, cost = 12, resource = "mana", effects = { buff("blink", "dodge", 50, 2), { type = "cdr", target = "all", match = { tag = "defensive", notTag = "blink" }, amount = 1, clampReady = true } } } })
ability(8062, "frost_armor", "Frost Armor", "shared", "Spell_Frost_FrostArmor02", 1, { kind = "form", tags = { "armor", "frost", "defensive" }, stats = { armor = 25 },
  triggers = { { on = "damaged", matchAttacker = { tag = "melee" }, icd = 2, effects = { { type = "debuff", key = "frost_armor", target = "all", match = { tag = "melee", anyTag = { "autoattack" } }, stat = "haste", value = 20, duration = 4 } } } } })
ability(8063, "ice_armor", "Ice Armor", "shared", "Spell_Frost_FrostArmor02", 2, { kind = "form", tags = { "armor", "frost", "defensive" }, stats = { armor = 45, hp = 30 },
  triggers = { { on = "damaged", matchAttacker = { tag = "melee" }, icd = 3, effects = { { type = "stun", controlType = "freeze", duration = 0.5 } } } } })
ability(8064, "mage_armor", "Mage Armor", "shared", "Spell_MageArmor", 2, { kind = "form", tags = { "armor", "defensive" }, stats = { armor = 12, regen = 3, mana = 25 } })
ability(8065, "remove_lesser_curse", "Remove Lesser Curse", "shared", "Spell_Nature_RemoveCurse", 1, { tags = { "spell", "defensive" },
  use = { cd = 10, cost = 6, resource = "mana", condition = "hasDot", effects = { { type = "cleanse", count = 1, countPerRank = 1 } } } })

ability(8014, "improved_arcane_missiles", "Improved Arcane Missiles", "arcane", "Spell_Nature_StarFall", 3, { shopRequires = { "arcane_missiles" },
  adjacency = { { match = { key = "arcane_missiles" }, mods = { dmgPct = 20 } } },
  triggers = { { on = "anyCrit", healing = false, match = { key = "arcane_missiles" }, effects = { { type = "resource", resource = "mana", amount = 3 } } } } })
ability(8015, "magic_attunement", "Magic Attunement", "arcane", "Spell_Nature_AbolishMagic", 4, { shape = S.v2,
  triggers = { { on = "absorbed", everyAmount = 20, effects = { { type = "bank", key = "arcane_resonance", fraction = 0.5, cap = { flat = 50, sp = 1 } }, { type = "cdr", target = "all", match = { key = "arcane_explosion" }, amount = 0.5, clampReady = true } } } } })
ability(8016, "improved_counterspell", "Improved Counterspell", "arcane", "Spell_Frost_IceShock", 4, { shape = S.v2, shopRequires = { "counterspell" },
  triggers = { { on = "anyUse", match = { key = "counterspell" }, effects = { { type = "buff", key = "improved_counterspell", stat = "crit", value = 100, charges = 1, duration = 5, target = "all", match = { tag = "spell", damaging = "direct" } } } } } })
ability(8032, "improved_fireball", "Improved Fireball", "fire", "Spell_Fire_FlameBolt", 3, { shopRequires = { "fireball" },
  adjacency = { { match = { key = "fireball" }, mods = { cdPct = 15 } } },
  triggers = { { on = "anyUse", match = { key = "fireball" }, every = 2, effects = { { type = "tickDots", match = { tag = "burn" } } } } } })
ability(8033, "incinerate", "Incinerate", "fire", "Spell_Fire_FlameShock", 3, {
  adjacency = { { match = { key = "fire_blast" }, mods = { crit = 12 } }, { match = { key = "scorch" }, mods = { crit = 12 } } },
  triggers = { { on = "adjacentCrit", healing = false, match = { tag = "fire" }, effects = { { type = "cdr", target = "all", match = { key = "fire_blast" }, amount = 1, clampReady = true } } } } })
ability(8034, "critical_mass", "Critical Mass", "fire", "Spell_Nature_WispHeal", 4, { shape = S.v2,
  triggers = { { on = "anyCrit", healing = false, match = { tag = "fire" }, every = 2, effects = { { type = "buff", key = "critical_mass", stat = "critDamage", value = 35, charges = 1, duration = 6, target = "all", match = { tag = "fire", damaging = "direct" } }, { type = "cdr", target = "all", match = { key = "pyroblast" }, amount = 1, clampReady = true } } } } })
ability(8035, "burning_soul", "Burning Soul", "fire", "Spell_Fire_Fire", 4, { shape = S.v2,
  triggers = { { on = "damaged", everyAmount = 40, effects = { { type = "resource", resource = "mana", amount = 6 }, { type = "cdr", target = "neighbors", match = { tag = "fire" }, amount = 1, clampReady = true } } } } })
ability(8052, "permafrost", "Permafrost", "frost", "Spell_Frost_Wisp", 1, {
  triggers = { { on = "anyHit", match = { tag = "frost" }, effects = { { type = "debuff", key = "permafrost", exclusiveGroup = "frost_chill", stat = "haste", value = 3, duration = 4, stack = true, maxStacks = 4 } } } } })
ability(8053, "improved_frostbolt", "Improved Frostbolt", "frost", "Spell_Frost_FrostBolt02", 3, { shopRequires = { "frostbolt" },
  adjacency = { { match = { key = "frostbolt" }, mods = { cdPct = 15 } } },
  triggers = { { on = "anyCrit", healing = false, match = { key = "frostbolt" }, condition = "enemyStunned", effects = { { type = "resource", resource = "mana", fromEvent = 0.15 } } } } })
ability(8054, "piercing_ice", "Piercing Ice", "frost", "Spell_Frost_FrostBolt", 3, {
  triggers = { { on = "anyCrit", healing = false, match = { tag = "frost" }, effects = { { type = "bank", key = "piercing_ice", fraction = 0.25, cap = { flat = 30, sp = 0.5 } } } },
    { on = "anyHit", match = { key = "cone_of_cold" }, effects = { { type = "damage", school = "frost", spendBank = "piercing_ice", bankLabel = "stored Frost damage", noCrit = true, noDodge = true, noOwnTriggers = true } } } } })
ability(8055, "frost_warding", "Frost Warding", "frost", "Spell_Frost_FrostWard", 4, { shape = S.v2,
  triggers = { { on = "absorbed", everyAmount = 30, effects = { { type = "buff", key = "frost_warding", stat = "dmgPct", value = 30, charges = 1, duration = 8, target = "all", match = { tag = "frost", damaging = "direct" } }, { type = "absorb", amount = 6, coef = 0.1 } } } } })

ability(8070, "mana_agate", "Mana Agate", "arcane", "INV_Misc_Gem_Emerald_01", 1, { tags = { "conjured", "mana_recovery" },
  use = { once = true, reactive = true, initialDelay = 0, condition = "lowMana", cd = 30, effects = { { type = "resource", resource = "mana", amount = 35 } } } })
ability(8071, "dampen_magic", "Dampen Magic", "arcane", "Spell_Nature_AbolishMagic", 2, { tags = { "arcane", "spell", "defensive" },
  use = { reactive = true, condition = "injured", cd = 18, cost = 10, rankCosts = { [2] = 8, [3] = 6 }, resource = "mana", effects = {
    { type = "buff", key = "dampen_magic", stat = "dr", value = 20, duration = 6, damageSchool = "magic", rankScale = false },
    { type = "buff", key = "dampen_magic_healing", stat = "healPct", value = -20, duration = 6, rankScale = false },
  } } })
