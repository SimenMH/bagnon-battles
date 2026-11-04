local ADDON, ns = ...



local function add(class, source, fields)
  local plan = ns.Util.DeepCopy(ns.Bots.ARCHETYPES[class][source])
  for key, value in pairs(fields) do plan[key] = value end
  table.insert(ns.Bots.ARCHETYPES[class], plan)
end

add("PALADIN", 1, { id = "light_judgement", minRound = 2,
  core = "seal_of_righteousness judgement_of_light holy_light", train = "seal_of_righteousness judgement_of_light", supportTrain = "blessing_of_might", payoff = "judgement_of_light",
  support = "blessing_of_might one_handed_weapon_specialization_paladin improved_judgement pursuit_of_justice divine_protection consecration hammer_of_justice" })
add("PALADIN", 4, { id = "wisdom_judgement", minRound = 3,
  core = "seal_of_righteousness judgement_of_wisdom holy_light holy_shock", train = "holy_light judgement_of_wisdom", supportTrain = "blessing_of_light", payoff = "holy_shock",
  support = "blessing_of_light illumination divine_favor spiritual_focus concentration_aura lasting_judgement flash_of_light" })
add("PALADIN", 3, { id = "reckoning_weapons", minRound = 3,
  core = "seal_of_righteousness reckoning holy_shield judgement", train = "reckoning judgement", supportTrain = "devotion_aura", payoff = "reckoning",
  support = "one_handed_weapon_specialization_paladin redoubt devotion_aura blessing_of_sanctuary paladin_shield_specialization holy_light divine_protection" })

add("PRIEST", 1, { id = "mana_burn", minRound = 3,
  core = "mana_burn power_word_shield smite", train = "mana_burn power_word_shield", supportTrain = "feedback", payoff = "mana_burn",
  support = "feedback meditation fear_ward lesser_heal inner_fire wand_specialization_priest mental_agility" })
add("PRIEST", 3, { id = "shadow_channel", minRound = 3,
  core = "shadow_word_pain mind_flay power_word_shield", train = "mind_flay shadow_word_pain", supportTrain = "vampiric_embrace", payoff = "mind_flay",
  support = "vampiric_embrace spirit_tap fear_ward shadow_weaving touch_of_weakness hex_of_weakness shadowguard shadowform" })
add("PRIEST", 2, { id = "holy_triage", minRound = 3,
  core = "holy_fire heal_priest smite", train = "heal_priest holy_fire", supportTrain = "spiritual_healing", payoff = "heal_priest",
  support = "spiritual_healing inspiration power_word_shield searing_light lesser_heal power_word_fortitude greater_heal blessed_recovery power_infusion" })

add("SHAMAN", 1, { id = "fire_totems", minRound = 3,
  core = "flame_shock lightning_bolt searing_totem", train = "searing_totem flame_shock", supportTrain = "improved_fire_totems", payoff = "searing_totem",
  support = "improved_fire_totems call_of_flame mana_spring_totem convection elemental_focus healing_wave fire_nova_totem concussion elemental_fury" })
add("SHAMAN", 2, { id = "flametongue_weapons", minRound = 2,
  core = "flametongue_weapon flametongue_totem earth_shock healing_wave", train = "flametongue_weapon earth_shock", supportTrain = "flametongue_totem", payoff = "flametongue_totem",
  support = "elemental_weapons stormstrike shaman_flurry mana_spring_totem reverberation lightning_shield strength_of_earth_totem_active shaman_weapon_mastery thundering_strikes" })
add("SHAMAN", 4, { id = "water_totem_sustain", minRound = 3,
  core = "healing_stream_totem healing_wave lightning_shield lightning_bolt", train = "healing_stream_totem healing_wave", supportTrain = "healing_grace", payoff = "healing_stream_totem",
  support = "healing_grace restorative_totems tidal_focus healing_way ancestral_healing poison_cleansing_totem reincarnation tidal_mastery totemic_mastery" })

