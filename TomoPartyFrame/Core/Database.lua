-- TomoPartyFrame Database
-- Default settings and SavedVariables initialization

local ADDON, ns = ...

local CreateFrame = CreateFrame
local C_Timer = C_Timer

-- Default settings for party frames
ns.defaults = {
    -- Global
    enabled = true,
    hideBlizzardFrames = true,
    hideWhenSolo = true,

    -- Frame settings
    frameWidth = 120,
    frameHeight = 50,
    frameSpacing = 2,
    growDirection = "DOWN",
    position = { point = "LEFT", x = 100, y = 0 },

    -- Layout
    sortMode = "GROUP",
    showPlayer = true,
    maxColumns = 5,
    columnSpacing = 4,

    -- Health bar
    healthColorMode = "class",
    healthCustomColor = { r = 0, g = 0.8, b = 0 },
    healthTexture = "Interface/TargetingFrame/UI-StatusBar",
    healthBarStyle = "standard",
    healthBackgroundColor = { r = 0.2, g = 0.2, b = 0.2, a = 0.8 },
    smoothHealthBars = true,

    -- Power bar
    showPowerBar = true,
    powerBarHeight = 8,
    powerBarSpacing = 1,
    powerTexture = "Interface/TargetingFrame/UI-StatusBar",
    powerBackgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.8 },

    -- Name text
    showName = true,
    namePosition = "INSIDE",
    nameAlignment = "CENTER",
    nameOffsetX = 0,
    nameOffsetY = 0,
    useClassColorName = true,
    nameColor = { r = 1, g = 1, b = 1 },
    nameFont = "Fonts\\FRIZQT__.TTF",
    nameSize = 11,
    showNameShadow = true,

    -- Background and border
    backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 },
    borderColor = { r = 0.3, g = 0.3, b = 0.3, a = 1 },
    showBorder = true,

    -- Range
    enableRangeFade = true,
    rangeFadeAlpha = 0.4,

    -- Role icons
    showRoleIcon = true,
    roleIconSize = 14,
    roleIconOffsetX = 0,
    roleIconOffsetY = 0,

    -- Raid target markers
    showRaidMarker = true,
    raidMarkerSize = 18,
    raidMarkerAnchor = "CENTER",
    raidMarkerOffsetX = 0,
    raidMarkerOffsetY = 0,

    -- Leader icon
    showLeaderIcon = true,
    leaderIconSize = 14,
    leaderIconOffsetX = 0,
    leaderIconOffsetY = 0,

    -- Resurrect indicator
    showResurrectIndicator = true,
    resurrectIconSize = 22,
    resurrectIconAnchor = "CENTER",
    resurrectIconOffsetX = 0,
    resurrectIconOffsetY = 0,

    -- Ready check indicator
    showReadyCheckIndicator = true,
    readyCheckIconSize = 22,
    readyCheckIconAnchor = "CENTER",
    readyCheckIconOffsetX = 0,
    readyCheckIconOffsetY = 0,

    -- Auras
    showBuffs = false,
    showDebuffs = true,
    buffCount = 4,
    debuffCount = 4,
    buffSize = 16,
    debuffSize = 18,
    buffPosition = "TOPRIGHT",
    debuffPosition = "BOTTOMRIGHT",

    -- Aura cooldown display
    auraSwipeAlpha = 0.5,
    auraHideCooldownAbove = 60,
    auraShowSwipe = true,

    -- Expiring
    showExpiringIndicator = true,
    expiringThreshold = 5,
    expiringBorderColor = { r = 1, g = 0.3, b = 0.3, a = 0.8 },

    -- Dispel overlay
    showDispelOverlay = true,
    dispelDisplayMode = "icon",
    dispelIconSize = 20,
    dispelBorderAlpha = 0.8,
    dispelBorderThickness = 12,
    dispelAnimateBorder = true,
    dispelMagicColor = { r = 0.2, g = 0.6, b = 1 },
    dispelCurseColor = { r = 0.6, g = 0, b = 1 },
    dispelDiseaseColor = { r = 0.6, g = 0.4, b = 0 },
    dispelPoisonColor = { r = 0, g = 0.6, b = 0.1 },

    -- Absorbs & Prediction
    showAbsorbs = true,
    absorbColor = { r = 0.8, g = 0.8, b = 0.2, a = 0.6 },
    showHealAbsorbs = true,
    healAbsorbColor = { r = 0.4, g = 0.1, b = 0.1, a = 0.7 },
    showHealPrediction = true,
    healPredictionColor = { r = 0, g = 0.5, b = 0, a = 0.5 },

    -- Private Auras
    showPrivateAuras = true,
    privateAuraCount = 2,
    privateAuraSize = 26,
    privateAuraSpacing = 2,
    privateAuraGrowth = "RIGHT",
    privateAuraAnchor = "CENTER",
    privateAuraOffsetX = 0,
    privateAuraOffsetY = 0,
    privateAuraShowCountdown = true,

    -- Selection Highlight
    showSelectionHighlight = true,
    selectionHighlightColor = { r = 1, g = 1, b = 1, a = 1 },
    selectionHighlightThickness = 2,
    selectionHighlightInset = 0,

    -- Hover Highlight
    showHoverHighlight = true,
    hoverHighlightColor = { r = 1, g = 1, b = 1, a = 0.6 },
    hoverHighlightThickness = 2,

    -- Summon Indicator
    showSummons = true,
    summonIconSize = 22,
    summonIconAnchor = "CENTER",
    summonIconOffsetX = 0,
    summonIconOffsetY = 0,

    -- Defensive Icon
    showDefensiveIcon = true,
    defensiveIconSize = 30,
    defensiveIconZoom = 0.08,
    defensiveIconAnchor = "CENTER",
    defensiveIconOffsetX = 0,
    defensiveIconOffsetY = 0,
    defensiveIconShowBorder = true,
    defensiveIconBorderSize = 2,
    defensiveIconBorderColor = { r = 0, g = 0.8, b = 0, a = 1 },
    defensiveIconShowDuration = true,
    defensiveIconShowSwipe = true,

    -- Test mode
    testMode = false,
    testFrameCount = 5,
    testAnimateHealth = false,
    testAnimateDispel = true,
    testShowHealth = true,
    testShowPower = true,
    testShowName = true,
    testShowRoleIcon = true,
    testShowOOR = false,
    testShowDead = false,
    testShowOffline = false,
    testShowAuras = false,
    testShowDispel = false,
    testShowDefensive = false,
    testShowSelection = false,
    testShowHover = true,
    testShowAbsorbs = false,
    testShowHealAbsorbs = false,
    testShowHealPred = false,
    testShowLeader = true,
    testShowRaidMarker = true,
    testShowReadyCheck = false,
    testShowResurrect = false,
    testShowSummon = false,
}

