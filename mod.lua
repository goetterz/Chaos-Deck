--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck (Toggles)
--- MOD_ID: chaos_deck_toggles
--- MOD_AUTHOR: [You]
--- MOD_DESCRIPTION: A deck with toggleable chaos features for stable Steamodded

----------------------------------------------
------------MOD CODE -------------------------

-- Default configuration (no external file for now)
local config = {
    enabled_enhancement = true,
    enable_seal = true,
    enable_edition = true
}

-- Simple Chaos Deck for fresh install
SMODS.Back({
    key = "chaos_deck",
    name = "Chaos Deck", 
    pos = {x = 0, y = 0},
    config = {joker_slot = 1},
    loc_txt = {
        name = "Chaos Deck",
        text = {
            "Start with {C:attention}+1{} Joker slot",
            "A simple test deck",
            "{C:inactive}(Fresh stable install)"
        }
    }
})

----------------------------------------------
------------MOD CODE END----------------------
