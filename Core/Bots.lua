local ADDON, ns = ...
local Util = ns.Util

local Bots = {}
ns.Bots = Bots

Bots.FIRST_RUN_BUDGET_SCALE = 0.75

Bots.NAMES = {
  "Aiden Vale", "Alva Reed", "Arlen Moss", "Astrid Holm", "Beric Hale", "Bran Harker",
  "Brenna Flint", "Bram Calder", "Carra Venn", "Cedric Holt", "Corin Ashby", "Dagna Stonehand",
  "Dain Copperfield", "Dalia Wells", "Daric Ward", "Della Rowan", "Dorin Anvilson", "Duncan Marr",
  "Edda Stonehill", "Edric Hayes", "Eira Frost", "Elin Rowe", "Elora Fern", "Emil Harth",
  "Erik Voss", "Fara Glen", "Fen Alder", "Finn Mercer", "Freya Brant", "Gareth Cole",
  "Gilda Copperwick", "Gorin Redbeard", "Greta Hall", "Halvar Berg", "Hanna Shaw", "Harlan Pike",
  "Hilda Ashford", "Ida Brook", "Ilan Thorne", "Ingrid Falk", "Iona Hart", "Ivar Fell",
  "Jana Winter", "Jarek Dusk", "Jessa Quinn", "Jonas Reed", "Joren Blackwell", "Kara Marsh",
  "Kellan Drake", "Kira Moonbrook", "Korin Steeltoe", "Lana Rivers", "Lars Fenwick", "Leif Brandt",
  "Lena Hawke", "Lina Quickfuse", "Lorn Beck", "Lyra Ashwood", "Mara West", "Maren Dale",
  "Mika Wren", "Milo Gearhart", "Mira Solen", "Nell Rook", "Nessa Ford", "Niko Rusk",
  "Nora Greymore", "Olin Fenn", "Orik Deepwell", "Oskar Holt", "Petra Stonefoot", "Rhea Morrow",
  "Rian Oakley", "Rolf Hald", "Ronan Grey", "Runa Bell", "Sella Thornwick", "Seth Willow",
  "Sigrid Norr", "Soren Fen", "Talia North", "Tamsin Redd", "Taran Beckett", "Tessa Vale",
  "Thora Ironvale", "Tobin Moss", "Torren Ashford", "Tristan Hale", "Una Crowe", "Vera Lind",
  "Viggo Brand", "Willa Hartwell", "Wren Alder", "Yara Dalen", "Ylva Reed", "Zara Venn",
}

local SPELL = {
  "simple_robe thin_cloth_armor cenarion_chest", "songstone_of_ironforge seal_of_wrynn", "spritecaster_cape",
  "briarwood_reed", "orb_of_the_darkmoon", "cenarion_head stormrage_head", "fine_leather_gloves cenarion_hands stormrage_hands", "second_wind",
  "whipvine_cord", "cenarion_feet stormrage_feet", "bracers_of_prosperity",
}
local HEALING = {
  "simple_robe thin_cloth_armor cenarion_chest", "bracers_of_prosperity", "whipvine_cord",
  "animated_chain_necklace orb_of_the_darkmoon", "hide_of_the_wild spritecaster_cape", "songstone_of_ironforge seal_of_wrynn",
  "idol_of_rejuvenation", "second_wind", "cenarion_head stormrage_head", "fine_leather_gloves cenarion_hands stormrage_hands", "cenarion_feet stormrage_feet",
}
local HUNTER_GEAR = {
  "tanned_leather_jerkin thin_cloth_armor beastmaster_chest giantstalker_chest cryptstalker_chest", "blackstone_ring seal_of_wrynn", "cape_of_the_brotherhood",
  "royal_seal_hunter devilsaur_tooth", "fine_leather_belt warpwood_binding dreamers_belt", "mark_of_fordring tooth_of_gnarr",
  "prospectors_cuffs wristguards_of_true_flight", "beastmaster_head giantstalker_head", "fine_leather_boots beastmaster_feet giantstalker_feet", "second_wind",
  "devilsaur_hands", "devilsaur_legs", "beastmaster_shoulder dragonstalker_shoulder",
}
local FERAL_GEAR = {
  "tanned_leather_jerkin thin_cloth_armor feralheart_chest dreamwalker_chest", "blackstone_ring seal_of_wrynn", "cape_of_the_brotherhood",
  "prospectors_cuffs bracers_of_the_eclipse", "mark_of_fordring onyxia_tooth_pendant", "idol_of_ferocity", "second_wind hand_of_justice",
  "feralheart_head dreamwalker_head", "fine_leather_boots feralheart_feet dreamwalker_feet",
  "devilsaur_hands", "devilsaur_legs", "feralheart_shoulder", "fine_leather_belt",
}
local BOWS = "worn_shortbow hunting_bow heavy_crossbow blackcrow carapace_spine_crossbow rhokdelar"
local STAVES = "gnarled_staff walking_stick staff_of_jordan staff_of_dominance staff_of_the_shadow_flame"

