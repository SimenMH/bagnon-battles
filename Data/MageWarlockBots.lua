local ADDON, ns = ...
local MAGE_STAVES = "bent_staff walking_stick caster_scrimshaw_dagger caster_sacrificial_kris staff_of_jordan hypnotic_blade witchblade rod_of_the_ogre_magi sorcerous_dagger staff_of_dominance staff_of_the_shadow_flame"
local WARLOCK_STAVES = "warlock_worn_dirk walking_stick caster_scrimshaw_dagger caster_sacrificial_kris staff_of_jordan hypnotic_blade witchblade soul_harvester sorcerous_dagger kris_of_unspoken_names blade_of_eternal_darkness staff_of_dominance staff_of_the_shadow_flame"
local MAGE_GEAR = {
  "thin_cloth_armor azure_silk_vest magister_chest arcanist_chest netherwind_chest", "azure_silk_hood magister_head arcanist_head",
  "azure_silk_gloves magister_hands netherwind_hands", "azure_silk_pants arcanist_legs netherwind_legs",
  "azure_silk_belt sorcerer_waist", "silver_thread_cuffs sorcerer_wrist", "spidersilk_boots magister_feet frostfire_feet",
  "silver_thread_amice arcanist_shoulder netherwind_shoulder", "mage_silver_thread_cloak",
  "mage_ring_of_spell_power", "fire_ruby briarwood_reed", "second_wind",
}
local WARLOCK_GEAR = {
  "thin_cloth_armor shadoweave_robe dreadmist_chest felheart_chest nemesis_chest", "shadoweave_mask dreadmist_head felheart_head",
  "shadoweave_gloves nemesis_hands", "shadoweave_pants nemesis_legs plagueheart_legs", "sanguine_belt deathmist_waist",
  "sanguine_cuffs deathmist_wrist", "shadoweave_boots dreadmist_feet plagueheart_feet", "shadoweave_shoulders dreadmist_shoulder",
  "sanguine_cape", "band_of_rumination band_of_dark_dominion", "royal_seal_warlock briarwood_reed", "second_wind",
}
ns.Bots.ARCHETYPES.MAGE = {
  { id = "arcane_resonance", spec = "arcane", secondary = "fire", weapons = { MAGE_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter wand_of_biting_cold" }, core = "arcane_missiles arcane_explosion mana_agate", train = "arcane_explosion arcane_missiles", payoff = "arcane_explosion", gear = MAGE_GEAR,
    support = "arcane_meditation arcane_concentration arcane_mind mana_shield mage_armor evocation magic_absorption dampen_magic arcane_instability" },
  { id = "ignite_pyroblast", spec = "fire", secondary = "arcane", weapons = { MAGE_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter wand_of_biting_cold" }, core = "fireball scorch ignite pyroblast", train = "pyroblast fireball", payoff = "pyroblast", gear = MAGE_GEAR,
    support = "fire_blast improved_scorch master_of_elements flamestrike impact mana_shield mage_armor evocation fire_power arcane_concentration" },
  { id = "frost_shatter", spec = "frost", secondary = "arcane", weapons = { MAGE_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter wand_of_biting_cold" }, core = "frostbolt frost_nova cone_of_cold shatter", train = "frostbolt cone_of_cold", payoff = "shatter", gear = {
      "thin_cloth_armor azure_silk_vest frostfire_chest", "azure_silk_hood frostfire_head", "silver_thread_amice frostfire_shoulder", "spidersilk_boots frostfire_feet", "hands_of_power frostfire_hands", "azure_silk_pants frostfire_legs", "silver_thread_cuffs sorcerer_wrist", "azure_silk_belt sorcerer_waist", "freezing_band", "mage_ring_of_spell_power", "second_wind", "mage_silver_thread_cloak" },
    support = "frostbite ice_shards frost_channeling ice_barrier frost_armor evocation blizzard winters_chill ice_block magic_absorption" },
  { id = "elemental_hybrid", minRound = 4, spec = "fire", secondary = "frost", hybrid = true, weapons = { MAGE_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter wand_of_biting_cold" }, core = "fireball frostbolt frost_nova scorch ignite pyroblast", train = "fireball frostbolt", payoff = "pyroblast", gear = MAGE_GEAR,
    support = "shatter cone_of_cold master_of_elements mana_shield mage_armor arcane_concentration evocation" },
}
ns.Bots.ARCHETYPES.WARLOCK = {
  { id = "affliction_drains", spec = "affliction", secondary = "destruction", weapons = { WARLOCK_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter skuls_ghastly_touch touch_of_chaos" }, core = "corruption curse_of_agony drain_life life_tap siphon_life", train = "corruption drain_life", payoff = "siphon_life", gear = WARLOCK_GEAR,
    support = "nightfall shadow_bolt drain_soul improved_corruption improved_drain_life demon_armor fear demonic_embrace shadow_mastery" },
  { id = "imp_demonology", spec = "demonology", secondary = "destruction", weapons = { WARLOCK_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter skuls_ghastly_touch touch_of_chaos" }, core = "summon_imp immolate shadow_bolt life_tap health_funnel unholy_power", train = "immolate shadow_bolt", payoff = "unholy_power", gear = WARLOCK_GEAR,
    support = "improved_imp healthstone fel_stamina demon_armor master_demonologist demonic_embrace searing_pain the_black_book" },
  { id = "destruction_burn", spec = "destruction", secondary = "affliction", weapons = { WARLOCK_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter skuls_ghastly_touch touch_of_chaos" }, core = "immolate searing_pain conflagrate life_tap shadow_bolt", train = "conflagrate immolate", payoff = "conflagrate", gear = WARLOCK_GEAR,
    support = "corruption rain_of_fire bane devastation ruin emberstorm drain_life demon_armor fear shadowburn" },
  { id = "voidwalker_attrition", minRound = 2, spec = "demonology", secondary = "affliction", hybrid = true, weapons = { WARLOCK_STAVES, "lesser_magic_wand greater_magic_wand gravestone_scepter skuls_ghastly_touch touch_of_chaos" }, core = "summon_voidwalker corruption curse_of_agony drain_life life_tap siphon_life", train = "corruption drain_life", payoff = "siphon_life", gear = WARLOCK_GEAR,
    support = "fel_stamina demonic_embrace demon_armor health_funnel unholy_power improved_corruption" },
}
