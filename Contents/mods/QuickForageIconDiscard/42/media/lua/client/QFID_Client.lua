-- Quick Forage Icon Discard Main Client File
-- Author: ivmakk
-- Version: 1.4.2

local QFID_Utils = require "QFID_Utils"
local QFID_ModOptions = require "QFID_ModOptions"
local QFID_QuickDiscard = require "Modules/QFID_QuickDiscard"
local QFID_Tooltip = require "Modules/QFID_Tooltip"

local QuickForageIconDiscard = {}

function QuickForageIconDiscard.init()
    QFID_Utils.logInfo("Quick Forage Icon Discard v" .. QFID_Utils.MOD_VERSION .. " - Initializing...")
    
    QFID_QuickDiscard.initialise()
    QFID_Tooltip.initialise()
    
    QFID_Utils.logInfo("Client initialization complete")
end

-- Register mod options at game boot, before any options screen (main-menu or
-- in-game) builds and calls PZAPI.ModOptions:load(). OnCreateUI never fires at
-- the title screen, so registering there leaves the options unregistered: they
-- don't show on the main-menu screen, and a title-screen save of another mod's
-- options parks QFID's saved lines in OtherOptions, where a vanilla save() bug
-- concatenates them into one corrupt line and wipes the values. pcall keeps a
-- failure falling back to hardcoded defaults.
function QuickForageIconDiscard.initModOptions()
    local ok, err = pcall(function()
        QFID_ModOptions.initialize()
    end)
    
    if not ok then
        QFID_Utils.logError("[CLIENT-PROTECTION] ModOptions initialization failed: " .. tostring(err))
        QFID_Utils.logInfo("[FALLBACK] ModOptions disabled - using hardcoded default values")
    end
end

-- Hook into game events
Events.OnGameStart.Add(QuickForageIconDiscard.init)
Events.OnGameBoot.Add(QuickForageIconDiscard.initModOptions)

return QuickForageIconDiscard
