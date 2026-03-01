# TomoFrames

> Standalone unit frame addon for World of Warcraft: Midnight

# ![TomoFrames](https://img.shields.io/badge/TomoFrames-v1.0.0-0cd29f?style=for-the-badge) ![WoW](https://img.shields.io/badge/WoW-Midnight-blue?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120001-orange?style=for-the-badge)

---

## Overview

**TomoFrames** is a fully standalone unit frame replacement extracted from the TomoMod UI suite. It replaces Blizzard's default Player, Target, Target-of-Target, Pet, Focus, and Boss frames with a consistent, highly configurable design that shares the same visual language as TomoPlates and TomoCooldown.

TomoFrames is completely independent — it does not require TomoMod or any other addon to function.

---

## Features

### Supported Frames

| Frame | Description |
|---|---|
| **Player** | Health, power, castbar, auras, absorb, leader icon |
| **Target** | Health, power, castbar, auras, enemy buffs, threat, raid/quest icons |
| **Target of Target** | Health bar, name, minimal display |
| **Pet** | Health bar, name |
| **Focus** | Health, power, castbar, auras |
| **Boss 1–5** | Health bars stacked, raid marker, name, health %, drag together |

### Health Bar
- Class color, faction color, or nameplate-style reaction color
- Health text with 5 formats: `current`, `percent`, `current_percent`, `current_max`, `deficit`
- Absorb bar overlay
- Threat indicator (color glow)
- Configurable width, total height, health height, power height per frame

### Power Bar
- Automatically adapts to the player's active resource type
- Color per power type (mana, rage, energy, focus, runic power, etc.)
- Optional power text display

### Castbar
- Per-unit castbar with configurable position, width, height
- Spell icon, cast timer, latency spark (player only)
- Interruptible / non-interruptible / interrupted colors (global setting)
- Draggable independently from the unit frame
- **Double API call race condition fixed** — single `UnitCastingInfo()` / `UnitChannelInfo()` call per update

### Auras
- Debuffs or buffs displayed in a configurable container
- Growth direction: LEFT or RIGHT
- Max count, icon size, spacing all configurable
- "Only my auras" filter
- Animated cooldown sweeps + duration text

### Enemy Buffs (Target only)
- Separate container from debuffs
- Independent max count, icon size, growth direction

### Boss Frames
- Stacked vertically (1–5 active bosses)
- All 5 frames move together via the boss1 drag handle
- Raid marker displayed left of name
- Health displayed as percentage only
- Color follows nameplate classification colors if TomoPlates is installed

### Frame Dragging
- All frames are draggable when unlocked via `/tf unlock`
- Positions saved per character in `TomoFramesDB`
- Amber-tinted drag overlay for clear visual feedback
- Lock with `/tf lock` to restore click-through behavior

---

## Installation

1. Download `TomoFrames-1_0_0.zip`
2. Extract to your WoW AddOns folder:
   ```
   World of Warcraft/_retail_/Interface/AddOns/TomoFrames/
   ```
3. Enable **TomoFrames** in the AddOns list at character select
4. Type `/tf` in-game to open configuration

---

## Slash Commands

| Command | Description |
|---|---|
| `/tf` | Open configuration window |
| `/tf enable` | Enable TomoFrames and show all frames |
| `/tf disable` | Disable TomoFrames |
| `/tf unlock` | Unlock all frames for repositioning |
| `/tf lock` | Lock frames (click-through restored) |
| `/tf refresh` | Force refresh all frames |
| `/tf reset` | Reset all settings to defaults |

---

## Configuration

Open with `/tf` or via **Escape → Settings → AddOns → TomoFrames**.

### Global Tab
- Enable / disable the addon
- Hide Blizzard's default frames toggle
- Global font size
- Global castbar colors (interruptible, non-interruptible, interrupted)
- Frame unlock / lock instructions
- Boss frame settings: enable, width, height, spacing

### Per-Unit Tabs (Player / Target / ToT / Focus / Pet)

Each unit has its own configuration tab with:
- Enable / disable that specific frame
- Width, total height, health height, power height
- Show/hide: name, level, health text, class color, faction color, absorb, threat
- Health text format
- Castbar: enable, width, height, icon, timer, latency, color
- Auras: enable, type (debuffs/buffs/all), max count, icon size, only-mine filter
- Enemy buffs (Target only): enable, max count, icon size

---

## Default Positions

| Frame | Default Anchor |
|---|---|
| Player | `CENTER -280, -190` |
| Player Castbar | `CENTER -280, -220` |
| Target | `CENTER +280, -190` |
| Target Castbar | Below target frame |
| Target of Target | Right of target frame |
| Pet | Left of player frame |
| Focus | `TOPLEFT +20, -200` |
| Boss | `RIGHT -80, +200` |

All positions can be overridden by dragging after `/tf unlock`.

---

## Credits

Extracted and adapted from **TomoMod** by TomoAniki.
