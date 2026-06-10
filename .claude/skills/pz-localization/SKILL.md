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

Translations live under `Contents/mods/QuickForageIconDiscard/42/media/lua/shared/Translate/<LANG>/UI.json`. The English file (`EN/UI.json`) is the source of truth — translate only the quoted string values, never the keys.

## File format: JSON

`UI.json` is a flat JSON object (build 42.15+). Mirror `EN/UI.json` as your template. (Older builds used a legacy Lua `.txt` format in a separate `42/` folder; that and the multi-version layout were dropped in 1.4.0.)

## Key-naming rules

- Every key carries the mod prefix. UI/settings keys use `UI_QFID_...`; option labels follow `UI_options_QFID_<optionName>` with tooltips at `UI_options_QFID_<optionName>_tooltip`. In-game UI keys use the `IGUI_QFID_` prefix.
- Keep key names byte-for-byte identical to the English file across all languages — translate values only.
- Preserve template placeholders (`%1`, `%2`, ...) and any `<BR>`/`<LINE>` tags exactly.
- You may reuse vanilla keys in code via `getText("UI_Yes")` etc.; placeholders are filled in Lua, not in the translation files.

## Procedure

1. Read the English source `42/media/lua/shared/Translate/EN/UI.json`.
2. Create `<LANG>/` under `42/media/lua/shared/Translate/`.
3. Translate every value; keep keys, placeholders, and tags intact. Match the JSON object structure exactly.
4. Use the correct encoding for the language (see table).
5. Verify keys match the EN file (translate values only).

## Supported language codes and encodings (Build 42)

Most languages are UTF-8. The exceptions matter — getting encoding wrong renders garbled text in-game.

| Code | Language | Encoding |
|------|----------|----------|
| AR | Spanish (Argentina) | Cp1252 |
| CA | Catalan | ISO-8859-15 |
| CH | Traditional Chinese | UTF-8 |
| CN | Simplified Chinese | UTF-8 |
| CS | Czech | Cp1250 |
| DA | Danish | UTF-8 |
| DE | German | UTF-8 |
| EN | English | UTF-8 |
| ES | Spanish | UTF-8 |
| FI | Finnish | UTF-8 |
| FR | French | UTF-8 |
| HU | Hungarian | UTF-8 |
| ID | Indonesian | UTF-8 |
| IT | Italian | UTF-8 |
| JP | Japanese | UTF-8 |
| KO | Korean | UTF-16 |
| NL | Dutch | UTF-8 |
| NO | Norwegian | UTF-8 |
| PH | Tagalog | UTF-8 |
| PL | Polish | UTF-8 |
| PT | Portuguese | UTF-8 |
| PTBR | Brazilian Portuguese | UTF-8 |
| RO | Romanian | UTF-8 |
| RU | Russian | UTF-8 |
| TH | Thai | UTF-8 |
| TR | Turkish | UTF-8 |
| UA | Ukrainian | UTF-8 |

Special encodings to remember: KO = UTF-16, CS = Cp1250, CA = ISO-8859-15, AR = Cp1252. Everything else UTF-8.
