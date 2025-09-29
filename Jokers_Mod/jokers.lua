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

-- Create Atlas for Spell Map joker
SMODS.Atlas{
    key = "spell_map_atlas",
    path = "spell_map_joker.png", -- You'll create this image
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS'
}

-- Spell Map Joker
SMODS.Joker{
    key = "spell_map",
    name = "Spell Map",
    rarity = 2, -- Uncommon rarity
    cost = 6,
    atlas = "spell_map_atlas",
    pos = {x = 0, y = 0},
    blueprint_compat = true,
    eternal_compat = true,
    perishable_compat = true,
    
    config = {
        extra = {
            base_mult = 2, -- Base multiplier when confused
            direction_understood = false, -- Whether directions were understood this hand
            copied_effect = nil, -- What effect was copied
            copied_joker1 = "None", -- First joker being copied (for display)
            copied_joker2 = "" -- Second joker being copied (for display)
        }
    },
    
    loc_txt = {
        name = "Spell Map",
        text = {
            "Asks {C:attention}2 random Jokers{} for directions",
            "Each has {C:green}#1# in #2#{} chance to give",
            "clear directions to copy their effect",
            "Otherwise: {C:red}'I can't spell it!'{}", 
            "{C:inactive}Currently copying:{} {C:attention}#3#{}",
            "{C:attention}#4#{}"
        }
    },
    
    loc_vars = function(self, info_queue, center)
        local prob_multiplier = G.GAME and G.GAME.probabilities and G.GAME.probabilities.normal or 1
        local numerator = math.min(prob_multiplier, 4)  -- Cap display at 4/4 for clarity
        
        -- Get copied joker names for display
        local copied1 = (center and center.ability and center.ability.extra and center.ability.extra.copied_joker1) or "None"
        local copied2 = (center and center.ability and center.ability.extra and center.ability.extra.copied_joker2) or ""
        
        return {vars = {numerator, 4, copied1, copied2}}
    end,
    
    calculate = function(self, card, context)
        -- Pick new targets at start of round and after each hand
        if context.first_hand_drawn or context.after then
            -- Reset previous directions
            card.ability.extra.direction_understood = false
            card.ability.extra.copied_effect = nil
            
            -- Look for other jokers to ask for directions (only blueprint-compatible ones)
            local other_jokers = {}
            if G.jokers and G.jokers.cards then
                for _, joker in ipairs(G.jokers.cards) do
                    if joker ~= card and joker.ability and joker.ability.name then
                        -- Check if the joker is blueprint compatible
                        local is_compatible = true
                        if joker.config and joker.config.center then
                            is_compatible = joker.config.center.blueprint_compat ~= false
                        end
                        
                        if is_compatible then
                            table.insert(other_jokers, joker)
                        end
                    end
                end
            end
            
            if #other_jokers >= 2 then
                -- Ask 2 different random jokers for directions
                local shuffled_jokers = {}
                for i, joker in ipairs(other_jokers) do
                    shuffled_jokers[i] = joker
                end
                -- Shuffle the array
                for i = #shuffled_jokers, 2, -1 do
                    local j = math.random(i)
                    shuffled_jokers[i], shuffled_jokers[j] = shuffled_jokers[j], shuffled_jokers[i]
                end
                
                local direction_giver1 = shuffled_jokers[1]
                local direction_giver2 = shuffled_jokers[2]
                
                -- Update display text
                card.ability.extra.copied_joker1 = direction_giver1.ability.name or "Unknown"
                card.ability.extra.copied_joker2 = direction_giver2.ability.name or "Unknown"
                
                -- 1 in 4 chance for each joker to give clear directions
                local understood1 = pseudorandom('spell_map_dir1') < G.GAME.probabilities.normal/4
                local understood2 = pseudorandom('spell_map_dir2') < G.GAME.probabilities.normal/4
                
                if understood1 then
                    card.ability.extra.direction_understood = true
                    card.ability.extra.copied_effect = direction_giver1.ability.name
                elseif understood2 then
                    card.ability.extra.direction_understood = true
                    card.ability.extra.copied_effect = direction_giver2.ability.name
                else
                    card.ability.extra.direction_understood = false
                    card.ability.extra.copied_effect = nil
                end
            elseif #other_jokers == 1 then
                -- Only one joker available - ask them with two attempts
                local direction_giver = other_jokers[1]
                
                -- Update display text
                card.ability.extra.copied_joker1 = direction_giver.ability.name or "Unknown"
                card.ability.extra.copied_joker2 = ""
                
                local understood1 = pseudorandom('spell_map_dir1') < G.GAME.probabilities.normal/4
                local understood2 = pseudorandom('spell_map_dir2') < G.GAME.probabilities.normal/4
                
                if understood1 or understood2 then
                    card.ability.extra.direction_understood = true
                    card.ability.extra.copied_effect = direction_giver.ability.name
                else
                    card.ability.extra.direction_understood = false
                    card.ability.extra.copied_effect = nil
                end
            else
                -- No jokers available
                card.ability.extra.copied_joker1 = "None"
                card.ability.extra.copied_joker2 = ""
                card.ability.extra.direction_understood = false
                card.ability.extra.copied_effect = nil

            end
        end
        
        -- Apply effect during scoring
        if context.joker_main then
            -- Show popup message based on whether we understood directions
            if not card.ability.extra.direction_understood then
                G.E_MANAGER:add_event(Event({
                    trigger = 'after',
                    delay = 0.1,
                    func = function()
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = "I can't spell it!",
                            colour = G.C.RED
                        })
                        return true
                    end
                }))
                return nil -- No effect when we can't understand
            end
            
            if card.ability.extra.direction_understood and card.ability.extra.copied_effect then
                -- Successfully understood directions - try to copy the effect from the other joker
                local copied_joker = nil
                
                -- Find the joker we're copying from
                if G.jokers and G.jokers.cards then
                    for _, joker in ipairs(G.jokers.cards) do
                        if joker.ability and joker.ability.name == card.ability.extra.copied_effect and joker ~= card then
                            copied_joker = joker
                            break
                        end
                    end
                end
                
                -- If we found the joker to copy, use SMODS.blueprint_effect
                if copied_joker then
                    -- Show popup message that we're copying
                    G.E_MANAGER:add_event(Event({
                        trigger = 'after',
                        delay = 0.1,
                        func = function()
                            card_eval_status_text(card, 'extra', nil, nil, nil, {
                                message = "Copied " .. (copied_joker.ability.name or "Joker"),
                                colour = G.C.GREEN
                            })
                            return true
                        end
                    }))
                    
                    -- Try SMODS.blueprint_effect first
                    local copied_result = nil
                    if SMODS and SMODS.blueprint_effect then
                        copied_result = SMODS.blueprint_effect(card, copied_joker, context)
                    end
                    
                    -- If SMODS.blueprint_effect failed, try manual approach
                    if not copied_result and copied_joker.calculate then
                        -- Create a context copy for safety
                        local copy_context = {}
                        for k, v in pairs(context) do
                            copy_context[k] = v
                        end
                        copy_context.blueprint_card = card
                        
                        copied_result = copied_joker:calculate_joker(copy_context)
                        if copied_result then
                            copied_result.card = card
                            copied_result.colour = G.C.GREEN
                        end
                    end
                    
                    if copied_result then
                        return copied_result
                    end
                end
                
                -- Fallback - couldn't copy for some reason but understood directions
                return {
                    message = "Tried to copy but failed - +6 Mult",
                    mult_mod = 6
                }
            -- If we didn't understand directions, do nothing (no mult bonus)
            -- The "I can't spell it!" message was already shown
            end
        end
    end
}

----------------------------------------------
------------JOKERS MOD CODE END--------------