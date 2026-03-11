-- TomoPartyFrame Widgets
-- Reusable UI widget creators for the options panel

local ADDON, ns = ...

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip

-- ============================================================================
-- CONSTANTS
-- ============================================================================

local WIDGET_HEIGHT = 24
local LABEL_WIDTH = 180
local SLIDER_WIDTH = 200
local DROPDOWN_WIDTH = 160
local SPACING = 6
local INDENT = 20

-- ============================================================================
-- TOOLTIP HELPERS
-- ============================================================================

local function ShowTooltip(widget, title, desc)
    GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")
    GameTooltip:AddLine(title, 1, 1, 1)
    if desc then
        GameTooltip:AddLine(desc, 0.8, 0.8, 0.8, true)
    end
    GameTooltip:Show()
end

local function HideTooltip()
    GameTooltip:Hide()
end

-- ============================================================================
-- HEADER
-- ============================================================================

function ns:CreateHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    header:SetText(text)
    header:SetTextColor(1, 0.82, 0)
    return header
end

-- ============================================================================
-- SEPARATOR
-- ============================================================================

function ns:CreateSeparator(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset or 0)
    line:SetHeight(1)
    line:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    return line
end

-- ============================================================================
-- CHECKBOX
-- ============================================================================

function ns:CreateCheckbox(parent, label, settingKey, yOffset, tooltip, onChange)
    local L = ns.L

    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    check:SetSize(26, 26)

    local text = check:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", check, "RIGHT", 4, 0)
    text:SetText(label)
    check.label = text

    local value = ns:GetSetting(settingKey)
    check:SetChecked(value == true)

    check:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        ns:SetSetting(settingKey, checked)
        if onChange then onChange(checked) end
        ns:RefreshAll()
    end)

    if tooltip then
        check:SetScript("OnEnter", function(self)
            ShowTooltip(self, label, tooltip)
        end)
        check:SetScript("OnLeave", HideTooltip)
    end

    check.settingKey = settingKey
    check.Refresh = function(self)
        self:SetChecked(ns:GetSetting(settingKey) == true)
    end

    return check
end

-- ============================================================================
-- SLIDER
-- ============================================================================

function ns:CreateSlider(parent, label, settingKey, minVal, maxVal, step, yOffset, tooltip, onChange)
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    container:SetSize(LABEL_WIDTH + SLIDER_WIDTH + 80, WIDGET_HEIGHT + 16)

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("TOPLEFT", 0, 0)
    text:SetText(label)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", 0, -18)
    slider:SetWidth(SLIDER_WIDTH)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)

    slider.Low:SetText(minVal)
    slider.High:SetText(maxVal)

    local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    valueText:SetPoint("LEFT", slider, "RIGHT", 8, 0)

    local currentVal = ns:GetSetting(settingKey) or minVal
    slider:SetValue(currentVal)
    valueText:SetText(currentVal)

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value / step + 0.5) * step
        valueText:SetText(value)
        ns:SetSetting(settingKey, value)
        if onChange then onChange(value) end
        ns:RefreshAll()
    end)

    if tooltip then
        slider:SetScript("OnEnter", function(self)
            ShowTooltip(self, label, tooltip)
        end)
        slider:SetScript("OnLeave", HideTooltip)
    end

    container.slider = slider
    container.valueText = valueText
    container.settingKey = settingKey
    container.Refresh = function(self)
        local v = ns:GetSetting(settingKey) or minVal
        self.slider:SetValue(v)
        self.valueText:SetText(v)
    end

    return container
end

-- ============================================================================
-- DROPDOWN
-- ============================================================================

