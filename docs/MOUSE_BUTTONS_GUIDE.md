# Mouse Button Binding Guide for Project Zomboid

## Yes! You CAN bind middle mouse button (and other mouse buttons)

Project Zomboid supports binding mouse buttons including the middle mouse button (scroll wheel click) and additional mouse buttons (4, 5, etc.).

## Mouse Button Constants

From `zombie.input.Mouse.java`:

```java
public static final int BTN_OFFSET = 10000;
public static final int BTN_0 = 10000;  // Left Mouse Button
public static final int BTN_1 = 10001;  // Right Mouse Button
public static final int BTN_2 = 10002;  // Middle Mouse Button (Scroll Wheel Click)
public static final int BTN_3 = 10003;  // Mouse Button 4
public static final int BTN_4 = 10004;  // Mouse Button 5
public static final int BTN_5 = 10005;  // Mouse Button 6
public static final int BTN_6 = 10006;  // Mouse Button 7
public static final int BTN_7 = 10007;  // Mouse Button 8

// Aliases
public static final int LMB = 10000;
public static final int RMB = 10001;
public static final int MMB = 10002;  // THIS IS THE MIDDLE MOUSE BUTTON!
```

## Available in Lua

```lua
-- Mouse button constants are available in Lua:
Mouse.LMB   -- 10000 (Left Mouse Button)
Mouse.RMB   -- 10001 (Right Mouse Button)
Mouse.MMB   -- 10002 (Middle Mouse Button / Scroll Wheel Click)
Mouse.BTN_0 -- 10000 (same as LMB)
Mouse.BTN_1 -- 10001 (same as RMB)
Mouse.BTN_2 -- 10002 (same as MMB)
Mouse.BTN_3 -- 10003 (extra button 4)
Mouse.BTN_4 -- 10004 (extra button 5)
-- etc...
Mouse.BTN_OFFSET -- 10000 (base offset for mouse buttons)
```

## Detection Methods

### Method 1: Direct State Check (For UI Elements)
```lua
-- Check if middle mouse button is currently down
if Mouse.isMiddleDown() then
    -- Middle mouse button is pressed
end

-- Check if middle mouse button was just pressed
if Mouse.isMiddlePressed() then
    -- Middle mouse button was just clicked
end

-- Check if middle mouse button was just released
if Mouse.isMiddleReleased() then
    -- Middle mouse button was just released
end

-- Check if middle mouse button is up (not pressed)
if Mouse.isMiddleUp() then
    -- Middle mouse button is not pressed
end
```

### Method 2: onMouseUp Override (For ISPanel-derived classes)
```lua
-- In your ISForageIcon or ISBaseIcon class
function ISForageIcon:onMouseUp(x, y)
    -- Check which button was released
    if Mouse.isMiddleReleased() then
        -- Handle middle mouse button click
        self:onClickDiscard(0, 0, nil);
        return true;
    end

    -- Call original if needed
    return false;
end
```

### Method 3: OnKeyPressed Event (Global)
```lua
-- Middle mouse button triggers OnKeyPressed with value 10002
Events.OnKeyPressed.Add(function(key)
    if key == Mouse.MMB then  -- or key == 10002
        print("Middle mouse button pressed!")
        -- Your code here
    end
end)

-- Also triggers OnKeyStartPressed when first pressed
Events.OnKeyStartPressed.Add(function(key)
    if key == Mouse.MMB then
        print("Middle mouse button started!")
    end
end)
```

### Method 4: onMouseButtonDown (For Extra Mouse Events)
```lua
-- Requires setWantExtraMouseEvents(true) on your UI element
function YourUIElement:onMouseButtonDown(btn)
    -- btn is the button index (0, 1, 2, 3, etc.)
    -- Convert to full button code
    local buttonCode = Mouse.BTN_OFFSET + btn

    if buttonCode == Mouse.MMB then
        -- Middle mouse button clicked
        print("Middle mouse button!")
        return true
    end
end

-- Enable extra mouse events in constructor
function YourUIElement:new(...)
    local o = ISPanel:new(...)
    o:setWantExtraMouseEvents(true)  -- REQUIRED for onMouseButtonDown
    return o
end
```

