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
  ragePct = "Rage from Hits", rageTakenPct = "Rage from Damage Taken", rageOnCrit = "Rage on Critical Strike",
}
local PCT_STATS = Util.Set{ "hpPct", "crit", "critDamage", "haste", "dodge", "blockChance", "lifesteal", "dr", "dmgPct", "healPct", "petPct", "rangedPct", "meleePct", "spellPct", "ragePct", "rageTakenPct" }
local STAT_ORDER = { "hp", "hpPct", "armor", "ap", "sp", "healing", "crit", "critDamage", "haste", "dodge", "block", "blockChance", "thorns", "lifesteal",
  "mana", "regen", "dr", "dmgPct", "healPct", "petPct", "rangedPct", "meleePct", "spellPct", "ragePct", "rageTakenPct", "rageOnCrit" }
local DAMAGE_SCHOOLS = { magic = "magic", physical = "physical", fire = "Fire", frost = "Frost", nature = "Nature", shadow = "Shadow", holy = "Holy", arcane = "Arcane" }

local MOD_LABELS = { dmgPct = "damage", healPct = "healing", crit = "critical strike chance", haste = "speed", costPct = "cost", cdPct = "cooldown", flat = "damage per hit", ammoEffectPct = "damage and debuff strength" }

local function fmtNum(v)
  return (string.format("%.1f", v):gsub("%.0$", ""))
end

local function fmtScalar(v)
  return (string.format("%.2f", v):gsub("0+$", ""):gsub("%.$", ""))
end

local function joinOr(parts)
  if #parts <= 1 then return parts[1] or "" end
  return table.concat(parts, ", ", 1, #parts - 1) .. " or " .. parts[#parts]
end

local function resourcePoint(key)
  return key == "combo" and "combo point" or ns.RESOURCE_NAMES[key] or key or "resource"
end

local SCHOOL_LABELS = { physical = "Physical", nature = "Nature", arcane = "Arcane", fire = "Fire", frost = "Frost", shadow = "Shadow", holy = "Holy" }

local function matchNoun(filter, plural)
  local f = filter or {}
  if f.key then local def = ns.ItemsByKey[f.key] return def and def.name or f.key end
  if f.tag == "affliction" and f.notTag == "channel" then return "Corruption, Curse of Agony and Siphon Life" end
  local nouns = {
    spell = { "spell", "spells" }, heal = { "healing spell", "healing spells" },
    melee = { "melee attack", "melee attacks" }, ranged = { "ranged attack", "ranged attacks" },
    autoattack = { "auto-attack", "auto-attacks" }, strike = { "strike", "strikes" }, shot = { "shot", "shots" },
    builder = { "combo point generating attack", "combo point generating attacks" }, opener = { "opening attack", "opening attacks" },
    finisher = { "finishing move", "finishing moves" }, elemental = { "Elemental spell", "Elemental spells" },
    totem = { "totem", "totems" }, curse = { "curse", "curses" }, poison = { "poison", "poisons" },
    bleed = { "bleed", "bleeds" }, burn = { "burn", "burns" }, shock = { "shock spell", "shock spells" },
    hot = { "healing over time effect", "healing over time effects" }, dot = { "damage over time effect", "damage over time effects" },
    bear = { "Bear attack", "Bear attacks" }, weapon = { "weapon attack", "weapon attacks" },
  }
  local index = plural and 2 or 1
  if f.kind == "pet" then return plural and "pet attacks" or "pet attack" end
  if f.kind == "form" then return plural and "form attacks" or "form attack" end
  if f.tag == "spell" and f.anyTag then
    if #f.anyTag == 1 and f.anyTag[1] == "dot" then return plural and "damage-over-time spells" or "damage-over-time spell" end
    local qualifiers = {}
    for _, tag in ipairs(f.anyTag) do qualifiers[#qualifiers + 1] = SCHOOL_LABELS[tag] or tag end
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
  oneseal = "the active seal slot", onearmor = "the active armor spell slot", twohand = "a two-handed melee weapon", dualwield = "two one-handed melee weapons" }
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
  return string.format("%s%s %s", sign, fmtScalar(v), label)
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
  thorns = "stored spell crit damage", maul = "stored damage taken or prevented by Armor",
  wolf_howl = "stored Wolf damage", wind_serpent = "stored damage from Mana spent", lethal_shots = "stored shot crit damage",
  arcane_resonance = "stored Arcane Explosion damage", piercing_ice = "stored Frost crit damage",
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
  shaman_lightning = "Lightning Bolt or Chain Lightning",
}

local function bankAmount(e, trigger)
  if e.amount ~= nil then return fmtNum(e.amount) .. " bonus damage" end
  return fmtNum((e.fraction or 1) * 100) .. "% of " .. eventAmountLabel(trigger)
end

