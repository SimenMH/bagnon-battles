local ADDON, ns = ...
local Util = ns.Util
local Economy = ns.Economy
local Run = ns.Run
local L = ns.L

local Migrations = {}
ns.Migrations = Migrations

Migrations.MAX_BACKUPS = 5

local MIN_LOCAL_VERSION = { WARRIOR = 13, HUNTER = 15, DRUID = 16, PALADIN = 21, ROGUE = 21, PRIEST = 21, SHAMAN = 21, MAGE = 21, WARLOCK = 21 }
local BLOODRAGE_ID = 1267




local WARRIOR_TRAINING_V32 = {
  heroic_strike = { 1200, 1, 1 }, rend = { 1201, 1, 1 }, overpower = { 1203, 2, 2 },
  mortal_strike = { 1204, 3, 3 }, execute = { 1205, 3, 4 }, bloodthirst = { 1208, 3, 3 },
  whirlwind = { 1209, 3, 4 }, shield_block = { 1219, 1, 1 }, shield_slam = { 1220, 3, 3 },
  revenge = { 1221, 1, 1 }, sunder_armor = { 1222, 1, 1 }, battle_shout = { 1250, 2, 2 },
  slam = { 1260, 2, 2 }, cleave = { 1701, 4, 7 }, shield_bash = { 1703, 3, 5 },
  hamstring = { 1900, 1, 1 }, demoralizing_shout = { 1905, 1, 1 },
  pummel = { 1907, 4, 7 }, thunder_clap = { 1909, 2, 2 },
}


