---
name: pz-localization
description: >
  Use this skill when adding or updating translations for the Quick Forage Icon Discard
  mod. Activates when the user asks to add a language, translate the mod into some
  language, update localization strings, or sync translation files. Covers PZ's
  Translate folder layout, the JSON file format, language codes and
  encodings, and the QFID key-naming rules.
---

# Adding localization to Quick Forage Icon Discard

Follow the central `pz-modding` skill (`references/localization.md`) for the JSON format, the translation rules, and the full language-code/encoding table. This file records only QFID's project-specific facts.

## QFID facts

- **Single build folder, JSON only** (Build 42.15+). No multi-version, no legacy `.txt` (dropped in 1.4.0).
- **Path:** `Contents/mods/QuickForageIconDiscard/42/media/lua/shared/Translate/<LANG>/UI.json`. Only `UI.json` exists — this mod has no `IG_UI.json`.
- **Source of truth:** `EN/UI.json`. Mirror its structure; translate only the quoted values, keep keys byte-for-byte identical.
- **Key prefixes:** settings `UI_options_QFID_<optionName>` (with `_tooltip` suffix), other UI `UI_QFID_...`, in-game `IGUI_QFID_...`. Preserve `%1`/`%2` placeholders and `<BR>`/`<LINE>` tags exactly.
- **Special encodings** (everything else UTF-8): KO = UTF-16, CS = Cp1250, CA = ISO-8859-15, AR = Cp1252.
