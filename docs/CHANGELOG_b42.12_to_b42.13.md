# Quick Forage Icon Discard - Changelog for b42.13

## Project Zomboid b42.13 - Critical Discard Feature Removal

This document outlines the **breaking changes** in Project Zomboid build 42.13 that directly affect this mod's core functionality.

---

## ⚠️ CRITICAL: Discard Feature Removed from Vanilla

**The discard functionality has been completely removed from the vanilla foraging system in b42.13.**

### What Was Removed

1. **forageSystem.lua**
   - `addOrDropItems()` function no longer accepts `_discardItems` parameter
   - All discard-related logic removed from core foraging system

2. **ISForageIcon.lua**
   - `onClickDiscard()` function completely removed
   - No discard context menu option in vanilla game

### Why Was It Removed?

**Likely reason: Multiplayer Compatibility**

Build 42.13's primary focus was the multiplayer update. The discard feature may have been removed due to:
- Synchronization issues in multiplayer
- Client-server state management complexity
- Potential exploits or bugs in MP environment
- Simplification of foraging mechanics for MP stability

---

## 📦 Updated Files (8)

Files updated to b42.13 versions:

| File                         | Changes                                             |
| ---------------------------- | --------------------------------------------------- |
| **forageSystem.lua**         | ⚠️ Discard parameter removed from `addOrDropItems()` |
| **ISForageIcon.lua**         | ⚠️ `onClickDiscard()` function removed               |
| **ISForageAction.lua**       | Updated foraging action logic                       |
| **ISBaseIcon.lua**           | Base icon class updates                             |
| **ISSearchManager.lua**      | Search mode improvements (distance tracking, etc.)  |
| **ISSearchWindow.lua**       | UI updates                                          |
| **ISWorldItemIcon.lua**      | Icon display updates                                |
| **ISWorldItemIconTrack.lua** | Icon tracking improvements                          |

---

## ➕ New Files Added (7)

New foraging system files introduced in b42.13:

| File                         | Purpose                       |
| ---------------------------- | ----------------------------- |
| **forageClient.lua**         | Client-side foraging logic    |
| **ISAnimalTracksFinder.lua** | Animal tracking system        |
| **forageCategories.lua**     | Foraging category definitions |
| **forageDefinitions.lua**    | Item definitions              |
| **forageSkills.lua**         | Skill mechanics               |
| **forageZones.lua**          | Zone configurations           |
| **scavenges.lua**            | Scavenging system             |

---

## 🔧 Impact on QuickForageIconDiscard Mod

### Immediate Issues

1. **Mod functionality broken** - Core discard feature no longer exists in vanilla
2. **API changes** - Functions that relied on discard parameters won't work
3. **Context menu changes** - Discard option no longer available in vanilla UI

### Required Mod Updates

To restore discard functionality, the mod will need to:

#### 1. Re-implement Discard Logic
```lua
-- The mod must now handle discarding independently
-- forageSystem.addOrDropItems() no longer has _discardItems parameter
-- Need to create custom discard handler
```

#### 2. Add Custom Context Menu
```lua
-- Re-implement ISForageIcon:onClickDiscard() or equivalent
-- Add discard option back to context menus
-- Handle item removal from forage lists
```

#### 3. Handle MP Compatibility
```lua
-- If the mod supports MP, ensure discard actions are properly synced
-- Consider why vanilla removed it (MP stability issues)
-- May need client-server communication code
```

### Code Migration Guide

**Old b42.12 code:**
```lua
forageSystem.addOrDropItems(character, inventory, items, true) -- discardItems = true
```

**New b42.13 approach (requires custom implementation):**
```lua
-- Must implement custom discard logic
-- forageSystem.addOrDropItems() no longer supports discard parameter
local function customDiscardItems(character, items)
    -- Custom implementation needed
    -- Remove items from foraging system
    -- Update UI accordingly
end
```

---

## 🎯 Other b42.13 Foraging Changes

### XP System Changes
- Distance-based XP bonuses added (capped at 20 squares)
- XP removed from pickup action (only awarded on finds)
- Force Find logic improved

### Search Mode Updates
- Minimum radius for affinity checks
- Reset `lastSpottedX/Y` on search toggle
- Better distance tracking

### New Features
- Animal tracking system integrated
- New file organization (modular structure)
- Improved zone-based foraging

---

## 💡 Recommendations

### For Single Player
- The mod can safely re-implement discard functionality
- No MP concerns to worry about
- Can use simpler implementation

### For Multiplayer Support
- Study why vanilla removed the feature
- Implement proper client-server synchronization
- Test thoroughly in MP environment
- Consider adding option to disable in MP

### Alternative Approaches
1. **Quick Trash**: Instead of discard during foraging, allow quick deletion of items from inventory
2. **Auto-Filter**: Add option to never pick up certain item types
3. **Blacklist**: Let players create item blacklists that auto-discard

---

## 📝 Technical Notes

### API Compatibility

**Breaking Changes:**
- `forageSystem.addOrDropItems(_character, _inventory, _items, _discardItems)`
  - Now: `forageSystem.addOrDropItems(_character, _inventory, _items)`
- `ISForageIcon:onClickDiscard(_x, _y, _contextOption)` - **Function removed**

**New APIs to Consider:**
- Check new foraging client-server architecture
- Review animal tracking integration points
- Examine new modular file structure

### File Structure Changes

The foraging system is now more modular:
- Separate files for categories, definitions, skills, zones
- Client-specific logic isolated in `forageClient.lua`
- Better organization for modders

---

## 🔍 Testing Checklist

After updating mod code:
- [ ] Test discard functionality works in single player
- [ ] Verify no errors when clicking discard
- [ ] Check that items are properly removed from lists
- [ ] Test with various forage item types
- [ ] Verify UI updates correctly after discard
- [ ] Test in multiplayer (if supported)
- [ ] Ensure compatibility with other foraging mods
- [ ] Check performance (no lag from custom implementation)

---

**Last Updated:** December 13, 2025
**Source:** Project Zomboid Build 42.13 Release Notes (January 13, 2025)
**Mod Status:** ⚠️ Requires code updates to restore functionality
