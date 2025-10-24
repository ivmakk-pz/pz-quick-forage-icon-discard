-- Quick Forage Icon Discard Main Client File
-- Author: ivmakk
-- Version: 1.0.0

-- Print mod loading message
print("[Quick Forage Icon Discard] Loading client-side components...")

-- Main mod initialization
local QuickForageIconDiscard = {}

-- Initialize the mod
function QuickForageIconDiscard.init()
    print("[Quick Forage Icon Discard] Client initialization complete")
end

-- Hook into game events
Events.OnGameStart.Add(QuickForageIconDiscard.init)

return QuickForageIconDiscard
