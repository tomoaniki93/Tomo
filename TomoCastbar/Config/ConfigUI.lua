-- =====================================
-- ConfigUI.lua — Config Panel for TomoCastbar
-- Sidebar navigation, dark modern theme
-- =====================================

TomoCastbar_Config = TomoCastbar_Config or {}
local C = TomoCastbar_Config
local W = TomoCastbar_Widgets
local T = W.Theme
local L = TomoCastbar_L

local FONT = "Fonts\\FRIZQT__.TTF"
local FONT_BOLD = "Fonts\\FRIZQT__.TTF"

local configFrame
local currentCategory = nil
local categoryPanels = {}
local categoryButtons = {}

-- =====================================
-- HELPER: Refresh all castbars after settings change
-- =====================================
local function RefreshCastbars()
    if TomoCastbar_Module and TomoCastbar_Module.RefreshAll then
        TomoCastbar_Module.RefreshAll()
    end
end

-- =====================================
-- PANEL BUILDERS
-- =====================================

-- ===== GENERAL SETTINGS =====
local function BuildGeneralPanel(parent)
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local db = TomoCastbarDB
    if not db then return scroll end

    local y = -10

    local _, ny = W.CreateSectionHeader(c, L["HEADER_GENERAL"], y)
    y = ny

    local _, ny = W.CreateCheckbox(c, L["HIDE_BLIZZARD"], db.hideBlizzardCastbar, y, function(v)
        db.hideBlizzardCastbar = v
        if v then
            TomoCastbar_Module.HideBlizzardCastbar()
        else
            TomoCastbar_Module.ShowBlizzardCastbar()
        end
    end)
    y = ny

    -- Textures
    local _, ny = W.CreateSeparator(c, y)
    y = ny
    local _, ny = W.CreateSectionHeader(c, L["HEADER_TEXTURES"], y)
    y = ny

    local bgOptions = {
        { key = "custom",      label = L["BG_CUSTOM"] },
        { key = "black",       label = L["BG_BLACK"] },
        { key = "transparent", label = L["BG_TRANSPARENT"] },
    }
    local _, ny = W.CreateDropdown(c, L["BACKGROUND_MODE"], bgOptions, db.backgroundMode or "custom", y, function(key)
        db.backgroundMode = key
        RefreshCastbars()
    end)
    y = ny

    local texOptions = {
        { key = "blizzard", label = L["TEX_BLIZZARD"] },
        { key = "smooth",   label = L["TEX_SMOOTH"] },
        { key = "flat",     label = L["TEX_FLAT"] },
    }
    local _, ny = W.CreateDropdown(c, L["BAR_TEXTURE"], texOptions, db.barTexture or "blizzard", y, function(key)
        db.barTexture = key
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, L["CUSTOM_BORDER"], db.useCustomBorder, y, function(v)
        db.useCustomBorder = v
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, L["SHOW_SPARK"], db.showSpark, y, function(v)
        db.showSpark = v
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, L["SHOW_CHANNEL_TICKS"], db.showChannelTicks, y, function(v)
        db.showChannelTicks = v
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, L["SLIDER_SPARK_HEIGHT"], db.sparkHeight or 26, 12, 50, 1, y, function(v)
        db.sparkHeight = v
        RefreshCastbars()
    end)
    y = ny

    -- Colors
    local _, ny = W.CreateSeparator(c, y)
    y = ny
    local _, ny = W.CreateSectionHeader(c, L["HEADER_COLORS"], y)
    y = ny

    local _, ny = W.CreateColorPicker(c, L["COLOR_CAST"], db.castbarColor, y, function(r, g, b)
        db.castbarColor.r = r
        db.castbarColor.g = g
        db.castbarColor.b = b
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, L["COLOR_NI"], db.castbarNIColor, y, function(r, g, b)
        db.castbarNIColor.r = r
        db.castbarNIColor.g = g
        db.castbarNIColor.b = b
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, L["COLOR_INTERRUPTED"], db.castbarInterruptColor, y, function(r, g, b)
        db.castbarInterruptColor.r = r
        db.castbarInterruptColor.g = g
        db.castbarInterruptColor.b = b
        RefreshCastbars()
    end)
    y = ny

    -- Font Size
    local _, ny = W.CreateSeparator(c, y)
    y = ny
    local _, ny = W.CreateSubLabel(c, L["SUBLABEL_FONTSIZE"], y)
    y = ny

    local _, ny = W.CreateSlider(c, L["SLIDER_FONTSIZE"], db.fontSize, 8, 24, 1, y, function(v)
        db.fontSize = v
        RefreshCastbars()
    end)
    y = ny

    -- Reset
    local _, ny = W.CreateSeparator(c, y)
    y = ny

    local _, ny = W.CreateButton(c, L["RESET_ALL"], 220, y, function()
        TomoCastbar_ResetDatabase()
        RefreshCastbars()
        -- Close & reopen config to refresh widgets
        C.Hide()
        C.configDirty = true
    end)
    y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- ===== PER-UNIT CASTBAR PANEL =====
