local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Mastery = {}
ns.UI.Mastery = Mastery

Mastery.TALENT_ICON = "Interface\\Icons\\Ability_Marksmanship"

function Mastery.SetTalentIcon(texture)
  local resolved = T.ResolveIcon(Mastery.TALENT_ICON)
  if resolved == T.TEX.questionMark then resolved = Mastery.TALENT_ICON end
  texture:SetTexture(resolved)
  texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)
  return resolved
end

function Mastery.CreateButton(parent, panel)
  local button = T.CreateSlot(parent, 36)
  Mastery.SetTalentIcon(button.icon)
  button:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")
  button:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  button.SetHighlighted = T.SetHighlighted
  local nativeSetEnabled = button.SetEnabled
  function button:SetEnabled(enabled)
    nativeSetEnabled(self, enabled)
    self:SetAlpha(enabled and 1 or 0.5)
  end
  button.badge = CreateFrame("Frame", nil, button)
  button.badge:SetSize(20, 20)
  button.badge:SetPoint("TOPRIGHT", 6, 6)
  button.badge:SetFrameLevel(button:GetFrameLevel() + 2)
  button.badge.background = button.badge:CreateTexture(nil, "BACKGROUND")
  button.badge.background:SetTexture(T.TEX.circle)
  button.badge.background:SetAllPoints()
  button.badge.background:SetVertexColor(1, 0.8, 0.2, 1)
  button.badge.count = T.Number(button.badge, 13, T.C.ink, nil, "OUTLINE")
  button.badge.count:SetPoint("CENTER", 0, 0)
  button.badge:Hide()
  button.earnedGlow = T.CreateGlow(button, 8, 1, 0.65, 0.15, 0)
  button.earnedGlow:Hide()
  function button:StopTalentNotice()
    self.talentNotice = false
    T.StopPulse(self.earnedGlow)
    self.earnedGlow:SetAlpha(0)
    self.earnedGlow:Hide()
  end
  function button:AcknowledgeTalentPoint(run)
    run = run or ns.run
    if run then
      self.talentRun = run
      self.acknowledgedBudget = run:TalentInfo().budget
    end
    self:StopTalentNotice()
  end
  function button:RefreshTalents(run)
    local info = run:TalentInfo()
    if self.talentRun ~= run then
      self.talentRun, self.acknowledgedBudget = run, 0
    end
    self.badge.count:SetText(tostring(info.available))
    self.badge:SetShown(info.available > 0)
    self:SetEnabled(run.phase == "shop")
    self:SetHighlighted(run.phase == "shop" and panel:IsShown())
    if info.available == 0 then self.acknowledgedBudget = info.budget end
    local pending = run.phase == "shop" and info.available > 0 and info.budget > (self.acknowledgedBudget or 0)
      and not panel:IsShown() and self:IsVisible()
    if pending then
      self.earnedGlow:Show()
      if not self.talentNotice then
        self.earnedGlow:SetAlpha(1)
        T.Pulse(self.earnedGlow, 0.2, 0.85, 0.8)
      end
      self.talentNotice = true
    else self:StopTalentNotice() end
  end
  function button:MaybePrompt(run, allowed)
    if not run then return false end
    self:RefreshTalents(run)
    local info = run:TalentInfo()
    if not allowed or run ~= ns.run or run.phase ~= "shop" or not self:IsVisible()
      or info.available <= 0 or info.budget <= (self.acknowledgedBudget or 0) then return false end
    if panel:IsShown() then self:AcknowledgeTalentPoint(run) return false end
    panel:Open()
    return panel:IsShown()
  end
  button:SetScript("OnEnter", function(self)
    self.glow:SetAlpha(0.35)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
    GameTooltip:ClearLines()
    GameTooltip:AddLine(L["Talents"], 1, 0.82, 0)
    local run = ns.run
    if run then
      local available = run:TalentInfo().available
      if available > 0 then
        GameTooltip:AddLine(string.format(L[available == 1 and "%d unspent talent point" or "%d unspent talent points"], available), 0.4, 1, 0.4)
      end
    end
    GameTooltip:AddLine(L["Click to open talents."], 1, 1, 1)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", function(self) self.glow:SetAlpha(0) GameTooltip:Hide() end)
  button:SetScript("OnHide", function(self)
    self:StopTalentNotice()
    if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
  end)
  button:SetScript("OnShow", function(self) if ns.run then self:RefreshTalents(ns.run) end end)
  panel.talentButton = button
  return button
end

local function showDetails(row)
  local run = ns.run
  if not run or not row.spec then return end
  local points = run:TalentInfo().allocation[row.spec] or 0
  GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
  GameTooltip:ClearLines()
  GameTooltip:AddDoubleLine(row.name:GetText(), tostring(points), 1, 0.82, 0, 1, 1, 1)
  for _, line in ipairs(ns.Mastery.Lines(run.class, row.spec, points)) do
    local text = line.text
    if (line.points or 0) > 0 then text = string.format(L["%d points: %s"], line.points, text) end
    local color = line.active and T.C.good or T.C.muted
    GameTooltip:AddLine(text, color[1], color[2], color[3], true)
  end
  GameTooltip:Show()
end

local function change(panel, row, amount)
  local run = ns.run
  if not run or run.phase ~= "shop" or not row.spec then return end
  local points = run:TalentInfo().allocation[row.spec] or 0
  local ok, err = run:SetTalent(row.spec, points + amount)
  if not ok then T.Error(err) return end
  T.PlaySound(T.SOUND_CLICK)
  ns.Addon:SaveRun()
  panel.onChange()
end

function Mastery.Create(parent, onChange)
  local panel = CreateFrame("Frame", nil, parent)
  panel:SetAllPoints(parent)
  panel:SetFrameLevel(parent:GetFrameLevel() + 30)
  panel:EnableMouse(true)
  panel.onChange = onChange
  panel.dim = panel:CreateTexture(nil, "BACKGROUND")
  panel.dim:SetTexture(T.TEX.white)
  panel.dim:SetVertexColor(0, 0, 0, 0.75)
  panel.dim:SetAllPoints()
  panel.card = T.Panel(panel, "card")
  panel.card:SetSize(620, 420)
  panel.card:SetPoint("CENTER", 0, 0)
  panel.title = T.Title(panel.card, 19, T.C.gold, L["Talents"])
  panel.title:SetPoint("TOPLEFT", 18, -16)
  panel.available = T.Number(panel.card, 15, T.C.gold)
  panel.available:SetPoint("TOPRIGHT", -18, -18)
  panel.hint = T.Text(panel.card, 11, T.C.muted, L["Gain talent points at round 3, 6, 9 and 12"])
  panel.hint:SetPoint("TOPLEFT", panel.title, "BOTTOMLEFT", 0, -8)
  panel.rows = {}
  for index = 1, 3 do
    local row = T.Panel(panel.card, "card")
    row:SetSize(584, 96)
    row:SetPoint("TOPLEFT", 18, -(68 + (index - 1) * 104))
    row:EnableMouse(true)
    row.name = T.Text(row, 14, T.C.text)
    row.name:SetPoint("TOPLEFT", 12, -10)
    row.current = T.Text(row, 11, T.C.good)
    row.current:SetPoint("TOPLEFT", 12, -33)
    row.current:SetSize(430, 30)
    row.current:SetJustifyH("LEFT")
    row.current:SetJustifyV("TOP")
    row.next = T.Text(row, 10, T.C.muted)
    row.next:SetPoint("BOTTOMLEFT", 12, 8)
    row.next:SetSize(560, 24)
    row.next:SetJustifyH("LEFT")
    row.next:SetJustifyV("BOTTOM")
    row.plus = T.CreateButton(row, "+", 28, 24, "default", 14)
    row.plus:SetPoint("TOPRIGHT", -12, -8)
    row.minus = T.CreateButton(row, "-", 28, 24, "default", 14)
    row.minus:SetPoint("RIGHT", row.plus, "LEFT", -44, 0)
    row.value = T.Number(row, 18, T.C.gold)
    row.value:SetPoint("CENTER", row.plus, "LEFT", -22, 0)
    row.pips = {}
    local maxPoints = ns.Mastery.MAX_POINTS
    for point = 1, maxPoints do
      local pip = row:CreateTexture(nil, "ARTWORK")
      pip:SetTexture(T.TEX.white)
      pip:SetSize(7, 8)
      pip:SetPoint("TOPRIGHT", row, "TOPRIGHT", -12 - (maxPoints - point) * 11, -42)
      row.pips[point] = pip
    end
    row.plus:SetScript("OnClick", function() change(panel, row, 1) end)
    row.minus:SetScript("OnClick", function() change(panel, row, -1) end)
    row:SetScript("OnEnter", function() showDetails(row) end)
    row:SetScript("OnLeave", function() ns.UI.Tooltip.Hide() end)
    panel.rows[index] = row
  end
  panel.reset = T.CreateButton(panel.card, L["Reset Points"], 120, 24, "default", 11)
  panel.reset:SetPoint("BOTTOMLEFT", 18, 12)
  panel.reset:SetScript("OnClick", function()
    local run = ns.run
    if not run or run.phase ~= "shop" then return end
    local ok, err = run:ResetTalents()
    if not ok then T.Error(err) return end
    T.PlaySound(T.SOUND_CLICK)
    ns.Addon:SaveRun()
    panel.onChange()
  end)
  panel.close = T.CreateButton(panel.card, L["Done"], 110, 24, "default", 11)
  panel.close:SetPoint("BOTTOMRIGHT", -18, 12)
  panel.close:SetScript("OnClick", function() panel:Hide() T.PlaySound(T.SOUND_CLICK) end)
  function panel:Refresh()
    local run = ns.run
    if not run or run.phase ~= "shop" then self:Hide() return end
    local info = run:TalentInfo()
    self.available:SetText(string.format(L["%d available, %d/%d spent"], info.available, info.spent, info.budget))
    self.reset:SetEnabled(info.spent > 0)
    for index, row in ipairs(self.rows) do
      local spec = ns.Classes[run.class].specs[index]
      row.spec = spec and spec.tag
      row:SetShown(spec ~= nil)
      if spec then
        local points = info.allocation[spec.tag] or 0
        row.name:SetText(spec.name)
        row.value:SetText(tostring(points))
        row.minus:SetEnabled(points > 0)
        row.plus:SetEnabled(info.available > 0 and points < ns.Mastery.MAX_POINTS)
        local current, milestone, nextReward
        for _, line in ipairs(ns.Mastery.Lines(run.class, spec.tag, points)) do
          if line.active then
            if (line.points or 0) == 0 then current = line.text else milestone = line.text end
          elseif (line.points or 0) > points and not nextReward then
            nextReward = line
          end
        end
        local summary = {}
        if current then summary[#summary + 1] = current end
        if milestone then summary[#summary + 1] = milestone end
        row.current:SetText(#summary > 0 and table.concat(summary, "\n") or L["No talent bonuses."])
        row.current:SetTextColor(T.RGB(#summary > 0 and T.C.good or T.C.dim))
        row.next:SetText(nextReward and string.format(L["Next at %d: %s"], nextReward.points, nextReward.text) or L["All talent bonuses unlocked."])
        for point, pip in ipairs(row.pips) do
          local color = point <= points and T.C.gold or T.C.line
          pip:SetVertexColor(color[1], color[2], color[3], point <= points and 1 or 0.5)
        end
      end
    end
  end
  function panel:Open()
    local run = ns.run
    if not run or run.phase ~= "shop" then return end
    if self.talentButton then self.talentButton:AcknowledgeTalentPoint() end
    ns.UI.Tooltip.Hide()
    self:Refresh()
    self:Show()
  end
  panel:SetScript("OnHide", function()
    ns.UI.Tooltip.Hide()
    if panel.talentButton and ns.run then panel.talentButton:RefreshTalents(ns.run) end
  end)
  panel:SetScript("OnShow", function()
    if panel.talentButton and ns.run then panel.talentButton:RefreshTalents(ns.run) end
  end)
  panel:Hide()
  return panel
end
