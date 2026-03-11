-- TomoPartyFrame Party Frame
-- Creates and updates unit frames for party members
-- Includes: health, power, name, role icon, leader icon, raid markers,
-- auras, dispel overlay, absorbs, heal prediction, defensive icon,
-- selection highlight, hover highlight, resurrect, ready check,
-- private auras, summon indicator

local ADDON, ns = ...

-- Cache WoW API
local pairs, ipairs, pcall = pairs, ipairs, pcall
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local UnitName = UnitName
local UnitClass = UnitClass
local UnitIsConnected = UnitIsConnected
local UnitInRange = UnitInRange
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsUnit = UnitIsUnit
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitGetIncomingHeals = UnitGetIncomingHeals
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitGetTotalHealAbsorbs = UnitGetTotalHealAbsorbs
local UnitGetDetailedHealPrediction = UnitGetDetailedHealPrediction
local GetRaidTargetIndex = GetRaidTargetIndex
local SetRaidTargetIconTexture = SetRaidTargetIconTexture
local InCombatLockdown = InCombatLockdown
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local GetReadyCheckStatus = GetReadyCheckStatus
local CreateUnitHealPredictionCalculator = CreateUnitHealPredictionCalculator
local C_UnitAuras = C_UnitAuras
local C_IncomingSummon = C_IncomingSummon

-- Aura position anchors
local positionAnchors = {
    TOPLEFT = { point = "TOPLEFT", relPoint = "TOPLEFT", xDir = 1, yDir = -1 },
    TOPRIGHT = { point = "TOPRIGHT", relPoint = "TOPRIGHT", xDir = -1, yDir = -1 },
    BOTTOMLEFT = { point = "BOTTOMLEFT", relPoint = "BOTTOMLEFT", xDir = 1, yDir = 1 },
    BOTTOMRIGHT = { point = "BOTTOMRIGHT", relPoint = "BOTTOMRIGHT", xDir = -1, yDir = 1 },
}

-- Summon textures
local SUMMON_TEXTURES = {}
if Enum and Enum.SummonStatus then
    SUMMON_TEXTURES[Enum.SummonStatus.Pending] = "Interface\\RaidFrame\\Raid-Icon-SummonPending"
    SUMMON_TEXTURES[Enum.SummonStatus.Accepted] = "Interface\\RaidFrame\\Raid-Icon-SummonAccepted"
    SUMMON_TEXTURES[Enum.SummonStatus.Declined] = "Interface\\RaidFrame\\Raid-Icon-SummonDeclined"
end

-- ============================================================================
-- PRIVATE AURA SYSTEM
-- ============================================================================
local privateAuraAnchors = {}
local privateAuraPool = {}
local PRIVATE_POOL_SIZE = 20

if C_UnitAuras and C_UnitAuras.AddPrivateAuraAnchor then
    for i = 1, PRIVATE_POOL_SIZE do
        local container = CreateFrame("Frame", "TPFBossDebuff" .. i, UIParent)
        container:SetSize(30, 30)
        container:Hide()
        container.poolIndex = i
        container.inUse = false
        privateAuraPool[i] = container
    end
end

local function AcquirePrivateContainer()
    for _, c in ipairs(privateAuraPool) do
        if not c.inUse then c.inUse = true; return c end
    end
    return nil
end

local function ReleasePrivateContainer(c)
    if not c or not c.poolIndex then return end
    if InCombatLockdown() then return end
    c.inUse = false
    c:Hide()
    c:ClearAllPoints()
    c:SetParent(UIParent)
end

