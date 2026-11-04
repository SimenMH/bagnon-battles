local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L
local Util = ns.Util
local itemDefinition = ns.Sim.SourceDefinition

local Inspector = {}
ns.UI.BattleInspector = Inspector

local RES_ORDER = T.RESOURCE_ORDER
local INSPECT_STATS = {
  { "hp", "Health" }, { "armor", "Armor" }, { "ap", "Attack Power" }, { "sp", "Spell Power" },
  { "healing", "Healing Power" }, { "crit", "Critical Strike", true }, { "haste", "Haste", true },
  { "dodge", "Dodge", true }, { "block", "Block Value" }, { "blockChance", "Block Chance", true },
  { "dr", "Damage Reduction", true }, { "critDamage", "Critical Strike Damage", true, true },
  { "thorns", "Thorns Damage", false, true }, { "lifesteal", "Life Steal", true, true },
  { "dmgPct", "Damage Dealt", true, true }, { "healPct", "Healing Done", true, true },
  { "petPct", "Pet Damage", true, true }, { "rangedPct", "Ranged Damage", true, true },
  { "meleePct", "Melee Damage", true, true }, { "spellPct", "Spell Damage", true, true },
  { "ragePct", "Rage from Hits", true, true }, { "rageTakenPct", "Rage from Damage Taken", true, true },
  { "rageOnCrit", "Rage on Critical Strike", false, true },
}

local function inspectContext(battle, sideId)
  local summary = battle.result[sideId]
  local class = ns.GetClass(summary.classKey)
  local context = {
    classKey = summary.classKey, classDef = class, round = battle.round, hpMax = summary.hpMax,
    stats = Util.DeepCopy(summary.stats), res = {}, items = {},
    talents = Util.DeepCopy(summary.talents or battle.allocations[sideId]),
  }
  for resource, maximum in pairs(summary.resources or {}) do
    local cfg = class.resources and class.resources[resource]
    context.res[resource] = { max = maximum, regen = cfg and cfg.regen or 0 }
  end
  for _, item in pairs(summary.items or {}) do
    local def = itemDefinition(item.key)
    if def and item.enabled then
      for resource, cfg in pairs(def.grants or {}) do
        local pool = context.res[resource]
        if pool then pool.regen = math.max(pool.regen, cfg.regen or 0) end
      end
    end
  end
  if context.res.mana then context.res.mana.regen = context.res.mana.regen + (context.stats.regen or 0) end
  return context
end

local function inspectNumber(value)
  return string.format("%.1f", value):gsub("%.0$", "")
end

local function inspectStatTooltip(owner, context)
  if not owner.statKey:match("^resource:") then ns.UI.Tooltip.ShowStat(owner, owner.statKey, context) return end
  ns.UI.Tooltip.Hide()
  GameTooltip:SetOwner(owner, "ANCHOR_TOP")
  GameTooltip:ClearLines()
  GameTooltip:AddDoubleLine(owner.label:GetText(), owner.value:GetText(), 1, 0.82, 0, 1, 1, 1)
  for _, line in ipairs(ns.Describe.StatLines(owner.statKey, context, false)) do
    GameTooltip:AddLine(line.text, 0.8, 0.8, 0.8, true)
  end
  GameTooltip:Show()
end

local function update(view, snapshot)
  if not view:IsShown() or not view.battle then return end
  local sideId = view.sideId
  local context = view.context
  local hp = math.max(0, snapshot["hp" .. sideId] or 0)
  local absorb = snapshot["abs" .. sideId] or 0
  view.health:SetText(string.format("%s: %d / %d%s", L["Health"], Util.Round(hp), context.hpMax,
    absorb > 0 and string.format("   %s: %d", L["Absorb"], Util.Round(absorb)) or ""))
  local index = 0
  for _, resource in ipairs(RES_ORDER) do
    local pool = context.res[resource]
    if pool then
      index = index + 1
      local row = view.resources[index]
      local current = (snapshot["res" .. sideId] or {})[resource] or 0
      pool.cur = current
      row.statKey = "resource:" .. resource
      row.label:SetText(ns.RESOURCE_NAMES[resource] or resource)
      row.value:SetText(string.format("%d / %d", Util.Round(current), pool.max))
      row:Show()
    end
  end
  for i = index + 1, #view.resources do view.resources[i]:Hide() end
end

