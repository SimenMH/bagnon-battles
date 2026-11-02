local ADDON, ns = ...
local paladinMelee = {
  "paladin_copper_chain_vest paladin_green_iron_hauberk lightforge_chest judgement_armor_chest", "prospectors_cuffs", "paladin_ornate_mithril_gloves",
  "fine_leather_boots paladin_peacekeeper_boots lightforge_feet", "seal_of_wrynn", "libram_of_hope", "second_wind", "judgement_armor_head", "lightforge_shoulder judgement_armor_shoulder",
  "paladin_linen_cloak paladin_dark_leather_cloak", "paladin_emberfury_talisman", "paladin_painweaver_band", "paladin_green_iron_leggings",
}
local paladinHealing = {
  "simple_robe paladin_green_iron_hauberk redemption_chest", "royal_seal_of_eldre_thalas_paladin", "libram_of_divinity libram_of_light", "paladin_linen_cloak paladin_silver_thread_cloak paladin_shroud_of_pure_thought",
  "seal_of_wrynn", "paladin_peacekeeper_boots redemption_feet", "second_wind", "redemption_head", "redemption_hands", "redemption_shoulder",
  "paladin_animated_chain_necklace paladin_pendant_of_the_fallen_dragon", "paladin_rosewine_circle", "paladin_azure_silk_pants", "paladin_bright_belt",
  "wooden_shield paladin_draconian_deflector",
}
local shamanPhysical = {
  "tanned_leather_jerkin shaman_green_iron_hauberk shaman_black_dragonscale_breastplate earthfury_chest", "prospectors_cuffs", "shaman_rune_of_the_guard_captain", "seal_of_wrynn", "fine_leather_boots earthfury_feet",
  "edgemasters_handguards earthfury_hands", "second_wind", "the_elements_head earthfury_head", "earthfury_shoulder", "fine_leather_belt",
  "shaman_linen_cloak shaman_dark_leather_cloak", "shaman_emberfury_talisman", "shaman_painweaver_band", "shaman_green_iron_leggings",
}
local shamanSpell = {
  "simple_robe shaman_copper_chain_vest shaman_green_iron_hauberk the_elements_chest ten_storms_chest", "briarwood_reed", "totem_of_rage", "seal_of_wrynn shaman_ring_of_spell_power", "shaman_turtle_scale_gloves ten_storms_hands",
  "second_wind", "fine_leather_boots ten_storms_feet", "the_elements_head ten_storms_head", "ten_storms_shoulder", "shaman_emberstone_staff",
  "shaman_linen_cloak shaman_silver_thread_cloak", "shaman_star_of_mystaria", "shaman_azure_silk_pants",
}
local shamanHealing = {
  "simple_robe shaman_green_iron_hauberk shaman_green_dragonscale_breastplate earthshatter_chest", "royal_seal_of_eldre_thalas_shaman", "totem_of_sustaining totem_of_life", "shaman_linen_cloak shaman_silver_thread_cloak shaman_shroud_of_pure_thought",
  "seal_of_wrynn", "shaman_turtle_scale_gloves earthshatter_hands", "second_wind", "the_elements_head earthshatter_head", "fine_leather_boots earthshatter_feet", "earthshatter_shoulder",
  "shaman_animated_chain_necklace", "shaman_rosewine_circle", "shaman_azure_silk_pants", "shaman_bright_belt",
}

