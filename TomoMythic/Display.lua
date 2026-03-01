-- TomoMythic / Display.lua

local _, TM = ...

-- ─────────────────────────────────────────────────────────────────────────────
--  BUILD FRAME
-- ─────────────────────────────────────────────────────────────────────────────
function TM:BuildFrame()
    if self.Frame then return end

    local C = self.C
    local W = self.W
    local F = CreateFrame("Frame", "TomoMythicFrame", UIParent)
    self.Frame = F

    F:SetSize(W, 300)   -- resized dynamically
    F:SetFrameStrata("MEDIUM")
    F:SetFrameLevel(50)
    F:SetClampedToScreen(true)
    F:Hide()

    -- ── Outer panel ──────────────────────────────────────────────────────────
    F._bg = self:MakeBG(F, 0, 0, 0, 0.82)

    -- Left green accent strip (3px, TomoMod OT style)
    F._accent = F:CreateTexture(nil, "ARTWORK")
    F._accent:SetWidth(3)
    F._accent:SetPoint("TOPLEFT",    F, "TOPLEFT",    0, 0)
    F._accent:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 0, 0)
    F._accent:SetColorTexture(unpack(C.ACCENT))

    -- 1px border lines
    self:MakeLineBorders(F, unpack(C.BORDER))

    -- Backdrop border used for unlock gold highlight
    F._bdrFrame = self:MakeBorder(F, unpack(C.BORDER))
    F._bdrFrame:SetFrameLevel(F:GetFrameLevel() + 8)

    -- Drag
    F:SetScript("OnDragStart", function(s) s:StartMoving() end)
    F:SetScript("OnDragStop",  function(s)
        s:StopMovingOrSizing()
        local a, _, ra, x, y = s:GetPoint()
        x = math.floor(x * 10 + 0.5) / 10
        y = math.floor(y * 10 + 0.5) / 10
        TM:SetPos(a, ra, x, y)
    end)

    -- ── HEADER — 2 lines ─────────────────────────────────────────────────────
    -- Line 1 (top):    [Dungeon Name]              [+20]
    -- Line 2 (bottom): [affix1][affix2][affix3]    [skull] 1 (+0:05)
    local HDR = CreateFrame("Frame", nil, F)
    F.Hdr = HDR
    HDR:SetHeight(self.HEADER_H)
    HDR:SetPoint("TOPLEFT",  F, "TOPLEFT",  0, 0)
    HDR:SetPoint("TOPRIGHT", F, "TOPRIGHT", 0, 0)

    HDR._bg = HDR:CreateTexture(nil, "BACKGROUND")
    HDR._bg:SetAllPoints(HDR)
    HDR._bg:SetColorTexture(unpack(C.BG_HEADER))

    -- ── Line 1 ───────────────────────────────────────────────────────────────
    -- Dungeon name (top-left)
    HDR.dungeonName = self:MakeFS(HDR, 13, "OUTLINE")
    HDR.dungeonName:SetPoint("TOPLEFT", HDR, "TOPLEFT", 8, -5)
    HDR.dungeonName:SetWordWrap(false)
    HDR.dungeonName:SetNonSpaceWrap(false)
    HDR.dungeonName:SetTextColor(unpack(C.TEXT_WHITE))

    -- Key level (top-right, large green)
    HDR.keyLevel = self:MakeFS(HDR, 16, "OUTLINE")
    HDR.keyLevel:SetPoint("TOPRIGHT", HDR, "TOPRIGHT", -8, -4)
    HDR.keyLevel:SetTextColor(unpack(C.TEXT_GREEN))

    -- ── Line 2 ───────────────────────────────────────────────────────────────
    -- Deaths (bottom-right): small skull texture + count + time lost
    -- Using a WoW-native icon inline so no broken UTF-8 glyphs
    HDR.deaths = self:MakeFS(HDR, 11, "OUTLINE")
    HDR.deaths:SetPoint("BOTTOMRIGHT", HDR, "BOTTOMRIGHT", -8, 5)
    HDR.deaths:SetTextColor(unpack(C.TEXT_SKULL))

    -- Affix icons (bottom-left, left→right order)
    HDR.affixes = {}
    for i = 1, 4 do
        local ic = HDR:CreateTexture(nil, "OVERLAY")
        ic:SetSize(16, 16)
        ic:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        HDR.affixes[i] = ic
        ic:Hide()
    end

    -- Green separator under header
    F._sep1 = F:CreateTexture(nil, "ARTWORK")
    F._sep1:SetHeight(1)
    F._sep1:SetPoint("TOPLEFT",  HDR, "BOTTOMLEFT",  0, 0)
    F._sep1:SetPoint("TOPRIGHT", HDR, "BOTTOMRIGHT", 0, 0)
    F._sep1:SetColorTexture(unpack(C.ACCENT))

    -- ── TIMER BAR ─────────────────────────────────────────────────────────────
    -- Layout inside bar:  [elapsed]    [±delta]    [/ limit]
    local TB = CreateFrame("StatusBar", nil, F)
    F.TimerBar = TB
    TB:SetHeight(self.BAR_H)
    TB:SetPoint("TOPLEFT",  F._sep1, "BOTTOMLEFT",  0, -self.GAP)
    TB:SetPoint("TOPRIGHT", F._sep1, "BOTTOMRIGHT", 0, -self.GAP)
    TB:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    TB:SetMinMaxValues(0, 1)
    TB:SetValue(0)

    TB._bg = TB:CreateTexture(nil, "BACKGROUND")
    TB._bg:SetAllPoints(TB)
    TB._bg:SetColorTexture(unpack(C.BAR_TRACK))

    -- Elapsed (left, bold-ish 13px)
    TB.elapsed = self:MakeFS(TB, 13, "OUTLINE")
    TB.elapsed:SetPoint("LEFT", TB, "LEFT", 8, 0)
    TB.elapsed:SetTextColor(unpack(C.TEXT_WHITE))

    -- ±Delta from limit (center, 11px)
    TB.delta = self:MakeFS(TB, 11, "OUTLINE")
    TB.delta:SetPoint("CENTER", TB, "CENTER", 0, 0)

    -- Time limit (right, grey, 11px)
    TB.limit = self:MakeFS(TB, 11, "OUTLINE")
    TB.limit:SetPoint("RIGHT", TB, "RIGHT", -8, 0)
    TB.limit:SetTextColor(unpack(C.TEXT_GREY))

    -- Tick marks inside bar only — no floating labels
    TB.ticks = {}
    for i = 1, 2 do
        local tick = TB:CreateTexture(nil, "OVERLAY")
        tick:SetSize(1, self.BAR_H)
        tick:SetColorTexture(1, 1, 1, 0.40)
        tick:Hide()
        TB.ticks[i] = tick
    end

    -- ── CHEST COUNTDOWN ROW — thin row directly below timer bar ──────────────
    -- Shows "+2 Bonus: XX:XX  |  In Time: XX:XX" (or just the relevant one)
    local CR = CreateFrame("Frame", nil, F)
    F.ChestRow = CR
    CR:SetHeight(14)
    CR:SetPoint("TOPLEFT",  TB, "BOTTOMLEFT",  0, -1)
    CR:SetPoint("TOPRIGHT", TB, "BOTTOMRIGHT", 0, -1)

    -- +2 chest time (left)
    CR.chest2 = self:MakeFS(CR, 10, "OUTLINE")
    CR.chest2:SetPoint("LEFT", CR, "LEFT", 8, 0)
    CR.chest2:SetTextColor(unpack(C.TEXT_GREEN))
    CR.chest2:Hide()

    -- In-time chest (right)
    CR.chest1 = self:MakeFS(CR, 10, "OUTLINE")
    CR.chest1:SetPoint("RIGHT", CR, "RIGHT", -8, 0)
    CR.chest1:SetTextColor(unpack(C.TEXT_YELLOW))
    CR.chest1:Hide()

    -- ── SEPARATOR 2 ───────────────────────────────────────────────────────────
    F._sep2 = F:CreateTexture(nil, "ARTWORK")
    F._sep2:SetHeight(1)
    F._sep2:SetPoint("TOPLEFT",  CR, "BOTTOMLEFT",  0, -self.GAP)
    F._sep2:SetPoint("TOPRIGHT", CR, "BOTTOMRIGHT", 0, -self.GAP)
    F._sep2:SetColorTexture(unpack(C.SEP))

    -- ── FORCES BAR ────────────────────────────────────────────────────────────
    local FB = CreateFrame("StatusBar", nil, F)
    F.ForcesBar = FB
    FB:SetHeight(self.BAR_H)
    FB:SetPoint("TOPLEFT",  F._sep2, "BOTTOMLEFT",  0, -self.GAP)
    FB:SetPoint("TOPRIGHT", F._sep2, "BOTTOMRIGHT", 0, -self.GAP)
    FB:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
    FB:SetMinMaxValues(0, 1)
    FB:SetValue(0)

    FB._bg = FB:CreateTexture(nil, "BACKGROUND")
    FB._bg:SetAllPoints(FB)
    FB._bg:SetColorTexture(unpack(C.BAR_TRACK))

    FB.label = self:MakeFS(FB, 10, "OUTLINE")
    FB.label:SetPoint("LEFT", FB, "LEFT", 8, 0)
    FB.label:SetText(self.L.FORCES)
    FB.label:SetTextColor(unpack(C.TEXT_TEAL))

    FB.pct = self:MakeFS(FB, 12, "OUTLINE")
    FB.pct:SetPoint("CENTER", FB, "CENTER", 0, 0)
    FB.pct:SetTextColor(unpack(C.TEXT_WHITE))

    FB.count = self:MakeFS(FB, 10, "OUTLINE")
    FB.count:SetPoint("RIGHT", FB, "RIGHT", -8, 0)
    FB.count:SetTextColor(unpack(C.TEXT_GREY))

    -- ── SEPARATOR 3 ───────────────────────────────────────────────────────────
    F._sep3 = F:CreateTexture(nil, "ARTWORK")
    F._sep3:SetHeight(1)
    F._sep3:SetPoint("TOPLEFT",  FB, "BOTTOMLEFT",  0, -self.GAP)
    F._sep3:SetPoint("TOPRIGHT", FB, "BOTTOMRIGHT", 0, -self.GAP)
    F._sep3:SetColorTexture(unpack(C.SEP))

    -- ── BOSS ROWS (up to 8) ───────────────────────────────────────────────────
    F.BossRows = {}
    local prevAnchor = F._sep3
    for i = 1, 8 do
        local row = CreateFrame("Frame", nil, F)
        row:SetHeight(self.BOSS_H)
        row:SetPoint("TOPLEFT",  prevAnchor, "BOTTOMLEFT",  0, i == 1 and -self.GAP or 0)
        row:SetPoint("TOPRIGHT", prevAnchor, "BOTTOMRIGHT", 0, i == 1 and -self.GAP or 0)

        row._bg = row:CreateTexture(nil, "BACKGROUND")
        row._bg:SetAllPoints(row)
        row._bg:SetColorTexture(0, 0, 0, 0)

        -- Small square icon instead of dot (matches TomoMod OT bullet style)
        row.dot = row:CreateTexture(nil, "ARTWORK")
        row.dot:SetSize(7, 7)
        row.dot:SetPoint("LEFT", row, "LEFT", 8, 0)
        row.dot:SetColorTexture(0.35, 0.35, 0.35, 1)

        row.name = self:MakeFS(row, 11, "OUTLINE")
        row.name:SetPoint("LEFT", row, "LEFT", 20, 0)
        row.name:SetTextColor(unpack(C.TEXT_GREY))

        row.time = self:MakeFS(row, 11, "OUTLINE")
        row.time:SetPoint("RIGHT", row, "RIGHT", -8, 0)
        row.time:SetTextColor(unpack(C.TEXT_GREY))

        row:Hide()
        F.BossRows[i] = row
        prevAnchor = row
    end

    -- ── COMPLETION BANNER ─────────────────────────────────────────────────────
    local BNR = CreateFrame("Frame", nil, F)
    F.Banner = BNR
    BNR:SetHeight(24)
    BNR:SetPoint("LEFT",  F, "LEFT",  0, 0)
    BNR:SetPoint("RIGHT", F, "RIGHT", 0, 0)

    BNR._bg = BNR:CreateTexture(nil, "BACKGROUND")
    BNR._bg:SetAllPoints(BNR)
    BNR._bg:SetColorTexture(0, 0.20, 0.04, 0.92)

    BNR.text = self:MakeFS(BNR, 13, "OUTLINE")
    BNR.text:SetPoint("CENTER", BNR, "CENTER", 0, 0)
    BNR.text:SetTextColor(unpack(C.TEXT_GREEN))
    BNR:Hide()

    -- Apply initial lock state
    self:SetMovable(not (self.db and self.db.locked))
