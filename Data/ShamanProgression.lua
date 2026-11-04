local ADDON, ns = ...
local H = ns.H


H.RankProfile{
  key = "lightning_bolt",
  overrides = { [2] = { ["use.effects.1.bankScale"] = 1.25, ["use.effects.1.coef"] = 1 }, [3] = { ["use.effects.1.bankScale"] = 1.5, ["use.effects.1.coef"] = 1.25 } },
  resourceCosts = { [2] = 12, [3] = 14 },
}

H.RankProfile{ key = "earth_shock", overrides = { [2] = { ["use.effects.1.coef"] = 0.75 }, [3] = { ["use.effects.1.coef"] = 0.95 } }, resourceCosts = { [2] = 16, [3] = 21 } }

H.RankProfile{
  key = "flame_shock",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.25, ["use.effects.2.coef"] = 0.2 }, [3] = { ["use.effects.1.coef"] = 0.3, ["use.effects.2.coef"] = 0.25 } },
  resourceCosts = { [2] = 15, [3] = 19 },
}

H.RankProfile{ key = "frost_shock", overrides = { [2] = { ["use.effects.1.coef"] = 0.65 }, [3] = { ["use.effects.1.coef"] = 0.8 } }, resourceCosts = { [2] = 15, [3] = 19 } }

H.RankProfile{
  key = "chain_lightning",
  overrides = {
    [2] = { ["use.effects.1.bankScale"] = 1.75, ["use.effects.1.coef"] = 1.1, ["use.effects.2.coef"] = 0.4 },
    [3] = { ["use.effects.1.bankScale"] = 2, ["use.effects.1.coef"] = 1.4, ["use.effects.2.coef"] = 0.5 },
  },
  resourceCosts = { [2] = 28, [3] = 32 },
}

H.RankProfile{ key = "convection", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -20 }, [3] = { ["adjacency.1.mods.costPct"] = -25 } } }

H.RankProfile{ key = "concussion", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 20 }, [3] = { ["adjacency.1.mods.dmgPct"] = 25 } } }

H.RankProfile{ key = "elemental_devastation", overrides = { [2] = { ["triggers.1.effects.1.value"] = 20 }, [3] = { ["triggers.1.effects.1.value"] = 25 } } }

H.RankProfile{
  key = "flametongue_weapon",
  overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2, ["triggers.1.effects.1.fromEvent"] = 0.35 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25, ["triggers.1.effects.1.fromEvent"] = 0.45 } },
}

H.RankProfile{
  key = "frostbrand_weapon",
  overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.3, ["triggers.1.effects.2.value"] = 25 }, [3] = { ["triggers.1.effects.1.coef"] = 0.4, ["triggers.1.effects.2.value"] = 30 } },
  trainingCosts = { [2] = 2, [3] = 3 },
}

H.RankProfile{
  key = "stormstrike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.85, ["use.effects.1.weaponPct"] = 1.75 }, [3] = { ["use.effects.1.coef"] = 1, ["use.effects.1.weaponPct"] = 2 } },
  resourceCosts = { [2] = 22, [3] = 28 },
}

H.RankProfile{
  key = "lightning_shield",
  overrides = {
    [2] = { ["triggers.1.effects.1.coef"] = 0.4, ["triggers.2.effects.1.stacksFromEvent"] = 1 },
    [3] = { ["triggers.1.effects.1.coef"] = 0.5, ["triggers.2.effects.1.stacksFromEvent"] = 1.25 },
  },
  resourceCosts = { [2] = 14, [3] = 16 },
}

H.RankProfile{ key = "shaman_flurry", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "thundering_strikes", overrides = { [2] = { ["adjacency.1.mods.crit"] = 12.5 }, [3] = { ["adjacency.1.mods.crit"] = 15 } } }

H.RankProfile{
  key = "elemental_weapons",
  overrides = {
    [2] = { ["triggers.1.effects.1.value"] = 35, ["triggers.1.effects.2.value"] = 25, ["triggers.1.effects.3.value"] = 25, ["triggers.1.effects.4.value"] = 35 },
    [3] = { ["triggers.1.effects.1.value"] = 50, ["triggers.1.effects.2.value"] = 30, ["triggers.1.effects.3.value"] = 30, ["triggers.1.effects.4.value"] = 50 },
  },
  trainingCosts = { [2] = 3, [3] = 5 },
}

H.RankProfile{ key = "improved_lightning_shield", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.2 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.25 } } }

H.RankProfile{ key = "shaman_toughness", overrides = { [2] = { ["gearBonuses.1.coef"] = 0.25 }, [3] = { ["gearBonuses.1.coef"] = 0.3 } } }

H.RankProfile{ key = "healing_wave", overrides = { [2] = { ["use.effects.1.coef"] = 0.9 }, [3] = { ["use.effects.1.coef"] = 1.1 } }, resourceCosts = { [2] = 25, [3] = 26 } }

