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

local QUALITY_ROUNDS = { 1, 2, 4, 7, 10 }
local TRAINING_ROUNDS = { [2] = 4, [3] = 7 }
local FIXED_RANK_SCALE = { mult = 1, power = 1, cost = 1, offensiveMana = 1 }
local SET_SLOTS = { "head", "shoulder", "chest", "hands", "legs", "feet" }

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



function H.RankProfile(options)
  local base = assert(ns.ItemsByKey[options.key], "Unknown rank family: " .. tostring(options.key))
  local ranks = {}
  for rank = 2, 3 do
    ranks[rank] = {
      minRound = options.minRounds and options.minRounds[rank] or math.max(base.minRound, TRAINING_ROUNDS[rank]),
      trainingCost = options.trainingCosts and options.trainingCosts[rank]
        or (rank == 2 and base.quality + 1 or base.quality * 2 + 1),
      scale = ns.Util.DeepCopy(options.scales and options.scales[rank] or FIXED_RANK_SCALE),
      resourceCost = options.resourceCosts and options.resourceCosts[rank],
      overrides = options.overrides and ns.Util.DeepCopy(options.overrides[rank]),
      id = options.ids and options.ids[rank],
    }
  end
  base.rankable, base.rankProfile = true, { maxRank = 3, ranks = ranks }
  return base
end

function H.SetPiece(t)
  t.kind = "armor"
  t.shape = t.shape or H.SLOT_SHAPES[t.slot]
  return ns.RegisterItem(t)
end

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
