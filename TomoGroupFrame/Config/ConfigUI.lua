-- =====================================
-- Config/ConfigUI.lua — Custom Dark-Themed Config Panel
-- Sidebar navigation, Tomo Suite purple theme
-- =====================================

local L = TGF_L

TGF_Config = TGF_Config or {}
local C = TGF_Config
local W = TGF_Widgets
local T = W.Theme

local ADDON_PATH = "Interface\\AddOns\\TomoGroupFrame\\"
local FONT       = ADDON_PATH .. "Assets\\Fonts\\Poppins-Medium.ttf"
local FONT_BOLD  = ADDON_PATH .. "Assets\\Fonts\\Poppins-SemiBold.ttf"

local configFrame
local currentCategory = nil
local categoryPanels = {}
local categoryButtons = {}

-- =====================================
-- CATEGORIES
-- =====================================

local categories = {
    { key = "party",    label = L["cat_party"],    builder = "TGF_ConfigPanel_Party" },
    { key = "raid",     label = L["cat_raid"],     builder = "TGF_ConfigPanel_Raid" },
    { key = "profiles", label = L["cat_profiles"], builder = "TGF_ConfigPanel_Profiles" },
}

-- =====================================
-- CREATE MAIN FRAME
-- =====================================

local function CreateConfigFrame()
    if configFrame then return end

    configFrame = CreateFrame("Frame", "TGFConfigFrame", UIParent, "BackdropTemplate")
    configFrame:SetSize(780, 580)
    configFrame:SetPoint("CENTER")
    configFrame:SetFrameStrata("HIGH")
    configFrame:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8x8",
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

    configFrame:SetScript("OnShow", function() C.isOpen = true end)
    configFrame:SetScript("OnHide", function()
        C.isOpen = false
        if TGF_Profiles then TGF_Profiles.AutoSaveActiveProfile() end
    end)

    tinsert(UISpecialFrames, "TGFConfigFrame")

    -- =====================================
    -- TITLE BAR
    -- =====================================
    local TITLE_H = 44

    local titleBar = CreateFrame("Frame", nil, configFrame)
    titleBar:SetSize(configFrame:GetWidth(), TITLE_H)
    titleBar:SetPoint("TOP", 0, 0)

    local titleBg = titleBar:CreateTexture(nil, "BACKGROUND")
    titleBg:SetAllPoints()
    titleBg:SetColorTexture(0.06, 0.06, 0.08, 1)

    -- Title text
    local titleText = titleBar:CreateFontString(nil, "OVERLAY")
    titleText:SetFont(FONT_BOLD, 16, "")
    titleText:SetPoint("LEFT", 14, 0)
    titleText:SetText("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r")

    local versionText = titleBar:CreateFontString(nil, "OVERLAY")
    versionText:SetFont(FONT, 10, "")
    versionText:SetPoint("LEFT", titleText, "RIGHT", 8, -1)
    versionText:SetTextColor(unpack(T.textDim))
    versionText:SetText("v1.0.0")

    -- Reload button
    local rlBtn = CreateFrame("Button", nil, titleBar, "BackdropTemplate")
    rlBtn:SetSize(44, 24)
    rlBtn:SetBackdrop({
        bgFile   = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        edgeSize = 1,
    })
    rlBtn:SetBackdropColor(0.10, 0.08, 0.04, 0.8)
    rlBtn:SetBackdropBorderColor(0.6, 0.42, 0.08, 0.7)

    local rlTxt = rlBtn:CreateFontString(nil, "OVERLAY")
    rlTxt:SetFont(FONT, 11, "")
    rlTxt:SetPoint("CENTER")
    rlTxt:SetText("RL")
    rlTxt:SetTextColor(0.85, 0.65, 0.20)

    rlBtn:SetScript("OnEnter", function()
        rlBtn:SetBackdropBorderColor(1, 0.80, 0.25, 1)
        rlTxt:SetTextColor(1, 0.90, 0.40)
        GameTooltip:SetOwner(rlBtn, "ANCHOR_BOTTOM")
        GameTooltip:SetText(L["btn_reload_ui"], 1, 1, 1)
        GameTooltip:Show()
    end)
    rlBtn:SetScript("OnLeave", function()
        rlBtn:SetBackdropBorderColor(0.6, 0.42, 0.08, 0.7)
        rlTxt:SetTextColor(0.85, 0.65, 0.20)
        GameTooltip:Hide()
    end)
    rlBtn:SetScript("OnClick", function() ReloadUI() end)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetSize(32, 32)
    closeBtn:SetPoint("RIGHT", -6, 0)

    local closeTxt = closeBtn:CreateFontString(nil, "OVERLAY")
    closeTxt:SetFont(FONT_BOLD, 18, "")
    closeTxt:SetPoint("CENTER")
    closeTxt:SetText("x")
    closeTxt:SetTextColor(unpack(T.textDim))

    closeBtn:SetScript("OnEnter", function() closeTxt:SetTextColor(unpack(T.red)) end)
    closeBtn:SetScript("OnLeave", function() closeTxt:SetTextColor(unpack(T.textDim)) end)
    closeBtn:SetScript("OnClick", function() configFrame:Hide() end)

    rlBtn:SetPoint("RIGHT", closeBtn, "LEFT", -4, 0)

    -- Title separator
    local titleSep = configFrame:CreateTexture(nil, "ARTWORK")
    titleSep:SetHeight(1)
    titleSep:SetPoint("TOPLEFT", 0, -TITLE_H)
    titleSep:SetPoint("TOPRIGHT", 0, -TITLE_H)
    titleSep:SetColorTexture(unpack(T.border))

    -- =====================================
    -- SIDEBAR
    -- =====================================
    local sidebarWidth = 150

    local sidebar = CreateFrame("Frame", nil, configFrame)
    sidebar:SetPoint("TOPLEFT", 0, -(TITLE_H + 1))
    sidebar:SetPoint("BOTTOMLEFT", 0, 0)
    sidebar:SetWidth(sidebarWidth)

    local sidebarBg = sidebar:CreateTexture(nil, "BACKGROUND")
    sidebarBg:SetAllPoints()
    sidebarBg:SetColorTexture(0.06, 0.06, 0.08, 1)

    local sidebarSep = configFrame:CreateTexture(nil, "ARTWORK")
    sidebarSep:SetWidth(1)
    sidebarSep:SetPoint("TOPLEFT", sidebarWidth, -(TITLE_H))
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

        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont(FONT, 12, "")
        lbl:SetPoint("LEFT", 16, 0)
        lbl:SetText(cat.label)
        lbl:SetTextColor(unpack(T.textDim))
        btn.label = lbl

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
    content:SetPoint("TOPLEFT", sidebarWidth + 1, -(TITLE_H + 1))
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
    footerText:SetText("/tgf pour toggle config")
