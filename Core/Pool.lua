local ADDON, ns = ...
local Util = ns.Util

local Pool = {}
ns.Pool = Pool

Pool.MAX_PER_ROUND = 1000
Pool.MAX_PER_AUTHOR = 5
Pool.MAX_FOUGHT = 5000
Pool.REPEAT_COOLDOWN = 5
Pool.LIVE_WINDOW = 15 * 60
Pool.FRESH_WINDOW = 24 * 60 * 60
Pool.AUTHOR_DAY = 24 * 60 * 60
Pool.AUTHOR_WEEK = 7 * 24 * 60 * 60
Pool.MIN_CANDIDATES = 5
Pool.GUILD_WEIGHT = 1.35
Pool.AUTHOR_DAY_WEIGHT = 0.25
Pool.AUTHOR_WEEK_WEIGHT = 0.5

local store, fought, fights
local indexes = {}
local faced = {}

local BUILD_FIELDS = { "v", "d", "c", "r", "w", "l", "s", "n", "g", "i", "b", "p" }

local function finite(value)
  return type(value) == "number" and value == value and value > -math.huge and value < math.huge
end

local function validRound(round)
  return finite(round) and round == math.floor(round) and round >= 1 and round <= ns.Economy.ROUNDS
end

local function safeTime(now)
  if finite(now) and now >= 0 then return now end
  return Util.Now()
end

local function approved(build, now, floor)
  local protected, valid, reason = pcall(ns.Snapshot.Validate, build, now, floor)
  if not protected then return nil, "invalid build" end
  if not valid then return nil, reason end
  local copied, copy, id = pcall(function()
    local out = {}
    for _, field in ipairs(BUILD_FIELDS) do out[field] = Util.DeepCopy(build[field]) end
    if build.bot == true then out.bot = true end
    return out, ns.Snapshot.Hash(out)
  end)
  if not copied then return nil, "invalid build" end
  return copy, id
end

local function record(id, build, received, firsthand, floor)
  return { id = id, b = build, rcv = received, fh = firsthand == true, bot = build.bot == true,
    m = build.d > ns.DATA_VERSION and finite(floor) and floor or nil }
end

local function evictsBefore(a, b)
  local aFought, bFought = fought[a.id] ~= nil, fought[b.id] ~= nil
  if aFought ~= bFought then return aFought end
  return a.b.s < b.b.s
end

local function evict(bucket, index)
  while #bucket.list > Pool.MAX_PER_ROUND do
    local worstIdx
    for i = 1, #bucket.list do
      if not worstIdx or evictsBefore(bucket.list[i], bucket.list[worstIdx]) then worstIdx = i end
    end
    local rec = table.remove(bucket.list, worstIdx)
    index[rec.id] = nil
  end
end

