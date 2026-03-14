-- =====================================
-- Modules/RaidFrames.lua
-- Raid frame container with per-size positioning
-- Each raid size (10/15/20/25/30/40) has its own saved position
-- =====================================

TGF_RaidFrames = {}
local RF = TGF_RaidFrames

local raidContainer = nil
local groupContainers = {}
local raidButtons = {}
local groupLabels = {}
local isTestMode = false
local testPlayerCount = 20

-- Per-size mover overlays
local sizeMovers = {}  -- sizeMovers["10"], sizeMovers["15"], etc.
local RAID_SIZES = { 10, 15, 20, 25, 30, 40 }
local SIZE_COLORS = {
    ["10"] = { 0.20, 0.80, 0.40 },  -- Green
    ["15"] = { 0.20, 0.60, 1.00 },  -- Blue
    ["20"] = { 0.80, 0.27, 1.00 },  -- Purple (Tomo)
    ["25"] = { 1.00, 0.70, 0.00 },  -- Orange
    ["30"] = { 1.00, 0.30, 0.30 },  -- Red
    ["40"] = { 1.00, 1.00, 0.20 },  -- Yellow
}

-- =====================================
-- HELPERS
-- =====================================

--- Get the position for a given raid size
local function GetPositionForSize(sizeKey)
    local db = TomoGroupFrameDB.raid
    if db.positions and db.positions[sizeKey] then
        return db.positions[sizeKey]
    end
    return db.position -- Fallback to legacy single position
end

--- Save position for a given raid size
local function SavePositionForSize(sizeKey, point, relPoint, x, y)
    local db = TomoGroupFrameDB.raid
    if not db.positions then db.positions = {} end
    db.positions[sizeKey] = {
        point = point,
        relativePoint = relPoint,
        x = x,
        y = y,
    }
end

--- Detect current raid size bracket
local function GetCurrentRaidSizeBracket()
    local numMembers = GetNumGroupMembers()
    if numMembers <= 10 then return "10"
    elseif numMembers <= 15 then return "15"
    elseif numMembers <= 20 then return "20"
    elseif numMembers <= 25 then return "25"
    elseif numMembers <= 30 then return "30"
    else return "40" end
end

--- Calculate container dimensions for a given player count
local function GetContainerDimensions(playerCount)
    local db = TomoGroupFrameDB.raid
    local groupsPerRow = db.groupsPerRow or 5
    local labelH = db.showGroupLabels and 16 or 0
    local numGroups = math.ceil(playerCount / 5)
    local groupW = db.width + 4
    local groupH = labelH + (db.height + db.spacing) * 5 + db.groupSpacing
    local numRows = math.ceil(numGroups / groupsPerRow)
    local numCols = math.min(numGroups, groupsPerRow)

    return numCols * (groupW + db.groupSpacing), numRows * groupH
end

-- =====================================
-- VISIBILITY LOGIC
-- =====================================

local function ShouldShowRaid()
    if isTestMode then return true end
    if TGF_Utils.IsInPvP() then return false end
    local db = TomoGroupFrameDB and TomoGroupFrameDB.raid
    if not db or not db.enabled then return false end
    return TGF_Utils.IsInRaid() or IsInRaid()
end

-- =====================================
-- CREATE CONTAINER
-- =====================================

local function CreateRaidContainer()
    if raidContainer then return end

    raidContainer = CreateFrame("Frame", "TGF_RaidContainer", UIParent)
    raidContainer:SetSize(600, 400)
    raidContainer:SetFrameStrata("LOW")
    raidContainer:SetClampedToScreen(true)
    raidContainer:SetMovable(true)

    -- Position based on current raid size or default
    local pos = GetPositionForSize("20") -- Default to 20-man position
    raidContainer:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
end

--- Reposition container based on detected raid size
local function RepositionForRaidSize()
    if not raidContainer then return end
    local sizeKey = GetCurrentRaidSizeBracket()
    local pos = GetPositionForSize(sizeKey)
    raidContainer:ClearAllPoints()
    raidContainer:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
end

-- =====================================
-- CREATE GROUP CONTAINERS & BUTTONS
-- =====================================

