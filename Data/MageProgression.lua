local ADDON, ns = ...
local H = ns.H


H.RankProfile{
  key = "arcane_missiles",
  overrides = { [2] = { ["triggers.1.effects.1.value"] = 60, ["use.effects.1.coef"] = 0.45 }, [3] = { ["triggers.1.effects.1.value"] = 80, ["use.effects.1.coef"] = 0.55 } },
  resourceCosts = { [2] = 22, [3] = 26 },
}

H.RankProfile{
  key = "arcane_explosion",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.8, ["use.effects.1.max"] = 5, ["use.effects.1.min"] = 3 }, [3] = { ["use.effects.1.coef"] = 1, ["use.effects.1.max"] = 6, ["use.effects.1.min"] = 4 } },
  resourceCosts = { [2] = 30, [3] = 36 },
}

H.RankProfile{ key = "arcane_intellect", overrides = { [2] = { ["stats.mana"] = 35, ["triggers.1.effects.1.value"] = 30 }, [3] = { ["stats.mana"] = 50, ["triggers.1.effects.1.value"] = 40 } } }

H.RankProfile{ key = "arcane_meditation", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 9 }, [3] = { ["triggers.1.effects.1.amount"] = 12 } } }

H.RankProfile{ key = "arcane_mind", overrides = { [2] = { ["gearBonuses.1.coef"] = 0.35 }, [3] = { ["gearBonuses.1.coef"] = 0.5 } } }

H.RankProfile{ key = "counterspell", overrides = { [2] = { ["use.cd"] = 12 }, [3] = { ["use.cd"] = 10 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "evocation", overrides = { [2] = { ["use.effects.1.periodic.effects.1.amount"] = 25 }, [3] = { ["use.effects.1.periodic.effects.1.amount"] = 30 } } }

H.RankProfile{ key = "magic_absorption", overrides = { [2] = { ["triggers.1.effects.1.pctMax"] = 0.03 }, [3] = { ["triggers.1.effects.1.pctMax"] = 0.04 } } }

H.RankProfile{ key = "arcane_resilience", overrides = { [2] = { ["gearBonuses.1.coef"] = 0.3 }, [3] = { ["gearBonuses.1.coef"] = 0.4 } } }

H.RankProfile{ key = "presence_of_mind", overrides = { [2] = { ["use.cd"] = 18 }, [3] = { ["use.cd"] = 14 } }, resourceCosts = { [2] = 18, [3] = 18 } }

H.RankProfile{ key = "arcane_power", overrides = { [2] = { ["use.effects.1.value"] = 65 }, [3] = { ["use.effects.1.value"] = 80 } }, resourceCosts = { [2] = 35, [3] = 35 } }

H.RankProfile{ key = "improved_arcane_missiles", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 35 }, [3] = { ["adjacency.1.mods.dmgPct"] = 50 } } }

H.RankProfile{
  key = "fireball",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.8, ["use.effects.2.coef"] = 0.05 }, [3] = { ["use.effects.1.coef"] = 1, ["use.effects.2.coef"] = 0.0625 } },
  resourceCosts = { [2] = 18, [3] = 20 },
}

H.RankProfile{ key = "fire_blast", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.05 } }, resourceCosts = { [2] = 22, [3] = 26 } }

H.RankProfile{ key = "scorch", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.75 } }, resourceCosts = { [2] = 13, [3] = 14 } }

H.RankProfile{ key = "ignite", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.35 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.4 } } }

H.RankProfile{
  key = "pyroblast",
  overrides = { [2] = { ["use.effects.1.coef"] = 3.75, ["use.effects.2.coef"] = 0.15 }, [3] = { ["use.effects.1.coef"] = 4.5, ["use.effects.2.coef"] = 0.175 } },
  resourceCosts = { [2] = 29, [3] = 35 },
}

