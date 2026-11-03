local ADDON, ns = ...

local H = {}
ns.H = H

H.I = ns.icon

H.S = {
  one = { "1" },
  v2 = { "1", "1" },
  h2 = { "11" },
  sq = { "11", "11" },
  v3 = { "1", "1", "1" },
  r23 = { "11", "11", "11" },
  r32 = { "111", "111" },
  v4 = { "1", "1", "1", "1" },
  r24 = { "11", "11", "11", "11" },
  r25 = { "11", "11", "11", "11", "11" },
  r34 = { "111", "111", "111", "111" },
  r44 = { "1111", "1111", "1111", "1111" },
  L = { "10", "11" },
  T = { "111", "010" },
}

H.SLOT_SHAPES = {
  head = H.S.sq, shoulder = H.S.h2, chest = H.S.r23, hands = H.S.v2, legs = H.S.sq, feet = H.S.h2, wrist = H.S.one, waist = H.S.h2,
}

H.ALL_SWORD = { "WARRIOR", "HUNTER", "PALADIN", "ROGUE", "MAGE", "WARLOCK" }
H.ALL_AXE = { "WARRIOR", "HUNTER", "PALADIN", "SHAMAN" }
H.ALL_MACE = { "WARRIOR", "DRUID", "PALADIN", "PRIEST", "SHAMAN", "ROGUE" }
H.ALL_DAGGER = { "WARRIOR", "HUNTER", "DRUID", "ROGUE", "PRIEST", "SHAMAN", "MAGE", "WARLOCK" }
H.ALL_SHIELD = { "WARRIOR", "PALADIN", "SHAMAN" }
H.LEATHER = { "DRUID", "ROGUE" }
H.MAIL = { "HUNTER", "SHAMAN" }
H.PLATE = { "WARRIOR", "PALADIN" }
H.PHYSICAL = { "WARRIOR", "HUNTER", "PALADIN", "ROGUE", "SHAMAN", "DRUID" }
H.PHYSICAL_SWORD = { "WARRIOR", "HUNTER", "PALADIN", "ROGUE" }
H.PHYSICAL_MACE = { "WARRIOR", "PALADIN", "SHAMAN", "DRUID" }

