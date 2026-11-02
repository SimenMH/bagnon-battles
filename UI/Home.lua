local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Home = {}
ns.UI.Home = Home

local screen
local selectedClass

local function refreshStats()
  if not screen or not ns.db then return end
  local s = ns.db.global.stats
  local rows = {
    { L["Games played"], tostring(s.runs) },
    { L["Games won"], tostring(s.gamesWon or 0), T.C.good },
    { L["Current win streak"], tostring(s.currentWinStreak or 0) },
    { L["Best win streak"], tostring(s.bestWinStreak or 0) },
    { L["Legendaries forged"], tostring(s.forgedLegendaries or 0) },
  }
  for i, row in ipairs(screen.statRows) do
    local data = rows[i]
    if data then
      row:Show()
      row.label:SetText(data[1])
      row.value:SetText(data[2])
      local c = data[3] or T.C.text
      row.value:SetTextColor(c[1], c[2], c[3])
    else
      row:Hide()
    end
  end
end

local function refreshContinue()
  if not screen then return end
  local run = ns.run
  if run and not run:IsOver() then
    screen.continueCard:Show()
    screen.continuePortrait:SetClass(run.class)
    local round = run.survival and string.format(L["Survival %d / %d"], run.round, ns.Economy.ROUNDS) or string.format(L["Round %d"], run.round)
    screen.continueText:SetText(string.format("%s%s|r   %s", T.ClassHex(run.class), ns.Classes[run.class].name, round))
    screen.continueRecord:SetText(string.format("|cff5aff7a%d|r |cff6a6d78/|r |cffff6a6a%d|r", run.wins, run.losses))
  else
    screen.continueCard:Hide()
  end
end

