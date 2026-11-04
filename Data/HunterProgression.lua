local ADDON, ns = ...
local H = ns.H


H.RankProfile{
  key = "aimed_shot",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.85, ["use.effects.1.weaponPct"] = 1.5 }, [3] = { ["use.effects.1.coef"] = 1.1, ["use.effects.1.weaponPct"] = 1.75 } },
  resourceCosts = { [2] = 25, [3] = 31 },
}

H.RankProfile{
  key = "multi_shot",
  overrides = {
    [2] = {
      ["use.effects.1.coef"] = 0.3, ["use.effects.1.weaponPct"] = 0.75, ["use.effects.2.coef"] = 0.3, ["use.effects.2.weaponPct"] = 0.75,
      ["use.effects.3.coef"] = 0.3, ["use.effects.3.weaponPct"] = 0.75,
    },
    [3] = {
      ["use.effects.1.coef"] = 0.4, ["use.effects.1.weaponPct"] = 0.85, ["use.effects.2.coef"] = 0.4, ["use.effects.2.weaponPct"] = 0.85,
      ["use.effects.3.coef"] = 0.4, ["use.effects.3.weaponPct"] = 0.85,
    },
  },
  resourceCosts = { [2] = 20, [3] = 25 },
}

H.RankProfile{ key = "arcane_shot", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.1 } }, resourceCosts = { [2] = 13, [3] = 17 } }

H.RankProfile{ key = "serpent_sting", overrides = { [2] = { ["use.effects.1.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.175 } }, resourceCosts = { [2] = 15, [3] = 19 } }

H.RankProfile{ key = "concussive_shot", overrides = { [2] = { ["use.cd"] = 8 }, [3] = { ["use.cd"] = 6 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "scatter_shot", overrides = { [2] = { ["use.effects.2.duration"] = 2.5 }, [3] = { ["use.effects.2.duration"] = 3 } }, resourceCosts = { [2] = 15, [3] = 15 } }

H.RankProfile{ key = "rapid_fire", overrides = { [2] = { ["use.effects.1.duration"] = 10 }, [3] = { ["use.effects.1.duration"] = 12 } }, resourceCosts = { [2] = 20, [3] = 20 } }

H.RankProfile{ key = "hunters_mark", overrides = { [2] = { ["triggers.1.effects.1.value"] = 15 }, [3] = { ["triggers.1.effects.1.value"] = 20 } } }

H.RankProfile{ key = "volley", overrides = { [2] = { ["use.effects.1.coef"] = 1 }, [3] = { ["use.effects.1.coef"] = 1.5 } }, resourceCosts = { [2] = 37, [3] = 46 } }

H.RankProfile{ key = "aspect_of_the_hawk", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.3 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.4 } } }

H.RankProfile{ key = "aspect_of_the_monkey", overrides = { [2] = { ["stats.dodge"] = 10 }, [3] = { ["stats.dodge"] = 12 } } }

H.RankProfile{ key = "aspect_of_the_beast", overrides = { [2] = { ["stats.meleePct"] = 15, ["stats.petPct"] = 25 }, [3] = { ["stats.meleePct"] = 20, ["stats.petPct"] = 35 } } }

H.RankProfile{
  key = "bestial_wrath",
  overrides = { [2] = { ["use.effects.1.duration"] = 10, ["use.effects.2.duration"] = 10 }, [3] = { ["use.effects.1.duration"] = 12, ["use.effects.2.duration"] = 12 } },
  resourceCosts = { [2] = 32, [3] = 32 },
}

H.RankProfile{ key = "intimidation", overrides = { [2] = { ["use.effects.2.value"] = 50 }, [3] = { ["use.effects.2.value"] = 65 } }, resourceCosts = { [2] = 18, [3] = 18 } }

H.RankProfile{ key = "frenzy", overrides = { [2] = { ["triggers.1.effects.1.value"] = 12.5 }, [3] = { ["triggers.1.effects.1.value"] = 15 } } }

H.RankProfile{ key = "pet_wolf", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } } }

H.RankProfile{ key = "pet_cat", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } } }

H.RankProfile{ key = "pet_bear", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } } }

H.RankProfile{ key = "pet_boar", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } } }

H.RankProfile{ key = "pet_raptor", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } } }

H.RankProfile{ key = "pet_scorpid", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } } }

H.RankProfile{ key = "pet_wind_serpent", overrides = { [2] = { ["use.effects.1.coef"] = 0.75 }, [3] = { ["use.effects.1.coef"] = 1 } } }

H.RankProfile{ key = "bite", overrides = { [2] = { ["use.effects.1.coef"] = 0.75 }, [3] = { ["use.effects.1.coef"] = 1 } }, resourceCosts = { [2] = 25, [3] = 25 } }

H.RankProfile{ key = "claw_pet", overrides = { [2] = { ["use.effects.1.coef"] = 0.6 }, [3] = { ["use.effects.1.coef"] = 0.8 } }, resourceCosts = { [2] = 28, [3] = 30 } }

H.RankProfile{ key = "screech", overrides = { [2] = { ["use.effects.1.value"] = 18 }, [3] = { ["use.effects.1.value"] = 25 } }, resourceCosts = { [2] = 20, [3] = 20 } }

H.RankProfile{
  key = "raptor_strike",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.55, ["use.effects.1.weaponPct"] = 1.5 }, [3] = { ["use.effects.1.coef"] = 0.7, ["use.effects.1.weaponPct"] = 1.75 } },
  resourceCosts = { [2] = 19, [3] = 24 },
}