-- Initialize SavedVariables
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "TomoPartyFrame" then return end

    if not TomoPartyFramDB then
        TomoPartyFramDB = ns.DeepCopy(ns.defaults)
    end

    -- Ensure all default keys exist (for addon updates)
    ns.DeepMerge(TomoPartyFramDB, ns.defaults)

    -- Set ns.db to the saved data
    ns.db = TomoPartyFramDB

    -- Data repair
    C_Timer.After(0.1, function()
        ns:RepairData()
    end)

    self:UnregisterEvent("ADDON_LOADED")
end)

-- Data repair
function ns:RepairData()
    if not self.db then return end

    local repaired = false

    local function RepairColorTable(color, defaultColor)
        if not color or type(color) ~= "table" then
            return ns.DeepCopy(defaultColor), true
        end
        local wasRepaired = false
        if color.r == nil then color.r = defaultColor.r or 1; wasRepaired = true end
        if color.g == nil then color.g = defaultColor.g or 1; wasRepaired = true end
        if color.b == nil then color.b = defaultColor.b or 1; wasRepaired = true end
        if defaultColor.a and color.a == nil then color.a = defaultColor.a; wasRepaired = true end
        return color, wasRepaired
    end

    local colorKeys = {
        "healthCustomColor", "healthBackgroundColor",
        "powerBackgroundColor", "nameColor",
        "backgroundColor", "borderColor",
        "dispelMagicColor", "dispelCurseColor", "dispelDiseaseColor", "dispelPoisonColor",
        "absorbColor", "healPredictionColor", "healAbsorbColor",
    }

    for _, key in ipairs(colorKeys) do
        local color, wasRepaired = RepairColorTable(self.db[key], ns.defaults[key])
        if wasRepaired then
            self.db[key] = color
            repaired = true
        end
    end

    if not self.db.position or type(self.db.position) ~= "table" then
        self.db.position = ns.DeepCopy(ns.defaults.position)
        repaired = true
    end

    if repaired then
        print("TomoPartyFrame: Repaired corrupted data")
    end
end

-- Helpers
function ns:GetSetting(key)
    if self.db and self.db[key] ~= nil then
        return self.db[key]
    end
    return self.defaults[key]
end

function ns:SetSetting(key, value)
    if self.db then
        self.db[key] = value
        if self.RefreshAll then
            self:RefreshAll()
        end
    end
end
