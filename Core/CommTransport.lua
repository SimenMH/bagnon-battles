local ADDON, ns = ...

local CommTransport = {}
ns.CommTransport = CommTransport

CommTransport.MAX_STREAMS = 64

CommTransport.MAX_FRAGMENTS = 32
CommTransport.STREAM_TIMEOUT = 60
local METHODS = {
  OnReceiveMultipartFirst = "first",
  OnReceiveMultipartNext = "next",
  OnReceiveMultipartLast = "last",
}

local enabled = false
local streams, streamCount = {}, 0
local wrappers = {}
local expiryScheduled = false

local function now()
  return GetTime and GetTime() or ns.Util.Now()
end

local function library()
  return LibStub("AceComm-3.0", true)
end

local function discard(key, comm)
  if streams[key] then
    streams[key] = nil
    streamCount = streamCount - 1
  end
  local spool = comm and comm.multipart_spool
  if spool then spool[key] = nil end
end

local function clear()
  streams, streamCount = {}, 0
  local comm = library()
  local prefix = ns.PREFIX .. "\t"
  for key in pairs(comm and comm.multipart_spool or {}) do
    if type(key) == "string" and key:sub(1, #prefix) == prefix then comm.multipart_spool[key] = nil end
  end
end

local function scheduleExpiry()
  if expiryScheduled or streamCount == 0 then return end
  local deadline = math.huge
  for _, stream in pairs(streams) do deadline = math.min(deadline, stream.seen + CommTransport.STREAM_TIMEOUT) end
  expiryScheduled = true
  C_Timer.After(math.max(0, deadline - now()), function()
    expiryScheduled = false
    local current, comm = now(), library()
    for key, stream in pairs(streams) do
      if current - stream.seen >= CommTransport.STREAM_TIMEOUT then discard(key, comm) end
    end
    scheduleExpiry()
  end)
end

local function accept(comm, part, message, distribution, sender)
  if type(distribution) ~= "string" or type(sender) ~= "string" then return false end
  local key = ns.PREFIX .. "\t" .. distribution .. "\t" .. sender
  if not enabled or type(message) ~= "string" then discard(key, comm) return false end
  local current = now()
  if part == "first" then
    discard(key, comm)
    if #message > ns.Snapshot.MAX_CHANNEL_PAYLOAD then return false end
    if streamCount >= CommTransport.MAX_STREAMS then
      local oldestKey, oldest
      for candidate, stream in pairs(streams) do
        if not oldest or stream.seen < oldest then oldestKey, oldest = candidate, stream.seen end
      end
      discard(oldestKey, comm)
    end
    streams[key] = { bytes = #message, fragments = 1, seen = current }
    streamCount = streamCount + 1
    scheduleExpiry()
    return true
  end
  local stream = streams[key]
  if not stream or current - stream.seen >= CommTransport.STREAM_TIMEOUT
    or stream.bytes + #message > ns.Snapshot.MAX_CHANNEL_PAYLOAD
    or stream.fragments >= CommTransport.MAX_FRAGMENTS then
    discard(key, comm)
    return false
  end
  stream.bytes, stream.fragments, stream.seen = stream.bytes + #message, stream.fragments + 1, current
  if part == "last" then

    streams[key] = nil
    streamCount = streamCount - 1
  end
  return true
end

function CommTransport.EnsureInstalled()
  local comm = library()
  if not comm then return false end
  for method, part in pairs(METHODS) do
    local original = comm[method]
    if type(original) ~= "function" then return false end
    if original ~= wrappers[method] then
      local wrapper
      wrapper = function(self, prefix, message, distribution, sender, ...)

        if wrappers[method] ~= wrapper or prefix ~= ns.PREFIX then
          return original(self, prefix, message, distribution, sender, ...)
        end
        if accept(self, part, message, distribution, sender) then
          return original(self, prefix, message, distribution, sender, ...)
        end
      end
      wrappers[method], comm[method] = wrapper, wrapper
    end
  end
  if not enabled then clear() end
  return true
end

function CommTransport.SetEnabled(value)
  enabled = value == true
  return CommTransport.EnsureInstalled()
end