function H.Weapon(t)
  t.kind = "weapon"
  t.hands = t.hands or 1
  if not t.shopClasses then
    local stats = t.stats or {}
    local caster = t.weaponType == "wand" or (stats.sp or 0) > 0 or (stats.healing or 0) > 0 or (stats.mana or 0) > 0 or (stats.regen or 0) > 0
    local physical = (stats.ap or 0) > 0
    t.shopClasses = {}
    local classes = t.classes
    if not classes then
      classes = {}
      for _, class in ipairs(ns.ClassList) do classes[#classes + 1] = class.key end
    end
    for _, key in ipairs(classes) do
      local allowed = true
      if caster and not physical and (key == "WARRIOR" or key == "ROGUE") then allowed = false end
      if not caster and (key == "MAGE" or key == "WARLOCK" or key == "PRIEST") then allowed = false end
      if t.hands == 2 and (key == "ROGUE" or key == "PRIEST" and t.weaponType ~= "staff"
        or (key == "MAGE" or key == "WARLOCK") and t.weaponType ~= "staff") then allowed = false end
      if allowed then t.shopClasses[#t.shopClasses + 1] = key end
    end
  end
  local ranged = ns.RANGED_WEAPON_TYPES[t.weaponType] == true
  local launcher = ranged and t.weaponType ~= "wand"
  if launcher then t.coef = t.coef or math.floor(15 * (t.speed or 2.4) + 0.5) / 100 end
  if not t.shape then
    if t.hands == 2 or launcher then t.shape = H.S.v4
    elseif t.weaponType == "dagger" or t.weaponType == "wand" then t.shape = H.S.v2
    else t.shape = H.S.v3 end
  end
  local coefficient = t.coef or (ranged and 0.30 or math.floor(11 * (t.speed or 2.4) * (t.hands == 2 and 1.5 or 1) + 0.5) / 100)
  t.use = t.use or { cd = t.speed or 2.4, effects = { { type = "damage", weaponSelf = true, coef = coefficient, school = "physical" } } }
  t.use.cd = t.speed or t.use.cd
  t.tags = t.tags or {}
  t.tags[#t.tags + 1] = "weapon"
  t.tags[#t.tags + 1] = "autoattack"
  if ranged then
    t.use.effects[1].ranged = true
    t.tags[#t.tags + 1] = "ranged"
  else
    t.tags[#t.tags + 1] = "melee"
  end
  return ns.RegisterItem(t)
end

function H.Armor(t)
  t.kind = "armor"
  t.shape = t.shape or H.SLOT_SHAPES[t.slot] or H.S.sq
  if t.armorType == "leather" then t.classes = t.classes or H.LEATHER
  elseif t.armorType == "mail" then t.classes = t.classes or H.MAIL
  elseif t.armorType == "plate" then t.classes = t.classes or H.PLATE end
  return ns.RegisterItem(t)
end

function H.Jewel(t)
  t.shape = t.shape or H.S.one
  return ns.RegisterItem(t)
end

function H.Bag(t)
  t.kind = "bag"
  return ns.RegisterItem(t)
end

function H.Ability(t)
  t.kind = t.kind or "ability"
  return ns.RegisterItem(t)
end

function H.Merge(def, extra)
  for k, v in pairs(extra or {}) do def[k] = v end
  return def
end

-- Opt-in authoring helpers. Values are normalized in the definitions themselves,
-- never only in their tooltip text. No class or rank opts in automatically.
local PERCENT_STATS = ns.Util.Set{ "hpPct", "crit", "critDamage", "haste", "dodge", "blockChance", "lifesteal", "dr",
  "dmgPct", "healPct", "petPct", "rangedPct", "meleePct", "spellPct", "ragePct", "rageTakenPct" }
local FRACTION_FIELDS = ns.Util.Set{ "coef", "pctMax", "perPointPctMax", "blockScale", "weaponPct", "gearCoef", "fromEvent" }

local function finitePercent(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

-- Input is percentage points: 99 -> 100, 1.58 -> 1.5, 1.19 -> 1.25.
-- Sub-1% values stay exact; fractional coefficients use the field-map conversion.
function H.FriendlyPercent(value)
  assert(finitePercent(value), "Percentage must be a finite number")
  local magnitude = math.abs(value)
  if magnitude < 1 then return value end
  local step = magnitude >= 10 and 5 or 0.25
  local rounded = math.floor(magnitude / step + 0.5) * step
  return value < 0 and -rounded or rounded
end

local function percentageTarget(base, path)
  assert(type(path) == "string", "Percentage path must be a string")
  local stat = path:match("^stats%.([%a][%w_]*)$")
  if stat and PERCENT_STATS[stat] and base.stats then return base.stats, stat, "percent" end
  local index, field = path:match("^use%.effects%.([1-9]%d*)%.([%a][%w_]*)$")
  local effect = index and base.use and base.use.effects and base.use.effects[tonumber(index)]
  if not index then
    local trigger, effectIndex, effectField = path:match("^triggers%.([1-9]%d*)%.effects%.([1-9]%d*)%.([%a][%w_]*)$")
    effect = trigger and base.triggers and base.triggers[tonumber(trigger)]
    effect = effect and effect.effects and effect.effects[tonumber(effectIndex)]
    field = effectField
  end
  if effect then
    if FRACTION_FIELDS[field] then return effect, field, "fraction" end
    if field == "value" and (effect.type == "buff" or effect.type == "debuff") and PERCENT_STATS[effect.stat] then
      return effect, field, "percent"
    end
  end
  index = path:match("^triggers%.([1-9]%d*)%.chance$")
  if index and base.triggers then return base.triggers[tonumber(index)], "chance", "percent" end
  error("Unsupported percentage path: " .. path)
end

local function percentageFields(base, fields)
  assert(type(base) == "table" and type(fields) == "table", "Percentage authoring needs a base and an explicit field map")
  local resolved = {}
  for path, spec in pairs(fields) do
    assert(type(spec) == "table", "Percentage field needs unit and scale: " .. tostring(path))
    for key in pairs(spec) do assert(key == "unit" or key == "scale", "Unknown percentage field option: " .. tostring(key)) end
    assert(spec.unit == "percent" or spec.unit == "fraction", "Unknown percentage unit: " .. tostring(spec.unit))
    assert(spec.scale == false or spec.scale == "power" or spec.scale == "mult", "Unknown percentage scale: " .. tostring(spec.scale))
    local holder, key, unit = percentageTarget(base, path)
    assert(holder and finitePercent(holder[key]), "Missing numeric percentage field: " .. tostring(path))
    assert(spec.unit == unit, "Percentage unit does not match " .. path)
    resolved[#resolved + 1] = { path = path, holder = holder, key = key, unit = unit, scale = spec.scale }
  end
  return resolved
end

local function friendlyValue(value, unit)
  assert(finitePercent(value), "Percentage field must be a finite number")
  local divisor = unit == "fraction" and 100 or 1
  return H.FriendlyPercent(value * divisor) / divisor
end

-- fields = { ["use.effects.1.coef"] = { unit = "fraction", scale = "power" },
--   ["triggers.1.effects.1.value"] = { unit = "percent", scale = "mult" } }
-- Explicit overrides win over base * declared scale. All validation and rounding
-- finishes before replacing overrides, so an authoring error leaves the rule intact.
function H.FriendlyRankPercentages(base, rule, fields)
  assert(type(rule) == "table", "Percentage authoring needs a rank rule")
  assert(rule.overrides == nil or type(rule.overrides) == "table", "Rank overrides must be a table")
  local resolved = percentageFields(base, fields)
  local overrides = ns.Util.DeepCopy(rule.overrides or {})
  for _, field in ipairs(resolved) do
    local value = overrides[field.path]
    if value == nil then
      local factor = field.scale == false and 1 or rule.scale and rule.scale[field.scale]
      assert(finitePercent(factor) and factor > 0, "Missing positive declared percentage scale for " .. field.path)
      value = field.holder[field.key] * factor
    end
    overrides[field.path] = friendlyValue(value, field.unit)
  end
  rule.overrides = overrides
  return rule
end

-- Base curation is a separate explicit operation. It shares the field map but
-- applies no rank multiplier. Unlisted percentages and all flat quantities stay put.
function H.FriendlyBasePercentages(base, fields)
  local changes = {}
  for _, field in ipairs(percentageFields(base, fields)) do
    changes[#changes + 1] = { holder = field.holder, key = field.key,
      value = friendlyValue(field.holder[field.key], field.unit) }
  end
  for _, change in ipairs(changes) do change.holder[change.key] = change.value end
  return base
end

function H.Damage(low, high, coef, school, extra)
  local e = extra or {}
  e.type, e.min, e.max, e.coef, e.school = "damage", low, high, coef, school
  return e
end

local QUALITY_ROUNDS = { 1, 2, 4, 7, 10 }

function H.QualityAbilities(classes, school)
  return function(id, key, name, spec, icon, quality, data)
    data = data or {}
    data.id, data.key, data.name, data.spec = id, key, name, spec
    data.icon, data.quality, data.classes = H.I(icon), quality, classes
    data.shape = data.shape or (data.use and H.S.v2 or H.S.one)
    data.tags = data.tags or { spec, "spell", school }
    data.minRound = data.minRound or QUALITY_ROUNDS[quality]
    return H.Ability(data)
  end
end

function H.RoundAbilities(classes)
  return function(id, key, name, spec, icon, quality, round, extra)
    local def = H.Merge({ id = id, key = key, name = name, spec = spec, icon = H.I(icon), quality = quality, minRound = round, classes = classes,
      shape = H.S.v2, tags = { spec }, passiveTriggers = true }, extra)
    if def.use then def.passiveTriggers = nil end
    return H.Ability(def)
  end
end

function H.SchoolAbilities(classes, school)
  local function ability(id, key, name, spec, icon, quality, use, extra)
    return H.Ability(H.Merge({ id = id, key = key, name = name, spec = spec, icon = H.I(icon), quality = quality, classes = classes,
      shape = H.S.v2, tags = { spec, "spell", school }, use = use }, extra))
  end
  local function passive(id, key, name, spec, icon, quality, triggers, extra)
    return ability(id, key, name, spec, icon, quality, nil, H.Merge({ passiveTriggers = true, rankable = false, triggers = triggers }, extra))
  end
  return ability, passive
end

function H.SetPiece(t)
  t.kind = "armor"
  t.shape = t.shape or H.SLOT_SHAPES[t.slot]
  return ns.RegisterItem(t)
end

local SET_SLOTS = { "head", "shoulder", "chest", "hands", "legs", "feet" }

function H.SetPieces(spec)
  for i, slot in ipairs(spec.slots or SET_SLOTS) do
    local weight = #ns.BuildRotations(H.SLOT_SHAPES[slot])[1].cells / 2
    local stats = {}
    for stat, value in pairs(spec.stats) do
      local scale = spec.statScale and spec.statScale[stat]
      stats[stat] = scale and math.floor(value * weight * scale + 0.5) or value * weight
    end
    H.SetPiece{
      id = spec.ids and spec.ids[i] or spec.firstId + i - 1, key = spec.key .. "_" .. slot, name = spec.names[i],
      icon = H.I(spec.icons[i] or spec.icons[slot]), quality = spec.qualities and spec.qualities[i] or spec.quality,
      cost = spec.cost, minRound = spec.rounds[i], classes = spec.classes, armorType = spec.armorType,
      slot = slot, set = spec.key, tags = { spec.tag }, stats = stats,
    }
  end
end
