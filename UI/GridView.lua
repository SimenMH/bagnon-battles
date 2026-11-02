local ADDON, ns = ...
local T = ns.UI.Theme
local Grid = ns.Grid

local GridView = {}
GridView.__index = GridView
ns.UI.GridView = GridView

local RANK_LABELS = { "I", "II", "III" }

function GridView.SetRankBadge(frame, def)
  local label = def and ns.Ranks.Definition(def, 2) and RANK_LABELS[def.rank or 1]
  if not label then
    if frame.rankText then frame.rankText:Hide() end
    return
  end
  if not frame.rankText then
    frame.rankText = T.Number(frame, 11, T.C.gold, nil, "OUTLINE")
  end
  frame.rankText:ClearAllPoints()
  frame.rankText:SetPoint("BOTTOMLEFT", frame.icon or frame, "BOTTOMLEFT", frame.icon and 3 or 4, frame.icon and 2 or 3)
  frame.rankText:SetText(label)
  frame.rankText:Show()
end

function GridView.New(parent, maxCell, interactive, minCell, compact)
  local self = setmetatable({}, GridView)
  self.maxCell = maxCell
  self.minCell = minCell or 22
  self.compact = compact
  self.cell = maxCell
  self.gap = T.CELL_GAP
  self.interactive = interactive
  self.viewport = parent
  self.frame = CreateFrame("Frame", nil, parent)
  self.frame:SetSize(ns.GRID_W * maxCell, ns.GRID_H * maxCell)
  self.frame:SetPoint("CENTER", parent, "CENTER", 0, 0)
  self.cells = {}
  self.itemFrames = {}
  self.framePool = {}
  self.bagFrames = {}
  self.bagPool = {}
  self.previewPool = {}
  self.previewUsed = 0
  self.callbacks = {}
  for y = 0, ns.GRID_H - 1 do
    for x = 0, ns.GRID_W - 1 do
      local tex = self.frame:CreateTexture(nil, "BACKGROUND", nil, 1)
      tex:SetTexture(T.TEX.emptySlot)
      tex:Hide()
      local edge = self.frame:CreateTexture(nil, "BACKGROUND", nil, 2)
      edge:SetTexture(T.TEX.slotFrame)
      edge:SetPoint("CENTER", tex, "CENTER", 0, -1)
      edge:Hide()
      tex.edge = edge
      self.cells[Grid.Key(x, y)] = tex
    end
  end
  self:LayoutCells()
  if interactive then
    local catcher = CreateFrame("Button", nil, self.frame)
    catcher:SetAllPoints()
    catcher:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    catcher:SetScript("OnClick", function(_, button) self:HandleClick(button) end)
    catcher:SetScript("OnEnter", function() self:BeginHover() end)
    catcher:SetScript("OnLeave", function() self:EndHover() end)
    catcher:SetScript("OnUpdate", function() self:OnUpdate() end)
    catcher:RegisterForDrag("LeftButton")
    catcher:SetScript("OnDragStart", function()
      local x, y = self:CellAtCursor()
      if x and self.grid:IsHomeCell(x, y) and not self.grid:ItemAt(x, y) and self.callbacks.onHomeDragStart then
        self.draggingHome = self.callbacks.onHomeDragStart(x, y)
      end
    end)
    catcher:SetScript("OnDragStop", function()
      if not self.draggingHome then return end
      self.draggingHome = nil
      self.dragEnded = true
      C_Timer.After(0, function() self.dragEnded = nil end)
      local x, y = self:CellAtCursor()
      if self.callbacks.onHomeDragStop then self.callbacks.onHomeDragStop(x, y) end
    end)
    self.catcher = catcher
  end
  return self
end

