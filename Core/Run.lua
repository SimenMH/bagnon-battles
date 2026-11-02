local ADDON, ns = ...
local Util = ns.Util
local Economy = ns.Economy

local Run = {}
Run.__index = Run
ns.Run = Run

local FORM_PAIRS = {
  { key = "bear", class = "DRUID", "bear_form", "maul" },
  { key = "cat", class = "DRUID", "cat_form", "claw" },
  { key = "judgement", class = "PALADIN", "seal_of_righteousness", "judgement" },
}

local function companionTarget(run, pair)
  local owned = Economy.StockCounts(run.grid, run.stash)
  local first, second = ns.ItemsByKey[pair[1]], ns.ItemsByKey[pair[2]]
  local a, b = first and (owned[first.id] or 0) > 0, second and (owned[second.id] or 0) > 0
  if a and b then return nil, true end
  if a then return pair[2] end
  if b then return pair[1] end
end

local function companionOffered(run, key)
  for _, id in ipairs(run.shop.offers or {}) do
    local def = ns.Items[id]
    if def and (def.baseKey or def.key) == key then return true end
  end
  return false
end

local function restoreFormCompanions(saved, classKey)
  if type(saved) ~= "table" or type(saved.seen) ~= "table" or type(saved.pending) ~= "table" then return nil end
  for key in pairs(saved) do if key ~= "seen" and key ~= "pending" then return nil end end
  local pairsByKey = {}
  for _, pair in ipairs(FORM_PAIRS) do pairsByKey[pair.key] = pair end
  for key, value in pairs(saved.seen) do
    if not pairsByKey[key] or pairsByKey[key].class ~= classKey or value ~= true then return nil end
  end
  for key, value in pairs(saved.pending) do
    local pair = pairsByKey[key]
    if not pair or pair.class ~= classKey or saved.seen[key] or value ~= pair[1] and value ~= pair[2] then return nil end
  end
  return Util.DeepCopy(saved)
end

function Run:SyncFormCompanions(infer)
  self.formCompanions = self.formCompanions or { seen = {}, pending = {} }
  if self.class ~= "DRUID" and self.class ~= "PALADIN" then return end
  local state = self.formCompanions
  for _, pair in ipairs(FORM_PAIRS) do
    if pair.class == self.class then
      local target, complete = companionTarget(self, pair)
      if complete then state.seen[pair.key] = true end
      if state.seen[pair.key] or not target then
        state.pending[pair.key] = nil
      elseif state.pending[pair.key] == target or infer then
        if companionOffered(self, target) then
          state.seen[pair.key], state.pending[pair.key] = true, nil
        else
          state.pending[pair.key] = target
        end
      else
        state.pending[pair.key] = nil
      end
    end
  end
end

function Run:TrackFormPurchase(def)
  self:SyncFormCompanions()
  if self.class ~= "DRUID" and self.class ~= "PALADIN" then return end
  local family = def.baseKey or def.key
  for _, pair in ipairs(FORM_PAIRS) do
    if pair.class == self.class and not self.formCompanions.seen[pair.key] and (family == pair[1] or family == pair[2]) then
      local target = companionTarget(self, pair)
      if target then
        if companionOffered(self, target) then self.formCompanions.seen[pair.key] = true
        else self.formCompanions.pending[pair.key] = target end
      end
    end
  end
end

function Run.PlaceStarter(grid, classDef)
  for _, entry in ipairs(classDef.starter or {}) do
    local def = ns.ItemsByKey[entry.key]
    if def then
      if entry.x then
        grid:PlaceItem(def, entry.x + grid.home.x - ns.START_X, entry.y + grid.home.y - ns.START_Y, entry.rot or 0)
      else
        local x, y, rot = grid:FindFit(def)
        if x then grid:PlaceItem(def, x, y, rot) end
      end
    end
  end
end

function Run.New(classKey, seed, who)
  local classDef = ns.GetClass(classKey)
  assert(classDef, "unknown class " .. tostring(classKey))
  local run = setmetatable({}, Run)
  run.class = classKey
  run.round = 1
  run.wins = 0
  run.losses = 0
  run.winCounted = false
  run.survival = false
  run.survivalLife = false
  run.gold = Economy.Income(1)
  run.grid = ns.Grid.New()
  run.seed = seed or Util.Now()
  run.who = who or "Player"
  run.history = {}
  run.recent = {}
  run.phase = "shop"
  run.shop = { offers = {}, sales = {}, reserved = nil, rerolls = 0 }
  run.stash = {}
  run.learnedRanks = {}
  run.trainingResale = {}
  run.formCompanions = { seen = {}, pending = {} }
  run.talents = ns.Mastery.Empty(classKey)
  run.consumedMaterials = {}
  run.craftedLegendaries = {}
  run.started = Util.Now()
  Run.PlaceStarter(run.grid, classDef)
  run:SyncFormCompanions(true)
  run:NewShop()
  return run
