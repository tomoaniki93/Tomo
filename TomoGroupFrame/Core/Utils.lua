-- =====================================
-- Core/Utils.lua — Utility Functions
-- =====================================

TGF_Utils = {}

-- =====================================
-- DEEP TABLE OPERATIONS
-- =====================================

function TGF_Utils.DeepCopy(src)
    if type(src) ~= "table" then return src end
    local copy = {}
    for k, v in pairs(src) do copy[k] = TGF_Utils.DeepCopy(v) end
    return copy
end

--- Merge src into dst (dst wins for existing keys)
function TGF_MergeTables(dst, src)
    for k, v in pairs(src) do
        if dst[k] == nil then
            if type(v) == "table" then
                dst[k] = TGF_Utils.DeepCopy(v)
            else
                dst[k] = v
            end
        elseif type(v) == "table" and type(dst[k]) == "table" then
            TGF_MergeTables(dst[k], v)
        end
    end
end

-- =====================================
-- CLASS COLORS
-- =====================================

function TGF_Utils.GetClassColor(unit)
    unit = unit or "player"
    local _, class = UnitClass(unit)
    if class and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        return c.r, c.g, c.b
    end
    return 0.8, 0.27, 1.0  -- Tomo purple fallback
end

function TGF_Utils.ColorText(text, r, g, b)
    return string.format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, text)
end

-- =====================================
-- NAME TRUNCATION
-- =====================================

function TGF_Utils.TruncateName(name, maxLen)
    if not name then return "" end
    maxLen = maxLen or 12
    if #name > maxLen then
        return name:sub(1, maxLen) .. ".."
    end
    return name
end

-- =====================================
-- HEALTH FORMAT
-- =====================================

-- =====================================
-- HEALTH FORMAT
-- NOTE: For real unit health, use SetFormattedText + UnitHealthPercent (C-side).
-- These helpers are only for non-tainted contexts (test mode, config preview).
-- =====================================

function TGF_Utils.FormatPercent(current, max)
    if not max or max == 0 then return "0%" end
    if not current then return "0%" end
    return string.format("%d%%", (current / max) * 100)
end

function TGF_Utils.FormatShort(value)
    if not value then return "0" end
    if value >= 1e6 then
        return string.format("%.1fM", value / 1e6)
    elseif value >= 1e3 then
        return string.format("%.0fK", value / 1e3)
    end
    return tostring(value)
end

-- =====================================
-- POWER COLORS
-- =====================================

local POWER_COLORS = {
    [0]  = { 0.00, 0.00, 1.00 },  -- Mana
    [1]  = { 1.00, 0.00, 0.00 },  -- Rage
    [2]  = { 1.00, 0.50, 0.25 },  -- Focus
    [3]  = { 1.00, 1.00, 0.00 },  -- Energy
    [4]  = { 0.00, 0.82, 1.00 },  -- Combo Points
    [5]  = { 0.50, 0.50, 0.50 },  -- Runes
    [6]  = { 0.00, 0.82, 1.00 },  -- Runic Power
    [7]  = { 0.80, 0.20, 1.00 },  -- Soul Shards
    [8]  = { 0.00, 0.80, 0.80 },  -- Lunar Power
    [9]  = { 0.72, 0.51, 0.25 },  -- Holy Power
    [11] = { 0.00, 0.50, 1.00 },  -- Maelstrom
    [12] = { 0.30, 0.50, 0.90 },  -- Chi
    [13] = { 0.64, 0.23, 0.93 },  -- Insanity
    [17] = { 0.90, 0.20, 0.20 },  -- Fury
    [18] = { 0.80, 0.70, 0.50 },  -- Pain
    [19] = { 0.40, 0.80, 0.40 },  -- Essence
}

function TGF_Utils.GetPowerColor(powerType)
    local c = POWER_COLORS[powerType]
    if c then return c[1], c[2], c[3] end
    return 0.5, 0.5, 0.5
end

-- =====================================
-- INSTANCE CHECK
-- =====================================

function TGF_Utils.GetInstanceInfo()
    local name, instanceType, difficultyID, difficultyName,
          maxPlayers, dynamicDifficulty, isDynamic, instanceID,
          instanceGroupSize, LfgDungeonID = GetInstanceInfo()
    return {
        name = name,
        type = instanceType,   -- "none", "pvp", "arena", "party", "raid", "scenario"
        difficultyID = difficultyID,
        maxPlayers = maxPlayers,
        instanceID = instanceID,
    }
end

function TGF_Utils.IsInDungeon()
    local info = TGF_Utils.GetInstanceInfo()
    return info.type == "party"
end

function TGF_Utils.IsInRaid()
    local info = TGF_Utils.GetInstanceInfo()
    return info.type == "raid"
end

function TGF_Utils.IsInPvP()
    local info = TGF_Utils.GetInstanceInfo()
    return info.type == "pvp" or info.type == "arena"
end

-- =====================================
-- DISPEL TYPE COLORS (matches image reference)
-- =====================================

TGF_Utils.DISPEL_COLORS = {
    Magic   = { 0.20, 0.60, 1.00 },  -- Blue
    Curse   = { 0.60, 0.00, 1.00 },  -- Purple
    Disease = { 0.60, 0.40, 0.00 },  -- Brown/Orange
    Poison  = { 0.00, 0.60, 0.00 },  -- Green
}

-- =====================================
-- ROLE ICON ATLAS
-- =====================================

TGF_Utils.ROLE_ICONS = {
    TANK    = "groupfinder-icon-role-large-tank",
    HEALER  = "groupfinder-icon-role-large-heal",
    DAMAGER = "groupfinder-icon-role-large-dps",
}
