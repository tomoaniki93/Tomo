-- =====================================
-- Database.lua — Defaults & Init
-- TomoFrames v1.0.0
-- =====================================

local ADDON_TEXTURE = "Interface\\AddOns\\TomoFrames\\Assets\\Textures\\tomoaniki"
local ADDON_FONT    = "Interface\\AddOns\\TomoFrames\\Assets\\Fonts\\Poppins-Medium.ttf"

TomoFrames_Defaults = {
    enabled           = true,
    hideBlizzardFrames = true,
    texture           = ADDON_TEXTURE,
    font              = ADDON_FONT,
    fontFamily        = ADDON_FONT,
    fontSize          = 12,
    fontOutline       = "OUTLINE",
    borderSize        = 1,
    borderColor       = { r = 0, g = 0, b = 0, a = 1 },
    castbarColor      = { r = 0.80, g = 0.10, b = 0.10 },
    castbarNIColor    = { r = 0.50, g = 0.50, b = 0.50 },
    castbarInterruptColor = { r = 0.10, g = 0.80, b = 0.10 },

    -- =====================
    -- PLAYER
    -- =====================
    player = {
        enabled = true,
        width = 260, height = 52,
        healthHeight = 38, powerHeight = 8,
        useClassColor = true, useFactionColor = false,
        showName = true, showLevel = false,
        showHealthText = true, healthTextFormat = "current_percent",
        showPowerText = false, showAbsorb = true,
        showThreat = false, showLeaderIcon = true,
        leaderIconOffset = { x = -2, y = 0 },
        castbar = {
            enabled = true, width = 260, height = 20,
            showIcon = true, showTimer = true, showLatency = true,
            color = { r = 1.0, g = 0.7, b = 0.0 },
            position = { point = "BOTTOM", relativePoint = "CENTER", x = -280, y = -220 },
        },
        auras = {
            enabled = true, type = "HARMFUL",
            maxAuras = 8, size = 30, spacing = 3,
            growDirection = "LEFT", showDuration = true, showOnlyMine = false,
            position = { point = "BOTTOMRIGHT", relativePoint = "TOPRIGHT", x = 0, y = 6 },
        },
        elementOffsets = {
            name = { x = 6, y = 0 }, level = { x = -6, y = 0 },
            healthText = { x = 0, y = 0 }, power = { x = 0, y = 0 }, auras = { x = 0, y = 0 },
        },
        position = { point = "BOTTOM", relativePoint = "CENTER", x = -280, y = -190 },
    },

    -- =====================
    -- TARGET
    -- =====================
    target = {
        enabled = true,
        width = 260, height = 52,
        healthHeight = 38, powerHeight = 8,
        useClassColor = true, useFactionColor = true, useNameplateColors = true,
        showName = true, showLevel = true,
        nameTruncate = true, nameTruncateLength = 20,
        showHealthText = true, healthTextFormat = "current_percent",
        showPowerText = false, showAbsorb = false,
        showThreat = true, showRaidIcon = true, showQuestIcon = true,
        showLeaderIcon = true, leaderIconOffset = { x = -2, y = 0 },
        castbar = {
            enabled = true, width = 260, height = 20,
            showIcon = true, showTimer = true,
            color = { r = 1.0, g = 0.7, b = 0.0 },
            position = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -6 },
        },
        auras = {
            enabled = true, type = "HARMFUL",
            maxAuras = 8, size = 30, spacing = 3,
            growDirection = "RIGHT", showDuration = true, showOnlyMine = false,
            position = { point = "BOTTOMLEFT", relativePoint = "TOPLEFT", x = 0, y = 6 },
        },
        enemyBuffs = {
            enabled = true, maxAuras = 4, size = 24, spacing = 2,
            growDirection = "UP", showDuration = true,
            position = { point = "BOTTOMRIGHT", relativePoint = "TOPRIGHT", x = 0, y = 6 },
        },
        elementOffsets = {
            name = { x = 6, y = 0 }, level = { x = -6, y = 0 },
            healthText = { x = 0, y = 0 }, power = { x = 0, y = 0 },
            castbar = { x = 0, y = 0 }, auras = { x = 0, y = 0 },
        },
        position = { point = "BOTTOM", relativePoint = "CENTER", x = 280, y = -190 },
    },

    -- =====================
    -- TARGET OF TARGET
    -- =====================
    targettarget = {
        enabled = true,
        width = 130, height = 32,
        healthHeight = 26, powerHeight = 0,
        useClassColor = true, useFactionColor = true,
        showName = true, showLevel = false,
        nameTruncate = true, nameTruncateLength = 12,
        showHealthText = false, healthTextFormat = "percent",
        showPowerText = false, showAbsorb = false, showThreat = false,
        position = { point = "TOPLEFT", relativePoint = "TOPRIGHT", x = 8, y = 0 },
        anchorTo = "target",
    },

    -- =====================
    -- PET
    -- =====================
    pet = {
        enabled = true,
        width = 130, height = 32,
        healthHeight = 26, powerHeight = 0,
        useClassColor = false, useFactionColor = false,
        showName = true, showLevel = false,
        showHealthText = false, healthTextFormat = "percent",
        showPowerText = false, showAbsorb = false, showThreat = false,
        position = { point = "TOPRIGHT", relativePoint = "TOPLEFT", x = -8, y = 0 },
        anchorTo = "player",
    },

    -- =====================
    -- FOCUS
    -- =====================
    focus = {
        enabled = true,
        width = 200, height = 44,
        healthHeight = 32, powerHeight = 6,
        useClassColor = true, useFactionColor = true, useNameplateColors = true,
        showName = true, showLevel = true,
        showHealthText = true, healthTextFormat = "percent",
        showPowerText = false, showAbsorb = false, showThreat = false,
        castbar = {
            enabled = true, width = 200, height = 16,
            showIcon = true, showTimer = true,
            color = { r = 1.0, g = 0.7, b = 0.0 },
            position = { point = "TOP", relativePoint = "BOTTOM", x = 0, y = -4 },
        },
        auras = {
            enabled = true, type = "HARMFUL",
            maxAuras = 6, size = 26, spacing = 3,
            growDirection = "RIGHT", showDuration = true, showOnlyMine = true,
            position = { point = "BOTTOMLEFT", relativePoint = "TOPLEFT", x = 0, y = 6 },
        },
        position = { point = "TOPLEFT", relativePoint = "TOPLEFT", x = 20, y = -200 },
    },

    -- =====================
    -- BOSS FRAMES
    -- =====================
    bossFrames = {
        enabled = true,
        width = 200, height = 28, spacing = 4,
        position = { point = "RIGHT", relativePoint = "RIGHT", x = -80, y = 200 },
    },
}

-- =====================================
-- Merge helper (only fills missing keys)
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

function TomoFrames_InitDB()
    if not TomoFramesDB then TomoFramesDB = {} end
    MergeTables(TomoFramesDB, TomoFrames_Defaults)
end

function TomoFrames_ResetDB()
    TomoFramesDB = CopyTable(TomoFrames_Defaults)
    print("|cfff59e0bTomoFrames|r : Paramètres réinitialisés.")
    if TomoFrames_UF and TomoFrames_UF.RefreshAll then
        TomoFrames_UF.RefreshAll()
    end
    if TomoFrames_BF and TomoFrames_BF.RefreshAll then
        TomoFrames_BF.RefreshAll()
    end
end