local function bankCap(e)
  if not e.cap then return "" end
  local parts = {}
  if e.cap.flat then parts[#parts + 1] = fmtNum(e.cap.flat) end
  for _, stat in ipairs(STAT_ORDER) do
    if e.cap[stat] then parts[#parts + 1] = fmtScalar(e.cap[stat] * 100) .. "% " .. STAT_LABELS[stat] end
  end
  return " Maximum stored: " .. table.concat(parts, " + ") .. "."
end

local function describeDamage(e, trigger)
  if e.consumeDebuff and not e.min and not e.weapon and not e.weaponSelf and not e.coef then
    return string.format("Consumes %s, dealing %s %s damage per stack.", statusName(e.consumeDebuff), fmtNum(e.perDebuffStack or 1), SCHOOL_LABELS[e.school or "physical"])
  end
  local school = SCHOOL_LABELS[e.school or "physical"]
  local s = ""
  if e.min then s = string.format("%d-%d %s damage", e.min, e.max or e.min, school) end
  if e.weaponSelf or e.weapon then
    local w = e.weaponPct and string.format("%s%% weapon damage", fmtNum(e.weaponPct * 100)) or "weapon damage"
    s = s ~= "" and (w .. " + " .. s) or w
  end
  local out = s ~= "" and ("Deals " .. s) or string.format("Deals %s damage", school)
  if e.fromEvent then
    out = out .. string.format(" %s %s%% of %s", s ~= "" and "plus" or "equal to", fmtNum(e.fromEvent * 100), eventAmountLabel(trigger))
  end
  if e.perPoint then out = out .. string.format(" + %s per %s spent", fmtScalar(e.perPoint), resourcePoint(e.pointResource)) end
  if e.consumeDebuff then out = out .. string.format(" + %s per %s stack, consuming your stacks", fmtNum(e.perDebuffStack or 1), statusName(e.consumeDebuff)) end
  if e.spendBank then
    local amount = string.format("%s%%", fmtNum((e.bankScale or 1) * 100))
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
  if e.blockScale then out = out .. string.format(" + %s%% Block Value", fmtNum(e.blockScale * 100)) end
  if e.coef and e.coef > 0 then
    out = out .. string.format(" (+%s%% %s)", fmtScalar(e.coef * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")])
  end
  if e.scaleMissing then out = out .. string.format(", up to %d%% more based on the enemy's missing health", e.scaleMissing * 100) end
  if e.perStatus then out = out .. string.format(", +%d%% per damage-over-time effect on the enemy", e.perStatus * 100) end
  if e.critBonus then out = out .. string.format(", +%d%% crit chance", e.critBonus) end
  if e.critIf and conditionLabel(e.critIf) then out = out .. ". Guaranteed crit " .. conditionLabel(e.critIf):gsub("^%u", string.lower) end
  if e.generatesRage then out = out .. " and generates Rage" end
  if e.noCrit then out = out .. ". Cannot critically strike" end
  if e.consumeDots and e.perCombo then out = out .. string.format(", +%d%% per combo point spent", e.perCombo * 100) end
  if e.consumeDots then
    local tag = e.consumeDots.match and e.consumeDots.match.tag
    local what = tag == "bleed" and "bleed damage" or tag == "poison" and "poison damage" or (tag == "fire" or tag == "burn") and "burn damage" or tag == "shadow" and "Shadow damage over time" or "spell damage over time"
    out = out .. string.format(". Adds %s%% of your remaining %s, consuming it", fmtNum((e.consumeDots.fraction or 1) * 100), what)
  end
  return out .. "."
end

local function durationText(e)
  if e.duration >= ns.Sim.MAX_TIME then return "" end
  return string.format(" for %ss", fmtScalar(e.duration))
end

local function describeEffect(e, trigger, details, context)
  local t = e.type
  if t == "damage" then return describeDamage(e, trigger)
  elseif t == "heal" then
    local s = e.min and string.format("%d-%d", e.min, e.max or e.min) or ""
    if e.pctMax then s = s .. (s ~= "" and " + " or "") .. string.format("%s%% max health", fmtScalar(e.pctMax * 100)) end
    if e.fromEvent then s = s .. (s ~= "" and " + " or "") .. string.format("%s%% of %s", fmtNum(e.fromEvent * 100), eventAmountLabel(trigger)) end
    if e.perPoint then s = s .. (s ~= "" and " + " or "") .. string.format("%s per %s spent", fmtScalar(e.perPoint), resourcePoint(e.pointResource)) end
    if e.perPointPctMax then s = s .. (s ~= "" and " + " or "") .. string.format("%s%% max health per %s spent", fmtScalar(e.perPointPctMax * 100), resourcePoint(e.pointResource)) end
    local out = "Heals " .. s
    if e.consumeHots then
      out = out .. (s ~= "" and " plus " or "") .. "100% of the remaining healing over time on you, consuming those effects"
    end
    if e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% Healing Power)", fmtScalar(e.coef * 100)) end
    return out .. "."
  elseif t == "dot" then
    if e.stack and (e.uncapped or e.decayStacks or e.rampStacks) then
      local out = string.format("Deals %s %s damage per stack every sec. for %s sec.", fmtNum(e.tick), SCHOOL_LABELS[e.school or "physical"], fmtNum(e.duration))
      if e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s per stack)", fmtScalar(e.coef * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")]) end
      if e.stacksFromEvent then out = string.format("Applies 1 stack per %s %s. ", fmtNum(1 / e.stacksFromEvent), e.fromCriticalDamage and "direct critical damage" or "damage dealt") .. out end
      if e.decayStacks then out = out .. string.format(" Loses %s stacks per tick.", fmtNum(e.decayStacks)) end
      if e.rampStacks then out = out .. string.format(" Gains %s stack%s every %s ticks.", fmtNum(e.rampStacks), e.rampStacks == 1 and "" or "s", fmtNum(e.rampEvery or 1)) end
      if not e.decayStacks then out = out .. (e.uncapped and " Stacks infinitely." or string.format(" Stacks up to %s times.", fmtNum(e.maxStacks or 5))) end
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
        and "Further critical strikes add to the remaining bleed damage and refresh the duration."
        or "Applying this bleed again adds to its remaining damage and refreshes the duration."
      return string.format("Causes the enemy to bleed for %s%% of that hit's damage over %d seconds. %s", fmtNum((e.fromEvent or 0) * 100), e.duration, repeatText)
    end
    if e.rolling and e.fromEvent then
      return string.format("Adds %s%% of %s as %s damage over %ds.", fmtNum(e.fromEvent * 100), eventAmountLabel(trigger), SCHOOL_LABELS[e.school or "physical"], e.duration)
    end
    local out = string.format("Deals %d %s damage every second for %d seconds", e.tick, SCHOOL_LABELS[e.school or "physical"], e.duration)
    if e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% %s per tick)", fmtScalar(e.coef * 100), STAT_LABELS[e.powerStat or ((e.school or "physical") == "physical" and "ap" or "sp")]) end
    if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
    if e.decayStacks then out = out .. string.format(". Each tick removes %s stacks", fmtNum(e.decayStacks)) end
    if e.rampStacks then out = out .. string.format(". Every %s ticks adds %s stack%s. Reapplications preserve accumulated stacks", fmtNum(e.rampEvery or 1), fmtNum(e.rampStacks), e.rampStacks == 1 and "" or "s") end
    if e.rolling and details then out = out .. ". Reapplications add to the remaining damage" end
    return out .. "."
  elseif t == "hot" then
    local out = string.format("Heals %d every second for %d seconds", e.tick, e.duration)
    if e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% Healing Power per tick)", fmtScalar(e.coef * 100)) end
    return out .. "."
  elseif t == "buff" then
    if e.free then
      return string.format("Your next %s costs nothing (within %s seconds).", matchNoun(e.match, false), fmtScalar(e.duration))
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
      local pet = e.match.kind == "pet"
      local noun = matchNoun(e.match, true)
      local what = pet and "Your pet" or noun:gsub("^%l", string.upper)
      if e.charges then
        what = "Your next " .. (e.charges == 1 and matchNoun(e.match, false) or e.charges .. " " .. noun)
        if e.stat == "crit" and e.value >= 100 then return what .. (e.charges > 1 and " are guaranteed crits." or " is a guaranteed crit.") end
        duration = details ~= false and duration or ""
      end
      if e.target == "neighbors" then what = "Adjacent " .. noun end
      if e.stat == "dmgPct" and not e.fromEvent and e.value < 0 then
        return string.format("%s %s %s%% less damage%s.", what, (pet and not e.charges or e.charges == 1) and "deals" or "deal", fmtNum(-e.value), duration)
      end
      local value = e.fromEvent and string.format("%s equal to %s%% of %s", STAT_LABELS[e.stat] or e.stat, fmtNum(e.fromEvent * 100), eventAmountLabel(trigger)) or fmtStat(e.stat, e.value):gsub("^%+", "")
      local out = string.format("%s %s %s%s", what, ((pet or e.match.key) and not e.charges or e.charges == 1) and "gains" or "gain", value, duration)
      if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
      return out .. "."
    end
    if e.stat == "none" then
      if e.double then
        return "Your " .. matchNoun(e.double, true) .. " activate twice" .. duration .. "."
      end
      return (e.name or e.key or "Effect") .. " active" .. duration .. "."
    end
    local out
    if e.missingHealth and e.stat == "dmgPct" then
      out = string.format("Deal up to %s%% more damage based on missing health%s", fmtNum(e.value), duration)
      if details ~= false then out = out .. string.format(". +%s%% damage per 1%% missing health", fmtNum(e.value / 100)) end
    elseif e.missingHealth then
      out = string.format("Gain up to %s based on missing health%s", fmtStat(e.stat, e.value), duration)
    elseif e.fromEvent then
      out = string.format("Gain %s equal to %s%% of %s%s", STAT_LABELS[e.stat] or e.stat, fmtNum(e.fromEvent * 100), eventAmountLabel(trigger), duration)
    elseif e.stat == "dr" then
      local scope = (e.rangedOnly and "ranged " or "") .. (e.damageSchool and (DAMAGE_SCHOOLS[e.damageSchool] or e.damageSchool) .. " " or "")
      out = string.format("Take %s%% %s %sdamage%s", fmtNum(math.abs(e.value)), e.value < 0 and "more" or "less", scope, duration)
    elseif e.stat == "healPct" and e.value < 0 then
      out = string.format("Receive %s%% less healing%s", fmtNum(-e.value), duration)
    elseif e.stat == "dmgPct" then
      out = string.format("Deal %s%% %s damage%s", fmtNum(math.abs(e.value)), e.value < 0 and "less" or "more", duration)
    else
      out = string.format("Gain %s%s", fmtStat(e.stat, e.value), duration)
    end
    if e.stack then out = out .. string.format(", stacking up to %d times", e.maxStacks or 5) end
    return out .. "."
  elseif t == "debuff" then
    if e.stat == "none" and e.stack then
      local out = e.stacksFromEvent and string.format("Applies %s equal to %s%% of %s%s.", e.name or "Lightning Charge", fmtNum(e.stacksFromEvent * 100), eventAmountLabel(trigger), durationText(e))
        or string.format("Applies %s stacks of %s%s.", fmtNum(e.stacks or 1), e.name or "Lightning Charge", durationText(e))
      out = out .. (e.uncapped and " Stacks infinitely." or string.format(" Stacks up to %d times.", e.maxStacks or 5))
      return out
    end
    if e.stat == "dr" then
      local scope = (e.rangedOnly and "ranged " or "") .. (e.damageSchool and (DAMAGE_SCHOOLS[e.damageSchool] or e.damageSchool) .. " " or "")
      return string.format("Enemy takes %s%% more %sdamage%s.", fmtNum(e.value), scope, durationText(e))
    end
    if e.target and e.match and e.match.kind == "ability" and e.match.tag == "spell" and e.stat == "haste" then
      return string.format("Enemy spells recharge %s%% slower%s.", fmtNum(e.value), durationText(e))
    end
    if e.target and e.match and e.stat == "haste" then
      if e.match.tag == "autoattack" then
        return string.format("Enemy auto-attacks are %s%% slower%s.", fmtNum(e.value), durationText(e))
      end
      if e.match.tag == "melee" and e.match.anyTag and #e.match.anyTag == 1 and e.match.anyTag[1] == "autoattack" then
        return string.format("Enemy melee auto-attacks are %s%% slower%s.", fmtNum(e.value), durationText(e))
      end
    end
    local out = string.format("Enemy suffers %s%s", fmtStat(e.stat, -e.value), durationText(e))
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
    if e.match and e.match.key then return "Trigger a tick of " .. statusName(e.match.key) .. "." end
    if e.match and e.match.tag == "poison" then return "Trigger a tick of your poisons." end
    if e.match and e.match.tag == "spell" then return "Trigger a tick of your spell damage over time." end
    if e.match and e.match.tag == "affliction" and e.match.notTag == "channel" then return "Trigger a tick of your Corruption, Curse of Agony and Siphon Life." end
    if e.match and e.match.tag == "burn" then return "Trigger a tick of your burns." end
    if e.match and SCHOOL_LABELS[e.match.tag] then return "Trigger a tick of your " .. SCHOOL_LABELS[e.match.tag] .. " damage over time." end
    return e.match and e.match.tag == "bleed" and "Trigger a tick of your bleeds." or "Trigger a tick of your damage over time."
  elseif t == "tickHots" then
    if e.match and e.match.key then return "Trigger a tick of " .. statusName(e.match.key) .. "." end
    if e.match and e.match.tag == "totem" then return "Trigger a tick of your healing totems." end
    return "Trigger a tick of your healing over time effects."
  elseif t == "bank" then
    local target = BANK_TARGETS[e.key] or e.bankTarget
    local value = bankAmount(e, trigger)
    local verb = (e.key == "blocked" or e.key == "maul" or e.key == "arcane_resonance") and "Stores" or "Adds"
    local out = target and string.format("%s %s %s your next %s.", verb, value, verb == "Stores" and "for" or "to", target)
      or string.format("Stores %s for a later attack.", value)
    return out .. (details ~= false and bankCap(e) or "")
  elseif t == "charge" then
    local def = ns.ItemsByKey[e.key]
    local amount = e.amount or 1
    if e.key == "primal_fury" then
      local cost = ns.ItemsByKey.swipe.use.empower.cost
      return string.format("Gain %s charge%s (maximum %s). Each charge adds a Swipe hit for %s extra Rage.", fmtNum(amount), amount == 1 and "" or "s", fmtNum(e.max or 3), fmtNum(cost))
    end
    return string.format("Gain %s %s charge%s (maximum %s).", fmtNum(amount), def and def.name or e.key, amount == 1 and "" or "s", fmtNum(e.max or 3))
  elseif t == "extraAttack" then
    local count = e.count or 1
    local bonus = e.bonusAttackPowerPct and string.format(" with %s%% bonus Attack Power", fmtNum(e.bonusAttackPowerPct)) or ""
    return string.format("Make %d extra melee attack%s%s.", count, count == 1 and "" or "s", bonus)
  elseif t == "cast" then
    if e.target == "source" then return "Repeat that ability for free." end
    if e.match and e.match.kind == "pet" then return "Your pet attacks again." end
    if e.match and e.match.kind == "form" then
      return e.target == "neighbors" and "Your adjacent form attacks for free." or "Your form attacks for free."
    end
    local out
    if e.key then
      local target = ns.ItemsByKey[e.key]
      out = "Cast " .. (target and target.name or e.key) .. " for free"
      if e.key == "execute" and e.ignoreCondition then out = out .. " at any enemy health" end
    else
      local what = Describe.FilterLabel(e.match):gsub(" item$", "")
      if not (e.match and e.match.key) then
        what = what:lower()
        what = what == "ability" and "abilities" or what == "item" and "abilities" or (what .. "s")
      end
      out = string.format("Cast %s %s for free", e.choose == "random" and "a random" or e.target == "neighbors" and "adjacent" or "all", e.choose == "random" and what:gsub("s$", "") or what)
    end
    if details ~= false and e.key == "execute" then out = out .. ". Free Execute gains no damage from Rage spent" end
    if e.deferDuringChannel then out = out .. ". If channeling or stunned, holds one free cast until you can act" end
    if e.consumeCooldown then out = out .. ". Starts its normal cooldown" end
    return out .. "."
  elseif t == "resource" then
    local amount = e.amount or 0
    if e.fromEvent and amount == 0 and trigger and trigger.on == "resourceSpent" and trigger.resource == "combo" then
      return string.format("Restores %s %s per combo point spent.", fmtNum(e.fromEvent), ns.RESOURCE_NAMES[e.resource] or e.resource)
    end
    if e.fromEvent then return string.format("Gain %s%s%% of %s as %s.", amount > 0 and fmtNum(amount) .. " + " or "", fmtNum(e.fromEvent * 100), eventAmountLabel(trigger), ns.RESOURCE_NAMES[e.resource] or e.resource) end
    if e.resource == "combo" then return string.format("Awards %d combo point%s.", e.amount, e.amount == 1 and "" or "s") end
    if e.resource == "rage" then return string.format("Gain %s Rage.", fmtScalar(amount)) end
    return string.format("Restores %d %s.", e.amount, ns.RESOURCE_NAMES[e.resource] or e.resource)
  elseif t == "absorb" then
    local out = e.fromEvent and string.format("Absorbs %s%% of %s", fmtNum(e.fromEvent * 100), eventAmountLabel(trigger)) or string.format("Gain a shield that absorbs %d damage", e.amount or 0)
    if e.coef and e.coef > 0 then out = out .. string.format(" (+%s%% Healing Power)", fmtScalar(e.coef * 100)) end
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
    local action = ({ fear = "Fears the enemy", charm = "Charms the enemy", sleep = "Puts the enemy to sleep", freeze = "Freezes the enemy", horror = "Horrifies the enemy" })[e.controlType] or "Stuns the enemy"
    return string.format("%s for %s second%s.", action, fmtScalar(e.duration), e.duration == 1 and "" or "s")
  elseif t == "sacrificePet" then
    return "Sacrifice your demon for the rest of this battle."
  elseif t == "cdr" then
    if e.target ~= "neighbors" and e.target ~= "all" then return string.format("Reduce its cooldown by %ss.", fmtScalar(e.amount)) end
    if e.match and e.match.kind == "form" then
      return string.format("Reduce your %sform attack cooldown by %ss.", e.target == "neighbors" and "adjacent " or "", fmtScalar(e.amount))
    end
    if e.match and e.match.key then
      local def = ns.ItemsByKey[e.match.key]
      return string.format("Reduce %s%s's cooldown by %ss.", e.target == "neighbors" and "adjacent " or "", def and def.name or e.match.key, fmtScalar(e.amount))
    end
    local what = Describe.FilterLabel(e.match):gsub(" item$", "")
    if not (e.match and e.match.key) then what = what:lower() end
    local target = e.target == "neighbors" and "adjacent" or "all"
    if e.amount >= 30 then return string.format("Reset %s %s cooldowns.", target, what) end
    return string.format("Reduce %s %s cooldowns by %ss.", target, what, fmtScalar(e.amount))
  elseif t == "cleanse" then
    return string.format("Removes %d harmful effect%s.", e.count or 1, (e.count or 1) == 1 and "" or "s")
  elseif t == "purge" then
    return string.format("Removes %d beneficial effect%s from the enemy.", e.count or 1, (e.count or 1) == 1 and "" or "s")
  elseif t == "drain" then
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