ns.Bots.ARCHETYPES.PALADIN = {
  { id = "righteous_judgement", spec = "retribution", secondary = "holy", weapons = { "worn_mace cruel_barb verigans_fist paladin_hammer_of_the_grand_crusader obsidian_edged_blade" },
    core = "seal_of_righteousness judgement holy_light blessing_of_might", train = "judgement", payoff = "judgement", gear = paladinMelee,
    support = "improved_judgement conviction vengeance_paladin benediction consecration sanctity_aura hammer_of_wrath eye_for_an_eye hammer_of_justice" },
  { id = "command_crits", minRound = 2, spec = "retribution", secondary = "protection", weapons = { "spiked_club war_hammer verigans_fist arcanite_reaper zinrokh_destroyer_of_worlds" },
    core = "seal_of_command judgement holy_light blessing_of_might", train = "judgement", payoff = "judgement", gear = paladinMelee,
    support = "conviction vengeance_paladin improved_judgement two_handed_weapon_specialization_paladin benediction retribution_aura repentance eye_for_an_eye hammer_of_justice" },
  { id = "holy_bulwark", spec = "protection", secondary = "holy", weapons = { "worn_mace cruel_barb ironfoe paladin_aurastone_hammer" },
    equipment = "wooden_shield paladin_draconian_deflector drillborer_disk elementium_reinforced_bulwark", core = "righteous_fury judgement holy_light redoubt holy_shield", train = "holy_shield judgement", payoff = "holy_shield",
    gear = { "thin_cloth_armor paladin_enchanted_thorium_breastplate lawbringer_chest", "libram_of_truth", "seal_of_wrynn", "paladin_stockade_pauldrons", "second_wind", "lawbringer_head", "lawbringer_hands", "fine_leather_boots lawbringer_feet", "paladin_linen_cloak paladin_dark_leather_cloak", "paladin_animated_chain_necklace", "paladin_green_iron_leggings" },
    support = "divine_protection blessing_of_sanctuary devotion_aura paladin_toughness reckoning paladin_shield_specialization improved_devotion_aura consecration seal_of_light divine_shield" },
  { id = "holy_shock", spec = "holy", secondary = "protection", weapons = { "worn_mace hand_of_edward_the_odd paladin_aurastone_hammer paladin_lokamir_il_romathis" },
    core = "holy_light judgement flash_of_light holy_shock", train = "holy_shock flash_of_light", payoff = "holy_shock", gear = paladinHealing,
    support = "concentration_aura healing_light illumination divine_favor seal_of_light blessing_of_wisdom divine_intellect spiritual_focus devotion_aura lasting_judgement lay_on_hands" },
}
ns.Bots.ARCHETYPES.SHAMAN = {
  { id = "elemental_fire", spec = "elemental", secondary = "restoration", weapons = { "walking_stick shaman_crescent_staff shaman_emberstone_staff staff_of_dominance staff_of_the_shadow_flame" },
    core = "lightning_bolt flame_shock earth_shock chain_lightning", train = "lightning_bolt chain_lightning", payoff = "chain_lightning", gear = shamanSpell,
    support = "searing_totem mana_spring_totem elemental_focus convection call_of_flame lightning_mastery concussion elemental_mastery healing_wave" },
  { id = "windfury_twohand", spec = "enhancement", secondary = "elemental", weapons = { "spiked_club war_hammer fist_of_omokk shaman_earthshaker shaman_spinal_reaper" },
    core = "rockbiter_weapon stormstrike earth_shock lightning_shield healing_wave", train = "stormstrike earth_shock", payoff = "stormstrike", gear = shamanPhysical,
    support = "strength_of_earth_totem_active shaman_flurry thundering_strikes elemental_weapons reverberation elemental_devastation mana_spring_totem windfury_totem windwall_totem frost_resistance_totem" },
  { id = "windfury_burst", minRound = 3, spec = "enhancement", secondary = "elemental", weapons = { "spiked_club war_hammer fist_of_omokk shaman_earthshaker shaman_spinal_reaper" },
    core = "windfury_weapon stormstrike earth_shock lightning_shield healing_wave", train = "stormstrike earth_shock", payoff = "stormstrike", gear = shamanPhysical,
    support = "flame_shock shaman_flurry strength_of_earth_totem_active thundering_strikes reverberation elemental_devastation grace_of_air_totem_active mana_spring_totem windwall_totem frost_resistance_totem" },
  { id = "restorative_lightning", spec = "restoration", secondary = "enhancement", weapons = { "walking_stick shaman_crescent_staff shaman_aurastone_hammer shaman_lokamir_il_romathis" },
    core = "healing_wave lightning_bolt lightning_shield healing_stream_totem", train = "healing_wave lightning_shield", payoff = "healing_wave", gear = shamanHealing,
    support = "lesser_healing_wave chain_heal ancestral_healing tidal_mastery tidal_focus tremor_totem healing_way restorative_totems healing_grace stoneskin_totem_active grounding_totem natures_swiftness_shaman" },
}
