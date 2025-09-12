--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck (Toggles)
--- MOD_ID: chaos_deck_toggles
--- MOD_AUTHOR: [You]
--- MOD_DESCRIPTION: A deck that gives every starting card random seal/enhancement/edition (Negative excluded), with toggles in the Mods menu.
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0909a]

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
        -- Get configuration with safe fallback
        local cfg = {
            enabled_enhancement = true,
            enable_seal = true,
            enable_edition = true
        }
        
        -- Try to load config from file
        local success, config_result = pcall(function()
            return loadfile("Mods/chaos_deck_toggles/config.lua")()
        end)
        if success and config_result then
            cfg = config_result
        end
        
        -- Wait for full deck initialization, then rebuild it completely
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            delay = 1.5,
            func = function()
                -- Create a completely fresh deck to avoid any metatable corruption
                local suits = {'Hearts', 'Diamonds', 'Clubs', 'Spades'}
                local ranks = {'2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'}
                local fresh_cards = {}
                
                -- Build new deck composition
                for _, suit in ipairs(suits) do
                    for _, rank in ipairs(ranks) do
                        table.insert(fresh_cards, {rank = rank, suit = suit})
                    end
                end
                
                -- Clear existing deck completely
                G.playing_cards = {}
                G.deck.cards = {}
                
                -- Create entirely new cards
                for i = 1, 52 do
                    local card_info = fresh_cards[i]
                    
                    -- Start with base parameters
                    local card_params = {
                        set = "Base",
                        rank = card_info.rank,
                        suit = card_info.suit,
                        area = G.deck
                    }
                    
                    -- Apply modifications during creation to avoid corruption
                    if cfg.enable_seal then
                        local seals = {'Red', 'Blue', 'Gold', 'Purple'}
                        card_params.seal = seals[math.random(#seals)]
                    end
                    
                    if cfg.enabled_enhancement then
                        local enhancements = {'m_bonus', 'm_mult', 'm_wild', 'm_glass', 'm_steel', 'm_stone', 'm_gold', 'm_lucky'}
                        card_params.enhancement = enhancements[math.random(#enhancements)]
                        card_params.set = "Enhanced"
                    end
                    
                    if cfg.enable_edition then
                        local editions = {
                            {foil = true},
                            {holo = true}, 
                            {polychrome = true}
                        }
                        card_params.edition = editions[math.random(#editions)]
                    end
                    
                    -- Create completely fresh card with modifications built-in
                    G.playing_card = (G.playing_card and G.playing_card + 1) or 1
                    local new_card = SMODS.create_card(card_params)
                    new_card.playing_card = G.playing_card
                    
                    -- Add to deck structures
                    new_card:add_to_deck()
                    table.insert(G.playing_cards, new_card)
                    G.deck:emplace(new_card)
                end
                
                -- Update deck properties
                G.deck.config.card_limit = #G.playing_cards
                
                return true
            end
        }))
    end
}

----------------------------------------------
------------MOD CODE END----------------------
