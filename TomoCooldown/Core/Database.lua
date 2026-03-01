-- =====================================
-- Database.lua — Defaults & Init
-- TomoCooldown v1.0.0
-- =====================================

local ADDON_FONT    = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-Medium.ttf"
local ADDON_TEXTURE = "Interface\\AddOns\\TomoCooldown\\Assets\\Textures\\tomoaniki"

TomoCooldown_Defaults = {

    -- =====================
    -- COOLDOWN MANAGER
    -- =====================
    cooldownManager = {
        enabled          = true,
        showHotKey       = false,
        combatAlpha      = true,
        alphaInCombat    = 1.0,
        alphaWithTarget  = 0.8,
        alphaOutOfCombat = 0.5,
    },

    -- =====================
    -- RESOURCE BARS
    -- =====================
    resourceBars = {
        enabled              = true,
        texture              = ADDON_TEXTURE,
        visibilityMode       = "always",   -- always | combat | target | hidden
        combatAlpha          = 1.0,
        oocAlpha             = 0.6,
        width                = 260,
        primaryHeight        = 16,
        secondaryHeight      = 12,
        scale                = 1.0,
        showText             = true,
        textAlignment        = "CENTER",   -- LEFT | CENTER | RIGHT
        font                 = ADDON_FONT,
        fontSize             = 11,
        syncWidthWithCooldowns = false,
        position = {
            point         = "BOTTOM",
            relativePoint = "CENTER",
            x = 0, y = -230,
        },
        colors = {
            mana            = { r = 0.00, g = 0.00, b = 1.00 },
            rage            = { r = 1.00, g = 0.00, b = 0.00 },
            energy          = { r = 1.00, g = 1.00, b = 0.00 },
            focus           = { r = 0.72, g = 0.55, b = 0.05 },
            runicPower      = { r = 0.00, g = 0.82, b = 1.00 },
            runes           = { r = 0.50, g = 0.50, b = 0.50 },
            runesReady      = { r = 0.75, g = 0.22, b = 0.22 },
            soulShards      = { r = 0.58, g = 0.51, b = 0.79 },
            astralPower     = { r = 0.30, g = 0.52, b = 0.90 },
            holyPower       = { r = 0.95, g = 0.90, b = 0.60 },
            maelstrom       = { r = 0.00, g = 0.50, b = 1.00 },
            chi             = { r = 0.71, g = 1.00, b = 0.92 },
            insanity        = { r = 0.40, g = 0.00, b = 0.80 },
            fury            = { r = 0.78, g = 0.26, b = 0.99 },
            comboPoints     = { r = 1.00, g = 0.96, b = 0.41 },
            arcaneCharges   = { r = 0.10, g = 0.10, b = 0.98 },
            essence         = { r = 0.00, g = 0.80, b = 0.60 },
            stagger         = { r = 0.52, g = 1.00, b = 0.52 },
            soulFragments   = { r = 0.80, g = 0.20, b = 1.00 },
            tipOfTheSpear   = { r = 0.20, g = 0.80, b = 0.20 },
            maelstromWeapon = { r = 0.00, g = 0.50, b = 1.00 },
        },
    },

    -- =====================
    -- SKYRIDING
    -- =====================
    skyRide = {
        enabled     = false,
        width       = 340,
        height      = 20,
        comboHeight = 5,
        font        = ADDON_FONT,
        fontSize    = 12,
        fontOutline = "OUTLINE",
        barColor    = { r = 1, g = 1, b = 0 },
        position = {
            point         = "BOTTOM",
            relativePoint = "CENTER",
            x = 0, y = -180,
        },
    },
}

-- =====================================
-- Merge helper (fills missing keys only)
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

function TomoCooldown_InitDB()
    if not TomoCooldownDB then TomoCooldownDB = {} end
    MergeTables(TomoCooldownDB, TomoCooldown_Defaults)
end

function TomoCooldown_ResetDB()
    TomoCooldownDB = CopyTable(TomoCooldown_Defaults)
    print("|cff06b6d4TomoCooldown|r : Paramètres réinitialisés.")
end
