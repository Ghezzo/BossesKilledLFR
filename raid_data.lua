local _, addon = ...

-- Index is from the first argument of DungeonInfoFunc.
-- This data table is needed as there's no way to find out how many encounters are in each part of the same raid (to my knowledge).
addon.raidData = {    
    -- Vaults of the Incarnates
    [2370] = { numEncounters = 3, startFrom =  1 },
    [2371] = { numEncounters = 3, startFrom =  1 },
    [2372] = { numEncounters = 2, startFrom =  1 },
    
    -- Aberrus
    [2399] = { numEncounters = 3, startFrom =  1 },
    [2400] = { numEncounters = 3, startFrom =  1 },
    [2401] = { numEncounters = 2, startFrom =  1 },
    [2402] = { numEncounters = 1, startFrom =  1 },
    
     -- Amirdrassil
    [2466] = { numEncounters = 3, startFrom =  1 },
    [2467] = { numEncounters = 2, startFrom =  1 },
    [2468] = { numEncounters = 2, startFrom =  1 },
    [2469] = { numEncounters = 2, startFrom =  1 },

    -- Vaults of the Incarnates Awakened
    [2703] = { numEncounters = 3, startFrom =  1 },
    [2705] = { numEncounters = 3, startFrom =  1 },
    [2706] = { numEncounters = 2, startFrom =  1 },
    
    -- Aberrus Awakened
    [2704] = { numEncounters = 3, startFrom =  1 },
    [2707] = { numEncounters = 3, startFrom =  1 },
    [2708] = { numEncounters = 2, startFrom =  1 },
    [2709] = { numEncounters = 1, startFrom =  1 },
    
        -- Amirdrassil Awakened
    [2710] = { numEncounters = 3, startFrom =  1 },
    [2711] = { numEncounters = 2, startFrom =  1 },
    [2712] = { numEncounters = 2, startFrom =  1 },
    [2713] = { numEncounters = 2, startFrom =  1 },
}