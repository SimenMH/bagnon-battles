local ADDON, ns = ...
local H = ns.H


H.RankProfile{ key = "wrath", overrides = { [2] = { ["use.effects.1.coef"] = 0.75 }, [3] = { ["use.effects.1.coef"] = 0.95 } }, resourceCosts = { [2] = 10, [3] = 13 } }

H.RankProfile{ key = "starfire", overrides = { [2] = { ["use.effects.1.coef"] = 2.2 }, [3] = { ["use.effects.1.coef"] = 2.75 } }, resourceCosts = { [2] = 34, [3] = 42 } }

H.RankProfile{
  key = "moonfire",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.25, ["use.effects.2.coef"] = 0.1 }, [3] = { ["use.effects.1.coef"] = 0.3, ["use.effects.2.coef"] = 0.125 } },
  resourceCosts = { [2] = 15, [3] = 19 },
}

H.RankProfile{ key = "insect_swarm", overrides = { [2] = { ["use.effects.1.coef"] = 0.15 }, [3] = { ["use.effects.1.coef"] = 0.2 } }, resourceCosts = { [2] = 13, [3] = 17 } }

H.RankProfile{ key = "hurricane", overrides = { [2] = { ["use.effects.1.coef"] = 1 }, [3] = { ["use.effects.1.coef"] = 1.25 } }, resourceCosts = { [2] = 34, [3] = 42 } }

H.RankProfile{ key = "natures_grace", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 0.75 }, [3] = { ["triggers.1.effects.1.amount"] = 1 } } }

H.RankProfile{ key = "moonkin_form", overrides = { [2] = { ["triggers.2.effects.1.value"] = 7.5 }, [3] = { ["triggers.2.effects.1.value"] = 10 } } }

H.RankProfile{ key = "faerie_fire", overrides = { [2] = { ["use.effects.1.value"] = 45 }, [3] = { ["use.effects.1.value"] = 55 } }, resourceCosts = { [2] = 5, [3] = 5 } }

H.RankProfile{ key = "entangling_roots", overrides = { [2] = { ["use.cd"] = 10 }, [3] = { ["use.cd"] = 8 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "omen_of_clarity", overrides = { [2] = { ["triggers.1.chance"] = 20 }, [3] = { ["triggers.1.chance"] = 25 } } }

H.RankProfile{ key = "innervate", overrides = { [2] = { ["use.effects.1.duration"] = 7 }, [3] = { ["use.effects.1.duration"] = 8 } } }

H.RankProfile{ key = "cat_form", overrides = { [2] = { ["use.effects.1.coef"] = 0.25 }, [3] = { ["use.effects.1.coef"] = 0.3 } } }

H.RankProfile{ key = "claw", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.1 } }, resourceCosts = { [2] = 40, [3] = 40 } }