function ns:CreateDropdown(parent, label, settingKey, options, yOffset, tooltip, onChange)
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    container:SetSize(LABEL_WIDTH + DROPDOWN_WIDTH + 20, WIDGET_HEIGHT + 4)

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 0, 0)
    text:SetText(label)

    -- Simple dropdown using a button + menu frame
    local dropBtn = CreateFrame("Button", nil, container, "BackdropTemplate")
    dropBtn:SetPoint("LEFT", text, "RIGHT", 10, 0)
    dropBtn:SetSize(DROPDOWN_WIDTH, 22)
    dropBtn:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    dropBtn:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    dropBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local selectedText = dropBtn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    selectedText:SetPoint("LEFT", 6, 0)
    selectedText:SetPoint("RIGHT", -20, 0)
    selectedText:SetJustifyH("LEFT")

    local arrow = dropBtn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("RIGHT", -4, 0)
    arrow:SetSize(12, 12)
    arrow:SetTexture("Interface\\ChatFrame\\ChatFrameExpandArrow")

    -- Find display text
    local function UpdateDisplay()
        local current = ns:GetSetting(settingKey)
        for _, opt in ipairs(options) do
            if opt.value == current then
                selectedText:SetText(opt.label)
                return
            end
        end
        selectedText:SetText(tostring(current))
    end
    UpdateDisplay()

    -- Menu frame
    local menuFrame = CreateFrame("Frame", nil, dropBtn, "BackdropTemplate")
    menuFrame:SetFrameStrata("DIALOG")
    menuFrame:SetFrameLevel(100)
    menuFrame:SetPoint("TOPLEFT", dropBtn, "BOTTOMLEFT", 0, -2)
    menuFrame:SetWidth(DROPDOWN_WIDTH)
    menuFrame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 8,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    menuFrame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    menuFrame:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    menuFrame:Hide()

    local menuHeight = 4
    for idx, opt in ipairs(options) do
        local item = CreateFrame("Button", nil, menuFrame)
        item:SetSize(DROPDOWN_WIDTH - 8, 20)
        item:SetPoint("TOPLEFT", 4, -(4 + (idx - 1) * 20))

        local itemText = item:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        itemText:SetPoint("LEFT", 4, 0)
        itemText:SetText(opt.label)

        item:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")

        item:SetScript("OnClick", function()
            ns:SetSetting(settingKey, opt.value)
            UpdateDisplay()
            menuFrame:Hide()
            if onChange then onChange(opt.value) end
            ns:RefreshAll()
        end)

        menuHeight = menuHeight + 20
    end
    menuFrame:SetHeight(menuHeight + 4)

    dropBtn:SetScript("OnClick", function()
        if menuFrame:IsShown() then
            menuFrame:Hide()
        else
            menuFrame:Show()
        end
    end)

    -- Close menu when clicking elsewhere
    menuFrame:SetScript("OnShow", function(self)
        self:SetPropagateKeyboardInput(true)
    end)

    if tooltip then
        dropBtn:SetScript("OnEnter", function(self)
            ShowTooltip(self, label, tooltip)
        end)
        dropBtn:SetScript("OnLeave", HideTooltip)
    end

    container.dropBtn = dropBtn
    container.menuFrame = menuFrame
    container.settingKey = settingKey
    container.UpdateDisplay = UpdateDisplay
    container.Refresh = function(self)
        self.UpdateDisplay()
    end

    return container
end

-- ============================================================================
-- COLOR PICKER
-- ============================================================================

