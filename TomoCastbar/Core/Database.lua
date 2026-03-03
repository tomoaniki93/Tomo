-- =====================================
-- Database.lua — Defaults & DB Management for TomoCastbar
-- =====================================

local DEFAULT_FONT = "Fonts\\FRIZQT__.TTF"
local DEFAULT_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"

-- Custom asset paths
local ADDON_PATH = "Interface\\AddOns\\TomoCastbar\\Assets\\Textures\\"
local CUSTOM_BACKGROUND = ADDON_PATH .. "background"
local CUSTOM_BORDER     = ADDON_PATH .. "border"
local CUSTOM_SPARK      = ADDON_PATH .. "cast_spark"

-- =====================================
-- DEFAULTS
-- =====================================

TomoCastbar_Defaults = {
    -- Global settings
    texture = DEFAULT_TEXTURE,
    font = DEFAULT_FONT,
    fontSize = 12,

    -- Custom textures
    backgroundMode      = "custom",   -- "custom", "black", "transparent"
    barTexture          = "blizzard", -- "blizzard", "smooth", "flat"
    useCustomBorder     = true,
    showSpark           = true,
    sparkHeight         = 26,
    showChannelTicks    = true,

    -- Asset paths (for reference by other modules)
    customBackgroundPath = CUSTOM_BACKGROUND,
    customBorderPath     = CUSTOM_BORDER,
    customSparkPath      = CUSTOM_SPARK,

    -- Colors
    castbarColor          = { r = 0.80, g = 0.10, b = 0.10 },
    castbarNIColor        = { r = 0.50, g = 0.50, b = 0.50 },
    castbarInterruptColor = { r = 0.10, g = 0.80, b = 0.10 },

    -- Hide Blizzard castbar
    hideBlizzardCastbar = true,

    -- Per-unit castbar settings
    player = {
        enabled = true,
        width = 260,
        height = 20,
        showIcon = true,
        showTimer = true,
        showLatency = true,
        position = { point = "BOTTOM", relativePoint = "CENTER", x = -280, y = -220 },
    },

    target = {
        enabled = true,
        width = 260,
        height = 20,
        showIcon = true,
        showTimer = true,
        showLatency = false,
        position = { point = "BOTTOM", relativePoint = "CENTER", x = 280, y = -250 },
    },

    focus = {
        enabled = true,
        width = 200,
        height = 16,
        showIcon = true,
        showTimer = true,
        showLatency = false,
        position = { point = "CENTER", relativePoint = "CENTER", x = -350, y = 100 },
    },
}

-- =====================================
-- DB FUNCTIONS
-- =====================================

function TomoCastbar_InitDatabase()
    if not TomoCastbarDB then
        TomoCastbarDB = {}
    end
    TomoCastbar_MergeTables(TomoCastbarDB, TomoCastbar_Defaults)
end

function TomoCastbar_ResetDatabase()
    TomoCastbarDB = CopyTable(TomoCastbar_Defaults)
    local L = TomoCastbar_L
    print("|cffd1b559TomoCastbar|r " .. L["DB_RESET"])
end

function TomoCastbar_ResetUnit(unitKey)
    if TomoCastbar_Defaults[unitKey] then
        TomoCastbarDB[unitKey] = CopyTable(TomoCastbar_Defaults[unitKey])
        local L = TomoCastbar_L
        print("|cffd1b559TomoCastbar|r " .. string.format(L["UNIT_RESET"], unitKey))
    end
end
