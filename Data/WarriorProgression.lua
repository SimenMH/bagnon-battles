local ADDON, ns = ...

-- Curated Warrior progression. Keep these choices local to the class: other
-- classes need their own resource, companion, buff and feedback review.
local function item(key) return assert(ns.ItemsByKey[key], key) end
local function effect(key, index) return item(key).use.effects[index or 1] end
local function attack(key, values)
  local e = effect(key)
  for field, value in pairs(values) do e[field] = value end
end

attack("heroic_strike", { min = 2, max = 3, weaponPct = 0.8, coef = 0.25 })
attack("rend", { tick = 1, coef = 0.1 })
local overpower = item("overpower").triggers[1].effects[1]
overpower.min, overpower.max, overpower.weaponPct, overpower.coef = 1, 3, 0.8, 0.3
attack("mortal_strike", { min = 3, max = 5, weaponPct = 1.2, coef = 0.6 })
attack("execute", { min = 4, max = 6, coef = 0.95 })
attack("bloodthirst", { min = 2, max = 4, coef = 0.6 })
local bloodHeal = effect("bloodthirst", 2)
bloodHeal.min, bloodHeal.max, bloodHeal.pctMax, bloodHeal.coef, bloodHeal.powerStat = 1, 2, 0.0075, 0.05, "ap"
for _, e in ipairs(item("whirlwind").use.effects) do e.min, e.max, e.weaponPct, e.coef = 1, 2, 0.65, 0.2 end
attack("slam", { min = 1, max = 3, weaponPct = 1.7, coef = 0.3 })
item("cleave").quality, item("cleave").minRound, item("cleave").cost, item("cleave").use.cost = 2, 2, 5, 20
item("cleave").shopWeight = 1.4
item("cleave").shopAffinities = { WARRIOR = { fury = 1, arms = 0.8 } }
for _, e in ipairs(item("cleave").use.effects) do e.min, e.max, e.weaponPct, e.coef = 2, 4, 1.25, 0.3 end
attack("shield_slam", { min = 2, max = 4, coef = 0.6, blockScale = 3, bankScale = 1 })
item("shield_slam").triggers[1].effects[1].cap = { hp = 0.25, block = 2 }
for _, trigger in ipairs(item("revenge").triggers) do
  local e = trigger.effects[1]
  e.min, e.max, e.coef, e.blockScale = 1, 3, 0.3, 0.4
end
attack("shield_bash", { min = 1, max = 3, coef = 0.25, blockScale = 2 })
attack("hamstring", { min = 1, max = 2, coef = 0.15 })
attack("pummel", { min = 1, max = 3, coef = 0.2 })
attack("thunder_clap", { min = 1, max = 3, coef = 0.3 })

