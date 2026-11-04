local ADDON, ns = ...
local Util = ns.Util

local Playback = {}
ns.UI.BattlePlayback = Playback

Playback.PROC_DELAY = 0.06
Playback.MAX_PROC_LAG = 0.18
Playback.BURST_DELAY = 0.1
Playback.MAX_BURST_HOLD = 0.8
Playback.MIN_BURST_HITS = 3

function Playback.ActivationKey(event)
  if event.nodeId then
    return (event.side or "") .. ":" .. tostring(event.rootId or 0) .. ":" .. tostring(event.nodeId)
  end
end

local function isActivation(event)
  return event.type == "fire" or event.type == "proc" and event.on ~= "use" and event.on ~= "battleStart"
    or event.type == "damage" and event.extraAttack == true
end

function Playback.Build(result, delay)
  delay = delay == nil and Playback.PROC_DELAY or math.max(0, delay)
  local playback = { steps = {}, visuals = {}, activations = {}, holds = {}, time = result.time, duration = result.time, initial = Util.DeepCopy(result.initial or result.timeline[1]) }
  local nextEvent = 1
  local function eventStep(event, index)
    local activation = Playback.ActivationKey(event)
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
          group.nodes[Playback.ActivationKey(event) or "event:" .. tostring(index)] = true
        end
      end
    end
    local beat, previous, hit = 0, nil, false
    for index = first, last do
      local step = playback.steps[index]
      local event = step.event
      local group = event and groups[event.rootId]
      local node = event and (Playback.ActivationKey(event) or "event:" .. tostring(index))
      if group and group.hits >= Playback.MIN_BURST_HITS and group.nodes[node] then
        if previous and (previous ~= node or event.type == "damage" and hit) then beat, hit = beat + 1, false end
        previous = node
        if event.type == "damage" then hit = true end
      end
      step.beat = beat
    end
    local width = delay > 0 and math.min(beat * Playback.BURST_DELAY, Playback.MAX_BURST_HOLD) or 0
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
        at = math.min(at, step.at + (step.paced and 0 or Playback.MAX_PROC_LAG))
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

function Playback.CombatTime(playback, at)
  local low, high, found = 1, #(playback.holds or {}), nil
  while low <= high do
    local middle = math.floor((low + high) / 2)
    if playback.holds[middle].at <= at then found, low = playback.holds[middle], middle + 1 else high = middle - 1 end
  end
  if found then at = at < found.finish and found.t or at - found.offset end
  return math.max(0, math.min(playback.time, at))
end

function Playback.ApplyEvent(snapshot, event, result)
  local target = event.target or event.side
  local hp, absorb, res = target and "hp" .. target, target and "abs" .. target, target and "res" .. target
  local amount = event.amount or 0
  if event.type == "damage" or event.type == "dot" or event.type == "thorns" or event.type == "healthCost" then
    if hp then snapshot[hp] = (snapshot[hp] or 0) - amount end
    if absorb then snapshot[absorb] = math.max(0, (snapshot[absorb] or 0) - (event.absorbed or 0)) end
  elseif event.type == "heal" or event.type == "hot" then
    if hp then
      if event.revive then snapshot[hp], snapshot[absorb] = math.min(result[target].hpMax, amount), 0
      else snapshot[hp] = math.min(result[target].hpMax, (snapshot[hp] or 0) + amount) end
    end
  elseif event.type == "absorb" and absorb then
    snapshot[absorb] = math.max(0, (snapshot[absorb] or 0) + amount)
  elseif event.type == "resource" and res then
    snapshot[res] = snapshot[res] or {}
    local maximum = result[target].resources[event.resource] or math.huge
    snapshot[res][event.resource] = Util.Clamp((snapshot[res][event.resource] or 0) + amount, 0, maximum)
  elseif event.type == "resourceReset" and res then
    snapshot[res] = snapshot[res] or {}
    snapshot[res][event.resource] = event.value
  elseif event.type == "fatigue" then
    snapshot.hpA, snapshot.hpB = snapshot.hpA - amount, snapshot.hpB - amount
  end
end

function Playback.ItemContributions(result, sideId, throughEvent)
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
      elseif event.type == "absorb" or event.type == "ground" then item.shield = item.shield + event.amount
      elseif event.type == "resource" and event.amount > 0 then
        item.resources[event.resource] = (item.resources[event.resource] or 0) + event.amount
      end
    end
  end
  return metrics
end

