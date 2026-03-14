-- =====================================
-- Modules/PartyFrames.lua
-- Party frame container (5-man dungeon display)
-- Only visible in dungeon instances (not PvP)
-- =====================================

TGF_PartyFrames = {}
local PF = TGF_PartyFrames

local partyContainer = nil
local partyMover = nil   -- Non-secure mover overlay
local partyButtons = {}
local updateTimer = nil
local isTestMode = false

-- =====================================
-- VISIBILITY LOGIC
-- =====================================

local function ShouldShowParty()
    if isTestMode then return true end
    if TGF_Utils.IsInPvP() then return false end

    local db = TomoGroupFrameDB and TomoGroupFrameDB.party
    if not db or not db.enabled then return false end

    -- Show in dungeons OR when in a party outside raid
    if TGF_Utils.IsInDungeon() then return true end

    -- Also show in open world party (not raid)
    if IsInGroup() and not IsInRaid() then return true end

    return false
end

-- =====================================
-- CREATE CONTAINER
-- =====================================

local function CreatePartyContainer()
    if partyContainer then return end

    local db = TomoGroupFrameDB.party

    partyContainer = CreateFrame("Frame", "TGF_PartyContainer", UIParent)
    partyContainer:SetSize(db.width + 4, (db.height + db.spacing) * 5)
    partyContainer:SetPoint(
        db.position.point,
        UIParent,
        db.position.relativePoint,
        db.position.x,
        db.position.y
    )
    partyContainer:SetFrameStrata("LOW")
    partyContainer:SetClampedToScreen(true)
    partyContainer:SetMovable(true)

    -- Mover overlay (non-secure, avoids ADDON_ACTION_BLOCKED)
    partyMover = CreateFrame("Frame", "TGF_PartyMover", UIParent, "BackdropTemplate")
    partyMover:SetAllPoints(partyContainer)
    partyMover:SetFrameStrata("DIALOG")
    partyMover:EnableMouse(true)
    partyMover:SetMovable(true)
    partyMover:RegisterForDrag("LeftButton")
    partyMover:SetScript("OnDragStart", function()
        partyContainer:StartMoving()
    end)
    partyMover:SetScript("OnDragStop", function()
        partyContainer:StopMovingOrSizing()
        local point, _, relPoint, x, y = partyContainer:GetPoint()
        local dbs = TomoGroupFrameDB.party
        dbs.position.point = point
        dbs.position.relativePoint = relPoint
        dbs.position.x = x
        dbs.position.y = y
    end)
    partyMover:Hide()
end

-- =====================================
-- CREATE / UPDATE BUTTONS
-- =====================================

