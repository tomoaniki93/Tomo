-- =====================================
-- Castbar.lua — Standalone Castbar Module
-- Supports: Casts, Channels, Empowered (Evoker stages)
-- Units: player, target, focus
-- =====================================

TomoCastbar_Module = TomoCastbar_Module or {}
local CB = TomoCastbar_Module
local L = TomoCastbar_L

local MAX_EMPOWER_STAGES = 4
local MAX_CHANNEL_TICKS = 20  -- max tick markers pool

-- =====================================
-- CHANNEL TICK DATABASE  (spellID → number of ticks)
-- Fallback: compute ticks from duration at ~1 tick/sec
-- =====================================
local CHANNEL_TICK_DATA = {
    -- Priest
    [15407]  = 6,  -- Mind Flay
    [263165] = 4,  -- Void Torrent
    [48045]  = 4,  -- Mind Sear
    [64843]  = 4,  -- Divine Hymn
    [47540]  = 9,  -- Penance (heal)
    [47666]  = 3,  -- Penance (damage)
    -- Mage
    [5143]   = 5,  -- Arcane Missiles
    [12051]  = 3,  -- Evocation
    [205021] = 5,  -- Ray of Frost
    -- Warlock
    [198590] = 6,  -- Drain Soul
    [234153] = 5,  -- Drain Life
    [755]    = 5,  -- Health Funnel
    -- Druid
    [740]    = 4,  -- Tranquility
    -- Monk
    [115175] = 9,  -- Soothing Mist
    [113656] = 4,  -- Fists of Fury
    [117952] = 4,  -- Crackling Jade Lightning
    -- Hunter
    [120360] = 3,  -- Barrage
    [257044] = 7,  -- Rapid Fire
    -- Death Knight
    [206931] = 3,  -- Blooddrinker
    -- Demon Hunter
    [198013] = 6,  -- Eye Beam
    [211053] = 3,  -- Fel Barrage
    -- Shaman
    [291944] = 6,  -- Regenerative Flame (Essence)
    -- Evoker (non-empower channels)
    [356995] = 3,  -- Disintegrate
}

-- Talent modifiers: { spellID = { talentSpellID, bonusTicks }, ... }
local CHANNEL_TICK_MODIFIERS = {
    [356995] = { 1219723, 1 },  -- Disintegrate: +1 tick if talent active
}

local function GetChannelTicks(spellID, durationMS)
    local ticks = 0
    if spellID and CHANNEL_TICK_DATA[spellID] then
        ticks = CHANNEL_TICK_DATA[spellID]
        -- Check talent modifiers
        local mod = CHANNEL_TICK_MODIFIERS[spellID]
        if mod and IsPlayerSpell(mod[1]) then
            ticks = ticks + mod[2]
        end
        return ticks
    end
    -- Fallback: 1 tick per second, minimum 2
    if durationMS and durationMS > 0 then
        return math.max(2, math.floor(durationMS / 1000 + 0.5))
    end
    return 0
end

-- Empower stage gradient colors (stage 1 → 4)
local EMPOWER_STAGE_COLORS = {
    { 0.80, 0.50, 0.10 },  -- Stage 1: orange
    { 0.90, 0.75, 0.10 },  -- Stage 2: gold
    { 0.20, 0.70, 0.90 },  -- Stage 3: cyan
    { 0.55, 0.30, 0.95 },  -- Stage 4: purple
}

-- Store all created castbars for lock/unlock
CB.castbars = {}

-- =====================================
-- BAR TEXTURE LOOKUP
-- =====================================

local BAR_TEXTURES = {
    blizzard = "Interface\\TargetingFrame\\UI-StatusBar",
    smooth   = "Interface\\RaidFrame\\Raid-Bar-Hp-Fill",
    flat     = "Interface\\Buttons\\WHITE8x8",
}

function CB.GetBarTexturePath(key)
    return BAR_TEXTURES[key] or BAR_TEXTURES["blizzard"]
end

-- =====================================
-- BORDER HELPER
-- =====================================

