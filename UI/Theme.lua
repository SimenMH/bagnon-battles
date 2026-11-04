local ADDON, ns = ...
local Util = ns.Util

ns.UI = ns.UI or {}
local T = {}
ns.UI.Theme = T

T.CELL = 50
T.CELL_GAP = 3
T.RESOURCE_ORDER = { "mana", "rage", "energy", "focus", "combo" }

local MEDIA = "Interface\\AddOns\\" .. ADDON .. "\\Media\\"

T.TEX = {
  panel = MEDIA .. "panel",
  panelSmall = MEDIA .. "panel_small",
  border = MEDIA .. "border",
  borderSmall = MEDIA .. "border_small",
  outline = MEDIA .. "outline",
  outlineSmall = MEDIA .. "outline_small",
  glossSmall = MEDIA .. "gloss_small",
  glow = MEDIA .. "glow",
  glowSquare = MEDIA .. "glow_square",
  ring = MEDIA .. "ring",
  circle = MEDIA .. "circle",
  burst = MEDIA .. "burst",
  shine = MEDIA .. "shine",
  heart = MEDIA .. "heart",
  trophy = MEDIA .. "trophy",
  white = "Interface\\Buttons\\WHITE8X8",
  emptySlot = "Interface\\PaperDoll\\UI-Backpack-EmptySlot",
  slotFrame = "Interface\\Buttons\\UI-Quickslot2",
  gold = "Interface\\MoneyFrame\\UI-GoldIcon",
  lock = "Interface\\PetBattles\\PetBattle-LockIcon",
  gear = "Interface\\Buttons\\UI-OptionsButton",
  close = "Interface\\Buttons\\UI-StopButton",
  classIcons = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
  minimapBorder = "Interface\\Minimap\\MiniMap-TrackingBorder",
  minimapBg = "Interface\\Minimap\\UI-Minimap-Background",
  questionMark = "Interface\\Icons\\INV_Misc_QuestionMark",
  logo = "Interface\\Icons\\INV_Misc_Bag_07_Red",
  sell = "Interface\\Icons\\INV_Misc_Coin_02",
}

T.GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:14:14:2:0|t"

T.C = {
  bg0 = { 0.12, 0.10, 0.11, 1 },
  bg1 = { 0.17, 0.14, 0.15, 1 },
  bg2 = { 0.07, 0.09, 0.11, 1 },
  bg3 = { 0.24, 0.20, 0.20, 1 },
  bg4 = { 0.32, 0.27, 0.26, 1 },
  line = { 0.38, 0.32, 0.30, 1 },
  ink = { 0.03, 0.02, 0.03, 1 },
  gold = { 0.98, 0.78, 0.34, 1 },
  goldDim = { 0.68, 0.53, 0.24, 1 },
  text = { 0.97, 0.94, 0.88, 1 },
  muted = { 0.72, 0.66, 0.62, 1 },
  dim = { 0.50, 0.45, 0.42, 1 },
  good = { 0.45, 0.88, 0.50, 1 },
  bad = { 0.95, 0.38, 0.38, 1 },
  cell = { 0.62, 0.50, 0.34, 1 },
}

T.BAG_TINTS = {
  { 0.30, 0.46, 0.62 },
  { 0.32, 0.56, 0.40 },
  { 0.56, 0.36, 0.60 },
  { 0.66, 0.48, 0.26 },
}

local function settings()
  return ns.db and ns.db.global and ns.db.global.settings or {}
end

local function fontOf(obj, fallback)
  if obj and obj.GetFont then
    local ok, path = pcall(obj.GetFont, obj)
    if ok and type(path) == "string" then return path end
  end
  return fallback
end
T.FONT = fontOf(GameFontNormal, "Fonts\\FRIZQT__.TTF")
T.NUMFONT = fontOf(NumberFontNormal, "Fonts\\ARIALN.TTF")
T.TITLEFONT = fontOf(QuestTitleFont, "Fonts\\MORPHEUS.TTF")

local function rgb(c) return c[1], c[2], c[3], c[4] or 1 end
T.RGB = rgb

function T.QualityColor(quality)
  local c = ITEM_QUALITY_COLORS and ITEM_QUALITY_COLORS[quality] or ns.QUALITY_COLORS[quality] or ns.QUALITY_COLORS[1]
  if quality and quality <= 1 then return 0.72, 0.72, 0.76 end
  return c.r, c.g, c.b
end

function T.QualityHex(quality)
  local r, g, b = T.QualityColor(quality)
  return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function T.ClassColor(classKey)
  local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classKey]
  if c then return c.r, c.g, c.b end
  local def = ns.Classes[classKey]
  if def and def.color then return def.color.r, def.color.g, def.color.b end
  return 1, 1, 1
end

function T.ClassHex(classKey)
  local r, g, b = T.ClassColor(classKey)
  return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function T.Hex(r, g, b)
  return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function T.ResolveIcon(icon)
  if type(icon) == "number" then return icon > 0 and icon or T.TEX.questionMark end
  if type(icon) ~= "string" or icon == "" then return T.TEX.questionMark end
  local legacy = icon:gsub("([\\/])[Cc][Ll][Aa][Ss][Ss][Ii][Cc]_", "%1")
  if GetFileIDFromPath then
    for _, path in ipairs(legacy ~= icon and { icon, legacy } or { icon }) do
      local candidates = path:match("%.[%a%d]+$") and { path } or { path, path .. ".blp" }
      for _, candidate in ipairs(candidates) do
        local ok, fileID = pcall(GetFileIDFromPath, candidate)
        if ok and type(fileID) == "number" and fileID > 0 then return fileID end
      end
    end
    return T.TEX.questionMark
  end
  return legacy
