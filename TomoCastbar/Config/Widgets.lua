-- =====================================
-- Widgets.lua — Custom Config UI Widgets for TomoCastbar
-- Grey & Gold theme
-- =====================================

TomoCastbar_Widgets = {}
local W = TomoCastbar_Widgets

-- =====================================
-- THEME CONSTANTS
-- =====================================
W.Theme = {
    bg           = { 0.10, 0.10, 0.10, 0.97 },
    bgLight      = { 0.16, 0.15, 0.14, 1 },
    bgMid        = { 0.13, 0.12, 0.12, 1 },
    accent       = { 0.82, 0.71, 0.35, 1 },         -- gold
    accentDark   = { 0.65, 0.55, 0.25, 1 },
    accentHover  = { 0.92, 0.80, 0.42, 1 },
    border       = { 0.25, 0.24, 0.22, 1 },
    borderLight  = { 0.38, 0.36, 0.32, 1 },
    text         = { 0.88, 0.86, 0.82, 1 },
    textDim      = { 0.55, 0.52, 0.48, 1 },
    textHeader   = { 0.82, 0.71, 0.35, 1 },
    red          = { 0.90, 0.20, 0.20, 1 },
    yellow       = { 0.98, 0.82, 0.11, 1 },
    white        = { 1, 1, 1, 1 },
    separator    = { 0.28, 0.26, 0.22, 0.6 },
}

local T = W.Theme
local FONT = "Fonts\\FRIZQT__.TTF"
local FONT_BOLD = "Fonts\\FRIZQT__.TTF"

-- =====================================
-- HELPERS
-- =====================================

local function SetColor(texture, colorTable)
    texture:SetColorTexture(unpack(colorTable))
end

-- =====================================
-- PANEL: Scroll container
-- =====================================

function W.CreateScrollPanel(parent)
    local SCROLLBAR_W   = 6
    local SCROLLBAR_PAD = 10
    local TRACK_PAD_V   = 6
    local THUMB_MIN_H   = 24

    local container = CreateFrame("Frame", nil, parent)
    container:SetAllPoints()

    local track = container:CreateTexture(nil, "BACKGROUND")
    track:SetWidth(SCROLLBAR_W)
    track:SetPoint("TOPRIGHT",    -4, -TRACK_PAD_V)
    track:SetPoint("BOTTOMRIGHT", -4,  TRACK_PAD_V)
    track:SetColorTexture(0.15, 0.15, 0.18, 1)

    local thumbFrame = CreateFrame("Frame", nil, container)
    thumbFrame:SetWidth(SCROLLBAR_W)
    thumbFrame:SetPoint("TOPRIGHT", -4, -TRACK_PAD_V)

    local thumb = thumbFrame:CreateTexture(nil, "OVERLAY")
    thumb:SetAllPoints()
    thumb:SetColorTexture(unpack(T.accent))

    local scroll = CreateFrame("ScrollFrame", nil, container)
    scroll:SetPoint("TOPLEFT",     0,            0)
    scroll:SetPoint("BOTTOMRIGHT", -SCROLLBAR_PAD, 0)

    local child = CreateFrame("Frame", nil, scroll)
    child:SetWidth(scroll:GetWidth() or 440)
    child:SetHeight(1)
    scroll:SetScrollChild(child)

    local function UpdateThumb()
        local scrollH   = scroll:GetHeight() or 0
        local childH    = child:GetHeight() or 0
        local trackH    = scrollH - 2 * TRACK_PAD_V
        local maxScroll = childH - scrollH

        if maxScroll <= 0 then
            thumbFrame:Hide()
            track:Hide()
            return
        end

        track:Show()
        thumbFrame:Show()

        local ratio   = math.min(scrollH / childH, 1)
        local thumbH  = math.max(math.floor(trackH * ratio), THUMB_MIN_H)
        thumbFrame:SetHeight(thumbH)

        local cur     = scroll:GetVerticalScroll()
        local thumbY  = (cur / maxScroll) * (trackH - thumbH)
        thumbFrame:SetPoint("TOPRIGHT", -4, -(TRACK_PAD_V + thumbY))
    end

    scroll:EnableMouseWheel(true)
    scroll:SetScript("OnMouseWheel", function(self, delta)
        local cur = self:GetVerticalScroll()
        local max = self:GetVerticalScrollRange()
        self:SetVerticalScroll(math.max(0, math.min(cur - delta * 30, max)))
        UpdateThumb()
    end)

    local isDragging = false
    local dragStartY, dragStartScroll

    thumbFrame:EnableMouse(true)
    thumbFrame:RegisterForDrag("LeftButton")
    thumbFrame:SetScript("OnDragStart", function(self)
        isDragging = true
        dragStartY     = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
        dragStartScroll = scroll:GetVerticalScroll()
        self:SetScript("OnUpdate", function()
            local curY    = select(2, GetCursorPosition()) / UIParent:GetEffectiveScale()
            local delta   = dragStartY - curY
            local scrollH = scroll:GetHeight() or 0
            local childH  = child:GetHeight() or 0
            local trackH  = scrollH - 2 * TRACK_PAD_V
            local ratio   = math.min(scrollH / childH, 1)
            local thumbH  = math.max(math.floor(trackH * ratio), THUMB_MIN_H)
            local maxScroll = childH - scrollH
            local newScroll = dragStartScroll + delta * (maxScroll / (trackH - thumbH))
            scroll:SetVerticalScroll(math.max(0, math.min(newScroll, maxScroll)))
            UpdateThumb()
        end)
    end)
    thumbFrame:SetScript("OnDragStop", function(self)
        isDragging = false
        self:SetScript("OnUpdate", nil)
    end)

    thumbFrame:SetScript("OnEnter", function()
        thumb:SetColorTexture(unpack(T.accentHover))
    end)
    thumbFrame:SetScript("OnLeave", function()
        thumb:SetColorTexture(unpack(T.accent))
    end)

    scroll:SetScript("OnSizeChanged", function(self, w, h)
        child:SetWidth(math.max(w, 10))
        UpdateThumb()
    end)

    scroll:SetScript("OnShow", function(self)
        local w = self:GetWidth()
        if w and w > 0 then child:SetWidth(w) end
        UpdateThumb()
    end)

    container.UpdateScroll = UpdateThumb
    container.child = child
    container.scroll = scroll
    scroll.child = child
    scroll.UpdateScroll = UpdateThumb

    return scroll