H.RankProfile{
  key = "rake",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.2, ["use.effects.2.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.25, ["use.effects.2.coef"] = 0.15 } },
  resourceCosts = { [2] = 35, [3] = 35 },
}

H.RankProfile{ key = "shred", overrides = { [2] = { ["use.effects.1.coef"] = 1.35 }, [3] = { ["use.effects.1.coef"] = 1.75 } }, resourceCosts = { [2] = 60, [3] = 60 } }

H.RankProfile{ key = "rip", overrides = { [2] = { ["use.effects.1.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.15 } }, resourceCosts = { [2] = 30, [3] = 30 } }

H.RankProfile{ key = "ferocious_bite", overrides = { [2] = { ["use.effects.1.coef"] = 1.1 }, [3] = { ["use.effects.1.coef"] = 1.4 } }, resourceCosts = { [2] = 35, [3] = 35 } }

H.RankProfile{ key = "tigers_fury", overrides = { [2] = { ["use.effects.1.gearCoef"] = 0.35 }, [3] = { ["use.effects.1.gearCoef"] = 0.45 } }, resourceCosts = { [2] = 25, [3] = 25 } }

H.RankProfile{ key = "bear_form", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.4 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.5 } } }

H.RankProfile{ key = "maul", overrides = { [2] = { ["use.effects.1.coef"] = 1.3 }, [3] = { ["use.effects.1.coef"] = 1.65 } }, resourceCosts = { [2] = 18, [3] = 22 } }

H.RankProfile{ key = "swipe", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.1 } }, resourceCosts = { [2] = 24, [3] = 29 } }

H.RankProfile{
  key = "frenzied_regeneration",
  overrides = { [2] = { ["use.effects.1.perPointPctMax"] = 0.003 }, [3] = { ["use.effects.1.perPointPctMax"] = 0.0035 } },
  resourceCosts = { [2] = 20, [3] = 20 },
}

H.RankProfile{ key = "demoralizing_roar", overrides = { [2] = { ["use.effects.1.value"] = 20 }, [3] = { ["use.effects.1.value"] = 24 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "rejuvenation", overrides = { [2] = { ["use.effects.1.coef"] = 0.15 }, [3] = { ["use.effects.1.coef"] = 0.2 } }, resourceCosts = { [2] = 15, [3] = 19 } }

H.RankProfile{
  key = "regrowth",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.65, ["use.effects.2.coef"] = 0.1 }, [3] = { ["use.effects.1.coef"] = 0.85, ["use.effects.2.coef"] = 0.125 } },
  resourceCosts = { [2] = 22, [3] = 27 },
}

H.RankProfile{ key = "healing_touch", overrides = { [2] = { ["use.effects.1.coef"] = 1.15 }, [3] = { ["use.effects.1.coef"] = 1.45 } }, resourceCosts = { [2] = 26, [3] = 32 } }

H.RankProfile{ key = "swiftmend", overrides = { [2] = { ["use.cd"] = 12 }, [3] = { ["use.cd"] = 9 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "tranquility", overrides = { [2] = { ["use.effects.1.coef"] = 1 }, [3] = { ["use.effects.1.coef"] = 1.25 } }, resourceCosts = { [2] = 38, [3] = 46 } }

H.RankProfile{ key = "barkskin", overrides = { [2] = { ["use.cd"] = 17.5 }, [3] = { ["use.cd"] = 15 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "thorns", overrides = { [2] = { ["triggers.2.effects.1.coef"] = 0.25 }, [3] = { ["triggers.2.effects.1.coef"] = 0.5 } } }

H.RankProfile{
  key = "savage_fury",
  overrides = { [2] = { ["triggers.1.effects.1.value"] = 7.5, ["triggers.2.effects.1.value"] = 7.5 }, [3] = { ["triggers.1.effects.1.value"] = 10, ["triggers.2.effects.1.value"] = 10 } },
  trainingCosts = { [2] = 4, [3] = 7 },
}

H.RankProfile{ key = "feral_charge", overrides = { [2] = { ["use.effects.1.coef"] = 0.45 }, [3] = { ["use.effects.1.coef"] = 0.6 } } }

H.RankProfile{ key = "natures_focus", overrides = { [2] = { ["triggers.1.effects.1.duration"] = 4.5 }, [3] = { ["triggers.1.effects.1.duration"] = 6 } } }

H.RankProfile{ key = "pounce", overrides = { [2] = { ["use.effects.2.coef"] = 0.1 }, [3] = { ["use.effects.2.coef"] = 0.125 } } }

H.RankProfile{ key = "ravage", overrides = { [2] = { ["use.effects.1.coef"] = 3.25 }, [3] = { ["use.effects.1.coef"] = 4 } }, resourceCosts = { [2] = 60, [3] = 60 } }

H.RankProfile{ key = "blood_frenzy", overrides = { [2] = { ["triggers.1.chance"] = 75 }, [3] = { ["triggers.1.chance"] = 100 } } }

H.RankProfile{ key = "improved_moonfire", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 30 }, [3] = { ["adjacency.1.mods.dmgPct"] = 40 } } }

H.RankProfile{ key = "moonglow", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -15 }, [3] = { ["adjacency.1.mods.costPct"] = -20 } } }

H.RankProfile{ key = "natural_shapeshifter", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 3 }, [3] = { ["triggers.1.effects.1.amount"] = 4 } } }