local CLASS_TRAINING_V33 = {
  PALADIN = {
    blessing_of_kings = { 5030, 3, 5 },
    blessing_of_might = { 5064, 1, 1 },
    consecration = { 5004, 2, 2 },
    flash_of_light = { 5003, 1, 1 },
    hammer_of_wrath = { 5063, 3, 5 },
    holy_light = { 5002, 1, 1 },
    holy_shield = { 5020, 3, 3 },
    holy_shock = { 5005, 3, 3 },
    judgement = { 5001, 1, 1 },
  },
  HUNTER = {
    aimed_shot = { 1400, 3, 4 },
    arcane_shot = { 1402, 1, 1 },
    bestial_wrath = { 1413, 5, 9 },
    bite = { 1426, 1, 1 },
    claw_pet = { 1427, 1, 1 },
    concussive_shot = { 1404, 2, 3 },
    counterattack = { 1432, 3, 5 },
    frost_trap = { 2007, 3, 4 },
    intimidation = { 1414, 3, 4 },
    mend_pet = { 2009, 1, 1 },
    mongoose_bite = { 1430, 2, 3 },
    multi_shot = { 1401, 2, 2 },
    rapid_fire = { 1406, 4, 7 },
    raptor_strike = { 1429, 1, 1 },
    scatter_shot = { 1405, 3, 5 },
    screech = { 1428, 2, 3 },
    serpent_sting = { 1403, 1, 1 },
    volley = { 1409, 2, 4 },
    wing_clip = { 1431, 1, 1 },
    wyvern_sting = { 1440, 5, 10 },
  },
  ROGUE = {
    ambush = { 4029, 2, 2 },
    backstab = { 4017, 2, 2 },
    blade_flurry = { 4020, 4, 7 },
    blind = { 4044, 3, 4 },
    cheap_shot = { 4031, 2, 3 },
    eviscerate = { 4001, 1, 1 },
    expose_armor = { 4045, 2, 2 },
    feint = { 4061, 1, 1 },
    garrote = { 4030, 1, 1 },
    ghostly_strike = { 4033, 2, 2 },
    gouge = { 4018, 1, 1 },
    hemorrhage = { 4032, 1, 1 },
    instant_poison = { 4005, 1, 1 },
    kick = { 4043, 2, 2 },
    kidney_shot = { 4004, 2, 3 },
    riposte = { 4019, 2, 3 },
    rupture = { 4002, 1, 1 },
    sinister_strike = { 4000, 1, 1 },
    slice_and_dice = { 4003, 2, 2 },
    sprint = { 4042, 1, 1 },
    vanish = { 4034, 3, 4 },
  },
  PRIEST = {
    abolish_disease = { 6039, 2, 2 },
    devouring_plague = { 6047, 3, 5 },
    dispel_magic = { 6038, 2, 2 },
    elunes_grace = { 6060, 2, 2 },
    flash_heal = { 6016, 2, 3 },
    greater_heal = { 6017, 3, 4 },
    heal_priest = { 6015, 2, 2 },
    holy_fire = { 6018, 1, 1 },
    holy_nova = { 6019, 3, 4 },
    lesser_heal = { 6013, 1, 1 },
    lightwell = { 6025, 5, 9 },
    mind_blast = { 6027, 1, 1 },
    mind_flay = { 6028, 2, 2 },
    power_infusion = { 6009, 5, 9 },
    power_word_shield = { 6001, 1, 1 },
    prayer_of_healing = { 6020, 4, 7 },
    psychic_scream = { 6037, 2, 2 },
    renew = { 6014, 1, 1 },
    shackle_undead = { 6041, 2, 3 },
    shadow_word_pain = { 6026, 1, 1 },
    silence = { 6036, 3, 4 },
    smite = { 6000, 1, 1 },
  },
  SHAMAN = {
    chain_heal = { 7042, 3, 3 },
    chain_lightning = { 7004, 3, 3 },
    earth_shock = { 7001, 1, 1 },
    fire_nova_totem = { 7062, 3, 4 },
    flame_shock = { 7002, 1, 1 },
    frost_shock = { 7003, 2, 2 },
    healing_stream_totem = { 7070, 1, 1 },
    healing_wave = { 7040, 1, 1 },
    lesser_healing_wave = { 7041, 1, 1 },
    lightning_bolt = { 7000, 1, 1 },
    lightning_shield = { 7025, 1, 1 },
    magma_totem = { 7061, 2, 3 },
    searing_totem = { 7060, 1, 1 },
    stoneclaw_totem = { 7066, 2, 3 },
    stormstrike = { 7024, 3, 3 },
    strength_of_earth_totem_active = { 7160, 1, 1 },
  },
  MAGE = {
    arcane_explosion = { 8002, 1, 1 },
    arcane_missiles = { 8001, 1, 1 },
    arcane_power = { 8013, 5, 10 },
    blast_wave = { 8026, 3, 4 },
    blink = { 8061, 2, 2 },
    blizzard = { 8043, 2, 2 },
    cold_snap = { 8051, 5, 10 },
    combustion = { 8031, 5, 10 },
    cone_of_cold = { 8042, 2, 2 },
    counterspell = { 8007, 2, 2 },
    dampen_magic = { 8071, 2, 2 },
    fire_blast = { 8021, 1, 1 },
    fireball = { 8020, 1, 1 },
    flamestrike = { 8025, 2, 2 },
    frost_nova = { 8041, 1, 1 },
    frostbolt = { 8040, 1, 1 },
    ice_barrier = { 8049, 3, 4 },
    ice_block = { 8050, 4, 7 },
    ignite = { 8023, 2, 2 },
    mana_shield = { 8060, 1, 1 },
    presence_of_mind = { 8012, 5, 10 },
    pyroblast = { 8024, 3, 4 },
    remove_lesser_curse = { 8065, 1, 1 },
    scorch = { 8022, 1, 1 },
  },
  WARLOCK = {
    amplify_curse = { 9010, 3, 4 },
    conflagrate = { 9044, 3, 4 },
    corruption = { 9001, 1, 1 },
    curse_of_agony = { 9002, 1, 1 },
    curse_of_exhaustion = { 9014, 3, 4 },
    curse_of_tongues = { 9071, 2, 2 },
    death_coil = { 9064, 3, 4 },
    drain_life = { 9003, 1, 1 },
    drain_mana = { 9006, 2, 2 },
    drain_soul = { 9005, 2, 2 },
    fear = { 9063, 2, 2 },
    fel_domination = { 9035, 4, 7 },
    healthstone = { 9070, 2, 2 },
    hellfire = { 9046, 2, 2 },
    immolate = { 9041, 1, 1 },
    rain_of_fire = { 9045, 2, 2 },
    searing_pain = { 9042, 1, 1 },
    shadow_bolt = { 9040, 1, 1 },
    shadowburn = { 9043, 3, 4 },
    siphon_life = { 9004, 2, 2 },
    soul_fire = { 9052, 5, 10 },
    soul_link = { 9031, 5, 10 },
  },
  DRUID = {
    abolish_poison = { 2114, 1, 1 },
    barkskin = { 1032, 2, 3 },
    bash = { 2122, 3, 4 },
    claw = { 1012, 1, 1 },
    demoralizing_roar = { 1023, 1, 1 },
    entangling_roots = { 1008, 1, 1 },
    faerie_fire = { 1007, 1, 1 },
    ferocious_bite = { 1016, 3, 5 },
    frenzied_regeneration = { 1022, 3, 5 },
    healing_touch = { 1028, 1, 1 },
    hurricane = { 1004, 4, 7 },
    insect_swarm = { 1003, 2, 2 },
    maul = { 1019, 1, 1 },
    moonfire = { 1002, 1, 1 },
    rake = { 1013, 2, 2 },
    ravage = { 1046, 3, 5 },
    regrowth = { 1027, 2, 2 },
    rejuvenation = { 1026, 1, 1 },
    rip = { 1015, 2, 3 },
    shred = { 1014, 3, 4 },
    starfire = { 1001, 2, 2 },
    swiftmend = { 1029, 3, 4 },
    swipe = { 1020, 2, 3 },
    thorns = { 1033, 1, 1 },
    tigers_fury = { 1017, 2, 3 },
    tranquility = { 1031, 4, 7 },
    wrath = { 1000, 1, 1 },
  },
}

local LEGACY_TRAINING_CREDIT = { [2] = 4, [3] = 11 }

local LEGACY_QUIVERS = {
  [20] = { shape = { "1111" }, quality = 1, minRound = 1, cost = 4, replacement = "woolen_bag" },
  [21] = { shape = { "111111" }, quality = 2, minRound = 3, cost = 6, replacement = "mageweave_bag" },
  [22] = { shape = { "11", "11", "11", "11" }, quality = 3, minRound = 6, cost = 8, replacement = "runecloth_bag" },
  [23] = { shape = { "11", "11", "11", "11", "11" }, quality = 4, minRound = 10, cost = 13, replacement = "bottomless_bag" },
}
for id, def in pairs(LEGACY_QUIVERS) do
  def.id, def.kind, def.key = id, "bag", "legacy_quiver_" .. id
  def.rots, def.distinctRots = ns.BuildRotations(def.shape)
  def.cellCount = #def.rots[1].cells
end

local function supportedLegacy(data)
  if type(data) ~= "table" then return false end
  local version = data.dataVersion
  local minimum = MIN_LOCAL_VERSION[data.class]
  return minimum ~= nil and type(version) == "number" and version == math.floor(version)
    and version >= minimum and version < ns.DATA_VERSION
