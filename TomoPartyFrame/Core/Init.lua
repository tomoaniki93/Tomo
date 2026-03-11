-- TomoPartyFrame Core Init
-- Main addon initialization, event handling, slash commands

local ADDON, ns = ...

-- Cache frequently used globals
local pairs, ipairs, wipe = pairs, ipairs, wipe
local floor, ceil, min, max = math.floor, math.ceil, math.min, math.max
local print = print
local CreateFrame = CreateFrame
local C_Timer = C_Timer
local UnitExists = UnitExists
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitInRange = UnitInRange
local UnitName = UnitName
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local GetNumGroupMembers = GetNumGroupMembers
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local GetPhysicalScreenSize = GetPhysicalScreenSize
local UIParent = UIParent

-- State
ns.testModeActive = false
ns.dragMode = false
ns.frames = {}
ns.testFrames = {}
ns.blizzardFramesHidden = false
ns.container = nil
ns.containerCreated = false
ns.pendingOptionsOpen = false
ns.pendingRefresh = false

-- Blizzard frame names to hide
ns.blizzardPartyFrames = {
    "CompactRaidFrameContainer",
    "CompactPartyFrame",
    "PartyFrame",
}

-- Pixel scale cache
local cachedPixelScale = nil

function ns:GetPixelScale()
    if not cachedPixelScale then
        local _, physicalHeight = GetPhysicalScreenSize()
        local uiScale = UIParent:GetEffectiveScale()
        cachedPixelScale = (768 / physicalHeight) / uiScale
    end
    return cachedPixelScale
end

function ns:InvalidatePixelScaleCache()
    cachedPixelScale = nil
end

-- Party unit tokens
ns.partyUnits = { "player", "party1", "party2", "party3", "party4" }

-- Role sort order
local roleSortOrder = {
    TANK = 1,
    HEALER = 2,
    DAMAGER = 3,
    NONE = 4,
}

-- Get sorted list of unit tokens for party
function ns:GetSortedUnits()
    local units = {}
    local cfg = ns.db or {}
    local sortMode = cfg.sortMode or "GROUP"
    local showPlayer = cfg.showPlayer ~= false

    local groupSize = GetNumGroupMembers()

    if groupSize == 0 then
        if showPlayer then
            return { "player" }
        end
        return {}
    end

    -- Party only: player + party1-party4
    if showPlayer then
        units[#units + 1] = "player"
    end
    for i = 1, groupSize - 1 do
        local unit = "party" .. i
        if UnitExists(unit) then
            units[#units + 1] = unit
        end
    end

    if sortMode == "ROLE" then
        table.sort(units, function(a, b)
            local roleA = UnitGroupRolesAssigned(a) or "NONE"
            local roleB = UnitGroupRolesAssigned(b) or "NONE"
            local orderA = roleSortOrder[roleA] or 4
            local orderB = roleSortOrder[roleB] or 4
            if orderA ~= orderB then
                return orderA < orderB
            end
            return (UnitName(a) or "") < (UnitName(b) or "")
        end)
    end

    return units
end

-- Event frame
local eventFrame = CreateFrame("Frame")

-- Hide Blizzard party frames
function ns:HideBlizzardFrames()
    if ns.blizzardFramesHidden then return end

    local containers = { "CompactRaidFrameContainer", "PartyFrame" }
    for _, frameName in ipairs(containers) do
        local frame = _G[frameName]
        if frame and not frame:IsForbidden() then
            pcall(function()
                frame:SetAlpha(0)
                if not InCombatLockdown() then
                    frame:SetScale(0.001)
                end
            end)
        end
    end

    if CompactPartyFrame and not CompactPartyFrame:IsForbidden() then
        pcall(function()
            CompactPartyFrame:SetAlpha(0)
            if CompactPartyFrame.title then CompactPartyFrame.title:SetAlpha(0) end
            if CompactPartyFrame.borderFrame then CompactPartyFrame.borderFrame:SetAlpha(0) end
        end)
    end

    local function HideFrameHighlights(frame)
        if not frame then return end
        pcall(function()
            frame:SetAlpha(0)
            if frame.selectionHighlight then frame.selectionHighlight:SetAlpha(0) end
            if frame.aggroHighlight then frame.aggroHighlight:SetAlpha(0) end
        end)
    end

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. i]
        if frame and not frame:IsForbidden() then
            HideFrameHighlights(frame)
        end
    end

    for i = 1, 4 do
        local frame = _G["PartyMemberFrame" .. i]
        if frame and not frame:IsForbidden() then
            HideFrameHighlights(frame)
        end
    end

    -- Hook selection updates to keep them hidden
    if not ns.blizzardSelectionHooked then
        ns.blizzardSelectionHooked = true
        if CompactUnitFrame_UpdateSelectionHighlight then
            hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
                if ns.blizzardFramesHidden and frame and not frame:IsForbidden() then
                    pcall(function()
                        if frame.selectionHighlight then frame.selectionHighlight:SetAlpha(0) end
                    end)
                end
            end)
        end
    end

    ns.blizzardFramesHidden = true
