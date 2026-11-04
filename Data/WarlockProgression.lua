local ADDON, ns = ...
local H = ns.H


H.RankProfile{ key = "corruption", overrides = { [2] = { ["use.effects.1.coef"] = 0.05 }, [3] = { ["use.effects.1.coef"] = 0.0625 } }, resourceCosts = { [2] = 15, [3] = 19 } }

H.RankProfile{ key = "curse_of_agony", overrides = { [2] = { ["use.effects.1.coef"] = 0.035 }, [3] = { ["use.effects.1.coef"] = 0.05 } }, resourceCosts = { [2] = 17, [3] = 22 } }

H.RankProfile{ key = "drain_life", overrides = { [2] = { ["use.effects.1.coef"] = 0.175 }, [3] = { ["use.effects.1.coef"] = 0.225 } }, resourceCosts = { [2] = 24, [3] = 31 } }

H.RankProfile{ key = "siphon_life", overrides = { [2] = { ["use.effects.1.coef"] = 0.035 }, [3] = { ["use.effects.1.coef"] = 0.05 } }, resourceCosts = { [2] = 21, [3] = 27 } }

H.RankProfile{ key = "drain_soul", overrides = { [2] = { ["use.effects.1.coef"] = 0.275 }, [3] = { ["use.effects.1.coef"] = 0.35 } }, resourceCosts = { [2] = 20, [3] = 26 } }

H.RankProfile{ key = "drain_mana", overrides = { [2] = { ["use.effects.1.coef"] = 0.075 }, [3] = { ["use.effects.1.coef"] = 0.1 } }, resourceCosts = { [2] = 6, [3] = 6 } }

H.RankProfile{ key = "improved_corruption", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 1.25 }, [3] = { ["triggers.1.effects.1.amount"] = 1.5 } } }

H.RankProfile{ key = "amplify_curse", overrides = { [2] = { ["use.effects.1.value"] = 80 }, [3] = { ["use.effects.1.value"] = 100 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "shadow_mastery", overrides = { [2] = { ["triggers.1.effects.1.value"] = 40 }, [3] = { ["triggers.1.effects.1.value"] = 60 } } }

H.RankProfile{ key = "dark_pact", overrides = { [2] = { ["use.effects.2.amount"] = 120 }, [3] = { ["use.effects.2.amount"] = 150 } } }

H.RankProfile{ key = "curse_of_exhaustion", overrides = { [2] = { ["use.effects.1.value"] = 30 }, [3] = { ["use.effects.1.value"] = 35 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "improved_life_tap", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.5 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.75 } } }

H.RankProfile{ key = "summon_imp", overrides = { [2] = { ["use.effects.1.coef"] = 0.5 }, [3] = { ["use.effects.1.coef"] = 0.65 } } }

H.RankProfile{ key = "summon_voidwalker", overrides = { [2] = { ["use.effects.1.coef"] = 0.5 }, [3] = { ["use.effects.1.coef"] = 0.65 } } }

H.RankProfile{ key = "summon_succubus", overrides = { [2] = { ["use.effects.1.coef"] = 0.5 }, [3] = { ["use.effects.1.coef"] = 0.65 } } }

H.RankProfile{ key = "summon_felhunter", overrides = { [2] = { ["use.effects.1.coef"] = 0.5 }, [3] = { ["use.effects.1.coef"] = 0.65 } } }

H.RankProfile{ key = "health_funnel", overrides = { [2] = { ["use.effects.1.value"] = 40 }, [3] = { ["use.effects.1.value"] = 50 } } }

H.RankProfile{ key = "improved_imp", overrides = { [2] = { ["triggers.2.effects.1.amount"] = 0.75 }, [3] = { ["triggers.2.effects.1.amount"] = 1 } } }

H.RankProfile{ key = "demonic_embrace", overrides = { [2] = { ["stats.hpPct"] = 15 }, [3] = { ["stats.hpPct"] = 20 } } }

H.RankProfile{ key = "fel_stamina", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.45 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.55 } } }