end

function T.SetItemIcon(texture, icon)
  local resolved = T.ResolveIcon(icon)
  texture:SetTexture(resolved)
  return resolved
end

function T.SetClassIcon(texture, classKey)
  local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[classKey]
  if coords then
    texture:SetTexture(T.TEX.classIcons)
    texture:SetTexCoord(unpack(coords))
  else
    local def = ns.Classes[classKey]
    T.SetItemIcon(texture, def and def.icon)
    texture:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  end
end

function T.SchoolColor(school)
  local c = ns.SCHOOL_COLORS[school] or ns.SCHOOL_COLORS.physical
  return c.r, c.g, c.b
end

function T.ResourceColor(resource)
  local c = ns.RESOURCE_COLORS[resource] or ns.RESOURCE_COLORS.mana
  return c.r, c.g, c.b
end

local function applyColor(fs, color)
  local c = color or T.C.text
  fs:SetTextColor(c[1], c[2], c[3], c[4] or 1)
end

function T.Text(parent, size, color, text, flags, layer)
  local fs = parent:CreateFontString(nil, layer or "OVERLAY")
  fs:SetFont(T.FONT, size or 12, flags or "")
  applyColor(fs, color)
  fs:SetShadowColor(0, 0, 0, 0.6)
  fs:SetShadowOffset(1, -1)
  if text then fs:SetText(text) end
  return fs
end

function T.Number(parent, size, color, text, flags)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  fs:SetFont(T.NUMFONT, size or 12, flags or "")
  applyColor(fs, color)
  fs:SetShadowColor(0, 0, 0, 0.7)
  fs:SetShadowOffset(1, -1)
  if text then fs:SetText(text) end
  return fs
end

function T.Title(parent, size, color, text, flags)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  fs:SetFont(T.FONT, size or 16, flags or "")
  applyColor(fs, color or T.C.text)
  fs:SetShadowColor(0, 0, 0, 0.8)
  fs:SetShadowOffset(1, -1)
  if text then fs:SetText(text) end
  return fs
end

function T.Display(parent, size, color, text)
  local fs = parent:CreateFontString(nil, "OVERLAY")
  fs:SetFont(T.TITLEFONT, size or 28, "OUTLINE")
  applyColor(fs, color or T.C.gold)
  fs:SetShadowColor(0, 0, 0, 0.9)
  fs:SetShadowOffset(2, -2)
  if text then fs:SetText(text) end
  return fs
end

function T.Label(parent, text)
  return T.Text(parent, 11, T.C.dim, text and text:upper() or nil)
end

function T.Font(parent, template, text, justify)
  local fs = parent:CreateFontString(nil, "OVERLAY", template or "GameFontNormal")
  if text then fs:SetText(text) end
  if justify then fs:SetJustifyH(justify) end
  return fs
end

local NineSlice = {}
NineSlice.__index = NineSlice

function T.NineSlice(parent, file, corner, layer, sublevel, fraction)
  local self = setmetatable({ parts = {} }, NineSlice)
  local names = { "tl", "t", "tr", "l", "c", "r", "bl", "b", "br" }
  for _, n in ipairs(names) do
    local tex = parent:CreateTexture(nil, layer or "BACKGROUND", nil, sublevel or 0)
    tex:SetTexture(file)
    self.parts[n] = tex
  end
  local p = self.parts
  local f = fraction or 0.25
  p.tl:SetTexCoord(0, f, 0, f)
  p.t:SetTexCoord(f, 1 - f, 0, f)
  p.tr:SetTexCoord(1 - f, 1, 0, f)
  p.l:SetTexCoord(0, f, f, 1 - f)
  p.c:SetTexCoord(f, 1 - f, f, 1 - f)
  p.r:SetTexCoord(1 - f, 1, f, 1 - f)
  p.bl:SetTexCoord(0, f, 1 - f, 1)
  p.b:SetTexCoord(f, 1 - f, 1 - f, 1)
  p.br:SetTexCoord(1 - f, 1, 1 - f, 1)
  self:SetCorner(corner or 12)
  p.tl:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
  p.tr:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
  p.bl:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 0)
  p.br:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
  p.t:SetPoint("TOPLEFT", p.tl, "TOPRIGHT")
  p.t:SetPoint("BOTTOMRIGHT", p.tr, "BOTTOMLEFT")
  p.b:SetPoint("TOPLEFT", p.bl, "TOPRIGHT")
  p.b:SetPoint("BOTTOMRIGHT", p.br, "BOTTOMLEFT")
  p.l:SetPoint("TOPLEFT", p.tl, "BOTTOMLEFT")
  p.l:SetPoint("BOTTOMRIGHT", p.bl, "TOPRIGHT")
  p.r:SetPoint("TOPLEFT", p.tr, "BOTTOMLEFT")
  p.r:SetPoint("BOTTOMRIGHT", p.br, "TOPRIGHT")
  p.c:SetPoint("TOPLEFT", p.tl, "BOTTOMRIGHT")
  p.c:SetPoint("BOTTOMRIGHT", p.br, "TOPLEFT")
  return self
end

function NineSlice:SetCorner(corner)
  for _, n in ipairs({ "tl", "tr", "bl", "br" }) do self.parts[n]:SetSize(corner, corner) end
end

function NineSlice:SetColor(r, g, b, a)
  for _, tex in pairs(self.parts) do tex:SetVertexColor(r, g, b, a or 1) end
end

function NineSlice:SetShown(shown)
  for _, tex in pairs(self.parts) do tex:SetShown(shown) end
end

function NineSlice:SetAlpha(a)
  for _, tex in pairs(self.parts) do tex:SetAlpha(a) end
end

function NineSlice:HideCenter()
  self.parts.c:Hide()