H.RankProfile{ key = "mongoose_bite", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.8 }, [3] = { ["triggers.1.effects.1.coef"] = 1 } } }

H.RankProfile{ key = "wing_clip", overrides = { [2] = { ["use.effects.2.value"] = 20 }, [3] = { ["use.effects.2.value"] = 25 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "counterattack", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.85 }, [3] = { ["triggers.1.effects.1.coef"] = 1.1 } } }



H.RankProfile{ key = "immolation_trap", ids = { [2] = 33434, [3] = 43434 }, overrides = { [2] = { ["use.effects.1.coef"] = 0.175 }, [3] = { ["use.effects.1.coef"] = 0.25 } } }

H.RankProfile{
  key = "explosive_trap", ids = { [2] = 33435, [3] = 43435 },
  overrides = { [2] = { ["use.effects.1.coef"] = 0.6, ["use.effects.2.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.8, ["use.effects.2.coef"] = 0.15 } },
}

H.RankProfile{ key = "wyvern_sting", overrides = { [2] = { ["use.effects.2.coef"] = 0.2 }, [3] = { ["use.effects.2.coef"] = 0.3 } }, resourceCosts = { [2] = 32, [3] = 32 } }

H.RankProfile{ key = "mortal_shots", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.4 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.55 } } }

H.RankProfile{ key = "feed_pet", ids = { [2] = 33462, [3] = 43462 }, overrides = { [2] = { ["use.effects.1.amount"] = 25 }, [3] = { ["use.effects.1.amount"] = 30 } } }

H.RankProfile{ key = "surefooted", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 12 }, [3] = { ["triggers.1.effects.1.amount"] = 15 } } }

H.RankProfile{ key = "clever_traps", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 25 }, [3] = { ["adjacency.1.mods.dmgPct"] = 35 } } }

H.RankProfile{ key = "efficiency", overrides = { [2] = { ["triggers.1.everyAmount"] = 25 }, [3] = { ["triggers.1.everyAmount"] = 20 } } }

H.RankProfile{ key = "killer_instinct", overrides = { [2] = { ["triggers.1.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 40 } } }

H.RankProfile{ key = "ferocity", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 10 }, [3] = { ["triggers.1.effects.1.amount"] = 12 } } }

H.RankProfile{ key = "improved_arcane_shot", overrides = { [2] = { ["triggers.1.effects.1.value"] = 60 }, [3] = { ["triggers.1.effects.1.value"] = 85 } } }

H.RankProfile{ key = "trueshot_aura", overrides = { [2] = { ["gearBonuses.1.coef"] = 0.35 }, [3] = { ["gearBonuses.1.coef"] = 0.45 } } }

H.RankProfile{ key = "frost_trap", overrides = { [2] = { ["use.effects.1.duration"] = 10 }, [3] = { ["use.effects.1.duration"] = 12 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{
  key = "mend_pet",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.5, ["use.effects.2.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.65, ["use.effects.2.coef"] = 0.15 } },
  resourceCosts = { [2] = 19, [3] = 24 },
}

H.RankProfile{ key = "quiver", overrides = { [2] = { ["adjacency.1.mods.haste"] = 15 }, [3] = { ["adjacency.1.mods.haste"] = 20 } } }

H.RankProfile{ key = "scorpid_sting", overrides = { [2] = { ["use.effects.1.value"] = 25 }, [3] = { ["use.effects.1.value"] = 40 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{ key = "aspect_of_the_wild", overrides = { [2] = { ["triggers.1.effects.1.value"] = 20 }, [3] = { ["triggers.1.effects.1.value"] = 25 } } }

H.RankProfile{ key = "improved_aspect_of_the_hawk", overrides = { [2] = { ["triggers.1.effects.1.value"] = 30 }, [3] = { ["triggers.1.effects.1.value"] = 40 } } }

H.RankProfile{ key = "improved_mend_pet", overrides = { [2] = { ["triggers.1.chance"] = 35 }, [3] = { ["triggers.1.chance"] = 50 } } }

H.RankProfile{ key = "pet_turtle", overrides = { [2] = { ["use.effects.1.coef"] = 0.45 }, [3] = { ["use.effects.1.coef"] = 0.6 } } }

H.RankProfile{ key = "shell_shield", overrides = { [2] = { ["use.effects.1.value"] = 60 }, [3] = { ["use.effects.1.value"] = 70 } }, resourceCosts = { [2] = 10, [3] = 10 } }

H.RankProfile{
  key = "prowl_pet", overrides = { [2] = { ["use.effects.1.value"] = 150 }, [3] = { ["use.effects.1.value"] = 200 } },
  resourceCosts = { [2] = 25, [3] = 25 }, trainingCosts = { [2] = 2, [3] = 3 },
}

H.RankProfile{
  key = "furious_howl",
  overrides = { [2] = { ["use.effects.1.value"] = 150, ["use.effects.2.value"] = 150 }, [3] = { ["use.effects.1.value"] = 200, ["use.effects.2.value"] = 200 } },
  resourceCosts = { [2] = 20, [3] = 20 },
}

H.RankProfile{
  key = "viper_sting",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.25, ["use.effects.1.tick"] = 3 }, [3] = { ["use.effects.1.coef"] = 0.35, ["use.effects.1.tick"] = 4 } },
  resourceCosts = { [2] = 12, [3] = 15 },
}