local WARRIOR_PHYSICAL = {
  "thin_cloth_armor tanned_leather_jerkin heroism_chest wrath_chest dreadnaught_chest", "tempered_band blackstone_ring seal_of_wrynn",
  "cape_of_the_brotherhood", "mark_of_fordring onyxia_tooth_pendant", "edgemasters_handguards",
  "second_wind hand_of_justice", "heroism_head wrath_head", "fine_leather_boots fleetfoot_boots heroism_feet wrath_feet",
  "wrath_shoulder dreadnaught_shoulder", "wrath_legs dreadnaught_legs", "prospectors_cuffs", "fine_leather_belt",
}
local WARRIOR_BERSERKER = {
  "thin_cloth_armor tanned_leather_jerkin heroism_chest dreadnaught_chest", "tempered_band ring_of_fury seal_of_wrynn",
  "bloodguard_emblem second_wind", "cape_of_the_brotherhood", "medallion_of_grand_marshal_morris",
  "edgemasters_handguards", "fine_leather_boots fleetfoot_boots heroism_feet",
  "heroism_head dreadnaught_head", "prospectors_cuffs", "fine_leather_belt", "dreadnaught_shoulder dreadnaught_legs",
}
local WARRIOR_BLOCK = {
  "thin_cloth_armor might_chest", "tempered_band ring_of_fury seal_of_wrynn", "bulwark_gauntlets might_hands",
  "medallion_of_grand_marshal_morris", "second_wind lifegiving_gem", "might_head", "might_shoulder might_legs",
  "cape_of_the_brotherhood", "prospectors_cuffs", "fine_leather_boots might_feet", "fine_leather_belt",
}
local WARRIOR_AVOIDANCE = {
  "thin_cloth_armor tanned_leather_jerkin might_chest", "tempered_band ring_of_fury seal_of_wrynn",
  "medallion_of_grand_marshal_morris", "bulwark_gauntlets edgemasters_handguards", "second_wind bloodguard_emblem",
  "cape_of_the_brotherhood", "prospectors_cuffs", "fine_leather_boots fleetfoot_boots", "might_head", "fine_leather_belt",
}
local WARRIOR_HEAVY = "spiked_club battle_axe claymore oak_mallet bonebiter arcanite_reaper fist_of_omokk shaman_earthshaker shaman_spinal_reaper"
local WARRIOR_MAIN = "worn_axe hand_axe ironwood_mace cruel_barb skullcrusher shadowfang crescent_axe ironfoe thrash_blade krol_blade deathbringer castigator"
local WARRIOR_OFF = "worn_dagger hand_axe ironwood_mace carving_knife twin_tomahawk cruel_barb nightblade dalrends_tribal_guardian"