function GridView:LayoutCells()
  local cell, gap = self.cell, self.gap
  self.frame:SetSize(ns.GRID_W * cell, ns.GRID_H * cell)
  for y = 0, ns.GRID_H - 1 do
    for x = 0, ns.GRID_W - 1 do
      local tex = self.cells[Grid.Key(x, y)]
      tex:SetSize(cell - gap, cell - gap)
      tex:ClearAllPoints()
      tex:SetPoint("TOPLEFT", self.frame, "TOPLEFT", x * cell + gap / 2, -(y * cell + gap / 2))
      tex.edge:SetSize((cell - gap) * 64 / 37, (cell - gap) * 64 / 37)
      tex.edge:ClearAllPoints()
      tex.edge:SetPoint("CENTER", tex, "CENTER", 0, -(cell - gap) / 37)
    end
  end
end

function GridView:SetCallbacks(cb)
  self.callbacks = cb or {}
end

function GridView:CellAtCursor()
  local cx, cy = GetCursorPosition()
  local scale = self.frame:GetEffectiveScale()
  cx, cy = cx / scale, cy / scale
  local left, top = self.frame:GetLeft(), self.frame:GetTop()
  if not left or not top then return nil end
  local x = math.floor((cx - left) / self.cell)
  local y = math.floor((top - cy) / self.cell)
  if x < 0 or y < 0 or x >= ns.GRID_W or y >= ns.GRID_H then return nil end
  return x, y
end

function GridView:HandleClick(button)
  if self.dragEnded then return end
  local x, y = self:CellAtCursor()
  if not x then return end
  if self.callbacks.onCellClick then self.callbacks.onCellClick(x, y, button) end
end

function GridView:BeginHover()
  self.hovering = true
  self.lastHoverAlt = nil
end

function GridView:EndHover()
  self.hovering = false
  self.lastHoverAlt = nil
  if self.callbacks.onHoverEnd then self.callbacks.onHoverEnd() end
end

function GridView:OnUpdate()
  if not self.hovering then return end
  local x, y = self:CellAtCursor()
  local alt = IsAltKeyDown and IsAltKeyDown() or false
  if x ~= self.lastHoverX or y ~= self.lastHoverY or alt ~= self.lastHoverAlt then
    self.lastHoverX, self.lastHoverY, self.lastHoverAlt = x, y, alt
    if self.callbacks.onHover then self.callbacks.onHover(x, y) end
  end
end

local function setItemHover(frame, alpha)
  frame.hover:SetAlpha(frame.rect and alpha or 0)
  for _, cf in ipairs(frame.cellFrames or {}) do cf.hover:SetAlpha(not frame.rect and cf:IsShown() and alpha or 0) end
end

local function setItemGlow(frame, r, g, b)
  local function update(region, active)
    T.StopPulse(region)
    region:SetAlpha(active and 0.8 or 0)
    if active then
      region:SetVertexColor(r, g, b, 1)
      T.Pulse(region, 0.35, 0.9, 0.6)
    end
  end
  update(frame.glow, r ~= nil and frame.rect)
  for _, cf in ipairs(frame.cellFrames or {}) do update(cf.glow, r ~= nil and not frame.rect and cf:IsShown()) end
end