local function CreateRaidButtons()
    local db = TomoGroupFrameDB.raid
    local groupsPerRow = db.groupsPerRow or 5
    local labelH = db.showGroupLabels and 16 or 0

    for groupIdx = 1, 8 do
        if not groupContainers[groupIdx] then
            groupContainers[groupIdx] = CreateFrame("Frame", "TGF_RaidGroup" .. groupIdx, raidContainer)
        end

        local gc = groupContainers[groupIdx]
        local col = ((groupIdx - 1) % groupsPerRow)
        local row = math.floor((groupIdx - 1) / groupsPerRow)

        local groupW = db.width + 4
        local groupH = labelH + (db.height + db.spacing) * 5 + db.groupSpacing

        gc:SetSize(groupW, groupH)
        gc:ClearAllPoints()
        gc:SetPoint("TOPLEFT", raidContainer, "TOPLEFT",
            col * (groupW + db.groupSpacing),
            -row * groupH
        )

        if db.showGroupLabels then
            if not groupLabels[groupIdx] then
                local label = gc:CreateFontString(nil, "OVERLAY")
                label:SetFont(TGF_GetFontPath("PoppinsBold"), 9, "OUTLINE")
                label:SetPoint("TOPLEFT", 2, 0)
                label:SetTextColor(0.8, 0.27, 1.0)
                groupLabels[groupIdx] = label
            end
            groupLabels[groupIdx]:SetText("G" .. groupIdx)
            groupLabels[groupIdx]:Show()
        elseif groupLabels[groupIdx] then
            groupLabels[groupIdx]:Hide()
        end

        for slot = 1, 5 do
            local raidIdx = (groupIdx - 1) * 5 + slot
            local unitID = "raid" .. raidIdx

            if not raidButtons[unitID] then
                raidButtons[unitID] = TGF_UnitFrame.CreateUnitButton(unitID, gc, db)
            end

            local btn = raidButtons[unitID]
            btn:ClearAllPoints()
            btn:SetSize(db.width, db.height)
            btn:SetPoint("TOPLEFT", gc, "TOPLEFT", 0, -labelH - (slot - 1) * (db.height + db.spacing))
            btn.settings = db
        end
    end

    -- Resize container to fit 40-man (groups will be hidden/shown as needed)
    local w, h = GetContainerDimensions(40)
    raidContainer:SetSize(w, h)
end

-- =====================================
-- PER-SIZE MOVER OVERLAYS
-- =====================================

local function CreateSizeMovers()
    for _, size in ipairs(RAID_SIZES) do
        local key = tostring(size)
        if sizeMovers[key] then break end -- Already created

        local mover = CreateFrame("Frame", "TGF_RaidMover_" .. key, UIParent, "BackdropTemplate")
        mover:SetFrameStrata("DIALOG")
        mover:EnableMouse(true)
        mover:SetMovable(true)
        mover:RegisterForDrag("LeftButton")
        mover:SetClampedToScreen(true)

        -- Position from saved data
        local pos = GetPositionForSize(key)
        local w, h = GetContainerDimensions(size)
        mover:SetSize(w, h)
        mover:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)

        -- Visual
        local c = SIZE_COLORS[key] or { 0.8, 0.27, 1.0 }
        mover:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 2,
        })
        mover:SetBackdropColor(c[1], c[2], c[3], 0.12)
        mover:SetBackdropBorderColor(c[1], c[2], c[3], 0.8)

        -- Label
        local label = mover:CreateFontString(nil, "OVERLAY")
        label:SetFont(TGF_GetFontPath("PoppinsBold"), 14, "OUTLINE")
        label:SetPoint("CENTER")
        label:SetTextColor(c[1], c[2], c[3])
        label:SetText("Raid " .. size)
        mover.label = label

        -- Sub-label
        local sub = mover:CreateFontString(nil, "OVERLAY")
        sub:SetFont(TGF_GetFontPath("Poppins"), 10, "OUTLINE")
        sub:SetPoint("TOP", label, "BOTTOM", 0, -2)
        sub:SetTextColor(c[1], c[2], c[3], 0.7)
        sub:SetText("Drag to position")
        mover.sub = sub

        -- Drag scripts
        mover:SetScript("OnDragStart", function(self)
            self:StartMoving()
        end)
        mover:SetScript("OnDragStop", function(self)
            self:StopMovingOrSizing()
            local pt, _, relPt, x, y = self:GetPoint()
            SavePositionForSize(key, pt, relPt, x, y)
        end)

        mover:Hide()
        sizeMovers[key] = mover
    end