local function BuildUnitPanel(parent, unitKey, displayName)
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local db = TomoCastbarDB
    if not db or not db[unitKey] then return scroll end

    local unitDB = db[unitKey]
    local y = -10

    local _, ny = W.CreateSectionHeader(c, string.format(L["HEADER_UNIT_CASTBAR"], displayName), y)
    y = ny

    -- Enable
    local _, ny = W.CreateCheckbox(c, L["ENABLE"], unitDB.enabled, y, function(v)
        unitDB.enabled = v
        RefreshCastbars()
    end)
    y = ny

    -- Dimensions
    local _, ny = W.CreateSeparator(c, y)
    y = ny
    local _, ny = W.CreateSubLabel(c, L["SUBLABEL_DIMENSIONS"], y)
    y = ny

    local _, ny = W.CreateSlider(c, L["SLIDER_WIDTH"], unitDB.width, 80, 500, 5, y, function(v)
        unitDB.width = v
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, L["SLIDER_HEIGHT"], unitDB.height, 8, 50, 1, y, function(v)
        unitDB.height = v
        RefreshCastbars()
    end)
    y = ny

    -- Display
    local _, ny = W.CreateSeparator(c, y)
    y = ny
    local _, ny = W.CreateSubLabel(c, L["SUBLABEL_DISPLAY"], y)
    y = ny

    local _, ny = W.CreateCheckbox(c, L["SHOW_ICON"], unitDB.showIcon, y, function(v)
        unitDB.showIcon = v
        RefreshCastbars()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, L["SHOW_TIMER"], unitDB.showTimer, y, function(v)
        unitDB.showTimer = v
        RefreshCastbars()
    end)
    y = ny

    -- Latency (player only)
    if unitDB.showLatency ~= nil then
        local _, ny = W.CreateCheckbox(c, L["SHOW_LATENCY"], unitDB.showLatency, y, function(v)
            unitDB.showLatency = v
            RefreshCastbars()
        end)
        y = ny
    end

    -- Position
    local _, ny = W.CreateSeparator(c, y)
    y = ny
    local _, ny = W.CreateSubLabel(c, L["SUBLABEL_POSITION"], y)
    y = ny

    local _, ny = W.CreateInfoText(c, L["INFO_DRAG"], y)
    y = ny

    local _, ny = W.CreateButton(c, string.format(L["RESET_POSITION"], displayName), 240, y, function()
        if TomoCastbar_Defaults[unitKey] then
            unitDB.position = CopyTable(TomoCastbar_Defaults[unitKey].position)
            local cb = TomoCastbar_Module.castbars[unitKey]
            if cb then
                local pos = unitDB.position
                cb:ClearAllPoints()
                cb:SetPoint(pos.point, UIParent, pos.relativePoint, pos.x, pos.y)
            end
            print("|cffd1b559TomoCastbar|r " .. string.format(L["POSITION_RESET"], displayName))
        end
    end)
    y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- CATEGORIES
-- =====================================

local categories = {
    { key = "general", label = L["CAT_GENERAL"],  icon = "+", builder = function(parent) return BuildGeneralPanel(parent) end },
    { key = "player",  label = L["CAT_PLAYER"],   icon = "+", builder = function(parent) return BuildUnitPanel(parent, "player", L["CAT_PLAYER"]) end },
    { key = "target",  label = L["CAT_TARGET"],   icon = "+", builder = function(parent) return BuildUnitPanel(parent, "target", L["CAT_TARGET"]) end },
    { key = "focus",   label = L["CAT_FOCUS"],    icon = "+", builder = function(parent) return BuildUnitPanel(parent, "focus", L["CAT_FOCUS"]) end },
}

