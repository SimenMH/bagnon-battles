local ADDON, ns = ...
local H = ns.H
local I = H.I
local DRUID = { "DRUID" }

H.Jewel{ id = 1043, key = "idol_of_ferocity", name = "Idol of Ferocity", icon = I("INV_Relics_IdolofFerocity"), kind = "relic", quality = 3, minRound = 7, classes = DRUID, tags = { "feral" },
  triggers = { { on = "anyUse", match = { tag = "finisher" }, effects = { { type = "resource", resource = "combo", amount = 1 } } } } }

H.Jewel{ id = 2248, key = "idol_of_rejuvenation", name = "Idol of Rejuvenation", icon = I("inv_relics_idolofrejuvenation"), kind = "relic", quality = 3, cost = 7, minRound = 4, classes = DRUID, stats = { healing = 8 },
  triggers = { { on = "hotTick", every = 5, effects = { { type = "buff", stat = "none", value = 0, double = { tag = "heal" }, charges = 1, duration = 15, key = "idol_of_rejuvenation", name = "Idol of Rejuvenation" } } } } }
H.Jewel{ id = 2249, key = "idol_of_the_moon", name = "Idol of the Moon", icon = I("inv_relics_idolofrejuvenation"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = DRUID, stats = { sp = 8 },
  triggers = { { on = "dotTick", match = { tag = "spell" }, every = 5, effects = { { type = "buff", stat = "crit", value = 100, target = "all", match = { tag = "spell", damaging = "direct" }, charges = 1, duration = 15, key = "idol_of_the_moon", name = "Idol of the Moon" } } } } }
H.Jewel{ id = 2250, key = "idol_of_brutality", name = "Idol of Brutality", icon = I("inv_relics_idolofferocity"), kind = "relic", quality = 3, cost = 7, minRound = 5, classes = DRUID, stats = { armor = 12 },
  triggers = { { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "cdr", target = "all", match = { kind = "form", tag = "autoattack" }, amount = 1, clampReady = true } } } } }