add("MAGE", 1, { id = "arcane_missiles", minRound = 2,
  core = "arcane_missiles mana_shield", train = "arcane_missiles mana_shield", supportTrain = "arcane_meditation", payoff = "arcane_missiles",
  support = "arcane_meditation arcane_concentration improved_arcane_missiles counterspell mage_armor arcane_intellect magic_absorption" })
add("MAGE", 2, { id = "scorch_blast", minRound = 2,
  core = "scorch fire_blast", train = "fire_blast scorch", supportTrain = "improved_fire_blast", payoff = "fire_blast",
  support = "improved_fire_blast improved_scorch incinerate master_of_elements arcane_meditation mage_armor mana_agate" })
add("MAGE", 3, { id = "blizzard_channel", minRound = 7,
  core = "blizzard ice_barrier improved_blizzard", train = "blizzard ice_barrier", supportTrain = "improved_blizzard", payoff = "blizzard",
  support = "frost_channeling fire_ward amplify_magic counterspell arcane_meditation mage_armor mana_agate" })
add("MAGE", 2, { id = "prepared_pyroblast", minRound = 10,
  core = "pyroblast presence_of_mind fire_ward", train = "pyroblast", supportTrain = "presence_of_mind", payoff = "pyroblast",
  support = "ignite fire_power combustion improved_fire_ward mana_agate evocation mage_armor" })
add("MAGE", 1, { id = "arcane_power_burst", minRound = 10,
  core = "arcane_explosion arcane_power mana_agate", train = "arcane_explosion arcane_power", supportTrain = "evocation", payoff = "arcane_explosion",
  support = "improved_arcane_explosion arcane_concentration arcane_instability evocation polymorph mage_armor" })

add("WARLOCK", 2, { id = "succubus_lash", minRound = 3, hybrid = true,
  core = "summon_succubus lash_of_pain shadow_bolt life_tap", train = "summon_succubus shadow_bolt", supportTrain = "lash_of_pain", payoff = "lash_of_pain",
  support = "curse_of_shadow unholy_power improved_shadow_bolt master_demonologist demon_armor death_coil healthstone" })
add("WARLOCK", 4, { id = "felhunter_commands", minRound = 3, hybrid = true,
  core = "summon_felhunter devour_magic drain_life life_tap", train = "summon_felhunter drain_life", supportTrain = "devour_magic", payoff = "devour_magic",
  support = "corruption drain_mana dark_pact soul_link demon_armor healthstone master_summoner" })
add("WARLOCK", 3, { id = "sacrifice_fire", minRound = 7, secondary = "demonology", hybrid = true,
  core = "immolate searing_pain summon_imp life_tap demonic_sacrifice", train = "immolate searing_pain", supportTrain = "demonic_sacrifice", payoff = "demonic_sacrifice",
  support = "conflagrate curse_of_the_elements ruin demon_armor healthstone bane" })
add("WARLOCK", 2, { id = "pact_command_hybrid", minRound = 10, spec = "destruction", secondary = "demonology", hybrid = true,
  core = "summon_succubus lash_of_pain searing_pain shadow_bolt dark_pact", train = "searing_pain shadow_bolt lash_of_pain", supportTrain = "dark_pact", payoff = "dark_pact",
  support = "curse_of_shadow bane devastation ruin unholy_power demon_armor healthstone" })

add("ROGUE", 2, { id = "trained_backstab", minRound = 2, hybrid = true,
  weapons = { "worn_dagger assassins_blade gut_ripper dragonfang_blade death_sting", "small_dagger distracting_dagger core_hound_tooth" },
  core = "backstab eviscerate", train = "backstab eviscerate", supportTrain = "relentless_strikes", payoff = "backstab",
  support = "seal_fate precision dagger_specialization cold_blood relentless_strikes blade_flurry gouge improved_sinister_strike" })
add("ROGUE", 3, { id = "ambush_reset", minRound = 3,
  core = "stealth ambush vanish eviscerate", train = "ambush eviscerate", supportTrain = "vanish", payoff = "ambush",
  support = "initiative camouflage opportunity preparation premeditation cold_blood hemorrhage" })
