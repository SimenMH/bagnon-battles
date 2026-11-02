local ADDON, ns = ...
local Util = ns.Util

local Economy = {}
ns.Economy = Economy

Economy.ROUNDS = 20
Economy.MAX_LOSSES = 5
Economy.MAX_WINS = 10
Economy.SHOP_SIZE = 8
Economy.REROLL_COST = 1
Economy.REROLL_COST_LATE = 2
Economy.CHEAP_REROLLS = 4
Economy.SALE_CHANCE = 0
local BAG_STOCK = { 4, 3, 2, 1, 1 }

function Economy.CategorySize(round)
  return round >= 6 and 4 or 3
end

function Economy.ShopSize(round)
  return Economy.CategorySize(round) * 2
end

Economy.INCOME = { 13, 13, 15, 16, 18, 20, 22, 24, 26, 28, 30, 32, 33, 34, 35, 36, 36, 36, 36, 36 }
Economy.HEALTH = { 150, 190, 230, 275, 377, 501, 643, 801, 977, 1207, 1460, 1620, 1780, 1940, 2160, 2380, 2600, 2800, 3020, 3240 }

Economy.RARITY_ODDS = {
  { 90, 10, 0, 0, 0 },
  { 84, 15, 1, 0, 0 },
  { 75, 20, 5, 0, 0 },
  { 64, 25, 10, 1, 0 },
  { 45, 35, 15, 5, 0 },
  { 29, 40, 20, 10, 1 },
  { 20, 35, 25, 15, 5 },
  { 20, 30, 25, 15, 10 },
  { 20, 28, 25, 15, 12 },
  { 20, 25, 25, 15, 15 },
  { 20, 23, 23, 17, 17 },
  { 20, 20, 20, 20, 20 },
}

