local ADDON, ns = ...
local H = ns.H


H.RankProfile{ key = "smite", overrides = { [2] = { ["use.effects.1.coef"] = 0.65 }, [3] = { ["use.effects.1.coef"] = 0.8 } }, resourceCosts = { [2] = 16, [3] = 17 } }

H.RankProfile{ key = "power_word_shield", overrides = { [2] = { ["use.effects.1.coef"] = 0.95 }, [3] = { ["use.effects.1.coef"] = 1.15 } }, resourceCosts = { [2] = 21, [3] = 27 } }

H.RankProfile{ key = "power_word_fortitude", overrides = { [2] = { ["stats.hpPct"] = 7.5 }, [3] = { ["stats.hpPct"] = 10 } } }

H.RankProfile{ key = "inner_focus", overrides = { [2] = { ["use.cd"] = 18 }, [3] = { ["use.cd"] = 16 } } }

H.RankProfile{ key = "meditation", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.125 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.15 } } }

H.RankProfile{ key = "mental_agility", overrides = { [2] = { ["triggers.1.everyAmount"] = 30 }, [3] = { ["triggers.1.everyAmount"] = 20 } } }

H.RankProfile{ key = "divine_spirit", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 6 }, [3] = { ["triggers.1.effects.1.amount"] = 7 } } }

H.RankProfile{
  key = "power_infusion",
  overrides = { [2] = { ["use.effects.1.value"] = 40, ["use.effects.2.value"] = 40 }, [3] = { ["use.effects.1.value"] = 50, ["use.effects.2.value"] = 50 } },
  resourceCosts = { [2] = 25, [3] = 30 },
}

H.RankProfile{ key = "improved_power_word_shield", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.2 }, [3] = { ["triggers.1.effects.1.coef"] = 0.25 } } }

H.RankProfile{ key = "improved_inner_fire", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.1 }, [3] = { ["triggers.1.effects.1.coef"] = 0.125 } } }

H.RankProfile{ key = "force_of_will", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 0.75 }, [3] = { ["triggers.1.effects.1.amount"] = 1 } } }

H.RankProfile{ key = "lesser_heal", overrides = { [2] = { ["use.effects.1.coef"] = 1 }, [3] = { ["use.effects.1.coef"] = 1.25 } }, resourceCosts = { [2] = 16, [3] = 21 } }

