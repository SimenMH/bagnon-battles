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
      if caster and not physical and key == "WARRIOR" then allowed = false end
      if not caster and (key == "MAGE" or key == "WARLOCK" or key == "PRIEST") then allowed = false end
      if t.hands == 2 and (key == "ROGUE" or key == "PRIEST" and t.weaponType ~= "staff"
        or (key == "MAGE" or key == "WARLOCK") and t.weaponType ~= "staff") then allowed = false end
      if allowed then t.shopClasses[#t.shopClasses + 1] = key end
    end
  end
  local ranged = ns.RANGED_WEAPON_TYPES[t.weaponType] == true
  local launcher = ranged and t.weaponType ~= "wand"
  if launcher then t.coef = t.coef or 0.30 end
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