end

-- Show Blizzard party frames
function ns:ShowBlizzardFrames()
    if not ns.blizzardFramesHidden then return end

    local containers = { "CompactRaidFrameContainer", "PartyFrame" }
    for _, frameName in ipairs(containers) do
        local frame = _G[frameName]
        if frame and not frame:IsForbidden() then
            pcall(function()
                frame:SetAlpha(1)
                if not InCombatLockdown() then frame:SetScale(1) end
            end)
        end
    end

    if CompactPartyFrame and not CompactPartyFrame:IsForbidden() then
        pcall(function()
            CompactPartyFrame:SetAlpha(1)
            if CompactPartyFrame.title then CompactPartyFrame.title:SetAlpha(1) end
            if CompactPartyFrame.borderFrame then CompactPartyFrame.borderFrame:SetAlpha(1) end
        end)
    end

    for i = 1, 5 do
        local frame = _G["CompactPartyFrameMember" .. i]
        if frame and not frame:IsForbidden() then
            pcall(function() frame:SetAlpha(1) end)
        end
    end

    for i = 1, 4 do
        local frame = _G["PartyMemberFrame" .. i]
        if frame and not frame:IsForbidden() then
            pcall(function() frame:SetAlpha(1) end)
        end
    end

    ns.blizzardFramesHidden = false
end

function ns:ApplyBlizzardFrameVisibility()
    if InCombatLockdown() then
        C_Timer.After(0.5, function() ns:ApplyBlizzardFrameVisibility() end)
        return
    end
    if ns.db and ns.db.hideBlizzardFrames then
        ns:HideBlizzardFrames()
    else
        ns:ShowBlizzardFrames()
    end
end

-- Update container visibility based on group status
function ns:UpdateContainerVisibility()
    if not ns.container then return end

    -- Always show in test/drag mode
    if ns.testModeActive or ns.dragMode then
        ns.container:Show()
        self:ApplyBlizzardFrameVisibility()
        return
    end

    local cfg = ns.db
    if cfg and cfg.hideWhenSolo then
        local groupSize = GetNumGroupMembers()
        if groupSize <= 1 then
            ns.container:Hide()
            -- Restore Blizzard frames when our frame is hidden
            if ns.blizzardFramesHidden then
                self:ShowBlizzardFrames()
            end
            return
        end
    end

    ns.container:Show()
    self:ApplyBlizzardFrameVisibility()
end

-- Create the party container
function ns:CreateContainer()
    if ns.containerCreated then return end

    local container = CreateFrame("Frame", "TomoPartyFrameContainer", UIParent)
    container:SetClampedToScreen(true)
    container:SetMovable(true)
    ns.container = container
    ns.containerCreated = true
end