end

-- ─────────────────────────────────────────────────────────────────────────────
--  SHOW / HIDE
-- ─────────────────────────────────────────────────────────────────────────────
function TM:ShowFrame()
    if self.Frame then
        self.Frame:SetAlpha(self.db.alpha)
        self.Frame:Show()
    end
end

function TM:HideFrame()
    if self.Frame then self.Frame:Hide() end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  REFRESH ALL
-- ─────────────────────────────────────────────────────────────────────────────
function TM:RefreshAll(preview)
    if not self.Frame then return end
    self:UpdateHeader(preview)
    self:UpdateTimerBar(preview)
    self:UpdateForcesBar(preview)
    self:UpdateBossRows(preview)
    self:UpdateBanner()
    self:LayoutFrame()
end

-- ─────────────────────────────────────────────────────────────────────────────
--  HEADER
-- ─────────────────────────────────────────────────────────────────────────────
function TM:UpdateHeader(preview)
    local HDR = self.Frame.Hdr
    local L, C = self.L, self.C

    -- ── Line 1: Dungeon name + Key level ─────────────────────────────────────
    local name = L.DUNGEON_UNKNOWN
    if preview then
        name = "Priory of the Sacred Flame"
    elseif self.mapID and self.mapID > 0 then
        local n = C_ChallengeMode.GetMapUIInfo(self.mapID)
        if n then name = n end
    end
    HDR.dungeonName:SetText(name)

    local lvl = preview and 20 or (self.level or 0)
    HDR.keyLevel:SetText(lvl > 0 and string.format(L.KEY_LEVEL, lvl) or "")

    -- ── Line 2: Deaths (right) ────────────────────────────────────────────────
    -- Skull icon via inline WoW texture (avoids broken UTF-8 glyph)
    local skullIcon = "|TInterface\Icons\spell_shadow_soulleech_3:13:13:0:-1|t"
    local deaths, timeLost = 0, 0
    if preview then
        deaths, timeLost = 1, 5
    else
        deaths, timeLost = C_ChallengeMode.GetDeathCount()
        deaths   = deaths   or 0
        timeLost = timeLost or 0
    end

    if deaths > 0 then
        HDR.deaths:SetText(skullIcon
            .. " |cFFE03030" .. deaths .. "|r"
            .. " |cFF777777(+" .. self:FormatTime(timeLost) .. ")|r")
    else
        HDR.deaths:SetText("")
    end

    -- ── Line 2: Affix icons (left → right, bottom of header) ─────────────────
    local affixes = preview and {9, 12, 134, 11} or (self.affixes or {})
    local lastShown = nil
    for i = 1, 4 do
        local ic = HDR.affixes[i]
        ic:ClearAllPoints()
        if affixes[i] then
            local _, _, icon = C_ChallengeMode.GetAffixInfo(affixes[i])
            if icon then
                ic:SetTexture(icon)
                if lastShown == nil then
                    ic:SetPoint("BOTTOMLEFT", HDR, "BOTTOMLEFT", 8, 5)
                else
                    ic:SetPoint("LEFT", lastShown, "RIGHT", 3, 0)
                end
                ic:Show()
                lastShown = ic
            else
                ic:Hide()
            end
        else
            ic:Hide()
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  TIMER BAR + CHEST COUNTDOWN ROW
-- ─────────────────────────────────────────────────────────────────────────────
function TM:UpdateTimerBar(preview)
    local TB = self.Frame.TimerBar
    local CR = self.Frame.ChestRow
    if not self.db.showTimer then
        TB:Hide(); CR:Hide()
        return
    end
    TB:Show()

    local C = self.C
    local elapsed   = 0
    local timeLimit = self.timeLimit or 1800

    if preview then
        elapsed, timeLimit = 179, 1800       -- 2:59 like in the screenshot
    elseif self.completionTime then
        elapsed = self.completionTime / 1000
    elseif C_ChallengeMode.IsChallengeModeActive() then
        -- GetWorldElapsedTime deprecated in 12.x
        elapsed = (C_ChallengeMode.GetActiveChallengeElapsedTime and C_ChallengeMode.GetActiveChallengeElapsedTime()) or select(2, GetWorldElapsedTime and GetWorldElapsedTime(1) or 0, 0) or 0
    end
    if timeLimit <= 0 then timeLimit = 1800 end

    local ratio    = math.min(elapsed / timeLimit, 1)
    local overtime = elapsed > timeLimit

    -- Bar fill color: green → yellow → red
    local r, g, b
    if overtime then
        r, g, b = C.BAR_RED[1], C.BAR_RED[2], C.BAR_RED[3]
        TB:SetValue(1)
    elseif ratio < 0.70 then
        local t = ratio / 0.70
        r = C.BAR_GREEN[1]  + (C.BAR_YELLOW[1] - C.BAR_GREEN[1])  * t
        g = C.BAR_GREEN[2]  + (C.BAR_YELLOW[2] - C.BAR_GREEN[2])  * t
        b = C.BAR_GREEN[3]  + (C.BAR_YELLOW[3] - C.BAR_GREEN[3])  * t
        TB:SetValue(ratio)
    else
        local t = (ratio - 0.70) / 0.30
        r = C.BAR_YELLOW[1] + (C.BAR_RED[1] - C.BAR_YELLOW[1]) * t
        g = C.BAR_YELLOW[2] + (C.BAR_RED[2] - C.BAR_YELLOW[2]) * t
        b = C.BAR_YELLOW[3] + (C.BAR_RED[3] - C.BAR_YELLOW[3]) * t
        TB:SetValue(ratio)
    end
    TB:SetStatusBarColor(r, g, b, 0.85)

    -- Elapsed text
    TB.elapsed:SetText(self:FormatTime(elapsed))
    if overtime then
        TB.elapsed:SetTextColor(unpack(C.TEXT_RED))
    else
        TB.elapsed:SetTextColor(unpack(C.TEXT_WHITE))
    end

    -- Time limit (right)
    TB.limit:SetText("/ " .. self:FormatTime(timeLimit))

    -- Delta ±time vs limit (center, colored like bar)
    local diff = timeLimit - elapsed
    local ds   = self:FormatDelta(diff)
    if diff >= 0 then
        local hex = string.format("|cFF%02x%02x%02x", math.floor(r*255), math.floor(g*255), math.floor(b*255))
        TB.delta:SetText(hex .. ds .. "|r")
    else
        TB.delta:SetText("|cFFE03020" .. ds .. "|r")
    end

    -- Tick marks inside bar
    local ct = preview and {timeLimit, math.floor(timeLimit * 0.80)} or (self.chestTimes or {})
    for i = 1, 2 do
        local tick  = TB.ticks[i]
        local ctime = ct[i]
        if ctime and ctime > 0 and ctime < timeLimit then
            local px = (ctime / timeLimit) * self.W
            tick:ClearAllPoints()
            tick:SetPoint("LEFT", TB, "LEFT", math.floor(px), 0)
            tick:Show()
        else
            tick:Hide()
        end
    end

    -- ── Chest countdown row (below timer bar) ─────────────────────────────────
    local anyChest = false
    -- +2 bonus chest (80% of time limit)
    local ct2 = ct[2]
    if ct2 and ct2 > 0 and ct2 < timeLimit then
        local rem2 = ct2 - elapsed
        local txt2
        if rem2 > 0 then
            txt2 = "|cFF55E210+2|r  " .. self:FormatTime(rem2)
            CR.chest2:SetTextColor(unpack(C.TEXT_GREEN))
        else
            txt2 = "|cFF55E210+2|r  |cFF888888-" .. self:FormatTime(-rem2) .. "|r"
        end
        CR.chest2:SetText(txt2)
        CR.chest2:Show()
        anyChest = true
    else
        CR.chest2:Hide()
    end

    -- In-time (100% of time limit)
    local ct1 = ct[1]
    if ct1 and ct1 > 0 then
        local rem1 = ct1 - elapsed
        local txt1
        if rem1 > 0 then
            txt1 = self:FormatTime(rem1) .. "  |cFFFFCC00±0|r"
            CR.chest1:SetTextColor(unpack(C.TEXT_YELLOW))
        else
            txt1 = "|cFF888888-" .. self:FormatTime(-rem1) .. "|r  |cFFE03020OT|r"
        end
        CR.chest1:SetText(txt1)
        CR.chest1:Show()
        anyChest = true
    else
        CR.chest1:Hide()
    end

    if anyChest then CR:Show() else CR:Hide() end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  FORCES BAR
