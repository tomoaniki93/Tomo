-- TomoPartyFrame Test Panel
-- Provides test mode with fake data and animated health bars

local ADDON, ns = ...

local pairs, ipairs, floor, min, max = pairs, ipairs, math.floor, math.min, math.max
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local GetTime = GetTime

-- ============================================================================
-- TEST DATA
-- ============================================================================

local CLASS_LIST = {
    "WARRIOR", "PALADIN", "HUNTER", "ROGUE", "PRIEST",
    "DEATHKNIGHT", "SHAMAN", "MAGE", "WARLOCK", "MONK",
    "DRUID", "DEMONHUNTER", "EVOKER",
}

local ROLE_LIST = { "TANK", "HEALER", "DAMAGER", "DAMAGER", "DAMAGER" }

local TEST_NAMES = {
    "Arthas", "Jaina", "Thrall", "Sylvanas", "Anduin",
    "Tyrande", "Malfurion", "Velen", "Khadgar", "Yrel",
    "Cairne", "Rexxar", "Gazlowe", "Alleria", "Turalyon",
    "Gul'dan", "Illidan", "Chromie", "Alexstrasza", "Wrathion",
}

local function GenerateTestData(count)
    local data = {}
    for i = 1, count do
        local classIndex = ((i - 1) % #CLASS_LIST) + 1
        local roleIndex = ((i - 1) % #ROLE_LIST) + 1
        local nameIndex = ((i - 1) % #TEST_NAMES) + 1

        local maxHP = 500000 + (i * 50000)
        local healthPct = 0.3 + (math.random() * 0.7)

        data[i] = {
            name = TEST_NAMES[nameIndex],
            class = CLASS_LIST[classIndex],
            role = ROLE_LIST[roleIndex],
            maxHealth = maxHP,
            health = floor(maxHP * healthPct),
            maxPower = 50000,
            power = floor(50000 * (0.4 + math.random() * 0.6)),
            powerType = (roleIndex == 2) and 0 or ((i % 3 == 0) and 3 or 0),
            isConnected = true,
            isDead = false,
            isGhost = false,
            raidTarget = (i <= 8) and i or nil,
            isLeader = (i == 1),
            isAssistant = (i == 2),
        }
    end
    return data
end

-- ============================================================================
-- TEST FRAME CREATION
-- ============================================================================

function ns:CreateTestFrame(index)
    if not ns.db or not ns.container then return nil end
    local cfg = ns.db

    local frameName = "TPF_Test" .. index
    local frame = CreateFrame("Button", frameName, ns.container, "BackdropTemplate")
    frame:SetSize(cfg.frameWidth, cfg.frameHeight)

    -- Generate fresh test data
    if not ns.testData then
        ns.testData = GenerateTestData(cfg.testFrameCount or 5)
    end

    local testInfo = ns.testData[index] or ns.testData[1]

    -- Apply test mode overrides
    local isDead = cfg.testShowDead and (index == 3)
    local isOffline = cfg.testShowOffline and (index == 4)
    local isOOR = cfg.testShowOOR and (index == 5)

    if isDead then testInfo.isDead = true; testInfo.health = 0 end
    if isOffline then testInfo.isConnected = false end

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
    local healthHeight = cfg.frameHeight - 4
    if cfg.showPowerBar and cfg.testShowPower ~= false then
        healthHeight = healthHeight - cfg.powerBarHeight - (cfg.powerBarSpacing or 1)
    end

    local healthBar = CreateFrame("StatusBar", nil, frame)
    healthBar:SetPoint("TOPLEFT", 2, -2)
    healthBar:SetPoint("TOPRIGHT", -2, -2)
    healthBar:SetHeight(healthHeight)
    healthBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
    healthBar:SetMinMaxValues(0, testInfo.maxHealth)
    healthBar:SetValue(testInfo.health)

    local classColor = ns.classColors[testInfo.class] or { r = 0.5, g = 0.5, b = 0.5 }
    if cfg.healthColorMode == "class" then
        healthBar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
    else
        local c = cfg.healthCustomColor
        healthBar:SetStatusBarColor(c.r, c.g, c.b)
    end

    local healthBg = healthBar:CreateTexture(nil, "BACKGROUND")
    healthBg:SetAllPoints()
    healthBg:SetTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
    local hbgC = cfg.healthBackgroundColor
    healthBg:SetVertexColor(hbgC.r, hbgC.g, hbgC.b, hbgC.a or 0.8)
    frame.healthBar = healthBar

    -- Heal prediction bar
    if cfg.showHealPrediction and cfg.testShowHealPred then
        local healPredBar = CreateFrame("StatusBar", nil, frame)
        healPredBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        local hpC = cfg.healPredictionColor
        healPredBar:SetStatusBarColor(hpC.r, hpC.g, hpC.b, hpC.a or 0.5)
        healPredBar:SetFrameLevel(healthBar:GetFrameLevel() + 1)
        healPredBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        healPredBar:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        healPredBar:SetWidth(healthBar:GetWidth())
        healPredBar:SetMinMaxValues(0, testInfo.maxHealth)
        healPredBar:SetValue(testInfo.maxHealth * 0.15)
        healPredBar:Show()
        frame.healPredBar = healPredBar
    end

    -- Absorb bar
    if cfg.showAbsorbs and cfg.testShowAbsorbs then
        local absColor = cfg.absorbColor
        local absorbBar = CreateFrame("StatusBar", nil, frame)
        absorbBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        absorbBar:SetStatusBarColor(absColor.r, absColor.g, absColor.b, absColor.a or 0.6)
        absorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 2)
        absorbBar:SetPoint("TOPLEFT", healthBar:GetStatusBarTexture(), "TOPRIGHT", 0, 0)
        absorbBar:SetPoint("BOTTOMLEFT", healthBar:GetStatusBarTexture(), "BOTTOMRIGHT", 0, 0)
        absorbBar:SetWidth(healthBar:GetWidth())
        absorbBar:SetMinMaxValues(0, testInfo.maxHealth)
        absorbBar:SetValue(testInfo.maxHealth * 0.1)
        absorbBar:Show()
        frame.absorbBar = absorbBar
    end

    -- Heal absorb bar
    if cfg.showHealAbsorbs and cfg.testShowHealAbsorbs then
        local haC = cfg.healAbsorbColor
        local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
        healAbsorbBar:SetStatusBarTexture(cfg.healthTexture or "Interface/TargetingFrame/UI-StatusBar")
        healAbsorbBar:SetStatusBarColor(haC.r, haC.g, haC.b, haC.a or 0.7)
        healAbsorbBar:SetFrameLevel(healthBar:GetFrameLevel() + 3)
        healAbsorbBar:SetPoint("TOPLEFT", healthBar, "TOPLEFT", 0, 0)
        healAbsorbBar:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT", 0, 0)
        healAbsorbBar:SetReverseFill(true)
        healAbsorbBar:SetWidth(healthBar:GetWidth())
        healAbsorbBar:SetMinMaxValues(0, testInfo.maxHealth)
        healAbsorbBar:SetValue(testInfo.maxHealth * 0.05)
        healAbsorbBar:Show()
        frame.healAbsorbBar = healAbsorbBar
    end

    -- Power bar
    if cfg.showPowerBar and cfg.testShowPower ~= false then
        local powerBar = CreateFrame("StatusBar", nil, frame)
        powerBar:SetPoint("BOTTOMLEFT", 2, 2)
        powerBar:SetPoint("BOTTOMRIGHT", -2, 2)
        powerBar:SetHeight(cfg.powerBarHeight)
        powerBar:SetStatusBarTexture(cfg.powerTexture or "Interface/TargetingFrame/UI-StatusBar")
        powerBar:SetMinMaxValues(0, testInfo.maxPower)
        powerBar:SetValue(testInfo.power)

        local pColor = ns.powerColors[testInfo.powerType] or { r = 0, g = 0, b = 1 }
        powerBar:SetStatusBarColor(pColor.r, pColor.g, pColor.b)

        local powerBg = powerBar:CreateTexture(nil, "BACKGROUND")
        powerBg:SetAllPoints()
        powerBg:SetTexture(cfg.powerTexture or "Interface/TargetingFrame/UI-StatusBar")
        local pbgC = cfg.powerBackgroundColor
        powerBg:SetVertexColor(pbgC.r, pbgC.g, pbgC.b, pbgC.a or 0.8)
        frame.powerBar = powerBar
    end

    -- Name
    if cfg.showName and cfg.testShowName ~= false then
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

        nameText:SetText(testInfo.name)
        if cfg.useClassColorName then
            nameText:SetTextColor(classColor.r, classColor.g, classColor.b)
        else
            local nc = cfg.nameColor
            nameText:SetTextColor(nc.r, nc.g, nc.b)
        end
        frame.nameText = nameText
    end

    -- Role icon
    if cfg.showRoleIcon and cfg.testShowRoleIcon ~= false then
        local rOX, rOY = cfg.roleIconOffsetX or 0, cfg.roleIconOffsetY or 0
        local roleFrame = CreateFrame("Frame", nil, frame)
        roleFrame:SetSize(cfg.roleIconSize or 14, cfg.roleIconSize or 14)
        roleFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + rOX, -2 + rOY)
        roleFrame:SetFrameLevel(frame:GetFrameLevel() + 10)

        local roleIcon = roleFrame:CreateTexture(nil, "ARTWORK")
        roleIcon:SetAllPoints()
        roleIcon:SetTexture("Interface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES")

        local roleTexCoords = {
            TANK = {0, 19/64, 22/64, 41/64},
            HEALER = {20/64, 39/64, 1/64, 20/64},
            DAMAGER = {20/64, 39/64, 22/64, 41/64},
        }
        local coords = roleTexCoords[testInfo.role]
        if coords then
            roleIcon:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            roleIcon:Show()
            roleFrame:Show()
        else
            roleIcon:Hide()
            roleFrame:Hide()
        end
        frame.roleFrame = roleFrame
        frame.roleIcon = roleIcon
    end

    -- Leader icon
    if cfg.showLeaderIcon and cfg.testShowLeader then
        if testInfo.isLeader or testInfo.isAssistant then
            local lOX, lOY = cfg.leaderIconOffsetX or 0, cfg.leaderIconOffsetY or 0
            local leaderFrame = CreateFrame("Frame", nil, frame)
            leaderFrame:SetSize(cfg.leaderIconSize or 14, cfg.leaderIconSize or 14)
            leaderFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 2 + lOX, -2 + lOY)
            leaderFrame:SetFrameLevel(frame:GetFrameLevel() + 10)

            if frame.roleFrame then
                leaderFrame:SetPoint("LEFT", frame.roleFrame, "RIGHT", 2, 0)
            end

            local leaderIcon = leaderFrame:CreateTexture(nil, "ARTWORK")
            leaderIcon:SetAllPoints()

            if testInfo.isLeader then
                leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
            else
                leaderIcon:SetTexture("Interface\\GroupFrame\\UI-Group-AssistantIcon")
            end
            leaderIcon:Show()
            leaderFrame:Show()
            frame.leaderFrame = leaderFrame
            frame.leaderIcon = leaderIcon
        end
    end

    -- Raid marker
    if cfg.showRaidMarker and cfg.testShowRaidMarker and testInfo.raidTarget then
        local mOX, mOY = cfg.raidMarkerOffsetX or 0, cfg.raidMarkerOffsetY or 0
        local markerFrame = CreateFrame("Frame", nil, frame)
        markerFrame:SetSize(cfg.raidMarkerSize or 18, cfg.raidMarkerSize or 18)
        markerFrame:SetPoint("CENTER", frame, "CENTER", mOX, mOY)
        markerFrame:SetFrameLevel(frame:GetFrameLevel() + 15)

        local markerIcon = markerFrame:CreateTexture(nil, "OVERLAY")
        markerIcon:SetAllPoints()
        markerIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")
        SetRaidTargetIconTexture(markerIcon, testInfo.raidTarget)
        markerIcon:Show()
        markerFrame:Show()
        frame.markerFrame = markerFrame
        frame.markerIcon = markerIcon
    end

    -- Dispel overlay
    if cfg.showDispelOverlay and cfg.testShowDispel then
        local borderSize = cfg.dispelBorderThickness or 2
        local dispelOverlay = CreateFrame("Frame", nil, frame)
        dispelOverlay:SetAllPoints(frame)
        dispelOverlay:SetFrameLevel(frame:GetFrameLevel() + 5)

        local dispelTypes = { "Magic", "Curse", "Disease", "Poison" }
        local dtype = dispelTypes[((index - 1) % #dispelTypes) + 1]
        local dColor = cfg["dispel" .. dtype .. "Color"] or ns.dispelTypeColors[dtype] or { r = 0.2, g = 0.6, b = 1 }

        for _, data in ipairs({
            { "borderTop", "TOPLEFT", "TOPRIGHT" },
            { "borderBottom", "BOTTOMLEFT", "BOTTOMRIGHT" },
            { "borderLeft", "TOPLEFT", "BOTTOMLEFT" },
            { "borderRight", "TOPRIGHT", "BOTTOMRIGHT" },
        }) do
            local border = CreateFrame("StatusBar", nil, dispelOverlay)
            border:SetFrameLevel(dispelOverlay:GetFrameLevel() + 1)
            border:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
            border:SetMinMaxValues(0, 1)
            border:SetValue(1)
            border:GetStatusBarTexture():SetVertexColor(dColor.r, dColor.g, dColor.b, cfg.dispelBorderAlpha or 0.8)

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

        dispelOverlay:Show()
        frame.dispelOverlay = dispelOverlay
    end

    -- Defensive icon
    if cfg.showDefensiveIcon and cfg.testShowDefensive then
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
        dTexture:SetTexture("Interface\\Icons\\spell_holy_divineprotection")
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
        dCooldown:SetHideCountdownNumbers(false)
        dCooldown:SetDrawSwipe(true)
        dCooldown:SetDrawEdge(false)
        dCooldown:SetDrawBling(false)
        dCooldown:SetReverse(true)
        dCooldown:SetCooldown(GetTime(), 10)
        defensiveIcon.cooldown = dCooldown

        defensiveIcon:Show()
        frame.defensiveIcon = defensiveIcon
    end

    -- Test aura icons
    if cfg.testShowAuras then
        ns:CreateTestAuraIcons(frame, index)
    end

    -- Selection highlight
    if cfg.showSelectionHighlight and cfg.testShowSelection and index == 1 then
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

        sel:Show()
        frame.selectionHighlight = sel
    end

    -- Hover highlight
    if cfg.showHoverHighlight and cfg.testShowHover then
        local hThick = cfg.hoverHighlightThickness or 2
        local hColor = cfg.hoverHighlightColor or { r = 1, g = 1, b = 1, a = 0.6 }

        local highlight = CreateFrame("Frame", nil, frame)
        highlight:SetAllPoints()
        highlight:SetFrameLevel(frame:GetFrameLevel() + 7)

        for _, data in ipairs({
            { "topLine", "TOPLEFT", "TOPRIGHT", hThick, nil },
            { "bottomLine", "BOTTOMLEFT", "BOTTOMRIGHT", hThick, nil },
            { "leftLine", "TOPLEFT", "BOTTOMLEFT", nil, hThick },
            { "rightLine", "TOPRIGHT", "BOTTOMRIGHT", nil, hThick },
        }) do
            local line = highlight:CreateTexture(nil, "OVERLAY")
            line:SetPoint(data[2], 0, 0)
            line:SetPoint(data[3], 0, 0)
            if data[4] then line:SetHeight(data[4]) end
            if data[5] then line:SetWidth(data[5]) end
            line:SetColorTexture(hColor.r, hColor.g, hColor.b, hColor.a or 0.6)
            highlight[data[1]] = line
        end

        highlight:Hide()
        frame.hoverHighlight = highlight

        frame:EnableMouse(true)
        frame:SetScript("OnEnter", function(self)
            if self.hoverHighlight then self.hoverHighlight:Show() end
        end)
        frame:SetScript("OnLeave", function(self)
            if self.hoverHighlight then self.hoverHighlight:Hide() end
        end)
    end

    -- Resurrect indicator
    if cfg.showResurrectIndicator and cfg.testShowResurrect and index == 2 then
        local resSize = cfg.resurrectIconSize or 22
        local resAnchor = cfg.resurrectIconAnchor or "CENTER"
        local resFrame = CreateFrame("Frame", nil, frame)
        resFrame:SetSize(resSize, resSize)
        resFrame:SetPoint(resAnchor, frame, resAnchor, cfg.resurrectIconOffsetX or 0, cfg.resurrectIconOffsetY or 0)
        resFrame:SetFrameLevel(frame:GetFrameLevel() + 25)

        local resIcon = resFrame:CreateTexture(nil, "OVERLAY")
        resIcon:SetAllPoints()
        resIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-Rez")
        resIcon:Show()
        resFrame:Show()
        frame.resurrectFrame = resFrame
        frame.resurrectIcon = resIcon
    end

    -- Ready check indicator
    if cfg.showReadyCheckIndicator and cfg.testShowReadyCheck then
        local rcSize = cfg.readyCheckIconSize or 22
        local rcAnchor = cfg.readyCheckIconAnchor or "CENTER"
        local rcFrame = CreateFrame("Frame", nil, frame)
        rcFrame:SetSize(rcSize, rcSize)
        rcFrame:SetPoint(rcAnchor, frame, rcAnchor, cfg.readyCheckIconOffsetX or 0, cfg.readyCheckIconOffsetY or 0)
        rcFrame:SetFrameLevel(frame:GetFrameLevel() + 26)

        local rcIcon = rcFrame:CreateTexture(nil, "OVERLAY")
        rcIcon:SetAllPoints()
        local statuses = { "Interface\\RaidFrame\\ReadyCheck-Ready", "Interface\\RaidFrame\\ReadyCheck-NotReady", "Interface\\RaidFrame\\ReadyCheck-Waiting" }
        rcIcon:SetTexture(statuses[((index - 1) % 3) + 1])
        rcIcon:Show()
        rcFrame:Show()
        frame.readyCheckFrame = rcFrame
        frame.readyCheckIcon = rcIcon
    end

    -- Summon indicator
    if cfg.showSummons and cfg.testShowSummon and index == 1 then
        local sSize = cfg.summonIconSize or 22
        local sAnchor = cfg.summonIconAnchor or "CENTER"
        local summonFrame = CreateFrame("Frame", nil, frame)
        summonFrame:SetSize(sSize, sSize)
        summonFrame:SetPoint(sAnchor, frame, sAnchor, cfg.summonIconOffsetX or 0, cfg.summonIconOffsetY or 0)
        summonFrame:SetFrameLevel(frame:GetFrameLevel() + 27)

        local summonIcon = summonFrame:CreateTexture(nil, "OVERLAY")
        summonIcon:SetAllPoints()
        summonIcon:SetTexture("Interface\\RaidFrame\\Raid-Icon-SummonPending")
        summonIcon:Show()
        summonFrame:Show()
        frame.summonFrame = summonFrame
        frame.summonIcon = summonIcon
    end

    -- Offline overlay
    if isOffline then
        local offlineOverlay = CreateFrame("Frame", nil, frame)
        offlineOverlay:SetAllPoints(healthBar)
        offlineOverlay:SetFrameLevel(frame:GetFrameLevel() + 8)

        local offlineBg = offlineOverlay:CreateTexture(nil, "OVERLAY")
        offlineBg:SetAllPoints()
        offlineBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

        local offlineText = offlineOverlay:CreateFontString(nil, "OVERLAY")
        offlineText:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
        offlineText:SetPoint("CENTER")
        offlineText:SetText(ns.L and ns.L.STATE_OFFLINE or "Offline")
        offlineText:SetTextColor(0.6, 0.6, 0.6)

        offlineOverlay:Show()
        frame.offlineOverlay = offlineOverlay
    end

    -- Dead state
    if isDead then
        healthBar:SetValue(0)
        healthBar:SetStatusBarColor(0.5, 0.5, 0.5)
    end

    -- Out of range
    if isOOR and cfg.enableRangeFade then
        frame:SetAlpha(cfg.rangeFadeAlpha or 0.4)
    end

    frame.testIndex = index
    frame.testInfo = testInfo
    frame:Show()

    return frame
end

-- ============================================================================
-- TEST AURA ICONS
-- ============================================================================

local TEST_AURA_TEXTURES = {
    "Interface\\Icons\\spell_nature_rejuvenation",
    "Interface\\Icons\\spell_holy_renew",
    "Interface\\Icons\\spell_holy_powerwordshield",
    "Interface\\Icons\\spell_shadow_shadowwordpain",
    "Interface\\Icons\\ability_druid_catform",
    "Interface\\Icons\\spell_nature_lightning",
    "Interface\\Icons\\spell_fire_fireball02",
    "Interface\\Icons\\spell_frost_frostbolt02",
}

function ns:CreateTestAuraIcons(frame, index)
    if not frame or not ns.db then return end
    local cfg = ns.db

    -- Test buff icons
    if cfg.showBuffs then
        frame.buffIcons = frame.buffIcons or {}
        local buffCount = min(cfg.buffCount or 4, #TEST_AURA_TEXTURES)
        local buffSize = cfg.buffSize or 14
        local position = cfg.buffPosition or "TOPRIGHT"
        local anchor = ({
            TOPLEFT = { point = "TOPLEFT", xDir = 1, yDir = -1 },
            TOPRIGHT = { point = "TOPRIGHT", xDir = -1, yDir = -1 },
            BOTTOMLEFT = { point = "BOTTOMLEFT", xDir = 1, yDir = 1 },
            BOTTOMRIGHT = { point = "BOTTOMRIGHT", xDir = -1, yDir = 1 },
        })[position] or { point = "TOPRIGHT", xDir = -1, yDir = -1 }

        for i = 1, buffCount do
            local icon = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            icon:SetSize(buffSize, buffSize)
            icon:SetFrameLevel(frame:GetFrameLevel() + 20)
            icon:ClearAllPoints()

            local row = floor((i - 1) / 4)
            local col = (i - 1) % 4
            local xOff = col * (buffSize + 1) * anchor.xDir + (2 * anchor.xDir)
            local yOff = row * (buffSize + 1) * anchor.yDir + (2 * anchor.yDir)
            icon:SetPoint(anchor.point, frame, anchor.point, xOff, yOff)

            local tex = icon:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints()
            tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tex:SetTexture(TEST_AURA_TEXTURES[((index + i - 2) % #TEST_AURA_TEXTURES) + 1])

            local border = icon:CreateTexture(nil, "OVERLAY")
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(0, 0, 0, 0.5)

            local cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
            cd:SetAllPoints()
            cd:SetDrawEdge(false)
            cd:SetDrawBling(false)
            cd:SetDrawSwipe(true)
            cd:SetReverse(true)
            cd:SetCooldown(GetTime(), 10 + i * 5)

            icon:Show()
            frame.buffIcons[i] = icon
        end
    end

    -- Test debuff icons
    if cfg.showDebuffs then
        frame.debuffIcons = frame.debuffIcons or {}
        local debuffCount = min(cfg.debuffCount or 4, #TEST_AURA_TEXTURES)
        local debuffSize = cfg.debuffSize or 16
        local position = cfg.debuffPosition or "BOTTOMRIGHT"
        local anchor = ({
            TOPLEFT = { point = "TOPLEFT", xDir = 1, yDir = -1 },
            TOPRIGHT = { point = "TOPRIGHT", xDir = -1, yDir = -1 },
            BOTTOMLEFT = { point = "BOTTOMLEFT", xDir = 1, yDir = 1 },
            BOTTOMRIGHT = { point = "BOTTOMRIGHT", xDir = -1, yDir = 1 },
        })[position] or { point = "BOTTOMRIGHT", xDir = -1, yDir = 1 }

        local dispelColors = {
            { r = 0.2, g = 0.6, b = 1 },
            { r = 0.6, g = 0, b = 1 },
            { r = 0.6, g = 0.4, b = 0 },
            { r = 0, g = 0.6, b = 0.1 },
        }

        for i = 1, debuffCount do
            local icon = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            icon:SetSize(debuffSize, debuffSize)
            icon:SetFrameLevel(frame:GetFrameLevel() + 20)
            icon:ClearAllPoints()

            local row = floor((i - 1) / 4)
            local col = (i - 1) % 4
            local xOff = col * (debuffSize + 1) * anchor.xDir + (2 * anchor.xDir)
            local yOff = row * (debuffSize + 1) * anchor.yDir + (2 * anchor.yDir)
            icon:SetPoint(anchor.point, frame, anchor.point, xOff, yOff)

            local tex = icon:CreateTexture(nil, "ARTWORK")
            tex:SetAllPoints()
            tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            tex:SetTexture(TEST_AURA_TEXTURES[((index + i + 3) % #TEST_AURA_TEXTURES) + 1])

            local dColor = dispelColors[((i - 1) % #dispelColors) + 1]
            local border = icon:CreateTexture(nil, "OVERLAY")
            border:SetPoint("TOPLEFT", -1, 1)
            border:SetPoint("BOTTOMRIGHT", 1, -1)
            border:SetColorTexture(dColor.r, dColor.g, dColor.b, 0.8)

            local cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
            cd:SetAllPoints()
            cd:SetDrawEdge(false)
            cd:SetDrawBling(false)
            cd:SetDrawSwipe(true)
            cd:SetReverse(true)
            cd:SetCooldown(GetTime(), 5 + i * 3)

            icon:Show()
            frame.debuffIcons[i] = icon
        end
    end
end

-- ============================================================================
-- HEALTH ANIMATION
-- ============================================================================

local healthAnimTicker = nil

function ns:StartHealthAnimation()
    if healthAnimTicker then return end

    healthAnimTicker = C_Timer.NewTicker(0.1, function()
        if not ns.testModeActive then
            ns:StopHealthAnimation()
            return
        end

        for _, frame in pairs(ns.testFrames) do
            if frame and frame:IsShown() and frame.healthBar and frame.testInfo then
                local info = frame.testInfo
                if not info.isDead and info.isConnected then
                    -- Smooth random health fluctuation
                    local delta = (math.random() - 0.5) * info.maxHealth * 0.05
                    info.health = max(1, min(info.maxHealth, info.health + delta))
                    frame.healthBar:SetValue(info.health)
                end
            end
        end
    end)
end

function ns:StopHealthAnimation()
    if healthAnimTicker then
        healthAnimTicker:Cancel()
        healthAnimTicker = nil
    end
end