local function CreateBorder(frame, useCustom)
    local db = TomoCastbarDB
    if useCustom and db and db.useCustomBorder and db.customBorderPath then
        local border = frame:CreateTexture(nil, "OVERLAY", nil, 7)
        border:SetTexture(db.customBorderPath)
        border:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
        border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
        frame.customBorder = border
        return
    end
    -- Fallback: simple 1px black edges
    local function Edge(point1, point2, w, h)
        local t = frame:CreateTexture(nil, "OVERLAY", nil, 7)
        t:SetColorTexture(0, 0, 0, 1)
        t:SetPoint(point1)
        t:SetPoint(point2)
        if w then t:SetWidth(w) end
        if h then t:SetHeight(h) end
    end
    Edge("TOPLEFT", "TOPRIGHT", nil, 1)
    Edge("BOTTOMLEFT", "BOTTOMRIGHT", nil, 1)
    Edge("TOPLEFT", "BOTTOMLEFT", 1, nil)
    Edge("TOPRIGHT", "BOTTOMRIGHT", 1, nil)
end

-- =====================================
-- CREATE CASTBAR
-- =====================================

function CB.CreateCastbar(unit)
    local db = TomoCastbarDB
    if not db then return nil end

    local unitSettings = db[unit]
    if not unitSettings or not unitSettings.enabled then return nil end

    local tex = CB.GetBarTexturePath(db.barTexture)
    local font = db.font or "Fonts\\FRIZQT__.TTF"

    local castbar = CreateFrame("StatusBar", "TomoCastbar_" .. unit, UIParent)
    castbar:SetSize(unitSettings.width, unitSettings.height)
    castbar:SetStatusBarTexture(tex)
    castbar:GetStatusBarTexture():SetHorizTile(false)
    castbar:SetMinMaxValues(0, 100)
    castbar:SetValue(100)

    -- Base color from DB (interruptible cast)
    local cbColors = db.castbarColor
    local baseR, baseG, baseB = 0.8, 0.1, 0.1
    if cbColors then baseR, baseG, baseB = cbColors.r, cbColors.g, cbColors.b end
    castbar:SetStatusBarColor(baseR, baseG, baseB, 1)
    castbar._baseColor = { baseR, baseG, baseB }

    -- Position (all castbars are standalone, anchored to UIParent)
    local pos = unitSettings.position or { point = "CENTER", relativePoint = "CENTER", x = 0, y = 0 }
    castbar:SetParent(UIParent)
    castbar:ClearAllPoints()
    castbar:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)

    -- Make draggable (toggled via /tcb lock)
    TomoCastbar_Utils.SetupDraggable(castbar, function()
        local point, _, relativePoint, x, y = castbar:GetPoint()
        unitSettings.position = unitSettings.position or {}
        unitSettings.position.point = point
        unitSettings.position.relativePoint = relativePoint
        unitSettings.position.x = x
        unitSettings.position.y = y
    end)
    castbar:SetFrameStrata("MEDIUM")

    -- Background
    local bg = castbar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    local bgMode = db.backgroundMode or "custom"
    if bgMode == "transparent" then
        bg:SetColorTexture(0, 0, 0, 0)
    elseif bgMode == "black" then
        bg:SetColorTexture(0, 0, 0, 0.85)
    else -- "custom"
        if db.customBackgroundPath then
            bg:SetTexture(db.customBackgroundPath)
            bg:SetVertexColor(0.12, 0.12, 0.15, 0.95)
        else
            bg:SetColorTexture(0, 0, 0, 0.85)
        end
    end
    castbar.bg = bg

    -- Border
    CreateBorder(castbar, true)

    -- Not-interruptible overlay
    local statustexture = castbar:GetStatusBarTexture()
    local niOverlay = castbar:CreateTexture(nil, "ARTWORK", nil, 1)
    niOverlay:SetPoint("TOPLEFT", statustexture, "TOPLEFT", 0, 0)
    niOverlay:SetPoint("BOTTOMRIGHT", statustexture, "BOTTOMRIGHT", 0, 0)
    local niColors = db.castbarNIColor
    local niR, niG, niB = 0.5, 0.5, 0.5
    if niColors then niR, niG, niB = niColors.r, niColors.g, niColors.b end
    niOverlay:SetColorTexture(niR, niG, niB, 1)
    niOverlay:SetAlpha(0)
    niOverlay:Show()
    castbar.niOverlay = niOverlay

    -- =====================================
    -- LATENCY OVERLAY (player only)
    -- =====================================
    if unit == "player" then
        local latencyTex = castbar:CreateTexture(nil, "ARTWORK", nil, 2)
        latencyTex:SetPoint("TOP", castbar, "TOP", 0, 0)
        latencyTex:SetPoint("BOTTOM", castbar, "BOTTOM", 0, 0)
        latencyTex:SetPoint("RIGHT", castbar, "RIGHT", 0, 0)
        latencyTex:SetWidth(1)
        latencyTex:SetTexture(tex)
        latencyTex:SetVertexColor(baseR * 0.35, baseG * 0.35, baseB * 0.35, 0.85)
        latencyTex:Hide()
        castbar.latencyTex = latencyTex
    end

    -- =====================================
    -- EMPOWER STAGE MARKERS
    -- =====================================
    castbar.stageMarkers = {}
    for i = 1, MAX_EMPOWER_STAGES do
        local marker = castbar:CreateTexture(nil, "OVERLAY", nil, 2)
        marker:SetWidth(2)
        marker:SetPoint("TOP", castbar, "TOP", 0, 0)
        marker:SetPoint("BOTTOM", castbar, "BOTTOM", 0, 0)
        marker:SetColorTexture(1, 1, 1, 0.7)
        marker:Hide()
        castbar.stageMarkers[i] = marker
    end

    -- =====================================
    -- EMPOWER STAGE GRADIENT OVERLAYS
    -- =====================================
    castbar.stageOverlays = {}
    castbar._stageBoundaries = {}  -- cumulative % for each stage end
    for i = 1, MAX_EMPOWER_STAGES do
        local overlay = castbar:CreateTexture(nil, "ARTWORK", nil, 3)
        overlay:SetPoint("TOP", castbar, "TOP", 0, 0)
        overlay:SetPoint("BOTTOM", castbar, "BOTTOM", 0, 0)
        local col = EMPOWER_STAGE_COLORS[i] or { 0.5, 0.5, 0.5 }
        overlay:SetColorTexture(col[1], col[2], col[3], 0.45)
        overlay:Hide()
        castbar.stageOverlays[i] = overlay
    end

    -- =====================================
    -- CHANNEL TICK MARKERS
    -- =====================================
    castbar.tickMarkers = {}
    for i = 1, MAX_CHANNEL_TICKS do
        local tick = castbar:CreateTexture(nil, "OVERLAY", nil, 1)
        tick:SetWidth(1)
        tick:SetPoint("TOP", castbar, "TOP", 0, 0)
        tick:SetPoint("BOTTOM", castbar, "BOTTOM", 0, 0)
        tick:SetColorTexture(1, 1, 1, 0.5)
        tick:Hide()
        castbar.tickMarkers[i] = tick
    end
    castbar._numTicks = 0

    -- Spark (glow at the leading edge of the cast)
    if db.showSpark then
        local sparkHeight = db.sparkHeight or 26
        local spark = castbar:CreateTexture(nil, "OVERLAY", nil, 3)
        spark:SetTexture(db.customSparkPath)
        spark:SetSize(12, sparkHeight)
        spark:SetBlendMode("ADD")
        spark:SetAlpha(0.9)
        spark:Hide()
        castbar.spark = spark
    end

    -- Icon
    if unitSettings.showIcon then
        local icon = castbar:CreateTexture(nil, "OVERLAY")
        icon:SetSize(unitSettings.height, unitSettings.height)
        icon:SetPoint("RIGHT", castbar, "LEFT", -3, 0)
        icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
        castbar.icon = icon

        local iconBorder = CreateFrame("Frame", nil, castbar)
        iconBorder:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        iconBorder:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        CreateBorder(iconBorder, true)
    end

    -- Spell name
    local fontSize = db.fontSize or 12
    local spellText = castbar:CreateFontString(nil, "OVERLAY")
    spellText:SetFont(font, fontSize, "OUTLINE")
    spellText:SetPoint("LEFT", 4, 0)
    spellText:SetTextColor(1, 1, 1, 1)
    spellText:SetJustifyH("LEFT")
    castbar.spellText = spellText

    -- Timer text
    if unitSettings.showTimer then
        local timerText = castbar:CreateFontString(nil, "OVERLAY")
        timerText:SetFont(font, fontSize, "OUTLINE")
        timerText:SetPoint("RIGHT", -4, 0)
        timerText:SetTextColor(1, 1, 1, 0.9)
        castbar.timerText = timerText
    end

    -- State
    castbar.unit = unit
    castbar.casting = false
    castbar.channeling = false
    castbar.empowered = false
    castbar.numStages = 0
    castbar.duration_obj = nil
    castbar.failstart = nil
    castbar._preview = false
    castbar._castStartMS = nil
    castbar._castEndMS = nil
    castbar._channelSpellID = nil

    castbar:Hide()

    -- =====================================
    -- HELPER: Hide channel tick markers
    -- =====================================
    local function HideTickMarkers(self)
        for i = 1, MAX_CHANNEL_TICKS do
            self.tickMarkers[i]:Hide()
        end
        self._numTicks = 0
    end

    -- =====================================
    -- HELPER: Show/position tick markers for a channel
    -- =====================================
    local function UpdateTickMarkers(self)
        HideTickMarkers(self)
        if not db.showChannelTicks then return end
        if not self.channeling then return end

        local durationSec = self._realDurationSec
        if not durationSec or durationSec <= 0 then return end

        local durationMS = durationSec * 1000
        local numTicks = GetChannelTicks(self._channelSpellID, durationMS)
        if numTicks < 2 then return end

        self._numTicks = numTicks
        local barWidth = self:GetWidth()

        -- Place markers between ticks (numTicks - 1 dividers)
        for i = 1, numTicks - 1 do
            local marker = self.tickMarkers[i]
            if marker then
                local pct = i / numTicks
                local xPos = barWidth * pct
                marker:ClearAllPoints()
                marker:SetPoint("TOP", self, "TOPLEFT", xPos, 0)
                marker:SetPoint("BOTTOM", self, "BOTTOMLEFT", xPos, 0)
                marker:Show()
            end
        end
    end

    -- =====================================
    -- HELPER: Hide all stage markers
    -- =====================================
    local function HideStageMarkers(self)
        for i = 1, MAX_EMPOWER_STAGES do
            self.stageMarkers[i]:Hide()
        end
        -- Also hide gradient overlays
        if self.stageOverlays then
            for i = 1, MAX_EMPOWER_STAGES do
                self.stageOverlays[i]:Hide()
            end
        end
        if self._stageBoundaries then
            wipe(self._stageBoundaries)
        end
    end

    -- =====================================
    -- HELPER: Position stage markers for empowered cast
    -- =====================================
    local function UpdateStageMarkers(self)
        HideStageMarkers(self)
        if not self.empowered or self.numStages <= 0 then return end

        local barWidth = self:GetWidth()
        local durationSec = self._realDurationSec
        if not durationSec or durationSec <= 0 then return end

        local ok, _ = pcall(function()
            local totalDurationMS = durationSec * 1000
            if totalDurationMS <= 0 then return end

            local cumulative = 0
            local boundaries = {}
            boundaries[0] = 0  -- start of bar

            for stage = 0, self.numStages - 1 do
                local stageDuration = GetUnitEmpowerStageDuration(self.unit, stage)
                if not stageDuration or stageDuration <= 0 then break end
                cumulative = cumulative + stageDuration

                local pct = cumulative / totalDurationMS
                boundaries[stage + 1] = pct

                -- Place marker between stages (not after the last one)
                if stage < self.numStages - 1 then
                    local xPos = barWidth * pct
                    local marker = self.stageMarkers[stage + 1]
                    if marker then
                        marker:ClearAllPoints()
                        marker:SetPoint("TOP", self, "TOPLEFT", xPos, 0)
                        marker:SetPoint("BOTTOM", self, "BOTTOMLEFT", xPos, 0)
                        marker:Show()
                    end
                end
            end

            -- Store boundaries for OnUpdate gradient reveal
            self._stageBoundaries = boundaries

            -- Position gradient overlays for each stage zone
            for stage = 1, self.numStages do
                local overlay = self.stageOverlays[stage]
                if overlay then
                    local leftPct = boundaries[stage - 1] or 0
                    local rightPct = boundaries[stage] or 1
                    local leftX = barWidth * leftPct
                    local rightX = barWidth * rightPct

                    overlay:ClearAllPoints()
                    overlay:SetPoint("TOPLEFT", self, "TOPLEFT", leftX, 0)
                    overlay:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", leftX, 0)
                    overlay:SetWidth(math.max(1, rightX - leftX))
                    overlay:SetAlpha(0)  -- start hidden, OnUpdate will reveal
                    overlay:Show()
                end
            end
        end)
    end

    -- =====================================
    -- HELPER: Reset cast state
    -- =====================================
    local function ResetState(self)
        self.casting = false
        self.channeling = false
        self.empowered = false
        self.numStages = 0
        self.duration_obj = nil
        self._castStartMS = nil
        self._castEndMS = nil
        self._realStartSec = nil
        self._realEndSec = nil
        self._realDurationSec = nil
        self._channelSpellID = nil
        HideStageMarkers(self)
        HideTickMarkers(self)
        if self.latencyTex then self.latencyTex:Hide() end
        if self.spark then self.spark:Hide() end
    end

    -- =====================================
    -- PREVIEW MODE (shown when unlocked via /tcb lock)
    -- =====================================

    function castbar:ShowPreview()
        self._preview = true
        ResetState(self)
        self.failstart = nil
        self.niOverlay:SetAlpha(0)

        self:SetMinMaxValues(0, 100)
        self:SetValue(100)
        self:SetReverseFill(false)
        local bc = self._baseColor or { 0.8, 0.1, 0.1 }
        self:SetStatusBarColor(bc[1], bc[2], bc[3], 1)

        if self.spellText then self.spellText:SetText(string.format(L["PREVIEW_CASTBAR"], self.unit)) end
        if self.timerText then self.timerText:SetText("1.5") end
        if self.icon then
            self.icon:SetTexture("Interface\\Icons\\Spell_Nature_Lightning")
        end

        -- Show latency preview (player only)
        if self.latencyTex then
            if unitSettings.showLatency then
                local previewWidth = math.max(2, self:GetWidth() * 0.04)
                self.latencyTex:SetWidth(previewWidth)
                local bc2 = self._baseColor or { 0.8, 0.1, 0.1 }
                self.latencyTex:SetVertexColor(bc2[1] * 0.35, bc2[2] * 0.35, bc2[3] * 0.35, 0.85)
                self.latencyTex:Show()
            else
                self.latencyTex:Hide()
            end
        end

        -- Show spark preview
        if self.spark then
            self.spark:ClearAllPoints()
            local barWidth = self:GetWidth()
            self.spark:SetPoint("CENTER", self, "LEFT", barWidth * 0.75, 0)
            self.spark:Show()
        end

        self:Show()
    end

    function castbar:HidePreview()
        self._preview = false
        if self.spellText then self.spellText:SetText("") end
        if self.timerText then self.timerText:SetText("") end
        if self.icon then self.icon:SetTexture(nil) end
        if self.latencyTex then self.latencyTex:Hide() end
        if self.spark then self.spark:Hide() end
        HideStageMarkers(self)
        if not self.casting and not self.channeling and not self.empowered and not self.failstart then
            self:Hide()
        end
    end

    -- =====================================
    -- LATENCY HELPER
    -- =====================================

    local function UpdateLatency(self)
        if not self.latencyTex then return end
        if not unitSettings.showLatency then
            self.latencyTex:Hide()
            return
        end

        if not self.casting then
            self.latencyTex:Hide()
            return
        end

        local durationSec = self._realDurationSec
        if not durationSec or durationSec <= 0 then
            self.latencyTex:Hide()
            return
        end

        local ok, result = pcall(function()
            local castDurationMS = durationSec * 1000
            if castDurationMS <= 0 then return 0 end
            local _, _, _, latencyWorld = GetNetStats()
            local barWidth = self:GetWidth()
            return math.min(barWidth * 0.25, math.max(2, (latencyWorld / castDurationMS) * barWidth))
        end)

        if ok and result and result > 0 then
            local bc = self._baseColor or { 0.8, 0.1, 0.1 }
            self.latencyTex:SetVertexColor(bc[1] * 0.35, bc[2] * 0.35, bc[3] * 0.35, 0.85)
            self.latencyTex:SetWidth(result)
            self.latencyTex:Show()
        else
            self.latencyTex:Hide()
        end
    end

    -- =====================================
    -- CASTBAR LOGIC
    -- =====================================

    local function CheckCast(self, isInterrupt)
        local unitID = self.unit

        -- Handle interrupt display
        if isInterrupt then
            self.niOverlay:SetAlpha(0)
            ResetState(self)
            local intCol = db.castbarInterruptColor
            if intCol then
                self:SetStatusBarColor(intCol.r, intCol.g, intCol.b, 1)
            else
                self:SetStatusBarColor(0.1, 0.8, 0.1, 1)
            end
            if self.spellText then
                self.spellText:SetText(INTERRUPTED or L["INTERRUPTED"])
            end
            self.failstart = GetTime()
            self:SetMinMaxValues(0, 100)
            self:SetValue(100)
            self:Show()
            return
        end

        -- Fade interrupted text after 1 second
        if self.failstart then
            if GetTime() - self.failstart > 1 then
                self.failstart = nil
                self:Hide()
            end
            return
        end

        -- ===== Check regular cast =====
        local bchannel = false
        local bempowered = false
        local numStages = 0

        local name, _, texture, startTimeMS, endTimeMS, _, _, notInterruptible = UnitCastingInfo(unitID)

        -- ===== Check channel / empowered =====
        local channelSpellID = nil
        if type(name) == "nil" then
            local chanName, _, chanTex, chanStart, chanEnd, _, chanNI, chanSpellID, _, chanStages = UnitChannelInfo(unitID)
            if type(chanName) ~= "nil" then
                name = chanName
                texture = chanTex
                startTimeMS = chanStart
                endTimeMS = chanEnd
                notInterruptible = chanNI
                channelSpellID = chanSpellID

                if chanStages and chanStages > 0 then
                    bempowered = true
                    numStages = chanStages
                else
                    bchannel = true
                end
            end
        end

        -- Nothing found → hide
        if type(name) == "nil" then
            ResetState(self)
            self:Hide()
            return
        end

        -- Get duration object for timer text
        local duration
        if bchannel or bempowered then
            duration = UnitChannelDuration(unitID)
        else
            duration = UnitCastingDuration(unitID)
        end
        self.duration_obj = duration

        -- Store raw times for SetMinMaxValues (secret values)
        self._castStartMS = startTimeMS
        self._castEndMS = endTimeMS

        -- Store real-number timing for manual math (spark, gradients, latency, ticks)
        -- In TWW, target/focus cast times can be "secret numbers" that error on arithmetic.
        -- pcall protects against this — features gracefully degrade via nil checks.
        self._realStartSec = nil
        self._realEndSec = nil
        self._realDurationSec = nil
        if duration then
            local ok, rStart, rEnd, rDur = pcall(function()
                local rem = duration:GetRemainingDuration(0)
                local now = GetTime()
                local endT = now + rem
                -- rem at cast start ≈ total duration; use it for all duration-based math
                return endT - rem, endT, rem
            end)
            if ok then
                self._realStartSec = rStart
                self._realEndSec = rEnd
                self._realDurationSec = rDur
            end
            -- If pcall failed, fields stay nil and dependent features (spark, ticks, etc.) safely skip
        end

        -- Update state
        self.casting = (not bchannel and not bempowered)
        self.channeling = bchannel
        self.empowered = bempowered
        self.numStages = numStages
        self._channelSpellID = channelSpellID
        self.failstart = nil

        -- TWW: SetMinMaxValues accepts secrets
        self:SetMinMaxValues(startTimeMS, endTimeMS)

        -- Fill direction
        self:SetReverseFill(bchannel)

        -- Reset base color
        local bc = self._baseColor or { 0.8, 0.1, 0.1 }
        self:SetStatusBarColor(bc[1], bc[2], bc[3], 1)

        -- Spell info
        if self.spellText then self.spellText:SetFormattedText("%s", name) end
        if self.icon then self.icon:SetTexture(texture) end

        -- TWW: SetAlpha accepts secrets from C_CurveUtil
        local alpha = C_CurveUtil.EvaluateColorValueFromBoolean(notInterruptible, 1, 0)
        self.niOverlay:SetAlpha(alpha)

        -- Empower: show stage markers
        if bempowered then
            UpdateStageMarkers(self)
            HideTickMarkers(self)
        elseif bchannel then
            HideStageMarkers(self)
            UpdateTickMarkers(self)
        else
            HideStageMarkers(self)
            HideTickMarkers(self)
        end

        -- Latency (regular casts only)
        UpdateLatency(self)

        -- Show spark
        if self.spark then self.spark:Show() end

        self:Show()
    end

    -- OnUpdate: bar progress + timer text
    castbar:SetScript("OnUpdate", function(self, elapsed)
        if self._preview then return end

        if self.failstart then
            if GetTime() - self.failstart > 1 then
                self.failstart = nil
                self:Hide()
            end
            return
        end

        if not self.casting and not self.channeling and not self.empowered then
            self:Hide()
            return
        end

        self:SetValue(GetTime() * 1000, Enum.StatusBarInterpolation.ExponentialEaseOut)

        -- Update spark position
        if self.spark then
            local startSec = self._realStartSec
            local endSec = self._realEndSec
            if startSec and endSec and endSec > startSec then
                local now = GetTime()
                local pct
                if self.channeling then
                    pct = (endSec - now) / (endSec - startSec)
                else
                    pct = (now - startSec) / (endSec - startSec)
                end
                pct = math.max(0, math.min(pct, 1))
                local barWidth = self:GetWidth()
                self.spark:ClearAllPoints()
                self.spark:SetPoint("CENTER", self, "LEFT", barWidth * pct, 0)
                self.spark:Show()
            else
                self.spark:Hide()
            end
        end

        if self.timerText and self.duration_obj then
            self.timerText:SetText(string.format("%.1f", self.duration_obj:GetRemainingDuration(0)))
        end

        -- Update empower gradient overlays
        if self.empowered and self._stageBoundaries and self.numStages > 0 then
            local startSec = self._realStartSec
            local endSec = self._realEndSec
            if startSec and endSec and endSec > startSec then
                local now = GetTime()
                local pct = (now - startSec) / (endSec - startSec)
                pct = math.max(0, math.min(pct, 1))

                for stage = 1, self.numStages do
                    local overlay = self.stageOverlays[stage]
                    if overlay and overlay:IsShown() then
                        local leftPct = self._stageBoundaries[stage - 1] or 0
                        local rightPct = self._stageBoundaries[stage] or 1

                        if pct >= rightPct then
                            -- Fully past this stage: full reveal
                            overlay:SetAlpha(0.50)
                        elseif pct > leftPct then
                            -- In progress within this stage: partial reveal (fade in)
                            local stageProgress = (pct - leftPct) / (rightPct - leftPct)
                            overlay:SetAlpha(0.15 + stageProgress * 0.35)
                        else
                            -- Not reached yet
                            overlay:SetAlpha(0)
                        end
                    end
                end
            end
        end
    end)

    -- =====================================
    -- EVENTS
    -- =====================================
    local events = CreateFrame("Frame")

    -- Regular cast events
    events:RegisterUnitEvent("UNIT_SPELLCAST_START", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_STOP", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_FAILED", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTED", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", unit)

    -- Channel events
    events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", unit)

    -- Interruptibility changes
    events:RegisterUnitEvent("UNIT_SPELLCAST_INTERRUPTIBLE", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", unit)

    -- Empowered cast events (Evoker)
    events:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_START", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_STOP", unit)
    events:RegisterUnitEvent("UNIT_SPELLCAST_EMPOWER_UPDATE", unit)

    -- Target/focus change for detecting ongoing casts
    if unit == "target" then
        events:RegisterEvent("PLAYER_TARGET_CHANGED")
    elseif unit == "focus" then
        events:RegisterEvent("PLAYER_FOCUS_CHANGED")
    end

    events:SetScript("OnEvent", function(self, event, eventUnit)
        if castbar._preview then return end

        if event == "PLAYER_TARGET_CHANGED" or event == "PLAYER_FOCUS_CHANGED" then
            castbar.failstart = nil
            CheckCast(castbar, false)
            return
        end

        if eventUnit ~= unit then return end

        if event == "UNIT_SPELLCAST_START"
            or event == "UNIT_SPELLCAST_CHANNEL_START"
            or event == "UNIT_SPELLCAST_EMPOWER_START" then
            castbar.failstart = nil
            CheckCast(castbar, false)

        elseif event == "UNIT_SPELLCAST_CHANNEL_UPDATE"
            or event == "UNIT_SPELLCAST_EMPOWER_UPDATE" then
            if castbar.channeling or castbar.empowered then
                CheckCast(castbar, false)
            end

        elseif event == "UNIT_SPELLCAST_INTERRUPTIBLE"
            or event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" then
            if castbar.casting or castbar.channeling or castbar.empowered then
                CheckCast(castbar, false)
            end

        elseif event == "UNIT_SPELLCAST_INTERRUPTED" then
            CheckCast(castbar, true)

        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            -- For channels/empowered, SUCCEEDED fires on release; ignore until STOP
            if castbar.channeling or castbar.empowered then
                return
            end
            -- Regular cast succeeded: hide immediately
            ResetState(castbar)
            castbar:Hide()

        elseif event == "UNIT_SPELLCAST_STOP"
            or event == "UNIT_SPELLCAST_FAILED"
            or event == "UNIT_SPELLCAST_CHANNEL_STOP"
            or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
            -- Cast ended: hide immediately instead of re-querying
            if not castbar.failstart then
                ResetState(castbar)
                castbar:Hide()
            end
        end
    end)

    castbar.eventFrame = events
    castbar:EnableMouse(false)

    -- Store reference
    CB.castbars[unit] = castbar

    return castbar
