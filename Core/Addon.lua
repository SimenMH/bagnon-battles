local ADDON, ns = ...
local Util = ns.Util

local Addon = LibStub("AceAddon-3.0"):NewAddon("BagnonBattles", "AceEvent-3.0", "AceTimer-3.0")
ns.Addon = Addon

local defaults = {
  global = {
    pool = {},
    selfNames = {},
    run = nil,
    settings = { share = true, traffic = false, minimap = { hide = false, angle = 220 }, speed = 1, debug = false, scale = 1, lastClass = "DRUID", sounds = true, soundChannel = "SFX" },
    stats = { runs = 0, gamesWon = 0, currentWinStreak = 0, bestWinStreak = 0, forgedLegendaries = 0 },
  },
}

local function storeBackup(global, reason, saved, time)
  global.runBackups = type(global.runBackups) == "table" and global.runBackups or {}
  local backups = global.runBackups
  backups[#backups + 1] = { reason = reason, time = time or Util.Now(), version = ns.VERSION, run = saved }
  while #backups > ns.Migrations.MAX_BACKUPS do table.remove(backups, 1) end
end

local function recordRunWin(run, stats)
  if not run or run.wins < ns.Economy.MAX_WINS or run.winCounted then return false end
  stats.gamesWon = (stats.gamesWon or 0) + 1
  stats.currentWinStreak = (stats.currentWinStreak or 0) + 1
  stats.bestWinStreak = math.max(stats.bestWinStreak or 0, stats.currentWinStreak)
  run.winCounted = true
  return true
end

local function recordRunEnd(run, stats)
  if not run or recordRunWin(run, stats) or run.winCounted then return end
  stats.currentWinStreak = 0
end

local function recordCrafts(saved, previous, stats)
  local before = type(previous) == "table" and type(previous.craftedLegendaries) == "table" and previous.craftedLegendaries or {}
  for _, recipe in ipairs(ns.Recipes) do
    local def = ns.ItemsByKey[recipe.output]
    if def and def.craftable and def.quality == ns.QUALITY.LEGENDARY
      and saved.craftedLegendaries[recipe.output] and not before[recipe.output] then
      stats.forgedLegendaries = (stats.forgedLegendaries or 0) + 1
    end
  end
end

function ns.PlayerName()
  if ns.IS_FOREVER then
    local name, surname = UnitFullName("player")
    if surname and surname ~= "" then return (name or "Player") .. "-" .. surname end
    return name or "Player"
  end
  local name = UnitName("player")
  local realm = GetNormalizedRealmName and GetNormalizedRealmName() or (GetRealmName and GetRealmName():gsub("%s", "")) or "Realm"
  return (name or "Player") .. "-" .. realm
end

function Addon:OnInitialize()
  self.db = LibStub("AceDB-3.0"):New("BagnonBattlesDB", defaults, true)
  ns.db = self.db
  local settings = self.db.global.settings
  if not settings.sharingLogsQuieted then
    settings.traffic, settings.debug, settings.sharingLogsQuieted = false, false, true
  end
  ns.Pool.Init(self.db.global)
  local problems = ns.ValidateRegistry()
  if #problems > 0 then
    for _, p in ipairs(problems) do ns.Print("|cffff2020Data problem:|r " .. p) end
  end
  local global = self.db.global
  if global.inventoryRecoveryBackup then
    storeBackup(global, "migration", global.inventoryRecoveryBackup, 0)
    global.inventoryRecoveryBackup = nil
  end
  if global.run then
    local loaded = ns.Migrations.LoadSaved(global.run)
    ns.run, global.run = loaded.run, loaded.save
    for _, backup in ipairs(loaded.backups) do storeBackup(global, backup.reason, backup.run) end
    for _, message in ipairs(loaded.messages) do ns.Print(message) end
  end
  if self.db.global.run and ns.run then
    local counted = recordRunWin(ns.run, self.db.global.stats)
    if ns.run:IsOver() then recordRunEnd(ns.run, self.db.global.stats) end
    if counted or ns.run:IsOver() then self:SaveRun() end
  end
  SLASH_BAGNONBATTLES1 = "/bb"
  SLASH_BAGNONBATTLES2 = "/bagnonbattles"
  SlashCmdList.BAGNONBATTLES = function(input) Addon:HandleSlash(input or "") end
end

function Addon:OnEnable()
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  ns.UI.Minimap.Init()
  ns.UI.Options.Register()
end

function Addon:PLAYER_REGEN_DISABLED()
  if ns.UI.Main and ns.UI.Main.frame and ns.UI.Main.frame:IsShown() then
    ns.UI.Main.frame:Hide()
    ns.Print(ns.L["Combat started, closing the bag. Reopen with /bb when it's over."])
  end
end

function Addon:PLAYER_ENTERING_WORLD(event, isLogin, isReload)
  if isLogin or isReload then
    ns.Comm.Start()
  end
end

function Addon:HandleSlash(input)
  local cmd, rest = input:match("^(%S*)%s*(.-)$")
  cmd = (cmd or ""):lower()
  if cmd == "" or cmd == "show" or cmd == "toggle" then
    ns.UI.Main.Toggle()
  elseif cmd == "pool" then
    local counts = ns.Pool.Counts()
    local parts = {}
    for r = 1, ns.Economy.ROUNDS do parts[#parts + 1] = string.format("r%d:%d", r, counts[r]) end
    ns.Print(ns.L["Stored builds"] .. ": " .. ns.Pool.Count() .. "  " .. table.concat(parts, " "))
    ns.Print(ns.L["Players seen"] .. ": " .. ns.Comm.PeerCount() .. "  " .. ns.L["Channel"] .. ": " .. (ns.Comm.ChannelIndex() or ns.L["not joined"]))
  elseif cmd == "share" then
    ns.Comm.SetSharing(not self.db.global.settings.share)
    ns.Print(ns.L["Build sharing"] .. ": " .. (self.db.global.settings.share and ns.L["on"] or ns.L["off"]))
  elseif cmd == "traffic" then
    local mode = (rest or ""):lower():match("^%s*(.-)%s*$")
    if mode == "" then
      ns.Comm.SetTraffic(not self.db.global.settings.traffic)
    elseif mode == "on" or mode == "off" then
      ns.Comm.SetTraffic(mode == "on")
    else
      ns.Print(ns.L["Usage: /bb traffic on or /bb traffic off"])
    end
  elseif cmd == "minimap" then
    self.db.global.settings.minimap.hide = not self.db.global.settings.minimap.hide
    ns.UI.Minimap.Refresh()
  elseif cmd == "options" or cmd == "config" then
    ns.UI.Options.Open()
  elseif cmd == "debug" then
    self.db.global.settings.debug = not self.db.global.settings.debug
    ns.Print(ns.L["Debug"] .. ": " .. tostring(self.db.global.settings.debug))
  elseif cmd == "abandon" then
    self:AbandonRun()
    ns.Print(ns.L["Run abandoned."])
  elseif cmd == "resetpool" then
    ns.Pool.Clear()
    ns.Print(ns.L["Stored builds cleared."])
  else
    ns.Print(ns.L["Commands: /bb, /bb pool, /bb share, /bb traffic, /bb minimap, /bb abandon"])
  end
end

function Addon:NewRun(classKey)
  if ns.UI.Dialogs then ns.UI.Dialogs.HideSurvival() end
  local seed = Util.Hash32(ns.PlayerName() .. tostring(Util.Now()) .. tostring(GetTime and GetTime() or 0))
  local replacement = ns.Run.New(classKey, seed, ns.PlayerName())
  recordRunEnd(ns.run, self.db.global.stats)
  ns.run = replacement
  self.db.global.settings.lastClass = classKey
  self.db.global.stats.runs = self.db.global.stats.runs + 1
  self:SaveRun()
  return ns.run
end

function Addon:SaveRun()
  if ns.run and not ns.run:IsOver() then
    local saved = ns.run:Serialize()
    recordCrafts(saved, self.db.global.run, self.db.global.stats)
    self.db.global.run = saved
  else
    self.db.global.run = nil
  end
end

function Addon:AbandonRun()
  if ns.UI.Dialogs then ns.UI.Dialogs.HideSurvival() end
  recordRunEnd(ns.run, self.db.global.stats)
  ns.run = nil
  self.db.global.run = nil
  if ns.UI.Main.frame and ns.UI.Main.frame:IsShown() then ns.UI.Main.ShowScreen("home") end
end

function Addon:DismissFinishedRun()
  if ns.run and not ns.run:IsOver() then return end
  ns.run = nil
  self:SaveRun()
end

function Addon:LockIn()
  local run = ns.run
  if not run then return nil end
  local result, opponent, mine = run:LockIn(ns.FindOpponent)
  if not result then return nil end
  local stats = self.db.global.stats
  recordRunWin(run, stats)
  if ns.Economy.LivesRemaining(run) == 0 or run.round >= ns.Economy.ROUNDS then recordRunEnd(run, stats) end
  ns.Comm.SendBuild(mine)
  self:SaveRun()
  return result, opponent
end

function Addon:NextRound()
  local run = ns.run
  if not run then return end
  local ok, finished = run:NextRound()
  if ok and run:IsOver() then recordRunEnd(run, self.db.global.stats) end
  self:SaveRun()
  return finished
end

function Addon:ChooseSurvival(continue)
  local run = ns.run
  if not run then return false, ns.L["No active run."] end
  local ok, finished = run:ChooseSurvival(continue)
  if not ok then return false, finished end
  if run:IsOver() then recordRunEnd(run, self.db.global.stats) end
  self:SaveRun()
  return true, finished
end