end

-- =====================================
-- SWITCH CATEGORY
-- =====================================

function C.SwitchCategory(key)
    if currentCategory == key then return end

    for _, panel in pairs(categoryPanels) do
        panel:Hide()
    end

    for catKey, btn in pairs(categoryButtons) do
        if catKey == key then
            btn.bg:SetColorTexture(0.10, 0.10, 0.13, 1)
            btn.indicator:Show()
            btn.label:SetTextColor(unpack(T.text))
        else
            btn.bg:SetColorTexture(0, 0, 0, 0)
            btn.indicator:Hide()
            btn.label:SetTextColor(unpack(T.textDim))
        end
    end

    if not categoryPanels[key] then
        for _, cat in ipairs(categories) do
            if cat.key == key then
                local builder = _G[cat.builder]
                if builder then
                    local panel = builder(configFrame.content)
                    panel:SetAllPoints(configFrame.content)
                    categoryPanels[key] = panel
                end
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
-- TOGGLE
-- =====================================

function C.Toggle()
    if not TomoGroupFrameDB then
        print("|cffff0000TomoGroupFrame|r " .. L["msg_db_not_init"])
        return
    end

    if not configFrame then
        CreateConfigFrame()
    end

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
        if not currentCategory then
            C.SwitchCategory("party")
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