end

Run.STASH_SIZE = 6

function Run:TalentInfo()
  local allocation = ns.Mastery.Normalize(self.class, self.talents)
  local spent = 0
  for _, points in pairs(allocation) do spent = spent + points end
  local budget = ns.Mastery.Budget(self.round)
  return { budget = budget, spent = spent, available = budget - spent, allocation = allocation }
end

function Run:SetTalent(spec, points)
  if self.phase ~= "shop" then return false, "Change talents between battles." end
  local allocation = ns.Mastery.Normalize(self.class, self.talents)
  if allocation[spec] == nil then return false, "Unknown specialization." end
  if type(points) ~= "number" then return false, "Invalid talent points." end
  allocation[spec] = points
  local valid, err = ns.Mastery.Validate(self.class, self.round, allocation)
  if not valid then return false, err end
  self.talents = allocation
  return true
end

function Run:ResetTalents()
  if self.phase ~= "shop" then return false, "Change talents between battles." end
  self.talents = ns.Mastery.Empty(self.class)
  return true
end

function Run:OwnsItem(id)
  for _, placement in ipairs(self.grid.items) do if placement.id == id then return true end end
  for _, ownedId in ipairs(self.stash or {}) do if ownedId == id then return true end end
  return false
end

function Run:SyncCraftingState()
  local previousCrafts = type(self.craftedLegendaries) == "table" and self.craftedLegendaries or {}
  local previousMaterials = type(self.consumedMaterials) == "table" and self.consumedMaterials or {}
  local crafted, consumed = {}, {}
  for _, recipe in ipairs(ns.Recipes) do
    local output = ns.ItemsByKey[recipe.output]
    if output and output.craftable and output.quality == ns.QUALITY.LEGENDARY and output.minRound <= self.round and ns.ItemAllowedForClass(output, self.class) then
      local complete = previousCrafts[recipe.output] == true or self:OwnsItem(output.id)
      if not complete then
        complete = true
        for _, key in ipairs(recipe.inputs) do
          local input = ns.ItemsByKey[key]
          if not input or previousMaterials[input.id] ~= true then complete = false break end
        end
      end
      if complete then
        crafted[recipe.output] = true
        for _, key in ipairs(recipe.inputs) do consumed[ns.ItemsByKey[key].id] = true end
      end
    end
  end
  self.craftedLegendaries, self.consumedMaterials = crafted, consumed
end

function Run:CheckCrafting()
  if self.phase ~= "shop" then return {} end
  self:SyncCraftingState()
  local crafted = ns.Crafting.Check(self.grid, self.craftedLegendaries)
  self:SyncCraftingState()
  return crafted
end

local function purchaseBlocked(run, def)
  if def.noShop or def.minRound > run.round or not ns.ItemOfferedForClass(def, run.class) then return "That item is not available in this shop." end
  local requirementsMet, missing = Economy.ShopRequirementsMet(def, Economy.StockCounts(run.grid, run.stash))
  if not requirementsMet then return "Requires " .. (ns.ItemsByKey[missing] and ns.ItemsByKey[missing].name or "its base ability") .. "." end
  if def.craftable and run.craftedLegendaries and run.craftedLegendaries[def.key] then return "Already forged this legendary this run." end
  if run.consumedMaterials and run.consumedMaterials[def.id] then return "Already used to forge a legendary this run." end
  if Economy.AvailableStock(def, Economy.StockCounts(run.grid, run.stash, run.consumedMaterials)) <= 0 then return "No copies of this item remain in the pool." end
  return nil
end

local function trainingTarget(run, target)
  if type(target) == "number" and target == math.floor(target) then
    local id = run.stash[target]
    if id then return ns.Items[id], "stash", target end
  elseif type(target) == "table" then
    for _, p in ipairs(run.grid.items) do
      if p == target then return ns.Items[p.id], "grid", p end
    end
  end
  return nil
end