function Economy.Income(round)
  return Economy.INCOME[Util.Clamp(round, 1, #Economy.INCOME)]
end

function Economy.CumulativeGold(round)
  local total = 0
  for r = 1, math.min(round, Economy.ROUNDS) do total = total + Economy.Income(r) end
  return total
end

function Economy.SellPrice(def, trainingSpent)
  if def.kind == "ability" and (def.rankable or def.rank) then
    local base = ns.Ranks.Base(def)
    local spent = trainingSpent == nil and def.cost - base.cost or trainingSpent
    return math.ceil((base.cost + math.max(0, spent)) / 2)
  end
  return math.ceil((def.craftedCost or def.cost) / 2)
end

function Economy.SalePrice(def)
  return math.ceil(def.cost / 2)
end

function Economy.RerollCost(rerolls)
  if rerolls < Economy.CHEAP_REROLLS then return Economy.REROLL_COST end
  return Economy.REROLL_COST_LATE
end

function Economy.RarityOdds(round, category)
  local odds = Economy.RARITY_ODDS[Util.Clamp(round, 1, #Economy.RARITY_ODDS)]
  if category ~= "gear" then return odds end
  local legendary = math.min(odds[5], round >= 15 and 3 or 2)
  if legendary == odds[5] then return odds end
  local redistributed = (odds[5] - legendary) / 2
  return { odds[1], odds[2], odds[3] + redistributed, odds[4] + redistributed, legendary }
end

function Economy.StockKey(def)
  local base = def.baseKey and ns.ItemsByKey[def.baseKey]
  return base and base.id or def.id
end

function Economy.StockLimit(def)
  if def.kind == "bag" then return BAG_STOCK[def.quality] or 1 end
  return 1
end

local function stockAmount(value)
  if value == true then return 1 end
  if type(value) == "number" then return math.max(0, math.floor(value)) end
  return 0
end

local function addStock(counts, id, amount)
  local def = ns.Items[id]
  if not def then return end
  local key = Economy.StockKey(def)
  counts[key] = (counts[key] or 0) + stockAmount(amount)
end

function Economy.StockCounts(grid, stash, consumedMaterials)
  local counts = {}
  for _, placement in ipairs(grid and grid.items or {}) do addStock(counts, placement.id, 1) end
  for _, placement in ipairs(grid and grid.bags or {}) do addStock(counts, placement.id, 1) end
  for _, id in ipairs(stash or {}) do addStock(counts, id, 1) end
  for id, amount in pairs(consumedMaterials or {}) do addStock(counts, id, amount) end
  return counts
end

local function matchesForm(def, form)
  local tag = form == "bearform" and "bear" or form == "catform" and "cat"
  return def.use and def.use.requires == form or tag and def.tagSet and def.tagSet[tag]
end

function Economy.FormPreference(grid, stash)
  local equipped, stored, intended = {}, {}, {}
  local function inspect(def, forms)
    if not def then return end
    if def.kind == "form" and (def.provides == "bearform" or def.provides == "catform") then forms[def.provides] = true end
    if Economy.ShopCategory(def) == "ability" then
      for _, form in ipairs({ "bearform", "catform" }) do if matchesForm(def, form) then intended[form] = true end end
    end
  end
  for _, placement in ipairs(grid and grid.items or {}) do inspect(ns.Items[placement.id], equipped) end
  for _, id in ipairs(stash or {}) do inspect(ns.Items[id], stored) end
  local function single(forms)
    if forms.bearform == forms.catform then return nil end
    return forms.bearform and "bearform" or "catform"
  end
  if next(equipped) then return single(equipped) end
  if next(stored) then return single(stored) end
  return single(intended)
end

function Economy.ShopRequirementsMet(def, ownedCounts)
  if not def.shopRequires then return true end
  local families = {}
  for id, amount in pairs(ownedCounts or {}) do
    local owned = ns.Items[id]
    if owned and Economy.ShopCategory(owned) == "ability" and stockAmount(amount) > 0 then
      families[Economy.StockKey(owned)] = true
    end
  end
  for _, requiredKey in ipairs(def.shopRequires) do
    local required = ns.ItemsByKey[requiredKey]
    if not required or Economy.ShopCategory(required) ~= "ability" or not families[Economy.StockKey(required)] then
      return false, requiredKey
    end
  end
  return true
end

function Economy.AvailableStock(def, counts)
  local owned = counts and stockAmount(counts[Economy.StockKey(def)]) or 0
  return math.max(0, Economy.StockLimit(def) - owned)
end

local function bagWeight(round, bagsOwned)
  if bagsOwned >= ns.MAX_BAGS then return 0 end
  if round <= 3 then return 25 end
  if round <= 8 then return 14 end
  return 8
end
local KIND_BUCKET = {
  ability = "ability", form = "ability", pet = "ability", ammo = "ability",
  weapon = "gear", shield = "gear", armor = "gear", ring = "gear", trinket = "gear", neck = "gear", cloak = "gear", relic = "gear", consumable = "gear",
  material = "material", bag = "bag",
}
Economy.KIND_BUCKET = KIND_BUCKET

function Economy.ShopCategory(def)
  return KIND_BUCKET[def.kind] == "ability" and "ability" or "gear"
end

function Economy.GearWeights(round, bagsOwned)
  local bag = bagWeight(round, bagsOwned or 0)
  local rest = 100 - bag
  local material = round >= 10 and rest * 0.08 or 0
  return {
    { value = "gear", weight = rest - material },
    { value = "material", weight = material },
    { value = "bag", weight = bag },
  }
end

local function pickBag(rng, pool, round, quality, exclude)
  local weighted = {}
  for i = 1, #pool do
    local def = pool[i]
    if def.kind == "bag" and def.quality == quality and not exclude[def.id] then
      local w = 10 - math.abs(def.minRound - round)
      if w < 1 then w = 1 end
      weighted[#weighted + 1] = { value = def, weight = w }
    end
  end
  if #weighted == 0 then return nil end
  return rng:PickWeighted(weighted)
end

local function pickAbility(rng, candidates, talents, formPreference)
  if type(talents) ~= "table" then talents = nil end
  if #candidates <= 1 or type(talents) ~= "table" and not formPreference then return rng:Pick(candidates) end
  local weights, count, total = {}, 0, 0
  for index, def in ipairs(candidates) do
    local spec = ns.Mastery.Spec(def)
    if spec then
      local points = talents and talents[spec]
      if type(points) ~= "number" or points ~= points then points = 0 end
      local weight = 1 + math.min(10, math.max(0, points)) * 0.05
      weights[index] = weight
      count, total = count + 1, total + weight
    end
  end
  local entries, changed = {}, total ~= count
  local feralTotal, preferredTotal = 0, 0
  for index, def in ipairs(candidates) do
    entries[index] = { value = def, weight = weights[index] and weights[index] * count / total or 1 }
    if formPreference and ns.Mastery.Spec(def) == "feral" then
      feralTotal = feralTotal + entries[index].weight
      local preferred = matchesForm(def, formPreference)
      preferredTotal = preferredTotal + entries[index].weight * (preferred and 2 or 1)
    end
  end
  if preferredTotal > feralTotal then
    for _, entry in ipairs(entries) do
      local def = entry.value
      if ns.Mastery.Spec(def) == "feral" then
        local preferred = matchesForm(def, formPreference)
        local weight = entry.weight * (preferred and 2 or 1) * feralTotal / preferredTotal
        if math.abs(weight - entry.weight) > 0.000000001 then changed = true end
        entry.weight = weight
      end
    end
  end
  if not changed then return rng:Pick(candidates) end
  return rng:PickWeighted(entries)
end

local GEAR_ROLES = {
  WARRIOR = { arms = { "ap" }, fury = { "ap" }, prot = { "ap", "block" } },
  HUNTER = { bm = { "ap" }, mm = { "ap" }, surv = { "ap", "sp" } },
  DRUID = { balance = { "sp" }, feral = { "ap" }, resto = { "healing" } },
  PALADIN = { holy = { "healing" }, protection = { "sp", "block" }, retribution = { "ap" } },
  ROGUE = { assassination = { "ap", "sp" }, combat = { "ap" }, subtlety = { "ap" } },
  PRIEST = { discipline = { "sp", "healing" }, holy = { "healing" }, shadow = { "sp" } },
  SHAMAN = { elemental = { "sp" }, enhancement = { "ap" }, restoration = { "healing" } },
  MAGE = { arcane = { "sp" }, fire = { "sp" }, frost = { "sp" } },
  WARLOCK = { affliction = { "sp" }, demonology = { "sp" }, destruction = { "sp" } },
}

function Economy.GearAffinity(def, classKey, talents)
  local roles = GEAR_ROLES[classKey]
  if not roles or type(talents) ~= "table" then return 1 end
  local total, relevant, maximum = 0, 0, 0
  for spec, stats in pairs(roles) do
    local points = talents[spec]
    if type(points) == "number" and points == points and points > 0 then
      points = math.min(10, points)
      total, maximum = total + points, math.max(maximum, points)
      for _, stat in ipairs(stats) do
        if (def.stats[stat] or 0) > 0 then relevant = relevant + points break end
      end
    end
  end
  if maximum < 2 then return 1 end
  return 1 + 1.5 * relevant / total
end

local function pickGear(rng, candidates, classKey, talents)
  if #candidates <= 1 then return rng:Pick(candidates) end
  local entries, changed, first = {}, false
  for index, def in ipairs(candidates) do
    local weight = Economy.GearAffinity(def, classKey, talents)
    entries[index] = { value = def, weight = weight }
    first = first or weight
    if weight ~= first then changed = true end
  end
  if not changed then return rng:Pick(candidates) end
  return rng:PickWeighted(entries)
end

local function pickByQuality(rng, pool, quality, exclude, category, bucket, talents, formPreference, classKey)
  local candidates = {}
  for i = 1, #pool do
    local def = pool[i]
    if def.quality == quality and def.kind ~= "bag" and not exclude[def.id] and Economy.ShopCategory(def) == category
      and (not bucket or KIND_BUCKET[def.kind] == bucket) then
      candidates[#candidates + 1] = def
    end
  end
  if #candidates == 0 then return nil end
  if category == "ability" then return pickAbility(rng, candidates, talents, formPreference) end
  return pickGear(rng, candidates, classKey, talents)
end

local function pickOffer(rng, pool, quality, exclude, category, bucket, allowBag, round, talents, formPreference, classKey)
  for q = quality, 1, -1 do
    local def
    if bucket == "bag" then
      if allowBag then def = pickBag(rng, pool, round, q, exclude) end
    else
      def = pickByQuality(rng, pool, q, exclude, category, bucket, talents, formPreference, classKey)
    end
    if not def then def = pickByQuality(rng, pool, q, exclude, category, nil, talents, formPreference, classKey) end
    if not def and allowBag then def = pickBag(rng, pool, round, q, exclude) end
    if def then return def end
  end
  return nil
end

function Economy.GenerateShop(rng, classKey, round, bagsOwned, owned, reservedId, talents, guaranteeBag, formPreference, companionId)
  bagsOwned = bagsOwned or 0
  local pool = ns.GetShopPool(classKey, round)
  local counts = {}
  for id, amount in pairs(owned or {}) do addStock(counts, id, amount) end
  local groups = { ability = {}, gear = {} }
  local sales = {}
  local exclude = {}
  local allowed = {}
  local function refreshStock()
    for _, def in ipairs(pool) do exclude[def.id] = not allowed[def.id] or Economy.AvailableStock(def, counts) <= 0 end
  end
  local function draw(def)
    local group = groups[Economy.ShopCategory(def)]
    group[#group + 1] = def.id
    local key = Economy.StockKey(def)
    counts[key] = (counts[key] or 0) + 1
    refreshStock()
  end
  for _, def in ipairs(pool) do
    if Economy.ShopRequirementsMet(def, counts) then allowed[def.id] = def end
  end
  refreshStock()
  local companion = companionId and allowed[companionId]
  if companion and Economy.ShopCategory(companion) ~= "ability" then companion = nil end
  local reserved = reservedId and allowed[reservedId]
  if reserved and not exclude[reservedId] and (reserved.kind ~= "bag" or bagsOwned < ns.MAX_BAGS) then
    draw(reserved)
  else
    reserved = nil
  end

  local bagOffered = reserved ~= nil and reserved.kind == "bag"
  for _, category in ipairs({ "ability", "gear" }) do
    local odds = Economy.RarityOdds(round, category)
    for slot = #groups[category] + 1, Economy.CategorySize(round) do
      local entries = {}
      for q = 1, 5 do entries[q] = { value = q, weight = odds[q] } end
      local quality = rng:PickWeighted(entries) or 1
      local bucket = category == "ability" and "ability" or rng:PickWeighted(Economy.GearWeights(round, bagsOwned))
      local allowBag = category == "gear" and not bagOffered and bagsOwned < ns.MAX_BAGS
      local def
      if guaranteeBag and allowBag then
        for q = quality, 1, -1 do
          def = pickBag(rng, pool, round, q, exclude)
          if def then break end
        end
      end
      if not def then def = pickOffer(rng, pool, quality, exclude, category, bucket, allowBag, round, talents, formPreference, classKey) end
      if category == "ability" and companion and not exclude[companion.id] and companion.quality <= quality then def = companion end
      if def then
        draw(def)
        if def.kind == "bag" then bagOffered = true end
      end
    end
  end
  local offers = {}
  for _, category in ipairs({ "ability", "gear" }) do
    for _, id in ipairs(groups[category]) do offers[#offers + 1] = id end
  end
  local reservedIndex = reserved and (Economy.ShopCategory(reserved) == "ability" and 1 or #groups.ability + 1)
  for i = 1, #offers do
    if i ~= reservedIndex and rng:Chance(Economy.SALE_CHANCE) then sales[i] = true end
  end
  local companionOffered
  for _, id in ipairs(offers) do if id == companionId then companionOffered = id break end end
  return offers, sales, companionOffered
end

function Economy.BaseHealth(round)
  return Economy.HEALTH[Util.Clamp(round, 1, #Economy.HEALTH)]
end

function Economy.LivesRemaining(run)
  return math.max(0, math.min(Economy.MAX_LOSSES, Economy.MAX_LOSSES + (run.survivalLife and 1 or 0) - run.losses))
end

function Economy.RunFinished(run)
  return run.round > Economy.ROUNDS or Economy.LivesRemaining(run) <= 0 or run.wins >= Economy.MAX_WINS and not run.survival
end
