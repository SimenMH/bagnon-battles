local ADDON, ns = ...
local Util = ns.Util

local Describe = {}
ns.Describe = Describe
local TAG_LABELS, TAG_PHRASES, conditionLabel, statusName
local MOD_KEYS = ns.Sim.MOD_KEYS

local STAT_LABELS = {
  hp = "Health", hpPct = "Maximum Health", armor = "Armor", ap = "Attack Power", sp = "Spell Power", crit = "Critical Strike", critDamage = "Critical Strike Damage",
  haste = "Haste", dodge = "Dodge", block = "Block Value", blockChance = "Block Chance", thorns = "Thorns Damage",
  lifesteal = "Life Steal", healing = "Healing Power", mana = "Mana", regen = "Mana Regeneration",
  dr = "Damage Reduction", dmgPct = "Damage Dealt", healPct = "Healing Done", petPct = "Pet Damage",
  rangedPct = "Ranged Damage", meleePct = "Melee Damage", spellPct = "Spell Damage",
  ragePct = "Rage from Hits", rageTakenPct = "Rage from Damage Taken", rageOnCrit = "Rage on Critical Strike", rageRegen = "Rage per second",
}
local PCT_STATS = Util.Set{ "hpPct", "crit", "critDamage", "haste", "dodge", "blockChance", "lifesteal", "dr", "dmgPct", "healPct", "petPct", "rangedPct", "meleePct", "spellPct", "ragePct", "rageTakenPct" }
local STAT_ORDER = { "hp", "hpPct", "armor", "ap", "sp", "healing", "crit", "critDamage", "haste", "dodge", "block", "blockChance", "thorns", "lifesteal",
  "mana", "regen", "dr", "dmgPct", "healPct", "petPct", "rangedPct", "meleePct", "spellPct", "ragePct", "rageTakenPct", "rageOnCrit" }
local DAMAGE_SCHOOLS = { magic = "magic", physical = "physical", fire = "Fire", frost = "Frost", nature = "Nature", shadow = "Shadow", holy = "Holy", arcane = "Arcane" }

local MOD_LABELS = { dmgPct = "damage", healPct = "healing", crit = "critical strike chance", haste = "speed", costPct = "cost", costFlat = "resource cost", durationPct = "effect duration", cdPct = "cooldown", flat = "damage per hit", ammoEffectPct = "damage and debuff strength" }

