--- Minecraft Phase Joker
--- A joker that starts powerful but decays over time, with bonuses for having friends

-- Atlas for this joker
SMODS.Atlas{
    key = "minecraft_phase_atlas", 
    path = "minecraft_server_joker.png", -- Fixed to match your actual filename
    px = 71,
    py = 95,
    atlas_table = 'ASSET_ATLAS'
}

-- Minecraft Phase Joker
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
        
        -- Reset the processed flag at the start of each round
        if context.setting_blind and not context.blueprint then
            card.ability.extra.processed_this_round = false
        end
    end
}