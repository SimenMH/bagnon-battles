local ADDON, ns = ...
local H = ns.H


H.RankProfile{
  key = "sinister_strike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.6, ["use.effects.1.weaponPct"] = 1.15 }, [3] = { ["use.effects.1.coef"] = 0.75, ["use.effects.1.weaponPct"] = 1.3 } },
  resourceCosts = { [2] = 35, [3] = 35 },
}

H.RankProfile{ key = "eviscerate", overrides = { [2] = { ["use.effects.1.coef"] = 0.65 }, [3] = { ["use.effects.1.coef"] = 0.8 } }, resourceCosts = { [2] = 3, [3] = 3 } }

H.RankProfile{ key = "rupture", overrides = { [2] = { ["use.effects.1.coef"] = 0.1 }, [3] = { ["use.effects.1.coef"] = 0.125 } }, resourceCosts = { [2] = 3, [3] = 3 } }

H.RankProfile{ key = "slice_and_dice", overrides = { [2] = { ["use.effects.1.value"] = 35 }, [3] = { ["use.effects.1.value"] = 40 } }, resourceCosts = { [2] = 2, [3] = 2 } }

H.RankProfile{ key = "kidney_shot", overrides = { [2] = { ["use.cd"] = 13 }, [3] = { ["use.cd"] = 11 } }, resourceCosts = { [2] = 3, [3] = 3 } }

H.RankProfile{ key = "instant_poison", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.25 }, [3] = { ["triggers.1.effects.1.coef"] = 0.3 } } }

H.RankProfile{ key = "deadly_poison", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.0375 }, [3] = { ["triggers.1.effects.1.coef"] = 0.05 } } }

H.RankProfile{ key = "wound_poison", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25 } } }

H.RankProfile{ key = "relentless_strikes", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 5 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 6 } } }

H.RankProfile{ key = "improved_poisons", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 8 }, [3] = { ["triggers.1.effects.1.amount"] = 12 } } }

H.RankProfile{ key = "vile_poisons", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 40 }, [3] = { ["adjacency.1.mods.dmgPct"] = 55 } } }

H.RankProfile{
  key = "backstab",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.7, ["use.effects.1.weaponPct"] = 1.95 }, [3] = { ["use.effects.1.coef"] = 0.85, ["use.effects.1.weaponPct"] = 2.2 } },
  resourceCosts = { [2] = 50, [3] = 50 },
}

H.RankProfile{ key = "gouge", overrides = { [2] = { ["use.cd"] = 10 }, [3] = { ["use.cd"] = 8 } }, resourceCosts = { [2] = 20, [3] = 20 } }

H.RankProfile{
  key = "riposte",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.6, ["use.effects.1.weaponPct"] = 1.75 }, [3] = { ["use.effects.1.coef"] = 0.75, ["use.effects.1.weaponPct"] = 2 } },
  resourceCosts = { [2] = 10, [3] = 10 },
}

H.RankProfile{
  key = "blade_flurry",
  overrides = { [2] = { ["use.effects.1.duration"] = 9, ["use.effects.2.duration"] = 9 }, [3] = { ["use.effects.1.duration"] = 11, ["use.effects.2.duration"] = 11 } },
  resourceCosts = { [2] = 20, [3] = 20 },
}

H.RankProfile{
  key = "adrenaline_rush",
  overrides = { [2] = { ["use.effects.1.duration"] = 10, ["use.effects.2.duration"] = 10 }, [3] = { ["use.effects.1.duration"] = 12, ["use.effects.2.duration"] = 12 } },
  trainingCosts = { [2] = 3, [3] = 5 },
}

H.RankProfile{ key = "dagger_specialization", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 0.75 }, [3] = { ["triggers.1.effects.1.amount"] = 1 } } }

H.RankProfile{ key = "precision", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 15 }, [3] = { ["adjacency.1.mods.dmgPct"] = 20 } } }

H.RankProfile{
  key = "ambush",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.9, ["use.effects.1.weaponPct"] = 2.25 }, [3] = { ["use.effects.1.coef"] = 1.1, ["use.effects.1.weaponPct"] = 2.5 } },
  resourceCosts = { [2] = 55, [3] = 55 },
}