-- Shout rewards printed equipped AP. It never reads total AP or other buffs.
local shout = effect("battle_shout")
shout.value, shout.gearCoef, shout.gearCap = 0, 0.4, 24
item("battle_shout").tags[#item("battle_shout").tags + 1] = "prot"
item("battle_shout").tagSet.prot = true

-- These supports change a window's strength, not both its frequency and output.
local craze = item("blood_craze").triggers[1].effects[1]
craze.tick, craze.coef, craze.powerStat = 1, 0.1, "ap"
item("death_wish").triggers[1].effects[1].value = 75
local anticipation = item("warrior_anticipation")
anticipation.triggers[1].icd = 2
anticipation.triggers[1].effects[1].match = { kind = "ability", tag = "strike", damaging = "direct" }
anticipation.triggers[1].effects[1].amount = 0.75
-- A dodged free Mortal Strike can trigger another Overpower. Bound the
-- follow-up talent itself so high avoidance/crit cannot become an instant loop.
item("improved_overpower").triggers[1].icd = 2
item("defensive_stance").stats.dr, item("defensive_stance").stats.dmgPct = 10, -10
-- Cleave's weapon improvement is a real geared attack contribution; it never
-- creates another activation, critical roll or Rage-generation event.
item("improved_cleave").triggers[1].effects[1].weaponPct = 0.75

local fractionPower = { unit = "fraction", scale = "power" }
local fractionMult = { unit = "fraction", scale = "mult" }
local fractionFixed = { unit = "fraction", scale = false }
local percentMult = { unit = "percent", scale = "mult" }
local percentFixed = { unit = "percent", scale = false }
local percentFields = {
  heroic_strike = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.weaponPct"] = fractionPower },
  -- Rend uses an explicitly curated 10/12.5/15% curve below. Applying the
  -- general five-point grid would collapse rank 2 back to rank 1's 10%.
  overpower = { ["triggers.1.effects.1.coef"] = fractionPower, ["triggers.1.effects.1.weaponPct"] = fractionPower },
  mortal_strike = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.weaponPct"] = fractionPower },
  execute = { ["use.effects.1.coef"] = fractionPower },
  bloodthirst = { ["use.effects.1.coef"] = fractionPower, ["use.effects.2.coef"] = fractionMult, ["use.effects.2.pctMax"] = fractionPower },
  whirlwind = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.weaponPct"] = fractionPower,
    ["use.effects.2.coef"] = fractionPower, ["use.effects.2.weaponPct"] = fractionPower },
  slam = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.weaponPct"] = fractionPower },
  cleave = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.weaponPct"] = fractionPower },
  shield_slam = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.blockScale"] = fractionPower },
  revenge = { ["triggers.1.effects.1.coef"] = fractionPower, ["triggers.1.effects.1.blockScale"] = fractionPower,
    ["triggers.2.effects.1.coef"] = fractionPower, ["triggers.2.effects.1.blockScale"] = fractionPower },
  shield_bash = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.blockScale"] = fractionPower },
  hamstring = { ["use.effects.1.coef"] = fractionPower, ["use.effects.2.value"] = percentMult, ["use.effects.3.value"] = percentMult },
  pummel = { ["use.effects.1.coef"] = fractionPower, ["use.effects.3.value"] = percentMult },
  thunder_clap = { ["use.effects.1.coef"] = fractionPower, ["use.effects.2.value"] = percentMult },
  battle_shout = { ["use.effects.1.gearCoef"] = fractionFixed },
  shield_block = { ["use.effects.1.value"] = percentMult },
  flurry = { ["triggers.1.effects.1.value"] = percentMult },
  deep_wounds = { ["triggers.1.effects.1.fromEvent"] = fractionFixed },
  death_wish = { ["triggers.1.effects.1.value"] = percentMult, ["triggers.1.effects.2.value"] = percentMult },
  dual_wield_specialization = { ["triggers.1.effects.1.value"] = percentMult },
  demoralizing_shout = { ["use.effects.2.value"] = percentMult },
  impale = { ["triggers.1.effects.1.value"] = percentMult },
  berserker_stance = { ["triggers.1.effects.1.gearCoef"] = fractionFixed, ["triggers.1.effects.1.value"] = percentFixed },
  intercept = { ["use.effects.1.coef"] = fractionPower, ["use.effects.1.weaponPct"] = fractionPower },
  improved_cleave = { ["triggers.1.effects.1.weaponPct"] = fractionPower },
  toughness = { ["triggers.1.effects.1.gearCoef"] = fractionFixed },
  improved_shield_bash = { ["triggers.1.effects.1.value"] = percentFixed },
  defensive_stance = { ["stats.dr"] = percentFixed, ["stats.dmgPct"] = percentFixed },
}