end

local function dense(list, stride)
  if type(list) ~= "table" or #list % stride ~= 0 then return false end
  for index in pairs(list) do
    if type(index) ~= "number" or index ~= math.floor(index) or index < 1 or index > #list then return false end
  end
  for index = 1, #list do if list[index] == nil then return false end end
  return true
end

local function coordinates(x, y, rot)
  return type(x) == "number" and x == math.floor(x) and type(y) == "number" and y == math.floor(y)
    and type(rot) == "number" and rot == math.floor(rot) and rot >= 0 and rot <= 3
end

local function migrateLegacyTraining(data, version, info)
  local historical
  if data.class == "WARRIOR" and version < 33 then historical = WARRIOR_TRAINING_V32
  elseif data.class ~= "WARRIOR" and version < 34 then historical = CLASS_TRAINING_V33[data.class] end
  if not historical then return data, info end
  local function integer(value, low, high)
    return type(value) == "number" and value == value and value < math.huge
      and value == math.floor(value) and value >= low and (not high or value <= high)
  end
  if not integer(data.round, 1, Economy.ROUNDS + 1) or not integer(data.gold, 0)
    or not dense(data.i, 4) or data.stash ~= nil and not dense(data.stash, 1)
    or data.learnedRanks ~= nil and type(data.learnedRanks) ~= "table"
    or data.trainingResale ~= nil and type(data.trainingResale) ~= "table" then return nil end
  local learned, owned = {}, {}
  local function historicalRank(key, rank)
    local old = historical[key]
    local unlock = rank == 3 and 7 or rank == 2 and 4 or 1
    return old and integer(rank, 1, 3) and data.round >= math.max(old[3], unlock)
  end
  for key, rank in pairs(data.learnedRanks or {}) do
    if historical[key] then
      if not historicalRank(key, rank) then return nil end
      learned[key] = rank
    elseif ns.ItemsByKey[key] and rank ~= 1 then

      return nil
    end
  end
  local function own(id)
    local def = ns.Items[id]
    local key = def and (def.baseKey or def.key)
    local old = key and historical[key]
    if old then
      local base = ns.ItemsByKey[key]
      local rank = def.rank or 1
      if not base or base.id ~= old[1] or not historicalRank(key, rank) then return false end
      owned[key], learned[key] = true, math.max(learned[key] or 1, rank)
    elseif def and def.rank then return false end
    return true
  end
  for index = 1, #data.i, 4 do if not own(data.i[index]) then return nil end end
  for _, id in ipairs(data.stash or {}) do if not own(id) then return nil end end
  local credits = {}
  if data.trainingResale then
    for key, value in pairs(data.trainingResale) do
      local old, rank = historical[key], learned[key]
      if not old or not rank or rank < 2 or not integer(value, 0) then return nil end
      local paid = rank == 2 and old[2] + 1 or old[2] * 3 + 2
      if value > math.max(paid, LEGACY_TRAINING_CREDIT[rank]) or value > 0 and not owned[key] then return nil end
      credits[key] = value
    end
  else


    for key in pairs(owned) do
      if learned[key] >= 2 then credits[key] = LEGACY_TRAINING_CREDIT[learned[key]] end
    end
  end
  local refund, changed = 0, data.trainingResale == nil and next(credits) ~= nil
  for key, value in pairs(credits) do
    local base, rank = ns.ItemsByKey[key], learned[key]
    local investment, legacy = ns.Ranks.Investment(base, rank), ns.Ranks.LegacyTrainingCost(base, rank)
    if not investment or not legacy then return nil end
    local cap = math.max(investment - base.cost, legacy)
    if value > cap then
      credits[key], refund, changed = cap, refund + value - cap, true
    end
  end
  local candidate = Util.ShallowCopy(data)
  candidate.trainingResale, candidate.gold = credits, data.gold + refund
  if changed then
    info = info or { quivers = 0, ammo = 0, removed = 0, refunded = 0 }
    info.changed, info.trainingAdjusted, info.trainingRefunded = true, true, refund
  end
  return candidate, info
end



local TRAINING_V34 = {
  blood_frenzy = { 1047, 7, 5, 14 }, demonic_sacrifice = { 9032, 7, 5, 14 },
  improved_enrage = { 3281, 2, 3, 8 }, improved_fire_totems = { 7082, 3, 3, 8 },
  improved_shred = { 3282, 3, 3, 8 }, improved_thorns = { 3284, 3, 3, 8 },
  precision_paladin = { 5032, 4, 4, 11 }, reflection = { 2108, 4, 4, 11 },
  savage_fury = { 1036, 7, 5, 14 }, soul_fire = { 9052, 10, 6, 17 },
  one_handed_weapon_specialization_paladin = { 5035, 9, 6, 17 }, frost_warding = { 8055, 7, 5, 14 },
  adrenaline_rush = { 4021, 9, 6, 17 },
  improved_healing_touch = { 2111, 4, 4, 11 }, prowl_pet = { 3087, 2, 3, 8 },
}

local TRAINING_V35 = {
  one_handed_weapon_specialization_paladin = { 5035, 9, 6, 17 }, frost_warding = { 8055, 7, 5, 14 },
  adrenaline_rush = { 4021, 9, 6, 17 },
  improved_healing_touch = { 2111, 4, 4, 11 }, prowl_pet = { 3087, 2, 3, 8 },
}

local TRAINING_V36 = {
  improved_healing_touch = { 2111, 4, 4, 11 }, prowl_pet = { 3087, 2, 3, 8 },
}



