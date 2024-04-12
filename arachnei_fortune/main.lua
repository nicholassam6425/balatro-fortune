------------------
-- dependencies --
local joker = require("joker")
local consumable = require("consumable")
------------------

----------------------
-- add luck to game --
local game_start_run = Game.start_run
function Game:start_run(args)
    game_start_run(self, args)
    if not G.GAME.arachnei_fortune then
        G.GAME.arachnei_fortune = {luck=10}
    end
end

------------------------
-- generic loot pools --
local type_pools = {
    -- suits
    diamond = {"j_greedy_joker", "j_rough_gem"},
    heart = {"j_lusty_joker", "j_bloodstone"},
    spade = {"j_wrathful_joker", "j_blackboard", "j_arrowhead"},
    club = {"j_gluttenous_joker", "j_blackboard", "j_onyx_agate"},
    multisuit = {"j_ancient", "j_castle", "j_smeared", "j_flower_pot", "j_seeing_double"},

    -- hand types
    solo_hand_type = {"j_supernova", "j_space", "j_card_sharp"},
    high_card = {"j_half", "j_mime", "j_card_sharp"},
    pair = {"j_jolly", "j_sly", "j_half", "j_mime", "j_duo", "j_card_sharp"},
    two_pair = {"j_square", "j_trousers", "j_card_sharp"},
    three_oak = {"j_zany", "j_wily", "j_jolly", "j_sly", "j_half", "j_trio"},
    four_oak = {"j_mad", "j_clever", "j_zany", "j_wily", "j_jolly", "j_sly", "j_dna", "j_square", "j_family"},
    straight = {"j_runner", "j_four_fingers", "j_shortcut", "j_crazy", "j_devious", "j_superposition", "j_order"},
    flush = {"j_four_fingers", "j_droll", "j_crafty", "j_smeared", "j_tribe"},
    straight_flush = {"j_seance"},

    -- ranks
    aces = {"j_fibonacci", "j_odd_todd", "j_scholar", "j_ride_the_bus"},
    twos = {"j_fibonacci", "j_hack", "j_even_steven", "j_ride_the_bus", "j_wee"},
    threes = {"j_fibonacci", "j_hack", "j_odd_todd", "j_ride_the_bus"},
    fours = {"j_hack", "j_even_steven", "j_ride_the_bus"},
    fives = {"j_fibonacci", "j_hack", "j_odd_todd", "j_ride_the_bus", "j_walkie_talkie"},
    sixs = {"j_even_steven", "j_ride_the_bus", "j_sixth_sense"},
    sevens = {"j_odd_todd", "j_ride_the_bus"},
    eights = {"j_8_ball", "j_fibonacci", "j_even_steven", "j_ride_the_bus"},
    nines = {"j_odd_todd", "j_ride_the_bus", "j_cloud_9"},
    tens = {"j_even_steven", "j_ride_the_bus", "j_walkie_talkie"},
    jack = {"j_scary_face", "j_pareidolia", "j_business", "j_faceless", "j_photograph", "j_reserved_parking", "j_smiley", "j_sock_and_buskin", "j_hit_the_road"},
    queen = {"j_scary_face", "j_pareidolia", "j_business", "j_faceless", "j_photograph", "j_reserved_parking", "j_smiley", "j_sock_and_buskin", "j_shoot_the_moon"},
    king = {"j_scary_face", "j_pareidolia", "j_business", "j_faceless", "j_baron", "j_photograph", "j_reserved_parking", "j_smiley", "j_sock_and_buskin"},

    -- consumeables
    planets = {"j_8_ball", "j_constellation", "j_satellite", "j_astronomer"},
    spectrals = {"j_sixth_sense", "j_seance"},
    tarots = {"j_vagabond", "j_hallucination", "j_fortune_teller", "j_cartomancer"},

    -- 'stats'
    cash = {"j_business", "j_faceless", "j_todo_list", "j_cloud_9", "j_rocket", "j_mail", "j_to_the_moon", "j_golden", "j_bull", "j_trading", "j_ticket", "j_rough_gem", "j_matador", "j_satellite", "j_reserved_parking", "j_bootstraps"},
    low_cash = {"j_credit_card", "j_vagabond"},
    discards = {"j_banner",  "j_faceless", "j_drunkard", "j_merry_andy", "j_hit_the_road", "j_burnt"},
    low_discards = {"j_mystic_summit", "j_burglar", "j_splash", "j_green_joker", "j_ramen", "j_delayed_grat",},
    hands = {"j_loyalty_card", "j_burglar", "j_hiker", "j_vagabond"},
    low_hands = {"j_troubadour", "j_merry_andy"},
    hand_size = {"j_turtle_bean", "j_juggler", "j_troubadour"},
    low_hand_size = {"j_merry_andy", "j_stuntman"},

    -- enhancements
    glass_card = {"j_glass", "j_dna"},
    lucky_card = {"j_lucky_cat", "j_dna"},
    stone_card = {"j_marble", "j_stone"},
    gold_card = {"j_midas_mask", "j_ticket"},
    steel_card = {"j_steel_joker", "j_dna"},

    -- gameplay styles (?)
    final_hand = {"j_dusk", "j_acrobat"},
    held_in_hand = {"j_mime", "j_raised_fist", "j_steel_joker", "j_baron", "j_shoot_the_moon", "j_reserved_parking"},
    first_played_card = {"j_photograph", "j_hanging_chad"},
    
    -- deck size
    small_deck = {"j_erosion", "j_sixth_sense", "j_trading"},
    deck_bloat = {"j_marble", "j_dna", "j_blue_joker", "j_certificate", "j_hologram"},

    -- shop related
    rerolls = {"j_chaos", "j_flash", "j_ring_master"},
    sell_value = {"j_ceremonial", "j_egg", "j_gift", "j_swashbuckler"},
    packs = {"j_red_card", "j_hallucination"},

    -- revolves around 1 joker
    j_oops = {"j_oops", "j_business", "j_space", "j_reserved_parking", "j_bloodstone", "j_glass"},
    j_riff_raff = {"j_riff_raff", "j_ceremonial", "j_madness", "j_campfire"},
    j_vampire = {"j_vampire", "j_marble", "j_midas_mask", "j_certificate"},
    j_drivers_license = {"j_drivers_license", "j_marble", "j_midas_mask", "j_certificate"},

    -- food
    food = {"j_gros_michel", "j_ice_cream", "j_turtle_bean", "j_popcorn", "j_ramen", "j_selzer"},

    -- unique combo format: uniq_SpaceRequired_id
    -- unique duo combos
    uniq_2_1 = {"j_riff_raff", "j_abstract"}, -- abstract has counter-synergy with other riff-raff cards
    uniq_2_2 = {"j_oops", "j_oops"},
    uniq_2_3 = {"j_stuntman", "j_stuntman"},
    uniq_2_4 = {"j_gros_michel", "j_gros_michel"},
    uniq_2_5 = {"j_sixth_sense", "j_dna"},
    uniq_2_7 = {"j_juggler", "j_drunkard"},

    -- unique trio combos
    -- uniq_3_1 = {},

    -- solo jokers for 1 joker slot
    uniq_1_1 = {"j_blueprint"},
    uniq_1_2 = {"j_brainstorm"},
    uniq_1_3 = {"j_baron"},
    uniq_1_4 = {"j_card_sharp"},
    uniq_1_5 = {"j_campfire", { joker="j_luchador", edition={negative=true} }},
    uniq_1_6 = {"j_abstract", { rarity=1, edition={negative=true} }},
    uniq_1_7 = {"j_mime", { consumeable={id="c_chariot", set="Tarot"}, edition={negative=true} }},
    uniq_1_8 = {"j_steel_joker", { consumeable={id="c_chariot", set="Tarot"}, edition={negative=true} }},
    uniq_1_9 = {"j_lucky_cat", { consumeable={id="c_magician", set="Tarot"}, edition={negative=true} }},
    uniq_1_10 = {"j_oops", { consumeable={id="c_wheel_of_fortune", set="Tarot"}, edition={negative=true} }},
    uniq_1_11 = {"j_fortune_teller", { consumeable={id="c_fool", set="Tarot"}, edition={negative=true} }, { consumeable={id="c_fool", set="Tarot"}, edition={negative=true} }}
}

