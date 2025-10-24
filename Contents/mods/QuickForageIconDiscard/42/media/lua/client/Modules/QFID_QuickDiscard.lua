-- QFID_QuickDiscard - Quick Discard Module
-- Implements quick discard on RMB and context menu on middle mouse button

require "Foraging/ISForageIcon"

local QFID_Utils = require("QFID_Utils")
local QFID_ModOptions = require("QFID_ModOptions")
local QFID_ModuleBase = require("Core/QFID_ModuleBase")

-- ===================================================================================================== --
-- MODULE SETUP USING QFID_ModuleBase PATTERN
-- ===================================================================================================== --

local QFID_QuickDiscard = QFID_ModuleBase:derive("QFID_QuickDiscard")
local instance = QFID_QuickDiscard:new()

-- ===================================================================================================== --
-- ISFORAGEICON OVERRIDE FUNCTIONS
-- ===================================================================================================== --

---Handle right mouse button based on configuration
---Priority: If both options use same button, discard takes priority
---@param self ISForageIcon
---@param x number
---@param y number
---@return boolean
local function ISForageIcon_onRightMouseDown(self, x, y)
    -- Check if icon is visible and interactable
    if self:getIsSeen() and self:getAlpha() > 0 then
        local discardButton = QFID_ModOptions.getDiscardButton()
        local contextMenuButton = QFID_ModOptions.getContextMenuButton()
        
        -- Priority: Discard takes priority if both use RMB
        if discardButton == Mouse.RMB then
            QFID_Utils.logDebug("Quick discard triggered via RMB for: " .. tostring(self.itemType))
            self:onClickDiscard(x, y, nil)
            return true
        -- RMB is context menu button (only if not also discard button)
        elseif contextMenuButton == Mouse.RMB then
            QFID_Utils.logDebug("Context menu triggered via RMB for: " .. tostring(self.itemType))
            self:doContextMenu()
            return true
        end
    end
    
    -- Call original if RMB not used by this mod
    local originalHandler = instance:getOriginal("onRightMouseDown", ISForageIcon)
    if originalHandler then
        return originalHandler(self, x, y)
    end
    
    return false
end

---Suppress default context menu on RMB Up if RMB is used by this mod
---@param self ISForageIcon
---@return boolean
local function ISForageIcon_onRightMouseUp(self)
    local discardButton = QFID_ModOptions.getDiscardButton()
    local contextMenuButton = QFID_ModOptions.getContextMenuButton()
    
    -- Suppress default context menu if RMB is used for discard or context menu
    if discardButton == Mouse.RMB or contextMenuButton == Mouse.RMB then
        return false
    end
    
    -- Call original if RMB not used by this mod
    local originalHandler = instance:getOriginal("onRightMouseUp", ISForageIcon)
    if originalHandler then
        return originalHandler(self)
    end
    
    return false
end

---Handle left mouse button based on configuration
---LMB removed from options to avoid conflict with default grab action
---@param self ISForageIcon
---@param x number
---@param y number
---@return boolean
local function ISForageIcon_onMouseDown(self, x, y)
    -- LMB no longer configurable - always call original (grab item)
    local originalHandler = instance:getOriginal("onMouseDown", ISForageIcon)
    if originalHandler then
        return originalHandler(self, x, y)
    end
    
    return false
end

---Handle extra mouse buttons (MMB, MB4, MB5) based on configuration
---Priority: If both options use same button, discard takes priority
---@param self ISForageIcon
---@param btn number Mouse button code (2=MMB, 3=MB4, 4=MB5)
---@return boolean
local function ISForageIcon_onMouseButtonDown(self, btn)
    if self:getIsSeen() and self:getAlpha() > 0 then
        -- Convert button index to button code
        local buttonCode = Mouse.BTN_OFFSET + btn
        local discardButton = QFID_ModOptions.getDiscardButton()
        local contextMenuButton = QFID_ModOptions.getContextMenuButton()
        
        -- Priority: Discard takes priority if both use same button
        if buttonCode == discardButton then
            QFID_Utils.logDebug("Quick discard triggered via button " .. btn .. " for: " .. tostring(self.itemType))
            self:onClickDiscard(0, 0, nil)
            return true
        -- Check if this button is context menu button (only if not also discard button)
        elseif buttonCode == contextMenuButton then
            QFID_Utils.logDebug("Context menu triggered via button " .. btn .. " for: " .. tostring(self.itemType))
            self:doContextMenu()
            return true
        end
    end
    
    -- Call original handler for unassigned buttons
    local originalHandler = instance:getOriginal("onMouseButtonDown", ISForageIcon)
    if originalHandler then
        return originalHandler(self, btn)
    end
    
    return false