end

-- =====================================
-- INITIALIZE: Create all enabled castbars
-- =====================================

function CB.Initialize()
    local db = TomoCastbarDB
    if not db then return end

    -- Hide Blizzard castbar if requested
    if db.hideBlizzardCastbar then
        CB.HideBlizzardCastbar()
    end

    -- Create castbars for each enabled unit
    for _, unit in ipairs({ "player", "target", "focus" }) do
        if db[unit] and db[unit].enabled then
            CB.CreateCastbar(unit)
        end
    end
end

-- =====================================
-- HIDE BLIZZARD CASTBAR
-- =====================================

local BLIZZARD_CASTBAR_FRAMES = {
    "PlayerCastingBarFrame",    -- Player castbar
    "PetCastingBarFrame",       -- Pet castbar
    "TargetFrameSpellBar",      -- Target castbar
    "FocusFrameSpellBar",       -- Focus castbar
}

local function KillFrame(frame)
    if not frame then return end
    frame:UnregisterAllEvents()
    frame:Hide()
    frame:SetScript("OnShow", function(self) self:Hide() end)
    -- Also hide sub-elements (border, icon, flash, etc.)
    if frame.Icon then frame.Icon:Hide() end
    if frame.Border then frame.Border:Hide() end
    if frame.BorderShield then frame.BorderShield:Hide() end
    if frame.Flash then frame.Flash:Hide() end
    if frame.Spark then frame.Spark:Hide() end
    if frame.Text then frame.Text:Hide() end