----------------------
-- helper functions --

-- create cards from loot pool format
local function create_joker(e)
    local j = nil
    if type(e) == "table" then
        if e.seed then
            math.randomseed(pseudoseed(e.seed))
            for i=1, math.random(1,5) do
                math.random()
            end
        end
        -- forced key or rarity or fully random
        if e.joker then
            j = create_card("Joker", G.jokers, nil, nil, true, nil, e.joker)
        elseif e.rarity then
            j = create_card("Joker", G.jokers, nil, e.rarity, true, false, nil)
        elseif e.consumeable then
            j = create_card(e.consumeable.set, G.consumeables, nil, nil, true, nil, e.consumeable.id)
        else
            j = create_card("Joker", G.jokers, nil, nil, true, false, nil)
        end
        -- add edition if defined
        if e.edition then
            j:set_edition(e.edition, true)
        end
        -- add eternal if defined
        if e.eternal then
            j:set_eternal(true)
        end
    elseif type(e) == "string" then
        j = create_card("Joker", G.jokers, nil, nil, true, nil, e)
    end
    j:add_to_deck()
    if e.consumeable then
        G.consumeables:emplace(j)
    else
        G.jokers:emplace(j)
    end
    
    return j
end

-- take a loot pool and # required cards
-- return a secondary loot pool that can meet # requirement
local function parse_primary_pool(e, num_card)
    if not num_card then return pseudorandom_element(e) end
    if num_card > 5 then logger:warn("parsing fortune pool with >5 space") end
    local temp_pool = {}
    if num_card == 1 then -- if no space, use solo unique pool
        for k, pool in pairs(e) do
            if k:find("uniq_1") then
                temp_pool[k] = pool
            end
        end
    else
        for k, pool in pairs(e) do
            -- if uniq is not found, then only go off of num_card and size of secondary pool
            -- if uniq is found, then also check if num_card == uniq size
            if (#pool >= num_card and not k:find("uniq")) or (#pool >= num_card and tonumber(k:sub(6,6)) == num_card) then
                temp_pool[k] = pool
            end
        end
    end
    return pseudorandom_element(temp_pool)
end

-- take a table of card objects, and add editions to eligible candidates
local function add_editions(cards, edition, num)
    -- find candidates
    local candidates = {size=0} -- did you know? if you make a set with numerical keys, you have to manually track the size!
    for i, v in ipairs(cards) do
        if v.edition == nil then
            candidates[candidates.size+1] = v
            candidates.size = candidates.size + 1
        end
    end
    if candidates.size < num then -- if insufficient candidates, replace a holo/foil/poly edition
        logger:debug("insufficient candidates, replacing an existing condition")
        for i, v in ipairs(cards) do
            if v.edition and (v.edition.holo or v.edition.foil or v.edition.polychrome) then
                candidates[candidates.size+1] = v
                candidates.size = candidates.size + 1
            end
        end
    end
    -- swap editions    
    local selected = {}
    math.random() -- call math.random so that its actually (pseudo)random
    for i=1, math.min(num, candidates.size) do
        local temp = nil
        repeat
            temp = math.random(1, candidates.size)
        until selected[temp] == nil
        selected[temp] = true
    end
    for k, _ in pairs(selected) do
        candidates[k]:set_edition(edition)
    end
end

local function cashout(card, context)
    local joker_space = G.jokers.config.card_limit -  #G.jokers.cards + 1
    local consumable_space = G.consumeables.config.card_limit - #G.consumeables.cards
----------------------------
------ 0 - 5 hand cashout --
----------------------------
    if G.GAME.arachnei_fortune.luck <= 5 then
        local loot_pool = pseudorandom("ftcashout1", 1, 100)
        -- 5 eternal jimbos (me & the boys) 20%
        if loot_pool < 20 then
            for i=1, 5 do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.4,
                    func = function()
                        local jimbo = create_joker({joker="j_joker", eternal=true})
                        jimbo:juice_up(0.3, 0.5)
                        play_sound('voice'..i, nil, 0.6)
                        return true
                    end
                }))
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_fivejimbo'), delay = 0.1})
            end
        -- lose all money, gain eternal burglar (burglar steals ur money) 15%
        elseif loot_pool < 35 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(-G.GAME.dollars, true)
                    play_sound('timpani', nil, 0.6)
                    delay(0.3)
                    local burglar = create_joker({joker="j_burglar", eternal=true})
                    burglar:juice_up(0.3, 0.5)
                    return true 
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_robbed')})
        -- permanently lose all discards, gain delayed gratitude (oops! no discards!) 15%
        elseif loot_pool < 50 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.GAME.round_resets.discards = 0
                    ease_discard(-G.GAME.current_round.discards_left)
                    delay(0.3)
                    local delayed = create_joker({joker="j_delayed_grat", eternal=true})
                    delayed:juice_up(0.3, 0.5)
                    return true 
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_oopsdiscards'), delay = 1.2})
        -- +2 ante (tripped forward) 15%
        elseif loot_pool < 65 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                        ease_ante(2)
                        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante or G.GAME.round_resets.ante
                        G.GAME.round_resets.blind_ante = G.GAME.round_resets.blind_ante + 2
                    return true 
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_tripped')})
            -- eternal egg (sup) 10%
        elseif loot_pool < 75 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local egg = create_joker({joker="j_egg", eternal=true})
                    egg:juice_up(0.3, 0.5)
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_egg')})
        -- set #hands to 1, gain eternal dna (the needle) 10%
        elseif loot_pool < 85 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    G.GAME.round_resets.hands = 1
                    ease_hands_played(1-G.GAME.current_round.hands_left)
                    local dna = create_joker({joker="j_dna", eternal=true})
                    dna:juice_up(0.3, 0.5)
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_needle')})
        -- eternal pareidolia, eternal ride the bus (average american public transit) 15%
        else
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0,
                func = function()
                    local parei = create_joker({joker="j_pareidolia", eternal=true})
                    parei:juice_up(0.3, 0.5)
                    return true
                end
            }))
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local bus = create_joker({joker="j_ride_the_bus", eternal=true})
                    bus:juice_up(0.3, 0.5)
                    return true
                end
            }))
            card_eval_status_text(card, 'extra', nil, nil, nil, {message = localize('k_arachnei_ftc_badbus')})
        end
