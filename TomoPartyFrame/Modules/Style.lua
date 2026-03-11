-- TomoPartyFrame Style
-- Centralized style constants and shared data

local ADDON, ns = ...

ns.Style = {}

-- Color palette (warm/classic WoW aesthetic)
ns.Style.Colors = {
    Text = { 0.84, 0.75, 0.64 },
    TextHighlight = { 1, 1, 1 },
    TextDisabled = { 0.58, 0.49, 0.40 },
    Header = { 1, 0.82, 0 },
    HeaderSection = { 0.9, 0.75, 0.4 },
    Background = { 0.067, 0.040, 0.024, 0.92 },
    BackgroundLight = { 0.10, 0.08, 0.06, 0.95 },
    BackgroundWidget = { 0.12, 0.10, 0.08, 0.90 },
    Border = { 0.25, 0.20, 0.15, 0.8 },
    BorderHighlight = { 0.4, 0.35, 0.25, 1 },
    AccentPositive = { 0.2, 0.5, 0.3, 1 },
    AccentNegative = { 0.5, 0.2, 0.2, 1 },
    TitleBar = { 0.15, 0.12, 0.10, 1 },
}

ns.Style.Sizes = {
    WindowWidth = 400,
    WindowHeight = 550,
    ContentWidth = 360,
    ButtonHeight = 24,
    SliderHeight = 16,
    SliderWidth = 180,
    CheckboxSize = 20,
    DropdownWidth = 160,
    ColorSwatchSize = 22,
    TabHeight = 26,
    TitleBarHeight = 26,
    CollapsibleHeaderHeight = 22,
}

ns.Style.Fonts = {
    Header = "GameFontNormalLarge",
    SectionHeader = "GameFontNormal",
    Label = "GameFontHighlightSmall",
    Value = "GameFontHighlightSmall",
}

ns.Style.Backdrops = {
    Window = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    },
    Tab = {
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
    },
}

-- Bar texture options
ns.barTextures = {
    { name = "Blizzard", path = "Interface/TargetingFrame/UI-StatusBar" },
    { name = "Solid", path = "Interface/Buttons/WHITE8X8" },
    { name = "Smooth", path = "Interface/RaidFrame/Raid-Bar-HP-Fill" },
    { name = "Minimalist", path = "Interface/BUTTONS/WHITE8x8" },
}

-- Health bar style definitions
ns.healthBarStyles = {
    { value = "standard", label = "Standard" },
    { value = "gradient", label = "Gradient" },
    { value = "striped", label = "Striped" },
    { value = "flat", label = "Flat" },
    { value = "pixel", label = "Pixel" },
}

-- Class colors (WoW standard)
ns.classColors = {
    WARRIOR = { r = 0.78, g = 0.61, b = 0.43 },
    PALADIN = { r = 0.96, g = 0.55, b = 0.73 },
    HUNTER = { r = 0.67, g = 0.83, b = 0.45 },
    ROGUE = { r = 1.00, g = 0.96, b = 0.41 },
    PRIEST = { r = 1.00, g = 1.00, b = 1.00 },
    DEATHKNIGHT = { r = 0.77, g = 0.12, b = 0.23 },
    SHAMAN = { r = 0.00, g = 0.44, b = 0.87 },
    MAGE = { r = 0.25, g = 0.78, b = 0.92 },
    WARLOCK = { r = 0.53, g = 0.53, b = 0.93 },
    MONK = { r = 0.00, g = 1.00, b = 0.60 },
    DRUID = { r = 1.00, g = 0.49, b = 0.04 },
    DEMONHUNTER = { r = 0.64, g = 0.19, b = 0.79 },
    EVOKER = { r = 0.20, g = 0.58, b = 0.50 },
}

-- Power type colors
ns.powerColors = {
    [0] = { r = 0.00, g = 0.00, b = 1.00 },  -- Mana
    [1] = { r = 1.00, g = 0.00, b = 0.00 },  -- Rage
    [2] = { r = 1.00, g = 0.50, b = 0.25 },  -- Focus
    [3] = { r = 1.00, g = 1.00, b = 0.00 },  -- Energy
    [4] = { r = 1.00, g = 0.96, b = 0.41 },  -- Combo Points
    [5] = { r = 0.50, g = 0.50, b = 0.50 },  -- Runes
    [6] = { r = 0.00, g = 0.82, b = 1.00 },  -- Runic Power
}

-- Dispel type colors
ns.dispelTypeColors = {
    Magic = { r = 0.2, g = 0.6, b = 1.0 },
    Curse = { r = 0.6, g = 0.0, b = 1.0 },
    Disease = { r = 0.6, g = 0.4, b = 0.0 },
    Poison = { r = 0.0, g = 0.6, b = 0.1 },
}
