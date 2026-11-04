local ADDON, ns = ...
local Util = ns.Util

local Grid = {}
Grid.__index = Grid
ns.Grid = Grid

local function key(x, y) return y * 100 + x end
Grid.Key = key

local function validHome(home)
  if type(home) ~= "table" then return false end
  for key in pairs(home) do if key ~= 1 and key ~= 2 then return false end end
  return #home == 2
    and type(home[1]) == "number" and home[1] == math.floor(home[1]) and home[1] >= 0 and home[1] <= ns.GRID_W - ns.START_W
    and type(home[2]) == "number" and home[2] == math.floor(home[2]) and home[2] >= 0 and home[2] <= ns.GRID_H - ns.START_H
end
Grid.ValidHome = validHome

function Grid.New(home)
  if home == nil then home = { ns.START_X, ns.START_Y } end
  if not validHome(home) then return nil, "Invalid backpack position." end
  local g = setmetatable({}, Grid)
  g.W, g.H = ns.GRID_W, ns.GRID_H
  g.cells   = {}
  g.bags    = {}
  g.items   = {}
  g.occ     = {}
  g.nextUid = 1
  g.home = { x = home[1], y = home[2] }
  for y = g.home.y, g.home.y + ns.START_H - 1 do
    for x = g.home.x, g.home.x + ns.START_W - 1 do
      g.cells[key(x, y)] = "start"
    end
  end
  return g
end

function Grid:InBounds(x, y)
  return x >= 0 and y >= 0 and x < self.W and y < self.H
end

function Grid:HasCell(x, y)
  return self.cells[key(x, y)] ~= nil
end

function Grid:CellBag(x, y)
  local c = self.cells[key(x, y)]
  if c == "start" then return nil end
  return c
end

function Grid:IsHomeCell(x, y)
  return self.cells[key(x, y)] == "start"
end