-----------------------------
------ 6 - 10 hand cashout --
-----------------------------
    elseif G.GAME.arachnei_fortune.luck <= 10 then
        -- random rare joker
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.2,
            func = function()
                local card = create_joker({rarity=3, seed="ftcashout2"})
                card:juice_up(0.3, 0.5)

                return true
            end
        }))
------------------------------
------ 11 - 16 hand cashout --
------------------------------
    elseif G.GAME.arachnei_fortune.luck <= 16 then -- baseline: duo combo 
        local num_cards = math.min(2, joker_space)
        local lost_cards = 2 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        if key:find("uniq") then
            for i=1, #pool do
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        local card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        elseif key:find("j_") then -- if pool based on joker
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    for i=2, num_cards do
                        local id = pseudorandom_element(pool)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        else
            for i=1, num_cards do
                local id = pseudorandom_element(pool)
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        local card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        return true
                    end
                }))
            end
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 4)
                    return true
                end
            }))
        end

------------------------------
------ 17 - 22 hand cashout --
------------------------------
    elseif G.GAME.arachnei_fortune.luck <= 22 then -- baseline: duo combo +1 neg
        joker_space = joker_space + 1
        local num_cards = math.min(2, joker_space)
        local lost_cards = 2 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        local temp = {}
        if key:find("uniq") then
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, #pool do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 1)
                    return true
                end
            }))
        elseif key:find("j_") then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    table.insert(temp, card)
                    for i=2, num_cards do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp,card)
                    end
                    add_editions(temp, {negative=true}, 1)
                    return true
                end
            }))
        else
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, num_cards do
                        local id = pseudorandom_element(pool, i)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 1)
                    return true
                end
            }))
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 4)
                    return true
                end
            }))
        end
