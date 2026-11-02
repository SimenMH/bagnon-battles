local ADDON, ns = ...
local T = ns.UI.Theme
local L = ns.L
local Util = ns.Util

local Battle = {}
ns.UI.Battle = Battle
Battle.PROC_DELAY = 0.06
Battle.MAX_PROC_LAG = 0.18
Battle.BURST_DELAY = 0.1
Battle.MAX_BURST_HOLD = 0.8
Battle.MIN_BURST_HITS = 3
Battle.VISUALS_PER_FRAME = 24
Battle.MAX_VISUAL_BACKLOG = 96
Battle.FOUND_TIME = 2.2
Battle.REVEAL_TIME = 0.45
Battle.COUNTDOWN_TIME = 3
Battle.MAJOR_SOUND_INTERVAL = 1
Battle.REGULAR_SOUND_LIMIT = 2
Battle.PROC_SOUND_LIMIT = 3
Battle.PROC_SOUND_INTERVAL = 0.08
Battle.FIGHT_SOUND_GAP = 0.35
Battle.RESULT_SOUND_GAP = 0.15

local screen
local state
local showInspector
local updateInspector

local CONTENT_W = 980
local TOP_H = 36
local HEADER_H = 128
local CENTER_GAP = 104
local PORTRAIT = 64
local BAR_W = CONTENT_W / 2 - CENTER_GAP / 2 - PORTRAIT - 40
local AURA_SIZE = 28
local MAX_AURAS = 12
local LOG_H = 84
local BAG_GAP = 16
local RES_ORDER = { "mana", "rage", "energy", "focus", "combo" }

local function activationKey(event)
  if event.nodeId then
    return (event.side or "") .. ":" .. tostring(event.rootId or 0) .. ":" .. tostring(event.nodeId)
  end
end

local function isActivation(event)
  return event.type == "fire" or event.type == "proc" and event.on ~= "use" and event.on ~= "battleStart"
    or event.type == "damage" and event.extraAttack == true
end