local NEW_V37_RANKS = { [12101] = true, [22101] = true, [18053] = true, [28053] = true }
local function validPreV37Ranks(data)
  if type(data.i) ~= "table" or data.stash ~= nil and type(data.stash) ~= "table"
    or data.learnedRanks ~= nil and type(data.learnedRanks) ~= "table"
    or data.trainingResale ~= nil and type(data.trainingResale) ~= "table" then return false end
  for _, key in ipairs({ "improved_moonfire", "improved_frostbolt" }) do
    local rank = data.learnedRanks and data.learnedRanks[key]
    if rank ~= nil and (type(rank) ~= "number" or rank ~= 1) then return false end
    local credit = data.trainingResale and data.trainingResale[key]
    if credit ~= nil and credit ~= 0 then return false end
  end
  for index = 1, #(data.i or {}), 4 do if NEW_V37_RANKS[data.i[index]] then return false end end
  for _, id in ipairs(data.stash or {}) do if NEW_V37_RANKS[id] then return false end end
  return true
end

local function migrateProfileTraining(data, info, historical)
  local function integer(value, low)
    return type(value) == "number" and value == value and value < math.huge and value == math.floor(value) and value >= low
  end
  if not integer(data.round, 1) or data.round > Economy.ROUNDS + 1 or not integer(data.gold, 0)
    or not dense(data.i, 4) or data.stash ~= nil and not dense(data.stash, 1)
    or data.learnedRanks ~= nil and type(data.learnedRanks) ~= "table"
    or data.trainingResale ~= nil and type(data.trainingResale) ~= "table" then return nil end
  local owned, learned = {}, {}
  for key, rank in pairs(data.learnedRanks or {}) do learned[key] = rank end
  local function own(id)
    local def = ns.Items[id]
    if not def then return false end
    local key = def.baseKey or def.key
    owned[key] = true
    local rank = def.rank or 1
    if integer(learned[key] or 1, 1) then learned[key] = math.max(learned[key] or 1, rank) end
    return true
  end
  for index = 1, #data.i, 4 do if not own(data.i[index]) then return nil end end
  for _, id in ipairs(data.stash or {}) do if not own(id) then return nil end end
  local credits, refund = {}, 0
  for key, value in pairs(data.trainingResale or {}) do
    local base, rank = ns.ItemsByKey[key], learned[key]
    if not base or not base.rankable or not ns.ItemAllowedForClass(base, data.class) or not integer(rank, 2)
      or not integer(value, 0) or value > 0 and not owned[key] then return nil end
    local def = ns.Ranks.Definition(base, rank)
    local investment, legacy = ns.Ranks.Investment(base, rank), ns.Ranks.LegacyTrainingCost(base, rank)
    if not def or not investment or not legacy then return nil end
    local cap = math.max(investment - base.cost, legacy)
    local old = historical[key]
    local oldCap = cap
    if old then
      if base.id ~= old[1] or rank > 3 or data.round < math.max(old[2], rank == 2 and 4 or 7) then return nil end
      oldCap = math.max(old[rank + 1], legacy)
    elseif def.minRound > data.round then return nil end
    if value > oldCap then return nil end
    credits[key] = math.min(value, cap)
    refund = refund + value - credits[key]
  end
  local candidate = Util.ShallowCopy(data)
  candidate.trainingResale, candidate.gold = credits, data.gold + refund
  if refund > 0 then
    info = info or { quivers = 0, ammo = 0, removed = 0, refunded = 0 }
    info.changed, info.trainingAdjusted, info.trainingRefunded = true, true, refund
  end
  return candidate, info
end

local function migrationRefund(def)
  local base = def.baseKey and ns.ItemsByKey[def.baseKey]
  return base and base.cost or def.craftedCost or def.cost
end

local function needsInventoryMigration(data)
  if not supportedLegacy(data) then return false end
  for _, list in ipairs({ data.g, data.stash }) do
    if type(list) == "table" then
      local stride = list == data.g and 4 or 1
      for index = 1, #list, stride do if LEGACY_QUIVERS[list[index]] then return true end end
    end
  end
  local ammo = 0
  for index = 1, #(type(data.i) == "table" and data.i or {}), 4 do
    local def = ns.Items[data.i[index]]
    if def and def.kind == "ammo" then ammo = ammo + 1 end
  end
  return ammo > 1
end