-- Update container size and position
function ns:UpdateContainer()
    local container = ns.container
    if not container or not ns.db then return end

    local cfg = ns.db
    local frameCount
    if ns.testModeActive then
        frameCount = cfg.testFrameCount or 5
    else
        local groupSize = GetNumGroupMembers()
        frameCount = (groupSize > 1) and groupSize or 5
    end

    local maxColumns = cfg.maxColumns or 5
    local columnSpacing = cfg.columnSpacing or 4
    local growDir = cfg.growDirection or "DOWN"

    local numCols = min(frameCount, maxColumns)
    local numRows = ceil(frameCount / maxColumns)

    local width, height
    if growDir == "DOWN" or growDir == "UP" then
        width = (cfg.frameWidth * numRows) + (columnSpacing * max(0, numRows - 1))
        height = (cfg.frameHeight * numCols) + (cfg.frameSpacing * max(0, numCols - 1))
    else
        width = (cfg.frameWidth * numCols) + (cfg.frameSpacing * max(0, numCols - 1))
        height = (cfg.frameHeight * numRows) + (columnSpacing * max(0, numRows - 1))
    end

    container:SetSize(width, height)

    local pos = cfg.position or { point = "LEFT", x = 100, y = 0 }
    container:ClearAllPoints()
    container:SetPoint(pos.point or "LEFT", UIParent, pos.point or "LEFT", pos.x or 100, pos.y or 0)
end

-- Create drag overlay for container
local function CreateDragOverlay(container)
    if container.dragOverlay then return end

    container.dragOverlay = CreateFrame("Frame", nil, container, "BackdropTemplate")
    container.dragOverlay:SetAllPoints()
    container.dragOverlay:SetFrameStrata("HIGH")
    container.dragOverlay:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
    })
    container.dragOverlay:SetBackdropColor(0.2, 0.4, 0.8, 0.5)
    container.dragOverlay:SetBackdropBorderColor(0.4, 0.6, 1.0, 1)

    container.dragLabel = container.dragOverlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    container.dragLabel:SetPoint("CENTER")
    container.dragLabel:SetText("TomoPartyFrame\nDrag to Move")

    container.dragOverlay:EnableMouse(true)
    container.dragOverlay:SetMovable(true)
    container.dragOverlay:RegisterForDrag("LeftButton")

    container.dragOverlay:SetScript("OnDragStart", function()
        container:StartMoving()
    end)

    container.dragOverlay:SetScript("OnDragStop", function()
        container:StopMovingOrSizing()
        local point, _, _, x, y = container:GetPoint()
        if ns.db then
            ns.db.position = { point = point, x = x, y = y }
        end
    end)
end

-- Toggle drag mode
function ns:ToggleDragMode(enable)
    if enable ~= nil then
        ns.dragMode = enable
    else
        ns.dragMode = not ns.dragMode
    end

    if ns.container then
        CreateDragOverlay(ns.container)
        if ns.dragMode then
            ns.container:Show()
            ns.container.dragOverlay:Show()
        else
            if ns.container.dragOverlay then ns.container.dragOverlay:Hide() end
            ns:UpdateContainerVisibility()
        end
    end

    local L = ns.L
    print("TomoPartyFrame: " .. (ns.dragMode and L.MSG_DRAG_ENABLED or L.MSG_DRAG_DISABLED))
end

-- Initialize addon
function ns:Initialize()
    if not ns.db then return end

    self:CreateContainer()
    self:UpdateContainer()

    -- Setup Blizzard aura hooks
    if ns.SetupBlizzardAuraHooks then
        ns:SetupBlizzardAuraHooks()
    end

    -- Create frames
    if ns.testModeActive then
        self:CreateTestFrames()
    else
        self:CreatePartyFrames()
    end

    self:UpdateContainerVisibility()
end

-- Create party frames
function ns:CreatePartyFrames()
    for _, frame in pairs(ns.testFrames) do
        frame:Hide()
    end

    local units = ns:GetSortedUnits()

    if ns.CreateUnitFrame then
        for i, unit in ipairs(units) do
            if not ns.frames[unit] then
                ns.frames[unit] = ns:CreateUnitFrame(unit, i)
            end
        end

        for unit, frame in pairs(ns.frames) do
            local found = false
            for _, u in ipairs(units) do
                if u == unit then found = true; break end
            end
            if not found and not InCombatLockdown() then
                frame:Hide()
            end
        end

        ns:LayoutFrames()
    end