H.RankProfile{ key = "unholy_power", overrides = { [2] = { ["triggers.1.everyAmount"] = 25 }, [3] = { ["triggers.1.everyAmount"] = 20 } } }

H.RankProfile{ key = "master_demonologist", overrides = { [2] = { ["triggers.1.effects.1.value"] = 40 }, [3] = { ["triggers.1.effects.1.value"] = 60 } } }

H.RankProfile{
  key = "soul_link",
  overrides = { [2] = { ["use.effects.1.value"] = 25, ["use.effects.2.value"] = 25 }, [3] = { ["use.effects.1.value"] = 30, ["use.effects.2.value"] = 30 } },
  resourceCosts = { [2] = 24, [3] = 28 },
}

H.RankProfile{
  key = "demonic_sacrifice",
  overrides = {
    [2] = { ["use.effects.1.value"] = 45, ["use.effects.2.value"] = 35, ["use.effects.3.coef"] = 0.075, ["use.effects.4.gearCoef"] = 0.0075 },
    [3] = { ["use.effects.1.value"] = 60, ["use.effects.2.value"] = 50, ["use.effects.3.coef"] = 0.1, ["use.effects.4.gearCoef"] = 0.01 },
  },
  trainingCosts = { [2] = 3, [3] = 5 },
}

H.RankProfile{ key = "improved_voidwalker", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.4 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.5 } }, trainingCosts = { [2] = 3, [3] = 5 } }

H.RankProfile{ key = "master_summoner", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 1.5 }, [3] = { ["triggers.1.effects.1.amount"] = 2 } } }

H.RankProfile{ key = "fel_domination", overrides = { [2] = { ["use.cd"] = 20 }, [3] = { ["use.cd"] = 16 } }, resourceCosts = { [2] = 18, [3] = 18 } }

H.RankProfile{ key = "shadow_bolt", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.05 } }, resourceCosts = { [2] = 17, [3] = 22 } }

H.RankProfile{
  key = "immolate",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.3, ["use.effects.2.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.4, ["use.effects.2.coef"] = 0.15 } },
  resourceCosts = { [2] = 21, [3] = 27 },
}

H.RankProfile{ key = "searing_pain", overrides = { [2] = { ["use.effects.1.coef"] = 0.7 }, [3] = { ["use.effects.1.coef"] = 0.9 } }, resourceCosts = { [2] = 16, [3] = 20 } }

H.RankProfile{ key = "shadowburn", overrides = { [2] = { ["use.effects.1.coef"] = 1.1 }, [3] = { ["use.effects.1.coef"] = 1.35 } }, resourceCosts = { [2] = 23, [3] = 29 } }

H.RankProfile{ key = "conflagrate", overrides = { [2] = { ["use.effects.1.coef"] = 0.95 }, [3] = { ["use.effects.1.coef"] = 1.2 } }, resourceCosts = { [2] = 23, [3] = 29 } }

H.RankProfile{ key = "rain_of_fire", overrides = { [2] = { ["use.effects.1.coef"] = 0.5 }, [3] = { ["use.effects.1.coef"] = 0.75 } }, resourceCosts = { [2] = 31, [3] = 38 } }

H.RankProfile{ key = "hellfire", overrides = { [2] = { ["use.effects.1.coef"] = 0.65 }, [3] = { ["use.effects.1.coef"] = 1 } }, resourceCosts = { [2] = 19, [3] = 24 } }

H.RankProfile{ key = "bane", overrides = { [2] = { ["adjacency.1.mods.cdPct"] = 20 }, [3] = { ["adjacency.1.mods.cdPct"] = 25 } } }

H.RankProfile{ key = "devastation", overrides = { [2] = { ["triggers.1.effects.1.value"] = 7.5 }, [3] = { ["triggers.1.effects.1.value"] = 10 } } }

H.RankProfile{ key = "ruin", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.4 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.5 } } }

