-- =====================================
-- Modules/DispelTracker.lua
-- Tracks dispellable debuffs on group members
-- Shows colored border overlay (Magic=Blue, Curse=Purple, Disease=Brown, Poison=Green)
-- =====================================

TGF_DispelTracker = {}
local DT = TGF_DispelTracker

-- Dispel type priorities (higher = shown first)
local DISPEL_PRIORITY = {
    Magic   = 4,
    Curse   = 3,
    Disease = 2,
    Poison  = 1,
}

-- Which classes can dispel what
local CLASS_DISPELS = {
    PRIEST    = { Magic = true, Disease = true },
    PALADIN   = { Magic = true, Disease = true, Poison = true },
    SHAMAN    = { Magic = true, Curse = true, Poison = true },
    DRUID     = { Magic = true, Curse = true, Poison = true },
    MAGE      = { Curse = true },
    MONK      = { Magic = true, Disease = true, Poison = true },
    WARLOCK   = { Magic = true },
    EVOKER    = { Magic = true, Poison = true },
}

-- Cache what the player can dispel
local playerDispels = {}

function DT.UpdatePlayerDispels()
    wipe(playerDispels)
    local _, class = UnitClass("player")
    local dispels = CLASS_DISPELS[class]
    if dispels then
        for dtype, _ in pairs(dispels) do
            playerDispels[dtype] = true
        end
    end
end

--- Scan a unit for dispellable debuffs and return the highest-priority type
--- @param unit string
--- @return string|nil dispelType "Magic", "Curse", "Disease", "Poison" or nil
function DT.GetHighestDispel(unit)
    if not UnitExists(unit) then return nil end

    local bestType = nil
    local bestPriority = 0

    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not auraData then break end

        local dispelName = auraData.dispelName
        if dispelName and playerDispels[dispelName] then
            local prio = DISPEL_PRIORITY[dispelName] or 0
            if prio > bestPriority then
                bestPriority = prio
                bestType = dispelName
            end
        end
    end

    return bestType
end

--- Get all dispellable types present on a unit (for multi-border display)
--- @param unit string
--- @return table types { ["Magic"] = true, ["Curse"] = true, ... }
function DT.GetAllDispels(unit)
    local types = {}
    if not UnitExists(unit) then return types end

    for i = 1, 40 do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not auraData then break end

        local dispelName = auraData.dispelName
        if dispelName and playerDispels[dispelName] then
            types[dispelName] = true
        end
    end

    return types
end

--- Create border overlays on a frame for dispel display
--- @param parent Frame The unit button frame
--- @param borderSize number Thickness of border
--- @return table overlay { top, bottom, left, right textures + Update method }
function DT.CreateDispelOverlay(parent, borderSize)
    borderSize = borderSize or 2

    local overlay = CreateFrame("Frame", nil, parent)
    overlay:SetAllPoints()
    overlay:SetFrameLevel(parent:GetFrameLevel() + 5)

    -- Create 4 edge textures
    overlay.top = overlay:CreateTexture(nil, "OVERLAY")
    overlay.top:SetPoint("TOPLEFT")
    overlay.top:SetPoint("TOPRIGHT")
    overlay.top:SetHeight(borderSize)
    overlay.top:SetColorTexture(1, 1, 1, 1)

    overlay.bottom = overlay:CreateTexture(nil, "OVERLAY")
    overlay.bottom:SetPoint("BOTTOMLEFT")
    overlay.bottom:SetPoint("BOTTOMRIGHT")
    overlay.bottom:SetHeight(borderSize)
    overlay.bottom:SetColorTexture(1, 1, 1, 1)

    overlay.left = overlay:CreateTexture(nil, "OVERLAY")
    overlay.left:SetPoint("TOPLEFT")
    overlay.left:SetPoint("BOTTOMLEFT")
    overlay.left:SetWidth(borderSize)
    overlay.left:SetColorTexture(1, 1, 1, 1)

    overlay.right = overlay:CreateTexture(nil, "OVERLAY")
    overlay.right:SetPoint("TOPRIGHT")
    overlay.right:SetPoint("BOTTOMRIGHT")
    overlay.right:SetWidth(borderSize)
    overlay.right:SetColorTexture(1, 1, 1, 1)

    -- Glow texture (inner glow)
    local ADDON_PATH = "Interface\\AddOns\\TomoGroupFrame\\"
    overlay.glow = overlay:CreateTexture(nil, "OVERLAY", nil, -1)
    overlay.glow:SetAllPoints()
    overlay.glow:SetTexture(ADDON_PATH .. "Assets\\Textures\\DispelGlow.tga")
    overlay.glow:SetAlpha(0.35)
    overlay.glow:SetBlendMode("ADD")

    overlay:Hide()

    function overlay:SetDispelColor(r, g, b)
        self.top:SetColorTexture(r, g, b, 1)
        self.bottom:SetColorTexture(r, g, b, 1)
        self.left:SetColorTexture(r, g, b, 1)
        self.right:SetColorTexture(r, g, b, 1)
        self.glow:SetVertexColor(r, g, b, 0.35)
    end

    function overlay:SetBorderSize(size)
        self.top:SetHeight(size)
        self.bottom:SetHeight(size)
        self.left:SetWidth(size)
        self.right:SetWidth(size)
    end

    --- Update dispel overlay for a unit
    function overlay:UpdateForUnit(unit, settings)
        if not settings or not settings.showDispel then
            self:Hide()
            return
        end

        local dispelType = DT.GetHighestDispel(unit)
        if dispelType then
            local colors = settings.dispelColors and settings.dispelColors[dispelType]
            if colors then
                self:SetDispelColor(colors.r, colors.g, colors.b)
            else
                local c = TGF_Utils.DISPEL_COLORS[dispelType]
                if c then
                    self:SetDispelColor(c[1], c[2], c[3])
                end
            end
            self:SetBorderSize(settings.dispelBorderSize or 2)
            self:Show()
        else
            self:Hide()
        end
    end

    return overlay
end