-- =====================================
-- CREATE MAIN FRAME
-- =====================================

local function CreateConfigFrame()
    if configFrame then return end

    configFrame = CreateFrame("Frame", "TomoCastbarConfigFrame", UIParent, "BackdropTemplate")
    configFrame:SetSize(620, 680)
    configFrame:SetPoint("CENTER")
    configFrame:SetFrameStrata("HIGH")
    configFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    configFrame:SetBackdropColor(unpack(T.bg))
    configFrame:SetBackdropBorderColor(unpack(T.border))
    configFrame:SetMovable(true)
    configFrame:SetClampedToScreen(true)
    configFrame:EnableMouse(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)
    configFrame:Hide()

    -- Close with Escape
    tinsert(UISpecialFrames, "TomoCastbarConfigFrame")

    -- =====================================
    -- TITLE BAR
    -- =====================================
    local titleBar = CreateFrame("Frame", nil, configFrame)
    titleBar:SetSize(configFrame:GetWidth(), 40)
    titleBar:SetPoint("TOP", 0, 0)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints()
    titleBg:SetColorTexture(0.06, 0.06, 0.08, 1)

    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT_BOLD, 16, "")
    titleText:SetPoint("LEFT", 20, 0)
    titleText:SetText(L["CONFIG_TITLE"])

    local versionText = titleBar:CreateFontString(nil, "OVERLAY")
    versionText:SetFont(FONT, 10, "")
    versionText:SetPoint("LEFT", titleText, "RIGHT", 8, -1)
    versionText:SetTextColor(unpack(T.textDim))
    versionText:SetText("v1.0.0")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(32, 32)
    closeBtn:SetPoint("RIGHT", -6, 0)

    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
    closeTxt:SetFont(FONT_BOLD, 18, "")
    closeTxt:SetPoint("CENTER")
    closeTxt:SetText("×")
    closeTxt:SetTextColor(unpack(T.textDim))

    closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(unpack(T.red)) end)
    closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(unpack(T.textDim)) end)
    closeBtn:SetScript("OnClick", function() configFrame:Hide() end)

    -- Title bar separator
    local titleSep = configFrame:CreateTexture(nil, "ARTWORK")
    titleSep:SetHeight(1)
    titleSep:SetPoint("TOPLEFT", 0, -40)
    titleSep:SetPoint("TOPRIGHT", 0, -40)
    titleSep:SetColorTexture(unpack(T.border))

    -- =====================================
    -- SIDEBAR
    -- =====================================
    local sidebarWidth = 140

    local sidebar = CreateFrame("Frame", nil, configFrame)
    sidebar:SetPoint("TOPLEFT", 0, -41)
    sidebar:SetPoint("BOTTOMLEFT", 0, 0)
    sidebar:SetWidth(sidebarWidth)

    local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBg:SetAllPoints()
    sidebarBg:SetColorTexture(0.06, 0.06, 0.08, 1)

    local sidebarSep = configFrame:CreateTexture(nil, "ARTWORK")
    sidebarSep:SetWidth(1)
    sidebarSep:SetPoint("TOPLEFT", sidebarWidth, -40)
    sidebarSep:SetPoint("BOTTOMLEFT", sidebarWidth, 0)
    sidebarSep:SetColorTexture(unpack(T.border))

    -- Category buttons
    for i, cat in ipairs(categories) do
        local btn = CreateFrame("Button", nil, sidebar)
        btn:SetSize(sidebarWidth, 36)
        btn:SetPoint("TOPLEFT", 0, -(i - 1) * 36 - 8)

        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(0, 0, 0, 0)
        btn.bg = btnBg

        local indicator = btn:CreateTexture(nil, "OVERLAY")
        indicator:SetSize(3, 24)
        indicator:SetPoint("LEFT", 0, 0)
        indicator:SetColorTexture(unpack(T.accent))
        indicator:Hide()
        btn.indicator = indicator

        local icon = btn:CreateFontString(nil, "OVERLAY")
        icon:SetFont(FONT, 13, "")
        icon:SetPoint("LEFT", 14, 0)
        icon:SetText(cat.icon)
        icon:SetTextColor(unpack(T.textDim))
        btn.icon = icon

        local label = btn:CreateFontString(nil, "OVERLAY")
        label:SetFont(FONT, 12, "")
        label:SetPoint("LEFT", icon, "RIGHT", 8, 0)
        label:SetText(cat.label)
        label:SetTextColor(unpack(T.textDim))
        btn.label = label

        btn:SetScript("OnEnter", function()
            if currentCategory ~= cat.key then
                btnBg:SetColorTexture(0.12, 0.12, 0.15, 1)
            end
        end)
        btn:SetScript("OnLeave", function()
            if currentCategory ~= cat.key then
                btnBg:SetColorTexture(0, 0, 0, 0)
            end
        end)
        btn:SetScript("OnClick", function()
            C.SwitchCategory(cat.key)
        end)

        categoryButtons[cat.key] = btn
    end

    -- =====================================
    -- CONTENT AREA
    -- =====================================
    local content = CreateFrame("Frame", nil, configFrame)
    content:SetPoint("TOPLEFT", sidebarWidth + 1, -41)
    content:SetPoint("BOTTOMRIGHT", 0, 0)
    configFrame.content = content

    -- =====================================
    -- FOOTER
    -- =====================================
    local footerSep = configFrame:CreateTexture(nil, "ARTWORK")
    footerSep:SetHeight(1)
    footerSep:SetPoint("BOTTOMLEFT", sidebarWidth + 1, 32)
    footerSep:SetPoint("BOTTOMRIGHT", 0, 32)
    footerSep:SetColorTexture(unpack(T.separator))

    local footerText = configFrame:CreateFontString(nil, "OVERLAY")
    footerText:SetFont(FONT, 9, "")
    footerText:SetPoint("BOTTOMRIGHT", -12, 10)
    footerText:SetTextColor(unpack(T.textDim))
    footerText:SetText(L["CONFIG_FOOTER"])
