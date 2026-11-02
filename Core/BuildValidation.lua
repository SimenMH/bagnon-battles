local ADDON, ns = ...
local Economy, Util = ns.Economy, ns.Util

local BuildValidation = {}
ns.BuildValidation = BuildValidation

function BuildValidation.Check(classDef, round, grid, build)
  if type(classDef) ~= "table" or type(build) ~= "table" or type(grid) ~= "table"
    or type(round) ~= "number" or round ~= math.floor(round) or round < 1 or round > Economy.ROUNDS then return false, "invalid build" end
  if type(build.w) ~= "number" or build.w ~= math.floor(build.w) or build.w < 0
    or type(build.l) ~= "number" or build.l ~= math.floor(build.l) or build.l < 0
    or build.w + build.l > round - 1 or build.l > Economy.MAX_LOSSES
    or build.l == Economy.MAX_LOSSES and build.w < Economy.MAX_WINS then return false, "unreachable record" end

  local starters, recipes = {}, {}
  for _, entry in ipairs(classDef.starter or {}) do
    local def = ns.ItemsByKey[entry.key]
    if def then starters[Economy.StockKey(def)] = def end
  end
  for _, recipe in ipairs(ns.Recipes) do
    recipes[recipe.output] = recipes[recipe.output] or {}
    recipes[recipe.output][#recipes[recipe.output] + 1] = recipe
  end
  local function shopPrice(def)
    return Economy.SALE_CHANCE > 0 and Economy.SalePrice(def) or def.cost
  end
  local dates, visiting = {}, {}
  local obtainable
  local function recipeDate(recipe)
    local date = 1
    for _, key in ipairs(recipe.inputs) do
      local input = ns.ItemsByKey[key]
      local unlocked = input and obtainable(input)
      if not unlocked then return nil end
      date = math.max(date, unlocked)
    end
    return date
  end
  obtainable = function(def)
    if dates[def.id] ~= nil then return dates[def.id] or nil end
    if visiting[def.id] or not ns.ItemAllowedForClass(def, classDef.key) then return nil end
    visiting[def.id] = true
    local date
    if def.rank then
      local base = ns.ItemsByKey[def.baseKey]
      if base and ns.Ranks.Definition(base, def.rank) == def then
        date = obtainable(base)
        if date then date = math.max(date, def.minRound) end
        for rank = 2, def.rank do
          local rule = ns.Ranks.TRAINING[rank]
          if not rule then date = nil break end
          if date then date = math.max(date, rule.minRound) end
        end
      end
    elseif starters[def.id] then
      date = 1
    elseif def.noShop then
      if def.craftable then
        for _, recipe in ipairs(recipes[def.key] or {}) do
          local unlocked = recipeDate(recipe)
          if unlocked then date = math.min(date or math.huge, math.max(def.minRound, unlocked)) end
        end
      end
    else
      for candidate = def.minRound, Economy.ROUNDS do
        local odds = Economy.RarityOdds(candidate, Economy.ShopCategory(def))
        for quality = def.quality, #odds do
          if odds[quality] > 0 then date = candidate break end
        end
        if date then break end
      end
    end
    for _, key in ipairs(def.shopRequires or {}) do
      local parent = ns.ItemsByKey[key]
      local unlocked = parent and obtainable(parent)
      if not date or not unlocked then date = nil break end
      date = math.max(date, unlocked)
    end
    visiting[def.id] = nil
    dates[def.id] = date or false
    return date
  end

  local counts = Economy.StockCounts(grid)
  local tasks, owned = {}, {}
  for _, list in ipairs({ grid.bags, grid.items }) do
    for _, placement in ipairs(list) do
      local def = ns.Items[placement.id]
      local date = def and obtainable(def)
      if not date then return false, "cannot obtain " .. tostring(def and def.key or placement.id) end
      if date > round then return false, def.key .. " not obtainable until round " .. date end
      owned[#owned + 1] = def
      if def.noShop and def.craftable and def.quality == ns.QUALITY.LEGENDARY then tasks[#tasks + 1] = { def = def, ancestry = {} } end
    end
  end
  for key, count in pairs(counts) do
    if count > Economy.StockLimit(ns.Items[key]) then return false, "exceeds stock for " .. ns.Items[key].key end
  end
  local consumedStock
  local function expandStock(current, pending, index)
    local task = pending[index]
    if not task then consumedStock = current return true end
    if task.ancestry[task.def.id] then return false end
    local ancestry = Util.ShallowCopy(task.ancestry)
    ancestry[task.def.id] = true
    for _, recipe in ipairs(recipes[task.def.key] or {}) do
      local unlocked = recipeDate(recipe)
      if unlocked and unlocked <= round then
        local nextCounts, nextTasks, valid = Util.ShallowCopy(current), Util.ShallowCopy(pending), true
        for _, key in ipairs(recipe.inputs) do
          local input = ns.ItemsByKey[key]
          local stockKey = Economy.StockKey(input)
          nextCounts[stockKey] = (nextCounts[stockKey] or 0) + 1
          if nextCounts[stockKey] > Economy.StockLimit(input) then valid = false break end
          if input.noShop and input.craftable and input.quality == ns.QUALITY.LEGENDARY then
            nextTasks[#nextTasks + 1] = { def = input, ancestry = ancestry }
          end
        end
        if valid and expandStock(nextCounts, nextTasks, index + 1) then return true end
      end
    end
    return false
  end
  if not expandStock(counts, tasks, 1) then return false, "exceeds consumed recipe stock" end

  local costs, costPath = {}, {}
  local function acquireCost(def)
    if costs[def.id] then return costs[def.id] end
    if costPath[def.id] then return nil end
    costPath[def.id] = true
    local cost
    if def.rank then
      local base = ns.ItemsByKey[def.baseKey]
      local training = math.min(ns.Ranks.Investment(base, def.rank) - base.cost, ns.Ranks.LEGACY_TRAINING[def.rank])
      local purchase = shopPrice(base)
      local resale = math.ceil((base.cost + training) / 2)
      cost = purchase + training + math.min(0, purchase - resale)
    elseif def.noShop and def.craftable then
      for _, recipe in ipairs(recipes[def.key] or {}) do
        local unlocked = recipeDate(recipe)
        if unlocked and unlocked <= round then
          local amount, valid = 0, true
          for _, key in ipairs(recipe.inputs) do
            local paid = acquireCost(ns.ItemsByKey[key])
            if not paid then valid = false break end
            amount = amount + paid
          end
          if valid then cost = math.min(cost or math.huge, amount) end
        end
      end
    else
      cost = shopPrice(def)
    end
    costPath[def.id] = nil
    costs[def.id] = cost
    return cost
  end
  local required, examined = {}, {}
  local function requirements(def)
    if examined[def.id] then return end
    examined[def.id] = true
    if def.rank then requirements(ns.ItemsByKey[def.baseKey]) end
    for _, key in ipairs(def.shopRequires or {}) do
      local parent = ns.ItemsByKey[key]
      required[Economy.StockKey(parent)] = parent
      requirements(parent)
    end
    if def.noShop and def.craftable and #(recipes[def.key] or {}) == 1 then
      for _, key in ipairs(recipes[def.key][1].inputs) do requirements(ns.ItemsByKey[key]) end
    end
  end
  local cost = grid:TotalCost()
  for _, def in ipairs(owned) do
    local face = def.rank and def.cost or def.craftedCost or def.cost
    local paid = acquireCost(def)
    if not paid then return false, "cannot obtain " .. def.key end
    cost = cost + paid - face
    requirements(def)
  end
  for key, def in pairs(required) do
    if not starters[key] and not consumedStock[key] then
      cost = cost + math.max(0, acquireCost(def) - Economy.SellPrice(def))
    end
  end
  local credit = 0
  for key, def in pairs(starters) do
    credit = credit + (consumedStock[key] and shopPrice(def) or Economy.SellPrice(def))
  end
  if cost > Economy.CumulativeGold(round) + credit then return false, "exceeds reachable gold budget" end
  return true
end
