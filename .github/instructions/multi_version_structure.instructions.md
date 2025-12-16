---
applyTo: '**'
---

# Multi-Version Mod Structure

## Overview

This mod uses a multi-version structure to support multiple Project Zomboid builds simultaneously from a single workshop item. The game automatically loads the appropriate version folder based on the player's game build.

## Folder Structure

```
Contents/mods/QuickForageIconDiscard/
├── 42.13/                       # Development version (Build 42.13+)
│   ├── mod.info                 # Version config: versionMin=42.13, no versionMax
│   └── media/
│       └── lua/
│           ├── client/          # Client-side code
│           │   ├── QFID_Client.lua
│           │   ├── QFID_Utils.lua
│           │   ├── QFID_ModOptions.lua
│           │   └── Modules/     # Feature modules
│           └── shared/
│               └── Translate/   # Localization files
│
├── 42.12/                       # Stable version (Build 42.12.x)
│   ├── mod.info                 # Version config: versionMin=42.12.0, versionMax=42.12.99
│   └── media/
│       └── lua/
│           ├── client/          # Client-side code (mirrors 42.13/ structure)
│           └── shared/
│               └── Translate/   # Localization files (mirrors 42.13/)
│
└── common/                      # Shared assets (required, can be empty)
    ├── .gitkeep                 # Ensures folder is tracked
    ├── ChangeLog.txt            # In-game changelog (plain text)
    └── media/                   # Optional shared resources
```

## Folder Purposes

### 42.13/ - Development Version
- **Target**: Build 42.13.0 and all future 42.13.x builds
- **Purpose**: Active development with latest features
- **Key Features**:
  - Custom discard implementation (vanilla feature removed in 42.13)
  - Latest bug fixes and enhancements
  - Forward-compatible with future 42.13.x updates
- **Configuration**:
  - `versionMin=42.13` (no trailing `.0`)
  - NO `versionMax` (supports all future 42.13.x builds)
- **Development Focus**: All new features go here first

### 42.12/ - Stable Version
- **Target**: Build 42.12.0 through 42.12.99 only
- **Purpose**: Stable support for players on stable game builds
- **Key Features**:
  - Uses vanilla discard functionality (still present in 42.12)
  - Proven stability from earlier releases
  - No breaking changes unless critical
- **Configuration**:
  - `versionMin=42.12.0` (explicit minor version)
  - `versionMax=42.12.99` (locks to 42.12.x only)
- **Maintenance**: Only critical backported fixes

### common/ - Shared Assets
- **Target**: All game versions
- **Purpose**: Assets that work across all supported builds
- **Contents**:
  - `ChangeLog.txt` - In-game changelog (plain text format)
  - Shared media assets (textures, sounds) if applicable
- **Requirement**: Folder MUST exist even if empty (add `.gitkeep`)

## Version Synchronization Rules

### CRITICAL: Synchronized Values
These values MUST be IDENTICAL in both `42.13/mod.info` and `42.12/mod.info`:

1. **modversion**: `1.2.1` (or current version)
   - Players see the same version number regardless of build
   - Prevents confusion about which version they're using

2. **id**: `Ivmakk_QuickForageIconDiscard`
   - Same mod ID for workshop detection

3. **name**: `Quick Forage Icon Discard`
   - Same display name

### Version-Specific Values
These values MUST be DIFFERENT:

1. **versionMin/versionMax**:
   - 42.13: `versionMin=42.13` (no versionMax)
   - 42.12: `versionMin=42.12.0` and `versionMax=42.12.99`

2. **description** (optional):
   - 42.13: Can mention "Build 42.13 compatible with restored discard"
   - 42.12: Generic description

## How Game Version Detection Works

1. **Player launches game** on specific build (e.g., 42.13.2)
2. **Game scans** `Contents/mods/QuickForageIconDiscard/` folder
3. **Game checks** each subfolder's `mod.info` for version constraints:
   - Checks `versionMin` - game build must be >= this value
   - Checks `versionMax` (if present) - game build must be <= this value
4. **Game loads** the first matching folder's content
5. **Common folder** is always loaded regardless of version

### Example Scenarios

**Player on Build 42.13.5:**
- Checks `42.13/mod.info`: versionMin=42.13 ✓ (42.13.5 >= 42.13)
- No versionMax ✓ (no upper limit)
- **Loads**: `42.13/` folder

**Player on Build 42.12.8:**
- Checks `42.12/mod.info`: versionMin=42.12.0 ✓ (42.12.8 >= 42.12.0)
- versionMax=42.12.99 ✓ (42.12.8 <= 42.12.99)
- **Loads**: `42.12/` folder

