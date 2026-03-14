-- =====================================
-- Config/Panels/Profiles.lua — Profile Management (3 tabs)
-- Adapted from TomoMod's profile system
-- =====================================

local W    = TGF_Widgets
local L    = TGF_L
local T    = W.Theme
local P    = TGF_Profiles
local ADDON_PATH = "Interface\\AddOns\\TomoGroupFrame\\"
local FONT      = ADDON_PATH .. "Assets\\Fonts\\Poppins-Medium.ttf"
local FONT_BOLD = ADDON_PATH .. "Assets\\Fonts\\Poppins-SemiBold.ttf"

-- =====================================
-- WIDGET HELPERS
-- =====================================

local function MkEditBox(parent, placeholder, width, yOff)
    local fr = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    fr:SetSize(width, 26)
    fr:SetPoint("TOPLEFT", 16, yOff)
    fr:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    fr:SetBackdropColor(0.06, 0.06, 0.08, 1)
    fr:SetBackdropBorderColor(unpack(T.border))

    local eb = CreateFrame("EditBox", nil, fr)
    eb:SetAllPoints()
    eb:SetFont(FONT, 11, "")
    eb:SetTextColor(0.9, 0.9, 0.9)
    eb:SetAutoFocus(false)
    eb:SetTextInsets(8, 8, 4, 4)
    eb:SetMaxLetters(64)

    local ph = eb:CreateFontString(nil, "OVERLAY")
    ph:SetFont(FONT, 11, "")
    ph:SetPoint("LEFT", 8, 0)
    ph:SetTextColor(unpack(T.textDim))
    ph:SetText(placeholder)
    eb:SetScript("OnTextChanged", function(self, u)
        if self:GetText() ~= "" then ph:Hide() else ph:Show() end
    end)
    eb:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    eb:SetScript("OnEditFocusGained", function() fr:SetBackdropBorderColor(unpack(T.accent)) end)
    eb:SetScript("OnEditFocusLost", function() fr:SetBackdropBorderColor(unpack(T.border)) end)

    fr.editBox = eb
    return fr, yOff - 32
end

local function MkSmallBtn(parent, label, w, onClickFn, red)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(w, 22)
    btn:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8", edgeFile = "Interface\\Buttons\\WHITE8x8", edgeSize = 1 })
    btn:SetBackdropColor(red and 0.15 or T.bgLight[1], red and 0.05 or T.bgLight[2], red and 0.05 or T.bgLight[3], 0.9)
    btn:SetBackdropBorderColor(unpack(T.border))

    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont(FONT, 9, "")
    lbl:SetPoint("CENTER")
    if red then
        lbl:SetTextColor(T.red[1], T.red[2], T.red[3])
    else
        lbl:SetTextColor(T.text[1], T.text[2], T.text[3])
    end
    lbl:SetText(label)

    local hR = red and T.red[1] or T.accent[1]
    local hG = red and T.red[2] or T.accent[2]
    local hB = red and T.red[3] or T.accent[3]
    btn:SetScript("OnEnter", function(b) b:SetBackdropBorderColor(hR, hG, hB) end)
    btn:SetScript("OnLeave", function(b) b:SetBackdropBorderColor(unpack(T.border)) end)
    btn:SetScript("OnClick", onClickFn)
    return btn
end

-- =====================================
-- TAB 1: PROFILES
-- =====================================

