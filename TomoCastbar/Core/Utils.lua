-- =====================================
-- Utils.lua — Utility Functions for TomoCastbar
-- =====================================

TomoCastbar_Utils = TomoCastbar_Utils or {}
local U = TomoCastbar_Utils

-- =====================================
-- TABLE UTILITIES
-- =====================================

function TomoCastbar_MergeTables(dest, src)
    for k, v in pairs(src) do
        if type(v) == "table" then
            if type(dest[k]) ~= "table" then
                dest[k] = {}
            end
            TomoCastbar_MergeTables(dest[k], v)
        elseif dest[k] == nil then
            dest[k] = v
        end
    end
end

function U.DeepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in pairs(orig) do
        copy[U.DeepCopy(k)] = U.DeepCopy(v)
    end
    return setmetatable(copy, getmetatable(orig))
end

-- =====================================
-- COLOR UTILITIES
-- =====================================

function U.GetClassColor(unit)
    unit = unit or "player"
    local _, class = UnitClass(unit)
    if class and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        return c.r, c.g, c.b, 1
    end
    return 0.5, 0.5, 0.5, 1
end

function U.HexColor(r, g, b)
    return string.format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function U.ColorText(text, r, g, b)
    return string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text)
end

function U.ClassColorText(text, unit)
    local r, g, b = U.GetClassColor(unit or "player")
    return U.ColorText(text, r, g, b)
end

-- =====================================
-- FRAME POSITION UTILITIES
-- =====================================

function U.SaveFramePosition(frame, dbTable)
    if not frame or not dbTable then return end
    local point, _, relativePoint, x, y = frame:GetPoint()
    dbTable.point = point or "CENTER"
    dbTable.relativePoint = relativePoint or "CENTER"
    dbTable.x = x or 0
    dbTable.y = y or 0
end

function U.ApplyFramePosition(frame, dbTable)
    if not frame or not dbTable then return end
    frame:ClearAllPoints()
    frame:SetPoint(
        dbTable.point or "CENTER",
        UIParent,
        dbTable.relativePoint or "CENTER",
        dbTable.x or 0,
        dbTable.y or 0
    )
end

function U.ResetFramePosition(frame, defaultPoint, defaultRelativePoint, defaultX, defaultY)
    if not frame then return end
    frame:ClearAllPoints()
    frame:SetPoint(
        defaultPoint or "CENTER",
        UIParent,
        defaultRelativePoint or "CENTER",
        defaultX or 0,
        defaultY or 0
    )
end

-- =====================================
-- LOCK/UNLOCK DRAG SYSTEM
-- =====================================

function U.SetupDraggable(frame, savePositionCallback)
    if not frame then return end
    frame.isLocked = true
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)

    local dragFrame = CreateFrame("Frame", nil, frame)
    dragFrame:SetAllPoints(frame)
    dragFrame:SetFrameLevel(frame:GetFrameLevel() + 20)
    dragFrame:EnableMouse(false)
    dragFrame:Hide()

    local dragOverlay = dragFrame:CreateTexture(nil, "OVERLAY")
    dragOverlay:SetAllPoints(dragFrame)
    dragOverlay:SetColorTexture(1, 1, 0, 0.1)
    frame.dragOverlay = dragOverlay

    local dragLabel = dragFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dragLabel:SetPoint("CENTER", dragFrame, "CENTER")
    dragLabel:SetTextColor(1, 1, 0)
    dragLabel:SetText(TomoCastbar_L and TomoCastbar_L["MOVE_LABEL"] or "(Move)")
    frame.dragLabel = dragLabel

    dragFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)

    dragFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
            if savePositionCallback then
                savePositionCallback()
            end
        end
    end)

    frame.dragFrame = dragFrame

    frame.SetLocked = function(self, locked)
        self.isLocked = locked
        if locked then
            dragFrame:EnableMouse(false)
            dragFrame:Hide()
        else
            dragFrame:EnableMouse(true)
            dragFrame:Show()
            self:SetAlpha(1)
            self:Show()
        end
    end

    frame.IsLocked = function(self)
        return self.isLocked
    end

    frame:SetLocked(true)
    return frame
end

-- =====================================
-- DEBUG
-- =====================================

function U.Debug(...)
    if TomoCastbarDB and TomoCastbarDB.debug then
        print("|cff00ff00[TomoCastbar Debug]|r", ...)
    end
end