**Player on Build 42.11.x:**
- Checks `42.13/mod.info`: versionMin=42.13 ✗ (42.11.x < 42.13)
- Checks `42.12/mod.info`: versionMin=42.12.0 ✗ (42.11.x < 42.12.0)
- **Loads**: Nothing (mod incompatible with this build)

## Development Workflow

### For New Features
1. **Implement** in `42.13/` folder
2. **Test** on Build 42.13.x
3. **Decide** if feature should be backported to 42.12/
4. **Backport** (optional) to `42.12/` if beneficial and compatible

### For Bug Fixes
1. **Fix** in `42.13/` folder first
2. **Test** on Build 42.13.x
3. **Backport** to `42.12/` if bug exists there too
4. **Test** on Build 42.12.x

### For Releases
1. **Update modversion** in BOTH `42.13/mod.info` AND `42.12/mod.info`
2. **Update version constants** in BOTH folders:
   - `42.13/media/lua/client/QFID_Utils.lua`
   - `42.12/media/lua/client/QFID_Utils.lua`
3. **Update documentation** (README.md, CHANGELOG.md)
4. **Update common/ChangeLog.txt** (in-game changelog)
5. **Verify** all version references are synchronized

### For Localization
1. **Add translations** to `42.13/media/lua/shared/Translate/{LANG}/`
2. **Copy** to `42.12/media/lua/shared/Translate/{LANG}/`
3. **Keep synchronized** between both versions

## File Synchronization Strategy

### Always Synchronize
- `mod.info` - modversion, id, name fields
- Translation files in `Translate/` folders
- Core utility files that work across both builds
- Mod option definitions

### Version-Specific Files
- `42.13/` - Custom discard implementation modules
- `42.12/` - Uses vanilla discard, simpler implementation
- Build-specific compatibility code

### Shared Files
- `common/ChangeLog.txt` - Single source for in-game changelog
- Asset files (textures, sounds) if applicable

## Testing Checklist

Before releasing:
- [ ] Both `mod.info` files have identical `modversion`
- [ ] Both `mod.info` files have identical `id`
- [ ] 42.13/mod.info has `versionMin=42.13` and NO `versionMax`
- [ ] 42.12/mod.info has `versionMin=42.12.0` and `versionMax=42.12.99`
- [ ] Version constants synchronized in both QFID_Utils.lua files
- [ ] Translations synchronized between 42.13/ and 42.12/
- [ ] common/ChangeLog.txt updated with latest changes
- [ ] Tested on Build 42.13.x (loads from 42.13/ folder)
- [ ] Tested on Build 42.12.x (loads from 42.12/ folder)
- [ ] Core functionality works in both builds

## Migration from Single Version

If migrating from old `42/` folder structure:

1. **Rename** `42/` to `42.13/`
2. **Copy** `42.13/` to `42.12/`
3. **Update** `42.13/mod.info`:
   - Change `versionMin=42.13`
   - Remove `versionMax` if present
4. **Update** `42.12/mod.info`:
   - Change `versionMin=42.12.0`
   - Add `versionMax=42.12.99`
5. **Create** `common/` folder with `.gitkeep`
6. **Move** `ChangeLog.txt` to `common/` if it exists
7. **Test** both versions load correctly

## Common Pitfalls

### ❌ Wrong: Different modversions
```ini
# 42.13/mod.info
modversion=1.2.1

# 42.12/mod.info
modversion=1.1.0  # WRONG - causes confusion
```

### ✓ Correct: Synchronized modversions
```ini
# 42.13/mod.info
modversion=1.2.1

# 42.12/mod.info
modversion=1.2.1  # Correct - same version
```

### ❌ Wrong: Missing versionMax on 42.12
```ini
# 42.12/mod.info
versionMin=42.12.0
# Missing versionMax - will load on 42.13+ too!
```

### ✓ Correct: Explicit version range
```ini
# 42.12/mod.info
versionMin=42.12.0
versionMax=42.12.99  # Locks to 42.12.x only
```

### ❌ Wrong: Trailing .0 on 42.13
```ini
# 42.13/mod.info
versionMin=42.13.0  # WRONG - should be 42.13
```

### ✓ Correct: No trailing .0
```ini
# 42.13/mod.info
versionMin=42.13  # Correct format
```

## Summary

- **42.13/** = Active development, latest features, Build 42.13+
- **42.12/** = Stable support, legacy features, Build 42.12.x only
- **common/** = Shared assets, all builds
- **modversion** = MUST be identical in both folders
- **Test both versions** before every release

This structure allows one workshop item to serve all players regardless of which game build they're using.
