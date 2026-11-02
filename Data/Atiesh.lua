local ADDON, ns = ...
local H = ns.H
local I, S = H.I, H.S

local variants = {
  { class = "MAGE", key = "mage", id = 9800, stats = { sp = 90, mana = 80, crit = 8 },
    triggers = { { on = "resourceSpent", resource = "mana", match = { tag = "spell", damaging = true }, everyAmount = 60,
      effects = { { type = "cast", target = "source" } } } } },
  { class = "WARLOCK", key = "warlock", id = 9804, stats = { sp = 95, healing = 30, hp = 100, mana = 50 },
    triggers = {
      { on = "healthSpent", effects = { { type = "buff", stat = "sp", value = 0, fromEvent = 0.5, duration = 8, key = "atiesh_dark_pact", name = "Atiesh" } } },
      { on = "dotTick", every = 4, effects = { { type = "heal", pctMax = 0.02, noCrit = true } } },
    } },
  { class = "PRIEST", key = "priest", id = 9808, stats = { sp = 65, healing = 120, mana = 60, regen = 4 },
    triggers = { { on = "healed", everyAmount = 50, effects = { { type = "cast", target = "all", match = { tag = "spell", damaging = "direct" }, choose = "random" } } } } },
  { class = "DRUID", key = "druid", id = 9812, stats = { sp = 55, healing = 110, ap = 60, mana = 60, regen = 3 },
    triggers = {
      { on = "hotTick", everyAmount = 30, effects = { { type = "cdr", target = "all", match = { kind = "form" }, amount = 0.5, clampReady = true } } },
      { on = "resourceSpent", resource = "rage", everyAmount = 30, effects = { { type = "heal", pctMax = 0.02, noCrit = true } } },
      { on = "resourceSpent", resource = "combo", everyAmount = 5, effects = { { type = "heal", pctMax = 0.03, noCrit = true } } },
    } },
}

for _, variant in ipairs(variants) do
  local classes, ingredients = { variant.class }, {}
  for index, part in ipairs({
    { key = "frame_of_atiesh", name = "Frame of Atiesh", icon = "INV_Staff_20", cost = 14, round = 12 },
    { key = "base_of_atiesh", name = "Base of Atiesh", icon = "INV_QirajIdol_Sun", cost = 12, round = 12 },
    { key = "staff_head_of_atiesh", name = "Staff Head of Atiesh", icon = "INV_Misc_AhnQirajTrinket_04", cost = 14, round = 14 },
  }) do
    local key = part.key .. "_" .. variant.key
    ingredients[index] = key
    ns.RegisterItem{ id = variant.id + index - 1, key = key, name = part.name, icon = I(part.icon),
      kind = "material", quality = 5, cost = part.cost, minRound = part.round, shape = S.one, unique = true, classes = classes }
  end
  H.Weapon{ id = variant.id + 3, key = "atiesh_" .. variant.key, name = "Atiesh, Greatstaff of the Guardian", icon = I("INV_Staff_Medivh"),
    quality = 5, cost = 40, craftedCost = 40, minRound = 14, noShop = true, craftable = true, unique = true, classes = classes,
    weaponType = "staff", hands = 2, shape = S.v4, weaponMin = 20, weaponMax = 30, speed = 2.9,
    stats = variant.stats, triggers = variant.triggers, passiveTriggers = true }
  ns.RegisterRecipe{ inputs = ingredients, output = "atiesh_" .. variant.key }
end
