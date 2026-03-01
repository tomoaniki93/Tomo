-- =====================================
-- Utils.lua — Utility Functions
-- TomoSkins v1.0.0
-- =====================================

TomoSkins_Utils = TomoSkins_Utils or {}
local U = TomoSkins_Utils

function U.GetClassColor(unit)
    unit = unit or "player"
    local _, class = UnitClass(unit)
    if class and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        return c.r, c.g, c.b, 1
    end
    return 0.5, 0.5, 0.5, 1
end

function U.ColorText(text, r, g, b)
    return string.format("|cff%02x%02x%02x%s|r", r*255, g*255, b*255, text)
end

function U.AbbreviateNumber(num)
    if not num then return "0" end
    if num >= 1000000 then return string.format("%.1fM", num/1000000)
    elseif num >= 1000 then return string.format("%.1fK", num/1000)
    else return tostring(math.floor(num)) end
end