local function insert(bucket, index, rec)
  local id, build = rec.id, rec.b
  if index[id] then
    local previous = index[id]
    local notOlder = rec.b.s >= previous.b.s
    local replace = rec.fh and (not previous.fh or notOlder)
      or not previous.fh and rec.b.s > previous.b.s
    if replace then
      previous.b, previous.bot, previous.m = rec.b, rec.bot, rec.m
    end
    if rec.fh or replace then previous.rcv = math.max(previous.rcv, rec.rcv) end
    previous.fh = previous.fh or rec.fh
    return false, "duplicate"
  end
  local byAuthor, replaceable = 0, {}
  for i = 1, #bucket.list do
    local previous = bucket.list[i]
    if previous.b.n == build.n then
      byAuthor = byAuthor + 1
      if rec.fh or not previous.fh then replaceable[#replaceable + 1] = i end
    end
  end
  if byAuthor >= Pool.MAX_PER_AUTHOR then
    if #replaceable == 0 then return false, "author limit" end
    local oldestIdx, oldest
    for _, idx in ipairs(replaceable) do
      local previous = bucket.list[idx]
      if not oldest or previous.b.s < oldest then oldest, oldestIdx = previous.b.s, idx end
    end
    local removed = table.remove(bucket.list, oldestIdx)
    index[removed.id] = nil
  end
  bucket.list[#bucket.list + 1] = rec
  index[id] = rec
  evict(bucket, index)
  return true, id
end

local function cleanBucket(round, now)
  if not store or not validRound(round) then return nil end
  local previous = store[round]
  local list = type(previous) == "table" and previous.list
  local bucket, index, positions = { list = {} }, {}, {}
  if type(list) == "table" then
    for position in pairs(list) do
      if finite(position) and position >= 1 and position == math.floor(position) then positions[#positions + 1] = position end
    end
    table.sort(positions)
    for _, position in ipairs(positions) do
      local old = list[position]
      if type(old) == "table" then
        local build, id = approved(old.b, now, old.m)
        if build and build.r == round then
          local received = finite(old.rcv) and old.rcv >= 0 and old.rcv <= now
          local rec = record(id, build, received and old.rcv or now, received and old.fh == true, old.m)
          rec.bot = old.bot == true or build.bot == true
          insert(bucket, index, rec)
        end
      end
    end
  end
  store[round], indexes[round] = bucket, index
  return bucket, index
end

local function validFight(entry)
  return type(entry) == "table" and type(entry.n) == "string" and validRound(entry.r)
    and finite(entry.f) and entry.f >= 0 and finite(entry.t) and entry.t >= 0
end

local function trimFought()
  local count = 0
  for _ in pairs(fought) do count = count + 1 end
  while count > Pool.MAX_FOUGHT do
    local oldestId, oldest
    for id, entry in pairs(fought) do
      if not oldest or entry.t < oldest then oldestId, oldest = id, entry.t end
    end
    fought[oldestId] = nil
    count = count - 1
  end
end

local function rebuildFaced()
  faced = {}
  for _, entry in pairs(fought) do
    faced[entry.n] = math.max(faced[entry.n] or 0, entry.t)
  end
end

local function fightState(rec, round)
  local entry = fought[rec.id]
  if not entry then return "new" end
  if (fights[round] or 0) - entry.f >= Pool.REPEAT_COOLDOWN then return "cooled", entry.f end
  return "waiting"
end

function Pool.Init(db)
  db.pool = type(db.pool) == "table" and db.pool or {}
  db.fought = type(db.fought) == "table" and db.fought or {}
  db.fights = type(db.fights) == "table" and db.fights or {}
  store, fought, fights = db.pool, db.fought, db.fights
  indexes = {}
  for id, entry in pairs(fought) do
    if type(id) ~= "string" or not validFight(entry) then fought[id] = nil end
  end
  for round, count in pairs(fights) do
    if not validRound(round) or not finite(count) or count < 0 or count ~= math.floor(count) then fights[round] = nil end
  end
  local now = safeTime()
  for round = 1, ns.Economy.ROUNDS do cleanBucket(round, now) end
  for round in pairs(store) do if not validRound(round) then store[round] = nil end end
  trimFought()
  rebuildFaced()
end

local function bucketFor(round)
  if not store or not validRound(round) then return nil end
  if not indexes[round] then return cleanBucket(round, safeTime()) end
  return store[round], indexes[round]
end

function Pool.Add(build, opts)
  opts = opts or {}
  local now = safeTime(opts.now)
  local copy, id = approved(build, now, opts.floor)
  if not copy then return false, id end
  local bucket, index = bucketFor(copy.r)
  if not bucket then return false, "pool unavailable" end
  return insert(bucket, index, record(id, copy, now, opts.firsthand, opts.floor))
end

function Pool.RecordFight(round, opponent, now)
  if not fights or not validRound(round) then return false end
  now = safeTime(now)
  fights[round] = (fights[round] or 0) + 1
  local _, index = bucketFor(round)
  local rec = type(opponent) == "table" and index and index[opponent.id]
  if not rec then return false end
  fought[rec.id] = { n = rec.b.n, r = round, f = fights[round], t = now }
  faced[rec.b.n] = math.max(faced[rec.b.n] or 0, now)
  trimFought()
  return true
end

function Pool.Count(round)
  if round then return store and store[round] and #store[round].list or 0 end
  local n = 0
  for r = 1, ns.Economy.ROUNDS do n = n + Pool.Count(r) end
  return n
end

function Pool.Counts()
  local counts = {}
  for r = 1, ns.Economy.ROUNDS do counts[r] = Pool.Count(r) end
  return counts
end

function Pool.UnfoughtCount(round)
  local bucket = bucketFor(round)
  if not bucket then return 0 end
  local n = 0
  for _, rec in ipairs(bucket.list) do
    if not rec.bot and not fought[rec.id] then n = n + 1 end
  end
  return n
end

function Pool.IsLive(rec, now, isOnline)
  return not rec.bot and rec.fh and now - rec.rcv < Pool.LIVE_WINDOW and (not isOnline or isOnline(rec.b.n))
end

function Pool.Weight(rec, now, opts)
  if rec.bot then return 1 end
  opts = opts or {}
  local weight = 1
  if Pool.IsLive(rec, now, opts.isOnline) then
    weight = 4
  elseif now - rec.b.s < Pool.FRESH_WINDOW then
    weight = 2
  end
  if opts.inGuild and opts.inGuild(rec.b.n) then weight = weight * Pool.GUILD_WEIGHT end
  local last = faced[rec.b.n]
  if last then
    local age = now - last
    if age < Pool.AUTHOR_DAY then
      weight = weight * Pool.AUTHOR_DAY_WEIGHT
    elseif age < Pool.AUTHOR_WEEK then
      weight = weight * Pool.AUTHOR_WEEK_WEIGHT
    end
  end
  return weight
end

function Pool.Candidates(round, opts)
  local excludedAuthors = opts and opts.excludedAuthors or {}
  local out = {}
  local bucket = bucketFor(round)
  if not bucket then return out end
  for i = 1, #bucket.list do
    local rec = bucket.list[i]
    if not rec.bot and not excludedAuthors[rec.b.n] then out[#out + 1] = rec end
  end
  return out
end

function Pool.Pick(round, opts)
  opts = opts or {}
  local now = safeTime(opts.now)
  local rng = opts.rng or Util.NewRNG(now)
  local unfought, cooled = {}, {}
  for _, rec in ipairs(Pool.Candidates(round, opts)) do
    local state, at = fightState(rec, round)
    if state == "new" then
      unfought[#unfought + 1] = rec
    elseif state == "cooled" then
      cooled[#cooled + 1] = { rec = rec, at = at }
    end
  end
  if #unfought > 0 then
    local candidates = unfought
    if opts.wins then
      local preferred = {}
      for _, rec in ipairs(candidates) do
        if math.abs(rec.b.w - opts.wins) <= 1 then preferred[#preferred + 1] = rec end
      end
      if #preferred >= Pool.MIN_CANDIDATES then candidates = preferred end
    end
    local entries = {}
    for _, rec in ipairs(candidates) do
      entries[#entries + 1] = { value = rec, weight = Pool.Weight(rec, now, opts) }
    end
    return rng:PickWeighted(entries)
  end
  if #cooled == 0 then return nil end
  local oldest = math.huge
  for _, entry in ipairs(cooled) do oldest = math.min(oldest, entry.at) end
  local choices = {}
  for _, entry in ipairs(cooled) do
    if entry.at == oldest then choices[#choices + 1] = entry.rec end
  end
  return rng:Pick(choices)
end

local function sharingCandidates(round, since, rng, opts, includeOlder)
  local recent, older = {}, {}
  for _, rec in ipairs(Pool.Candidates(round, opts)) do
    if rec.b.s > since then
      recent[#recent + 1] = rec
    elseif includeOlder then
      older[#older + 1] = rec
    end
  end
  table.sort(recent, function(a, b) return a.b.s > b.b.s end)
  rng:Shuffle(older)
  for _, rec in ipairs(older) do recent[#recent + 1] = rec end
  return recent
end

local function appendSample(out, seen, lists, limit)
  local depth = 1
  while #out < limit do
    local found = false
    for _, list in ipairs(lists) do
      local rec = list[depth]
      if rec then
        found = true
        if not seen[rec.id] then
          out[#out + 1], seen[rec.id] = rec, true
          if #out >= limit then return end
        end
      end
    end
    if not found then break end
    depth = depth + 1
  end
end

function Pool.ShareSample(rounds, since, limit, rng, excludedAuthor)
  local out, seen, requested, ordered, lists = {}, {}, {}, {}, {}
  since = finite(since) and math.max(0, since) or 0
  limit = finite(limit) and math.max(0, math.floor(limit)) or 0
  if limit == 0 then return out end
  rng = rng or Util.NewRNG(safeTime())
  local opts = { excludedAuthors = excludedAuthor and { [excludedAuthor] = true } or {} }
  for _, round in ipairs(rounds) do
    if validRound(round) and not requested[round] then
      requested[round] = true
      ordered[#ordered + 1] = round
    end
  end
  rng:Shuffle(ordered)
  for _, round in ipairs(ordered) do
    lists[#lists + 1] = sharingCandidates(round, since, rng, opts, true)
  end
  appendSample(out, seen, lists, limit)
  if #out >= limit then return out end
  ordered, lists = {}, {}
  for round = 1, ns.Economy.ROUNDS do
    if not requested[round] then ordered[#ordered + 1] = round end
  end
  rng:Shuffle(ordered)
  for _, round in ipairs(ordered) do
    lists[#lists + 1] = sharingCandidates(round, since, rng, opts, false)
  end
  appendSample(out, seen, lists, limit)
  return out
end

function Pool.ThinRounds(threshold)
  local out = {}
  for r = 1, ns.Economy.ROUNDS do
    local real = 0
    for _, rec in ipairs(store[r].list) do if not rec.bot then real = real + 1 end end
    if real < threshold then out[#out + 1] = r end
  end
  return out
end

function Pool.Remove(round, id)
  local bucket, index = bucketFor(round)
  if not bucket or not index[id] then return false end
  for i = 1, #bucket.list do
    if bucket.list[i].id == id then table.remove(bucket.list, i) break end
  end
  index[id] = nil
  return true
end

function Pool.Clear()
  for r = 1, ns.Economy.ROUNDS do
    store[r] = { list = {} }
    indexes[r] = {}
  end
end
