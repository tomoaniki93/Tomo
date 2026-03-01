# TomoPlates

> Standalone nameplate addon for World of Warcraft: Midnight

# ![TomoPlates](https://img.shields.io/badge/TomoPlates-v1.0.0-0cd29f?style=for-the-badge) ![WoW](https://img.shields.io/badge/WoW-Midnight-blue?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120001-orange?style=for-the-badge)

---

## Overview

**TomoPlates** is a fully standalone nameplate replacement extracted from the TomoMod UI suite. It replaces Blizzard's default nameplates with a clean, performance-optimized design featuring customizable health bars, castbars, auras, and a threat system with rounded border and glow effects.

TomoPlates is completely independent — it does not require TomoMod or any other addon to function.

---

## Features

### Health Bar
- Custom health bar with configurable width, height, and texture
- Reaction-based coloring: hostile, neutral, friendly, tapped, focus
- NPC type detection: casters (blue), mini-bosses (purple), enemies in combat (red)
- Classification coloring: boss, elite, rare, normal, trivial
- Class colors for enemy players
- Out-of-combat darkening (×0.60 multiplier)
- Absorb bar overlay

### Castbar
- Displays below the health bar
- Interruptible cast color (configurable, default red)
- Non-interruptible cast color (configurable, default grey)
- Empower stage markers for empowered spells
- Interrupt animation with green flash on successful kick
- **Race condition fixes** — START events processed immediately, no flicker on cast begin, no blocked display after interrupts

### Auras
- Debuffs displayed above the unit name (up to 10, configurable)
- "Only my debuffs" filter option
- Enemy buff row displayed to the left of the health bar
- Separate size and count controls for debuffs vs enemy buffs
- Cooldown sweeps and duration text on all icons

### Threat System
- Rounded 9-slice border using `border.png` asset
- Additive-blended glow halo using `background.png` asset
- Dynamic color from `GetThreatStatusColor()`
- **Tank mode**: 50% alpha reduction in instances for a less intrusive display

### Alpha & Stacking
- Independent alpha for selected vs non-selected plates
- CVar-based vertical overlap control
- Top inset control (how high plates render on screen)

### Performance
- Dirty-flag batch system — START/CHANNEL/EMPOWER events are processed immediately, all others batched
- No per-frame operations outside active casts
- Conditional processing skips invisible or dead units

---

## Installation

1. Download `TomoPlates-1_0_0.zip`
2. Extract to your WoW AddOns folder:
   ```
   World of Warcraft/_retail_/Interface/AddOns/TomoPlates/
   ```
3. Enable **TomoPlates** in the AddOns list at character select
4. Type `/tp` in-game to open configuration

---

## Slash Commands

| Command | Description |
|---|---|
| `/tp` | Open configuration window |
| `/tp enable` | Enable TomoPlates |
| `/tp disable` | Disable TomoPlates |
| `/tp refresh` | Force refresh all active nameplates |
| `/tp reset` | Reset all settings to defaults |

---

## Configuration

Open with `/tp` or via **Escape → Settings → AddOns → TomoPlates**.

### General Tab
- Enable / disable the addon
- Width, health bar height, name font size
- Show/hide: name, level, health text, classification, absorb, threat indicator
- Health text format: Percentage / Current value / Current + percentage
- Class colors for enemy players
- Castbar: enable, height, colors for interruptible and non-interruptible casts

### Auras Tab
- Enable debuffs above nameplate, set max count and icon size
- "Only my debuffs" toggle
- Enemy buffs: enable, icon size, max count

### Advanced Tab
- Alpha for selected and non-selected plates
- Vertical stacking overlap and top screen inset
- Full color customization for all reaction types, NPC types, and classifications
- Tank mode: enable, color per threat status (no threat / low threat / has threat / DPS has aggro / DPS near aggro)
- Reset button

---

## Known Limitations

- Friendly player nameplates are not styled (Blizzard restriction on friendly secure frames)
- Skyriding / vehicle frames are handled by Blizzard and hidden automatically during those states

---

## Credits

Extracted and adapted from **TomoMod** by TomoAniki.