end

-- Create test frames
function ns:CreateTestFrames()
    if not InCombatLockdown() then
        for _, frame in pairs(ns.frames) do
            frame:Hide()
        end
    end

    if ns.CreateTestFrame then
        local count = ns.db and ns.db.testFrameCount or 5
        for i = 1, count do
            if not ns.testFrames[i] then
                ns.testFrames[i] = ns:CreateTestFrame(i)
            else
                ns.testFrames[i]:Show()
            end
        end
        for i = count + 1, #ns.testFrames do
            if ns.testFrames[i] then ns.testFrames[i]:Hide() end
        end
        ns:LayoutTestFrames()
    end
end

-- Destroy all frames
function ns:DestroyFrames()
    if not InCombatLockdown() then
        for unit, frame in pairs(ns.frames) do
            if frame then frame:Hide(); frame:SetParent(nil) end
            ns.frames[unit] = nil
        end
    end

    for i, frame in pairs(ns.testFrames) do
        if frame then frame:Hide(); frame:SetParent(nil) end
        ns.testFrames[i] = nil
    end
end

-- Refresh all frames
function ns:RefreshAll()
    if InCombatLockdown() then
        ns.pendingRefresh = true
        return
    end

    self:DestroyFrames()

    if ns.testModeActive then
        self:CreateTestFrames()
    else
        self:CreatePartyFrames()
    end
    self:UpdateContainer()
end

-- Toggle test mode
function ns:ToggleTestMode(enable)
    if enable ~= nil then
        ns.testModeActive = enable
    else
        ns.testModeActive = not ns.testModeActive
    end

    if ns.db then ns.db.testMode = ns.testModeActive end

    if ns.testModeActive then
        self:RefreshAll()
        if ns.db and ns.db.testAnimateHealth and ns.StartHealthAnimation then
            ns:StartHealthAnimation()
        end
    else
        if ns.StopHealthAnimation then ns:StopHealthAnimation() end
        self:RefreshAll()
    end

    local L = ns.L
    print("TomoPartyFrame: " .. (ns.testModeActive and L.MSG_TEST_ENABLED or L.MSG_TEST_DISABLED))
end

-- Toggle options
function ns:ToggleOptions()
    if InCombatLockdown() then
        ns.pendingOptionsOpen = true
        print("TomoPartyFrame: " .. ns.L.MSG_COMBAT_DEFER)
        return
    end

    if ns.CreateOptionsWindow then
        local frame = ns:CreateOptionsWindow()
        if frame:IsShown() then
            frame:Hide()
        else
            if frame.RefreshContent then frame:RefreshContent() end
            frame:Show()
        end
    end
end

-- Layout party frames
function ns:LayoutFrames()
    if not ns.db or not ns.container then return end
    if InCombatLockdown() then
        ns.pendingRefresh = true
        return
    end

    local cfg = ns.db
    local growDir = cfg.growDirection or "DOWN"
    local maxColumns = cfg.maxColumns or 5
    local columnSpacing = cfg.columnSpacing or 4
    local units = ns:GetSortedUnits()

    local index = 0
    for _, unit in ipairs(units) do
        local frame = ns.frames[unit]
        if frame and UnitExists(unit) then
            frame:ClearAllPoints()

            local row = floor(index / maxColumns)
            local col = index % maxColumns
            local offsetX, offsetY = 0, 0
            local anchorPoint = "TOPLEFT"

            if growDir == "DOWN" then
                offsetX = row * (cfg.frameWidth + columnSpacing)
                offsetY = -col * (cfg.frameHeight + cfg.frameSpacing)
            elseif growDir == "UP" then
                offsetX = row * (cfg.frameWidth + columnSpacing)
                offsetY = col * (cfg.frameHeight + cfg.frameSpacing)
                anchorPoint = "BOTTOMLEFT"
            elseif growDir == "RIGHT" then
                offsetX = col * (cfg.frameWidth + cfg.frameSpacing)
                offsetY = -row * (cfg.frameHeight + columnSpacing)
            elseif growDir == "LEFT" then
                offsetX = -col * (cfg.frameWidth + cfg.frameSpacing)
                offsetY = -row * (cfg.frameHeight + columnSpacing)
                anchorPoint = "TOPRIGHT"
            end

            frame:SetPoint(anchorPoint, ns.container, anchorPoint, offsetX, offsetY)
            frame:Show()
            index = index + 1
        elseif frame then
            frame:Hide()
        end
    end

    -- Hide frames for units no longer in group
    for unit, frame in pairs(ns.frames) do
        local found = false
        for _, u in ipairs(units) do
            if u == unit then found = true; break end
        end
        if not found then frame:Hide() end
    end

    ns:UpdateContainer()
