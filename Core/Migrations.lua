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

function Migrations.Upgrade(data)
  local context = { inferCompanions = data.class == "PALADIN" and data.dataVersion == 21 }
  if data.dataVersion == ns.DATA_VERSION then return data, context end
  if not supportedLegacy(data) then return nil end
  if needsInventoryMigration(data) then
    local candidate, info = migrateInventory(data)
    if not candidate then return nil end
    context.inferCompanions, context.info = false, info
    return candidate, context
  end
  data = Util.ShallowCopy(data)
  data.dataVersion = ns.DATA_VERSION
  return data, context
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
  if not ns.RETIRED_IDS[BLOODRAGE_ID] or ns.Items[BLOODRAGE_ID] then return end
  for index = #run.shop.offers, 1, -1 do
    if run.shop.offers[index] == BLOODRAGE_ID then run:RemoveOffer(index) end
  end
end

local function recoverDuplicates(data)
  if type(data) ~= "table" or data.dataVersion ~= 16 then return nil end
  local candidate, info = migrateInventory(data, true)
  if not candidate or info.removed == 0 then return nil end
  local ok, restored = pcall(Run.Restore, candidate)
  if ok and restored then return restored, info.removed, info end
  return nil
end

local function refundMessage(info, messages)
  if info and info.refunded > 0 then
    messages[#messages + 1] = string.format(L["Refunded %d gold for items that no longer fit."], info.refunded)
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
  if run and migration and migration.changed and legacy then
    out.backups[1] = { reason = "migration", run = original }
    out.save = run:Serialize()
    out.messages[1] = L[migration.quivers > 0 and "Quivers replaced with bags. Original save backed up." or "Extra ammo stored or refunded. Original save backed up."]
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
