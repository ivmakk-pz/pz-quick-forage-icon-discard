# Build 42.19 Compatibility Review & Upgrade Plan

Status: code + docs + version + changelogs done on branch `release/1.4.0`. SP-tested clean on 2026-06-10 (logs clean). Version 1.3.1 → **1.4.0** (multi-version support dropped + EnduranceModifier removed). Only commit + finalize (merge/tag/push) remain — pending user.

## Summary

The mod's two real features (QuickDiscard, Tooltip) **work on 42.19**. The `42.15/` folder has no `versionMax`, so the game selects it on 42.19. Scope:

1. **EnduranceModifier crashes on 42.18+ (player-reported)** — recommend removing it. See findings; it is dead code with a live crash landmine.
2. **Drop multi-version support** — collapse to a single version folder targeting the latest build. The old-build (42.12–42.14) variant is no longer needed since the mod is no longer published on Steam.

Method: diffed the three vanilla files the mod hooks between the `42.15.2` and `42.19.0` tags in `C:\games\pz-modding-llm-context`, then traced each change against the mod's modules.

## Findings by module

### QuickDiscard (core feature) — works, no change

- `ISForageIcon:onRightMouseDown`, `onRightMouseUp`, `initialise` still exist in 42.19. `onMouseButtonDown` is still mod-stubbed (vanilla never defined it).
- `QFID_customDiscardIcon` uses `manager:removeItem` / `manager:removeIcon` + `triggerEvent("onUpdateIcon", …)` + `setIsBeingRemoved(true)`. This is exactly the API vanilla's new 42.18 `forageSystem.actionComplete()` uses, so the discard path is well-aligned with current vanilla.

### Tooltip — works, no change

- Overrides `onMouseMove` / `onMouseMoveOutside` (UI base-class methods, unchanged). `ISForageIcon` hover behavior is unaffected by the 42.18 refactor.

### EnduranceModifier — dead code AND a crash landmine on 42.18+ (recommend remove)

A player reported this crash on the Steam build (happens "when an item is found during foraging"):

```
java.lang.RuntimeException: Object tried to call nil in forageSystem_doEndurancePenalty
    QFID_EnduranceModifier.lua:83
    wrapper(QFID_ModuleBase.lua:217)
    Lua(Vanilla).forageAction(forageSystem.lua:2346)
    Lua(Vanilla).actionComplete(forageSystem.lua:2339)
    Lua(Vanilla).perform(ISForageAction.lua:34)
[QFID] ERROR [AUTO-DISABLE] QFID_EnduranceModifier override 'doEndurancePenalty' crashed and module has been permanently disabled
```

Three independent things are wrong, two of which long predate this:

1. **Discard detection never worked.** It keys off `currentAction.discardItems == true`, but `discardItems` has **never existed** on vanilla `ISForageAction` (removed in 42.13). `isCurrentActionDiscard()` has always returned false → the slider has been a no-op since at least 42.15.
2. **The hook it relies on was removed.** 42.18 removed `ISForageAction:forage()` (logic moved to `forageSystem.forageAction`, invoked via `forageSystem.actionComplete`). The mod's override of `ISForageAction.forage` now silently no-ops (`QFID_ModuleBase:overrideFunction` returns false when the target isn't a function, `Core/QFID_ModuleBase.lua:203`).
3. **The fallback branch uses a removed Stats API.** Lines 83/85 call `_character:getStats():getEndurance()` / `:setEndurance()`. The 42.18 refactor **renamed these to `get(CharacterStat.ENDURANCE)` / `set(CharacterStat.ENDURANCE, …)`** (see `forageSystem.doEndurancePenalty` in 42.19). So `getEndurance` is now nil — calling it is the exact "Object tried to call nil" in the report. These are the only two uses of the removed API in the whole mod; nothing else touches Stats.

The crash requires reaching the modified-penalty branch (lines 82–87), which only happens when the fast-path guard at lines 74–78 is bypassed (i.e. `getOriginal("doEndurancePenalty")` returns nil). A faithful Lua simulation of the current `QFID_ModuleBase` + module logic against a 42.18+ environment shows the guard **holds** in the current tree (it returns the vanilla original and never reaches line 83) — so the current code happens not to crash in that simulation. But the player's stack trace proves their build does reach line 83, so the branch is a live landmine, and given reasons 1–3 the module is unsalvageable as-is.

**Recommendation: remove the module.** Even a "fix" would mean rewriting the Stats calls and changing behavior so discards cost scaled endurance — counter to the mod's purpose (free, single-click discard). Removing it eliminates the crash and the dead code. (If the feature were ever wanted, the vanilla building blocks still exist: `forageSystem.endurancePenalty = 0.015` and `forageSystem.doEndurancePenalty`, now using `CharacterStat.ENDURANCE`.)

### Unrelated vanilla change (no impact)

`ISForageIcon:doForage` switched `item:getType()` → `item:getFullType()` — internal to a function the mod does not touch.

## Decision: collapse to a single version folder

