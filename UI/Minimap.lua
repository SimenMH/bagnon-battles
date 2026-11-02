local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Minimap = {}
ns.UI.Minimap = Minimap

local button

local function settings()
  return ns.db.global.settings.minimap
end

local function updatePosition()
  local angle = math.rad(settings().angle or 220)
  local x, y = math.cos(angle), math.sin(angle)
  local width = math.max(1, _G.Minimap:GetWidth()) / 2 + 5
  local height = math.max(1, _G.Minimap:GetHeight()) / 2 + 5
  local square = GetMinimapShape and GetMinimapShape() == "SQUARE"
  local distance
  if square then
    distance = 1 / math.max(math.abs(x) / width, math.abs(y) / height)
  else
    distance = 1 / math.sqrt((x / width) ^ 2 + (y / height) ^ 2)
  end
  button:ClearAllPoints()
  button:SetPoint("CENTER", _G.Minimap, "CENTER", x * distance, y * distance)
end

local function onDragUpdate()
  local mx, my = _G.Minimap:GetCenter()
  local cx, cy = GetCursorPosition()
  local scale = _G.Minimap:GetEffectiveScale()
  if not mx or not my or not cx or not cy or not scale or scale <= 0 then return end
  cx, cy = cx / scale, cy / scale
  if cx == mx and cy == my then return end
  settings().angle = math.deg(math.atan2(cy - my, cx - mx))
  updatePosition()
end

function Minimap.Init()
  if button or not _G.Minimap then return end
  button = CreateFrame("Button", "BagnonBattlesMinimapButton", _G.Minimap)
  button:SetSize(32, 32)
  button:SetFrameStrata("MEDIUM")
  button:SetFrameLevel(8)
  button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
  button:RegisterForDrag("LeftButton")
  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

  local bg = button:CreateTexture(nil, "BACKGROUND")
  bg:SetTexture(T.TEX.minimapBg)
  bg:SetSize(24, 24)
  bg:SetPoint("CENTER", 0, 1)
  local icon = button:CreateTexture(nil, "ARTWORK")
  icon:SetTexture(T.TEX.logo)
  icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  icon:SetSize(19, 19)
  icon:SetPoint("CENTER", 0, 1)
  local border = button:CreateTexture(nil, "OVERLAY")
  border:SetTexture(T.TEX.minimapBorder)
  border:SetSize(54, 54)
  border:SetPoint("TOPLEFT")

  button:SetScript("OnClick", function(_, mouseButton)
    if mouseButton == "RightButton" then
      ns.UI.Options.Open()
    else
      ns.UI.Main.Toggle()
    end
  end)
  button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", onDragUpdate)
  end)
  button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
  end)
  button:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil)
    if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine(L["Bagnon Battles"], 1, 0.82, 0)
    if ns.run and not ns.run:IsOver() then
      GameTooltip:AddLine(string.format("%s  %s  %d-%d", ns.Classes[ns.run.class].name, string.format(L["Round %d"], ns.run.round), ns.run.wins, ns.run.losses), 1, 1, 1)
    end
    GameTooltip:AddLine(L["Left-click to open. Right-click for options. Drag to move."], 0.7, 0.7, 0.7)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function() GameTooltip:Hide() end)
  _G.Minimap:HookScript("OnSizeChanged", updatePosition)
  _G.Minimap:HookScript("OnShow", updatePosition)
  Minimap.Refresh()
end

function Minimap.Refresh()
  if not button then return end
  updatePosition()
  if settings().hide then button:Hide() else button:Show() end
end
