--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck Jokers
--- MOD_ID: chaos_deck_jokers
--- MOD_AUTHOR: [Caveman5880]
--- MOD_DESCRIPTION: Custom jokers for the Chaos Deck mod
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0821c]

----------------------------------------------
------------JOKERS MOD CODE-------------------

-- Create separate atlases for each joker (much easier to manage!)
SMODS.Atlas{
    key = "alec_mukbang_atlas",
    path = "alec_mukbang_joker.png",
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS'
}

SMODS.Atlas{
    key = "minecraft_phase_atlas", 
    path = "minecraft_server_joker.png", -- Fixed to match your actual filename
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS'
}

-- Helper function to check if a joker is food-themed
local function is_food_joker(joker)
    local food_jokers = {
        'j_ice_cream',      -- Ice Cream
        'j_popcorn',        -- Popcorn
        'j_ramen',          -- Ramen
        'j_selzer',         -- Seltzer
        'j_diet_cola',      -- Diet Cola
        'j_pickle',         -- Pickle
        'j_cavendish',      -- Cavendish (banana)
        'j_gros_michel',    -- Gros Michel (banana)
        'j_egg',            -- Egg
        'j_turtle_bean',    -- Turtle Bean
    }
    
    if joker and joker.config and joker.config.center then
        local center_key = joker.config.center.key
        for _, food_key in ipairs(food_jokers) do
            if center_key == food_key then
                return true
            end
        end
    end
    
    return false
end

-- Alec Mukbang Joker
SMODS.Joker{
    key = "alec_mukbang",
    name = "Alec Mukbang",
    rarity = 2, -- Uncommon rarity
    cost = 6,
    atlas = "alec_mukbang_atlas", -- Uses its own dedicated atlas
    pos = {x = 0, y = 0}, -- Single joker image
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    
    config = {
        extra = {
            x_mult = 1 -- Starting at 1x mult
        }
    },
    
    loc_txt = {
        name = "Alec Mukbang",
        text = {
            "When {C:attention}Blind{} is selected,",
            "destroy all {C:attention}food{} Jokers",
            "and gain {C:red}X1{} Mult for each",
            "destroyed food Joker",
            "{C:inactive}(Currently {C:red}X#1#{C:inactive} Mult)"
        }
    },
    
    loc_vars = function(self, info_queue, center)
        return {vars = {center.ability.extra.x_mult}}
    end,
    
    calculate = function(self, card, context)
        -- Trigger when blind is selected
        if context.setting_blind and not context.blueprint then
            local destroyed_count = 0
            
            -- Look through all jokers for food-themed ones
            if G.jokers and G.jokers.cards then
                local cards_to_destroy = {}
                
                -- First pass: identify food jokers to destroy
                for _, joker in ipairs(G.jokers.cards) do
                    if joker ~= card and is_food_joker(joker) then
                        table.insert(cards_to_destroy, joker)
                        destroyed_count = destroyed_count + 1
                    end
                end
                
                -- Second pass: actually destroy the jokers
                if destroyed_count > 0 then
                    -- Add visual effect
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            for _, joker_to_destroy in ipairs(cards_to_destroy) do
                                -- Create destruction effect
                                joker_to_destroy:start_dissolve(nil, true)
                            end
                            
                            -- Update Alec Mukbang's multiplier
                            card.ability.extra.x_mult = card.ability.extra.x_mult + destroyed_count
                            
                            -- Show juice effect on Alec Mukbang
                            card:juice_up(0.8, 0.8)
                            
                            -- Play sound effect
                            play_sound('generic1', 0.9 + math.random() * 0.1, 0.8)
                            
                            -- Create popup text
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "+" .. destroyed_count .. " Mult!",
                                colour = G.C.RED
                            })
                            
                            return true
                        end
                    }))
                end
            end
        end
        
        -- Apply the multiplier during scoring
        if context.joker_main then
            return {
                message = localize{type='variable',key='a_xmult',vars={card.ability.extra.x_mult}},
                Xmult_mod = card.ability.extra.x_mult
            }
        end
    end
}