local function acquireItemFrame(self)
  local f = table.remove(self.framePool)
  if f then
    f:Show()
    return f
  end
  f = CreateFrame("Button", nil, self.frame)
  f.fill = T.NineSlice(f, T.TEX.panelSmall, 6, "BACKGROUND", 2)
  f.shadow = f:CreateTexture(nil, "BACKGROUND", nil, 0)
  f.shadow:SetTexture(T.TEX.glowSquare)
  f.shadow:SetVertexColor(0, 0, 0, 0.4)
  f.shadow:SetPoint("TOPLEFT", -5, 3)
  f.shadow:SetPoint("BOTTOMRIGHT", 5, -7)
  f.outline = T.NineSlice(f, T.TEX.outlineSmall, 6, "BORDER", 1)
  f.outline:HideCenter()
  f.outline:SetColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.9)
  f.border = T.NineSlice(f, T.TEX.borderSmall, 6, "BORDER", 0)
  f.border:HideCenter()
  f.icon = f:CreateTexture(nil, "ARTWORK", nil, 2)
  f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  f.icon:SetPoint("CENTER")
  f.shade = f:CreateTexture(nil, "ARTWORK", nil, 3)
  f.shade:SetTexture(T.TEX.white)
  f.shade:SetVertexColor(0.3, 0, 0, 0.55)
  f.shade:SetAllPoints(f.icon)
  f.shade:Hide()
  f.warn = f:CreateTexture(nil, "OVERLAY", nil, 2)
  f.warn:SetTexture(T.TEX.circle)
  f.warn:SetSize(14, 14)
  f.warn:SetPoint("TOPRIGHT", -2, -2)
  f.warn:SetVertexColor(T.RGB(T.C.bad))
  f.warn:Hide()
  f.warnText = T.Number(f, 10, { 1, 1, 1, 1 }, "!", "OUTLINE")
  f.warnText:SetPoint("CENTER", f.warn, "CENTER", 0, 0)
  f.warnText:Hide()
  f.glow = T.CreateGlow(f, 10, 1, 0.9, 0.4, 0)
  f.hover = T.CreateGlow(f, 5, 1, 1, 1, 0)
  f.flash = f:CreateTexture(nil, "OVERLAY", nil, 3)
  f.flash:SetTexture(T.TEX.glowSquare)
  f.flash:SetBlendMode("ADD")
  f.flash:SetPoint("TOPLEFT", -4, 4)
  f.flash:SetPoint("BOTTOMRIGHT", 4, -4)
  f.flash:SetAlpha(0)
  f.cooldown = CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
  f.cooldown:SetAllPoints(f.icon)
  f.cooldown:SetDrawEdge(false)
  f.cooldown:SetHideCountdownNumbers(true)
  f.cooldown:SetSwipeColor(0, 0, 0, 0.6)
  f.cooldown:Hide()
  f:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  f.itemView = self
  f:SetScript("OnClick", function(btn, button)
    if self.callbacks.onItemClick then self.callbacks.onItemClick(btn.placement, button) end
  end)
  f:SetScript("OnEnter", function(btn)
    self:BeginHover()
    setItemHover(btn, 0.3)
    if self.callbacks.onItemEnter then self.callbacks.onItemEnter(btn.placement, btn) end
  end)
  f:SetScript("OnLeave", function(btn)
    setItemHover(btn, 0)
    if self.callbacks.onItemLeave then self.callbacks.onItemLeave(btn.placement, btn) end
    if self.catcher and self.catcher:IsMouseOver() then self.lastHoverAlt = nil else self:EndHover() end
  end)
  return f
end

local function cellFrame(f, i)
  f.cellFrames = f.cellFrames or {}
  local cf = f.cellFrames[i]
  if not cf then
    cf = CreateFrame("Button", nil, f)
    cf:SetFrameLevel(f:GetFrameLevel())
    cf:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    for _, handler in ipairs({ "OnClick", "OnEnter", "OnLeave" }) do
      cf:SetScript(handler, function(_, ...)
        local script = f:GetScript(handler)
        if script then script(f, ...) end
      end)
    end
    cf.fill = T.NineSlice(cf, T.TEX.panelSmall, 6, "BACKGROUND", 2)
    cf.outline = T.NineSlice(cf, T.TEX.outlineSmall, 6, "BORDER", 1)
    cf.outline:HideCenter()
    cf.outline:SetColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.9)
    cf.ring = T.NineSlice(cf, T.TEX.borderSmall, 6, "BORDER", 0)
    cf.ring:HideCenter()
    cf.glow = T.CreateGlow(cf, 0, 1, 0.9, 0.4, 0)
    cf.glow:SetDrawLayer("BORDER", 1)
    cf.hover = T.CreateGlow(cf, 0, 1, 1, 1, 0)
    cf.hover:SetDrawLayer("BORDER", 2)
    f.cellFrames[i] = cf
  end
  return cf
end

