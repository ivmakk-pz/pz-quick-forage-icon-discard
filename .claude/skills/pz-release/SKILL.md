---
name: pz-release
description: >
  Use this skill to cut or finalize a release of the Quick Forage Icon Discard mod.
  Activates when the user asks to release a new version, bump the mod version, prepare
  a release, update the changelogs for a release, or tag/finalize a release on GitHub.
  Covers the full flow: synchronize version numbers, update all three changelog
  formats, then merge and tag.
---

# Releasing Quick Forage Icon Discard

Follow the generic release procedure in the central `pz-modding` skill (`references/releasing.md`) for the two-phase flow (prepare on a `release/X.Y.Z` branch → finalize with merge + tag), the exact changelog block formats, and the `workshop.txt` publish gate. This file records only QFID's project-specific facts that the generic procedure asks for.

## QFID facts

- **Layout:** one build folder `Contents/mods/QuickForageIconDiscard/42/` plus `common/`. Not multi-version — a single `mod.info`. Don't touch `versionMin`/`versionMax` in a routine release (`42/` = `versionMin=42.15`, no `versionMax`).
- **Version references (all must read `X.Y.Z`):**
  - `Contents/mods/QuickForageIconDiscard/42/mod.info` → `modversion=X.Y.Z`
  - `Contents/mods/QuickForageIconDiscard/42/media/lua/client/QFID_Utils.lua` → `QFID_Utils.MOD_VERSION = "X.Y.Z"`
  - `README.md` → version badge `![...Version-X.Y.Z-blue...]`
- **Three changelogs:** `CHANGELOG.md` (newest-first), `workshop_assets/workshop_updates.txt` (plain text, `v` prefix, newest-first), `Contents/mods/QuickForageIconDiscard/common/ChangeLog.txt` (in-game alert, oldest-first, append at BOTTOM).
- **Tag convention: `v` prefix** (`v1.4.1`), matching the workshop/in-game changelogs and the `ivmakk-pz` org. The `modversion`/`MOD_VERSION`/README-badge fields stay unprefixed (`X.Y.Z`).
- **mod id:** `Ivmakk_QuickForageIconDiscard`.
