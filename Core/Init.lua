local ADDON, ns = ...

ns.ADDON            = ADDON
ns.VERSION          = "0.2.0"
ns.PROTOCOL_VERSION = 1
ns.DATA_VERSION     = 28
ns.MIN_DATA_VERSION = 28
ns.PREFIX           = "BgnB"
ns.CHANNEL          = "BagnonBattles"

ns.GRID_W     = 10
ns.GRID_H     = 8
ns.START_X    = 3
ns.START_Y    = 2
ns.START_W    = 3
ns.START_H    = 4
ns.MAX_BAGS   = 12

ns.QUALITY = { COMMON = 1, UNCOMMON = 2, RARE = 3, EPIC = 4, LEGENDARY = 5 }
ns.QUALITY_NAMES = { "Common", "Uncommon", "Rare", "Epic", "Legendary" }
ns.QUALITY_COLORS = {
  [1] = { r = 1.00, g = 1.00, b = 1.00 },
  [2] = { r = 0.12, g = 1.00, b = 0.00 },
  [3] = { r = 0.00, g = 0.44, b = 0.87 },
  [4] = { r = 0.64, g = 0.21, b = 0.93 },
  [5] = { r = 1.00, g = 0.50, b = 0.00 },
}

ns.SCHOOL_COLORS = {
  physical = { r = 1.00, g = 1.00, b = 0.00 },
  nature   = { r = 0.30, g = 1.00, b = 0.30 },
  arcane   = { r = 1.00, g = 0.50, b = 1.00 },
  fire     = { r = 1.00, g = 0.50, b = 0.00 },
  frost    = { r = 0.50, g = 1.00, b = 1.00 },
  shadow   = { r = 0.50, g = 0.50, b = 1.00 },
  holy     = { r = 1.00, g = 0.90, b = 0.50 },
  heal     = { r = 0.10, g = 1.00, b = 0.10 },
}

ns.RESOURCE_COLORS = {
  mana   = { r = 0.00, g = 0.00, b = 1.00 },
  rage   = { r = 1.00, g = 0.00, b = 0.00 },
  energy = { r = 1.00, g = 1.00, b = 0.00 },
  focus  = { r = 1.00, g = 0.50, b = 0.25 },
}

ns.RESOURCE_NAMES = { mana = "Mana", rage = "Rage", energy = "Energy", focus = "Focus", combo = "Combo Points" }
ns.RESOURCE_COLORS.combo = { r = 1.00, g = 0.85, b = 0.20 }

ns.L = setmetatable({}, { __index = function(_, key) return key end })

function ns.Print(...)
  local parts = {}
  for i = 1, select("#", ...) do parts[#parts + 1] = tostring(select(i, ...)) end
  local msg = table.concat(parts, " ")
  if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
    DEFAULT_CHAT_FRAME:AddMessage("|cffff8000Bagnon Battles:|r " .. msg)
  else
    print("[BB] " .. msg)
  end
end

function ns.Debug(...)
  if ns.db and ns.db.global and ns.db.global.settings and ns.db.global.settings.debug then
    ns.Print("|cff888888[debug]|r", ...)
  end
end

ns.icon = function(name) return "Interface\\Icons\\" .. name end