function Run:TrainingInfo(target)
  local def = trainingTarget(self, target)
  if not def then return nil, "Choose an ability in your bag or stash." end
  local base = ns.Ranks.Base(def)
  if not base.rankable then return nil, "This item has no trainable ranks." end
  local learned = math.max(self.learnedRanks[base.key] or 1, def.rank or 1)
  local nextRank = learned < 3 and learned + 1 or nil
  local nextDef = nextRank and ns.Ranks.Definition(base, nextRank)
  local price = nextRank and ns.Ranks.TrainingCost(base, nextRank)
  local reason
  if not nextRank then reason = "All ranks learned."
  elseif self.phase ~= "shop" then reason = "Train between battles."
  elseif self.round < nextDef.minRound then reason = "Available in round " .. nextDef.minRound .. "."
  elseif self.gold < price then reason = "Not enough gold." end
  return {
    base = base, def = def, rank = def.rank or 1, learned = learned, nextRank = nextRank,
    cost = price, minRound = nextDef and nextDef.minRound,
    canTrain = nextRank ~= nil and reason == nil, reason = reason,
  }
end

function Run:SetRank(target, rank)
  if self.phase ~= "shop" then return nil, "Change ranks between battles." end
  local info, err = self:TrainingInfo(target)
  if not info then return nil, err end
  if type(rank) ~= "number" or rank ~= math.floor(rank) or rank < 1 or rank > info.learned then
    return nil, "That rank has not been learned."
  end
  local def = ns.Ranks.Definition(info.base, rank)
  if not def then return nil, "That rank does not exist." end
  local _, where, ref = trainingTarget(self, target)
  if where == "grid" then ref.id = def.id else self.stash[ref] = def.id end
  return def
end

function Run:Train(target)
  local info, err = self:TrainingInfo(target)
  if not info then return nil, err end
  if not info.canTrain then return nil, info.reason end
  self.gold = self.gold - info.cost
  self.learnedRanks[info.base.key] = info.nextRank
  self.trainingResale[info.base.key] = (self.trainingResale[info.base.key] or 0) + info.cost
  return self:SetRank(target, info.nextRank)
end

function Run:SellPrice(def)
  local family = ns.Ranks.FamilyKey(def)
  return Economy.SellPrice(def, family and (self.trainingResale[family] or 0) or nil)
end

function Run:CreditSale(def)
  local price = self:SellPrice(def)
  local family = ns.Ranks.FamilyKey(def)
  if family then self.trainingResale[family] = nil end
  self.gold = self.gold + price
  self:SyncFormCompanions()
  return price
end