function GridView.IconCell(rot)
  local sx, sy = 0, 0
  for _, c in ipairs(rot.cells) do sx, sy = sx + c[1], sy + c[2] end
  local cx, cy = sx / #rot.cells, sy / #rot.cells
  local best, bestD
  for _, c in ipairs(rot.cells) do
    local d = (c[1] - cx) ^ 2 + (c[2] - cy) ^ 2
    if not bestD or d < bestD then best, bestD = c, d end
  end
  return best
end

function GridView.PlaceIcon(f, rot, cell, inset)
  local rect = #rot.cells == rot.w * rot.h
  f.icon:ClearAllPoints()
  if rect then
    local w, h = rot.w * cell, rot.h * cell
    local iconSize = math.min(w, h) - inset
    if rot.w > 1 and rot.h > 1 then iconSize = math.min(iconSize, cell * 1.9) end
    if rot.w ~= rot.h then iconSize = math.min(iconSize, cell * 1.45) end
    f.icon:SetSize(iconSize, iconSize)
    f.icon:SetPoint("CENTER", f, "CENTER", 0, 0)
  else
    local c = GridView.IconCell(rot)
    local iconSize = cell - inset
    f.icon:SetSize(iconSize, iconSize)
    f.icon:SetPoint("CENTER", f, "TOPLEFT", (c[1] + 0.5) * cell, -(c[2] + 0.5) * cell)
  end
end

function GridView.LayoutShape(f, rot, cell, gap, r, g, b, quality)
  local rect = #rot.cells == rot.w * rot.h
  local corner = math.max(5, math.floor(cell / 5))
  f.fill:SetShown(rect)
  f.border:SetShown(rect)
  f.outline:SetShown(rect)
  if f.shadow then f.shadow:SetShown(rect) end
  if rect then
    f.fill:SetCorner(corner)
    f.border:SetCorner(corner)
    f.outline:SetCorner(corner)
  end
  for i, c in ipairs(rot.cells) do
    local cf = cellFrame(f, i)
    cf:SetShown(not rect)
    cf:EnableMouse(not rect and f.itemView ~= nil)
    if not rect then
      cf:SetSize(cell - gap, cell - gap)
      cf:ClearAllPoints()
      cf:SetPoint("TOPLEFT", f, "TOPLEFT", c[1] * cell, -c[2] * cell)
      cf.fill:SetCorner(corner)
      cf.outline:SetCorner(corner)
      cf.ring:SetCorner(corner)
      cf.fill:SetColor(r * 0.16 + 0.08, g * 0.16 + 0.085, b * 0.16 + 0.1, 0.85)
      cf.ring:SetColor(r, g, b, quality <= 1 and 0.7 or 1)
    end
  end
  for i = #rot.cells + 1, #(f.cellFrames or {}) do
    f.cellFrames[i]:EnableMouse(false)
    f.cellFrames[i]:Hide()
  end
end

local function layoutItem(self, f, p, def)
  local rot = ns.RotationCells(def, p.rot)
  local cell, gap = self.cell, self.gap
  local w, h = rot.w * cell, rot.h * cell
  f:SetSize(w - gap, h - gap)
  f:ClearAllPoints()
  f:SetPoint("TOPLEFT", self.frame, "TOPLEFT", p.x * cell + gap / 2, -(p.y * cell + gap / 2))
  local r, g, b = T.QualityColor(def.quality)
  f.rect = #rot.cells == rot.w * rot.h
  GridView.LayoutShape(f, rot, cell, gap, r, g, b, def.quality)
  f.border:SetColor(r, g, b, def.quality <= 1 and 0.7 or 1)
  f.fill:SetColor(r * 0.16 + 0.08, g * 0.16 + 0.085, b * 0.16 + 0.1, 0.85)
  T.SetItemIcon(f.icon, def.icon)
  GridView.PlaceIcon(f, rot, cell, 6)
  f.icon:SetDesaturated(false)
  f.icon:SetVertexColor(1, 1, 1)
  f.shade:Hide()
  f.warn:Hide()
  f.warnText:Hide()
  GridView.SetRankBadge(f, def)
  f.cooldown:Hide()
  f.flash:SetAlpha(0)
  setItemGlow(f)
  setItemHover(f, 0)
  f.placement = p
  f.def = def