-- More families receive meaningful training, using the familiar two upgrade
-- milestones. Five scalar-only tiers added purchases without new decisions.
-- Explicit Rage costs avoid the old 3x cost curve on an invested core.
local POWERS = { 1.3, 1.65 }
local UNLOCKS = { 4, 7 }
local function profile(key, costs, overrides, maximum)
  local base = item(key)
  local fields = percentFields[key]
  if fields then ns.H.FriendlyBasePercentages(base, fields) end
  maximum = maximum or 3
  base.rankable = true
  base.rankProfile = { maxRank = maximum, ranks = {} }
  for rank = 2, maximum do
    local power = POWERS[rank - 1]
    local rule = { minRound = math.max(base.minRound, UNLOCKS[rank - 1]),
      trainingCost = rank == 2 and base.quality + 1 or base.quality * 2 + 1,
      scale = { mult = power, power = power, cost = 1, offensiveMana = 1 },
      overrides = overrides and overrides[rank] }
    if rank > 3 then rule.id = base.id + (rank == 4 and 40000 or 50000) end
    if costs then rule.resourceCost = costs[rank] end
    if fields then ns.H.FriendlyRankPercentages(base, rule, fields) end
    base.rankProfile.ranks[rank] = rule
  end
end

profile("heroic_strike", { [2] = 12, [3] = 18 }, { [3] = { ["use.cd"] = 3 } })
profile("rend", { [2] = 7, [3] = 13 }, { [2] = { ["use.effects.1.coef"] = 0.125 },
  [3] = { ["use.effects.1.coef"] = 0.15 } })
profile("overpower")
profile("mortal_strike", { [2] = 29, [3] = 43 }, { [3] = { ["use.cd"] = 8 } })
profile("execute", { [2] = 18, [3] = 27 })
local bloodRanks = {}
for rank = 2, 3 do bloodRanks[rank] = { ["use.effects.2.pctMax"] = rank == 2 and 0.0125 or 0.015,
  ["use.effects.2.coef"] = rank == 2 and 0.07 or 0.09 } end
profile("bloodthirst", { [2] = 23, [3] = 34 }, bloodRanks)
profile("whirlwind", { [2] = 24, [3] = 36 }, { [3] = { ["use.cd"] = 5.5 } })
profile("slam", { [2] = 23, [3] = 34 })
profile("cleave", { [2] = 24, [3] = 32 }, { [3] = { ["use.cd"] = 8 } })
profile("shield_slam", { [2] = 23, [3] = 34 })
profile("revenge")
profile("shield_bash", { [2] = 12, [3] = 18 })
-- Control magnitude stays bounded while training improves the attack.
profile("hamstring", { [2] = 9, [3] = 12 }, {
  [2] = { ["use.effects.2.value"] = 15, ["use.effects.3.value"] = 9 },
  [3] = { ["use.effects.2.value"] = 15, ["use.effects.3.value"] = 12 },
})
local pummelRanks, clapRanks = {}, {}
for rank = 2, 3 do
  pummelRanks[rank] = { ["use.effects.3.value"] = 20 }
  clapRanks[rank] = { ["use.effects.2.value"] = 20 }
end
profile("pummel", { [2] = 17, [3] = 23 }, pummelRanks)
profile("thunder_clap", { [2] = 14, [3] = 20 }, clapRanks)

local shoutRanks = {}
for rank = 2, 3 do shoutRanks[rank] = { ["use.effects.1.gearCoef"] = rank == 2 and 0.5 or 0.6,
  ["use.effects.1.gearCap"] = rank == 2 and 40 or 60 } end
profile("battle_shout", { [2] = 11, [3] = 14 }, shoutRanks)
profile("shield_block", { [2] = 12, [3] = 14 }, {
  [2] = { ["use.effects.1.value"] = 48 }, [3] = { ["use.effects.1.value"] = 56 },
}, 3)
profile("flurry", nil, { [2] = { ["triggers.1.effects.1.value"] = 30 },
  [3] = { ["triggers.1.effects.1.value"] = 35 } }, 3)
profile("deep_wounds", nil, { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.36 },
  [3] = { ["triggers.1.effects.1.fromEvent"] = 0.42 } }, 3)
-- Preserve the deliberate 12.5% middle rank instead of rounding it to 15%.
profile("blood_craze", nil, { [2] = { ["triggers.1.effects.1.coef"] = 0.125, ["triggers.1.effects.1.tick"] = 1 },
  [3] = { ["triggers.1.effects.1.coef"] = 0.15, ["triggers.1.effects.1.tick"] = 1 } }, 3)
