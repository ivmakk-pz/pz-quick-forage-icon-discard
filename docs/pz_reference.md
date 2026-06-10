# PZ modding reference (project lookup)

Lookup material for this mod, migrated from the old `.github/instructions/` Copilot config. CLAUDE.md points here; read the relevant section when you actually need it.

## mod.info format

Source: https://pzwiki.net/wiki/Mod.info — UTF-8 text file, one `key=value` per line.

- **No spaces around `=`**: `name=ModName` (not `name = ModName`).
- Parameter names are case-sensitive.
- Mod ID references take a backslash prefix and comma-separate: `require=\mod1,\mod2`, `incompatible=\mod1`.
- Filename must be lowercase `mod.info` (Linux/macOS).

Required: `name`, `id`. Recommended: `author`, `description`, `modversion`. Common optional: `poster`, `icon`, `versionMin`, `versionMax`, `tags`, `require`, `incompatible`, `url`, `loadModAfter`, `loadModBefore`.

This mod's `id` is `Ivmakk_QuickForageIconDiscard` (format `Author_ModName`). For the per-build `versionMin`/`versionMax` values and sync rules, see CLAUDE.md.

## PZAPI.ModOptions API quick reference

Used by `media/lua/client/QFID_ModOptions.lua`. Options must be registered on `Events.OnCreateUI` (not `OnGameStart`) — the UI must be loaded before `PZAPI.ModOptions` exists — and wrapped in `pcall` so a failure falls back to hardcoded defaults.

```lua
local options = PZAPI.ModOptions:create("ModID", getText("UI_options_title"))

-- Formatting
options:addTitle("Section Title")
options:addDescription("Description text")
options:addSeparator()

-- Interactive
local checkbox = options:addTickBox("id", getText("label"), defaultValue, getText("tooltip"))
local textField = options:addTextEntry("id", getText("label"), "defaultText", getText("tooltip"))
local keybind   = options:addKeyBind("id", getText("label"), Keyboard.KEY_Z, getText("tooltip"))
local slider    = options:addSlider("id", getText("label"), min, max, step, defaultValue, getText("tooltip"))
local colorPick = options:addColorPicker("id", getText("label"), r, g, b, a, getText("tooltip"))
local button    = options:addButton("id", getText("label"), getText("tooltip"), callback)

local dropdown = options:addComboBox("id", getText("label"), getText("tooltip"))
dropdown:addItem("Option 1", false)   -- second arg = initially selected
dropdown:addItem("Option 2", true)

local multiBox = options:addMultipleTickBox("id", getText("label"), getText("tooltip"))
multiBox:addTickBox("Sub Option 1", false)  -- read via getValue(1)

-- Reading values
checkbox:getValue()   -- boolean
textField:getValue()  -- string
keybind:getValue()    -- keyboard key constant
slider:getValue()     -- number in [min,max]
colorPick:getValue()  -- {r,g,b,a}
dropdown:getValue()   -- 1-based index
multiBox:getValue(1)  -- boolean for sub-checkbox 1
```

Conventions: don't add options or localization unless asked; no separators unless asked; new labels/tooltips must be added to `UI_EN.txt` (and the other languages); name options positively ("Show X", not "Hide X"); follow `UI_options_QFID_<name>` / `UI_options_QFID_<name>_tooltip`.

## Steam Workshop BBCode (workshop_description.bbcode)

Source: https://steamcommunity.com/comment/Guide/formattinghelp. Tags must be closed.

| BBCode | Meaning |
|---|---|
| `[b]…[/b]` | bold |
| `[i]…[/i]` | italic |
| `[u]…[/u]` | underline |
| `[strike]…[/strike]` / `[s]…[/s]` | strikethrough |
| `[url]http://…[/url]` or `[url=http://…]Label[/url]` | hyperlink |
| `[code]…[/code]` | monospace block |
| `[h1]…[/h1]` … `[h5]…[/h5]` | headers |
| `[quote]…[/quote]` | blockquote |
| `[list][*]Item[*]Item[/list]` | bulleted list |
| `[olist][*]First[*]Second[/olist]` | numbered list |
| `[img]http://…[/img]` | image |
| `[spoiler]…[/spoiler]` | spoiler |
| `[table][tr][td]A[/td][td]B[/td][/tr][/table]` | table |

Do **not** add `Workshop ID:` or `Mod ID:` lines — Steam auto-generates those on publish.