-- ─────────────────────────────────────────────────────────────────────────────
function TM:UpdateForcesBar(preview)
    local FB  = self.Frame.ForcesBar
    local sep = self.Frame._sep3
    if not self.db.showForces then
        FB:Hide(); sep:Hide()
        return
    end
    FB:Show(); sep:Show()

    local C = self.C
    local qty, total, pct = 0, 1, 0

    if preview then
        qty, total = 730, 1000
    else
        local steps = select(3, C_Scenario.GetStepInfo())
        if steps and steps > 0 then
            for i = steps, 1, -1 do
                local cr = C_ScenarioInfo.GetCriteriaInfo(i)
                if cr and cr.isWeightedProgress then
                    qty   = cr.quantity      or 0
                    total = cr.totalQuantity or 1
                    break
                end
            end
        end
    end
    pct = (total > 0) and (qty / total * 100) or 0

    local ratio = math.min(pct / 100, 1)
    FB:SetValue(ratio)

    if pct >= 100 then
        FB:SetStatusBarColor(unpack(C.BAR_GREEN))
        FB.pct:SetText(self.L.FORCES_DONE)
        FB.pct:SetTextColor(unpack(C.TEXT_GREEN))
    else
        local r = C.BAR_BLUE[1] + (C.BAR_TEAL[1] - C.BAR_BLUE[1]) * ratio
        local g = C.BAR_BLUE[2] + (C.BAR_TEAL[2] - C.BAR_BLUE[2]) * ratio
        local b = C.BAR_BLUE[3] + (C.BAR_TEAL[3] - C.BAR_BLUE[3]) * ratio
        FB:SetStatusBarColor(r, g, b, 0.88)
        FB.pct:SetText(string.format(self.L.FORCES_PCT, pct))
        FB.pct:SetTextColor(unpack(C.TEXT_WHITE))
    end
    FB.count:SetText(string.format(self.L.FORCES_COUNT, qty, total))
