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

This mod ships a single build folder (`42/`) plus `common/`, and three changelog files in different formats. A release has two phases: **prepare** (version + changelogs, committed on a release branch) and **finalize** (merge + tag).

## Phase 1 — Prepare the release

### 1. Determine the version

- On a `release/X.Y.Z` branch: take the version from the branch name.
- On `master`: pick the next semver (patch/minor/major) from the nature of the unreleased changes.

### 2. Bump version in every place (all must match)

- `Contents/mods/QuickForageIconDiscard/42/mod.info` → `modversion=X.Y.Z`
- `Contents/mods/QuickForageIconDiscard/42/media/lua/client/QFID_Utils.lua` → `QFID_Utils.MOD_VERSION = "X.Y.Z"`
- `README.md` → version badge `![...Version-X.Y.Z-blue...]`

Do **not** touch `versionMin`/`versionMax` during a routine release — those only change when adding support for a new game build. (`42/` = `versionMin=42.15`, no `versionMax`.)

### 3. Update all three changelogs with the same information

Each file expresses the same changes in a different format. Use the Keep a Changelog section order where applicable: `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.

**a) `CHANGELOG.md`** — Keep a Changelog markdown, newest first. Move the `## [Unreleased]` entries into a new `## [X.Y.Z] - YYYY-MM-DD` section (ISO date). Leave `## [Unreleased]` empty or omit it.

**b) `workshop_assets/workshop_updates.txt`** — plain text for Steam's change-notes field, newest first, no markdown.
```
vX.Y.Z - YYYY-MM-DD

Changed
- User-facing description of the change

Fixed
- Another change
```
Header uses a `v` prefix. Single blank line between sections, double blank line between versions. No `Unreleased` section here. Keep it user-facing — omit pure refactors.

**c) `Contents/mods/QuickForageIconDiscard/common/ChangeLog.txt`** — in-game alert format, **oldest at top, newest appended at BOTTOM** (the alert system reverses for display). Append:
```
[ vX.Y.Z - YYYY-MM-DD ]
Changed:
- User-facing description
Fixed:
- Another change
[ ------ ]
```
Section headers take a trailing colon (`Added:`, `Fixed:`, ...). For a second same-day update use `[ vX.Y.Z #2 - YYYY-MM-DD ]`.

### 4. Validate before committing

- All three version references (`mod.info`, `QFID_Utils.lua`, README badge) read `X.Y.Z`.
- `mod.info` has the right `id` (`Ivmakk_QuickForageIconDiscard`) and `name`.
- The three changelogs describe the same changes; dates are ISO `YYYY-MM-DD`.

Commit the prepared release on the `release/X.Y.Z` branch. Do not commit unless the user asks.

## Phase 2 — Finalize (merge + tag)

Only after the prepare commit is in place and the user asks to finalize.

1. Confirm the working tree is clean (`git status`); if not, ask whether to commit, stash, or discard before continuing.
2. Merge and tag:
   ```
   git checkout master
   git merge release/X.Y.Z
   git tag X.Y.Z          # NOTE: no "v" prefix — matches existing tags (1.3.1, 1.3.0, ...)
   git push origin master
   git push origin X.Y.Z
   ```
3. Clean up the branch:
   ```
   git branch -d release/X.Y.Z
   git push origin --delete release/X.Y.Z
   ```
4. Verify: on `master`, working tree clean, `git tag --sort=-version:refname` shows `X.Y.Z` at top.

The git tag uses **no** `v` prefix even though the in-game and workshop changelogs do.
