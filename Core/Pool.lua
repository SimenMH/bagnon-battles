local ADDON, ns = ...
local Util = ns.Util

local Pool = {}
ns.Pool = Pool

Pool.MAX_PER_ROUND = 300
Pool.MAX_PER_AUTHOR = 3
Pool.LIVE_WINDOW = 15 * 60
Pool.FRESH_WINDOW = 24 * 60 * 60
Pool.MIN_CANDIDATES = 5

local store
local indexes = {}

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

local function approved(build, now)
  local protected, valid, reason = pcall(ns.Snapshot.Validate, build, now)
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

local function evict(bucket, index)
  while #bucket.list > Pool.MAX_PER_ROUND do
    local worst, worstIdx
    for i = 1, #bucket.list do
      local rec = bucket.list[i]
      local score = rec.rcv
      if rec.fh then score = score + 3600 end
      if not worst or score < worst then worst, worstIdx = score, i end
    end
    local rec = table.remove(bucket.list, worstIdx)
    index[rec.id] = nil
  end
end

local function insert(bucket, index, rec)
  local id, build = rec.id, rec.b
  if index[id] then
    local previous = index[id]
    if rec.fh and not previous.fh then
      previous.fh = true
      previous.rcv = rec.rcv
    end
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
        local build, id = approved(old.b, now)
        if build and build.r == round then
          local received = finite(old.rcv) and old.rcv >= 0 and old.rcv <= now
          local rec = { id = id, b = build, rcv = received and old.rcv or now,
            fh = received and old.fh == true or false, bot = old.bot == true or build.bot == true }
          insert(bucket, index, rec)
        end
      end
    end
  end
  store[round], indexes[round] = bucket, index
  return bucket, index
end

function Pool.Init(db)
  db.pool = type(db.pool) == "table" and db.pool or {}
  store = db.pool
  indexes = {}
  local now = safeTime()
  for round = 1, ns.Economy.ROUNDS do cleanBucket(round, now) end
  for round in pairs(store) do if not validRound(round) then store[round] = nil end end
end

local function bucketFor(round)
  if not store or not validRound(round) then return nil end
  if not indexes[round] then return cleanBucket(round, safeTime()) end
  return store[round], indexes[round]
end

function Pool.Add(build, opts)
  opts = opts or {}
  local now = safeTime(opts.now)
  local copy, id = approved(build, now)
  if not copy then return false, id end
  local bucket, index = bucketFor(copy.r)
  if not bucket then return false, "pool unavailable" end
  return insert(bucket, index, { id = id, b = copy, rcv = now, fh = opts.firsthand == true, bot = copy.bot == true })
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

function Pool.Weight(rec, now, isOnline)
  local age = now - rec.rcv
  if rec.bot then return 1 end
  if rec.fh and age < Pool.LIVE_WINDOW and (not isOnline or isOnline(rec.b.n)) then return 4 end
  if age < Pool.FRESH_WINDOW then return 2 end
  return 1
end

function Pool.Candidates(round, opts)
  opts = opts or {}
  local exclude = opts.exclude or {}
  local out = {}
  local bucket = bucketFor(round)
  if not bucket then return out end
  for i = 1, #bucket.list do
    local rec = bucket.list[i]
    if not exclude[rec.id] and rec.b.n ~= opts.ownName and (opts.allowBots or not rec.bot) then
      out[#out + 1] = rec
    end
  end
  return out
end

function Pool.Pick(round, opts)
  opts = opts or {}
  local now = safeTime(opts.now)
  local rng = opts.rng or Util.NewRNG(now)
  local candidates = Pool.Candidates(round, opts)
  if #candidates == 0 then return nil end
  local preferred = {}
  if opts.wins then
    for _, rec in ipairs(candidates) do
      if math.abs(rec.b.w - opts.wins) <= 1 then preferred[#preferred + 1] = rec end
    end
  end
  if #preferred >= Pool.MIN_CANDIDATES then candidates = preferred end
  local entries = {}
  for _, rec in ipairs(candidates) do
    entries[#entries + 1] = { value = rec, weight = Pool.Weight(rec, now, opts.isOnline) }
  end
  return rng:PickWeighted(entries)
end

function Pool.Sample(round, n, rng)
  local bucket = bucketFor(round)
  if not bucket or #bucket.list == 0 then return {} end
  local idx = {}
  for i = 1, #bucket.list do if not bucket.list[i].bot then idx[#idx + 1] = i end end
  rng:Shuffle(idx)
  local out = {}
  for i = 1, math.min(n, #idx) do out[#out + 1] = Util.DeepCopy(bucket.list[idx[i]].b) end
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
