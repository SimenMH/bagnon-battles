local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L
local Util = ns.Util

local Shop = {}
ns.UI.Shop = Shop

local SHOP_W = 236
local CARD_W = SHOP_W
local CARD_H = 84
local CARD_GAP = 6
local ICON_SIZE = 56
local GLYPH_CELL = 5
local HERO_H = 60
local FOOTER_H = 70

local cursor = nil
local holdRun
local heldCrafted
local announceCrafted
local homeMove
local screen
local onItemEnter

local function run() return ns.run end

local function trainingOpen()
  return screen and screen.trainingOverlay and screen.trainingOverlay:IsShown()
end

local function beginHold()
  local r = run()
  if holdRun then holdRun:EndHold(true) end
  if r:IsHolding() then r:EndHold(true) end
  r:BeginHold()
  holdRun, heldCrafted = r, nil
end

local function endHold(rollback)
  local r = holdRun
  if not r then return end
  r:EndHold(rollback)
  holdRun = nil
  local crafted = heldCrafted
  heldCrafted = nil
  if rollback and run() == r and Shop.RefreshAll then Shop.RefreshAll() end
  if not rollback and announceCrafted then announceCrafted(crafted) end
end

local function hideHomeTooltip()
  if screen and screen.homeTooltip then screen.homeTooltip = nil GameTooltip:Hide() end
end

local function hideBagTooltip()
  if screen and screen.bagTooltip then screen.bagTooltip = nil ns.UI.Tooltip.Hide() end
end

local function cancelHomeMove()
  homeMove = nil
  hideHomeTooltip()
  hideBagTooltip()
  if screen then
    screen.grid:ClearPreview()
    screen.grid:SetGhost(cursor ~= nil and cursor.def.kind == "bag")
  end
end

local function cursorFrame()
  if Shop.cursorFrame then return Shop.cursorFrame end
  local f = CreateFrame("Frame", "BagnonBattlesCursor", UIParent)
  f:SetFrameStrata("TOOLTIP")
  f:SetSize(T.CELL, T.CELL)
  f:EnableMouse(false)
  f.fill = T.NineSlice(f, T.TEX.panelSmall, 6, "BACKGROUND", 0)
  f.border = T.NineSlice(f, T.TEX.borderSmall, 6, "BORDER", 0)
  f.border:HideCenter()
  f.outline = T.NineSlice(f, T.TEX.outlineSmall, 6, "BORDER", 1)
  f.outline:HideCenter()
  f.outline:SetColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.9)
  f.icon = f:CreateTexture(nil, "ARTWORK")
  f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  f.icon:SetPoint("CENTER")
  f:SetAlpha(0.92)
  f:Hide()
  f:SetScript("OnUpdate", function(self)
    if not cursor then return end
    local cell = screen and screen.grid.cell or T.CELL
    local gridScale = screen and screen.grid.frame:GetEffectiveScale() or UIParent:GetEffectiveScale()
    local scale = gridScale / UIParent:GetEffectiveScale()
    if self:GetScale() ~= scale or self.cursorCell ~= cell then Shop.UpdateCursorFrame() end
    local x, y = GetCursorPosition()
    x, y = x / self:GetEffectiveScale(), y / self:GetEffectiveScale()
    self:ClearAllPoints()
    self:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x - (cursor.grabX + 0.5) * cell, y + (cursor.grabY + 0.5) * cell)
  end)
  Shop.cursorFrame = f
  return f
end

function Shop.UpdateCursorFrame()
  local f = cursorFrame()
  if not cursor then
    f:Hide()
    return
  end
  local def = cursor.def
  local cell = screen and screen.grid.cell or T.CELL
  local gridScale = screen and screen.grid.frame:GetEffectiveScale() or UIParent:GetEffectiveScale()
  f:SetScale(gridScale / UIParent:GetEffectiveScale())
  f.cursorCell = cell
  local rot = ns.RotationCells(def, cursor.rot)
  local w, h = rot.w * cell - T.CELL_GAP, rot.h * cell - T.CELL_GAP
  f:SetSize(w, h)
  local r, g, b = T.QualityColor(def.quality)
  ns.UI.GridView.LayoutShape(f, rot, cell, T.CELL_GAP, r, g, b, def.quality)
  f.fill:SetColor(r * 0.16 + 0.08, g * 0.16 + 0.085, b * 0.16 + 0.1, 1)
  f.border:SetColor(r, g, b, 1)
  T.SetItemIcon(f.icon, def.icon)
  ns.UI.GridView.PlaceIcon(f, rot, cell, 8)
  ns.UI.GridView.SetRankBadge(f, def)
  f:Show()
end

local function setCursor(c)
  cancelHomeMove()
  if screen and screen.trainingOverlay then
    screen.trainingTarget = nil
    screen.trainingOverlay:Hide()
  end
  if screen and screen.talentOverlay then screen.talentOverlay:Hide() end
  cursor = c
  Shop.UpdateCursorFrame()
  if screen then
    screen.grid:SetGhost(c ~= nil and c.def.kind == "bag")
    screen.sell:SetArmed(c ~= nil and c.origin ~= "shop")
  end
end

local function clearCursor()
  endHold()
  cursor = nil
  Shop.UpdateCursorFrame()
  if screen then
    screen.grid:ClearPreview()
    screen.grid:SetGhost(homeMove ~= nil)
    screen.sell:SetArmed(false)
  end
end

local function disabledUids()
  local r = run()
  if not r then return {} end
  local ok, side = pcall(ns.Sim.PreviewStats, { name = r.who, classKey = r.class, round = r.round, grid = r.grid, talents = r.talents })
  local out = {}
  if ok and side then
    for _, it in ipairs(side.items) do
      if it.def.use and not it.enabled then out[it.uid] = it.reason or true end
    end
    Shop.preview = side
  end
  return out
end

local STAT_CHIPS = {
  { "armor", L["Armor"] }, { "ap", L["Attack"] }, { "sp", L["Spell"] }, { "healing", L["Healing"] },
  { "crit", L["Crit"], "%" }, { "critDamage", L["Crit Damage"], "%" }, { "haste", L["Haste"], "%" }, { "dodge", L["Dodge"], "%" }, { "block", L["Block"] }, { "blockChance", L["Block"], "%" },
  { "thorns", L["Thorns"] }, { "lifesteal", L["Leech"], "%" }, { "dr", L["Reduction"], "%" },
}

