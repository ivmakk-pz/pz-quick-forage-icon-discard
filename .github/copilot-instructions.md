# Copilot PR Review — Quick Forage Icon Discard

GitHub Copilot reads this during PR reviews. Review-oriented: what to flag, not how to build. Deep dev conventions live in `CLAUDE.md` (root) — don't duplicate.

## What the mod is

Client-side Project Zomboid mod (Lua 5.1). Single mouse click discards forage icons (RMB default) instead of context menu — restores feature vanilla removed in B42.13. Current version: 1.4.0.

## Structure (for orienting a diff)

- `Contents/mods/QuickForageIconDiscard/42/` — Build 42.15+ code. Client Lua in `media/lua/client/`, translations JSON in `media/lua/shared/Translate/<LANG>/UI.json`.
- `Contents/mods/QuickForageIconDiscard/common/` — `ChangeLog.txt` (in-game changelog, oldest-first).
- Entry: `42/media/lua/client/QFID_Client.lua`. Core feature: `Modules/QFID_QuickDiscard.lua`. Module base: `Core/QFID_ModuleBase.lua`.

## Flag in review

- **Vanilla override safety** — patched vanilla functions must go through the module base (`overrideFunction`/`getOriginal`), never call an overridden vanilla fn directly. Risky logic unwrapped → can crash game instead of disabling one module.
- **Prefix collisions** — every file, module, global symbol prefixed `QFID_`. Flag unprefixed globals.
- **Bad defensive coding** — `or` fallbacks / `pcall` only on genuinely optional data (mod options, optional item props, mod data). Flag fallbacks on guaranteed singletons (`getPlayer()`, `ScriptManager.instance`, `forageSystem.searchManager`) — those should fail fast.
- **Hot-path perf** — numeric `for i = 1, #t` over `ipairs`; `table.concat` for 5+ string parts.
- **Version drift** — `modversion` in `mod.info`, `MOD_VERSION` in `QFID_Utils.lua`, README badge, three changelogs (`CHANGELOG.md`, `workshop_assets/workshop_updates.txt`, `common/ChangeLog.txt`) must move in lockstep on a bump.
- **Commit/PR titles** — start with category (`Added|Changed|Deprecated|Removed|Fixed|Security`), imperative, ≤72 chars, no emojis. Example: `Fixed: null crash in discard handler [QuickDiscard]`.
- **Localization** — UI strings keyed `UI_options_QFID_*`, read via `getText(...)`, kept in sync across all `Translate/<LANG>/UI.json`. Flag added strings missing from some languages.
- **No emojis** in docs, markdown, code comments.
- **No test files** — mod tested manually in-game. Flag added unit tests / test guides.

## B42.13 context (why the mod exists)

`ISForageIcon.onClickDiscard()` and `forageSystem.addOrDropItems(_discardItems)` removed in B42.13. Mod re-implements discard via function override + `triggerEvent("onUpdateIcon", ...)` for MP sync.