end

-- ─────────────────────────────────────────────────────────────────────────────
--  BOSS ROWS
-- ─────────────────────────────────────────────────────────────────────────────
function TM:UpdateBossRows(preview)
    for _, row in ipairs(self.Frame.BossRows) do row:Hide() end
    if not self.db.showBosses then return end

    local C       = self.C
    local elapsed = 0

    if not preview and C_ChallengeMode.IsChallengeModeActive() then
        -- GetWorldElapsedTime deprecated in 12.x
        elapsed = (C_ChallengeMode.GetActiveChallengeElapsedTime and C_ChallengeMode.GetActiveChallengeElapsedTime()) or select(2, GetWorldElapsedTime and GetWorldElapsedTime(1) or 0, 0) or 0
    end

    local criteria = {}
    if preview then
        criteria = {
            { criteriaString = "Prioress Murrpray",   completed = true,  elapsed = 340 },
            { criteriaString = "Sergeant Shaynemail", completed = true,  elapsed = 560 },
            { criteriaString = "Captain Dailcry",     completed = false, elapsed = nil },
            { criteriaString = "High Priest Aemya",   completed = false, elapsed = nil },
        }
        elapsed = 900
    else
        local steps = select(3, C_Scenario.GetStepInfo()) or 0
        for i = 1, steps do
            local cr = C_ScenarioInfo.GetCriteriaInfo(i)
            if cr and not cr.isWeightedProgress then
                table.insert(criteria, cr)
            end
        end
    end

    self.bossKillTimes = self.bossKillTimes or {}

    for i, cr in ipairs(criteria) do
        local row = self.Frame.BossRows[i]
        if not row then break end
        row:Show()

        -- Alternating row background
        if i % 2 == 0 then
            row._bg:SetColorTexture(unpack(C.BG_ROW_ALT))
        else
            row._bg:SetColorTexture(0, 0, 0, 0)
        end

        row.name:SetText(cr.criteriaString or ("Boss " .. i))

        if cr.completed then
            row.dot:SetColorTexture(unpack(C.ACCENT))
            row.name:SetTextColor(unpack(C.TEXT_WHITE))

            local kt = self.bossKillTimes[i]
            if not kt and cr.elapsed and elapsed > 0 then
                kt = elapsed - cr.elapsed
                self.bossKillTimes[i] = kt
            end
            row.time:SetText(kt and ("|cFF55E210✔|r  " .. self:FormatTime(kt)) or "|cFF55E210✔|r")
            row.time:SetTextColor(unpack(C.TEXT_GREEN))
        else
            row.dot:SetColorTexture(0.30, 0.30, 0.30, 1)
            row.name:SetTextColor(unpack(C.TEXT_GREY))
            row.time:SetText("—")
            row.time:SetTextColor(unpack(C.TEXT_GREY))
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  COMPLETION BANNER
-- ─────────────────────────────────────────────────────────────────────────────
function TM:UpdateBanner()
    local BNR = self.Frame.Banner
    local L   = self.L
    local info = C_ChallengeMode.GetChallengeCompletionInfo()
    if info and info.time and info.time > 0 then
        local sec    = info.time / 1000
        local inTime = self.timeLimit and (sec <= self.timeLimit)
        if inTime then
            BNR._bg:SetColorTexture(0, 0.22, 0.04, 0.92)
            BNR.text:SetText("|cFF55E210" .. L.COMPLETED_ON_TIME .. "|r  " .. self:FormatTime(sec))
        else
            BNR._bg:SetColorTexture(0.22, 0.04, 0, 0.92)
            BNR.text:SetText("|cFFE03020" .. L.COMPLETED_DEPLETED .. "|r  " .. self:FormatTime(sec))
        end
        BNR:Show()
    else
        BNR:Hide()
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
--  LAYOUT — resize frame height dynamically
-- ─────────────────────────────────────────────────────────────────────────────
function TM:LayoutFrame()
    if not self.Frame then return end
    local F   = self.Frame
    local GAP = self.GAP

    -- Measure sections
    local h = self.HEADER_H + 1 + GAP   -- header + sep1 + gap before timer

    if self.db.showTimer then
        h = h + self.BAR_H               -- timer bar
        -- Chest row (visible only when chest countdowns are active)
        if F.ChestRow:IsShown() then
            h = h + 1 + 14              -- gap + chest row
        end
    end

    if self.db.showForces then
        h = h + GAP + 1 + GAP + self.BAR_H  -- gap + sep2 + gap + forces
    end

    -- Count visible boss rows
    local bossCnt  = 0
    local lastRow  = nil
    for _, row in ipairs(F.BossRows) do
        if row:IsShown() then bossCnt = bossCnt + 1; lastRow = row end
    end
    if bossCnt > 0 then
        h = h + GAP + 1 + GAP            -- sep3 + gaps
        h = h + bossCnt * self.BOSS_H
    end

    if F.Banner:IsShown() then
        h = h + GAP + 24
    end
    h = h + 4  -- bottom padding

    F:SetHeight(math.max(h, self.HEADER_H + self.BAR_H * 2 + 20))

    -- Update bg / accent / border to match new size
    F._bg:SetAllPoints(F)
    F._accent:ClearAllPoints()
    F._accent:SetPoint("TOPLEFT",    F, "TOPLEFT",    0, 0)
    F._accent:SetPoint("BOTTOMLEFT", F, "BOTTOMLEFT", 0, 0)
    if F._bdrFrame then F._bdrFrame:SetAllPoints(F) end

    -- Reanchor banner below last boss row (or forces bar)
    local bannerAnchor = (lastRow and lastRow:IsShown()) and lastRow
                         or (self.db.showForces and F.ForcesBar)
                         or F.TimerBar
    F.Banner:ClearAllPoints()
    F.Banner:SetPoint("TOPLEFT",  bannerAnchor, "BOTTOMLEFT",  0, -GAP)
    F.Banner:SetPoint("TOPRIGHT", bannerAnchor, "BOTTOMRIGHT", 0, -GAP)
end

-- ─────────────────────────────────────────────────────────────────────────────
--  PREVIEW
-- ─────────────────────────────────────────────────────────────────────────────
function TM:Preview()
    if not self.Frame then self:BuildFrame() end
    self.mapID          = 0
    self.level          = 20
    self.affixes        = {}
    self.timeLimit      = 1800
    self.chestTimes     = { [1] = 1800, [2] = 1440 }
    self.bossKillTimes  = {}
    self.completionTime = nil
    self:RefreshAll(true)
    self:ShowFrame()
    print("|cFF55B400TomoMythic|r: Aperçu actif — |cFF55B400/tmt lock|r pour verrouiller.")
end