local function CreatePartyButtons()
    local db = TomoGroupFrameDB.party

    -- Create 5 buttons: player + party1-4 (or just party1-4 depending on preference)
    local units = { "player", "party1", "party2", "party3", "party4" }

    for i, unitID in ipairs(units) do
        if not partyButtons[i] then
            partyButtons[i] = TGF_UnitFrame.CreateUnitButton(unitID, partyContainer, db)
        end

        local btn = partyButtons[i]
        btn:ClearAllPoints()

        if db.growDirection == "DOWN" then
            local offset = (i - 1) * (db.height + db.spacing)
            btn:SetPoint("TOPLEFT", partyContainer, "TOPLEFT", 0, -offset)
        elseif db.growDirection == "UP" then
            local offset = (i - 1) * (db.height + db.spacing)
            btn:SetPoint("BOTTOMLEFT", partyContainer, "BOTTOMLEFT", 0, offset)
        elseif db.growDirection == "RIGHT" then
            local offset = (i - 1) * (db.width + db.spacing)
            btn:SetPoint("TOPLEFT", partyContainer, "TOPLEFT", offset, 0)
        elseif db.growDirection == "LEFT" then
            local offset = (i - 1) * (db.width + db.spacing)
            btn:SetPoint("TOPRIGHT", partyContainer, "TOPRIGHT", -offset, 0)
        end

        btn:SetSize(db.width, db.height)
    end

    -- Resize container
    if db.growDirection == "DOWN" or db.growDirection == "UP" then
        partyContainer:SetSize(db.width, (db.height + db.spacing) * #units)
    else
        partyContainer:SetSize((db.width + db.spacing) * #units, db.height)
    end

    -- Sync mover overlay
    if partyMover then
        partyMover:ClearAllPoints()
        partyMover:SetAllPoints(partyContainer)
    end
end

-- =====================================
-- UPDATE LOOP
-- =====================================

local UPDATE_INTERVAL = 0.1 -- 10 FPS update rate
local elapsed = 0

local function OnUpdate(self, dt)
    elapsed = elapsed + dt
    if elapsed < UPDATE_INTERVAL then return end
    elapsed = 0

    if not ShouldShowParty() then
        if partyContainer and partyContainer:IsShown() then
            partyContainer:Hide()
        end
        return
    end

    if partyContainer and not partyContainer:IsShown() then
        partyContainer:Show()
    end

    -- In test mode, data is static — skip UpdateAll
    if isTestMode then return end

    for _, btn in ipairs(partyButtons) do
        if btn:IsShown() then
            TGF_UnitFrame.UpdateAll(btn)
        end
    end
end

-- =====================================
-- EVENT HANDLING
-- =====================================

local eventFrame = CreateFrame("Frame")

local function OnEvent(self, event, arg1)
    if not TomoGroupFrameDB or not TomoGroupFrameDB.party then return end
    if isTestMode then return end

    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        if ShouldShowParty() then
            if partyContainer then
                partyContainer:Show()
                CreatePartyButtons()
                for _, btn in ipairs(partyButtons) do
                    TGF_UnitFrame.UpdateAll(btn)
                end
            end
        else
            if partyContainer then
                partyContainer:Hide()
            end
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        for _, btn in ipairs(partyButtons) do
            if btn.unit == arg1 then
                TGF_UnitFrame.UpdateHealth(btn)
                TGF_UnitFrame.UpdateStatus(btn)
            end
        end
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        for _, btn in ipairs(partyButtons) do
            if btn.unit == arg1 then
                TGF_UnitFrame.UpdatePower(btn)
            end
        end
    elseif event == "UNIT_AURA" then
        for _, btn in ipairs(partyButtons) do
            if btn.unit == arg1 then
                btn.dispelOverlay:UpdateForUnit(btn.unit, btn.settings)
                btn.hotContainer:UpdateForUnit(btn.unit, btn.settings)
            end
        end
    elseif event == "UNIT_NAME_UPDATE" then
        for _, btn in ipairs(partyButtons) do
            if btn.unit == arg1 then
                TGF_UnitFrame.UpdateName(btn)
            end
        end
    elseif event == "RAID_TARGET_UPDATE" then
        for _, btn in ipairs(partyButtons) do
            TGF_UnitFrame.UpdateRaidIcon(btn)
        end
    elseif event == "PLAYER_ROLES_ASSIGNED" or event == "GROUP_ROSTER_UPDATE" then
        for _, btn in ipairs(partyButtons) do
            TGF_UnitFrame.UpdateRole(btn)
        end
    end
end

-- =====================================
-- PUBLIC API
-- =====================================

function PF.Initialize()
    local db = TomoGroupFrameDB and TomoGroupFrameDB.party
    if not db or not db.enabled then return end

    TGF_DispelTracker.UpdatePlayerDispels()
    CreatePartyContainer()
    CreatePartyButtons()

    -- Register events
    eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:RegisterEvent("UNIT_HEALTH")
    eventFrame:RegisterEvent("UNIT_MAXHEALTH")
    eventFrame:RegisterEvent("UNIT_POWER_FREQUENT")
    eventFrame:RegisterEvent("UNIT_MAXPOWER")
    eventFrame:RegisterEvent("UNIT_AURA")
    eventFrame:RegisterEvent("UNIT_NAME_UPDATE")
    eventFrame:RegisterEvent("RAID_TARGET_UPDATE")
    eventFrame:RegisterEvent("PLAYER_ROLES_ASSIGNED")
    eventFrame:SetScript("OnEvent", OnEvent)

    -- Periodic update (range check, etc.)
    eventFrame:SetScript("OnUpdate", OnUpdate)

    -- Initial visibility check
    if ShouldShowParty() then
        partyContainer:Show()
    else
        partyContainer:Hide()
    end

    -- Hide Blizzard party frames
    PF.HideBlizzardParty()
end

function PF.HideBlizzardParty()
    if CompactPartyFrame then
        CompactPartyFrame:UnregisterAllEvents()
        CompactPartyFrame:Hide()
        CompactPartyFrame:SetParent(CreateFrame("Frame")) -- Orphan it
    end
    for i = 1, 4 do
        local f = _G["PartyMemberFrame" .. i]
        if f then
            f:UnregisterAllEvents()
            f:Hide()
            f:SetParent(CreateFrame("Frame"))
        end
    end
end

function PF.Refresh()
    if not partyContainer then return end
    local db = TomoGroupFrameDB.party

    -- Update container position
    partyContainer:ClearAllPoints()
    partyContainer:SetPoint(
        db.position.point,
        UIParent,
        db.position.relativePoint,
        db.position.x,
        db.position.y
    )

    -- Recreate buttons with new settings
    for _, btn in ipairs(partyButtons) do
        btn.settings = db
        btn:SetSize(db.width, db.height)

        -- Update textures
        TGF_Bar.SetTexture(btn.healthBar, db.barTexture)
        if btn.powerBar then
            TGF_Bar.SetTexture(btn.powerBar, db.barTexture)
        end

        -- Update fonts
        btn.nameText:SetFont(TGF_GetFontPath(db.nameFont), db.nameFontSize, "OUTLINE")
        btn.hpText:SetFont(TGF_GetFontPath(db.hpFont), db.hpFontSize, "OUTLINE")

        -- Update HoT icon size
        btn.hotContainer:UpdateIconSize(db.hotIconSize or 16)

        -- Update dispel border
        btn.dispelOverlay:SetBorderSize(db.dispelBorderSize or 2)

        TGF_UnitFrame.UpdateAll(btn)
    end

    CreatePartyButtons() -- Reposition
end

function PF.ToggleTestMode()
    isTestMode = not isTestMode
    if isTestMode then
        if not partyContainer then
            CreatePartyContainer()
            CreatePartyButtons()
        end
        partyContainer:Show()
        -- Set fake data for preview
        local classes = { "WARRIOR", "PALADIN", "PRIEST", "SHAMAN", "DRUID" }
        for i, btn in ipairs(partyButtons) do
            -- CRITICAL: UnregisterUnitWatch so buttons stay visible
            UnregisterUnitWatch(btn)
            btn:Show()
            btn.healthBar:SetMinMaxValues(0, 100)
            btn.healthBar:SetValue(math.random(20, 100))
            btn.nameText:SetText(TGF_Utils.TruncateName("TestPlayer" .. i, btn.settings.nameTruncateLen))
            btn.hpText:SetText(math.random(20, 100) .. "%")
            btn.statusText:SetText("")

            local c = RAID_CLASS_COLORS[classes[i] or "WARRIOR"]
            if c then
                btn.healthBar:SetStatusBarColor(c.r, c.g, c.b)
                btn.nameText:SetTextColor(c.r, c.g, c.b)
            end
        end
        print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r Party " .. TGF_L["test_mode_on"])
    else
        -- Re-register unit watch
        for _, btn in ipairs(partyButtons) do
            RegisterUnitWatch(btn)
        end
        if partyContainer and not ShouldShowParty() then
            partyContainer:Hide()
        end
        print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r Party " .. TGF_L["test_mode_off"])
    end
end

function PF.ToggleLock()
    if not partyContainer or not partyMover then return end

    if partyMover:IsShown() then
        partyMover:Hide()
    else
        partyMover:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        partyMover:SetBackdropColor(0.8, 0.27, 1.0, 0.15)
        partyMover:SetBackdropBorderColor(0.8, 0.27, 1.0, 0.6)

        if not partyMover.label then
            local lbl = partyMover:CreateFontString(nil, "OVERLAY")
            lbl:SetFont(TGF_GetFontPath("PoppinsBold"), 11, "OUTLINE")
            lbl:SetPoint("CENTER")
            lbl:SetTextColor(0.8, 0.27, 1.0)
            lbl:SetText("Party — Drag to move")
            partyMover.label = lbl
        end

        partyContainer:Show()
        partyMover:Show()
    end
end

function PF.GetContainer()
    return partyContainer
end