end

-- =====================================
-- SECTION HEADER
-- =====================================

function W.CreateSectionHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY")
    header:SetFont(FONT_BOLD, 14, "")
    header:SetPoint("TOPLEFT", 16, yOffset)
    header:SetTextColor(unpack(T.textHeader))
    header:SetText(text)

    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", 16, yOffset - 20)
    sep:SetPoint("TOPRIGHT", -16, yOffset - 20)
    SetColor(sep, T.separator)

    return header, yOffset - 30
end

-- =====================================
-- SUBSECTION LABEL
-- =====================================

function W.CreateSubLabel(parent, text, yOffset)
    local label = parent:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 11, "")
    label:SetPoint("TOPLEFT", 16, yOffset)
    label:SetTextColor(unpack(T.textDim))
    label:SetText(text)
    return label, yOffset - 18
end

-- =====================================
-- CHECKBOX
-- =====================================

function W.CreateCheckbox(parent, text, checked, yOffset, callback)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(math.max(parent:GetWidth(), 440), 28)
    frame:SetPoint("TOPLEFT", 16, yOffset)

    local box = CreateFrame("Button", nil, frame)
    box:SetSize(18, 18)
    box:SetPoint("LEFT", 0, 0)

    local bg = box:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    SetColor(bg, T.bgLight)
    box.bg = bg

    local border = box:CreateTexture(nil, "BORDER")
    border:SetPoint("TOPLEFT", -1, 1)
    border:SetPoint("BOTTOMRIGHT", 1, -1)
    SetColor(border, T.border)
    box.border = border

    local check = box:CreateTexture(nil, "OVERLAY")
    check:SetSize(12, 12)
    check:SetPoint("CENTER")
    SetColor(check, T.accent)
    box.check = check

    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 11, "")
    label:SetPoint("LEFT", box, "RIGHT", 8, 0)
    label:SetTextColor(unpack(T.text))
    label:SetText(text)

    local isChecked = checked

    local function UpdateVisual()
        if isChecked then
            SetColor(check, T.accent)
            check:Show()
            SetColor(border, T.accentDark)
        else
            check:Hide()
            SetColor(border, T.border)
        end
    end
    UpdateVisual()

    box:SetScript("OnClick", function()
        isChecked = not isChecked
        UpdateVisual()
        if callback then callback(isChecked) end
    end)

    box:SetScript("OnEnter", function()
        SetColor(border, T.borderLight)
    end)
    box:SetScript("OnLeave", function()
        if isChecked then
            SetColor(border, T.accentDark)
        else
            SetColor(border, T.border)
        end
    end)

    frame.SetChecked = function(_, val)
        isChecked = val
        UpdateVisual()
    end
    frame.GetChecked = function()
        return isChecked
    end

    return frame, yOffset - 30
