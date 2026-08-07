-- QFID_QuickDiscard - Quick Discard Module
-- Implements quick discard on RMB and context menu on middle mouse button

require "Foraging/ISForageIcon"
require "Foraging/ISSearchManager"

local QFID_Utils = require("QFID_Utils")
local QFID_ModOptions = require("QFID_ModOptions")
local QFID_ModuleBase = require("Core/QFID_ModuleBase")

-- ===================================================================================================== --
-- MULTIPLAYER DISCARD STATE
-- ===================================================================================================== --

-- 42.20 made foraging server-authoritative: the client polls the server every ~2s and
-- ISSearchManager:applyServerPool re-materialises any icon id missing from self.forageIcons.
-- A client-side discard never reaches the server pool, so the icon reappears within ~2s.
-- Track ids we discarded this session and suppress them in an applyServerPool override.
-- Keys are getRandomUUID() icon ids, so this is a small session-local set (cleared on game
-- restart) that never needs pruning - reuse/collision does not happen.
---@type table<string, true>
local QFID_discardedIconIds = {}

-- ===================================================================================================== --
-- MODULE SETUP USING QFID_ModuleBase PATTERN
-- ===================================================================================================== --

local QFID_QuickDiscard = QFID_ModuleBase:derive("QFID_QuickDiscard")
local instance = QFID_QuickDiscard:new()

-- ===================================================================================================== --
-- CUSTOM DISCARD IMPLEMENTATION
-- ===================================================================================================== --

---Custom discard implementation (vanilla onClickDiscard was removed in Build 42.13)
---Removes the forage icon from display and marks it as discarded in zone data
---@param icon ISForageIcon The forage icon to discard
---@param x number Mouse X coordinate (unused, kept for API compatibility)
---@param y number Mouse Y coordinate (unused, kept for API compatibility)
---@param contextOption any Context menu option (optional, will hide if provided)
local function QFID_customDiscardIcon(icon, x, y, contextOption)
    -- Hide context menu if provided
    if contextOption then 
        contextOption:hideAndChildren() 
    end
    
    -- Validate icon has required data
    if not icon or not icon.iconID then
        QFID_Utils.logDebug("Cannot discard - invalid icon object")
        return
    end
    
    -- Flag icon for removal (prevents race conditions)
    if icon.setIsBeingRemoved then
        icon:setIsBeingRemoved(true)
    end
    
    -- Remove from zone data and update clients (handles multiplayer sync)
    if icon.manager then
        -- removeItem handles zone data updates via forageSystem and forageClient
        icon.manager:removeItem(icon)
        -- removeIcon removes from UI and internal tracking
        icon.manager:removeIcon(icon)
        -- Remember it so the 42.20 server pool can't re-materialise it (see applyServerPool override)
        QFID_discardedIconIds[icon.iconID] = true
    else
        QFID_Utils.logWarning("Icon has no manager reference: " .. tostring(icon.iconID))
    end
    
    -- Trigger update event for other listeners (multiplayer sync)
    triggerEvent("onUpdateIcon", icon.zoneData, icon.iconID, nil)
end

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
            QFID_customDiscardIcon(self, x, y, nil)
            return true
        -- RMB is context menu button (only if not also discard button)
        elseif contextMenuButton == Mouse.RMB then
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

---Handle extra mouse buttons (MMB, MB4, MB5) based on configuration
---Priority: If both options use same button, discard takes priority
---@param self ISForageIcon
---@param btn number Mouse button code (2=MMB, 3=MB4, 4=MB5)
---@return boolean
local function ISForageIcon_onMouseButtonDown(self, btn)
    if self:getIsSeen() and self:getAlpha() > 0 then
        local buttonCode = Mouse.BTN_OFFSET + btn
        local discardButton = QFID_ModOptions.getDiscardButton()
        local contextMenuButton = QFID_ModOptions.getContextMenuButton()

        -- Priority: Discard takes priority if both use same button
        if discardButton ~= QFID_Utils.BUTTON_NONE and buttonCode == discardButton then
            QFID_customDiscardIcon(self, 0, 0, nil)
        -- Check if this button is context menu button (only if not also discard button)
        elseif buttonCode == contextMenuButton then
            self:doContextMenu()
        end
    end
    
    -- Call original handler for unassigned buttons
    local originalHandler = instance:getOriginal("onMouseButtonDown", ISForageIcon)
    if originalHandler then
        return originalHandler(self, btn)
    end
    
    return false
end

---Initialise to enable extra mouse events
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
    else
        QFID_Utils.logWarning("setWantExtraMouseEvents not available on ISForageIcon")
    end
end

---Suppress server-pool re-materialisation of icons discarded this session (42.20+ MP)
---Vanilla applyServerPool recreates any icon id not in self.forageIcons; strip our
---discarded ids from the incoming pool before the original runs. Only exists on 42.20+;
---on older builds the override is skipped because the vanilla function is absent.
---@param self ISSearchManager
---@param zoneId unknown Zone id (passed through unchanged)
---@param icons table<string, table>|nil Server-supplied icon pool, keyed by icon id
local function ISSearchManager_applyServerPool(self, zoneId, icons)
    if icons then
        -- Iterate the (bounded) incoming pool, not the session-wide discard set which
        -- grows with every discard. Clearing the current key mid-traversal is allowed in Lua 5.1.
        -- Safe to mutate: icons is a per-call table decoded from the pool packet.
        for iconID in pairs(icons) do
            if QFID_discardedIconIds[iconID] then
                icons[iconID] = nil
            end
        end
    end

    local original = instance:getOriginal("applyServerPool", ISSearchManager)
    if original then
        return original(self, zoneId, icons)
    end
end

-- ===================================================================================================== --
-- MODULE SETUP LOGIC
-- ===================================================================================================== --

---Setup module with vanilla function overrides using safe QFID_ModuleBase pattern
function QFID_QuickDiscard:setupModule()
    -- Override initialise to enable extra mouse events
    self:overrideFunction(ISForageIcon, "initialise", ISForageIcon_initialise)
    
    -- Override Right Mouse Button handlers
    self:overrideFunction(ISForageIcon, "onRightMouseDown", ISForageIcon_onRightMouseDown)
    self:overrideFunction(ISForageIcon, "onRightMouseUp", ISForageIcon_onRightMouseUp)
    
    -- Create stub for onMouseButtonDown (vanilla doesn't define it, but we need it for overrideFunction to succeed)
    ISForageIcon.onMouseButtonDown = ISForageIcon.onMouseButtonDown or function() return false end
    self:overrideFunction(ISForageIcon, "onMouseButtonDown", ISForageIcon_onMouseButtonDown)

    -- Keep discards from reappearing under 42.20+ server-authoritative foraging (no-op on <42.20)
    self:overrideFunction(ISSearchManager, "applyServerPool", ISSearchManager_applyServerPool)

    QFID_Utils.logInfo("Quick Discard module initialized successfully")
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
