-- TomoPartyFrame Config UI
-- Tabbed options window: Layout, Appearance, Features, Test

local ADDON, ns = ...

local CreateFrame = CreateFrame
local pairs, ipairs = pairs, ipairs

-- ============================================================================
-- OPTIONS WINDOW
-- ============================================================================

local optionsFrame = nil

function ns:CreateOptionsWindow()
    if optionsFrame then return optionsFrame end

    local L = ns.L

    -- Main window
    local frame = CreateFrame("Frame", "TomoPartyFrameOptions", UIParent, "BackdropTemplate")
    frame:SetSize(560, 520)
    frame:SetPoint("CENTER")
    frame:SetFrameStrata("HIGH")
    frame:SetMovable(true)
    frame:SetClampedToScreen(true)
    frame:EnableMouse(true)
    frame:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    frame:SetBackdropColor(0.08, 0.08, 0.08, 0.95)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Title bar
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", 0, 0)
    titleBar:SetHeight(28)
    titleBar:EnableMouse(true)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() frame:StartMoving() end)
    titleBar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)

    local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    title:SetText("TomoPartyFrame")
    title:SetTextColor(1, 0.82, 0)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Tab system
    local TAB_NAMES = {
        L.TAB_LAYOUT or "Layout",
        L.TAB_APPEARANCE or "Appearance",
        L.TAB_FEATURES or "Features",
        L.TAB_TEST or "Test",
    }

    local tabButtons = {}
    local tabPanels = {}
    local selectedTab = 1

    local tabBar = CreateFrame("Frame", nil, frame)
    tabBar:SetPoint("TOPLEFT", 8, -30)
    tabBar:SetPoint("TOPRIGHT", -8, -30)
    tabBar:SetHeight(26)

    for i, tabName in ipairs(TAB_NAMES) do
        local btn = CreateFrame("Button", nil, tabBar, "BackdropTemplate")
        btn:SetSize(120, 24)
        btn:SetPoint("LEFT", tabBar, "LEFT", (i - 1) * 124, 0)
        btn:SetBackdrop({
            bgFile = "Interface/Tooltips/UI-Tooltip-Background",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 8,
            insets = { left = 2, right = 2, top = 2, bottom = 2 },
        })

        local btnText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        btnText:SetPoint("CENTER")
        btnText:SetText(tabName)
        btn.text = btnText

        btn:SetScript("OnClick", function()
            selectedTab = i
            for j, panel in ipairs(tabPanels) do
                panel:Hide()
                tabButtons[j]:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
                tabButtons[j].text:SetTextColor(0.6, 0.6, 0.6)
            end
            tabPanels[i]:Show()
            tabButtons[i]:SetBackdropColor(0.25, 0.25, 0.4, 1)
            tabButtons[i].text:SetTextColor(1, 0.82, 0)
        end)

        tabButtons[i] = btn
    end

    -- Content area with scroll
    local contentArea = CreateFrame("Frame", nil, frame)
    contentArea:SetPoint("TOPLEFT", 8, -60)
    contentArea:SetPoint("BOTTOMRIGHT", -8, 8)

    for i = 1, #TAB_NAMES do
        local scroll = CreateFrame("ScrollFrame", nil, contentArea, "UIPanelScrollFrameTemplate")
        scroll:SetPoint("TOPLEFT", 0, 0)
        scroll:SetPoint("BOTTOMRIGHT", -24, 0)

        local panel = CreateFrame("Frame", nil, scroll)
        panel:SetWidth(scroll:GetWidth() or 500)
        panel:SetHeight(900)
        scroll:SetScrollChild(panel)

        panel:SetScript("OnSizeChanged", function(self)
            self:SetWidth(scroll:GetWidth())
        end)

        panel:Hide()
        tabPanels[i] = panel
        panel.scroll = scroll

        -- Store scroll frames for showing/hiding
        scroll:SetParent(contentArea)
        panel.scrollFrame = scroll
    end

    -- Override panel show/hide to include scroll frame
    for i, panel in ipairs(tabPanels) do
        local origShow = panel.Show
        local origHide = panel.Hide
        panel.Show = function(self)
            self.scrollFrame:Show()
            origShow(self)
        end
        panel.Hide = function(self)
            self.scrollFrame:Hide()
            origHide(self)
        end
    end

    -- ========================================================================
    -- TAB 1: LAYOUT
    -- ========================================================================
    local layoutPanel = tabPanels[1]
    local y = -10

    ns:CreateHeader(layoutPanel, L.HEADER_LAYOUT or "Layout", y)
    y = y - 30

    ns:CreateDropdown(layoutPanel, L.OPT_GROW_DIR or "Growth Direction", "growDirection", {
        { value = "DOWN", label = L.DIR_DOWN or "Down" },
        { value = "UP", label = L.DIR_UP or "Up" },
        { value = "LEFT", label = L.DIR_LEFT or "Left" },
        { value = "RIGHT", label = L.DIR_RIGHT or "Right" },
    }, y)
    y = y - 34

    ns:CreateDropdown(layoutPanel, L.OPT_SORT or "Sort Mode", "sortMode", {
        { value = "GROUP", label = L.SORT_GROUP or "Group" },
        { value = "ROLE", label = L.SORT_ROLE or "Role" },
    }, y)
    y = y - 34

    ns:CreateSlider(layoutPanel, L.OPT_FRAME_WIDTH or "Frame Width", "frameWidth", 60, 300, 1, y)
    y = y - 46

    ns:CreateSlider(layoutPanel, L.OPT_FRAME_HEIGHT or "Frame Height", "frameHeight", 20, 200, 1, y)
    y = y - 46

    ns:CreateSlider(layoutPanel, L.OPT_SPACING or "Frame Spacing", "frameSpacing", 0, 20, 1, y)
    y = y - 46

    ns:CreateSlider(layoutPanel, L.OPT_MAX_COLUMNS or "Max Columns", "maxColumns", 1, 10, 1, y)
    y = y - 46

    ns:CreateSlider(layoutPanel, L.OPT_COL_SPACING or "Column Spacing", "columnSpacing", 0, 20, 1, y)
    y = y - 46

    ns:CreateCheckbox(layoutPanel, L.OPT_SHOW_PLAYER or "Show Player", "showPlayer", y)
    y = y - 28

    ns:CreateCheckbox(layoutPanel, L.OPT_HIDE_BLIZZARD or "Hide Blizzard Frames", "hideBlizzardFrames", y, nil, function()
        ns:ApplyBlizzardFrameVisibility()
    end)
    y = y - 28

    ns:CreateSeparator(layoutPanel, y)
    y = y - 16

    ns:CreateHeader(layoutPanel, L.HEADER_NAME or "Name", y)
    y = y - 30

    ns:CreateCheckbox(layoutPanel, L.OPT_SHOW_NAME or "Show Name", "showName", y)
    y = y - 28

    ns:CreateDropdown(layoutPanel, L.OPT_NAME_POS or "Name Position", "namePosition", {
        { value = "INSIDE", label = "Inside" },
        { value = "ABOVE", label = "Above" },
        { value = "BELOW", label = "Below" },
    }, y)
    y = y - 34

    ns:CreateDropdown(layoutPanel, L.OPT_NAME_ALIGN or "Name Alignment", "nameAlignment", {
        { value = "LEFT", label = "Left" },
        { value = "CENTER", label = "Center" },
        { value = "RIGHT", label = "Right" },
    }, y)
    y = y - 34

    ns:CreateSlider(layoutPanel, L.OPT_NAME_SIZE or "Name Size", "nameSize", 6, 24, 1, y)
    y = y - 46

    ns:CreateCheckbox(layoutPanel, L.OPT_CLASS_COLOR_NAME or "Class Color Name", "useClassColorName", y)
    y = y - 28

    ns:CreateCheckbox(layoutPanel, L.OPT_NAME_SHADOW or "Name Shadow", "showNameShadow", y)
    y = y - 28

    ns:CreateColorPicker(layoutPanel, L.OPT_NAME_COLOR or "Name Color", "nameColor", y)
    y = y - 28

    layoutPanel:SetHeight(math.abs(y) + 20)

    -- ========================================================================
    -- TAB 2: APPEARANCE
    -- ========================================================================
    local appearancePanel = tabPanels[2]
    y = -10

    ns:CreateHeader(appearancePanel, L.HEADER_HEALTH or "Health Bar", y)
    y = y - 30

    ns:CreateDropdown(appearancePanel, L.OPT_HEALTH_BAR_STYLE or "Bar Style", "healthBarStyle", {
        { value = "standard", label = L.STYLE_STANDARD or "Standard" },
        { value = "gradient", label = L.STYLE_GRADIENT or "Gradient" },
        { value = "striped", label = L.STYLE_STRIPED or "Striped" },
        { value = "flat", label = L.STYLE_FLAT or "Flat" },
        { value = "pixel", label = L.STYLE_PIXEL or "Pixel" },
    }, y)
    y = y - 34

    ns:CreateDropdown(appearancePanel, L.OPT_HEALTH_COLOR or "Health Color", "healthColorMode", {
        { value = "class", label = L.HEALTH_CLASS or "Class Color" },
        { value = "custom", label = L.HEALTH_CUSTOM or "Custom" },
    }, y)
    y = y - 34

    ns:CreateColorPicker(appearancePanel, L.OPT_HEALTH_CUSTOM_COLOR or "Custom Health Color", "healthCustomColor", y)
    y = y - 28

    ns:CreateColorPicker(appearancePanel, L.OPT_HEALTH_BG_COLOR or "Health BG Color", "healthBackgroundColor", y)
    y = y - 28

    ns:CreateCheckbox(appearancePanel, L.OPT_SMOOTH_HEALTH or "Smooth Health Bars", "smoothHealthBars", y)
    y = y - 34

    ns:CreateSeparator(appearancePanel, y)
    y = y - 16

    ns:CreateHeader(appearancePanel, L.HEADER_POWER or "Power Bar", y)
    y = y - 30

    ns:CreateCheckbox(appearancePanel, L.OPT_SHOW_POWER or "Show Power Bar", "showPowerBar", y)
    y = y - 28

    ns:CreateSlider(appearancePanel, L.OPT_POWER_HEIGHT or "Power Bar Height", "powerBarHeight", 2, 20, 1, y)
    y = y - 46

    ns:CreateColorPicker(appearancePanel, L.OPT_POWER_BG_COLOR or "Power BG Color", "powerBackgroundColor", y)
    y = y - 34

    ns:CreateSeparator(appearancePanel, y)
    y = y - 16

    ns:CreateHeader(appearancePanel, L.HEADER_BACKGROUND or "Background & Border", y)
    y = y - 30

    ns:CreateCheckbox(appearancePanel, L.OPT_SHOW_BORDER or "Show Border", "showBorder", y)
    y = y - 28

    ns:CreateColorPicker(appearancePanel, L.OPT_BG_COLOR or "Background Color", "backgroundColor", y)
    y = y - 28

    ns:CreateColorPicker(appearancePanel, L.OPT_BORDER_COLOR or "Border Color", "borderColor", y)
    y = y - 34

    ns:CreateSeparator(appearancePanel, y)
    y = y - 16

    ns:CreateHeader(appearancePanel, L.HEADER_RANGE or "Range", y)
    y = y - 30

    ns:CreateCheckbox(appearancePanel, L.OPT_RANGE_FADE or "Range Fade", "enableRangeFade", y)
    y = y - 28

    ns:CreateSlider(appearancePanel, L.OPT_RANGE_ALPHA or "Range Fade Alpha", "rangeFadeAlpha", 0.1, 1.0, 0.05, y)
    y = y - 46

    ns:CreateSeparator(appearancePanel, y)
    y = y - 16

    ns:CreateHeader(appearancePanel, L.HEADER_SELECTION or "Selection & Hover", y)
    y = y - 30

    ns:CreateCheckbox(appearancePanel, L.OPT_SELECTION_HL or "Selection Highlight", "showSelectionHighlight", y)
    y = y - 28

    ns:CreateSlider(appearancePanel, L.OPT_SELECTION_THICK or "Selection Thickness", "selectionHighlightThickness", 1, 5, 1, y)
    y = y - 46

    ns:CreateColorPicker(appearancePanel, L.OPT_SELECTION_COLOR or "Selection Color", "selectionHighlightColor", y)
    y = y - 28

    ns:CreateCheckbox(appearancePanel, L.OPT_HOVER_HL or "Hover Highlight", "showHoverHighlight", y)
    y = y - 28

    ns:CreateColorPicker(appearancePanel, L.OPT_HOVER_COLOR or "Hover Color", "hoverHighlightColor", y)
    y = y - 28

    appearancePanel:SetHeight(math.abs(y) + 20)

    -- ========================================================================
    -- TAB 3: FEATURES
    -- ========================================================================
    local featuresPanel = tabPanels[3]
    y = -10

    ns:CreateHeader(featuresPanel, L.HEADER_ICONS or "Icons", y)
    y = y - 30

    ns:CreateCheckbox(featuresPanel, L.OPT_ROLE_ICON or "Role Icon", "showRoleIcon", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_ROLE_ICON_SIZE or "Role Icon Size", "roleIconSize", 8, 32, 1, y)
    y = y - 46

    ns:CreateCheckbox(featuresPanel, L.OPT_LEADER_ICON or "Leader Icon", "showLeaderIcon", y)
    y = y - 28

    ns:CreateCheckbox(featuresPanel, L.OPT_RAID_MARKER or "Raid Marker", "showRaidMarker", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_MARKER_SIZE or "Marker Size", "raidMarkerSize", 8, 40, 1, y)
    y = y - 46

    ns:CreateDropdown(featuresPanel, L.OPT_MARKER_ANCHOR or "Marker Position", "raidMarkerAnchor", {
        { value = "CENTER", label = L.ANCHOR_CENTER or "Center" },
        { value = "TOPLEFT", label = L.ANCHOR_TOPLEFT or "Top Left" },
        { value = "TOP", label = L.ANCHOR_TOP or "Top" },
        { value = "TOPRIGHT", label = L.ANCHOR_TOPRIGHT or "Top Right" },
        { value = "LEFT", label = L.ANCHOR_LEFT or "Left" },
        { value = "RIGHT", label = L.ANCHOR_RIGHT or "Right" },
        { value = "BOTTOMLEFT", label = L.ANCHOR_BOTTOMLEFT or "Bottom Left" },
        { value = "BOTTOM", label = L.ANCHOR_BOTTOM or "Bottom" },
        { value = "BOTTOMRIGHT", label = L.ANCHOR_BOTTOMRIGHT or "Bottom Right" },
    }, y)
    y = y - 34

    ns:CreateSlider(featuresPanel, L.OPT_MARKER_OFFSET_X or "Marker Offset X", "raidMarkerOffsetX", -50, 50, 1, y)
    y = y - 46

    ns:CreateSlider(featuresPanel, L.OPT_MARKER_OFFSET_Y or "Marker Offset Y", "raidMarkerOffsetY", -50, 50, 1, y)
    y = y - 52

    ns:CreateSeparator(featuresPanel, y)
    y = y - 16

    ns:CreateHeader(featuresPanel, L.HEADER_AURAS or "Auras", y)
    y = y - 30

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_BUFFS or "Show Buffs", "showBuffs", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_BUFF_COUNT or "Buff Count", "buffCount", 0, 12, 1, y)
    y = y - 46

    ns:CreateSlider(featuresPanel, L.OPT_BUFF_SIZE or "Buff Size", "buffSize", 8, 32, 1, y)
    y = y - 46

    ns:CreateDropdown(featuresPanel, L.OPT_BUFF_POS or "Buff Position", "buffPosition", {
        { value = "TOPLEFT", label = "Top Left" },
        { value = "TOPRIGHT", label = "Top Right" },
        { value = "BOTTOMLEFT", label = "Bottom Left" },
        { value = "BOTTOMRIGHT", label = "Bottom Right" },
    }, y)
    y = y - 34

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_DEBUFFS or "Show Debuffs", "showDebuffs", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_DEBUFF_COUNT or "Debuff Count", "debuffCount", 0, 12, 1, y)
    y = y - 46

    ns:CreateSlider(featuresPanel, L.OPT_DEBUFF_SIZE or "Debuff Size", "debuffSize", 8, 32, 1, y)
    y = y - 46

    ns:CreateDropdown(featuresPanel, L.OPT_DEBUFF_POS or "Debuff Position", "debuffPosition", {
        { value = "TOPLEFT", label = "Top Left" },
        { value = "TOPRIGHT", label = "Top Right" },
        { value = "BOTTOMLEFT", label = "Bottom Left" },
        { value = "BOTTOMRIGHT", label = "Bottom Right" },
    }, y)
    y = y - 34

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_EXPIRING or "Expiring Indicator", "showExpiringIndicator", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_EXPIRING_THRESHOLD or "Expiring Threshold (s)", "expiringThreshold", 1, 30, 1, y)
    y = y - 52

    ns:CreateSeparator(featuresPanel, y)
    y = y - 16

    ns:CreateHeader(featuresPanel, L.HEADER_DISPEL or "Dispel Overlay", y)
    y = y - 30

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_DISPEL or "Show Dispel Overlay", "showDispelOverlay", y)
    y = y - 28

    ns:CreateDropdown(featuresPanel, L.OPT_DISPEL_MODE or "Dispel Display Mode", "dispelDisplayMode", {
        { value = "icon", label = L.DISPEL_MODE_ICON or "Icon" },
        { value = "border", label = L.DISPEL_MODE_BORDER or "Border" },
        { value = "both", label = L.DISPEL_MODE_BOTH or "Both" },
    }, y)
    y = y - 34

    ns:CreateSlider(featuresPanel, L.OPT_DISPEL_ICON_SIZE or "Dispel Icon Size", "dispelIconSize", 10, 40, 1, y)
    y = y - 46

    ns:CreateSlider(featuresPanel, L.OPT_DISPEL_THICKNESS or "Dispel Border Thickness", "dispelBorderThickness", 1, 20, 1, y)
    y = y - 46

    ns:CreateCheckbox(featuresPanel, L.OPT_DISPEL_ANIMATE or "Animate Dispel Border", "dispelAnimateBorder", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_DISPEL_MAGIC_COLOR or "Magic Color", "dispelMagicColor", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_DISPEL_CURSE_COLOR or "Curse Color", "dispelCurseColor", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_DISPEL_DISEASE_COLOR or "Disease Color", "dispelDiseaseColor", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_DISPEL_POISON_COLOR or "Poison Color", "dispelPoisonColor", y)
    y = y - 34

    ns:CreateSeparator(featuresPanel, y)
    y = y - 16

    ns:CreateHeader(featuresPanel, L.HEADER_HEALING or "Healing & Absorbs", y)
    y = y - 30

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_HEAL_PRED or "Heal Prediction", "showHealPrediction", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_HEAL_PRED_COLOR or "Heal Prediction Color", "healPredictionColor", y)
    y = y - 28

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_ABSORBS or "Show Absorbs", "showAbsorbs", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_ABSORB_COLOR or "Absorb Color", "absorbColor", y)
    y = y - 28

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_HEAL_ABSORBS or "Show Heal Absorbs", "showHealAbsorbs", y)
    y = y - 28

    ns:CreateColorPicker(featuresPanel, L.OPT_HEAL_ABSORB_COLOR or "Heal Absorb Color", "healAbsorbColor", y)
    y = y - 34

    ns:CreateSeparator(featuresPanel, y)
    y = y - 16

    ns:CreateHeader(featuresPanel, L.HEADER_PRIVATE_AURAS or "Private Auras", y)
    y = y - 30

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_PRIVATE or "Show Private Auras", "showPrivateAuras", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_PRIVATE_COUNT or "Private Aura Count", "privateAuraCount", 1, 5, 1, y)
    y = y - 46

    ns:CreateSlider(featuresPanel, L.OPT_PRIVATE_SIZE or "Private Aura Size", "privateAuraSize", 12, 40, 1, y)
    y = y - 52

    ns:CreateSeparator(featuresPanel, y)
    y = y - 16

    ns:CreateHeader(featuresPanel, L.HEADER_INDICATORS or "Indicators", y)
    y = y - 30

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_RESURRECT or "Resurrect Indicator", "showResurrectIndicator", y)
    y = y - 28

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_READYCHECK or "Ready Check Indicator", "showReadyCheckIndicator", y)
    y = y - 28

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_SUMMONS or "Summon Indicator", "showSummons", y)
    y = y - 28

    ns:CreateCheckbox(featuresPanel, L.OPT_SHOW_DEFENSIVE or "Defensive Icon", "showDefensiveIcon", y)
    y = y - 28

    ns:CreateSlider(featuresPanel, L.OPT_DEFENSIVE_SIZE or "Defensive Icon Size", "defensiveIconSize", 12, 50, 1, y)
    y = y - 46

    featuresPanel:SetHeight(math.abs(y) + 20)

    -- ========================================================================
    -- TAB 4: TEST
    -- ========================================================================
    local testPanel = tabPanels[4]
    y = -10

    ns:CreateHeader(testPanel, L.HEADER_TEST or "Test Mode", y)
    y = y - 30

    ns:CreateButton(testPanel, L.BTN_TOGGLE_TEST or "Toggle Test Mode", y, function()
        ns:ToggleTestMode()
    end, 180)
    y = y - 34

    ns:CreateButton(testPanel, L.BTN_TOGGLE_DRAG or "Toggle Drag Mode", y, function()
        ns:ToggleDragMode()
    end, 180)
    y = y - 34

    ns:CreateSlider(testPanel, L.OPT_TEST_COUNT or "Test Frame Count", "testFrameCount", 1, 5, 1, y, nil, function()
        if ns.testModeActive then
            ns.testData = nil
            ns:RefreshAll()
        end
    end)
    y = y - 46

    ns:CreateCheckbox(testPanel, L.OPT_TEST_ANIMATE or "Animate Health", "testAnimateHealth", y, nil, function(checked)
        if ns.testModeActive then
            if checked then
                ns:StartHealthAnimation()
            else
                ns:StopHealthAnimation()
            end
        end
    end)
    y = y - 34

    ns:CreateSeparator(testPanel, y)
    y = y - 16

    ns:CreateHeader(testPanel, L.HEADER_TEST_TOGGLES or "Test Toggles", y)
    y = y - 30

    local testToggles = {
        { key = "testShowHealth", label = L.OPT_TEST_HEALTH or "Show Health" },
        { key = "testShowPower", label = L.OPT_TEST_POWER or "Show Power" },
        { key = "testShowName", label = L.OPT_TEST_NAME or "Show Name" },
        { key = "testShowRoleIcon", label = L.OPT_TEST_ROLE or "Show Role Icon" },
        { key = "testShowOOR", label = L.OPT_TEST_OOR or "Show Out of Range" },
        { key = "testShowDead", label = L.OPT_TEST_DEAD or "Show Dead" },
        { key = "testShowOffline", label = L.OPT_TEST_OFFLINE or "Show Offline" },
        { key = "testShowAuras", label = L.OPT_TEST_AURAS or "Show Auras" },
        { key = "testShowDispel", label = L.OPT_TEST_DISPEL or "Show Dispel" },
        { key = "testShowDefensive", label = L.OPT_TEST_DEFENSIVE or "Show Defensive" },
        { key = "testShowSelection", label = L.OPT_TEST_SELECTION or "Show Selection" },
        { key = "testShowHover", label = L.OPT_TEST_HOVER or "Show Hover" },
        { key = "testShowAbsorbs", label = L.OPT_TEST_ABSORBS or "Show Absorbs" },
        { key = "testShowHealAbsorbs", label = L.OPT_TEST_HEAL_ABSORBS or "Show Heal Absorbs" },
        { key = "testShowHealPred", label = L.OPT_TEST_HEAL_PRED or "Show Heal Prediction" },
        { key = "testShowLeader", label = L.OPT_TEST_LEADER or "Show Leader" },
        { key = "testShowRaidMarker", label = L.OPT_TEST_MARKER or "Show Raid Marker" },
        { key = "testShowReadyCheck", label = L.OPT_TEST_READYCHECK or "Show Ready Check" },
        { key = "testShowResurrect", label = L.OPT_TEST_RESURRECT or "Show Resurrect" },
        { key = "testShowSummon", label = L.OPT_TEST_SUMMON or "Show Summon" },
    }

    for _, toggle in ipairs(testToggles) do
        ns:CreateCheckbox(testPanel, toggle.label, toggle.key, y, nil, function()
            if ns.testModeActive then
                ns.testData = nil
                ns:RefreshAll()
            end
        end)
        y = y - 26
    end

    y = y - 10
    ns:CreateSeparator(testPanel, y)
    y = y - 16

    ns:CreateButton(testPanel, L.BTN_RESET_DEFAULTS or "Reset to Defaults", y, function()
        StaticPopup_Show("TPF_CONFIRM_RESET")
    end, 180)
    y = y - 28

    testPanel:SetHeight(math.abs(y) + 20)

    -- ========================================================================
    -- RESET CONFIRMATION DIALOG
    -- ========================================================================
    StaticPopupDialogs["TPF_CONFIRM_RESET"] = {
        text = L.MSG_RESET_CONFIRM or "Reset all TomoPartyFrame settings to defaults?",
        button1 = YES,
        button2 = NO,
        OnAccept = function()
            TomoPartyFramDB = ns.DeepCopy(ns.defaults)
            ns.db = TomoPartyFramDB
            ns.testData = nil
            ns:RefreshAll()
            print("TomoPartyFrame: " .. (L.MSG_RESET_DONE or "Settings reset to defaults."))
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }

    -- ========================================================================
    -- REFRESH LOGIC
    -- ========================================================================
    frame.RefreshContent = function()
        -- Widgets auto-refresh on re-creation; future enhancement
    end

    -- Select first tab
    tabButtons[1]:GetScript("OnClick")()

    frame:Hide()
    optionsFrame = frame

    -- Register with ESC key
    tinsert(UISpecialFrames, "TomoPartyFrameOptions")

    return frame
end