add("ROGUE", 3, { id = "sap_preparation", minRound = 2, secondary = "combat", hybrid = true,
  core = "stealth sap sinister_strike eviscerate", train = "sinister_strike eviscerate", supportTrain = "improved_sap", payoff = "sap",
  support = "improved_sap vanish preparation premeditation setup evasion kick improved_sinister_strike" })

add("HUNTER", 1, { id = "turtle_sustain", minRound = 3,
  core = "rough_arrows pet_turtle arcane_shot bite mend_pet", train = "pet_turtle bite", supportTrain = "improved_mend_pet", payoff = "pet_turtle",
  support = "improved_mend_pet spirit_bond bestial_discipline aspect_of_the_monkey feed_pet efficiency quiver" })
add("HUNTER", 3, { id = "wolf_weapon_timing", minRound = 3,
  core = "rough_arrows pet_wolf furious_howl aimed_shot", train = "aimed_shot pet_wolf", supportTrain = "furious_howl", payoff = "furious_howl",
  support = "hunters_mark aspect_of_the_hawk quiver rapid_fire efficiency lethal_shots mortal_shots" })
add("HUNTER", 2, { id = "survival_melee", minRound = 2,
  weapons = { "worn_dagger cruel_barb bonebiter arcanite_reaper" },
  core = "pet_cat raptor_strike mongoose_bite counterattack", train = "raptor_strike mongoose_bite", supportTrain = "aspect_of_the_monkey", payoff = "raptor_strike",
  support = "aspect_of_the_monkey deterrence wyvern_sting surefooted mend_pet spirit_bond killer_instinct" })

add("DRUID", 1, { id = "wrath_periodic", minRound = 2, hybrid = true,
  core = "wrath moonfire insect_swarm", train = "wrath moonfire", supportTrain = "improved_moonfire", payoff = "wrath",
  support = "improved_wrath improved_moonfire moonglow natures_grace rejuvenation reflection mark_of_the_wild innervate moonkin_form" })
add("DRUID", 2, { id = "shred_finisher", minRound = 3, secondary = "balance",
  core = "cat_form claw rip ferocious_bite", train = "claw rip ferocious_bite", supportTrain = "improved_shred", payoff = "ferocious_bite",
  support = "rake shred improved_shred feral_aggression faerie_fire pounce omen_of_clarity mark_of_the_wild tigers_fury leader_of_the_pack" })
add("DRUID", 3, { id = "swipe_control", minRound = 3,
  core = "bear_form swipe enrage_druid bash", train = "swipe bear_form", supportTrain = "improved_enrage", payoff = "swipe",
  support = "primal_fury improved_enrage feral_charge brutal_impact faerie_fire demoralizing_roar mark_of_the_wild" })
add("DRUID", 1, { id = "hurricane_channel", minRound = 7, hybrid = true,
  core = "hurricane moonfire rejuvenation", train = "hurricane moonfire", supportTrain = "barkskin", payoff = "hurricane",
  support = "barkskin entangling_roots thorns improved_thorns natures_grasp mark_of_the_wild innervate" })
add("DRUID", 4, { id = "touch_periodic", minRound = 3, hybrid = true,
  core = "healing_touch rejuvenation moonfire", train = "healing_touch rejuvenation", supportTrain = "gift_of_nature", payoff = "healing_touch",
  support = "improved_healing_touch gift_of_nature tranquil_spirit insect_swarm regrowth reflection mark_of_the_wild natures_swiftness" })


for _, class in ipairs(ns.ClassList) do
  for _, plan in ipairs(ns.Bots.ARCHETYPES[class.key] or {}) do
    for _, field in ipairs({ "core", "support", "train", "supportTrain" }) do
      if plan[field] then
        local choices = {}
        for key in plan[field]:gmatch("%S+") do
          local def = assert(ns.ItemsByKey[key], plan.id .. " references unknown ability " .. key)
          if not def.shopClasses or #def.shopClasses > 0 then choices[#choices + 1] = key end
        end
        plan[field] = table.concat(choices, " ")
      end
    end
  end
end