local function fmtNumber(v)
  return (string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", ""))
end

local function joinOr(parts)
  if #parts <= 1 then return parts[1] or "" end
  return table.concat(parts, ", ", 1, #parts - 1) .. " or " .. parts[#parts]
end

local function joinAnd(parts)
  if #parts <= 1 then return parts[1] or "" end
  return table.concat(parts, ", ", 1, #parts - 1) .. " and " .. parts[#parts]
end

local function resourcePoint(key)
  return key == "combo" and "combo point" or ns.RESOURCE_NAMES[key] or key or "resource"
end

local SCHOOL_LABELS = { physical = "Physical", nature = "Nature", arcane = "Arcane", fire = "Fire", frost = "Frost", shadow = "Shadow", holy = "Holy" }

local function matchNoun(filter, plural)
  local f = filter or {}
  if f.key then local def = ns.ItemsByKey[f.key] return def and def.name or f.key end
  if f.tag == "totem" and f.notTag == "mana_totem" then return plural and "non-Mana totems" or "non-Mana totem" end
  if f.tag == "affliction" and f.notTag == "channel" then return "Corruption, Curse of Agony and Siphon Life" end
  local nouns = {
    spell = { "spell", "spells" }, heal = { "healing spell", "healing spells" },
    melee = { "melee attack", "melee attacks" }, ranged = { "ranged attack", "ranged attacks" },
    autoattack = { "auto-attack", "auto-attacks" }, strike = { "strike", "strikes" }, shot = { "shot", "shots" },
    builder = { "combo point generating attack", "combo point generating attacks" }, opener = { "opening attack", "opening attacks" },
    finisher = { "finishing move", "finishing moves" }, elemental = { "Elemental spell", "Elemental spells" },
    totem = { "totem", "totems" }, curse = { "curse", "curses" }, poison = { "poison", "poisons" },
    bleed = { "bleed", "bleeds" }, burn = { "burn", "burns" }, shock = { "shock spell", "shock spells" },
    lightning = { "lightning spell", "lightning spells" },
    hot = { "healing over time effect", "healing over time effects" }, dot = { "damage over time effect", "damage over time effects" },
    damaging_totem = { "damaging totem", "damaging totems" },
    druid_hot = { "Rejuvenation or Regrowth", "Rejuvenation and Regrowth" },
    druid_nuke = { "Wrath, Starfire or Moonfire", "Wrath, Starfire and Moonfire" },
    druid_tranquil = { "Healing Touch or Tranquility", "Healing Touch and Tranquility" },
    druid_response = { "Wrath, Entangling Roots, Healing Touch or Regrowth", "Wrath, Entangling Roots, Healing Touch and Regrowth" },
    cold_blood_attack = { "Sinister Strike, Backstab, Ambush or Eviscerate", "Sinister Strike, Backstab, Ambush and Eviscerate" },
    paladin_direct_heal = { "Holy Light, Flash of Light or Holy Shock", "Holy Light, Flash of Light and Holy Shock" },
    patient_heal = { "Lesser Heal, Heal or Greater Heal", "Lesser Heal, Heal and Greater Heal" },
    druid_ferocity_attack = { "Claw, Rake, Maul or Swipe", "Claw, Rake, Maul and Swipe" },
    primal_generator = { "Bear Form or Maul", "Bear Form and Maul" },
    paladin_holy_attack = { "Holy attack", "Holy attacks" },
    maintained_judgement = { "maintained judgement", "maintained judgements" },
    bear = { "Bear attack", "Bear attacks" }, weapon = { "weapon attack", "weapon attacks" },
  }
  local index = plural and 2 or 1
  if f.kind == "weapon" then
    local ranged = f.anyWeaponType and #f.anyWeaponType > 0
    for _, weaponType in ipairs(f.anyWeaponType or {}) do
      if not ns.IsRangedWeapon({ kind = "weapon", weaponType = weaponType }) then ranged = false break end
    end
    local scope = (f.tag == "melee" or f.tag == "ranged") and (f.tag .. " ") or ranged and "ranged " or ""
    return scope .. (plural and "weapon attacks" or "weapon attack")
  end
  if f.kind == "pet" then return plural and "pet attacks" or "pet attack" end
  if f.kind == "form" then return plural and "form attacks" or "form attack" end
  if f.prepared then return (SCHOOL_LABELS[f.tag] and SCHOOL_LABELS[f.tag] .. " " or "") .. (plural and "spells with a cast time" or "spell with a cast time") end
  if f.channeled then return (SCHOOL_LABELS[f.tag] and SCHOOL_LABELS[f.tag] .. " " or "") .. (plural and "channels" or "channel") end
  if f.tag == "spell" and f.notTag == "channel" then return plural and "non-channeled spells" or "non-channeled spell" end
  if f.tag == "spell" and f.anyTag then
    if #f.anyTag == 1 and f.anyTag[1] == "dot" then return plural and "damage-over-time spells" or "damage-over-time spell" end
    local qualifiers = {}
    for _, tag in ipairs(f.anyTag) do qualifiers[#qualifiers + 1] = SCHOOL_LABELS[tag] or tag == "heal" and "healing" or tag == "elemental" and "Elemental" or tag end
    return (f.damaging == "direct" and "direct " or f.damaging and "damaging " or "") .. joinOr(qualifiers) .. (plural and " spells" or " spell")
  end
  if SCHOOL_LABELS[f.tag] and f.anyTag and #f.anyTag == 1 and f.anyTag[1] == "heal" then
    return SCHOOL_LABELS[f.tag] .. (plural and " healing spells" or " healing spell")
  end
  if SCHOOL_LABELS[f.tag] then
    return (f.damaging == "direct" and "direct " or "") .. SCHOOL_LABELS[f.tag]
      .. (f.damaging and (plural and " spells" or " spell") or (plural and " abilities" or " ability"))
  end
  if f.tag == "spell" and f.damaging then return (f.damaging == "direct" and "direct damage " or "damaging ") .. nouns.spell[index] end
  if f.tag == "melee" and f.anyTag and #f.anyTag == 1 and f.anyTag[1] == "autoattack" then return plural and "melee auto-attacks" or "melee auto-attack" end
  if f.tag and nouns[f.tag] then return nouns[f.tag][index] end
  if f.anyTag then
    local parts = {}
    for _, tag in ipairs(f.anyTag) do parts[#parts + 1] = matchNoun({ tag = tag }, plural) end
    return joinOr(parts)
  end
  if f.tag then return (TAG_LABELS[f.tag] or f.tag) .. (plural and " abilities" or " ability") end
  return plural and "abilities" or "ability"
end

local function spatialWord(area)
  return area and (area.side or area.corners or area.empty) and "marked" or "adjacent"
end

local function spatialNoun(filter, area, plural)
  return spatialWord(area) .. " " .. matchNoun(filter, plural)
end
Describe.SpatialNoun = spatialNoun

local function effectNoun(effect, plural, owner)
  if effect.target == "neighbors" and effect.match and effect.match.tag == "druid_hot" and owner then
    local family = owner.baseKey or owner.key
    if family == "regrowth" then return spatialNoun({ key = "rejuvenation" }, effect.area, plural) end
    if family == "rejuvenation" then return spatialNoun({ key = "regrowth" }, effect.area, plural) end
  end
  return effect.target == "neighbors" and spatialNoun(effect.match, effect.area, plural) or matchNoun(effect.match, plural)
end

local function consumptionText(owner, filter, plural)
  local resources = Describe.TriggerResources and Describe.TriggerResources(owner, filter) or {}
  return " that " .. (plural and "consume " or "consumes ") .. (#resources > 0 and joinOr(resources) or "resources")
end

local KIND_LABELS = {
  bag = "Bag", weapon = "Weapon", shield = "Shield", armor = "Armor", ring = "Ring", trinket = "Trinket",
  neck = "Neck", cloak = "Cloak", relic = "Idol", ability = "Ability", form = "Form", pet = "Pet", ammo = "Ammunition",
  material = "Crafting Material", consumable = "Consumable",
}
local SLOT_LABELS = { head = "Head", shoulder = "Shoulder", chest = "Chest", hands = "Hands", legs = "Legs", feet = "Feet", wrist = "Wrist", waist = "Waist" }
local ARMOR_LABELS = { cloth = "Cloth", leather = "Leather", mail = "Mail", plate = "Plate" }
local WEAPON_LABELS = { axe = "Axe", sword = "Sword", mace = "Mace", dagger = "Dagger", staff = "Staff", polearm = "Polearm", bow = "Bow", gun = "Gun", crossbow = "Crossbow", wand = "Wand", fist = "Fist Weapon" }
local REQUIRE_LABELS = { catform = "Cat Form", bearform = "Bear Form", moonkin = "Moonkin Form", shield = "a shield", weapon = "a weapon",
  ranged = "a ranged weapon", melee = "a melee weapon", pet = "a pet", battlestance = "Battle Stance", defensivestance = "Defensive Stance",
  berserkerstance = "Berserker Stance", mana = "Mana", rage = "Rage", energy = "Energy", focus = "Focus", aspect = "an Aspect", trap = "a trap",
  hands = "an available weapon slot", onepet = "the active pet slot", oneform = "the active form slot", oneaspect = "the active aspect slot",
  oneseal = "the active seal slot", onearmor = "the active armor spell slot", twohand = "a two-handed melee weapon", dualwield = "two one-handed melee weapons", feralform = "Cat or Bear Form",
  warlock_imp = "Imp", warlock_voidwalker = "Voidwalker", warlock_succubus = "Succubus", warlock_felhunter = "Felhunter" }
REQUIRE_LABELS.cat, REQUIRE_LABELS.wolf, REQUIRE_LABELS.turtle = "a Cat pet", "a Wolf pet", "a Turtle pet"
Describe.REQUIRE_LABELS = REQUIRE_LABELS
local FORM_LABELS = { form = "Form", aspect = "Aspect", seal = "Seal", armor = "Armor Spell" }
local SLOT_RULES = {
  finger = "Only two rings can be equipped at a time.", trinket = "Only two trinkets can be equipped at a time.",
  neck = "Only one neck item can be equipped at a time.", back = "Only one cloak can be equipped at a time.",
  ammo = "Only one ammo item can be equipped at a time.", pet = "Only one pet can be active at a time.",
}

local function relicLabel(def)
  return def.relicType or (def.classSet and def.classSet.PALADIN and "Libram") or (def.classSet and def.classSet.SHAMAN and "Totem") or "Idol"
end

function Describe.SlotRule(def)
  if def.kind == "shield" then return "Only one shield can be active at a time. Two-handed weapons disable it." end
  local slot = ns.Grid.EquipmentSlot(def)
  if not slot then return nil end
  if def.exclusiveGroup then return "Only one " .. string.lower(def.exclusiveLabel or "ability in this group") .. " can be active at a time." end
  if slot == "relic" then return "Only one " .. string.lower(relicLabel(def)) .. " can be equipped at a time." end
  if FORM_LABELS[slot] then return "Only one " .. string.lower(FORM_LABELS[slot]) .. " can be active at a time." end
  if SLOT_LABELS[slot] then return "Only one " .. string.lower(SLOT_LABELS[slot]) .. " item can be equipped at a time." end
  return SLOT_RULES[slot]
end

local function fmtStat(stat, value)
  local label = STAT_LABELS[stat] or stat
  local sign = value >= 0 and "+" or "-"
  local v = math.abs(value)
  if PCT_STATS[stat] then return string.format("%s%s%% %s", sign, Util.FormatPct(v):gsub("%%", ""), label) end
  return string.format("%s%s %s", sign, fmtNumber(v), label)
end
Describe.FormatStat = fmtStat

function Describe.KindLine(def)
  local parts = {}
  if def.kind == "armor" then
    parts[#parts + 1] = (ARMOR_LABELS[def.armorType] or "") .. " " .. (SLOT_LABELS[def.slot] or "Armor")
  elseif def.kind == "weapon" then
    local ranged = def.weaponType == "bow" or def.weaponType == "gun" or def.weaponType == "crossbow" or def.weaponType == "wand"
    parts[#parts + 1] = (ranged and "Ranged " or def.hands == 2 and "Two-Handed " or "One-Handed ") .. (WEAPON_LABELS[def.weaponType] or "Weapon")
  elseif def.kind == "bag" then
    parts[#parts + 1] = "Bag"
  elseif def.kind == "form" then
    parts[#parts + 1] = FORM_LABELS[ns.Grid.EquipmentSlot(def)]
  elseif def.kind == "relic" then
    parts[#parts + 1] = relicLabel(def)
  elseif def.kind == "ability" then
    local types = {}
    for _, entry in ipairs({ { "strike", "Strike" }, { "finisher", "Finisher" }, { "shot", "Shot" }, { "spell", "Spell" }, { "trap", "Trap" }, { "sting", "Sting" } }) do
      if def.tagSet[entry[1]] then types[#types + 1] = entry[2] end
    end
    parts[#parts + 1] = #types > 0 and table.concat(types, " / ") or def.passiveTriggers and "Passive" or "Ability"
  else
    parts[#parts + 1] = KIND_LABELS[def.kind] or def.kind
  end
  local text = table.concat(parts, "  ")
  local spec = ns.Mastery and ns.Mastery.Spec(def)
  local tree = spec and def.classes and ns.Mastery.Definition(def.classes[1], spec)
  if tree then text = tree.name .. " " .. text end
  return text
end

local function eventAmountLabel(trigger)
  local on = trigger and trigger.on
  if on == "block" then return "damage blocked" end
  if on == "damaged" then return "damage taken" end
  if on == "armorPrevented" then return "damage prevented by Armor" end
  if on == "absorbed" then return "damage absorbed" end
  if on == "healthSpent" then return "Health spent" end
  if on == "healed" or on == "hotTick" or trigger and trigger.healing then return "effective healing" end
  if on == "resourceSpent" or on == "resourceGained" or on == "resourceOverflow" then
    local resource = ns.RESOURCE_NAMES[trigger.resource] or trigger.resource or "resources"
    return resource .. (on == "resourceSpent" and " spent" or on == "resourceOverflow" and " gained above your maximum" or " gained")
  end
  return "damage dealt"
end

local BANK_LABELS = {
  blocked = "damage blocked since its last use", flask = "bonus damage stored by Diamond Flask",
  thorns = "stored damage", maul = "stored damage taken or prevented by Armor",
  wolf_howl = "stored Wolf damage", wind_serpent = "stored damage from Mana spent", lethal_shots = "stored damage from shot critical strikes",
  arcane_resonance = "stored Arcane Explosion damage", piercing_ice = "stored damage from Frost critical strikes",
  discipline_aegis = "bonus damage stored by Power Word: Shield", holy_grace = "bonus damage stored by Renew",
  paladin_holy = "stored Holy Shock damage", paladin_seal = "stored Judgement damage",
  paladin_sanctuary = "stored damage prevented by Armor or blocks", paladin_reckoning_damage = "stored Reckoning damage",
  shaman_stormstrike = "stored melee damage", shaman_tidal = "stored damage from effective healing", shaman_lightning = "stored periodic Fire damage",
}

local BANK_TARGETS = {
  blocked = "Shield Slam", flask = "melee auto-attack", thorns = "Thorns retaliation", maul = "Maul",
  wolf_howl = "weapon auto-attack", wind_serpent = "Wind Serpent breath", lethal_shots = "ranged auto-attack",
  arcane_resonance = "Arcane Explosion", piercing_ice = "Cone of Cold",
  discipline_aegis = "Smite", holy_grace = "Holy Fire", paladin_holy = "Holy Shock", paladin_seal = "Judgement",
  paladin_sanctuary = "Consecration or Righteous Fury retaliation", paladin_reckoning_damage = "melee hit's Holy retaliation",
  shaman_stormstrike = "Stormstrike or Rockbiter-empowered shock", shaman_tidal = "Lightning Shield retaliation",
  shaman_lightning = "Lightning Bolt", shaman_chain_lightning = "Chain Lightning",
}

local function bankAmount(e, trigger)
  if e.amount ~= nil then return fmtNumber(e.amount) .. " bonus damage" end
  return fmtNumber((e.fraction or 1) * 100) .. "% of " .. eventAmountLabel(trigger)
end

local function bankCap(e)
  if not e.cap then return "" end
  local parts = {}
  if e.cap.flat then parts[#parts + 1] = fmtNumber(e.cap.flat) end
  for _, stat in ipairs(STAT_ORDER) do
    if e.cap[stat] then parts[#parts + 1] = fmtNumber(e.cap[stat] * 100) .. "% " .. STAT_LABELS[stat] end
  end
  return " Maximum stored: " .. table.concat(parts, " + ") .. "."
end



local function showFlatDamage(low, high, scaled, details)
  if low == nil then return false end
  high = high or low
  if low == 0 and high == 0 and scaled then return false end
  return details ~= false or not scaled or low < 0 or high > 10
end

local function describeDamage(e, trigger, details)
  if e.consumeDebuff and not e.min and not e.weapon and not e.weaponSelf and not e.coef then
    return string.format("Consumes %s, dealing %s %s damage per stack.", statusName(e.consumeDebuff), fmtNumber(e.perDebuffStack or 1), SCHOOL_LABELS[e.school or "physical"])
  end
  local school = SCHOOL_LABELS[e.school or "physical"]
  local s = ""
  local scaled = e.weaponSelf or e.weapon or (e.coef or 0) > 0 or e.fromEvent or e.blockScale or e.spendBank or e.perPoint
  if showFlatDamage(e.min, e.max, scaled, details) then s = string.format("%d-%d %s damage", e.min, e.max or e.min, school) end
  if e.weaponSelf or e.weapon then
    local weapon = e.weaponType and e.weaponType .. " damage" or "weapon damage"
    local w = e.weaponPct and string.format("%s%% %s", fmtNumber(e.weaponPct * 100), weapon) or weapon
    s = s ~= "" and (w .. " + " .. s) or w
  end
  local out = s ~= "" and ("Deals " .. s) or string.format("Deals %s damage", school)
  if e.fromEvent then
    out = out .. string.format(" %s %s%% of %s", s ~= "" and "plus" or "equal to", fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger))
  end
  if e.perPoint then out = out .. string.format(" + %s per %s spent", fmtNumber(e.perPoint), resourcePoint(e.pointResource)) end
  if e.consumeDebuff then out = out .. string.format(" + %s per %s stack, consuming your stacks", fmtNumber(e.perDebuffStack or 1), statusName(e.consumeDebuff)) end
  if e.spendBank then
    local amount = string.format("%s%%", fmtNumber((e.bankScale or 1) * 100))
    local label = BANK_LABELS[e.spendBank] or e.bankLabel or "stored bonus damage"
    if s == "" and (e.bankScale or 1) == 1 then
      out = "Deals " .. label .. " as " .. school .. " damage"
    elseif (e.bankScale or 1) == 1 then
      out = out .. " plus " .. label
    else
      out = out .. string.format(" %s %s of %s", s ~= "" and "plus" or "equal to", amount, label)
    end
    if (e.bankScale or 1) ~= 1 then out = out .. ", consuming all of it" end
  end
  if e.blockScale then
    if s == "" and not (e.fromEvent or e.perPoint or e.consumeDebuff or e.spendBank) then
      out = string.format("Deals %s damage equal to %s%% of your Block Value", school, fmtNumber(e.blockScale * 100))
    else out = out .. string.format(" + %s%% Block Value", fmtNumber(e.blockScale * 100)) end
  end
  if e.coef and e.coef > 0 then
    local power = STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")]
    if s == "" and not e.fromEvent and not e.perPoint and not e.consumeDebuff and not e.spendBank and not e.blockScale then
      out = string.format("Deals %s damage equal to %s%% of your %s", school, fmtNumber(e.coef * 100), power)
    else
      out = out .. string.format(" (+%s%% %s)", fmtNumber(e.coef * 100), power)
    end
  end
  if e.scaleMissing then out = out .. string.format(", up to %d%% more based on the enemy's missing health", e.scaleMissing * 100) end
  if e.multIf then out = out .. string.format(". Deals %s%% damage %s", fmtNumber(e.multIf.mult * 100), (conditionLabel(e.multIf.condition) or ""):gsub("^%u", string.lower)) end
  if e.perStatus then out = out .. string.format(", +%d%% per damage-over-time effect on the enemy", e.perStatus * 100) end
  if e.critBonus then out = out .. string.format(". Has an additional %d%% critical strike chance", e.critBonus) end
  if e.critIf == "enemyStunned" then out = out .. ". Guaranteed critical strike against crowd-controlled targets"
  elseif e.critIf and conditionLabel(e.critIf) then out = out .. ". Always critically strikes " .. conditionLabel(e.critIf):gsub("^%u", string.lower) end
  if e.generatesRage then out = out .. ". Generates Rage" end
  if e.noCrit then out = out .. ". Cannot critically strike" end
  if e.consumeDots and e.perCombo then out = out .. string.format(", +%d%% per combo point spent", e.perCombo * 100) end
  if e.consumeDots then
    local tag = e.consumeDots.match and e.consumeDots.match.tag
    local what = tag == "bleed" and "bleed damage" or tag == "poison" and "poison damage" or (tag == "fire" or tag == "burn") and "burn damage" or tag == "shadow" and "Shadow damage over time" or "spell damage over time"
    if e.consumeDots.match and e.consumeDots.match.key then what = statusName(e.consumeDots.match.key) .. " damage over time" end
    out = out .. string.format(". Adds %s%% of your remaining %s, consuming it", fmtNumber((e.consumeDots.fraction or 1) * 100), what)
  end
  return out .. "."
end

local function durationText(e)
  if e.durationPerPoint then return string.format(" for %ss plus %ss per Combo Point spent", fmtNumber(e.duration), fmtNumber(e.durationPerPoint)) end
  if e.duration >= ns.Sim.MAX_TIME then return "" end
  return string.format(" for %ss", fmtNumber(e.duration))
end

local function describeEffect(e, trigger, details, context, owner)
  local t = e.type
  if t == "reapplyCoatings" then return "Reapply each active poison once. Conflicting or unplaced poisons are excluded." end
  if t == "reapplyImbue" then return "Trigger your active weapon imbue again. Extra attacks do not count." end
  if t == "damage" then return describeDamage(e, trigger, details)
  elseif t == "heal" then
    if type(e.consumeHots) == "table" and (e.min or 0) == 0 and (e.max or 0) == 0 and (e.coef or 0) == 0 and not (e.pctMax or e.fromEvent or e.perPoint or e.perPointPctMax) then
      return "Consume one " .. effectNoun(e, false) .. " and restore its " .. (e.consumeHots.full and "full" or "remaining") .. " healing immediately."
    end
    local scaled = (e.coef or 0) > 0 or e.pctMax or e.fromEvent or e.perPoint or e.perPointPctMax or e.consumeHots
    local s = showFlatDamage(e.min, e.max, scaled, details) and string.format("%d-%d", e.min, e.max or e.min) or ""
    if e.pctMax then s = s .. (s ~= "" and " + " or "") .. string.format("%s%% max health", fmtNumber(e.pctMax * 100)) end
    if e.fromEvent then s = s .. (s ~= "" and " + " or "") .. string.format("%s%% of %s", fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger)) end
    if e.perPoint then s = s .. (s ~= "" and " + " or "") .. string.format("%s per %s spent", fmtNumber(e.perPoint), resourcePoint(e.pointResource)) end
    if e.perPointPctMax then s = s .. (s ~= "" and " + " or "") .. string.format("%s%% max health per %s spent", fmtNumber(e.perPointPctMax * 100), resourcePoint(e.pointResource)) end
    local out = "Heals " .. s
    if e.consumeHots then
      if type(e.consumeHots) == "table" then
        out = out .. (s ~= "" and " plus " or "") .. "the " .. (e.consumeHots.full and "full" or "remaining")
          .. " healing of one " .. effectNoun(e, false) .. ", consuming that effect"
      else out = out .. (s ~= "" and " plus " or "") .. "100% of the remaining healing over time on you, consuming those effects" end
    end
    if e.coef and e.coef > 0 then
      if s == "" and not e.consumeHots then
        out = string.format("Heals for %s%% of your %s", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "healing"])
      else out = out .. string.format(" (+%s%% %s)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "healing"]) end
    end
    return out .. "."
  elseif t == "dot" then
    if e.drainResource then
      local amount = fmtNumber(e.tick or 0)
      if e.coef and e.coef > 0 then
        amount = amount .. string.format(" (+%s%% %s)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "sp"])
      end
      return string.format("%s up to %s %s every second for %ss.", e.transfer and "Steal" or "Drain", amount, ns.RESOURCE_NAMES[e.drainResource], fmtNumber(e.duration))
    end
    if e.directTicks then
      local text = describeDamage({ min = e.tick, max = e.tick, coef = e.coef, powerStat = e.powerStat,
        school = e.school, noCrit = e.noCrit }, trigger, details)
      return text:gsub("%.$", "") .. string.format(" each second for %ss.", fmtNumber(e.duration))
    end
    if e.stack and (e.uncapped or e.decayStacks or e.rampStacks) then
      local showFlat = showFlatDamage(e.tick, nil, (e.coef or 0) > 0, details)
      local out = string.format("Deals %s %s damage per stack every sec. for %s sec.", fmtNumber(e.tick), SCHOOL_LABELS[e.school or "physical"], fmtNumber(e.duration))
      if not showFlat then out = string.format("Deals %s damage equal to %s%% of your %s per stack every sec. for %s sec.",
        SCHOOL_LABELS[e.school or "physical"], fmtNumber((e.coef or 0) * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")], fmtNumber(e.duration))
      elseif e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s per stack)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")]) end
      if e.stacksFromEvent then out = string.format("Applies 1 stack per %s %s. ", fmtNumber(1 / e.stacksFromEvent), e.fromCriticalDamage and "direct critical damage" or "damage dealt") .. out end
      if e.decayStacks then out = out .. string.format(" Loses %s stacks per tick.", fmtNumber(e.decayStacks)) end
      if e.rampStacks then out = out .. string.format(" Gains %s stack%s every %s ticks.", fmtNumber(e.rampStacks), e.rampStacks == 1 and "" or "s", fmtNumber(e.rampEvery or 1)) end
      if not e.decayStacks then out = out .. (e.uncapped and " Stacks infinitely." or string.format(" Stacks up to %s times.", fmtNumber(e.maxStacks or 5))) end
      if details then
        if e.stacksFromEvent then
          out = out .. (e.fromCriticalDamage and " Minimum 1 stack per direct critical hit. Consumed burn damage cannot create Ignite stacks." or " Minimum 1 stack per damaging hit.")
        end
        out = out .. " Applications add stacks and refresh the duration."
        if e.preserveTicks then out = out .. " Refreshing does not delay the next tick." end
      end
      return out
    end
    if e.rolling and e.fromEvent and (e.school or "physical") == "physical" then
      local repeatText = trigger and (trigger.on == "crit" or trigger.on == "anyCrit" or trigger.on == "adjacentCrit")
        and "Further critical strikes add damage and refresh the bleed."
        or "Reapplying adds damage and refreshes the bleed."
      return string.format("Causes the enemy to bleed for %s%% of that hit's damage over %d seconds. %s", fmtNumber((e.fromEvent or 0) * 100), e.duration, repeatText)
    end
    if e.rolling and e.fromEvent then
      return string.format("Adds %s%% of %s as %s damage over %ds.", fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger), SCHOOL_LABELS[e.school or "physical"], e.duration)
    end
    local showFlat = showFlatDamage(e.tick, nil, (e.coef or 0) > 0, details)
    local out = string.format("Deals %d %s damage every second for %d seconds", e.tick, SCHOOL_LABELS[e.school or "physical"], e.duration)
    if not showFlat then out = string.format("Deals %s damage equal to %s%% of your %s every second for %d seconds",
      SCHOOL_LABELS[e.school or "physical"], fmtNumber((e.coef or 0) * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")], e.duration)
    elseif e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s per tick)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")]) end
    if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
    if e.decayStacks then out = out .. string.format(". Each tick removes %s stacks", fmtNumber(e.decayStacks)) end
    if e.rampStacks then out = out .. string.format(". Every %s ticks adds %s stack%s. Reapplications preserve accumulated stacks", fmtNumber(e.rampEvery or 1), fmtNumber(e.rampStacks), e.rampStacks == 1 and "" or "s") end
    if e.rolling and details then out = out .. ". Reapplications add to the remaining damage" end
    return out .. "."
  elseif t == "hot" then
    if e.fixedFraction then
      local text = string.format("Recover %s%% of that damage over %s sec.", fmtNumber((e.fromEvent or 0) * 100), fmtNumber(e.duration))
      return text .. (details and " Additional ticks deliver the same healing sooner." or "")
    end
    local flat = showFlatDamage(e.tick, nil, (e.coef or 0) > 0, details)
    local out = flat and string.format("Heals %s every second for %ss", fmtNumber(e.tick), fmtNumber(e.duration))
      or string.format("Heals for %s%% of your %s every second for %ss", fmtNumber((e.coef or 0) * 100), STAT_LABELS[e.powerStat or "healing"], fmtNumber(e.duration))
    if flat and e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s per tick)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "healing"]) end
    if e.breakDamagePctMax then out = out .. string.format(". Ends after taking health damage equal to %s%% of maximum health", fmtNumber(e.breakDamagePctMax * 100))
    elseif e.breakOnDamage then out = out .. ". Ends when health damage is taken" end
    return out .. "."
  elseif t == "buff" then
    if e.consumeOn == "block" then
      return string.format("Gain %s%% Block Chance for %ss or %d blocks.", fmtNumber(e.value), fmtNumber(e.duration), e.charges)
    end
    if e.periodic then
      local parts = {}
      for _, effect in ipairs(e.periodic.effects) do parts[#parts + 1] = describeEffect(effect, trigger, details, context, owner):gsub("%.$", "") end
      return table.concat(parts, ". ") .. " every " .. fmtNumber(e.periodic.every) .. "s for " .. fmtNumber(e.duration) .. "s."
    end
    if e.charges == 0 then return "Consume " .. (e.name or e.key and statusName(e.key) or "the effect") .. "." end
    if e.controlTypes then
      if e.controlChance then return string.format("Gain %s%% chance to resist %s for %ss.",
        fmtNumber(e.controlChance), table.concat(e.controlTypes, " or "), fmtNumber(e.duration)) end
      return string.format("Prevent the next %d %s effect%s for %ss.", e.controlCharges,
        table.concat(e.controlTypes, " or "), e.controlCharges == 1 and "" or "s", fmtNumber(e.duration))
    end
    if e.stat == "dmgPct" and e.damageSchool and not (e.target and e.match) then
      return string.format("Deal %s%% %s %s damage%s.", fmtNumber(math.abs(e.value)), e.value < 0 and "less" or "more",
        SCHOOL_LABELS[e.damageSchool] or e.damageSchool, durationText(e))
    end
    if e.free then
      local plural = not e.charges or e.charges > 1
      local subject = "Your " .. (e.charges and ("next " .. (e.charges > 1 and e.charges .. " " or "")) or "") .. effectNoun(e, plural)
      local resources = {}
      for _, resource in ipairs(Describe.TriggerResources(owner, e.match)) do
        if resource ~= ns.RESOURCE_NAMES.combo then resources[#resources + 1] = resource end
      end
      local cost = #resources > 0 and "no " .. joinOr(resources) or "nothing"
      local bonus = e.stat == "dmgPct" and (e.value or 0) > 0 and string.format(" and %s %s%% more damage", plural and "deal" or "deals", fmtNumber(e.value)) or ""
      if e.stat == "crit" and (e.value or 0) > 0 then bonus = " and " .. (plural and "gain " or "gains ") .. fmtStat(e.stat, e.value) end
      if e.charges then return string.format("%s within %s sec %s %s%s.", subject, fmtNumber(e.duration), plural and "cost" or "costs", cost, bonus) end
      return string.format("%s cost %s%s for %s sec.", subject, cost, bonus, fmtNumber(e.duration))
    end
    if ns.Sim.ITEM_STATS[e.stat] then
      local plural = e.charges and e.charges > 1 or not e.charges and not (e.match and e.match.key)
      local noun = effectNoun(e, plural)
      local duration = durationText(e)
      if e.charges then
        noun = "Your next " .. (e.charges == 1 and noun or e.charges .. " " .. effectNoun(e, true))
        if details ~= false and e.paidOnly then noun = noun .. consumptionText(owner, e.match, e.charges ~= 1) end
        if e.duration and e.duration < ns.Sim.MAX_TIME then noun = noun .. " within " .. fmtNumber(e.duration) .. " sec" end
        duration = ""
      else noun = noun:gsub("^%l", string.upper) end
      if e.stat == "delayFlat" then return string.format("%s detonates %ss sooner.", noun, fmtNumber(-e.value)) end
      if e.stat == "prepareFlat" then return string.format("%s casts instantly%s.", noun, duration) end
      if e.stat == "bankPct" then return string.format("%s stores %s%% more damage.", noun, fmtNumber(e.value)) end
      if e.stat == "extraAttackBonusPct" then return string.format("%s gains %s%% more bonus Attack Power.", noun, fmtNumber(e.value)) end
      if e.stat == "costPct" or e.stat == "costFlat" then
        local resources = Describe.TriggerResources and Describe.TriggerResources(owner, e.match) or {}
        local resource = #resources == 1 and resources[1] or "resources"
        return string.format("%s %s %s%s %s %s%s.", noun, plural and "cost" or "costs", fmtNumber(math.abs(e.value)), e.stat == "costPct" and "%" or "", e.value < 0 and "less" or "more", resource, duration)
      end
      if e.stat == "durationPct" then return string.format("%s effects last %s%% longer.", noun, fmtNumber(e.value)) end
      if e.stat == "procChance" then return string.format("%s gains %s%% trigger chance.", noun, fmtNumber(e.value)) end
      if e.stat == "dodgeIgnore" then return string.format("%s %s a %s%% lower chance to be dodged.", noun, plural and "have" or "has", fmtNumber(e.value)) end
    end
    local duration = durationText(e)
    if e.double then
      local match = e.double
      local what = matchNoun(match, false)
      if e.charges then
        local subject = e.charges == 1 and what or e.charges .. " " .. matchNoun(match, true)
        return string.format("Your next %s %s twice.", subject, (match.kind == "pet" or match.kind == "form") and (e.charges == 1 and "hits" or "hit") or (e.charges == 1 and "activates" or "activate"))
      end
      if match.kind == "form" then return "Your form attacks hit twice" .. duration .. "." end
      if match.kind == "pet" then return "Your pet attacks twice" .. duration .. "." end
      return "Your " .. matchNoun(match, true) .. " activate twice" .. duration .. "."
    end
    if e.target and e.match then
      local pet = e.match.kind == "pet" and e.target ~= "neighbors"
      local noun = effectNoun(e, true)
      local what = pet and "Your pet" or noun:gsub("^%l", string.upper)
      local stacking = e.stack and string.format(", stacking up to %d times", e.maxStacks or 5) or ""
      if e.charges then
        what = "Your next " .. (e.charges == 1 and effectNoun(e, false) or e.charges .. " " .. noun)
        if pet and e.match.key then
          local named = ns.ItemsByKey[e.match.key]
          local name = named and named.name:gsub("^Pet: *", "") or "pet"
          what = "Your " .. name .. "'s next " .. (e.charges == 1 and "attack" or e.charges .. " attacks")
        end
        if details ~= false and e.paidOnly then what = what .. consumptionText(owner, e.match, e.charges ~= 1) end
        if e.duration and e.duration < ns.Sim.MAX_TIME then what = what .. " within " .. fmtNumber(e.duration) .. " sec" end
        if e.stat == "crit" and e.value >= 100 then return what .. (e.charges > 1 and " are guaranteed critical strikes." or " is a guaranteed critical strike.") end
        duration = ""
      end
      if e.stat == "dmgPct" and e.damageSchool then
        return string.format("%s %s %s%% %s %s damage%s.", what,
          (pet and not e.charges or e.charges == 1) and "deals" or "deal", fmtNumber(math.abs(e.value)),
          e.value < 0 and "less" or "more", SCHOOL_LABELS[e.damageSchool] or e.damageSchool, duration .. stacking)
      end
      if e.stat == "dmgPct" and not e.fromEvent then
        return string.format("%s %s %s%% %s damage%s.", what, ((pet or e.match.key) and not e.charges or e.charges == 1) and "deals" or "deal", fmtNumber(math.abs(e.value)), e.value < 0 and "less" or "more", duration .. stacking)
      end
      if e.stat == "healPct" and not e.fromEvent then
        return string.format("%s %s for %s%% %s%s.", what, ((pet or e.match.key) and not e.charges or e.charges == 1) and "heals" or "heal", fmtNumber(math.abs(e.value)), e.value < 0 and "less" or "more", duration .. stacking)
      end
      local value = e.fromEvent and string.format("%s equal to %s%% of %s", STAT_LABELS[e.stat] or e.stat, fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger)) or fmtStat(e.stat, e.value):gsub("^%+", "")
      if e.gearCoef then
        value = string.format("%s equal to %s%% of the %s on equipped items", STAT_LABELS[e.stat] or e.stat,
          fmtNumber(e.gearCoef * 100), STAT_LABELS[e.gearStat or e.stat] or e.stat)
        if e.gearCap then value = value .. ", up to " .. fmtStat(e.stat, e.gearCap):gsub("^%+", "") end
        if (e.value or 0) ~= 0 then value = value .. " plus " .. fmtStat(e.stat, e.value):gsub("^%+", "") end
      end
      local out = string.format("%s %s %s%s", what, ((pet or e.match.key) and not e.charges or e.charges == 1) and "gains" or "gain", value, duration)
      if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
      return out .. "."
    end
    if e.stat == "none" then
      if e.double then
        return "Your " .. matchNoun(e.double, true) .. " activate twice" .. duration .. "."
      end
      if e.key == "druid_prowl" then
        return "Gain Prowl" .. duration .. ". Enables Pounce and Ravage." .. (details ~= false and " Either attack ends Prowl." or "")
      end
      if e.key == "rogue_stealth" then
        return "Enter Stealth" .. duration .. ". Enables Ambush, Garrote, Cheap Shot and Sap." .. (details ~= false and " Ambush, Garrote and Cheap Shot end Stealth." or "")
      end
      return (e.name or e.key or "Effect") .. " active" .. duration .. "."
    end
    local out
    if e.gearCoef then
      if not e.gearStat or e.gearStat == e.stat then
        out = string.format("Gain %s%% more %s from equipped items", fmtNumber(e.gearCoef * 100), STAT_LABELS[e.stat] or e.stat)
      else
        out = string.format("Gain %s equal to %s%% of the %s on your equipped items", STAT_LABELS[e.stat] or e.stat,
          fmtNumber(e.gearCoef * 100), STAT_LABELS[e.gearStat or e.stat] or e.stat)
      end
      if e.gearCap then out = out .. ", up to " .. fmtStat(e.stat, e.gearCap):gsub("^%+", "") end
      out = out .. duration
      if (e.value or 0) ~= 0 then out = out .. string.format(". Also gain %s", fmtStat(e.stat, e.value)) end
    elseif e.missingHealth and e.stat == "dmgPct" then
      out = string.format("Deal up to %s%% more damage based on missing health%s", fmtNumber(e.value), duration)
      if details ~= false then out = out .. string.format(". +%s%% damage per 1%% missing health", fmtNumber(e.value / 100)) end
    elseif e.missingHealth then
      out = string.format("Gain up to %s based on missing health%s", fmtStat(e.stat, e.value), duration)
    elseif e.fromEvent then
      out = string.format("Gain %s equal to %s%% of %s%s", STAT_LABELS[e.stat] or e.stat, fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger), duration)
    elseif e.stat == "dr" then
      local scope = (e.rangedOnly and "ranged " or "") .. (e.damageSchool and (DAMAGE_SCHOOLS[e.damageSchool] or e.damageSchool) .. " " or "")
      out = string.format("Take %s%% %s %sdamage%s", fmtNumber(math.abs(e.value)), e.value < 0 and "more" or "less", scope, duration)
    elseif e.stat == "healPct" and e.value < 0 then
      out = string.format("Receive %s%% less healing%s", fmtNumber(-e.value), duration)
    elseif e.stat == "dmgPct" then
      out = string.format("Deal %s%% %s damage%s", fmtNumber(math.abs(e.value)), e.value < 0 and "less" or "more", duration)
    else
      out = string.format("Gain %s%s", fmtStat(e.stat, e.value), duration)
    end
    if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
    return out .. "."
  elseif t == "debuff" then
    if e.controlKey and e.stat == "dr" then
      return string.format("Enemy takes %s%% more damage while affected by %s.", fmtNumber(e.value), statusName(e.controlKey))
    end
    if e.valuePerPoint then
      return string.format("Reduce enemy %s by %s per Combo Point spent%s.", STAT_LABELS[e.stat] or e.stat, fmtNumber(e.valuePerPoint), durationText(e))
    end
    if e.controlTypes then return string.format("Enemy gains %s%% resistance to %s for %ss.", fmtNumber(e.controlChance or 100), table.concat(e.controlTypes, " and "), fmtNumber(e.duration)) end
    if e.stat == "dmgPct" and e.damageSchool then
      return string.format("Enemy deals %s%% less %s damage%s.", fmtNumber(e.value), SCHOOL_LABELS[e.damageSchool] or e.damageSchool, durationText(e))
    end
    if e.stat == "healPct" then
      local out = e.value < 0
        and string.format("The enemy's healing is %s%% stronger%s", fmtNumber(-e.value), durationText(e))
        or string.format("Enemy receives %s%% less healing%s", fmtNumber(e.value), durationText(e))
      if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
      return out .. "."
    end
    if e.stat == "none" and e.stack then
      local out = e.stacksFromEvent and string.format("Applies %s equal to %s%% of %s%s.", e.name or "Lightning Charge", fmtNumber(e.stacksFromEvent * 100), eventAmountLabel(trigger), durationText(e))
        or string.format("Applies %s stacks of %s%s.", fmtNumber(e.stacks or 1), e.name or "Lightning Charge", durationText(e))
      out = out .. (e.uncapped and " Stacks infinitely." or string.format(" Stacks up to %d times.", e.maxStacks or 5))
      return out
    end
    if e.stat == "none" then
      return "Applies " .. (e.name or e.key and statusName(e.key) or "the effect") .. durationText(e) .. "."
    end
    if e.stat == "dr" then
      local scope = (e.rangedOnly and "ranged " or "") .. (e.damageSchool and (DAMAGE_SCHOOLS[e.damageSchool] or e.damageSchool) .. " " or "")
      return string.format("Enemy takes %s%% more %sdamage%s.", fmtNumber(e.value), scope, durationText(e))
    end
    if e.target and e.match and e.match.kind == "ability" and e.match.tag == "spell" and e.stat == "haste" then
      return string.format("Enemy spells recharge %s%% slower%s.", fmtNumber(e.value), durationText(e))
    end
    if e.target and e.match and e.stat == "haste" then
      if e.match.tag == "autoattack" then
        return string.format("Enemy auto-attacks are %s%% slower%s.", fmtNumber(e.value), durationText(e))
      end
      if e.match.tag == "melee" and e.match.anyTag and #e.match.anyTag == 1 and e.match.anyTag[1] == "autoattack" then
        return string.format("Enemy melee auto-attacks are %s%% slower%s.", fmtNumber(e.value), durationText(e))
      end
    end
    local damage = { dmgPct = "", meleePct = "melee ", rangedPct = "ranged ", spellPct = "spell " }
    local out
    if damage[e.stat] then
      out = string.format("Reduce the enemy's %sdamage by %s%%%s", damage[e.stat], fmtNumber(e.value), durationText(e))
      if e.value < 0 then out = string.format("Increase the enemy's %sdamage by %s%%%s", damage[e.stat], fmtNumber(-e.value), durationText(e)) end
    else
      out = string.format("%s the enemy's %s by %s%s%s", e.value < 0 and "Increase" or "Reduce",
        STAT_LABELS[e.stat] or e.stat, fmtNumber(math.abs(e.value)), PCT_STATS[e.stat] and "%" or "", durationText(e))
    end
    if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
    out = out .. "."
    if e.exclusiveGroup == "frost_chill" then out = out .. " Only the strongest Chill effect applies." end
    return out
  elseif t == "refresh" then
    if e.match then
      local tag = e.match.tag
      local what = tag == "poison" and "poisons" or tag == "bleed" and "bleeds" or "damage over time effects"
      return "Refreshes your " .. what .. "."
    end
    return string.format("Refreshes %s.", e.name or ns.ItemsByKey[e.key] and ns.ItemsByKey[e.key].name or e.key)
  elseif t == "tickDots" then
    if e.target == "neighbors" then
      if e.match and e.match.tag == "totem" then return "Trigger an extra damage tick from " .. effectNoun(e, true) .. "." end
      local school = e.match and SCHOOL_LABELS[e.match.tag]
      return "Trigger an extra tick of " .. spatialWord(e.area) .. " " .. (school and school .. " " or "") .. "damage over time effects."
    end
    if e.match and e.match.key then return "Trigger a tick of " .. statusName(e.match.key) .. "." end
    if e.match and e.match.tag == "poison" then return "Trigger a tick of your poisons." end
    if e.match and e.match.tag == "spell" then return "Trigger a tick of your spell damage over time." end
    if e.match and e.match.tag == "affliction" and e.match.notTag == "channel" then return "Trigger a tick of your Corruption, Curse of Agony and Siphon Life." end
    if e.match and e.match.tag == "burn" then return "Trigger a tick of your burns." end
    if e.match and SCHOOL_LABELS[e.match.tag] then return "Trigger a tick of your " .. SCHOOL_LABELS[e.match.tag] .. " damage over time." end
    return e.match and e.match.tag == "bleed" and "Trigger a tick of your bleeds." or "Trigger a tick of your damage over time."
  elseif t == "tickHots" then
    if e.target == "neighbors" then
      if e.match and e.match.tag == "totem" then return "Trigger an extra healing tick from " .. effectNoun(e, true) .. "." end
      return "Trigger an extra tick of " .. effectNoun(e, true, owner) .. "."
    end
    if e.match and e.match.key then return "Trigger a tick of " .. statusName(e.match.key) .. "." end
    if e.match and e.match.tag == "totem" then return "Trigger a tick of your healing totems." end
    return "Trigger a tick of your healing over time effects."
  elseif t == "bank" then
    local target = BANK_TARGETS[e.key] or e.bankTarget
    local value = bankAmount(e, trigger)
    local verb = (e.key == "blocked" or e.key == "maul" or e.key == "arcane_resonance") and "Stores" or "Adds"
    local out = target and string.format("%s %s %s your next %s.", verb, value, verb == "Stores" and "for" or "to", target)
      or string.format("Stores %s for a later attack.", value)
    return out .. ((details ~= false or e.cap and not e.cap.flat) and bankCap(e) or "")
  elseif t == "charge" then
    local def = ns.ItemsByKey[e.key]
    local amount = e.amount or 1
    if amount < 0 then return string.format("Consume %s %s charge%s.", fmtNumber(-amount), def and def.name or e.key, amount == -1 and "" or "s") end
    if e.key == "primal_fury" then
      local cost = ns.ItemsByKey.swipe.use.empower.cost
      return string.format("Gain %s charge%s (maximum %s). Each charge adds a Swipe hit for %s extra Rage.", fmtNumber(amount), amount == 1 and "" or "s", fmtNumber(e.max or 3), fmtNumber(cost))
    end
    return string.format("Gain %s %s charge%s (maximum %s).", fmtNumber(amount), def and def.name or e.key, amount == 1 and "" or "s", fmtNumber(e.max or 3))
  elseif t == "extraAttack" then
    local count = e.count or 1
    local bonus = e.bonusAttackPowerPct and string.format(" with %s%% bonus Attack Power", fmtNumber(e.bonusAttackPowerPct)) or ""
    local attacks = count == 1 and "an extra melee attack" or string.format("%d extra melee attacks", count)
    return (e.spendCharge and ("Consume a " .. statusName(e.spendCharge) .. " charge to trigger ") or "Trigger ") .. attacks .. bonus .. "."
  elseif t == "cast" then
    if e.target == "source" then return "Repeat that ability for free." end
    if e.match and e.match.kind == "pet" then return "Your pet attacks again." end
    if e.match and e.match.kind == "form" then
      if e.target == "neighbors" and e.choose == "first" then return "Trigger an extra attack from an " .. spatialWord(e.area) .. " form." end
      return e.target == "neighbors" and "Trigger an extra attack from each " .. spatialWord(e.area) .. " form." or "Your form attacks again."
    end
    local out
    if e.key then
      local target = ns.ItemsByKey[e.key]
      out = "Cast " .. (target and target.name or e.key) .. " for free"
      if e.key == "execute" and e.ignoreCondition then out = out .. " at any enemy health" end
    elseif e.choose == "first" then
      local noun = matchNoun(e.match, false)
      if e.target == "neighbors" and noun:find(",", 1, true) then
        out = "Cast " .. noun .. " from one " .. spatialWord(e.area) .. " slot at no cost"
      else
        if e.target == "neighbors" then noun = spatialWord(e.area) .. " " .. noun end
        out = "Cast one " .. noun .. " at no cost"
      end
    else
      local what = effectNoun(e, true)
      if e.choose == "random" then
        out = "Cast one of " .. (e.target == "neighbors" and "the " or "your ") .. what .. " at random at no cost"
      else out = "Cast all " .. (e.target == "neighbors" and "" or "your ") .. what .. " at no cost" end
    end
    if details ~= false and e.key == "execute" then out = out .. ". Free Execute gains no damage from Rage spent" end
    if e.consumeCooldown then
      local target = e.key and ns.ItemsByKey[e.key]
      out = out .. ". Starts " .. (target and target.name .. "'s" or "its") .. " cooldown"
    end
    if details ~= false and e.deferDuringChannel then out = out .. ". If unable to act, the spell activates when you recover" end
    return out:gsub(" +", " ") .. "."
  elseif t == "resource" then
    if e.pctMax then return string.format("Restore %s%% of maximum %s.", fmtNumber(e.pctMax * 100), ns.RESOURCE_NAMES[e.resource] or e.resource) end
    if e.fromPaid then return string.format("Refund %s%% of the %s spent on the spell.", fmtNumber(e.fromPaid * 100), ns.RESOURCE_NAMES[e.resource] or e.resource) end
    local amount = e.amount or 0
    if amount < 0 and not e.fromEvent then
      return string.format("Spend %s %s.", fmtNumber(-amount), ns.RESOURCE_NAMES[e.resource] or e.resource)
    end
    if e.fromEvent and amount == 0 and trigger and trigger.on == "resourceSpent" and trigger.resource == "combo" then
      return string.format("Restores %s %s per combo point spent.", fmtNumber(e.fromEvent), ns.RESOURCE_NAMES[e.resource] or e.resource)
    end
    if e.fromEvent then return string.format("Gain %s%s%% of %s as %s.", amount > 0 and fmtNumber(amount) .. " + " or "", fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger), ns.RESOURCE_NAMES[e.resource] or e.resource) end
    if e.resource == "combo" then return string.format("Awards %d combo point%s.", e.amount, e.amount == 1 and "" or "s") end
    if e.resource == "rage" then return string.format("Gain %s Rage.", fmtNumber(amount)) end
    return string.format("Restores %d %s.", e.amount, ns.RESOURCE_NAMES[e.resource] or e.resource)
  elseif t == "absorb" then
    if e.damageSchool then
      local flat = showFlatDamage(e.amount or 0, nil, (e.coef or 0) > 0, details)
      local out = flat and string.format("Absorb %s %s damage", fmtNumber(e.amount or 0), SCHOOL_LABELS[e.damageSchool] or e.damageSchool)
        or string.format("Absorb %s damage equal to %s%% of your %s", SCHOOL_LABELS[e.damageSchool] or e.damageSchool, fmtNumber((e.coef or 0) * 100), STAT_LABELS[e.powerStat or "healing"])
      if flat and e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "healing"]) end
      return out .. string.format(" for %ss.", fmtNumber(e.duration))
    end
    if not showFlatDamage(e.amount or 0, nil, (e.coef or 0) > 0, details) and not e.fromEvent and (e.coef or 0) > 0 then
      return string.format("Gain a shield that absorbs damage equal to %s%% of your %s.", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "healing"])
    end
    local out = e.fromEvent and string.format("Absorbs %s%% of %s", fmtNumber(e.fromEvent * 100), eventAmountLabel(trigger)) or string.format("Gain a shield that absorbs %d damage", e.amount or 0)
    if e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "healing"]) end
    if trigger and trigger.on == "block" then out = out .. ", including this hit" end
    return out .. "."
  elseif t == "clearControl" then
    local labels = { fear = "Fear", charm = "Charm", sleep = "Sleep", stun = "Stun", freeze = "Freeze", horror = "Horror" }
    local parts = {}
    for _, control in ipairs(e.types or {}) do parts[#parts + 1] = labels[control] or control end
    if #parts == 0 then return "Removes crowd control." end
    local last = table.remove(parts)
    return "Removes " .. (#parts > 0 and table.concat(parts, ", ") .. " and " or "") .. last .. "."
  elseif t == "stun" then
    local action = ({ fear = "Fears the enemy", charm = "Charms the enemy", sleep = "Puts the enemy to sleep", freeze = "Freezes the enemy", horror = "Horrifies the enemy", incapacitate = "Incapacitates the enemy" })[e.controlType] or "Stuns the enemy"
    return string.format("%s for %s second%s.%s%s", action, fmtNumber(e.duration), e.duration == 1 and "" or "s", e.breakOnDamage and " Ends when health damage is taken." or "",
      e.holdDirect and " Pauses weapon attacks and instant damage spells. Prepared spells can continue." or e.holdWeapons and " Pauses your weapon attacks until this control ends." or "")
      .. (e.healPctPerSecond and " The enemy recovers " .. fmtNumber(e.healPctPerSecond * 100) .. "% Health each second." or "")
  elseif t == "sacrificePet" then
    return "Sacrifice your demon for the rest of this battle."
  elseif t == "cdr" then
    if e.target == "neighbors" then
      local what = e.match and e.match.key and Describe.FilterLabel(e.match) or matchNoun(e.match, e.choose ~= "first")
      what = spatialWord(e.area) .. " " .. what
      if e.choose == "first" then what = "one " .. what end
      if e.amount < 0 then return string.format("Delay %s by %s sec.", what, fmtNumber(-e.amount)) end
      if e.amount >= 30 then return "Reset the cooldown of " .. what .. "." end
      return string.format("Reduce the cooldown of %s by %s sec.", what, fmtNumber(e.amount))
    end
    if e.target ~= "neighbors" and e.target ~= "all" then return string.format("Reduce its cooldown by %ss.", fmtNumber(e.amount)) end
    if e.match and e.match.kind == "form" then
      return string.format("Reduce your %sform attack cooldown by %ss.", e.target == "neighbors" and "adjacent " or "", fmtNumber(e.amount))
    end
    if e.match and e.match.key then
      local def = ns.ItemsByKey[e.match.key]
      return string.format("Reduce %s%s's cooldown by %ss.", e.target == "neighbors" and "adjacent " or "", def and def.name or e.match.key, fmtNumber(e.amount))
    end
    local what = Describe.FilterLabel(e.match):gsub(" item$", "")
    if not (e.match and e.match.key) then what = what:lower() end
    local target = e.target == "neighbors" and "adjacent" or "all"
    if e.amount >= 30 then return string.format("Reset %s %s cooldowns.", target, what) end
    return string.format("Reduce %s %s cooldowns by %ss.", target, what, fmtNumber(e.amount))
  elseif t == "cleanse" then
    if e.match and e.match.anyTag then
      return string.format("Remove %d %s effect%s.", e.count or 1, joinOr(e.match.anyTag), (e.count or 1) == 1 and "" or "s")
    end
    if e.match and e.match.tag then
      return string.format("Remove %d %s effect%s.", e.count or 1, e.match.tag, (e.count or 1) == 1 and "" or "s")
    end
    return string.format("Remove %d harmful effect%s.", e.count or 1, (e.count or 1) == 1 and "" or "s")
  elseif t == "purge" then
    local text = string.format("Remove %d beneficial effect%s from the enemy.", e.count or 1, (e.count or 1) == 1 and "" or "s")
    if e.healCoef or e.healAmount then
      local healing = describeEffect({ type = "heal", min = e.healAmount or 0, max = e.healAmount or 0,
        coef = e.healCoef, powerStat = e.powerStat or "sp", noCrit = true }, trigger, details, context, owner)
      text = text .. " If an effect is removed, " .. healing:gsub("^Heals ", "heal ")
    end
    return text
  elseif t == "drain" then
    if e.coef or e.damagePerResource then
      local amount = fmtNumber(e.amount or 0)
      if e.coef and e.coef > 0 then
        amount = amount .. string.format(" (+%s%% %s)", fmtNumber(e.coef * 100), STAT_LABELS[e.powerStat or "sp"])
      end
      local out = string.format("%s up to %s %s from the enemy", e.transfer and "Steal" or "Drain", amount, ns.RESOURCE_NAMES[e.resource] or e.resource)
      if e.damagePerResource then
        out = out .. string.format(", dealing %s %s damage per point drained", fmtNumber(e.damagePerResource), SCHOOL_LABELS[e.school or "shadow"])
      end
      return out .. "."
    end
    if e.transfer then return string.format("Steal up to %d %s from the enemy.", e.amount, ns.RESOURCE_NAMES[e.resource] or e.resource) end
    return string.format("Drains %d %s from the enemy.", e.amount, ns.RESOURCE_NAMES[e.resource] or e.resource)
  end
  return ""
end
Describe.Effect = describeEffect

local function sameEffect(a, b)
  if type(a) ~= type(b) then return false end
  if type(a) ~= "table" then return a == b end
  for key, value in pairs(a) do
    if not sameEffect(value, b[key]) then return false end
  end
  for key in pairs(b) do if a[key] == nil then return false end end
  return true
end

local function chargeWard(def)
  local use = def.use
  if not use or #use.effects ~= 2 then return nil end
  local buff, charge = use.effects[1], use.effects[2]
  if buff.type ~= "buff" or buff.stat ~= "none" or buff.charges or buff.target or buff.free or buff.periodic
    or charge.type ~= "charge" or (charge.amount or 1) ~= charge.max or use.condition ~= "notBuff:" .. buff.key then return nil end
  for _, trigger in ipairs(def.triggers) do
    local spent, hit, removed = trigger.effects[1], trigger.effects[2], trigger.effects[3]
    if #trigger.effects == 3 and spent.type == "charge" and spent.key == charge.key and spent.amount == -1
      and hit.type == "damage" and removed.type == "buff" and removed.key == buff.key and removed.charges == 0
      and removed.cond == "chargesAtMost:" .. charge.key .. ":0"
      and sameEffect(trigger.condition, { "buff:" .. buff.key, "chargesAtLeast:" .. charge.key .. ":1" }) then
      return { buff = buff, charge = charge, trigger = trigger }
    end
  end
end

local function effectLines(effects, trigger, resource, details, context, owner)
  local lines = {}
  local index = 1
  while index <= #effects do
    local effect = effects[index]
    local count = 1
    if effect.type == "damage" then
      while effects[index + count] and sameEffect(effect, effects[index + count]) do count = count + 1 end
    end
    local described = effect
    if resource and not effect.pointResource and (effect.perPoint or effect.perPointPctMax) then
      described = Util.ShallowCopy(effect)
      described.pointResource = resource
    end
    if (effect.type == "buff" or effect.type == "debuff") and (effect.stat == "dr" or effect.stat == "dmgPct")
      and SCHOOL_LABELS[effect.damageSchool] and effect.damageSchool ~= "physical" and not effect.gearCoef then
      local schools, seen = { SCHOOL_LABELS[effect.damageSchool] }, { [effect.damageSchool] = true }
      while effects[index + count] do
        local nextEffect = effects[index + count]
        if not SCHOOL_LABELS[nextEffect.damageSchool] or nextEffect.damageSchool == "physical" or seen[nextEffect.damageSchool] then break end
        local compared = Util.ShallowCopy(nextEffect)
        compared.damageSchool, compared.key = effect.damageSchool, effect.key
        if not sameEffect(effect, compared) then break end
        schools[#schools + 1], seen[nextEffect.damageSchool] = SCHOOL_LABELS[nextEffect.damageSchool], true
        count = count + 1
      end
      if count > 1 then
        described = Util.ShallowCopy(effect)
        described.damageSchool = #schools == 6 and "magic" or joinAnd(schools)
      end
    end
    local text = describeEffect(described, trigger, details, context, owner)
    if effect.type == "cdr" and effect.target == "all" and effect.amount > 0 and effect.amount < 30
      and effect.match and effect.match.key and sameEffect(effect.match, { key = effect.match.key }) then
      local names = { ns.ItemsByKey[effect.match.key] and ns.ItemsByKey[effect.match.key].name or effect.match.key }
      while effects[index + count] do
        local nextEffect = effects[index + count]
        if not nextEffect.match or not nextEffect.match.key or not sameEffect(nextEffect.match, { key = nextEffect.match.key }) then break end
        local compared = Util.ShallowCopy(nextEffect)
        compared.match = effect.match
        if not sameEffect(effect, compared) then break end
        names[#names + 1] = ns.ItemsByKey[nextEffect.match.key] and ns.ItemsByKey[nextEffect.match.key].name or nextEffect.match.key
        count = count + 1
      end
      if count > 1 then text = "Reduce the cooldowns of " .. joinAnd(names) .. " by " .. fmtNumber(effect.amount) .. " sec." end
    end
    local groupedStats = { ap = true, sp = true, armor = true, crit = true, haste = true, healing = true, mana = true, block = true, dodge = true }
    if effect.type == "buff" and groupedStats[effect.stat] and (effect.value or 0) > 0
      and not (effect.target or effect.gearCoef or effect.fromEvent or effect.charges or effect.periodic or effect.consumeOn) then
      local stats = { (fmtStat(effect.stat, effect.value):gsub("^%+", "")) }
      while effects[index + count] do
        local nextEffect = effects[index + count]
        if not groupedStats[nextEffect.stat] or (nextEffect.value or 0) <= 0 then break end
        local compared = Util.ShallowCopy(nextEffect)
        compared.stat, compared.value, compared.key = effect.stat, effect.value, effect.key
        if not sameEffect(effect, compared) then break end
        stats[#stats + 1] = fmtStat(nextEffect.stat, nextEffect.value):gsub("^%+", "")
        count = count + 1
      end
      if count > 1 then text = "Gain " .. joinAnd(stats) .. durationText(effect) .. "." end
    end
    if effect.type == "buff" and effect.gearCoef and (effect.value or 0) == 0 and not (effect.target or effect.charges)
      and (not effect.gearStat or effect.gearStat == effect.stat) then
      local stats = { STAT_LABELS[effect.stat] or effect.stat }
      while effects[index + count] do
        local nextEffect = effects[index + count]
        if nextEffect.gearStat and nextEffect.gearStat ~= nextEffect.stat then break end
        local compared = Util.ShallowCopy(nextEffect)
        compared.key, compared.name, compared.stat, compared.gearStat = effect.key, effect.name, effect.stat, effect.gearStat
        if not sameEffect(effect, compared) then break end
        stats[#stats + 1] = STAT_LABELS[nextEffect.stat] or nextEffect.stat
        count = count + 1
      end
      if count > 1 then
        local names = table.concat(stats, ", ", 1, #stats - 1) .. " and " .. stats[#stats]
        text = string.format("Gain %s%% more %s from equipped items%s.", fmtNumber(effect.gearCoef * 100), names, durationText(effect))
      end
    end
    if effect.type == "cdr" and effects[index + 1] and effects[index + 2] then
      local tick = Util.ShallowCopy(effect)
      tick.type, tick.amount, tick.clampReady, tick.rankScale = "tickHots", nil, nil, nil
      if sameEffect(tick, effects[index + 1]) then
        tick.type = "tickDots"
        if sameEffect(tick, effects[index + 2]) then
          text = string.format("Reduce %s cooldowns by %s sec and trigger an extra tick of their healing and damage over time effects.", effectNoun(effect, false), fmtNumber(effect.amount))
          count = 3
        end
      end
    end
    if effect.perCombo and not (effect.type == "damage" and effect.consumeDots) then
      text = text .. string.format(" +%s%% per combo point spent.", fmtNumber(effect.perCombo * 100))
    end
    if count > 1 and effect.type == "damage" then
      local hits = count == 2 and "Hits twice." or string.format("Hits %d times.", count)
      text = hits .. " " .. text:gsub("^Deals ", "Each hit deals ")
    end
    if effect.cond and conditionLabel(effect.cond) then
      local condition = conditionLabel(effect.cond):gsub("^While ", "If "):gsub("^In ", "If you are in ")
      local verbs = { Heal = "heal", Heals = "heal", Deal = "deal", Deals = "deal", Gain = "gain", Awards = "gain", Restores = "restore", Adds = "add", Stores = "store", Gains = "gain", Applies = "apply", Consumes = "consume" }
      local verb = text:match("^(%a+) ")
      text = condition .. (trigger and ", " or " when cast, ") .. (verbs[verb] and text:gsub("^%a+ ", verbs[verb] .. " ") or text:gsub("^The ", "the "):gsub("^Your ", "your "))
    end
    if text ~= "" then lines[#lines + 1] = text end
    index = index + count
  end
  return lines
end

local function bankReferences(def, context, details)
  local spent, supplied, lines = {}, {}, {}
  local function inspect(owner, callback)
    for _, effect in ipairs(owner.use and owner.use.effects or {}) do callback(effect) end
    for _, trigger in ipairs(owner.triggers or {}) do
      for _, effect in ipairs(trigger.effects or {}) do callback(effect, trigger) end
    end
  end
  inspect(def, function(effect)
    if effect.spendBank then spent[effect.spendBank] = true end
    if effect.type == "bank" then supplied[effect.key] = true end
  end)
  for _, key in ipairs(Util.SortedKeys(spent)) do
    if not supplied[key] then
      local sources, seen = {}, {}
      local function source(owner)
        local family = owner.baseKey or owner.key
        if seen[family] then return end
        inspect(owner, function(effect, trigger)
          if effect.type == "bank" and effect.key == key then
            seen[family] = true
            sources[#sources + 1] = { def = owner, effect = effect, trigger = trigger }
          end
        end)
      end
      for _, item in ipairs(context and context.items or {}) do
        if not item.suppressed and (item.enabled or item.def.passiveTriggers) then source(item.def) end
      end
      if #sources == 0 then
        for _, candidate in ipairs(ns.ItemList) do
          if not candidate.baseKey then source(candidate) end
          if #sources > 0 and not details then break end
        end
      end
      for _, entry in ipairs(sources) do
        local effect, trigger = entry.effect, entry.trigger
        local origin = eventAmountLabel(trigger)
        if trigger and trigger.on == "healed" then origin = "your effective healing"
        elseif trigger and trigger.on == "absorbed" then origin = "damage absorbed by your shields"
        elseif trigger and trigger.on == "regularHit" then origin = "your " .. (trigger.match and trigger.match.tag == "melee" and "melee " or "") .. "auto-attack damage"
        elseif trigger and trigger.on == "dotTick" and trigger.match and trigger.match.tag == "fire" then origin = "your periodic Fire damage"
        elseif trigger and trigger.match and trigger.match.key and (trigger.on == "anyHit" or trigger.on == "hit") then
          origin = matchNoun(trigger.match, false) .. " damage"
        end
        local value = effect.amount ~= nil and fmtNumber(effect.amount) .. " bonus damage" or fmtNumber((effect.fraction or 1) * 100) .. "% of " .. origin
        local text = entry.def.name .. " stores " .. value .. " for " .. def.name .. "."
        if trigger and trigger.chance then text = text .. " " .. fmtNumber(trigger.chance) .. "% chance per trigger." end
        if trigger and trigger.everyAmount then text = text .. " Requires " .. fmtNumber(trigger.everyAmount) .. " " .. eventAmountLabel(trigger) .. " per trigger." end
        lines[#lines + 1] = text .. (details and bankCap(effect) or "")
      end
    end
  end
  return lines
end

local CONDITION_LABELS = {
  readyStrike = "When another melee strike is ready and affordable",
  injured = "Below 90% health",
  injuredOrHarmful = "Below 90% health or affected by a harmful effect",
  below75 = "Below 75% health",
  below50 = "Below 50% health",
  below35 = "Below 35% health",
  enemyBelow20 = "Enemy below 20% health",
  enemyBelow50 = "Enemy below 50% health",
  hasDot = "While affected by damage over time",
  hasHarmful = "While affected by a harmful effect",
  hasCurse = "While affected by a curse", hasPoison = "While affected by poison",
  enemyHumanoid = "Against a humanoid enemy",
  enemyMana = "While the enemy has Mana", enemyBeneficialBuff = "While the enemy has a beneficial effect",
  injuredWithHot = "While injured and you have a heal over time",
  enemyBleeding = "If the enemy is bleeding",
  enemyPoisoned = "If the enemy is poisoned",
  noAbsorb = "While you have no absorb shield",
  lowMana = "Below 30% mana",
  enemyStunned = "While the enemy is under crowd control",
  dualwield = "While dual wielding",
}

statusName = function(key)
  local markers = { druid_prowl = "Prowl", rogue_stealth = "Stealth", natures_grasp_ready = "Nature's Grasp charge" }
  if markers[key] then return markers[key] end
  if ns.ItemsByKey[key] then return ns.ItemsByKey[key].name end
  for _, def in ipairs(ns.ItemList) do
    for _, effect in ipairs(def.use and def.use.effects or {}) do
      if effect.key == key and effect.name then return effect.name end
    end
    for _, trigger in ipairs(def.triggers or {}) do
      for _, effect in ipairs(trigger.effects or {}) do
        if effect.key == key and effect.name then return effect.name end
      end
    end
  end
  return (key:gsub("_", " "):gsub("^%l", string.upper))
end

conditionLabel = function(cond, hideMaintenance)
  if not cond then return nil end
  if type(cond) == "table" then
    local parts = {}
    local specificPet = false
    for _, entry in ipairs(cond) do if type(entry) == "string" and entry:match("^provides:warlock_") then specificPet = true end end
    for _, entry in ipairs(cond) do
      if entry ~= "provides:pet" or not specificPet then
        local label = conditionLabel(entry, hideMaintenance)
        if label then parts[#parts + 1] = label end
      end
    end
    return #parts > 0 and table.concat(parts, ", ") or nil
  end
  if CONDITION_LABELS[cond] then return CONDITION_LABELS[cond] end
  local resource, amount = cond:match("^resourceAtLeast:([^:]+):([%d%.]+)$")
  if resource and tonumber(amount) then
    if resource == "combo" and tonumber(amount) == 1 then return "At least 1 Combo Point" end
    return string.format("At %s+ %s", fmtNumber(tonumber(amount)), ns.RESOURCE_NAMES[resource] or resource)
  end
  resource, amount = cond:match("^resourceIdle:([^:]+):([%d%.]+)$")
  if resource then return "After " .. amount .. "s without spending " .. (ns.RESOURCE_NAMES[resource] or resource) end
  local provided = cond:match("^provides:(.+)$")
  if provided == "hawk" then return "While Aspect of the Hawk is active" end
  if provided == "pet" then return "While your pet is active" end
  if provided == "shield" then return "While a shield is equipped" end
  if provided == "melee" then return "While a melee weapon is equipped" end
  if provided == "ranged" then return "While a ranged weapon is equipped" end
  if provided and provided:match("^warlock_") and REQUIRE_LABELS[provided] then return "While your " .. REQUIRE_LABELS[provided] .. " is active" end
  if provided then return "In " .. (REQUIRE_LABELS[provided] or provided) end
  local key = cond:match("^enemyHas:(.+)$")
  if key then return "While the enemy has " .. statusName(key) end
  key = cond:match("^enemyBuff:(.+)$")
  if key then return "While the enemy has " .. statusName(key) end
  local harmful = cond:match("^hasHarmful:(.+)$")
  if harmful then return "While affected by " .. harmful:gsub(",", " or ") end
  key = cond:match("^buff:(.+)$")
  if key then return "While " .. statusName(key) .. " is active" end
  key = cond:match("^notBuff:(.+)$")
  if key then return "While " .. statusName(key) .. " is inactive" end
  local mode, name, seconds = cond:match("^(%a+):([^:]+):([%d%.]+)$")
  if mode == "buffNeeds" or mode == "hotNeeds" or mode == "enemyNeeds" then
    if hideMaintenance then return nil end
    return "Waits for " .. statusName(name) .. " to expire before refreshing it"
  end
  if cond:match("^enemyControlled:") then return "While the enemy is stunned or incapacitated" end
  resource, amount = cond:match("^resourceAtMost:([^:]+):([%d%.]+)$")
  if resource then return string.format("At %s or less %s", amount, ns.RESOURCE_NAMES[resource] or resource) end
  local chargeMode, chargeKey, chargeAmount = cond:match("^(chargesAt%a+):([^:]+):([%d%.]+)$")
  if chargeKey and chargeMode == "chargesAtMost" and tonumber(chargeAmount) == 0 then return "While " .. statusName(chargeKey) .. " has no charges" end
  if chargeKey then return string.format("While %s has %s %s charge%s", statusName(chargeKey), chargeMode == "chargesAtMost" and "at most" or "at least", chargeAmount, tonumber(chargeAmount) == 1 and "" or "s") end
  key = cond:match("^owns:(.+)$")
  if key then return "While carrying " .. statusName(key) end
  return nil
end

local function filterLabel(f)
  if not f then return "item" end
  if f.tag == "totem" and f.notTag == "mana_totem" then return "non-Mana totem" end
  if f.channeled then return (SCHOOL_LABELS[f.tag] and SCHOOL_LABELS[f.tag] .. " " or "") .. "channel" end
  if f.tag == "spell" and f.notTag == "channel" then return "non-channeled spell" end
  if f.tag == "spell" and f.anyTag and #f.anyTag == 1 and f.anyTag[1] == "heal" then return "healing spell" end
  local namedGroups = {
    druid_hot = "Rejuvenation and Regrowth", druid_nuke = "Wrath, Starfire and Moonfire",
    druid_tranquil = "Healing Touch and Tranquility", druid_response = "Wrath, Entangling Roots, Healing Touch and Regrowth",
    cold_blood_attack = "Sinister Strike, Backstab, Ambush and Eviscerate",
    paladin_direct_heal = "direct Holy healing", paladin_holy_attack = "Holy attacks", patient_heal = "Lesser Heal, Heal and Greater Heal", maintained_judgement = "maintained judgement", druid_ferocity_attack = "Claw, Rake, Maul and Swipe", primal_generator = "Bear Form and Maul",
  }
  if f.tag and namedGroups[f.tag] then return namedGroups[f.tag] end
  if f.tag == "spell" and f.anyTag and #f.anyTag == 1 and f.anyTag[1] == "elemental" then return "Elemental spell" end
  if f.key then local d = ns.ItemsByKey[f.key] return d and d.name or f.key end
  if f.hands then return f.hands == 2 and "Two-handed weapon" or "One-handed weapon" end
  if f.weaponType then return WEAPON_LABELS[f.weaponType] or f.weaponType end
  if f.anyWeaponType then
    local types = {}
    for _, weaponType in ipairs(f.anyWeaponType) do types[weaponType] = true end
    if #f.anyWeaponType == 3 and types.bow and types.gun and types.crossbow then return "Ranged weapon" end
    local parts = {}
    for _, w in ipairs(f.anyWeaponType) do parts[#parts + 1] = WEAPON_LABELS[w] or w end
    return joinOr(parts)
  end
  if f.kind == "weapon" then
    if f.tag == "melee" then return "Melee weapon" end
    if f.tag == "ranged" then return "Ranged weapon" end
    return "Weapon"
  end
  if f.tag == "spell" and f.anyTag and #f.anyTag == 1 and f.anyTag[1] == "dot" then return "Damage-over-time spell" end
  if f.tag then return Describe.TagLabel(f.tag) .. " item" end
  if f.anyTag then
    local parts, spells = {}, true
    for _, tag in ipairs(f.anyTag) do
      parts[#parts + 1] = Describe.TagLabel(tag)
      if tag ~= "lightning" and tag ~= "shock" and tag ~= "heal" then spells = false end
    end
    return joinOr(parts) .. (spells and " spell" or " item")
  end
  if f.kind then return KIND_LABELS[f.kind] or f.kind end
  if f.slot then return SLOT_LABELS[f.slot] or f.slot end
  if f.set then local s = ns.Sets[f.set] return s and s.name or f.set end
  return "item"
end
Describe.FilterLabel = filterLabel

function Describe.FilterPhrase(f, determiner)
  if not f then return determiner == "every" and "every item" or "an item" end
  local weapon = f.kind == "weapon" or f.hands or f.weaponType or f.anyWeaponType
  if not weapon and f.tag and TAG_PHRASES[f.tag] then return TAG_PHRASES[f.tag][determiner == "every" and 2 or 1] end
  local label = filterLabel(f)
  if f.key then return label end
  if weapon then label = label:lower() end
  if determiner == "every" then return "every " .. label end
  return (label:match("^[AEIOUaeiou]") and "an " or "a ") .. label
end

TAG_LABELS = {
  balance = "Balance", feral = "Feral", resto = "Restoration", arms = "Arms", fury = "Fury", prot = "Protection", bear = "Bear",
  bm = "Beast Mastery", mm = "Marksmanship", surv = "Survival", spell = "Spell", melee = "Melee", ranged = "Ranged",
  nature = "Nature", arcane = "Arcane", fire = "Fire", frost = "Frost", shadow = "Shadow", holy = "Holy", heal = "Healing", lightning = "Lightning",
  dot = "Damage over Time", hot = "Heal over Time", bleed = "Bleed", poison = "Poison", shout = "Shout", pet = "Pet", trap = "Trap",
  aspect = "Aspect", sting = "Sting", shot = "Shot", strike = "Strike", form = "Form", stance = "Stance", physical = "Physical",
  defensive = "Defensive", finisher = "Finisher", ammo = "Ammunition", weapon = "Weapon", autoattack = "Auto-attack",
  protection = "Protection", retribution = "Retribution", assassination = "Assassination", combat = "Combat", subtlety = "Subtlety",
  discipline = "Discipline", elemental = "Elemental", enhancement = "Enhancement", restoration = "Restoration",
  affliction = "Affliction", demonology = "Demonology", destruction = "Destruction", totem = "Totem", imbue = "Weapon Imbue",
  builder = "Combo Builder", opener = "Opener", control = "Control", burn = "Burn", seal = "Seal", judgement = "Judgement", shock = "Shock", pet_command = "Demon Command",
}
TAG_PHRASES = {
  autoattack = { "an auto-attack", "every auto-attack" }, melee = { "a melee attack", "every melee attack" },
  spell = { "a spell", "every spell" }, strike = { "a strike", "every strike" }, shot = { "a shot", "every shot" },
  bleed = { "a bleed", "every bleed" }, heal = { "a healing ability", "every healing ability" },
  poison = { "a poison", "every poison" },
  damaging_totem = { "a damaging totem", "every damaging totem" },
  trap = { "a trap", "every trap" }, pet = { "your pet", "your pet" },
  lightning = { "a lightning spell", "every lightning spell" },
}
function Describe.TagLabel(tag) return TAG_LABELS[tag] or tag end

local function describeMods(mods, labels)
  local parts = {}
  for _, k in ipairs(MOD_KEYS) do
    local v = mods[k]
    if v and v ~= 0 then
      if k == "cdPct" then parts[#parts + 1] = string.format("%s%% %s cooldown", fmtNumber(math.abs(v)), v > 0 and "reduced" or "increased")
      elseif k == "prepareFlat" then parts[#parts + 1] = (v > 0 and "+" or "") .. fmtNumber(v) .. "s cast time"
      elseif k == "flat" or k == "costFlat" then parts[#parts + 1] = (v > 0 and "+" or "") .. fmtNumber(v) .. " " .. (labels and labels[k] or MOD_LABELS[k])
      else parts[#parts + 1] = (v > 0 and "+" or "") .. fmtNumber(v) .. "% " .. (labels and labels[k] or MOD_LABELS[k]) end
    end
  end
  return table.concat(parts, ", ")
end

local function highlightedSubject(filter)
  if not filter then return "Items" end
  if filter.key then return filterLabel(filter) end
  if filter.kind == "ammo" then return "Ammo" end
  if filter.kind == "armor" then return "Armor" end
  if filter.set or filter.slot then return filterLabel(filter) .. " items" end
  if filter.anyWeaponType and filterLabel(filter) ~= "Ranged weapon" then
    local parts = {}
    for _, weaponType in ipairs(filter.anyWeaponType) do
      parts[#parts + 1] = weaponType == "staff" and "staves" or (WEAPON_LABELS[weaponType] or weaponType):lower() .. "s"
    end
    return joinOr(parts):gsub("^%l", string.upper)
  end
  if filter.weaponType or filter.anyWeaponType or filter.hands
    or filter.kind and filter.kind ~= "ability" and filter.kind ~= "pet" and filter.kind ~= "form" then
    return filterLabel(filter) .. "s"
  end
  return matchNoun(filter, true):gsub("^%l", string.upper)
end

local function describeStats(stats)
  local parts = {}
  for _, k in ipairs(STAT_ORDER) do
    if stats[k] and stats[k] ~= 0 then parts[#parts + 1] = fmtStat(k, stats[k]) end
  end
  return parts
end

local function modifierSentence(mods, subject, singular)
  local parts = {}
  local function verb(plural, single) return singular and single or plural end
  for _, key in ipairs(MOD_KEYS) do
    local value = mods[key]
    if value and value ~= 0 then
      local amount = fmtNumber(math.abs(value))
      if key == "dmgPct" then parts[#parts + 1] = verb("deal", "deals") .. " " .. amount .. "% " .. (value > 0 and "more" or "less") .. " damage"
      elseif key == "healPct" then parts[#parts + 1] = verb("restore", "restores") .. " " .. amount .. "% " .. (value > 0 and "more" or "less") .. " Health"
      elseif key == "cdPct" then parts[#parts + 1] = verb("have", "has a") .. " " .. amount .. "% " .. (value > 0 and "shorter" or "longer") .. verb(" cooldowns", " cooldown")
      elseif key == "costPct" then parts[#parts + 1] = verb("cost", "costs") .. " " .. amount .. "% " .. (value < 0 and "less" or "more")
      elseif key == "costFlat" then parts[#parts + 1] = verb("cost", "costs") .. " " .. amount .. " " .. (value < 0 and "less" or "more") .. " resources"
      elseif key == "prepareFlat" then parts[#parts + 1] = verb("cast", "casts") .. " " .. amount .. " sec " .. (value < 0 and "faster" or "slower")
      elseif key == "durationPct" then parts[#parts + 1] = verb("have", "has") .. " " .. amount .. "% " .. (value > 0 and "longer" or "shorter") .. " effects"
      elseif key == "flat" then parts[#parts + 1] = verb("deal", "deals") .. " " .. amount .. (value > 0 and " additional" or " less") .. " damage per hit"
      elseif key == "ammoEffectPct" then parts[#parts + 1] = verb("deal", "deals") .. " " .. amount .. "% " .. (value > 0 and "more" or "less") .. " damage and " .. verb("apply", "applies") .. " " .. amount .. "% " .. (value > 0 and "stronger" or "weaker") .. " debuffs"
      else parts[#parts + 1] = verb(value > 0 and "gain" or "lose", value > 0 and "gains" or "loses") .. " " .. amount .. "% " .. (key == "haste" and "Haste" or MOD_LABELS[key] or key) end
    end
  end
  local predicate = #parts > 1 and table.concat(parts, ", ", 1, #parts - 1) .. " and " .. parts[#parts] or parts[1]
  return predicate and subject .. " " .. predicate .. "." or ""
end

local function adjacencySubject(rule, owner)
  local filter = rule.match or {}
  local singleSlot = owner and owner.cellCount == 1 and rule.side and not rule.corners and rule.once
  local singular = rule.once and not singleSlot or filter.key ~= nil or filter.kind == "ammo" or filter.kind == "armor"
  local noun = singular and filterLabel(filter):gsub(" item$", " ability") or highlightedSubject(filter)
  if filter.kind == "ammo" then noun = "ammunition"
  elseif filter.kind == "armor" then noun = "armor"
  elseif not filter.key and (filter.kind == "weapon" or filter.weaponType or filter.anyWeaponType or filter.hands) then noun = noun:lower()
  elseif not filter.key and not SCHOOL_LABELS[filter.tag]
    and not (filter.tag and (filter.tag:match("^druid_") or filter.tag == "paladin_direct_heal" or filter.tag == "patient_heal" or filter.tag == "cold_blood_attack" or filter.tag == "primal_generator")) then noun = noun:gsub("^%u", string.lower) end
  if rule.inside then return noun:gsub("^%l", string.upper) .. " in this bag", singular end
  if singleSlot then return noun .. " in the highlighted slot", singular end
  return (rule.once and "One " or "") .. spatialWord(rule) .. " " .. noun, singular
end

local function describeSetBonus(bonus)
  local parts = describeStats(bonus.stats or {})
  if bonus.text then parts[#parts + 1] = bonus.text
  elseif bonus.mods then parts[#parts + 1] = filterLabel(bonus.mods.match) .. "s: " .. describeMods(bonus.mods) end
  return table.concat(parts, ", ")
end

function Describe.SetGoal(setKey)
  local set = ns.Sets[setKey]
  return set and set.thresholds[#set.thresholds] or 0
end

function Describe.Rate(value)
  if value >= 10 then return string.format("%d", math.floor(value + 0.5)) end
  return (string.format("%.1f", value):gsub("%.0$", ""))
end

function Describe.Demand(side)
  local demand = {}
  for _, it in ipairs(side.items) do
    local use = it.def.use
    if it.enabled and use and not use.once and use.resource and use.cost and use.cost > 0 then
      local cd = it.cdMax or use.cd
      local cost = use.cost * math.max(0, 1 + (it.mods and it.mods.costPct or 0) / 100)
      demand[use.resource] = (demand[use.resource] or 0) + cost / cd
    end
  end
  return demand
end

function Describe.StatLines(statKey, context, details)
  local lines = {}
  if not context or not context.stats then return lines end
  local function add(text, color) lines[#lines + 1] = { text = text, color = color } end
  local function value(stat)
    if context.buffs then return ns.Sim.OwnerStat(context, stat) end
    return context.stats[stat] or 0
  end
  local function percent(amount) return fmtNumber(amount) .. "%" end
  local function chance(amount) return math.max(0, math.min(100, amount)) end
  local resource = statKey and statKey:match("^resource:(.+)$")
  local setKey = statKey and statKey:match("^set:(.+)$")
  if resource then
    local pool = context.res and context.res[resource]
    if not pool then return lines end
    local name = ns.RESOURCE_NAMES[resource] or resource
    add(string.format("Maximum: %s %s.", fmtNumber(pool.max), name))
    if resource == "rage" then
      add("Auto-attacks and damage taken generate Rage. Harder hits generate more.")
      if details then
        local conversion = ns.Sim.RageDamageScale(context)
        local hit = (1 + value("ragePct") / 100) * conversion
        add(string.format("Auto-attacks: %s of damage dealt. Incoming hits: %s of damage taken.", percent(ns.Sim.RAGE_PER_DAMAGE_DEALT * 100 * hit), percent(ns.Sim.RAGE_PER_DAMAGE_TAKEN * 100 * (1 + value("rageTakenPct") / 100) * conversion)))
        if value("rageOnCrit") > 0 then add(string.format("Weapon critical strikes grant %s extra Rage.", fmtNumber(value("rageOnCrit")))) end
        add("Gains above your maximum count as excess Rage.")
      end
    elseif resource == "combo" then
      add("Builders generate points. Finishers spend them.")
      if details then add("Finishers spend all saved points once their minimum is met.") end
    else
      add(string.format("Regenerates %s %s per second.", fmtNumber(pool.regen or 0), name))
      if details then
        local demand = Describe.Demand(context)[resource] or 0
        if demand > 0 then
          add(string.format("Listed ability demand: %s %s per second, before haste and free casts.", fmtNumber(demand), name))
        else
          add("No active ability spends this resource.")
        end
      end
    end
    return lines
  elseif setKey then
    local set = ns.Sets[setKey]
    if not set then return lines end
    local owned = context.setCounts and context.setCounts[setKey] or {}
    if details then return Describe.SetLines(setKey, owned) end
    local count = Util.Count(owned)
    add(string.format("%d %s in your bag.", count, count == 1 and "piece" or "pieces"))
    for _, threshold in ipairs(set.thresholds) do
      local bonus = set.bonuses[threshold]
      local text = describeSetBonus(bonus)
      if text ~= "" then
        local active = count >= threshold
        add(string.format("%d pieces%s: %s", threshold, active and " (active)" or "", text), active and { r = 0.1, g = 1, b = 0.1 } or { r = 0.6, g = 0.6, b = 0.6 })
      end
    end
    return lines
  end
  local amount = value(statKey)
  if statKey == "hp" then
    local bonus = value("hpPct")
    local scale = math.max(0, 1 + bonus / 100)
    local unscaled = scale > 0 and (context.hpMax or 0) / scale or 0
    local base = context.round and ns.Economy.BaseHealth(context.round) or unscaled - amount
    add(string.format("%s base health + %s from your bag.", fmtNumber(base), fmtNumber(amount)))
    if bonus ~= 0 then
      add(string.format("%s applies to base health and Health from your bag.", fmtStat("hpPct", bonus)))
      if details then add(string.format("(%s + %s) x %s = %s maximum health.", fmtNumber(base), fmtNumber(amount), fmtNumber(scale), fmtNumber(context.hpMax or Util.Round((base + amount) * scale)))) end
    end
  elseif statKey == "armor" then
    local armor = math.max(0, amount)
    local class = context.classDef or ns.GetClass(context.classKey)
    local base = class and class.baseArmor or 0
    add(string.format("%s base armor + %s from your bag.", fmtNumber(base), fmtNumber(amount - base)))
    add("Reduces damage from physical hits by " .. percent(ns.Sim.ArmorReduction(armor) * 100) .. ".")
    add("Magic damage and bleeds ignore armor.")
    if details then add(string.format("%s / (%s + 200). Capped at 60%% reduction.", fmtNumber(armor), fmtNumber(armor))) end
  elseif statKey == "ap" or statKey == "sp" or statKey == "healing" then
    local name = STAT_LABELS[statKey]
    if statKey == "ap" then
      local class = context.classDef or ns.GetClass(context.classKey)
      local base = class and class.baseAP or 0
      if base ~= 0 then add(string.format("%s base Attack Power + %s from your bag.", fmtNumber(base), fmtNumber(context.stats.ap - base))) end
      add("Strengthens weapon hits and abilities that scale with Attack Power.")
    elseif statKey == "sp" then add("Strengthens magic damage effects that scale with Spell Power.")
    else add("Strengthens healing effects that scale with Healing Power.") end
    if details then add("Added " .. (statKey == "healing" and "healing" or "damage") .. " = " .. name .. " x the effect's scaling percentage.") end
  elseif statKey == "crit" then
    add(string.format("%s%% base + %s%% from your bag.", fmtNumber(ns.Sim.BASE_CRIT), fmtNumber(amount)))
    add("Hits and direct heals can critically strike. Periodic ticks cannot.")
    if details then
      local bonus = math.max(0, 1 + value("critDamage") / 100)
      add(string.format("Physical crits deal %s damage. Magic crits deal %s. Direct heal crits gain 50%%.", percent(200 * bonus), percent(150 * bonus)))
      if ns.Sim.BASE_CRIT + amount ~= ns.Sim.CritChance(amount) then add("Critical strike chance is capped between 0% and 100%.") end
    end
  elseif statKey == "critDamage" then
    add(string.format("Critical hits deal %s%% more damage.", fmtNumber(amount)))
    if details then add("Strengthens critical hits before armor and absorbs. Does not affect healing or periodic ticks.") end
  elseif statKey == "haste" then
    local speed = math.max(0.25, 1 + amount / 100)
    add(string.format("Items recharge %s%% %s.", fmtNumber(math.abs((speed - 1) * 100)), speed >= 1 and "faster" or "slower"))
    add("Does not increase resource regeneration.")
    if details then
      local divisor = string.format("%.3f", speed):gsub("0+$", ""):gsub("%.$", "")
      add(string.format("Recharge time = cooldown / %s. Recharge speed cannot fall below 25%% of normal.", divisor))
    end
  elseif statKey == "dodge" then
    add(string.format("%s%% base + %s%% from your bag.", fmtNumber(ns.Sim.BASE_DODGE), fmtNumber(amount)))
    add("Avoids physical hits. Magic damage and bleeds cannot be dodged.")
    if details then add("Some attacks cannot be dodged. Dodge chance is capped between 0% and 100%.") end
  elseif statKey == "block" then
    add(string.format("Blocks prevent up to %s damage, capped at half of the hit.", fmtNumber(amount)))
    if details then add("Calculated after armor. Only physical hits can be blocked.") end
  elseif statKey == "blockChance" then
    add(percent(chance(amount)) .. " chance to block a physical hit.")
    add("Block Value determines how much damage is prevented.")
    if details then add("Blocks happen after armor and cannot prevent more than half of one hit.") end
  elseif statKey == "thorns" then
    add(string.format("Returns %s damage when the enemy hero hits you in melee.", fmtNumber(amount)))
    if details then add("Pet attacks, ranged attacks, magic damage and bleed ticks do not trigger this retaliation.") end
  elseif statKey == "lifesteal" then
    add("Heals you for " .. percent(amount) .. " of direct damage dealt.")
    add("Damage-over-time ticks do not restore health.")
    if details then add("Uses damage that gets through defenses. Healing cannot exceed your missing health.") end
  elseif statKey == "dr" then
    local reduction = math.min(90, amount)
    add(string.format("%s damage from hits and damage over time by %s.", reduction >= 0 and "Reduces" or "Increases", percent(math.abs(reduction))))
    if details then add("Bonuses add together, up to 90% reduction. Fatigue and flat Thorns retaliation ignore this stat.") end
  end
  return lines
end

function Describe.Short(def)
  if def.spellIntercept then return string.format("Intercept one direct magic spell hit every %ss.", fmtNumber(def.spellIntercept.cooldown)) end
  local lines = Describe.Lines(def, { details = false })
  if def.kind == "weapon" and lines[1] then return lines[1].text end
  local useLine, triggerLine, adjacentLine, passiveLine, plainLine
  for _, line in ipairs(lines) do
    local text = line.text:gsub("^%s+", "")
    if line.role == "effect" then useLine = useLine or text
    elseif line.role == "trigger" then triggerLine = triggerLine or text
    elseif line.role == "adjacency" then adjacentLine = adjacentLine or text
    elseif line.role == "passive" then passiveLine = passiveLine or text
    elseif not line.role and not text:match("^Requires ") and text ~= def.useRestrictionText then plainLine = plainLine or text end
  end
  local text = useLine or triggerLine or adjacentLine or passiveLine or plainLine or ""
  local use = def.use
  if def.useRestrictionText and not use then
    for _, trigger in ipairs(def.triggers or {}) do
      for _, effect in ipairs(trigger.effects) do
        if effect.type == "buff" and effect.stat == "dmgPct" and (effect.value or 0) > 0 then
          text = describeEffect(effect, trigger, false)
          break
        end
      end
    end
  end
  if use and use.needsNeighbor and use.needsNeighbor.kind == "pet" then
    local recovery, delay
    for _, effect in ipairs(use.effects) do
      if effect.type == "resource" and effect.resource == "mana" and effect.amount then recovery = effect.amount end
      if effect.type == "cdr" and effect.target == "neighbors" and effect.match and effect.match.kind == "pet" and effect.amount < 0 then delay = -effect.amount end
    end
    if recovery and delay then text = string.format("Restore %s Mana. Delay the adjacent pet's next attack by %s sec.", fmtNumber(recovery), fmtNumber(delay)) end
  end
  for _, effect in ipairs(use and use.effects or {}) do
    if effect.type == "sacrificePet" then
      if (def.baseKey or def.key) == "demonic_sacrifice" then
        text = "Sacrifice your demon for Fire damage, Shadow damage, healing or Mana regeneration."
      elseif (def.baseKey or def.key) == "sacrifice_voidwalker" then
        text = "Sacrifice your Voidwalker for a shield."
      else
        text = "Sacrifice your demon for its benefit."
      end
      break
    end
  end
  if use and (use.healthCost or use.healthCostPct) then
    local cost = use.healthCost and fmtNumber(use.healthCost) .. " Health" or string.format("%s%% maximum Health", fmtNumber(use.healthCostPct * 100))
    text = string.format("Costs %s. %s", cost, text)
  end
  return text
end

local function standardWeaponUse(def)
  local use = def.use
  if def.kind ~= "weapon" or not use or #use.effects ~= 1 or use.condition or use.requires or use.resource
    or use.healthCost or use.healthCostPct then return false end
  local effect = use.effects[1]
  if effect.type ~= "damage" or not effect.weaponSelf or (effect.school or "physical") ~= "physical" then return false end
  local fields = { type = true, weaponSelf = true, coef = true, school = true, ranged = true }
  for key in pairs(effect) do if not fields[key] then return false end end
  return true
end



local triggerResourceCache, triggerResourceCount = {}, 0
function Describe.TriggerResources(def, filter, selfEvent)
  if triggerResourceCount ~= #ns.ItemList then
    triggerResourceCache, triggerResourceCount = {}, #ns.ItemList
  end
  local ownerKey, filterKey = def or false, filter or false
  local ownerCache = triggerResourceCache[ownerKey]
  if not ownerCache then ownerCache = {} triggerResourceCache[ownerKey] = ownerCache end
  local filterCache = ownerCache[filterKey]
  if not filterCache then filterCache = {} ownerCache[filterKey] = filterCache end
  local eventKey = selfEvent and "self" or "all"
  if filterCache[eventKey] then return filterCache[eventKey] end
  local found = {}
  local function compatible(candidate)
    if not def or not def.classes then return true end
    for _, class in ipairs(def.classes) do
      if ns.ItemAllowedForClass(candidate, class) then return true end
    end
    return false
  end
  local function include(candidate)
    local use = candidate and candidate.use
    if not use or not compatible(candidate) or not Util.MatchDef(candidate, filter) then return end
    if use.resource and (use.cost or 0) > 0 then found[use.resource] = true end
    if (use.comboCost or 0) > 0 and not (use.resource and (use.cost or 0) > 0) then found.combo = true end
  end
  if selfEvent then include(def)
  else for _, candidate in ipairs(ns.ItemList) do include(candidate) end end
  local out = {}
  for _, resource in ipairs({ "mana", "energy", "rage", "focus", "combo" }) do
    if found[resource] then out[#out + 1] = ns.RESOURCE_NAMES[resource] or resource end
  end
  filterCache[eventKey] = out
  return out
end

local function triggerResourceText(def, filter, selfEvent)
  local resources = Describe.TriggerResources(def, filter, selfEvent)
  return #resources > 0 and #resources <= 2 and joinOr(resources) or "resources"
end

local healingTriggerFilter = { healing = true }
local function triggerNoun(def, trig, plural, details)
  local filter = trig.match
  local selfEvent = trig.on == "use" or trig.on == "hit" or trig.on == "crit"
  if not filter and selfEvent then filter = { key = def.baseKey or def.key } end
  local selected = Util.ShallowCopy(filter or {})
  if ((trig.healing == true or trig.on == "healed" or trig.on == "hotTick")
      and (not selected.tag or selected.tag == "spell") and not selected.anyTag)
    or selected.healing == true and not selected.tag then selected.tag = "heal" end
  if selected.tag == "heal" and trig.paidOnly and not trig.match and trig.healing and not selfEvent then selected.tag = nil selected.healing = true end
  if trig.healing == true and SCHOOL_LABELS[selected.tag] and not selected.anyTag then selected.anyTag = { "heal" } end
  local noun = matchNoun(selected, plural)
  local source = selected.key and ns.ItemsByKey[selected.key]
  if source and source.kind == "pet" then noun = "your " .. source.name:gsub("^Summon ", ""):gsub("^Pet: *", "") end
  if selected.healing and (not selected.tag or trig.match and not trig.match.tag) then noun = plural and "healing abilities" or "healing ability" end
  if selected.tag == "primal_generator" then noun = plural and "Bear Form attacks and Maul" or "Bear Form attack or Maul" end
  if trig.on == "anyUse" or trig.on == "use" or trig.on == "adjacentUse" then noun = noun:gsub(",([^,]+) and ", ",%1 or ") end
  if selected.kind == "weapon" and selected.tag == "melee" then noun = "melee weapon attack" .. (plural and "s" or "")
  elseif selected.kind == "weapon" and selected.tag == "ranged" then noun = "ranged weapon attack" .. (plural and "s" or "")
  elseif selected.weaponType then noun = (WEAPON_LABELS[selected.weaponType] or selected.weaponType):lower() .. (plural and " attacks" or " attack")
  elseif selected.anyWeaponType then noun = "ranged weapon attack" .. (plural and "s" or "")
  elseif selected.hands then noun = (selected.hands == 2 and "two-handed" or "one-handed") .. " weapon attack" .. (plural and "s" or "") end
  if trig.on == "adjacentUse" or trig.on == "adjacentHit" or trig.on == "adjacentCrit" then noun = "adjacent " .. noun end
  local namedList = not selected.key and noun:match("^%u") and noun:find(",", 1, true)
  if trig.paidOnly and details ~= false then
    if filter and filter.key or selfEvent or namedList then noun = (plural and "casts of " or "cast of ") .. noun
    elseif noun == "melee attacks" then noun = "melee abilities"
    elseif noun == "melee attack" then noun = "melee ability" end
    local resources = trig.match or (trig.healing == true and not selfEvent and healingTriggerFilter or nil)
    noun = noun .. (plural and " that consume " or " that consumes ") .. triggerResourceText(def, resources, selfEvent and not trig.match)
  elseif namedList and not plural then noun = "cast of " .. noun
  end
  return noun
end

local function triggerArticle(noun, named)
  if named or noun:match("^your ") or noun:match("^this ") then return noun end
  if noun:match("^casts of ") then return "a " .. noun:gsub("^casts of ", "cast of ") end
  return (noun:match("^[AEIOUaeiou]") and "an " or "a ") .. noun
end

local function triggerCondition(trig, activeKey)
  if not trig.condition then return nil end
  if activeKey and trig.condition == "buff:" .. activeKey then return "while active" end
  if type(trig.condition) == "table" then
    local parts = {}
    local specificPet = false
    for _, entry in ipairs(trig.condition) do if type(entry) == "string" and entry:match("^provides:warlock_") then specificPet = true end end
    for _, entry in ipairs(trig.condition) do
      if entry ~= "provides:pet" or not specificPet then
        local text = triggerCondition({ condition = entry }, activeKey)
        if text then
          if #parts > 0 and parts[1]:match("^while ") then text = text:gsub("^while ", "") end
          parts[#parts + 1] = text
        end
      end
    end
    return #parts > 0 and table.concat(parts, " and ") or nil
  end
  local resource, amount = trig.condition:match("^resourceAtLeast:([^:]+):([%d%.]+)$")
  if resource then return "while you have at least " .. fmtNumber(tonumber(amount)) .. " " .. (ns.RESOURCE_NAMES[resource] or resource) end
  resource, amount = trig.condition:match("^resourceAtMost:([^:]+):([%d%.]+)$")
  if resource then return "while you have " .. fmtNumber(tonumber(amount)) .. " or less " .. (ns.RESOURCE_NAMES[resource] or resource) end
  local label = conditionLabel(trig.condition, true)
  if not label then return nil end
  if label:match("^In ") then return "while " .. label:gsub("^In ", "in ") end
  if label:match("^If the enemy ") then return label:gsub("^If the enemy ", "while the enemy ") end
  if label:match("^Below ") then return label:gsub("^Below ", "while you are below ") end
  if label:match("^At least ") then return "with " .. label:gsub("^At least ", "at least ") end
  if label:match("^At ") then return "while " .. label:gsub("^At ", "at ") end
  return label:gsub("^%u", string.lower)
end

local function triggerIntro(def, trig, context, sharedShadow)
  local on = trig.on
  local details = not context or context.details ~= false
  local paidOnly = trig.paidOnly and details
  local noun = triggerNoun(def, trig, false, details)
  local many = triggerNoun(def, trig, true, details)
  local named = trig.match and trig.match.key or on == "use" or on == "hit" or on == "crit"
  local source = triggerArticle(noun, named and not paidOnly)
  if not paidOnly and noun:match("^cast of ") then source = noun:gsub("^cast of ", "") end
  local namedSource = trig.match and trig.match.key and matchNoun(trig.match, false)
    or (on == "use" or on == "hit" or on == "crit") and def.name or nil
  if not namedSource and trig.match and noun:match("^cast of ") then namedSource = matchNoun(trig.match, false) end
  local consumption = paidOnly and namedSource and " consumes " .. triggerResourceText(def, trig.match, not trig.match) or nil
  local resourceEvent = on == "resourceSpent" or on == "resourceGained" or on == "resourceOverflow"
  local ordinal = ({ "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth" })[trig.every]
  local counted = ordinal and not paidOnly and (trig.every == 1 and "Every" or "Every " .. ordinal)
  if resourceEvent then
    local resource = trig.resource
    if not resource and context and context.res then
      for key in pairs(context.res) do if resource then resource = nil break end resource = key end
    end
    local name = ns.RESOURCE_NAMES[resource] or resource or "resources"
    local scope = trig.match and (on == "resourceSpent" and " on " or " from ") .. matchNoun(trig.match, true) or ""
    if trig.every then return "After you " .. (on == "resourceSpent" and "spend " or "gain ") .. name .. scope .. " " .. trig.every .. " times" end
    if on == "resourceOverflow" then
      return trig.everyAmount and "For every " .. fmtNumber(trig.everyAmount) .. " " .. name .. " gained above your maximum"
        or "When you gain " .. name .. " above your maximum"
    end
    local verb = on == "resourceSpent" and "spend" or "gain"
    return trig.everyAmount and "For every " .. fmtNumber(trig.everyAmount) .. " " .. name .. " you " .. verb .. scope
      or "When you " .. verb .. " " .. name .. scope
  end
  if sharedShadow then return "After any combination of " .. trig.every .. " Shadow hits and damage-over-time ticks" end
  if trig.everyAmount then
    local amount = fmtNumber(trig.everyAmount)
    local event = ({ damaged = "damage taken", block = "damage blocked", absorbed = "damage absorbed by your shields",
      armorPrevented = "damage prevented by Armor", healthSpent = "Health you spend" })[on]
    if on == "hotTick" then event = "Health restored by healing ticks" .. ((trig.match or trig.paidOnly) and " from " .. many or "")
    elseif on == "healed" then event = "Health restored" .. ((trig.match or trig.paidOnly) and " by " .. many or "")
    elseif on == "dotTick" then event = "damage dealt over time" .. ((trig.match or trig.paidOnly) and " by " .. many or "") end
    return "For every " .. amount .. " " .. (event or "damage dealt")
  end
  if on == "regularHit" then
    local filter = trig.match or {}
    local kind = filter.weaponType and (WEAPON_LABELS[filter.weaponType] or filter.weaponType):lower()
      or filter.tag == "melee" and "melee" or filter.tag == "ranged" and "ranged"
      or filter.hands == 2 and "two-handed" or filter.hands == 1 and "one-handed"
      or filter.anyWeaponType and "ranged" or nil
    local attack = (kind and kind .. " " or "") .. "auto-attack"
    if counted then return counted .. " " .. attack .. " hit" end
    return trig.every and "After every " .. trig.every .. " " .. attack .. " hits" or "When " .. triggerArticle(attack) .. " hits"
  end
  if trig.regularAttackOnly then
    local weapon = noun:gsub(" attacks?$", "")
    local sourceWeapon = triggerArticle(weapon, trig.match and trig.match.key)
    return trig.every and "After every " .. trig.every .. " auto-attack hits from " .. sourceWeapon
      or "When an auto-attack from " .. sourceWeapon .. " hits"
  end
  if trig.every then
    local count = tostring(trig.every)
    if counted then
      if on == "dotTick" then
        local tag = trig.match and trig.match.tag
        if tag == "burn" or tag == "bleed" then return counted .. " " .. tag .. " tick" end
        if trig.match and trig.match.key then return counted .. " " .. many .. " damage tick" end
        return counted .. " periodic damage tick" .. (trig.match and " from " .. many or "")
      end
      if on == "hotTick" then return counted .. " healing tick" .. (trig.match and " from " .. many or "") end
      if on == "anyCrit" or on == "adjacentCrit" or on == "crit" then
        return counted .. " critical " .. (trig.healing and "heal" or "strike") .. " with " .. many
      end
      if on == "anyUse" or on == "adjacentUse" or on == "use" then
        local source = trig.match and trig.match.key and ns.ItemsByKey[trig.match.key]
          or not trig.match and on == "use" and def
        if source and source.tagSet.spell then return counted .. " " .. source.name .. " cast" end
        return counted .. " use of " .. many:gsub("^casts of ", "")
      end
      if on == "block" then return counted .. " attack you block" end
      if many:match("^your ") then return counted .. " hit by " .. many end
      return counted .. " hit" .. ((trig.match or on == "hit") and " with " .. many or "")
    end
    if on == "dotTick" then return "After every " .. count .. " periodic damage ticks from " .. many end
    if on == "hotTick" then return "After every " .. count .. " healing ticks" .. (trig.match and " from " .. many or "") end
    if on == "anyCrit" or on == "adjacentCrit" or on == "crit" then
      return "After every " .. count .. " critical "
        .. (trig.healing and "heals" or "strikes") .. " with " .. many
    end
    if on == "anyUse" or on == "adjacentUse" or on == "use" then return "After every " .. count .. " uses of " .. many:gsub("^casts of ", "") end
    if on == "block" then return "After every " .. count .. " attacks you block" end
    return "After every " .. count .. " hits" .. ((trig.match or on == "hit") and " with " .. many or "")
  end
  if on == "battleStart" then return "At the start of combat" end
  if on == "channelComplete" then return "After you finish channeling " .. (trig.match and noun or def.name) end
  if on == "coatingApplied" then return "When you apply a poison" end
  if on == "use" or on == "anyUse" or on == "adjacentUse" then
    return consumption and "When " .. namedSource .. consumption or "When you use " .. source
  end
  if on == "crit" or on == "anyCrit" or on == "adjacentCrit" then
    if consumption then
      return "When " .. namedSource .. consumption .. " and " .. (trig.healing and "critically heals you" or "critically strikes")
    end
    if not trig.match and on == "anyCrit" and not paidOnly then
      if trig.healing then return "When you critically heal" end
      return "When you critically strike"
    end
    return "When " .. source .. (trig.healing and " critically heals you" or " critically strikes")
  end
  if on == "hit" or on == "anyHit" or on == "adjacentHit" or on == "extraHit" then
    if on == "extraHit" then return "When an extra attack hits" end
    if consumption then return "When " .. namedSource .. consumption .. " and " .. (trig.effective and "deals damage" or "hits") end
    if not trig.match and on == "anyHit" and not paidOnly then return trig.effective and "When you deal damage" or "When you hit an enemy" end
    return "When " .. source .. (trig.effective and " deals damage" or " hits")
  end
  if on == "healed" then
    if consumption then return "When " .. namedSource .. consumption .. (trig.effective and " and restores Health" or " and heals you") end
    if not trig.match and not paidOnly then return "When you receive healing" end
    return "When " .. source .. (trig.effective and " restores Health" or " heals you")
  end
  if on == "hotTick" then return "When a healing tick" .. ((trig.match or trig.paidOnly) and " from " .. source or "") .. (trig.effective and " restores Health" or " heals you") end
  if on == "dotTick" then return "When " .. ((trig.match or trig.paidOnly) and source or "a damage-over-time effect") .. " deals periodic damage" end
  if on == "damaged" then
    if trig.critical == true then return "When you are critically hit" end
    if trig.critical == false then return "When a hit against you does not critically strike" end
    return "When you take damage"
  end
  if on == "block" then return "When you block an attack" end
  if on == "absorbed" then return "When your shields absorb damage" end
  if on == "armorPrevented" then return "When your Armor prevents damage" end
  if on == "healthSpent" then return "When you spend Health" .. (trig.match and " through " .. matchNoun(trig.match, false) or "") end
  if on == "dodged" then return "When you dodge an attack" end
  if on == "targetDodged" then return "When the enemy dodges" .. (trig.match and " " .. source or " an attack") end
  if on == "enemyStunned" then return trig.match and "When " .. source .. " applies crowd control" or "When you apply crowd control" end
  if on == "lowHealth" then return "The first time you fall below 35% Health" end
  if on == "below40" then return "When you fall below 40% Health" end
  if on == "stunned" then
    local labels = { fear = "feared", charm = "charmed", sleep = "put to sleep", stun = "stunned", freeze = "frozen", horror = "horrified" }
    local controls = {}
    for _, control in ipairs(trig.controlTypes or { "stun" }) do controls[#controls + 1] = labels[control] or control end
    return "When you are " .. joinOr(controls)
  end
  return "When this effect triggers"
end

local function triggerOutcome(text)
  local condition, action = text:match("^([Ii]f .-), (.+)$")
  if not condition then condition, action = text:match("^([Ii]n .-), (.+)$") end
  if not condition then condition, action = text:match("^([Ww]hile .-), (.+)$") end
  if not condition then condition, action = text:match("^([Aa]t .-), (.+)$") end
  if not condition then condition, action = text:match("^([Bb]elow .-), (.+)$") end
  if condition then
    local clause, note = triggerOutcome(action)
    local label = condition:gsub("^%u", string.lower):gsub(" when cast$", "")
    if label:match("^in ") or label:match("^at ") or label:match("^below ") then label = "while " .. label end
    return clause .. " " .. label, note
  end
  local first, rest = text:match("^(.-)%.%s+(.+)$")
  first, rest = first or text:gsub("%.$", ""), rest or ""
  local verbs = { Restore = "restore", Restores = "restore", Gain = "gain", Awards = "gain", Heal = "heal", Heals = "heal",
    Deal = "deal", Deals = "deal", Trigger = "trigger", Cast = "cast", Reduce = "reduce", Reset = "reset", Delay = "delay",
    Add = "add", Adds = "add", Absorb = "absorb", Absorbs = "absorb", Remove = "remove", Removes = "remove",
    Spend = "spend", Recover = "recover", Consume = "consume", Make = "make", Sacrifice = "sacrifice",
    Stuns = "stun", Freezes = "freeze", Fears = "fear", Charms = "charm", Puts = "put", Horrifies = "horrify", Incapacitates = "incapacitate",
    Apply = "apply", Applies = "apply", Cause = "cause", Causes = "cause", Store = "store", Stores = "store", Take = "take", Steal = "steal", Drain = "drain", Prevent = "prevent", Refresh = "refresh", Enter = "enter",
    Consumes = "consume", Prevents = "prevent", Refund = "regain", Refunds = "regain", Repeat = "repeat", Repeats = "repeat", Refreshes = "refresh", Recover = "recover", Recovers = "recover", Drains = "drain", Steals = "steal" }
  local verb, tail = first:match("^(%a+)%s+(.*)$")
  local lookup = verb and verb:gsub("^%l", string.upper)
  if lookup and verbs[lookup] then first = "you " .. verbs[lookup] .. " " .. tail
  else
    local active, duration = first:match("^(.+) active(.*)$")
    if active then first = "you gain " .. active .. duration
    else first = first:gsub("^Your ", "your "):gsub("^The ", "the "):gsub("^Enemy ", "the enemy ")
      :gsub("^Melee ", "melee "):gsub("^Ranged ", "ranged "):gsub("^Weapon ", "weapon ")
      :gsub("^Spells ", "spells "):gsub("^Marked ", "marked "):gsub("^Auto%-attacks ", "auto-attacks ")
      :gsub("^Opening attacks ", "opening attacks "):gsub("^Damage%-over%-time spells ", "damage-over-time spells ") end
  end
  return first, rest
end

local function triggerConstant(trig)
  if trig.on ~= "battleStart" or trig.chance or trig.every or trig.everyAmount or #trig.effects == 0 then return false end
  for _, effect in ipairs(trig.effects) do
    if (effect.type ~= "buff" and effect.type ~= "debuff") or effect.charges or (effect.duration or 0) < ns.Sim.MAX_TIME then return false end
  end
  return true
end

local function chanceSentence(def, trig, parts, details, condition)
  if not trig.chance or trig.every or trig.everyAmount or trig.effective or trig.matchAttacker
    or trig.regularAttackOnly or trig.paidOnly and details then return nil end
  local subject, singular
  local on = trig.on
  local many = triggerNoun(def, trig, true, details)
  if on == "regularHit" then
    local source = triggerIntro(def, trig, { details = details }):match("^When an? (.-) hits$")
    if not source then return nil end
    subject = source:gsub("auto%-attack$", "auto-attacks")
  elseif on == "hit" and not trig.match then
    subject, singular = "Each hit", true
  elseif on == "anyHit" or on == "adjacentHit" then
    subject = trig.match and trig.match.key and "Hits with " .. many or "Your " .. many
    if not trig.match then subject = "Your hits" end
    if many:match("^your ") then subject = many:gsub("^your ", "Your ") .. "'s hits" end
  elseif on == "anyCrit" or on == "adjacentCrit" then
    subject = trig.healing and "Your critical heals" or "Your critical strikes"
    if trig.match then subject = subject .. " with " .. many end
  elseif on == "dotTick" then
    subject, singular = "Periodic damage" .. (trig.match and " from " .. many or ""), true
  elseif on == "damaged" then
    subject, singular = trig.critical == true and "Critical hits against you" or "Damage taken", trig.critical ~= true
    if trig.critical == false then subject, singular = "Non-critical hits against you", false end
  else
    return nil
  end
  local gerunds = { gain = "granting you", restore = "restoring", heal = "healing", deal = "dealing", reduce = "reducing",
    increase = "increasing", reset = "resetting", stun = "stunning", freeze = "freezing", cast = "casting",
    trigger = "triggering", add = "adding", store = "storing", consume = "consuming", drain = "draining", steal = "stealing",
    apply = "applying", remove = "removing", refresh = "refreshing" }
  local actions = {}
  for _, part in ipairs(parts) do
    local verb, tail = part:match("^you (%a+) (.+)$")
    local action
    if gerunds[verb] then
      local extraAttack = verb == "trigger" and tail:find("extra melee attack", 1, true)
      action = (extraAttack and "granting you" or gerunds[verb]) .. " " .. tail:gsub("^%+", "")
    else
      local target, bonus = part:match("^(.-) gains? (.+)$")
      if target then action = "granting " .. target .. " " .. bonus
      else
        local target, cost = part:match("^(your .-) costs? (.+)$")
        if target then action = "making " .. target .. " cost " .. cost end
      end
    end
    if not action then return nil end
    actions[#actions + 1] = action
  end
  if #actions == 0 then return nil end
  local chance = fmtNumber(trig.chance)
  local article = chance:match("^8") or trig.chance >= 11 and trig.chance < 12 or trig.chance >= 18 and trig.chance < 19
  local text = subject .. (singular and " has " or " have ") .. (article and "an " or "a ") .. chance .. "% chance of " .. joinAnd(actions)
  if condition then text = condition:gsub("^%l", string.upper) .. ", " .. text:gsub("^%u", string.lower) end
  return text
end

local function combinedTrigger(first, second)
  if first.every or first.everyAmount or first.oncePerActivation then return nil end
  local compared = Util.ShallowCopy(second)
  compared.on = first.on
  if not sameEffect(first, compared) then return nil end
  local events = { [first.on] = true, [second.on] = true }
  if first.on == second.on then return nil end
  local result = {}
  if events.block and events.dodged then
    for _, effect in ipairs(first.effects) do if effect.fromEvent then return nil end end
    result.intro = "When you block or dodge an attack"
    if first.icd and not first.counterKey then
      result.cooldown = "Separate " .. fmtNumber(first.icd) .. " sec cooldowns for blocking and dodging."
    end
  elseif events.anyHit and events.dotTick then
    local effect, filter = first.effects[1], first.match
    if #first.effects ~= 1 or not filter or not SCHOOL_LABELS[filter.tag]
      or not sameEffect(first, { on = first.on, match = filter, effects = first.effects })
      or not sameEffect(filter, filter.kind and { kind = "ability", tag = filter.tag } or { tag = filter.tag })
      or not sameEffect(effect, { type = "heal", fromEvent = effect.fromEvent, noCrit = true }) or not effect.fromEvent then return nil end
    local school, amount = SCHOOL_LABELS[filter.tag], fmtNumber(effect.fromEvent * 100)
    result.text = filter.kind and "Your " .. school .. " abilities heal you for " .. amount .. "% of the damage they deal"
      or "Your " .. school .. " damage heals you for " .. amount .. "% of the damage dealt"
  elseif events.anyUse and events.channelComplete then
    local source = first.match and first.match.key and ns.ItemsByKey[first.match.key]
    if not source or not source.use or not source.use.channel
      or not sameEffect(first, { on = first.on, match = first.match, effects = first.effects }) then return nil end
    result.intro = "When you begin or finish channeling " .. source.name
  else
    return nil
  end
  if first.icd and not result.cooldown then
    if not first.counterKey then return nil end
    result.cooldown = "Once every " .. fmtNumber(first.icd) .. " sec."
  end
  return result
end

local function extraAttackSummary(def, details, context)
  if #def.triggers ~= 3 then return nil end
  local attacks = {}
  for _, trig in ipairs(def.triggers) do
    if attacks[trig.on] then return nil end
    attacks[trig.on] = trig
  end
  local regular, extra, strike = attacks.regularHit, attacks.extraHit, attacks.anyHit
  if not regular or not extra or not strike or not regular.chance or not extra.chance
    or strike.chance ~= regular.chance or #regular.effects ~= 1 or regular.effects[1].type ~= "extraAttack"
    or not sameEffect(regular.match, { tag = "melee" })
    or not sameEffect(extra.match, { kind = "weapon", anyTag = { "autoattack" }, tag = "melee" })
    or not strike.match or not strike.match.key
    or not sameEffect(strike.match, { key = strike.match.key, kind = "ability", tag = "melee" }) then return nil end
  local source = ns.ItemsByKey[strike.match.key]
  if not source then return nil end
  for _, trig in ipairs({ regular, extra, strike }) do
    if not sameEffect(trig, { on = trig.on, match = trig.match, chance = trig.chance, effects = regular.effects }) then return nil end
  end
  local action = describeEffect(regular.effects[1], regular, details, context, def)
  if not action:match("^Trigger ") then return nil end
  action = action:gsub("^Trigger ", "granting you ")
  return {
    "Melee auto-attacks and " .. source.name .. " have a " .. fmtNumber(regular.chance) .. "% chance of " .. action,
    "Extra attacks have a " .. fmtNumber(extra.chance) .. "% chance of triggering this effect.",
  }
end

local function passiveTrigger(trigger)
  if trigger.on ~= "battleStart" or (trigger.condition and trigger.condition ~= "dualwield") or trigger.chance or trigger.everyAmount then return false end
  if #trigger.effects == 0 then return false end
  for _, effect in ipairs(trigger.effects) do
    if (effect.type ~= "buff" and effect.type ~= "debuff") or effect.charges or (effect.duration or 0) < ns.Sim.MAX_TIME then return false end
  end
  return true
end

function Describe.Lines(def, context)
  local details = not context or context.details ~= false
  local lines = {}
  local function add(text, color, role)
    lines[#lines + 1] = { text = text, color = color, role = role }
  end
  local white = { r = 1, g = 1, b = 1 }
  local green = { r = 0.1, g = 1, b = 0.1 }
  local gold = { r = 1, g = 0.82, b = 0 }
  local grey = { r = 0.6, g = 0.6, b = 0.6 }

  if def.kind == "weapon" then
    local speed = def.use and def.use.cd or 2
    local dps = ((def.weaponMin or 0) + (def.weaponMax or 0)) / 2 / speed
    local scaling = ""
    if standardWeaponUse(def) and (def.use.effects[1].coef or 0) > 0 then
      scaling = " (+" .. fmtNumber(def.use.effects[1].coef * 100) .. "% Attack Power)"
    end
    add(string.format("%d - %d Damage%s   Speed %.1f", def.weaponMin or 0, def.weaponMax or 0, scaling, speed), white)
    add(string.format("(%.1f damage per second)", dps), white)
  end
  for _, line in ipairs(describeStats(def.stats)) do add(line, white) end
  if def.lethalSave then
    add(string.format("Once per battle, survive lethal damage and recover %s%% maximum health.", fmtNumber(def.lethalSave.health * 100)), green)
    add(string.format("Lose %s%% maximum health per second for %ss.", fmtNumber(def.lethalSave.health * 100 / def.lethalSave.duration), fmtNumber(def.lethalSave.duration)), gold)
    for _, effect in ipairs(def.lethalSave.effects or {}) do add(describeEffect(effect, nil, details), green) end
  end
  if def.revive then
    local text = string.format("Once per battle, revive with %s%% maximum health", fmtNumber(def.revive.health * 100))
    if def.revive.mana then text = text .. string.format(" and %s%% maximum Mana", fmtNumber(def.revive.mana * 100)) end
    add(text .. ".", green)
  end
  if def.kind == "bag" then
    add(string.format("%d Slot Bag", def.cellCount), white)
  end
  if def.coating then
    add("Adjacent melee weapons apply this poison. Each weapon can have one poison.", green, "adjacency")
  end
  if def.useRestrictionText then add(def.useRestrictionText, { r = 1, g = 0.4, b = 0.4 }) end
  if def.spellIntercept then
    add(string.format("Intercept one direct magic spell hit every %ss.", fmtNumber(def.spellIntercept.cooldown)), green)
  end
  if def.wardReflection then
    local rule = def.wardReflection
    local ward = ns.ItemsByKey[rule.key]
    add(string.format("While %s is active: %s%% chance to reflect a direct %s hit. Once per ward.", ward and ward.name or rule.key,
      fmtNumber(rule.chance), rule.school == "magic" and "magic" or (rule.school:gsub("^%l", string.upper))), green)
  end
  local gearGroups, gearOrder = {}, {}
  for _, bonus in ipairs(def.gearBonuses or {}) do
    if bonus.stat == bonus.gearStat then
      if not gearGroups[bonus.coef] then gearGroups[bonus.coef] = {} gearOrder[#gearOrder + 1] = bonus.coef end
      gearGroups[bonus.coef][#gearGroups[bonus.coef] + 1] = STAT_LABELS[bonus.stat] or bonus.stat
    else
      add(string.format("Gain %s%% of %s on equipped items as %s.", fmtNumber(bonus.coef * 100), STAT_LABELS[bonus.gearStat] or bonus.gearStat,
        STAT_LABELS[bonus.stat] or bonus.stat), green)
    end
  end
  for _, coefficient in ipairs(gearOrder) do
    add(string.format("Gain %s%% more %s from equipped items.", fmtNumber(coefficient * 100), table.concat(gearGroups[coefficient], ", ")), green)
  end
  if def.grants then
    local resources, included, capacities = {}, {}, {}
    for _, res in ipairs({ "mana", "energy", "rage", "focus", "combo" }) do
      if def.grants[res] then resources[#resources + 1], included[res] = res, true end
    end
    for _, res in ipairs(Util.SortedKeys(def.grants)) do if not included[res] then resources[#resources + 1] = res end end
    for _, res in ipairs(resources) do
      local cfg = def.grants[res]
      capacities[#capacities + 1] = fmtNumber(cfg.max) .. " " .. (ns.RESOURCE_NAMES[res] or res)
    end
    if #capacities > 0 then
      local text = #capacities == 1 and capacities[1] or table.concat(capacities, ", ", 1, #capacities - 1) .. " and " .. capacities[#capacities]
      add("Grants " .. text .. ".", white)
    end
    local showRegen = def.kind ~= "form" and def.kind ~= "pet"
    if showRegen then
      for _, res in ipairs(resources) do
        local cfg = def.grants[res]
        if (cfg.regen or 0) > 0 then add(string.format("Regenerates %s %s per second.", fmtNumber(cfg.regen), ns.RESOURCE_NAMES[res] or res), white) end
      end
    end
    if details then
      for _, res in ipairs(resources) do
        local cfg = def.grants[res]
        local text = string.format("Starts with %s %s.", fmtNumber(cfg.start or 0), ns.RESOURCE_NAMES[res] or res)
        if not showRegen and (cfg.regen or 0) > 0 then text = text .. string.format(" Regenerates %s per second.", fmtNumber(cfg.regen)) end
        add(text, grey, "detail")
      end
    end
  end
  if def.provides then
    local list = type(def.provides) == "table" and def.provides or { def.provides }
    local provided = Util.Set(list)
    for _, p in ipairs(list) do
      local used = false
      for _, candidate in ipairs(ns.ItemList) do
        local required = candidate.use and candidate.use.requires
        for _, flag in ipairs(type(required) == "table" and required or { required }) do
          if flag == p then used = true break end
        end
        if used then break end
      end
      if used and p ~= "aspect" and not (p == "feralform" and (provided.catform or provided.bearform)) and REQUIRE_LABELS[p] then
        local label = REQUIRE_LABELS[p]:gsub("^a ", ""):gsub("^an ", "")
        add("Enables " .. label .. " abilities.", white)
      end
    end
  end
  local use = def.use
  local ward = not details and chargeWard(def)
  local activeKey
  if not details and use and #use.effects == 1 and use.effects[1].type == "buff" and use.effects[1].stat == "none" then activeKey = use.effects[1].key end
  if use and (details or not standardWeaponUse(def)) then
    if use.needsNeighbor then
      local recipient = use.needsNeighbor.kind == "pet" and "an active pet" or "a " .. matchNoun(use.needsNeighbor, false)
      add("Requires " .. recipient .. " in an adjacent slot.", { r = 1, g = 0.4, b = 0.4 }, "detail")
    end
    local initial = ns.Sim.InitialCooldown(use)
    if use.condition and not use.once then
      add("Cooldown: " .. fmtNumber(use.cd) .. "s", gold, "timing")
    elseif details then
      if use.once or math.abs(initial - use.cd) >= 1e-7 then add("Initial cooldown: " .. fmtNumber(initial) .. "s", gold, "timing") end
      add(use.once and "Once per battle" or ("Cooldown: " .. fmtNumber(use.cd) .. "s"), gold, "timing")
    elseif use.once then
      add(initial <= 0 and (use.condition and "Once per battle" or "On battle start (once per battle)") or ("Once per battle (" .. fmtNumber(initial) .. "s delay)"), gold, "timing")
    elseif initial <= 0 then
      add("On battle start and every " .. fmtNumber(use.cd) .. "s", gold, "timing")
    elseif math.abs(initial - use.cd) < 1e-7 then
      add("Cooldown: " .. fmtNumber(use.cd) .. "s", gold, "timing")
    else
      add("Cooldown: " .. fmtNumber(initial) .. "s / " .. fmtNumber(use.cd) .. "s", gold, "timing")
    end
    if use.channel then
      add("Channeled: " .. fmtNumber(use.channel.duration) .. "s", gold, "timing")
      if details then add("Cannot attack or cast other spells while channeling.", grey, "detail") end
    end
    if use.prepare then
      add("Cast time: " .. fmtNumber(use.prepare) .. "s", gold, "timing")
      if details then add("Interrupted by crowd control.", grey, "detail") end
    end
    if use.delay then add("Detonates after " .. fmtNumber(use.delay) .. "s.", gold, "timing") end
    if def.actor == "pet" then add(details and "Pet ability. Usable while channeling." or "Pet ability.", grey, "detail") end
    local costs = {}
    if use.resource and (use.spendAll or use.cost and use.cost > 0) then
      if use.spendAll then
        costs[#costs + 1] = "Consumes all " .. (ns.RESOURCE_NAMES[use.resource] or use.resource)
          .. ((use.cost or 0) > 0 and string.format(" (minimum %d)", use.cost) or "")
      elseif use.spendMax then
        costs[#costs + 1] = string.format("%d-%d %s", use.cost, use.spendMax, ns.RESOURCE_NAMES[use.resource] or use.resource)
      else
        costs[#costs + 1] = string.format("%d %s", use.cost, ns.RESOURCE_NAMES[use.resource] or use.resource)
      end
    end
    if use.healthCost or use.healthCostPct then
      local cost = use.healthCost and fmtNumber(use.healthCost) or string.format("%s%% maximum", fmtNumber(use.healthCostPct * 100))
      costs[#costs + 1] = cost .. " Health"
    end
    if #costs > 0 then add(table.concat(costs, ", "), white, "cost") end
    if use.comboCost then
      add(use.spendCombo and string.format("Consumes all Combo Points (minimum %d).", use.comboCost)
        or string.format("Consumes %d Combo Points.", use.comboCost), white, "cost")
    end
    if ward then
      add(string.format("Gain %s charges for %s sec.", fmtNumber(ward.charge.amount), fmtNumber(ward.buff.duration)), green, "effect")
    else
      for _, text in ipairs(effectLines(use.effects, nil, use.resource, details, context, def)) do add(text, green, "effect") end
    end
    if use.empower then
      local source = ns.ItemsByKey[use.empower.key]
      local owned = false
      for _, it in ipairs(context and context.items or {}) do
        if it.def and not it.suppressed and (it.def.baseKey or it.def.key) == use.empower.key then owned = true break end
      end
      if details or not context or not context.items or owned then
        add(string.format("  Spend %d extra %s per %s charge for an extra hit, up to %d extra hits.", use.empower.cost, ns.RESOURCE_NAMES[use.resource] or use.resource,
          source and source.name or use.empower.key, use.empower.max or 3), green)
      end
    end
    local useCondition = use.condition and conditionLabel(use.condition, not details)
    if ward then useCondition = nil end
    if useCondition then
      useCondition = useCondition:gsub(", While ", " and while "):gsub(", Against ", " and against ")
      local requiredBuff = type(use.condition) == "string" and use.condition:match("^buff:(.+)$")
      if requiredBuff then useCondition = "Requires " .. statusName(requiredBuff) .. " to be active"
      elseif useCondition:match("^Below ") then useCondition = useCondition:gsub("^Below ", "Activates below ")
      elseif useCondition:match("^While ") then useCondition = useCondition:gsub("^While ", "Activates while ")
      elseif useCondition:match("^Against ") then useCondition = useCondition:gsub("^Against ", "Only usable against ") end
      add(useCondition .. ".", grey, "detail")
    end
    if use.minRecovering then add("Requires a marked spell with at least " .. fmtNumber(use.minRecovering * 100) .. "% of its cooldown remaining.", grey, "detail") end
    if use.prefer then add("  Waits up to " .. fmtNumber(use.prefer.wait) .. "s for the enemy to be stunned or incapacitated.", grey) end
    if use.interruptChannel then add("  Interrupts your current channel.", grey) end
    if use.requires then
      local list = type(use.requires) == "table" and use.requires or { use.requires }
      local required = Util.Set(list)
      local specificPet = required.warlock_imp or required.warlock_voidwalker or required.warlock_succubus or required.warlock_felhunter
        or required.cat or required.wolf or required.turtle
      local parts = {}
      for _, r in ipairs(list) do
        local implied = (r == "melee" and (required.twohand or required.dualwield))
          or (r == "weapon" and (required.melee or required.twohand or required.dualwield or required.ranged))
          or (r == "pet" and (specificPet or use.needsNeighbor and use.needsNeighbor.kind == "pet"))
        if not implied and (not context or not context.provides or not context.provides[r]) then parts[#parts + 1] = REQUIRE_LABELS[r] or r end
      end
      if #parts > 0 then add("  Requires " .. table.concat(parts, " and ") .. ".", { r = 1, g = 0.4, b = 0.4 }) end
    end
  end
  local sharedCooldowns, emittedCooldowns, spendingIntros, combinedTriggers, triggerGroups = {}, {}, {}, {}, {}
  for index, trig in ipairs(def.triggers) do
    if trig.counterKey and trig.icd then sharedCooldowns[trig.counterKey] = (sharedCooldowns[trig.counterKey] or 0) + 1 end
    if not combinedTriggers[trig] and trig.on == "resourceSpent" and trig.counterKey and trig.resource and trig.everyAmount then
      local costs, resources = { fmtNumber(trig.everyAmount) .. " " .. (ns.RESOURCE_NAMES[trig.resource] or trig.resource) }, { [trig.resource] = true }
      for otherIndex = index + 1, #def.triggers do
        local other = def.triggers[otherIndex]
        if not combinedTriggers[other] and other.resource and other.everyAmount and not resources[other.resource] then
          local compared = Util.ShallowCopy(other)
          compared.resource, compared.everyAmount = trig.resource, trig.everyAmount
          if sameEffect(trig, compared) then
            costs[#costs + 1] = fmtNumber(other.everyAmount) .. " " .. (ns.RESOURCE_NAMES[other.resource] or other.resource)
            resources[other.resource], combinedTriggers[other] = true, true
          end
        end
      end
      if #costs > 1 then spendingIntros[trig] = "For every " .. joinOr(costs) .. " spent" end
    end
    if not combinedTriggers[trig] then
      for otherIndex = index + 1, #def.triggers do
        local other = def.triggers[otherIndex]
        local group = not combinedTriggers[other] and combinedTrigger(trig, other)
        if group then
          triggerGroups[trig], combinedTriggers[other] = group, true
          break
        end
      end
    end
  end
  local extraAttacks = extraAttackSummary(def, details, context)
  for _, trig in ipairs(def.triggers) do
    local effect = trig.effects[1]
    local sharedShadow = trig.counterKey == "priest_shadow_weaving"
    local petRecovery = trig.on == "damaged" and trig.condition == "provides:pet" and #trig.effects == 1
      and not (trig.chance or trig.every or trig.everyAmount or trig.icd or trig.matchAttacker or trig.match)
      and effect.type == "cdr" and effect.target == "all" and effect.match and effect.match.kind == "pet"
    if extraAttacks then
      if trig == def.triggers[1] then
        for _, text in ipairs(extraAttacks) do add(text, green, "trigger") end
      end
    elseif combinedTriggers[trig] or sharedShadow and trig.on == "anyHit" then

    elseif (details or not trig.detail) and petRecovery then
      local pet = def.classes and #def.classes == 1 and def.classes[1] == "WARLOCK" and "demon" or "pet"
      add(string.format("While your %s is active, taking damage reduces its attack cooldown by %s sec.", pet, fmtNumber(effect.amount)), green, "trigger")
    elseif details or not trig.detail then
      local passive = passiveTrigger(trig) or triggerConstant(trig)
      local group = triggerGroups[trig]
      local condition = triggerCondition(trig, activeKey)
      local effects = trig.effects
      if ward and trig == ward.trigger then
        condition = nil
        effects = { trig.effects[1], trig.effects[2] }
      end
      local parts, notes = {}, {}
      for _, text in ipairs(effectLines(effects, trig, nil, details, context, def)) do
        if text ~= "" and not text:match("^%s*Adjacent effects:") then
          local clause, note = triggerOutcome(text)
          parts[#parts + 1] = clause
          if note ~= "" then notes[#notes + 1] = note end
        end
      end
      local function join(parts)
        if #parts < 2 then return parts[1] or "" end
        return table.concat(parts, ", ", 1, #parts - 1) .. " and " .. parts[#parts]
      end
      local text
      local chance = chanceSentence(def, trig, parts, details, condition)
      local manaBonus = trig.on == "resourceGained" and trig.resource == "mana" and trig.match and trig.match.key
        and #trig.effects == 1 and effect.type == "resource" and effect.resource == "mana" and effect.fromEvent
        and sameEffect(trig, { on = "resourceGained", resource = "mana", match = { key = trig.match.key }, effects = trig.effects })
        and sameEffect(effect, { type = "resource", resource = "mana", fromEvent = effect.fromEvent })
      if chance then
        text = chance
      elseif manaBonus then
        local source = ns.ItemsByKey[trig.match.key]
        text = (source and source.name or trig.match.key) .. " restores " .. fmtNumber(effect.fromEvent * 100) .. "% more Mana"
        if details then notes[#notes + 1] = "Bonus Mana is based on the amount actually restored." end
      elseif group and group.text then
        text = group.text
        if condition then text = condition:gsub("^%l", string.upper) .. ", " .. text:gsub("^%u", string.lower) end
      elseif passive then
        text = join(parts):gsub("^you ", ""):gsub(", you ", ", "):gsub(" and you ", " and ")
        if #trig.effects == 1 and effect.type == "buff" and effect.stat == "crit" and effect.target == "all"
          and effect.match and effect.match.tag == "melee" then
          text = "increases your melee critical strike chance by " .. fmtNumber(effect.value) .. "%"
        end
        if condition then text = condition:gsub("^%l", string.upper) .. ", " .. text end
      elseif effect.type == "bank" and #trig.effects == 1 and #parts == 1 and trig.healing ~= true
        and (trig.on == "crit" or trig.on == "anyCrit" or trig.on == "adjacentCrit")
        and not (trig.chance or trig.every or trig.everyAmount) and (parts[1]:match("^you add ") or parts[1]:match("^you store ")) then
        local outcome = parts[1]:gsub("^you add ", "store "):gsub("^you store ", "store ")
          :gsub("of damage dealt", "of their damage"):gsub(" to your next ", " for your next ")
        text = "Critical strikes with " .. triggerNoun(def, trig, true, details) .. " " .. outcome
        if condition then text = condition:gsub("^%l", string.upper) .. ", " .. text:gsub("^%u", string.lower) end
      elseif trig.on == "healed" and trig.match and trig.match.key == (def.baseKey or def.key)
        and trig.effective and not (trig.paidOnly or trig.condition or trig.chance or trig.every or trig.everyAmount or trig.icd)
        and #trig.effects == 1 and effect.type == "tickHots" and effect.target == "neighbors" then
        local combined = false
        for index = #lines, 1, -1 do
          if lines[index].role == "effect" and lines[index].text:match("^Heals ") then
            lines[index].text = lines[index].text:gsub("%.$", "") .. " and triggers an extra tick of " .. effectNoun(effect, true, def) .. "."
            combined = true
            break
          end
        end
        if not combined then text = "Healing with this spell triggers an extra tick of " .. effectNoun(effect, true, def) end
      elseif #trig.effects == 1 and effect.type == "cast" and effect.target == "neighbors"
        and effect.match and effect.match.kind == "form" and effect.match.tag == "autoattack"
        and (trig.on == "anyCrit" or trig.on == "crit" or trig.on == "adjacentCrit")
        and trig.healing ~= true and not (trig.every or trig.everyAmount or trig.chance) then
        text = "Critical strikes with " .. triggerNoun(def, trig, true, details) .. " trigger an extra attack from "
          .. (effect.choose == "first" and "an adjacent form" or "each adjacent form")
        if condition and not (trig.condition == "provides:feralform" and trig.match and trig.match.tag == "feral") then
          text = condition:gsub("^%l", string.upper) .. ", " .. text:gsub("^%u", string.lower)
        end
      else
        local intro = group and group.intro or spendingIntros[trig] or triggerIntro(def, trig, context, sharedShadow)
        if trig.matchAttacker then
          local attacker = triggerArticle(matchNoun(trig.matchAttacker, false), trig.matchAttacker.key)
          intro = intro .. (trig.on == "damaged" and trig.critical == true and " by " or " from ") .. attacker
        end
        if condition then intro = intro .. " " .. condition end
        local body = join(parts)
        if trig.chance then
          local allYou = #parts > 0
          for _, part in ipairs(parts) do if not part:match("^you ") then allYou = false end end
          if allYou then
            local actions = {}
            for _, part in ipairs(parts) do actions[#actions + 1] = part:gsub("^you ", "") end
            local chance = fmtNumber(trig.chance)
            local article = (chance:match("^8") or chance:match("^11$") or chance:match("^18$")) and "an " or "a "
            body = "you have " .. article .. chance .. "% chance to " .. join(actions)
          else body = "there is a " .. fmtNumber(trig.chance) .. "% chance that " .. body end
        end
        local actionsOnly = true
        for _, part in ipairs(parts) do if not part:match("^you ") then actionsOnly = false break end end
        if actionsOnly then body = body:gsub("^you ", ""):gsub(", you ", ", "):gsub(" and you ", " and ") end
        local verb, tail = body:match("^(%a+) (.+)$")
        local countedVerbs = { trigger = "triggers", reduce = "reduces", gain = "grants", restore = "restores", cast = "casts", reset = "resets", deal = "deals", steal = "steals", drain = "drains" }
        if intro:match("^Every ") and actionsOnly and #parts == 1 and countedVerbs[verb] then
          text = intro .. " " .. countedVerbs[verb] .. " " .. tail
        else
          if intro:match("^Every ") then intro = "After " .. intro:gsub("^Every ", "every ") end
          text = intro .. ", " .. body
        end
      end
      if text and text ~= "" then
        text = text:gsub("^you ", "")
        text = text:gsub("^%l", string.upper):gsub("%.$", "") .. "."
        if #notes > 0 then text = text .. " " .. table.concat(notes, " ") end
        add(text, green, passive and "passive" or "trigger")
      end
      if trig.icd and not (trig.counterKey and emittedCooldowns[trig.counterKey]) then
        local text = "Once every " .. fmtNumber(trig.icd) .. " sec."
        if trig.counterKey and sharedCooldowns[trig.counterKey] > 1 and not sharedShadow then
          text = "These effects share a " .. fmtNumber(trig.icd) .. " sec cooldown."
        end
        if group and group.cooldown then text = group.cooldown end
        add(text, grey, "detail")
        if trig.counterKey then emittedCooldowns[trig.counterKey] = true end
      end
      if details and trig.on == "regularHit" then add("Extra attacks do not trigger this effect.", grey, "detail") end
      if details and trig.oncePerActivation then add("Each use can trigger this effect only once.", grey, "detail") end
      if details and trig.effective and (trig.healing or trig.on == "healed" or trig.on == "hotTick") then add("Overhealing does not count.", grey, "detail") end
    end
  end
  for _, text in ipairs(bankReferences(def, context, details)) do add(text, green) end
  local spatialNotes, marked = false, false
  for _, rule in ipairs(ns.EffectRules(def)) do
    if not rule.inside then
      spatialNotes = true
      if spatialWord(rule) == "marked" then marked = true end
    end
  end
  local emitted = {}
  local function addAdjacent(text)
    text = text:gsub("^%l", string.upper)
    if text ~= "" and not emitted[text] then add(text, green, "adjacency") emitted[text] = true end
  end
  for _, rule in ipairs(def.adjacency) do
    local subject, singular = adjacencySubject(rule, def)
    if rule.mods then addAdjacent(modifierSentence(rule.mods, subject, singular)) end
    if rule.selfMods or rule.stats then
      local suffix
      if rule.inside then
        local noun = filterLabel(rule.match):gsub("^%u", string.lower)
        suffix = rule.once and (" while this bag contains " .. (noun:match("^[aeiou]") and "an " or "a ") .. noun)
          or (" for each " .. noun .. " in this bag")
      elseif rule.empty then
        suffix = rule.once and (" while a " .. spatialWord(rule) .. " slot is empty")
          or (" for each empty " .. spatialWord(rule) .. " slot")
      else
        local singleRule = Util.ShallowCopy(rule)
        singleRule.once = true
        local noun = adjacencySubject(singleRule):gsub("^One ", "")
        suffix = rule.once and (" while " .. (noun:match("^[aeiou]") and "an " or "a ") .. noun .. " is present")
          or (" for each " .. noun)
      end
      if rule.selfMods then
        local text = modifierSentence(rule.selfMods, "This ability", true)
        addAdjacent(text:gsub("%.$", "") .. suffix .. ".")
      end
      if rule.stats then addAdjacent("Gain " .. table.concat(describeStats(rule.stats), ", ") .. suffix .. ".") end
    end
  end
  if details and spatialNotes then
    if marked then add("Marked items occupy the blue effect slots.", grey, "detail") end
    if def.facing then add("Rotate to change the marked slots.", grey, "detail") end
  end
  if def.rankText then add(def.rankText, green) end
  if def.flavor then add(def.flavor, gold) end
  return lines
end

function Describe.SetLines(setKey, ownedPieces)
  local setDef = ns.Sets[setKey]
  if not setDef then return {} end
  local lines = {}
  local pieces = ns.SetPieces(setKey)
  local owned = ownedPieces or {}
  local count = Util.Count(owned)
  local goal = Describe.SetGoal(setKey)
  lines[#lines + 1] = { text = string.format("%s (%d/%d)", setDef.name, math.min(count, goal), goal), color = { r = 1, g = 0.82, b = 0 } }
  for _, piece in ipairs(pieces) do
    local have = owned[piece.key]
    lines[#lines + 1] = { text = "  " .. piece.name, color = have and { r = 1, g = 1, b = 1 } or { r = 0.5, g = 0.5, b = 0.5 } }
  end
  for _, threshold in ipairs(setDef.thresholds) do
    local bonus = setDef.bonuses[threshold]
    local active = count >= threshold
    local color = active and { r = 0.1, g = 1, b = 0.1 } or { r = 0.5, g = 0.5, b = 0.5 }
    lines[#lines + 1] = { text = string.format("(%d) Set: %s", threshold, describeSetBonus(bonus)), color = color }
  end
  return lines
end
