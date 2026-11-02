local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Main = {}
ns.UI.Main = Main

Main.WIDTH = 1000
Main.HEIGHT = 820
Main.TOP_H = 60
Main.PAD = 10
Main.CONTENT_W = Main.WIDTH - Main.PAD * 2

Main.screens = {}
Main.current = nil

local function hasActiveRun()
  return ns.run ~= nil and not ns.run:IsOver()
end

local function validScreen(name)
  if name == "shop" and not hasActiveRun() then return "home" end
  if name == "battle" and (ns.run == nil or ns.UI.Battle.CurrentRun() ~= ns.run) then return "home" end
  return name
end

local function battleLocked()
  return Main.current == "battle" and validScreen("battle") == "battle"
end

local function build()
  if Main.frame then return Main.frame end
  local f = CreateFrame("Frame", "BagnonBattlesFrame", UIParent, "PortraitFrameTemplate")
  f:SetSize(Main.WIDTH, Main.HEIGHT)
  f:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
  f:SetFrameStrata("HIGH")
  f:SetToplevel(true)
  f:SetClampedToScreen(true)
  f:SetMovable(true)
  f:EnableMouse(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()
  tinsert(UISpecialFrames, "BagnonBattlesFrame")

  if type(f.SetTitle) == "function" then
    pcall(f.SetTitle, f, L["Bagnon Battles"])
  elseif type(f.TitleContainer) == "table" and f.TitleContainer.TitleText then
    f.TitleContainer.TitleText:SetText(L["Bagnon Battles"])
  end
  if type(f.PortraitContainer) == "table" and f.PortraitContainer.portrait and SetPortraitToTexture then
    pcall(SetPortraitToTexture, f.PortraitContainer.portrait, T.TEX.logo)
  end
  if type(f.CloseButton) == "table" then
    f.CloseButton:SetScript("OnClick", function() Main.Hide() end)
  end

  local options = T.IconButton(f, 24, T.TEX.gear, { inset = 3, tooltip = L["Options"] })
  options:SetPoint("TOPRIGHT", f, "TOPRIGHT", -32, -2)
  options:SetScript("OnClick", function() ns.UI.Options.Open() end)

  local content = CreateFrame("Frame", nil, f)
  content:SetPoint("TOPLEFT", Main.PAD, -Main.TOP_H)
  content:SetPoint("BOTTOMRIGHT", -Main.PAD, Main.PAD)
  f.content = content

  local homeTab = T.CreateTab(f, L["Camp"])
  homeTab:SetPoint("BOTTOMLEFT", content, "TOPLEFT", 52, -3)
  homeTab:SetScript("OnClick", function()
    if battleLocked() then return end
    Main.ShowScreen("home")
    T.PlaySound(T.SOUND_CLICK)
  end)
  f.homeButton = homeTab
  local bagTab = T.CreateTab(f, L["Bag"])
  bagTab:SetPoint("LEFT", homeTab, "RIGHT", 4, 0)
  bagTab:SetScript("OnClick", function()
    if battleLocked() then return end
    if hasActiveRun() then Main.ShowScreen("shop") end
    T.PlaySound(T.SOUND_CLICK)
  end)
  f.bagButton = bagTab
  local battleTab = T.CreateTab(f, L["Battle"])
  battleTab:SetPoint("LEFT", bagTab, "RIGHT", 4, 0)
  battleTab:Hide()
  f.battleTab = battleTab

  Main.screens.home = ns.UI.Home.Create(content)
  Main.screens.shop = ns.UI.Shop.Create(content)
  Main.screens.battle = ns.UI.Battle.Create(content)
  for _, s in pairs(Main.screens) do s:Hide() end

  f:EnableKeyboard(false)
  f:SetScript("OnKeyDown", function(self, key)
    local handled = false
    if Main.current == "shop" and ns.UI.Shop.OnKey then handled = ns.UI.Shop.OnKey(key) end
    if not InCombatLockdown() then self:SetPropagateKeyboardInput(not handled) end
  end)
  f:SetScript("OnShow", function(self)
    if not InCombatLockdown() then
      self:EnableKeyboard(true)
      self:SetPropagateKeyboardInput(true)
    end
    T.PlaySound(T.SOUND_OPEN)
  end)
  f:SetScript("OnHide", function(self)
    ns.UI.Dialogs.HideSurvival()
    self:EnableKeyboard(false)
    T.PlaySound(T.SOUND_CLOSE)
  end)

  Main.frame = f
  Main.ApplyScale()
  return f
end

function Main.ApplyScale()
  if Main.frame and ns.db then
    Main.frame:SetScale(ns.db.global.settings.scale or 1)
  end
end

function Main.SetAccent(classKey)
  if not Main.frame then return end
  local f = Main.frame
  if type(f.PortraitContainer) == "table" and f.PortraitContainer.portrait then
    if classKey then
      T.SetClassIcon(f.PortraitContainer.portrait, classKey)
    elseif SetPortraitToTexture then
      pcall(SetPortraitToTexture, f.PortraitContainer.portrait, T.TEX.logo)
    end
  end
end

function Main.ShowScreen(name)
  build()
  name = validScreen(name)
  for key, s in pairs(Main.screens) do
    if key == name then
      if not s:IsShown() then T.FadeIn(s, 0.15) else s:Show() end
    else
      s:Hide()
    end
  end
  Main.current = name
  local hasRun = hasActiveRun()
  local f = Main.frame
  f.bagButton:SetShown(hasRun)
  f.battleTab:SetShown(name == "battle")
  f.homeButton:SetActive(name == "home")
  f.bagButton:SetActive(name == "shop")
  f.battleTab:SetActive(name == "battle")
  if hasRun then Main.SetAccent(ns.run.class) else Main.SetAccent(nil) end
  if name == "home" then ns.UI.Home.Refresh() end
  if name == "shop" then ns.UI.Shop.RefreshAll() end
  if name ~= "battle" then Main.ShowSurvivalChoice() end
end

function Main.ShowSurvivalChoice()
  local run = ns.run
  if not run or not run:NeedsSurvivalChoice() then ns.UI.Dialogs.HideSurvival() return false end
  if run.phase == "result" then ns.Addon:NextRound() end
  if run.phase ~= "survival" then return false end
  return ns.UI.Dialogs.ShowSurvival(Main.frame, run, function(continue)
    if ns.run ~= run then ns.UI.Dialogs.HideSurvival() return end
    local ok, finished = ns.Addon:ChooseSurvival(continue)
    if not ok then T.Error(finished) return end
    ns.UI.Dialogs.HideSurvival()
    if finished then
      Main.ShowScreen("home")
      ns.UI.Home.ShowRunOver(run)
    else
      Main.ShowScreen("shop")
    end
  end)
end

function Main.Show()
  if InCombatLockdown() then
    ns.Print(L["Wait until combat ends."])
    return
  end
  build()
  local name = Main.current and validScreen(Main.current) or (hasActiveRun() and "shop" or "home")
  if name ~= Main.current then Main.ShowScreen(name) end
  T.FadeIn(Main.frame, 0.2)
  if Main.current ~= "battle" then Main.ShowSurvivalChoice() end
end

function Main.Hide()
  if Main.frame then Main.frame:Hide() end
end

function Main.Toggle()
  if Main.frame and Main.frame:IsShown() then Main.Hide() else Main.Show() end
end

function Main.OnPoolChanged()
  if Main.frame and Main.frame:IsShown() and Main.current == "home" then ns.UI.Home.Refresh() end
end
