-- TomoMythic / Config.lua

local _, TM = ...

-- ─────────────────────────────────────────────────────────────────────────────
--  BUILD CONFIG PANEL
-- ─────────────────────────────────────────────────────────────────────────────
function TM:BuildConfigPanel()
    if self.ConfigPanel then return end
    local L, C = self.L, self.C
    local W, H = 300, 434

    local P = CreateFrame("Frame", "TomoMythicConfig", UIParent, "BackdropTemplate")
    self.ConfigPanel = P
    P:SetSize(W, H)
    P:SetPoint("CENTER", UIParent, "CENTER", 280, 20)
    P:SetFrameStrata("HIGH")
    P:SetFrameLevel(200)
    P:SetMovable(true)
    P:EnableMouse(true)
    P:RegisterForDrag("LeftButton")
    P:SetClampedToScreen(true)
    P:SetScript("OnDragStart", function(s) s:StartMoving() end)
    P:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
    P:Hide()

    -- Outer shell — same as TomoMod config panels
    P:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    P:SetBackdropColor(0, 0, 0, 0.88)
    P:SetBackdropBorderColor(unpack(C.BORDER))

    -- Left accent strip
    local accent = P:CreateTexture(nil, "ARTWORK")
    accent:SetWidth(3)
    accent:SetPoint("TOPLEFT",    P, "TOPLEFT",    0, 0)
    accent:SetPoint("BOTTOMLEFT", P, "BOTTOMLEFT", 0, 0)
    accent:SetColorTexture(unpack(C.ACCENT))

    -- Header bar
    local hdrBG = P:CreateTexture(nil, "BACKGROUND")
    hdrBG:SetSize(W, 30)
    hdrBG:SetPoint("TOPLEFT", P, "TOPLEFT", 0, 0)
    hdrBG:SetColorTexture(unpack(C.BG_HEADER))

    local titleFS = self:MakeFS(P, 14, "OUTLINE")
    titleFS:SetPoint("LEFT", P, "TOPLEFT", 10, -15)
    titleFS:SetText("|cFF55B400Tomo|r|cFF3377CC" .. L.CONFIG_TITLE:gsub("TomoMythic","Mythic") .. "|r"
        .. "  |cFF445566v1.0.0|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, P)
    closeBtn:SetSize(22, 22)
    closeBtn:SetPoint("TOPRIGHT", P, "TOPRIGHT", -4, -4)
    local closeX = self:MakeFS(closeBtn, 13, "OUTLINE")
    closeX:SetPoint("CENTER")
    closeX:SetText("|cFFCC3322✕|r")
    closeBtn:SetScript("OnClick", function() TM:ToggleConfig() end)

    -- ── Helpers ───────────────────────────────────────────────────────────────
    local function SectionHdr(text, yOff)
        local lbl = TM:MakeFS(P, 10, "OUTLINE")
        lbl:SetPoint("TOPLEFT", P, "TOPLEFT", 10, yOff)
        lbl:SetText("|cFF3377CC" .. text:upper() .. "|r")
        lbl:SetTextColor(unpack(C.TEXT_BLUE))
        local line = P:CreateTexture(nil, "ARTWORK")
        line:SetSize(W - 12, 1)
        line:SetPoint("TOPLEFT", P, "TOPLEFT", 8, yOff - 13)
        line:SetColorTexture(0.15, 0.32, 0.55, 0.60)
    end

    local checkboxes = {}
    local function CB(label, yOff, dbKey, onChange)
        local cb = CreateFrame("CheckButton", nil, P, "UICheckButtonTemplate")
        cb:SetSize(18, 18)
        cb:SetPoint("TOPLEFT", P, "TOPLEFT", 10, yOff)
        cb:SetChecked(TM.db[dbKey])
        local lbl = TM:MakeFS(P, 12, "OUTLINE")
        lbl:SetPoint("LEFT", cb, "RIGHT", 3, 0)
        lbl:SetText(label)
        lbl:SetTextColor(unpack(C.TEXT_WHITE))
        cb:SetScript("OnClick", function(self)
            TM.db[dbKey] = (self:GetChecked() == true)
            if onChange then onChange(TM.db[dbKey]) end
        end)
        checkboxes[dbKey] = cb
        return cb
    end

    local sliders = {}
    local sliderCount = 0
    local function Slider(label, yOff, minV, maxV, step, dbKey, fmt, onChange)
        local lbl = TM:MakeFS(P, 10, "OUTLINE")
        lbl:SetPoint("TOPLEFT", P, "TOPLEFT", 10, yOff)
        lbl:SetText(label)
        lbl:SetTextColor(unpack(C.TEXT_GREY))

        -- Unique global name so OptionsSliderTemplate child refs work
        sliderCount = sliderCount + 1
        local slName = "TomoMythicConfigSlider" .. sliderCount
        local sl = CreateFrame("Slider", slName, P, "OptionsSliderTemplate")
        sl:SetSize(W - 60, 14)
        sl:SetPoint("TOPLEFT", P, "TOPLEFT", 10, yOff - 17)
        sl:SetMinMaxValues(minV, maxV)
        sl:SetValueStep(step)
        sl:SetObeyStepOnDrag(true)
        sl:SetValue(TM.db[dbKey])

        local lowLbl  = _G[slName .. "Low"]
        local highLbl = _G[slName .. "High"]
        if lowLbl  then lowLbl:SetText( fmt and string.format(fmt, minV) or tostring(minV)) end
        if highLbl then highLbl:SetText(fmt and string.format(fmt, maxV) or tostring(maxV)) end

        local valLbl = TM:MakeFS(P, 10, "OUTLINE")
        valLbl:SetPoint("LEFT", sl, "RIGHT", 4, 0)
        valLbl:SetText(fmt and string.format(fmt, TM.db[dbKey]) or tostring(TM.db[dbKey]))
        valLbl:SetTextColor(unpack(C.TEXT_GREEN))

        sl:SetScript("OnValueChanged", function(self, val)
            val = math.floor(val / step + 0.5) * step
            TM.db[dbKey] = val
            valLbl:SetText(fmt and string.format(fmt, val) or tostring(val))
            if onChange then onChange(val) end
        end)
        sliders[dbKey] = sl
        return sl
    end

    local function Btn(label, yOff, xOff, onClick)
        local b = CreateFrame("Button", nil, P, "BackdropTemplate")
        b:SetSize(118, 20)
        b:SetPoint("TOPLEFT", P, "TOPLEFT", xOff or 10, yOff)
        b:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
        b:SetBackdropColor(0.05, 0.12, 0.26, 0.92)
        b:SetBackdropBorderColor(unpack(C.BORDER_BLUE))
        local fs = TM:MakeFS(b, 11, "OUTLINE")
        fs:SetPoint("CENTER"); fs:SetText(label)
        fs:SetTextColor(unpack(C.TEXT_WHITE))
        b:SetScript("OnEnter", function(s) s:SetBackdropColor(0.10, 0.22, 0.44, 0.95) end)
        b:SetScript("OnLeave", function(s) s:SetBackdropColor(0.05, 0.12, 0.26, 0.92) end)
        b:SetScript("OnClick", onClick)
        return b
    end

    -- ── Layout ────────────────────────────────────────────────────────────────
    local y = -38
    SectionHdr(L.CFG_SECTION_DISPLAY, y) ; y = y - 20

    CB(L.CFG_SHOW_TIMER,  y, "showTimer",  function(v) if TM.Frame then TM.Frame.TimerBar:SetShown(v); TM:LayoutFrame() end end) ; y = y - 24
    CB(L.CFG_SHOW_FORCES, y, "showForces", function(v) if TM.Frame then TM.Frame.ForcesBar:SetShown(v); TM:LayoutFrame() end end) ; y = y - 24
    CB(L.CFG_SHOW_BOSSES, y, "showBosses", function() TM:UpdateBossRows(); TM:LayoutFrame() end) ; y = y - 24
    CB(L.CFG_HIDE_BLIZZARD, y, "hideBlizzard", function(v) if v and TM._inChallenge then TM:SuppressBlizzardUI() end end) ; y = y - 24
    CB(L.CFG_SHOW_INTERRUPT, y, "showInterrupt", function(v) TM:SetInterruptTrackerEnabled(v) end) ; y = y - 34

    SectionHdr(L.CFG_SECTION_FRAME, y) ; y = y - 20
    CB(L.CFG_LOCK, y, "locked", function(v) TM:SetMovable(not v) end) ; y = y - 30

    Slider(L.CFG_SCALE, y, 0.5, 2.0, 0.05, "scale", "%.2f", function(v) if TM.Frame then TM.Frame:SetScale(v) end end)
    y = y - 48

    Slider(L.CFG_ALPHA, y, 0.2, 1.0, 0.05, "alpha", "%.2f", function(v) if TM.Frame then TM.Frame:SetAlpha(v) end end)
    y = y - 44

    SectionHdr(L.CFG_SECTION_ACTIONS, y) ; y = y - 24

    Btn(L.CFG_PREVIEW,   y,  10, function() TM:Preview() end)
    Btn(L.CFG_RESET_POS, y, 150, function() TM:ResetPosition(); print(TM.L.RESET_MSG) end)

    -- Version footer
    local ver = TM:MakeFS(P, 9, "OUTLINE")
    ver:SetPoint("BOTTOMRIGHT", P, "BOTTOMRIGHT", -8, 6)
    ver:SetText("|cFF334455TomoMythic 1.0.0|r")

    -- Store for refresh
    P._checkboxes = checkboxes
    P._sliders    = sliders
end

-- ── Toggle ────────────────────────────────────────────────────────────────────
function TM:ToggleConfig()
    if not self.ConfigPanel then self:BuildConfigPanel() end
    if self.ConfigPanel:IsShown() then
        self.ConfigPanel:Hide()
    else
        -- Sync checkboxes to current db state
        if self.ConfigPanel._checkboxes then
            for key, cb in pairs(self.ConfigPanel._checkboxes) do
                cb:SetChecked(self.db[key])
            end
        end
        self.ConfigPanel:Show()
    end
end