end

-- =====================================
-- SWITCH CATEGORY
-- =====================================

function C.SwitchCategory(key)
    if currentCategory == key then return end

    -- Hide all panels
    for _, panel in pairs(categoryPanels) do
        panel:Hide()
    end

    -- Update button visuals
    for catKey, btn in pairs(categoryButtons) do
        if catKey == key then
            btn.bg:SetColorTexture(0.10, 0.10, 0.13, 1)
            btn.indicator:Show()
            btn.icon:SetTextColor(unpack(T.accent))
            btn.label:SetTextColor(unpack(T.text))
        else
            btn.bg:SetColorTexture(0, 0, 0, 0)
            btn.indicator:Hide()
            btn.icon:SetTextColor(unpack(T.textDim))
            btn.label:SetTextColor(unpack(T.textDim))
        end
    end

    -- Create or show the panel (lazy creation)
    if not categoryPanels[key] then
        for _, cat in ipairs(categories) do
            if cat.key == key and cat.builder then
                local panel = cat.builder(configFrame.content)
                panel:SetAllPoints(configFrame.content)
                categoryPanels[key] = panel
                break
            end
        end
    end

    if categoryPanels[key] then
        categoryPanels[key]:Show()
    end

    currentCategory = key
end

-- =====================================
-- TOGGLE / SHOW / HIDE
-- =====================================

function C.Toggle()
    if not TomoCastbarDB then
        print("|cffd1b559TomoCastbar|r " .. L["DB_NOT_INIT"])
        return
    end

    -- Recreate config if dirty (after reset)
    if C.configDirty then
        if configFrame then
            configFrame:Hide()
            configFrame:SetParent(nil)
            configFrame = nil
        end
        categoryPanels = {}
        categoryButtons = {}
        currentCategory = nil
        C.configDirty = false
    end

    if not configFrame then
        CreateConfigFrame()
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
        if not currentCategory then
            C.SwitchCategory("general")
        end
    end
end

function C.Show()
    C.Toggle()
    if configFrame and not configFrame:IsShown() then
        C.Toggle()
    end
end

function C.Hide()
    if configFrame and configFrame:IsShown() then
        configFrame:Hide()
    end
end
