# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A Project Zomboid client-side mod ("Quick Forage Icon Discard") written in Lua 5.1 for PZ's modding environment. It lets players discard forage icons with a single mouse click (RMB by default) instead of the context menu, restoring a discard feature that vanilla removed in Build 42.13.

There is no build, compile, lint, or test step. The mod runs as Lua loaded by the game. All testing is manual in-game by the developer — do **not** create unit tests, test files, or testing guides.

## Folder structure

The shipped mod lives under `Contents/mods/QuickForageIconDiscard/` and ships a single Build-42 version folder plus a shared one:

- `42/` — Build 42.15+. `mod.info` has `versionMin=42.15`, no `versionMax`. Client Lua under `media/lua/client/`; translations in JSON format (`Translate/<LANG>/UI.json`). The folder name `42` is just the selection label (`≤ current build`); actual compatibility is governed by `versionMin`.
- `common/` — shared assets; holds `ChangeLog.txt` (in-game changelog). Mandatory in Build 42 even if nearly empty.

Multi-version support (parallel `42/` + `42.15/` folders and the legacy `.txt` translation format for Builds 42.12–42.14) was dropped in 1.4.0. Build 42 still requires at least one version-named folder plus `common/`; a fully flat `media/` layout is Build 41 only.

## Code architecture

Entry point: `media/lua/client/QFID_Client.lua` — registers `Events.OnGameStart` (initializes modules) and `Events.OnCreateUI` (initializes mod options, wrapped in pcall). It requires and initializes two feature modules.

Everything is built on a self-protecting module pattern in `Core/QFID_ModuleBase.lua` (derives from vanilla `ISBaseObject`). Each feature module derives from it and gets:

- **Auto-disable safenet**: if `initialise()` or any patched function throws, the module is blacklisted, marked inactive, and never runs again that session — the game keeps working.
- **`overrideFunction(target, name, fn)`**: idempotent monkey-patching of vanilla functions. Stores the original (retrievable via `getOriginal(name, target)`); on a runtime crash in the wrapper it auto-restores the vanilla function and falls back to calling it.
- **`registerEvent(name, handler)`**: dedup'd, pcall-wrapped event registration.
- **`destroy()`**: removes events and restores all overridden vanilla functions.

Feature modules (`Modules/`), each exporting `{ initialise, destroy, isActive, getInstance }` over a single instance:

- `QFID_QuickDiscard.lua` — the core feature. Overrides `ISForageIcon` mouse handlers (`onRightMouseDown`, `onRightMouseUp`, `onMouseButtonDown`, `initialise`) to map configured mouse buttons to discard vs. context menu. Implements `QFID_customDiscardIcon` to remove a forage icon via `icon.manager:removeItem/removeIcon` and `triggerEvent("onUpdateIcon", ...)` for multiplayer sync (vanilla `onClickDiscard` no longer exists in 42.13+). On Build 42.20+ foraging is server-authoritative: a session-local `QFID_discardedIconIds` set plus an override of `ISSearchManager:applyServerPool` strips discarded ids from the incoming server pool so they aren't re-materialised.
- `QFID_Tooltip.lua` — overrides `ISForageIcon` to show a compact item-name tooltip on hover.

Support files (`client/` root):

- `QFID_Utils.lua` — logging helpers (`logInfo/logWarning/logError/logDebug`, all prefixed `[QFID]`), `MOD_VERSION` constant, `BUTTON_NONE = -1`, and a `DEBUG_MODE` flag that gates debug logs.
- `QFID_ModOptions.lua` — registers options via `PZAPI.ModOptions` (discard button, context-menu button, show-tooltip tickbox) and exposes typed getters the modules read at runtime. Mouse-button combo-box indices map to `{RMB, MMB, BTN_3..BTN_6, NONE}`.

### Conventions

- Prefix every file, module, and global symbol with `QFID_` to avoid collisions with the game and other mods.
- Never call vanilla functions you've overridden directly — go through `instance:getOriginal(name, target)` so the original chain stays intact.
- Wrap risky logic so a failure disables one module rather than crashing the game; the module base already does this for overrides and event handlers.
- `MOD_VERSION` in `QFID_Utils.lua` must match `modversion` in `mod.info`.

### Lua style

- Annotate functions with LuaLS/EmmyLua types (`---@param`, `---@return`, `---@type`). Keep them minimal — don't restate the obvious or duplicate the description in `@return`. Use `unknown` (and say so) when a type can't be determined.
- When hooking a vanilla class and adding fields, declare an extended type (`---@class ISForageIconWithTooltip : ISForageIcon` / `---@field tooltip ISToolTip|nil`) and `---@cast` constructor results, instead of `---@diagnostic disable` suppressions.
- Comment the "why," not the "what." Skip obvious comments; explain non-trivial logic. Separate large files with `-- ===== SECTION =====` banner comments (Constants/Imports → Helpers → Main Logic → Exports/Overrides).
- Defensive programming by data certainty: no fallbacks for guaranteed singletons (`getPlayer()`, `ScriptManager.instance`, `forageSystem.searchManager`) — let those fail fast. Use `or` fallbacks only for genuinely optional data (mod options, optional item properties, mod data). Reserve `pcall` for the module-base wrappers and the occasional top-level override fallback.
- Performance in hot paths: numeric `for i = 1, #t` over `ipairs`; `table.concat` for building 5+ string parts, `..` for small concatenations.

### Commit messages

Keep-a-Changelog ready: start the subject with one category (`Added | Changed | Deprecated | Removed | Fixed | Security`), imperative mood, ≤72 chars, optional `[scope]`, no emojis. Example: `Fixed: null crash in discard handler [QuickDiscard]`. This maps directly onto the `CHANGELOG.md` sections.

## Localization

`media/lua/shared/Translate/<LANG>/` holds UI strings (keys like `UI_options_QFID_*`, read via `getText(...)`), kept in sync across all languages. Translations are JSON (`UI.json`). To add or update a language, use the **`pz-localization`** skill — it carries the language-code/encoding table and the key-naming rules.

## Releasing

A version bump touches several files in lockstep: `modversion` in `mod.info`, `MOD_VERSION` in `QFID_Utils.lua`, the `README.md` badge, plus three changelog formats (`CHANGELOG.md`, `workshop_assets/workshop_updates.txt`, and `common/ChangeLog.txt` — note the last is oldest-first/append-at-bottom). Git tags use a `v` prefix (`v1.4.1`); the `modversion`/`MOD_VERSION` fields stay unprefixed. Use the **`pz-release`** skill for the full prepare-and-finalize sequence.

## Reference material

- `docs/pz_reference.md` — project lookup notes: `mod.info` format, the `PZAPI.ModOptions` API + option conventions, and Steam Workshop BBCode syntax.
- `docs/tickets/` — internal working tickets (`project-docs` convention). Gitignored and local-only; kept out of the public repo.
- Vanilla game source, decompiled Java, release notes, PZwiki references, and migration guides live in the shared context repo wired up by the **`pz-modding`** skill — read from there instead of keeping local copies. The discard gap this mod fills: `ISForageIcon.onClickDiscard` and `forageSystem.addOrDropItems(_discardItems)` existed in 42.12 but were removed in 42.13.
