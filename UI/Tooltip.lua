local ADDON, ns = ...
local T = ns.UI.Theme
local Describe = ns.Describe

local Tooltip = {}
ns.UI.Tooltip = Tooltip
local DETAIL_TAGS = ns.Util.Set{ "autoattack", "strike", "finisher", "shot", "spell", "heal", "pet", "bleed", "dot", "hot", "trap", "sting", "shout", "form", "stance", "melee", "ranged", "ammo", "physical", "nature", "arcane", "fire", "frost", "shadow", "holy" }

local function percentage(value)
  return (string.format("%.1f", value):gsub("%.0$", "")) .. "%"
end

local armorReduction = ns.Sim.ArmorReduction

local function armorEffects(def)
  local effects = {}
  local function add(list)
    for _, effect in ipairs(list or {}) do
      if effect.type == "debuff" and effect.stat == "armor" and (effect.value or 0) > 0 then effects[#effects + 1] = effect end
    end
  end
  add(def.use and def.use.effects)
  for _, trigger in ipairs(def.triggers or {}) do add(trigger.effects) end
  return effects
end

function Tooltip.ContextLines(def, context, target)
  local lines = {}
  local function add(text, r, g, b)
    lines[#lines + 1] = { text = text, r = r or 0.75, g = g or 0.75, b = b or 0.75 }
  end
  if context and context.items then
    local item = type(target) == "table" and context.byUid and context.byUid[target.uid]
    local blockerKey = item and item.reason and item.reason:match("^blocked:(.+)$")
    if blockerKey then
      local blocker = ns.ItemsByKey[blockerKey]
      add("Inactive while " .. (blocker and blocker.name or blockerKey) .. " is active.", 1, 0.55, 0.4)
    end
    local missing = {}
    local function check(effects)
      for _, effect in ipairs(effects or {}) do
        if effect.type == "cast" and effect.key then
          local required = ns.ItemsByKey[effect.key]
          local family = required and (required.baseKey or required.key) or effect.key
          local owned = false
          for _, item in ipairs(context.items) do
            if item.def and (item.def.baseKey or item.def.key) == family then owned = true break end
          end
          if not owned and not missing[family] then
            add("Requires " .. (required and required.name or effect.key) .. ".", 1, 0.55, 0.4)
            missing[family] = true
          end
        end
      end
    end
    check(def.use and def.use.effects)
    for _, trigger in ipairs(def.triggers or {}) do check(trigger.effects) end
  end
  if def.coating and context and context.byUid and type(target) == "table" then
    local source = context.byUid[target.uid]
    if source then
      local function names(weapons)
        local out = {}
        for uid in pairs(weapons or {}) do
          local weapon = context.byUid[uid]
          if weapon then out[#out + 1] = weapon.def.name end
        end
        table.sort(out)
        return table.concat(out, ", ")
      end
      local active, conflicts = names(source.coatedWeapons), names(source.coatingConflicts)
      if active ~= "" then add("Coats " .. active .. ".", 0.35, 1, 0.45) end
      if conflicts ~= "" then add("Multiple poisons affect " .. conflicts .. ". Each weapon can have one poison.", 1, 0.55, 0.4)
      elseif active == "" then add("Requires an adjacent equipped melee weapon.", 1, 0.55, 0.4) end
    end
  end
  if def.kind == "weapon" then
    local ranged = ns.IsRangedWeapon(def)
    local item = context and type(target) == "table" and context.byUid and context.byUid[target.uid]
    if item and item.def.id == def.id then
      local attacking, form
      for _, active in ipairs(context.actOrder or {}) do
        if active.enabled and active.uid == item.uid then attacking = true end
        if active.enabled and active.def.replacesWeapon then form = active.def.name end
      end
      if item.equipped == false or item.suppressed then
        add("Unequipped weapon. No stats or effects.", 1, 0.55, 0.4)
      elseif form and not ranged and not attacking then
        add("Weapon attacks replaced by " .. form, 1, 0.75, 0.4)
      elseif not ranged and not attacking and context.weaponRanged and context.weaponRanged.def.weaponType == "wand" then
        add("Weapon attacks replaced by wand", 1, 0.75, 0.4)
      elseif attacking and not ranged and context.weaponMelee and item.uid ~= context.weaponMelee.uid then
        add("Off-hand attacks deal 50% damage.", 1, 0.75, 0.4)
      end
    end
  elseif def.kind == "shield" then
    local item = context and type(target) == "table" and context.byUid and context.byUid[target.uid]
    if item and item.def.id == def.id and not item.equipped then
      add("Inactive shield. No stats or effects.", 1, 0.55, 0.4)
    end
  end

  local rule = Describe.SlotRule(def)
  local equipment = def.kind == "weapon" or def.kind == "shield" or def.kind == "armor"
    or def.kind == "ring" or def.kind == "trinket" or def.kind == "neck" or def.kind == "cloak" or def.kind == "relic"
  if rule and (not equipment or context and context.details) then add(rule) end

  if not context or not context.details then return lines end
  local tags = {}
  local seen = {}
  for _, tag in ipairs(def.tags or {}) do
    if DETAIL_TAGS[tag] and not seen[tag] then tags[#tags + 1] = Describe.TagLabel(tag) seen[tag] = true end
  end
  if #tags > 0 then add("Tags: " .. table.concat(tags, ", ") .. ".") end
  if def.kind == "weapon" then
    local ranged = ns.IsRangedWeapon(def)
    local class = context.classDef
    if ranged then
      add("One ranged weapon attacks, using a separate slot.")
    elseif def.hands == 2 then
      add("A two-handed weapon attacks alone.")
    elseif context.shield then
      add("A shield occupies the off hand.")
    elseif class and class.dualWield then
      add("Dual wield: two one-handed melee weapons can attack.")
    else
      add("One melee weapon can attack at a time.")
    end
    add("Weapons are selected by base damage per second.")
  end

  if context and context.stats and def.stats and (def.stats.armor or 0) > 0 then
    add("Current physical damage reduction: " .. percentage(armorReduction(context.stats.armor) * 100) .. ".")
  end
  for _, effect in ipairs(armorEffects(def)) do
    local knownArmor = context and context.lastOpponentArmor
    local armor = type(knownArmor) == "number" and math.max(0, knownArmor) or 100
    local before = 1 - armorReduction(armor)
    local function increase(stacks)
      return percentage(((1 - armorReduction(armor - effect.value * stacks)) / before - 1) * 100)
    end
    local label = type(knownArmor) == "number" and "vs. last opponent" or "at 100 Armor"
    local value = "+" .. increase(1)
    if effect.stack and (effect.maxStacks or 5) > 1 then value = value .. " to +" .. increase(effect.maxStacks or 5) end
    add(value .. " physical hit damage " .. label .. ".", 0.7, 0.9, 0.7)
  end
  return lines
end

function Tooltip.TypeLine(def, context, target)
  local text = Describe.KindLine(def)
  local item = context and type(target) == "table" and context.byUid and context.byUid[target.uid]
  if def.kind == "shield" then
    if item and item.def.id == def.id and item.equipped then text = text .. " (Off Hand)" end
    return text
  end
  local ranged = ns.IsRangedWeapon(def)
  if def.kind ~= "weapon" or ranged or def.hands ~= 1 or not item or not context.weaponMelee then return text end
  if context.shield and item.enabled and item.uid == context.weaponMelee.uid then return text .. " (Main Hand)" end
  if not context.classDef or not context.classDef.dualWield then return text end
  local weapons = 0
  for _, active in ipairs(context.actOrder or {}) do
    if active.enabled and active.def.kind == "weapon" and active.def.hands == 1
      and not ns.IsRangedWeapon(active.def) then
      weapons = weapons + 1
    end
  end
  if weapons == 2 and item and item.enabled and context.weaponMelee then
    text = text .. (item.uid == context.weaponMelee.uid and " (Main Hand)" or " (Off Hand)")
  end
  return text
end

local function isOurFrame(frame)
  local main = ns.UI.Main and ns.UI.Main.frame
  while frame and main do
    if frame.IsForbidden and frame:IsForbidden() then return false end
    if frame == main then return true end
    frame = frame:GetParent()
  end
  return false
end

local function ownsGameTooltip()
  local current = Tooltip.current
  return current ~= nil and GameTooltip:IsOwned(current.owner) or isOurFrame(GameTooltip:GetOwner())
end

local function trackTooltip(owner, refresh)
  if not Tooltip.watcher then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("MODIFIER_STATE_CHANGED")
    frame:SetScript("OnEvent", function(_, _, key)
      if key ~= "LSHIFT" and key ~= "RSHIFT" then return end
      local current = Tooltip.current
      if current and current.owner:IsShown() and GameTooltip:IsShown() and GameTooltip:IsOwned(current.owner) then current.refresh() end
    end)
    Tooltip.watcher = frame
  end
  Tooltip.current = { owner = owner, refresh = refresh }
end

local function tooltipContext(opts)
  local context = opts.context
  if not context then
    local fighter = opts.fighter
    if not fighter and opts.run then
      fighter = { classKey = opts.run.class, name = opts.run.who, round = opts.run.round, grid = opts.run.grid, talents = opts.run.talents }
    end
    if fighter then
      local ok, preview = pcall(ns.Sim.PreviewStats, fighter)
      if ok then context = preview end
    end
  end
  if not context then return nil end
  local copy = {}
  for key, value in pairs(context) do copy[key] = value end
  local battle = opts.run and opts.run.lastBattle
  local opponent = battle and battle.result and battle.result.B
  if opponent and opponent.stats then copy.lastOpponentArmor = opponent.stats.armor end
  return copy
end

local function classList(def)
  if not def.classes then return nil end
  local names = {}
  for _, key in ipairs(def.classes) do
    local c = ns.Classes[key]
    if c then names[#names + 1] = T.ClassHex(key) .. c.name .. "|r" end
  end
  return table.concat(names, ", ")
end

local function positionAbove(left, right, anchor)
  local parentScale = UIParent:GetEffectiveScale()
  local anchorScale = (anchor:GetParent() or anchor):GetEffectiveScale() / parentScale
  local leftScale = left:GetEffectiveScale() / parentScale
  local leftWidth = left:GetWidth() * leftScale
  local height = left:GetHeight() * leftScale
  local gap, margin = 8, 8
  local width = leftWidth
  if right then
    local rightScale = right:GetEffectiveScale() / parentScale
    width = width + gap + right:GetWidth() * rightScale
    height = math.max(height, right:GetHeight() * rightScale)
  end
  local center = anchor:GetCenter()
  local maximumX = math.max(margin, UIParent:GetWidth() - width - margin)
  local maximumY = math.max(margin, UIParent:GetHeight() - height - margin)
  local x = math.max(margin, math.min(maximumX, center * anchorScale - width / 2))
  local y = math.max(margin, math.min(maximumY, anchor:GetTop() * anchorScale + gap))
  left:ClearAllPoints()
  left:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)
  if right then
    right:ClearAllPoints()
    right:SetPoint("BOTTOMLEFT", left, "BOTTOMRIGHT", gap, 0)
  end
end

local function hideEquipmentComparisons()
  for _, tooltip in ipairs(Tooltip.equipmentTooltips or {}) do tooltip:Hide() end
  if Tooltip.equipmentScale then
    GameTooltip:SetScale(Tooltip.equipmentScale)
    Tooltip.equipmentScale = nil
  end
  Tooltip.equipmentComparison = nil
end

function Tooltip.EquippedItems(def, context, target)
  local out = {}
  if not context then return out end
  local targetUid = type(target) == "table" and target.uid
  local function add(item)
    if not item or item.suppressed or #out >= 2 or targetUid and item.uid == targetUid then return end
    for _, existing in ipairs(out) do if existing.uid == item.uid then return end end
    out[#out + 1] = item
  end
  if ns.IsRangedWeapon(def) then
    if context.weaponRanged and context.weaponRanged.enabled then add(context.weaponRanged) end
  elseif def.kind == "weapon" or def.kind == "shield" then
    if context.weaponMelee and context.weaponMelee.enabled then add(context.weaponMelee) end
    if context.shield and context.shield.equipped then
      add(context.shield)
    else
      for _, item in ipairs(context.items or {}) do
        if item.def.kind == "weapon" and not ns.IsRangedWeapon(item.def) and item.enabled then add(item) end
      end
    end
  else
    local slot = ns.Grid.EquipmentSlot(def)
    if slot then
      for _, item in ipairs(context.items or {}) do
        if ns.Grid.EquipmentSlot(item.def) == slot then add(item) end
      end
    end
  end
  return out
end

local function positionEquipment(tooltips, owner)
  local margin, gap = 8, 8
  local parentScale = UIParent:GetEffectiveScale()
  local screenWidth, screenHeight = UIParent:GetWidth(), UIParent:GetHeight()
  local width, height = 0, 0
  for _, tooltip in ipairs(tooltips) do
    local scale = tooltip:GetEffectiveScale() / parentScale
    width = width + tooltip:GetWidth() * scale
    height = math.max(height, tooltip:GetHeight() * scale)
  end
  local spaces = gap * (#tooltips - 1)
  local shrink = math.min(1, math.max(1, screenWidth - margin * 2 - spaces) / width, math.max(1, screenHeight - margin * 2) / height)
  if shrink < 1 then
    for _, tooltip in ipairs(tooltips) do tooltip:SetScale(tooltip:GetScale() * shrink) end
    width, height = width * shrink, height * shrink
  end
  width = width + spaces
  local ownerScale = owner:GetEffectiveScale() / parentScale
  local x = owner:GetRight() * ownerScale + gap
  if x + width > screenWidth - margin then x = owner:GetLeft() * ownerScale - gap - width end
  x = math.max(margin, math.min(math.max(margin, screenWidth - width - margin), x))
  local top = math.max(height + margin, math.min(screenHeight - margin, owner:GetTop() * ownerScale))
  for index, tooltip in ipairs(tooltips) do
    tooltip:ClearAllPoints()
    if index == 1 then tooltip:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, top)
    else tooltip:SetPoint("TOPLEFT", tooltips[index - 1], "TOPRIGHT", gap, 0) end
  end
end

function Tooltip.Show(owner, def, opts)
  opts = opts or {}
  if not opts.comparisonMember then
    hideEquipmentComparisons()
    if Tooltip.rankComparisonTooltip then Tooltip.rankComparisonTooltip:Hide() end
  end
  local tooltip = opts.tooltip or GameTooltip
  local context = tooltipContext(opts) or {}
  context.details = IsShiftKeyDown and IsShiftKeyDown() or false
  local hasDetails = def.classes ~= nil or #(def.tags or {}) > 0 or def.kind == "weapon"
  tooltip:SetOwner(owner, opts.above and "ANCHOR_NONE" or opts.anchor or "ANCHOR_RIGHT")
  tooltip:ClearLines()
  if opts.label then tooltip:AddLine(opts.label, 1, 0.82, 0) end
  local r, g, b = T.QualityColor(def.quality)
  if def.rank or def.rankable and ns.Ranks.TrainableMaxRank(def) > 1 then
    tooltip:AddDoubleLine(def.name, string.format(ns.L["Rank %d"], def.rank or 1), r, g, b, 1, 1, 1)
  else
    tooltip:AddLine(def.name, r, g, b)
  end
  tooltip:AddLine(Tooltip.TypeLine(def, context, opts.target), 0.75, 0.75, 0.75)
  for _, line in ipairs(Describe.Lines(def, context)) do
    tooltip:AddLine(line.text, line.color.r, line.color.g, line.color.b, true)
  end
  local contextLines = Tooltip.ContextLines(def, context, opts.target)
  local contextAdded = false
  for _, line in ipairs(contextLines) do
    if not contextAdded then tooltip:AddLine(" ") contextAdded = true end
    tooltip:AddLine(line.text, line.r, line.g, line.b, true)
  end
  if def.set then
    tooltip:AddLine(" ")
    local owned = opts.run and opts.run:SetPieces()[def.set] or context.setCounts and context.setCounts[def.set] or {}
    for _, line in ipairs(Describe.SetLines(def.set, owned)) do
      tooltip:AddLine(line.text, line.color.r, line.color.g, line.color.b, true)
    end
  end
  local recipes = ns.Crafting.RecipesFor(def)
  if #recipes > 0 then
    tooltip:AddLine(" ")
    for _, recipe in ipairs(recipes) do
      local parts = {}
      for _, key in ipairs(recipe.inputs) do
        if key ~= def.key then
          local other = ns.ItemsByKey[key]
          parts[#parts + 1] = other and (T.QualityHex(other.quality) .. other.name .. "|r") or key
        end
      end
      local output = ns.ItemsByKey[recipe.output]
      tooltip:AddLine(string.format(ns.L["Place next to %s to create %s."], table.concat(parts, ns.L[" and "]), output and (T.QualityHex(output.quality) .. output.name .. "|r") or recipe.output), 1, 0.82, 0, true)
    end
  end
  if def.craftable then
    tooltip:AddLine(ns.L["Crafted by combining its components in your bag."], 1, 0.82, 0, true)
  end
  local classes = classList(def)
  if classes and context.details then tooltip:AddLine(ns.L["Classes: "] .. classes, 1, 1, 1, true) end
  if opts.price == "buy" then
    tooltip:AddLine(" ")
    local price = def.cost
    if opts.run and opts.index then price = opts.run:OfferPrice(opts.index) or price end
    if price < def.cost then
      tooltip:AddDoubleLine(ns.L["On sale"], T.GOLD_ICON .. " " .. price, 0.4, 1, 0.4, 0.4, 1, 0.4)
    else
      tooltip:AddDoubleLine(ns.L["Cost"], T.GOLD_ICON .. " " .. price, 1, 1, 1, 1, 1, 1)
    end
    if opts.gold and opts.gold < price then tooltip:AddLine(ns.L["Not enough gold"], 1, 0.3, 0.3) end
  elseif opts.price == "sell" then
    tooltip:AddLine(" ")
    local price = opts.run and opts.run:SellPrice(def) or ns.Economy.SellPrice(def)
    tooltip:AddDoubleLine(ns.L["Sells for"], T.GOLD_ICON .. " " .. price, 1, 1, 1, 1, 1, 1)
  end
  local rankHint = opts.run and opts.target and (def.rankable or def.rank) and opts.run:TrainingInfo(opts.target)
  if opts.extra then
    for _, line in ipairs(opts.extra) do tooltip:AddLine(line.text, line.r or 1, line.g or 1, line.b or 1, true) end
  end
  if rankHint and hasDetails and not context.details then
    tooltip:AddDoubleLine(ns.L["Right-click: ranks"], ns.L["Shift: details"], 1, 0.82, 0, 0.6, 0.6, 0.6)
  elseif rankHint then
    tooltip:AddLine(ns.L["Right-click: ranks"], 1, 0.82, 0, true)
  elseif hasDetails and not context.details then
    tooltip:AddLine(ns.L["Hold Shift for more details"], 0.6, 0.6, 0.6, true)
  end
  tooltip:Show()
  if opts.above and not opts.comparisonMember then positionAbove(tooltip, nil, opts.above) end
  if not opts.comparisonMember then trackTooltip(owner, function() Tooltip.Show(owner, def, opts) end) end
  return tooltip
end

function Tooltip.ShowEquipmentComparison(owner, def, opts)
  hideEquipmentComparisons()
  if Tooltip.rankComparisonTooltip then Tooltip.rankComparisonTooltip:Hide() end
  local options = {}
  for key, value in pairs(opts or {}) do options[key] = value end
  local context = tooltipContext(options)
  local equipped = Tooltip.EquippedItems(def, context, options.target)
  if #equipped == 0 then return Tooltip.Show(owner, def, opts) end
  Tooltip.equipmentScale = GameTooltip:GetScale()
  options.context, options.tooltip, options.comparisonMember = context, GameTooltip, true
  options.anchor, options.above = "ANCHOR_NONE", nil
  Tooltip.Show(owner, def, options)
  local tooltips = { GameTooltip }
  Tooltip.equipmentTooltips = Tooltip.equipmentTooltips or {}
  for index, item in ipairs(equipped) do
    local tooltip = Tooltip.equipmentTooltips[index]
    if not tooltip then
      tooltip = CreateFrame("GameTooltip", "BagnonBattlesEquippedTooltip" .. index, UIParent, "GameTooltipTemplate")
      tooltip:SetFrameStrata("TOOLTIP")
      tooltip:SetClampedToScreen(true)
      Tooltip.equipmentTooltips[index] = tooltip
    end
    tooltip:SetScale(GameTooltip:GetScale())
    local comparison = {}
    for key, value in pairs(options) do comparison[key] = value end
    comparison.tooltip, comparison.target = tooltip, item.placement
    comparison.price, comparison.gold, comparison.index = "sell", nil, nil
    comparison.extra, comparison.label = nil, ns.L["Equipped"]
    Tooltip.Show(owner, item.def, comparison)
    tooltips[#tooltips + 1] = tooltip
  end
  positionEquipment(tooltips, owner)
  Tooltip.equipmentComparison = { candidate = GameTooltip, equipped = equipped, tooltips = tooltips }
  trackTooltip(owner, function() Tooltip.ShowEquipmentComparison(owner, def, opts) end)
  return GameTooltip
end

function Tooltip.ShowRankComparison(owner, previous, nextRank, opts)
  hideEquipmentComparisons()
  if not previous then return Tooltip.Show(owner, nextRank, opts) end
  if not Tooltip.rankComparisonTooltip then
    local tooltip = CreateFrame("GameTooltip", "BagnonBattlesRankComparisonTooltip", UIParent, "GameTooltipTemplate")
    tooltip:SetFrameStrata("TOOLTIP")
    tooltip:SetClampedToScreen(true)
    Tooltip.rankComparisonTooltip = tooltip
  end
  local shared = {}
  for key, value in pairs(opts or {}) do shared[key] = value end
  shared.anchor, shared.comparisonMember = "ANCHOR_NONE", true
  shared.price, shared.gold, shared.index, shared.target = nil, nil, nil, nil
  shared.tooltip = GameTooltip
  Tooltip.Show(owner, previous, shared)
  local nextOptions = {}
  for key, value in pairs(shared) do nextOptions[key] = value end
  local right = Tooltip.rankComparisonTooltip
  nextOptions.tooltip = right
  right:SetScale(GameTooltip:GetScale())
  Tooltip.Show(owner, nextRank, nextOptions)
  positionAbove(GameTooltip, right, opts and opts.above or owner)
  trackTooltip(owner, function() Tooltip.ShowRankComparison(owner, previous, nextRank, opts) end)
end

function Tooltip.ShowStat(owner, stat, context)
  if not stat or not context then return end
  hideEquipmentComparisons()
  if Tooltip.rankComparisonTooltip then Tooltip.rankComparisonTooltip:Hide() end
  local details = IsShiftKeyDown and IsShiftKeyDown() or false
  GameTooltip:SetOwner(owner, "ANCHOR_TOP")
  GameTooltip:ClearLines()
  local title = owner.label and owner.label:GetText() or stat
  local value = owner.value and owner.value:GetText() or ""
  GameTooltip:AddDoubleLine(title, value, 1, 0.82, 0, 1, 1, 1)
  local lines = Describe.StatLines(stat, context, details)
  for _, line in ipairs(lines) do
    local color = line.color or {}
    GameTooltip:AddLine(line.text, color.r or color[1] or 0.8, color.g or color[2] or 0.8, color.b or color[3] or 0.8, true)
  end
  if not details and #Describe.StatLines(stat, context, true) > #lines then
    GameTooltip:AddLine(ns.L["Hold Shift for more details"], 0.6, 0.6, 0.6, true)
  end
  GameTooltip:Show()
  trackTooltip(owner, function() Tooltip.ShowStat(owner, stat, context) end)
end

function Tooltip.Hide()
  hideEquipmentComparisons()
  if ownsGameTooltip() then GameTooltip:Hide() end
  Tooltip.current = nil
  if Tooltip.rankComparisonTooltip then Tooltip.rankComparisonTooltip:Hide() end
end