end

function GridView:FitCell()
  local vw, vh = self.viewport:GetWidth(), self.viewport:GetHeight()
  if not vw or vw <= 1 or not vh or vh <= 1 then return end
  local bw, bh = ns.GRID_W, ns.GRID_H
  if self.compact and self.grid then
    local minX, minY, maxX, maxY = self.grid:Bounds()
    if minX ~= math.huge then bw, bh = maxX - minX + 1, maxY - minY + 1 end
  end
  local cell = math.floor(math.min(self.maxCell, (vw - 8) / bw, (vh - 8) / bh))
  cell = math.max(self.minCell, math.min(self.maxCell, cell))
  if cell ~= self.cell then
    self.cell = cell
    self:LayoutCells()
  end
end

function GridView:Recenter()
  self.frame:ClearAllPoints()
  if self.compact and self.grid then
    local minX, minY, maxX, maxY = self.grid:Bounds()
    if minX ~= math.huge then
      local cx = (minX + maxX + 1) / 2 * self.cell
      local cy = (minY + maxY + 1) / 2 * self.cell
      self.frame:SetPoint("CENTER", self.viewport, "CENTER", self.frame:GetWidth() / 2 - cx, -(self.frame:GetHeight() / 2 - cy))
      return
    end
  end
  self.frame:SetPoint("CENTER", self.viewport, "CENTER", 0, 0)
end