## Key Binding Support

Middle mouse button can be bound in the keybindings system:

```lua
-- From keyBinding.lua example
bind = {}
bind.value = "Attack/Click"
bind.key = Mouse.LMB  -- Left mouse button
table.insert(keyBinding, bind)

bind = {}
bind.value = "Aim"
bind.key = Keyboard.KEY_LCONTROL
bind.alt = Mouse.RMB  -- Right mouse button as alternative
table.insert(keyBinding, bind)

-- You can do the same with MMB
bind = {}
bind.value = "QuickDiscard"  -- Your custom action
bind.key = Mouse.MMB  -- Middle mouse button!
table.insert(keyBinding, bind)
```

## Practical Example: RMB or MMB to Discard Forage Items

```lua
-- Override onMouseUp in ISForageIcon
local originalOnMouseUp = ISForageIcon.onMouseUp

function ISForageIcon:onMouseUp(x, y)
    -- Check for middle mouse button click
    if Mouse.isMiddleReleased() and self:getIsSeen() and self:getAlpha() > 0 then
        self:onClickDiscard(0, 0, nil);
        return true;
    end

    -- Call original behavior
    if originalOnMouseUp then
        return originalOnMouseUp(self, x, y)
    end
    return false;
end

-- Alternative: Override onRightMouseUp for RMB
local originalOnRightMouseUp = ISForageIcon.onRightMouseUp

function ISForageIcon:onRightMouseUp()
    if self:getIsSeen() and self:getAlpha() > 0 then
        -- Right mouse button = discard
        self:onClickDiscard(0, 0, nil);
        return true;
    end
    return false;
end
```

## Advanced: Detecting Any Mouse Button

```lua
-- Check any mouse button state
function checkMouseButton(buttonIndex)
    if Mouse.isButtonDown(buttonIndex) then
        return true
    end
    return false
end

-- Example usage
if checkMouseButton(2) then  -- Check middle mouse (button index 2)
    print("Middle mouse is down!")
end

-- Or use the button code directly
if Mouse.isButtonDown(2) then  -- Same as isMiddleDown()
    print("Button 2 (middle) is down!")
end
```

## Important Notes

1. **Button Indices vs Button Codes:**
   - Button Index: 0, 1, 2, 3, ... (for `isButtonDown(index)`)
   - Button Code: 10000, 10001, 10002, 10003, ... (for key events)
   - MMB Index: `2`
   - MMB Code: `10002` or `Mouse.MMB`

2. **Mouse wheel scroll is different from middle mouse button:**
   - Mouse wheel scroll: `onMouseWheel(del)` event
   - Middle mouse click: Button 2 / `Mouse.MMB`

3. **UI Capture:**
   - Mouse buttons can be captured by UI elements
   - Check `Mouse.UICaptured[buttonIndex]` to see if UI consumed the button

4. **Extra Mouse Events:**
   - Must call `setWantExtraMouseEvents(true)` to receive `onMouseButtonDown` events
   - See `ISSetKeybindDialog.lua` for reference implementation

## Testing

```lua
-- Simple test to detect middle mouse clicks globally
Events.OnKeyPressed.Add(function(key)
    if key == Mouse.MMB then
        print("=== MIDDLE MOUSE CLICKED! ===")
        print("Key code:", key)
        print("isMiddleDown:", Mouse.isMiddleDown())
    end
end)
```

## Summary for ForageFlow Mod

**To bind middle mouse button for discarding forage items:**

1. Override `ISForageIcon:onMouseUp(x, y)`
2. Check `Mouse.isMiddleReleased()`
3. Call `self:onClickDiscard(0, 0, nil)`
4. Return `true` to consume the event

**Alternative: Use RMB (right mouse button):**
- Override `ISForageIcon:onRightMouseUp()`
- This is simpler and already has the event handler in place
- Just needs to call discard instead of showing context menu

Both approaches work! MMB is available if you prefer it.
