--- Spell Map Joker
--- A joker that copies other jokers' effects with probability scaling

-- Atlas for this joker
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
    rarity = 3, -- Rare rarity
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
            copied_effect = nil, -- What effect was copied (first one for compatibility)
            copied_effects = {}, -- All effects that were copied (can be multiple)
            copied_joker1 = "None", -- First joker being copied (for display)
            copied_joker2 = "", -- Second joker being copied (for display)
            target_joker1 = nil, -- Target joker 1 for this blind
            target_joker2 = nil -- Target joker 2 for this blind
        }
    },
    
    loc_txt = {
        name = "Spell Map",
        text = {
            "Picks {C:attention}2 random Jokers{} per blind",
            "Each has {C:green}#1# in #2#{} chance to give",
            "clear directions to copy their effect",
            "Otherwise: {C:red}'I can't spell it!'{}", 
            "{C:inactive}Targets:{} {C:attention}#3#{}",
            "{C:attention}#4#{}"
        }
    },
    
    loc_vars = function(self, info_queue, center)
        -- Use SMODS function to get proper probability vars that account for Oops All 6s
        local numerator, denominator = SMODS.get_probability_vars(center, 1, 4, 'spell_map_prob')
        
        -- Get copied joker names for display
        local copied1 = (center and center.ability and center.ability.extra and center.ability.extra.copied_joker1) or "None"
        local copied2 = (center and center.ability and center.ability.extra and center.ability.extra.copied_joker2) or ""
        
        return {vars = {numerator, denominator, copied1, copied2}}
    end,
    
    calculate = function(self, card, context)
        -- Pick new targets at the start of each blind (stays consistent throughout the blind)
        if context.setting_blind and not context.blueprint then
            -- Reset state for new blind
            card.ability.extra.direction_understood = false
            card.ability.extra.copied_effect = nil
            card.ability.extra.copied_effects = {}
            card.ability.extra.target_joker1 = nil
            card.ability.extra.target_joker2 = nil
            
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
                -- Pick 2 different random jokers for this blind
                local shuffled_jokers = {}
                for i, joker in ipairs(other_jokers) do
                    shuffled_jokers[i] = joker
                end
                -- Shuffle the array
                for i = #shuffled_jokers, 2, -1 do
                    local j = math.random(i)
                    shuffled_jokers[i], shuffled_jokers[j] = shuffled_jokers[j], shuffled_jokers[i]
                end
                
                card.ability.extra.target_joker1 = shuffled_jokers[1]
                card.ability.extra.target_joker2 = shuffled_jokers[2]
                
                -- Update display text
                card.ability.extra.copied_joker1 = shuffled_jokers[1].ability.name or "Unknown"
                card.ability.extra.copied_joker2 = shuffled_jokers[2].ability.name or "Unknown"
            elseif #other_jokers == 1 then
                -- Only one other joker available, use it for both slots
                local single_joker = other_jokers[1]
                card.ability.extra.target_joker1 = single_joker
                card.ability.extra.target_joker2 = single_joker
                card.ability.extra.copied_joker1 = single_joker.ability.name or "Unknown"
                card.ability.extra.copied_joker2 = ""
            else
                -- No other jokers available
                card.ability.extra.target_joker1 = nil
                card.ability.extra.target_joker2 = nil
                card.ability.extra.copied_joker1 = "None"
                card.ability.extra.copied_joker2 = ""
            end
        end
        
        -- Check for directions DURING SCORING where Oops All 6s can modify probability
        if context.before and not context.blueprint and card.ability.extra.target_joker1 then
            -- Reset directions for this hand
            card.ability.extra.copied_effects = {}
            card.ability.extra.direction_understood = false
            
            -- Store all successful directions
            local successful_directions = {}
            
            -- Check first joker - always exists if we're here
            if SMODS.pseudorandom_probability(card, 'spell_map_prob', 1, 4) then
                table.insert(successful_directions, card.ability.extra.target_joker1.ability.name)
            end
            
            -- Check second joker - only if it exists AND is different from first
            if card.ability.extra.target_joker2 and card.ability.extra.target_joker2 ~= card.ability.extra.target_joker1 then
                if SMODS.pseudorandom_probability(card, 'spell_map_prob', 1, 4) then
                    table.insert(successful_directions, card.ability.extra.target_joker2.ability.name)
                end
            end
            
            -- Store the successful jokers for actual copying later
            card.ability.extra.copied_effects = successful_directions
            card.ability.extra.direction_understood = #successful_directions > 0
            
            -- Show message about understanding/confusion
            if #successful_directions > 0 then
                return {
                    message = "Got directions!",
                    colour = G.C.GREEN
                }
            else
                return {
                    message = "Can't spell!",
                    colour = G.C.RED
                }
            end
        end
        
        -- Apply effect during scoring - handle BOTH joker_main AND individual contexts
        if context.joker_main then
            -- If we didn't understand directions, show failure message
            if not card.ability.extra.direction_understood then
                return {
                    message = "Can't Spell",
                    colour = G.C.RED
                }
            end
            
            -- If we understood directions, try to copy ALL successful effects
            if card.ability.extra.direction_understood and card.ability.extra.copied_effects then
                local total_result = {
                    message = "M-A-P",
                    colour = G.C.GREEN
                }
                
                -- Copy effects from all successful jokers
                for _, effect_name in ipairs(card.ability.extra.copied_effects) do
                    -- Find the joker we're copying from
                    local copied_joker = nil
                    if G.jokers and G.jokers.cards then
                        for _, joker in ipairs(G.jokers.cards) do
                            if joker.ability and joker.ability.name == effect_name and joker ~= card then
                                copied_joker = joker
                                break
                            end
                        end
                    end
                    
                    if copied_joker then
                        local copied_result = SMODS.blueprint_effect(card, copied_joker, context)
                        if copied_result then
                            -- Show "Copied" message under each copied joker
                            G.E_MANAGER:add_event(Event({
                                trigger = 'immediate',
                                func = function()
                                    card_eval_status_text(copied_joker, 'extra', nil, nil, nil, {
                                        message = "Copied",
                                        colour = G.C.GREEN
                                    })
                                    return true
                                end
                            }))
                            
                            -- Merge effects (only numeric values, skip message/colour/card)
                            for key, value in pairs(copied_result) do
                                if key ~= 'message' and key ~= 'colour' and key ~= 'card' and type(value) == "number" then
                                    if key == 'Xmult_mod' or key == 'xmult' then
                                        -- Multiply X-mult effects
                                        total_result[key] = (total_result[key] or 1) * value
                                    elseif key == 'mult' or key == 'chips' or key == 'dollars' then
                                        -- Add other numeric effects (chips, mult, etc.)
                                        total_result[key] = (total_result[key] or 0) + value
                                    end
                                end
                            end
                        end
                    end
                end
                
                return total_result
            end
        end
        
        -- ALSO handle individual card context for per-card effects (like Lusty Joker)
        if context.individual and card.ability.extra.direction_understood and card.ability.extra.copied_effects then
            local total_result = {}
            
            -- Copy effects from ALL successful jokers, but only if they trigger in individual context
            for _, effect_name in ipairs(card.ability.extra.copied_effects) do
                local copied_joker = nil
                if G.jokers and G.jokers.cards then
                    for _, joker in ipairs(G.jokers.cards) do
                        if joker.ability and joker.ability.name == effect_name and joker ~= card then
                            copied_joker = joker
                            break
                        end
                    end
                end
                
                if copied_joker then
                    local copied_result = SMODS.blueprint_effect(card, copied_joker, context)
                    
                    -- Only merge if result is non-empty (has actual effects)
                    if copied_result and next(copied_result) then
                        -- Merge effects (only numeric values, skip message/colour/card)
                        for key, value in pairs(copied_result) do
                            if key ~= 'message' and key ~= 'colour' and key ~= 'card' and type(value) == "number" then
                                if key == 'Xmult_mod' or key == 'xmult' then
                                    -- Multiply X-mult effects
                                    total_result[key] = (total_result[key] or 1) * value
                                elseif key == 'mult' or key == 'chips' or key == 'dollars' then
                                    -- Add other numeric effects (chips, mult, etc.)
                                    total_result[key] = (total_result[key] or 0) + value
                                end
                            end
                        end
                    end
                end
            end
            
            -- Only return if we have actual effects to contribute
            if next(total_result) then
                return total_result
            end
        end
    end
}