local function renderInspector(view)
  local context = inspectContext(view.battle, view.sideId)
  view.context = context
  view.title:SetText(view.battle.names[view.sideId] .. ": " .. L["Stats & Talents"])
  view.mine:SetHighlighted(view.sideId == "A")
  view.theirs:SetHighlighted(view.sideId == "B")
  local rows = {}
  for _, entry in ipairs(INSPECT_STATS) do
    local key, value = entry[1], context.stats[entry[1]] or 0
    if key == "hp" then value = context.hpMax end
    if key == "crit" then value = ns.Sim.CritChance(value) end
    if key == "dodge" then value = ns.Sim.DodgeChance(value) end
    if key == "blockChance" then value = Util.Clamp(value, 0, 100) end
    if key == "dr" then value = math.min(90, value) end
    if not entry[4] or value ~= 0 then
      rows[#rows + 1] = { key = key, label = L[entry[2]], value = inspectNumber(value) .. (entry[3] and "%" or "") }
    end
  end
  if context.res.mana then
    rows[#rows + 1] = { key = "resource:mana", label = L["Mana Regeneration"], value = inspectNumber(context.res.mana.regen) .. "/s" }
  end
  view.statEntries = rows
  view:LayoutStats()
  local total = 0
  for index, spec in ipairs(context.classDef.specs or {}) do
    local row = view.talents[index]
    local points = context.talents[spec.tag] or 0
    total = total + points
    row.spec, row.points = spec.tag, points
    T.SetItemIcon(row.icon, ns.Mastery.Definition(context.classKey, spec.tag).icon)
    row.name:SetText(L[spec.name])
    row.value:SetText(string.format(points == 1 and L["%d point"] or L["%d points"], points))
    row.bonus:SetText(string.format(L["%d%% damage and healing"], points * ns.Mastery.SPEC_BONUS_PCT))
    local milestones = {}
    for _, threshold in ipairs(ns.Mastery.THRESHOLDS) do
      milestones[#milestones + 1] = (points >= threshold and "|cff45e568" or "|cff888888") .. threshold .. "|r"
    end
    row.milestones:SetText(L["Milestones"] .. ": " .. table.concat(milestones, "   "))
    row:Show()
  end
  for index = #(context.classDef.specs or {}) + 1, #view.talents do view.talents[index]:Hide() end
  view.talentHeading:SetText(string.format(total == 1 and L["Talents (%d point)"] or L["Talents (%d points)"], total))
end

function Inspector.Create(parent, anchor, onSelect)
  local view = T.Panel(parent, "card")
  view:SetSize(740, 450)
  view:SetPoint("CENTER", anchor, "CENTER", 0, 0)
  view:SetFrameLevel(parent:GetFrameLevel() + 12)
  view:SetClampedToScreen(true)
  view:EnableMouse(true)
  T.CreateShadow(view, 30, 0.8)
  view.title = T.Title(view, 17, T.C.text)
  view.title:SetPoint("TOPLEFT", 18, -18)
  view.close = T.CreateButton(view, L["Close"], 70, 24, "default", 12)
  view.close:SetPoint("TOPRIGHT", -14, -14)
  view.close:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) view:Hide() end)
  view.mine = T.CreateButton(view, L["You"], 90, 24, "default", 12)
  view.mine:SetPoint("TOPLEFT", 18, -48)
  view.theirs = T.CreateButton(view, L["Opponent"], 90, 24, "default", 12)
  view.theirs:SetPoint("LEFT", view.mine, "RIGHT", 6, 0)
  view.mine:SetScript("OnClick", function() onSelect("A") end)
  view.theirs:SetScript("OnClick", function() onSelect("B") end)
  view.health = T.Text(view, 13, T.C.good)
  view.health:SetPoint("TOPLEFT", 18, -82)
  view.resources = {}
  for index = 1, #RES_ORDER do
    local row = CreateFrame("Frame", nil, view)
    row:SetSize(132, 30)
    row:SetPoint("TOPLEFT", 18 + (index - 1) * 140, -103)
    row:EnableMouse(true)
    row.label = T.Text(row, 10, T.C.muted)
    row.label:SetPoint("TOPLEFT", 0, 0)
    row.value = T.Number(row, 12, T.C.text)
    row.value:SetPoint("TOPLEFT", 0, -13)
    row:SetScript("OnEnter", function(self) inspectStatTooltip(self, view.context) end)
    row:SetScript("OnLeave", function() ns.UI.Tooltip.Hide() end)
    view.resources[index] = row
  end
  local statsHeading = T.Title(view, 13, T.C.gold, L["Starting stats"])
  statsHeading:SetPoint("TOPLEFT", 18, -145)
  view.talentHeading = T.Title(view, 13, T.C.gold)
  view.talentHeading:SetPoint("TOPLEFT", 388, -145)
  view.statsFrame = CreateFrame("Frame", nil, view)
  view.statsFrame:SetSize(330, 244)
  view.statsFrame:SetPoint("TOPLEFT", 18, -164)
  view.previous = T.CreateButton(view, L["Previous"], 76, 22, "default", 11)
  view.previous:SetPoint("BOTTOMLEFT", 18, 12)
  view.next = T.CreateButton(view, L["Next"], 76, 22, "default", 11)
  view.next:SetPoint("BOTTOMLEFT", 272, 12)
  view.pageText = T.Text(view, 11, T.C.muted)
  view.pageText:SetPoint("BOTTOMLEFT", 112, 17)
  view.pageText:SetWidth(142)
  view.pageText:SetJustifyH("CENTER")
  function view:SetStatPage(page)
    ns.UI.Tooltip.Hide()
    self.page = Util.Clamp(math.floor(page or 1), 1, self.pageCount or 1)
    local offset = (self.page - 1) * self.rowsPerPage
    for index = 1, self.rowsPerPage do
      local data, row = self.statEntries[offset + index], self.rows[index]
      if data then
        if not row then
          row = CreateFrame("Frame", nil, self.statsFrame)
          row:SetSize(310, 22)
          row:SetPoint("TOPLEFT", 0, -(index - 1) * 22)
          row:EnableMouse(true)
          row.label = T.Text(row, 11, T.C.muted)
          row.label:SetPoint("LEFT", 0, 0)
          row.label:SetWidth(236)
          row.label:SetJustifyH("LEFT")
          row.value = T.Number(row, 12, T.C.text)
          row.value:SetPoint("RIGHT", -2, 0)
          row:SetScript("OnEnter", function(self) inspectStatTooltip(self, view.context) end)
          row:SetScript("OnLeave", function() ns.UI.Tooltip.Hide() end)
          self.rows[index] = row
        end
        row.statKey = data.key
        row.label:SetText(data.label)
        row.value:SetText(data.value)
        row:Show()
      elseif row then row:Hide() end
    end
    for index = self.rowsPerPage + 1, #self.rows do self.rows[index]:Hide() end
    self.previous:SetEnabled(self.page > 1)
    self.next:SetEnabled(self.page < self.pageCount)
    self.pageText:SetText(string.format(L["Page %d of %d"], self.page, self.pageCount))
    local paged = self.pageCount > 1
    self.previous:SetShown(paged)
    self.next:SetShown(paged)
    self.pageText:SetShown(paged)
  end
  function view:LayoutStats()
    self:SetScale(1)
    local inheritedScale = self:GetEffectiveScale()
    local screenHeight = UIParent:GetHeight() * UIParent:GetEffectiveScale()
    local screenWidth = UIParent:GetWidth() * UIParent:GetEffectiveScale()
    local fit = math.min(1, math.max(0.1, (screenHeight / inheritedScale - 48) / 450), math.max(0.1, (screenWidth / inheritedScale - 48) / 740))
    if fit < 1 then self:SetScale(fit) end
    local height = screenHeight / self:GetEffectiveScale()
    local available = math.max(450, math.floor(height - 48))
    local wanted = math.max(450, 164 + #self.statEntries * 22 + 24)
    self:SetHeight(math.min(wanted, available))
    local paged = wanted > available
    self.rowsPerPage = math.max(1, math.floor((self:GetHeight() - 164 - (paged and 48 or 24)) / 22))
    self.pageCount = math.max(1, math.ceil(#self.statEntries / self.rowsPerPage))
    self.statsFrame:SetHeight(self.rowsPerPage * 22)
    self:SetStatPage(1)
  end
  view.previous:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) view:SetStatPage(view.page - 1) end)
  view.next:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) view:SetStatPage(view.page + 1) end)
  view.statsFrame:EnableMouseWheel(true)
  view.statsFrame:SetScript("OnMouseWheel", function(_, delta)
    if delta ~= 0 then view:SetStatPage(view.page - delta) end
  end)
  view.rows, view.talents = {}, {}
  for index = 1, 3 do
    local row = CreateFrame("Frame", nil, view)
    row:SetSize(334, 76)
    row:SetPoint("TOPLEFT", 388, -164 - (index - 1) * 82)
    row:EnableMouse(true)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(32, 32)
    row.icon:SetPoint("TOPLEFT", 0, -3)
    row.name = T.Text(row, 12, T.C.text)
    row.name:SetPoint("TOPLEFT", 42, -4)
    row.name:SetWidth(178)
    row.name:SetJustifyH("LEFT")
    row.value = T.Number(row, 12, T.C.gold)
    row.value:SetPoint("TOPRIGHT", 0, -4)
    row.bonus = T.Text(row, 11, T.C.muted)
    row.bonus:SetPoint("TOPLEFT", 42, -26)
    row.milestones = T.Text(row, 11, T.C.muted)
    row.milestones:SetPoint("TOPLEFT", 42, -48)
    row:SetScript("OnEnter", function(self)
      local context = view.context
      GameTooltip:SetOwner(self, "ANCHOR_TOP")
      GameTooltip:ClearLines()
      GameTooltip:AddDoubleLine(self.name:GetText(), self.value:GetText(), 1, 0.82, 0, 1, 1, 1)
      for _, line in ipairs(ns.Mastery.Lines(context.classKey, self.spec, self.points)) do
        local prefix = line.points > 0 and string.format(L["%d points: "], line.points) or ""
        local color = line.active and T.C.good or T.C.muted
        local r, g, b = T.RGB(color)
        GameTooltip:AddLine(prefix .. line.text, r, g, b, true)
      end
      GameTooltip:Show()
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    view.talents[index] = row
  end
  function view:Open(sideId, battle, snapshot)
    self.sideId, self.battle = sideId, battle
    renderInspector(self)
    self:Show()
    update(self, snapshot)
  end
  view.Update = update
  view:SetScript("OnHide", function(self)
    self.battle, self.context = nil, nil
    ns.UI.Tooltip.Hide()
  end)
  view:Hide()
  return view
end

