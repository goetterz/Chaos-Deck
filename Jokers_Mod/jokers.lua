--- STEAMODDED HEADER
--- MOD_NAME: Chaos Deck Jokers
--- MOD_ID: chaos_deck_jokers
--- MOD_AUTHOR: [Caveman5880]
--- MOD_DESCRIPTION: Custom jokers for the Chaos Deck mod
--- DEPENDENCIES: [Steamodded>=1.0.0~BETA-0821c]

----------------------------------------------
------------JOKERS MOD LOADER-----------------

-- Register custom sounds for this mod
SMODS.Sound({
    key = "chaos_deck_jokers_eating",
    path = "eating.ogg" -- Will look in assets/sounds/eating.ogg
})

SMODS.Sound({
    key = "chaos_deck_jokers_hungry_growl", 
    path = "hungry_growl.ogg" -- Will look in assets/sounds/hungry_growl.ogg
})

-- Load individual joker files
local mod_path = SMODS.current_mod.path
dofile(mod_path .. "jokers/alec_mukbang.lua")
dofile(mod_path .. "jokers/minecraft_phase.lua")
dofile(mod_path .. "jokers/spell_map.lua")

----------------------------------------------
------------JOKERS MOD LOADER END--------------