end

-- =====================================
-- SLIDER
-- =====================================

function W.CreateSlider(parent, text, value, minVal, maxVal, step, yOffset, callback, formatStr)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(math.max(parent:GetWidth(), 440), 50)
    frame:SetPoint("TOPLEFT", 16, yOffset)

    formatStr = formatStr or "%.0f"

    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 11, "")
    label:SetPoint("TOPLEFT", 0, 0)
    label:SetTextColor(unpack(T.text))

    local valText = frame:CreateFontString(nil, "OVERLAY")
    valText:SetFont(FONT, 11, "")
    valText:SetPoint("TOPRIGHT", -30, 0)
    valText:SetTextColor(unpack(T.accent))

    local function UpdateLabel(v)
        label:SetText(text)
        valText:SetText(string.format(formatStr, v))
    end
    UpdateLabel(value)

    local slider = CreateFrame("Slider", nil, frame, "BackdropTemplate")
    slider:SetOrientation("HORIZONTAL")
    slider:SetSize(380, 8)
    slider:SetPoint("TOPLEFT", 0, -18)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(value)

    local trackBg = slider:CreateTexture(nil, "BACKGROUND")
    trackBg:SetAllPoints()
    SetColor(trackBg, T.bgLight)

    slider:SetThumbTexture("Interface\\Buttons\\WHITE8x8")
    local thumbTex = slider:GetThumbTexture()
    thumbTex:SetSize(12, 14)
    thumbTex:SetVertexColor(unpack(T.accent))

    slider:SetScript("OnValueChanged", function(self, val)
        val = math.floor(val / step + 0.5) * step
        UpdateLabel(val)
        if callback then callback(val) end
    end)

    slider:SetScript("OnEnter", function()
        thumbTex:SetVertexColor(unpack(T.accentHover))
    end)
    slider:SetScript("OnLeave", function()
        thumbTex:SetVertexColor(unpack(T.accent))
    end)

    frame.slider = slider
    frame.SetValue = function(_, v) slider:SetValue(v); UpdateLabel(v) end
    frame.GetValue = function() return slider:GetValue() end

    return frame, yOffset - 52
end

-- =====================================
-- COLOR PICKER BUTTON
-- =====================================

