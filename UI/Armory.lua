local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L
local Describe = ns.Describe

local Armory = {}
ns.UI.Armory = Armory

local PAGE_SIZE = 8
local FILTER_W = 210
local CARD_LEFT = FILTER_W + 28
local CATEGORIES = { { "all", "All" }, { "abilities", "Abilities" }, { "gear", "Gear" }, { "bags", "Bags" } }
local ABILITY_MODES = { { "active", "Active" }, { "passives", "Passive" } }
local RARITIES = { { 1, "Common" }, { 2, "Uncommon" }, { 3, "Rare" }, { 4, "Epic" }, { 5, "Legendary" } }
local TAGS = {
  { "cat", "Cat Form", "DRUID" }, { "bear", "Bear Form", "DRUID" },
  { "pet", "Pets", "HUNTER" }, { "shot", "Shots", "HUNTER" }, { "sting", "Stings", "HUNTER" }, { "trap", "Traps", "HUNTER" },
  { "aspect", "Aspects", "HUNTER" }, { "ammo", "Ammunition", "HUNTER" },
  { "builder", "Combo Builders", "ROGUE" }, { "finisher", "Finishers", "ROGUE" }, { "opener", "Openers", "ROGUE" },
  { "poison", "Poisons", "ROGUE" }, { "bleed", "Bleeds", "ROGUE" },
  { "shout", "Shouts", "WARRIOR" }, { "bleed", "Bleeds", "WARRIOR" },
  { "seal", "Seals", "PALADIN" }, { "judgement", "Judgement", "PALADIN" }, { "aura", "Auras", "PALADIN" }, { "blessing", "Blessings", "PALADIN" },
  { "totem", "Totems", "SHAMAN" }, { "shock", "Shocks", "SHAMAN" }, { "imbue", "Weapon Imbues", "SHAMAN" },
  { "curse", "Curses", "WARLOCK" }, { "pet", "Demons", "WARLOCK" }, { "drain", "Drains", "WARLOCK" },
  { "armor", "Armor Spells", "MAGE" }, { "armor", "Armor Spells", "WARLOCK" },
  { "heal", "Healing" }, { "dot", "Damage over Time" }, { "defensive", "Defensive" },
  { "shield", "Shield & Block" }, { "control", "Crowd Control" }, { "mana", "Mana Regeneration" },
}
local function feralForms(i)
  local cat = i.related.catform or i.resources.energy or i.resources.combo
  local bear = i.related.bearform or i.resources.rage or i.tags.bear
  if not cat and not bear and i.related.form then return true, true end
  return cat, bear
end
local TAG_TESTS = {
  cat = function(i) return (feralForms(i)) end,
  bear = function(i) return select(2, feralForms(i)) end,
  pet = function(i) return i.related.pet or i.tags.pet end,
  ammo = function(i) return i.related.ammo or i.tags.ammo end,
  aura = function(i) return i.groups.paladin_aura end,
  blessing = function(i) return i.groups.paladin_blessing end,
  heal = function(i, def)
    return i.effects.heal or i.effects.hot or i.effects.tickHots or i.tags.heal or i.tags.hot or (def.stats.healing or 0) > 0 or (def.stats.lifesteal or 0) > 0
  end,
  dot = function(i) return i.effects.dot or i.effects.tickDots or i.effects.consumeDots or i.triggers.dotTick or i.tags.dot or i.tags.bleed end,
  defensive = function(i)
    return i.tags.defensive or i.effects.absorb or i.buffs.dr or i.buffs.dodge or i.buffs.armor or i.buffs.block or i.buffs.blockChance
  end,
  control = function(i) return i.tags.control or i.effects.stun or i.debuffs.haste end,
  mana = function(i, def) return i.tags.mana_recovery or i.gains.mana or (def.stats.regen or 0) > 0 end,
  shield = function(i, def)
    return i.related.shield or i.triggers.block or i.buffs.block or i.buffs.blockChance or (def.stats.block or 0) > 0 or (def.stats.blockChance or 0) > 0
  end,
}
local ABILITIES = ns.Util.Set{ "ability", "form", "pet", "ammo" }
local screen

local function selected(options)
  local out = {}
  for _, option in ipairs(options) do out[option[1]] = true end
  return out
end

