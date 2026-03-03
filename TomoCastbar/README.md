# TomoCastbar

A lightweight, standalone castbar addon for World of Warcraft (Retail — Midnight).

Replaces the default Blizzard castbar with clean, customizable bars for **Player**, **Target**, and **Focus** units. Supports regular casts, channels, **Empowered casts** (Evoker stage markers with gradient overlays), and **channel tick markers**.

# ![TomoCastbar](https://img.shields.io/badge/TomoCastbar-v1.0.0-d1b559?style=for-the-badge) ![WoW](https://img.shields.io/badge/WoW-Midnight-blue?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120001-orange?style=for-the-badge)

---

## Features

- **Player / Target / Focus** castbars — independently configurable
- **Empowered cast support** — stage markers and color gradient overlays for Evoker abilities (Fire Breath, Eternity Surge, etc.)
- **Channel tick markers** — displays tick positions on channeled spells with a built-in spell database and talent-aware modifiers (e.g. Disintegrate +1 tick with talent)
- **Custom textures** — includes custom background, border, and spark (glow) textures in `Assets/Textures/`
- **Background modes** — choose between custom texture, solid black, or fully transparent background
- **Bar texture choices** — Blizzard, Smooth, or Flat bar fill textures
- **Spark effect** — configurable glow at the leading edge of the cast bar
- **Latency overlay** — shows world latency on the player castbar so you can clip casts optimally
- **Non-interruptible indicator** — overlay color change when a cast cannot be interrupted
- **Interrupted flash** — brief colored flash + text on interrupt
- **Drag & drop positioning** — unlock castbars and drag them anywhere on screen
- **Built-in config UI** — dark-themed panel with sliders, checkboxes, color pickers, and dropdowns
- **Hide Blizzard castbar** — suppresses Player, Pet, Target, and Focus default castbar frames
- **Localization** — English (enUS) and French (frFR) supported
- **Midnight-compatible** — uses secret-safe C-side APIs (`SetMinMaxValues`, `SetValue`, `SetFormattedText`, `C_CurveUtil`)
- **Zero dependencies** — no libraries required, fully self-contained

---

## Installation

1. Download or clone this repository
2. Place the `TomoCastbar` folder into:
   ```
   World of Warcraft\_retail_\Interface\AddOns\
   ```
3. Restart WoW or type `/reload` in-game

---

## Slash Commands

| Command | Description |
|---|---|
| `/tcb` | Open the config panel |
| `/tcb lock` | Toggle lock/unlock — drag castbars to reposition |
| `/tcb reset` | Reset all settings to defaults |
| `/tcb reset player` | Reset player castbar settings |
| `/tcb reset target` | Reset target castbar settings |
| `/tcb reset focus` | Reset focus castbar settings |
| `/tcb help` | Show all available commands |

---

## Config Panel

Open with `/tcb` — a dark-themed config window with sidebar navigation:

- **General**
  - Background mode (Custom / Black / Transparent)
  - Bar texture (Blizzard / Smooth / Flat)
  - Custom border toggle
  - Spark toggle and height slider
  - Channel tick markers toggle
  - Cast colors (normal / non-interruptible / interrupted)
  - Font size slider
  - Hide Blizzard castbar toggle
  - Full reset button
- **Player** — Enable/disable, width, height, show icon, show timer, show latency, reset position
- **Target** — Enable/disable, width, height, show icon, show timer, reset position
- **Focus** — Enable/disable, width, height, show icon, show timer, reset position

---

## File Structure

```
TomoCastbar/
├── TomoCastbar.toc           # Addon manifest (Interface 12.0)
├── README.md
│
├── Assets/
│   └── Textures/
│       ├── background.png    # Custom castbar background
│       ├── border.png        # Custom border texture
│       └── cast_spark.tga    # Spark glow effect
│
├── Locales/
│   ├── enUS.lua              # English locale (always loaded)
│   └── frFR.lua              # French locale (loaded when client is frFR)
│
├── Core/
│   ├── Utils.lua             # Utilities: table merge, drag system, colors
│   ├── Database.lua          # Defaults & SavedVariables management
│   └── Init.lua              # ADDON_LOADED / PLAYER_LOGIN, slash commands
│
├── Config/
│   ├── Widgets.lua           # UI widget library (scroll, checkbox, slider, color picker, dropdown, tabs)
│   └── ConfigUI.lua          # Config panel with sidebar navigation
│
└── Modules/
    └── Castbar.lua           # Castbar engine (casts, channels, empowered, ticks, latency, spark)
```

---

## Default Settings

| Unit | Width | Height | Icon | Timer | Latency |
|---|---|---|---|---|---|
| Player | 260 | 20 | Yes | Yes | Yes |
| Target | 260 | 20 | Yes | Yes | No |
| Focus | 200 | 16 | Yes | Yes | No |

**Default colors:**
- Cast: `rgb(204, 26, 26)` — red
- Non-interruptible: `rgb(128, 128, 128)` — grey
- Interrupted: `rgb(26, 204, 26)` — green

**Default options:**
- Background mode: Custom texture
- Bar texture: Blizzard
- Custom border: Enabled
- Spark: Enabled (height 26)
- Channel ticks: Enabled
- Hide Blizzard castbar: Enabled
- Font size: 12

---

## Channel Tick Database

TomoCastbar includes a built-in database of tick counts for common channeled spells across all classes. For spells not in the database, a fallback heuristic computes approximately 1 tick per second.

Talent-aware modifiers are supported — for example, Evoker's Disintegrate gains +1 tick when the corresponding talent (spell ID 1219723) is active.

---

## Empowered Cast Gradients

Evoker empowered spells display colored stage zones that progressively reveal as the cast progresses:

| Stage | Color |
|---|---|
| 1 | Orange |
| 2 | Gold |
| 3 | Cyan |
| 4 | Purple |

---

## How It Works

TomoCastbar uses the Midnight secret-number-safe approach:

- `StatusBar:SetMinMaxValues(startTimeMS, endTimeMS)` — accepts secret values from `UnitCastingInfo` / `UnitChannelInfo`
- `StatusBar:SetValue(GetTime() * 1000)` — progress driven by non-secret client time
- `C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, 1, 0)` — converts secret boolean to secret alpha
- `SetFormattedText("%s", name)` — C-side string formatting for secret spell names
- `UnitCastingDuration` / `UnitChannelDuration` — duration objects with `:GetRemainingDuration(0)` for timer text
- Real-number extraction via `pcall` — safely attempts arithmetic on duration values; gracefully degrades for target/focus when values are tainted secrets

No `tonumber()`, no unsafe Lua-side arithmetic on secret values, no taint.

---

**Credits**

Extracted and adapted from TomoMod by TomoAniki.
