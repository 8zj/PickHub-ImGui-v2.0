# PickHub ImGui v2.0

> A full-featured Roblox ImGui-style UI library demo with live logging, toast notifications, config save/load, accent color theming, and more.

![Version](https://img.shields.io/badge/version-2.0-red) ![Platform](https://img.shields.io/badge/platform-Roblox-blue) ![Language](https://img.shields.io/badge/language-Lua-gray)

---

## Preview

The UI features a dark ImGui-style window with tabbed navigation, a floating console logger (bottom-right), and a watermark overlay showing FPS, time, and ping.

Toggle the window at any time with `RightShift`.

---

## Features

| Category | Features |
|----------|----------|
| Core UI | Toggles, sliders, dropdowns, textboxes, keybinds, color pickers, buttons, labels, separators |
| Watermark | Top-left overlay showing FPS / time / ping, accent-colored |
| Logger | Floating bottom-right console with log types: `Success`, `Info`, `Warn`, `Error`, `Debug` |
| Notifications | Toast-style pop-ups with title, message, and duration |
| Config | Save and load named configs to/from `writefile` |
| Theming | Live accent color picker — updates the entire UI instantly |
| Toggle Key | Rebindable UI toggle key (default: `RightShift`) |

---

## Tabs

### Main
General gameplay utilities:
- Auto Farm toggle
- Anti AFK toggle
- Walk Speed slider (16–200 studs)
- Farm Mode dropdown (Normal / Aggressive / Passive / AFK)

### Combat
PVP and visual tools:
- Aimbot toggle with FOV slider, smoothness slider, target part dropdown, and keybind
- Player ESP toggle
- Chams toggle
- ESP color picker

### Misc
Quality of life:
- Teleport to location dropdown + button
- Discord webhook URL textbox
- Rejoin Server button
- Copy Server Link button

### Settings
UI customization and config management:
- Accent color picker
- UI opacity slider
- Toggle key rebind
- Config name textbox with Save / Load buttons
- Destroy UI button

---

## Load

Paste this into your executor console:

```lua
loadstring(game:HttpGet("https://pastefy.app/NPqoo1Jn/raw?cb=" .. tostring(tick())))()
```

> The `?cb=` cache-bust parameter forces Roblox to always fetch the latest version.

---

## Usage

```
RightShift          → Toggle the UI window
Settings tab        → Change accent color, rebind toggle key
Config section      → Type a name, then Save / Load your settings
Logger (bottom-right) → Live feed of all UI events and actions
```

---

## Library API (quick reference)

```lua
-- Create the window
local Window = Library:CreateWindow({ Title, Size, Position, ToggleKey })

-- Watermark overlay
Window:CreateWatermark()

-- Floating logger
local Logger = Window:CreateLogger({ Title })
Logger:Log("message", "Success" | "Info" | "Warn" | "Error" | "Debug")

-- Tabs and sections
local Tab = Window:AddTab("Tab Name")
local Section = Tab:AddSection("Section Name")

-- Elements
Section:AddLabel("text")
Section:AddSeparator()
Section:AddButton({ Text, Callback })
Section:AddToggle({ Text, Default, Flag, Callback })
Section:AddSlider({ Text, Min, Max, Default, Suffix, Flag, Callback })
Section:AddDropdown({ Text, Options, Default, Flag, Callback })
Section:AddTextbox({ Text, Placeholder, Default, Flag, Callback })
Section:AddKeybind({ Text, Default, Flag, Callback })
Section:AddColorPicker({ Text, Default, Flag, Callback })

-- Notifications
Window:Notify({ Title, Text, Duration })

-- Theming
Library:SetAccent(Color3)

-- Config
Window:SaveConfig("name")
Window:LoadConfig("name")
```

---

## Log Types

| Type | Color | Use case |
|------|-------|----------|
| `Success` | Green | Action completed |
| `Info` | Blue | General information |
| `Warn` | Yellow | Non-critical warning |
| `Error` | Red | Something went wrong |
| `Debug` | Gray | Developer info |

---

## Notes

- Tested on PickHub ImGui v2.0 — if you get a `CreateWatermark missing` warning, your paste URL may be cached or outdated.
- The demo includes a fake live log system that simulates real activity every few seconds for showcase purposes.
- Studio users can swap the `loadstring` line for `require(game.ReplicatedStorage.ImGui)`.

---

## License

This demo script is provided as-is for educational and showcase purposes.