function Battle.BuildPlayback(result, delay)
  delay = delay == nil and Battle.PROC_DELAY or math.max(0, delay)
  local playback = { steps = {}, visuals = {}, activations = {}, holds = {}, time = result.time, duration = result.time, initial = Util.DeepCopy(result.initial or result.timeline[1]) }
  local nextEvent = 1
  local function eventStep(event, index)
    local activation = activationKey(event)
    if activation and isActivation(event) then
      local previous = playback.activations[activation]
      if not previous or event.type == "fire" then playback.activations[activation] = event end
    end
    playback.steps[#playback.steps + 1] = { at = event.t, t = event.t, event = event, index = index }
  end
  for _, snapshot in ipairs(result.timeline) do
    while nextEvent <= #result.events and result.events[nextEvent].t <= snapshot.t + 1e-7 do
      eventStep(result.events[nextEvent], nextEvent)
      nextEvent = nextEvent + 1
    end
    playback.steps[#playback.steps + 1] = { at = snapshot.t, t = snapshot.t, snapshot = snapshot }
  end
  while nextEvent <= #result.events do
    eventStep(result.events[nextEvent], nextEvent)
    nextEvent = nextEvent + 1
  end
  local offset, first = 0, 1
  while first <= #playback.steps do
    local last, tick = first, playback.steps[first].t
    while last < #playback.steps and math.abs(playback.steps[last + 1].t - tick) < 1e-7 do last = last + 1 end
    local groups = {}
    for index = first, last do
      local event = playback.steps[index].event
      if event and event.rootId then
        local group = groups[event.rootId]
        if not group then group = { hits = 0, nodes = {} } groups[event.rootId] = group end
        if event.type == "damage" then
          group.hits = group.hits + 1
          group.nodes[activationKey(event) or "event:" .. tostring(index)] = true
        end
      end
    end
    local beat, previous, hit = 0, nil, false
    for index = first, last do
      local step = playback.steps[index]
      local event = step.event
      local group = event and groups[event.rootId]
      local node = event and (activationKey(event) or "event:" .. tostring(index))
      if group and group.hits >= Battle.MIN_BURST_HITS and group.nodes[node] then
        if previous and (previous ~= node or event.type == "damage" and hit) then beat, hit = beat + 1, false end
        previous = node
        if event.type == "damage" then hit = true end
      end
      step.beat = beat
    end
    local width = delay > 0 and math.min(beat * Battle.BURST_DELAY, Battle.MAX_BURST_HOLD) or 0
    for index = first, last do
      local step = playback.steps[index]
      if step.snapshot then step.beat = beat end
      step.at = step.t + offset + (beat > 0 and width * step.beat / beat or 0)
      step.paced = width > 0
    end
    if width > 0 then
      playback.holds[#playback.holds + 1] = { t = tick, at = tick + offset, finish = tick + offset + width, offset = offset + width }
      offset = offset + width
    end
    first = last + 1
  end
  playback.duration = result.time + offset
  local starts, roots = {}, {}
  local function nodeKey(event, id) return tostring(event.rootId or 0) .. ":" .. tostring(id) end
  for _, step in ipairs(playback.steps) do
    local event = step.event
    if event then
      local root = event.rootId and tostring(event.rootId) or "event:" .. tostring(step.index)
      local at = math.max(step.at, roots[root] or 0)
      local key = event.nodeId and nodeKey(event, event.nodeId)
      if key and not starts[key] then
        local parent = event.parentNodeId and starts[nodeKey(event, event.parentNodeId)]
        if parent and not step.paced then at = math.max(at, parent + delay) end
        at = math.min(at, step.at + (step.paced and 0 or Battle.MAX_PROC_LAG))
        starts[key] = at
      end
      roots[root] = at
      playback.visuals[#playback.visuals + 1] = { at = at, event = event, index = step.index, root = root, paced = step.paced, beat = step.paced and step.at or nil }
    end
  end
  table.sort(playback.visuals, function(a, b)
    if a.at ~= b.at then return a.at < b.at end
    return a.index < b.index
  end)
  return playback
end

function Battle.PlaybackCombatTime(playback, at)
  local low, high, found = 1, #(playback.holds or {}), nil
  while low <= high do
    local middle = math.floor((low + high) / 2)
    if playback.holds[middle].at <= at then found, low = playback.holds[middle], middle + 1 else high = middle - 1 end
  end
  if found then at = at < found.finish and found.t or at - found.offset end
  return math.max(0, math.min(playback.time, at))
end

function Battle.ApplyPlaybackEvent(snapshot, event, result)
  local target = event.target or event.side
  local hp, absorb, res = target and "hp" .. target, target and "abs" .. target, target and "res" .. target
  local amount = event.amount or 0
  if event.type == "damage" or event.type == "dot" or event.type == "thorns" or event.type == "healthCost" then
    if hp then snapshot[hp] = (snapshot[hp] or 0) - amount end
    if absorb then snapshot[absorb] = math.max(0, (snapshot[absorb] or 0) - (event.absorbed or 0)) end
  elseif event.type == "heal" or event.type == "hot" then
    if hp then
      if event.revive then snapshot[hp], snapshot[absorb] = result[target].hpMax, 0
      else snapshot[hp] = math.min(result[target].hpMax, (snapshot[hp] or 0) + amount) end
    end
  elseif event.type == "absorb" and absorb then
    snapshot[absorb] = math.max(0, (snapshot[absorb] or 0) + amount)
  elseif event.type == "resource" and res then
    snapshot[res] = snapshot[res] or {}
    local maximum = result[target].resources[event.resource] or math.huge
    snapshot[res][event.resource] = Util.Clamp((snapshot[res][event.resource] or 0) + amount, 0, maximum)
  elseif event.type == "fatigue" then
    snapshot.hpA, snapshot.hpB = snapshot.hpA - amount, snapshot.hpB - amount
  end
end

local function itemDefinition(key)
  return ns.ItemsByKey[key] or ns.Sim.SourceDefinition(key)
end

function Battle.StopSounds(keepCombat)
  if not state then return end
  for _, handle in ipairs(state.cueHandles or {}) do T.StopSound(handle) end
  state.cueHandles = {}
  state.majorCandidate = nil
  state.procCandidate = nil
  state.resultCue = nil
  if not keepCombat then
    for _, sound in ipairs(state.regularSounds or {}) do T.StopSound(sound.handle) end
    state.regularSounds = {}
    for _, sound in ipairs(state.procSounds or {}) do T.StopSound(sound.handle) end
    state.procSounds = {}
    T.StopSound(state.majorHandle)
    state.majorHandle, state.majorUntil = nil, 0
  end
end

local function queueResultCue(winner)
  if winner ~= "A" and winner ~= "B" then return end
  state.resultCue = { at = GetTime() + Battle.RESULT_SOUND_GAP, winner = winner }
end

local function updateResultCue()
  local cue = state.resultCue
  if not cue or GetTime() < cue.at then return end
  state.resultCue = nil
  if not state.finished or state.paused or not screen:IsVisible() then return end
  local handle = T.PlayResultSound(cue.winner)
  if handle then state.cueHandles[#state.cueHandles + 1] = handle end
end

local function playCue(sound)
  local handle = T.PlaySound(sound)
  if handle then
    state.cueHandles = state.cueHandles or {}
    state.cueHandles[#state.cueHandles + 1] = handle
  end
end

local function queueCombatSound(event, node)
  local side = event.side and state.result[event.side]
  if not side or not event.uid or not side.items[event.uid] then return end
  local extra = event.type == "damage" and event.extraAttack == true
  if event.type ~= "fire" and not extra and not (event.type == "proc" and event.on ~= "use" and event.on ~= "battleStart") then return end
  local info = side.items[event.uid]
  local def = itemDefinition(info.key)
  local family = def and (def.baseKey or def.key)
  local major = family and T.MAJOR_ABILITY_CLIPS[family]
  if major and event.type ~= "fire" then return end
  local proc = event.type == "proc" and family and T.PROC_ABILITY_CLIPS[family]
  local triggered = extra or event.type == "fire" and event.freeCast and event.parentNodeId
  local clip = major or proc or family and T.REGULAR_ABILITY_CLIPS[family]
  if not clip and def and def.kind == "weapon" and (extra or event.type == "fire") then
    clip = def.tagSet.ranged and "quiet569565" or "quiet569098"
  end
  if not clip then return end
  local key = node or "activation:" .. event.side .. ":" .. tostring(event.uid) .. ":" .. tostring(event.t)
  if state.soundedNodes[key] then return end
  state.soundedNodes[key] = true
  if not major and (triggered or proc) then
    local priority = family == "leader_of_the_pack" and 3 or triggered and 2 or 1
    if not state.procCandidate or priority > state.procCandidate.priority then
      state.procCandidate = { clip = clip, priority = priority }
    end
    return
  end
  if major then
    if not state.majorCandidate then state.majorCandidate = clip end
    return
  end
  local now = GetTime()
  if state.paused or state.finished or not screen:IsVisible() or now < state.combatReadyAt then return end
  local active, duplicate = {}, false
  for _, sound in ipairs(state.regularSounds) do
    if sound.expires > now then
      active[#active + 1] = sound
      if sound.clip == clip then duplicate = true end
    end
  end
  state.regularSounds = active
  if duplicate or #active >= Battle.REGULAR_SOUND_LIMIT then return end
  local handle, duration = T.PlayCombatSound(clip)
  if handle then active[#active + 1] = { clip = clip, handle = handle, expires = now + duration } end
end

local function updateCombatSound()
  local major, proc = state.majorCandidate, state.procCandidate
  state.majorCandidate, state.procCandidate = nil, nil
  if not (major or proc) or state.paused or state.finished or not screen:IsVisible() then return end
  local now = GetTime()
  if now < state.combatReadyAt then return end
  if proc then
    local active = {}
    for _, sound in ipairs(state.procSounds) do if sound.expires > now then active[#active + 1] = sound end end
    state.procSounds = active
    if #active < Battle.PROC_SOUND_LIMIT and now - state.lastProcAt + 1e-7 >= Battle.PROC_SOUND_INTERVAL then
      local handle, duration = T.PlayCombatSound(proc.clip)
      if handle then
        active[#active + 1] = { clip = proc.clip, handle = handle, expires = now + duration }
        state.lastProcAt = now
      end
    end
  end
  if major and now >= state.majorUntil and now - state.lastMajorAt + 1e-7 >= Battle.MAJOR_SOUND_INTERVAL then
    local handle, duration = T.PlayCombatSound(major)
    if handle then
      state.majorHandle = handle
      state.majorUntil = now + duration
      state.lastMajorAt = now
      return
    end
  end
end

function Battle.ItemContributions(result, sideId, throughEvent)
  local metrics = {}
  local summary = sideId == "A" and result.A or result.B
  for uid, info in pairs(summary.items) do
    if throughEvent == nil then
      metrics[uid] = { dmg = info.dmg, heal = info.heal, uses = info.fired, procs = info.procs or 0,
        shield = info.shield or 0, extraHits = info.extraHits or 0, resources = Util.ShallowCopy(info.resources or {}) }
    else
      metrics[uid] = { dmg = 0, heal = 0, uses = 0, procs = 0, shield = 0, extraHits = 0, resources = {} }
    end
  end
  if throughEvent == nil then return metrics end
  for index = 1, math.min(throughEvent, #result.events) do
    local event = result.events[index]
    local item = event.side == sideId and metrics[event.uid]
    if item then
      if event.type == "damage" or event.type == "dot" then
        item.dmg = item.dmg + event.amount
        if event.extraAttack then item.extraHits = item.extraHits + 1 end
      elseif event.type == "heal" or event.type == "hot" then item.heal = item.heal + event.amount
      elseif event.type == "fire" then item.uses = item.uses + 1
      elseif event.type == "proc" and event.on ~= "use" and event.on ~= "battleStart" then item.procs = item.procs + 1
      elseif event.type == "absorb" then item.shield = item.shield + event.amount
      elseif event.type == "resource" and event.amount > 0 then
        item.resources[event.resource] = (item.resources[event.resource] or 0) + event.amount
      end
    end
  end
  return metrics
end

local function contributionLines(metrics)
  local parts, support = {}, {}
  for _, entry in ipairs({ { "dmg", "damage" }, { "heal", "healing" }, { "uses", "uses", "use" }, { "procs", "procs", "proc" } }) do
    local amount = metrics[entry[1]]
    if amount > 0 then parts[#parts + 1] = string.format("%d %s", Util.Round(amount), L[(amount == 1 and entry[3]) or entry[2]]) end
  end
  if metrics.shield > 0 then support[#support + 1] = string.format(L["%d shield gained"], Util.Round(metrics.shield)) end
  if metrics.extraHits > 0 then support[#support + 1] = string.format(L[metrics.extraHits == 1 and "%d extra hit" or "%d extra hits"], metrics.extraHits) end
  for _, resource in ipairs(RES_ORDER) do
    local amount = metrics.resources[resource]
    if amount and amount > 0 then support[#support + 1] = string.format(L["%d %s gained"], Util.Round(amount), ns.RESOURCE_NAMES[resource] or resource) end
  end
  return parts, support
end

local function itemExtra(sideId, uid, def)
  local summary = sideId == "A" and state.result.A or state.result.B
  local info = summary.items[uid]
  local extra = {}
  if not info then return extra end
  if info.enabled == false and info.reason and def.kind ~= "weapon" and not (def.use and def.use.requires) then
    extra[#extra + 1] = { text = L["Inactive: needs "] .. (ns.Describe.REQUIRE_LABELS[info.reason] or info.reason), r = 1, g = 0.4, b = 0.4 }
  end
  local throughEvent = state.nextEvent - 1
  if state.finished then throughEvent = nil end
  local metrics = Battle.ItemContributions(state.result, sideId, throughEvent)[uid]
  if metrics then
    local parts, support = contributionLines(metrics)
    if #parts > 0 then extra[#extra + 1] = { text = table.concat(parts, ", "), r = 1, g = 0.82, b = 0 } end
    if #support > 0 then extra[#extra + 1] = { text = table.concat(support, ", "), r = 0.6, g = 0.9, b = 0.7 } end
  end
  return extra
end

local function sideName(id)
  if id == "A" then return state.myName end
  return state.theirName
end

local function displayName(name)
  if ns.IS_FOREVER then return (name:gsub("-", " ")) end
  return name:match("^([^-]+)") or name
end

local function itemName(sideId, uid)
  local summary = sideId == "A" and state.result.A or state.result.B
  local info = summary.items[uid]
  if info then
    local def = itemDefinition(info.key)
    return def and def.name or info.key
  end
  return "?"
end

local function renderBreakdown()
  local view = screen.breakdown
  local sideId = view.sideId or "A"
  local summary = sideId == "A" and state.result.A or state.result.B
  local metrics = Battle.ItemContributions(state.result, sideId)
  local items = {}
  for uid, info in pairs(summary.items) do
    local def = itemDefinition(info.key)
    if def then items[#items + 1] = { uid = uid, def = def, metrics = metrics[uid] } end
  end
  table.sort(items, function(a, b)
    local outputA, outputB = a.metrics.dmg + a.metrics.heal, b.metrics.dmg + b.metrics.heal
    if outputA ~= outputB then return outputA > outputB end
    if a.metrics.procs ~= b.metrics.procs then return a.metrics.procs > b.metrics.procs end
    if a.def.name ~= b.def.name then return a.def.name < b.def.name end
    return tostring(a.uid) < tostring(b.uid)
  end)
  local pageSize = #view.rows
  view.offset = Util.Clamp(math.floor((view.offset or 0) / pageSize) * pageSize, 0, math.max(0, math.floor((#items - 1) / pageSize) * pageSize))
  for index, row in ipairs(view.rows) do
    local item = items[index + view.offset]
    if item then
      row.item = item
      row.sideId = sideId
      T.SetItemIcon(row.icon, item.def.icon)
      row.name:SetText(item.def.name)
      row.name:SetTextColor(T.QualityColor(item.def.quality))
      local _, support = contributionLines(item.metrics)
      if #support > 0 then
        row.detail:SetText(table.concat(support, ", "))
      else
        local stats = {}
        for _, stat in ipairs(ns.Sim.STAT_KEYS) do
          local amount = item.def.stats[stat]
          if amount and amount ~= 0 then stats[#stats + 1] = ns.Describe.FormatStat(stat, amount) end
        end
        row.detail:SetText(#stats > 0 and table.concat(stats, ", ") or item.def.setThreshold and L["Set Bonus"] or ns.Describe.KindLine(item.def))
      end
      for _, entry in ipairs(row.values) do
        local amount = item.metrics[entry.key]
        entry.text:SetText(amount > 0 and tostring(Util.Round(amount)) or "")
      end
      row:Show()
    else
      row.item = nil
      row:Hide()
    end
  end
  view.title:SetText((sideId == "A" and state.myName or state.theirName) .. ": " .. L["Battle Breakdown"])
  view.page:SetText(string.format(L["%d-%d of %d"], #items > 0 and view.offset + 1 or 0, math.min(#items, view.offset + #view.rows), #items))
  view.mine:SetHighlighted(sideId == "A")
  view.theirs:SetHighlighted(sideId == "B")
  view.previous:SetEnabled(view.offset > 0)
  view.nextPage:SetEnabled(view.offset + #view.rows < #items)
end

local function showBreakdown()
  T.PlaySound(T.SOUND_CLICK)
  screen.inspector:Hide()
  screen.breakdown.sideId = "A"
  screen.breakdown.offset = 0
  renderBreakdown()
  screen.breakdown:Show()
end

local function changeBreakdownPage(pages)
  T.PlaySound(T.SOUND_CLICK)
  screen.breakdown.offset = (screen.breakdown.offset or 0) + pages * #screen.breakdown.rows
  ns.UI.Tooltip.Hide()
  renderBreakdown()
end

local function createBreakdown(parent)
  local view = T.Panel(parent, "card")
  view:SetSize(720, 404)
  view:SetPoint("CENTER", screen, "CENTER", 0, 0)
  view:SetFrameLevel(parent:GetFrameLevel() + 10)
  view:EnableMouse(true)
  T.CreateShadow(view, 30, 0.8)
  view.title = T.Title(view, 17, T.C.text)
  view.title:SetPoint("TOPLEFT", 18, -18)
  local close = T.CreateButton(view, L["Close"], 70, 24, "default", 12)
  close:SetPoint("TOPRIGHT", -14, -14)
  close:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) view:Hide() ns.UI.Tooltip.Hide() end)
  view.close = close
  view.mine = T.CreateButton(view, L["You"], 90, 24, "default", 12)
  view.mine:SetPoint("TOPLEFT", 18, -48)
  view.theirs = T.CreateButton(view, L["Opponent"], 90, 24, "default", 12)
  view.theirs:SetPoint("LEFT", view.mine, "RIGHT", 6, 0)
  view.inspect = T.CreateButton(view, L["Stats & Talents"], 130, 24, "default", 12)
  view.inspect:SetPoint("LEFT", view.theirs, "RIGHT", 6, 0)
  view.inspect:SetScript("OnClick", function() showInspector(view.sideId or "A") end)
  for _, entry in ipairs({ { view.mine, "A" }, { view.theirs, "B" } }) do
    local button, sideId = entry[1], entry[2]
    button:SetScript("OnClick", function()
      T.PlaySound(T.SOUND_CLICK)
      view.sideId, view.offset = sideId, 0
      ns.UI.Tooltip.Hide()
      renderBreakdown()
    end)
  end
  local columns = { { key = "dmg", label = "Damage", x = 402 }, { key = "heal", label = "Healing", x = 486 }, { key = "uses", label = "Uses", x = 566 }, { key = "procs", label = "Procs", x = 644 } }
  local itemHeading = T.Text(view, 11, T.C.muted, L["Item"])
  itemHeading:SetPoint("TOPLEFT", 18, -86)
  for _, column in ipairs(columns) do
    local heading = T.Text(view, 11, T.C.muted, L[column.label])
    heading:SetPoint("TOPRIGHT", view, "TOPLEFT", column.x + 36, -86)
  end
  view.rows = {}
  for index = 1, 8 do
    local row = CreateFrame("Frame", nil, view)
    row:SetSize(684, 32)
    row:SetPoint("TOPLEFT", 18, -106 - (index - 1) * 32)
    row:EnableMouse(true)
    row.icon = row:CreateTexture(nil, "ARTWORK")
    row.icon:SetSize(26, 26)
    row.icon:SetPoint("LEFT", 0, 0)
    row.name = T.Text(row, 12, T.C.text)
    row.name:SetPoint("TOPLEFT", 34, -1)
    row.name:SetWidth(300)
    row.name:SetHeight(14)
    row.name:SetWordWrap(false)
    row.name:SetJustifyH("LEFT")
    row.detail = T.Text(row, 10, T.C.muted)
    row.detail:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -1)
    row.detail:SetWidth(300)
    row.detail:SetHeight(12)
    row.detail:SetWordWrap(false)
    row.detail:SetJustifyH("LEFT")
    row.values = {}
    for _, column in ipairs(columns) do
      local value = T.Number(row, 12, column.key == "heal" and T.C.good or T.C.text)
      value:SetPoint("RIGHT", row, "LEFT", column.x + 18, 0)
      row.values[#row.values + 1] = { key = column.key, text = value }
    end
    row:SetScript("OnEnter", function(self)
      if not self.item then return end
      local summary = self.sideId == "A" and state.result.A or state.result.B
      local panel = self.sideId == "A" and screen.mine or screen.theirs
      ns.UI.Tooltip.Show(self, self.item.def, {
        extra = itemExtra(self.sideId, self.item.uid, self.item.def), target = self.item,
        fighter = { classKey = summary.classKey, round = state.run.round, grid = panel.grid.grid, talents = summary.talents },
      })
    end)
    row:SetScript("OnLeave", function() ns.UI.Tooltip.Hide() end)
    view.rows[index] = row
  end
  view.page = T.Text(view, 11, T.C.muted)
  view.page:SetPoint("BOTTOMLEFT", 18, 14)
  local previous = T.CreateButton(view, L["Previous"], 80, 22, "default", 11)
  previous:SetPoint("BOTTOMRIGHT", -106, 10)
  previous:SetScript("OnClick", function() changeBreakdownPage(-1) end)
  local nextPage = T.CreateButton(view, L["Next"], 80, 22, "default", 11)
  nextPage:SetPoint("BOTTOMRIGHT", -18, 10)
  nextPage:SetScript("OnClick", function() changeBreakdownPage(1) end)
  view.previous, view.nextPage = previous, nextPage
  view:EnableMouseWheel(true)
  view:SetScript("OnMouseWheel", function(_, delta)
    if delta == 0 then return end
    changeBreakdownPage((delta > 0 and -1 or 1) * math.ceil(math.abs(delta)))
  end)
  view:SetScript("OnHide", function() ns.UI.Tooltip.Hide() end)
  view:Hide()
  return view
end

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

local function inspectContext(sideId)
  local summary = state.result[sideId]
  local class = ns.GetClass(summary.classKey)
  local context = {
    classKey = summary.classKey, classDef = class, round = state.round, hpMax = summary.hpMax,
    stats = Util.DeepCopy(summary.stats), res = {}, items = {},
    talents = Util.DeepCopy(summary.talents or state.allocations[sideId]),
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

updateInspector = function()
  local view = screen and screen.inspector
  if not view or not view:IsShown() or not state then return end
  local sideId, snapshot = view.sideId, state.display
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

local function renderInspector()
  local view = screen.inspector
  local context = inspectContext(view.sideId)
  view.context = context
  view.title:SetText(sideName(view.sideId) .. ": " .. L["Stats & Talents"])
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

showInspector = function(sideId)
  if not state or not screen or (sideId ~= "A" and sideId ~= "B") then return end
  T.PlaySound(T.SOUND_CLICK)
  ns.UI.Tooltip.Hide()
  screen.breakdown:Hide()
  screen.inspector.sideId = sideId
  renderInspector()
  screen.inspector:Show()
  updateInspector()
end

local function createInspector(parent)
  local view = T.Panel(parent, "card")
  view:SetSize(740, 450)
  view:SetPoint("CENTER", screen, "CENTER", 0, 0)
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
  view.mine:SetScript("OnClick", function() showInspector("A") end)
  view.theirs:SetScript("OnClick", function() showInspector("B") end)
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
  view:SetScript("OnHide", function() ns.UI.Tooltip.Hide() end)
  view:Hide()
  return view
end

local function createAuraRow(parent, right)
  local row = CreateFrame("Frame", nil, parent)
  row:SetSize(MAX_AURAS * (AURA_SIZE + 3), AURA_SIZE)
  row.icons = {}
  for i = 1, MAX_AURAS do
    local f = T.CreateSlot(row, AURA_SIZE)
    if right then
      f:SetPoint("RIGHT", row, "RIGHT", -(i - 1) * (AURA_SIZE + 3), 0)
    else
      f:SetPoint("LEFT", row, "LEFT", (i - 1) * (AURA_SIZE + 3), 0)
    end
    f.border:SetAlpha(1)
    f.time = T.Number(f, 10, T.C.text, nil, "OUTLINE")
    f.time:SetPoint("BOTTOM", f, "BOTTOM", 0, 1)
    f.stacks = T.Number(f, 10, T.C.gold, nil, "OUTLINE")
    f.stacks:SetPoint("TOPRIGHT", f, "TOPRIGHT", -1, -1)
    f:SetScript("OnEnter", function(self)
      self.glow:SetAlpha(0.4)
      if not self.aura then return end
      GameTooltip:SetOwner(self, right and "ANCHOR_LEFT" or "ANCHOR_RIGHT")
      GameTooltip:AddLine(self.aura.name or "?", 1, 1, 1)
      if self.aura.stat then
        GameTooltip:AddLine(ns.Describe.FormatStat(self.aura.stat, self.aura.value or 0), 0.8, 0.8, 0.8)
      elseif self.aura.kind == "dot" then
        GameTooltip:AddLine(L["Damage over time"], 1, 0.4, 0.4)
      elseif self.aura.kind == "hot" then
        GameTooltip:AddLine(L["Heal over time"], 0.4, 1, 0.4)
      end
      GameTooltip:AddLine(string.format(L["%.1fs remaining"], math.max(0, self.aura.expires - state.simTime)), 0.6, 0.6, 0.6)
      GameTooltip:Show()
    end)
    f:SetScript("OnLeave", function(self)
      self.glow:SetAlpha(0)
      if GameTooltip:IsOwned(self) then GameTooltip:Hide() end
    end)
    f:Hide()
    row.icons[i] = f
  end
  return row
end

local function createSide(header, right)
  local side = {}
  local portrait = T.CreatePortrait(header, PORTRAIT)
  if right then portrait:SetPoint("RIGHT", header, "RIGHT", -14, 0) else portrait:SetPoint("LEFT", header, "LEFT", 14, 0) end
  side.portrait = portrait
  side.statsButton = T.CreateButton(header, L["Stats"], PORTRAIT, 22, "default", 11)
  side.statsButton:SetPoint("TOP", portrait, "BOTTOM", 0, -4)
  local sideId = right and "B" or "A"
  side.statsButton:SetScript("OnClick", function() showInspector(sideId) end)
  portrait:EnableMouse(true)
  portrait:SetScript("OnMouseUp", function(_, button) if button == "LeftButton" then showInspector(sideId) end end)

  side.name = T.Title(header, 17, T.C.text)
  side.sub = T.Text(header, 12, T.C.muted)
  if right then
    side.name:SetPoint("TOPRIGHT", header, "TOPRIGHT", -(14 + PORTRAIT + 12), -10)
    side.name:SetJustifyH("RIGHT")
    side.sub:SetPoint("TOPRIGHT", side.name, "BOTTOMRIGHT", 0, -3)
    side.sub:SetJustifyH("RIGHT")
  else
    side.name:SetPoint("TOPLEFT", header, "TOPLEFT", 14 + PORTRAIT + 12, -10)
    side.name:SetJustifyH("LEFT")
    side.sub:SetPoint("TOPLEFT", side.name, "BOTTOMLEFT", 0, -3)
    side.sub:SetJustifyH("LEFT")
  end

  local hp = T.CreateBar(header, BAR_W, 24, 0.3, 0.8, 0.4, right)
  if right then hp:SetPoint("TOPRIGHT", header, "TOPRIGHT", -(14 + PORTRAIT + 12), -44) else hp:SetPoint("TOPLEFT", header, "TOPLEFT", 14 + PORTRAIT + 12, -44) end
  hp.text:SetFont(T.NUMFONT, 14, "OUTLINE")
  side.hp = hp
  side.resBars = {}
  local prev = hp
  for i = 1, 3 do
    local bar = T.CreateBar(header, BAR_W, 10, 0, 0, 1, right)
    if right then bar:SetPoint("TOPRIGHT", prev, "BOTTOMRIGHT", 0, -3) else bar:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -3) end
    bar.text:SetFont(T.NUMFONT, 9, "OUTLINE")
    bar.text:ClearAllPoints()
    if right then bar.text:SetPoint("LEFT", bar, "LEFT", 6, 0) else bar.text:SetPoint("RIGHT", bar, "RIGHT", -6, 0) end
    bar.label = T.Text(bar.textLayer, 9, T.C.text, nil, "OUTLINE")
    if right then bar.label:SetPoint("RIGHT", bar, "RIGHT", -6, 0) else bar.label:SetPoint("LEFT", bar, "LEFT", 6, 0) end
    bar:Hide()
    side.resBars[i] = bar
    prev = bar
  end
  side.channel = T.CreateBar(header, BAR_W, 12, 0.65, 0.3, 0.85, right)
  if right then side.channel:SetPoint("TOPRIGHT", header, "TOPRIGHT", -(14 + PORTRAIT + 12), -110)
  else side.channel:SetPoint("TOPLEFT", header, "TOPLEFT", 14 + PORTRAIT + 12, -110) end
  side.channel.text:SetFont(T.NUMFONT, 10, "OUTLINE")
  side.channel:Hide()
  return side
end

local function createBagPanel(parent, side, right)
  local inset = T.Inset(parent)
  side.inset = inset
  local spot = T.Spotlight(inset)
  spot:SetAlpha(0.3)
  local clip = CreateFrame("Frame", nil, inset)
  clip:SetPoint("TOPLEFT", 6, -6)
  clip:SetPoint("BOTTOMRIGHT", -6, 6)
  if clip.SetClipsChildren then clip:SetClipsChildren(true) end
  side.grid = ns.UI.GridView.New(clip, 56, false, 24, true)
  side.auraRow = createAuraRow(parent, right)
  return inset
end

local floatPool = {}
local FLOAT_TIME = 1.2
local FLOAT_MERGE = 0.18

local function floatText(text, r, g, b, big)
  local event = state.visualEvent or {}
  if not event.uid then return end
  local panel = event.side == "A" and screen.mine or event.side == "B" and screen.theirs
  if not panel then return end
  local sourceFrame = panel.grid:ItemFrame(event.uid)
  if not sourceFrame then return end
  local now = state.eventAt or state.playTime
  local key = event.nodeId and tostring(event.rootId or 0) .. ":" .. tostring(event.nodeId)
  local kind = event.type
  if kind == "damage" or kind == "dot" or kind == "thorns" then kind = "damage"
  elseif kind == "heal" or kind == "hot" then kind = "heal"
  elseif kind == "healthCost" then kind = "cost" end
  local numeric = kind == "damage" or kind == "heal" or kind == "absorb" or kind == "cost"
  local stack = (kind == "heal" or kind == "absorb") and 1 or 0
  local fs, empty, oldest
  for _, entry in ipairs(panel.floatTexts) do
    local active = entry.active and now - entry.start < FLOAT_TIME
    if active and entry.sourceUid == event.uid and entry.stack == stack then fs = entry break end
    if not active and not empty then empty = entry end
    if not oldest or (entry.order or 0) < (oldest.order or 0) then oldest = entry end
  end
  local merge = fs and fs.kind == kind and fs.beat == state.visualBeat and (key and fs.nodeKey == key or now - fs.updated <= FLOAT_MERGE)
  fs = fs or empty or oldest
  if not merge then
    state.floatOrder = (state.floatOrder or 0) + 1
    fs.order = state.floatOrder
    fs.amount, fs.start, fs.nodeKey, fs.crit, fs.beat = 0, now, key, false, state.visualBeat
  end
  local source = event.sourceKey and itemDefinition(event.sourceKey)
  fs.cause = event.masteryName or source and source.name
  fs.sourceUid, fs.sourceSide, fs.sourceKey, fs.kind = event.uid, event.side, event.sourceKey, kind
  fs.anchor, fs.stack, fs.nodeId, fs.baseY = sourceFrame.icon, stack, event.nodeId, 4 + stack * 30
  fs.active, fs.updated, fs.crit = true, now, fs.crit or big
  if numeric then
    fs.amount = fs.amount + (event.amount or 0)
    text = tostring(Util.Round(fs.amount))
    if kind == "heal" then text = "+" .. text
    elseif kind == "cost" then text = "-" .. text
    elseif kind == "absorb" then text = text .. " " .. L["absorb"] end
  elseif kind == "stun" then
    text = L["Stun"]
  end
  fs:SetFont(numeric and T.NUMFONT or T.FONT, numeric and (fs.crit and 19 or 15) or 12, "OUTLINE")
  fs:SetText(text)
  fs:SetTextColor(r, g, b)
  fs:SetAlpha(1)
  fs:ClearAllPoints()
  fs:SetPoint("BOTTOM", fs.anchor, "TOP", 0, fs.baseY)
  fs:Show()
end

local function updateFloats()
  local now = state.playTime
  for _, fs in ipairs(floatPool) do
    if fs.active then
      local age = now - fs.start
      if age >= FLOAT_TIME then
        fs.active = false
        fs:Hide()
      else
        fs:SetAlpha(1 - math.max(0, age - 0.7) / 0.5)
        fs:ClearAllPoints()
        fs:SetPoint("BOTTOM", fs.anchor, "TOP", 0, fs.baseY + age / FLOAT_TIME * 8)
      end
    end
  end
end

local function logLine(e)
  local who = sideName(e.side)
  local color = e.side == "A" and "|cff7ec8ff" or "|cffff8a8a"
  local victim = e.target and sideName(e.target) or ""
  local stamp = string.format("|cff6a6d78%5.1f|r ", e.t)
  if e.type == "fire" and e.freeCast then
    local source = e.sourceKey and itemDefinition(e.sourceKey)
    local cause = e.masteryName and (e.masteryName .. " " .. L["talents"]) or source and source.name
    return stamp .. string.format("%s%s|r: %s %s%s", color, who, itemName(e.side, e.uid), L["(free)"], cause and (" " .. L["from"] .. " " .. cause) or "")
  elseif e.type == "channel" then
    if e.phase == "start" then return stamp .. string.format("%s%s|r: %s %s", color, who, L["Channeling"], itemName(e.side, e.uid)) end
    if e.phase == "interrupt" then return stamp .. string.format("%s%s|r: %s %s", color, who, itemName(e.side, e.uid), L["interrupted"]) end
  elseif e.type == "damage" then
    local r, g, b = T.SchoolColor(e.school)
    local crit = e.crit and (" |cffffe066" .. L["(crit)"] .. "|r") or ""
    local absorbed = e.absorbed and e.absorbed > 0 and string.format(" (%d %s)", e.absorbed, L["absorbed"]) or ""
    local extra = e.extraAttack and (" " .. L["(extra attack)"]) or ""
    return stamp .. string.format("%s%s|r: %s %s %s %s%d|r%s%s%s", color, who, itemName(e.side, e.uid), L["hits"], victim, T.Hex(r, g, b), e.amount, crit, absorbed, extra)
  elseif e.type == "proc" and e.sourceKey and e.on ~= "use" and e.on ~= "battleStart" then
    local summary = e.side == "A" and state.result.A or state.result.B
    local item = summary.items[e.uid]
    local source = itemDefinition(e.sourceKey)
    if item and item.key ~= e.sourceKey and source then
      return stamp .. string.format("%s%s|r: %s %s %s", color, who, itemName(e.side, e.uid), L["triggered by"], source.name)
    end
  elseif e.type == "dot" then
    local r, g, b = T.SchoolColor(e.school)
    return stamp .. string.format("%s%s|r: %s %s %s %s%d|r", color, who, itemName(e.side, e.uid), L["ticks on"], victim, T.Hex(r, g, b), e.amount)
  elseif e.type == "heal" then
    return stamp .. string.format("%s%s|r: %s %s |cff5aff7a%d|r%s", color, who, e.lifesteal and L["Life Steal"] or itemName(e.side, e.uid), L["heals"], e.amount, e.crit and " |cffffe066" .. L["(crit)"] .. "|r" or "")
  elseif e.type == "hot" then
    return stamp .. string.format("%s%s|r: %s %s |cff5aff7a%d|r", color, who, itemName(e.side, e.uid), L["heals"], e.amount)
  elseif e.type == "healthCost" then
    return stamp .. string.format("%s%s|r: %s %s |cffff8080%d|r %s", color, who, itemName(e.side, e.uid), L["pays"], e.amount, L["health"])
  elseif e.type == "dodge" then
    return stamp .. string.format("%s%s|r: %s %s", color, who, itemName(e.side, e.uid), L["was dodged"])
  elseif e.type == "block" then
    return stamp .. string.format("%s%s|r %s %d", color, who, L["blocks"], e.amount)
  elseif e.type == "status" then
    if e.refresh then return nil end
    return stamp .. string.format("%s%s|r: %s %s %s", color, who, itemName(e.side, e.uid), e.kind == "dot" and L["afflicts"] or L["soothes"], victim)
  elseif e.type == "stun" then
    return stamp .. string.format("%s%s|r %s %s %.1fs", color, who, L["stuns"], victim, e.duration)
  elseif e.type == "controlBreak" then
    return stamp .. string.format("%s%s|r breaks crowd control.", color, who)
  elseif e.type == "thorns" then
    return stamp .. string.format("%s%s|r: %s %s |cff5aff7a%d|r", color, who, L["Thorns"], L["hits"], e.amount)
  elseif e.type == "absorb" then
    return stamp .. string.format("%s%s|r %s %d", color, who, L["gains an absorb of"], e.amount)
  elseif e.type == "fatigue" then
    return stamp .. string.format("|cffffa040%s %d|r", L["Fatigue strikes both for"], e.amount)
  elseif e.type == "buff" or e.type == "debuff" then
    if e.refresh then return nil end
    return stamp .. string.format("%s%s|r: %s %s %s", color, who, e.name or L["Effect"], e.type == "buff" and L["empowers"] or L["weakens"], victim)
  end
  return nil
end

local function auraKey(e)
  local kind = (e.type == "status" or e.type == "statusRemoved") and (e.kind or "hot") or e.type
  return table.concat({ e.key or "?", kind, e.side or "?", tostring(e.uid or "?") }, ":")
end

local function trackAura(e)
  local target = e.target
  if e.type == "revive" or e.revive then
    local bucket = target and state.auras[target]
    for key, aura in pairs(bucket or {}) do
      if aura.kind == "dot" or aura.kind == "hot" then bucket[key] = nil end
    end
    return
  end
  if e.type == "statusRemoved" then
    if target and state.auras[target] then state.auras[target][auraKey(e)] = nil end
    return
  end
  if not target or not e.duration then return end
  local bucket = state.auras[target]
  local key = auraKey(e)
  local aura = bucket[key]
  if not aura then
    local helpful = e.type == "buff" or (e.type == "status" and e.kind == "hot")
    aura = { key = key, icon = e.icon or T.TEX.questionMark, name = e.name, kind = e.kind or e.type, stat = e.stat,
      srcSide = e.side, srcUid = e.uid, order = state.auraOrder, helpful = helpful }
    state.auraOrder = state.auraOrder + 1
    bucket[key] = aura
  end
  aura.expires = e.t + e.duration
  aura.stacks = e.stacks or 1
  aura.value = e.value
end

local function renderAuras(row, bucket)
  local list = {}
  for _, aura in pairs(bucket) do
    if aura.expires > state.simTime then list[#list + 1] = aura end
  end
  table.sort(list, function(a, b)
    if a.helpful ~= b.helpful then return a.helpful end
    return a.order < b.order
  end)
  for i, f in ipairs(row.icons) do
    local aura = list[i]
    if aura then
      if f.aura ~= aura then
        T.Pop(f, 1.3, 0.2)
        f.aura = aura
        T.SetItemIcon(f.icon, aura.icon)
        if aura.helpful then f.border:SetColor(T.RGB(T.C.good)) else f.border:SetColor(T.RGB(T.C.bad)) end
      end
      f.icon:Show()
      f.time:SetText(string.format("%d", math.ceil(aura.expires - state.simTime)))
      if aura.stacks and aura.stacks > 1 then f.stacks:SetText(aura.stacks) else f.stacks:SetText("") end
      f:Show()
    else
      f.aura = nil
      f:Hide()
    end
  end
end

local function updateCooldowns()
  if not state or not state.cooldowns then return end
  for sideId, cooldowns in pairs(state.cooldowns) do
    local panel = sideId == "A" and screen.mine or screen.theirs
    for uid, cooldown in pairs(cooldowns) do
      local frame = panel.grid:ItemFrame(uid)
      local remaining = cooldown.paused and cooldown.remaining or cooldown.expires - state.simTime
      if frame and remaining > 0 then
        frame.cooldown:Show()
        frame.cooldown:Pause()
        frame.cooldown:SetCooldown(GetTime() - (cooldown.duration - remaining) / state.speed, cooldown.duration / state.speed)
      else
        if frame then frame.cooldown:Clear() frame.cooldown:Hide() end
        cooldowns[uid] = nil
      end
    end
  end
end

local function stopPausedAnimations()
  for _, group in ipairs(state.pausedAnimations or {}) do group:Stop() end
  state.pausedAnimations = nil
end

local function applyEvent(e)
  Battle.ApplyPlaybackEvent(state.display, e, state.result)
  if e.type == "channel" then
    if e.phase == "start" then
      state.channels[e.side] = { name = itemName(e.side, e.uid), duration = e.duration, endsAt = e.endsAt or e.t + e.duration }
    else
      state.channels[e.side] = nil
    end
  end
  if e.type == "cooldown" then
    if e.cd > 0 then
      state.cooldowns[e.side][e.uid] = { expires = e.t + e.cd, duration = math.max(e.cd, e.duration or e.cd),
        remaining = e.cd, paused = e.paused == true }
    else
      state.cooldowns[e.side][e.uid] = nil
      local panel = e.side == "A" and screen.mine or screen.theirs
      local frame = panel.grid:ItemFrame(e.uid)
      if frame then frame.cooldown:Clear() frame.cooldown:Hide() end
    end
  end
  if e.type == "buff" or e.type == "debuff" or e.type == "status" or e.type == "statusRemoved" or e.type == "revive" or e.revive then trackAura(e) end
  local line = logLine(e)
  if line then screen.log:AddMessage(line) end
end

local function showVisualEvent(e)
  local panel = e.side == "A" and screen.mine or screen.theirs
  local node = activationKey(e)
  if e.uid and e.type ~= "cooldown" and (node and not state.shownNodes[node] or not node and (e.type == "fire" or e.type == "proc")) then
    local frame = panel.grid:ItemFrame(e.uid)
    panel.grid:FlashItem(e.uid, 0.4)
    if node then state.shownNodes[node] = true end
    local activation = node and state.playback.activations[node] or e
    if frame and frame:IsShown() and activation and activation.uid == e.uid and activation.side == e.side then
      queueCombatSound(activation, node)
    end
  end
  state.visualEvent = e
  if e.type == "damage" then
    local r, g, b = T.SchoolColor(e.school)
    floatText(tostring(e.amount), r, g, b, e.crit)
  elseif e.type == "dot" then
    local r, g, b = T.SchoolColor(e.school)
    floatText(tostring(e.amount), r * 0.85, g * 0.85, b * 0.85, false)
  elseif e.type == "heal" or e.type == "hot" then
    if e.amount > 0 then floatText("+" .. e.amount, 0.35, 1, 0.45, e.crit) end
  elseif e.type == "absorb" then
    if e.amount > 0 then floatText(tostring(e.amount), 0.5, 0.8, 1, false) end
  elseif e.type == "healthCost" then
    floatText("-" .. e.amount, 1, 0.45, 0.45, false)
  elseif e.type == "dodge" then
    floatText(L["Dodge"], 1, 1, 1, false)
  elseif e.type == "block" then
    floatText(L["Block"], 0.8, 0.85, 1, false)
  elseif e.type == "stun" then
    floatText(L["Stunned"], 1, 0.65, 0.2, true)
  elseif e.type == "thorns" then
    floatText(tostring(e.amount), 0.4, 1, 0.4, false)
  end
  state.visualEvent = nil
end

local function clearVisualFeedback()
  state.nextVisual = #state.playback.visuals + 1
  for _, fs in ipairs(floatPool) do fs.active = false fs:Hide() end
  for _, panel in ipairs({ screen.mine, screen.theirs }) do
    if panel.inset.bbShake then panel.inset.bbShake:Stop() end
    for _, frame in pairs(panel.grid.itemFrames) do
      if frame.flash.bbFlash then frame.flash.bbFlash:Stop() end
      if frame.bbPop then frame.bbPop:Stop() end
      frame.flash:SetAlpha(0)
    end
  end
end

local function advanceVisuals(at)
  local visuals = state.playback.visuals
  local low, high, last = state.nextVisual, #visuals, state.nextVisual - 1
  while low <= high do
    local middle = math.floor((low + high) / 2)
    if visuals[middle].at <= at + 1e-7 then last, low = middle, middle + 1 else high = middle - 1 end
  end
  local discardThrough = last - Battle.MAX_VISUAL_BACKLOG
  while state.nextVisual <= last do
    local step = visuals[state.nextVisual]
    if state.nextVisual > discardThrough and step.at >= at - Battle.MAX_PROC_LAG - 1e-7 then break end
    if not step.paced then state.droppedVisualRoots[step.root] = true end
    state.nextVisual = state.nextVisual + 1
  end
  local shown = 0
  while state.nextVisual <= last and shown < Battle.VISUALS_PER_FRAME do
    local step = visuals[state.nextVisual]
    if not step.paced and not state.droppedVisualRoots[step.root] then
      state.eventAt, state.visualBeat = at, step.beat
      showVisualEvent(step.event)
      shown = shown + 1
    end
    state.nextVisual = state.nextVisual + 1
  end
  state.eventAt, state.visualBeat = nil, nil
end

local function updatePanelBars(panel, summary, hp, absorb, res, instant)
  panel.hp:SetValue(hp, summary.hpMax, true)
  panel.hp.text:SetText(string.format("%d / %d", Util.Round(hp), summary.hpMax))
  local f = summary.hpMax > 0 and hp / summary.hpMax or 0
  if f > 0.5 then panel.hp:SetColor(0.3, 0.78, 0.4) elseif f > 0.25 then panel.hp:SetColor(0.9, 0.72, 0.25) else panel.hp:SetColor(0.9, 0.3, 0.3) end
  panel.hp:SetAbsorb(absorb or 0)
  local i = 0
  for _, resKey in ipairs(RES_ORDER) do
    local max = summary.resources and summary.resources[resKey]
    if max and max > 0 and i < #panel.resBars then
      i = i + 1
      local bar = panel.resBars[i]
      bar:Show()
      local cur = res and res[resKey] or 0
      bar:SetValue(cur, max, instant)
      bar:SetColor(T.ResourceColor(resKey))
      bar.text:SetText(string.format("%d", Util.Round(cur)))
      bar.label:SetText(ns.RESOURCE_NAMES[resKey] or resKey)
    end
  end
  for j = i + 1, #panel.resBars do panel.resBars[j]:Hide() end
end

local function updateBars(instant)
  local snap = state.display
  if not snap then return end
  updatePanelBars(screen.mine, state.result.A, math.max(0, snap.hpA), snap.absA, snap.resA, instant)
  updatePanelBars(screen.theirs, state.result.B, math.max(0, snap.hpB), snap.absB, snap.resB, instant)
  for _, sideId in ipairs({ "A", "B" }) do
    local panel = sideId == "A" and screen.mine or screen.theirs
    local channel = state.channels[sideId]
    local remaining = channel and channel.endsAt - state.simTime or 0
    if remaining > 0 and not state.finished then
      panel.channel:SetValue(remaining, channel.duration, true)
      panel.channel.text:SetText(string.format("%s %.1fs", channel.name, remaining))
      panel.channel:Show()
    else
      panel.channel:Hide()
    end
  end
  screen.timer:SetText(string.format("%.1fs", state.simTime))
  renderAuras(screen.mine.auraRow, state.auras.A)
  renderAuras(screen.theirs.auraRow, state.auras.B)
  updateInspector()
end

local function updateProgress()
  local record = state.finished and state.progressAfter or state.progressBefore
  screen.wins:SetFilled(math.min(record.wins, ns.Economy.MAX_WINS))
  screen.lives:SetFilled(ns.Economy.LivesRemaining(record))
end

local function setIntroReveal(alpha)
  screen.header:SetAlpha(alpha)
  screen.mine.inset:SetAlpha(alpha)
  screen.theirs.inset:SetAlpha(alpha)
  screen.logBox:SetAlpha(alpha)
end

local function clearIntro()
  state.intro = nil
  screen.introOverlay:Hide()
  screen.introOverlay:SetAlpha(1)
  screen.countdown:Hide()
  setIntroReveal(1)
end

local function finish(quiet, keepCombat)
  if state.finished then return end
  Battle.StopSounds(keepCombat == true)
  clearIntro()
  state.finished = true
  updateProgress()
  state.paused = false
  stopPausedAnimations()
  clearVisualFeedback()
  screen.pausedText:Hide()
  T.StopPulse(screen.pausedText)
  local winner = state.result.winner
  local banner, r, g, b
  if winner == "A" then
    banner, r, g, b = L["Victory"], 0.5, 0.95, 0.55
  elseif winner == "B" then
    banner, r, g, b = L["Defeat"], 0.95, 0.4, 0.4
  else
    banner, r, g, b = L["Draw"], 0.95, 0.85, 0.5
  end
  if not quiet then queueResultCue(winner) end
  if state.run.survival and ns.Economy.LivesRemaining(state.run) == 0 then
    banner, r, g, b = L["Survival Ended"], 0.95, 0.4, 0.4
  elseif state.run.survival and state.run.round >= ns.Economy.ROUNDS then
    banner, r, g, b = L["Survival Complete"], 0.5, 0.95, 0.55
  end
  screen.banner.text:SetText(banner)
  screen.banner.text:SetTextColor(r, g, b)
  screen.banner.glow:SetVertexColor(r, g, b, 1)
  screen.banner:SetBorderColor(r, g, b, 0.8)
  local A, B = state.result.A, state.result.B
  screen.banner.summary:SetText(string.format(L["You dealt %d and healed %d. %s dealt %d and healed %d.\n%.1f seconds."],
    A.dmgDone, A.healDone, state.theirName, B.dmgDone, B.healDone, state.result.time))
  T.Bounce(screen.banner, 0.35)
  screen.continueButton:Show()
  screen.continueButton:SetText(L["Continue"])
  screen.replayButton:Show()
  screen.resultsButton:Show()
  screen.controls:Hide()
  local final = state.result.timeline[#state.result.timeline]
  if final then state.display = Util.DeepCopy(final) end
  state.simTime = state.result.time
  updateBars(true)
  state.cooldowns = { A = {}, B = {} }
  screen.mine.grid:ClearCooldowns()
  screen.theirs.grid:ClearCooldowns()
end

local function showOpponent()
  local opponent, theirs = state.opponent, screen.theirs
  local fighter = state.fighters.B
  local theirClass = ns.Classes[fighter.classKey]
  theirs.portrait:SetClass(fighter.classKey)
  theirs.name:SetText(fighter.name)
  theirs.name:SetTextColor(T.ClassColor(fighter.classKey))
  theirs.sub:SetText(string.format("%s   %d - %d", theirClass.name, fighter.wins, fighter.losses))
  theirs.grid:SetGrid(opponent.grid)
  updateBars(true)
  T.Pop(theirs.portrait, 1.5, 0.4)
  T.Pop(screen.vs, 1.6, 0.4)
end

local function showCountdown(text, sound)
  screen.countdown.text:SetText(text)
  screen.countdown:Show()
  if sound then playCue(sound) end
end

local function startFight()
  clearIntro()
  state.fightTextUntil = 0.9
  showCountdown(L["Fight!"], T.SOUND_FIGHT)
  state.combatReadyAt = GetTime() + Battle.FIGHT_SOUND_GAP
end

local function beginIntro(skipMatchup)
  state.intro = { t = skipMatchup and Battle.FOUND_TIME + Battle.REVEAL_TIME or 0 }
  ns.UI.Tooltip.Hide()
  screen.countdown:Hide()
  showOpponent()
  for _, entry in ipairs({ { screen.introOverlay.mine, state.fighters.A }, { screen.introOverlay.theirs, state.fighters.B } }) do
    local card, fighter = entry[1], entry[2]
    card.portrait:SetClass(fighter.classKey)
    card.name:SetText(fighter.name)
    card.label:SetText(ns.Classes[fighter.classKey].name)
    card.label:SetTextColor(T.ClassColor(fighter.classKey))
    card.card:SetBorderColor(T.ClassColor(fighter.classKey))
    card.record:SetText(string.format(L["Wins: %s%d|r   Losses: %s%d|r"], T.Hex(T.RGB(T.C.good)), fighter.wins, T.Hex(T.RGB(T.C.bad)), fighter.losses))
  end
  screen.introOverlay:SetAlpha(1)
  if skipMatchup then
    screen.introOverlay:Hide()
    setIntroReveal(1)
    state.intro.shown = Battle.COUNTDOWN_TIME
    showCountdown(tostring(Battle.COUNTDOWN_TIME), T.SOUND_COUNTDOWN)
  else
    playCue(T.SOUND_OPPONENT)
    screen.introOverlay:Show()
    setIntroReveal(0)
  end
end

local function updateIntro(elapsed)
  local intro = state.intro
  intro.t = intro.t + elapsed
  local revealEnd = Battle.FOUND_TIME + Battle.REVEAL_TIME
  if intro.t < revealEnd then
    local alpha = Util.Clamp((intro.t - Battle.FOUND_TIME) / Battle.REVEAL_TIME, 0, 1)
    screen.introOverlay:SetAlpha(1 - alpha)
    setIntroReveal(alpha)
  elseif intro.t >= revealEnd + Battle.COUNTDOWN_TIME then
    startFight()
  else
    screen.introOverlay:Hide()
    setIntroReveal(1)
    local n = math.ceil(Battle.COUNTDOWN_TIME - (intro.t - revealEnd))
    if intro.shown ~= n then
      intro.shown = n
      showCountdown(tostring(n), T.SOUND_COUNTDOWN)
    end
  end
end

local function advancePlayback(at, quiet)
  at = math.max(0, math.min(state.playback.duration, at))
  state.playTime = at
  local steps = state.playback.steps
  while state.nextStep <= #steps and steps[state.nextStep].at <= at + 1e-7 do
    local step = steps[state.nextStep]
    if step.event then
      applyEvent(step.event)
      state.nextEvent = step.index + 1
      if step.paced and not quiet then
        state.eventAt, state.visualBeat = at, step.at
        showVisualEvent(step.event)
        state.eventAt, state.visualBeat = nil, nil
      end
    else
      state.display = Util.DeepCopy(step.snapshot)
    end
    state.nextStep = state.nextStep + 1
  end
  state.simTime = Battle.PlaybackCombatTime(state.playback, at)
  if not quiet then advanceVisuals(at) end
end

local function onUpdate(_, elapsed)
  if not state then return end
  updateResultCue()
  if state.intro then
    if not state.paused then updateIntro(elapsed) end
    updateFloats()
    return
  end
  if state.finished then
    state.playTime = state.playTime + elapsed * state.speed
    updateFloats()
    return
  end
  if state.paused then
    updateCooldowns()
    updateFloats()
    return
  end
  advancePlayback(state.playTime + elapsed * state.speed)
  local ending = state.playTime + 1e-7 >= state.playback.duration
  updateCombatSound()
  if state.fightTextUntil and state.simTime >= state.fightTextUntil then
    state.fightTextUntil = nil
    screen.countdown:Hide()
  end
  updateBars()
  updateCooldowns()
  updateFloats()
  if ending then finish(false, true) end
end

local function setSpeed(speed)
  state.speed = speed
  for _, b in ipairs(screen.speedButtons) do b:SetHighlighted(b.speed == speed) end
  if ns.db then ns.db.global.settings.speed = speed end
  updateCooldowns()
end

local function setPaused(paused)
  if not state then return end
  if state.finished then
    if paused then Battle.StopSounds() end
    return
  end
  state.paused = paused
  if paused then
    Battle.StopSounds()
    state.pausedAnimations = {}
    local function pause(group)
      if group and group:IsPlaying() then group:Pause() state.pausedAnimations[#state.pausedAnimations + 1] = group end
    end
    for _, panel in ipairs({ screen.mine, screen.theirs }) do
      pause(panel.inset.bbShake)
      for _, frame in pairs(panel.grid.itemFrames) do pause(frame.flash.bbFlash) pause(frame.bbPop) end
    end
  else
    for _, group in ipairs(state.pausedAnimations or {}) do group:Play() end
    state.pausedAnimations = nil
  end
  screen.pauseButton:SetText(paused and L["Resume"] or L["Pause"])
  screen.pauseButton:SetHighlighted(paused)
  screen.pausedText:SetShown(paused)
  if paused then T.Pulse(screen.pausedText, 0.4, 1, 0.7) else T.StopPulse(screen.pausedText) end
  updateBars(true)
  updateCooldowns()
end

local function skip(quiet)
  if not state then return end
  if state.finished then Battle.StopSounds() return end
  clearIntro()
  advancePlayback(state.playback.duration, true)
  finish(quiet == true)
end

local function resetPlayback()
  Battle.StopSounds()
  stopPausedAnimations()
  clearVisualFeedback()
  state.simTime = 0
  state.playTime = 0
  state.nextStep = 1
  state.nextEvent = 1
  state.nextVisual = 1
  state.finished = false
  updateProgress()
  state.paused = false
  state.auras = { A = {}, B = {} }
  state.auraOrder = 0
  state.floatOrder = 0
  state.shownNodes = {}
  state.droppedVisualRoots = {}
  state.cooldowns = { A = {}, B = {} }
  state.channels = {}
  state.display = Util.DeepCopy(state.playback.initial)
  state.soundedNodes = {}
  state.lastMajorAt = -math.huge
  state.lastProcAt = -math.huge
  state.combatReadyAt = math.huge
  state.fightTextUntil = nil
  clearIntro()
  screen.log:Clear()
  screen.banner:Hide()
  screen.resultsButton:Hide()
  screen.breakdown.sideId, screen.breakdown.offset = "A", 0
  screen.breakdown:Hide()
  screen.inspector:Hide()
  screen.continueButton:Hide()
  screen.replayButton:Hide()
  screen.controls:Show()
  screen.pauseButton:SetText(L["Pause"])
  screen.pauseButton:SetHighlighted(false)
  screen.pausedText:Hide()
  T.StopPulse(screen.pausedText)
  screen.mine.grid:ClearCooldowns()
  screen.theirs.grid:ClearCooldowns()
  updateBars(true)
end

function Battle.Replay()
  if not state then return end
  resetPlayback()
  beginIntro(true)
end

function Battle.CurrentRun()
  return state and state.run
end

local function continueRun()
  T.PlaySound(T.SOUND_CLICK)
  screen.breakdown:Hide()
  screen.inspector:Hide()
  ns.UI.Tooltip.Hide()
  local finished = ns.Addon:NextRound()
  if finished then
    ns.UI.Main.ShowScreen("home")
    ns.UI.Home.ShowRunOver(state.run)
  else
    ns.UI.Main.ShowScreen("shop")
  end
end

local function itemTooltip(sideId)
  return function(p, frame)
    if screen.introOverlay:IsShown() then return end
    local def = ns.Items[p.id]
    local summary = sideId == "A" and state.result.A or state.result.B
    local extra = itemExtra(sideId, p.uid, def)
    local panel = sideId == "A" and screen.mine or screen.theirs
    ns.UI.Tooltip.Show(frame, def, {
      extra = extra, target = p, anchor = sideId == "A" and "ANCHOR_RIGHT" or "ANCHOR_LEFT",
      fighter = { classKey = summary.classKey, round = state.run.round, grid = panel.grid.grid, talents = summary.talents },
    })
  end
end

function Battle.Show(result, opponent, run)
  if not screen then return end
  if state then stopPausedAnimations() Battle.StopSounds() end
  local previous = run.lastBattle
  local mine = previous and previous.result == result and previous.mine
  if mine and (mine.r ~= run.round or mine.c ~= ns.Classes[run.class].id) then mine = nil end
  state = {
    result = result, opponent = opponent, run = run,
    round = run.round,
    allocations = {
      A = Util.DeepCopy(result.A.talents or ns.Mastery.Normalize(result.A.classKey, run.talents)),
      B = Util.DeepCopy(result.B.talents or ns.Mastery.Unpack(result.B.classKey, run.round, opponent.build.p) or ns.Mastery.Empty(result.B.classKey)),
    },
    playback = Battle.BuildPlayback(result),
    speed = ns.db and ns.db.global.settings.speed or 1,
    myName = displayName(run.who),
    theirName = displayName(opponent.build.n or "?"),
  }
  state.fighters = {
    A = { name = state.myName, classKey = run.class, wins = mine and mine.w or run.wins or 0, losses = mine and mine.l or run.losses or 0 },
    B = { name = state.theirName, classKey = opponent.classKey, wins = opponent.build.w or 0, losses = opponent.build.l or 0 },
  }
  state.progressBefore = { wins = state.fighters.A.wins, losses = state.fighters.A.losses, survivalLife = run.survivalLife == true }
  state.progressAfter = { wins = run.wins or 0, losses = run.losses or 0, survivalLife = run.survivalLife == true }
  local myClass = ns.Classes[run.class]
  screen.mine.portrait:SetClass(run.class)
  screen.mine.name:SetText(state.myName)
  screen.mine.name:SetTextColor(T.ClassColor(run.class))
  screen.mine.sub:SetText(string.format("%s   %d - %d", myClass.name, state.fighters.A.wins, state.fighters.A.losses))
  screen.mine.grid:SetGrid(run.grid)
  screen.roundText:SetText(run.survival and string.format(L["Survival %d / %d"], run.round, ns.Economy.ROUNDS) or string.format(L["Round %d"], run.round))
  setSpeed(state.speed)
  resetPlayback()
  beginIntro()
  ns.UI.Main.ShowScreen("battle")
end

function Battle.Create(parent)
  screen = CreateFrame("Frame", nil, parent)
  screen:SetAllPoints()

  local bar = T.Inset(screen)
  bar:SetPoint("TOPLEFT", 0, 0)
  bar:SetPoint("TOPRIGHT", 0, 0)
  bar:SetHeight(TOP_H)

  local roundText = T.Text(bar, 13, T.C.muted)
  roundText:SetPoint("LEFT", bar, "LEFT", 12, 0)
  screen.roundText = roundText
  local timer = T.Number(bar, 20, T.C.text, "0.0s")
  timer:SetPoint("LEFT", roundText, "RIGHT", 12, 0)
  screen.timer = timer
  local pausedText = T.Text(bar, 13, T.C.gold, L["Paused"])
  pausedText:SetPoint("LEFT", timer, "RIGHT", 14, 0)
  pausedText:Hide()
  screen.pausedText = pausedText

  local wins = T.Pips(bar, ns.Economy.MAX_WINS, T.TEX.trophy, 15, 3, T.C.gold)
  wins:SetPoint("CENTER", bar, "CENTER", -35, 8)
  screen.wins = wins
  local lives = T.Pips(bar, ns.Economy.MAX_LOSSES, T.TEX.heart, 15, 3, T.C.bad)
  lives:SetPoint("CENTER", bar, "CENTER", -35, -8)
  screen.lives = lives

  local controls = CreateFrame("Frame", nil, bar)
  controls:SetSize(340, 26)
  controls:SetPoint("RIGHT", bar, "RIGHT", -10, 0)
  screen.controls = controls
  local resultsButton = T.CreateButton(bar, L["Show Results"], 116, 26, "default", 12)
  resultsButton:SetPoint("RIGHT", bar, "RIGHT", -10, 0)
  resultsButton:SetScript("OnClick", function()
    T.PlaySound(T.SOUND_CLICK)
    if state and state.finished then screen.banner:Show() end
  end)
  resultsButton:Hide()
  screen.resultsButton = resultsButton
  local pauseButton = T.CreateButton(controls, L["Pause"], 76, 26, "default", 12)
  pauseButton:SetPoint("LEFT", controls, "LEFT", 0, 0)
  pauseButton:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) setPaused(not (state and state.paused)) end)
  screen.pauseButton = pauseButton
  screen.speedButtons = {}
  local prev = pauseButton
  for i, s in ipairs({ 1, 2, 4 }) do
    local b = T.CreateButton(controls, s .. "x", 42, 26, "default", 12)
    b:SetPoint("LEFT", prev, "RIGHT", 4, 0)
    b.speed = s
    b:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) setSpeed(s) end)
    screen.speedButtons[i] = b
    prev = b
  end
  local skipButton = T.CreateButton(controls, L["Skip"], 70, 26, "default", 12)
  skipButton:SetPoint("LEFT", prev, "RIGHT", 10, 0)
  skipButton:SetScript("OnClick", function() T.PlaySound(T.SOUND_CLICK) skip() end)
  screen.skipButton = skipButton

  local header = T.Panel(screen, "card")
  header:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -2)
  header:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -2)
  header:SetHeight(HEADER_H)
  screen.header = header
  local mine = createSide(header, false)
  local theirs = createSide(header, true)
  screen.mine = mine
  screen.theirs = theirs

  local vsBurst = header:CreateTexture(nil, "ARTWORK", nil, -1)
  vsBurst:SetTexture(T.TEX.shine)
  vsBurst:SetSize(150, 150)
  vsBurst:SetPoint("CENTER", header, "CENTER", 0, 0)
  vsBurst:SetVertexColor(T.C.gold[1], T.C.gold[2], T.C.gold[3], 1)
  vsBurst:SetBlendMode("ADD")
  vsBurst:SetAlpha(0.45)
  T.Pulse(vsBurst, 0.25, 0.6, 1.8)
  local vs = T.Display(header, 38, T.C.gold, L["VS"])
  vs:SetPoint("CENTER", header, "CENTER", 0, 0)
  screen.vs = vs

  local bagTop = -(TOP_H + 2 + HEADER_H + 6 + AURA_SIZE + 6)
  local mineInset = createBagPanel(screen, mine, false)
  mine.auraRow:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -6)
  mineInset:SetPoint("TOPLEFT", screen, "TOPLEFT", 0, bagTop)
  mineInset:SetPoint("BOTTOMRIGHT", screen, "BOTTOM", -BAG_GAP / 2, LOG_H + 8)
  local theirsInset = createBagPanel(screen, theirs, true)
  theirs.auraRow:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -8, -6)
  theirsInset:SetPoint("TOPRIGHT", screen, "TOPRIGHT", 0, bagTop)
  theirsInset:SetPoint("BOTTOMLEFT", screen, "BOTTOM", BAG_GAP / 2, LOG_H + 8)
  mine.grid:SetCallbacks({ onItemEnter = itemTooltip("A"), onItemLeave = function() ns.UI.Tooltip.Hide() end })
  theirs.grid:SetCallbacks({ onItemEnter = itemTooltip("B"), onItemLeave = function() ns.UI.Tooltip.Hide() end })

  local logBox = T.Inset(screen)
  logBox:SetPoint("TOPLEFT", mineInset, "BOTTOMLEFT", 0, -8)
  logBox:SetPoint("BOTTOMRIGHT", screen, "BOTTOMRIGHT", 0, 0)
  screen.logBox = logBox
  local log = CreateFrame("ScrollingMessageFrame", nil, logBox)
  log:SetPoint("TOPLEFT", 12, -8)
  log:SetPoint("BOTTOMRIGHT", -12, 8)
  log:SetFontObject("GameFontHighlightSmall")
  log:SetJustifyH("LEFT")
  log:SetMaxLines(400)
  log:SetFading(false)
  log:EnableMouseWheel(true)
  log:SetScript("OnMouseWheel", function(self, delta)
    if delta > 0 then self:ScrollUp() else self:ScrollDown() end
  end)
  screen.log = log
  log:Show()

  local floatLayer = CreateFrame("Frame", nil, screen)
  floatLayer:SetAllPoints()
  floatLayer:SetFrameLevel(screen:GetFrameLevel() + 40)
  screen.floatLayer = floatLayer
  floatPool = {}
  for _, panel in ipairs({ mine, theirs }) do
    panel.floatTexts = {}
    for slot = 1, 6 do
      local text = T.Text(floatLayer, 15, T.C.text, "", "OUTLINE")
      text:SetSize(96, 22)
      text:SetJustifyH("CENTER")
      text:SetWordWrap(false)
      text:SetMaxLines(1)
      text.start, text.active = -math.huge, false
      panel.floatTexts[slot] = text
      floatPool[#floatPool + 1] = text
      text:Hide()
    end
  end

  local introOverlay = CreateFrame("Frame", nil, floatLayer)
  introOverlay:SetPoint("TOPLEFT", screen, "TOPLEFT", 0, -TOP_H)
  introOverlay:SetPoint("BOTTOMRIGHT", screen, "BOTTOMRIGHT", 0, 0)
  introOverlay:SetFrameLevel(floatLayer:GetFrameLevel() + 4)
  introOverlay:EnableMouse(true)
  local introShade = introOverlay:CreateTexture(nil, "BACKGROUND")
  introShade:SetAllPoints()
  introShade:SetTexture(T.TEX.white)
  introShade:SetVertexColor(T.C.bg0[1], T.C.bg0[2], T.C.bg0[3], 0.97)
  local found = T.Title(introOverlay, 30, T.C.gold, L["Opponent found"])
  found:SetPoint("CENTER", introOverlay, "CENTER", 0, 152)
  introOverlay.title = found
  introOverlay.vs = T.Display(introOverlay, 32, T.C.gold, L["VS"])
  introOverlay.vs:SetPoint("CENTER", introOverlay, "CENTER", 0, 8)
  for index, side in ipairs({ "mine", "theirs" }) do
    local card = T.Panel(introOverlay, "card")
    card:SetSize(244, 222)
    card:SetPoint("CENTER", introOverlay, "CENTER", index == 1 and -158 or 158, 0)
    local portrait = T.CreatePortrait(card, 76)
    portrait:SetPoint("TOP", card, "TOP", 0, -24)
    local name = T.Text(card, 20, T.C.text)
    name:SetPoint("TOP", portrait, "BOTTOM", 0, -12)
    name:SetWidth(216)
    name:SetJustifyH("CENTER")
    name:SetWordWrap(false)
    name:SetMaxLines(1)
    local label = T.Text(card, 14, T.C.text)
    label:SetPoint("TOP", name, "BOTTOM", 0, -4)
    label:SetWidth(216)
    label:SetJustifyH("CENTER")
    label:SetWordWrap(false)
    local record = T.Text(card, 14, T.C.text)
    record:SetPoint("TOP", label, "BOTTOM", 0, -12)
    record:SetWidth(216)
    record:SetJustifyH("CENTER")
    record:SetWordWrap(false)
    introOverlay[side] = { card = card, portrait = portrait, name = name, label = label, record = record }
  end
  introOverlay:Hide()
  screen.introOverlay = introOverlay

  local countdown = CreateFrame("Frame", nil, floatLayer)
  countdown:SetSize(320, 130)
  countdown:SetPoint("CENTER", screen, "CENTER", 0, 20)
  countdown:SetFrameLevel(floatLayer:GetFrameLevel() + 6)
  countdown.text = T.Display(countdown, 84, T.C.gold, "")
  countdown.text:SetPoint("CENTER", countdown, "CENTER", 0, 0)
  countdown:Hide()
  screen.countdown = countdown

  local banner = T.Panel(floatLayer, "card")
  banner:SetSize(440, 168)
  banner:SetPoint("CENTER", screen, "CENTER", 0, 0)
  banner:SetFrameLevel(floatLayer:GetFrameLevel() + 5)
  local closeResults = T.IconButton(banner, 22, T.TEX.close, { inset = 2, tooltip = L["Close results"] })
  closeResults:SetPoint("TOPRIGHT", -8, -8)
  closeResults:SetScript("OnClick", function()
    if state and state.finished then
      if banner.bbBounce then banner.bbBounce:Stop() end
      banner:Hide()
      ns.UI.Tooltip.Hide()
    end
  end)
  banner.close = closeResults
  T.CreateShadow(banner, 30, 0.8)
  banner.glow = T.CreateGlow(banner, 30, 1, 0.82, 0.2, 0.35)
  banner.text = T.Display(banner, 36, T.C.gold, "")
  banner.text:SetPoint("TOP", banner, "TOP", 0, -18)
  banner.summary = T.Text(banner, 12, T.C.muted)
  banner.summary:SetPoint("TOP", banner.text, "BOTTOM", 0, -8)
  banner.summary:SetWidth(400)
  banner.summary:SetJustifyH("CENTER")
  local continueButton = T.CreateButton(banner, L["Continue"], 140, 30, "primary", 14)
  continueButton:SetPoint("BOTTOMRIGHT", banner, "BOTTOMRIGHT", -16, 14)
  continueButton:SetScript("OnClick", continueRun)
  screen.continueButton = continueButton
  local replayButton = T.CreateButton(banner, L["Replay"], 90, 30, "default", 13)
  replayButton:SetPoint("RIGHT", continueButton, "LEFT", -8, 0)
  replayButton:SetScript("OnClick", Battle.Replay)
  screen.replayButton = replayButton
  local breakdownButton = T.CreateButton(banner, L["Breakdown"], 96, 30, "default", 13)
  breakdownButton:SetPoint("RIGHT", replayButton, "LEFT", -8, 0)
  breakdownButton:SetScript("OnClick", showBreakdown)
  screen.breakdownButton = breakdownButton
  banner:Hide()
  screen.banner = banner
  screen.breakdown = createBreakdown(floatLayer)
  screen.inspector = createInspector(floatLayer)

  screen:SetScript("OnUpdate", onUpdate)
  screen:SetScript("OnShow", function()
    screen.resultsButton:SetShown(state and state.finished)
  end)
  screen:SetScript("OnHide", function()
    screen.breakdown:Hide()
    screen.inspector:Hide()
    if state and not state.finished then skip(true) end
    Battle.StopSounds()
    screen.banner:Hide()
    screen.resultsButton:Hide()
    ns.UI.Tooltip.Hide()
  end)
  return screen
end