H.RankProfile{ key = "emberstorm", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 40 }, [3] = { ["adjacency.1.mods.dmgPct"] = 65 } } }

H.RankProfile{
  key = "soul_fire",
  overrides = { [2] = { ["use.effects.1.bankScale"] = 2.5, ["use.effects.1.coef"] = 1.9 }, [3] = { ["use.effects.1.bankScale"] = 3, ["use.effects.1.coef"] = 2.4 } },
  resourceCosts = { [2] = 40, [3] = 49 }, trainingCosts = { [2] = 4, [3] = 7 },
}

H.RankProfile{ key = "intensity", overrides = { [2] = { ["triggers.1.effects.2.value"] = 20 }, [3] = { ["triggers.1.effects.2.value"] = 25 } } }

H.RankProfile{ key = "life_tap", overrides = { [2] = { ["use.effects.1.amount"] = 50 }, [3] = { ["use.effects.1.amount"] = 65 } } }

H.RankProfile{ key = "demon_skin", overrides = { [2] = { ["stats.armor"] = 15 }, [3] = { ["stats.armor"] = 20 } } }

H.RankProfile{ key = "demon_armor", overrides = { [2] = { ["stats.armor"] = 30 }, [3] = { ["stats.armor"] = 40 } } }

H.RankProfile{ key = "fear", overrides = { [2] = { ["use.cd"] = 13 }, [3] = { ["use.cd"] = 10 } }, resourceCosts = { [2] = 14, [3] = 14 } }

H.RankProfile{ key = "death_coil", overrides = { [2] = { ["use.effects.1.coef"] = 0.8 }, [3] = { ["use.effects.1.coef"] = 1 } }, resourceCosts = { [2] = 25, [3] = 31 } }

H.RankProfile{ key = "healthstone", overrides = { [2] = { ["use.effects.1.pctMax"] = 0.225 }, [3] = { ["use.effects.1.pctMax"] = 0.275 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "curse_of_tongues", overrides = { [2] = { ["use.effects.1.value"] = 40 }, [3] = { ["use.effects.1.value"] = 50 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "curse_of_the_elements", overrides = { [2] = { ["use.effects.1.duration"] = 14 }, [3] = { ["use.effects.1.duration"] = 16 } }, resourceCosts = { [2] = 12, [3] = 15 } }

H.RankProfile{
  key = "curse_of_shadow",
  overrides = { [2] = { ["use.effects.1.value"] = 12.5, ["use.effects.2.value"] = 12.5 }, [3] = { ["use.effects.1.value"] = 15, ["use.effects.2.value"] = 15 } },
  resourceCosts = { [2] = 12, [3] = 15 },
}

H.RankProfile{ key = "curse_of_recklessness", overrides = { [2] = { ["use.effects.1.value"] = 20 }, [3] = { ["use.effects.1.value"] = 25 } }, resourceCosts = { [2] = 12, [3] = 15 } }

H.RankProfile{ key = "sacrifice_voidwalker", overrides = { [2] = { ["use.effects.2.coef"] = 4 }, [3] = { ["use.effects.2.coef"] = 5 } } }

H.RankProfile{ key = "devour_magic", overrides = { [2] = { ["triggers.1.effects.2.healCoef"] = 0.55 }, [3] = { ["triggers.1.effects.2.healCoef"] = 0.7 } } }

H.RankProfile{ key = "lash_of_pain", overrides = { [2] = { ["triggers.1.effects.2.coef"] = 1 }, [3] = { ["triggers.1.effects.2.coef"] = 1.25 } } }

H.RankProfile{ key = "soulstone", overrides = { [2] = { ["revive.health"] = 0.35, ["revive.mana"] = 0.25 }, [3] = { ["revive.health"] = 0.45, ["revive.mana"] = 0.3 } } }
