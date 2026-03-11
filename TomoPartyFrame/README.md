# TomoPartyFrame

A lightweight, fully-featured party frame replacement addon for **World of Warcraft (Retail)**. Designed as a standalone alternative to the default Blizzard party frames, with extensive customization and no external library dependencies.

## Features

- **Complete party frame replacement** — replaces Blizzard party frames for up to 5 members (player + party1–4)
- **Health & power bars** — class-colored or custom health bar with multiple display styles (Standard, Gradient, Striped, Flat, Pixel), smooth interpolation, power bar with type-based coloring
- **Heal prediction & absorbs** — incoming heal overlay, absorb shields (attached + overflow), heal absorb indicator
- **Aura display** — configurable buff and debuff icons with cooldown swipes, stack counts, and expiring indicators
- **Dispel icons** — per-type custom icons (Magic, Curse, Disease, Poison) displayed on frames with dispellable debuffs; alternative animated border mode also available
- **Private auras** — boss debuff anchors via `C_UnitAuras.AddPrivateAuraAnchor` for Mythic+ and raid content
- **Defensive icon** — center icon for important defensive cooldowns with duration swipe
- **Indicators** — role icon, leader/assistant icon, raid target marker (with configurable anchor position), resurrect, ready check, summon status
- **Selection & hover highlights** — customizable border highlights for the current target and mouseover
- **Range fade** — out-of-range members fade to a configurable alpha
- **Auto-hide when solo** — party frames automatically hide when not in a group
- **Drag & drop positioning** — unlock frames and drag to reposition anywhere on screen
- **Test mode** — preview frames with fake data without needing a group, with animated health bars and per-element toggles
- **Full options panel** — tabbed configuration window with sliders, checkboxes, dropdowns, and color pickers
- **Localization** — English (enUS) and French (frFR) support
- **Zero dependencies** — no external libraries required

## Installation

1. Download or clone this repository.
2. Place the `TomoPartyFrame` folder into your WoW addons directory:
   ```
   World of Warcraft\_retail_\Interface\AddOns\TomoPartyFrame
   ```
3. Restart WoW or type `/reload` in-game.

## Slash Commands

| Command | Description |
|---------|-------------|
| `/tpf` | Open the options window |
| `/tpf options` | Open the options window |
| `/tpf test` | Toggle test mode (fake party frames) |
| `/tpf unlock` | Enable drag mode to reposition frames |
| `/tpf lock` | Lock frames in place |
| `/tpf refresh` | Force refresh all frames |

`/tomopartyframe` is also accepted as a full-length alternative.

## Configuration

Open the options panel with `/tpf` and navigate through four tabs:

### Layout
- Growth direction (Down / Up / Left / Right)
- Sort mode (Group order or Role: Tank > Healer > DPS)
- Frame dimensions (width 60–300px, height 20–200px)
- Spacing, max columns, column spacing
- Show/hide player frame
- Hide Blizzard default frames
- Name text settings (position, alignment, size, class coloring, shadow)

### Appearance
- Health bar style (Standard, Gradient, Striped, Flat, Pixel)
- Health bar color mode (class color or custom)
- Health and power bar background colors
- Smooth health bar transitions
- Power bar visibility and height
- Frame background and border colors
- Range fade with adjustable alpha
- Selection and hover highlight colors and thickness

### Features
- Role, leader, and raid marker icons (with size controls)
- Raid marker anchor position (9-point anchor) and X/Y offset
- Buff and debuff display (count, size, corner position)
- Expiring aura indicator with configurable threshold
- Dispel display mode (Icon, Border, or Both) with icon size and border thickness controls
- Heal prediction, absorb, and heal absorb overlays with colors
- Private aura (boss debuff) display (count, size)
- Resurrect, ready check, summon, and defensive indicators

### Test
- Toggle test mode and drag mode
- Adjust test frame count (1–5)
- Animate health bars
- 20 individual toggles to preview specific elements (auras, dispel, dead/offline states, absorbs, markers, etc.)
- Reset all settings to defaults

## File Structure

```
TomoPartyFrame/
├── TomoPartyFrame.toc          # Addon manifest
├── README.md
├── Assets/
│   └── Textures/               # Icon textures (dispel type icons)
├── Locales/
│   ├── enUS.lua                # English localization
│   └── frFR.lua                # French localization
├── Core/
│   ├── Init.lua                # Initialization, events, layout, slash commands
│   ├── Utils.lua               # DeepCopy & DeepMerge utilities
│   └── Database.lua            # Default settings & SavedVariables
├── Modules/
│   ├── Style.lua               # Colors, fonts, sizes, class/power/dispel palettes
│   ├── PartyFrame.lua          # Unit frame creation & update logic
│   └── TestPanel.lua           # Test mode with fake data & animation
└── Config/
    ├── Widgets.lua             # Reusable UI widgets (sliders, checkboxes, etc.)
    └── ConfigUI.lua            # Tabbed options window
```

## Saved Variables

Settings are stored in `TomoPartyFramDB` (a single flat table). New default keys are automatically merged on addon updates, and color tables are validated and repaired if corrupted.

## Compatibility

- **Interface version:** 12.0.0 / 12.0.1 (Midnight — Retail)
- **No external libraries** — does not require LibStub, Ace3, or any other framework
- **Secure templates** — uses `SecureUnitButtonTemplate` for click-to-target and right-click menus (combat safe)

## Author

**TomoAniki** — Part of the TomoSuite addon collection.

## License

This addon is provided as-is for personal use within World of Warcraft.
