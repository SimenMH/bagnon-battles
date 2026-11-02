local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S

local B = {
  row3 = { "111" },
  row4 = { "1111" },
  row6 = { "111111" },
  corner3 = { "10", "11" },
  corner5 = { "11", "11", "10" },
  cee6 = { "11", "10", "10", "11" },
}

H.Bag{ id = 1, key = "linen_bag", name = "Linen Bag", icon = I("inv_misc_bag_01"), quality = 1, minRound = 1, shape = S.sq }
H.Bag{ id = 2, key = "small_red_pouch", name = "Red Linen Bag", icon = I("inv_misc_bag_02"), quality = 1, minRound = 1, shape = B.row3 }
H.Bag{ id = 3, key = "small_black_pouch", name = "Small Black Pouch", icon = I("INV_Misc_Bag_09_Black"), quality = 1, minRound = 1, shape = B.corner3 }
H.Bag{ id = 4, key = "woolen_bag", name = "Woolen Bag", icon = I("INV_Misc_Bag_10"), quality = 1, minRound = 1, shape = B.row4 }
H.Bag{ id = 18, key = "small_brown_pouch", name = "Small Brown Pouch", icon = I("inv_misc_bag_09"), quality = 1, cost = 1, minRound = 1, shape = S.one }

H.Bag{ id = 5, key = "red_woolen_bag", name = "Red Woolen Bag", icon = I("INV_Misc_Bag_10_Red"), quality = 2, minRound = 2, shape = S.r32 }
H.Bag{ id = 6, key = "small_silk_pack", name = "Small Silk Pack", icon = I("inv_misc_bag_07"), quality = 2, minRound = 2, shape = S.r23 }
H.Bag{ id = 16, key = "green_silk_pack", name = "Green Silk Pack", icon = I("inv_misc_bag_07_green"), quality = 2, minRound = 3, shape = S.r23 }
H.Bag{ id = 17, key = "black_silk_pack", name = "Black Silk Pack", icon = I("inv_misc_bag_07_black"), quality = 2, minRound = 3, shape = B.corner5 }
H.Bag{ id = 7, key = "mageweave_bag", name = "Mageweave Bag", icon = I("inv_misc_bag_10_black"), quality = 2, minRound = 4, shape = B.row6 }
H.Bag{ id = 8, key = "red_mageweave_bag", name = "Red Mageweave Bag", icon = I("inv_misc_bag_10_red"), quality = 2, minRound = 4, shape = B.cee6 }

H.Bag{ id = 9, key = "runecloth_bag", name = "Runecloth Bag", icon = I("inv_misc_bag_19"), quality = 3, minRound = 6, shape = S.r24 }
H.Bag{ id = 13, key = "mooncloth_bag", name = "Mooncloth Bag", icon = I("inv_misc_bag_14"), quality = 3, minRound = 6, shape = { "111", "111", "111" } }
H.Bag{ id = 10, key = "travelers_backpack", name = "Traveler's Backpack", icon = I("inv_misc_bag_08"), quality = 3, minRound = 7, shape = S.r24 }

H.Bag{ id = 11, key = "onyxia_hide_backpack", name = "Onyxia Hide Backpack", icon = I("inv_misc_bag_22"), quality = 4, minRound = 9, shape = S.r34 }
H.Bag{ id = 12, key = "bottomless_bag", name = "Bottomless Bag", icon = I("inv_misc_bag_13"), quality = 4, minRound = 10, shape = S.r25 }
H.Bag{ id = 14, key = "core_felcloth_bag", name = "Core Felcloth Bag", icon = I("inv_misc_bag_corefelclothbag"), quality = 4, minRound = 10, shape = S.r25 }

H.Bag{ id = 15, key = "satchel_of_cenarius", name = "Satchel of Cenarius", icon = I("inv_misc_bag_satchelofcenarius"), quality = 5, minRound = 12, shape = S.r44 }
