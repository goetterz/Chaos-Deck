--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck
--- MOD_ID: chaos_deck_toggles
--- MOD_AUTHOR: [Caveman5880]
--- MOD_DESCRIPTION: A deck that gives every starting card a chance at a random seal/enhancement/edition, with toggles in the Mods menu.
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0821c]

----------------------------------------------
------------MOD CODE -------------------------

-- Store reference to this mod for config access in both deck and UI
local current_mod_ref = SMODS.current_mod

-- Create the Atlas for our custom deck back
SMODS.Atlas{
    key = "chaos_deck_back",
    path = "cards_2.png",
    px = 100,
    py = 150
}

SMODS.Back{
    name = "Chaos Deck",
    key = "chaos_deck",
    atlas = "chaos_deck_back",
    pos = {x = 0, y = 0},
    config = {card_limit = 52},
    loc_txt = {
        name = "Chaos Deck",
        text = {
            "Each starting playing card",
            "gets a random {C:attention}Enhancement{},",
            "a random {C:attention}Seal{}, and a random {C:attention}Edition{}",
            "(Negative excluded).",
            "{C:inactive}(Go to settings to toggle different options and set custom percentages.){}"
        }
    },
    apply = function(self)
        
        G.E_MANAGER:add_event(Event({
            func = function()
                -- Get configuration - use the mod's config directly
                local cfg = current_mod_ref and current_mod_ref.config or {}
                
                -- Default values if config not found
                if cfg.enabled_enhancement == nil then cfg.enabled_enhancement = true end
                if cfg.enable_seal == nil then cfg.enable_seal = true end
                if cfg.enable_edition == nil then cfg.enable_edition = true end
                
                -- Process each card in the playing cards table
                for _, card in ipairs(G.playing_cards) do
                    -- Add ENHANCEMENT if enabled and chance succeeds
                    if cfg.enabled_enhancement and math.random(100) <= (cfg.enhancement_chance or 20) then
                        -- Build list of allowed enhancements
                        local allowed_enhancements = {}
                        if cfg.allow_bonus ~= false then table.insert(allowed_enhancements, 'm_bonus') end
                        if cfg.allow_mult ~= false then table.insert(allowed_enhancements, 'm_mult') end
                        if cfg.allow_wild ~= false then table.insert(allowed_enhancements, 'm_wild') end
                        if cfg.allow_glass ~= false then table.insert(allowed_enhancements, 'm_glass') end
                        if cfg.allow_gold ~= false then table.insert(allowed_enhancements, 'm_gold') end
                        if cfg.allow_steel ~= false then table.insert(allowed_enhancements, 'm_steel') end
                        if cfg.allow_stone ~= false then table.insert(allowed_enhancements, 'm_stone') end
                        if cfg.allow_lucky ~= false then table.insert(allowed_enhancements, 'm_lucky') end
                        
                        if #allowed_enhancements > 0 then
                            local enh_key = allowed_enhancements[math.random(#allowed_enhancements)]
                            if G.P_CENTERS[enh_key] then
                                card:set_ability(G.P_CENTERS[enh_key], nil, true)
                            end
                        end
                    end
                    
                    -- Add SEAL if enabled and chance succeeds
                    if cfg.enable_seal and math.random(100) <= (cfg.seal_chance or 20) then
                        -- Build list of allowed seals
                        local allowed_seals = {}
                        if cfg.allow_red_seal ~= false then table.insert(allowed_seals, 'Red') end
                        if cfg.allow_blue_seal ~= false then table.insert(allowed_seals, 'Blue') end
                        if cfg.allow_gold_seal ~= false then table.insert(allowed_seals, 'Gold') end
                        if cfg.allow_purple_seal ~= false then table.insert(allowed_seals, 'Purple') end
                        
                        if #allowed_seals > 0 then
                            local seal = allowed_seals[math.random(#allowed_seals)]
                            card:set_seal(seal, true)
                        end
                    end
                    
                    -- Add EDITION if enabled and chance succeeds
                    if cfg.enable_edition and math.random(100) <= (cfg.edition_chance or 20) then
                        -- Build list of allowed editions
                        local allowed_editions = {}
                        if cfg.allow_foil ~= false then table.insert(allowed_editions, 'foil') end
                        if cfg.allow_holo ~= false then table.insert(allowed_editions, 'holo') end
                        if cfg.allow_polychrome ~= false then table.insert(allowed_editions, 'polychrome') end
                        
                        if #allowed_editions > 0 then
                            local edition = allowed_editions[math.random(#allowed_editions)]
                            card:set_edition({[edition] = true}, true, true)
                        end
                    end
                    
                    -- Ensure card has proper ID for game mechanics
                    if not card.get_id or type(card.get_id) ~= "function" then
                        -- Add get_id method using proper Balatro card structure
                        card.get_id = function(self)
                            -- Use the rank and suit from the card's base properties
                            local rank = self.base and self.base.value or self.rank or 14
                            local suit = self.base and self.base.suit or self.suit or 'Spades'
                            return tostring(rank) .. suit
                        end
                    end
                end
                
                return true
            end
        }))
    end
}

-- Percentage control callbacks
G.FUNCS.chaos_deck_enhancement_chance = function(e)
    local values = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    current_mod_ref.config.enhancement_chance = values[e.to_key]
end

G.FUNCS.chaos_deck_seal_chance = function(e)
    local values = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    current_mod_ref.config.seal_chance = values[e.to_key]
end

G.FUNCS.chaos_deck_edition_chance = function(e)
    local values = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
    current_mod_ref.config.edition_chance = values[e.to_key]
end

-- Two-column configuration interface to fit everything on screen
SMODS.current_mod.config_tab = function()
    return {
        n = G.UIT.ROOT, 
        config = {r = 0.1, minw = 10, align = "cm", padding = 0.001, colour = G.C.BLACK}, 
        nodes = {
            -- Title
            {n = G.UIT.R, config = {align = "cm", padding = 0.001}, nodes = {
                {n = G.UIT.T, config = {text = "Chaos Deck Settings", scale = 0.38, colour = G.C.UI.TEXT_LIGHT}}
            }},
            
            -- Master Controls with Percentages
            {n = G.UIT.R, config = {align = "cm", padding = 0.001}, nodes = {
                {n = G.UIT.T, config = {text = "Master Controls & Chances", scale = 0.33, colour = G.C.ORANGE}}
            }},
            
            {n = G.UIT.R, config = {align = "cm", padding = 0.001}, nodes = {
                {n = G.UIT.C, config = {align = "cm", padding = 0.003}, nodes = {
                    create_toggle({label = "Enable Enhancements", ref_table = current_mod_ref.config, ref_value = "enabled_enhancement"}),
                    create_toggle({label = "Enable Seals", ref_table = current_mod_ref.config, ref_value = "enable_seal"}),
                    create_toggle({label = "Enable Editions", ref_table = current_mod_ref.config, ref_value = "enable_edition"}),
                }},
                {n = G.UIT.C, config = {align = "cm", padding = 0.003}, nodes = {
                    create_option_cycle({label = "Enhancement %", scale = 0.55, options = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}, opt_callback = 'chaos_deck_enhancement_chance', current_option = (current_mod_ref.config.enhancement_chance or 20) == 10 and 1 or (current_mod_ref.config.enhancement_chance or 20) == 20 and 2 or (current_mod_ref.config.enhancement_chance or 20) == 30 and 3 or (current_mod_ref.config.enhancement_chance or 20) == 40 and 4 or (current_mod_ref.config.enhancement_chance or 20) == 50 and 5 or (current_mod_ref.config.enhancement_chance or 20) == 60 and 6 or (current_mod_ref.config.enhancement_chance or 20) == 70 and 7 or (current_mod_ref.config.enhancement_chance or 20) == 80 and 8 or (current_mod_ref.config.enhancement_chance or 20) == 90 and 9 or 10}),
                    create_option_cycle({label = "Seal %", scale = 0.55, options = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}, opt_callback = 'chaos_deck_seal_chance', current_option = (current_mod_ref.config.seal_chance or 20) == 10 and 1 or (current_mod_ref.config.seal_chance or 20) == 20 and 2 or (current_mod_ref.config.seal_chance or 20) == 30 and 3 or (current_mod_ref.config.seal_chance or 20) == 40 and 4 or (current_mod_ref.config.seal_chance or 20) == 50 and 5 or (current_mod_ref.config.seal_chance or 20) == 60 and 6 or (current_mod_ref.config.seal_chance or 20) == 70 and 7 or (current_mod_ref.config.seal_chance or 20) == 80 and 8 or (current_mod_ref.config.seal_chance or 20) == 90 and 9 or 10}),
                    create_option_cycle({label = "Edition %", scale = 0.55, options = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}, opt_callback = 'chaos_deck_edition_chance', current_option = (current_mod_ref.config.edition_chance or 20) == 10 and 1 or (current_mod_ref.config.edition_chance or 20) == 20 and 2 or (current_mod_ref.config.edition_chance or 20) == 30 and 3 or (current_mod_ref.config.edition_chance or 20) == 40 and 4 or (current_mod_ref.config.edition_chance or 20) == 50 and 5 or (current_mod_ref.config.edition_chance or 20) == 60 and 6 or (current_mod_ref.config.edition_chance or 20) == 70 and 7 or (current_mod_ref.config.edition_chance or 20) == 80 and 8 or (current_mod_ref.config.edition_chance or 20) == 90 and 9 or 10}),
                }},
            }},
            
            -- Two-column layout for detailed controls
            {n = G.UIT.R, config = {align = "tm", padding = 0.001}, nodes = {
                -- LEFT COLUMN
                {n = G.UIT.C, config = {align = "tm", padding = 0.003, minw = 4.5}, nodes = {
                    -- Enhancement Types
                    {n = G.UIT.R, config = {align = "cm", padding = 0.001}, nodes = {
                        {n = G.UIT.T, config = {text = "Enhancement Types", scale = 0.32, colour = G.C.ORANGE}}
                    }},
                    
                    create_toggle({label = "Bonus Card", ref_table = current_mod_ref.config, ref_value = "allow_bonus"}),
                    create_toggle({label = "Mult Card", ref_table = current_mod_ref.config, ref_value = "allow_mult"}),
                    create_toggle({label = "Wild Card", ref_table = current_mod_ref.config, ref_value = "allow_wild"}),
                    create_toggle({label = "Glass Card", ref_table = current_mod_ref.config, ref_value = "allow_glass"}),
                    create_toggle({label = "Gold Card", ref_table = current_mod_ref.config, ref_value = "allow_gold"}),
                    create_toggle({label = "Steel Card", ref_table = current_mod_ref.config, ref_value = "allow_steel"}),
                    create_toggle({label = "Stone Card", ref_table = current_mod_ref.config, ref_value = "allow_stone"}),
                    create_toggle({label = "Lucky Card", ref_table = current_mod_ref.config, ref_value = "allow_lucky"}),
                }},
                
                -- RIGHT COLUMN
                {n = G.UIT.C, config = {align = "tm", padding = 0.003, minw = 4.5}, nodes = {
                    -- Seal Types
                    {n = G.UIT.R, config = {align = "cm", padding = 0.001}, nodes = {
                        {n = G.UIT.T, config = {text = "Seal Types", scale = 0.32, colour = G.C.ORANGE}}
                    }},
                    
                    create_toggle({label = "Red Seal", ref_table = current_mod_ref.config, ref_value = "allow_red_seal"}),
                    create_toggle({label = "Blue Seal", ref_table = current_mod_ref.config, ref_value = "allow_blue_seal"}),
                    create_toggle({label = "Gold Seal", ref_table = current_mod_ref.config, ref_value = "allow_gold_seal"}),
                    create_toggle({label = "Purple Seal", ref_table = current_mod_ref.config, ref_value = "allow_purple_seal"}),
                    
                    -- Edition Types
                    {n = G.UIT.R, config = {align = "cm", padding = 0.001}, nodes = {
                        {n = G.UIT.T, config = {text = "Edition Types", scale = 0.32, colour = G.C.ORANGE}}
                    }},
                    
                    create_toggle({label = "Foil", ref_table = current_mod_ref.config, ref_value = "allow_foil"}),
                    create_toggle({label = "Holographic", ref_table = current_mod_ref.config, ref_value = "allow_holo"}),
                    create_toggle({label = "Polychrome", ref_table = current_mod_ref.config, ref_value = "allow_polychrome"}),
                }},
            }},
        }
    }
end

----------------------------------------------
------------MOD CODE END----------------------
