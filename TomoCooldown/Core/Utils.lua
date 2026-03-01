-- =====================================
-- Utils.lua — Utility Functions
-- TomoCooldown v1.0.0
-- =====================================

TomoCooldown_Utils = TomoCooldown_Utils or {}
local U = TomoCooldown_Utils

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
    dragOverlay:SetColorTexture(0.024, 0.714, 0.831, 0.12)  -- cyan tint
    frame.dragOverlay = dragOverlay

    local dragLabel = dragFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dragLabel:SetPoint("CENTER", dragFrame, "CENTER")
    dragLabel:SetTextColor(0.024, 0.714, 0.831)
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
