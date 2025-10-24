# Quick Forage Icon Discard - Project Zomboid Mod

## Project Overview

This is a Project Zomboid mod called "Quick Forage Icon Discard" that allows players to quickly discard forage items by single mouse click (RMB by default) instead of using the context menu.

## Project Structure

This workspace follows the standard Project Zomboid mod structure:

### Main Development Directory
- **`Contents/mods/QuickForageIconDiscard/`** - Main code folder where all development work happens
  - Contains all mod files, scripts, and resources
  - This is where you implement features, fixes, and enhancements for your mod

### Reference Directory (if applicable)
- **`Mods_Refs/`** - Reference mods for learning patterns and implementations (if included)
  - Contains source code from other mods used as reference material
  - Used to understand existing implementations, patterns, and best practices
  - **DO NOT MODIFY** - These directories should remain unchanged to preserve reference implementations
  - Key areas to reference:
    - Modular architecture patterns
    - UI component implementations
    - Patch systems and compatibility fixes
    - Localization systems

### Vanilla Game Reference Directory (if applicable)
- **`PZ_Files/`** - Original Project Zomboid files for version comparison (if included)
  - Used for diff analysis and understanding vanilla game changes
  - Essential for compatibility and understanding what the game provides vs what your mod changes

### Other Directories
- **`.github/instructions/`** - Development guidelines and modding instructions
  - Contains project-specific development patterns and best practices
  - Reference these for consistent development workflow
- **`.github/prompts/`** - Reusable AI prompts for common tasks
  - Contains templates for common development tasks
- **`workshop_assets/`** - Steam Workshop assets and metadata
  - Thumbnails, preview images, and workshop description
- **Root files** - Mod documentation and configuration (README.md, CHANGELOG.md, LICENSE, etc.)

When developing features, always work in the `Contents/mods/QuickForageIconDiscard/` directory and reference any included reference mods as needed.

## Recommended Modular Architecture (Optional)

For implementing complex features or systems, consider using a modular architecture pattern:

### Modular Base Pattern
- **Base Class**: Create a base module class that provides foundation for individual components
- **Auto-Disable Safenet**: Modules automatically disable themselves on crashes to prevent game instability
- **Crash Recovery**: Automatic restoration of vanilla functions when modules fail
- **Event Management**: Safe event registration with error wrapping and automatic cleanup
- **Function Overrides**: Idempotent function patching with automatic restoration on failure

### Suggested Structure for Complex Mods
```
Contents/mods/QuickForageIconDiscard/42/media/lua/client/
├── QFID_Client.lua          # Main coordinator
├── Core/
│   └── QFID_ModuleBase.lua  # Base module class
├── Modules/
│   ├── QFID_Feature1.lua    # Individual feature modules
│   └── QFID_Feature2.lua
└── Utils/
    └── QFID_Utils.lua       # Shared utilities
```

### Benefits of Modular Approach
- **Isolation**: Each component is independent and can fail without affecting others
- **Maintainability**: Clear separation of concerns makes debugging and updates easier
- **Reliability**: Automatic error recovery prevents single feature failures from breaking the entire mod
- **Extensibility**: Easy to add new features without modifying existing ones

## Technologies and Framework

- **Primary Language**: Lua 5.1 (Project Zomboid's Lua environment)
- **Target Platform**: Project Zomboid (Steam Workshop mod)
- **Mod Framework**: Project Zomboid's mod system
- **File Structure**: Standard PZ mod structure with `media/lua/` directories
- **Build Version**: [Specify target game build version, e.g., Build 42.12]

## Key Development Principles

- **Code Quality**: Write clean, maintainable, and well-documented code
- **Compatibility-First Approach**: Ensure changes maintain compatibility with vanilla game and other popular mods
- **Minimal Footprint**: Keep the mod lightweight and focused on core functionality
- **Safe Patching**: Use safe function overriding and extension patterns that won't break on game updates
- **Error Resilience**: Implement proper error handling and graceful degradation
- **Read-Only References**: Never modify files in reference directories - they should remain unchanged
- **Naming Conventions**: Use consistent prefixing (e.g., `QFID_`) for all mod files and functions to avoid conflicts
- **Performance Consideration**: Optimize code for performance, especially in frequently called functions

## Testing Guidelines

- **No Automated Tests**: Avoid creating unit tests or automated test suites for this mod
- **No Testing Files**: Do NOT create separate testing files, testing guides, or testing instruction documents
- **In-Game Testing Only**: All functionality should be tested directly in Project Zomboid by the developer
- **Manual Testing Preferred**: The developer will manually test all features in-game
- **Implementation Only**: Focus on implementing features correctly rather than documenting how to test them

## Implementation Guidelines

- **Questions vs Implementation**: If the user asks a question about architecture, patterns, or "how to" - provide guidance and explanation in chat only
- **Explicit Implementation Requests**: Only create/modify files when the user explicitly asks for implementation (e.g., "implement this", "create a file", "modify this code")
- **No Unsolicited Files**: Do NOT create example files, sample implementations, or demonstration code unless specifically requested
- **Chat-First Approach**: For questions about design patterns, architecture advice, or technical guidance - respond with detailed explanations in chat
- **No Emojis in Documents**: Do NOT use emojis in any documentation files, markdown files, or code comments. Use plain text symbols and clear descriptive language instead

### Code Implementation Focus
When implementing a feature (only when explicitly requested), focus solely on:
1. Clean, working code implementation
2. Proper error handling and logging
3. Following existing mod patterns and conventions
4. Maintaining compatibility with vanilla game and other mods
5. Using consistent naming conventions with QFID

**DO NOT CREATE**: Testing guides, testing files, test scenarios, testing instructions, example files, or demonstration code unless explicitly requested.

## Localization Support

- Follow the localization instructions in `.github/instructions/localization.instructions.md`
- Support multiple languages when applicable
- Keep text keys organized and consistently named
- Use the `Translate/` directory structure for language files

## Steam Workshop Integration

- Update `workshop_description.txt` with proper formatting following `.github/instructions/steam_syntax.instructions.md`
- Maintain `CHANGELOG.md` for version history using `.github/instructions/changelog.instructions.md`
- Keep workshop assets in `workshop_assets/` directory
- Follow Steam Workshop guidelines and best practices

## Development Workflow

1. **Planning**: Review existing instructions and prompts in `.github/` directory
2. **Implementation**: Work in `Contents/mods/QuickForageIconDiscard/` following established patterns
3. **Documentation**: Update relevant documentation files (README.md, CHANGELOG.md, etc.)
4. **Localization**: Add or update translation files if text changes are made
5. **Testing**: Test in-game manually
6. **Release**: Use `.github/prompts/release.prompt.md` workflow for publishing updates

## Common Tasks Reference

- **Adding Localization**: See `.github/prompts/add_localization.prompt.md`
- **Release Process**: See `.github/prompts/release.prompt.md`
- **Mod Options**: See `.github/instructions/mod_options.instructions.md`
- **Mod Info Updates**: See `.github/instructions/mod.info.instructions.md`
