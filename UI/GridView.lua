local ADDON, ns = ...
local T = ns.UI.Theme
local Grid = ns.Grid

local GridView = {}
GridView.__index = GridView
ns.UI.GridView = GridView

local RANK_LABELS = { "I", "II", "III", "IV", "V" }

function GridView.SetRankBadge(frame, def)
  local rank = def and (def.rank or 1)
  local label = def and ns.Ranks.Definition(def, 2) and (RANK_LABELS[rank] or tostring(rank))
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

local FACING_LABELS = { "^", ">", "v", "<" }

-- Catalog glyphs have no inventory context. A synthetic usable one-cell band
-- shows potential effects, using the combat resolver rather than real bag fit.
function GridView.GlyphGeometry(def, rotation)
  local shape = ns.RotationCells(def, rotation or 0)
  local grid = setmetatable({ W = shape.w + 2, H = shape.h + 2, cells = {}, occ = {}, items = {}, bags = {} }, Grid)
  for y = 0, grid.H - 1 do
    for x = 0, grid.W - 1 do grid.cells[Grid.Key(x, y)] = "glyph" end
  end
  local placement = { id = def.id, uid = 1, x = 1, y = 1, rot = rotation or 0, cells = {} }
  for _, cell in ipairs(shape.cells) do
    local key = Grid.Key(cell[1] + 1, cell[2] + 1)
    placement.cells[#placement.cells + 1], grid.occ[key] = key, placement
  end
  grid.items[1] = placement
  local selected = {}
  local function include(rule)
    for _, key in ipairs(grid:EffectCells(placement, rule)) do selected[key] = true end
  end
  for _, rule in ipairs(def.adjacency or {}) do if not rule.inside then include(rule) end end
  local orthogonal = false
  local function effects(list)
    for _, effect in ipairs(list or {}) do if effect.target == "neighbors" then orthogonal = true end end
  end
  effects(def.use and def.use.effects)
  for _, trigger in ipairs(def.triggers or {}) do
    if trigger.on and trigger.on:find("^adjacent") then orthogonal = true end
    effects(trigger.effects)
  end
  if orthogonal then include() end
  local keys, cells = {}, {}
  for key in pairs(selected) do keys[#keys + 1] = key end
  table.sort(keys)
  local minX, minY, maxX, maxY = 0, 0, shape.w - 1, shape.h - 1
  for _, key in ipairs(keys) do
    local x, y = key % 100 - 1, math.floor(key / 100) - 1
    cells[#cells + 1] = { x, y }
    minX, minY = math.min(minX, x), math.min(minY, y)
    maxX, maxY = math.max(maxX, x), math.max(maxY, y)
  end
  return { shape = shape, effects = cells, minX = minX, minY = minY, w = maxX - minX + 1, h = maxY - minY + 1 }
end

function GridView.SetFacingBadge(frame, def, rotation, cell, gap)
  local directional = false
  for _, rule in ipairs(def and def.adjacency or {}) do
    if rule.side then directional = true break end
  end
  if not directional then
    if frame.facingText then frame.facingText:Hide() end
    return
  end
  local rot = ns.RotationCells(def, rotation)
  local direction = (rotation or 0) % 4
  local dx, dy = 0, -1
  for _ = 1, direction do dx, dy = -dy, dx end
  local best, projection, distance
  for _, c in ipairs(rot.cells) do
    local along = c[1] * dx + c[2] * dy
    local across = math.abs((c[1] - (rot.w - 1) / 2) * dy - (c[2] - (rot.h - 1) / 2) * dx)
    if not best or along > projection or along == projection and across < distance then
      best, projection, distance = c, along, across
    end
  end
  if not frame.facingText then frame.facingText = T.Number(frame, 13, T.C.gold, nil, "OUTLINE") end
  frame.facingText:ClearAllPoints()
  -- Anchor inside an occupied silhouette cell, including nonrectangular shapes.
  frame.facingText:SetPoint("CENTER", frame, "TOPLEFT",
    (best[1] + 0.5) * cell + dx * (cell * 0.5 - 6) - (gap or 0) / 2,
    -(best[2] + 0.5) * cell - dy * (cell * 0.5 - 6) + (gap or 0) / 2)
  frame.facingText:SetText(FACING_LABELS[direction + 1])
  frame.facingText:Show()
end

local function placementOrder(a, b)
  if a.x ~= b.x then return a.x < b.x end
  if a.y ~= b.y then return a.y < b.y end
  if a.id ~= b.id then return a.id < b.id end
  return (a.rot or 0) < (b.rot or 0)
end

function GridView.RuleRecipients(grid, placement, rule, suppressed)
  local out = {}
  if suppressed and suppressed[placement.uid] then return out end
  for _, recipient in ipairs(grid:EffectNeighbors(placement, rule)) do
    if not (suppressed and suppressed[recipient.uid]) and ns.Util.MatchDef(ns.Items[recipient.id], rule.match) then
      out[#out + 1] = recipient
    end
  end
  table.sort(out, placementOrder)
  if rule.once then for index = #out, 2, -1 do out[index] = nil end end
  return out
end

-- Geometry comes from the same resolver as combat. Potential cells remain
-- visible when empty, occupied by a nonmatching item, or excluded by once.
function GridView.EffectHints(grid, placement, suppressed)
  local states, targets, seen = {}, {}, {}
  local def = ns.Items[placement.id]
  for _, rule in ipairs(def and def.adjacency or {}) do
    if not rule.inside then
      local regionRule = rule
      if rule.empty then
        regionRule = { side = rule.side, corners = rule.corners }
      end
      for _, key in ipairs(grid:EffectCells(placement, regionRule)) do
        if not states[key] then states[key] = "potential" end
      end
      if not (suppressed and suppressed[placement.uid]) then
        if rule.empty then
          for index, key in ipairs(grid:EffectCells(placement, rule)) do
            if not rule.once or index == 1 then states[key] = "empty" end
          end
        else
          local selected = {}
          for _, key in ipairs(grid:EffectCells(placement, rule)) do selected[key] = true end
          for _, recipient in ipairs(GridView.RuleRecipients(grid, placement, rule, suppressed)) do
            if not seen[recipient] then targets[#targets + 1], seen[recipient] = recipient, true end
            for _, key in ipairs(recipient.cells) do
              if selected[key] then states[key] = "matched" end
            end
          end
        end
      end
    end
  end
  local cells = {}
  for key, state in pairs(states) do cells[#cells + 1] = { key = key, state = state } end
  table.sort(cells, function(a, b) return a.key < b.key end)
  table.sort(targets, placementOrder)
  return { cells = cells, targets = targets }
end

function GridView:ClearEffectHints()
  for _, hint in ipairs(self.effectHintPool or {}) do
    if hint.glow then
      T.StopPulse(hint.glow)
      hint.glow:Hide()
    end
    hint:Hide()
  end
  self.effectHints = nil
end

function GridView:ShowEffectHints(placement, grid, suppressed)
  self:ClearEffectHints()
  grid = grid or self.grid
  if not grid or not placement then return end
  local hints = GridView.EffectHints(grid, placement, suppressed or self.suppressedUids)
  self.effectHints = hints
  self.effectHintPool = self.effectHintPool or {}
  for index, info in ipairs(hints.cells) do
    local hint = self.effectHintPool[index]
    if not hint then
      hint = CreateFrame("Frame", nil, self.frame)
      hint:EnableMouse(false)
      hint.fill = hint:CreateTexture(nil, "BACKGROUND")
      hint.fill:SetTexture(T.TEX.white)
      hint.fill:SetAllPoints()
      hint.glow = hint:CreateTexture(nil, "OVERLAY", nil, 1)
      local atlas = "bags-glow-white"
      local atlasInfo = C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas)
      if atlasInfo and hint.glow.SetAtlas then
        hint.glow:SetAtlas(atlas)
        hint.glowScale = 1.1
      else
        hint.glow:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        hint.glowScale = 62 / 36
      end
      hint.glow:SetBlendMode("ADD")
      hint.glow:SetPoint("CENTER", hint, "CENTER", 0, 0)
      hint.edges = {}
      for edge = 1, 4 do
        hint.edges[edge] = hint:CreateTexture(nil, "OVERLAY")
        hint.edges[edge]:SetTexture(T.TEX.white)
      end
      self.effectHintPool[index] = hint
    end
    local size = self.cell - self.gap - 4
    hint:SetFrameLevel(self.frame:GetFrameLevel() + 8)
    hint:SetSize(size, size)
    hint:ClearAllPoints()
    hint:SetPoint("TOPLEFT", self.frame, "TOPLEFT",
      (info.key % 100) * self.cell + self.gap / 2 + 2,
      -(math.floor(info.key / 100) * self.cell + self.gap / 2 + 2))
    local potential = info.state == "potential"
    local r, g, b = 0.35, 0.7, 1
    if info.state == "matched" then r, g, b = 1, 0.85, 0.3
    elseif info.state == "empty" then r, g, b = 0.3, 1, 0.5 end
    hint.fill:SetVertexColor(r, g, b, potential and 0.04 or 0.13)
    local glowSize = size * hint.glowScale
    hint.glow:SetSize(glowSize, glowSize)
    hint.glow:SetVertexColor(r, g, b, 1)
    hint.glow:SetAlpha(0.85)
    hint.glow:SetShown(not potential)
    if not potential then T.Pulse(hint.glow, 0.2, 1, 0.5) end
    for edge, texture in ipairs(hint.edges) do
      texture:ClearAllPoints()
      texture:SetVertexColor(r, g, b, potential and 0.45 or 0.95)
      if edge <= 2 then
        texture:SetSize(size, potential and 1 or 2)
        texture:SetPoint(edge == 1 and "TOPLEFT" or "BOTTOMLEFT", hint, edge == 1 and "TOPLEFT" or "BOTTOMLEFT", 0, 0)
      else
        texture:SetSize(potential and 1 or 2, size)
        texture:SetPoint(edge == 3 and "TOPLEFT" or "TOPRIGHT", hint, edge == 3 and "TOPLEFT" or "TOPRIGHT", 0, 0)
      end
    end
    hint:Show()
  end
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
  self:ClearEffectHints()
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
    self:ShowEffectHints(btn.placement)
    if self.callbacks.onItemEnter then self.callbacks.onItemEnter(btn.placement, btn) end
  end)
  f:SetScript("OnLeave", function(btn)
    setItemHover(btn, 0)
    self:ClearEffectHints()
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
  GridView.SetFacingBadge(f, def, p.rot, cell, gap)
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
  self:ClearPreview()
  self:ClearEffectHints()
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
  self:ClearEffectHints()
  if self.previewFacing then self.previewFacing:Hide() end
end

function GridView.PreviewPlacement(grid, def, x, y, rot, replacedUid)
  local preview = setmetatable({ W = grid.W, H = grid.H, cells = grid.cells, occ = {}, items = {}, bags = grid.bags }, Grid)
  for key, placement in pairs(grid.occ) do
    if placement.uid ~= replacedUid then preview.occ[key] = placement end
  end
  for _, placement in ipairs(grid.items) do
    if placement.uid ~= replacedUid then preview.items[#preview.items + 1] = placement end
  end
  local placement = { id = def.id, uid = grid.nextUid, x = x, y = y, rot = rot, cells = {} }
  for _, cell in ipairs(Grid.Footprint(def, x, y, rot)) do
    local key = Grid.Key(cell[1], cell[2])
    placement.cells[#placement.cells + 1], preview.occ[key] = key, placement
  end
  preview.items[#preview.items + 1] = placement
  return preview, placement
end

function GridView:ShowPreview(def, x, y, rot, valid, replacedUid)
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
  if def.kind ~= "bag" then
    if not self.previewFacing then
      self.previewFacing = CreateFrame("Frame", nil, self.frame)
      self.previewFacing:EnableMouse(false)
    end
    local shape = ns.RotationCells(def, rot)
    self.previewFacing:SetSize(shape.w * self.cell - self.gap, shape.h * self.cell - self.gap)
    self.previewFacing:ClearAllPoints()
    self.previewFacing:SetPoint("TOPLEFT", self.frame, "TOPLEFT", x * self.cell + self.gap / 2, -(y * self.cell + self.gap / 2))
    self.previewFacing:SetFrameLevel(self.frame:GetFrameLevel() + 9)
    GridView.SetFacingBadge(self.previewFacing, def, rot, self.cell, self.gap)
    self.previewFacing:Show()
    if valid and self.grid then
      local preview, placement = GridView.PreviewPlacement(self.grid, def, x, y, rot, replacedUid)
      self:ShowEffectHints(placement, preview)
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