Bots.ARCHETYPES = {
  WARRIOR = {
    { id = "arms_bleed", spec = "arms", secondary = "fury", weapons = { "worn_axe battle_axe claymore bonebiter arcanite_reaper" },
      core = "heroic_strike rend bloodrage deep_wounds", train = "rend heroic_strike", supportTrain = "battle_shout", payoff = "rend", gear = WARRIOR_PHYSICAL,
      support = "impale improved_rend axe_specialization battle_shout battle_stance anger_management" },
    { id = "fury_dual", spec = "fury", secondary = "arms", weapons = { WARRIOR_MAIN, WARRIOR_OFF },
      core = "heroic_strike bloodrage bloodthirst", train = "bloodthirst heroic_strike", supportTrain = "battle_shout blood_craze", payoff = "bloodthirst", gear = WARRIOR_PHYSICAL,
      support = "flurry berserker_rage unbridled_wrath blood_craze battle_shout booming_voice dual_wield_specialization one_handed_weapon_specialization" },
    { id = "protection", spec = "prot", secondary = "arms", weapons = { WARRIOR_MAIN },
      equipment = "wooden_shield shaman_redbeard_crest crest_of_retribution drillborer_disk", core = "bloodrage shield_bash shield_slam revenge shield_block", train = "shield_slam shield_bash", supportTrain = "shield_block", payoff = "shield_slam",
      gear = WARRIOR_BLOCK, support = "defensive_stance defiance improved_shield_block shield_wall iron_will toughness improved_shield_bash" },
    { id = "fury_berserker", minRound = 4, spec = "fury", secondary = "arms", weapons = { WARRIOR_MAIN, WARRIOR_OFF },
      core = "bloodrage heroic_strike whirlwind execute", train = "whirlwind heroic_strike", supportTrain = "blood_craze berserker_stance", payoff = "whirlwind", gear = WARRIOR_BERSERKER,
      support = "death_wish blood_craze berserker_rage berserker_stance improved_bloodrage flurry recklessness intimidating_shout" },
    { id = "arms_mortal", minRound = 2, spec = "arms", secondary = "fury", weapons = { WARRIOR_HEAVY },
      core = "heroic_strike bloodrage mortal_strike overpower", train = "mortal_strike overpower", supportTrain = "battle_shout", payoff = "mortal_strike", gear = WARRIOR_PHYSICAL,
      support = "deep_wounds impale improved_overpower sunder_armor battle_stance battle_shout two_handed_weapon_specialization" },
    { id = "arms_heavy", minRound = 3, spec = "arms", secondary = "fury", weapons = { WARRIOR_HEAVY },
      core = "bloodrage slam intercept sunder_armor", train = "slam intercept", supportTrain = "battle_shout battle_stance", payoff = "slam", gear = WARRIOR_PHYSICAL,
      support = "two_handed_weapon_specialization tactical_mastery battle_stance battle_shout berserker_rage intimidating_shout" },
    { id = "fury_heavy", minRound = 2, spec = "fury", secondary = "arms", weapons = { WARRIOR_HEAVY },
      core = "bloodrage cleave slam", train = "cleave slam", supportTrain = "battle_shout improved_cleave", payoff = "cleave", gear = WARRIOR_PHYSICAL,
      support = "improved_cleave improved_slam two_handed_weapon_specialization berserker_rage enrage battle_shout booming_voice" },
    { id = "prot_counter", minRound = 2, spec = "prot", secondary = "arms", weapons = { WARRIOR_MAIN },
      equipment = "wooden_shield duelists_buckler crest_of_retribution drillborer_disk", core = "bloodrage shield_bash revenge thunder_clap deflection", train = "shield_bash revenge", supportTrain = "deflection warrior_anticipation", payoff = "shield_bash", gear = WARRIOR_AVOIDANCE,
      support = "warrior_anticipation improved_revenge one_handed_weapon_specialization improved_shield_bash intimidating_shout shield_block toughness defensive_stance" },
    { id = "prot_bleed", minRound = 2, spec = "prot", secondary = "arms", weapons = { WARRIOR_MAIN },
      equipment = "wooden_shield shaman_redbeard_crest crest_of_retribution drillborer_disk", core = "bloodrage shield_bash rend sunder_armor", train = "rend shield_bash", supportTrain = "battle_shout", payoff = "rend", gear = WARRIOR_BLOCK,
      support = "defensive_stance improved_rend deep_wounds defiance battle_shout improved_shield_bash shield_block toughness" },
  },
  HUNTER = {
    { id = "cat_focus", spec = "bm", secondary = "mm", weapons = { BOWS }, core = "rough_arrows pet_cat claw_pet feed_pet arcane_shot", train = "claw_pet arcane_shot", payoff = "claw_pet", gear = HUNTER_GEAR,
      support = "ferocity bestial_discipline spirit_bond mend_pet aspect_of_the_beast frenzy efficiency quiver" },
    { id = "scorpid_poison", spec = "surv", secondary = "bm", weapons = { BOWS }, core = "rough_arrows serpent_sting pet_scorpid claw_pet immolation_trap", train = "serpent_sting claw_pet", payoff = "serpent_sting", gear = HUNTER_GEAR,
      support = "immolation_trap frost_trap trap_mastery improved_stings spirit_bond mend_pet aspect_of_the_hawk quiver" },
    { id = "marksmanship", spec = "mm", secondary = "bm", weapons = { BOWS }, core = "rough_arrows arcane_shot multi_shot hunters_mark aimed_shot", train = "multi_shot aimed_shot", payoff = "aimed_shot", gear = HUNTER_GEAR,
      support = "efficiency mortal_shots lethal_shots concussive_shot improved_concussive_shot pet_wolf rapid_fire aspect_of_the_hawk quiver" },
    { id = "wind_serpent", minRound = 5, spec = "bm", secondary = "mm", hybrid = true, weapons = { BOWS }, core = "rough_arrows pet_wind_serpent arcane_shot claw_pet mend_pet", train = "arcane_shot claw_pet", payoff = "claw_pet",
      gear = { "thin_cloth_armor beastmaster_chest", "fine_leather_belt dreamers_belt primalists_linked_waistguard", "fine_leather_gloves dreamweave_gloves", "spritecaster_cape cloak_of_consumption", "briarwood_reed devilsaur_tooth", "songstone_of_ironforge seal_of_wrynn", "tooth_of_gnarr", "second_wind" },
      support = "feed_pet spirit_bond ferocity efficiency improved_arcane_shot bestial_discipline quiver" },
  },
  DRUID = {
    { id = "balance", spec = "balance", secondary = "resto", weapons = { STAVES }, core = "wrath moonfire starfire", train = "starfire wrath", payoff = "starfire", gear = SPELL,
      support = "improved_wrath natures_grace moonglow improved_moonfire vengeance barkskin idol_of_the_moon" },
    { id = "cat_rotation", spec = "feral", secondary = "resto", weapons = { "worn_dagger carving_knife manual_crowd_pummeler" }, core = "cat_form claw rake rip ferocious_bite", train = "claw rip ferocious_bite", payoff = "claw", gear = FERAL_GEAR,
      support = "tigers_fury blood_frenzy savage_fury omen_of_clarity rejuvenation furor" },
    { id = "bear", spec = "feral", secondary = "resto", weapons = { "worn_dagger spiked_club oak_mallet manual_crowd_pummeler warden_staff" }, core = "bear_form maul enrage_druid rejuvenation", train = "maul frenzied_regeneration", payoff = "maul",
      gear = { "thin_cloth_armor tanned_leather_jerkin feralheart_chest", "naglering seal_of_wrynn", "prospectors_cuffs bracers_of_the_eclipse", "medallion_of_grand_marshal_morris", "idol_of_brutality", "second_wind", "feralheart_head dreamwalker_head", "cape_of_the_brotherhood", "fine_leather_boots", "fine_leather_belt" },
      support = "furor frenzied_regeneration swipe demoralizing_roar barkskin healing_touch savage_fury thick_hide primal_fury bash brutal_impact" },
    { id = "restoration", spec = "resto", secondary = "balance", weapons = { "gnarled_staff walking_stick staff_of_the_blessed_seer staff_of_jordan" }, core = "rejuvenation healing_touch insect_swarm", train = "insect_swarm rejuvenation", payoff = "healing_touch", gear = HEALING,
      support = "moonfire swiftmend regrowth reflection improved_rejuvenation improved_healing_touch improved_regrowth tranquility natures_focus" },
    { id = "spell_hybrid", minRound = 4, spec = "balance", secondary = "resto", hybrid = true, weapons = { STAVES }, core = "moonfire wrath rejuvenation healing_touch insect_swarm", train = "moonfire rejuvenation", payoff = "starfire", gear = SPELL,
      support = "regrowth natures_grace moonglow reflection improved_moonfire improved_rejuvenation" },
  },
}

