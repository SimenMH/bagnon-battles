local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L

local Training = {}
ns.UI.Training = Training

local function chooseRank(overlay, rank)
  local r = ns.run

  if not r or r ~= overlay.run or not overlay.target then overlay:Close() return end
  local info = r:TrainingInfo(overlay.target)
  if r:IsHolding() or not info or info.def.id ~= overlay.itemId or r.phase ~= "shop" then
    overlay:Close()
    return
  end
  local def, err
  local training = rank == info.nextRank
  if training then
    def, err = r:Train(overlay.target)
  else
    def, err = r:SetRank(overlay.target, rank)
  end
  if not def then T.Error(err) return end
  overlay.itemId = def.id
  if training then overlay.page = nil end
  T.PlaySound(training and T.SOUND_TRAIN or T.SOUND_CLICK)
  ns.Addon:SaveRun()
  overlay.onChange()
end

local function refresh(overlay)
  local r = ns.run
  if not r or r ~= overlay.run or not overlay.target then overlay:Close() return end
  local info = r:TrainingInfo(overlay.target)
  if not info or info.def.id ~= overlay.itemId or r.phase ~= "shop" then
    overlay:Close()
    return
  end
  overlay.title:SetText(info.base.name)
  local slots = ns.Ranks.MaxRank(info.base) > 3 and 5 or 3
  local ranks, page, pages = ns.Ranks.Page(info.base, overlay.page, slots, math.max(info.learned, info.nextRank or info.rank))
  local gap, width = slots > 3 and 8 or 16, slots > 3 and 126 or 190
  local available = overlay:GetWidth()
  if available and available > 0 then width = math.min(width, math.floor((available - 32 - (slots - 1) * gap) / slots)) end
  overlay.page = page
  overlay.previous:SetShown(pages > 1)
  overlay.next:SetShown(pages > 1)
  overlay.previous:SetEnabled(page > 1)
  overlay.next:SetEnabled(page < pages)
  overlay.pageLabel:SetShown(pages > 1)
  overlay.pageLabel:SetText(string.format("%d / %d", page, pages))
  for i, card in ipairs(overlay.cards) do
    local rank = ranks[i]
    local def = rank and ns.Ranks.Definition(info.base, rank)
    card.rank = rank
    if def then
      card:SetSize(width, 175)
      card:ClearAllPoints()
      card:SetPoint("CENTER", overlay, "CENTER", (i - (slots + 1) / 2) * (width + gap), -10)
      for _, label in ipairs({ card.name, card.kind, card.price, card.note }) do label:SetWidth(width - 16) end
      card:Show()
      card.def = def
      local previousRank = rank - 1
      while previousRank > 0 and not ns.Ranks.Definition(info.base, previousRank) do previousRank = previousRank - 1 end
      card.compare = previousRank > 0 and ns.Ranks.Definition(info.base, previousRank) or nil
      T.SetItemIcon(card.iconSlot.icon, def.icon)
      card.iconSlot.icon:Show()
      card.iconSlot:SetQuality(def.quality)
      local qr, qg, qb = T.QualityColor(def.quality)
      card.name:SetText(string.format(L["Rank %d"], rank))
      card.name:SetTextColor(qr, qg, qb)
      local use = def.use
      if use then
        local timing = use.once and "Once per battle" or ns.Describe.Rate(use.cd) .. "s"
        card.kind:SetText(string.format("%s %s / %s", ns.Describe.Rate(use.cost or 0), ns.RESOURCE_NAMES[use.resource] or "", timing))
      else
        card.kind:SetText(L["Triggered attack"])
      end
      if rank > info.learned then
        card.price:SetText(string.format("%s  %s%d", L["Train"], T.GOLD_ICON, ns.Ranks.TrainingCost(info.base, rank)))
        card.price:Show()
      else
        card.price:SetText("")
        card.price:Hide()
      end
      if rank == info.rank then
        card.note:SetText(L["Selected"])
        card:SetEnabled(false)
      elseif rank <= info.learned then
        card.note:SetText(L["Use this rank"])
        card:SetEnabled(true)
      elseif rank == info.nextRank then
        card.note:SetText(info.canTrain and "" or info.reason)
        card:SetEnabled(info.canTrain)
      else
        card.note:SetText(string.format(L["Learn Rank %d first"], previousRank))
        card:SetEnabled(false)
      end
      card:SetAlpha((rank <= info.learned or info.canTrain and rank == info.nextRank) and 1 or 0.55)
    else
      card:Hide()
      card.def = nil
      card.compare = nil
    end
  end