Build 42 mods require a mandatory `common/` folder plus at least one version-named folder (a fully flat `media/` layout is Build 41 only). So "single version" = keep `common/` + **one** version folder, delete the other.

Chosen approach:

- **Surviving folder: `42/`**, but carrying the **current `42.15/` content** (JSON translations + current client code + the 42.15 `mod.info` description). The existing `42/` folder's `.txt` translations and `versionMax=42.14` are the old-build variant and cannot serve 42.19 — its content is discarded, only the folder name is reused.
- **`mod.info`: `versionMin=42.15`, no `versionMax`.** JSON translations are the 42.15+ format (verified working on 42.15); they are not the format older builds use, so 42.15 is the honest floor. The folder name `42` is just a selection label (`42.0 <= current build`); actual compatibility is governed by `versionMin`.
- **Delete the `42.15/` folder** after its content moves into `42/`.
- **`common/` stays** (mandatory; holds the in-game `ChangeLog.txt`).

Net result: one `42/` folder + `common/`, supporting 42.15 through latest, with no `.txt`/`.json` format split to keep in sync.

## Decision: EnduranceModifier — remove it

Decided: **remove the module entirely** — delete `QFID_EnduranceModifier.lua`, its mod option + getter, and its localization keys. This fixes the player crash, drops three layers of dead/broken code, and keeps discarding free (the mod's purpose).

Rejected alternatives: "leave as-is" crashes players on 42.18+; "fix to work" would mean rewriting the Stats calls and making discards cost endurance, which runs against the mod's free-discard premise.

## Implementation Plan

> **Rule**: Check off each step as it is completed. Update this plan if blockers or scope changes are encountered.

### 1. Remove the EnduranceModifier module (fixes the player crash)

Do this in the `42.15/` folder content (which carries forward in Phase 2); the `42/` folder is discarded, so it needs no edits.

- [x] Delete `Modules/QFID_EnduranceModifier.lua`
- [x] Remove its `require`/init from `QFID_Client.lua`
- [x] Remove the endurance-modifier option + its getter (`getDiscardEnduranceModifier`) from `QFID_ModOptions.lua`
- [x] Remove the `UI_options_QFID_*endurance*` keys from every `Translate/<LANG>/UI.json` (2 keys × 16 languages)
- [x] Grep confirmed: no `EnduranceModifier`/`endurance`/`getEndurance`/`setEndurance` left in code (only a historical `common/ChangeLog.txt` entry, kept)

### 2. Collapse to a single version folder

- [x] Replaced `42/` with the (EnduranceModifier-free) `42.15/` content via `rm -rf 42 && mv 42.15 42`
- [x] `42/mod.info` already has `versionMin=42.15`, no `versionMax`; `id`/`name`/description preserved
- [x] `42.15/` folder gone (single `42/` + `common/` remain)
- [x] `common/` untouched
- [x] `MOD_VERSION` (1.4.0) matches `modversion` (1.4.0)

### 3. Update project docs to match the single-folder structure

- [x] Rewrote `CLAUDE.md`: single-folder structure, two feature modules, no endurance option, single-folder localization + release notes, version → 1.4.0
- [x] Updated `pz-release` + `pz-localization` skills to single-folder (removed all "both folders" / `.txt` / `42.15` references)

### 4. Manual in-game verification (developer)

- [x] SP test passed; single `42/` folder loads. Log `2026-06-10_22-06_DebugLog.txt`: v1.4.0, both modules init, no `[QFID]` errors
- [x] Quick discard + mouse-button mapping verified in-game
- [x] Tooltip verified
- [x] Localization loads from JSON
- [x] Foraged an item — no `doEndurancePenalty` crash; endurance option gone (console.txt + DebugLog clean of forage/endurance errors; remaining ERRORs are vanilla baseline noise)

### 5. Release 1.4.0 (pz-release flow)

- [x] Create `release/1.4.0` branch
- [x] Bump `modversion=1.4.0` in the single `42/mod.info`
- [x] Bump `QFID_Utils.MOD_VERSION = "1.4.0"` in `42/media/lua/client/QFID_Utils.lua`
- [x] Update the `README.md` version badge to 1.4.0
- [x] Update all three changelogs (`CHANGELOG.md`, `workshop_assets/workshop_updates.txt`, `common/ChangeLog.txt`) — Removed: endurance modifier; Fixed: foraging crash on 42.18+; Changed: dropped legacy multi-version folders
- [x] Updated `workshop_description.bbcode` (dropped endurance feature/option, builds → 42.15+)
- [x] Commit release on `release/1.4.0` (`121621b`), push, open PR #3 → master
- [ ] Finalize: merge PR #3, tag `1.4.0` (no `v` prefix) on master, push tag, delete branch

### 6. Verify

- [x] Only the `42/` folder + `common/` remain under `Contents/mods/QuickForageIconDiscard/`
- [x] No `EnduranceModifier`/`getEndurance`/`setEndurance` references remain in code
- [x] `MOD_VERSION` (1.4.0) matches `modversion` (1.4.0)
- [x] In-game smoke test passed (Phase 4)
- [x] No `[QFID]` errors or auto-disable warnings in the client log
