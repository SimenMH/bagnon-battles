local ADDON, ns = ...
local Util = ns.Util

local CommVersion = {}
ns.CommVersion = CommVersion

CommVersion.COOLDOWN = 24 * 60 * 60

local MESSAGE = "Version v%s is available on CurseForge. Until you update, you may stop being matched against other players."
local notice
local warned = false

local function parseVersion(value)
  if type(value) ~= "string" or #value > 16 then return nil end
  local major, minor, patch = value:match("^(%d+)%.(%d+)%.(%d+)$")
  if not major then return nil end
  return tonumber(major), tonumber(minor), tonumber(patch)
end

local function newerVersion(value, current)
  local a1, a2, a3 = parseVersion(value)
  local b1, b2, b3 = parseVersion(current)
  if not a1 or not b1 then return false end
  if a1 ~= b1 then return a1 > b1 end
  if a2 ~= b2 then return a2 > b2 end
  return a3 > b3
end

local function validTime(value, now)
  return type(value) == "number" and value >= 0 and value <= now and value == math.floor(value)
end

function CommVersion.Init(global)
  if type(global) ~= "table" then notice = nil return false end
  local previous = type(global.updateNotice) == "table" and global.updateNotice or {}
  local version = parseVersion(previous.version) and previous.version or nil
  local now = Util.Now()
  local time = version and validTime(previous.time, now) and previous.time or 0
  if type(global.announced) == "table" then
    for value, announced in pairs(global.announced) do
      if announced == true and parseVersion(value) and (not version or newerVersion(value, version)) then version = value end
    end
  end
  notice = { version = version, time = time }
  global.updateNotice, global.announced = notice, nil
  return true
end

function CommVersion.Note(value)
  if warned or not notice or not newerVersion(value, ns.VERSION) then return false end
  if notice.version and not newerVersion(value, notice.version) then return false end
  local now = Util.Now()
  if notice.time > now then notice.time = 0 end
  if notice.time > 0 and now - notice.time < CommVersion.COOLDOWN then return false end
  notice.version, notice.time, warned = value, now, true
  ns.Print(string.format(MESSAGE, value))
  return true
end