H.RankProfile{
  key = "flamestrike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.7, ["use.effects.2.coef"] = 0.15 }, [3] = { ["use.effects.1.coef"] = 0.9, ["use.effects.2.coef"] = 0.2 } },
  resourceCosts = { [2] = 29, [3] = 35 },
}

H.RankProfile{ key = "blast_wave", overrides = { [2] = { ["use.effects.1.coef"] = 1 }, [3] = { ["use.effects.1.coef"] = 1.25 } }, resourceCosts = { [2] = 24, [3] = 29 } }

H.RankProfile{
  key = "fire_power",
  overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 25, ["triggers.1.effects.1.amount"] = 2 }, [3] = { ["adjacency.1.mods.dmgPct"] = 30, ["triggers.1.effects.1.amount"] = 2.5 } },
}

H.RankProfile{ key = "combustion", overrides = { [2] = { ["use.effects.1.charges"] = 4 }, [3] = { ["use.effects.1.charges"] = 5 } }, resourceCosts = { [2] = 25, [3] = 25 } }

H.RankProfile{ key = "incinerate", overrides = { [2] = { ["adjacency.1.mods.crit"] = 15 }, [3] = { ["adjacency.1.mods.crit"] = 20 } } }

H.RankProfile{ key = "burning_soul", overrides = { [2] = { ["triggers.1.effects.1.value"] = 45 }, [3] = { ["triggers.1.effects.1.value"] = 60 } } }

H.RankProfile{ key = "frostbolt", overrides = { [2] = { ["use.effects.1.coef"] = 0.8 }, [3] = { ["use.effects.1.coef"] = 1 } }, resourceCosts = { [2] = 17, [3] = 19 } }

H.RankProfile{ key = "frost_nova", overrides = { [2] = { ["use.cd"] = 10.5 }, [3] = { ["use.cd"] = 9 } }, resourceCosts = { [2] = 18, [3] = 18 } }

H.RankProfile{ key = "cone_of_cold", overrides = { [2] = { ["use.effects.1.coef"] = 0.95 }, [3] = { ["use.effects.1.coef"] = 1.2 } }, resourceCosts = { [2] = 23, [3] = 25 } }

H.RankProfile{
  key = "blizzard",
  overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2, ["use.effects.1.coef"] = 0.4 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25, ["use.effects.1.coef"] = 0.5 } },
  resourceCosts = { [2] = 29, [3] = 35 },
}

H.RankProfile{ key = "frost_channeling", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -25 }, [3] = { ["adjacency.1.mods.costPct"] = -35 } } }

H.RankProfile{ key = "ice_barrier", overrides = { [2] = { ["use.effects.1.coef"] = 0.95 }, [3] = { ["use.effects.1.coef"] = 1.2 } }, resourceCosts = { [2] = 22, [3] = 26 } }

H.RankProfile{ key = "ice_block", overrides = { [2] = { ["use.cd"] = 21 }, [3] = { ["use.cd"] = 18 } }, resourceCosts = { [2] = 18, [3] = 18 } }

H.RankProfile{ key = "cold_snap", resourceCosts = { [2] = 25, [3] = 25 } }

H.RankProfile{ key = "improved_frostbolt", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 1.5 }, [3] = { ["triggers.1.effects.1.amount"] = 2 } } }

H.RankProfile{ key = "frost_warding", overrides = { [2] = { ["triggers.1.effects.1.value"] = 35 }, [3] = { ["triggers.1.effects.1.value"] = 50 } }, trainingCosts = { [2] = 3, [3] = 5 } }

H.RankProfile{ key = "mana_shield", overrides = { [2] = { ["use.effects.1.coef"] = 0.7 }, [3] = { ["use.effects.1.coef"] = 0.9 } }, resourceCosts = { [2] = 17, [3] = 21 } }