local function BuildProfileTab(parent)
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local y = -10

    local _, ny = W.CreateSectionHeader(c, L["section_named_profiles"], y); y = ny
    local _, ny = W.CreateInfoText(c, L["info_profiles"], y); y = ny

    -- Active profile display
    local activeLabel = c:CreateFontString(nil, "OVERLAY")
    activeLabel:SetFont(FONT_BOLD, 12, "")
    activeLabel:SetPoint("TOPLEFT", 16, y)
    activeLabel:SetTextColor(unpack(T.accent))
    activeLabel:SetText("Active: " .. P.GetActiveProfileName())
    y = y - 24

    -- Create new profile
    local editFrame, ny = MkEditBox(c, L["placeholder_profile"], 240, y); y = ny

    local _, ny = W.CreateButton(c, L["btn_create"], 120, y, function()
        local name = editFrame.editBox:GetText()
        local ok, err = P.CreateNamedProfile(name)
        if ok then
            print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r " .. string.format(L["msg_profile_created"], name))
            editFrame.editBox:SetText("")
            activeLabel:SetText("Active: " .. P.GetActiveProfileName())
        else
            print("|cffff0000TomoGroupFrame|r " .. (err or "Error"))
        end
    end); y = ny

    -- Profile list
    local _, ny = W.CreateSeparator(c, y); y = ny

    local order, named = P.GetProfileList()
    for _, profileName in ipairs(order) do
        local row = CreateFrame("Frame", nil, c)
        row:SetSize(500, 28)
        row:SetPoint("TOPLEFT", 16, y)

        local nameLabel = row:CreateFontString(nil, "OVERLAY")
        nameLabel:SetFont(FONT, 11, "")
        nameLabel:SetPoint("LEFT", 0, 0)
        nameLabel:SetTextColor(unpack(T.text))
        nameLabel:SetText(profileName)

        if profileName == P.GetActiveProfileName() then
            nameLabel:SetTextColor(unpack(T.accent))
        end

        local xOff = 260
        -- Load button
        local loadBtn = MkSmallBtn(row, L["btn_load"], 50, function()
            local ok = P.LoadNamedProfile(profileName)
            if ok then
                print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r " .. string.format(L["msg_profile_loaded"], profileName))
                C_Timer.After(0.3, ReloadUI)
            end
        end)
        loadBtn:SetPoint("LEFT", xOff, 0)

        -- Delete button (not for Default)
        if profileName ~= "Default" then
            local delBtn = MkSmallBtn(row, L["btn_delete"], 60, function()
                P.DeleteNamedProfile(profileName)
                print("|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r " .. string.format(L["msg_profile_deleted"], profileName))
            end, true)
            delBtn:SetPoint("LEFT", xOff + 56, 0)
        end

        y = y - 30
    end

    -- =====================================
    -- SPEC PROFILES
    -- =====================================
    local _, ny = W.CreateSeparator(c, y); y = ny
    local _, ny = W.CreateSectionHeader(c, L["section_spec_profiles"], y); y = ny
    local _, ny = W.CreateInfoText(c, L["info_spec_profiles"], y); y = ny

    local specs = P.GetAllSpecs()
    for _, spec in ipairs(specs) do
        local assigned = P.GetSpecAssignedProfile(spec.id) or "—"

        local row = CreateFrame("Frame", nil, c)
        row:SetSize(500, 28)
        row:SetPoint("TOPLEFT", 16, y)

        local icon = row:CreateTexture(nil, "OVERLAY")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", 0, 0)
        icon:SetTexture(spec.icon)

        local specLabel = row:CreateFontString(nil, "OVERLAY")
        specLabel:SetFont(FONT, 11, "")
        specLabel:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        specLabel:SetTextColor(unpack(T.text))
        specLabel:SetText(spec.name .. "  >>  |cffCC44FF" .. assigned .. "|r")

        -- Build dropdown options from existing profiles
        local profileOptions = {}
        local pOrder = P.GetProfileList()
        for _, pName in ipairs(pOrder) do
            table.insert(profileOptions, { key = pName, label = pName })
        end

        local assignBtn = MkSmallBtn(row, "Assign", 60, function()
            -- Simple: assign to current active profile
            local active = P.GetActiveProfileName()
            P.AssignSpecToProfile(spec.id, active)
            specLabel:SetText(spec.name .. "  >>  |cffCC44FF" .. active .. "|r")
        end)
        assignBtn:SetPoint("LEFT", 280, 0)

        y = y - 30
    end

    y = y - 20
    c:SetHeight(math.abs(y) + 20)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 2: IMPORT / EXPORT (placeholder)
-- =====================================

local function BuildImportExportTab(parent)
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local y = -10

    local _, ny = W.CreateSectionHeader(c, L["section_export"], y); y = ny
    local _, ny = W.CreateInfoText(c, "Export/Import requires LibSerialize & LibDeflate.\nComing soon in a future update.", y); y = ny

    y = y - 20
    c:SetHeight(math.abs(y) + 20)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 3: RESETS
-- =====================================

local function BuildResetsTab(parent)
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local y = -10

    local _, ny = W.CreateSectionHeader(c, L["section_reset_all"], y); y = ny
    local _, ny = W.CreateInfoText(c, L["info_reset_warning"], y); y = ny

    local _, ny = W.CreateButton(c, "Reset Party Settings", 220, y, function()
        TGF_ResetModule("party")
        TGF_PartyFrames.Refresh()
    end); y = ny

    local _, ny = W.CreateButton(c, "Reset Raid Settings", 220, y, function()
        TGF_ResetModule("raid")
        TGF_RaidFrames.Refresh()
    end); y = ny

    local _, ny = W.CreateSeparator(c, y); y = ny

    local _, ny = W.CreateButton(c, L["btn_reset_all"], 260, y, function()
        StaticPopup_Show("TGF_RESET_ALL")
    end); y = ny

    y = y - 20
    c:SetHeight(math.abs(y) + 20)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- ENTRY POINT
-- =====================================

function TGF_ConfigPanel_Profiles(parent)
    local tabs = {
        { key = "profiles",     label = L["tab_profiles"],      builder = BuildProfileTab },
        { key = "importexport", label = L["tab_import_export"],  builder = BuildImportExportTab },
        { key = "resets",       label = L["tab_resets"],         builder = BuildResetsTab },
    }
    return W.CreateTabPanel(parent, tabs)
end

-- =====================================
-- STATIC POPUPS
-- =====================================

StaticPopupDialogs["TGF_RESET_ALL"] = {
    text = "|cffCC44FFTomo|r|cffFFFFFFGroupFrame|r\n\nReset ALL settings?\nThis cannot be undone.",
    button1 = L["popup_confirm"] or "Confirm",
    button2 = L["popup_cancel"] or "Cancel",
    OnAccept = function()
        TGF_ResetDatabase()
        ReloadUI()
    end,
    timeout = 0, whileDead = true, hideOnEscape = true, preferredIndex = 3,
}
