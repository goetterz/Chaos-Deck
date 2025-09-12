--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck (Toggles)
--- MOD_ID: chaos_deck_toggles
--- MOD_AUTHOR: [You]
--- MOD_DESCRIPTION: A deck that gives every starting card random seal/enhancement/edition (Negative excluded), with toggles in the Mods menu.
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0821c]

----------------------------------------------
------------MOD CODE -------------------------

SMODS.Back{
    name = "Chaos Deck",
    key = "chaos_deck",
    pos = {x = 0, y = 0},
    loc_txt = {
        name = "Chaos Deck",
        text = {
            "Each starting playing card",
            "gets a random {C:attention}Enhancement{},",
            "a random {C:attention}Seal{}, and a random {C:attention}Edition{}",
            "(Negative excluded).",
            "{C:inactive}(Use Mods → this mod → Config to toggle each){}"
        }
    },
    apply = function(self)
        G.E_MANAGER:add_event(Event({
            func = function()
                -- Try to get configuration, but have safe fallbacks
                local cfg = {}
                if SMODS and SMODS.current_mod and SMODS.current_mod.config then
                    cfg = SMODS.current_mod.config
                else
                    -- Fallback to default config from config.lua if available
                    local config_file = loadfile("Mods/chaos_deck_toggles/config.lua")
                    if config_file then
                        cfg = config_file() or {}
                    end
                end
                
                -- Default values if config not found
                if cfg.enabled_enhancement == nil then cfg.enabled_enhancement = true end
                if cfg.enable_seal == nil then cfg.enable_seal = true end
                if cfg.enable_edition == nil then cfg.enable_edition = true end
                
                -- Process each card in the playing cards table
                for _, card in ipairs(G.playing_cards) do
                    -- Add ENHANCEMENT if enabled
                    if cfg.enabled_enhancement then
                        local enhancements = {
                            'm_bonus', 'm_mult', 'm_wild', 'm_glass',
                            'm_gold', 'm_steel', 'm_stone', 'm_lucky'
                        }
                        local enh_key = enhancements[math.random(#enhancements)]
                        if G.P_CENTERS[enh_key] then
                            card:set_ability(G.P_CENTERS[enh_key], nil, true)
                        end
                    end
                    
                    -- Add SEAL if enabled
                    if cfg.enable_seal then
                        local seals = {'Red', 'Blue', 'Gold', 'Purple'}
                        local seal = seals[math.random(#seals)]
                        card:set_seal(seal, true)
                    end
                    
                    -- Add EDITION if enabled (using safe method)
                    if cfg.enable_edition then
                        local editions = {'foil', 'holo', 'polychrome'}
                        local edition = editions[math.random(#editions)]
                        card:set_edition({[edition] = true}, true, true)
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

----------------------------------------------
------------MOD CODE END----------------------
