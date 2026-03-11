local ADDON_NAME, ns = ...
local L = ns.L

----------------------------------------------------------------------
-- Settings Panel
----------------------------------------------------------------------

local settingsFrame = nil

local function CreateSettingsPanel()
    local frame = CreateFrame("Frame", "TomoDamageMeterSettings", UIParent, "BackdropTemplate")
    frame:SetSize(340, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
    frame:SetClampedToScreen(true)

    frame:SetBackdrop({
        bgFile = ns.FLAT,
        edgeFile = ns.FLAT,
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.00, 0.00, 0.00, 0.88)
    frame:SetBackdropBorderColor(ns.BORDER_COLOR[1], ns.BORDER_COLOR[2], ns.BORDER_COLOR[3], ns.BORDER_COLOR[4])

    -- Title
    local title = frame:CreateFontString(nil, "ARTWORK")
    title:SetFont(ns.GetFont(), 13, "OUTLINE")
    title:SetTextColor(ns.ACCENT[1], ns.ACCENT[2], ns.ACCENT[3])
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetText(L["SETTINGS_TITLE"])

    -- Close button (texture)
    local closeBtn = CreateFrame("Button", nil, frame)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("TOPRIGHT", -6, -6)
    local closeIcon = closeBtn:CreateTexture(nil, "ARTWORK")
    closeIcon:SetTexture(ns.TEX_CLOSE)
    closeIcon:SetSize(10, 10)
    closeIcon:SetPoint("CENTER")
    closeIcon:SetVertexColor(unpack(ns.TEXT_MUTED))
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    closeBtn:SetScript("OnEnter", function() closeIcon:SetVertexColor(1, 1, 1) end)
    closeBtn:SetScript("OnLeave", function() closeIcon:SetVertexColor(unpack(ns.TEXT_MUTED)) end)

    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", 12, -36)
    content:SetPoint("BOTTOMRIGHT", -12, 12)

    local yOff = 0
    local function AddWidget(widget, height)
        widget:SetParent(content)
        widget:ClearAllPoints()
        widget:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOff)
        widget:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        yOff = yOff + (height or 50) + 6
    end

    -- Section label helper
    local function AddSection(text)
        local fs = content:CreateFontString(nil, "ARTWORK")
        fs:SetFont(ns.GetFont(), 11, "OUTLINE")
        fs:SetTextColor(ns.ACCENT[1], ns.ACCENT[2], ns.ACCENT[3])
        fs:SetPoint("TOPLEFT", content, "TOPLEFT", 0, -yOff)
        fs:SetText(text)
        yOff = yOff + 18
    end

    ----------------------------------------------------------------------
    -- Appearance
    ----------------------------------------------------------------------
    AddSection(L["SETTINGS_APPEARANCE"])

    -- Font Size
    local fontSlider = ns.Widgets.CreateSlider(content, L["SETTINGS_FONT_SIZE"],
        8, 16, 1,
        function() return ns.db.fontSize end,
        function(val)
            ns.db.fontSize = val
            ns.ClearCharWidthCache()
            for _, win in ipairs(ns.windows) do
                if win.RefreshFonts then win.RefreshFonts() end
                win.Refresh()
            end
        end)
    AddWidget(fontSlider, 50)

    -- Bar Height
    local barSlider = ns.Widgets.CreateSlider(content, L["SETTINGS_BAR_HEIGHT"],
        14, 32, 1,
        function() return ns.db.barHeight end,
        function(val)
            ns.db.barHeight = val
            for _, win in ipairs(ns.windows) do
                if win.RefreshBarHeight then win.RefreshBarHeight() end
            end
        end)
    AddWidget(barSlider, 50)

    -- BG Opacity
    local bgSlider = ns.Widgets.CreateSlider(content, L["SETTINGS_BG_OPACITY"],
        0, 1, 0.05,
        function() return ns.db.bgAlpha end,
        function(val)
            ns.db.bgAlpha = val
            for _, win in ipairs(ns.windows) do
                if win.SetBGAlpha then win.SetBGAlpha(val) end
            end
        end)
    AddWidget(bgSlider, 50)

    -- OOC Opacity
    local oocSlider = ns.Widgets.CreateSlider(content, L["SETTINGS_OOC_OPACITY"],
        0.1, 1, 0.05,
        function() return ns.db.oocAlpha end,
        function(val)
            ns.db.oocAlpha = val
            if not ns.inCombat then
                for _, win in ipairs(ns.windows) do
                    win.SetCombatAlpha(false)
                end
            end
        end)
    AddWidget(oocSlider, 50)

    ----------------------------------------------------------------------
    -- General
    ----------------------------------------------------------------------
    AddSection(L["SETTINGS_GENERAL"])

    -- Strip realm names
    local realmCB = ns.Widgets.CreateCheckbox(content, L["SETTINGS_STRIP_REALM"],
        function() return ns.db.stripRealm end,
        function(val) ns.db.stripRealm = val; ns.Refresh() end)
    AddWidget(realmCB, 24)

    -- Use class color for accent
    local classCB = ns.Widgets.CreateCheckbox(content, L["SETTINGS_USE_CLASS_COLOR"],
        function() return ns.db.accentUseClassColor end,
        function(val)
            ns.db.accentUseClassColor = val
            ns.ApplyAccentColor()
            for _, win in ipairs(ns.windows) do
                if win.RefreshAccentColor then win.RefreshAccentColor() end
            end
        end)
    AddWidget(classCB, 24)

    ----------------------------------------------------------------------
    -- Report
    ----------------------------------------------------------------------
    AddSection(L["REPORT"])

    local channelOptions = {
        { value = "SAY",     label = L["REPORT_CHANNEL_SAY"] },
        { value = "PARTY",   label = L["REPORT_CHANNEL_PARTY"] },
        { value = "RAID",    label = L["REPORT_CHANNEL_RAID"] },
        { value = "GUILD",   label = L["REPORT_CHANNEL_GUILD"] },
        { value = "WHISPER", label = L["REPORT_CHANNEL_WHISPER"] },
    }
    local channelDD = ns.Widgets.CreateDropdown(content, L["SETTINGS_REPORT_CHANNEL"],
        channelOptions,
        function() return ns.db.reportChannel end,
        function(val) ns.db.reportChannel = val end)
    AddWidget(channelDD, 30)

    local linesSlider = ns.Widgets.CreateSlider(content, L["SETTINGS_REPORT_LINES"],
        1, 20, 1,
        function() return ns.db.reportLines end,
        function(val) ns.db.reportLines = val end)
    AddWidget(linesSlider, 50)

    ----------------------------------------------------------------------
    -- Windows
    ----------------------------------------------------------------------
    AddSection(L["SETTINGS_WINDOWS"])

    local windowFrame = CreateFrame("Frame", nil, content)
    windowFrame:SetHeight(30)

    local windowCountFS = windowFrame:CreateFontString(nil, "ARTWORK")
    windowCountFS:SetFont(ns.GetFont(), 11, "OUTLINE")
    windowCountFS:SetTextColor(unpack(ns.TEXT_LABEL))
    windowCountFS:SetPoint("LEFT", 0, 0)

    local addBtn = CreateFrame("Button", nil, windowFrame)
    addBtn:SetSize(80, 22)
    addBtn:SetPoint("RIGHT", windowFrame, "RIGHT", 0, 0)

    local addBtnBG = addBtn:CreateTexture(nil, "BACKGROUND")
    addBtnBG:SetTexture(ns.FLAT)
    addBtnBG:SetVertexColor(0.05, 0.12, 0.26, 0.92)
    addBtnBG:SetAllPoints()

    local addBtnText = addBtn:CreateFontString(nil, "ARTWORK")
    addBtnText:SetFont(ns.GetFont(), 10, "OUTLINE")
    addBtnText:SetTextColor(unpack(ns.TEXT_PRIMARY))
    addBtnText:SetPoint("CENTER")
    addBtnText:SetText(L["SETTINGS_ADD_WINDOW"])

    local addHL = addBtn:CreateTexture(nil, "HIGHLIGHT")
    addHL:SetTexture(ns.FLAT); addHL:SetVertexColor(1, 1, 1, 0.08)
    addHL:SetAllPoints()

    local removeBtn = CreateFrame("Button", nil, windowFrame)
    removeBtn:SetSize(80, 22)
    removeBtn:SetPoint("RIGHT", addBtn, "LEFT", -4, 0)

    local removeBtnBG = removeBtn:CreateTexture(nil, "BACKGROUND")
    removeBtnBG:SetTexture(ns.FLAT)
    removeBtnBG:SetVertexColor(0.05, 0.12, 0.26, 0.92)
    removeBtnBG:SetAllPoints()

    local removeBtnText = removeBtn:CreateFontString(nil, "ARTWORK")
    removeBtnText:SetFont(ns.GetFont(), 10, "OUTLINE")
    removeBtnText:SetTextColor(unpack(ns.TEXT_PRIMARY))
    removeBtnText:SetPoint("CENTER")
    removeBtnText:SetText(L["SETTINGS_REMOVE_WINDOW"])

    local removeHL = removeBtn:CreateTexture(nil, "HIGHLIGHT")
    removeHL:SetTexture(ns.FLAT); removeHL:SetVertexColor(1, 1, 1, 0.08)
    removeHL:SetAllPoints()

    local function UpdateWindowButtons()
        local count = #ns.windows
        windowCountFS:SetText(string.format(L["SETTINGS_WINDOW_COUNT"], count, ns.MAX_WINDOWS))
        if count >= ns.MAX_WINDOWS then
            addBtnText:SetTextColor(unpack(ns.TEXT_MUTED))
        else
            addBtnText:SetTextColor(unpack(ns.TEXT_PRIMARY))
        end
        if count <= 1 then
            removeBtnText:SetTextColor(unpack(ns.TEXT_MUTED))
        else
            removeBtnText:SetTextColor(unpack(ns.TEXT_PRIMARY))
        end
    end
    UpdateWindowButtons()

    addBtn:SetScript("OnClick", function()
        if #ns.windows >= ns.MAX_WINDOWS then return end
        ns.CreateNewWindow()
        UpdateWindowButtons()
    end)

    removeBtn:SetScript("OnClick", function()
        if #ns.windows <= 1 then return end
        ns.RemoveWindow()
        UpdateWindowButtons()
    end)

    AddWidget(windowFrame, 30)

    frame:Hide()
    return frame
end

function ns.ToggleSettings()
    if not settingsFrame then
        settingsFrame = CreateSettingsPanel()
    end
    settingsFrame:SetShown(not settingsFrame:IsShown())
end