H.RankProfile{ key = "renew", overrides = { [2] = { ["use.effects.1.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.15 } }, resourceCosts = { [2] = 20, [3] = 26 } }

H.RankProfile{ key = "heal_priest", overrides = { [2] = { ["use.effects.1.coef"] = 1.3 }, [3] = { ["use.effects.1.coef"] = 1.6 } }, resourceCosts = { [2] = 26, [3] = 34 } }

H.RankProfile{ key = "flash_heal", overrides = { [2] = { ["use.effects.1.coef"] = 0.95 }, [3] = { ["use.effects.1.coef"] = 1.2 } }, resourceCosts = { [2] = 26, [3] = 34 } }

H.RankProfile{ key = "greater_heal", overrides = { [2] = { ["use.effects.1.coef"] = 2.2 }, [3] = { ["use.effects.1.coef"] = 2.75 } }, resourceCosts = { [2] = 36, [3] = 46 } }

H.RankProfile{
  key = "holy_fire",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.75, ["use.effects.2.coef"] = 0.0625 }, [3] = { ["use.effects.1.coef"] = 0.95, ["use.effects.2.coef"] = 0.075 } },
  resourceCosts = { [2] = 24, [3] = 31 },
}

H.RankProfile{
  key = "holy_nova",
  overrides = { [2] = { ["use.effects.1.coef"] = 0.65, ["use.effects.2.coef"] = 0.8 }, [3] = { ["use.effects.1.coef"] = 0.8, ["use.effects.2.coef"] = 1 } },
  resourceCosts = { [2] = 31, [3] = 40 },
}

H.RankProfile{
  key = "prayer_of_healing",
  overrides = { [2] = { ["use.effects.1.coef"] = 3.75, ["use.effects.2.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 4.75, ["use.effects.2.coef"] = 0.15 } },
  resourceCosts = { [2] = 36, [3] = 46 },
}

H.RankProfile{ key = "spiritual_healing", overrides = { [2] = { ["triggers.1.effects.1.value"] = 25 }, [3] = { ["triggers.1.effects.1.value"] = 30 } } }

H.RankProfile{ key = "inspiration", overrides = { [2] = { ["triggers.1.effects.1.gearCoef"] = 0.3 }, [3] = { ["triggers.1.effects.1.gearCoef"] = 0.4 } } }

H.RankProfile{ key = "divine_fury", overrides = { [2] = { ["adjacency.1.mods.cdPct"] = 15 }, [3] = { ["adjacency.1.mods.cdPct"] = 20 } } }

H.RankProfile{ key = "lightwell", overrides = { [2] = { ["use.effects.1.coef"] = 1.25 }, [3] = { ["use.effects.1.coef"] = 1.5 } }, resourceCosts = { [2] = 30, [3] = 38 } }

H.RankProfile{ key = "shadow_word_pain", overrides = { [2] = { ["use.effects.1.coef"] = 0.125 }, [3] = { ["use.effects.1.coef"] = 0.15 } }, resourceCosts = { [2] = 18, [3] = 24 } }

H.RankProfile{ key = "mind_blast", overrides = { [2] = { ["use.effects.1.coef"] = 0.85 }, [3] = { ["use.effects.1.coef"] = 1.05 } }, resourceCosts = { [2] = 24, [3] = 31 } }

H.RankProfile{ key = "mind_flay", overrides = { [2] = { ["use.effects.1.coef"] = 0.225 }, [3] = { ["use.effects.1.coef"] = 0.275 } }, resourceCosts = { [2] = 21, [3] = 27 } }

H.RankProfile{
  key = "vampiric_embrace",
  overrides = {
    [2] = { ["triggers.1.effects.1.fromEvent"] = 0.125, ["triggers.2.effects.1.fromEvent"] = 0.125 },
    [3] = { ["triggers.1.effects.1.fromEvent"] = 0.15, ["triggers.2.effects.1.fromEvent"] = 0.15 },
  },
}

H.RankProfile{
  key = "shadow_weaving",
  overrides = { [2] = { ["triggers.1.effects.1.value"] = 4, ["triggers.2.effects.1.value"] = 4 }, [3] = { ["triggers.1.effects.1.value"] = 5, ["triggers.2.effects.1.value"] = 5 } },
}

H.RankProfile{ key = "spirit_tap", overrides = { [2] = { ["triggers.1.effects.1.amount"] = 6 }, [3] = { ["triggers.1.effects.1.amount"] = 7 } } }

H.RankProfile{ key = "silence", overrides = { [2] = { ["use.cd"] = 12 }, [3] = { ["use.cd"] = 10 } }, resourceCosts = { [2] = 15, [3] = 15 } }

H.RankProfile{ key = "psychic_scream", overrides = { [2] = { ["use.cd"] = 15 }, [3] = { ["use.cd"] = 12 } }, resourceCosts = { [2] = 18, [3] = 18 } }

H.RankProfile{
  key = "dispel_magic",
  overrides = { [2] = { ["use.effects.1.count"] = 2, ["use.effects.2.count"] = 2 }, [3] = { ["use.effects.1.count"] = 3, ["use.effects.2.count"] = 3 } },
  resourceCosts = { [2] = 14, [3] = 16 },
}

H.RankProfile{ key = "abolish_disease", overrides = { [2] = { ["use.effects.2.duration"] = 10 }, [3] = { ["use.effects.2.duration"] = 12 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "shackle_undead", overrides = { [2] = { ["use.effects.2.coef"] = 0.2 }, [3] = { ["use.effects.2.coef"] = 0.25 } }, resourceCosts = { [2] = 13, [3] = 11 } }

H.RankProfile{ key = "desperate_prayer", overrides = { [2] = { ["use.effects.1.coef"] = 1.4 }, [3] = { ["use.effects.1.coef"] = 1.75 } } }

H.RankProfile{ key = "wand_specialization_priest", overrides = { [2] = { ["adjacency.1.mods.dmgPct"] = 25 }, [3] = { ["adjacency.1.mods.dmgPct"] = 35 } } }

H.RankProfile{ key = "martyrdom", overrides = { [2] = { ["triggers.1.everyAmount"] = 45 }, [3] = { ["triggers.1.everyAmount"] = 40 } } }

H.RankProfile{ key = "devouring_plague", overrides = { [2] = { ["use.effects.1.coef"] = 0.1 }, [3] = { ["use.effects.1.coef"] = 0.125 } }, resourceCosts = { [2] = 28, [3] = 36 } }

H.RankProfile{
  key = "elunes_grace",
  overrides = { [2] = { ["use.effects.1.duration"] = 8, ["use.effects.2.duration"] = 8 }, [3] = { ["use.effects.1.duration"] = 10, ["use.effects.2.duration"] = 10 } },
  resourceCosts = { [2] = 12, [3] = 12 },
}

H.RankProfile{
  key = "mana_burn",
  overrides = { [2] = { ["use.effects.1.amount"] = 25, ["use.effects.1.coef"] = 0.25 }, [3] = { ["use.effects.1.amount"] = 30, ["use.effects.1.coef"] = 0.3 } },
  resourceCosts = { [2] = 18, [3] = 22 },
}

H.RankProfile{
  key = "feedback",
  overrides = { [2] = { ["triggers.1.effects.1.amount"] = 15, ["triggers.1.effects.1.coef"] = 0.15 }, [3] = { ["triggers.1.effects.1.amount"] = 20, ["triggers.1.effects.1.coef"] = 0.2 } },
  resourceCosts = { [2] = 14, [3] = 14 },
}

H.RankProfile{ key = "fear_ward", overrides = { [2] = { ["use.cd"] = 20 }, [3] = { ["use.cd"] = 16 } }, resourceCosts = { [2] = 12, [3] = 12 } }

H.RankProfile{ key = "starshards", overrides = { [2] = { ["use.effects.1.coef"] = 0.7 }, [3] = { ["use.effects.1.coef"] = 0.9 } }, resourceCosts = { [2] = 21, [3] = 27 } }

H.RankProfile{ key = "hex_of_weakness", overrides = { [2] = { ["use.effects.2.value"] = 20 }, [3] = { ["use.effects.2.value"] = 25 } }, resourceCosts = { [2] = 12, [3] = 14 } }

H.RankProfile{ key = "touch_of_weakness", overrides = { [2] = { ["triggers.1.effects.1.coef"] = 0.45 }, [3] = { ["triggers.1.effects.1.coef"] = 0.55 } }, resourceCosts = { [2] = 12, [3] = 15 } }

H.RankProfile{ key = "improved_healing_priest", overrides = { [2] = { ["adjacency.1.mods.costPct"] = -30 }, [3] = { ["adjacency.1.mods.costPct"] = -40 } } }

H.RankProfile{ key = "improved_renew", overrides = { [2] = { ["adjacency.1.mods.healPct"] = 25 }, [3] = { ["adjacency.1.mods.healPct"] = 35 } } }

H.RankProfile{ key = "blessed_recovery", overrides = { [2] = { ["triggers.1.effects.1.fromEvent"] = 0.2 }, [3] = { ["triggers.1.effects.1.fromEvent"] = 0.25 } } }

H.RankProfile{ key = "shadowguard", overrides = { [2] = { ["triggers.1.effects.2.coef"] = 0.45 }, [3] = { ["triggers.1.effects.2.coef"] = 0.55 } }, resourceCosts = { [2] = 15, [3] = 18 } }

H.RankProfile{
  key = "spell_warding",
  overrides = {
    [2] = {
      ["triggers.1.effects.1.value"] = 7.5, ["triggers.1.effects.2.value"] = 7.5, ["triggers.1.effects.3.value"] = 7.5,
      ["triggers.1.effects.4.value"] = 7.5, ["triggers.1.effects.5.value"] = 7.5, ["triggers.1.effects.6.value"] = 7.5,
    },
    [3] = {
      ["triggers.1.effects.1.value"] = 10, ["triggers.1.effects.2.value"] = 10, ["triggers.1.effects.3.value"] = 10,
      ["triggers.1.effects.4.value"] = 10, ["triggers.1.effects.5.value"] = 10, ["triggers.1.effects.6.value"] = 10,
    },
  },
}
