local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Dialogs = {}
ns.UI.Dialogs = Dialogs

function Dialogs.Confirm(text, onAccept)
  StaticPopupDialogs.BAGNONBATTLES_CONFIRM = StaticPopupDialogs.BAGNONBATTLES_CONFIRM or {
    text = "%s", button1 = YES, button2 = NO, timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
    OnAccept = function(self, data) if data and data.onAccept then data.onAccept() end end,
  }
  local popup = StaticPopup_Show("BAGNONBATTLES_CONFIRM", text)
  if popup then popup.data = { onAccept = onAccept } end
end

function Dialogs.HideRankReminder(notify)
  local view = Dialogs.rankReminder
  local visible = view and view:IsShown()
  local onDismiss = visible and view.onDismiss
  if view then view:Hide() end
  if notify and onDismiss then onDismiss() end
  return visible
end

function Dialogs.ShowRankReminder(parent, run, rank, onDismiss)
  if not run or run ~= ns.run or run.phase ~= "shop" then return false end
  local view = Dialogs.rankReminder
  if not view then
    view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints(parent)
    view:SetFrameLevel(parent:GetFrameLevel() + 60)
    view:EnableMouse(true)
    local shade = view:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints()
    shade:SetTexture(T.TEX.white)
    shade:SetVertexColor(0, 0, 0, 0.55)
    local card = T.Panel(view, "card")
    card:SetSize(400, 148)
    card:SetPoint("CENTER")
    card:SetBorderColor(T.RGB(T.C.gold))
    card:EnableMouse(true)
    T.CreateShadow(card, 28, 0.8)
    view.card = card
    view.title = T.Title(card, 20, T.C.gold, L["Ability Training"])
    view.title:SetPoint("TOP", 0, -18)
    view.body = T.Text(card, 13, T.C.text)
    view.body:SetPoint("TOP", view.title, "BOTTOM", 0, -14)
    view.body:SetWidth(360)
    view.body:SetJustifyH("CENTER")
    view.hint = T.Text(card, 12, T.C.muted, L["Right-click an ability to train."])
    view.hint:SetPoint("TOP", view.body, "BOTTOM", 0, -9)
    view.dismiss = T.CreateButton(card, L["Okay"], 120, 30, "primary", 13)
    view.dismiss:SetPoint("BOTTOM", 0, 18)
    view.dismiss:SetScript("OnClick", function()
      T.PlaySound(T.SOUND_CLICK)
      Dialogs.HideRankReminder(true)
    end)
    view:SetScript("OnHide", function(self)
      self.onDismiss = nil
      ns.UI.Tooltip.Hide()
    end)
    view:Hide()
    Dialogs.rankReminder = view
  end
  view.onDismiss = onDismiss
  view.body:SetText(string.format(L["You can now train Rank %d abilities."], rank))
  ns.UI.Tooltip.Hide()
  view:Show()
  return true
end

function Dialogs.HideSurvival()
  if Dialogs.survival then Dialogs.survival:Hide() end
end

function Dialogs.ShowSurvival(parent, run, onChoice)
  if not run or run ~= ns.run or run.phase ~= "survival" then return false end
  local view = Dialogs.survival
  if not view then
    view = CreateFrame("Frame", nil, parent)
    view:SetAllPoints(parent)
    view:SetFrameLevel(parent:GetFrameLevel() + 40)
    view:EnableMouse(true)
    local shade = view:CreateTexture(nil, "BACKGROUND")
    shade:SetAllPoints()
    shade:SetTexture(T.TEX.white)
    shade:SetVertexColor(0, 0, 0, 0.65)
    local card = T.Panel(view, "card")
    card:SetSize(440, 196)
    card:SetPoint("CENTER")
    card:SetBorderColor(T.RGB(T.C.gold))
    card:EnableMouse(true)
    T.CreateShadow(card, 28, 0.8)
    view.card = card
    view.title = T.Title(card, 23, T.C.gold, L["Victory!"])
    view.title:SetPoint("TOP", 0, -20)
    view.record = T.Text(card, 13, T.C.text)
    view.record:SetPoint("TOP", view.title, "BOTTOM", 0, -10)
    view.body = T.Text(card, 13, T.C.muted)
    view.body:SetPoint("TOP", view.record, "BOTTOM", 0, -14)
    view.body:SetWidth(400)
    view.body:SetJustifyH("CENTER")
    view.finish = T.CreateButton(card, L["Finish Run"], 190, 34, "default", 14)
    view.finish:SetPoint("BOTTOMLEFT", 20, 18)
    view.enter = T.CreateButton(card, L["Enter Survival"], 190, 34, "primary", 14)
    view.enter:SetPoint("BOTTOMRIGHT", -20, 18)
    for _, entry in ipairs({ { view.finish, false }, { view.enter, true } }) do
      local button, enter = entry[1], entry[2]
      button:SetScript("OnClick", function()
        if view.run ~= ns.run or not view.run or view.run.phase ~= "survival" then Dialogs.HideSurvival() return end
        if view.onChoice then T.PlaySound(T.SOUND_CLICK) view.onChoice(enter) end
      end)
    end
    view:SetScript("OnHide", function(self)
      self.run, self.onChoice = nil, nil
      ns.UI.Tooltip.Hide()
    end)
    Dialogs.survival = view
  end
  view.run, view.onChoice = run, onChoice
  local lives = ns.Economy.LivesRemaining(run)
  view.record:SetText(string.format(lives == 1 and L["%s: %d wins, %d life remaining"] or L["%s: %d wins, %d lives remaining"], ns.Classes[run.class].name, run.wins, lives))
  local body = string.format(L["You can continue to round %d in Survival."], ns.Economy.ROUNDS)
  if lives < ns.Economy.MAX_LOSSES then body = body .. "\n" .. L["Entering Survival restores one life."] end
  view.body:SetText(body)
  ns.UI.Tooltip.Hide()
  view:Show()
  return true
end