-------------------------
------ 23 - 29 cashout --
-------------------------
    elseif G.GAME.arachnei_fortune.luck <= 29 then -- baseline: duo combo +2 neg
        joker_space = joker_space + 2
        local num_cards = math.min(2, joker_space)
        local lost_cards = 2 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        local temp = {}
        if key:find("uniq") then
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, #pool do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 2)
                    return true
                end
            }))
        elseif key:find("j_") then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    table.insert(temp, card)
                    for i=2, num_cards do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp,card)
                    end
                    add_editions(temp, {negative=true}, 1)
                    return true
                end
            }))
        else
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, num_cards do
                        local id = pseudorandom_element(pool, i)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 2)
                    return true
                end
            }))
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 5)
                    return true
                end
            }))
        end
---------------------
-- 30 - 36 cashout --
---------------------
    elseif G.GAME.arachnei_fortune.luck <= 36 then -- baseline: trio combo +2 neg
        joker_space = joker_space + 2
        local num_cards = math.min(3, joker_space)
        local lost_cards = 3 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        local temp = {}
        if key:find("uniq") then
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, #pool do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 2)
                    return true
                end
            }))
        elseif key:find("j_") then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    table.insert(temp, card)
                    for i=2, num_cards do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp,card)
                    end
                    add_editions(temp, {negative=true}, 1)
                    return true
                end
            }))
        else
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, num_cards do
                        local id = pseudorandom_element(pool, i)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 2)
                    return true
                end
            }))
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 6)
                    return true
                end
            }))
        end