profile("death_wish", nil, { [2] = { ["triggers.1.effects.1.value"] = 90, ["triggers.1.effects.2.value"] = -20 },
  [3] = { ["triggers.1.effects.1.value"] = 105, ["triggers.1.effects.2.value"] = -20 } }, 3)
item("death_wish").rankProfile.ranks[2].id = 31217
item("death_wish").rankProfile.ranks[3].id = 61217
profile("dual_wield_specialization", nil, { [2] = { ["triggers.1.effects.1.value"] = 24 },
  [3] = { ["triggers.1.effects.1.value"] = 28 } }, 3)
profile("warrior_anticipation", nil, { [2] = { ["stats.dodge"] = 4, ["stats.blockChance"] = 6, ["triggers.1.effects.1.amount"] = 0.9 },
  [3] = { ["stats.dodge"] = 5, ["stats.blockChance"] = 7, ["triggers.1.effects.1.amount"] = 1 } }, 3)

profile("sunder_armor", { [2] = 12, [3] = 14 }, { [2] = { ["use.effects.1.value"] = 16 },
  [3] = { ["use.effects.1.value"] = 20 } }, 3)
profile("demoralizing_shout", { [2] = 12, [3] = 14 }, {
  [2] = { ["use.effects.1.value"] = 20, ["use.effects.2.value"] = 12 },
  [3] = { ["use.effects.1.value"] = 24, ["use.effects.2.value"] = 12 },
}, 3)

-- Encounter weights express accessibility, separately from power rarity.
for key, weight in pairs({ mortal_strike = 2, bloodthirst = 2.2, shield_slam = 1.8, rend = 1.4,
  slam = 1.5, shield_block = 1.4, bloodrage = 1.4, improved_execute = 0.7,
  sword_specialization = 0.7, sweeping_strikes = 0.65, shield_specialization = 0.65 }) do item(key).shopWeight = weight end

-- New Classic families train the useful part of their identity, keeping
-- geometry, control frequency and damage-reduction limits fixed.
profile("intercept", { [2] = 18, [3] = 22 })
profile("intimidating_shout", { [2] = 20, [3] = 20 }, {
  [2] = { ["use.effects.1.duration"] = 1.25 }, [3] = { ["use.effects.1.duration"] = 1.5 },
})
profile("improved_cleave", nil, { [2] = { ["triggers.1.effects.1.weaponPct"] = 1 },
  [3] = { ["triggers.1.effects.1.weaponPct"] = 1.25 } })
profile("improved_bloodrage", nil, { [2] = { ["triggers.1.effects.1.amount"] = 6 },
  [3] = { ["triggers.1.effects.1.amount"] = 8 } })
profile("deflection", nil, { [2] = { ["triggers.1.effects.1.amount"] = 0.5 },
  [3] = { ["triggers.1.effects.1.amount"] = 0.75 } })
profile("toughness", nil, { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.2, ["triggers.1.effects.1.gearCap"] = 45 },
  [3] = { ["triggers.1.effects.1.gearCoef"] = 0.25, ["triggers.1.effects.1.gearCap"] = 60 } })
profile("improved_shield_bash", nil, { [2] = { ["triggers.1.effects.1.value"] = 30 },
  [3] = { ["triggers.1.effects.1.value"] = 35 } })
profile("impale", nil, { [2] = { ["triggers.1.effects.1.value"] = 40 },
  [3] = { ["triggers.1.effects.1.value"] = 50 } }, 3)
profile("berserker_stance", nil, { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.35, ["triggers.1.effects.1.gearCap"] = 9 },
  [3] = { ["triggers.1.effects.1.gearCoef"] = 0.5, ["triggers.1.effects.1.gearCap"] = 12 } }, 3)
profile("battle_stance", nil, { [2] = { ["triggers.1.effects.2.amount"] = 0.75 },
  [3] = { ["triggers.1.effects.2.amount"] = 1 } }, 3)
profile("defensive_stance", nil, { [2] = { ["stats.dr"] = 15 }, [3] = { ["stats.dr"] = 20 } })
