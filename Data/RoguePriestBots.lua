local ADDON, ns = ...
local ROGUE_GEAR = {
  "dark_leather_tunic blackened_defias_armor cadaverous_armor bloodfang_chest", "dark_leather_gloves venomshroud_mitts_rogue shadowcraft_hands bloodfang_hands", "leggings_of_the_fang bonescythe_legs", "dark_leather_boots shadowcraft_feet nightslayer_feet", "nightscape_headband nightslayer_head bonescythe_head", "truestrike_shoulders bloodfang_shoulder", "prospectors_cuffs blackmist_armguards shadowcraft_wrist", "venomshroud_belt_rogue fine_leather_belt belt_of_the_preserved_heads shadowcraft_waist", "rogue_blackhands_breadth royal_seal_rogue renatakis_charm_of_trickery", "band_of_veiled_shadows royal_seal_of_alexis", "pendant_of_celerity", "cloak_of_veiled_shadows", "hand_of_justice second_wind",
}
local PRIEST_GEAR = {
  "simple_robe gray_woolen_robe robes_of_the_exalted prophecy_chest faith_chest", "whitemanes_chapeau prophecy_head faith_head", "burial_shawl prophecy_shoulder", "greenweave_gloves_priest hands_of_the_exalted_herald devout_hands faith_hands", "simple_britches_priest abyssal_cloth_pants_priest prophecy_legs", "wolfrunner_shoes devout_feet faith_feet", "bracers_of_prosperity_priest devout_wrist", "greenweave_sash_priest dawnspire_cord devout_waist", "royal_seal_priest blessed_prayer_beads scarab_brooch_priest", "animated_chain_necklace_priest", "band_of_mending_priest", "hide_of_the_wild_priest", "second_wind mindtap_talisman_priest",
}
local SHADOW_GEAR = {
  "simple_robe gray_woolen_robe transcendence_chest", "shadoweave_mask_priest transcendence_head", "burial_shawl transcendence_shoulder", "greenweave_gloves_priest shadoweave_gloves_priest transcendence_hands", "simple_britches_priest abyssal_cloth_pants_priest transcendence_legs", "wolfrunner_shoes transcendence_feet", "bracers_of_prosperity_priest", "greenweave_sash_priest dawnspire_cord", "briarwood_reed mindtap_talisman_priest", "animated_chain_necklace_priest", "maiden_circle_priest", "blackflame_cape_priest", "second_wind",
}
local WANDS = "lesser_magic_wand greater_magic_wand gravestone_scepter skuls_ghastly_touch"
local STAVES = "acolytes_staff chanting_blade_priest walking_stick sacrificial_kris_priest illusionary_rod trindlehaven_staff priest_benediction"

ns.Bots.ARCHETYPES.ROGUE = {
  { id = "assassination_poison", spec = "assassination", secondary = "combat", weapons = { "worn_dagger assassins_blade gut_ripper dragonfang_blade death_sting", "small_dagger toxic_revenger distracting_dagger core_hound_tooth" }, core = "sinister_strike deadly_poison eviscerate", train = "eviscerate sinister_strike", payoff = "eviscerate", gear = ROGUE_GEAR,
    support = "instant_poison relentless_strikes mind_numbing_poison improved_poisons seal_fate vile_poisons cold_blood lethality wound_poison" },
  { id = "combat_blades", spec = "combat", secondary = "assassination", weapons = { "worn_dagger cruel_barb thrash_blade krol_blade", "small_dagger distracting_dagger gut_ripper" }, core = "sinister_strike slice_and_dice eviscerate", train = "sinister_strike eviscerate", payoff = "sinister_strike", gear = ROGUE_GEAR,
    support = "dual_wield_specialization_rogue instant_poison precision sword_specialization_rogue aggression blade_flurry relentless_strikes mind_numbing_poison" },
  { id = "subtlety_ambush", spec = "subtlety", secondary = "assassination", weapons = { "worn_dagger assassins_blade barman_shanker dragonfang_blade death_sting", "small_dagger toxic_revenger distracting_dagger core_hound_tooth" }, core = "stealth garrote hemorrhage rupture", train = "hemorrhage rupture", payoff = "hemorrhage", gear = ROGUE_GEAR,
    support = "ambush vanish initiative serrated_blades ghostly_strike setup evasion dirty_deeds relentless_strikes" },
  { id = "evasive_duelist", spec = "combat", secondary = "subtlety", hybrid = true, weapons = { "worn_dagger cruel_barb thrash_blade krol_blade", "small_dagger distracting_dagger" }, core = "sinister_strike ghostly_strike riposte kidney_shot", train = "ghostly_strike riposte", payoff = "riposte", gear = ROGUE_GEAR,
    support = "setup evasion feint deadly_poison gouge backstab relentless_strikes dirty_deeds aggression" },
}

ns.Bots.ARCHETYPES.PRIEST = {
  { id = "discipline_aegis", spec = "discipline", secondary = "holy", weapons = { STAVES, WANDS }, core = "smite power_word_shield lesser_heal", train = "smite power_word_shield", payoff = "smite", gear = PRIEST_GEAR,
    support = "meditation elunes_grace inner_fire mental_agility improved_power_word_shield renew force_of_will inner_focus power_word_fortitude" },
  { id = "holy_grace", spec = "holy", secondary = "discipline", weapons = { STAVES, WANDS }, core = "smite renew holy_fire lesser_heal", train = "holy_fire renew", payoff = "holy_fire", gear = PRIEST_GEAR,
    support = "heal_priest spiritual_healing inspiration searing_light divine_fury power_word_shield meditation greater_heal" },
  { id = "shadow_sustain", spec = "shadow", secondary = "discipline", weapons = { "acolytes_staff chanting_blade_priest walking_stick sacrificial_kris_priest illusionary_rod trindlehaven_staff anathema", WANDS }, core = "shadow_word_pain mind_blast vampiric_embrace", train = "mind_blast shadow_word_pain", payoff = "mind_blast", gear = SHADOW_GEAR,
    support = "mind_flay spirit_tap darkness shadow_weaving power_word_shield renew shadow_reach improved_shadow_word_pain silence" },
  { id = "twilight_healing", spec = "shadow", secondary = "holy", hybrid = true, weapons = { STAVES, WANDS }, core = "shadow_word_pain renew holy_fire vampiric_embrace mind_blast", train = "holy_fire renew", payoff = "holy_fire", gear = PRIEST_GEAR,
    support = "mind_flay spirit_tap spiritual_healing lesser_heal power_word_shield meditation searing_light inspiration" },
}