---------------------
-- 37 - 44 cashout --
---------------------
    elseif G.GAME.arachnei_fortune.luck <= 44 then -- baseline: trio combo +3 neg
        joker_space = joker_space + 3
        local num_cards = math.min(3, joker_space)
        local lost_cards = 3 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        local temp = {}
        if key:find("uniq") then
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, #pool do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 3)
                    return true
                end
            }))
        elseif key:find("j_") then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    table.insert(temp, card)
                    for i=2, num_cards do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp,card)
                    end
                    add_editions(temp, {negative=true}, 3)
                    return true
                end
            }))
        else
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, num_cards do
                        local id = pseudorandom_element(pool, i)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 3)
                    return true
                end
            }))
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 9)
                    return true
                end
            }))
        end
    elseif G.GAME.arachnei_fortune.luck <= 52 then -- baseline: quartet combo +3 neg
        joker_space = joker_space + 3
        local num_cards = math.min(4, joker_space)
        local lost_cards = 4 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        local temp = {}
        if key:find("uniq") then
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, #pool do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 3)
                    return true
                end
            }))
        elseif key:find("j_") then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    table.insert(temp, card)
                    for i=2, num_cards do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp,card)
                    end
                    add_editions(temp, {negative=true}, 3)
                    return true
                end
            }))
        else
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, num_cards do
                        local id = pseudorandom_element(pool, i)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 3)
                    return true
                end
            }))
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 7)
                    return true
                end
            }))
        end
    elseif G.GAME.arachnei_fortune.luck <= 60 then -- baseline: quartet combo +4 neg
        joker_space = joker_space + 4
        local num_cards = math.min(4, joker_space)
        local lost_cards = 4 - num_cards
        local pool, key = parse_primary_pool(type_pools, num_cards)
        local temp = {}
        if key:find("uniq") then
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, #pool do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 4)
                    return true
                end
            }))
        elseif key:find("j_") then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    local card = create_joker({joker=pool[1]})
                    card:juice_up(0.3, 0.5)
                    table.insert(temp, card)
                    for i=2, num_cards do
                        card = create_joker({joker=pool[i], seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp,card)
                    end
                    add_editions(temp, {negative=true}, 4)
                    return true
                end
            }))
        else
            local card = nil
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, num_cards do
                        local id = pseudorandom_element(pool, i)
                        card = create_joker({joker=id, seed="ftcashout"..tostring(i*6000)})
                        card:juice_up(0.3, 0.5)
                        table.insert(temp, card)
                    end
                    add_editions(temp, {negative=true}, 4)
                    return true
                end
            }))
        end
        if lost_cards > 0 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(lost_cards * 12)
                    return true
                end
            }))
        end
    else -- baseline: yipppe!!!
        local loot_pool = pseudorandom("ftcashoutmega", 1, 20)
        loot_pool = loot_pool + G.GAME.arachnei_fortune.luck - 60 -- get better reward for more luck
        if loot_pool >= 4 then -- $10000, money package
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    ease_dollars(10000)
                    card = create_joker({joker="j_bull", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    card = create_joker({joker="j_to_the_moon", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    card = create_joker({joker="j_bootstraps", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
        if loot_pool >= 10 then -- every legendary joker, as negative
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    card = create_joker({joker="j_caino", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    card = create_joker({joker="j_triboulet", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    card = create_joker({joker="j_yorick", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    card = create_joker({joker="j_chicot", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    card = create_joker({joker="j_perkeo", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
        if loot_pool >= 12 then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, 3 do
                        card = create_joker({joker="j_blueprint", edition={negative=true}})
                        card:juice_up(0.3, 0.5)
                    end
                    for i=1, 3 do
                        card = create_joker({joker="j_brainstorm", edition={negative=true}})
                        card:juice_up(0.3, 0.5)
                    end
                    return true
                end
            }))
        end
        if loot_pool >= 16 then -- a lot of invisible jokers
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    for i=1, 10 do
                        card = create_joker({joker="j_invisible", edition={negative=true}})
                        card.ability.invis_round = 3
                    end
                    return true
                end
            }))
        end 
        if loot_pool >= 20 then -- big tree
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.2,
                func = function()
                    card = create_joker({joker="j_the_fortune_tree_arachnei", edition={negative=true}})
                    card:juice_up(0.3, 0.5)
                    return true
                end
            }))
        end
    end
end

-------------------
-- joker effects --
local function tree_jokerEffect(card, context)
    if card.ability.name == "Fortune Tree" and context.cardarea == G.jokers and context.after and not context.blueprint then
        G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + 1
        return {
            message = localize('k_arachnei_ft_luck'),
            colour = G.C.GOLD
        }
    end
    if card.ability.name == "Fortune Tree" and context.selling_self and not context.blueprint then
        G.GAME.pool_flags.fortune_tree_extinct = true
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 0.1,
            func = function()
                cashout(card, context)
                return true
            end
        }))
        card:explode({G.C.GOLD})
    end
    if card.ability.name == "Fortune Tree" and context.cardarea == G.jokers and not context.before and not context.after and not context.blueprint then
        return {
            message = localize{type='variable', key='a_xmult', vars={1 - (card.ability.extra.scaling * G.GAME.arachnei_fortune.luck)}},
            card = card,
            Xmult_mod = 1 - (card.ability.extra.scaling * G.GAME.arachnei_fortune.luck)
        }
    end
end

local function bigtree_jokerEffect(card, context)
    if card.ability.name == "The Fortune Tree" and context.cardarea == G.jokers and context.after and not context.blueprint then
        G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + card.ability.extra.luck_scaling
        return {
            message = "+2 Luck",
            colour = G.C.GOLD
        }
    end
    if card.ability.name == "The Fortune Tree" and context.cardarea == G.jokers and not context.before and not context.after then
        return {
            message = localize{type='variable', key='a_xmult', vars={1+(card.ability.extra.xmult_scaling*G.GAME.arachnei_fortune.luck)}},
            card = card,
            Xmult_mod = 1+(card.ability.extra.xmult_scaling*G.GAME.arachnei_fortune.luck),
            chip_mod = card.ability.extra.chip_scaling * G.GAME.arachnei_fortune.luck
        }
    end
end

local function bigtree_dollarbonus(card)
    if card.ability.name == "The Fortune Tree" then
        return G.GAME.arachnei_fortune.luck * card.ability.extra.gold_scaling
    end
end

local function tree_addtodeck(card, from_debuff)
    if not from_debuff and card.ability.name == "Fortune Tree" or card.ability.name == "The Fortune Tree" then
        G.GAME.pool_flags.fortune_tree_exist = true
    end
end

local function tree_removefromdeck(card, from_debuff)
    if not from_debuff and card.ability.name == "Fortune Tree" or card.ability.name == "The Fortune Tree" then
        G.GAME.pool_flags.fortune_tree_exist = false
    end
end

local function dumpling_jokerEffect(card, context)
    if context.end_of_round and not context.repetition and not context.individual and card.ability.name == "Dumplings" then
        G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + card.ability.extra.luck
        if not context.blueprint then
            if card.ability.extra.luck - card.ability.extra.decay < 0 then
                G.E_MANAGER:add_event(Event({
                    func = function()
                        play_sound('tarot1')
                        card.T.r = -0.2
                        card:juice_up(0.3, 0.4)
                        card.states.drag.is = true
                        card.children.center.pinch.x = true
                        G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                            func = function()
                                    G.jokers:remove_card(card)
                                    card:remove()
                                    card = nil
                                return true; 
                            end})) 
                        return true
                    end
                })) 
                return {
                    message = localize('k_eaten_ex'),
                    colour = G.C.GOLD,
                }
            else
                card.ability.extra.luck = card.ability.extra.luck - card.ability.extra.decay
                return {
                    message = "+"..tostring(card.ability.extra.luck+1).." Luck",
                    colour = G.C.GOLD,
                }
            end
            
        end
    end
end

local function firecrackers_effect(card, context)
    if context.end_of_round and not context.repetition and not context.individual and card.ability.name == "Firecrackers" then
        if G.GAME.current_round.hands_played == 1 then
            G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + card.ability.extra.luck
            return {
                message = "+"..tostring(card.ability.extra.luck).." Luck",
                colour = G.C.GOLD,
            }
        end
    end
end

local function envelope_effect(card, area, copier)
    if card.ability.name == "Red Envelope" then
        ease_dollars(G.GAME.arachnei_fortune.luck)
        card_eval_status_text(card, 'dollars', G.GAME.arachnei_fortune.luck)
    end
end

local function envelope_condition(card, any_state, skip_check)
    if card.ability.name == "Red Envelope" then
        return true
    end
end

local function liondance_effect(card, area, copier)
    if card.ability.name == "Lion Dance" then
        local temp = G.GAME.dollars
        G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + G.GAME.dollars
        ease_dollars(-G.GAME.dollars, true)
        card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+"..tostring(temp).." Luck", colour = G.C.GOLD})
    end
end

local function liondance_condition(card, any_state, skip_check)
    if card.ability.name == "Lion Dance" then
        return true
    end
end

local function fortunate_effect(card, context)
    if card.ability.name == "Fortunate Joker" and context.other_card.lucky_trigger then
        G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + card.ability.extra.luck
        return {
            extra = {focus = self, message = "+"..tostring(card.ability.extra.luck).." Luck", colour = G.C.GOLD},
            card = self,
        }
    end
end

local function caishen_effect(card, context)
    if card.ability.name == "Caishen" then
        if context.end_of_round and not context.repetition and not context.individual then
            if G.GAME.dollars > G.GAME.arachnei_fortune.luck then
                local diff = G.GAME.dollars - G.GAME.arachnei_fortune.luck
                G.GAME.arachnei_fortune.luck = G.GAME.arachnei_fortune.luck + math.floor(diff / 2)
                card_eval_status_text(card, 'extra', nil, nil, nil, {message = "+"..tostring(math.floor(diff / 2)).." Luck", colour = G.C.GOLD})
            end
        end
    end
end

local function caishen_dollarbonus(card)
    if card.ability.name == "Caishen" then
        if G.GAME.dollars < G.GAME.arachnei_fortune.luck then
            local diff = G.GAME.arachnei_fortune.luck - G.GAME.dollars
            return math.floor(diff/2)
        end
    end
end
--------------------
-- joker loc_vars --
local function tree_loc_vars(card)
    -- if looking from main menu
    if not G.GAME.arachnei_fortune then
        return {(1 - (card.ability.extra.scaling * 0)), card.ability.extra.scaling, 0, card.ability.extra.luck_scaling}
    else
        return {(1 - (card.ability.extra.scaling * G.GAME.arachnei_fortune.luck)), card.ability.extra.scaling, G.GAME.arachnei_fortune.luck or 0, card.ability.extra.luck_scaling}
    end
end

local function bigtree_loc_vars(card)
    if not G.GAME.arachnei_fortune then
        return {card.ability.extra.xmult_scaling, card.ability.extra.gold_scaling, card.ability.extra.chip_scaling, card.ability.extra.luck_scaling, 0, 1}
    else
        return {card.ability.extra.xmult_scaling, card.ability.extra.gold_scaling, card.ability.extra.chip_scaling, card.ability.extra.luck_scaling, G.GAME.arachnei_fortune.luck, G.GAME.arachnei_fortune.luck * card.ability.extra.xmult_scaling}
    end
end

local function dumpling_loc_vars(card)
    return {card.ability.extra.luck, card.ability.extra.decay}
end

local function firecrackers_loc_vars(card)
    return {card.ability.extra.luck}
end

local function envelope_loc_vars(card)
    if not G.GAME.arachnei_fortune then
        return {0}
    else
        return {G.GAME.arachnei_fortune.luck}
    end
end

local function fortunate_loc_vars(card)
    return {card.ability.extra.luck}
end
-------------------
-- balamod funcs --
local function on_enable()
    G.P_JOKER_RARITY_POOLS[5] = {} -- add mythical rarity to pools
    joker.add{ -- normal fortune tree
        id = 'j_fortune_tree_arachnei', 
        name = "Fortune Tree",
        calculate_joker_effect = tree_jokerEffect,
        unlocked = true,
        discovered = true,
        cost = 8,
        effect = nil, 
        config = {extra={scaling = 0.01, luck_scaling = 1}},
        desc = { --description text
            "{X:mult,C:white}X#1#{} Mult", 
            "Every hand, gain #4# {C:gold}Luck{}.", 
            "Lose {X:mult,C:white}X#2#{} Mult per {C:gold}Luck", 
            "When you sell this card, explode", 
            "into loot, depending on your {C:gold}Luck",
            "{C:inactive}(Current Luck: {C:gold}#3#{C:inactive})"
        },
        rarity = 3,
        blueprint_compat = false,
        eternal_compat = false,
        alerted = true,
        no_pool_flag = "fortune_tree_extinct", 
        yes_pool_flag = nil,       
        unlock_condition = nil, 
        unlock_condition_desc = nil,     
        mod_id = "arachnei_fortune",  
        loc_vars = tree_loc_vars,
        add_to_deck_effect = tree_addtodeck,
        remove_from_deck_effect = tree_removefromdeck,
    }
    joker.add{ -- big fortune tree
        id = 'j_the_fortune_tree_arachnei', 
        name = "The Fortune Tree",
        calculate_joker_effect = bigtree_jokerEffect,
        unlocked = false,
        discovered = false,
        cost = 200,
        effect = nil, 
        config = {extra={xmult_scaling = 0.5, gold_scaling = 1, chip_scaling = 1, luck_scaling = 2}},
        desc = { --description text
            "{X:mult,C:white}X#1#{} Mult for each {C:gold}Luck{}.",
            "Earn {C:money}$#2#{} for each {C:gold}Luck{}.",
            "Gain {C:chips}+#3#{} for each {C:gold}Luck{}.",
            "Every hand, gain {C:gold}#4# Luck{}.",
            "{C:inactive}(Current Luck: {C:gold}#5#{C:inactive})",
            "{C:inactive}(Currently {X:mult,C:white}X#6#{C:inactive} Mult)"
        },
        rarity = 5,
        blueprint_compat = true,
        eternal_compat = true,
        alerted = true,
        no_pool_flag = nil, 
        yes_pool_flag = nil,       
        unlock_condition = nil, 
        unlock_condition_desc = {
            "Legends say the extremely",
            "{C:gold}fortunate{} may encounter",
            "this {C:purple}Mythical{} tree..."
        },     
        mod_id = "arachnei_fortune",  
        loc_vars = bigtree_loc_vars,
        calculate_dollar_bonus_effect = bigtree_dollarbonus,
        add_to_deck_effect = tree_addtodeck,
        remove_from_deck_effect = tree_removefromdeck,
    }
    joker.add{
        id = 'j_dumplings_arachnei',
        name = 'Dumplings',
        calculate_joker_effect = dumpling_jokerEffect,
        unlocked = true,
        discovered = true,
        cost = 4,
        effect = nil,
        config = {extra={luck=3, decay=1}},
        desc = {
            "+#1# {C:gold}Luck{} per round,",
            "this loses #2# {C:gold}Luck{}",
            "per round"
        },
        rarity = 1,
        blueprint_compat = true,
        eternal_compat = false,
        alerted = true,
        no_pool_flag = nil,
        yes_pool_flag = "fortune_tree_exist",
        unlock_condition = nil,
        unlock_condition_desc = nil,
        mod_id = "arachnei_fortune",
        loc_vars = dumpling_loc_vars,
    }
    joker.add{
        id = 'j_firecrackers_arachnei',
        name = "Firecrackers",
        calculate_joker_effect = firecrackers_effect,
        unlocked = true,
        discovered = true,
        cost = 6,
        effect = nil,
        config = {extra={luck=3}},
        desc = {
            "Gain #1# {C:gold}Luck{} if you",
            "defeat the {C:attention}Blind{} with",
            "a single hand"
        },
        rarity = 2,
        blueprint_compat = true,
        eternal_compat = true,
        alerted = true,
        no_pool_flag = nil,
        yes_pool_flag = "fortune_tree_exist",
        unlock_condition = nil,
        unlock_condition_desc = nil,
        mod_id = "arachnei_fortune",
        loc_vars = firecrackers_loc_vars,
    }
    joker.add{
        mod_id = "arachnei_fortune",
        id = "j_fortunate_arachnei",
        name = "Fortunate Joker",
        calculate_joker_effect = fortunate_effect,
        cost = 4,
        config = {extra={luck=2}},
        desc = {
            "Gain #1# {C:gold}Luck{} every time a",
            "{C:attention}Lucky{} card {C:green}successfully{} triggers",
        },
        rarity = 1,
        blueprint_compat = true,
        eternal_compat = true,
        yes_pool_flag = "fortune_tree_exist",
        loc_vars = fortunate_loc_vars,
        enhancement_gate = 'm_lucky',
    }
    joker.add{
        mod_id = "arachnei_fortune",
        id = "j_caishen_arachnei",
        name = "Caishen",
        calculate_joker_effect = caishen_effect,
        calculate_dollar_bonus_effect = caishen_dollarbonus,
        cost = 8,
        config = {},
        desc = {
            "At the end of the round," ,
            "half the difference between",
            "your {C:money}money{} and {C:gold}luck{} is added",
            "to the lower of the two",
        },
        rarity = 3,
        blueprint_compat = true,
        eternal_compat = true,
        yes_pool_flag = "fortune_tree_exist",
    }
    consumable.add{
        mod_id = "arachnei_fortune",
        id = "c_envelope_arachnei",
        name = "Red Envelope",
        use_effect = envelope_effect,
        use_condition = envelope_condition,
        unlocked = true,
        discovered = true,
        cost = 4,
        config = {},
        desc = {
            "Gain {C:gold}$#1#{}, based on",
            "your current {C:gold}Luck",
        },
        alerted = true,
        loc_vars = envelope_loc_vars,
        set = "Tarot",
        yes_pool_flag = "fortune_tree_exist",
    }
    consumable.add{
        mod_id = "arachnei_fortune",
        id = "c_lion_dance_arachnei",
        name = "Lion Dance",
        use_effect = liondance_effect,
        use_condition = liondance_condition,
        cost = 5,
        config = {},
        desc = {
            "Gain {C:gold}Luck{} equal",
            "to your money, then set", 
            "money to {C:money}$0",
        },
        set = "Spectral",
        yes_pool_flag = "fortune_tree_exist",
    }
    -- low luck quips
    G.localization.misc.dictionary.k_arachnei_ftc_fivejimbo = "Jimbo!"
    G.localization.misc.dictionary.k_arachnei_ftc_robbed = "Robbed!"
    G.localization.misc.dictionary.k_arachnei_ftc_oopsdiscards = "Oops! No discards!"
    G.localization.misc.dictionary.k_arachnei_ftc_tripped = "Tripped!"
    G.localization.misc.dictionary.k_arachnei_ftc_egg = "Egg!"
    G.localization.misc.dictionary.k_arachnei_ftc_needle = "D Needle A!"
    G.localization.misc.dictionary.k_arachnei_ftc_badbus = "American Transit!"
    G.localization.misc.dictionary.k_arachnei_ft_luck = "+1 Luck"

    -- add mythical rarity to game
    local to_replace = [[localize%('k_legendary'%)]]
    local replacement = [[localize%('k_legendary'%), "Mythical"]]
    local file_name = "functions/UI_definitions.lua"
    local fun_name = "G.UIDEF.card_h_popup"
    inject(file_name, fun_name, to_replace, replacement)
    G.C.RARITY[5] = HEX("e4cd29")
end

local function on_disable()
    joker.remove("j_fortune_tree_arachnei")
    joker.remove("j_the_fortune_tree_arachnei")
    joker.remove("j_dumplings_arachnei")
    joker.remove("j_firecrackers_arachnei")
end


return {
    on_enable = on_enable,
    on_disable = on_disable,
}