local function bagTint(grid, owner)
  for i, p in ipairs(grid.bags) do
    if p == owner or p.uid == owner then return T.BAG_TINTS[((i - 1) % #T.BAG_TINTS) + 1] end
  end
  return T.C.cell
end

local function acquireBagFrame(self)
  local f = table.remove(self.bagPool)
  if f then
    f:Show()
    return f
  end
  f = CreateFrame("Frame", nil, self.frame)
  f:EnableMouse(false)
  f.border = T.NineSlice(f, T.TEX.borderSmall, 6, "BORDER", 0)
  f.border:HideCenter()
  f.icon = f:CreateTexture(nil, "ARTWORK")
  f.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  f.icon:SetAlpha(0.3)
  f.tag = f:CreateTexture(nil, "ARTWORK", nil, -1)
  f.tag:SetTexture(T.TEX.circle)
  f.tag:SetVertexColor(0, 0, 0, 0.55)
  return f
end

local function layoutBag(self, f, p, def, tint)
  local rot = ns.RotationCells(def, p.rot)
  local cell, gap = self.cell, self.gap
  f:SetSize(rot.w * cell - gap, rot.h * cell - gap)
  f:ClearAllPoints()
  f:SetPoint("TOPLEFT", self.frame, "TOPLEFT", p.x * cell + gap / 2, -(p.y * cell + gap / 2))
  local corner = math.max(5, math.floor(cell / 5))
  local rect = #rot.cells == rot.w * rot.h
  f.border:SetShown(rect)
  f.border:SetCorner(corner)
  f.border:SetColor(tint[1], tint[2], tint[3], 0.9)
  f.cellRings = f.cellRings or {}
  for i, c in ipairs(rot.cells) do
    local cf = f.cellRings[i]
    if not cf then
      cf = CreateFrame("Frame", nil, f)
      cf.ring = T.NineSlice(cf, T.TEX.borderSmall, corner, "BORDER", 0)
      cf.ring:HideCenter()
      f.cellRings[i] = cf
    end
    cf:SetShown(not rect)
    if not rect then
      cf:SetSize(cell - gap, cell - gap)
      cf:ClearAllPoints()
      cf:SetPoint("TOPLEFT", f, "TOPLEFT", c[1] * cell, -c[2] * cell)
      cf.ring:SetCorner(corner)
      cf.ring:SetColor(tint[1], tint[2], tint[3], 0.9)
    end
  end
  for i = #rot.cells + 1, #f.cellRings do f.cellRings[i]:Hide() end
  local iconSize = math.floor(cell * 0.55)
  T.SetItemIcon(f.icon, def.icon)
  f.icon:SetSize(iconSize, iconSize)
  f.icon:ClearAllPoints()
  f.icon:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5)
  f.tag:SetSize(iconSize + 8, iconSize + 8)
  f.tag:ClearAllPoints()
  f.tag:SetPoint("CENTER", f.icon, "CENTER", 0, 0)
  f:SetFrameLevel(self.frame:GetFrameLevel() + 1)
  f.placement = p
end

function GridView:SetGrid(grid, disabledUids)
  self.grid = grid
  self.lastHoverAlt = nil
  self.lastDisabled = disabledUids
  if grid then self:FitCell() end
  for key, tex in pairs(self.cells) do
    local owner = grid and grid.cells[key]
    if owner then
      tex:Show()
      tex.edge:Show()
      tex:SetAlpha(1)
      tex.edge:SetAlpha(1)
    elseif self.compact then
      tex:Hide()
      tex.edge:Hide()
    else
      tex:Show()
      tex.edge:Show()
      local a = self.ghost and 0.4 or 0.16
      tex:SetAlpha(a)
      tex.edge:SetAlpha(a)
    end
  end
  for uid, f in pairs(self.itemFrames) do
    f:Hide()
    setItemGlow(f)
    if f.bbPop then f.bbPop:Stop() end
    f.placement = nil
    self.framePool[#self.framePool + 1] = f
    self.itemFrames[uid] = nil
  end
  for uid, f in pairs(self.bagFrames) do
    f:Hide()
    if f.bbPop then f.bbPop:Stop() end
    f.placement = nil
    self.bagPool[#self.bagPool + 1] = f
    self.bagFrames[uid] = nil
  end
  if not grid then return end
  if not self.homeFrame then
    self.homeFrame = CreateFrame("Frame", nil, self.frame)
    self.homeFrame:EnableMouse(false)
    self.homeFrame.border = T.NineSlice(self.homeFrame, T.TEX.borderSmall, 8, "BORDER", 0)
    self.homeFrame.border:HideCenter()
    self.homeFrame.border:SetColor(T.C.cell[1], T.C.cell[2], T.C.cell[3], 0.65)
  end
  self.homeFrame:SetSize(ns.START_W * self.cell - self.gap, ns.START_H * self.cell - self.gap)
  self.homeFrame:ClearAllPoints()
  self.homeFrame:SetPoint("TOPLEFT", self.frame, "TOPLEFT", grid.home.x * self.cell + self.gap / 2, -(grid.home.y * self.cell + self.gap / 2))
  self.homeFrame:SetFrameLevel(self.frame:GetFrameLevel() + 1)
  self.homeFrame:Show()
  for _, p in ipairs(grid.bags) do
    local def = ns.Items[p.id]
    local f = acquireBagFrame(self)
    layoutBag(self, f, p, def, bagTint(grid, p))
    self.bagFrames[p.uid] = f
  end
  for _, p in ipairs(grid.items) do
    local def = ns.Items[p.id]
    local f = acquireItemFrame(self)
    layoutItem(self, f, p, def)
    f.shadow:SetAlpha(1)
    f.icon:SetAlpha(1)
    f:SetFrameLevel(self.frame:GetFrameLevel() + (f.rect and 4 or 3))
    f:EnableMouse(f.rect)
    for _, cf in ipairs(f.cellFrames) do cf:SetFrameLevel(f:GetFrameLevel()) end
    if disabledUids and disabledUids[p.uid] then
      f.icon:SetDesaturated(true)
      f.warn:Show()
      f.warnText:Show()
    end
    self.itemFrames[p.uid] = f
  end
  self:Recenter()
end

function GridView:SetGhost(on)
  if self.ghost ~= on then
    self.ghost = on
    self:SetGrid(self.grid, self.lastDisabled)
  end
end

function GridView:ItemFrame(uid)
  return self.itemFrames[uid] or self.bagFrames[uid]
end

function GridView:PopItem(uid)
  local f = self.itemFrames[uid] or self.bagFrames[uid]
  if f then T.Pop(f, 1.2, 0.2) T.Burst(self.frame, f, 1, 0.9, 0.5, math.max(f:GetWidth(), f:GetHeight()) + 24) end
end

local function acquirePreview(self)
  self.previewUsed = self.previewUsed + 1
  local tex = self.previewPool[self.previewUsed]
  if not tex then
    tex = self.frame:CreateTexture(nil, "OVERLAY", nil, 2)
    tex:SetTexture(T.TEX.panelSmall)
    self.previewPool[self.previewUsed] = tex
  end
  tex:SetSize(self.cell - self.gap, self.cell - self.gap)
  tex:Show()
  return tex
end

function GridView:ClearPreview()
  for i = 1, self.previewUsed do self.previewPool[i]:Hide() end
  self.previewUsed = 0
end

function GridView:ShowPreview(def, x, y, rot, valid)
  self:ClearPreview()
  local cells = Grid.Footprint(def, x, y, rot)
  for _, c in ipairs(cells) do
    local cx, cy = c[1], c[2]
    if cx >= 0 and cy >= 0 and cx < ns.GRID_W and cy < ns.GRID_H then
      local tex = acquirePreview(self)
      tex:ClearAllPoints()
      tex:SetPoint("TOPLEFT", self.frame, "TOPLEFT", cx * self.cell + self.gap / 2, -(cy * self.cell + self.gap / 2))
      if valid == "swap" then tex:SetVertexColor(1, 0.85, 0.2, 0.45)
      elseif valid then tex:SetVertexColor(0.3, 1, 0.4, 0.4)
      else tex:SetVertexColor(1, 0.25, 0.25, 0.4) end
    end
  end
end

function GridView:ShowHomePreview(x, y, valid)
  self:ClearPreview()
  local dx, dy = x - self.grid.home.x, y - self.grid.home.y
  for key in pairs(self.grid:HomeMoveCells()) do
    local cx, cy = key % 100 + dx, math.floor(key / 100) + dy
    if self.grid:InBounds(cx, cy) then
      local tex = acquirePreview(self)
      tex:ClearAllPoints()
      tex:SetPoint("TOPLEFT", self.frame, "TOPLEFT", cx * self.cell + self.gap / 2, -(cy * self.cell + self.gap / 2))
      if valid then tex:SetVertexColor(0.3, 1, 0.4, 0.4) else tex:SetVertexColor(1, 0.25, 0.25, 0.4) end
    end
  end
end

function GridView:ClearGlow()
  for _, f in pairs(self.itemFrames) do setItemGlow(f) end
end

function GridView:GlowItems(placements, r, g, b)
  for _, p in ipairs(placements) do
    local f = self.itemFrames[p.uid]
    if f then setItemGlow(f, r or 1, g or 0.9, b or 0.4) end
  end
end

function GridView:FlashItem(uid, duration)
  local f = self.itemFrames[uid]
  if not f then return end
  f.flash:SetVertexColor(1, 0.95, 0.7, 1)
  T.Flash(f.flash, duration or 0.4)
  T.Pop(f, 1.1, 0.15)
end

function GridView:StartCooldown(uid, duration)
  local f = self.itemFrames[uid]
  if not f or not duration or duration <= 0 then return end
  f.cooldown:Show()
  f.cooldown:Resume()
  f.cooldown:SetCooldown(GetTime(), duration)
end

function GridView:ClearCooldowns()
  for _, f in pairs(self.itemFrames) do
    f.cooldown:Resume()
    f.cooldown:Clear()
    f.cooldown:Hide()
    f.flash:SetAlpha(0)
  end
end