local function migrateInventory(data, repairDuplicates)
  if not supportedLegacy(data) or not ns.Classes[data.class] or not ns.Grid.ValidHome(data.home)
    or type(data.round) ~= "number" or data.round ~= math.floor(data.round) or data.round < 1 or data.round > Economy.ROUNDS + 1
    or type(data.gold) ~= "number" or data.gold ~= math.floor(data.gold) or data.gold < 0
    or not dense(data.g, 4) or not dense(data.i, 4) or not dense(data.stash, 1) or #data.stash > Run.STASH_SIZE then return nil end
  local layout = ns.Grid.New(data.home)
  local bags, counts, pending = {}, {}, {}
  local function count(def)
    local family = LEGACY_QUIVERS[def.id] and def.id or Economy.StockKey(def)
    counts[family] = (counts[family] or 0) + 1
    return counts[family] <= Economy.StockLimit(def), family
  end
  local function allowed(def)
    if not def or def.minRound > data.round then return false end
    if LEGACY_QUIVERS[def.id] then return data.class == "HUNTER" end
    return ns.ItemAllowedForClass(def, data.class)
  end
  for index = 1, #data.g, 4 do
    local id, x, y, rot = data.g[index], data.g[index + 1], data.g[index + 2], data.g[index + 3]
    local def = ns.Items[id] or LEGACY_QUIVERS[id]
    if not allowed(def) or def.kind ~= "bag" or not coordinates(x, y, rot) or not count(def) then return nil end
    local entry = { def = def, x = x, y = y, rot = rot, legacy = LEGACY_QUIVERS[id] ~= nil }
    bags[#bags + 1], pending[#pending + 1] = entry, entry
  end
  while #pending > 0 do
    local progress = false
    for index = #pending, 1, -1 do
      local entry = pending[index]
      if layout:PlaceBag(entry.def, entry.x, entry.y, entry.rot) then table.remove(pending, index) progress = true end
    end
    if not progress then return nil end
  end
  local entries, seen, slots, removed = {}, {}, {}, 0
  for index = 1, #data.i, 4 do
    local id, x, y, rot = data.i[index], data.i[index + 1], data.i[index + 2], data.i[index + 3]
    local def = ns.Items[id]
    if not allowed(def) or def.kind == "bag" or not coordinates(x, y, rot) then return nil end
    local placed = layout:PlaceItem({ id = id, kind = "material", rots = def.rots }, x, y, rot)
    if not placed then return nil end
    if data.dataVersion >= 17 then
      for _, cell in ipairs(placed.cells) do
        local owner = layout.cells[cell]
        if type(owner) == "table" and LEGACY_QUIVERS[owner.id] and def.kind ~= "ammo" then return nil end
      end
    end
    local ok, family = count(def)
    if not ok then
      if not repairDuplicates or data.dataVersion ~= 16 or seen[family] ~= id or def.kind == "material" or Economy.StockLimit(def) ~= 1 then return nil end
      removed = removed + 1
    else
      seen[family] = id
      local slot, limit = ns.Grid.EquipmentSlot(def)
      if slot and slot ~= "ammo" then
        slots[slot] = (slots[slot] or 0) + 1
        if slots[slot] > limit then return nil end
      end
      entries[#entries + 1] = { id = id, x = x, y = y, rot = rot, order = index }
    end
  end
  local stash = {}
  for _, id in ipairs(data.stash) do
    local def = ns.Items[id] or LEGACY_QUIVERS[id]
    if not allowed(def) or not count(def) then return nil end
    stash[#stash + 1] = id
  end
  if data.consumedMaterials ~= nil and type(data.consumedMaterials) ~= "table" then return nil end
  for id, amount in pairs(data.consumedMaterials or {}) do
    local def = ns.Items[id]
    if not def or def.kind ~= "material" or amount ~= true or (counts[Economy.StockKey(def)] or 0) > 0 then return nil end
  end
  local candidate = Util.DeepCopy(data)
  local info = { quivers = 0, ammo = 0, refunded = 0, removed = removed, changed = removed > 0 }
  local kept, ammo = {}, false
  for _, entry in ipairs(entries) do
    local def = ns.Items[entry.id]
    if def.kind == "ammo" and ammo then
      info.ammo, info.changed = info.ammo + 1, true
      if #stash < Run.STASH_SIZE then stash[#stash + 1] = entry.id
      else info.refunded = info.refunded + migrationRefund(def) end
    else
      kept[#kept + 1] = entry
      if def.kind == "ammo" then ammo = true end
    end
  end
  local bagCounts, funds = {}, 0
  for _, bag in ipairs(bags) do
    if bag.legacy then funds = funds + bag.def.cost
    else bagCounts[bag.def.id] = (bagCounts[bag.def.id] or 0) + 1 end
  end
  for _, id in ipairs(stash) do
    local def = ns.Items[id] or LEGACY_QUIVERS[id]
    if LEGACY_QUIVERS[id] then funds = funds + def.cost
    elseif def.kind == "bag" then bagCounts[id] = (bagCounts[id] or 0) + 1 end
  end
  local function replacement(old, rot, exact)
    local choices = {}
    for _, def in ipairs(ns.ItemList) do
      if def.kind == "bag" and def.minRound <= data.round and ns.ItemAllowedForClass(def, data.class)
        and (bagCounts[def.id] or 0) < Economy.StockLimit(def) and def.cost <= funds then
        local selectedRot
        for _, value in ipairs(def.distinctRots) do
          if def.rots[value + 1].sig == old.rots[rot + 1].sig then selectedRot = value break end
        end
        if not exact or selectedRot then
          local score = math.abs(def.cellCount - old.cellCount) * 100 + math.abs(def.cost - old.cost)
          if def.key == old.replacement then score = score - 1 end
          choices[#choices + 1] = { def = def, rot = selectedRot or 0, score = score }
        end
      end
    end
    table.sort(choices, function(a, b) if a.score ~= b.score then return a.score < b.score end return a.def.id < b.def.id end)
    local selected = choices[1]
    if selected then
      funds = funds - selected.def.cost
      bagCounts[selected.def.id] = (bagCounts[selected.def.id] or 0) + 1
    end
    return selected
  end
  local repack = false
  for _, bag in ipairs(bags) do
    if bag.legacy then
      info.quivers, info.changed = info.quivers + 1, true
      local selected = replacement(bag.def, bag.rot, true)
      if not selected then selected = replacement(bag.def, bag.rot, false) repack = true end
      bag.def, bag.rot = selected and selected.def or nil, selected and selected.rot or 0
    end
  end
  for index = #stash, 1, -1 do
    local old = LEGACY_QUIVERS[stash[index]]
    if old then
      info.quivers, info.changed = info.quivers + 1, true
      local selected = replacement(old, 0, false)
      if selected then stash[index] = selected.def.id else table.remove(stash, index) end
    end
  end
  info.refunded = info.refunded + funds
  candidate.gold = data.gold + info.refunded
  candidate.stash = stash
  candidate.g, candidate.i = {}, {}
  for _, bag in ipairs(bags) do
    if bag.def then
      for _, value in ipairs({ bag.def.id, bag.x, bag.y, bag.rot }) do candidate.g[#candidate.g + 1] = value end
    end
  end
  for _, entry in ipairs(kept) do
    for _, value in ipairs({ entry.id, entry.x, entry.y, entry.rot }) do candidate.i[#candidate.i + 1] = value end
  end
  local grid = not repack and ns.Grid.Deserialize(candidate.g, candidate.i, data.class, data.home)
  if not grid then
    local best, missingBest, bestScore
    for pass = 1, 4 do
      local attempt = ns.Grid.New(data.home)
      local ordered = {}
      for _, bag in ipairs(bags) do if bag.def then ordered[#ordered + 1] = bag end end
      if pass > 1 then table.sort(ordered, function(a, b) if a.def.cellCount ~= b.def.cellCount then return a.def.cellCount > b.def.cellCount end return a.def.id < b.def.id end) end
      local missingBags = {}
      for _, bag in ipairs(ordered) do
        local placed = attempt:PlaceBag(bag.def, bag.x, bag.y, bag.rot)
        if not placed then
          local x, y, rot = attempt:FindBagFit(bag.def)
          if x then placed = attempt:PlaceBag(bag.def, x, y, rot) end
        end
        if not placed then missingBags[#missingBags + 1] = bag.def.id end
      end
      local orderedItems = Util.ShallowCopy(kept)
      if pass % 2 == 0 then table.sort(orderedItems, function(a, b) if ns.Items[a.id].cellCount ~= ns.Items[b.id].cellCount then return ns.Items[a.id].cellCount > ns.Items[b.id].cellCount end return a.order < b.order end) end
      local missing = {}
      for _, entry in ipairs(orderedItems) do
        local def = ns.Items[entry.id]
        local placed = pass <= 2 and attempt:PlaceItem(def, entry.x, entry.y, entry.rot)
        if not placed then
          local x, y, rot = attempt:FindFit(def, entry.rot)
          if x then placed = attempt:PlaceItem(def, x, y, rot) end
        end
        if not placed then missing[#missing + 1] = def.id end
      end
      for _, id in ipairs(missingBags) do missing[#missing + 1] = id end
      local score = #missing
      for _, id in ipairs(missing) do score = score + migrationRefund(ns.Items[id]) * 1000 end
      if not best or score < bestScore then best, missingBest, bestScore = attempt, missing, score end
      if #missing == 0 then break end
    end
    grid = best
    for _, id in ipairs(missingBest) do
      if #candidate.stash < Run.STASH_SIZE then candidate.stash[#candidate.stash + 1] = id
      else
        local def = ns.Items[id]
        local value = migrationRefund(def)
        candidate.gold, info.refunded = candidate.gold + value, info.refunded + value
      end
    end
  end
  candidate.g, candidate.i, candidate.home = grid:Serialize()
  candidate.dataVersion = ns.DATA_VERSION
  return candidate, info
end





local DRAFT_SHAPE_OFFSETS = {
  improved_enrage = { [3] = { { 1, 0 }, { 0, 1 }, { 1, 1 } } },
  improved_thorns = { [3] = { { 2, 0 }, { 0, 1 }, { 1, 1 }, { 2, 1 } } },
  druid_ferocity = { [1] = { { 1, 0 }, { 1, 1 } }, [2] = { { 0, 1 }, { 1, 1 } } },
}

local function migrateDraftShapes(data, info)
  if data.class ~= "DRUID" or ns.Grid.Deserialize(data.g, data.i, data.class, data.home) then return data, info end
  if not dense(data.i, 4) then return nil end
  local candidate, choices = Util.ShallowCopy(data), {}
  candidate.i = Util.DeepCopy(data.i)
  for index = 1, #data.i, 4 do
    local def = ns.Items[data.i[index]]
    local rotations = def and DRAFT_SHAPE_OFFSETS[def.baseKey or def.key]
    local offsets = rotations and rotations[data.i[index + 3]]
    if offsets then choices[#choices + 1] = { index = index, offsets = offsets } end
  end
  if #choices == 0 then return nil end
  local attempts = 0
  local function fit(index)
    if attempts >= 256 then return false end
    if index > #choices then
      attempts = attempts + 1
      return ns.Grid.Deserialize(candidate.g, candidate.i, candidate.class, candidate.home) ~= nil
    end
    local choice = choices[index]
    local x, y = data.i[choice.index + 1], data.i[choice.index + 2]
    if type(x) ~= "number" or type(y) ~= "number" then return false end

    for option = 0, #choice.offsets do
      local offset = option > 0 and choice.offsets[option]
      candidate.i[choice.index + 1] = x + (offset and offset[1] or 0)
      candidate.i[choice.index + 2] = y + (offset and offset[2] or 0)
      if fit(index + 1) then return true end
    end
    return false
  end
  if not fit(1) then return nil end
  info = info or { quivers = 0, ammo = 0, removed = 0, refunded = 0 }
  info.changed, info.shapeAdjusted = true, true
  return candidate, info
end

local FERAL_FAERIE_FIRE_RANKS = { [3280] = 1, [13280] = 2, [23280] = 3 }

local function migrateFeralFaerieFire(data, context)
  if ns.Items[3280] or not ns.RETIRED_IDS[3280] then return data end
  if not dense(data.i, 4) or data.stash ~= nil and not dense(data.stash, 1) then return nil end
  local items, stash, owned, rank = {}, {}, 0, 1
  for index = 1, #data.i, 4 do
    local retiredRank = FERAL_FAERIE_FIRE_RANKS[data.i[index]]
    if retiredRank then
      owned, rank = owned + 1, math.max(rank, retiredRank)
      context.feralFirePlacement = { data.i[index + 1], data.i[index + 2], data.i[index + 3] }
    else
      for offset = 0, 3 do items[#items + 1] = data.i[index + offset] end
    end
  end
  for _, id in ipairs(data.stash or {}) do
    local retiredRank = FERAL_FAERIE_FIRE_RANKS[id]
    if retiredRank then owned, rank = owned + 1, math.max(rank, retiredRank)
    else stash[#stash + 1] = id end
  end
  local learned, credit
  if type(data.learnedRanks) == "table" then learned = data.learnedRanks.faerie_fire_feral end
  if type(data.trainingResale) == "table" then credit = data.trainingResale.faerie_fire_feral end
  if owned == 0 and learned == nil and credit == nil then return data end
  local function integer(value, low, high)
    return type(value) == "number" and value == value and value < math.huge
      and value == math.floor(value) and value >= low and (not high or value <= high)
  end
  if data.class ~= "DRUID" or owned > 1 or not integer(data.round, 2, Economy.ROUNDS + 1)
    or not integer(data.gold, 0) or #(data.stash or {}) > Run.STASH_SIZE
    or data.learnedRanks ~= nil and type(data.learnedRanks) ~= "table"
    or data.trainingResale ~= nil and type(data.trainingResale) ~= "table"
    or learned ~= nil and not integer(learned, 1, 3) then return nil end
  rank = math.max(rank, learned or 1)
  if data.round < (rank == 3 and 7 or rank == 2 and 4 or 2) then return nil end
  local cap = rank == 3 and 5 or rank == 2 and 2 or 0
  if credit ~= nil and (rank < 2 or not integer(credit, 0, cap) or owned == 0 and credit > 0) then return nil end
  local refund = owned == 1 and 4 + (credit or data.trainingResale == nil and cap or 0) or 0
  local candidate = Util.ShallowCopy(data)
  candidate.i, candidate.stash, candidate.gold = items, stash, data.gold + refund
  for _, field in ipairs({ "learnedRanks", "trainingResale" }) do
    if data[field] then
      candidate[field] = Util.ShallowCopy(data[field])
      candidate[field].faerie_fire_feral = nil
    end
  end
  context.retiredFaerieFire, context.retiredRefunded = true, refund
  return candidate
end

local function finishFeralFaerieFire(data, context)
  local placement = context.feralFirePlacement
  if placement then
    local x, y, rot = unpack(placement)
    if not coordinates(x, y, rot) then return nil end
    local grid = ns.Grid.Deserialize(data.g, data.i, data.class, data.home)
    if not grid or not grid:CanPlaceItem({ kind = "ability", rots = ns.BuildRotations({ "11" }) }, x, y, rot) then return nil end
  end
  if context.retiredFaerieFire then
    context.info = context.info or { quivers = 0, ammo = 0, removed = 0, refunded = 0 }
    context.info.changed, context.info.retiredFaerieFire = true, true
    context.info.retiredRefunded = context.retiredRefunded
  end
  return data, context
end

function Migrations.Upgrade(data)
  local context = { inferCompanions = data.class == "PALADIN" and data.dataVersion == 21 }
  if data.dataVersion ~= ns.DATA_VERSION and not supportedLegacy(data) then return nil end
  data = migrateFeralFaerieFire(data, context)
  if not data then return nil end
  if data.dataVersion == ns.DATA_VERSION then return finishFeralFaerieFire(data, context) end
  local version = data.dataVersion
  if version < 37 and not validPreV37Ranks(data) then return nil end
  if needsInventoryMigration(data) then
    local candidate, info = migrateInventory(data)
    if not candidate then return nil end
    context.inferCompanions, context.info = false, info
    data = candidate
  end
  local candidate, info = migrateLegacyTraining(data, version, context.info)
  if not candidate then return nil end
  data, context.info = candidate, info
  if version == 34 then
    candidate, info = migrateProfileTraining(data, context.info, TRAINING_V34)
    if not candidate then return nil end
    data, context.info = candidate, info
  end
  if version == 35 then
    candidate, info = migrateProfileTraining(data, context.info, TRAINING_V35)
    if not candidate then return nil end
    data, context.info = candidate, info
  end
  if version == 36 then
    candidate, info = migrateProfileTraining(data, context.info, TRAINING_V36)
    if not candidate then return nil end
    data, context.info = candidate, info
  end
  if version >= 34 and version < 36 then
    candidate, info = migrateDraftShapes(data, context.info)
    if not candidate then return nil end
    data, context.info = candidate, info
  end
  data = Util.ShallowCopy(data)
  data.dataVersion = ns.DATA_VERSION
  return finishFeralFaerieFire(data, context)
end

function Migrations.RepairInventory(data)
  local removedPlacement
  if ns.RETIRED_IDS[BLOODRAGE_ID] and not ns.Items[BLOODRAGE_ID] then
    local items, stash, owned = {}, {}, 0
    if #(data.i or {}) % 4 ~= 0 then return nil end
    for index = 1, #(data.i or {}), 4 do
      if data.i[index] == BLOODRAGE_ID then
        owned = owned + 1
        removedPlacement = { data.i[index + 1], data.i[index + 2], data.i[index + 3] }
      else
        for offset = 0, 3 do items[#items + 1] = data.i[index + offset] end
      end
    end
    for _, id in ipairs(data.stash or {}) do
      if id == BLOODRAGE_ID then owned = owned + 1 else stash[#stash + 1] = id end
    end
    if owned > 0 then
      if owned ~= 1 or data.class ~= "WARRIOR" or data.round < 2 or #(data.stash or {}) > Run.STASH_SIZE then return nil end
      data = Util.ShallowCopy(data)
      data.i, data.stash, data.gold = items, stash, data.gold + 5
    end
  end
  local casterStarter = ns.ItemsByKey.warlock_worn_dirk
  if data.class == "WARLOCK" and casterStarter and dense(data.i, 4) and (data.stash == nil or dense(data.stash, 1)) then
    local old, current = ns.ItemsByKey.worn_dagger.id, casterStarter.id
    local ownsOld, ownsCurrent = false, false
    for index = 1, #data.i, 4 do
      ownsOld = ownsOld or data.i[index] == old
      ownsCurrent = ownsCurrent or data.i[index] == current
    end
    for _, id in ipairs(data.stash or {}) do
      ownsOld = ownsOld or id == old
      ownsCurrent = ownsCurrent or id == current
    end
    if ownsOld and not ownsCurrent then
      data = Util.ShallowCopy(data)
      data.i, data.stash = Util.DeepCopy(data.i), Util.DeepCopy(data.stash or {})
      for index = 1, #data.i, 4 do if data.i[index] == old then data.i[index] = current end end
      for index, id in ipairs(data.stash) do if id == old then data.stash[index] = current end end
    end
  end
  return data, removedPlacement
end

function Migrations.FitsRemovedPlacement(grid, placement)
  local x, y, rot = unpack(placement)
  if not coordinates(x, y, rot) then return false end
  return grid:CanPlaceItem({ kind = "ability", rots = ns.BuildRotations({ "1", "1" }) }, x, y, rot)
end

function Migrations.PurgeRetiredOffers(run)
  for index = #run.shop.offers, 1, -1 do
    local id = run.shop.offers[index]
    if not ns.Items[id] and ns.RETIRED_IDS[id] and (id == BLOODRAGE_ID or FERAL_FAERIE_FIRE_RANKS[id]) then run:RemoveOffer(index) end
  end
end

local function recoverDuplicates(data)
  if type(data) ~= "table" or data.dataVersion ~= 16 then return nil end
  local candidate, info = migrateInventory(data, true)
  if not candidate or info.removed == 0 then return nil end
  candidate, info = migrateLegacyTraining(candidate, data.dataVersion, info)
  if not candidate then return nil end
  local ok, restored = pcall(Run.Restore, candidate)
  if ok and restored then return restored, info.removed, info end
  return nil
end

local function refundMessage(info, messages)
  if info and info.refunded > 0 then
    messages[#messages + 1] = string.format(L["Refunded %d gold for items that no longer fit."], info.refunded)
  end
  if info and (info.trainingRefunded or 0) > 0 then
    messages[#messages + 1] = string.format(L["Refunded %d gold from previous training costs."], info.trainingRefunded)
  end
  if info and (info.retiredRefunded or 0) > 0 then
    messages[#messages + 1] = string.format(L["Refunded %d gold for Faerie Fire (Feral)."], info.retiredRefunded)
  end
end

function Migrations.LoadSaved(saved)
  local out = { save = saved, backups = {}, messages = {} }
  local original = Util.DeepCopy(saved)
  local legacy = type(saved) == "table" and (saved.dataVersion == 16 or needsInventoryMigration(saved))
  local ok, run, migration = pcall(Run.Restore, saved)
  if not ok then
    out.backups[1] = { reason = "error", run = original }
    out.messages[1] = string.format(L["Your saved run could not be loaded and was kept unchanged, with a backup: %s"], tostring(run))
    return out
  end
  if run and migration and migration.changed and (legacy or migration.trainingAdjusted or migration.shapeAdjusted or migration.retiredFaerieFire) then
    out.backups[1] = { reason = "migration", run = original }
    out.save = run:Serialize()
    if migration.quivers > 0 or migration.ammo > 0 then
      out.messages[1] = L[migration.quivers > 0 and "Quivers replaced with bags. Original save backed up." or "Extra ammo stored or refunded. Original save backed up."]
    elseif migration.shapeAdjusted then
      out.messages[1] = L["Ability shapes updated. Original save backed up."]
    elseif migration.retiredFaerieFire then
      out.messages[1] = L["Faerie Fire (Feral) removed. Original save backed up."]
    else
      out.messages[1] = L["Ability training updated. Original save backed up."]
    end
    refundMessage(migration, out.messages)
  elseif not run and legacy then
    local recovered, removed, repaired = recoverDuplicates(original)
    if recovered then
      run = recovered
      out.backups[1] = { reason = "migration", run = original }
      out.save = recovered:Serialize()
      out.messages[1] = string.format(L[removed == 1 and "Removed %d duplicate item. Original save backed up." or "Removed %d duplicate items. Original save backed up."], removed)
      refundMessage(repaired, out.messages)
    end
  end
  if not run then
    out.save = nil
    out.backups[1] = { reason = "incompatible", run = original }
    out.messages[1] = L["Your saved run can't be continued in this version, so it was backed up. Choose a class to begin."]
  end
  out.run = run
  return out
end
