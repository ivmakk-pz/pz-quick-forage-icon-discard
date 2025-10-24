-- QFID_ModOptions - Mod Options Configuration
-- Configuration options for Quick Forage Icon Discard

local QFID_Utils = require("QFID_Utils")

-- Constants
local DEFAULT_OPTION_MARKER = " *"

local QFID_ModOptions = {
    discardButtonOption = nil,
    contextMenuButtonOption = nil,
    showTooltipOption = nil,
}

-- ===================================================================================================== --
-- OPTION ACCESS FUNCTIONS
-- ===================================================================================================== --

---Get the discard button binding
---@return number buttonCode Mouse button code (10001=RMB, 10002=MMB, etc.)
function QFID_ModOptions.getDiscardButton()
    local value = QFID_ModOptions.discardButtonOption and QFID_ModOptions.discardButtonOption:getValue() or 1
    -- Map index to button code: 1=RMB, 2=MMB, 3-4=Side buttons (LMB removed to avoid conflict with grab)
    local buttons = {Mouse.RMB, Mouse.MMB, Mouse.BTN_3, Mouse.BTN_4}
    return buttons[value] or Mouse.RMB
end

---Get the context menu button binding
---@return number buttonCode Mouse button code (10001=RMB, 10002=MMB, etc.)
function QFID_ModOptions.getContextMenuButton()
    local value = QFID_ModOptions.contextMenuButtonOption and QFID_ModOptions.contextMenuButtonOption:getValue() or 2
    -- Map index to button code: 1=RMB, 2=MMB, 3-4=Side buttons (LMB removed to avoid conflict with grab)
    local buttons = {Mouse.RMB, Mouse.MMB, Mouse.BTN_3, Mouse.BTN_4}
    return buttons[value] or Mouse.MMB
end

---Get whether to show tooltips on hover
---@return boolean showTooltip Whether to show item name tooltip on hover
function QFID_ModOptions.getShowTooltip()
    if QFID_ModOptions.showTooltipOption then
        return QFID_ModOptions.showTooltipOption:getValue()
    else
        return true  -- Default enabled when not initialized
    end
end

-- ===================================================================================================== --
-- MOD OPTIONS INITIALIZATION
-- ===================================================================================================== --

---Initialize mod options when the game starts
function QFID_ModOptions.initialize()
    if not PZAPI or not PZAPI.ModOptions then
        QFID_Utils.logWarning("ModOptions API not available, using default values")
        return
    end
    
    QFID_Utils.logInfo("Initializing mod options...")
    
    -- Create the mod options object
    local options = PZAPI.ModOptions:create("Ivmakk_QuickForageIconDiscard", "Quick Forage Icon Discard")
    
    -- Discard button option
    QFID_ModOptions.discardButtonOption = options:addComboBox(
        "discardButton",
        getText("UI_options_QFID_discardButton")
    )
    QFID_ModOptions.discardButtonOption:addItem(getText("UI_options_QFID_button_RMB") .. DEFAULT_OPTION_MARKER, true)   -- RMB (default)
    QFID_ModOptions.discardButtonOption:addItem(getText("UI_options_QFID_button_MMB"), false)  -- MMB
    QFID_ModOptions.discardButtonOption:addItem(getText("UI_options_QFID_button_MB4"), false)  -- Mouse Button 4
    QFID_ModOptions.discardButtonOption:addItem(getText("UI_options_QFID_button_MB5"), false)  -- Mouse Button 5
    
    -- Context menu button option
    QFID_ModOptions.contextMenuButtonOption = options:addComboBox(
        "contextMenuButton",
        getText("UI_options_QFID_contextMenuButton")
    )
    QFID_ModOptions.contextMenuButtonOption:addItem(getText("UI_options_QFID_button_RMB_default"), false)  -- RMB (game default)
    QFID_ModOptions.contextMenuButtonOption:addItem(getText("UI_options_QFID_button_MMB") .. DEFAULT_OPTION_MARKER, true)  -- MMB (default)
    QFID_ModOptions.contextMenuButtonOption:addItem(getText("UI_options_QFID_button_MB4"), false)          -- Mouse Button 4
    QFID_ModOptions.contextMenuButtonOption:addItem(getText("UI_options_QFID_button_MB5"), false)          -- Mouse Button 5
    
    -- Show tooltip option
    QFID_ModOptions.showTooltipOption = options:addTickBox(
        "showTooltip",
        getText("UI_options_QFID_showTooltip"),
        true  -- Default enabled
    )
    
    QFID_Utils.logInfo("Mod options initialized successfully")
end

return QFID_ModOptions