function W.CreateColorPicker(parent, text, color, yOffset, callback)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(math.max(parent:GetWidth(), 440), 30)
    frame:SetPoint("TOPLEFT", 16, yOffset)

    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 11, "")
    label:SetPoint("LEFT", 0, 0)
    label:SetTextColor(unpack(T.text))
    label:SetText(text)

    local swatch = CreateFrame("Button", nil, frame, "BackdropTemplate")
    swatch:SetSize(24, 18)
    swatch:SetPoint("LEFT", label, "RIGHT", 10, 0)
    swatch:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    swatch:SetBackdropColor(color.r, color.g, color.b, 1)
    swatch:SetBackdropBorderColor(unpack(T.border))

    local rgbText = frame:CreateFontString(nil, "OVERLAY")
    rgbText:SetFont(FONT, 10, "")
    rgbText:SetPoint("LEFT", swatch, "RIGHT", 6, 0)
    rgbText:SetTextColor(unpack(T.textDim))

    local function UpdateRGB(r, g, b)
        swatch:SetBackdropColor(r, g, b, 1)
        rgbText:SetText(string.format("(%d, %d, %d)", r * 255, g * 255, b * 255))
    end
    UpdateRGB(color.r, color.g, color.b)

    swatch:SetScript("OnClick", function()
        local prev = { color.r, color.g, color.b }
        local function OnChanged()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            UpdateRGB(r, g, b)
            if callback then callback(r, g, b) end
        end
        local function OnCancel()
            UpdateRGB(prev[1], prev[2], prev[3])
            if callback then callback(prev[1], prev[2], prev[3]) end
        end

        if ColorPickerFrame.SetupColorPickerAndShow then
            local info = {
                swatchFunc = OnChanged,
                cancelFunc = OnCancel,
                r = color.r,
                g = color.g,
                b = color.b,
                hasOpacity = false,
            }
            ColorPickerFrame:SetupColorPickerAndShow(info)
        else
            ColorPickerFrame:SetColorRGB(color.r, color.g, color.b)
            ColorPickerFrame.hasOpacity = false
            ColorPickerFrame.func = OnChanged
            ColorPickerFrame.cancelFunc = OnCancel
            ColorPickerFrame:Hide()
            ColorPickerFrame:Show()
        end
    end)

    frame.UpdateColor = function(_, r, g, b)
        color.r, color.g, color.b = r, g, b
        UpdateRGB(r, g, b)
    end

    return frame, yOffset - 32
end

-- =====================================
-- DROPDOWN SELECTOR
-- =====================================