end

-- Layout test frames
function ns:LayoutTestFrames()
    if not ns.db or not ns.container then return end

    local cfg = ns.db
    local count = cfg.testFrameCount or 5
    local growDir = cfg.growDirection or "DOWN"
    local maxColumns = cfg.maxColumns or 5
    local columnSpacing = cfg.columnSpacing or 4

    for i = 1, count do
        local frame = ns.testFrames[i]
        if frame then
            frame:SetParent(ns.container)
            frame:ClearAllPoints()

            local col = (i - 1) % maxColumns
            local row = floor((i - 1) / maxColumns)
            local offsetX, offsetY = 0, 0
            local anchorPoint = "TOPLEFT"

            if growDir == "DOWN" then
                offsetX = row * (cfg.frameWidth + columnSpacing)
                offsetY = -col * (cfg.frameHeight + cfg.frameSpacing)
            elseif growDir == "UP" then
                offsetX = row * (cfg.frameWidth + columnSpacing)
                offsetY = col * (cfg.frameHeight + cfg.frameSpacing)
                anchorPoint = "BOTTOMLEFT"
            elseif growDir == "RIGHT" then
                offsetX = col * (cfg.frameWidth + cfg.frameSpacing)
                offsetY = -row * (cfg.frameHeight + columnSpacing)
            elseif growDir == "LEFT" then
                offsetX = -col * (cfg.frameWidth + cfg.frameSpacing)
                offsetY = -row * (cfg.frameHeight + columnSpacing)
                anchorPoint = "TOPRIGHT"
            end

            frame:SetPoint(anchorPoint, ns.container, anchorPoint, offsetX, offsetY)
            frame:Show()

            if ns.UpdateTestFrame then ns:UpdateTestFrame(frame) end
        end
    end

    ns:UpdateContainer()
end

-- Event handler
eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        ns:Initialize()
    elseif event == "GROUP_ROSTER_UPDATE" then
        if not ns.testModeActive then
            ns:RefreshAll()
        end
        ns:UpdateContainerVisibility()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if ns.pendingRefresh then
            ns.pendingRefresh = false
            ns:RefreshAll()
        end
        if ns.pendingOptionsOpen then
            ns.pendingOptionsOpen = false
            ns:ToggleOptions()
        end
    elseif event == "UNIT_HEALTH" or event == "UNIT_POWER_UPDATE" or event == "UNIT_AURA"
        or event == "UNIT_HEAL_PREDICTION" or event == "UNIT_ABSORB_AMOUNT_CHANGED"
        or event == "UNIT_HEAL_ABSORB_AMOUNT_CHANGED" or event == "INCOMING_RESURRECT_CHANGED" then
        local unit = ...
        if ns.UpdateUnitFrame and ns.frames[unit] then
            ns:UpdateUnitFrame(ns.frames[unit], unit)
        end
    elseif event == "RAID_TARGET_UPDATE" or event == "PARTY_LEADER_CHANGED"
        or event == "READY_CHECK" or event == "READY_CHECK_CONFIRM"
        or event == "PLAYER_TARGET_CHANGED" then
        if not ns.testModeActive and ns.UpdateUnitFrame then
            for unit, frame in pairs(ns.frames) do
                ns:UpdateUnitFrame(frame, unit)
            end
        end
        -- Re-hide Blizzard highlights
        if event == "PLAYER_TARGET_CHANGED" and ns.blizzardFramesHidden then
            C_Timer.After(0.01, function()
                if not ns.blizzardFramesHidden then return end
                for i = 1, 5 do
                    local f = _G["CompactPartyFrameMember" .. i]
                    if f and not f:IsForbidden() then
                        pcall(function()
                            if f.selectionHighlight then f.selectionHighlight:SetAlpha(0) end
                        end)
                    end
                end
            end)
        end
    elseif event == "READY_CHECK_FINISHED" then
        C_Timer.After(3, function()
            if not ns.testModeActive and ns.UpdateUnitFrame then
                for unit, frame in pairs(ns.frames) do
                    ns:UpdateUnitFrame(frame, unit)
                end
            end
        end)
    elseif event == "UI_SCALE_CHANGED" or event == "DISPLAY_SIZE_CHANGED" then
        ns:InvalidatePixelScaleCache()
    end
