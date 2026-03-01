-- =====================================
-- Database.lua — Defaults & Init
-- TomoSkins v1.0.0
-- =====================================

TomoSkins_Defaults = {

    -- =====================
    -- CHARACTER SKIN
    -- =====================
    characterSkin = {
        enabled          = true,
        skinCharacter    = true,
        skinInspect      = true,
        showItemInfo     = true,
        midnightEnchants = true,
        scale            = 1.0,
    },

    -- =====================
    -- ACTION BAR SKIN
    -- =====================
    actionBarSkin = {
        enabled        = false,
        useClassColor  = true,
        shiftReveal    = false,
        barOpacity = {
            ActionButton           = 100,
            MultiBarBottomLeft     = 100,
            MultiBarBottomRight    = 100,
            MultiBarRight          = 100,
            MultiBarLeft           = 100,
            MultiBar5              = 100,
            MultiBar6              = 100,
            MultiBar7              = 100,
            PetActionButton        = 100,
            StanceButton           = 100,
        },
        combatShow = {
            ActionButton           = false,
            MultiBarBottomLeft     = false,
            MultiBarBottomRight    = false,
            MultiBarRight          = false,
            MultiBarLeft           = false,
            MultiBar5              = false,
            MultiBar6              = false,
            MultiBar7              = false,
            PetActionButton        = false,
            StanceButton           = false,
        },
    },

    -- =====================
    -- MINIMAP
    -- =====================
    minimap = {
        enabled     = true,
        scale       = 1.0,
        borderColor = "class",   -- "class" | "black"
        size        = 200,
    },

    -- =====================
    -- INFO PANEL
    -- =====================
    infoPanel = {
        enabled        = true,
        showTime       = true,
        showCoords     = true,
        showDurability = true,
        use24Hour      = true,
        useServerTime  = true,
    },

    -- =====================
    -- OBJECTIVE TRACKER
    -- =====================
    objectiveTracker = {
        enabled           = false,
        bgAlpha           = 0.65,
        showBorder        = true,
        hideWhenEmpty     = false,
        headerFontSize    = 13,
        categoryFontSize  = 11,
        questFontSize     = 12,
        objectiveFontSize = 11,
    },
}

-- =====================================
-- Merge (fills missing keys only)
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

function TomoSkins_InitDB()
    if not TomoSkinsDB then TomoSkinsDB = {} end
    MergeTables(TomoSkinsDB, TomoSkins_Defaults)
end

function TomoSkins_ResetDB()
    TomoSkinsDB = CopyTable(TomoSkins_Defaults)
    print("|cfff43f5eTomoSkins|r : Paramètres réinitialisés.")
    -- Re-apply all active modules
    if TomoSkins_CS  then TomoSkins_CS.ApplySettings()  end
    if TomoSkins_ABS then TomoSkins_ABS.ApplySettings() end
    if TomoSkins_MM  then TomoSkins_MM.ApplySettings()  end
    if TomoSkins_IP  then TomoSkins_IP.Update()         end
    if TomoSkins_OT  then TomoSkins_OT.ApplySettings()  end
end
