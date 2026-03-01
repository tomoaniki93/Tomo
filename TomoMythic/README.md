# TomoMythic

# ![TomoMythic](https://img.shields.io/badge/TomoMythic-v1.0.0-0cd29f?style=for-the-badge) ![WoW](https://img.shields.io/badge/WoW-Midnight-blue?style=for-the-badge) ![Interface](https://img.shields.io/badge/Interface-120001-orange?style=for-the-badge)

**A clean, standalone Mythic+ interface replacement for Midnight**

TomoMythic completely replaces Blizzard's default Mythic+ tracking UI with a compact, dark-themed panel. It is fully independent — no dependencies, no libraries — and optionally integrates with [TomoMod](https://www.curseforge.com/wow/addons/tomomod) for a consistent visual experience.

---

## Features

### Timer Bar
- Live elapsed time with a color-coded progress bar (green → yellow → red)
- ±Delta display showing how far ahead or behind the timer limit you are
- Tick marks for the **In Time** and **+2 Bonus** thresholds
- Dedicated chest countdown row showing remaining time for each reward tier

### Enemy Forces Bar
- Real-time percentage and raw count (e.g. `730 / 1000`)
- Color interpolates from blue → teal → green as forces fill up

### Boss Timers
- One row per boss with kill time recorded at the moment of death
- Completed bosses highlighted in green with a checkmark
- Alternating row backgrounds for easy readability

### Header
- Dungeon name and key level on the top line
- Affix icons and death counter (with time penalty) on the bottom line
- Uses native WoW icon textures — no broken glyphs

### Completion Banner
- Shows **COMPLETED** (green) or **DEPLETED** (red) with the final run time
- Persists on screen until you leave the instance

### Quality of Life
- **Suppresses all Blizzard M+ UI** — ObjectiveTrackerFrame, ScenarioFrame, challenge mode blocks — nothing bleeds through
- **Auto-slots your keystone** when you open the Font of Power
- **Fully draggable** panel with saved position per character

---

## Slash Commands

| Command | Action |
|---|---|
| `/tmt` | Open / close the configuration panel |
| `/tmt unlock` | Unlock the frame for dragging |
| `/tmt lock` | Lock the frame in place |
| `/tmt preview` | Show a preview with sample data |
| `/tmt reset` | Reset position to default |
| `/tmt help` | Print command list to chat |

---

## Configuration Panel

Open with `/tmt`. All settings are saved automatically.

- **Show Timer Bar** — toggle the timer progress bar
- **Show Enemy Forces** — toggle the forces bar
- **Show Boss Timers** — toggle individual boss rows
- **Hide Blizzard Tracker** — suppress the default Blizzard M+ UI (recommended: ON)
- **Lock Frame** — prevent accidental dragging
- **Scale** — resize the entire panel (0.5× – 2.0×)
- **Background Opacity** — adjust panel transparency
- **Reset Position** — snap back to the default position (top-right of screen)

---

## TomoMod Integration

TomoMythic is **completely standalone** and requires nothing else to function.

However, if [TomoMod](https://www.curseforge.com/wow/addons/tomomod) is installed, TomoMythic automatically matches its visual style:
- Same midnight-blue background panel
- Same apple-green 3px left accent strip
- Same 1px border lines and separator colors
- Same font size and shadow settings as the TomoMod Objective Tracker skin

The two addons side by side look like a single cohesive interface.

---

## Installation

1. Download the latest release
2. Extract the `TomoMythic` folder into your `World of Warcraft\_retail_\Interface\AddOns\` directory
3. Reload your UI or restart the game client
4. Type `/tmt preview` in-game to verify it's working

---

## Feedback & Bug Reports

Please use the **Issues** tab on CurseForge or leave a comment on the project page. When reporting a bug, include:
- Your TomoMythic version (shown in the bottom-right corner of the config panel)
- Any other Mythic+ addons you have installed
- The error message from `BugSack` / `!BugGrabber` if available

---

## Changelog

### 1.0.0
- Initial release
- Full Blizzard M+ UI suppression
- Timer bar with chest thresholds and countdown row
- Enemy forces bar with color interpolation
- Boss rows with kill times
- Completion banner (in-time / depleted)
- Auto-slot keystone quality of life
- Full EN / FR localization
- Optional TomoMod skin integration

---

*TomoMythic is not affiliated with or endorsed by Blizzard Entertainment.*