end

---Enhanced initialise to enable extra mouse events
---@param self ISForageIcon
local function ISForageIcon_initialise(self)
    -- Call original initialise first
    local originalInitialise = instance:getOriginal("initialise", ISForageIcon)
    if originalInitialise then
        originalInitialise(self)
    end
    
    -- Enable extra mouse events to receive onMouseButtonDown calls
    if self.setWantExtraMouseEvents then
        self:setWantExtraMouseEvents(true)
        QFID_Utils.logDebug("Enabled extra mouse events for quick discard on: " .. tostring(self.itemType))
    else
        QFID_Utils.logWarning("setWantExtraMouseEvents not available on ISForageIcon")
    end
end

-- ===================================================================================================== --
-- MODULE SETUP LOGIC
-- ===================================================================================================== --

---Setup module with vanilla function overrides using safe QFID_ModuleBase pattern
function QFID_QuickDiscard:setupModule()
    if not ISForageIcon then
        QFID_Utils.logError("ISForageIcon not found - quick discard will not work!")
        return
    end
    
    QFID_Utils.logInfo("Setting up Quick Discard module...")
    
    -- Override initialise to enable extra mouse events
    if ISForageIcon.initialise then
        self:overrideFunction(ISForageIcon, "initialise", ISForageIcon_initialise)
        QFID_Utils.logInfo("Successfully hooked ISForageIcon.initialise")
    else
        QFID_Utils.logError("ISForageIcon.initialise not found!")
    end
    
    -- Override Left Mouse Button handlers
    if not ISForageIcon.onMouseDown then
        ISForageIcon.onMouseDown = function() return false end
    end
    self:overrideFunction(ISForageIcon, "onMouseDown", ISForageIcon_onMouseDown)
    QFID_Utils.logInfo("Successfully hooked ISForageIcon.onMouseDown (LMB)")
    
    -- Override Right Mouse Button handlers
    if ISForageIcon.onRightMouseDown then
        self:overrideFunction(ISForageIcon, "onRightMouseDown", ISForageIcon_onRightMouseDown)
        QFID_Utils.logInfo("Successfully hooked ISForageIcon.onRightMouseDown (RMB)")
    end
    
    if ISForageIcon.onRightMouseUp then
        self:overrideFunction(ISForageIcon, "onRightMouseUp", ISForageIcon_onRightMouseUp)
        QFID_Utils.logInfo("Successfully hooked ISForageIcon.onRightMouseUp (RMB)")
    end
    
    -- Override onMouseButtonDown for MMB/MB4/MB5
    if not ISForageIcon.onMouseButtonDown then
        ISForageIcon.onMouseButtonDown = function() return false end
    end
    self:overrideFunction(ISForageIcon, "onMouseButtonDown", ISForageIcon_onMouseButtonDown)
    QFID_Utils.logInfo("Successfully hooked ISForageIcon.onMouseButtonDown (MMB/MB4/MB5)")
    
    QFID_Utils.logInfo("Quick Discard module setup complete!")
end

-- ===================================================================================================== --
-- MODULE EXPORT
-- ===================================================================================================== --

return {
    initialise = function() return instance:initialise(function(self) self:setupModule() end) end,
    destroy = function() return instance:destroy() end,
    isActive = function() return instance:isActive() end,
    getInstance = function() return instance end
}
