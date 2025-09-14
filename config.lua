return {
    -- Master toggles for each modification type
    enabled_enhancement = true, -- Enable/disable enhancement modifications
    enable_seal = true, -- Enable/disable seal modifications  
    enable_edition = true, -- Enable/disable edition modifications
    
    -- Chance percentages (0-100) for each modification to be applied
    enhancement_chance = 20, -- Percentage chance each card gets an enhancement
    seal_chance = 20, -- Percentage chance each card gets a seal
    edition_chance = 20, -- Percentage chance each card gets an edition
    
    -- Individual enhancement toggles
    allow_bonus = true, -- Bonus Card (+30 chips)
    allow_mult = true, -- Mult Card (+4 mult)
    allow_wild = true, -- Wild Card (can be any suit)
    allow_glass = true, -- Glass Card (X2 mult, 1 in 4 chance to destroy)
    allow_gold = true, -- Gold Card (+3 dollars when scored)
    allow_steel = true, -- Steel Card (X1.5 mult)
    allow_stone = true, -- Stone Card (+50 chips, no suit)
    allow_lucky = true, -- Lucky Card (1 in 5 chance for +20 mult and +15 dollars)
    
    -- Individual seal toggles
    allow_red_seal = true, -- Red Seal (retrigger card)
    allow_blue_seal = true, -- Blue Seal (creates Planet card)
    allow_gold_seal = true, -- Gold Seal (+3 dollars)
    allow_purple_seal = true, -- Purple Seal (creates Tarot card)
    
    -- Individual edition toggles
    allow_foil = true, -- Foil (+50 chips)
    allow_holo = true, -- Holographic (+10 mult)
    allow_polychrome = true, -- Polychrome (X1.5 mult)
}