local function chipRows()
  local side = Shop.preview
  local rows = {}
  if not side then return rows end
  rows[#rows + 1] = { L["Health"], tostring(side.hpMax), nil, T.C.good, statKey = "hp" }
  for _, row in ipairs(STAT_CHIPS) do
    local key = row[1]
    local v = ns.Sim.OwnerStat(side, key)
    if key == "crit" then v = ns.Sim.CritChance(v) end
    if key == "dodge" then v = ns.Sim.DodgeChance(v) end
    if v ~= 0 or key == "crit" or key == "dodge" then
      rows[#rows + 1] = { row[2], string.format("%s%s", Util.Round(v), row[3] or ""), statKey = key }
    end
  end
  for _, res in ipairs(Util.SortedKeys(side.res)) do
    if res == "mana" or res == "focus" then
      local pool = side.res[res]
      local cr, cg, cb = T.ResourceColor(res)
      rows[#rows + 1] = { ns.RESOURCE_NAMES[res] or res, string.format("%d  +%s/s", pool.max, ns.Describe.Rate(pool.regen)), { cr * 0.75 + 0.25, cg * 0.75 + 0.25, cb * 0.75 + 0.25 }, T.C.text, statKey = "resource:" .. res }
    end
  end
  return rows
end

local function createStatChip()
  local chip = T.Chip(screen.chipArea, 24)
  chip:EnableMouse(true)
  chip:SetScript("OnEnter", function(self)
    if trainingOpen() then return end
    if self.statKey then ns.UI.Tooltip.ShowStat(self, self.statKey, Shop.preview) end
  end)
  chip:SetScript("OnLeave", function() if not trainingOpen() then ns.UI.Tooltip.Hide() end end)
  screen.chips[#screen.chips + 1] = chip
  return chip
end

local function layoutChips()
  local rows = chipRows()
  local widest = 0
  for i, row in ipairs(rows) do
    local chip = screen.chips[i] or createStatChip()
    chip:Show()
    chip:Set(row[1], row[2], row[3], row[4])
    chip.statKey = row.statKey
    widest = math.max(widest, chip:GetWidth())
  end
  local left, top = screen.chipLeft, 4
  local mainWidth = screen.main:GetWidth()
  if mainWidth - left - 2 < math.max(widest, 260) then left, top = 2, 64 end
  local maxW = math.max(1, mainWidth - left - 2)
  screen.chipArea:ClearAllPoints()
  screen.chipArea:SetPoint("TOPLEFT", screen.footer, "TOPLEFT", left, -top)
  screen.chipArea:SetWidth(maxW)
  local x, y, rowH = 0, 0, 26
  for i, chip in ipairs(screen.chips) do
    if rows[i] then
      local w = chip:GetWidth()
      if x > 0 and x + w > maxW then x = 0 y = y + rowH end
      chip:ClearAllPoints()
      chip:SetPoint("TOPLEFT", screen.chipArea, "TOPLEFT", x, -y)
      x = x + w + 5
    else
      chip.statKey = nil
      chip:Hide()
    end
  end
  local height = #rows > 0 and y + 24 or 0
  screen.chipArea:SetHeight(height)
  local footerHeight = math.max(FOOTER_H, top + height + 6)
  if screen.footer:GetHeight() ~= footerHeight then screen.footer:SetHeight(footerHeight) end
end

local function refreshRecord()
  local r = run()
  screen.wins:SetFilled(math.min(r.wins, ns.Economy.MAX_WINS))
  screen.lives:SetFilled(ns.Economy.LivesRemaining(r))
end

function Shop.RefreshSide()
  local r = run()
  if not screen or not r then return end
  layoutChips()
  screen.goldText:SetText(tostring(r.gold))
  screen.roundText:SetText(string.format(r.survival and L["Survival %d / %d"] or L["Round %d of %d"], r.round, ns.Economy.ROUNDS))
  screen.portrait:SetClass(r.class)
  screen.classText:SetText(ns.Classes[r.class].name)
  screen.classText:SetTextColor(T.ClassColor(r.class))
  local rerollCost = ns.Economy.RerollCost(r.shop.rerolls or 0)
  screen.rerollButton:SetText(string.format("%s  %s%d", L["Reroll"], T.GOLD_ICON, rerollCost))
  screen.rerollButton:SetEnabled(r.phase == "shop" and r.gold >= rerollCost)
  screen.fightButton:SetEnabled(r.phase == "shop")
  if screen.talentsButton then
    screen.talentsButton:RefreshTalents(r)
  end
  refreshRecord()
end

function Shop.RefreshStash()
  local r = run()
  if not screen or not r then return end
  for i, slot in ipairs(screen.stashSlots) do
    local id = r.stash[i]
    if id then
      local def = ns.Items[id]
      slot.def = def
      T.SetItemIcon(slot.icon, def.icon)
      slot.icon:Show()
      slot:SetQuality(def.quality)
      ns.UI.GridView.SetRankBadge(slot, def)
    else
      slot.def = nil
      slot.icon:Hide()
      slot:SetQuality(nil)
      ns.UI.GridView.SetRankBadge(slot, nil)
    end
  end
end

function Shop.RefreshGrid()
  if not screen or not run() then return end
  hideHomeTooltip()
  hideBagTooltip()
  screen.grid:SetGrid(run().grid, disabledUids())
  Shop.RefreshSide()
  Shop.RefreshStash()
end

function Shop.LayoutOffer(slot, def)
  T.SetItemIcon(slot.iconSlot.icon, def.icon)
  slot.iconSlot.icon:Show()
  slot.iconSlot:SetQuality(def.quality)
  ns.UI.GridView.SetRankBadge(slot.iconSlot, def)
  local shape = ns.RotationCells(def, 0)
  local compact = slot:GetHeight() < CARD_H
  slot.glyph.cellSize = math.max(1, math.min(compact and 4 or GLYPH_CELL, math.floor((compact and 18 or 24) / shape.h)))
  slot.glyph:SetItem(def)
end

local function layoutOffers(round)
  local rows = ns.Economy.CategorySize(round)
  local height = rows == 4 and 64 or CARD_H
  local iconSize = rows == 4 and 44 or ICON_SIZE
  local groupHeight = rows * height + (rows - 1) * CARD_GAP
  local gearTop = 26 + groupHeight + 30
  for index, slot in ipairs(screen.offers) do
    local category = index <= rows and "ability" or index <= rows * 2 and "gear" or nil
    slot.category = category
    if category then
      local row = (index - 1) % rows
      slot:ClearAllPoints()
      slot:SetPoint("TOPLEFT", screen.shopColumn, "TOPLEFT", 8, -((category == "ability" and 26 or gearTop) + row * (height + CARD_GAP)))
      slot:SetHeight(height)
      slot.iconSlot:SetSize(iconSize, iconSize)
      slot.iconSlot.frameTex:SetSize(iconSize * 64 / 37, iconSize * 64 / 37)
      slot.iconSlot.frameTex:ClearAllPoints()
      slot.iconSlot.frameTex:SetPoint("CENTER", slot.iconSlot, "CENTER", 0, -iconSize / 37)
      local textLeft = 20 + iconSize
      slot.name:ClearAllPoints()
      slot.name:SetPoint("TOPLEFT", textLeft, -7)
      slot.name:SetPoint("RIGHT", slot, "RIGHT", -38, 0)
      slot.kind:SetHeight(rows == 4 and 14 or 28)
      slot.kind:SetWordWrap(rows ~= 4)
      slot.glyph:ClearAllPoints()
      slot.glyph:SetPoint("BOTTOMLEFT", slot, "BOTTOMLEFT", textLeft, 7)
    end
  end
  screen.gearLabel:ClearAllPoints()
  screen.gearLabel:SetPoint("TOPLEFT", screen.shopColumn, "TOPLEFT", 10, -(gearTop - 18))
  screen.abilityEmpty:ClearAllPoints()
  screen.abilityEmpty:SetPoint("TOP", screen.shopColumn, "TOP", 0, -(26 + groupHeight / 2))
  screen.gearEmpty:ClearAllPoints()
  screen.gearEmpty:SetPoint("TOP", screen.shopColumn, "TOP", 0, -(gearTop + groupHeight / 2))
  screen.rerollButton:ClearAllPoints()
  screen.rerollButton:SetPoint("TOPLEFT", screen.shopColumn, "TOPLEFT", 8, -(gearTop + groupHeight + 10))
end

function Shop.RefreshOffers()
  local r = run()
  if not screen or not r then return end
  layoutOffers(r.round)
  local capacity = ns.Economy.CategorySize(r.round)
  local display = {}
  local nextSlot = { ability = 1, gear = capacity + 1 }
  for index, id in ipairs(r.shop.offers) do
    local def = ns.Items[id]
    if def then
      local category = ns.Economy.ShopCategory(def)
      local slot = nextSlot[category]
      if slot and slot <= (category == "ability" and capacity or capacity * 2) then
        display[slot] = { def = def, index = index }
        nextSlot[category] = slot + 1
      end
    end
  end
  for i, slot in ipairs(screen.offers) do
    local entry = display[i]
    local def = entry and entry.def
    if def then
      local index = entry.index
      slot:Show()
      slot.def = def
      slot.index = index
      Shop.LayoutOffer(slot, def)
      local price = r:OfferPrice(index)
      local sale = r:OfferIsSale(index)
      slot.price:SetText(tostring(price))
      slot.saleTag:SetShown(sale)
      local qr, qg, qb = T.QualityColor(def.quality)
      slot.name:SetText(def.name)
      slot.name:SetTextColor(qr, qg, qb)
      slot.kind:SetText(ns.Describe.Short(def))
      local affordable = r.gold >= price
      slot.iconSlot:SetAlpha(affordable and 1 or 0.4)
      slot.name:SetAlpha(affordable and 1 or 0.5)
      if affordable then
        if sale then slot.price:SetTextColor(T.RGB(T.C.good)) else slot.price:SetTextColor(T.RGB(T.C.gold)) end
      else
        slot.price:SetTextColor(T.RGB(T.C.bad))
      end
      local reserved = r:IsReserved(index)
      slot.lock.icon:SetAlpha(1)
      if reserved then
        slot.lock.icon:SetVertexColor(T.RGB(T.C.gold))
        slot.lock.bg:SetVertexColor(T.C.gold[1] * 0.4, T.C.gold[2] * 0.32, T.C.gold[3] * 0.14, 1)
      else
        slot.lock.icon:SetVertexColor(0.9, 0.9, 0.9)
        slot.lock.bg:SetVertexColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.85)
      end
      if reserved then slot:SetBorderColor(T.RGB(T.C.gold)) else slot:SetBorderColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.95) end
    else
      slot:Hide()
      slot.def = nil
      slot.index = nil
    end
  end
  screen.abilityEmpty:SetShown(nextSlot.ability == 1)
  screen.gearEmpty:SetShown(nextSlot.gear == capacity + 1)
end

function Shop.RefreshAll()
  Shop.RefreshOffers()
  Shop.RefreshGrid()
  if Shop.RefreshTraining then Shop.RefreshTraining() end
  if screen and screen.talentOverlay then screen.talentOverlay:Refresh() end
  local r = run()
  if screen and r and r.phase == "shop" and screen:IsVisible()
    and (screen.rankReminderRun ~= r or screen.rankReminderRound ~= r.round) then
    local unlockedRank
    for rank, training in pairs(ns.Ranks.TRAINING) do
      if r.round == training.minRound then
        unlockedRank = rank
        break
      end
    end
    if not unlockedRank or ns.UI.Dialogs.ShowRankReminder(screen, r, unlockedRank, Shop.RefreshAll) then
      screen.rankReminderRun, screen.rankReminderRound = r, r.round
    end
  end
  if screen and screen.talentsButton and r then
    local allowed = r.phase == "shop" and screen:IsVisible() and not cursor and not homeMove
      and not (screen.trainingOverlay and screen.trainingOverlay:IsShown())
      and not (screen.searchOverlay and screen.searchOverlay:IsShown())
      and not (ns.UI.Dialogs.rankReminder and ns.UI.Dialogs.rankReminder:IsShown())
    screen.talentsButton:MaybePrompt(r, allowed)
  end
end

announceCrafted = function(crafted)
  if not crafted or #crafted == 0 then return end
  for _, def in ipairs(crafted) do
    ns.Print(string.format(L["%s has been forged!"], T.QualityHex(def.quality) .. def.name .. "|r"))
    T.PlaySound(T.SOUND_LOOT)
    if RaidNotice_AddMessage and RaidWarningFrame then
      RaidNotice_AddMessage(RaidWarningFrame, string.format(L["%s has been forged!"], def.name), ChatTypeInfo["RAID_WARNING"])
    end
    for _, p in ipairs(run().grid.items) do
      if p.id == def.id then screen.grid:PopItem(p.uid) end
    end
  end
end

local function recordCrafted(crafted)
  if not holdRun then announceCrafted(crafted) return end
  heldCrafted = heldCrafted or {}
  for _, def in ipairs(crafted or {}) do heldCrafted[#heldCrafted + 1] = def end
end

local function pickUpFromShop(index)
  local r = run()
  local def = r:OfferDef(index)
  if not def then return end
  if not r:CanAfford(index) then
    T.Error(L["Not enough gold."])
    T.Shake(screen.goldBox, 3)
    return
  end
  beginHold()
  setCursor({ def = def, origin = "shop", index = index, rot = 0, grabX = 0, grabY = 0 })
  T.PlaySound(T.SOUND_PICKUP)
end

local function grabOffset(def, p)
  local hx, hy = screen.grid:CellAtCursor()
  if not hx then return 0, 0 end
  local r = ns.RotationCells(def, p.rot)
  return Util.Clamp(hx - p.x, 0, r.w - 1), Util.Clamp(hy - p.y, 0, r.h - 1)
end

local function currentPlacement(p)
  local r = run()
  return r and r.phase == "shop" and type(p) == "table" and p.uid and r.grid:FindItem(p.uid) or nil
end

local function pickUpFromGrid(p)
  local r = run()
  p = currentPlacement(p)
  if not p then Shop.RefreshGrid() return end
  beginHold()
  local def, cargo, err = r:LiftPlacement(p)
  if not def then
    endHold(true)
    if err then T.Error(err) end
    return
  end
  local gx, gy = grabOffset(def, p)
  setCursor({ def = def, origin = "grid", uid = p.uid, placement = { id = p.id, x = p.x, y = p.y, rot = p.rot }, rot = p.rot, grabX = gx, grabY = gy, cargo = cargo })
  T.PlaySound(T.SOUND_PICKUP)
  Shop.RefreshGrid()
end

local function canPlaceCursor(def, x, y, rot)
  local r = run()
  if def.kind == "bag" then return r.grid:CanPlaceBag(def, x, y, rot) end
  return r.grid:CanPlaceItem(def, x, y, rot)
end

local function pickUpFromStash(index)
  local r = run()
  if not r.stash[index] then return end
  beginHold()
  local def = r:StashTake(index)
  if not def then endHold(true) return end
  setCursor({ def = def, origin = "stash", rot = 0, grabX = 0, grabY = 0 })
  T.PlaySound(T.SOUND_PICKUP)
  Shop.RefreshStash()
  Shop.RefreshSide()
end

local function cancelCursor()
  if homeMove then cancelHomeMove() ns.UI.Tooltip.Hide() return end
  if not cursor then return end
  local r = run()
  local restored = true
  if holdRun and holdRun ~= r then
    endHold(true)
    r = nil
  end
  if r then
    if cursor.origin == "grid" then
      local pl = cursor.placement
      restored = r:PlaceHeld(ns.Items[pl.id], pl.x, pl.y, pl.rot, cursor.cargo, cursor.uid) ~= nil
    elseif cursor.origin == "stash" then
      restored = r:StashAdd(cursor.def)
    elseif cursor.origin == "swap" then
      if not r:StashAdd(cursor.def) then
        local x, y, rot = r.grid:FindFit(cursor.def)
        restored = x ~= nil and r:PlaceHeld(cursor.def, x, y, rot, nil, cursor.uid) ~= nil
      end
    end
  end
  if not restored then endHold(true) end
  clearCursor()
  T.PlaySound(T.SOUND_DROP)
  ns.Addon:SaveRun()
  Shop.RefreshAll()
end

function Shop.BeginHomeMove(x, y)
  local r = run()
  if not r or r.phase ~= "shop" or cursor or not r.grid:IsHomeCell(x, y) or r.grid:ItemAt(x, y) then return false end
  homeMove = { grid = r.grid, grabX = x - r.grid.home.x, grabY = y - r.grid.home.y }
  hideHomeTooltip()
  hideBagTooltip()
  ns.UI.Tooltip.Hide()
  screen.grid:SetGhost(true)
  screen.grid:ShowHomePreview(r.grid.home.x, r.grid.home.y, true)
  T.PlaySound(T.SOUND_PICKUP)
  return true
end

function Shop.CommitHomeMove(x, y)
  local r = run()
  if not homeMove or not r or r.phase ~= "shop" or r.grid ~= homeMove.grid or not x or not y then return false end
  local ok, err = r:MoveHome(x - homeMove.grabX, y - homeMove.grabY)
  if not ok then T.Error(err) return false end
  cancelHomeMove()
  T.PlaySound(T.SOUND_DROP)
  ns.Addon:SaveRun()
  Shop.RefreshAll()
  return true
end

local function targetCell(x, y)
  return x - cursor.grabX, y - cursor.grabY
end

local function swapCandidate(def, x, y, rot)
  local r = run()
  local cells = ns.Grid.Footprint(def, x, y, rot)
  local found
  for _, c in ipairs(cells) do
    if not r.grid:InBounds(c[1], c[2]) or not r.grid:HasCell(c[1], c[2]) then return nil end
    local occ = r.grid:ItemAt(c[1], c[2])
    if occ then
      if found and occ ~= found then return nil end
      found = occ
    end
  end
  if not found then return nil end
  if r.grid:CanPlaceItem(def, x, y, rot, found) then return found end
  return nil
end

local function commitPlacement(def, x, y, rot)
  local r = run()
  if cursor.origin == "shop" then
    local p, err, crafted = r:BuyAndPlace(cursor.index, x, y, rot)
    if not p then return false, err end
    T.PlaySound(T.SOUND_BUY)
    Shop.RefreshAll()
    screen.grid:PopItem(p.uid)
    recordCrafted(crafted)
    return true
  end
  local p, err = r:PlaceHeld(def, x, y, rot, cursor.cargo, cursor.uid)
  if not p then return false, err end
  T.PlaySound(T.SOUND_DROP)
  Shop.RefreshAll()
  screen.grid:PopItem(p.uid)
  recordCrafted(r:CheckCrafting())
  return true
end

local function tryPlace(x, y)
  local r = run()
  if not cursor or not r then return end
  if holdRun and holdRun ~= r then cancelCursor() return end
  local tx, ty = targetCell(x, y)
  local def = cursor.def
  local swapWith = nil
  if not canPlaceCursor(def, tx, ty, cursor.rot) then
    swapWith = def.kind ~= "bag" and swapCandidate(def, tx, ty, cursor.rot) or nil
    if not swapWith then
      local _, err = canPlaceCursor(def, tx, ty, cursor.rot)
      T.Error(err or L["Can't place that there."])
      return
    end
    if cursor.origin == "shop" and not r:CanAfford(cursor.index) then
      T.Error(L["Not enough gold."])
      return
    end
    r:LiftPlacement(swapWith)
  end
  local ok, err = commitPlacement(def, tx, ty, cursor.rot)
  if not ok then
    if swapWith and not r:PlaceHeld(ns.Items[swapWith.id], swapWith.x, swapWith.y, swapWith.rot, nil, swapWith.uid) then
      endHold(true)
      clearCursor()
    end
    Shop.RefreshAll()
    T.Error(err or L["Can't place that there."])
    return
  end
  if swapWith then
    local swappedDef = ns.Items[swapWith.id]
    local gx, gy = grabOffset(swappedDef, swapWith)
    setCursor({ def = swappedDef, origin = "swap", uid = swapWith.uid, rot = swapWith.rot, grabX = gx, grabY = gy })
  else
    clearCursor()
  end
  ns.Addon:SaveRun()
  Shop.RefreshSide()
end

local function rotateCursor()
  if not cursor then return end
  if cursor.cargo and #cursor.cargo > 0 then return end
  local previousRotation = cursor.rot
  cursor.rot = ns.NextRotation(cursor.def, cursor.rot)
  if cursor.rot ~= previousRotation then T.PlaySound(T.SOUND_CLICK) end
  local rot = ns.RotationCells(cursor.def, cursor.rot)
  cursor.grabX = Util.Clamp(cursor.grabX, 0, rot.w - 1)
  cursor.grabY = Util.Clamp(cursor.grabY, 0, rot.h - 1)
  Shop.UpdateCursorFrame()
  local x, y = screen.grid:CellAtCursor()
  if x then Shop.Hover(x, y) end
end

local function sellCursor()
  local r = run()
  if not cursor or not r then return end
  if holdRun and holdRun ~= r then cancelCursor() return end
  if cursor.cargo and #cursor.cargo > 0 then T.Error(L["Empty the bag first."]) return end
  if cursor.origin == "shop" then
    cancelCursor()
    return
  end
  local price, err = r:SellHeld(cursor.def)
  if not price then T.Error(err) return end
  clearCursor()
  T.PlaySound(T.SOUND_SELL)
  ns.Addon:SaveRun()
  Shop.RefreshAll()
  T.Pop(screen.goldBox, 1.15, 0.2)
end

local function stashCursor()
  local r = run()
  if not cursor or not r then return end
  if holdRun and holdRun ~= r then cancelCursor() return end
  if cursor.cargo and #cursor.cargo > 0 then T.Error(L["Empty the bag first."]) return end
  if cursor.origin == "shop" then
    local def, err = r:BuyToStash(cursor.index)
    if not def then
      T.Error(err)
      return
    end
    T.PlaySound(T.SOUND_BUY)
  else
    local ok, err = r:StashAdd(cursor.def)
    if not ok then
      T.Error(err)
      return
    end
    T.PlaySound(T.SOUND_DROP)
  end
  clearCursor()
  ns.Addon:SaveRun()
  Shop.RefreshAll()
  T.Pop(screen.stashSlots[math.max(1, math.min(#r.stash, #screen.stashSlots))], 1.2, 0.2)
end

local function sellPlacement(p)
  local r = run()
  p = currentPlacement(p)
  if not p then Shop.RefreshGrid() return end
  local ok, err = r:Sell(p)
  if not ok then
    T.Error(err)
    return
  end
  T.PlaySound(T.SOUND_SELL)
  ns.Addon:SaveRun()
  Shop.RefreshAll()
  T.Pop(screen.goldBox, 1.15, 0.2)
end

local function inspectBagAt(x, y)
  local r = run()
  if trainingOpen() or not r or r.phase ~= "shop" or not x or not y or cursor or homeMove then return false end
  local bag = r.grid:CellBag(x, y)
  if not bag or r.grid:ItemAt(x, y) and not (IsAltKeyDown and IsAltKeyDown()) then return false end
  local frame = screen.grid:ItemFrame(bag.uid)
  if not frame then return false end
  hideHomeTooltip()
  screen.grid:ClearGlow()
  ns.UI.Tooltip.Show(frame, ns.Items[bag.id], { price = "sell", run = r, context = Shop.preview, target = bag })
  screen.bagTooltip = { grid = r.grid, uid = bag.uid }
  return true
end

function Shop.Hover(x, y)
  if not screen or trainingOpen() then return end
  local r = run()
  if homeMove and x and y then
    hideBagTooltip()
    local r = run()
    if not r or r.phase ~= "shop" or r.grid ~= homeMove.grid then cancelHomeMove() return end
    local tx, ty = x - homeMove.grabX, y - homeMove.grabY
    screen.grid:ShowHomePreview(tx, ty, r.grid:CanMoveHome(tx, ty))
    return
  end
  if inspectBagAt(x, y) then screen.grid:ClearPreview() return end
  local inspectedBag = screen.bagTooltip ~= nil
  hideBagTooltip()
  if inspectedBag and not cursor and not homeMove and r and x and y then
    local item = r.grid:ItemAt(x, y)
    local frame = item and screen.grid:ItemFrame(item.uid)
    if frame then onItemEnter(item, frame) return end
  end
  if not cursor and not homeMove and r and x and y and r.grid:IsHomeCell(x, y) and not r.grid:ItemAt(x, y) then
    GameTooltip:SetOwner(screen.grid.catcher, "ANCHOR_CURSOR")
    GameTooltip:SetText(L["Backpack"], 1, 1, 1)
    GameTooltip:AddLine(L["Click to pick up."], 0.8, 0.8, 0.8)
    GameTooltip:Show()
    screen.homeTooltip = true
    return
  end
  hideHomeTooltip()
  if not cursor or not x then
    screen.grid:ClearPreview()
    return
  end
  local tx, ty = targetCell(x, y)
  local valid = canPlaceCursor(cursor.def, tx, ty, cursor.rot)
  if not valid and cursor.def.kind ~= "bag" and swapCandidate(cursor.def, tx, ty, cursor.rot) then valid = "swap" end
  screen.grid:ShowPreview(cursor.def, tx, ty, cursor.rot, valid)
end

local function onCellClick(x, y, button)
  if button == "RightButton" then
    if homeMove then cancelHomeMove() elseif cursor then rotateCursor() end
    return
  end
  if homeMove then Shop.CommitHomeMove(x, y) return end
  if cursor then
    tryPlace(x, y)
    return
  end
  local r = run()
  if not r then return end
  if r.grid:IsHomeCell(x, y) and not r.grid:ItemAt(x, y) then Shop.BeginHomeMove(x, y) return end
  local bag = r.grid:CellBag(x, y)
  if bag then pickUpFromGrid(bag) end
end

local function onItemClick(p, button)
  local r = run()
  if not r then return end
  if homeMove then
    if button == "RightButton" then cancelHomeMove()
    else
      local x, y = screen.grid:CellAtCursor()
      if x then Shop.CommitHomeMove(x, y) end
    end
    return
  end
  if cursor then
    local x, y = screen.grid:CellAtCursor()
    if button == "RightButton" then rotateCursor() elseif x then tryPlace(x, y) end
    return
  end
  p = currentPlacement(p)
  if not p then Shop.RefreshGrid() return end
  if button == "RightButton" then
    if IsShiftKeyDown() then sellPlacement(p) else Shop.OpenTraining(p) end
    return
  end
  pickUpFromGrid(p)
end

local function glowSynergies(p)
  local r = run()
  if not r then return end
  local def = ns.Items[p.id]
  local neighbors = r.grid:EffectNeighbors(p)
  local affected = {}
  for _, rule in ipairs(def.adjacency) do
    for _, n in ipairs(neighbors) do
      if Util.MatchDef(ns.Items[n.id], rule.match) then affected[#affected + 1] = n end
    end
  end
  for _, n in ipairs(neighbors) do
    local nd = ns.Items[n.id]
    for _, rule in ipairs(nd.adjacency) do
      if Util.MatchDef(def, rule.match) then affected[#affected + 1] = n end
    end
    for _, trig in ipairs(nd.triggers) do
      if trig.on and trig.on:find("^adjacent") and Util.MatchDef(def, trig.match) then affected[#affected + 1] = n end
    end
    for _, trig in ipairs(def.triggers) do
      for _, e in ipairs(trig.effects) do
        if e.type == "cdr" and e.target == "neighbors" and Util.MatchDef(nd, e.match) then affected[#affected + 1] = n end
      end
    end
  end
  for _, trig in ipairs(def.triggers) do
    if trig.on and trig.on:find("^adjacent") then
      for _, n in ipairs(neighbors) do
        if Util.MatchDef(ns.Items[n.id], trig.match) then affected[#affected + 1] = n end
      end
    end
  end
  if #affected > 0 then screen.grid:GlowItems(affected, 1, 0.9, 0.3) end
end

onItemEnter = function(p, frame)
  if trainingOpen() then return end
  hideHomeTooltip()
  if cursor or homeMove then hideBagTooltip() return end
  local x, y = screen.grid:CellAtCursor()
  if inspectBagAt(x, y) then return end
  hideBagTooltip()
  p = currentPlacement(p)
  if not p then return end
  local def = ns.Items[p.id]
  local extra
  local reason
  if Shop.preview then
    for _, it in ipairs(Shop.preview.items) do
      if it.uid == p.uid and not it.enabled and it.reason then reason = it.reason end
    end
  end
  if reason and def.kind ~= "weapon" and not (def.use and def.use.requires) then
    extra = { { text = L["Inactive: needs "] .. (ns.Describe.REQUIRE_LABELS[reason] or reason), r = 1, g = 0.4, b = 0.4 } }
  end
  ns.UI.Tooltip.Show(frame, def, { price = "sell", run = run(), context = Shop.preview, target = p, extra = extra })
  glowSynergies(p)
end

local function onItemLeave()
  if trainingOpen() then return end
  if screen then screen.bagTooltip = nil end
  ns.UI.Tooltip.Hide()
  if screen then screen.grid:ClearGlow() end
end

local function startBattle()
  local r = run()
  local result, opponent = ns.Addon:LockIn()
  if not result then return end
  ns.UI.Battle.Show(result, opponent, r)
end

local SEARCH_TIME = 3

local function cancelSearch(silent)
  if screen and screen.searchOverlay and screen.searchOverlay:IsShown() then
    screen.searchOverlay:Hide()
    if silent ~= true then T.PlaySound(T.SOUND_CLICK) end
  end
end

local function startSearch()
  local overlay = screen.searchOverlay
  overlay.t = 0
  overlay.text:SetText(L["Searching for an opponent"])
  overlay:Show()
  T.PlaySound(T.SOUND_SEARCH)
end

local function updateSearch(overlay, elapsed)
  if not overlay:IsShown() then return end
  overlay.t = overlay.t + elapsed
  overlay.text:SetText(L["Searching for an opponent"] .. string.rep(".", math.floor(overlay.t * 2) % 4))
  if overlay.t >= SEARCH_TIME then
    overlay:Hide()
    startBattle()
  end
end

local function lockIn()
  local r = run()
  if not r or r.phase ~= "shop" then return end
  screen.trainingOverlay:Hide()
  screen.trainingTarget = nil
  if screen.talentOverlay then screen.talentOverlay:Hide() end
  if cursor or homeMove then cancelCursor() end
  startSearch()
end

local function chooseRank(rank)
  local r = run()
  if not r or not screen.trainingTarget then return end
  local info = r:TrainingInfo(screen.trainingTarget)
  if cursor or not info or info.def.id ~= screen.trainingId then
    screen.trainingTarget = nil
    screen.trainingOverlay:Hide()
    return
  end
  local def, err
  local training = rank == info.learned + 1
  if training then
    def, err = r:Train(screen.trainingTarget)
  else
    def, err = r:SetRank(screen.trainingTarget, rank)
  end
  if not def then T.Error(err) return end
  screen.trainingId = def.id
  T.PlaySound(training and T.SOUND_TRAIN or T.SOUND_CLICK)
  ns.Addon:SaveRun()
  Shop.RefreshAll()
end

function Shop.OpenTraining(target)
  local r = run()
  if not screen or not r or r.phase ~= "shop" or cursor or homeMove then return end
  local info = r:TrainingInfo(target)
  if not info then return end
  if screen.talentOverlay then screen.talentOverlay:Hide() end
  hideHomeTooltip()
  hideBagTooltip()
  screen.grid.hovering = false
  screen.grid.lastHoverX, screen.grid.lastHoverY, screen.grid.lastHoverAlt = nil, nil, nil
  screen.grid:ClearPreview()
  screen.grid:ClearGlow()
  screen.trainingTarget = target
  screen.trainingId = info.def.id
  Shop.RefreshTraining()
  screen.trainingOverlay:Show()
  ns.UI.Tooltip.Hide()
  T.PlaySound(T.SOUND_CLICK)
end

function Shop.RefreshTraining()
  if not screen then return end
  local r = run()
  local overlay = screen.trainingOverlay
  if not r or not screen.trainingTarget then overlay:Hide() return end
  local info = r:TrainingInfo(screen.trainingTarget)
  if not info or info.def.id ~= screen.trainingId or r.phase ~= "shop" then
    screen.trainingTarget = nil
    overlay:Hide()
    return
  end
  overlay.title:SetText(info.base.name)
  for i, card in ipairs(overlay.cards) do
    local key = i == 1 and info.base.key or info.base.ranks[i]
    local def = key and ns.ItemsByKey[key]
    if def then
      card:Show()
      card.def = def
      card.compare = i > 1 and ns.Ranks.Definition(info.base, i - 1) or nil
      T.SetItemIcon(card.iconSlot.icon, def.icon)
      card.iconSlot.icon:Show()
      card.iconSlot:SetQuality(def.quality)
      local qr, qg, qb = T.QualityColor(def.quality)
      card.name:SetText(string.format(L["Rank %d"], i))
      card.name:SetTextColor(qr, qg, qb)
      local use = def.use
      if use then
        local timing = use.once and "Once per battle" or ns.Describe.Rate(use.cd) .. "s"
        card.kind:SetText(string.format("%s %s / %s", ns.Describe.Rate(use.cost or 0), ns.RESOURCE_NAMES[use.resource] or "", timing))
      else
        card.kind:SetText(L["Triggered attack"])
      end
      if i > info.learned then
        card.price:SetText(string.format("%s  %s%d", L["Train"], T.GOLD_ICON, ns.Ranks.TrainingCost(info.base, i)))
        card.price:Show()
      else
        card.price:SetText("")
        card.price:Hide()
      end
      if i == info.rank then
        card.note:SetText(L["Selected"])
        card:SetEnabled(false)
      elseif i <= info.learned then
        card.note:SetText(L["Use this rank"])
        card:SetEnabled(true)
      elseif i == info.nextRank then
        card.note:SetText(info.canTrain and "" or info.reason)
        card:SetEnabled(info.canTrain)
      else
        card.note:SetText(string.format(L["Learn Rank %d first"], i - 1))
        card:SetEnabled(false)
      end
      card:SetAlpha((i <= info.learned or info.canTrain and i == info.nextRank) and 1 or 0.55)
    else
      card:Hide()
      card.def = nil
      card.compare = nil
    end
  end
end

local function createCard(parent)
  local slot = T.Panel(parent, "card", { frameType = "Button" })
  slot:SetSize(CARD_W, CARD_H)
  slot.iconSlot = T.CreateSlot(slot, ICON_SIZE)
  slot.iconSlot:SetPoint("LEFT", slot, "LEFT", 10, 0)
  slot.iconSlot:EnableMouse(false)
  slot.glyph = T.CreateItemGlyph(slot, GLYPH_CELL)
  slot.glyph:SetPoint("BOTTOMLEFT", slot, "BOTTOMLEFT", 10 + ICON_SIZE + 10, 7)
  local textLeft = 10 + ICON_SIZE + 10
  slot.name = T.Text(slot, 12, T.C.text)
  slot.name:SetPoint("TOPLEFT", textLeft, -7)
  slot.name:SetPoint("RIGHT", slot, "RIGHT", -38, 0)
  slot.name:SetJustifyH("LEFT")
  slot.name:SetJustifyV("TOP")
  slot.name:SetHeight(14)
  slot.name:SetWordWrap(false)
  slot.kind = T.Text(slot, 10, T.C.muted)
  slot.kind:SetPoint("TOPLEFT", slot.name, "BOTTOMLEFT", 0, -2)
  slot.kind:SetPoint("RIGHT", slot, "RIGHT", -38, 0)
  slot.kind:SetJustifyH("LEFT")
  slot.kind:SetJustifyV("TOP")
  slot.kind:SetHeight(28)
  slot.kind:SetWordWrap(true)
  slot.priceIcon = slot:CreateTexture(nil, "ARTWORK")
  slot.priceIcon:SetTexture(T.TEX.gold)
  slot.priceIcon:SetSize(16, 16)
  slot.priceIcon:SetPoint("BOTTOMRIGHT", -10, 7)
  slot.price = T.Number(slot, 15, T.C.gold)
  slot.price:SetPoint("RIGHT", slot.priceIcon, "LEFT", -3, 0)
  slot.saleTag = T.Panel(slot, "pill", { fill = { 0.55, 0.18, 0.18, 1 }, border = { 0.75, 0.3, 0.3, 1 } })
  slot.saleTag:SetSize(40, 18)
  slot.saleTag:SetPoint("TOPLEFT", 6, -6)
  slot.saleTag.text = T.Number(slot.saleTag, 11, T.C.text, "-50%")
  slot.saleTag.text:SetPoint("CENTER", 0, 0)
  slot.saleTag:Hide()
  local function toggleLock()
    local r = run()
    if r then
      r:ToggleReserve(slot.index)
      ns.Addon:SaveRun()
      Shop.RefreshOffers()
      T.PlaySound(T.SOUND_CLICK)
    end
  end
  local lock = CreateFrame("Button", nil, slot)
  lock:SetSize(26, 26)
  lock:SetPoint("TOPRIGHT", slot, "TOPRIGHT", -6, -6)
  lock:SetFrameLevel(slot:GetFrameLevel() + 5)
  lock.bg = lock:CreateTexture(nil, "BACKGROUND")
  lock.bg:SetTexture(T.TEX.circle)
  lock.bg:SetAllPoints()
  lock.bg:SetVertexColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.75)
  lock.icon = lock:CreateTexture(nil, "OVERLAY")
  lock.icon:SetTexture(T.TEX.lock)
  lock.icon:SetPoint("TOPLEFT", 5, -5)
  lock.icon:SetPoint("BOTTOMRIGHT", -5, 5)
  lock:SetScript("OnClick", toggleLock)
  lock:SetScript("OnEnter", function(self)
    if trainingOpen() then return end
    self.icon:SetAlpha(1)
    self.icon:SetVertexColor(1, 1, 1)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L["Keep this offer for next round"], 1, 1, 1)
    GameTooltip:AddLine(L["Right-click the card does the same."], 0.6, 0.6, 0.6)
    GameTooltip:Show()
  end)
  lock:SetScript("OnLeave", function() if not trainingOpen() then GameTooltip:Hide() end Shop.RefreshOffers() end)
  slot.lock = lock
  slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  slot:SetScript("OnClick", function(self, button)
    if button == "RightButton" then
      if not cursor then toggleLock() end
      return
    end
    if cursor then
      if cursor.origin == "shop" and cursor.index == self.index then cancelCursor() end
      return
    end
    pickUpFromShop(self.index)
  end)
  slot:SetScript("OnEnter", function(self)
    if trainingOpen() then return end
    self:SetFillColor(T.RGB(T.C.bg4))
    if self.def then ns.UI.Tooltip.ShowEquipmentComparison(self, self.def, { price = "buy", run = run(), context = Shop.preview, gold = run() and run().gold, index = self.index }) end
  end)
  slot:SetScript("OnLeave", function(self)
    self:SetFillColor(T.RGB(T.C.bg3))
    if not trainingOpen() then ns.UI.Tooltip.Hide() end
  end)
  return slot
end

function Shop.Create(parent)
  screen = CreateFrame("Frame", nil, parent)
  screen:SetAllPoints()

  local shopCol = T.Inset(screen)
  screen.shopColumn = shopCol
  shopCol:SetPoint("TOPLEFT", 0, 0)
  shopCol:SetPoint("BOTTOMLEFT", 0, 0)
  shopCol:SetWidth(SHOP_W + 16)
  local shopLabel = T.Label(shopCol, L["Abilities"])
  shopLabel:SetPoint("TOPLEFT", 10, -8)
  screen.abilityLabel = shopLabel
  screen.gearLabel = T.Label(shopCol, L["Gear"])
  screen.gearLabel:SetPoint("TOPLEFT", shopCol, "TOPLEFT", 10, -302)
  screen.abilityEmpty = T.Text(shopCol, 11, T.C.dim, L["No abilities available."])
  screen.abilityEmpty:SetPoint("TOP", shopCol, "TOP", 0, -136)
  screen.gearEmpty = T.Text(shopCol, 11, T.C.dim, L["No gear available."])
  screen.gearEmpty:SetPoint("TOP", shopCol, "TOP", 0, -430)

  screen.offers = {}
  for i = 1, ns.Economy.SHOP_SIZE do
    local slot = createCard(shopCol)
    screen.offers[i] = slot
  end

  local reroll = T.CreateButton(shopCol, L["Reroll"], SHOP_W, 28, "default", 13)
  reroll:SetScript("OnClick", function()
    local r = run()
    if not r then return end
    if cursor then cancelCursor() end
    local ok, err = r:Reroll()
    if not ok then T.Error(err) return end
    T.PlaySound(T.SOUND_BUY)
    ns.Addon:SaveRun()
    Shop.RefreshAll()
    for _, slot in ipairs(screen.offers) do if slot:IsShown() then T.FadeIn(slot, 0.15) end end
  end)
  screen.rerollButton = reroll

  local sell = T.CreateSlot(shopCol, 44)
  sell:SetPoint("TOP", reroll, "BOTTOM", 0, -8)
  sell.icon:SetTexture(T.TEX.sell)
  sell.icon:Show()
  sell.label = T.Text(shopCol, 12, T.C.muted, L["Sell"])
  sell.label:SetPoint("TOP", sell, "BOTTOM", 0, -4)
  sell.label:SetSize(100, 14)
  sell.label:SetWordWrap(false)
  function sell:SetArmed(armed)
    if armed then
      self:SetQuality(5)
      self.glow:SetVertexColor(T.C.gold[1], T.C.gold[2], T.C.gold[3], 1)
      self.glow:SetAlpha(0.6)
      T.Pulse(self.glow, 0.3, 0.8, 0.7)
    else
      T.StopPulse(self.glow)
      self:SetQuality(nil)
      self.glow:SetAlpha(0)
    end
  end
  sell:SetScript("OnClick", function() sellCursor() end)
  sell:SetScript("OnEnter", function(self)
    if trainingOpen() then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    local r = run()
    if cursor and cursor.origin ~= "shop" and r then
      GameTooltip:SetText(string.format(L["Sell %s for %s%d"], cursor.def.name, T.GOLD_ICON, r:SellPrice(cursor.def)), 1, 1, 1, 1, true)
    else
      GameTooltip:SetText(L["Drop an item here to sell it"], 1, 1, 1)
      GameTooltip:AddLine(L["Shift-right-click an item in your bag to sell it instantly."], 0.6, 0.6, 0.6, true)
    end
    GameTooltip:Show()
  end)
  sell:SetScript("OnLeave", function(self) if not cursor then self.glow:SetAlpha(0) end if not trainingOpen() then GameTooltip:Hide() end end)
  screen.sell = sell

  local abandon = T.CreateButton(shopCol, L["Abandon Run"], SHOP_W, 24, "default", 11)
  abandon:SetPoint("BOTTOMLEFT", shopCol, "BOTTOMLEFT", 8, 8)
  abandon:SetScript("OnClick", function()
    T.PlaySound(T.SOUND_CLICK)
    ns.UI.Dialogs.Confirm(L["Abandon this run? Your bag and record will be lost."], function()
      if cursor then clearCursor() end
      ns.Addon:AbandonRun()
    end)
  end)

  local main = CreateFrame("Frame", nil, screen)
  main:SetPoint("TOPLEFT", shopCol, "TOPRIGHT", 8, 0)
  main:SetPoint("BOTTOMRIGHT", screen, "BOTTOMRIGHT", 0, 0)
  screen.main = main

  local hero = CreateFrame("Frame", nil, main)
  hero:SetPoint("TOPLEFT", 0, 0)
  hero:SetPoint("TOPRIGHT", 0, 0)
  hero:SetHeight(HERO_H)
  local portrait = T.CreatePortrait(hero, 48)
  portrait:SetPoint("LEFT", hero, "LEFT", 2, 0)
  screen.portrait = portrait
  local classText = T.Title(hero, 17, T.C.text)
  classText:SetPoint("TOPLEFT", portrait, "TOPRIGHT", 10, -5)
  classText:SetWidth(124)
  classText:SetJustifyH("LEFT")
  classText:SetWordWrap(false)
  screen.classText = classText
  local roundText = T.Text(hero, 12, T.C.muted)
  roundText:SetPoint("TOPLEFT", classText, "BOTTOMLEFT", 0, -4)
  roundText:SetWidth(124)
  roundText:SetJustifyH("LEFT")
  roundText:SetWordWrap(false)
  screen.roundText = roundText

  local wins = T.Pips(hero, ns.Economy.MAX_WINS, T.TEX.trophy, 15, 3, T.C.gold)
  wins:SetPoint("LEFT", hero, "LEFT", 196, 10)
  screen.wins = wins
  local lives = T.Pips(hero, ns.Economy.MAX_LOSSES, T.TEX.heart, 15, 3, T.C.bad)
  lives:SetPoint("LEFT", hero, "LEFT", 196, -10)
  screen.lives = lives

  local fight = T.CreateButton(hero, L["Start Battle"], 180, 36, "primary", 15)
  fight:SetPoint("RIGHT", hero, "RIGHT", 0, 0)
  fight:SetScript("OnClick", lockIn)
  fight.glow = T.CreateGlow(fight, 8, T.C.gold[1], T.C.gold[2], T.C.gold[3], 0.2)
  T.Pulse(fight.glow, 0.05, 0.35, 1.4)
  screen.fightButton = fight
  local goldBox = T.Panel(hero, "pill")
  goldBox:SetSize(100, 34)
  goldBox:SetPoint("RIGHT", fight, "LEFT", -12, 0)
  goldBox.icon = goldBox:CreateTexture(nil, "ARTWORK")
  goldBox.icon:SetTexture(T.TEX.gold)
  goldBox.icon:SetSize(20, 20)
  goldBox.icon:SetPoint("LEFT", 12, 0)
  local goldText = T.Number(goldBox, 20, T.C.gold, "0")
  goldText:SetPoint("LEFT", goldBox.icon, "RIGHT", 8, 0)
  screen.goldText = goldText
  screen.goldBox = goldBox

  local board = T.Inset(main)
  board:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -4)
  board:SetPoint("TOPRIGHT", hero, "BOTTOMRIGHT", 0, -4)
  screen.board = board
  T.Spotlight(board)
  local clip = CreateFrame("Frame", nil, board)
  clip:SetPoint("TOPLEFT", 6, -6)
  clip:SetPoint("BOTTOMRIGHT", -6, 6)
  if clip.SetClipsChildren then clip:SetClipsChildren(true) end
  local grid = ns.UI.GridView.New(clip, T.CELL, true, 30)
  grid:SetCallbacks({ onCellClick = onCellClick, onItemClick = onItemClick, onItemEnter = onItemEnter, onItemLeave = onItemLeave, onHover = Shop.Hover,
    onHomeDragStart = Shop.BeginHomeMove,
    onHomeDragStop = function(x, y) if not Shop.CommitHomeMove(x, y) then cancelHomeMove() end end,
    onHoverEnd = function() if screen and not trainingOpen() then screen.grid:ClearPreview() hideHomeTooltip() hideBagTooltip() end end })
  screen.grid = grid
  clip:SetScript("OnSizeChanged", function()
    if grid.grid then grid:SetGrid(grid.grid, grid.lastDisabled) end
  end)
  screen.boardClip = clip
  screen.talentOverlay = ns.UI.Mastery.Create(board, Shop.RefreshAll)
  local talentsButton = ns.UI.Mastery.CreateButton(hero, screen.talentOverlay)
  local talentBadge = talentsButton.badge
  talentBadge:SetSize(16, 16)
  talentBadge:ClearAllPoints()
  talentBadge:SetPoint("TOPRIGHT", talentsButton, "TOPRIGHT", -1, -1)
  talentBadge:SetFrameLevel(talentsButton:GetFrameLevel() + 5)
  talentBadge:EnableMouse(false)
  talentBadge.background:SetTexture(T.TEX.white)
  talentBadge.background:SetTexCoord(0, 1, 0, 1)
  talentBadge.fill = talentBadge:CreateTexture(nil, "ARTWORK")
  talentBadge.fill:SetTexture(T.TEX.white)
  talentBadge.fill:SetVertexColor(0.08, 0.06, 0.04, 1)
  talentBadge.fill:SetPoint("TOPLEFT", talentBadge, "TOPLEFT", 1, -1)
  talentBadge.fill:SetPoint("BOTTOMRIGHT", talentBadge, "BOTTOMRIGHT", -1, 1)
  talentBadge.count:SetFont(T.NUMFONT, 11, "OUTLINE")
  talentBadge.count:SetTextColor(1, 0.9, 0.5, 1)
  talentBadge.count:SetSize(14, 14)
  talentBadge.count:SetJustifyH("CENTER")
  talentBadge.count:SetJustifyV("MIDDLE")
  talentsButton:SetPoint("RIGHT", goldBox, "LEFT", -8, 0)
  talentsButton:SetScript("OnClick", function()
    local r = run()
    if not r or r.phase ~= "shop" then return end
    if cursor or homeMove then cancelCursor() end
    screen.trainingTarget = nil
    screen.trainingOverlay:Hide()
    screen.talentOverlay:Open()
    T.PlaySound(T.SOUND_CLICK)
  end)
  screen.talentsButton = talentsButton

  local footer = CreateFrame("Frame", nil, main)
  footer:SetPoint("BOTTOMLEFT", main, "BOTTOMLEFT", 0, 0)
  footer:SetPoint("BOTTOMRIGHT", main, "BOTTOMRIGHT", 0, 0)
  footer:SetHeight(FOOTER_H)
  screen.footer = footer
  board:SetPoint("BOTTOM", footer, "TOP", 0, 6)

  local stashLabel = T.Label(footer, L["Stash"])
  stashLabel:SetPoint("TOPLEFT", footer, "TOPLEFT", 4, -2)
  screen.stashSlots = {}
  local stashSize = 38
  for i = 1, ns.Run.STASH_SIZE do
    local slot = T.CreateSlot(footer, stashSize)
    slot:SetPoint("TOPLEFT", footer, "TOPLEFT", 2 + (i - 1) * (stashSize + 4), -18)
    slot.icon:Hide()
    slot.index = i
    slot:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    slot:SetScript("OnClick", function(self, button)
      if cursor then stashCursor() return end
      if self.def then
        if button == "RightButton" and (self.def.rankable or self.def.rank) then
          Shop.OpenTraining(self.index)
        else
          pickUpFromStash(self.index)
        end
      end
    end)
    slot:SetScript("OnEnter", function(self)
      if trainingOpen() then return end
      self.glow:SetAlpha(0.4)
      if self.def then
        ns.UI.Tooltip.Show(self, self.def, { price = "sell", run = run(), context = Shop.preview, target = self.index })
      else
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText(L["Stash"], 1, 1, 1)
        GameTooltip:AddLine(L["Items kept here sit out the fight and stay with you between rounds."], 0.6, 0.6, 0.6, true)
        GameTooltip:Show()
      end
    end)
    slot:SetScript("OnLeave", function(self) self.glow:SetAlpha(0) if not trainingOpen() then ns.UI.Tooltip.Hide() end end)
    screen.stashSlots[i] = slot
  end

  local chipArea = CreateFrame("Frame", nil, footer)
  screen.chipArea = chipArea
  screen.chipLeft = 2 + ns.Run.STASH_SIZE * (stashSize + 4) + 14
  screen.chips = {}
  main:SetScript("OnSizeChanged", function() layoutChips() end)

  local overlay = CreateFrame("Frame", nil, board)
  overlay:SetAllPoints(board)
  overlay:SetFrameLevel(board:GetFrameLevel() + 20)
  overlay:EnableMouse(true)
  overlay.dim = overlay:CreateTexture(nil, "BACKGROUND")
  overlay.dim:SetTexture(T.TEX.white)
  overlay.dim:SetVertexColor(0, 0, 0, 0.7)
  overlay.dim:SetAllPoints()
  overlay.title = T.Title(overlay, 18, T.C.gold)
  overlay.title:SetPoint("CENTER", overlay, "CENTER", 0, 100)
  overlay.cards = {}
  for i = 1, 3 do
    local card = T.Panel(overlay, "card", { frameType = "Button" })
    card:SetSize(190, 175)
    card:SetPoint("CENTER", overlay, "CENTER", (i - 2) * 206, -10)
    card.iconSlot = T.CreateSlot(card, 56)
    card.iconSlot:SetPoint("TOP", card, "TOP", 0, -12)
    card.iconSlot:EnableMouse(false)
    card.name = T.Text(card, 13, T.C.text)
    card.name:SetPoint("TOP", card.iconSlot, "BOTTOM", 0, -8)
    card.name:SetSize(170, 16)
    card.name:SetJustifyH("CENTER")
    card.name:SetWordWrap(false)
    card.kind = T.Text(card, 11, T.C.dim)
    card.kind:SetPoint("TOP", card.name, "BOTTOM", 0, -3)
    card.kind:SetSize(170, 14)
    card.kind:SetJustifyH("CENTER")
    card.kind:SetWordWrap(false)
    card.rank = i
    card.price = T.Text(card, 13, T.C.gold)
    card.price:SetPoint("BOTTOM", card, "BOTTOM", 0, 32)
    card.price:SetSize(170, 18)
    card.price:SetJustifyH("CENTER")
    card.price:SetWordWrap(false)
    card.note = T.Text(card, 11, T.C.gold)
    card.note:SetPoint("BOTTOM", card, "BOTTOM", 0, 10)
    card.note:SetSize(170, 14)
    card.note:SetJustifyH("CENTER")
    card.note:SetWordWrap(false)
    if card.SetMotionScriptsWhileDisabled then card:SetMotionScriptsWhileDisabled(true) end
    card:SetScript("OnClick", function(self) chooseRank(self.rank) end)
    card:SetScript("OnEnter", function(self)
      self:SetFillColor(T.RGB(T.C.bg4))
      self:SetBorderColor(T.RGB(T.C.gold))
      if self.def then
        ns.UI.Tooltip.ShowRankComparison(self, self.compare, self.def, { run = run(), context = Shop.preview, above = overlay.title })
      end
    end)
    card:SetScript("OnLeave", function(self)
      self:SetFillColor(T.RGB(T.C.bg3))
      self:SetBorderColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.95)
      ns.UI.Tooltip.Hide()
    end)
    overlay.cards[i] = card
  end
  overlay.close = T.CreateButton(overlay, L["Done"], 120, 26, "default", 12)
  overlay.close:SetPoint("TOP", overlay.cards[2], "BOTTOM", 0, -14)
  overlay.close:SetScript("OnClick", function()
    screen.trainingTarget = nil
    overlay:Hide()
    ns.UI.Tooltip.Hide()
    T.PlaySound(T.SOUND_CLICK)
  end)
  overlay:SetScript("OnHide", function() ns.UI.Tooltip.Hide() end)
  overlay:Hide()
  screen.trainingOverlay = overlay

  local search = CreateFrame("Frame", nil, screen)
  search:SetAllPoints()
  search:SetFrameLevel(screen:GetFrameLevel() + 60)
  search:EnableMouse(true)
  search.dim = search:CreateTexture(nil, "BACKGROUND")
  search.dim:SetAllPoints()
  search.dim:SetTexture(T.TEX.white)
  search.dim:SetVertexColor(0, 0, 0, 0.45)
  local searchCard = T.Panel(search, "card")
  searchCard:SetSize(360, 120)
  searchCard:SetPoint("CENTER", search, "CENTER", 0, 0)
  T.CreateShadow(searchCard, 30, 0.8)
  search.text = T.Title(searchCard, 17, T.C.text, L["Searching for an opponent"])
  search.text:SetPoint("TOP", searchCard, "TOP", 0, -24)
  local cancelButton = T.CreateButton(searchCard, L["Cancel"], 120, 30, "default", 13)
  cancelButton:SetPoint("BOTTOM", searchCard, "BOTTOM", 0, 16)
  cancelButton:SetScript("OnClick", cancelSearch)
  search.cancelButton = cancelButton
  search:SetScript("OnUpdate", updateSearch)
  search:Hide()
  screen.searchOverlay = search

  screen:SetScript("OnHide", function()
    ns.UI.Dialogs.HideRankReminder()
    hideBagTooltip()
    if cursor or homeMove then cancelCursor() end
    if not cursor then endHold(true) end
    cancelSearch(true)
    screen.trainingTarget = nil
    screen.trainingOverlay:Hide()
    screen.talentOverlay:Hide()
    ns.UI.Tooltip.Hide()
  end)
  screen:SetScript("OnShow", function()
    Shop.RefreshAll()
  end)
  return screen
end

function Shop.OnKey(key)
  if key == "ESCAPE" and ns.UI.Dialogs.HideRankReminder(true) then return true end
  if key == "ESCAPE" and ns.UI.Tooltip.equipmentComparison then ns.UI.Tooltip.Hide() end
  if key == "ESCAPE" and homeMove then cancelHomeMove() return true end
  if key == "ESCAPE" and screen and screen.talentOverlay:IsShown() then
    screen.talentOverlay:Hide()
    ns.UI.Tooltip.Hide()
    T.PlaySound(T.SOUND_CLICK)
    return true
  end
  if key == "ESCAPE" and screen and screen.trainingOverlay:IsShown() then
    screen.trainingTarget = nil
    screen.trainingOverlay:Hide()
    ns.UI.Tooltip.Hide()
    T.PlaySound(T.SOUND_CLICK)
    return true
  end
  if not cursor then return false end
  if key == "R" then
    rotateCursor()
    return true
  elseif key == "ESCAPE" then
    cancelCursor()
    return true
  end
  return false
end
