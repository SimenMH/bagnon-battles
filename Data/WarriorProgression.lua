local ADDON, ns = ...
local H = ns.H
local SCALES = { [2] = { cost = 1, mult = 1.3, offensiveMana = 1, power = 1.3 }, [3] = { cost = 1, mult = 1.65, offensiveMana = 1, power = 1.65 } }




H.RankProfile{
  key = "heroic_strike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.35, ["use.effects.1.weaponPct"] = 1.05 }, [3] = { ["use.cd"] = 3, ["use.effects.1.coef"] = 0.4, ["use.effects.1.weaponPct"] = 1.3 } },
  resourceCosts = { [2] = 12, [3] = 18 }, scales = SCALES,
}


H.RankProfile{ key = "rend", overrides = { [2] = { ["use.effects.1.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.15 } }, resourceCosts = { [2] = 7, [3] = 13 }, scales = SCALES }

H.RankProfile{
  key = "overpower",
  overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.4, ["triggers.1.effects.1.weaponPct"] = 1.05 }, [3] = { ["triggers.1.effects.1.coef"] = 0.5, ["triggers.1.effects.1.weaponPct"] = 1.3 } },
  scales = SCALES,
}

H.RankProfile{
  key = "mortal_strike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.8, ["use.effects.1.weaponPct"] = 1.55 }, [3] = { ["use.cd"] = 8, ["use.effects.1.coef"] = 1, ["use.effects.1.weaponPct"] = 2 } },
  resourceCosts = { [2] = 29, [3] = 43 }, scales = SCALES,
}

H.RankProfile{ key = "execute", overrides = { [2] = { ["use.effects.1.coef"] = 1.25 }, [3] = { ["use.effects.1.coef"] = 1.55 } }, resourceCosts = { [2] = 18, [3] = 27 }, scales = SCALES }

H.RankProfile{
  key = "bloodthirst",
  overrides = {
    [2] = { ["use.effects.1.coef"] = 0.8, ["use.effects.2.coef"] = 0.07, ["use.effects.2.pctMax"] = 0.0125 },
    [3] = { ["use.effects.1.coef"] = 1, ["use.effects.2.coef"] = 0.09, ["use.effects.2.pctMax"] = 0.015 },
  },
  resourceCosts = { [2] = 23, [3] = 34 }, scales = SCALES,
}

H.RankProfile{
  key = "whirlwind",
  overrides = {
    [2] = { ["use.effects.1.coef"] = 0.25, ["use.effects.1.weaponPct"] = 0.85, ["use.effects.2.coef"] = 0.25, ["use.effects.2.weaponPct"] = 0.85 },
    [3] = { ["use.cd"] = 5.5, ["use.effects.1.coef"] = 0.35, ["use.effects.1.weaponPct"] = 1.05, ["use.effects.2.coef"] = 0.35, ["use.effects.2.weaponPct"] = 1.05 },
  },
  resourceCosts = { [2] = 24, [3] = 36 }, scales = SCALES,
}

H.RankProfile{ key = "flurry", overrides = { [2] = { ["triggers.1.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 35 } }, scales = SCALES }

H.RankProfile{
  key = "death_wish", ids = { [2] = 31217, [3] = 61217 },
  overrides = { [2] = { ["triggers.1.effects.1.value"] = 90, ["triggers.1.effects.2.value"] = -20 }, [3] = { ["triggers.1.effects.1.value"] = 105, ["triggers.1.effects.2.value"] = -20 } },
  scales = SCALES,
}

H.RankProfile{ key = "shield_block", overrides = { [2] = { ["use.effects.1.value"] = 50 }, [3] = { ["use.effects.1.value"] = 55 } }, resourceCosts = { [2] = 12, [3] = 14 }, scales = SCALES }

H.RankProfile{
  key = "shield_slam",
  overrides = { [2] = { ["use.effects.1.blockScale"] = 3.9, ["use.effects.1.coef"] = 0.8 }, [3] = { ["use.effects.1.blockScale"] = 4.95, ["use.effects.1.coef"] = 1 } },
  resourceCosts = { [2] = 23, [3] = 34 }, scales = SCALES,
}

H.RankProfile{
  key = "revenge",
  overrides = {
    [2] = { ["triggers.1.effects.1.blockScale"] = 0.5, ["triggers.1.effects.1.coef"] = 0.4, ["triggers.2.effects.1.blockScale"] = 0.5, ["triggers.2.effects.1.coef"] = 0.4 },
    [3] = { ["triggers.1.effects.1.blockScale"] = 0.65, ["triggers.1.effects.1.coef"] = 0.5, ["triggers.2.effects.1.blockScale"] = 0.65, ["triggers.2.effects.1.coef"] = 0.5 },
  },
  scales = SCALES,
}

H.RankProfile{ key = "sunder_armor", overrides = { [2] = { ["use.effects.1.value"] = 16 }, [3] = { ["use.effects.1.value"] = 20 } }, resourceCosts = { [2] = 12, [3] = 14 }, scales = SCALES }

H.RankProfile{ key = "deep_wounds", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.35 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.4 } }, scales = SCALES }


H.RankProfile{
  key = "blood_craze",
  overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.125, ["triggers.1.effects.1.tick"] = 1 }, [3] = { ["triggers.1.effects.1.coef"] = 0.15, ["triggers.1.effects.1.tick"] = 1 } },
  scales = SCALES,
}

H.RankProfile{ key = "impale", overrides = { [2] = { ["triggers.1.effects.1.value"] = 40 }, [3] = { ["triggers.1.effects.1.value"] = 50 } }, scales = SCALES }

H.RankProfile{ key = "battle_shout", overrides = { [2] = { ["use.effects.1.gearCoef"] = 0.25 }, [3] = { ["use.effects.1.gearCoef"] = 0.3 } }, resourceCosts = { [2] = 11, [3] = 14 }, scales = SCALES }

H.RankProfile{
  key = "slam",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.4, ["use.effects.1.weaponPct"] = 2.2 }, [3] = { ["use.effects.1.coef"] = 0.5, ["use.effects.1.weaponPct"] = 2.8 } },
  resourceCosts = { [2] = 23, [3] = 34 }, scales = SCALES,
}