local function specOptions(classKey)
  local options = { { "shared", L["Shared"] } }
  for _, spec in ipairs(ns.Classes[classKey].specs) do options[#options + 1] = { spec.tag, spec.name } end
  return options
end

function Armory.DefaultFilters(classKey)
  return { abilityModes = selected(ABILITY_MODES), specs = selected(specOptions(classKey)), rarities = selected(RARITIES), tags = {} }
end

function Armory.Type(def)
  if ABILITIES[def.kind] then return def.use and "active" or "passives" end
  if def.kind == "bag" then return "bags" end
  if def.kind == "material" then return "materials" end
  return "gear"
end

local function list(value)
  return type(value) == "table" and value or { value }
end

local function inspect(def)
  local info = {
    tags = ns.Util.ShallowCopy(def.tagSet), related = {}, groups = {}, resources = {}, gains = {}, effects = {}, buffs = {}, debuffs = {},
    triggers = {},
  }
  local function relate(flags) for _, flag in ipairs(list(flags)) do info.related[flag] = true end end
  local function condition(value)
    local provided = type(value) == "string" and value:match("^provides:(.+)$")
    if provided then relate(provided) end
  end
  local function reference(key)
    local other = key and ns.ItemsByKey[key]
    if not other or other == def then return end
    for tag in pairs(other.tagSet) do
      if tag ~= "defensive" and tag ~= "control" then info.tags[tag] = true end
    end
    if other.exclusiveGroup then info.groups[other.exclusiveGroup] = true end
    relate(other.provides)
    if other.use then relate(other.use.requires) end
  end
  local function match(filter)
    if not filter then return end
    if filter.tag then info.tags[filter.tag] = true end
    for _, tag in ipairs(filter.anyTag or {}) do info.tags[tag] = true end
    relate(filter.kind)
    reference(filter.key)
  end
  local function effects(entries)
    for _, effect in ipairs(entries or {}) do
      info.effects[effect.type] = true
      match(effect.match)
      match(effect.double)
      if effect.consumeDots then info.effects.consumeDots = true match(effect.consumeDots.match) end
      if effect.type == "resource" then info.resources[effect.resource] = true info.gains[effect.resource] = true end
      if effect.type == "buff" then info.buffs[effect.stat] = true end
      if effect.type == "debuff" then info.debuffs[effect.stat] = true end
      if effect.type == "cast" then reference(effect.key) end
      if effect.pet then relate("pet") end
    end
  end
  if def.kind == "pet" or def.kind == "shield" or def.kind == "ammo" then relate(def.kind) end
  if def.exclusiveGroup then info.groups[def.exclusiveGroup] = true end
  relate(def.provides)
  for resource in pairs(def.grants or {}) do info.resources[resource] = true end
  for _, key in ipairs(def.shopRequires or {}) do reference(key) end
  if def.use then
    relate(def.use.requires)
    condition(def.use.condition)
    if def.use.resource then info.resources[def.use.resource] = true end
    effects(def.use.effects)
  end
  for _, trigger in ipairs(def.triggers) do
    info.triggers[trigger.on] = true
    if trigger.resource then info.resources[trigger.resource] = true end
    condition(trigger.condition)
    match(trigger.match)
    effects(trigger.effects)
  end
  for _, adjacency in ipairs(def.adjacency) do match(adjacency.match) end
  return info
end

local tagCache = {}
function Armory.Tags(def)
  if tagCache[def] then return tagCache[def] end
  local info, tags = inspect(def), {}
  for _, option in ipairs(TAGS) do
    local key = option[1]
    local test = TAG_TESTS[key]
    if test then tags[key] = test(info, def) and true or nil else tags[key] = info.tags[key] end
  end
  tagCache[def] = tags
  return tags
end

local function filterMatches(def, category, filters)
  if not filters then return true end
  if category == "abilities" and filters.abilityModes and not filters.abilityModes[Armory.Type(def)] then return false end
  if filters.specs and not filters.specs[ns.Mastery.Spec(def) or "shared"] then return false end
  if filters.rarities and not filters.rarities[def.quality] then return false end
  local any, matched = false, false
  for tag, checked in pairs(filters.tags or {}) do
    if checked then
      any = true
      if Armory.Tags(def)[tag] then matched = true end
    end
  end
  return not any or matched
end

local function categoryMatches(def, category)
  if category == "abilities" then return ABILITIES[def.kind] end
  if category == "bags" then return def.kind == "bag" end
  if category == "gear" then return def.kind ~= "bag" and not ABILITIES[def.kind] end
  return true
end

local function searchMatches(def, query)
  if query == "" then return true end
  local parts = { def.name, Describe.KindLine(def), ns.QUALITY_NAMES[def.quality] or "" }
  for _, line in ipairs(Describe.Lines(def, { details = false })) do parts[#parts + 1] = line.text end
  for _, key in ipairs(def.classes or {}) do
    local class = ns.Classes[key]
    if class then parts[#parts + 1] = class.name end
  end
  for _, tag in ipairs(def.tags) do parts[#parts + 1] = Describe.TagLabel(tag) end
  return table.concat(parts, " "):lower():find(query, 1, true) ~= nil
end

local function summary(def)
  if def.kind ~= "bag" and not ABILITIES[def.kind] then
    local stats = {}
    for _, line in ipairs(Describe.Lines(def, { details = false })) do
      if line.text:match("^[+-]") then stats[#stats + 1] = line.text end
    end
    if #stats > 0 then return table.concat(stats, ", ") end
  end
  return Describe.Short(def)
end

function Armory.Entries(classKey, category, query, filters)
  local class = ns.Classes[classKey]
  if not class or not class.playable then return {} end
  query = ns.Util.Trim(query or ""):lower()
  local entries, seen = {}, {}
  local function add(def)
    if def.rank or (def.starter and def.noShop) or ns.RETIRED_IDS[def.id] or seen[def.key] then return end
    if not categoryMatches(def, category) or not searchMatches(def, query) or not filterMatches(def, category, filters) then return end
    entries[#entries + 1] = def
    seen[def.key] = true
  end
  for _, def in ipairs(ns.GetShopPool(classKey, ns.Economy.ROUNDS)) do add(def) end
  for _, def in ipairs(ns.ItemList) do
    if def.craftable and def.minRound <= ns.Economy.ROUNDS and ns.ItemOfferedForClass(def, classKey) then add(def) end
  end
  table.sort(entries, function(a, b)
    if a.quality ~= b.quality then return a.quality < b.quality end
    if a.minRound ~= b.minRound then return a.minRound < b.minRound end
    if a.kind ~= b.kind then return a.kind < b.kind end
    if a.name == b.name then return a.key < b.key end
    return a.name < b.name
  end)
  return entries
end

local function tooltip(card, def)
  if not def then return end
  ns.UI.Tooltip.Show(card, def, { context = screen.context })
end

local function refreshCards()
  ns.UI.Tooltip.Hide()
  screen.rankPages = screen.rankPages or {}
  local pages = math.max(1, math.ceil(#screen.entries / PAGE_SIZE))
  screen.page = math.max(1, math.min(pages, screen.page))
  screen.pageLabel:SetText(string.format("%d / %d", screen.page, pages))
  screen.previous:SetEnabled(screen.page > 1)
  screen.next:SetEnabled(screen.page < pages)
  screen.empty:SetShown(#screen.entries == 0)
  screen.count:SetText(string.format(L["%s: %d items"], ns.Classes[screen.classKey].name, #screen.entries))
  for i, card in ipairs(screen.cards) do
    local base = screen.entries[(screen.page - 1) * PAGE_SIZE + i]
    card.base = base
    if base then
      local rank = screen.ranks[base.key] or 1
      if not ns.Ranks.Definition(base, rank) then rank = 1 screen.ranks[base.key] = rank end
      local def = ns.Ranks.Definition(base, rank)
      card.def = def
      card.name:SetText(def.name)
      card.name:SetTextColor(T.QualityColor(def.quality))
      card.kind:SetText(Describe.KindLine(def))
      card.summary:SetText(summary(def))
      T.SetItemIcon(card.iconSlot.icon, def.icon)
      card.iconSlot:SetQuality(def.quality)
      ns.UI.GridView.SetRankBadge(card.iconSlot, def)
      card.glyph:SetItem(def)
      card.price:SetText(tostring(base.cost))
      card.price:SetWidth(math.ceil(card.price:GetStringWidth()))
      local slots = ns.Ranks.MaxRank(base) > 3 and 5 or 3
      local ranks, rankPage, rankPages = ns.Ranks.Page(base, screen.rankPages[base.key], slots, rank)
      screen.rankPages[base.key] = rankPage
      card.rankPage = rankPage
      local paged = rankPages > 1 and base.rankable == true
      card.previousRankPage:SetShown(paged)
      card.nextRankPage:SetShown(paged)
      card.previousRankPage:SetEnabled(rankPage > 1)
      card.nextRankPage:SetEnabled(rankPage < rankPages)
      local width, gap = slots > 3 and (paged and 34 or 36) or 55, 2
      local right = paged and 32 or 10
      card.previousRankPage:ClearAllPoints()
      card.previousRankPage:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -right - slots * (width + gap) - 1, 9)
      local glyphRight = base.rankable == true and right + slots * (width + gap) + 7 or 12
      card.glyph:ClearAllPoints()
      card.glyph:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -glyphRight, 10)
      for number, button in ipairs(card.rankButtons) do
        local actualRank = ranks[number]
        button.rank = actualRank
        button.def = actualRank and ns.Ranks.Definition(base, actualRank)
        button:SetShown(base.rankable == true and button.def ~= nil)
        button:SetHighlighted(actualRank == rank)
        button:SetText(actualRank and (paged and tostring(actualRank) or string.format(L["Rank %d"], actualRank)) or "")
        button:SetWidth(width)
        button:ClearAllPoints()
        button:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -right - (slots - number) * (width + gap), 9)
      end
      card:Show()
    else
      card.def = nil
      card:Hide()
    end
  end
end

local refresh

local function tagOptions(classKey)
  local counts, abilities, options = {}, {}, {}
  for _, def in ipairs(Armory.Entries(classKey, "all")) do
    for tag in pairs(Armory.Tags(def)) do
      counts[tag] = (counts[tag] or 0) + 1
      if ABILITIES[def.kind] then abilities[tag] = true end
    end
  end
  for _, option in ipairs(TAGS) do
    local key = option[1]
    if abilities[key] and counts[key] >= 2 and (not option[3] or option[3] == classKey) then options[#options + 1] = option end
  end
  return options
end

local function refreshFilters()
  local options = { specs = specOptions(screen.classKey), rarities = RARITIES, tags = tagOptions(screen.classKey) }
  local y = 0
  for _, key in ipairs({ "specs", "rarities", "tags" }) do
    local group = screen.filterGroups[key]
    group:ClearAllPoints()
    group:SetPoint("TOPLEFT", screen.filtersPanel, "TOPLEFT", 0, -y)
    group.options = options[key]
    for index, option in ipairs(group.options) do
      local checkbox = group.checks[index]
      if not checkbox then
        checkbox = T.CreateCheck(group, L[option[2]], function(checked)
          screen.filters[key][group.checks[index].key] = checked
          refresh()
        end)
        checkbox:SetSize(20, 20)
        checkbox.label:SetFont(T.FONT, 11, "")
        checkbox:SetHitRectInsets(0, group.columns == 1 and -165 or -77, 0, 0)
        group.checks[index] = checkbox
      end
      checkbox.key = option[1]
      checkbox.label:SetText(L[option[2]])
      checkbox:SetChecked(screen.filters[key][option[1]] == true)
      checkbox:ClearAllPoints()
      checkbox:SetPoint("TOPLEFT", group, "TOPLEFT", ((index - 1) % group.columns) * 103, -20 - math.floor((index - 1) / group.columns) * 20)
      checkbox:Show()
    end
    for index = #group.options + 1, #group.checks do group.checks[index]:Hide() end
    local height = 20 + math.ceil(#group.options / group.columns) * 20
    group:SetHeight(height)
    y = y + height + 10
  end
end

refresh = function()
  screen.entries = Armory.Entries(screen.classKey, screen.category, screen.query, screen.filters)
  screen.page = 1
  for _, button in ipairs(screen.classButtons) do button:SetHighlighted(button.classKey == screen.classKey) end
  for _, button in ipairs(screen.categories) do button:SetHighlighted(button.category == screen.category) end
  screen.abilityModeGroup:SetShown(screen.category == "abilities")
  for _, checkbox in ipairs(screen.abilityModeGroup.checks) do checkbox:SetChecked(screen.filters.abilityModes[checkbox.key] == true) end
  refreshFilters()
  local class = ns.Classes[screen.classKey]
  screen.context = { classDef = class, classKey = class.key, res = class.resources }
  refreshCards()
end

local function turnPage(direction)
  local previous = screen.page
  screen.page = screen.page + direction
  refreshCards()
  if screen.page ~= previous then T.PlaySound(T.SOUND_CLICK) end
end

function Armory.Close()
  if screen then screen:Hide() end
end

local function createCard(parent, index)
  local card = T.Panel(parent, "card", { frameType = "Button" })
  local width = (ns.UI.Main.CONTENT_W - CARD_LEFT - 26) / 2
  card:SetSize(width, 132)
  card:SetPoint("TOPLEFT", parent, "TOPLEFT", CARD_LEFT + ((index - 1) % 2) * (width + 10), -120 - math.floor((index - 1) / 2) * 142)
  card.iconSlot = T.CreateSlot(card, 44)
  card.iconSlot:SetPoint("TOPLEFT", 12, -12)
  card.iconSlot:EnableMouse(false)
  card.name = T.Text(card, 14, T.C.text)
  card.name:SetPoint("TOPLEFT", 68, -12)
  card.name:SetWidth(width - 80)
  card.name:SetHeight(20)
  card.name:SetJustifyH("LEFT")
  card.kind = T.Text(card, 11, T.C.muted)
  card.kind:SetPoint("TOPLEFT", 68, -35)
  card.summary = T.Text(card, 11, T.C.good)
  card.summary:SetPoint("TOPLEFT", 12, -64)
  card.summary:SetWidth(width - 24)
  card.summary:SetHeight(26)
  card.summary:SetJustifyH("LEFT")
  card.summary:SetJustifyV("TOP")
  card.price = T.Text(card, 11, T.C.muted)
  card.price:SetPoint("BOTTOMLEFT", 12, 12)
  card.price:SetHeight(14)
  card.price:SetJustifyH("LEFT")
  card.price:SetJustifyV("MIDDLE")
  card.price:SetWordWrap(false)
  card.priceIcon = card:CreateTexture(nil, "ARTWORK")
  card.priceIcon:SetTexture(T.TEX.gold)
  card.priceIcon:SetSize(14, 14)
  card.priceIcon:SetPoint("LEFT", card.price, "RIGHT", 4, 0)
  card.glyph = T.CreateItemGlyph(card, 6)
  card.glyph.maxWidth, card.glyph.maxHeight = 32, 30
  card.glyph:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -188, 10)
  card.rankButtons = {}
  for rank = 1, 5 do
    local button = T.CreateButton(card, string.format(L["Rank %d"], rank), 55, 20, "default", 10)
    button:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10 - (3 - rank) * 57, 9)
    button.rank = rank
    button:SetScript("OnClick", function(self)
      if card.base then screen.ranks[card.base.key] = self.rank refreshCards() T.PlaySound(T.SOUND_CLICK) end
    end)
    button:SetScript("OnEnter", function(self) tooltip(self, self.def) end)
    button:SetScript("OnLeave", ns.UI.Tooltip.Hide)
    card.rankButtons[rank] = button
  end
  card.previousRankPage = T.CreateButton(card, "<", 18, 20, "default", 10)
  card.previousRankPage:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -167, 9)
  card.previousRankPage:SetScript("OnClick", function()
    if card.base then
      screen.rankPages[card.base.key] = (card.rankPage or 1) - 1
      refreshCards()
      T.PlaySound(T.SOUND_CLICK)
    end
  end)
  card.nextRankPage = T.CreateButton(card, ">", 18, 20, "default", 10)
  card.nextRankPage:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT", -10, 9)
  card.nextRankPage:SetScript("OnClick", function()
    if card.base then
      screen.rankPages[card.base.key] = (card.rankPage or 1) + 1
      refreshCards()
      T.PlaySound(T.SOUND_CLICK)
    end
  end)
  card.previousRankPage:Hide()
  card.nextRankPage:Hide()
  card:SetScript("OnEnter", function(self)
    self:SetFillColor(T.RGB(T.C.bg4))
    tooltip(self, self.def)
  end)
  card:SetScript("OnLeave", function(self)
    self:SetFillColor(T.RGB(T.C.bg3))
    ns.UI.Tooltip.Hide()
  end)
  return card
end

local function create(parent)
  screen = T.Panel(parent, "panel")
  screen:SetAllPoints(parent)
  screen:SetFrameLevel(parent:GetFrameLevel() + 30)
  screen:EnableMouse(true)
  screen:EnableMouseWheel(true)
  screen.category, screen.query, screen.page, screen.ranks, screen.rankPages = "all", "", 1, {}, {}
  screen.back = T.CreateButton(screen, L["Back to Camp"], 120, 28, "default", 12)
  screen.back:SetPoint("TOPLEFT", 16, -14)
  screen.back:SetScript("OnClick", function() Armory.Close() T.PlaySound(T.SOUND_CLICK) end)
  screen.title = T.Title(screen, 22, T.C.gold, L["Armory"])
  screen.title:SetPoint("LEFT", screen.back, "RIGHT", 16, 0)
  screen.classButtons = {}
  local classes = ns.PlayableClasses()
  local titleWidth = math.max(84, math.ceil(screen.title:GetStringWidth()))
  screen.title:SetSize(titleWidth, 28)
  screen.title:SetJustifyH("LEFT")
  local classLeft = 16 + screen.back:GetWidth() + 16 + titleWidth + 16
  local buttonWidth = math.min(104, math.floor((ns.UI.Main.CONTENT_W - classLeft - 16 - (#classes - 1) * 4) / #classes))
  for i, class in ipairs(classes) do
    local button = T.CreateButton(screen, class.name, buttonWidth, 28, "default", 12)
    button:SetPoint("TOPLEFT", screen, "TOPLEFT", classLeft + (i - 1) * (buttonWidth + 4), -14)
    button.classKey = class.key
    button:SetScript("OnClick", function(self)
      screen.classKey = self.classKey
      screen.filters.specs = selected(specOptions(self.classKey))
      local relevant = selected(tagOptions(self.classKey))
      for tag in pairs(screen.filters.tags) do if not relevant[tag] then screen.filters.tags[tag] = nil end end
      refresh()
      T.PlaySound(T.SOUND_CLICK)
    end)
    screen.classButtons[i] = button
  end
  screen.categories = {}
  for index, category in ipairs(CATEGORIES) do
    local button = T.CreateButton(screen, L[category[2]], 88, 28, "default", 12)
    button:SetPoint("TOPLEFT", 16 + (index - 1) * 92, -58)
    button.category = category[1]
    button:SetScript("OnClick", function(self) screen.category = self.category refresh() T.PlaySound(T.SOUND_CLICK) end)
    screen.categories[index] = button
  end
  screen.abilityModeGroup = CreateFrame("Frame", nil, screen)
  screen.abilityModeGroup:SetSize(190, 28)
  screen.abilityModeGroup:SetPoint("TOPLEFT", 402, -58)
  screen.abilityModeGroup.checks = {}
  for index, mode in ipairs(ABILITY_MODES) do
    local key = mode[1]
    local checkbox = T.CreateCheck(screen.abilityModeGroup, L[mode[2]], function(checked)
      screen.filters.abilityModes[key] = checked
      refresh()
    end)
    checkbox.key = key
    checkbox:SetSize(20, 20)
    checkbox:SetPoint("LEFT", (index - 1) * 90, 0)
    checkbox:SetHitRectInsets(0, -60, 0, 0)
    checkbox.label:SetFont(T.FONT, 11, "")
    screen.abilityModeGroup.checks[index] = checkbox
  end
  screen.resetFilters = T.CreateButton(screen, L["Reset filters"], 120, 20, "default", 11)
  screen.resetFilters:SetPoint("TOPLEFT", 106, -94)
  screen.resetFilters:SetScript("OnClick", function()
    screen.filters = Armory.DefaultFilters(screen.classKey)
    screen.category = "all"
    screen.query = ""
    screen.search:SetText("")
    screen.searchHint:Show()
    refresh()
    T.PlaySound(T.SOUND_CLICK)
  end)
  screen.filtersTitle = T.Text(screen, 12, T.C.muted, L["Filters"])
  screen.filtersTitle:SetPoint("TOPLEFT", 18, -99)
  screen.filtersPanel = CreateFrame("Frame", nil, screen)
  screen.filtersPanel:SetSize(FILTER_W, 570)
  screen.filtersPanel:SetPoint("TOPLEFT", 16, -120)
  screen.filterGroups = {}
  for _, row in ipairs({ { "specs", "Spec", 1 }, { "rarities", "Rarity", 2 }, { "tags", "Tags", 1 } }) do
    local key = row[1]
    local group = CreateFrame("Frame", nil, screen.filtersPanel)
    group:SetWidth(FILTER_W)
    group.checks, group.columns = {}, row[3]
    group.title = T.Text(group, 12, T.C.gold, L[row[2]])
    group.title:SetPoint("TOPLEFT", 2, -1)
    for _, choice in ipairs({ { "all", "All", true, -40 }, { "none", "None", false, 0 } }) do
      local button = T.CreateButton(group, L[choice[2]], 38, 18, "default", 10)
      button:SetPoint("TOPRIGHT", choice[4], 0)
      button:SetScript("OnClick", function()
        screen.filters[key] = choice[3] and selected(group.options) or {}
        refresh()
        T.PlaySound(T.SOUND_CLICK)
      end)
      group[choice[1]] = button
    end
    screen.filterGroups[key] = group
  end
  local searchPanel = T.Panel(screen, "pill")
  searchPanel:SetSize(290, 28)
  searchPanel:SetPoint("TOPRIGHT", -16, -58)
  screen.search = CreateFrame("EditBox", nil, searchPanel)
  screen.search:SetPoint("TOPLEFT", 10, -2)
  screen.search:SetPoint("BOTTOMRIGHT", -10, 2)
  screen.search:SetAutoFocus(false)
  screen.search:SetFont(T.FONT, 12, "")
  screen.search:SetTextColor(T.RGB(T.C.text))
  screen.search:SetMaxLetters(80)
  screen.searchHint = T.Text(searchPanel, 12, T.C.dim, L["Search items"])
  screen.searchHint:SetPoint("LEFT", 10, 0)
  screen.search:SetScript("OnTextChanged", function(self)
    screen.query = self:GetText() or ""
    screen.searchHint:SetShown(screen.query == "")
    if screen.classKey then refresh() end
  end)
  screen.search:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    if self:GetText() ~= "" then self:SetText("") else Armory.Close() end
  end)
  screen.search:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
  screen.count = T.Text(screen, 12, T.C.muted)
  screen.count:SetPoint("TOPLEFT", CARD_LEFT + 2, -99)
  screen.empty = T.Text(screen, 14, T.C.muted, L["No items match your search."])
  screen.empty:SetPoint("CENTER")
  screen.cards = {}
  for i = 1, PAGE_SIZE do screen.cards[i] = createCard(screen, i) end
  screen.pageLabel = T.Number(screen, 13, T.C.muted)
  screen.pageLabel:SetPoint("BOTTOM", 0, 23)
  screen.previous = T.CreateButton(screen, L["Previous"], 100, 26, "default", 12)
  screen.previous:SetPoint("RIGHT", screen.pageLabel, "LEFT", -24, 0)
  screen.previous:SetScript("OnClick", function() turnPage(-1) end)
  screen.next = T.CreateButton(screen, L["Next"], 100, 26, "default", 12)
  screen.next:SetPoint("LEFT", screen.pageLabel, "RIGHT", 24, 0)
  screen.next:SetScript("OnClick", function() turnPage(1) end)
  screen:SetScript("OnMouseWheel", function(_, delta) turnPage(delta > 0 and -1 or 1) end)
  screen:SetScript("OnHide", function()
    screen.search:ClearFocus()
    ns.UI.Tooltip.Hide()
  end)
  screen:Hide()
end

function Armory.Open(parent, classKey)
  if not screen then create(parent) end
  if not ns.Classes[classKey] or not ns.Classes[classKey].playable then classKey = ns.PlayableClasses()[1].key end
  if not screen.filters then screen.filters = Armory.DefaultFilters(classKey) end
  if screen.classKey ~= classKey then
    screen.filters.specs = selected(specOptions(classKey))
    local relevant = selected(tagOptions(classKey))
    for tag in pairs(screen.filters.tags) do if not relevant[tag] then screen.filters.tags[tag] = nil end end
  end
  screen.classKey = classKey
  refresh()
  screen:Show()
end
