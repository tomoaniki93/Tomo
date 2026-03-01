-- =====================================
-- Utils.lua — Utility Functions
-- TomoFrames v1.0.0
-- =====================================

TomoFrames_Utils = TomoFrames_Utils or {}
local U = TomoFrames_Utils

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

function U.GetPowerColor(powerType)
    local info = PowerBarColor[powerType]
    if info then return info.r, info.g, info.b end
    return 0.5, 0.5, 0.5
end

function U.GetReactionColor(unit)
    local reaction = UnitReaction(unit, "player")
    if not reaction then return 0.5, 0.5, 0.5 end
    if reaction >= 5 then return 0.11, 0.82, 0.11 end
    if reaction == 4 then return 0.98, 0.82, 0.11 end
    return 0.78, 0.04, 0.04
end

-- =====================================
-- FRAME DRAGGING
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
    dragOverlay:SetColorTexture(1, 0.62, 0.04, 0.12)  -- amber tint
    frame.dragOverlay = dragOverlay

    local dragLabel = dragFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dragLabel:SetPoint("CENTER", dragFrame, "CENTER")
    dragLabel:SetTextColor(1, 0.62, 0.04)
    dragLabel:SetText("(Déplacer)")
    frame.dragLabel = dragLabel

    dragFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then frame:StartMoving() end
    end)
    dragFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
            if savePositionCallback then savePositionCallback() end
        end
    end)

    frame.dragFrame = dragFrame

    frame.SetLocked = function(self, locked)
        self.isLocked = locked
        if locked then
            dragFrame:EnableMouse(false); dragFrame:Hide()
        else
            dragFrame:EnableMouse(true); dragFrame:Show()
            self:SetAlpha(1); self:Show()
        end
    end
    frame.IsLocked = function(self) return self.isLocked end
    frame:SetLocked(true)
    return frame
end