H.RankProfile{ key = "blink", overrides = { [2] = { ["use.effects.1.duration"] = 3 }, [3] = { ["use.effects.1.duration"] = 4 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "frost_armor", overrides = { [2] = { ["stats.armor"] = 18 }, [3] = { ["stats.armor"] = 24 } } }

H.RankProfile{ key = "ice_armor", overrides = { [2] = { ["stats.armor"] = 30 }, [3] = { ["stats.armor"] = 40 } } }

H.RankProfile{ key = "mage_armor", overrides = { [2] = { ["stats.regen"] = 2.5 }, [3] = { ["stats.regen"] = 3 } } }

H.RankProfile{ key = "remove_lesser_curse", overrides = { [2] = { ["use.effects.1.count"] = 2 }, [3] = { ["use.effects.1.count"] = 3 } }, resourceCosts = { [2] = 6, [3] = 6 } }

H.RankProfile{ key = "mana_agate", overrides = { [2] = { ["use.effects.1.amount"] = 55 }, [3] = { ["use.effects.1.amount"] = 80 } } }

H.RankProfile{
  key = "dampen_magic",
  overrides = { [2] = { ["use.effects.1.duration"] = 8, ["use.effects.2.duration"] = 8 }, [3] = { ["use.effects.1.duration"] = 10, ["use.effects.2.duration"] = 10 } },
  resourceCosts = { [2] = 10, [3] = 10 },
}

H.RankProfile{
  key = "fire_ward",
  overrides = { [2] = { ["use.effects.1.coef"] = 1, ["use.effects.2.coef"] = 0.35 }, [3] = { ["use.effects.1.coef"] = 1.25, ["use.effects.2.coef"] = 0.5 } },
  resourceCosts = { [2] = 12, [3] = 12 },
}

H.RankProfile{ key = "frost_ward", overrides = { [2] = { ["use.effects.1.coef"] = 1.15 }, [3] = { ["use.effects.1.coef"] = 1.4 } }, resourceCosts = { [2] = 15, [3] = 18 } }

H.RankProfile{ key = "improved_mana_shield", overrides = { [2] = { ["triggers.1.effects.1.fromPaid"] = 0.4 }, [3] = { ["triggers.1.effects.1.fromPaid"] = 0.5 } } }

H.RankProfile{ key = "improved_fire_blast", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 1.5 }, [3] = { ["triggers.1.effects.1.amount"] = 2 } } }

H.RankProfile{ key = "improved_frost_nova", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 2 }, [3] = { ["triggers.1.effects.1.amount"] = 2.5 } } }

H.RankProfile{
  key = "improved_blizzard",
  overrides = { [2] = { ["triggers.1.effects.1.value"] = 30, ["triggers.2.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 40, ["triggers.2.effects.1.value"] = 40 } },
}

H.RankProfile{ key = "improved_arcane_explosion", overrides = { [2] = { ["triggers.1.effects.1.value"] = 20 }, [3] = { ["triggers.1.effects.1.value"] = 25 } } }

H.RankProfile{ key = "improved_flamestrike", overrides = { [2] = { ["triggers.1.effects.1.value"] = 40 }, [3] = { ["triggers.1.effects.1.value"] = 50 } } }

H.RankProfile{ key = "improved_cone_of_cold", overrides = { [2] = { ["triggers.1.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 40 } } }

H.RankProfile{ key = "improved_fire_ward", overrides = { [2] = { ["wardReflection.chance"] = 40 }, [3] = { ["wardReflection.chance"] = 60 } } }

H.RankProfile{ key = "polymorph", overrides = { [2] = { ["use.cd"] = 20 }, [3] = { ["use.cd"] = 16 } }, resourceCosts = { [2] = 8, [3] = 8 } }

H.RankProfile{
  key = "amplify_magic",
  overrides = { [2] = { ["use.effects.1.value"] = 30, ["use.effects.2.value"] = -30 }, [3] = { ["use.effects.1.value"] = 40, ["use.effects.2.value"] = -40 } },
  resourceCosts = { [2] = 12, [3] = 12 },
}