end

local PANELS = {
  panel = { fill = T.C.bg1, outline = T.C.ink, rim = { 1, 1, 1 }, rimAlpha = 0.07, corner = 16 },
  card = { fill = T.C.bg3, outline = T.C.ink, rim = { 1, 1, 1 }, rimAlpha = 0.10, corner = 14, lift = true },
  pill = { fill = T.C.bg2, outline = T.C.ink, outlineAlpha = 0.8, corner = 10, small = true },
}

function T.Panel(parent, style, opts)
  opts = opts or {}
  local s = PANELS[style or "panel"] or PANELS.panel
  local f = CreateFrame(opts.frameType or "Frame", opts.name, parent)
  local small = s.small
  local corner = opts.corner or s.corner
  f.fill = T.NineSlice(f, small and T.TEX.panelSmall or T.TEX.panel, corner, "BACKGROUND", 0)
  f.fill:SetColor(rgb(opts.fill or s.fill))
  if s.lift then
    local lift = f:CreateTexture(nil, "BACKGROUND", nil, -1)
    lift:SetTexture(T.TEX.glowSquare)
    lift:SetVertexColor(0, 0, 0, 0.5)
    lift:SetPoint("TOPLEFT", f, "TOPLEFT", -6, 2)
    lift:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", 6, -10)
  end
  if s.outline or opts.border then
    f.border = T.NineSlice(f, small and T.TEX.outlineSmall or T.TEX.outline, corner, "BORDER", 0)
    f.border:HideCenter()
    local b = opts.border or s.outline
    f.border:SetColor(b[1], b[2], b[3], opts.borderAlpha or s.outlineAlpha or 0.95)
  end
  if s.rim then
    local rimInset = small and 2 or 3
    f.rim = T.NineSlice(f, small and T.TEX.borderSmall or T.TEX.border, math.max(4, corner - rimInset), "BORDER", 1)
    f.rim:HideCenter()
    f.rim:SetColor(s.rim[1], s.rim[2], s.rim[3], s.rimAlpha or 0.1)
    for _, tex in pairs(f.rim.parts) do
      tex:ClearAllPoints()
    end
    local p = f.rim.parts
    p.tl:SetPoint("TOPLEFT", f, "TOPLEFT", rimInset, -rimInset)
    p.tr:SetPoint("TOPRIGHT", f, "TOPRIGHT", -rimInset, -rimInset)
    p.bl:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", rimInset, rimInset)
    p.br:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -rimInset, rimInset)
    p.t:SetPoint("TOPLEFT", p.tl, "TOPRIGHT") p.t:SetPoint("BOTTOMRIGHT", p.tr, "BOTTOMLEFT")
    p.b:SetPoint("TOPLEFT", p.bl, "TOPRIGHT") p.b:SetPoint("BOTTOMRIGHT", p.br, "BOTTOMLEFT")
    p.l:SetPoint("TOPLEFT", p.tl, "BOTTOMLEFT") p.l:SetPoint("BOTTOMRIGHT", p.bl, "TOPRIGHT")
    p.r:SetPoint("TOPLEFT", p.tr, "BOTTOMLEFT") p.r:SetPoint("BOTTOMRIGHT", p.br, "TOPRIGHT")
    p.c:SetPoint("TOPLEFT", p.tl, "BOTTOMRIGHT") p.c:SetPoint("BOTTOMRIGHT", p.br, "TOPLEFT")
  end
  function f:SetFillColor(r, g, b, a) self.fill:SetColor(r, g, b, a or 1) end
  function f:SetBorderColor(r, g, b, a) if self.border then self.border:SetColor(r, g, b, a or 1) end end
  return f
end

function T.CreateShadow(frame, size, alpha)
  local shadow = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
  shadow:SetTexture(T.TEX.glowSquare)
  shadow:SetVertexColor(0, 0, 0, alpha or 0.6)
  shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -(size or 18), size or 18)
  shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", size or 18, -(size or 18))
  return shadow
end

function T.CreateGlow(frame, inset, r, g, b, a)
  local glow = frame:CreateTexture(nil, "BACKGROUND", nil, -3)
  glow:SetTexture(T.TEX.glowSquare)
  glow:SetVertexColor(r or 1, g or 0.82, b or 0.2, 1)
  glow:SetAlpha(a or 0)
  glow:SetPoint("TOPLEFT", frame, "TOPLEFT", -(inset or 10), inset or 10)
  glow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", inset or 10, -(inset or 10))
  glow:SetBlendMode("ADD")
  return glow
end

function T.Spotlight(frame, r, g, b, a)
  local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 2)
  tex:SetTexture(T.TEX.glow)
  tex:SetVertexColor(r or 0.30, g or 0.40, b or 0.46, 1)
  tex:SetAlpha(a or 0.4)
  tex:SetPoint("TOPLEFT", frame, "TOPLEFT", -40, 40)
  tex:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 40, -40)
  tex:SetBlendMode("ADD")
  return tex
end

function T.Chip(parent, height)
  local f = T.Panel(parent, "pill")
  f:SetHeight(height or 24)
  f.label = T.Text(f, 11, T.C.muted)
  f.label:SetPoint("LEFT", 9, 0)
  f.value = T.Number(f, 13, T.C.text)
  f.value:SetPoint("LEFT", f.label, "RIGHT", 5, 0)
  function f:Set(label, value, labelColor, valueColor)
    self.label:SetText(label)
    self.value:SetText(value)
    local lc = labelColor or T.C.muted
    local vc = valueColor or T.C.text
    self.label:SetTextColor(lc[1], lc[2], lc[3])
    self.value:SetTextColor(vc[1], vc[2], vc[3])
    local w = (self.label:GetStringWidth() or 30) + (self.value:GetStringWidth() or 20) + 24
    self:SetWidth(math.max(44, math.floor(w)))
  end
  return f