end

-- =====================================
-- UPDATE LOOP
-- =====================================

local UPDATE_INTERVAL = 0.15
local elapsed = 0

local function OnUpdate(self, dt)
    elapsed = elapsed + dt
    if elapsed < UPDATE_INTERVAL then return end
    elapsed = 0

    if not ShouldShowRaid() then
        if raidContainer and raidContainer:IsShown() then
            raidContainer:Hide()
        end
        return
    end

    if raidContainer and not raidContainer:IsShown() then
        raidContainer:Show()
        RepositionForRaidSize()
    end

    if isTestMode then return end

    for _, btn in pairs(raidButtons) do
        if btn:IsShown() then
            TGF_UnitFrame.UpdateAll(btn)
        end
    end
end

-- =====================================
-- EVENTS
-- =====================================

local eventFrame = CreateFrame("Frame")

local function OnEvent(self, event, arg1)
    if not TomoGroupFrameDB or not TomoGroupFrameDB.raid then return end
    if isTestMode then return end

    if event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_ENTERING_WORLD" then
        if ShouldShowRaid() then
            if raidContainer then
                RepositionForRaidSize()
                raidContainer:Show()
                CreateRaidButtons()
                for _, btn in pairs(raidButtons) do
                    TGF_UnitFrame.UpdateAll(btn)
                end
            end
        elseif raidContainer then
            raidContainer:Hide()
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH" then
        local btn = raidButtons[arg1]
        if btn then
            TGF_UnitFrame.UpdateHealth(btn)
            TGF_UnitFrame.UpdateStatus(btn)
        end
    elseif event == "UNIT_POWER_FREQUENT" or event == "UNIT_MAXPOWER" then
        local btn = raidButtons[arg1]
        if btn then TGF_UnitFrame.UpdatePower(btn) end
    elseif event == "UNIT_AURA" then
        local btn = raidButtons[arg1]
        if btn then
            btn.dispelOverlay:UpdateForUnit(btn.unit, btn.settings)
            btn.hotContainer:UpdateForUnit(btn.unit, btn.settings)
        end
    elseif event == "UNIT_NAME_UPDATE" then
        local btn = raidButtons[arg1]
        if btn then TGF_UnitFrame.UpdateName(btn) end
    elseif event == "RAID_TARGET_UPDATE" then
        for _, btn in pairs(raidButtons) do TGF_UnitFrame.UpdateRaidIcon(btn) end
    elseif event == "PLAYER_ROLES_ASSIGNED" then
        for _, btn in pairs(raidButtons) do TGF_UnitFrame.UpdateRole(btn) end
    end
end

-- =====================================
-- PUBLIC API
-- =====================================

function RF.Initialize()
    local db = TomoGroupFrameDB and TomoGroupFrameDB.raid
    if not db or not db.enabled then return end

    CreateRaidContainer()
    CreateRaidButtons()

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
    eventFrame:SetScript("OnUpdate", OnUpdate)

    if ShouldShowRaid() then
        RepositionForRaidSize()
        raidContainer:Show()
    else
        raidContainer:Hide()
    end

    RF.HideBlizzardRaid()
end

function RF.HideBlizzardRaid()
    if CompactRaidFrameContainer then
        CompactRaidFrameContainer:UnregisterAllEvents()
        CompactRaidFrameContainer:Hide()
    end
    if CompactRaidFrameManager then
        CompactRaidFrameManager:UnregisterAllEvents()
        CompactRaidFrameManager:Hide()
    end
end