H.RankProfile{ key = "reflection", overrides = { [2] = { ["triggers.1.effects.1.value"] = 3 }, [3] = { ["triggers.1.effects.1.value"] = 4 } } }

H.RankProfile{ key = "improved_rejuvenation", overrides = { [2] = { ["adjacency.1.mods.healPct"] = 35 }, [3] = { ["adjacency.1.mods.healPct"] = 45 } } }

H.RankProfile{ key = "improved_regrowth", overrides = { [2] = { ["adjacency.1.mods.crit"] = 30 }, [3] = { ["adjacency.1.mods.crit"] = 40 } } }

H.RankProfile{ key = "improved_healing_touch", overrides = { [2] = { ["adjacency.1.mods.cdPct"] = 25 }, [3] = { ["adjacency.1.mods.cdPct"] = 30 } } }

H.RankProfile{ key = "gift_of_nature", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.035 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.05 } } }

H.RankProfile{ key = "tranquil_spirit", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -30 }, [3] = { ["adjacency.1.mods.costPct"] = -35 } } }

H.RankProfile{
  key = "abolish_poison",
  overrides = { [2] = { ["use.effects.1.count"] = 2, ["use.effects.2.coef"] = 0.4 }, [3] = { ["use.effects.1.count"] = 3, ["use.effects.2.coef"] = 0.55 } },
  resourceCosts = { [2] = 10, [3] = 10 },
}

H.RankProfile{
  key = "mark_of_the_wild",
  overrides = {
    [2] = { ["gearBonuses.1.coef"] = 0.075, ["gearBonuses.2.coef"] = 0.075, ["gearBonuses.3.coef"] = 0.075, ["gearBonuses.4.coef"] = 0.075, ["gearBonuses.5.coef"] = 0.075 },
    [3] = { ["gearBonuses.1.coef"] = 0.1, ["gearBonuses.2.coef"] = 0.1, ["gearBonuses.3.coef"] = 0.1, ["gearBonuses.4.coef"] = 0.1, ["gearBonuses.5.coef"] = 0.1 },
  },
}

H.RankProfile{ key = "thick_hide", overrides = { [2] = { ["triggers.1.effects.1.fraction"] = 0.3 }, [3] = { ["triggers.1.effects.1.fraction"] = 0.35 } } }

H.RankProfile{ key = "bash", overrides = { [2] = { ["use.effects.1.coef"] = 0.8 }, [3] = { ["use.effects.1.coef"] = 1.05 } }, resourceCosts = { [2] = 25, [3] = 25 } }

H.RankProfile{ key = "improved_enrage", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 7.5 }, [3] = { ["triggers.1.effects.1.amount"] = 10 } } }

H.RankProfile{ key = "improved_shred", overrides = { [2] = { ["triggers.1.effects.1.value"] = -15 }, [3] = { ["triggers.1.effects.1.value"] = -20 } } }

H.RankProfile{
  key = "feral_aggression",
  overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.5, ["triggers.2.effects.1.value"] = 12 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.65, ["triggers.2.effects.1.value"] = 16 } },
}

H.RankProfile{ key = "improved_thorns", overrides = { [2] = { ["triggers.1.effects.1.value"] = 75 }, [3] = { ["triggers.1.effects.1.value"] = 100 } } }

H.RankProfile{ key = "druid_ferocity", overrides = { [2] = { ["triggers.1.effects.1.value"] = 20 }, [3] = { ["triggers.1.effects.1.value"] = 40 } } }

H.RankProfile{ key = "remove_curse_druid", overrides = { [2] = {}, [3] = {} }, resourceCosts = { [2] = 0, [3] = 0 } }

H.RankProfile{ key = "cure_poison_druid", overrides = { [2] = {}, [3] = {} }, resourceCosts = { [2] = 0, [3] = 0 } }

H.RankProfile{ key = "natural_weapons_druid", overrides = { [2] = { ["triggers.1.effects.1.value"] = 75 }, [3] = { ["triggers.1.effects.1.value"] = 100 } } }