end

function T.Inset(parent, opts)
  return CreateFrame(opts and opts.frameType or "Frame", opts and opts.name, parent, "InsetFrameTemplate")
end

function T.SetHighlighted(button, on)
  if on then button:LockHighlight() else button:UnlockHighlight() end
end

function T.CreateButton(parent, text, width, height, style, fontSize)
  local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  b:SetSize(width or 120, height or 24)
  b:SetText(text or "")
  local fs = b.GetFontString and b:GetFontString()
  if type(fs) == "table" and fs.SetFont then
    fs:SetFont(T.FONT, fontSize or 12, "")
    if style == "primary" then fs:SetTextColor(T.RGB(T.C.gold)) end
  end
  b.SetHighlighted = T.SetHighlighted
  return b
end

function T.IconButton(parent, size, texture, opts)
  opts = opts or {}
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(size, size)
  b.bg = b:CreateTexture(nil, "BACKGROUND")
  b.bg:SetTexture(T.TEX.circle)
  b.bg:SetAllPoints()
  b.bg:SetVertexColor(rgb(T.C.bg3))
  b.bg:SetAlpha(0)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetTexture(texture)
  local inset = opts.inset or math.floor(size * 0.22)
  b.icon:SetPoint("TOPLEFT", inset, -inset)
  b.icon:SetPoint("BOTTOMRIGHT", -inset, inset)
  if opts.coords then b.icon:SetTexCoord(unpack(opts.coords)) end
  b.icon:SetVertexColor(rgb(opts.color or T.C.muted))
  b:SetScript("OnEnter", function(self)
    self.bg:SetAlpha(1)
    self.icon:SetVertexColor(rgb(opts.hoverColor or T.C.text))
    if opts.tooltip then
      GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
      GameTooltip:SetText(opts.tooltip, 1, 1, 1)
      GameTooltip:Show()
    end
  end)
  b:SetScript("OnLeave", function(self)
    self.bg:SetAlpha(0)
    self.icon:SetVertexColor(rgb(opts.color or T.C.muted))
    if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
  end)
  b:HookScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) end)
  return b
end

function T.CreateTab(parent, text)
  local b = CreateFrame("Button", nil, parent, "PanelTopTabButtonTemplate")
  b:SetText(text or "")
  if PanelTemplates_TabResize then pcall(PanelTemplates_TabResize, b, 12) end
  function b:SetActive(active)
    self.active = active
    if active then
      if PanelTemplates_SelectTab then pcall(PanelTemplates_SelectTab, self) end
    else
      if PanelTemplates_DeselectTab then pcall(PanelTemplates_DeselectTab, self) end
    end
  end
  function b:SetHighlighted(on) self:SetActive(on) end
  b:SetActive(false)
  return b
end

function T.CreateItemGlyph(parent, cellSize)
  local glyph = CreateFrame("Frame", nil, parent)
  glyph.cells = {}
  glyph.effectCells = {}
  glyph.cellSize = cellSize or 8
  function glyph:SetItem(def, rotation)
    for _, texture in ipairs(self.cells) do texture:Hide() end
    for _, texture in ipairs(self.effectCells) do texture:Hide() end
    self.def, self.rotation = def, rotation or 0
    if not def then self.geometry = nil self:SetSize(1, 1) return end
    local geometry = ns.UI.GridView.GlyphGeometry(def, self.rotation)
    self.geometry = geometry
    local shape = geometry.shape
    local cell = self.cellSize
    if self.maxWidth then cell = math.min(cell, math.max(1, math.floor(self.maxWidth / geometry.w))) end
    if self.maxHeight then cell = math.min(cell, math.max(1, math.floor(self.maxHeight / geometry.h))) end
    self.drawCellSize = cell
    local r, g, b = T.QualityColor(def.quality)
    self:SetSize(geometry.w * cell, geometry.h * cell)
    for i, position in ipairs(geometry.effects) do
      local texture = self.effectCells[i]
      if not texture then
        texture = self:CreateTexture(nil, "ARTWORK", nil, -1)
        texture:SetTexture(T.TEX.white)
        self.effectCells[i] = texture
      end
      texture:SetSize(math.max(1, cell - 1), math.max(1, cell - 1))
      texture:ClearAllPoints()
      texture:SetPoint("TOPLEFT", self, "TOPLEFT", (position[1] - geometry.minX) * cell, -(position[2] - geometry.minY) * cell)
      texture:SetVertexColor(0.3, 0.7, 1, 0.7)
      texture:Show()
    end
    for i, position in ipairs(shape.cells) do
      local texture = self.cells[i]
      if not texture then
        texture = self:CreateTexture(nil, "ARTWORK")
        texture:SetTexture(T.TEX.panelSmall)
        self.cells[i] = texture
      end
      texture:SetSize(math.max(1, cell - 1), math.max(1, cell - 1))
      texture:ClearAllPoints()
      texture:SetPoint("TOPLEFT", self, "TOPLEFT", (position[1] - geometry.minX) * cell, -(position[2] - geometry.minY) * cell)
      texture:SetVertexColor(r, g, b, 0.85)
      texture:Show()
    end
  end
  return glyph
end