function W.CreateDropdown(parent, text, options, selectedKey, yOffset, callback)
    -- options = { { key = "abc", label = "Abc" }, ... }
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetSize(math.max(parent:GetWidth(), 440), 30)
    frame:SetPoint("TOPLEFT", 16, yOffset)

    local label = frame:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT, 11, "")
    label:SetPoint("LEFT", 0, 0)
    label:SetTextColor(unpack(T.text))
    label:SetText(text)

    -- Find current label
    local currentLabel = selectedKey or ""
    for _, opt in ipairs(options) do
        if opt.key == selectedKey then
            currentLabel = opt.label
            break
        end
    end

    local btn = CreateFrame("Button", nil, frame, "BackdropTemplate")
    btn:SetSize(180, 22)
    btn:SetPoint("LEFT", label, "RIGHT", 10, 0)
    btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    btn:SetBackdropColor(unpack(T.bgLight))
    btn:SetBackdropBorderColor(unpack(T.border))

    local btnText = btn:CreateFontString(nil, "OVERLAY")
    btnText:SetFont(FONT, 10, "")
    btnText:SetPoint("LEFT", 6, 0)
    btnText:SetPoint("RIGHT", -16, 0)
    btnText:SetJustifyH("LEFT")
    btnText:SetTextColor(unpack(T.accent))
    btnText:SetText(currentLabel)

    local arrow = btn:CreateFontString(nil, "OVERLAY")
    arrow:SetFont(FONT, 10, "")
    arrow:SetPoint("RIGHT", -4, 0)
    arrow:SetTextColor(unpack(T.textDim))
    arrow:SetText("▼")

    -- Dropdown menu frame
    local menu = CreateFrame("Frame", nil, btn, "BackdropTemplate")
    menu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    menu:SetBackdropColor(0.08, 0.08, 0.10, 0.98)
    menu:SetBackdropBorderColor(unpack(T.border))
    menu:SetPoint("TOPLEFT", btn, "BOTTOMLEFT", 0, -2)
    menu:SetWidth(btn:GetWidth())
    menu:SetFrameStrata("TOOLTIP")
    menu:Hide()

    local itemHeight = 20
    menu:SetHeight(#options * itemHeight + 4)

    for i, opt in ipairs(options) do
        local item = CreateFrame("Button", nil, menu)
        item:SetSize(menu:GetWidth() - 2, itemHeight)
        item:SetPoint("TOPLEFT", 1, -(i - 1) * itemHeight - 2)

        local itemBg = item:CreateTexture(nil, "BACKGROUND")
        itemBg:SetAllPoints()
        itemBg:SetColorTexture(0, 0, 0, 0)

        local itemLabel = item:CreateFontString(nil, "OVERLAY")
        itemLabel:SetFont(FONT, 10, "")
        itemLabel:SetPoint("LEFT", 6, 0)
        itemLabel:SetTextColor(unpack(T.text))
        itemLabel:SetText(opt.label)

        item:SetScript("OnEnter", function()
            itemBg:SetColorTexture(unpack(T.accentDark))
        end)
        item:SetScript("OnLeave", function()
            itemBg:SetColorTexture(0, 0, 0, 0)
        end)
        item:SetScript("OnClick", function()
            btnText:SetText(opt.label)
            menu:Hide()
            if callback then callback(opt.key) end
        end)
    end

    btn:SetScript("OnClick", function()
        if menu:IsShown() then
            menu:Hide()
        else
            menu:Show()
        end
    end)

    btn:SetScript("OnEnter", function()
        btn:SetBackdropBorderColor(unpack(T.borderLight))
    end)
    btn:SetScript("OnLeave", function()
        if not menu:IsShown() then
            btn:SetBackdropBorderColor(unpack(T.border))
        end
    end)

    -- Close menu when clicking elsewhere
    menu:SetScript("OnShow", function(self)
        self:SetScript("OnUpdate", function(self2)
            if not self2:IsMouseOver() and not btn:IsMouseOver() and IsMouseButtonDown("LeftButton") then
                self2:Hide()
            end
        end)
    end)
    menu:SetScript("OnHide", function(self)
        self:SetScript("OnUpdate", nil)
        btn:SetBackdropBorderColor(unpack(T.border))
    end)

    frame.SetSelected = function(_, key)
        for _, opt in ipairs(options) do
            if opt.key == key then
                btnText:SetText(opt.label)
                break
            end
        end
    end

    return frame, yOffset - 32
end

-- =====================================
-- BUTTON
-- =====================================

function W.CreateButton(parent, text, width, yOffset, callback)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(width or 140, 28)
    btn:SetPoint("TOPLEFT", 16, yOffset)
    btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    btn:SetBackdropColor(unpack(T.accentDark))
    btn:SetBackdropBorderColor(unpack(T.accent))

    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont(FONT_BOLD, 11, "")
    label:SetPoint("CENTER")
    label:SetTextColor(1, 1, 1, 1)
    label:SetText(text)

    btn:SetScript("OnEnter", function()
        btn:SetBackdropColor(unpack(T.accent))
        label:SetTextColor(0.08, 0.08, 0.10, 1)
    end)
    btn:SetScript("OnLeave", function()
        btn:SetBackdropColor(unpack(T.accentDark))
        label:SetTextColor(1, 1, 1, 1)
    end)
    btn:SetScript("OnClick", function()
        if callback then callback() end
    end)

    return btn, yOffset - 36
end

-- =====================================
-- SEPARATOR
-- =====================================

function W.CreateSeparator(parent, yOffset)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT", 16, yOffset)
    sep:SetPoint("TOPRIGHT", -16, yOffset)
    SetColor(sep, T.separator)
    return sep, yOffset - 12
end

-- =====================================
-- INFO TEXT
-- =====================================

function W.CreateInfoText(parent, text, yOffset)
    local info = parent:CreateFontString(nil, "OVERLAY")
    info:SetFont(FONT, 10, "")
    info:SetPoint("TOPLEFT", 24, yOffset)
    info:SetWidth(parent:GetWidth() - 48)
    info:SetJustifyH("LEFT")
    info:SetTextColor(unpack(T.textDim))
    info:SetText(text)
    local lines = math.ceil(info:GetStringHeight() / 12)
    return info, yOffset - (lines * 14 + 6)
end

-- =====================================
-- TAB PANEL (sub-tabs)
-- =====================================

function W.CreateTabPanel(parent, tabs)
    local wrapper = CreateFrame("Frame", nil, parent)
    wrapper:SetAllPoints()

    local TABS_PER_ROW = 5
    local totalTabs = #tabs
    local numRows = math.ceil(totalTabs / TABS_PER_ROW)

    local singleRowHeight = 34
    local tabBarHeight = singleRowHeight * numRows
    local tabBar = CreateFrame("Frame", nil, wrapper)
    tabBar:SetPoint("TOPLEFT", 0, 0)
    tabBar:SetPoint("TOPRIGHT", 0, 0)
    tabBar:SetHeight(tabBarHeight)

    local tabBarBg = tabBar:CreateTexture(nil, "BACKGROUND")
    tabBarBg:SetAllPoints()
    tabBarBg:SetColorTexture(0.06, 0.06, 0.08, 1)

    local tabBarSep = tabBar:CreateTexture(nil, "ARTWORK")
    tabBarSep:SetHeight(1)
    tabBarSep:SetPoint("BOTTOMLEFT", 0, 0)
    tabBarSep:SetPoint("BOTTOMRIGHT", 0, 0)
    tabBarSep:SetColorTexture(unpack(T.border))

    local content = CreateFrame("Frame", nil, wrapper)
    content:SetPoint("TOPLEFT", 0, -tabBarHeight)
    content:SetPoint("BOTTOMRIGHT", 0, 0)

    local tabButtons = {}
    local tabPanels = {}
    local currentTab = nil

    local function SwitchTab(key)
        if currentTab == key then return end

        for _, panel in pairs(tabPanels) do
            panel:Hide()
        end

        for tabKey, btn in pairs(tabButtons) do
            if tabKey == key then
                btn.bg:SetColorTexture(unpack(T.bgLight))
                btn.indicator:Show()
                btn.label:SetTextColor(unpack(T.accent))
            else
                btn.bg:SetColorTexture(0, 0, 0, 0)
                btn.indicator:Hide()
                btn.label:SetTextColor(unpack(T.textDim))
            end
        end

        if not tabPanels[key] then
            for _, tab in ipairs(tabs) do
                if tab.key == key and tab.builder then
                    local panel = tab.builder(content)
                    panel:SetAllPoints(content)
                    tabPanels[key] = panel
                    break
                end
            end
        end

        if tabPanels[key] then
            tabPanels[key]:Show()
        end

        currentTab = key
    end

    local tabsInFirstRow = math.min(totalTabs, TABS_PER_ROW)
    local tabWidth = math.floor(math.max(parent:GetWidth(), 540) / tabsInFirstRow)
    tabWidth = math.min(tabWidth, 120)

    for i, tab in ipairs(tabs) do
        local row = math.floor((i - 1) / TABS_PER_ROW)
        local col = (i - 1) % TABS_PER_ROW
        local tabsInThisRow = math.min(TABS_PER_ROW, totalTabs - row * TABS_PER_ROW)
        local rowTabWidth = math.floor(math.max(parent:GetWidth(), 540) / tabsInThisRow)
        rowTabWidth = math.min(rowTabWidth, 120)

        local btn = CreateFrame("Button", nil, tabBar)
        btn:SetSize(rowTabWidth, singleRowHeight)
        btn:SetPoint("TOPLEFT", col * rowTabWidth, -(row * singleRowHeight))

        local bg = btn:CreateTexture(nil, "BACKGROUND", nil, 1)
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0)
        btn.bg = bg

        local indicator = btn:CreateTexture(nil, "OVERLAY")
        indicator:SetHeight(2)
        indicator:SetPoint("BOTTOMLEFT", 4, 0)
        indicator:SetPoint("BOTTOMRIGHT", -4, 0)
        indicator:SetColorTexture(unpack(T.accent))
        indicator:Hide()
        btn.indicator = indicator

        local labelFS = btn:CreateFontString(nil, "OVERLAY")
        labelFS:SetFont(FONT, 11, "")
        labelFS:SetPoint("CENTER", 0, 1)
        labelFS:SetTextColor(unpack(T.textDim))
        labelFS:SetText(tab.label)
        btn.label = labelFS

        btn:SetScript("OnEnter", function()
            if currentTab ~= tab.key then
                bg:SetColorTexture(0.10, 0.10, 0.13, 0.5)
            end
        end)
        btn:SetScript("OnLeave", function()
            if currentTab ~= tab.key then
                bg:SetColorTexture(0, 0, 0, 0)
            end
        end)
        btn:SetScript("OnClick", function()
            SwitchTab(tab.key)
        end)

        tabButtons[tab.key] = btn
    end

    if #tabs > 0 then
        SwitchTab(tabs[1].key)
    end

    wrapper.SwitchTab = SwitchTab
    wrapper.content = content
    return wrapper
end