local function selectClass(key)
  selectedClass = key
  for _, b in ipairs(screen.classButtons) do
    local def = ns.Classes[b.classKey]
    if b.classKey == key then
      b.portrait:SetRingColor(T.ClassColor(key))
      b.glow:SetAlpha(0.7)
      b.label:SetTextColor(T.RGB(T.C.text))
      T.Pop(b, 1.1, 0.2)
    else
      b.portrait:SetRingColor(T.RGB(T.C.line))
      b.glow:SetAlpha(0)
      if def.playable then b.label:SetTextColor(T.RGB(T.C.muted)) else b.label:SetTextColor(T.RGB(T.C.dim)) end
    end
  end
  local def = ns.Classes[key]
  screen.classTitle:SetText(def.name)
  screen.classTitle:SetTextColor(T.ClassColor(key))
  local specs = {}
  for _, spec in ipairs(def.specs) do specs[#specs + 1] = spec.name end
  screen.classBlurb:SetText(def.blurb or L["This class is not available yet."])
  screen.classSpecs:SetText(table.concat(specs, ", "))
  screen.startButton:SetEnabled(def.playable)
  screen.startButton:SetText(def.playable and L["Start a Run"] or L["Coming soon"])
  ns.UI.Main.SetAccent(key)
end

function Home.Refresh()
  refreshStats()
  refreshContinue()
  if selectedClass then selectClass(selectedClass) end
end

function Home.ShowRunOver(run)
  if not screen or not run then return end
  local cleared = run:IsVictory()
  local text
  if run.survival and cleared then
    text = string.format(L["Your %s survived all %d rounds with %d wins."], ns.Classes[run.class].name, ns.Economy.ROUNDS, run.wins)
  elseif run.survival then
    text = string.format(L["Your %s fell in Survival after %d wins and %d losses."], ns.Classes[run.class].name, run.wins, run.losses)
  elseif cleared then
    text = string.format(L["Your %s finished the run %d-%d. Victory!"], ns.Classes[run.class].name, run.wins, run.losses)
  elseif ns.Economy.LivesRemaining(run) == 0 then
    text = string.format(L["Your %s fell after %d wins and %d losses."], ns.Classes[run.class].name, run.wins, run.losses)
  else
    text = string.format(L["Your %s completed all %d rounds with %d wins."], ns.Classes[run.class].name, ns.Economy.ROUNDS, run.wins)
  end
  screen.runOver.text:SetText(text)
  if cleared then screen.runOver:SetBorderColor(T.RGB(T.C.good)) else screen.runOver:SetBorderColor(T.RGB(T.C.bad)) end
  T.Bounce(screen.runOver, 0.3)
  ns.Addon:DismissFinishedRun()
  Home.Refresh()
end

local function createStatRow(parent, index)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(24)
  row:SetPoint("LEFT", parent, "LEFT", 14, 0)
  row:SetPoint("RIGHT", parent, "RIGHT", -14, 0)
  if index % 2 == 0 then
    local stripe = row:CreateTexture(nil, "BACKGROUND")
    stripe:SetTexture(T.TEX.white)
    stripe:SetVertexColor(1, 1, 1, 0.025)
    stripe:SetAllPoints()
  end
  row.label = T.Text(row, 12, T.C.muted)
  row.label:SetPoint("LEFT", 4, 0)
  row.value = T.Number(row, 13, T.C.text)
  row.value:SetPoint("RIGHT", -4, 0)
  return row
end

function Home.Create(parent)
  screen = CreateFrame("Frame", nil, parent)
  screen:SetAllPoints()

  local hero = T.Inset(screen)
  hero:SetPoint("TOPLEFT", 0, 0)
  hero:SetPoint("TOPRIGHT", 0, 0)
  hero:SetHeight(330)
  local heroLabel = T.Label(hero, L["Choose a class"])
  heroLabel:SetPoint("TOPLEFT", 14, -12)

  screen.classButtons = {}
  local size = 60
  local spacing = 92
  local total = (#ns.ClassList - 1) * spacing + size
  local startX = (952 - total) / 2
  for i, def in ipairs(ns.ClassList) do
    local b = CreateFrame("Button", nil, hero)
    b:SetSize(size, size + 20)
    b:SetPoint("TOPLEFT", hero, "TOPLEFT", startX + (i - 1) * spacing, -36)
    b.portrait = T.CreatePortrait(b, size)
    b.portrait:SetPoint("TOP", 0, 0)
    b.portrait:SetClass(def.key)
    b.portrait:SetRingColor(T.RGB(T.C.line))
    b.glow = b:CreateTexture(nil, "BACKGROUND", nil, -2)
    b.glow:SetTexture(T.TEX.glow)
    b.glow:SetSize(size + 44, size + 44)
    b.glow:SetPoint("CENTER", b.portrait, "CENTER")
    b.glow:SetVertexColor(T.ClassColor(def.key))
    b.glow:SetBlendMode("ADD")
    b.glow:SetAlpha(0)
    b.label = T.Text(b, 12, T.C.muted, def.name)
    b.label:SetPoint("TOP", b.portrait, "BOTTOM", 0, -4)
    if not def.playable then
      b.portrait.icon:SetDesaturated(true)
      b.portrait.icon:SetVertexColor(0.4, 0.4, 0.4)
    end
    b.classKey = def.key
    b:SetScript("OnClick", function() selectClass(def.key) T.PlaySound(T.SOUND_CLICK) end)
    b:SetScript("OnEnter", function(self)
      if self.classKey ~= selectedClass then self.glow:SetAlpha(0.3) end
      GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
      GameTooltip:AddLine(def.name, T.ClassColor(def.key))
      if def.playable then
        GameTooltip:AddLine(def.blurb or "", 1, 1, 1, true)
      else
        GameTooltip:AddLine(L["Coming in a later version."], 0.6, 0.6, 0.6)
      end
      GameTooltip:Show()
    end)
    b:SetScript("OnLeave", function(self)
      if self.classKey ~= selectedClass then self.glow:SetAlpha(0) end
      GameTooltip:Hide()
    end)
    screen.classButtons[i] = b
  end

  local classTitle = T.Title(hero, 24, T.C.text)
  classTitle:SetPoint("TOPLEFT", hero, "TOPLEFT", 20, -150)
  screen.classTitle = classTitle
  local classSpecs = T.Text(hero, 12, T.C.muted)
  classSpecs:SetPoint("LEFT", classTitle, "RIGHT", 14, -2)
  screen.classSpecs = classSpecs
  local classBlurb = T.Text(hero, 13, T.C.muted)
  classBlurb:SetPoint("TOPLEFT", classTitle, "BOTTOMLEFT", 1, -8)
  classBlurb:SetWidth(600)
  classBlurb:SetJustifyH("LEFT")
  screen.classBlurb = classBlurb

  local startButton = T.CreateButton(hero, L["Start a Run"], 200, 44, "primary", 15)
  startButton:SetPoint("BOTTOMLEFT", hero, "BOTTOMLEFT", 20, 18)
  startButton:SetScript("OnClick", function()
    if not selectedClass then return end
    local function go()
      ns.Addon:NewRun(selectedClass)
      screen.runOver:Hide()
      ns.UI.Main.ShowScreen("shop")
      T.PlaySound(T.SOUND_OPEN)
    end
    if ns.run and not ns.run:IsOver() then
      T.PlaySound(T.SOUND_CLICK)
      ns.UI.Dialogs.Confirm(L["Starting a new run will abandon your current one. Continue?"], go)
    else
      go()
    end
  end)
  screen.startButton = startButton

  local armoryButton = T.CreateButton(hero, L["Armory"], 120, 44, "default", 14)
  armoryButton:SetPoint("LEFT", startButton, "RIGHT", 12, 0)
  armoryButton:SetScript("OnClick", function()
    ns.UI.Armory.Open(screen, selectedClass)
    T.PlaySound(T.SOUND_CLICK)
  end)
  screen.armoryButton = armoryButton

  local continueCard = T.Panel(hero, "card", { frameType = "Button" })
  continueCard:SetSize(320, 64)
  continueCard:SetPoint("BOTTOMRIGHT", hero, "BOTTOMRIGHT", -20, 14)
  continueCard:SetScript("OnClick", function() ns.UI.Main.ShowScreen("shop") T.PlaySound(T.SOUND_CLICK) end)
  continueCard:SetScript("OnEnter", function(self) self:SetFillColor(T.RGB(T.C.bg4)) self:SetBorderColor(T.RGB(T.C.gold)) end)
  continueCard:SetScript("OnLeave", function(self) self:SetFillColor(T.RGB(T.C.bg3)) self:SetBorderColor(T.C.ink[1], T.C.ink[2], T.C.ink[3], 0.95) end)
  local continuePortrait = T.CreatePortrait(continueCard, 42)
  continuePortrait:SetPoint("LEFT", 12, 0)
  screen.continuePortrait = continuePortrait
  local continueLabel = T.Text(continueCard, 11, T.C.gold, L["Continue your run"])
  continueLabel:SetPoint("TOPLEFT", continuePortrait, "TOPRIGHT", 10, -8)
  local continueText = T.Text(continueCard, 13, T.C.text)
  continueText:SetPoint("TOPLEFT", continueLabel, "BOTTOMLEFT", 0, -4)
  screen.continueText = continueText
  local continueRecord = T.Number(continueCard, 17, T.C.text)
  continueRecord:SetPoint("RIGHT", continueCard, "RIGHT", -16, 0)
  screen.continueRecord = continueRecord
  screen.continueCard = continueCard

  local runOver = T.Panel(screen, "card")
  runOver:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -8)
  runOver:SetPoint("TOPRIGHT", hero, "BOTTOMRIGHT", 0, -8)
  runOver:SetHeight(40)
  runOver.text = T.Text(runOver, 14, T.C.text)
  runOver.text:SetPoint("CENTER")
  runOver:Hide()
  screen.runOver = runOver

  local statsPanel = T.Inset(screen)
  statsPanel:SetPoint("TOPLEFT", hero, "BOTTOMLEFT", 0, -56)
  statsPanel:SetPoint("BOTTOMLEFT", screen, "BOTTOMLEFT", 0, 0)
  statsPanel:SetWidth(400)
  local statsLabel = T.Label(statsPanel, L["Record"])
  statsLabel:SetPoint("TOPLEFT", 14, -12)
  screen.statRows = {}
  local prev = statsLabel
  for i = 1, 8 do
    local row = createStatRow(statsPanel, i)
    row:SetPoint("TOP", prev, "BOTTOM", 0, i == 1 and -8 or 0)
    screen.statRows[i] = row
    prev = row
  end
  local howPanel = T.Inset(screen)
  howPanel:SetPoint("TOPLEFT", statsPanel, "TOPRIGHT", 8, 0)
  howPanel:SetPoint("BOTTOMRIGHT", screen, "BOTTOMRIGHT", 0, 0)
  local howLabel = T.Label(howPanel, L["How to play"])
  howLabel:SetPoint("TOPLEFT", 14, -12)
  local steps = {
    { L["Shop"], L["Spend your gold on items from the shop and place them in your bag."] },
    { L["Build"], L["Purchase bags to gain more space and arrange your items."] },
    { L["Fight"], L["Once you are ready, start the battle to fight against another player's build."] },
    { L["Win"], string.format(L["At ten wins, finish or enter Survival through round %d. Lose all lives and the run ends."], ns.Economy.ROUNDS) },
  }
  local last = howLabel
  for i, step in ipairs(steps) do
    local num = T.Number(howPanel, 20, T.C.goldDim, tostring(i))
    num:SetPoint("TOPLEFT", last, "BOTTOMLEFT", i == 1 and 2 or 0, i == 1 and -14 or -16)
    local title = T.Text(howPanel, 13, T.C.text, step[1])
    title:SetPoint("TOPLEFT", num, "TOPLEFT", 26, -1)
    local body = T.Text(howPanel, 12, T.C.muted, step[2])
    body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
    body:SetPoint("RIGHT", howPanel, "RIGHT", -16, 0)
    body:SetJustifyH("LEFT")
    last = num
  end

  screen:SetScript("OnShow", function() Home.Refresh() end)
  screen:SetScript("OnHide", function() ns.UI.Armory.Close() end)
  selectClass(ns.db and ns.db.global.settings.lastClass or "DRUID")
  return screen
end