local ranged = ns.IsRangedWeapon

local function words(text)
  local out = {}
  for key in (text or ""):gmatch("%S+") do
    local def = ns.ItemsByKey[key]
    out[#out + 1] = def and def.stockKey or key
  end
  return out
end

local function relation(source, target)
  local score = 0
  for _, rule in ipairs(source.adjacency) do if Util.MatchDef(target, rule.match) then score = score + 2 end end
  for _, trigger in ipairs(source.triggers) do
    if trigger.on:find("adjacent", 1, true) and Util.MatchDef(target, trigger.match) then score = score + 2 end
    for _, effect in ipairs(trigger.effects) do
      if effect.target == "neighbors" and Util.MatchDef(target, effect.match)
        and ((effect.type ~= "cdr" and effect.type ~= "cast") or target.use) then score = score + 2 end
    end
  end
  return score
end

local function hasSpatialRules(def)
  for _, rule in ipairs(ns.EffectRules(def)) do if rule.side or rule.corners or rule.empty or rule.coating then return true end end
  return false
end

local function spatialLayoutScore(grid, probe, formAttack)
  local score, ownLink = 0, false
  local function active(p)
    local def = ns.Items[p.id]
    return not (formAttack and def.kind == "weapon" and not ranged(def))
  end
  local inactive = {}
  for _, p in ipairs(grid.items) do if not active(p) then inactive[p.uid] = true end end
  local coatings = ns.ResolveCoatings(grid, nil, inactive)
  for _, source in ipairs(grid.items) do
    if active(source) then
      local def = ns.Items[source.id]
      for _, rule in ipairs(ns.EffectRules(def)) do
        local matches = 0
        if rule.empty then
          matches = #grid:EffectCells(source, rule)
          if rule.once then matches = math.min(1, matches) end
        elseif not rule.inside then
          local recipients = grid:EffectNeighbors(source, rule)
          table.sort(recipients, Util.PlacementLess)
          for _, recipient in ipairs(recipients) do
            if active(recipient) and Util.MatchDef(ns.Items[recipient.id], rule.match)
              and (not rule.coating or coatings[source.uid] and coatings[source.uid][recipient.uid]) then
              matches = matches + 1
              if rule.once then break end
            end
          end
        end
        score = score + matches * 16
        if source == probe and matches > 0 then ownLink = true end
      end
    end
  end
  return score, ownLink
end

local function placementProbe(grid, def, x, y, rot)
  local probe = { id = def.id, uid = grid.nextUid, x = x, y = y, rot = rot, cells = {} }
  local view = setmetatable({ W = grid.W, H = grid.H, cells = grid.cells, occ = {}, items = {}, bags = grid.bags }, getmetatable(grid))
  for key, p in pairs(grid.occ) do view.occ[key] = p end
  for _, p in ipairs(grid.items) do view.items[#view.items + 1] = p end
  for _, cell in ipairs(ns.Grid.Footprint(def, x, y, rot)) do
    local key = ns.Grid.Key(cell[1], cell[2])
    probe.cells[#probe.cells + 1], view.occ[key] = key, probe
  end
  view.items[#view.items + 1] = probe
  return view, probe
end



function Bots.PlacementScore(grid, def, x, y, rot)
  local formAttack = false
  for _, p in ipairs(grid.items) do if ns.Items[p.id].replacesWeapon then formAttack = true break end end
  local before = spatialLayoutScore(grid, nil, formAttack)
  local view, probe = placementProbe(grid, def, x, y, rot)
  local after, ownLink = spatialLayoutScore(view, probe, formAttack)
  return after - before, ownLink
end

local function placeNear(grid, def, rng)
  local best, choices, evaluated = nil, {}, 0
  local formAttack = false
  for _, p in ipairs(grid.items) do if ns.Items[p.id].replacesWeapon then formAttack = true break end end
  local spatial = hasSpatialRules(def)
  if not spatial then
    for _, p in ipairs(grid.items) do if hasSpatialRules(ns.Items[p.id]) then spatial = true break end end
  end
  local linked, autonomous = #def.adjacency > 0, false
  for _, trigger in ipairs(def.triggers) do
    local adjacent = trigger.on:find("adjacent", 1, true)
    if adjacent then linked = true end
    for _, effect in ipairs(trigger.effects) do
      if effect.target == "neighbors" then linked = true elseif not adjacent then autonomous = true end
    end
  end
  local requireLink = linked and not autonomous and not def.use and not next(def.stats)
  local cells = grid:CellList()
  rng:Shuffle(cells)
  for _, cell in ipairs(cells) do
    if evaluated >= 48 then break end
    for _, rot in ipairs(def.distinctRots) do
      if evaluated >= 48 then break end
      local x, y = cell[1], cell[2]
      if grid:CanPlaceItem(def, x, y, rot) then
        evaluated = evaluated + 1
        local probe = { id = def.id, uid = grid.nextUid, x = x, y = y, rot = rot, cells = {} }
        for _, c in ipairs(ns.Grid.Footprint(def, x, y, rot)) do probe.cells[#probe.cells + 1] = ns.Grid.Key(c[1], c[2]) end
        local neighbors = grid:EffectNeighbors(probe)
        local score, ownLink = 0, false
        if spatial then score, ownLink = Bots.PlacementScore(grid, def, x, y, rot) end
        for _, other in ipairs(neighbors) do
          local otherDef = ns.Items[other.id]
          local inactive = formAttack and otherDef.kind == "weapon" and not ranged(otherDef)
          if not spatial and not inactive then
            local forward = relation(def, otherDef)
            score = score + (forward + relation(otherDef, def)) * 8
            if forward > 0 then ownLink = true end
          end
          score = score + 0.3
        end
        score = score - (math.abs(x - grid.home.x) + math.abs(y - grid.home.y)) * 0.02
        if not requireLink or ownLink then
          if not best or score > best then best = score end
          choices[#choices + 1] = { x = x, y = y, rot = rot, score = score }
        end
      end
    end
  end
  if not best then return nil end
  table.sort(choices, function(a, b)
    if a.score ~= b.score then return a.score > b.score end
    if a.y ~= b.y then return a.y < b.y end
    if a.x ~= b.x then return a.x < b.x end
    return a.rot < b.rot
  end)
  local count = 1
  while count < math.min(4, #choices) and choices[count + 1].score >= best - 1 do count = count + 1 end
  local chosen = choices[rng:Range(1, count)]
  return grid:PlaceItem(def, chosen.x, chosen.y, chosen.rot)
end

local function flagsFor(grid)
  local flags = {}
  for _, p in ipairs(grid.items) do
    local def = ns.Items[p.id]
    local provides = type(def.provides) == "table" and def.provides or { def.provides }
    for _, flag in ipairs(provides) do flags[flag] = true end
    if def.kind == "weapon" then
      flags.weapon = true
      flags[ranged(def) and "ranged" or "melee"] = true
      if def.weaponType then flags[def.weaponType] = true end
      if not ranged(def) and def.hands == 2 then flags.twohand = true end
    end
    if def.kind == "shield" then flags.shield = true end
    if def.kind == "pet" then flags.pet = true end
    if def.kind == "ammo" then flags.ammo = true end
    for resource in pairs(def.grants or {}) do flags[resource] = true end
  end
  return flags
end

function Bots.Generate(classKey, round, seed, archetypeId, firstRun)
  local rng = Util.NewRNG(seed)
  local class = assert(ns.GetClass(classKey), "Unknown bot class.")
  local plans, availablePlans, allowed = {}, {}, {}
  for _, def in ipairs(ns.GetShopPool(classKey, round)) do allowed[def.id] = true end
  for _, candidate in ipairs(Bots.ARCHETYPES[classKey] or {}) do
    if (candidate.minRound or 1) <= round and (not archetypeId or candidate.id == archetypeId) then
      plans[#plans + 1] = candidate
      for _, key in ipairs(words(candidate.core .. " " .. candidate.support)) do
        local def = ns.ItemsByKey[key]
        if def and allowed[def.id] and def.kind == "ability" then availablePlans[#availablePlans + 1] = candidate break end
      end
    end
  end
  local planRng = Util.NewRNG(Util.Hash32("bot:" .. tostring(seed) .. ":" .. tostring(round)))
  local plan = assert(planRng:Pick(#availablePlans > 0 and availablePlans or plans), "No available bot archetype.")
  local payoff = ns.ItemsByKey[plan.payoff]
  local payoffRound = payoff.minRound + (payoff.quality >= 3 and planRng:Range(0, 2) or 0)
  local budget = math.floor(ns.Economy.CumulativeGold(round) * (0.77 + rng:Next() * 0.12 - 0.10 * math.max(0, 8 - round) / 7)) + ns.StarterValue(class)
  if firstRun then
    local starterValue = ns.StarterValue(class)
    budget = starterValue + math.floor((budget - starterValue) * Bots.FIRST_RUN_BUDGET_SCALE)
  end
  local gold, grid = budget, ns.Grid.New()
  local desiredRank = round >= 10 + rng:Range(0, 3) and rng:Chance(65) and 3 or round >= 4 + rng:Range(0, 3) and 2 or 1
  local trainingBase = ns.ItemsByKey[words(plan.train)[1]]
  local curatedTraining = trainingBase and trainingBase.rankProfile ~= nil
  if classKey == "WARRIOR" or curatedTraining then
    local base = trainingBase
    desiredRank = 1
    for rank = 2, ns.Ranks.MaxRank(base) do
      local target = ns.Ranks.Definition(base, rank)
      if target and rank <= ns.Ranks.TrainableMaxRank(base) and target.minRound <= round then desiredRank = rank end
    end
    if desiredRank > 2 and rng:Chance(25) then desiredRank = desiredRank - 1 end
  end
  local supportLimit = math.min(6, 1 + math.floor(round / 3))
  local gear = Util.ShallowCopy(plan.gear)
  local function eligible(def)
    return def and def.minRound <= round and def.quality < 5 and ns.ItemAllowedForClass(def, classKey)
      and (allowed[def.id] or def.starter) and not def.craftable
      and ((def.baseKey or def.key) ~= plan.payoff or round >= payoffRound)
  end
  local function rollQuality(atRound, category)
    local entries = {}
    for quality, weight in ipairs(ns.Economy.RarityOdds(atRound, category)) do
      entries[#entries + 1] = { value = quality, weight = weight }
    end
    return rng:PickWeighted(entries) or 1
  end
  local function choose(text, weapon)
    local candidates, offered = {}, {}
    local owned = ns.Economy.StockCounts(grid)
    for _, key in ipairs(words(text)) do
      local def = ns.ItemsByKey[key]
      if eligible(def) and ns.Economy.AvailableStock(def, owned) > 0 and def.cost <= gold and (not weapon or def.cost <= math.max(4, budget * 0.19)) then
        candidates[#candidates + 1] = def
      end
    end
    if #candidates == 0 then return nil, 0 end
    local category = ns.Economy.ShopCategory(candidates[1])
    for atRound = category == "gear" and 1 or round, round do
      local quality = rollQuality(atRound, category)
      local highest = 0
      for _, def in ipairs(candidates) do
        if def.minRound <= atRound and def.quality <= quality then highest = math.max(highest, def.quality) end
      end
      for _, def in ipairs(candidates) do
        if def.minRound <= atRound and def.quality == highest then offered[def.id] = def end
      end
    end
    local highest, choices = 0, {}
    for _, def in pairs(offered) do highest = math.max(highest, def.quality) end
    for _, def in ipairs(candidates) do if offered[def.id] and def.quality == highest then choices[#choices + 1] = def end end
    return rng:Pick(choices), highest, offered
  end
  local function addBag(reserve)
    reserve = reserve or 0
    local choices, highest = {}, 0
    local quality = rollQuality(round, "gear")
    local keys = round >= 9 and "linen_bag red_woolen_bag small_silk_pack runecloth_bag mooncloth_bag"
      or round >= 6 and "linen_bag woolen_bag red_woolen_bag small_silk_pack runecloth_bag"
      or "linen_bag woolen_bag red_woolen_bag"
    local counts = ns.Economy.StockCounts(grid)
    for _, key in ipairs(words(keys)) do
      local def = ns.ItemsByKey[key]
      if eligible(def) and def.quality <= quality and def.cost + reserve <= gold and ns.Economy.AvailableStock(def, counts) > 0 then
        local x, y, rot = grid:FindBagFit(def)
        if x then
          highest = math.max(highest, def.quality)
          choices[#choices + 1] = { def = def, x = x, y = y, rot = rot }
        end
      end
    end
    if #grid.bags >= math.min(7, 1 + math.floor(round / 2)) then return false end
    local matching = {}
    for _, choice in ipairs(choices) do if choice.def.quality == highest then matching[#matching + 1] = choice end end
    local selected = rng:Pick(matching)
    if not selected then return false end
    assert(grid:PlaceBag(selected.def, selected.x, selected.y, selected.rot))
    gold = gold - selected.def.cost
    return true
  end
  local supportGear = {}
  local function tryAdd(def, rarityChecked)
    if not eligible(def) or def.cost > gold then return false end
    if not rarityChecked and ns.Economy.ShopCategory(def) == "gear" then
      if supportGear[def.id] == nil then
        supportGear[def.id] = false
        for atRound = def.minRound, round do
          if def.quality <= rollQuality(atRound, "gear") then supportGear[def.id] = true break end
        end
      end
      if not supportGear[def.id] then return false end
    end
    local counts = ns.Economy.StockCounts(grid)
    if ns.Economy.AvailableStock(def, counts) <= 0 or not ns.Economy.ShopRequirementsMet(def, counts) then return false end
    local flags = flagsFor(grid)
    if def.key == "quiver" and (not flags.ranged or not flags.ammo) then return false end
    if def.key == "devilsaur_tooth" and not flags.pet then return false end
    if def.key == "furor" then
      local healed = false
      for _, p in ipairs(grid.items) do if ns.Items[p.id].tagSet.heal then healed = true break end end
      if not healed then return false end
    end
    local use = def.use
    if use then
      local needs = type(use.requires) == "table" and use.requires or { use.requires }
      for _, flag in ipairs(needs) do if not flags[flag] then return false end end
      if use.resource and not (class.resources and class.resources[use.resource]) and not flags[use.resource] then return false end
    end
    if def.kind == "weapon" then
      local melee, hasShield = 0, false
      for _, p in ipairs(grid.items) do
        local other = ns.Items[p.id]
        if other.kind == "shield" then hasShield = true end
        if other.kind == "weapon" and ranged(other) == ranged(def) then
          if ranged(def) or other.hands == 2 or def.hands == 2 then return false end
          melee = melee + 1
        end
      end
      if not ranged(def) and (hasShield and (melee >= 1 or def.hands == 2) or melee >= (class.dualWield and 2 or 1)) then return false end
    elseif def.kind == "shield" then
      local count = 0
      for _, p in ipairs(grid.items) do
        local other = ns.Items[p.id]
        if other.kind == "weapon" and not ranged(other) then if other.hands == 2 then return false end count = count + 1 end
      end
      if count > 1 then return false end
    end
    if not grid:CanEquip(def) then return false end
    if def.set and ns.Sets[def.set] and ns.Sets[def.set].bonuses[6] then
      local pieces = 0
      for _, placement in ipairs(grid.items) do if ns.Items[placement.id].set == def.set then pieces = pieces + 1 end end
      if pieces >= 5 then return false end
    end
    local p = placeNear(grid, def, rng)
    if not p and gold >= def.cost + 1 then
      local oldBags = #grid.bags
      if addBag(def.cost) and def.cost <= gold then p = placeNear(grid, def, rng) end
      if not p and #grid.bags > oldBags and addBag(def.cost) and def.cost <= gold then p = placeNear(grid, def, rng) end
    end
    if not p then return false end
    gold = gold - def.cost
    return true
  end
  local function add(text, weapon)
    local candidates = words(text)
    local def, quality, offered = choose(text, weapon)
    if def and tryAdd(def, true) then return true end
    for rarity = quality, 1, -1 do
      for _, key in ipairs(candidates) do
        local fallback = ns.ItemsByKey[key]
        if fallback and fallback.quality == rarity and offered[fallback.id] and tryAdd(fallback, true) then return true end
      end
    end
    return false
  end
  for _, options in ipairs(plan.weapons) do add(options, true) end
  if plan.equipment then add(plan.equipment) end
  for _, key in ipairs(words(plan.core)) do
    if key == "rough_arrows" then add("rough_arrows razor_arrows thorium_headed_arrows ice_threaded_arrows")
    else tryAdd(ns.ItemsByKey[key]) end
  end
  for index = 1, math.min(2, #gear) do add(gear[index]) end
  local trainingSpent = 0
  local function train(key, rank)
    for _, p in ipairs(grid.items) do
      local current = ns.Items[p.id]
      if (current.baseKey or current.key) == key then
        local target = ns.Ranks.Definition(current, rank)
        local price = ns.Ranks.TrainingCost(current, rank)
        if target and (current.rank or 1) + 1 == rank and rank <= ns.Ranks.TrainableMaxRank(current)
          and target.minRound <= round and price <= gold then
          p.id, gold = target.id, gold - price
          trainingSpent = trainingSpent + price
          return true
        end
      end
    end
    return false
  end
  local training = words(plan.train)
  for rank = 2, desiredRank do if not train(training[1], rank) then break end end
  local support = words(plan.support)
  rng:Shuffle(support)
  local bought = 0
  for pass = 1, 2 do
    for _, key in ipairs(support) do
      if bought < supportLimit and tryAdd(ns.ItemsByKey[key]) then bought = bought + 1 end
    end
  end
  local mainOwned = false
  for _, p in ipairs(grid.items) do
    local def = ns.Items[p.id]
    if (def.baseKey or def.key) == training[1] then mainOwned = true break end
  end
  if not mainOwned and desiredRank >= 2 then
    for _, p in ipairs(grid.items) do
      local def = ns.Items[p.id]
      if def.rankable and train(def.baseKey or def.key, 2) then break end
    end
  end
  local remainingGear = {}
  for index = 3, #gear do remainingGear[#remainingGear + 1] = gear[index] end
  rng:Shuffle(remainingGear)
  for _, options in ipairs(remainingGear) do if rng:Chance(88) then add(options) end end
  if classKey == "WARRIOR" or curatedTraining then
    if round >= 6 and training[2] and rng:Chance(55) and train(training[2], 2) and round >= 12 and rng:Chance(35) then train(training[2], 3) end
    if round >= 7 and rng:Chance(60) then
      for _, key in ipairs(words(plan.supportTrain)) do if train(key, 2) then break end end
    end



    if round >= 10 then
      local function finishTraining(key)
        for _, p in ipairs(grid.items) do
          local def = ns.Items[p.id]
          if (def.baseKey or def.key) == key then
            for rank = (def.rank or 1) + 1, ns.Ranks.MaxRank(def) do
              if not train(key, rank) then break end
            end
            return true
          end
        end
        return false
      end
      for _, key in ipairs(training) do finishTraining(key) end
      for _, key in ipairs(words(plan.supportTrain)) do if finishTraining(key) then break end end
    end
  elseif round >= 10 and rng:Chance(35) and training[2] then train(training[2], 2) end
  local talents = ns.Mastery.Empty(classKey)
  local points, primary = ns.Mastery.Budget(round), ns.Mastery.Budget(round)
  local counts = ns.Economy.StockCounts(grid)
  local function owns(key) local def = ns.ItemsByKey[key] return def and (counts[ns.Economy.StockKey(def)] or 0) > 0 end
  if plan.hybrid then primary = math.min(5, points) elseif points > 8 then primary = 8 end
  if primary >= 8 and not owns(plan.payoff) then primary = 7 end
  local secondaryOwned = false
  for _, p in ipairs(grid.items) do if ns.Mastery.Spec(ns.Items[p.id]) == plan.secondary then secondaryOwned = true break end end
  if not secondaryOwned and owns(plan.payoff) then primary = points end
  talents[plan.spec] = primary
  talents[plan.secondary] = points - primary
  local completed = round - 1
  local lossCap = completed >= ns.Economy.MAX_WINS + ns.Economy.MAX_LOSSES and ns.Economy.MAX_LOSSES or ns.Economy.MAX_LOSSES - 1
  local losses = rng:Range(0, math.min(lossCap, completed))
  local wins = completed - losses
  local bags, items, home = grid:Serialize()
  return {
    v = ns.PROTOCOL_VERSION, d = ns.DATA_VERSION, c = class.id, r = round, w = wins, l = losses,
    s = Util.Now(), n = rng:Pick(Bots.NAMES), g = bags, i = items, b = home, p = ns.Mastery.Pack(classKey, talents), bot = true,
  }, grid, { archetype = plan.id, budget = budget, spent = budget - gold, remaining = gold, trainingSpent = trainingSpent }
end

function Bots.Opponent(round, seed, firstRun)
  local rng = Util.NewRNG(seed)
  local class = rng:Pick(ns.PlayableClasses())
  return Bots.Generate(class.key, round, seed, nil, firstRun)
end