end

function Training.Create(parent, onChange, getContext)
  local overlay = CreateFrame("Frame", nil, parent)
  overlay:SetAllPoints(parent)
  overlay:SetFrameLevel(parent:GetFrameLevel() + 20)
  overlay:EnableMouse(true)
  overlay.dim = overlay:CreateTexture(nil, "BACKGROUND")
  overlay.dim:SetTexture(T.TEX.white)
  overlay.dim:SetVertexColor(0, 0, 0, 0.7)
  overlay.dim:SetAllPoints()
  overlay.title = T.Title(overlay, 18, T.C.gold)
  overlay.title:SetPoint("CENTER", overlay, "CENTER", 0, 100)
  overlay.cards = {}
  for i = 1, 5 do
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
    card:SetScript("OnClick", function(self) chooseRank(overlay, self.rank) end)
    card:SetScript("OnEnter", function(self)
      self:SetFillColor(T.RGB(T.C.bg4))
      self:SetBorderColor(T.RGB(T.C.gold))
      if self.def then
        ns.UI.Tooltip.ShowRankComparison(self, self.compare, self.def, { run = ns.run, context = overlay.getContext(), above = overlay.title })
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
  overlay.close:SetPoint("TOP", overlay, "CENTER", 0, -112)
  overlay.close:SetScript("OnClick", function()
    overlay:Close()
    T.PlaySound(T.SOUND_CLICK)
  end)
  overlay.previous = T.CreateButton(overlay, L["Previous"], 84, 26, "default", 12)
  overlay.previous:SetPoint("RIGHT", overlay.close, "LEFT", -14, 0)
  overlay.previous:SetScript("OnClick", function()
    overlay.page = (overlay.page or 1) - 1
    ns.UI.Tooltip.Hide()
    overlay:Refresh()
    T.PlaySound(T.SOUND_CLICK)
  end)
  overlay.next = T.CreateButton(overlay, L["Next"], 84, 26, "default", 12)
  overlay.next:SetPoint("LEFT", overlay.close, "RIGHT", 14, 0)
  overlay.next:SetScript("OnClick", function()
    overlay.page = (overlay.page or 1) + 1
    ns.UI.Tooltip.Hide()
    overlay:Refresh()
    T.PlaySound(T.SOUND_CLICK)
  end)
  overlay.pageLabel = T.Text(overlay, 11, T.C.muted)
  overlay.pageLabel:SetPoint("TOP", overlay.close, "BOTTOM", 0, -5)
  overlay.previous:Hide()
  overlay.next:Hide()
  overlay.pageLabel:Hide()
  overlay:SetScript("OnHide", function() ns.UI.Tooltip.Hide() end)
  overlay:SetScript("OnSizeChanged", function(self) if self:IsShown() then self:Refresh() end end)
  overlay.onChange, overlay.getContext = onChange, getContext
  overlay.Refresh = refresh
  function overlay:Close()
    self.run, self.target, self.itemId, self.page = nil, nil, nil, nil
    self:Hide()
  end
  function overlay:Open(target)
    local r = ns.run
    if not r or r.phase ~= "shop" then return false end
    local info = r:TrainingInfo(target)
    if not info then return false end
    self.run, self.target, self.itemId, self.page = r, target, info.def.id, nil
    self:Refresh()
    self:Show()
    ns.UI.Tooltip.Hide()
    T.PlaySound(T.SOUND_CLICK)
    return true
  end
  overlay:Hide()
  return overlay
end

