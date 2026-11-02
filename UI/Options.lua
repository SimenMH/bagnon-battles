local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Options = {}
ns.UI.Options = Options

local panel
local category

local function settings()
  return ns.db.global.settings
end

local function createPanel()
  if panel then return panel end
  panel = CreateFrame("Frame")
  panel.name = L["Bagnon Battles"]

  local title = T.Font(panel, "GameFontNormalLarge", L["Bagnon Battles"])
  title:SetPoint("TOPLEFT", 16, -16)
  local version = T.Font(panel, "GameFontDisableSmall", string.format(L["Version %s"], ns.VERSION))
  version:SetPoint("LEFT", title, "RIGHT", 8, 0)
  local desc = T.Font(panel, "GameFontHighlightSmall", L["Open with /bb or the minimap button."])
  desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)

  local share = T.CreateCheck(panel, L["Share builds with other players"], function(checked)
    ns.Comm.SetSharing(checked)
  end)
  share:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", -4, -16)
  panel.share = share

  local minimap = T.CreateCheck(panel, L["Show minimap button"], function(checked)
    settings().minimap.hide = not checked
    ns.UI.Minimap.Refresh()
  end)
  minimap:SetPoint("TOPLEFT", share, "BOTTOMLEFT", 0, -8)
  panel.minimap = minimap

  local sounds = T.CreateCheck(panel, L["Play sound effects"], function(checked)
    settings().sounds = checked
    if not checked and ns.UI.Battle and ns.UI.Battle.StopSounds then ns.UI.Battle.StopSounds() end
  end)
  sounds:SetPoint("TOPLEFT", minimap, "BOTTOMLEFT", 0, -8)
  panel.sounds = sounds

  local speedLabel = T.Font(panel, "GameFontNormal", L["Default battle speed"])
  speedLabel:SetPoint("TOPLEFT", sounds, "BOTTOMLEFT", 4, -20)
  panel.speedButtons = {}
  for i, s in ipairs({ 1, 2, 4 }) do
    local b = T.CreateButton(panel, s .. "x", 50, 22)
    b:SetPoint("TOPLEFT", speedLabel, "BOTTOMLEFT", (i - 1) * 56, -6)
    b.speed = s
    b:SetScript("OnClick", function()
      settings().speed = s
      Options.Refresh()
      T.PlaySound(T.SOUND_CLICK)
    end)
    panel.speedButtons[i] = b
  end

  local scaleLabel = T.Font(panel, "GameFontNormal", L["Window size"])
  scaleLabel:SetPoint("TOPLEFT", speedLabel, "BOTTOMLEFT", 0, -50)
  local slider = CreateFrame("Slider", "BagnonBattlesScaleSlider", panel, "OptionsSliderTemplate")
  slider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -16)
  slider:SetWidth(200)
  slider:SetMinMaxValues(0.6, 1.4)
  slider:SetValueStep(0.05)
  slider:SetObeyStepOnDrag(true)
  local low, high, text = _G[slider:GetName() .. "Low"], _G[slider:GetName() .. "High"], _G[slider:GetName() .. "Text"]
  if low then low:SetText("60%") end
  if high then high:SetText("140%") end
  if text then text:SetText("100%") end
  slider:SetScript("OnValueChanged", function(self, value)
    value = math.floor(value * 20 + 0.5) / 20
    settings().scale = value
    if text then text:SetText(string.format("%d%%", value * 100)) end
    ns.UI.Main.ApplyScale()
  end)
  panel.slider = slider

  local poolLabel = T.Font(panel, "GameFontNormal", L["Saved builds"])
  poolLabel:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -30)
  local poolText = T.Font(panel, "GameFontHighlightSmall")
  poolText:SetPoint("TOPLEFT", poolLabel, "BOTTOMLEFT", 0, -6)
  poolText:SetJustifyH("LEFT")
  panel.poolText = poolText
  local clear = T.CreateButton(panel, L["Delete saved builds"], 160, 22)
  clear:SetPoint("TOPLEFT", poolText, "BOTTOMLEFT", 0, -10)
  clear:SetScript("OnClick", function()
    T.PlaySound(T.SOUND_CLICK)
    ns.UI.Dialogs.Confirm(L["Delete all saved builds? You'll face bots until new player builds arrive."], function()
      ns.Pool.Clear()
      Options.Refresh()
    end)
  end)

  panel:SetScript("OnShow", function() Options.Refresh() end)
  return panel
end

function Options.Refresh()
  if not panel or not ns.db then return end
  local s = settings()
  panel.share:SetChecked(s.share)
  panel.minimap:SetChecked(not s.minimap.hide)
  panel.sounds:SetChecked(s.sounds ~= false)
  for _, b in ipairs(panel.speedButtons) do
    if b.speed == (s.speed or 1) then b:SetNormalFontObject("GameFontHighlight") else b:SetNormalFontObject("GameFontNormal") end
  end
  panel.slider:SetValue(s.scale or 1)
  panel.poolText:SetText(string.format(L["Saved builds: %d. Players seen recently: %d."], ns.Pool.Count(), ns.Comm.PeerCount()))
end

function Options.Register()
  createPanel()
  if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
  elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
  end
end

function Options.Open()
  if not panel then Options.Register() end
  if Settings and Settings.OpenToCategory and category then
    Settings.OpenToCategory(category:GetID())
  elseif InterfaceOptionsFrame_OpenToCategory then
    InterfaceOptionsFrame_OpenToCategory(panel)
    InterfaceOptionsFrame_OpenToCategory(panel)
  end
end