H.RankProfile{ key = "lesser_healing_wave", overrides = { [2] = { ["use.effects.1.coef"] = 0.75 }, [3] = { ["use.effects.1.coef"] = 0.95 } }, resourceCosts = { [2] = 17, [3] = 18 } }

H.RankProfile{
  key = "chain_heal",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.8, ["use.effects.2.coef"] = 0.35 }, [3] = { ["use.effects.1.coef"] = 1.1, ["use.effects.2.coef"] = 0.5 } },
  resourceCosts = { [2] = 33, [3] = 34 },
}

H.RankProfile{ key = "ancestral_healing", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.25 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.35 } }, trainingCosts = { [2] = 2, [3] = 3 } }

H.RankProfile{ key = "healing_way", overrides = { [2] = { ["triggers.1.effects.1.value"] = 12.5 }, [3] = { ["triggers.1.effects.1.value"] = 15 } } }

H.RankProfile{ key = "tidal_focus", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -20 }, [3] = { ["adjacency.1.mods.costPct"] = -25 } } }

H.RankProfile{ key = "tidal_mastery", overrides = { [2] = { ["adjacency.1.mods.crit"] = 12.5 }, [3] = { ["adjacency.1.mods.crit"] = 15 } } }

H.RankProfile{ key = "restorative_totems", overrides = { [2] = { ["adjacency.1.mods.healPct"] = 20 }, [3] = { ["adjacency.1.mods.healPct"] = 25 } } }

H.RankProfile{ key = "searing_totem", overrides = { [2] = { ["use.effects.1.coef"] = 0.3 }, [3] = { ["use.effects.1.coef"] = 0.4 } }, resourceCosts = { [2] = 4, [3] = 5 } }

H.RankProfile{ key = "magma_totem", overrides = { [2] = { ["use.effects.1.coef"] = 0.25 }, [3] = { ["use.effects.1.coef"] = 0.3 } }, resourceCosts = { [2] = 20, [3] = 25 } }

H.RankProfile{ key = "fire_nova_totem", overrides = { [2] = { ["use.effects.1.coef"] = 1.75 }, [3] = { ["use.effects.1.coef"] = 2.25 } }, resourceCosts = { [2] = 25, [3] = 31 } }

H.RankProfile{ key = "stoneclaw_totem", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.05 } }, resourceCosts = { [2] = 15, [3] = 19 } }

H.RankProfile{ key = "healing_stream_totem", overrides = { [2] = { ["use.effects.1.coef"] = 0.25 }, [3] = { ["use.effects.1.coef"] = 0.3 } }, resourceCosts = { [2] = 13, [3] = 16 } }

H.RankProfile{ key = "mana_spring_totem", overrides = { [2] = { ["use.effects.1.amount"] = 7 }, [3] = { ["use.effects.1.amount"] = 8 } }, resourceCosts = { [2] = 0, [3] = 0 } }

H.RankProfile{
  key = "mana_tide_totem",
  overrides = { [2] = { ["use.effects.1.periodic.effects.1.pctMax"] = 0.2 }, [3] = { ["use.effects.1.periodic.effects.1.pctMax"] = 0.25 } },
  resourceCosts = { [2] = 0, [3] = 0 },
}

H.RankProfile{ key = "flametongue_totem", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.45 }, [3] = { ["triggers.1.effects.1.coef"] = 0.6 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{ key = "totemic_focus", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -20 }, [3] = { ["adjacency.1.mods.costPct"] = -25 } } }

H.RankProfile{ key = "improved_fire_totems", overrides = { [2] = { ["triggers.1.effects.1.value"] = -2 }, [3] = { ["triggers.1.effects.1.value"] = -3 } }, trainingCosts = { [2] = 1, [3] = 1 } }

H.RankProfile{ key = "fire_resistance_totem", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 35 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{ key = "nature_resistance_totem", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 35 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{ key = "earths_grasp", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.35 }, [3] = { ["triggers.1.effects.1.coef"] = 0.45 } } }

H.RankProfile{ key = "shaman_shield_specialization", overrides = { [2] = { ["adjacency.1.stats.blockChance"] = 15 }, [3] = { ["adjacency.1.stats.blockChance"] = 20 } } }

H.RankProfile{ key = "strength_of_earth_totem_active", overrides = { [2] = { ["use.effects.1.gearCoef"] = 0.2 }, [3] = { ["use.effects.1.gearCoef"] = 0.25 } }, resourceCosts = { [2] = 10, [3] = 12 } }

H.RankProfile{ key = "stoneskin_totem_active", overrides = { [2] = { ["use.effects.1.value"] = 25 }, [3] = { ["use.effects.1.value"] = 30 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{ key = "grace_of_air_totem_active", overrides = { [2] = { ["use.effects.1.gearCoef"] = 0.4 }, [3] = { ["use.effects.1.gearCoef"] = 0.55 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "windwall_totem", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 35 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{ key = "frost_resistance_totem", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 35 } }, resourceCosts = { [2] = 8, [3] = 8 } }