end

local function RestoreFrame(frame)
    if not frame then return end
    frame:SetScript("OnShow", nil)
    frame:Show()
    if frame.Icon then frame.Icon:Show() end
    if frame.Border then frame.Border:Show() end
    if frame.Text then frame.Text:Show() end
    if frame.Spark then frame.Spark:Show() end
end

function CB.HideBlizzardCastbar()
    for _, name in ipairs(BLIZZARD_CASTBAR_FRAMES) do
        local frame = _G[name]
        KillFrame(frame)
    end
end

function CB.ShowBlizzardCastbar()
    for _, name in ipairs(BLIZZARD_CASTBAR_FRAMES) do
        local frame = _G[name]
        RestoreFrame(frame)
    end
    -- Note: re-registering all events properly would require a /reload
end

-- =====================================
-- LOCK/UNLOCK ALL CASTBARS
-- =====================================

function CB.ToggleLock()
    local anyUnlocked = false
    for _, cb in pairs(CB.castbars) do
        if not cb:IsLocked() then
            anyUnlocked = true
            break
        end
    end

    if anyUnlocked then
        -- Lock all
        for _, cb in pairs(CB.castbars) do
            cb:SetLocked(true)
            cb:HidePreview()
        end
        print("|cffd1b559TomoCastbar|r " .. L["CASTBARS_LOCKED"])
    else
        -- Unlock all
        for _, cb in pairs(CB.castbars) do
            cb:SetLocked(false)
            cb:ShowPreview()
        end
        print("|cffd1b559TomoCastbar|r " .. L["CASTBARS_UNLOCKED"])
    end
end

-- =====================================
-- REFRESH ALL (recreate after settings change)
-- =====================================

function CB.RefreshAll()
    -- Destroy existing castbars
    for unit, cb in pairs(CB.castbars) do
        if cb.eventFrame then
            cb.eventFrame:UnregisterAllEvents()
            cb.eventFrame:SetScript("OnEvent", nil)
        end
        cb:SetScript("OnUpdate", nil)
        cb:Hide()
        cb:SetParent(nil)
    end
    wipe(CB.castbars)

    -- Recreate
    CB.Initialize()
end
