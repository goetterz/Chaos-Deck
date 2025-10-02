--- Alec Mukbang Joker
--- A joker that destroys food jokers for X-mult

-- Atlas for this joker
SMODS.Atlas{
    key = "alec_mukbang_atlas",
    path = "alec_mukbang_joker.png",
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
SMODS.Joker {
    key = "alec_mukbang",
    atlas = "alec_mukbang_atlas",
    pos = {x = 0, y = 0},
    rarity = 2,
    cost = 7,
    
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
            "{C:green}I hunger...{}",
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
                
                -- Second pass: sequentially devour each joker with dramatic effect
                if destroyed_count > 0 then
                    -- Create sequential eating events - works for any number of food jokers
                    local base_delay = 0.1
                    local sequence_interval = 0.3 -- Clean 0.3-second intervals between each eating
                    
                    for i, joker_to_destroy in ipairs(cards_to_destroy) do
                        -- Sound, jiggle, and eating happen together sequentially
                        G.E_MANAGER:add_event(Event({
                            trigger = 'after',
                            delay = base_delay + (i - 1) * sequence_interval,
                            func = function()
                                -- Sound and effects happen together
                                play_sound('chaos_deck_jokers_eating', 1.0 + math.random() * 0.2, 0.8)
                                card:juice_up(1.2, 1.2) -- Big jiggle
                                joker_to_destroy:start_dissolve(nil, true) -- Destroy joker
                                
                                return true
                            end
                        }))
                    end
                    
                    -- Final total mult message after all food is consumed
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = base_delay + destroyed_count * sequence_interval + 0.2, -- Final message after all eating is done
                        func = function()
                            -- Update Alec Mukbang's multiplier
                            card.ability.extra.x_mult = card.ability.extra.x_mult + destroyed_count
                            
                            -- Final satisfaction juice
                            card:juice_up(1.5, 1.5)
                            
                            -- Show total mult gained
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "+ X" .. destroyed_count .. " Mult!",
                                colour = G.C.RED
                            })
                            
                            -- Play final satisfaction sound
                            play_sound('generic1', 0.8, 0.9)
                            
                            return true
                        end
                    }))
                end
            end
        end
        
        -- Hunger reminder at end of round (only once per round)
        if context.end_of_round and not context.blueprint and not context.repetition and context.main_eval then
            G.E_MANAGER:add_event(Event({
                trigger = 'after',
                delay = 0.5, -- Much shorter delay
                func = function()
                    -- Play stomach grumble sound
                    play_sound('chaos_deck_jokers_hungry_growl', 1.0, 0.8)
                    
                    -- Show hunger message
                    card_eval_status_text(card, 'extra', nil, nil, nil, {
                        message = "I still hunger...",
                        colour = G.C.DARK_EDITION
                    })
                    
                    -- Subtle juice effect
                    card:juice_up(0.5, 0.5)
                    
                    return true
                end
            }))
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