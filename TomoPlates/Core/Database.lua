-- =====================================
-- Database.lua — Defaults & Init
-- TomoPlates v1.0.0
-- =====================================

local ADDON_FONT    = "Interface\\AddOns\\TomoPlates\\Assets\\Fonts\\Poppins-Medium.ttf"

TomoPlates_Defaults = {
    enabled = true,

    -- Dimensions
    width           = 156,
    height          = 17,
    font            = ADDON_FONT,
    fontSize        = 10,
    nameFontSize    = 11,
    fontOutline     = "OUTLINE",

    -- Display
    showName                = true,
    showLevel               = false,
    showHealthText          = true,
    healthTextFormat        = "current_percent",   -- "percent" | "current" | "current_percent"
    showClassification      = true,
    showThreat              = true,
    showAbsorb              = true,
    useClassColors          = true,
    useClassificationColors = true,

    -- Castbar
    showCastbar           = true,
    castbarHeight         = 14,
    castbarColor          = { r = 0.85, g = 0.15, b = 0.15 },
    castbarUninterruptible = { r = 0.45, g = 0.45, b = 0.45 },

    -- Auras (debuffs above name)
    showAuras       = true,
    auraSize        = 24,
    maxAuras        = 5,
    showOnlyMyAuras = true,

    -- Enemy buffs (left of health bar)
    showEnemyBuffs  = true,
    enemyBuffSize   = 22,
    maxEnemyBuffs   = 4,
    enemyBuffYOffset = 4,

    -- Alpha
    selectedAlpha   = 1.0,
    unselectedAlpha = 0.8,

    -- CVar stacking
    overlapV  = 1.05,
    topInset  = 0.065,

    -- Health colors
    colors = {
        hostile       = { r = 0.78, g = 0.04, b = 0.04 },
        neutral       = { r = 0.81, g = 0.72, b = 0.19 },
        friendly      = { r = 0.11, g = 0.82, b = 0.11 },
        tapped        = { r = 0.50, g = 0.50, b = 0.50 },
        focus         = { r = 0.05, g = 0.82, b = 0.62 },
        caster        = { r = 0.23, g = 0.51, b = 0.97 },
        miniboss      = { r = 0.52, g = 0.24, b = 0.98 },
        enemyInCombat = { r = 0.80, g = 0.14, b = 0.14 },
        boss          = { r = 0.85, g = 0.10, b = 0.10 },
        elite         = { r = 0.52, g = 0.24, b = 0.98 },
        rare          = { r = 0.00, g = 0.80, b = 0.80 },
        normal        = { r = 0.80, g = 0.14, b = 0.14 },
        trivial       = { r = 0.50, g = 0.50, b = 0.50 },
    },

    -- Tank mode
    tankMode = false,
    tankColors = {
        noThreat    = { r = 1.00, g = 0.22, b = 0.17 },
        lowThreat   = { r = 0.81, g = 0.72, b = 0.19 },
        hasThreat   = { r = 0.05, g = 0.82, b = 0.62 },
        dpsHasAggro = { r = 1.00, g = 0.50, b = 0.00 },
        dpsNearAggro = { r = 0.81, g = 0.72, b = 0.19 },
    },
}

-- =====================================
-- Merge helper (copy missing keys only)
-- =====================================
local function MergeTables(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then dest[k] = {} end
            MergeTables(dest[k], v)
        elseif dest[k] == nil then
            dest[k] = v
        end
    end
end

function TomoPlates_InitDB()
    if not TomoPlatesDB then TomoPlatesDB = {} end
    MergeTables(TomoPlatesDB, TomoPlates_Defaults)
end

function TomoPlates_ResetDB()
    TomoPlatesDB = CopyTable(TomoPlates_Defaults)
    print("|cff8b5cf6TomoPlates|r : Settings reset to defaults.")
    if TomoPlates_NP then
        TomoPlates_NP.RefreshAll()
    end
end
