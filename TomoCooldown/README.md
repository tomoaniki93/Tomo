# TomoCooldown

> Standalone cooldown, resource bar, and Skyriding addon for World of Warcraft: Midnight

# ![TomoCooldown](https://img.shields.io/badge/TomoCooldown-v1.0.0-0cd29f?style=for-the-badge) ![WoW](https://img.shields.io/badge/WoW-Midnight-blue?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120001-orange?style=for-the-badge)

---

## Overview

**TomoCooldown** is a fully standalone addon extracted from the TomoMod UI suite. It bundles three complementary HUD modules into one lightweight package:

- **Cooldown Manager** — contextual alpha on action bar cooldown icons
- **Resource Bars** — class-adaptive primary and secondary resource display
- **Skyriding Bar** — speed and ability tracker for dynamic flight

TomoCooldown is completely independent — it does not require TomoMod, TomoPlates, or TomoFrames to function.

---

## Modules

---

### Cooldown Manager

Enhances WoW's built-in cooldown display on action bars with context-sensitive transparency.

**Features:**
- Reads cooldowns directly from action bar buttons — no duplicate tracking
- Three alpha levels: in combat, with a target (out of combat), fully out of combat
- Combat alpha mode can be toggled off for a flat full-opacity display
- Hotkey visibility toggle (show/hide action bar keybind labels)
- Integrates with WoW's **Edit Mode** for icon repositioning

**How it works:**
The Cooldown Manager applies alpha values to viewer frames that sit above action bar buttons. It responds to `PLAYER_REGEN_DISABLED`, `PLAYER_REGEN_ENABLED`, and `PLAYER_TARGET_CHANGED` events to transition between the three alpha states smoothly.

---

### Resource Bars

Displays your character's primary and secondary resources in a clean, draggable horizontal bar.

**Features:**
- **21 resource types** supported with individual color control:
  - Mana, Rage, Energy, Focus
  - Runic Power + Runes (Death Knight — split bar with cooldown runes)
  - Soul Shards, Astral Power, Holy Power (segmented point bars)
  - Maelstrom, Chi, Insanity, Fury
  - Combo Points, Arcane Charges
  - Essence, Stagger, Soul Fragments, Tip of the Spear, Maelstrom Weapon
- **Druid dual-bar**: automatic secondary mana bar when shapeshifted into Bear or Cat form
- **Visibility modes**: Always / In combat / With a target / Hidden
- Independent alpha for combat and out-of-combat states
- Configurable width, primary height, secondary height, global scale
- **Width sync**: optionally match bar width to the Cooldown Manager's viewer width
- Text display with font, size, and alignment controls (LEFT / CENTER / RIGHT)
- Fully draggable when unlocked

**Positioning:**
Default anchor is `CENTER, 0, -230`. Drag with `/tc unlock`, save automatically on mouse release.

---

### Skyriding Bar

Tracks speed and Skyriding abilities while on a Dragonriding / dynamic flight mount.

**Features:**
- Speed bar showing current flight speed as a percentage of maximum
- Vigor / combo point pips displayed as a secondary segmented bar
- Active Skyriding spell icons with cooldown sweeps (Surge Forward, Skyward Ascent, etc.)
- Auto-shows when mounting a Skyriding-capable mount, hides otherwise
- Configurable width, bar height, pip height, bar color, font size
- Draggable independently from resource bars

**Note:** The Skyriding bar is **disabled by default**. Enable it in the Skyriding tab or with `/tc sky`.

---

## Installation

1. Download `TomoCooldown-1_0_0.zip`
2. Extract to your WoW AddOns folder:
   ```
   World of Warcraft/_retail_/Interface/AddOns/TomoCooldown/
   ```
3. Enable **TomoCooldown** in the AddOns list at character select
4. Type `/tc` in-game to open configuration

---

## Slash Commands

| Command | Description |
|---|---|
| `/tc` | Open configuration window |
| `/tc unlock` | Unlock resource bars and Skyriding bar for repositioning |
| `/tc lock` | Lock bars (click-through restored) |
| `/tc sky` | Toggle Skyriding bar on / off |
| `/tc reset` | Reset all settings to defaults |

---

## Configuration

Open with `/tc` or via **Escape → Settings → AddOns → TomoCooldown**.

### Cooldowns Tab
- Enable / disable the Cooldown Manager
- Show / hide hotkey labels on action buttons
- Enable contextual alpha mode
- Sliders for in-combat alpha, with-target alpha, out-of-combat alpha

### Resources Tab
- Enable / disable resource bars
- Visibility mode dropdown (Always / In combat / With target / Hidden)
- Combat alpha and out-of-combat alpha sliders
- Width, primary bar height, secondary bar height, global scale
- Width sync checkbox and "Sync Now" button

### Text Tab
- Show / hide resource text
- Text alignment (Left / Center / Right)
- Font size
- Font picker: 7 bundled fonts + 3 WoW system fonts

| Font | Notes |
|---|---|
| Poppins Medium | Default — clean, readable |
| Poppins SemiBold | Slightly heavier |
| Poppins Bold | Bold weight |
| Poppins Black | Heavy display weight |
| Expressway | Condensed, action-game style |
| Accidental Pres. | Handwritten aesthetic |
| Tomo | Custom TomoAniki font |
| Friz Quadrata | WoW default UI font |
| Arial Narrow | WoW compact text font |
| Morpheus | WoW header / title font |

- Frame unlock / lock button
- Reset position button

### Colors Tab
- Individual color picker for each of the 21 resource types
- Changes apply immediately to the active bar

### Skyriding Tab
- Enable / disable the Skyriding bar
- Width, speed bar height, vigor pip height
- Bar color picker
- Font size
- Frame unlock button

---

## Credits

Extracted and adapted from **TomoMod** by TomoAniki.