function Grid:HomeCargo()
  local cargo = {}
  for _, p in ipairs(self.items) do
    for _, cell in ipairs(p.cells) do
      if self.cells[cell] == "start" then cargo[#cargo + 1] = p break end
    end
  end
  return cargo
end

function Grid:HomeMoveCells()
  local cells = {}
  for cell, owner in pairs(self.cells) do if owner == "start" then cells[cell] = true end end
  for _, p in ipairs(self:HomeCargo()) do
    for _, cell in ipairs(p.cells) do cells[cell] = true end
  end
  return cells
end

local function homeMovePlan(grid, x, y, stashSpace)
  if not validHome({ x, y }) then return nil, "Backpack must stay inside the board." end
  local dx, dy = x - grid.home.x, y - grid.home.y
  local cells, occ, moving, cargoCells = {}, {}, {}, {}
  for cell, owner in pairs(grid.cells) do if owner ~= "start" then cells[cell] = owner end end
  for cy = y, y + ns.START_H - 1 do
    for cx = x, x + ns.START_W - 1 do
      local cell = key(cx, cy)
      if cells[cell] then return nil, "Overlaps another bag." end
      cells[cell] = "start"
    end
  end
  local originalCargo, cargo, stashed = grid:HomeCargo(), {}, {}
  for _, p in ipairs(originalCargo) do moving[p] = true end
  for cell, owner in pairs(grid.occ) do if not moving[owner] then occ[cell] = owner end end
  for _, p in ipairs(originalCargo) do
    local translated, problem = {}
    for _, cell in ipairs(p.cells) do
      local cx, cy = cell % 100 + dx, math.floor(cell / 100) + dy
      local target = key(cx, cy)
      if not grid:InBounds(cx, cy) then problem = "Items must stay inside the board." break end
      if not cells[target] then problem = "An item would leave bag space." break end
      if occ[target] then problem = "Items would overlap." break end
      translated[#translated + 1] = target
    end
    if problem then
      if #stashed >= (stashSpace or 0) then return nil, problem end
      stashed[#stashed + 1] = p
    else
      for _, cell in ipairs(translated) do occ[cell] = p end
      cargo[#cargo + 1] = p
      cargoCells[p] = translated
    end
  end
  return { cells = cells, occ = occ, cargo = cargo, cargoCells = cargoCells, stashed = stashed, dx = dx, dy = dy }
end

function Grid:CanMoveHome(x, y, stashSpace)
  local plan, err = homeMovePlan(self, x, y, stashSpace)
  return plan ~= nil, err
end

function Grid:MoveHome(x, y, stashSpace)
  local plan, err = homeMovePlan(self, x, y, stashSpace)
  if not plan then return false, err end
  for _, p in ipairs(plan.cargo) do
    p.x, p.y = p.x + plan.dx, p.y + plan.dy
    for i, cell in ipairs(plan.cargoCells[p]) do p.cells[i] = cell end
  end
  for _, p in ipairs(plan.stashed) do self:RemoveItem(p) end
  self.home.x, self.home.y = x, y
  self.cells, self.occ = plan.cells, plan.occ
  return true, nil, plan.stashed
end

function Grid:ItemAt(x, y)
  return self.occ[key(x, y)]
end

local function footprint(def, x, y, rot)
  local r = ns.RotationCells(def, rot)
  local out = {}
  for i = 1, #r.cells do out[i] = { x + r.cells[i][1], y + r.cells[i][2] } end
  return out, r
end
Grid.Footprint = footprint

function Grid:CanPlaceBag(def, x, y, rot)
  if def.kind ~= "bag" then return false, "not a bag" end
  if #self.bags >= ns.MAX_BAGS then return false, "You can only carry " .. ns.MAX_BAGS .. " bags." end
  local cells = footprint(def, x, y, rot)
  for i = 1, #cells do
    local cx, cy = cells[i][1], cells[i][2]
    if not self:InBounds(cx, cy) then return false, "Out of bounds." end
    if self.cells[key(cx, cy)] then return false, "Overlaps your backpack." end
  end
  return true
end

function Grid:PlaceBag(def, x, y, rot)
  local ok, err = self:CanPlaceBag(def, x, y, rot)
  if not ok then return nil, err end
  local cells = footprint(def, x, y, rot)
  local p = { uid = self.nextUid, id = def.id, x = x, y = y, rot = rot % 4, cells = {} }
  self.nextUid = self.nextUid + 1
  for i = 1, #cells do
    local k = key(cells[i][1], cells[i][2])
    self.cells[k] = p
    p.cells[#p.cells + 1] = k
  end
  self.bags[#self.bags + 1] = p
  return p
end

function Grid:BagHasItems(p)
  for i = 1, #p.cells do
    if self.occ[p.cells[i]] then return true end
  end
  return false
end

function Grid:CanRemoveBag(p)
  if self:BagHasItems(p) then return false, "Empty the bag first." end
  return true
end

function Grid:RemoveBag(p)
  local ok, err = self:CanRemoveBag(p)
  if not ok then return false, err end
  for i = 1, #p.cells do self.cells[p.cells[i]] = nil end
  for i = 1, #self.bags do
    if self.bags[i] == p then table.remove(self.bags, i) break end
  end
  return true
end

function Grid.EquipmentSlot(def)
  if def.exclusiveGroup then return "exclusive:" .. def.exclusiveGroup, 1 end
  local slot
  if def.kind == "armor" then slot = def.slot
  elseif def.kind == "ring" then slot = "finger"
  elseif def.kind == "neck" then slot = "neck"
  elseif def.kind == "trinket" then slot = "trinket"
  elseif def.kind == "cloak" then slot = "back"
  elseif def.kind == "relic" then slot = "relic"
  elseif def.kind == "ammo" then slot = "ammo"
  elseif def.kind == "form" then slot = def.tagSet.aspect and "aspect" or def.tagSet.seal and "seal" or def.tagSet.armor and "armor" or "form"
  elseif def.kind == "pet" then slot = "pet" end
  if not slot then return nil end
  return slot, (slot == "finger" or slot == "trinket") and 2 or 1
end

function Grid:CanEquip(def, ignore)
  local slot, limit = Grid.EquipmentSlot(def)
  if not slot then return true end
  local count = 0
  for _, other in ipairs(self.items) do
    if other ~= ignore and Grid.EquipmentSlot(ns.Items[other.id]) == slot then
      count = count + 1
      if count >= limit then return false, ns.Describe.SlotRule(def) end
    end
  end
  return true
end

local function canPlaceItem(self, def, x, y, rot, ignore)
  if def.kind == "bag" then return self:CanPlaceBag(def, x, y, rot) end
  local canEquip, equipError = self:CanEquip(def, ignore)
  if not canEquip then return false, equipError end
  local cells = footprint(def, x, y, rot)
  for i = 1, #cells do
    local cx, cy = cells[i][1], cells[i][2]
    if not self:InBounds(cx, cy) then return false, "Out of bounds." end
    local k = key(cx, cy)
    if not self.cells[k] then return false, "No bag space there." end
    local occ = self.occ[k]
    if occ and occ ~= ignore then return false, "Something is already there." end
  end
  if def.unique then
    for i = 1, #self.items do
      local other = self.items[i]
      if other ~= ignore and other.id == def.id then return false, "You can only carry one " .. def.name .. "." end
    end
  end
  return true
end

function Grid:CanPlaceItem(def, x, y, rot, ignore)
  return canPlaceItem(self, def, x, y, rot, ignore)
end

local function placeItem(self, def, x, y, rot)
  if def.kind == "bag" then return self:PlaceBag(def, x, y, rot) end
  local ok, err = canPlaceItem(self, def, x, y, rot)
  if not ok then return nil, err end
  local cells = footprint(def, x, y, rot)
  local p = { uid = self.nextUid, id = def.id, x = x, y = y, rot = rot % 4, cells = {} }
  self.nextUid = self.nextUid + 1
  for i = 1, #cells do
    local k = key(cells[i][1], cells[i][2])
    self.occ[k] = p
    p.cells[#p.cells + 1] = k
  end
  self.items[#self.items + 1] = p
  return p
end

function Grid:PlaceItem(def, x, y, rot)
  return placeItem(self, def, x, y, rot)
end

function Grid:RemoveItem(p)
  if p.cells and self.cells[p.cells[1]] == p then return self:RemoveBag(p) end
  for i = 1, #p.cells do
    if self.occ[p.cells[i]] == p then self.occ[p.cells[i]] = nil end
  end
  for i = 1, #self.items do
    if self.items[i] == p then table.remove(self.items, i) break end
  end
  return true
end

function Grid:FindItem(uid)
  for i = 1, #self.items do if self.items[i].uid == uid then return self.items[i] end end
  for i = 1, #self.bags do if self.bags[i].uid == uid then return self.bags[i] end end
  return nil
end

function Grid:IsBagPlacement(p)
  return self.cells[p.cells[1]] == p
end

function Grid:BagItems(p)
  local seen, out = {}, {}
  for i = 1, #p.cells do
    local it = self.occ[p.cells[i]]
    if it and not seen[it] then
      seen[it] = true
      out[#out + 1] = it
    end
  end
  return out
end

function Grid:LiftBag(p)
  local items = self:BagItems(p)
  local cargo = {}
  for _, it in ipairs(items) do cargo[#cargo + 1] = { id = it.id, uid = it.uid, dx = it.x - p.x, dy = it.y - p.y, rot = it.rot } end
  for _, it in ipairs(items) do self:RemoveItem(it) end
  self:RemoveBag(p)
  return cargo
end

local function bagCargoPlan(grid, def, x, y, rot, cargo, stashSpace)
  local attempt = setmetatable(Util.ShallowCopy(grid), Grid)
  for _, field in ipairs({ "cells", "occ", "bags", "items" }) do attempt[field] = Util.ShallowCopy(grid[field]) end
  local p, err = attempt:PlaceBag(def, x, y, rot)
  if not p then return nil, err end
  local stashed = {}
  for _, c in ipairs(cargo or {}) do
    local ip = attempt:PlaceItem(ns.Items[c.id], x + c.dx, y + c.dy, c.rot)
    if not ip then
      if #stashed >= (stashSpace or 0) then return nil, "The items inside would not fit there." end
      stashed[#stashed + 1] = c
    elseif c.uid then
      ip.uid = c.uid
    end
  end
  return { grid = attempt, placement = p, stashed = stashed }
end

function Grid:CanPlaceBagWithCargo(def, x, y, rot, cargo, stashSpace)
  local plan, err = bagCargoPlan(self, def, x, y, rot, cargo, stashSpace)
  return plan ~= nil, err
end

function Grid:PlaceBagWithCargo(def, x, y, rot, cargo, stashSpace)
  local plan, err = bagCargoPlan(self, def, x, y, rot, cargo, stashSpace)
  if not plan then return nil, err end
  for _, field in ipairs({ "cells", "occ", "bags", "items", "nextUid" }) do self[field] = plan.grid[field] end
  return plan.placement, nil, plan.stashed
end

function Grid:CountItem(id)
  local n = 0
  for i = 1, #self.items do if self.items[i].id == id then n = n + 1 end end
  return n
end

local DIRS = { { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } }

function Grid:AdjacentItems(p)
  local seen, out = { [p] = true }, {}
  for i = 1, #p.cells do
    local k = p.cells[i]
    local x, y = k % 100, math.floor(k / 100)
    for d = 1, 4 do
      local other = self.occ[key(x + DIRS[d][1], y + DIRS[d][2])]
      if other and not seen[other] then
        seen[other] = true
        out[#out + 1] = other
      end
    end
  end
  table.sort(out, function(a, b) return a.uid < b.uid end)
  return out
end

function Grid:AdjacentBags(p)
  local seen, out = {}, {}
  for i = 1, #p.cells do
    local k = p.cells[i]
    local x, y = k % 100, math.floor(k / 100)
    local here = self.cells[k]
    if type(here) == "table" and not seen[here] then seen[here] = true out[#out + 1] = here end
    for d = 1, 4 do
      local other = self.cells[key(x + DIRS[d][1], y + DIRS[d][2])]
      if type(other) == "table" and not seen[other] then
        seen[other] = true
        out[#out + 1] = other
      end
    end
  end
  table.sort(out, function(a, b) return a.uid < b.uid end)
  return out
end

function Grid:ItemInsideBag(p, bag)
  for i = 1, #p.cells do
    if self.cells[p.cells[i]] ~= bag then return false end
  end
  return true
end

local EFFECT_SIDES = {
  front = { 0, -1 }, back = { 0, 1 }, left = { -1, 0 }, right = { 1, 0 },
}
local DIAGONALS = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }



local EFFECT_RULE_FIELDS = { side = true, corners = true, empty = true, inside = true, once = true,
  match = true, mods = true, selfMods = true, stats = true, activeSource = true, coating = true }

function Grid.ValidateEffectRule(rule)
  if rule == nil then return true end
  if type(rule) ~= "table" then return false, "spatial rule must be a table" end
  for field in pairs(rule) do
    if not EFFECT_RULE_FIELDS[field] then return false, "unknown spatial field " .. tostring(field) end
  end
  if rule.side ~= nil and not EFFECT_SIDES[rule.side] then return false, "unknown spatial side" end
  if rule.corners ~= nil and type(rule.corners) ~= "boolean" and not EFFECT_SIDES[rule.corners] then
    return false, "corners must be boolean or a valid side"
  end
  if rule.empty ~= nil and type(rule.empty) ~= "boolean" then return false, "empty must be boolean" end
  if rule.activeSource ~= nil and type(rule.activeSource) ~= "boolean" then return false, "activeSource must be boolean" end
  if rule.coating ~= nil and type(rule.coating) ~= "boolean" then return false, "coating must be boolean" end
  if rule.side and rule.corners and type(rule.corners) ~= "string" then
    return false, "a side can combine only with directional corners"
  end
  if rule.inside and (rule.side or rule.corners or rule.empty) then
    return false, "inside cannot be combined with spatial selectors"
  end
  if rule.empty and (rule.mods or rule.match) then
    return false, "empty-cell rules cannot target or match recipients"
  end
  return true
end

local function effectCells(grid, p, rule)
  local valid, problem = Grid.ValidateEffectRule(rule)
  assert(valid, problem)
  rule = rule or {}
  local own, selected = {}, {}
  for _, cell in ipairs(p.cells) do own[cell] = true end
  local function add(x, y)
    if grid:InBounds(x, y) then
      local cell = key(x, y)
      if not own[cell] and grid.cells[cell] ~= nil then selected[cell] = true end
    end
  end
  if rule.side then
    local direction = EFFECT_SIDES[rule.side]
    local dx, dy = direction[1], direction[2]
    local rot = p.rot or 0
    assert(type(rot) == "number" and rot == math.floor(rot) and rot >= 0 and rot <= 3, "invalid effect orientation")
    for _ = 1, rot do dx, dy = -dy, dx end




    local edge = {}
    for _, cell in ipairs(p.cells) do
      local x, y = cell % 100, math.floor(cell / 100)
      local ray, projection = dx * y - dy * x, dx * x + dy * y
      if not edge[ray] or projection > edge[ray].projection then
        edge[ray] = { x = x, y = y, projection = projection }
      end
    end
    for _, cell in pairs(edge) do add(cell.x + dx, cell.y + dy) end
  end
  if rule.corners or not rule.side then
    local sideCells = rule.side and selected
    if sideCells then selected = {} end
    local directions = rule.corners and DIAGONALS or DIRS
    if type(rule.corners) == "string" then
      directions = {}
      local side = EFFECT_SIDES[rule.corners]
      for _, diagonal in ipairs(DIAGONALS) do
        if diagonal[1] * side[1] + diagonal[2] * side[2] > 0 then
          local dx, dy = diagonal[1], diagonal[2]
          for _ = 1, p.rot or 0 do dx, dy = -dy, dx end
          directions[#directions + 1] = { dx, dy }
        end
      end
    end
    for _, cell in ipairs(p.cells) do
      local x, y = cell % 100, math.floor(cell / 100)
      for _, direction in ipairs(directions) do add(x + direction[1], y + direction[2]) end
    end
    if rule.corners then

      for _, cell in ipairs(p.cells) do
        local x, y = cell % 100, math.floor(cell / 100)
        for _, direction in ipairs(DIRS) do selected[key(x + direction[1], y + direction[2])] = nil end
      end
    end
    for cell in pairs(sideCells or {}) do selected[cell] = true end
  end
  local out = {}
  for cell in pairs(selected) do
    if not rule.empty or not grid.occ[cell] then out[#out + 1] = cell end
  end
  table.sort(out)
  return out
end




function Grid:EffectCells(p, rule)
  return effectCells(self, p, rule)
end

function Grid:EffectNeighbors(p, rule)
  local valid, problem = Grid.ValidateEffectRule(rule)
  assert(valid, problem)
  if not rule or not rule.side and not rule.corners and not rule.empty then
    return self:AdjacentItems(p)
  end
  local cells = effectCells(self, p, rule)
  if rule.empty then return {} end
  local seen, excluded, out = { [p] = true }, {}, {}
  if rule.corners == true then

    for _, other in ipairs(self:AdjacentItems(p)) do excluded[other] = true end
  end
  for _, cell in ipairs(cells) do
    local other = self.occ[cell]
    if other and not seen[other] and not excluded[other] then
      seen[other] = true
      out[#out + 1] = other
    end
  end
  table.sort(out, function(a, b) return a.uid < b.uid end)
  return out
end



function Grid:ResolveEffect(p, rule)
  local cells, neighbors = self:EffectCells(p, rule), self:EffectNeighbors(p, rule)
  return { cells = cells, neighbors = neighbors, count = rule and rule.empty and #cells or #neighbors }
end

function Grid:CellList()
  local out = {}
  for k in pairs(self.cells) do out[#out + 1] = { k % 100, math.floor(k / 100) } end
  table.sort(out, function(a, b)
    if a[2] ~= b[2] then return a[2] < b[2] end
    return a[1] < b[1]
  end)
  return out
end

function Grid:Bounds()
  local minX, minY, maxX, maxY = math.huge, math.huge, -1, -1
  for k in pairs(self.cells) do
    local x, y = k % 100, math.floor(k / 100)
    if x < minX then minX = x end
    if y < minY then minY = y end
    if x > maxX then maxX = x end
    if y > maxY then maxY = y end
  end
  return minX, minY, maxX, maxY
end

function Grid:FindFit(def, preferredRot)
  if def.kind == "bag" then return nil end
  if not self:CanEquip(def) then return nil end
  local cells = self:CellList()
  local rots = def.distinctRots
  local order = {}
  if preferredRot then order[#order + 1] = preferredRot end
  for i = 1, #rots do if rots[i] ~= preferredRot then order[#order + 1] = rots[i] end end
  for i = 1, #cells do
    for r = 1, #order do
      local rot = order[r]
      if self:CanPlaceItem(def, cells[i][1], cells[i][2], rot) then
        return cells[i][1], cells[i][2], rot
      end
    end
  end
  return nil
end

function Grid:FindBagFit(def)
  local rots = def.distinctRots
  for y = 0, self.H - 1 do
    for x = 0, self.W - 1 do
      for r = 1, #rots do
        if self:CanPlaceBag(def, x, y, rots[r]) then return x, y, rots[r] end
      end
    end
  end
  return nil
end

function Grid:Serialize()
  local g, i = {}, {}
  for n = 1, #self.bags do
    local p = self.bags[n]
    g[#g + 1] = p.id; g[#g + 1] = p.x; g[#g + 1] = p.y; g[#g + 1] = p.rot
  end
  for n = 1, #self.items do
    local p = self.items[n]
    i[#i + 1] = p.id; i[#i + 1] = p.x; i[#i + 1] = p.y; i[#i + 1] = p.rot
  end
  return g, i, { self.home.x, self.home.y }
end

local function deserialize(bags, items, classKey, home)
  local g, homeError = Grid.New(home)
  if not g then return nil, homeError end
  bags, items = bags or {}, items or {}
  if #bags % 4 ~= 0 or #items % 4 ~= 0 then return nil, "malformed placement list" end
  if #bags / 4 > ns.MAX_BAGS then return nil, "too many bags" end
  local function validCoordinates(x, y, rot)
    return type(x) == "number" and x == math.floor(x) and type(y) == "number" and y == math.floor(y)
      and type(rot) == "number" and rot == math.floor(rot) and rot >= 0 and rot <= 3 and g:InBounds(x, y)
  end
  local pending, bagOrder = {}, {}
  for n = 1, #bags, 4 do
    local id, x, y, rot = bags[n], bags[n + 1], bags[n + 2], bags[n + 3]
    local def = ns.Items[id]
    if not def or def.kind ~= "bag" then return nil, "unknown bag " .. tostring(id) end
    if classKey and not ns.ItemAllowedForClass(def, classKey) then return nil, def.key .. " not allowed for class" end
    if not validCoordinates(x, y, rot) then return nil, "bad bag coordinates" end
    pending[#pending + 1] = { def = def, x = x, y = y, rot = rot }
  end
  local remaining = #pending
  while remaining > 0 do
    local progressed = false
    for index, entry in ipairs(pending) do
      if not bagOrder[index] then
        local p, err = g:PlaceBag(entry.def, entry.x, entry.y, entry.rot)
        if p then
          p.uid = index
          bagOrder[index] = p
          remaining, progressed = remaining - 1, true
        else
          entry.error = err
        end
      end
    end
    if not progressed then
      for index, entry in ipairs(pending) do
        if not bagOrder[index] then return nil, "bag " .. entry.def.key .. ": " .. tostring(entry.error) end
      end
    end
  end
  g.bags = bagOrder
  g.nextUid = #bagOrder + 1
  for n = 1, #items, 4 do
    local id, x, y, rot = items[n], items[n + 1], items[n + 2], items[n + 3]
    local def = ns.Items[id]
    if not def or def.kind == "bag" then return nil, "unknown item " .. tostring(id) end
    if classKey and not ns.ItemAllowedForClass(def, classKey) then return nil, def.key .. " not allowed for class" end
    if not validCoordinates(x, y, rot) then return nil, "bad item coordinates" end
    local p, err = placeItem(g, def, x, y, rot)
    if not p then return nil, "item " .. def.key .. ": " .. tostring(err) end
  end
  return g
end

function Grid.Deserialize(bags, items, classKey, home)
  return deserialize(bags, items, classKey, home)
end

function Grid:TotalCost()
  local total = 0
  local trained = {}
  for n = 1, #self.bags do total = total + ns.Items[self.bags[n].id].cost end
  for _, placement in ipairs(self.items) do
    local def = ns.Items[placement.id]
    if def.rank then
      local base = ns.ItemsByKey[def.baseKey]
      total = total + base.cost
      trained[base.key] = math.max(trained[base.key] or 1, def.rank)
    else
      total = total + (def.craftedCost or def.cost)
    end
  end
  for key, rank in pairs(trained) do
    local base = ns.ItemsByKey[key]
    total = total + ns.Ranks.Investment(base, rank) - base.cost
  end
  return total
end