H.RankProfile{ key = "garrote", overrides = { [2] = { ["use.effects.1.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.15 } }, resourceCosts = { [2] = 40, [3] = 40 } }

H.RankProfile{ key = "cheap_shot", resourceCosts = { [2] = 25, [3] = 20 } }

H.RankProfile{
  key = "hemorrhage",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.45, ["use.effects.1.weaponPct"] = 1.15 }, [3] = { ["use.effects.1.coef"] = 0.55, ["use.effects.1.weaponPct"] = 1.3 } },
  resourceCosts = { [2] = 30, [3] = 30 },
}

H.RankProfile{
  key = "ghostly_strike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.55, ["use.effects.1.weaponPct"] = 1.45 }, [3] = { ["use.effects.1.coef"] = 0.7, ["use.effects.1.weaponPct"] = 1.65 } },
  resourceCosts = { [2] = 30, [3] = 30 },
}

H.RankProfile{ key = "vanish", overrides = { [2] = { ["use.cd"] = 15 }, [3] = { ["use.cd"] = 12 } }, resourceCosts = { [2] = 15, [3] = 15 } }

H.RankProfile{ key = "initiative", overrides = { [2] = { ["triggers.1.effects.2.amount"] = 10 }, [3] = { ["triggers.1.effects.2.amount"] = 12 } } }

H.RankProfile{ key = "serrated_blades", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.225 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.3 } } }

H.RankProfile{ key = "setup", overrides = { [2] = { ["triggers.1.effects.2.amount"] = 7 }, [3] = { ["triggers.1.effects.2.amount"] = 9 } } }

H.RankProfile{ key = "dirty_deeds", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -35 }, [3] = { ["adjacency.1.mods.costPct"] = -50 } } }

H.RankProfile{ key = "sprint", overrides = { [2] = { ["use.effects.1.value"] = 25 }, [3] = { ["use.effects.1.value"] = 30 } }, resourceCosts = { [2] = 15, [3] = 15 } }

H.RankProfile{ key = "kick", overrides = { [2] = { ["use.cd"] = 10 }, [3] = { ["use.cd"] = 8 } }, resourceCosts = { [2] = 15, [3] = 15 } }

H.RankProfile{ key = "blind", overrides = { [2] = { ["use.cd"] = 17 }, [3] = { ["use.cd"] = 14 } }, resourceCosts = { [2] = 20, [3] = 20 } }

H.RankProfile{ key = "expose_armor", overrides = { [2] = { ["use.effects.1.valuePerPoint"] = 17.5 }, [3] = { ["use.effects.1.valuePerPoint"] = 22.5 } }, resourceCosts = { [2] = 2, [3] = 2 } }

H.RankProfile{
  key = "endurance_rogue",
  overrides = { [2] = { ["triggers.1.effects.1.amount"] = 2, ["triggers.1.effects.2.amount"] = 2 }, [3] = { ["triggers.1.effects.1.amount"] = 3, ["triggers.1.effects.2.amount"] = 3 } },
}

H.RankProfile{ key = "mace_specialization_rogue", overrides = { [2] = { ["triggers.1.chance"] = 20 }, [3] = { ["triggers.1.chance"] = 25 } } }

H.RankProfile{ key = "camouflage", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 15 }, [3] = { ["triggers.1.effects.1.amount"] = 18 } } }

H.RankProfile{
  key = "opportunity",
  overrides = { [2] = { ["triggers.1.effects.1.amount"] = 1.5, ["triggers.1.effects.2.amount"] = 1.5 }, [3] = { ["triggers.1.effects.1.amount"] = 2.25, ["triggers.1.effects.2.amount"] = 2.25 } },
}

H.RankProfile{ key = "feint", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 40 } }, resourceCosts = { [2] = 20, [3] = 20 } }

H.RankProfile{ key = "improved_sap", overrides = { [2] = { ["triggers.1.chance"] = 75 }, [3] = { ["triggers.1.chance"] = 100 } } }

H.RankProfile{ key = "improved_sinister_strike", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -15 }, [3] = { ["adjacency.1.mods.costPct"] = -20 } } }

H.RankProfile{ key = "improved_backstab", overrides = { [2] = { ["adjacency.1.mods.crit"] = 20 }, [3] = { ["adjacency.1.mods.crit"] = 25 } } }

H.RankProfile{
  key = "improved_ambush",
  overrides = { [2] = { ["triggers.1.effects.1.value"] = 30, ["triggers.2.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 40, ["triggers.2.effects.1.value"] = 40 } },
}

H.RankProfile{ key = "improved_eviscerate", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 20 }, [3] = { ["adjacency.1.mods.dmgPct"] = 25 } } }

H.RankProfile{ key = "improved_slice_and_dice", overrides = { [2] = { ["triggers.1.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 45 } } }

H.RankProfile{ key = "improved_kidney_shot", overrides = { [2] = { ["triggers.1.effects.1.value"] = 35 }, [3] = { ["triggers.1.effects.1.value"] = 50 } } }

H.RankProfile{ key = "improved_backstab_classic", overrides = { [2] = { ["triggers.1.effects.1.value"] = 20 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "improved_sprint", overrides = { [2] = { ["triggers.1.effects.1.count"] = 2 }, [3] = { ["triggers.1.effects.1.count"] = 3 } } }