function ns:CreateColorPicker(parent, label, settingKey, yOffset, tooltip, onChange)
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    container:SetSize(LABEL_WIDTH + 40, WIDGET_HEIGHT)

    local text = container:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    text:SetPoint("LEFT", 0, 0)
    text:SetText(label)

    local swatch = CreateFrame("Button", nil, container, "BackdropTemplate")
    swatch:SetPoint("LEFT", text, "RIGHT", 8, 0)
    swatch:SetSize(20, 20)
    swatch:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 4,
        insets = { left = 1, right = 1, top = 1, bottom = 1 },
    })

    local colorTex = swatch:CreateTexture(nil, "ARTWORK")
    colorTex:SetPoint("TOPLEFT", 2, -2)
    colorTex:SetPoint("BOTTOMRIGHT", -2, 2)

    local function UpdateSwatch()
        local c = ns:GetSetting(settingKey) or { r = 1, g = 1, b = 1, a = 1 }
        colorTex:SetColorTexture(c.r, c.g, c.b, c.a or 1)
    end
    UpdateSwatch()

    swatch:SetScript("OnClick", function()
        local c = ns:GetSetting(settingKey) or { r = 1, g = 1, b = 1, a = 1 }
        local hasAlpha = (c.a ~= nil)

        local info = {}
        info.r = c.r
        info.g = c.g
        info.b = c.b
        info.opacity = c.a or 1
        info.hasOpacity = hasAlpha

        info.swatchFunc = function()
            local r, g, b = ColorPickerFrame:GetColorRGB()
            local a = 1
            if hasAlpha and OpacitySliderFrame then
                a = OpacitySliderFrame:GetValue()
            end
            ns:SetSetting(settingKey, { r = r, g = g, b = b, a = a })
            UpdateSwatch()
            if onChange then onChange({ r = r, g = g, b = b, a = a }) end
            ns:RefreshAll()
        end

        info.cancelFunc = function(prev)
            ns:SetSetting(settingKey, { r = prev.r, g = prev.g, b = prev.b, a = prev.opacity or 1 })
            UpdateSwatch()
            ns:RefreshAll()
        end

        ColorPickerFrame:SetupColorPickerAndShow(info)
    end)

    if tooltip then
        swatch:SetScript("OnEnter", function(self)
            ShowTooltip(self, label, tooltip)
        end)
        swatch:SetScript("OnLeave", HideTooltip)
    end

    container.swatch = swatch
    container.settingKey = settingKey
    container.Refresh = function(self)
        UpdateSwatch()
    end

    return container
end

-- ============================================================================
-- BUTTON
-- ============================================================================

function ns:CreateButton(parent, label, yOffset, onClick, width, tooltip)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset or 0)
    btn:SetSize(width or 120, 24)
    btn:SetText(label)

    btn:SetScript("OnClick", function()
        if onClick then onClick() end
    end)

    if tooltip then
        btn:SetScript("OnEnter", function(self)
            ShowTooltip(self, label, tooltip)
        end)
        btn:SetScript("OnLeave", HideTooltip)
    end

    return btn
end

-- ============================================================================
-- COLLAPSIBLE SECTION
-- ============================================================================

function ns:CreateCollapsibleSection(parent, title, yOffset)
    local section = CreateFrame("Frame", nil, parent)
    section:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset or 0)
    section:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
    section:SetHeight(24)

    local headerBtn = CreateFrame("Button", nil, section)
    headerBtn:SetPoint("TOPLEFT", 10, 0)
    headerBtn:SetSize(300, 20)

    local arrow = headerBtn:CreateTexture(nil, "OVERLAY")
    arrow:SetPoint("LEFT", 0, 0)
    arrow:SetSize(12, 12)

    local headerText = headerBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    headerText:SetPoint("LEFT", arrow, "RIGHT", 4, 0)
    headerText:SetText(title)
    headerText:SetTextColor(1, 0.82, 0)

    section.content = CreateFrame("Frame", nil, section)
    section.content:SetPoint("TOPLEFT", 0, -24)
    section.content:SetPoint("RIGHT", 0, 0)
    section.content:SetHeight(1)

    section.expanded = true
    section.widgets = {}

    local function UpdateArrow()
        if section.expanded then
            arrow:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
        else
            arrow:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
        end
    end
    UpdateArrow()

    headerBtn:SetScript("OnClick", function()
        section.expanded = not section.expanded
        UpdateArrow()
        if section.expanded then
            section.content:Show()
        else
            section.content:Hide()
        end
        if section.onToggle then section.onToggle(section.expanded) end
    end)

    section.headerBtn = headerBtn
    return section
end