end)

-- Register events
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("UNIT_HEALTH")
eventFrame:RegisterEvent("UNIT_POWER_UPDATE")
eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:RegisterEvent("UNIT_HEAL_PREDICTION")
eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
eventFrame:RegisterEvent("UNIT_HEAL_ABSORB_AMOUNT_CHANGED")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("UI_SCALE_CHANGED")
eventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")
eventFrame:RegisterEvent("INCOMING_RESURRECT_CHANGED")
eventFrame:RegisterEvent("READY_CHECK")
eventFrame:RegisterEvent("READY_CHECK_CONFIRM")
eventFrame:RegisterEvent("READY_CHECK_FINISHED")
eventFrame:RegisterEvent("RAID_TARGET_UPDATE")
eventFrame:RegisterEvent("PARTY_LEADER_CHANGED")

-- Range check ticker
local rangeCheckTicker = nil

local function UpdateRangeForAllFrames()
    if ns.testModeActive or not ns.db or not ns.db.enableRangeFade then return end

    local fadeAlpha = ns.db.rangeFadeAlpha or 0.4

    for unit, frame in pairs(ns.frames) do
        if frame and frame:IsShown() then
            if unit == "player" then
                frame:SetAlpha(1.0)
            elseif UnitExists(unit) then
                local inRange = UnitInRange(unit)
                if inRange == nil then
                    frame:SetAlpha(1.0)
                else
                    frame:SetAlphaFromBoolean(inRange, 1.0, fadeAlpha)
                end
            else
                frame:SetAlpha(1.0)
            end
        end
    end
end

C_Timer.After(2, function()
    if not rangeCheckTicker then
        rangeCheckTicker = C_Timer.NewTicker(0.2, UpdateRangeForAllFrames)
    end
end)

-- Slash commands
SLASH_TOMOPARTYFRAME1 = "/tpf"
SLASH_TOMOPARTYFRAME2 = "/tomopartyframe"
SlashCmdList["TOMOPARTYFRAME"] = function(msg)
    local args = {}
    for word in msg:gmatch("%S+") do
        args[#args + 1] = word:lower()
    end
    local cmd = args[1] or ""

    if cmd == "unlock" then
        ns:ToggleDragMode(true)
    elseif cmd == "lock" then
        ns:ToggleDragMode(false)
    elseif cmd == "test" then
        ns:ToggleTestMode()
    elseif cmd == "refresh" then
        ns:RefreshAll()
        print("TomoPartyFrame: " .. ns.L.MSG_REFRESHED)
    elseif cmd == "" or cmd == "options" or cmd == "config" then
        ns:ToggleOptions()
    else
        local L = ns.L
        print("|cffd1b559TomoPartyFrame|r " .. L.CMD_HELP)
        print("  /tpf - " .. L.CMD_OPTIONS)
        print("  /tpf test - " .. L.CMD_TEST)
        print("  /tpf unlock - " .. L.CMD_UNLOCK)
        print("  /tpf lock - " .. L.CMD_LOCK)
        print("  /tpf refresh - " .. L.CMD_REFRESH)
    end
end