function T.CreateSlot(parent, size)
  local b = CreateFrame("Button", nil, parent)
  b:SetSize(size, size)
  b.slot = b:CreateTexture(nil, "BACKGROUND", nil, 1)
  b.slot:SetTexture(T.TEX.emptySlot)
  b.slot:SetAllPoints()
  b.frameTex = b:CreateTexture(nil, "BACKGROUND", nil, 2)
  b.frameTex:SetTexture(T.TEX.slotFrame)
  b.frameTex:SetSize(size * 64 / 37, size * 64 / 37)
  b.frameTex:SetPoint("CENTER", b, "CENTER", 0, -size / 37)
  b.icon = b:CreateTexture(nil, "ARTWORK")
  b.icon:SetPoint("TOPLEFT", 1, -1)
  b.icon:SetPoint("BOTTOMRIGHT", -1, 1)
  b.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
  b.border = T.NineSlice(b, T.TEX.borderSmall, math.max(5, math.floor(size / 5)), "OVERLAY", 0)
  b.border:HideCenter()
  b.border:SetAlpha(0)
  b.glow = T.CreateGlow(b, 6, 1, 1, 1, 0)
  b:SetScript("OnEnter", function(self) self.glow:SetAlpha(0.35) end)
  b:SetScript("OnLeave", function(self) self.glow:SetAlpha(0) end)
  function b:SetQuality(quality)
    if quality then
      local r, g, bb = T.QualityColor(quality)
      self.border:SetColor(r, g, bb, 1)
      self.border:SetAlpha(1)
    else
      self.border:SetAlpha(0)
    end
  end
  return b
end

function T.CreateBar(parent, width, height, r, g, b, reverse)
  local bar = CreateFrame("Frame", nil, parent)
  bar:SetSize(width, height)
  local corner = math.min(8, math.floor(height / 2.2))
  bar.track = T.NineSlice(bar, T.TEX.panelSmall, corner, "BACKGROUND", 0)
  bar.track:SetColor(rgb(T.C.bg2))
  bar.edge = T.NineSlice(bar, T.TEX.outlineSmall, corner, "OVERLAY", 0)
  bar.edge:HideCenter()
  bar.edge:SetColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.9)
  local fillFrame = CreateFrame("Frame", nil, bar)
  if reverse then
    fillFrame:SetPoint("TOPRIGHT", -2, -2)
    fillFrame:SetPoint("BOTTOMRIGHT", -2, 2)
  else
    fillFrame:SetPoint("TOPLEFT", 2, -2)
    fillFrame:SetPoint("BOTTOMLEFT", 2, 2)
  end
  fillFrame:SetWidth(width - 4)
  bar.fillFrame = fillFrame
  bar.fill = T.NineSlice(fillFrame, T.TEX.glossSmall, math.max(2, corner - 2), "ARTWORK", 0)
  local absorb = bar:CreateTexture(nil, "ARTWORK", nil, 2)
  absorb:SetTexture(T.TEX.white)
  absorb:SetVertexColor(1, 1, 1, 0.3)
  if reverse then
    absorb:SetPoint("TOPRIGHT", fillFrame, "TOPLEFT")
    absorb:SetPoint("BOTTOMRIGHT", fillFrame, "BOTTOMLEFT")
  else
    absorb:SetPoint("TOPLEFT", fillFrame, "TOPRIGHT")
    absorb:SetPoint("BOTTOMLEFT", fillFrame, "BOTTOMRIGHT")
  end
  absorb:SetWidth(0.01)
  bar.absorb = absorb
  local textLayer = CreateFrame("Frame", nil, bar)
  textLayer:SetAllPoints()
  textLayer:SetFrameLevel(fillFrame:GetFrameLevel() + 2)
  bar.textLayer = textLayer
  local text = T.Number(textLayer, math.max(9, height - 6), T.C.text, nil, "OUTLINE")
  text:SetPoint("CENTER", bar, "CENTER", 0, 0)
  bar.text = text
  bar.value, bar.max, bar.shown = 1, 1, 1
  function bar:SetColor(cr, cg, cb)
    self.fill:SetColor(cr, cg, cb, 1)
  end
  function bar:SetValue(value, max, instant)
    self.value = value
    self.max = max or self.max
    if instant then self.shown = value self:Apply() end
  end
  function bar:Apply()
    local fraction = self.max > 0 and Util.Clamp(self.shown / self.max, 0, 1) or 0
    local inner = self:GetWidth() - 4
    self.fillFrame:SetWidth(math.max(0.01, inner * fraction))
    self.fillFrame:SetShown(fraction > 0.005)
  end
  function bar:SetAbsorb(amount)
    local fraction = self.max > 0 and Util.Clamp((amount or 0) / self.max, 0, 1) or 0
    local inner = self:GetWidth() - 4
    local remaining = inner - self.fillFrame:GetWidth()
    self.absorb:SetWidth(math.max(0.01, math.min(remaining, inner * fraction)))
  end
  bar:SetScript("OnUpdate", function(self, elapsed)
    if self.shown ~= self.value then
      local diff = self.value - self.shown
      if math.abs(diff) < 0.5 then self.shown = self.value else self.shown = self.shown + diff * math.min(1, elapsed * 12) end
      self:Apply()
    end
  end)
  bar:SetColor(r or 0.2, g or 0.8, b or 0.3)
  bar:Apply()
  return bar
end