function RF.Refresh()
    if not raidContainer then return end
    local db = TomoGroupFrameDB.raid

    for _, btn in pairs(raidButtons) do
        btn.settings = db
        btn:SetSize(db.width, db.height)
        TGF_Bar.SetTexture(btn.healthBar, db.barTexture)
        if btn.powerBar then TGF_Bar.SetTexture(btn.powerBar, db.barTexture) end
        btn.nameText:SetFont(TGF_GetFontPath(db.nameFont), db.nameFontSize, "OUTLINE")
        btn.hpText:SetFont(TGF_GetFontPath(db.hpFont), db.hpFontSize, "OUTLINE")
        btn.hotContainer:UpdateIconSize(db.hotIconSize or 14)
        btn.dispelOverlay:SetBorderSize(db.dispelBorderSize or 2)
    end

    CreateRaidButtons()
    RepositionForRaidSize()

    -- Update mover sizes if they exist
    for _, size in ipairs(RAID_SIZES) do
        local key = tostring(size)
        if sizeMovers[key] then
            local w, h = GetContainerDimensions(size)
            sizeMovers[key]:SetSize(w, h)
        end
    end

    if isTestMode then RF.ApplyTestMode() end
end

-- =====================================
-- TEST MODE
-- =====================================

function RF.SetTestSize(count)
    testPlayerCount = count or 20
    if isTestMode then RF.ApplyTestMode() end
end

function RF.GetTestSize()
    return testPlayerCount
end

function RF.ApplyTestMode()
    if not raidContainer then
        CreateRaidContainer()
        CreateRaidButtons()
    end

    -- Use the position for the test size
    local sizeKey = tostring(testPlayerCount)
    local pos = GetPositionForSize(sizeKey)
    raidContainer:ClearAllPoints()
    raidContainer:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
    raidContainer:Show()

    local classes = { "WARRIOR", "PALADIN", "PRIEST", "SHAMAN", "DRUID",
        "HUNTER", "MAGE", "WARLOCK", "ROGUE", "DEATHKNIGHT" }

    for i = 1, 40 do
        local unitID = "raid" .. i
        local btn = raidButtons[unitID]
        if btn then
            UnregisterUnitWatch(btn)
            if i <= testPlayerCount then
                btn:Show()
                btn.healthBar:SetMinMaxValues(0, 100)
                btn.healthBar:SetValue(math.random(15, 100))
                btn.nameText:SetText(TGF_Utils.TruncateName("Raider" .. i, btn.settings.nameTruncateLen))
                btn.hpText:SetText(math.random(15, 100) .. "%")
                btn.statusText:SetText("")
                local cls = classes[((i - 1) % #classes) + 1]
                local c = RAID_CLASS_COLORS[cls]
                if c then
                    btn.healthBar:SetStatusBarColor(c.r, c.g, c.b)
                    btn.nameText:SetTextColor(c.r, c.g, c.b)
                end
            else
                btn:Hide()
            end
        end
    end

    local numGroups = math.ceil(testPlayerCount / 5)
    for groupIdx = 1, 8 do
        if groupContainers[groupIdx] then
            groupContainers[groupIdx]:SetShown(groupIdx <= numGroups)
        end
    end
end

function RF.ToggleTestMode()
    isTestMode = not isTestMode
    if isTestMode then
        RF.ApplyTestMode()
        print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r Raid test (" .. testPlayerCount .. "p) " .. TGF_L["test_mode_on"])
    else
        for i = 1, 40 do
            local btn = raidButtons["raid" .. i]
            if btn then RegisterUnitWatch(btn) end
        end
        for groupIdx = 1, 8 do
            if groupContainers[groupIdx] then groupContainers[groupIdx]:Show() end
        end
        if raidContainer and not ShouldShowRaid() then raidContainer:Hide() end
        print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r Raid " .. TGF_L["test_mode_off"])
    end
end

-- =====================================
-- LOCK / UNLOCK — Shows 6 mover ghosts, one per raid size
-- =====================================

function RF.ToggleLock()
    -- Create movers lazily
    CreateSizeMovers()

    -- Check if any mover is shown
    local anyShown = false
    for _, m in pairs(sizeMovers) do
        if m:IsShown() then anyShown = true; break end
    end

    if anyShown then
        -- Lock: hide all movers
        for _, m in pairs(sizeMovers) do m:Hide() end
    else
        -- Unlock: show all 6 size movers for independent positioning
        for _, size in ipairs(RAID_SIZES) do
            local key = tostring(size)
            local m = sizeMovers[key]
            if m then
                local pos = GetPositionForSize(key)
                local w, h = GetContainerDimensions(size)
                m:SetSize(w, h)
                m:ClearAllPoints()
                m:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
                m:Show()
            end
        end
    end
end

function RF.GetContainer()
    return raidContainer
end
