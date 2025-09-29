--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck Jokers
--- MOD_ID: chaos_deck_jokers
--- MOD_AUTHOR: [Caveman5880]
--- MOD_DESCRIPTION: Custom jokers for the Chaos Deck mod
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0821c]

----------------------------------------------
------------JOKERS MOD CODE-------------------

-- Atlas temporarily disabled to test functionality - will re-enable once we solve the display issue
-- SMODS.Atlas{
--     key = "chaos_jokers",
--     path = "alec_mukbang_joker.png",
--     px = 71,
--     py = 95,
--     frames = 1,
--     atlas_table = 'ASSET_ATLAS'
-- }

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
    -- atlas = "chaos_jokers", -- Temporarily using default sprite
    pos = {x = 0, y = 0}, -- Will use default joker appearance for now
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

----------------------------------------------
------------JOKERS MOD CODE END--------------