function T.CreatePortrait(parent, size)
  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(size, size)
  f.shadow = f:CreateTexture(nil, "BACKGROUND", nil, -1)
  f.shadow:SetTexture(T.TEX.glow)
  f.shadow:SetVertexColor(0, 0, 0, 0.6)
  f.shadow:SetPoint("TOPLEFT", -6, 4)
  f.shadow:SetPoint("BOTTOMRIGHT", 6, -8)
  f.bgc = f:CreateTexture(nil, "BACKGROUND")
  f.bgc:SetTexture(T.TEX.circle)
  f.bgc:SetAllPoints()
  f.bgc:SetVertexColor(rgb(T.C.ink))
  f.icon = f:CreateTexture(nil, "ARTWORK")
  f.icon:SetPoint("TOPLEFT", 4, -4)
  f.icon:SetPoint("BOTTOMRIGHT", -4, 4)
  if f.CreateMaskTexture and f.icon.AddMaskTexture then
    local mask = f:CreateMaskTexture()
    mask:SetTexture(T.TEX.circle, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(f.icon)
    pcall(f.icon.AddMaskTexture, f.icon, mask)
    f.mask = mask
  end
  f.ring = f:CreateTexture(nil, "OVERLAY")
  f.ring:SetTexture(T.TEX.ring)
  f.ring:SetAllPoints()
  f.ring:SetVertexColor(rgb(T.C.line))
  function f:SetClass(classKey)
    T.SetClassIcon(self.icon, classKey)
    local r, g, b = T.ClassColor(classKey)
    self.ring:SetVertexColor(r, g, b, 1)
  end
  function f:SetRingColor(r, g, b, a) self.ring:SetVertexColor(r, g, b, a or 1) end
  return f
end

function T.Pips(parent, count, texture, size, gap, onColor, offColor)
  local f = CreateFrame("Frame", nil, parent)
  f:SetSize(count * (size + gap) - gap, size)
  f.pips = {}
  for i = 1, count do
    local tex = f:CreateTexture(nil, "ARTWORK")
    tex:SetTexture(texture)
    tex:SetSize(size, size)
    tex:SetPoint("LEFT", f, "LEFT", (i - 1) * (size + gap), 0)
    f.pips[i] = tex
  end
  function f:SetFilled(n)
    for i, tex in ipairs(self.pips) do
      if i <= n then tex:SetVertexColor(rgb(onColor)) tex:SetAlpha(1)
      else tex:SetVertexColor(rgb(offColor or T.C.dim)) tex:SetAlpha(0.55) end
    end
  end
  f:SetFilled(0)
  return f
end

function T.CreateCheck(parent, label, onChange)
  local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
  cb:SetSize(24, 24)
  local text = T.Font(cb, "GameFontHighlightSmall", label)
  text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
  cb.label = text
  cb:SetScript("OnClick", function(self)
    if onChange then onChange(self:GetChecked() and true or false) end
    T.PlaySound(T.SOUND_CLICK)
  end)
  return cb
end

local function scaleAnim(group, from, to, duration, order, smoothing)
  local s = group:CreateAnimation("Scale")
  if s.SetScaleFrom then
    s:SetScaleFrom(from, from)
    s:SetScaleTo(to, to)
  elseif s.SetScale then
    s:SetScale(to / from, to / from)
  end
  if s.SetOrigin then s:SetOrigin("CENTER", 0, 0) end
  s:SetDuration(duration)
  if order then s:SetOrder(order) end
  if smoothing and s.SetSmoothing then s:SetSmoothing(smoothing) end
  return s
end

local function alphaAnim(group, from, to, duration, order, smoothing)
  local a = group:CreateAnimation("Alpha")
  if a.SetFromAlpha then
    a:SetFromAlpha(from)
    a:SetToAlpha(to)
  elseif a.SetChange then
    a:SetChange(to - from)
  end
  a:SetDuration(duration)
  if order then a:SetOrder(order) end
  if smoothing and a.SetSmoothing then a:SetSmoothing(smoothing) end
  return a
end

function T.FadeIn(frame, duration)
  frame:Show()
  if not frame.bbFadeIn then
    local g = frame:CreateAnimationGroup()
    alphaAnim(g, 0, 1, duration or 0.2, 1, "OUT")
    frame.bbFadeIn = g
  end
  frame.bbFadeIn:Stop()
  frame.bbFadeIn:Play()
end

function T.Pop(frame, from, duration)
  if not frame.bbPop then
    local g = frame:CreateAnimationGroup()
    scaleAnim(g, from or 1.18, 1, duration or 0.18, 1, "OUT")
    frame.bbPop = g
  end
  frame.bbPop:Stop()
  frame.bbPop:Play()
end

function T.Bounce(frame, duration)
  if not frame.bbBounce then
    local g = frame:CreateAnimationGroup()
    scaleAnim(g, 0.7, 1.06, (duration or 0.3) * 0.7, 1, "OUT")
    scaleAnim(g, 1.06, 1, (duration or 0.3) * 0.3, 2, "IN_OUT")
    alphaAnim(g, 0, 1, (duration or 0.3) * 0.5, 1)
    frame.bbBounce = g
  end
  frame:Show()
  frame.bbBounce:Stop()
  frame.bbBounce:Play()
end

function T.Pulse(region, lo, hi, duration)
  if not region.bbPulse then
    local g = region:CreateAnimationGroup()
    alphaAnim(g, lo or 0.3, hi or 1, duration or 0.8, 1, "IN_OUT")
    g:SetLooping("BOUNCE")
    region.bbPulse = g
  end
  region.bbPulse:Play()
end

function T.StopPulse(region)
  if region.bbPulse then region.bbPulse:Stop() end
end

function T.Flash(region, duration)
  region:SetAlpha(1)
  if not region.bbFlash then
    local g = region:CreateAnimationGroup()
    alphaAnim(g, 1, 0, duration or 0.4, 1, "OUT")
    g:SetScript("OnFinished", function() region:SetAlpha(0) end)
    region.bbFlash = g
  end
  region.bbFlash:Stop()
  region.bbFlash:Play()
end

function T.Shake(frame, strength)
  if not frame.bbShake then
    local g = frame:CreateAnimationGroup()
    for i = 1, 4 do
      local tr = g:CreateAnimation("Translation")
      tr:SetOffset((i % 2 == 0 and 1 or -1) * (strength or 4), 0)
      tr:SetDuration(0.04)
      tr:SetOrder(i)
    end
    frame.bbShake = g
  end
  frame.bbShake:Stop()
  frame.bbShake:Play()
end

local burstPool = {}
function T.Burst(parent, anchorFrame, r, g, b, size)
  local burst
  for _, f in ipairs(burstPool) do
    if not f.active and f:GetParent() == parent then burst = f break end
  end
  if not burst then
    burst = CreateFrame("Frame", nil, parent)
    burst:SetFrameLevel(parent:GetFrameLevel() + 30)
    burst.tex = burst:CreateTexture(nil, "OVERLAY")
    burst.tex:SetTexture(T.TEX.burst)
    burst.tex:SetAllPoints()
    burst.tex:SetBlendMode("ADD")
    local ag = burst:CreateAnimationGroup()
    scaleAnim(ag, 0.4, 1.5, 0.35, 1, "OUT")
    alphaAnim(ag, 1, 0, 0.35, 1, "IN")
    ag:SetScript("OnFinished", function() burst.active = false burst:Hide() end)
    burst.ag = ag
    burstPool[#burstPool + 1] = burst
  end
  burst.active = true
  burst:SetSize(size or 48, size or 48)
  burst:ClearAllPoints()
  local cx, cy = anchorFrame:GetCenter()
  local px, py = parent:GetLeft(), parent:GetBottom()
  if cx and px then
    burst:SetPoint("CENTER", parent, "BOTTOMLEFT", cx - px, cy - py)
  else
    burst:SetPoint("CENTER", anchorFrame, "CENTER", 0, 0)
  end
  burst.tex:SetVertexColor(r or 1, g or 0.9, b or 0.5, 1)
  burst:Show()
  burst.ag:Stop()
  burst.ag:Play()
end

function T.Error(msg)
  if UIErrorsFrame then UIErrorsFrame:AddMessage(msg, 1, 0.2, 0.2, 1) else ns.Print(msg) end
end

function T.PlaySound(id)
  local s = settings()
  if s.sounds == false or not id then return end
  if PlaySound then
    local ok, played, handle = pcall(PlaySound, id, s.soundChannel or "SFX")
    if ok and played then return handle end
  end
end

function T.StopSound(handle)
  if handle and StopSound then pcall(StopSound, handle, 100) end
end

T.COMBAT_CLIPS = {
  defeat = { file = MEDIA .. "Audio\\defeat.wav", duration = 2.706 },
  mortalStrike = { file = MEDIA .. "Audio\\mortal_strike.wav", duration = 1.01 },
  execute = { file = MEDIA .. "Audio\\classic_warrior_finisher.wav", duration = 0.718 },
  shieldSlam = { file = MEDIA .. "Audio\\shield_slam.wav", duration = 1.01 },
  aimedShot = { file = MEDIA .. "Audio\\aimed_shot.wav", duration = 1.79 },
  bestialWrath = { file = MEDIA .. "Audio\\classic_bestial_wrath.wav", duration = 1.426 },
  starfire = { file = MEDIA .. "Audio\\starfire.wav", duration = 2.36 },
  ferociousBite = { file = MEDIA .. "Audio\\ferocious_bite.wav", duration = 1.90 },
  swiftmend = { file = MEDIA .. "Audio\\swiftmend.wav", duration = 2.42 },
  classicBearAuto = { file = MEDIA .. "Audio\\classic_bear_auto.wav", duration = 0.778 },
  classicCatAuto = { file = MEDIA .. "Audio\\classic_cat_auto.wav", duration = 0.744 },
  classicMaul = { file = MEDIA .. "Audio\\classic_maul.wav", duration = 0.952 },
  classicCatStrike = { file = MEDIA .. "Audio\\classic_cat_strike.wav", duration = 0.744 },
  classicFeralSwipe = { file = MEDIA .. "Audio\\classic_feral_swipe.wav", duration = 0.718 },
  classicWrath = { file = MEDIA .. "Audio\\classic_wrath.wav", duration = 3.515 },
  classicNatureHeal = { file = MEDIA .. "Audio\\classic_nature_heal.wav", duration = 2.415 },
  classicRaptorStrike = { file = MEDIA .. "Audio\\classic_raptor_strike.wav", duration = 1.000 },
  classicPummel = { file = MEDIA .. "Audio\\classic_pummel.wav", duration = 1.514 },
  classicShoutDebuff = { file = MEDIA .. "Audio\\classic_shout_debuff.wav", duration = 2.136 },
  quiet567879 = { file = MEDIA .. "Audio\\quiet_567879.wav", duration = 1.007 },
  quiet568003 = { file = MEDIA .. "Audio\\quiet_568003.wav", duration = 0.718 },
  quiet568028 = { file = MEDIA .. "Audio\\quiet_568028.wav", duration = 1.500 },
  quiet568208 = { file = MEDIA .. "Audio\\quiet_568208.wav", duration = 4.000 },
  quiet568227 = { file = MEDIA .. "Audio\\quiet_568227.wav", duration = 1.500 },
  quiet568316 = { file = MEDIA .. "Audio\\quiet_568316.wav", duration = 4.001 },
  quiet568461 = { file = MEDIA .. "Audio\\quiet_568461.wav", duration = 1.983 },
  quiet568510 = { file = MEDIA .. "Audio\\quiet_568510.wav", duration = 1.202 },
  quiet568519 = { file = MEDIA .. "Audio\\quiet_568519.wav", duration = 2.148 },
  quiet568524 = { file = MEDIA .. "Audio\\quiet_568524.wav", duration = 1.514 },
  quiet568555 = { file = MEDIA .. "Audio\\quiet_568555.wav", duration = 3.000 },
  quiet568994 = { file = MEDIA .. "Audio\\quiet_568994.wav", duration = 1.231 },
  quiet569022 = { file = MEDIA .. "Audio\\quiet_569022.wav", duration = 1.334 },
  quiet569023 = { file = MEDIA .. "Audio\\quiet_569023.wav", duration = 3.000 },
  quiet569098 = { file = MEDIA .. "Audio\\quiet_569098.wav", duration = 1.000 },
  quiet569153 = { file = MEDIA .. "Audio\\quiet_569153.wav", duration = 2.442 },
  quiet569222 = { file = MEDIA .. "Audio\\quiet_569222.wav", duration = 1.424 },
  quiet569254 = { file = MEDIA .. "Audio\\quiet_569254.wav", duration = 1.994 },
  quiet569429 = { file = MEDIA .. "Audio\\quiet_569429.wav", duration = 2.486 },
  quiet569473 = { file = MEDIA .. "Audio\\quiet_569473.wav", duration = 1.500 },
  quiet569491 = { file = MEDIA .. "Audio\\quiet_569491.wav", duration = 2.408 },
  quiet569565 = { file = MEDIA .. "Audio\\quiet_569565.wav", duration = 1.650 },
  quiet569570 = { file = MEDIA .. "Audio\\quiet_569570.wav", duration = 1.994 },
  quiet569594 = { file = MEDIA .. "Audio\\quiet_569594.wav", duration = 4.301 },
  quiet569632 = { file = MEDIA .. "Audio\\quiet_569632.wav", duration = 3.555 },
  quiet569767 = { file = MEDIA .. "Audio\\quiet_569767.wav", duration = 0.661 },
  quiet569828 = { file = MEDIA .. "Audio\\quiet_569828.wav", duration = 0.636 },
}

T.MAJOR_ABILITY_CLIPS = {
  mortal_strike = "mortalStrike",
  execute = "execute",
  bloodthirst = "execute",
  shield_slam = "shieldSlam",
  aimed_shot = "aimedShot",
  bestial_wrath = "bestialWrath",
  starfire = "starfire",
  ferocious_bite = "ferociousBite",
  swiftmend = "swiftmend",
}

T.PROC_ABILITY_CLIPS = {
  leader_of_the_pack = "quiet568524",
  omen_of_clarity = "quiet569767",
}

T.REGULAR_ABILITY_CLIPS = {
  abolish_poison = "quiet569632",
  arcane_shot = "quiet569565",
  battle_shout = "quiet568028",
  bear_form = "classicBearAuto",
  berserker_rage = "quiet568524",
  bite = "quiet569098",
  cat_form = "classicCatAuto",
  claw = "classicCatStrike",
  claw_pet = "classicFeralSwipe",
  cleave = "quiet568227",
  concussion_blow = "quiet567879",
  concussive_shot = "quiet569565",
  demoralizing_shout = "classicShoutDebuff",
  disarm = "quiet568994",
  enrage = "quiet568524",
  explosive_trap = "quiet568461",
  faerie_fire = "quiet569254",
  freezing_trap = "quiet568316",
  hamstring = "quiet568003",
  healing_touch = "classicNatureHeal",
  heroic_strike = "quiet569098",
  hurricane = "quiet568555",
  immolation_trap = "quiet569153",
  innervate = "classicNatureHeal",
  insect_swarm = "quiet569767",
  maul = "classicMaul",
  bash = "classicMaul",
  mend_pet = "quiet569570",
  moonfire = "quiet569023",
  multi_shot = "quiet569491",
  overpower = "quiet569098",
  piercing_howl = "classicShoutDebuff",
  pummel = "classicPummel",
  rake = "classicCatStrike",
  raptor_strike = "classicRaptorStrike",
  recklessness = "quiet569491",
  regrowth = "classicNatureHeal",
  rejuvenation = "quiet569594",
  rend = "quiet568003",
  retaliation = "quiet568994",
  revenge = "quiet569098",
  rip = "classicFeralSwipe",
  screech = "quiet569429",
  serpent_sting = "quiet568208",
  shield_bash = "quiet567879",
  shield_block = "quiet569473",
  shield_wall = "quiet568510",
  shred = "classicCatStrike",
  slam = "quiet569828",
  sunder_armor = "quiet569491",
  swipe = "classicFeralSwipe",
  thorns = "quiet569022",
  thunder_clap = "quiet569222",
  volley = "quiet569565",
  whirlwind = "quiet568519",
  wrath = "classicWrath",
}

function T.PlayCombatSound(key)
  local clip = T.COMBAT_CLIPS[key]
  local s = settings()
  if not clip or s.sounds == false or not PlaySoundFile then return end
  local ok, played, handle = pcall(PlaySoundFile, clip.file, s.soundChannel or "SFX")
  if ok and played then return handle, clip.duration end
end

function T.PlayResultSound(winner)
  if winner == "A" then return T.PlaySound(T.SOUND_VICTORY) end
  if winner == "B" then return T.PlaySound(T.SOUND_DEFEAT) or T.PlayCombatSound("defeat") end
end

T.SOUND_OPEN = 862
T.SOUND_CLOSE = 863
T.SOUND_BUY = 895
T.SOUND_SELL = 120
T.SOUND_PICKUP = 1186
T.SOUND_DROP = 1187
T.SOUND_VICTORY = 888
T.SOUND_DEFEAT = 846
T.SOUND_CLICK = 856
T.SOUND_LOOT = 1194
T.SOUND_SEARCH = 8458
T.SOUND_OPPONENT = 8459
T.SOUND_COUNTDOWN = 25477
T.SOUND_FIGHT = 25478
T.SOUND_TRAIN = 1455