function Run:StashAdd(def)
  if #self.stash >= Run.STASH_SIZE then return false, "Your stash is full." end
  if not def or ns.Items[def.id] ~= def or not ns.ItemAllowedForClass(def, self.class) then return false, "That item is not available to your class." end
  self:SyncCraftingState()
  if Economy.AvailableStock(def, Economy.StockCounts(self.grid, self.stash, self.consumedMaterials)) <= 0 then return false, "No copies of this item remain in the pool." end
  self.stash[#self.stash + 1] = def.id
  return true
end

function Run:StashTake(index)
  self:SyncCraftingState()
  local id = self.stash[index]
  if not id then return nil end
  table.remove(self.stash, index)
  return ns.Items[id]
end

function Run:BuyToStash(index)
  if self.phase ~= "shop" then return nil, "Not in the shop." end
  local def = self:OfferDef(index)
  if not def then return nil, "Nothing there." end
  self:SyncCraftingState()
  local blocked = purchaseBlocked(self, def)
  if blocked then return nil, blocked end
  local price = self:OfferPrice(index)
  if self.gold < price then return nil, "Not enough gold." end
  local ok, err = self:StashAdd(def)
  if not ok then return nil, err end
  self.gold = self.gold - price
  self:RemoveOffer(index)
  self:TrackFormPurchase(def)
  return def
end

function Run:ShopRNG()
  return Util.NewRNG(Util.Hash32(table.concat({ self.who, tostring(self.seed), tostring(self.round), tostring(self.shop.rerolls) }, ":")))
end

function Run:NewShop(keepReserved)
  self:SyncCraftingState()
  self:SyncFormCompanions()
  local owned = Economy.StockCounts(self.grid, self.stash, self.consumedMaterials)
  local reservedId
  if keepReserved and self.shop.reserved then reservedId = self.shop.reserved end
  local reservedSale = reservedId and self.shop.reservedSale or nil
  local companionId
  for _, pair in ipairs(FORM_PAIRS) do
    local key = self.formCompanions.pending[pair.key]
    if key then companionId = ns.ItemsByKey[key].id break end
  end
  self.shop.offers, self.shop.sales = Economy.GenerateShop(self:ShopRNG(), self.class, self.round, #self.grid.bags, owned, reservedId,
    self.shopBias and self.shopBias.talents, self.shop.rerolls == 0,
    self.class == "DRUID" and Economy.FormPreference(self.grid, self.stash) or nil, companionId)
  local reservedIndex
  for index, id in ipairs(self.shop.offers) do if id == reservedId then reservedIndex = index break end end
  self.shop.reserved = reservedIndex and reservedId or nil
  self.shop.reservedIndex = reservedIndex
  if reservedIndex and reservedSale then self.shop.sales[reservedIndex] = true end
  self.shop.reservedSale = self.shop.reserved and reservedSale or nil
  self:SyncFormCompanions()
end

function Run:RerollCost()
  return Economy.RerollCost(self.shop.rerolls)
end

function Run:Reroll()
  if self.phase ~= "shop" then return false, "Not in the shop." end
  local cost = self:RerollCost()
  if self.gold < cost then return false, "Not enough gold." end
  self.gold = self.gold - cost
  self.shop.rerolls = self.shop.rerolls + 1
  self:NewShop(true)
  return true
end

function Run:IsReserved(index)
  return self.shop.reservedIndex == index and self.shop.reserved ~= nil and self.shop.offers[index] == self.shop.reserved
end

function Run:ToggleReserve(index)
  local id = self.shop.offers[index]
  if not id then return false end
  if self:IsReserved(index) then
    self.shop.reserved = nil
    self.shop.reservedIndex = nil
    self.shop.reservedSale = nil
  else
    self.shop.reserved = id
    self.shop.reservedIndex = index
    self.shop.reservedSale = self.shop.sales[index] and true or nil
  end
  return true
end

function Run:OfferDef(index)
  local id = self.shop.offers[index]
  return id and ns.Items[id] or nil
end

function Run:OfferIsSale(index)
  return self.shop.sales ~= nil and self.shop.sales[index] == true
end

function Run:OfferPrice(index)
  local def = self:OfferDef(index)
  if not def then return nil end
  if self:OfferIsSale(index) then return Economy.SalePrice(def) end
  return def.cost
end

function Run:CanAfford(index)
  local price = self:OfferPrice(index)
  return price ~= nil and self.gold >= price
end

function Run:RemoveOffer(index)
  if self:IsReserved(index) then
    self.shop.reserved = nil
    self.shop.reservedIndex = nil
    self.shop.reservedSale = nil
  elseif self.shop.reservedIndex and self.shop.reservedIndex > index then
    self.shop.reservedIndex = self.shop.reservedIndex - 1
  end
  table.remove(self.shop.offers, index)
  local sales = {}
  for i, flag in pairs(self.shop.sales or {}) do
    if i < index then sales[i] = flag elseif i > index then sales[i - 1] = flag end
  end
  self.shop.sales = sales
end

function Run:PruneShopOffers()
  local owned = Economy.StockCounts(self.grid, self.stash)
  local removed = 0
  for index = #self.shop.offers, 1, -1 do
    local def = ns.Items[self.shop.offers[index]]
    if def and not Economy.ShopRequirementsMet(def, owned) then
      self:RemoveOffer(index)
      removed = removed + 1
    end
  end
  local reserved = self.shop.reserved and ns.Items[self.shop.reserved]
  if reserved and not Economy.ShopRequirementsMet(reserved, owned) then
    self.shop.reserved, self.shop.reservedIndex, self.shop.reservedSale = nil, nil, nil
  end
  self:SyncFormCompanions()
  return removed
end

function Run:BuyAndPlace(index, x, y, rot)
  if self.phase ~= "shop" then return nil, "Not in the shop." end
  local def = self:OfferDef(index)
  if not def then return nil, "Nothing there." end
  self:SyncCraftingState()
  local blocked = purchaseBlocked(self, def)
  if blocked then return nil, blocked end
  local price = self:OfferPrice(index)
  if self.gold < price then return nil, "Not enough gold." end
  local p, err = self.grid:PlaceItem(def, x, y, rot)
  if not p then return nil, err end
  self.gold = self.gold - price
  self:RemoveOffer(index)
  self:TrackFormPurchase(def)
  local crafted = self:CheckCrafting()
  return p, nil, crafted
end

local HOLD_FIELDS = { "grid", "stash", "gold", "shop", "learnedRanks", "trainingResale", "formCompanions", "consumedMaterials", "craftedLegendaries" }

function Run:BeginHold()
  if self.hold then return end
  local checkpoint = self:Serialize()
  local state = {}
  for _, field in ipairs(HOLD_FIELDS) do state[field] = self[field] end
  self.hold = { checkpoint = checkpoint, state = Util.DeepCopy(state) }
end

function Run:EndHold(rollback)
  local hold = self.hold
  if not hold then return end
  if rollback then
    for _, field in ipairs(HOLD_FIELDS) do self[field] = hold.state[field] end
  end
  self.hold = nil
end

function Run:IsHolding()
  return self.hold ~= nil
end

function Run:LiftPlacement(p)
  if self.phase ~= "shop" then return nil, nil, "Not in the shop." end
  p = type(p) == "table" and self.grid:FindItem(p.uid) or nil
  if not p then return nil, nil, "That item is no longer in your bag." end
  local def = ns.Items[p.id]
  if self.grid:IsBagPlacement(p) then
    local cargo, err = self.grid:LiftBag(p)
    if not cargo then return nil, nil, err end
    return def, cargo
  end
  self.grid:RemoveItem(p)
  if self.grid:FindItem(p.uid) then return nil end
  return def
end

function Run:PlaceHeld(def, x, y, rot, cargo, uid)
  if self.phase ~= "shop" then return nil, "Not in the shop." end
  local p, err
  if def.kind == "bag" then
    p, err = self.grid:PlaceBagWithCargo(def, x, y, rot, cargo)
  else
    p, err = self.grid:PlaceItem(def, x, y, rot)
  end
  if p and uid then p.uid = uid end
  return p, err
end

function Run:SellHeld(def)
  if self.phase ~= "shop" then return nil, "Not in the shop." end
  self:SyncCraftingState()
  local price = self:CreditSale(def)
  self:PruneShopOffers()
  return price
end

function Run:MoveHome(x, y)
  if self.phase ~= "shop" then return false, "Not in the shop." end
  return self.grid:MoveHome(x, y)
end

function Run:Sell(p)
  if self.phase ~= "shop" then return false, "Not in the shop." end
  p = type(p) == "table" and self.grid:FindItem(p.uid) or nil
  if not p then return false, "That item is no longer in your bag." end
  self:SyncCraftingState()
  if self.grid:IsBagPlacement(p) then
    local ok, err = self.grid:RemoveBag(p)
    if not ok then return false, err end
  else
    self.grid:RemoveItem(p)
  end
  return true, nil, self:SellHeld(ns.Items[p.id])
end

function Run:Snapshot()
  return ns.Snapshot.FromRun(self, self.who)
end

function Run:LockIn(finder)
  if self.phase ~= "shop" then return nil, "Not in the shop." end
  if self.hold then return nil, "Place the item you are holding first." end
  local mine = self:Snapshot()
  local myId = ns.Snapshot.Hash(mine)
  local opponent = finder(self, myId)
  local seed = Util.Hash32(myId .. ":" .. opponent.id)
  local result = ns.Sim.Run(
    { name = self.who, classKey = self.class, round = self.round, grid = self.grid, talents = self.talents },
    { name = opponent.build.n, classKey = opponent.classKey, round = self.round, grid = opponent.grid,
      talents = ns.Mastery.Unpack(opponent.classKey, self.round, opponent.build.p) },
    seed)
  local won = result.winner == "A"
  local draw = result.winner == "draw"
  if won then self.wins = self.wins + 1 elseif not draw then self.losses = self.losses + 1 end
  self.history[#self.history + 1] = { round = self.round, won = won, draw = draw }
  self.shopBias = { round = self.round, talents = ns.Mastery.Unpack(self.class, self.round, mine.p) }
  self.recent[#self.recent + 1] = opponent.id
  while #self.recent > 5 do table.remove(self.recent, 1) end
  self.lastBattle = { result = result, opponent = opponent, mine = mine, myId = myId }
  self.phase = "result"
  return result, opponent, mine
end

function Run:NextRound()
  if self.phase ~= "result" then return false end
  if self:NeedsSurvivalChoice() then
    self.phase = "survival"
    return true, false
  end
  self.round = self.round + 1
  if Economy.RunFinished(self) then
    self.phase = "over"
    return true, true
  end
  self.gold = self.gold + Economy.Income(self.round)
  self.shop.rerolls = 0
  self.phase = "shop"
  self:NewShop(true)
  return true, false
end

function Run:NeedsSurvivalChoice()
  return self.phase == "survival" or self.phase == "result" and not self.survival
    and self.wins >= Economy.MAX_WINS and self.round < Economy.ROUNDS and Economy.LivesRemaining(self) > 0
end

function Run:ChooseSurvival(continue)
  if self.phase ~= "survival" or self.survival or self.wins < Economy.MAX_WINS
    or self.round >= Economy.ROUNDS or Economy.LivesRemaining(self) <= 0 then return false, "No Survival choice is pending." end
  if type(continue) ~= "boolean" then return false, "Choose whether to enter Survival." end
  if not continue then
    self.phase = "over"
    return true, true
  end
  self.survival = true
  self.survivalLife = self.losses > 0
  self.phase = "result"
  return self:NextRound()
end

function Run:IsOver()
  return self.phase == "over"
end

function Run:IsVictory()
  return self:IsOver() and self.wins >= Economy.MAX_WINS and Economy.LivesRemaining(self) > 0
end

function Run:Serialize()
  if self.hold then return Util.DeepCopy(self.hold.checkpoint) end
  self:SyncCraftingState()
  local g, i, home = self.grid:Serialize()
  return {
    class = self.class, round = self.round, wins = self.wins, losses = self.losses, gold = self.gold,
    seed = self.seed, who = self.who, history = Util.DeepCopy(self.history), recent = Util.DeepCopy(self.recent),
    phase = self.phase, survival = self.survival == true, survivalLife = self.survivalLife == true,
    winCounted = self.winCounted == true,
    shop = { offers = Util.DeepCopy(self.shop.offers), sales = Util.DeepCopy(self.shop.sales or {}), reserved = self.shop.reserved, reservedIndex = self.shop.reservedIndex, reservedSale = self.shop.reservedSale, rerolls = self.shop.rerolls },
    stash = Util.DeepCopy(self.stash or {}),
    learnedRanks = Util.DeepCopy(self.learnedRanks or {}),
    trainingResale = Util.DeepCopy(self.trainingResale or {}),
    formCompanions = Util.DeepCopy(self.formCompanions or { seen = {}, pending = {} }),
    talents = ns.Mastery.Normalize(self.class, self.talents),
    shopBias = Util.DeepCopy(self.shopBias),
    consumedMaterials = Util.DeepCopy(self.consumedMaterials),
    craftedLegendaries = Util.DeepCopy(self.craftedLegendaries),
    g = g, i = i, home = home, started = self.started, dataVersion = ns.DATA_VERSION,
  }
end

function Run.Restore(data)
  if type(data) ~= "table" or not data.class or not ns.Classes[data.class] then return nil end
  local migration
  data, migration = ns.Migrations.Upgrade(data)
  if not data then return nil end
  if type(data.round) ~= "number" or data.round ~= math.floor(data.round) or data.round < 1 or data.round > Economy.ROUNDS + 1 then return nil end
  if type(data.gold) ~= "number" or data.gold ~= math.floor(data.gold) or data.gold < 0 then return nil end
  for _, value in ipairs({ data.wins, data.losses }) do
    if type(value) ~= "number" or value ~= math.floor(value) or value < 0 or value > Economy.ROUNDS then return nil end
  end
  if data.wins == nil or data.losses == nil then return nil end
  if data.winCounted ~= nil and type(data.winCounted) ~= "boolean" then return nil end
  if data.winCounted and data.wins < Economy.MAX_WINS then return nil end
  if data.survival ~= nil and type(data.survival) ~= "boolean" then return nil end
  if data.survivalLife ~= nil and type(data.survivalLife) ~= "boolean" then return nil end
  local survival, survivalLife = data.survival == true, data.survivalLife == true
  if survival and (data.wins < Economy.MAX_WINS or data.round <= Economy.MAX_WINS) then return nil end
  if survivalLife and (not survival or data.losses == 0) then return nil end
  local phase = data.phase or "shop"
  if phase ~= "shop" and phase ~= "result" and phase ~= "survival" and phase ~= "over" then return nil end
  if data.round > Economy.ROUNDS and phase ~= "over" then return nil end
  if data.history ~= nil and type(data.history) ~= "table" then return nil end
  if data.recent ~= nil and type(data.recent) ~= "table" then return nil end
  local history = data.history or {}
  local completed = history[#history]
  if phase == "shop" and type(completed) == "table" and completed.round == data.round then
    phase = "result"
  end
  if phase == "result" or phase == "survival" then
    if type(completed) ~= "table" or completed.round ~= data.round or type(completed.won) ~= "boolean"
      or completed.draw ~= nil and type(completed.draw) ~= "boolean" or completed.won and completed.draw
      or completed.won and data.wins == 0 or not completed.won and not completed.draw and data.losses == 0 then return nil end
  end
  if data.wins + data.losses > (phase == "shop" and data.round - 1 or math.min(data.round, Economy.ROUNDS)) then return nil end
  if phase == "survival" and (survival or data.wins < Economy.MAX_WINS or data.round >= Economy.ROUNDS
    or Economy.LivesRemaining({ losses = data.losses, survivalLife = survivalLife }) <= 0) then return nil end
  if not ns.Grid.ValidHome(data.home) then return nil end
  local removedPlacement
  data, removedPlacement = ns.Migrations.RepairInventory(data)
  if not data then return nil end
  local grid = ns.Grid.Deserialize(data.g, data.i, data.class, data.home)
  if not grid then return nil end
  if removedPlacement and not ns.Migrations.FitsRemovedPlacement(grid, removedPlacement) then return nil end
  local run = setmetatable({}, Run)
  run.class = data.class
  run.round = data.round
  run.wins = data.wins
  run.losses = data.losses
  run.winCounted = data.winCounted == true
  run.survival = survival
  run.survivalLife = survivalLife
  run.gold = data.gold
  run.grid = grid
  local validTalents = ns.Mastery.Validate(data.class, data.round, data.talents)
  if not validTalents then return nil end
  run.talents = ns.Mastery.Normalize(data.class, data.talents)
  run.seed = data.seed
  run.who = data.who
  run.history = Util.DeepCopy(history)
  local bias = data.shopBias
  local lastRound = type(run.history) == "table" and run.history[#run.history]
  if type(bias) == "table" and type(bias.round) == "number" and bias.round == math.floor(bias.round)
    and bias.round >= 1 and bias.round <= Economy.ROUNDS and (bias.round == run.round or bias.round == run.round - 1)
    and type(lastRound) == "table" and lastRound.round == bias.round and type(bias.talents) == "table"
    and ns.Mastery.Validate(run.class, bias.round, bias.talents) then
    run.shopBias = { round = bias.round, talents = ns.Mastery.Normalize(run.class, bias.talents) }
  end
  run.recent = Util.DeepCopy(data.recent or {})
  run.phase = phase
  run.shop = { offers = {}, sales = {}, rerolls = data.shop and data.shop.rerolls or 0 }
  local savedShop = data.shop or {}
  local reservedIndex = savedShop.reservedIndex
  if savedShop.reserved and reservedIndex == nil then
    for index, id in ipairs(savedShop.offers or {}) do
      if id == savedShop.reserved then reservedIndex = index break end
    end
  end
  if savedShop.reserved and type(reservedIndex) == "number" and reservedIndex >= 1 and reservedIndex <= #(savedShop.offers or {}) and reservedIndex == math.floor(reservedIndex) and savedShop.offers[reservedIndex] == savedShop.reserved then
    run.shop.reserved = savedShop.reserved
    run.shop.reservedIndex = reservedIndex
    run.shop.reservedSale = savedShop.reservedSale == true and true or nil
  end
  run.stash = {}
  for _, id in ipairs(data.stash or {}) do
    if not ns.Items[id] then return nil end
    run.stash[#run.stash + 1] = id
  end
  run.consumedMaterials = type(data.consumedMaterials) == "table" and Util.DeepCopy(data.consumedMaterials) or {}
  run.craftedLegendaries = type(data.craftedLegendaries) == "table" and Util.DeepCopy(data.craftedLegendaries) or {}
  run:SyncCraftingState()
  if #run.stash > Run.STASH_SIZE then return nil end
  local owned = Economy.StockCounts(run.grid, run.stash, run.consumedMaterials)
  for id, count in pairs(owned) do
    local def = ns.Items[id]
    if not def or count > Economy.StockLimit(def) then return nil end
  end
  run.learnedRanks = {}
  for key, rank in pairs(type(data.learnedRanks) == "table" and data.learnedRanks or {}) do
    local base = ns.ItemsByKey[key]
    if base and base.rankable and ns.ItemAllowedForClass(base, run.class) and type(rank) == "number" and rank == math.floor(rank) then
      local def = ns.Ranks.Definition(base, rank)
      if def and def.minRound <= run.round then run.learnedRanks[key] = rank end
    end
  end
  for _, p in ipairs(run.grid.items) do
    local def = ns.Items[p.id]
    if def.minRound > run.round then return nil end
    if def.rank then run.learnedRanks[def.baseKey] = math.max(run.learnedRanks[def.baseKey] or 1, def.rank) end
  end
  for _, id in ipairs(run.stash) do
    local def = ns.Items[id]
    if def.minRound > run.round or not ns.ItemAllowedForClass(def, run.class) then return nil end
    if def.rank then run.learnedRanks[def.baseKey] = math.max(run.learnedRanks[def.baseKey] or 1, def.rank) end
  end
  run.trainingResale = {}
  if data.trainingResale ~= nil and type(data.trainingResale) ~= "table" then return nil end
  if data.trainingResale then
    for key, value in pairs(data.trainingResale) do
      local base, rank = ns.ItemsByKey[key], run.learnedRanks[key]
      if not base or not rank or rank < 2 or type(value) ~= "number" or value ~= math.floor(value) or value < 0
        or value > math.max(ns.Ranks.Investment(base, rank) - base.cost, ns.Ranks.LEGACY_TRAINING[rank]) then return nil end
      run.trainingResale[key] = value
    end
  else
    for key, rank in pairs(run.learnedRanks) do
      local base = ns.ItemsByKey[key]
      if rank >= 2 and (owned[base.id] or 0) > 0 then run.trainingResale[key] = ns.Ranks.LEGACY_TRAINING[rank] end
    end
  end
  run.started = data.started
  run.shop.offers = Util.DeepCopy(savedShop.offers or {})
  run.shop.sales = Util.DeepCopy(savedShop.sales or {})
  run.formCompanions = { seen = {}, pending = {} }
  if data.formCompanions ~= nil then
    run.formCompanions = restoreFormCompanions(data.formCompanions, run.class)
    if not run.formCompanions then return nil end
  end
  ns.Migrations.PurgeRetiredOffers(run)
  run:PruneShopOffers()
  run:SyncFormCompanions(data.formCompanions == nil or migration.inferCompanions)
  local valid = true
  local categories, bagOffers = { ability = 0, gear = 0 }, 0
  if #run.shop.offers > Economy.ShopSize(run.round) then valid = false end
  local offeredCounts = Util.DeepCopy(owned)
  for _, id in ipairs(run.shop.offers) do
    local def = ns.Items[id]
    if not def or purchaseBlocked(run, def) or Economy.AvailableStock(def, offeredCounts) <= 0 then
      valid = false
    else
      local key = Economy.StockKey(def)
      offeredCounts[key] = (offeredCounts[key] or 0) + 1
      local category = Economy.ShopCategory(def)
      categories[category] = categories[category] + 1
      if categories[category] > Economy.CategorySize(run.round) then valid = false end
      if def.kind == "bag" then
        bagOffers = bagOffers + 1
        if bagOffers > 1 or #run.grid.bags >= ns.MAX_BAGS then valid = false end
      end
    end
  end
  if not valid then run:NewShop(true) end
  if run.phase == "result" then
    run:NextRound()
  elseif run.phase == "shop" and Economy.RunFinished(run) then
    run.phase = "over"
  end
  return run, migration.info
end

function Run:SetPieces()
  local owned = {}
  for _, p in ipairs(self.grid.items) do
    local def = ns.Items[p.id]
    if def.set then
      owned[def.set] = owned[def.set] or {}
      owned[def.set][def.key] = true
    end
  end
  return owned
end

function ns.FindOpponent(run, myId)
  local now = Util.Now()
  local exclude = Util.Set(run.recent)
  local rec = ns.Pool.Pick(run.round, {
    now = now, exclude = exclude, ownName = run.who, ownAlias = ns.Comm and ns.Comm.SelfName(run.who) or nil, wins = run.wins,
    rng = Util.NewRNG(Util.Hash32(myId .. tostring(now))),
    isOnline = ns.Comm and ns.Comm.IsOnline or nil,
  })
  if rec then
    local ok, err, grid = ns.Snapshot.Validate(rec.b, now)
    if ok then
      local classDef = ns.ClassesById[rec.b.c]
      return { id = rec.id, build = rec.b, grid = grid, classKey = classDef.key }
    end
    ns.Pool.Remove(run.round, rec.id)
  end
  local seed = Util.Hash32(myId .. ":bot:" .. tostring(now))
  local build, grid = ns.Bots.Opponent(run.round, seed)
  local classDef = ns.ClassesById[build.c]
  return { id = "bot:" .. ns.Snapshot.Hash(build), build = build, grid = grid, classKey = classDef.key }
end
