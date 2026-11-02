local ADDON, ns = ...
local Util = ns.Util

local Crafting = {}
ns.Crafting = Crafting

local function connected(grid, placements)
  if #placements <= 1 then return true end
  local idx = {}
  for i, p in ipairs(placements) do idx[p] = i end
  local seen = { [placements[1]] = true }
  local stack = { placements[1] }
  while #stack > 0 do
    local p = table.remove(stack)
    for _, n in ipairs(grid:AdjacentItems(p)) do
      if idx[n] and not seen[n] then
        seen[n] = true
        stack[#stack + 1] = n
      end
    end
  end
  return Util.Count(seen) == #placements
end

local function findGroup(grid, recipe)
  local needed = {}
  for _, key in ipairs(recipe.inputs) do
    local def = ns.ItemsByKey[key]
    if not def then return nil end
    needed[#needed + 1] = def.id
  end
  local used = {}
  local chosen = {}
  for _, id in ipairs(needed) do
    local found
    for _, p in ipairs(grid.items) do
      if p.id == id and not used[p] then found = p break end
    end
    if not found then return nil end
    used[found] = true
    chosen[#chosen + 1] = found
  end
  if not connected(grid, chosen) then
    local options = {}
    for _, id in ipairs(needed) do
      local list = {}
      for _, p in ipairs(grid.items) do if p.id == id then list[#list + 1] = p end end
      options[#options + 1] = list
    end
    local function search(depth, picked, usedSet)
      if depth > #options then
        if connected(grid, picked) then return Util.ShallowCopy(picked) end
        return nil
      end
      for _, p in ipairs(options[depth]) do
        if not usedSet[p] then
          usedSet[p] = true
          picked[#picked + 1] = p
          local r = search(depth + 1, picked, usedSet)
          if r then return r end
          picked[#picked] = nil
          usedSet[p] = nil
        end
      end
      return nil
    end
    chosen = search(1, {}, {})
    if not chosen then return nil end
  end
  return chosen
end

function Crafting.Check(grid, craftedLedger)
  local crafted = {}
  local progress = true
  local guard = 0
  while progress and guard < 10 do
    guard = guard + 1
    progress = false
    for _, recipe in ipairs(ns.Recipes) do
      local output = ns.ItemsByKey[recipe.output]
      local tracked = craftedLedger and output.craftable and output.quality == ns.QUALITY.LEGENDARY
      local alreadyCrafted = tracked and craftedLedger[recipe.output]
      local alreadyOwned = output.unique and grid:CountItem(output.id) > 0
      local group = not alreadyCrafted and not alreadyOwned and findGroup(grid, recipe)
      if group then
        local primary = group[1]
        local snapshot = {}
        for _, p in ipairs(group) do snapshot[#snapshot + 1] = { id = p.id, uid = p.uid, x = p.x, y = p.y, rot = p.rot } end
        for _, p in ipairs(group) do grid:RemoveItem(p) end
        local placed
        for _, rot in ipairs(output.distinctRots) do
          if grid:CanPlaceItem(output, primary.x, primary.y, rot) then
            placed = grid:PlaceItem(output, primary.x, primary.y, rot)
            break
          end
        end
        if not placed then
          local x, y, rot = grid:FindFit(output)
          if x then placed = grid:PlaceItem(output, x, y, rot) end
        end
        if placed then
          crafted[#crafted + 1] = output
          if tracked then craftedLedger[recipe.output] = true end
          progress = true
        else
          for _, s in ipairs(snapshot) do grid:PlaceItem(ns.Items[s.id], s.x, s.y, s.rot).uid = s.uid end
        end
      end
    end
  end
  return crafted
end

function Crafting.RecipesFor(def)
  local out = {}
  for _, recipe in ipairs(ns.Recipes) do
    for _, key in ipairs(recipe.inputs) do
      if key == def.key then out[#out + 1] = recipe break end
    end
  end
  return out
end