-- The One Month Minecraft Phase Joker
SMODS.Joker{
    key = "minecraft_phase",
    name = "The One Month Minecraft Phase",
    rarity = 2, -- Uncommon rarity
    cost = 7,
    atlas = "minecraft_phase_atlas", -- Uses its own dedicated atlas
    pos = {x = 0, y = 0}, -- Single joker image
    blueprint_compat = true,
    eternal_compat = false, -- Can't be eternal since it destroys itself
    perishable_compat = true,
    
    config = {
        extra = {
            x_mult = 6.0, -- Starting multiplier
            rounds_remaining = 8, -- Lasts 8 rounds
            base_decay = 0.5, -- How much it loses per round
            processed_this_round = false -- Prevent multiple triggers per round
        }
    },
    
    loc_txt = {
        name = "The One Month Minecraft Phase",
        text = {
            "Starts at {C:red}X6{} Mult",
            "Loses {C:red}X0.5{} Mult each round played",
            "Gains {C:red}X1{} Mult for each other Joker",
            "Dies after {C:attention}8 rounds{}",
            "{C:green}Minecraft is better with friends{}",
            "{C:inactive}(Currently {C:red}X#1#{C:inactive} Mult, {C:attention}#2#{C:inactive} rounds left)"
        }
    },
    
    loc_vars = function(self, info_queue, center)
        -- Calculate current multiplier including friend bonus for display
        local other_jokers = 0
        if G and G.jokers and G.jokers.cards then
            for _, joker in ipairs(G.jokers.cards) do
                if joker ~= center and joker.ability and joker.ability.name then
                    other_jokers = other_jokers + 1
                end
            end
        end
        local display_mult = math.max(0.1, center.ability.extra.x_mult + other_jokers)
        return {vars = {display_mult, center.ability.extra.rounds_remaining}}
    end,
    
    calculate = function(self, card, context)
        -- Apply the multiplier during scoring
        if context.joker_main then
            -- Calculate current multiplier based on other jokers (count friends)
            local other_jokers = 0
            if G.jokers and G.jokers.cards then
                for _, joker in ipairs(G.jokers.cards) do
                    if joker ~= card and joker.ability and joker.ability.name then
                        other_jokers = other_jokers + 1
                    end
                end
            end
            
            -- Current mult = base mult + friend bonus
            local current_mult = math.max(0.1, card.ability.extra.x_mult + other_jokers)
            
            return {
                message = localize{type='variable',key='a_xmult',vars={current_mult}},
                Xmult_mod = current_mult
            }
        end
        
        -- Decay at end of round - use a more specific context to prevent multiple triggers
        if context.end_of_round and not context.blueprint and not context.repetition and not context.individual then
            -- Only trigger once per round by checking if we haven't already processed this round
            if not card.ability.extra.processed_this_round then
                card.ability.extra.processed_this_round = true
                
                -- Reduce rounds remaining
                card.ability.extra.rounds_remaining = card.ability.extra.rounds_remaining - 1
                
                -- Reduce multiplier
                card.ability.extra.x_mult = card.ability.extra.x_mult - card.ability.extra.base_decay
                
                -- Visual effect for decay
                card:juice_up(0.8, 0.8)
                
                -- Show decay message
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.2,
                    func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "Losing Interest...",
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
                
                -- Check if it should die
                if card.ability.extra.rounds_remaining <= 0 then
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.5,
                        func = function()
                            -- Death message
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Server Died!",
                                colour = G.C.RED
                            })
                            
                            -- Destroy the card
                            card:start_dissolve(nil, true)
                            
                            return true
                        end
                    }))
                end
            end
        end
        
        -- Reset the round processing flag at start of new round
        if context.first_hand_drawn then
            card.ability.extra.processed_this_round = false
        end
    end
}

----------------------------------------------
------------JOKERS MOD CODE END--------------