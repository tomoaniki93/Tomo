-- TomoMythic / Core.lua
-- Addon table, color palette, utilities, slash commands.

local ADDON_NAME, TM = ...

-- ── TomoMod skin detection ────────────────────────────────────────────────────
-- If TomoMod is loaded, we re-use its color identity so the two addons look
-- visually consistent. All values fall back to TomoMythic's own palette when
-- TomoMod is absent.

local function HasTomoMod()
    return C_AddOns.IsAddOnLoaded("TomoMod")
end
TM.HasTomoMod = HasTomoMod

-- ── Color palette (mirrors TomoMod's objective-tracker skin exactly) ──────────
TM.C = {
    -- Panel backgrounds (same values as TomoMod OT skin)
    BG          = { 0.00, 0.00, 0.00, 0.80 },   -- main dark bg
    BG_HEADER   = { 0.04, 0.08, 0.16, 1.00 },   -- header bar (deep midnight blue)
    BG_ROW_ALT  = { 0.05, 0.09, 0.16, 0.50 },   -- alternating boss rows

    -- Accent / borders
    ACCENT      = { 0.33, 0.70, 0.00, 1.00 },   -- apple green accent strip
    BORDER      = { 0.25, 0.25, 0.30, 0.70 },   -- subtle border (TomoMod OT)
    BORDER_BLUE = { 0.15, 0.32, 0.60, 0.90 },   -- blue border highlight
    SEP         = { 0.18, 0.38, 0.18, 0.80 },   -- green separator line

    -- Bar fills
    BAR_GREEN   = { 0.33, 0.70, 0.00, 0.90 },   -- timer / forces full
    BAR_YELLOW  = { 0.95, 0.78, 0.00, 0.90 },
    BAR_RED     = { 0.85, 0.15, 0.10, 0.90 },
    BAR_BLUE    = { 0.15, 0.38, 0.72, 0.85 },   -- forces bar
    BAR_TEAL    = { 0.10, 0.68, 0.72, 0.85 },
    BAR_TRACK   = { 0.04, 0.08, 0.14, 1.00 },   -- empty bar background

    -- Text
    TEXT_WHITE  = { 1.00, 1.00, 1.00, 1.00 },
    TEXT_GREY   = { 0.55, 0.55, 0.55, 1.00 },
    TEXT_GREEN  = { 0.55, 0.90, 0.20, 1.00 },
    TEXT_YELLOW = { 1.00, 0.82, 0.10, 1.00 },
    TEXT_RED    = { 1.00, 0.30, 0.20, 1.00 },
    TEXT_TEAL   = { 0.30, 0.85, 0.90, 1.00 },
    TEXT_SKULL  = { 1.00, 0.35, 0.30, 1.00 },
    TEXT_BLUE   = { 0.50, 0.72, 1.00, 1.00 },
}

-- ── Layout constants ──────────────────────────────────────────────────────────
TM.W           = 260    -- frame width
TM.HEADER_H    = 38     -- key info header
TM.BAR_H       = 20     -- timer / forces bar height
TM.BOSS_H      = 18     -- boss row height
TM.GAP         = 2      -- spacing between sections
TM.EDGE        = 1      -- border edge px
TM.UPDATE_RATE = 0.25   -- ticker interval

-- ── Font resolution ───────────────────────────────────────────────────────────
-- Uses TomoMod's registered font if present, else WoW default.
function TM:GetFont(size, flags)
    -- TomoMod registers "FRIZQT__" and a custom font via LSM.
    -- We just use the standard WoW font — same family TomoMod falls back to.
    return "Fonts\\FRIZQT__.TTF", size or 12, flags or "OUTLINE"
end

-- ── Utility ───────────────────────────────────────────────────────────────────
function TM:FormatTime(sec, doCeil)
    if not sec then return "--:--" end
    if doCeil then sec = math.ceil(sec) else sec = math.floor(sec) end
    local h = math.floor(sec / 3600)
    local m = math.floor((sec % 3600) / 60)
    local s = sec % 60
    if h > 0 then return string.format("%d:%02d:%02d", h, m, s)
    else          return string.format("%d:%02d", m, s) end
end

function TM:FormatDelta(diff)
    local sign = diff >= 0 and "+" or "-"
    return sign .. self:FormatTime(math.abs(diff))
end

-- ── Frame helpers (shared with TomoMod OT skin logic) ─────────────────────────
function TM:MakeBG(parent, r, g, b, a)
    local t = parent:CreateTexture(nil, "BACKGROUND")
    t:SetAllPoints(parent)
    t:SetColorTexture(r, g, b, a)
    return t
end

function TM:MakeBorder(parent, r, g, b, a, size)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    f:SetAllPoints(parent)
    f:SetBackdrop({ edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = size or TM.EDGE })
    f:SetBackdropBorderColor(r, g, b, a or 1)
    return f
end

-- 4-side manual borders (no backdrop — works at any frame level)
function TM:MakeLineBorders(parent, r, g, b, a, size)
    size = size or 1
    local c = { r, g, b, a or 1 }
    local sides = {}
    for _, info in ipairs({
        { "TOPLEFT",    "TOPRIGHT",    "h", size },
        { "BOTTOMLEFT", "BOTTOMRIGHT", "h", size },
        { "TOPLEFT",    "BOTTOMLEFT",  "v", size },
        { "TOPRIGHT",   "BOTTOMRIGHT", "v", size },
    }) do
        local t = parent:CreateTexture(nil, "BORDER")
        t:SetColorTexture(unpack(c))
        t:SetPoint(info[1], parent, info[1])
        t:SetPoint(info[2], parent, info[2])
        if info[3] == "h" then t:SetHeight(info[4])
        else                    t:SetWidth(info[4]) end
        sides[#sides + 1] = t
    end
    return sides
end

function TM:MakeFS(parent, size, flags, anchor, relTo, x, y)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    fs:SetFont(self:GetFont(size, flags))
    fs:SetShadowColor(0, 0, 0, 0.9)
    fs:SetShadowOffset(1, -1)
    if anchor then
        fs:SetPoint(anchor, relTo or parent, anchor, x or 0, y or 0)
    end
    return fs
end

-- ── Slash commands ─────────────────────────────────────────────────────────────
SLASH_TOMOMYTHIC1 = "/tmt"
SlashCmdList["TOMOMYTHIC"] = function(msg)
    msg = strtrim(msg or ""):lower()
    local L = TM.L
    if     msg == ""        then TM:ToggleConfig()
    elseif msg:find("^interrupt") then
        local sub = msg:match("^interrupt%s*(.*)$") or ""
        TM:InterruptCommand(sub)
    elseif msg == "unlock"  then TM:SetMovable(true);  print(L.UNLOCK_MSG)
    elseif msg == "lock"    then TM:SetMovable(false); print(L.LOCK_MSG)
    elseif msg == "reset"   then TM:ResetPosition();   print(L.RESET_MSG)
    elseif msg == "preview" then TM:Preview()
    elseif msg == "help"    then print(L.CMD_USAGE)
    else print(L.UNKNOWN_CMD); print(L.CMD_USAGE)
    end
end

function TM:SetMovable(enable)
    if not self.Frame then return end
    self.db.locked = not enable
    local F = self.Frame
    F:SetMovable(enable)
    F:EnableMouse(enable)
    if enable then
        F:RegisterForDrag("LeftButton")
        -- Gold border = unlocked (same visual cue as TomoMod OT skin unlock)
        if F._bdrFrame then
            F._bdrFrame:SetBackdropBorderColor(0.9, 0.75, 0.1, 1)
        end
    else
        if F._bdrFrame then
            local c = self.C.BORDER
            F._bdrFrame:SetBackdropBorderColor(unpack(c))
        end
    end
end

function TM:ResetPosition()
    local def = self.Defaults.position
    self:SetPos(def.anchor, def.relTo, def.x, def.y)
    if self.Frame then
        self.Frame:ClearAllPoints()
        self.Frame:SetPoint(def.anchor, UIParent, def.relTo, def.x, def.y)
    end
end