function ns:SetupPrivateAuraAnchors(frame)
    if not frame or not frame.unit then return end
    if not C_UnitAuras or not C_UnitAuras.AddPrivateAuraAnchor then return end
    if InCombatLockdown() then return end

    local cfg = ns.db
    if not cfg or not cfg.showPrivateAuras then return end

    ns:ClearPrivateAuraAnchors(frame)

    local unit = frame.unit
    local maxIcons = cfg.privateAuraCount or 2
    local iconSize = cfg.privateAuraSize or 24
    local spacing = cfg.privateAuraSpacing or 2
    local growth = cfg.privateAuraGrowth or "RIGHT"
    local anchor = cfg.privateAuraAnchor or "CENTER"
    local offX = cfg.privateAuraOffsetX or 0
    local offY = cfg.privateAuraOffsetY or 0
    local showCountdown = cfg.privateAuraShowCountdown ~= false

    local pointOnCurrent, pointOnPrev, xMult, yMult
    if growth == "RIGHT" then pointOnCurrent, pointOnPrev, xMult, yMult = "LEFT", "RIGHT", 1, 0
    elseif growth == "LEFT" then pointOnCurrent, pointOnPrev, xMult, yMult = "RIGHT", "LEFT", -1, 0
    elseif growth == "DOWN" then pointOnCurrent, pointOnPrev, xMult, yMult = "TOP", "BOTTOM", 0, -1
    else pointOnCurrent, pointOnPrev, xMult, yMult = "BOTTOM", "TOP", 0, 1
    end

    frame.privateAuraContainers = frame.privateAuraContainers or {}
    privateAuraAnchors[frame] = {}

    for i = 1, maxIcons do
        local container = AcquirePrivateContainer()
        if not container then break end

        frame.privateAuraContainers[i] = container
        container:SetParent(frame)
        container:ClearAllPoints()
        container:SetFrameLevel(frame:GetFrameLevel() + 20)
        container:SetSize(iconSize, iconSize)

        if i == 1 then
            container:SetPoint(anchor, frame, anchor, offX, offY)
        else
            local prev = frame.privateAuraContainers[i - 1]
            container:SetPoint(pointOnCurrent, prev, pointOnPrev, spacing * xMult, spacing * yMult)
        end
        container:Show()

        local success, anchorID = pcall(function()
            return C_UnitAuras.AddPrivateAuraAnchor({
                unitToken = unit,
                auraIndex = i,
                parent = container,
                showCountdownFrame = showCountdown,
                showCountdownNumbers = showCountdown,
                iconInfo = {
                    iconWidth = iconSize,
                    iconHeight = iconSize,
                    iconAnchor = {
                        point = "CENTER",
                        relativeTo = container,
                        relativePoint = "CENTER",
                        offsetX = 0,
                        offsetY = 0,
                    },
                },
            })
        end)

        if success and anchorID then
            privateAuraAnchors[frame][#privateAuraAnchors[frame] + 1] = anchorID
        else
            ReleasePrivateContainer(container)
            frame.privateAuraContainers[i] = nil
        end
    end
end

function ns:ClearPrivateAuraAnchors(frame)
    if not frame then return end
    if InCombatLockdown() then return end

    local anchors = privateAuraAnchors[frame]
    if anchors then
        for _, anchorID in ipairs(anchors) do
            pcall(function() C_UnitAuras.RemovePrivateAuraAnchor(anchorID) end)
        end
        privateAuraAnchors[frame] = nil
    end

    if frame.privateAuraContainers then
        for _, c in ipairs(frame.privateAuraContainers) do
            ReleasePrivateContainer(c)
        end
        frame.privateAuraContainers = {}
    end
end

-- ============================================================================
-- AURA ICON CREATION
-- ============================================================================

local function CreateAuraIcon(parent, index, auraType)
    local icon = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    icon:SetSize(16, 16)
    icon:SetFrameLevel(parent:GetFrameLevel() + 20)

    icon.texture = icon:CreateTexture(nil, "ARTWORK")
    icon.texture:SetAllPoints()
    icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    icon.border = icon:CreateTexture(nil, "OVERLAY")
    icon.border:SetPoint("TOPLEFT", -1, 1)
    icon.border:SetPoint("BOTTOMRIGHT", 1, -1)
    icon.border:SetColorTexture(0, 0, 0, 0.8)
    icon.border:Hide()

    icon.expiringBorder = icon:CreateTexture(nil, "OVERLAY", nil, 1)
    icon.expiringBorder:SetPoint("TOPLEFT", -2, 2)
    icon.expiringBorder:SetPoint("BOTTOMRIGHT", 2, -2)
    icon.expiringBorder:SetColorTexture(1, 0.3, 0.3, 1)
    icon.expiringBorder:Hide()

    icon.cooldown = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
    icon.cooldown:SetAllPoints()
    icon.cooldown:SetDrawEdge(false)
    icon.cooldown:SetDrawBling(false)
    icon.cooldown:SetDrawSwipe(true)
    icon.cooldown:SetHideCountdownNumbers(false)
    icon.cooldown:SetReverse(true)

    local swipeAlpha = ns.db and ns.db.auraSwipeAlpha or 0.5
    icon.cooldown:SetSwipeColor(0, 0, 0, swipeAlpha)

    icon.count = icon:CreateFontString(nil, "OVERLAY")
    icon.count:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    icon.count:SetPoint("BOTTOMRIGHT", 1, -1)
    icon.count:SetJustifyH("RIGHT")

    icon.auraType = auraType
    icon.index = index
    icon:Hide()
    return icon
end

local function CreateAuraIcons(frame)
    if not frame or not ns.db then return end
    local cfg = ns.db

    frame.buffIcons = frame.buffIcons or {}
    for i = 1, (cfg.buffCount or 4) do
        if not frame.buffIcons[i] then
            frame.buffIcons[i] = CreateAuraIcon(frame, i, "BUFF")
        end
    end

    frame.debuffIcons = frame.debuffIcons or {}
    for i = 1, (cfg.debuffCount or 4) do
        if not frame.debuffIcons[i] then
            frame.debuffIcons[i] = CreateAuraIcon(frame, i, "DEBUFF")
        end
    end
end

-- ============================================================================
-- AURA LAYOUT & UPDATE
-- ============================================================================

local function LayoutAuraIcons(frame, icons, position, size)
    if not frame or not icons then return end
    local anchor = positionAnchors[position] or positionAnchors.TOPRIGHT
    local spacing = 1
    local iconsPerRow = 4

    for i, icon in ipairs(icons) do
        icon:SetSize(size, size)
        icon:ClearAllPoints()
        local row = floor((i - 1) / iconsPerRow)
        local col = (i - 1) % iconsPerRow
        local xOff = col * (size + spacing) * anchor.xDir + (2 * anchor.xDir)
        local yOff = row * (size + spacing) * anchor.yDir + (2 * anchor.yDir)
        icon:SetPoint(anchor.point, frame, anchor.relPoint, xOff, yOff)
    end
end

local function UpdateAuraType(frame, unit, filter, icons, maxAuras, size, position)
    if not UnitExists(unit) then
        for _, icon in ipairs(icons) do icon:Hide() end
        return
    end

    LayoutAuraIcons(frame, icons, position, size)

    local displayedCount = 0
    local slot = 1
    local cfg = ns.db

    while displayedCount < maxAuras and slot <= 40 do
        local auraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex(unit, slot, filter)
        if not auraData then break end

        local icon = icons[displayedCount + 1]
        if icon then
            local auraIcon, duration, expirationTime, applications, dispelType
            local success = pcall(function()
                auraIcon = auraData.icon
                duration = auraData.duration or 0
                expirationTime = auraData.expirationTime or 0
                applications = auraData.applications or 0
                dispelType = auraData.dispelName
            end)

            if success and auraIcon then
                icon.texture:SetTexture(auraIcon)

                local swipeAlpha = cfg.auraSwipeAlpha or 0.5
                local showSwipe = cfg.auraShowSwipe ~= false
                local hideCooldownAbove = cfg.auraHideCooldownAbove or 60

                icon.cooldown:SetSwipeColor(0, 0, 0, swipeAlpha)
                icon.cooldown:SetDrawSwipe(showSwipe)

                local auraInstanceID = auraData.auraInstanceID

                if icon.cooldown.SetCooldownFromExpirationTime then
                    pcall(function()
                        icon.cooldown:SetCooldownFromExpirationTime(expirationTime, duration)
                    end)
                end

                local hideCountdown = false
                pcall(function()
                    if hideCooldownAbove > 0 and duration > hideCooldownAbove then
                        hideCountdown = true
                    end
                end)
                icon.cooldown:SetHideCountdownNumbers(hideCountdown)

                if auraInstanceID and C_UnitAuras.DoesAuraHaveExpirationTime then
                    local hasExpiration = C_UnitAuras.DoesAuraHaveExpirationTime(unit, auraInstanceID)
                    if icon.cooldown.SetShownFromBoolean then
                        icon.cooldown:SetShownFromBoolean(hasExpiration, true, false)
                    else
                        icon.cooldown:Show()
                    end
                else
                    icon.cooldown:Show()
                end

                -- Stack count
                icon.count:SetText("")
                if auraInstanceID and C_UnitAuras.GetAuraApplicationDisplayCount then
                    pcall(function()
                        local stackText = C_UnitAuras.GetAuraApplicationDisplayCount(unit, auraInstanceID, 2, 99)
                        icon.count:SetText(stackText)
                    end)
                else
                    pcall(function()
                        if applications and applications > 1 then icon.count:SetText(applications) end
                    end)
                end
                icon.count:Show()

                -- Border color
                local borderSet = false
                if filter == "HARMFUL" then
                    pcall(function()
                        if dispelType then
                            local borderColor = ns.dispelTypeColors[dispelType]
                            if borderColor then
                                local custom = cfg["dispel" .. dispelType .. "Color"]
                                if custom then borderColor = custom end
                                icon.border:SetColorTexture(borderColor.r, borderColor.g, borderColor.b, 0.8)
                                borderSet = true
                            end
                        end
                    end)
                end
                if not borderSet then
                    icon.border:SetColorTexture(0, 0, 0, 0.5)
                end
                icon.border:Show()

                -- Expiring indicator
                if cfg.showExpiringIndicator and icon.expiringBorder then
                    local isExpiring = false
                    pcall(function()
                        if expirationTime and expirationTime > 0 then
                            local remaining = expirationTime - GetTime()
                            if remaining > 0 and remaining <= (cfg.expiringThreshold or 5) then
                                isExpiring = true
                            end
                        end
                    end)
                    if isExpiring then
                        local ec = cfg.expiringBorderColor or { r = 1, g = 0.3, b = 0.3, a = 1 }
                        icon.expiringBorder:SetColorTexture(ec.r, ec.g, ec.b, ec.a or 1)
                        icon.expiringBorder:Show()
                    else
                        icon.expiringBorder:Hide()
                    end
                elseif icon.expiringBorder then
                    icon.expiringBorder:Hide()
                end

                icon:Show()
                displayedCount = displayedCount + 1
            end
        end
        slot = slot + 1
    end

    for i = displayedCount + 1, #icons do
        if icons[i] then icons[i]:Hide() end
    end
end

function ns:UpdateAuras(frame, unit)
    if not frame or not unit or not ns.db then return end
    local cfg = ns.db

    if cfg.showBuffs and frame.buffIcons then
        UpdateAuraType(frame, unit, "HELPFUL", frame.buffIcons, cfg.buffCount or 4, cfg.buffSize or 14, cfg.buffPosition or "TOPRIGHT")
    elseif frame.buffIcons then
        for _, icon in ipairs(frame.buffIcons) do icon:Hide() end
    end

    if cfg.showDebuffs and frame.debuffIcons then
        UpdateAuraType(frame, unit, "HARMFUL", frame.debuffIcons, cfg.debuffCount or 4, cfg.debuffSize or 16, cfg.debuffPosition or "BOTTOMRIGHT")
    elseif frame.debuffIcons then
        for _, icon in ipairs(frame.debuffIcons) do icon:Hide() end
    end
end

-- ============================================================================
-- DISPEL OVERLAY UPDATE
-- ============================================================================

-- Texture paths for dispel type icons
local DISPEL_ICON_TEXTURES = {
    Magic   = "Interface\\AddOns\\TomoPartyFrame\\Assets\\Textures\\Dispel_Magic",
    Curse   = "Interface\\AddOns\\TomoPartyFrame\\Assets\\Textures\\Dispel_Curse",
    Disease = "Interface\\AddOns\\TomoPartyFrame\\Assets\\Textures\\Dispel_Disease",
    Poison  = "Interface\\AddOns\\TomoPartyFrame\\Assets\\Textures\\Dispel_Poison",
}

function ns:UpdateDispelOverlay(frame, unit)
    if not frame or not unit then return end
    local cfg = ns.db
    if not cfg or not cfg.showDispelOverlay then
        if frame.dispelOverlay then frame.dispelOverlay:Hide() end
        if frame.dispelIconFrame then frame.dispelIconFrame:Hide() end
        return
    end

    local dispelMode = cfg.dispelDisplayMode or "icon"

    -- Check for dispellable debuffs
    local dispelColor = nil
    local dispelType = nil
    local slot = 1
    while slot <= 40 do
        local auraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex(unit, slot, "HARMFUL")
        if not auraData then break end

        pcall(function()
            if auraData.isPlayerAuraDispellable and auraData.dispelName then
                local dtype = auraData.dispelName
                local c = cfg["dispel" .. dtype .. "Color"] or ns.dispelTypeColors[dtype]
                if c and not dispelColor then
                    dispelColor = c
                    dispelType = dtype
                end
            end
        end)
        slot = slot + 1
    end

    -- Update border overlay
    if frame.dispelOverlay then
        if dispelColor and (dispelMode == "border" or dispelMode == "both") then
            local r, g, b = dispelColor.r, dispelColor.g, dispelColor.b
            local a = cfg.dispelBorderAlpha or 0.8
            local overlay = frame.dispelOverlay

            for _, borderName in ipairs({"borderTop", "borderBottom", "borderLeft", "borderRight"}) do
                local border = overlay[borderName]
                if border then
                    local tex = border:GetStatusBarTexture()
                    tex:SetVertexColor(r, g, b, a)
                    border:Show()
                end
            end

            if overlay.pulseAnimation and cfg.dispelAnimateBorder then
                if not overlay.pulseAnimation:IsPlaying() then
                    overlay.pulseAnimation:Play()
                end
            end

            overlay:Show()
        else
            local overlay = frame.dispelOverlay
            if overlay.pulseAnimation and overlay.pulseAnimation:IsPlaying() then
                overlay.pulseAnimation:Stop()
                overlay:SetAlpha(1)
            end
            overlay:Hide()
        end
    end

    -- Update dispel type icon
    if frame.dispelIconFrame and frame.dispelIconTex then
        if dispelType and (dispelMode == "icon" or dispelMode == "both") then
            local texPath = DISPEL_ICON_TEXTURES[dispelType]
            if texPath then
                frame.dispelIconTex:SetTexture(texPath)
                frame.dispelIconTex:Show()
                frame.dispelIconFrame:Show()
            else
                frame.dispelIconTex:Hide()
                frame.dispelIconFrame:Hide()
            end
        else
            frame.dispelIconTex:Hide()
            frame.dispelIconFrame:Hide()
        end
    end
end

-- ============================================================================
-- DEFENSIVE ICON UPDATE
-- ============================================================================

function ns:UpdateDefensiveIcon(frame, unit)
    if not frame or not frame.defensiveIcon then return end
    local cfg = ns.db
    if not cfg or not cfg.showDefensiveIcon then
        frame.defensiveIcon:Hide()
        return
    end

    -- Search for center defensive buff (Blizzard pattern)
    local defensiveAura = nil
    local slot = 1
    while slot <= 40 do
        local auraData = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex(unit, slot, "HELPFUL")
        if not auraData then break end
        pcall(function()
            if auraData.isBossAura or (auraData.sourceUnit and UnitIsUnit(auraData.sourceUnit, unit)) then
                if not defensiveAura then
                    defensiveAura = auraData
                end
            end
        end)
        slot = slot + 1
    end

    if not defensiveAura then
        frame.defensiveIcon:Hide()
        return
    end

    pcall(function()
        frame.defensiveIcon.texture:SetTexture(defensiveAura.icon)
    end)

    local cooldown = frame.defensiveIcon.cooldown
    if cooldown.SetCooldownFromExpirationTime then
        pcall(function()
            cooldown:SetCooldownFromExpirationTime(defensiveAura.expirationTime, defensiveAura.duration)
        end)
    end

    frame.defensiveIcon:Show()
end

-- ============================================================================
-- SUMMON INDICATOR
-- ============================================================================

function ns:UpdateSummonIndicator(frame, unit)
    if not frame or not frame.summonIcon then return end
    local cfg = ns.db
    if not cfg or not cfg.showSummons then
        if frame.summonFrame then frame.summonFrame:Hide() end
        return
    end

    if not unit or not UnitExists(unit) then
        if frame.summonFrame then frame.summonFrame:Hide() end
        return
    end

    local status = C_IncomingSummon and C_IncomingSummon.IncomingSummonStatus(unit)
    local texture = SUMMON_TEXTURES[status]

    if texture then
        frame.summonIcon:SetTexture(texture)
        frame.summonIcon:Show()
        frame.summonFrame:Show()
    else
        frame.summonIcon:Hide()
        frame.summonFrame:Hide()
    end
end

-- ============================================================================
-- HOVER HIGHLIGHT
-- ============================================================================

local function CreateHoverHighlight(frame)
    if not frame or not ns.db then return end
    local cfg = ns.db
    if not cfg.showHoverHighlight then return end

    local thickness = cfg.hoverHighlightThickness or 2
    local color = cfg.hoverHighlightColor or { r = 1, g = 1, b = 1, a = 0.6 }

    local highlight = CreateFrame("Frame", nil, frame)
    highlight:SetAllPoints()
    highlight:SetFrameLevel(frame:GetFrameLevel() + 7)

    for _, data in ipairs({
        { "topLine", "TOPLEFT", "TOPRIGHT", thickness, nil },
        { "bottomLine", "BOTTOMLEFT", "BOTTOMRIGHT", thickness, nil },
        { "leftLine", "TOPLEFT", "BOTTOMLEFT", nil, thickness },
        { "rightLine", "TOPRIGHT", "BOTTOMRIGHT", nil, thickness },
    }) do
        local line = highlight:CreateTexture(nil, "OVERLAY")
        line:SetPoint(data[2], 0, 0)
        line:SetPoint(data[3], 0, 0)
        if data[4] then line:SetHeight(data[4]) end
        if data[5] then line:SetWidth(data[5]) end
        line:SetColorTexture(color.r, color.g, color.b, color.a or 0.6)
        highlight[data[1]] = line
    end

    highlight:Hide()
    frame.hoverHighlight = highlight
end

-- ============================================================================
-- CREATE UNIT FRAME
-- ============================================================================

function ns:CreateUnitFrame(unit, index)
    if not ns.db or not ns.container then return nil end
    local cfg = ns.db

    local frameName = "TPF_" .. unit
    local frame = CreateFrame("Button", frameName, ns.container, "SecureUnitButtonTemplate, BackdropTemplate")
    frame:SetAttribute("unit", unit)
    frame:SetAttribute("type1", "target")
    frame:SetAttribute("type2", "togglemenu")
    frame:SetSize(cfg.frameWidth, cfg.frameHeight)
    frame:RegisterForClicks("AnyUp")

    -- Background
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = cfg.showBorder and "Interface/Tooltips/UI-Tooltip-Border" or nil,
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    local bgColor = cfg.backgroundColor
    frame:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a or 0.9)
    if cfg.showBorder then
        local bc = cfg.borderColor
        frame:SetBackdropBorderColor(bc.r, bc.g, bc.b, bc.a or 1)
    end

    -- Health bar
    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetPoint("TOPLEFT", 2, -2)
    healthBar:SetPoint("TOPRIGHT", -2, -2)
    local healthHeight = cfg.frameHeight - 4
    if cfg.showPowerBar then
        healthHeight = healthHeight - cfg.powerBarHeight - (cfg.powerBarSpacing or 1)
    end
    healthBar:SetHeight(healthHeight)

    local barStyle = cfg.healthBarStyle or "standard"
    local barTexture = cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar"

    if barStyle == "flat" then
        healthBar:SetStatusBarTexture("Interface/Buttons/WHITE8X8")
    elseif barStyle == "pixel" then
        healthBar:SetStatusBarTexture("Interface/Buttons/WHITE8X8")
    else
        healthBar:SetStatusBarTexture(barTexture)
    end

    if cfg.smoothHealthBars ~= false and healthBar.SetInterpolateToward then
        healthBar:SetInterpolateToward(true)
    end

    local healthBg = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBg:SetAllPoints()
    if barStyle == "flat" or barStyle == "pixel" then
        healthBg:SetTexture("Interface/Buttons/WHITE8X8")
    else
        healthBg:SetTexture(barTexture)
    end
    local hbgC = cfg.healthBackgroundColor
    healthBg:SetVertexColor(hbgC.r, hbgC.g, hbgC.b, hbgC.a or 0.8)

    -- Gradient overlay (created but hidden unless style == "gradient")
    local gradientOverlay = healthBar:CreateTexture(nil, "ARTWORK", nil, 1)
    gradientOverlay:SetAllPoints(healthBar:GetStatusBarTexture())
    gradientOverlay:SetTexture("Interface/Buttons/WHITE8X8")
    gradientOverlay:SetBlendMode("ADD")
    gradientOverlay:Hide()
    healthBar.gradientOverlay = gradientOverlay

    -- Striped overlay (created but hidden unless style == "striped")
    local stripedOverlay = healthBar:CreateTexture(nil, "ARTWORK", nil, 2)
    stripedOverlay:SetAllPoints(healthBar:GetStatusBarTexture())
    stripedOverlay:SetTexture("Interface/Buttons/WHITE8X8")
    stripedOverlay:SetAlpha(0.08)
    stripedOverlay:SetBlendMode("ADD")
    stripedOverlay:Hide()
    healthBar.stripedOverlay = stripedOverlay

    -- Pixel border lines (created but hidden unless style == "pixel")
    local pixelLine = healthBar:CreateTexture(nil, "ARTWORK", nil, 3)
    pixelLine:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPLEFT", 0, 0)
    pixelLine:SetPoint("TOPRIGHT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
    pixelLine:SetHeight(1)
    pixelLine:SetColorTexture(1, 1, 1, 0.15)
    pixelLine:Hide()
    healthBar.pixelLine = pixelLine

    frame.healthBar = healthBar

    -- Heal prediction bar
    if cfg.showHealPrediction then
        local healPredBar = CreateFrame("StatusBar", nil, frame)
        healPredBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        local hpC = cfg.healPredictionColor
        healPredBar:SetStatusBarColor(hpC.r, hpC.g, hpC.b, hpC.a or 0.5)
        healPredBar:SetFrameLevel(healthBar:GetFrameLevel() + 1)
        healPredBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        healPredBar:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        healPredBar:SetWidth(1)
        healPredBar:Hide()
        frame.healPredBar = healPredBar
    end

    -- Absorb bar
    if cfg.showAbsorbs then
        local absColor = cfg.absorbColor
        local absorbBar = CreateFrame("StatusBar", nil, frame)
        absorbBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        absorbBar:SetStatusBarColor(absColor.r, absColor.g, absColor.b, absColor.a or 0.6)
        absorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 2)
        absorbBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        absorbBar:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        absorbBar:SetWidth(1)
        absorbBar:Hide()
        frame.absorbBar = absorbBar

        local attachedVis = absorbBar:CreateTexture(nil, "BACKGROUND")
        attachedVis:SetSize(1, 1)
        attachedVis:SetColorTexture(0, 0, 0, 0)
        absorbBar.visibilityHelper = attachedVis

        local absorbOverflowBar = CreateFrame("StatusBar", nil, healthBar)
        absorbOverflowBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        absorbOverflowBar:SetStatusBarColor(absColor.r, absColor.g, absColor.b, absColor.a or 0.6)
        absorbOverflowBar:SetFrameLevel(healthBar:GetFrameLevel() + 3)
        absorbOverflowBar:SetAllPoints(healthBar)
        absorbOverflowBar:SetReverseFill(true)
        absorbOverflowBar:SetMinMaxValues(0, 1)
        absorbOverflowBar:EnableMouse(false)
        absorbOverflowBar:Hide()
        frame.absorbOverflowBar = absorbOverflowBar

        local overflowVis = absorbOverflowBar:CreateTexture(nil, "BACKGROUND")
        overflowVis:SetSize(1, 1)
        overflowVis:SetColorTexture(0, 0, 0, 0)
        absorbOverflowBar.visibilityHelper = overflowVis
    end

    -- Heal absorb bar
    if cfg.showHealAbsorbs then
        local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
        healAbsorbBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        local haC = cfg.healAbsorbColor
        healAbsorbBar:SetStatusBarColor(haC.r, haC.g, haC.b, haC.a or 0.7)
        healAbsorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 3)
        healAbsorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
        healAbsorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
        healAbsorbBar:SetReverseFill(true)
        healAbsorbBar:SetWidth(1)
        healAbsorbBar:Hide()
        frame.healAbsorbBar = healAbsorbBar
    end

    -- Power bar
    if cfg.showPowerBar then
        local powerBar = CreateFrame("StatusBar", nil, frame)
        powerBar:SetPoint("BOTTOMLEFT", 2, 2)
        powerBar:SetPoint("BOTTOMRIGHT", -2, 2)
        powerBar:SetHeight(cfg.powerBarHeight)
        powerBar:SetStatusBarTexture(cfg.powerTexture or "Interface/TargetingFrame/UI-StatusBar")

        local powerBg = powerBar:CreateTexture(nil, "BACKGROUND")
        powerBg:SetAllPoints()
        powerBg:SetTexture(cfg.powerTexture or "Interface/TargetingFrame/UI-StatusBar")
        local pbgC = cfg.powerBackgroundColor
        powerBg:SetVertexColor(pbgC.r, pbgC.g, pbgC.b, pbgC.a or 0.8)
        frame.powerBar = powerBar
    end

    -- Name text
    if cfg.showName then
        local nameParent = (cfg.namePosition == "INSIDE") and healthBar or frame
        local nameText = nameParent:CreateFontString(nil, "OVERLAY")
        local nameFlags = cfg.showNameShadow and "OUTLINE" or ""
        nameText:SetFont(cfg.nameFont or "Fonts\\FRIZQT__.TTF", cfg.nameSize or 10, nameFlags)
        nameText:SetJustifyH(cfg.nameAlignment or "CENTER")

        local nOX, nOY = cfg.nameOffsetX or 0, cfg.nameOffsetY or 0
        local alignment = cfg.nameAlignment or "CENTER"

        if cfg.namePosition == "INSIDE" then
            if alignment == "LEFT" then
                nameText:SetPoint("LEFT", healthBar, "LEFT", 2 + nOX, nOY)
            elseif alignment == "RIGHT" then
                nameText:SetPoint("RIGHT", healthBar, "RIGHT", -2 + nOX, nOY)
            else
                nameText:SetPoint("CENTER", healthBar, "CENTER", nOX, nOY)
            end
        elseif cfg.namePosition == "ABOVE" then
            nameText:SetPoint("BOTTOM", frame, "TOP", nOX, 2 + nOY)
        else
            nameText:SetPoint("TOP", frame, "BOTTOM", nOX, -2 + nOY)
        end

        frame.nameText = nameText
    end

    -- Role icon
    if cfg.showRoleIcon then
        local rOX, rOY = cfg.roleIconOffsetX or 0, cfg.roleIconOffsetY or 0
        local roleFrame = CreateFrame("Frame", nil, frame)
        roleFrame:SetSize(cfg.roleIconSize or 14, cfg.roleIconSize or 14)
        roleFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + rOX, -2 + rOY)
        roleFrame:SetFrameLevel(frame:GetFrameLevel() + 10)

        local roleIcon = roleFrame:CreateTexture(nil, "ARTWORK")
        roleIcon:SetAllPoints()
        roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")
        roleIcon:Hide()

        frame.roleFrame = roleFrame
        frame.roleIcon = roleIcon
        roleFrame:Hide()
    end

    -- Leader icon
    if cfg.showLeaderIcon then
        local lOX, lOY = cfg.leaderIconOffsetX or 0, cfg.leaderIconOffsetY or 0
        local leaderFrame = CreateFrame("Frame", nil, frame)
        leaderFrame:SetSize(cfg.leaderIconSize or 14, cfg.leaderIconSize or 14)
        leaderFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + lOX, -2 + lOY)
        leaderFrame:SetFrameLevel(frame:GetFrameLevel() + 10)

        local leaderIcon = leaderFrame:CreateTexture(nil, "ARTWORK")
        leaderIcon:SetAllPoints()
        leaderIcon:Hide()
        frame.leaderFrame = leaderFrame
        frame.leaderIcon = leaderIcon
        leaderFrame:Hide()
    end

    -- Raid target marker
    if cfg.showRaidMarker then
        local mOX, mOY = cfg.raidMarkerOffsetX or 0, cfg.raidMarkerOffsetY or 0
        local mAnchor = cfg.raidMarkerAnchor or "CENTER"
        local markerFrame = CreateFrame("Frame", nil, frame)
        markerFrame:SetSize(cfg.raidMarkerSize or 18, cfg.raidMarkerSize or 18)
        markerFrame:SetPoint(mAnchor, frame, mAnchor, mOX, mOY)
        markerFrame:SetFrameLevel(frame:GetFrameLevel() + 15)

        local markerIcon = markerFrame:CreateTexture(nil, "OVERLAY")
        markerIcon:SetAllPoints()
        markerIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        markerIcon:Hide()

        frame.markerFrame = markerFrame
        frame.markerIcon = markerIcon
        markerFrame:Hide()
    end

    -- Resurrect indicator
    if cfg.showResurrectIndicator then
        local resSize = cfg.resurrectIconSize or 22
        local resAnchor = cfg.resurrectIconAnchor or "CENTER"
        local resFrame = CreateFrame("Frame", nil, frame)
        resFrame:SetSize(resSize, resSize)
        resFrame:SetPoint(resAnchor, frame, resAnchor, cfg.resurrectIconOffsetX or 0, cfg.resurrectIconOffsetY or 0)
        resFrame:SetFrameLevel(frame:GetFrameLevel() + 25)

        local resIcon = resFrame:CreateTexture(nil, "OVERLAY")
        resIcon:SetAllPoints()
        resIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        resIcon:Hide()

        frame.resurrectFrame = resFrame
        frame.resurrectIcon = resIcon
        resFrame:Hide()
    end

    -- Ready check indicator
    if cfg.showReadyCheckIndicator then
        local rcSize = cfg.readyCheckIconSize or 22
        local rcAnchor = cfg.readyCheckIconAnchor or "CENTER"
        local rcFrame = CreateFrame("Frame", nil, frame)
        rcFrame:SetSize(rcSize, rcSize)
        rcFrame:SetPoint(rcAnchor, frame, rcAnchor, cfg.readyCheckIconOffsetX or 0, cfg.readyCheckIconOffsetY or 0)
        rcFrame:SetFrameLevel(frame:GetFrameLevel() + 26)

        local rcIcon = rcFrame:CreateTexture(nil, "OVERLAY")
        rcIcon:SetAllPoints()
        rcIcon:Hide()

        frame.readyCheckFrame = rcFrame
        frame.readyCheckIcon = rcIcon
        rcFrame:Hide()
    end

    -- Dispel overlay (StatusBar borders)
    if cfg.showDispelOverlay then
        local dispelMode = cfg.dispelDisplayMode or "icon"

        -- Border overlay (for "border" or "both" modes)
        if dispelMode == "border" or dispelMode == "both" then
            local borderSize = cfg.dispelBorderThickness or 2

            local dispelOverlay = CreateFrame("Frame", nil, frame)
            dispelOverlay:SetAllPoints(frame)
            dispelOverlay:SetFrameLevel(frame:GetFrameLevel() + 5)

            for _, data in ipairs({
                { "borderTop", "TOPLEFT", "TOPRIGHT", nil, nil, borderSize, "height" },
                { "borderBottom", "BOTTOMLEFT", "BOTTOMRIGHT", nil, nil, borderSize, "height" },
                { "borderLeft", "TOPLEFT", "BOTTOMLEFT", nil, nil, borderSize, "width" },
                { "borderRight", "TOPRIGHT", "BOTTOMRIGHT", nil, nil, borderSize, "width" },
            }) do
                local border = CreateFrame("StatusBar", nil, dispelOverlay)
                border:SetFrameLevel(dispelOverlay:GetFrameLevel() + 1)
                border:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
                border:SetMinMaxValues(0, 1)
                border:SetValue(1)
                border:GetStatusBarTexture():SetBlendMode("BLEND")

                if data[1] == "borderTop" then
                    border:SetPoint("TOPLEFT", dispelOverlay, "TOPLEFT", borderSize, 0)
                    border:SetPoint("TOPRIGHT", dispelOverlay, "TOPRIGHT", -borderSize, 0)
                    border:SetHeight(borderSize)
                elseif data[1] == "borderBottom" then
                    border:SetPoint("BOTTOMLEFT", dispelOverlay, "BOTTOMLEFT", borderSize, 0)
                    border:SetPoint("BOTTOMRIGHT", dispelOverlay, "BOTTOMRIGHT", -borderSize, 0)
                    border:SetHeight(borderSize)
                elseif data[1] == "borderLeft" then
                    border:SetPoint("TOPLEFT", dispelOverlay, "TOPLEFT", 0, 0)
                    border:SetPoint("BOTTOMLEFT", dispelOverlay, "BOTTOMLEFT", 0, 0)
                    border:SetWidth(borderSize)
                elseif data[1] == "borderRight" then
                    border:SetPoint("TOPRIGHT", dispelOverlay, "TOPRIGHT", 0, 0)
                    border:SetPoint("BOTTOMRIGHT", dispelOverlay, "BOTTOMRIGHT", 0, 0)
                    border:SetWidth(borderSize)
                end

                dispelOverlay[data[1]] = border
            end

            if cfg.dispelAnimateBorder then
                local animGroup = dispelOverlay:CreateAnimationGroup()
                animGroup:SetLooping("BOUNCE")
                local fade = animGroup:CreateAnimation("Alpha")
                fade:SetFromAlpha(1.0)
                fade:SetToAlpha(0.4)
                fade:SetDuration(0.5)
                fade:SetSmoothing("IN_OUT")
                dispelOverlay.pulseAnimation = animGroup

                dispelOverlay:SetScript("OnShow", function(self)
                    if self.pulseAnimation then self.pulseAnimation:Play() end
                end)
                dispelOverlay:SetScript("OnHide", function(self)
                    if self.pulseAnimation then self.pulseAnimation:Stop() end
                end)
            end

            dispelOverlay:Hide()
            frame.dispelOverlay = dispelOverlay
        end

        -- Dispel type icon (for "icon" or "both" modes)
        if dispelMode == "icon" or dispelMode == "both" then
            local iconSize = cfg.dispelIconSize or 20
            local dispelIconFrame = CreateFrame("Frame", nil, frame)
            dispelIconFrame:SetSize(iconSize, iconSize)
            dispelIconFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -3, -3)
            dispelIconFrame:SetFrameLevel(frame:GetFrameLevel() + 18)

            local dispelIconTex = dispelIconFrame:CreateTexture(nil, "OVERLAY")
            dispelIconTex:SetAllPoints()
            dispelIconTex:Hide()

            -- Pulse animation for the icon
            if cfg.dispelAnimateBorder then
                local animGroup = dispelIconFrame:CreateAnimationGroup()
                animGroup:SetLooping("BOUNCE")
                local fade = animGroup:CreateAnimation("Alpha")
                fade:SetFromAlpha(1.0)
                fade:SetToAlpha(0.5)
                fade:SetDuration(0.6)
                fade:SetSmoothing("IN_OUT")
                dispelIconFrame.pulseAnimation = animGroup

                dispelIconFrame:SetScript("OnShow", function(self)
                    if self.pulseAnimation then self.pulseAnimation:Play() end
                end)
                dispelIconFrame:SetScript("OnHide", function(self)
                    if self.pulseAnimation then self.pulseAnimation:Stop() end
                end)
            end

            dispelIconFrame:Hide()
            frame.dispelIconFrame = dispelIconFrame
            frame.dispelIconTex = dispelIconTex
        end
    end

    -- Defensive icon
    if cfg.showDefensiveIcon then
        local dSize = cfg.defensiveIconSize or 30
        local dAnchor = cfg.defensiveIconAnchor or "CENTER"
        local dBorderSize = cfg.defensiveIconBorderSize or 2
        local dShowBorder = cfg.defensiveIconShowBorder ~= false

        local defensiveIcon = CreateFrame("Frame", nil, frame)
        defensiveIcon:SetSize(dSize, dSize)
        defensiveIcon:SetPoint(dAnchor, frame, dAnchor, cfg.defensiveIconOffsetX or 0, cfg.defensiveIconOffsetY or 0)
        defensiveIcon:SetFrameLevel(frame:GetFrameLevel() + 20)

        local dTexture = defensiveIcon:CreateTexture(nil, "ARTWORK")
        if dShowBorder then
            dTexture:SetPoint("TOPLEFT", dBorderSize, -dBorderSize)
            dTexture:SetPoint("BOTTOMRIGHT", -dBorderSize, dBorderSize)
        else
            dTexture:SetAllPoints()
        end
        local zoom = cfg.defensiveIconZoom or 0.08
        dTexture:SetTexCoord(zoom, 1 - zoom, zoom, 1 - zoom)
        defensiveIcon.texture = dTexture

        if dShowBorder then
            local dbc = cfg.defensiveIconBorderColor or { r = 0, g = 0.8, b = 0, a = 1 }
            for _, side in ipairs({
                { "borderLeft", "TOPLEFT", "BOTTOMLEFT", dBorderSize, nil },
                { "borderRight", "TOPRIGHT", "BOTTOMRIGHT", dBorderSize, nil },
                { "borderTop", "TOPLEFT", "TOPRIGHT", nil, dBorderSize },
                { "borderBottom", "BOTTOMLEFT", "BOTTOMRIGHT", nil, dBorderSize },
            }) do
                local b = defensiveIcon:CreateTexture(nil, "BACKGROUND")
                b:SetPoint(side[2], 0, 0)
                b:SetPoint(side[3], 0, 0)
                if side[4] then b:SetWidth(side[4]) end
                if side[5] then b:SetHeight(side[5]) end
                b:SetColorTexture(dbc.r, dbc.g, dbc.b, dbc.a)
                defensiveIcon[side[1]] = b
            end
        end

        local dCooldown = CreateFrame("Cooldown", nil, defensiveIcon, "CooldownFrameTemplate")
        dCooldown:SetAllPoints(dTexture)
        dCooldown:SetHideCountdownNumbers(not (cfg.defensiveIconShowDuration ~= false))
        dCooldown:SetDrawSwipe(cfg.defensiveIconShowSwipe ~= false)
        dCooldown:SetDrawEdge(false)
        dCooldown:SetDrawBling(false)
        dCooldown:SetReverse(true)
        defensiveIcon.cooldown = dCooldown

        defensiveIcon:Hide()
        frame.defensiveIcon = defensiveIcon
    end

    -- Selection highlight
    if cfg.showSelectionHighlight then
        local sThick = cfg.selectionHighlightThickness or 2
        local sInset = cfg.selectionHighlightInset or 0
        local sColor = cfg.selectionHighlightColor or { r = 1, g = 1, b = 1, a = 1 }

        local sel = CreateFrame("Frame", nil, frame)
        sel:SetPoint("TOPLEFT", sInset, -sInset)
        sel:SetPoint("BOTTOMRIGHT", -sInset, sInset)
        sel:SetFrameLevel(frame:GetFrameLevel() + 6)

        for _, data in ipairs({
            { "topLine", "TOPLEFT", "TOPRIGHT", sThick, nil },
            { "bottomLine", "BOTTOMLEFT", "BOTTOMRIGHT", sThick, nil },
            { "leftLine", "TOPLEFT", "BOTTOMLEFT", nil, sThick },
            { "rightLine", "TOPRIGHT", "BOTTOMRIGHT", nil, sThick },
        }) do
            local line = sel:CreateTexture(nil, "OVERLAY")
            line:SetPoint(data[2], 0, 0)
            line:SetPoint(data[3], 0, 0)
            if data[4] then line:SetHeight(data[4]) end
            if data[5] then line:SetWidth(data[5]) end
            line:SetColorTexture(sColor.r, sColor.g, sColor.b, sColor.a or 1)
            sel[data[1]] = line
        end

        sel:Hide()
        frame.selectionHighlight = sel
    end

    -- Offline overlay
    local offlineOverlay = CreateFrame("Frame", nil, frame)
    offlineOverlay:SetAllPoints(healthBar)
    offlineOverlay:SetFrameLevel(frame:GetFrameLevel() + 8)

    local offlineBg = offlineOverlay:CreateTexture(nil, "OVERLAY")
    offlineBg:SetAllPoints()
    offlineBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

    local offlineText = offlineOverlay:CreateFontString(nil, "OVERLAY")
    offlineText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    offlineText:SetPoint("CENTER")
    offlineText:SetText(ns.L.STATE_OFFLINE)
    offlineText:SetTextColor(0.6, 0.6, 0.6)

    offlineOverlay:Hide()
    frame.offlineOverlay = offlineOverlay

    -- Aura icons
    CreateAuraIcons(frame)

    -- Hover highlight
    if cfg.showHoverHighlight then
        CreateHoverHighlight(frame)
        frame:HookScript("OnEnter", function(self)
            if ns.db and ns.db.showHoverHighlight and self.hoverHighlight then
                self.hoverHighlight:Show()
            end
        end)
        frame:HookScript("OnLeave", function(self)
            if self.hoverHighlight then self.hoverHighlight:Hide() end
        end)
    end

    -- Summon indicator
    if cfg.showSummons then
        local sSize = cfg.summonIconSize or 22
        local sAnchor = cfg.summonIconAnchor or "CENTER"
        local summonFrame = CreateFrame("Frame", nil, frame)
        summonFrame:SetSize(sSize, sSize)
        summonFrame:SetPoint(sAnchor, frame, sAnchor, cfg.summonIconOffsetX or 0, cfg.summonIconOffsetY or 0)
        summonFrame:SetFrameLevel(frame:GetFrameLevel() + 27)

        local summonIcon = summonFrame:CreateTexture(nil, "OVERLAY")
        summonIcon:SetAllPoints()
        summonIcon:Hide()

        frame.summonFrame = summonFrame
        frame.summonIcon = summonIcon
        summonFrame:Hide()
    end

    frame.unit = unit
    frame.index = index

    -- Initial update
    ns:UpdateUnitFrame(frame, unit)

    -- Private aura anchors
    ns:SetupPrivateAuraAnchors(frame)

    return frame
