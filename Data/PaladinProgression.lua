local ADDON, ns = ...
local H = ns.H


H.RankProfile{ key = "seal_of_righteousness", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.35 }, [3] = { ["triggers.1.effects.1.coef"] = 0.45 } } }

H.RankProfile{
  key = "judgement",
  overrides = { [2] = { ["use.effects.1.bankScale"] = 1.25, ["use.effects.1.coef"] = 0.8 }, [3] = { ["use.effects.1.bankScale"] = 1.5, ["use.effects.1.coef"] = 1 } },
  resourceCosts = { [2] = 12, [3] = 14 },
}

H.RankProfile{ key = "holy_light", overrides = { [2] = { ["use.effects.1.coef"] = 1.1 }, [3] = { ["use.effects.1.coef"] = 1.35 } }, resourceCosts = { [2] = 23, [3] = 26 } }

H.RankProfile{ key = "flash_of_light", overrides = { [2] = { ["use.effects.1.coef"] = 0.55 }, [3] = { ["use.effects.1.coef"] = 0.7 } }, resourceCosts = { [2] = 10, [3] = 12 } }

H.RankProfile{
  key = "consecration",
  overrides = {
    [2] = { ["use.effects.1.bankScale"] = 0.8, ["use.effects.1.coef"] = 0.4, ["use.effects.2.coef"] = 0.2 },
    [3] = { ["use.effects.1.bankScale"] = 1, ["use.effects.1.coef"] = 0.5, ["use.effects.2.coef"] = 0.25 },
  },
  resourceCosts = { [2] = 24, [3] = 28 },
}

H.RankProfile{
  key = "holy_shock",
  overrides = {
    [2] = { ["use.effects.1.bankScale"] = 1.25, ["use.effects.1.coef"] = 0.8, ["use.effects.2.coef"] = 0.45 },
    [3] = { ["use.effects.1.bankScale"] = 1.5, ["use.effects.1.coef"] = 1, ["use.effects.2.coef"] = 0.55 },
  },
  resourceCosts = { [2] = 21, [3] = 24 },
}

H.RankProfile{ key = "illumination", overrides = { [2] = { ["triggers.1.effects.1.fromPaid"] = 0.75 }, [3] = { ["triggers.1.effects.1.fromPaid"] = 1 } } }

H.RankProfile{ key = "healing_light", overrides = { [2] = { ["triggers.1.effects.1.value"] = 20 }, [3] = { ["triggers.1.effects.1.value"] = 25 } } }

H.RankProfile{ key = "spiritual_focus", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 0.8 }, [3] = { ["triggers.1.effects.1.amount"] = 1 } } }

H.RankProfile{ key = "divine_intellect", overrides = { [2] = { ["gearBonuses.1.coef"] = 0.25 }, [3] = { ["gearBonuses.1.coef"] = 0.3 } } }

H.RankProfile{
  key = "lasting_judgement",
  overrides = { [2] = { ["adjacency.1.mods.durationPct"] = 75, ["triggers.1.effects.1.fromEvent"] = 0.35 }, [3] = { ["adjacency.1.mods.durationPct"] = 100, ["triggers.1.effects.1.fromEvent"] = 0.45 } },
}

H.RankProfile{ key = "improved_blessing_of_wisdom", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.75 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 1 } } }

H.RankProfile{ key = "improved_lay_on_hands", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.35 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.5 } }, trainingCosts = { [2] = 3, [3] = 5 } }

H.RankProfile{
  key = "holy_shield",
  overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.35, ["triggers.1.effects.1.fromEvent"] = 0.75 }, [3] = { ["triggers.1.effects.1.coef"] = 0.45, ["triggers.1.effects.1.fromEvent"] = 1 } },
  resourceCosts = { [2] = 20, [3] = 24 },
}

H.RankProfile{ key = "reckoning", overrides = { [2] = { ["triggers.1.chance"] = 75 }, [3] = { ["triggers.1.chance"] = 100 } } }

H.RankProfile{ key = "blessing_of_sanctuary", overrides = { [2] = { ["triggers.1.effects.2.amount"] = 4 }, [3] = { ["triggers.1.effects.2.amount"] = 5 } } }

H.RankProfile{ key = "paladin_toughness", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.4 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.5 } } }

H.RankProfile{ key = "paladin_shield_specialization", overrides = { [2] = { ["triggers.2.effects.2.value"] = 15 }, [3] = { ["triggers.2.effects.2.value"] = 20 } } }

H.RankProfile{ key = "improved_devotion_aura", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.125 }, [3] = { ["triggers.1.effects.1.coef"] = 0.15 } } }

H.RankProfile{
  key = "blessing_of_kings",
  overrides = {
    [2] = { ["use.effects.1.gearCoef"] = 0.125, ["use.effects.2.gearCoef"] = 0.125, ["use.effects.3.gearCoef"] = 0.125 },
    [3] = { ["use.effects.1.gearCoef"] = 0.15, ["use.effects.2.gearCoef"] = 0.15, ["use.effects.3.gearCoef"] = 0.15 },
  },
  resourceCosts = { [2] = 15, [3] = 18 },
}

H.RankProfile{ key = "precision_paladin", overrides = { [2] = { ["triggers.1.effects.1.value"] = 7.5 }, [3] = { ["triggers.1.effects.1.value"] = 10 } } }

H.RankProfile{ key = "guardians_favor", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.3 }, [3] = { ["triggers.1.effects.1.coef"] = 0.4 } } }