local function effectLines(effects, trigger, resource, details, context)
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
    local text = describeEffect(described, trigger, details, context)
    if effect.perCombo and not (effect.type == "damage" and effect.consumeDots) then
      text = text .. string.format(" +%d%% per %s spent.", effect.perCombo * 100, resource == "combo" and "combo point" or "point of " .. (ns.RESOURCE_NAMES[resource] or resource or "resource"))
    end
    if count > 1 then
      local hits = count == 2 and "Hits twice." or string.format("Hits %d times.", count)
      text = hits .. " " .. text:gsub("^Deals ", "Each hit deals ")
    end
    if effect.cond and conditionLabel(effect.cond) then text = conditionLabel(effect.cond) .. ": " .. text end
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
        local value = effect.amount ~= nil and fmtNum(effect.amount) .. " bonus damage" or fmtNum((effect.fraction or 1) * 100) .. "% of " .. origin
        local text = entry.def.name .. " stores " .. value .. " for " .. def.name .. "."
        if trigger and trigger.chance then text = text .. " " .. fmtNum(trigger.chance) .. "% chance per trigger." end
        if trigger and trigger.everyAmount then text = text .. " Requires " .. fmtNum(trigger.everyAmount) .. " " .. eventAmountLabel(trigger) .. " per trigger." end
        lines[#lines + 1] = text .. (details and bankCap(effect) or "")
      end
    end
  end
  return lines
end

local CONDITION_LABELS = {
  injured = "Below 90% health",
  below50 = "Below 50% health",
  below35 = "Below 35% health",
  enemyBelow20 = "Enemy below 20% health",
  enemyBelow50 = "Enemy below 50% health",
  hasDot = "While affected by damage over time",
  injuredWithHot = "While injured and you have a heal over time",
  enemyBleeding = "If enemy is bleeding",
  enemyPoisoned = "If enemy is poisoned",
  noAbsorb = "While you have no absorb shield",
  lowMana = "Below 30% mana",
  enemyStunned = "While the enemy is stunned",
  dualwield = "While dual wielding",
}

statusName = function(key)
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

conditionLabel = function(cond)
  if not cond then return nil end
  if CONDITION_LABELS[cond] then return CONDITION_LABELS[cond] end
  local resource, amount = cond:match("^resourceAtLeast:([^:]+):([%d%.]+)$")
  if resource and tonumber(amount) then
    if resource == "combo" and tonumber(amount) == 1 then return "At least 1 Combo Point" end
    return string.format("At %s+ %s", fmtScalar(tonumber(amount)), ns.RESOURCE_NAMES[resource] or resource)
  end
  local provided = cond:match("^provides:(.+)$")
  if provided == "pet" then return "While your pet is active" end
  if provided == "shield" then return "While a shield is equipped" end
  if provided == "melee" then return "While a melee weapon is equipped" end
  if provided == "ranged" then return "While a ranged weapon is equipped" end
  if provided then return "In " .. (REQUIRE_LABELS[provided] or provided) end
  local key = cond:match("^enemyHas:(.+)$")
  if key then return "While the enemy has " .. statusName(key) end
  key = cond:match("^buff:(.+)$")
  if key then return "While " .. statusName(key) .. " is active" end
  return nil
end

local TRIGGER_LABELS = {
  battleStart = "Battle start", hit = "On hit", crit = "On crit", damaged = "On damage taken",
  below40 = "When you fall below 40% Health",
  lowHealth = "First time below 35% health", targetDodged = "On enemy dodge", block = "On block",
  use = "On use", adjacentUse = "On adjacent %s use", adjacentHit = "On adjacent %s hit",
  adjacentCrit = "On adjacent %s crit", anyUse = "On %s use",
  anyHit = "On %s hit", anyCrit = "On %s crit", healed = "On heal",
  dotTick = "On %s tick", stunned = "When stunned",
  hotTick = "On healing tick", dodged = "On dodge", healthSpent = "When you spend health",
  regularHit = "On auto-attack", extraHit = "On extra attack hit", resourceSpent = "On resource spent", resourceGained = "On resource gained",
  resourceOverflow = "On excess resource",
  armorPrevented = "When Armor prevents damage", enemyStunned = "When you stun the enemy",
  absorbed = "When your shields absorb damage",
}
local UNMATCHED_LABELS = {
  anyUse = "On item use", anyHit = "On hit", anyCrit = "On crit",
  dotTick = "On periodic damage", adjacentUse = "On adjacent item use",
  adjacentHit = "On adjacent hit", adjacentCrit = "On adjacent crit",
}

local function filterLabel(f)
  if not f then return "item" end
  if f.key then local d = ns.ItemsByKey[f.key] return d and d.name or f.key end
  if f.hands then return f.hands == 2 and "Two-handed weapon" or "One-handed weapon" end
  if f.tag == "spell" and f.anyTag and #f.anyTag == 1 and f.anyTag[1] == "dot" then return "Damage-over-time spell" end
  if f.tag then return Describe.TagLabel(f.tag) .. " item" end
  if f.anyTag then
    local parts = {}
    for _, tag in ipairs(f.anyTag) do parts[#parts + 1] = Describe.TagLabel(tag) end
    return joinOr(parts) .. " item"
  end
  if f.weaponType then return WEAPON_LABELS[f.weaponType] or f.weaponType end
  if f.anyWeaponType then
    local types = {}
    for _, weaponType in ipairs(f.anyWeaponType) do types[weaponType] = true end
    if #f.anyWeaponType == 3 and types.bow and types.gun and types.crossbow then return "Ranged weapon" end
    local parts = {}
    for _, w in ipairs(f.anyWeaponType) do parts[#parts + 1] = WEAPON_LABELS[w] or w end
    return joinOr(parts)
  end
  if f.kind then return KIND_LABELS[f.kind] or f.kind end
  if f.slot then return SLOT_LABELS[f.slot] or f.slot end
  if f.set then local s = ns.Sets[f.set] return s and s.name or f.set end
  return "item"
end
Describe.FilterLabel = filterLabel

local function triggerSubject(filter)
  local label = filterLabel(filter)
  if filter and filter.key == "bear_form" and filter.tag == "autoattack" then return "Bear auto-attack" end
  if filter and filter.key then return label end
  return label:gsub(" item$", ""):lower()
end

function Describe.FilterPhrase(f, determiner)
  if not f then return determiner == "every" and "every item" or "an item" end
  if f.tag and TAG_PHRASES[f.tag] then return TAG_PHRASES[f.tag][determiner == "every" and 2 or 1] end
  local label = filterLabel(f)
  if f.key then return label end
  if determiner == "every" then return "every " .. label end
  return (label:match("^[AEIOUaeiou]") and "an " or "a ") .. label
end

TAG_LABELS = {
  balance = "Balance", feral = "Feral", resto = "Restoration", arms = "Arms", fury = "Fury", prot = "Protection", bear = "Bear",
  bm = "Beast Mastery", mm = "Marksmanship", surv = "Survival", spell = "Spell", melee = "Melee", ranged = "Ranged",
  nature = "Nature", arcane = "Arcane", fire = "Fire", frost = "Frost", shadow = "Shadow", holy = "Holy", heal = "Healing",
  dot = "Damage over Time", hot = "Heal over Time", bleed = "Bleed", poison = "Poison", shout = "Shout", pet = "Pet", trap = "Trap",
  aspect = "Aspect", sting = "Sting", shot = "Shot", strike = "Strike", form = "Form", stance = "Stance", physical = "Physical",
  defensive = "Defensive", finisher = "Finisher", ammo = "Ammunition", weapon = "Weapon", autoattack = "Auto-attack",
  protection = "Protection", retribution = "Retribution", assassination = "Assassination", combat = "Combat", subtlety = "Subtlety",
  discipline = "Discipline", elemental = "Elemental", enhancement = "Enhancement", restoration = "Restoration",
  affliction = "Affliction", demonology = "Demonology", destruction = "Destruction", totem = "Totem", imbue = "Weapon Imbue",
  builder = "Combo Builder", opener = "Opener", control = "Control", burn = "Burn", seal = "Seal", judgement = "Judgement", shock = "Shock",
}
TAG_PHRASES = {
  autoattack = { "an auto-attack", "every auto-attack" }, melee = { "a melee attack", "every melee attack" },
  spell = { "a spell", "every spell" }, strike = { "a strike", "every strike" }, shot = { "a shot", "every shot" },
  bleed = { "a bleed", "every bleed" }, heal = { "a healing ability", "every healing ability" },
  poison = { "a poison", "every poison" },
  trap = { "a trap", "every trap" }, pet = { "your pet", "your pet" },
}
function Describe.TagLabel(tag) return TAG_LABELS[tag] or tag end

local function describeMods(mods)
  local parts = {}
  for _, k in ipairs(MOD_KEYS) do
    local v = mods[k]
    if v and v ~= 0 then
      if k == "cdPct" then parts[#parts + 1] = string.format("%s%% %s cooldown", fmtScalar(math.abs(v)), v > 0 and "reduced" or "increased")
      elseif k == "flat" then parts[#parts + 1] = string.format("%+d %s", v, MOD_LABELS[k])
      else parts[#parts + 1] = string.format("%+d%% %s", v, MOD_LABELS[k]) end
    end
  end
  return table.concat(parts, ", ")
end

local function describeStats(stats)
  local parts = {}
  for _, k in ipairs(STAT_ORDER) do
    if stats[k] and stats[k] ~= 0 then parts[#parts + 1] = fmtStat(k, stats[k]) end
  end
  return parts
end

local function describeSetBonus(bonus)
  local parts = describeStats(bonus.stats or {})
  if bonus.mods then parts[#parts + 1] = filterLabel(bonus.mods.match) .. "s: " .. describeMods(bonus.mods) end
  if bonus.text then parts[#parts + 1] = bonus.text end
  return table.concat(parts, ", ")
end

function Describe.SetGoal(setKey)
  local set = ns.Sets[setKey]
  return set and set.thresholds[#set.thresholds] or 0
end

function Describe.Rate(value)
  if value >= 10 then return string.format("%d", value + 0.5) end
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
  local function percent(amount) return fmtNum(amount) .. "%" end
  local function chance(amount) return math.max(0, math.min(100, amount)) end
  local resource = statKey and statKey:match("^resource:(.+)$")
  local setKey = statKey and statKey:match("^set:(.+)$")
  if resource then
    local pool = context.res and context.res[resource]
    if not pool then return lines end
    local name = ns.RESOURCE_NAMES[resource] or resource
    add(string.format("Maximum: %s %s.", fmtNum(pool.max), name))
    if resource == "rage" then
      add("Auto-attacks and damage taken generate Rage. Harder hits generate more.")
      if details then
        local conversion = ns.Sim.RageDamageScale(context)
        local hit = (1 + value("ragePct") / 100) * conversion
        add(string.format("Auto-attacks: %s of damage dealt. Incoming hits: %s of damage taken.", percent(ns.Sim.RAGE_PER_DAMAGE_DEALT * 100 * hit), percent(ns.Sim.RAGE_PER_DAMAGE_TAKEN * 100 * (1 + value("rageTakenPct") / 100) * conversion)))
        if value("rageOnCrit") > 0 then add(string.format("Weapon critical strikes grant %s extra Rage.", fmtNum(value("rageOnCrit")))) end
        add("Gains above your maximum count as excess Rage.")
      end
    elseif resource == "combo" then
      add("Builders generate points. Finishers spend them.")
      if details then add("Finishers spend all saved points once their minimum is met.") end
    else
      add(string.format("Regenerates %s %s per second.", fmtNum(pool.regen or 0), name))
      if details then
        local demand = Describe.Demand(context)[resource] or 0
        if demand > 0 then
          add(string.format("Listed ability demand: %s %s per second, before haste and free casts.", fmtNum(demand), name))
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
    add(string.format("%s base health + %s from your bag.", fmtNum(base), fmtNum(amount)))
    if bonus ~= 0 then
      add(string.format("%s applies to base health and Health from your bag.", fmtStat("hpPct", bonus)))
      if details then add(string.format("(%s + %s) x %s = %s maximum health.", fmtNum(base), fmtNum(amount), fmtScalar(scale), fmtNum(context.hpMax or Util.Round((base + amount) * scale)))) end
    end
  elseif statKey == "armor" then
    local armor = math.max(0, amount)
    local class = context.classDef or ns.GetClass(context.classKey)
    local base = class and class.baseArmor or 0
    add(string.format("%s base armor + %s from your bag.", fmtNum(base), fmtNum(amount - base)))
    add("Reduces damage from physical hits by " .. percent(ns.Sim.ArmorReduction(armor) * 100) .. ".")
    add("Magic damage and bleeds ignore armor.")
    if details then add(string.format("%s / (%s + 200). Capped at 60%% reduction.", fmtNum(armor), fmtNum(armor))) end
  elseif statKey == "ap" or statKey == "sp" or statKey == "healing" then
    local name = STAT_LABELS[statKey]
    if statKey == "ap" then
      local class = context.classDef or ns.GetClass(context.classKey)
      local base = class and class.baseAP or 0
      if base ~= 0 then add(string.format("%s base Attack Power + %s from your bag.", fmtNum(base), fmtNum(context.stats.ap - base))) end
      add("Strengthens weapon hits and abilities that scale with Attack Power.")
    elseif statKey == "sp" then add("Strengthens magic damage effects that scale with Spell Power.")
    else add("Strengthens healing effects that scale with Healing Power.") end
    if details then add("Added " .. (statKey == "healing" and "healing" or "damage") .. " = " .. name .. " x the effect's scaling percentage.") end
  elseif statKey == "crit" then
    add(string.format("%s%% base + %s%% from your bag.", fmtNum(ns.Sim.BASE_CRIT), fmtNum(amount)))
    add("Hits and direct heals can critically strike. Periodic ticks cannot.")
    if details then
      local bonus = math.max(0, 1 + value("critDamage") / 100)
      add(string.format("Physical crits deal %s damage. Magic crits deal %s. Direct heal crits gain 50%%.", percent(200 * bonus), percent(150 * bonus)))
      if ns.Sim.BASE_CRIT + amount ~= ns.Sim.CritChance(amount) then add("Critical strike chance is capped between 0% and 100%.") end
    end
  elseif statKey == "critDamage" then
    add(string.format("Critical hits deal %s%% more damage.", fmtNum(amount)))
    if details then add("Strengthens critical hits before armor and absorbs. Does not affect healing or periodic ticks.") end
  elseif statKey == "haste" then
    local speed = math.max(0.25, 1 + amount / 100)
    add(string.format("Items recharge %s%% %s.", fmtNum(math.abs((speed - 1) * 100)), speed >= 1 and "faster" or "slower"))
    add("Does not increase resource regeneration.")
    if details then
      local divisor = string.format("%.3f", speed):gsub("0+$", ""):gsub("%.$", "")
      add(string.format("Recharge time = cooldown / %s. Recharge speed cannot fall below 25%% of normal.", divisor))
    end
  elseif statKey == "dodge" then
    add(string.format("%s%% base + %s%% from your bag.", fmtNum(ns.Sim.BASE_DODGE), fmtNum(amount)))
    add("Avoids physical hits. Magic damage and bleeds cannot be dodged.")
    if details then add("Some attacks cannot be dodged. Dodge chance is capped between 0% and 100%.") end
  elseif statKey == "block" then
    add(string.format("Blocks prevent up to %s damage, capped at half of the hit.", fmtNum(amount)))
    if details then add("Calculated after armor. Only physical hits can be blocked.") end
  elseif statKey == "blockChance" then
    add(percent(chance(amount)) .. " chance to block a physical hit.")
    add("Block Value determines how much damage is prevented.")
    if details then add("Blocks happen after armor and cannot prevent more than half of one hit.") end
  elseif statKey == "thorns" then
    add(string.format("Returns %s damage when the enemy hero hits you in melee.", fmtNum(amount)))
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
  local lines = Describe.Lines(def, { details = false })
  if def.kind == "weapon" and lines[1] then return lines[1].text end
  local prefix, useLine, triggerLine, plainLine
  for _, line in ipairs(lines) do
    local text = line.text:gsub("^%s+", "")
    if line.role == "timing" then
      prefix = "use"
    elseif line.role == "cost" then
    elseif text == ns.L["Adjacent effects:"] then
      prefix = "adjacent"
    elseif prefix == "adjacent" then
      triggerLine = triggerLine or text
      prefix = nil
    elseif text:match(":$") then
      prefix = text
    elseif text:match("^Requires ") or text:match("^Used ") then
      prefix = nil
    elseif prefix == "use" then
      useLine = useLine or text
      prefix = nil
    elseif prefix then
      triggerLine = triggerLine or (prefix .. " " .. text)
      prefix = nil
    else
      plainLine = plainLine or text
    end
  end
  local text = useLine or triggerLine or plainLine or ""
  local use = def.use
  if use and (use.healthCost or use.healthCostPct) then
    local cost = use.healthCost and fmtNum(use.healthCost) or string.format("%s%%", fmtNum(use.healthCostPct * 100))
    text = string.format("Pays %s health. %s", cost, text)
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

local function passiveTrigger(trigger)
  if trigger.on ~= "battleStart" or (trigger.condition and trigger.condition ~= "dualwield") or trigger.chance or trigger.everyAmount then return false end
  if #trigger.effects == 0 then return false end
  for _, effect in ipairs(trigger.effects) do
    if (effect.type ~= "buff" and effect.type ~= "debuff") or (effect.duration or 0) < ns.Sim.MAX_TIME then return false end
  end
  return true
end

function Describe.Lines(def, context)
  local details = not context or context.details ~= false
  local lines = {}
  local function add(text, color, role) lines[#lines + 1] = { text = text, color = color, role = role } end
  local white = { r = 1, g = 1, b = 1 }
  local green = { r = 0.1, g = 1, b = 0.1 }
  local gold = { r = 1, g = 0.82, b = 0 }
  local grey = { r = 0.6, g = 0.6, b = 0.6 }

  if def.kind == "weapon" then
    local speed = def.use and def.use.cd or 2
    local dps = ((def.weaponMin or 0) + (def.weaponMax or 0)) / 2 / speed
    local scaling = ""
    if standardWeaponUse(def) and (def.use.effects[1].coef or 0) > 0 then
      scaling = " (+" .. fmtScalar(def.use.effects[1].coef * 100) .. "% Attack Power)"
    end
    add(string.format("%d - %d Damage%s   Speed %.1f", def.weaponMin or 0, def.weaponMax or 0, scaling, speed), white)
    add(string.format("(%.1f damage per second)", dps), white)
  end
  for _, line in ipairs(describeStats(def.stats)) do add(line, white) end
  if def.kind == "bag" then
    add(string.format("%d Slot Bag", def.cellCount), white)
  end
  if def.grants then
    for _, res in ipairs(Util.SortedKeys(def.grants)) do
      local cfg = def.grants[res]
      local text = string.format("Grants %d %s", cfg.max, ns.RESOURCE_NAMES[res] or res)
      if (cfg.regen or 0) > 0 then text = text .. string.format(" (regenerates %d per second)", cfg.regen) end
      add(text .. ".", white)
    end
  end
  if def.provides then
    local list = type(def.provides) == "table" and def.provides or { def.provides }
    for _, p in ipairs(list) do
      if p ~= "aspect" and REQUIRE_LABELS[p] then add("Enables " .. REQUIRE_LABELS[p] .. " abilities.", white) end
    end
  end
  local use = def.use
  if use and (details or not standardWeaponUse(def)) then
    local initial = ns.Sim.InitialCooldown(use)
    if use.condition and not use.once then
      add("Cooldown: " .. fmtScalar(use.cd) .. "s", gold, "timing")
    elseif details then
      if use.once or math.abs(initial - use.cd) >= 1e-7 then add("Initial cooldown: " .. fmtScalar(initial) .. "s", gold, "timing") end
      add(use.once and "Once per battle" or ("Cooldown: " .. fmtScalar(use.cd) .. "s"), gold, "timing")
    elseif use.once then
      add(initial <= 0 and (use.condition and "Once per battle" or "On battle start (once per battle)") or ("Once per battle (" .. fmtScalar(initial) .. "s delay)"), gold, "timing")
    elseif initial <= 0 then
      add("On battle start and every " .. fmtScalar(use.cd) .. "s", gold, "timing")
    elseif math.abs(initial - use.cd) < 1e-7 then
      add("Cooldown: " .. fmtScalar(use.cd) .. "s", gold, "timing")
    else
      add("Cooldown: " .. fmtScalar(initial) .. "s / " .. fmtScalar(use.cd) .. "s", gold, "timing")
    end
    if use.channel then
      add("Channeled: " .. fmtScalar(use.channel.duration) .. "s", gold, "timing")
      add("Cannot attack or cast other spells while channeling.", grey)
    end
    local costs = {}
    if use.resource and use.cost and use.cost > 0 then
      if use.spendMax then
        costs[#costs + 1] = string.format("%d-%d %s", use.cost, use.spendMax, ns.RESOURCE_NAMES[use.resource] or use.resource)
      elseif use.spendAll then
        costs[#costs + 1] = string.format("Spends all %s (minimum %d)", ns.RESOURCE_NAMES[use.resource] or use.resource, use.cost)
      else
        costs[#costs + 1] = string.format("%d %s", use.cost, ns.RESOURCE_NAMES[use.resource] or use.resource)
      end
    end
    if use.healthCost or use.healthCostPct then
      local cost = use.healthCost and fmtNum(use.healthCost) or string.format("%s%% of maximum", fmtNum(use.healthCostPct * 100))
      costs[#costs + 1] = "Pays " .. cost .. " health"
    end
    if #costs > 0 then add(table.concat(costs, ", "), white, "cost") end
    for _, text in ipairs(effectLines(use.effects, nil, use.resource, details, context)) do add("  " .. text, green) end
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
    if use.condition and conditionLabel(use.condition) then add("  " .. conditionLabel(use.condition) .. ".", grey) end
    if use.interruptChannel then add("  Interrupts your current channel.", grey) end
    if use.requires then
      local list = type(use.requires) == "table" and use.requires or { use.requires }
      local required = Util.Set(list)
      local parts = {}
      for _, r in ipairs(list) do
        local implied = (r == "melee" and (required.twohand or required.dualwield))
          or (r == "weapon" and (required.melee or required.twohand or required.dualwield or required.ranged))
        if not implied and (not context or not context.provides or not context.provides[r]) then parts[#parts + 1] = REQUIRE_LABELS[r] or r end
      end
      if #parts > 0 then add("  Requires " .. table.concat(parts, " and ") .. ".", { r = 1, g = 0.4, b = 0.4 }) end
    end
  end
  for _, trig in ipairs(def.triggers) do
    local effect = trig.effects[1]
    local petRecovery = trig.on == "damaged" and trig.condition == "provides:pet" and #trig.effects == 1
      and not (trig.chance or trig.every or trig.everyAmount or trig.icd or trig.matchAttacker or trig.match)
      and effect.type == "cdr" and effect.target == "all" and effect.match and effect.match.kind == "pet"
    if (details or not trig.detail) and petRecovery then
      local pet = def.classes and #def.classes == 1 and def.classes[1] == "WARLOCK" and "demon" or "pet"
      add(string.format("Damage taken reduces your %s's attack cooldown by %ss.", pet, fmtScalar(effect.amount)), green)
    elseif details or not trig.detail then
      local label = TRIGGER_LABELS[trig.on] or trig.on
      if trig.on == "stunned" and trig.controlTypes then
        local names = { fear = "feared", charm = "charmed", sleep = "put to sleep", stun = "stunned", freeze = "frozen", horror = "horrified" }
        local parts = {}
        for _, controlType in ipairs(trig.controlTypes) do parts[#parts + 1] = names[controlType] or controlType end
        label = "When " .. joinOr(parts)
      end
      local resourceEvent = trig.on == "resourceSpent" or trig.on == "resourceGained" or trig.on == "resourceOverflow"
      if resourceEvent then
        local resourceKey = trig.resource
        if not resourceKey and context and context.res then
          for key in pairs(context.res) do
            if resourceKey then resourceKey = nil break end
            resourceKey = key
          end
        end
        local resource = ns.RESOURCE_NAMES[resourceKey] or resourceKey or "resources"
        local verb = trig.on == "resourceSpent" and "spend" or "gain"
        local action = trig.on == "resourceSpent" and "spent" or "gained"
        if trig.on == "resourceOverflow" then
          label = trig.everyAmount and string.format("Every %s excess %s", fmtNum(trig.everyAmount), resource) or ("On excess " .. resource)
        else
          label = trig.everyAmount and string.format("Every %s %s %s", fmtNum(trig.everyAmount), resource, action) or string.format("When you %s %s", verb, resource)
        end
      end
      if label:find("%%s") then
        label = (not trig.match and UNMATCHED_LABELS[trig.on]) or string.format(label, triggerSubject(trig.match))
      end
      if trig.on == "regularHit" and trig.match then
        local scope = trig.match.tag == "melee" and "melee " or trig.match.hands == 2 and "two-handed "
          or trig.match.hands == 1 and "one-handed " or trig.match.anyWeaponType and "ranged " or ""
        label = "On " .. scope .. "auto-attack"
      end
      if trig.on == "damaged" and trig.matchAttacker and trig.matchAttacker.tag == "melee" then
        label = "When hit in melee"
      elseif trig.matchAttacker then
        label = label .. " from " .. Describe.FilterPhrase(trig.matchAttacker)
      end
      if trig.everyAmount and not resourceEvent then
        local amount = fmtNum(trig.everyAmount)
        if trig.on == "healed" then label = "Every " .. amount .. " Health restored" .. (trig.match and " by " .. matchNoun(trig.match, false) or "")
        elseif trig.on == "hotTick" then label = "Every " .. amount .. " Health restored by " .. (trig.match and matchNoun(trig.match, false) or "HoTs")
        elseif trig.on == "healthSpent" then label = "Every " .. amount .. " Health spent"
        elseif trig.on == "damaged" then
          label = "Every " .. amount .. (trig.matchAttacker and trig.matchAttacker.tag == "melee" and " melee damage taken" or " damage taken")
          if trig.matchAttacker and trig.matchAttacker.tag ~= "melee" then label = label .. " from " .. triggerSubject(trig.matchAttacker) end
        elseif trig.on == "block" then label = "Every " .. amount .. " damage blocked"
        elseif trig.on == "absorbed" then label = "Every " .. amount .. " damage absorbed"
        elseif trig.on == "dotTick" then label = "Every " .. amount .. " " .. (trig.match and triggerSubject(trig.match) .. " damage" or "periodic damage")
        else label = "Every " .. amount .. " damage dealt" end
      end
      if trig.every then
        local subject = trig.match and triggerSubject(trig.match) .. " " or ""
        if trig.on == "hotTick" then label = string.format("Every %d %sHoT ticks", trig.every, subject)
        elseif trig.on == "dotTick" then label = string.format("Every %d %sDoT ticks", trig.every, subject)
        elseif resourceEvent then label = string.format("After spending %s %d times", ns.RESOURCE_NAMES[trig.resource] or trig.resource or "resources", trig.every)
        elseif trig.on == "anyCrit" or trig.on == "adjacentCrit" or trig.on == "crit" then label = string.format("Every %d %scrits", trig.every, subject)
        elseif trig.on == "anyUse" or trig.on == "adjacentUse" or trig.on == "use" then label = string.format("Every %d %scasts", trig.every, subject)
        else label = string.format("Every %d %shits", trig.every, subject) end
      end
      if trig.on == "resourceSpent" and trig.every and trig.match and trig.match.kind == "ability" then
        label = string.format("After casting %d %s that cost %s", trig.every, matchNoun(trig.match, true), ns.RESOURCE_NAMES[trig.resource] or trig.resource or "resources")
      elseif trig.match and resourceEvent then
        label = label .. (trig.on == "resourceSpent" and " on " or " from ") .. matchNoun(trig.match, true)
      elseif trig.match and trig.on == "healthSpent" then
        label = label .. " through " .. matchNoun(trig.match, false)
      elseif trig.match and trig.on == "healed" and not trig.everyAmount then
        label = "On healing from " .. matchNoun(trig.match, false)
      elseif trig.match and trig.on == "hotTick" and not trig.every and not trig.everyAmount then
        label = "On " .. triggerSubject(trig.match) .. " healing tick"
      end
      if trig.healing == true then label = label:gsub("spell crit", "healing crit")
      elseif trig.healing == false then label = label:gsub("spell crit", "damaging spell crit") end
      if trig.chance then label = label .. string.format(" (%d%% chance)", trig.chance) end
      if trig.icd then label = label .. string.format(" (%ss cooldown)", fmtScalar(trig.icd)) end
      if trig.condition and conditionLabel(trig.condition) and not (trig.condition == "provides:bearform" and trig.match and trig.match.key == "bear_form") then
        local separator = trig.condition:match("^buff:") and " " or ", "
        label = label .. separator .. conditionLabel(trig.condition):gsub("^%u", string.lower)
      end
      local passive = passiveTrigger(trig)
      if passive and trig.condition then add(conditionLabel(trig.condition) .. ":", gold)
      elseif not passive then add(label .. ":", gold) end
      for _, text in ipairs(effectLines(trig.effects, trig, nil, details, context)) do add((passive and "" or "  ") .. text, green) end
      if details and trig.on == "regularHit" then add("  Extra attacks do not trigger this effect.", grey) end
      if trig.oncePerActivation then add("  Each attack can trigger this once.", grey) end
    end
  end
  for _, text in ipairs(bankReferences(def, context, details)) do add(text, green) end
  if #def.adjacency > 0 then
    add(ns.L[def.kind == "bag" and "Bag effects:" or "Adjacent effects:"], { r = 0.4, g = 0.8, b = 1 })
    for _, rule in ipairs(def.adjacency) do
      local target = filterLabel(rule.match)
      local per = rule.inside and (rule.once and "an" or "each") or (rule.once and "an adjacent" or "each adjacent")
      local where = rule.inside and " inside" or ""
      if rule.mods then
        local phrase = Describe.FilterPhrase(rule.match, "every")
        if rule.inside then phrase = (rule.match and rule.match.kind == "ammo" and "Ammo" or triggerSubject(rule.match)) .. " inside"
        else
          local subject = triggerSubject(rule.match)
          if rule.match and not rule.match.key then
            if rule.match.tag == "spell" then subject = "spells"
            elseif rule.match.tag == "heal" then subject = "healing abilities" end
          end
          phrase = "Adjacent " .. subject
        end
        add(string.format("  %s: %s.", phrase, describeMods(rule.mods)), green)
      end
      if rule.selfMods then add(string.format("  Gains %s for %s %s%s.", describeMods(rule.selfMods), per, target, where), green) end
      if rule.stats then
        local parts = describeStats(rule.stats)
        if rule.inside then
          local subject = rule.match and rule.match.kind == "ammo" and "ammo item" or target:lower()
          add(string.format("  %s %s inside: %s.", rule.once and "An" or "Each", subject, table.concat(parts, ", ")), green)
        else
          add(string.format("  You gain %s for %s %s.", table.concat(parts, ", "), per, target), green)
        end
      end
    end
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