end

-- ============================================================================
-- UPDATE UNIT FRAME
-- ============================================================================

function ns:UpdateUnitFrame(frame, unit)
    if not frame or not ns.db then return end
    local cfg = ns.db

    if not UnitExists(unit) then
        if not InCombatLockdown() then frame:Hide() end
        return
    end
    if not InCombatLockdown() then frame:Show() end

    local isConnected = UnitIsConnected(unit)

    -- Health
    if frame.healthBar then
        local health = UnitHealth(unit)
        local maxHealth = UnitHealthMax(unit)
        frame.healthBar:SetMinMaxValues(0, maxHealth)
        frame.healthBar:SetValue(health)

        local _, class = UnitClass(unit)
        local classColor = ns.classColors[class] or { r = 0.5, g = 0.5, b = 0.5 }

        local barR, barG, barB
        if cfg.healthColorMode == "class" then
            barR, barG, barB = classColor.r, classColor.g, classColor.b
        else
            local c = cfg.healthCustomColor
            barR, barG, barB = c.r, c.g, c.b
        end
        frame.healthBar:SetStatusBarColor(barR, barG, barB)

        -- Apply bar style overlays
        local barStyle = cfg.healthBarStyle or "standard"
        if frame.healthBar.gradientOverlay then
            if barStyle == "gradient" then
                frame.healthBar.gradientOverlay:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0.4), CreateColor(barR * 0.3, barG * 0.3, barB * 0.3, 0))
                frame.healthBar.gradientOverlay:Show()
            else
                frame.healthBar.gradientOverlay:Hide()
            end
        end
        if frame.healthBar.stripedOverlay then
            if barStyle == "striped" then
                frame.healthBar.stripedOverlay:Show()
            else
                frame.healthBar.stripedOverlay:Hide()
            end
        end
        if frame.healthBar.pixelLine then
            if barStyle == "pixel" then
                frame.healthBar.pixelLine:Show()
            else
                frame.healthBar.pixelLine:Hide()
            end
        end

        -- Heal prediction
        if frame.healPredBar and cfg.showHealPrediction then
            local incomingHeals = UnitGetIncomingHeals(unit)
            local hpC = cfg.healPredictionColor
            frame.healPredBar:SetStatusBarColor(hpC.r, hpC.g, hpC.b, hpC.a or 0.5)
            local barWidth = frame.healthBar:GetWidth()
            if barWidth > 0 then frame.healPredBar:SetWidth(barWidth) end
            frame.healPredBar:SetMinMaxValues(0, maxHealth)
            frame.healPredBar:SetValue(incomingHeals or 0)
            frame.healPredBar:Show()
        elseif frame.healPredBar then
            frame.healPredBar:Hide()
        end

        -- Absorb bar
        if frame.absorbBar and cfg.showAbsorbs then
            local totalAbsorb = UnitGetTotalAbsorbs(unit)
            local absC = cfg.absorbColor
            frame.absorbBar:SetStatusBarColor(absC.r, absC.g, absC.b, absC.a or 0.6)
            if frame.absorbOverflowBar then
                frame.absorbOverflowBar:SetStatusBarColor(absC.r, absC.g, absC.b, absC.a or 0.6)
            end

            local barWidth = frame.healthBar:GetWidth()
            if barWidth > 0 then frame.absorbBar:SetWidth(barWidth) end

            local attachedAbsorbs = totalAbsorb
            local isClamped = false

            if CreateUnitHealPredictionCalculator and unit then
                if not frame.absorbCalculator then
                    frame.absorbCalculator = CreateUnitHealPredictionCalculator()
                end
                pcall(function() frame.absorbCalculator:SetDamageAbsorbClampMode(1) end)
                UnitGetDetailedHealPrediction(unit, nil, frame.absorbCalculator)
                local success, r1, r2 = pcall(function() return frame.absorbCalculator:GetDamageAbsorbs() end)
                if success and r1 then
                    attachedAbsorbs = r1
                    isClamped = r2
                end
            end

            frame.absorbBar:SetMinMaxValues(0, maxHealth)
            frame.absorbBar:SetValue(attachedAbsorbs or 0)

            if frame.absorbOverflowBar then
                frame.absorbOverflowBar:SetMinMaxValues(0, maxHealth)
                frame.absorbOverflowBar:SetValue(totalAbsorb or 0)

                local aVH = frame.absorbBar.visibilityHelper
                local oVH = frame.absorbOverflowBar.visibilityHelper
                if aVH and oVH then
                    oVH:Show()
                    oVH:SetAlphaFromBoolean(isClamped, 1, 0)
                    frame.absorbOverflowBar:SetAlpha(oVH:GetAlpha())
                    frame.absorbOverflowBar:Show()
                    aVH:Show()
                    aVH:SetAlphaFromBoolean(isClamped, 0, 1)
                    frame.absorbBar:SetAlpha(aVH:GetAlpha())
                    frame.absorbBar:Show()
                else
                    frame.absorbBar:Show()
                    frame.absorbOverflowBar:Hide()
                end
            else
                frame.absorbBar:Show()
            end
        elseif frame.absorbBar then
            frame.absorbBar:Hide()
            if frame.absorbOverflowBar then frame.absorbOverflowBar:Hide() end
        end

        -- Heal absorb bar
        if frame.healAbsorbBar and cfg.showHealAbsorbs then
            local totalHealAbsorb = UnitGetTotalHealAbsorbs(unit)
            local barWidth = frame.healthBar:GetWidth()
            if barWidth > 0 then frame.healAbsorbBar:SetWidth(barWidth) end
            local haC = cfg.healAbsorbColor
            frame.healAbsorbBar:SetStatusBarColor(haC.r, haC.g, haC.b, haC.a or 0.7)
            frame.healAbsorbBar:SetMinMaxValues(0, maxHealth)
            frame.healAbsorbBar:SetValue(totalHealAbsorb or 0)
            frame.healAbsorbBar:Show()
        elseif frame.healAbsorbBar then
            frame.healAbsorbBar:Hide()
        end
    end

    -- Power
    if frame.powerBar and cfg.showPowerBar then
        local power = UnitPower(unit)
        local maxPower = UnitPowerMax(unit)
        local powerType = UnitPowerType(unit) or 0
        frame.powerBar:SetMinMaxValues(0, maxPower)
        frame.powerBar:SetValue(power)
        local pColor = ns.powerColors[powerType] or { r = 0, g = 0, b = 1 }
        frame.powerBar:SetStatusBarColor(pColor.r, pColor.g, pColor.b)
    end

    -- Name
    if frame.nameText and cfg.showName then
        frame.nameText:SetText(UnitName(unit) or "")
        if cfg.useClassColorName then
            local _, class = UnitClass(unit)
            local cc = ns.classColors[class] or { r = 1, g = 1, b = 1 }
            frame.nameText:SetTextColor(cc.r, cc.g, cc.b)
        else
            local nc = cfg.nameColor
            frame.nameText:SetTextColor(nc.r, nc.g, nc.b)
        end
    end

    -- Role icon
    if frame.roleIcon and cfg.showRoleIcon then
        local role = UnitGroupRolesAssigned(unit)
        local roleTexCoords = {
            TANK = {0, 19/64, 22/64, 41/64},
            HEALER = {20/64, 39/64, 1/64, 20/64},
            DAMAGER = {20/64, 39/64, 22/64, 41/64},
        }
        local coords = roleTexCoords[role]
        if coords then
            frame.roleIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            frame.roleIcon:Show()
            if frame.roleFrame then frame.roleFrame:Show() end
        else
            frame.roleIcon:Hide()
            if frame.roleFrame then frame.roleFrame:Hide() end
        end
    end

    -- Leader icon
    if frame.leaderIcon and cfg.showLeaderIcon then
        if UnitIsGroupLeader(unit) then
            frame.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
            frame.leaderIcon:Show()
            if frame.leaderFrame then frame.leaderFrame:Show() end
        elseif UnitIsGroupAssistant(unit) then
            frame.leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
            frame.leaderIcon:Show()
            if frame.leaderFrame then frame.leaderFrame:Show() end
        else
            frame.leaderIcon:Hide()
            if frame.leaderFrame then frame.leaderFrame:Hide() end
        end
    end

    -- Raid target marker
    if frame.markerIcon and cfg.showRaidMarker then
        local raidTarget = GetRaidTargetIndex(unit)
        if raidTarget then
            frame.markerIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
            SetRaidTargetIconTexture(frame.markerIcon, raidTarget)
            frame.markerIcon:Show()
            if frame.markerFrame then frame.markerFrame:Show() end
        else
            frame.markerIcon:Hide()
            if frame.markerFrame then frame.markerFrame:Hide() end
        end
    end

    -- Resurrect indicator
    if frame.resurrectIcon and cfg.showResurrectIndicator then
        if UnitHasIncomingResurrection(unit) then
            frame.resurrectIcon:Show()
            if frame.resurrectFrame then frame.resurrectFrame:Show() end
        else
            frame.resurrectIcon:Hide()
            if frame.resurrectFrame then frame.resurrectFrame:Hide() end
        end
    end

    -- Ready check
    if frame.readyCheckIcon and cfg.showReadyCheckIndicator then
        local status = GetReadyCheckStatus(unit)
        if status then
            local tex = ({
                ready = "Interface\\RaidFrame\\ReadyCheck-Ready",
                notready = "Interface\\RaidFrame\\ReadyCheck-NotReady",
                waiting = "Interface\\RaidFrame\\ReadyCheck-Waiting",
            })[status]
            if tex then
                frame.readyCheckIcon:SetTexture(tex)
                frame.readyCheckIcon:Show()
                if frame.readyCheckFrame then frame.readyCheckFrame:Show() end
            else
                frame.readyCheckIcon:Hide()
                if frame.readyCheckFrame then frame.readyCheckFrame:Hide() end
            end
        else
            frame.readyCheckIcon:Hide()
            if frame.readyCheckFrame then frame.readyCheckFrame:Hide() end
        end
    end

    -- Range
    if cfg.enableRangeFade then
        local fadeAlpha = cfg.rangeFadeAlpha or 0.4
        if unit == "player" then
            frame:SetAlpha(1.0)
        else
            local inRange = UnitInRange(unit)
            if inRange == nil then
                frame:SetAlpha(1.0)
            else
                frame:SetAlphaFromBoolean(inRange, 1.0, fadeAlpha)
            end
        end
    else
        frame:SetAlpha(1.0)
    end

    -- Dead state
    pcall(function()
        if UnitIsDead(unit) or UnitIsGhost(unit) then
            if frame.healthBar then frame.healthBar:SetStatusBarColor(0.5, 0.5, 0.5) end
        end
    end)

    -- Selection highlight
    if frame.selectionHighlight and cfg.showSelectionHighlight then
        if UnitIsUnit(unit, "target") then
            frame.selectionHighlight:Show()
        else
            frame.selectionHighlight:Hide()
        end
    elseif frame.selectionHighlight then
        frame.selectionHighlight:Hide()
    end

    -- Offline state
    if not isConnected then
        if frame.offlineOverlay then frame.offlineOverlay:Show() end
        if frame.healthBar then frame.healthBar:SetStatusBarColor(0.4, 0.4, 0.4) end
        if frame.powerBar then frame.powerBar:SetStatusBarColor(0.3, 0.3, 0.3) end
    else
        if frame.offlineOverlay then frame.offlineOverlay:Hide() end
    end

    -- Auras
    ns:UpdateAuras(frame, unit)

    -- Dispel overlay
    ns:UpdateDispelOverlay(frame, unit)

    -- Defensive icon
    ns:UpdateDefensiveIcon(frame, unit)

    -- Summon indicator
    ns:UpdateSummonIndicator(frame, unit)
end

-- Register INCOMING_SUMMON_CHANGED
local summonEventFrame = CreateFrame("Frame")
summonEventFrame:RegisterEvent("INCOMING_SUMMON_CHANGED")
summonEventFrame:SetScript("OnEvent", function(_, _, unit)
    if unit and ns.frames[unit] then
        ns:UpdateSummonIndicator(ns.frames[unit], unit)
    end
end)
