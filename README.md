# Quick Forage Icon Discard

![Mod Version](https://img.shields.io/badge/Version-1.4.0-blue)

A Project Zomboid mod for Build 42.

## Features

- Quick discard forage items with right mouse button (RMB)
- Access context menu with middle mouse button (scroll click)
- No need to open context menu for quick discarding

## Mouse Button Controls

### Default Behavior (Vanilla)
- **Left Mouse Button (LMB)**: Double-click to pickup item
- **Right Mouse Button (RMB)**: Open context menu

### Modified Behavior (This Mod)
- **Left Mouse Button (LMB)**: Double-click to pickup item (unchanged)
- **Right Mouse Button (RMB)**: Quick discard item (no menu)
- **Middle Mouse Button**: Open context menu (for pickup to specific container or discard)

### Technical Details
The mod uses the following mouse button event handlers:
- **LMB**: `onMouseDown()` / `onMouseUp()` - Standard pickup behavior
- **RMB**: `onRightMouseDown()` / `onRightMouseUp()` - Quick discard action
- **Middle Mouse**: `onMouseButtonDown(btn=2)` - Context menu access
- **Side Buttons**: `onMouseButtonDown(btn=3, btn=4)` - Available for future features

## Installation

### Steam Workshop
1. Subscribe to the mod on Steam Workshop
2. Enable in Mods menu
3. Start/load game

### Manual Installation
1. Extract to `%USERPROFILE%\Zomboid\mods\`
2. Enable in Mods menu

## Requirements

- **Build 42.15+** — restores the discard feature removed by vanilla in Build 42.13.

Older builds (42.12–42.14) are no longer supported as of 1.4.0; use an earlier mod release for those.

## Usage

### Quick Actions
- **Right-click (RMB)** on any forage icon to instantly discard it
- **Middle-click (scroll button)** on any forage icon to open the context menu
- **Double left-click (LMB)** on any forage icon to pick it up (vanilla behavior)

### Context Menu Options
When you middle-click a forage icon, you can:
- Pick up to specific inventory/container
- Discard the item
- View item details

## License

See [LICENSE](LICENSE) file.