H.RankProfile{ key = "dual_wield_specialization", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } }, scales = SCALES }

H.RankProfile{
  key = "cleave",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.4, ["use.effects.1.weaponPct"] = 1.65 }, [3] = { ["use.cd"] = 8, ["use.effects.1.coef"] = 0.5, ["use.effects.1.weaponPct"] = 2.05 } },
  resourceCosts = { [2] = 24, [3] = 32 }, scales = SCALES,
}

H.RankProfile{
  key = "shield_bash",
  overrides = { [2] = { ["use.effects.1.blockScale"] = 2.6, ["use.effects.1.coef"] = 0.35 }, [3] = { ["use.effects.1.blockScale"] = 3.3, ["use.effects.1.coef"] = 0.4 } },
  resourceCosts = { [2] = 12, [3] = 18 }, scales = SCALES,
}

H.RankProfile{
  key = "hamstring",
  overrides = {
    [2] = { ["use.effects.1.coef"] = 0.2, ["use.effects.2.value"] = 15, ["use.effects.3.value"] = 9 },
    [3] = { ["use.effects.1.coef"] = 0.25, ["use.effects.2.value"] = 15, ["use.effects.3.value"] = 10 },
  },
  resourceCosts = { [2] = 9, [3] = 12 }, scales = SCALES,
}

H.RankProfile{
  key = "demoralizing_shout",
  overrides = { [2] = { ["use.effects.1.value"] = 20, ["use.effects.2.value"] = 10 }, [3] = { ["use.effects.1.value"] = 24, ["use.effects.2.value"] = 10 } },
  resourceCosts = { [2] = 12, [3] = 14 }, scales = SCALES,
}

H.RankProfile{
  key = "pummel",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.25, ["use.effects.3.value"] = 20 }, [3] = { ["use.effects.1.coef"] = 0.35, ["use.effects.3.value"] = 20 } },
  resourceCosts = { [2] = 17, [3] = 23 }, scales = SCALES,
}

H.RankProfile{
  key = "thunder_clap",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.4, ["use.effects.2.value"] = 20 }, [3] = { ["use.effects.1.coef"] = 0.5, ["use.effects.2.value"] = 20 } },
  resourceCosts = { [2] = 14, [3] = 20 }, scales = SCALES,
}

H.RankProfile{ key = "defensive_stance", overrides = { [2] = { ["stats.dmgPct"] = -10, ["stats.dr"] = 15 }, [3] = { ["stats.dmgPct"] = -10, ["stats.dr"] = 20 } }, scales = SCALES }

H.RankProfile{
  key = "warrior_anticipation",
  overrides = {
    [2] = { ["stats.blockChance"] = 6, ["stats.dodge"] = 4, ["triggers.1.effects.1.amount"] = 0.9 },
    [3] = { ["stats.blockChance"] = 7, ["stats.dodge"] = 5, ["triggers.1.effects.1.amount"] = 1 },
  },
  scales = SCALES,
}

H.RankProfile{
  key = "berserker_stance",
  overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.3, ["triggers.1.effects.1.value"] = 3 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.35, ["triggers.1.effects.1.value"] = 3 } },
  scales = SCALES,
}

H.RankProfile{ key = "battle_stance", overrides = { [2] = { ["triggers.1.effects.2.amount"] = 0.75 }, [3] = { ["triggers.1.effects.2.amount"] = 1 } }, scales = SCALES }

H.RankProfile{
  key = "intercept",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.45, ["use.effects.1.weaponPct"] = 1.3 }, [3] = { ["use.effects.1.coef"] = 0.6, ["use.effects.1.weaponPct"] = 1.65 } },
  resourceCosts = { [2] = 18, [3] = 22 }, scales = SCALES,
}

H.RankProfile{
  key = "intimidating_shout", overrides = { [2] = { ["use.effects.1.duration"] = 1.25 }, [3] = { ["use.effects.1.duration"] = 1.5 } },
  resourceCosts = { [2] = 20, [3] = 20 }, scales = SCALES,
}

H.RankProfile{ key = "deflection", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 0.5 }, [3] = { ["triggers.1.effects.1.amount"] = 0.75 } }, scales = SCALES }

H.RankProfile{ key = "improved_cleave", overrides = { [2] = { ["triggers.1.effects.1.weaponPct"] = 1 }, [3] = { ["triggers.1.effects.1.weaponPct"] = 1.25 } }, scales = SCALES }

H.RankProfile{ key = "improved_bloodrage", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 6 }, [3] = { ["triggers.1.effects.1.amount"] = 8 } }, scales = SCALES }

H.RankProfile{ key = "toughness", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.15 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.2 } }, scales = SCALES }

H.RankProfile{ key = "improved_shield_bash", overrides = { [2] = { ["triggers.1.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 35 } }, scales = SCALES }