H.RankProfile{
  key = "one_handed_weapon_specialization_paladin",
  overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 35 }, [3] = { ["adjacency.1.mods.dmgPct"] = 45 } }, trainingCosts = { [2] = 3, [3] = 5 },
}

H.RankProfile{ key = "seal_of_command", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.85 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 1 } } }

H.RankProfile{ key = "seal_of_the_crusader", overrides = { [2] = { ["stats.haste"] = 15 }, [3] = { ["stats.haste"] = 20 } } }

H.RankProfile{ key = "vengeance_paladin", overrides = { [2] = { ["triggers.1.effects.1.value"] = 6.25 }, [3] = { ["triggers.1.effects.1.value"] = 7.5 } } }

H.RankProfile{ key = "benediction", overrides = { [2] = { ["triggers.1.effects.1.value"] = -25 }, [3] = { ["triggers.1.effects.1.value"] = -35 } } }

H.RankProfile{ key = "conviction", overrides = { [2] = { ["triggers.1.effects.1.value"] = 15 }, [3] = { ["triggers.1.effects.1.value"] = 20 } } }

H.RankProfile{ key = "sanctity_aura", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 20 }, [3] = { ["adjacency.1.mods.dmgPct"] = 25 } } }

H.RankProfile{ key = "two_handed_weapon_specialization_paladin", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 20 }, [3] = { ["adjacency.1.mods.dmgPct"] = 25 } } }

H.RankProfile{ key = "pursuit_of_justice", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "deflection_paladin", overrides = { [2] = { ["stats.dodge"] = 7.5 }, [3] = { ["stats.dodge"] = 10 } }, trainingCosts = { [2] = 3, [3] = 5 } }

H.RankProfile{ key = "seal_of_light", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25 } } }

H.RankProfile{ key = "seal_of_wisdom", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 5 }, [3] = { ["triggers.1.effects.1.amount"] = 6 } } }

H.RankProfile{ key = "hammer_of_wrath", overrides = { [2] = { ["use.effects.1.coef"] = 1.25 }, [3] = { ["use.effects.1.coef"] = 1.5 } }, resourceCosts = { [2] = 17, [3] = 20 } }

H.RankProfile{ key = "blessing_of_might", overrides = { [2] = { ["use.effects.1.gearCoef"] = 0.25 }, [3] = { ["use.effects.1.gearCoef"] = 0.3 } }, resourceCosts = { [2] = 10, [3] = 12 } }

H.RankProfile{ key = "blessing_of_wisdom", overrides = { [2] = { ["use.effects.1.amount"] = 15 }, [3] = { ["use.effects.1.amount"] = 18 } }, resourceCosts = { [2] = 0, [3] = 0 } }

H.RankProfile{ key = "devotion_aura", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.25 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.3 } } }

H.RankProfile{ key = "retribution_aura", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25 } } }

H.RankProfile{ key = "cleanse_paladin", overrides = { [2] = { ["use.effects.1.count"] = 3 }, [3] = { ["use.effects.1.count"] = 4 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "seal_of_justice", overrides = { [2] = { ["triggers.1.effects.1.duration"] = 0.75 }, [3] = { ["triggers.1.effects.1.duration"] = 1 } }, trainingCosts = { [2] = 1, [3] = 2 } }

H.RankProfile{ key = "judgement_of_light", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "judgement_of_wisdom", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 4 }, [3] = { ["triggers.1.effects.1.amount"] = 5 } }, resourceCosts = { [2] = 6, [3] = 6 } }

H.RankProfile{
  key = "blessing_of_light",
  overrides = { [2] = { ["use.effects.1.gearCoef"] = 0.35, ["use.effects.2.gearCoef"] = 0.3 }, [3] = { ["use.effects.1.gearCoef"] = 0.45, ["use.effects.2.gearCoef"] = 0.4 } },
  resourceCosts = { [2] = 12, [3] = 15 },
}

H.RankProfile{
  key = "blessing_of_protection",
  overrides = { [2] = { ["use.effects.1.duration"] = 3.5, ["use.effects.2.duration"] = 3.5 }, [3] = { ["use.effects.1.duration"] = 4, ["use.effects.2.duration"] = 4 } },
  resourceCosts = { [2] = 12, [3] = 12 },
}

H.RankProfile{ key = "unyielding_faith", overrides = { [2] = { ["triggers.1.effects.1.controlChance"] = 25 }, [3] = { ["triggers.1.effects.1.controlChance"] = 35 } } }

H.RankProfile{ key = "shadow_resistance_aura", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "frost_resistance_aura", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "fire_resistance_aura", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "judgement_of_the_crusader", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 40 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{ key = "judgement_of_command", overrides = { [2] = { ["use.effects.1.coef"] = 1.25 }, [3] = { ["use.effects.1.coef"] = 1.5 } }, resourceCosts = { [2] = 14, [3] = 17 } }

H.RankProfile{ key = "concentration_aura", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 0.4 }, [3] = { ["triggers.1.effects.1.amount"] = 0.5 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{
  key = "divine_protection",
  overrides = { [2] = { ["use.effects.1.duration"] = 3.5, ["use.effects.2.duration"] = 3.5 }, [3] = { ["use.effects.1.duration"] = 4, ["use.effects.2.duration"] = 4 } },
  resourceCosts = { [2] = 12, [3] = 12 },
}
