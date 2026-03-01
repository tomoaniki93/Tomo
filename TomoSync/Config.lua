-- TomoSync | Config.lua

TomoSyncConfig = {}
local Config = TomoSyncConfig
local TS     = TomoSync

-- ============================================================
--  Helpers UI
-- ============================================================

local function CreateCheckbox(parent, label, tooltip, x, y, getter, setter)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local txt = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txt:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    txt:SetText(label)

    cb:SetScript("OnClick",  function(self) setter(self:GetChecked()) end)
    cb:SetScript("OnShow",   function(self) self:SetChecked(getter()) end)
    cb:SetScript("OnEnter",  function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        if tooltip then GameTooltip:AddLine(tooltip, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave",  function() GameTooltip:Hide() end)
    return cb
end

local function CreateSlider(parent, label, tooltip, min, max, step, x, y, getter, setter)
    local sliderName = "TomoSyncSlider_" .. label:gsub("[^%w]", "_")
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(240, 52)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local lbl = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    lbl:SetText(label)

    local slider = CreateFrame("Slider", sliderName, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -18)
    slider:SetWidth(220)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText(tostring(min))
    slider.High:SetText(tostring(max))

    local valText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valText:SetPoint("TOP", slider, "BOTTOM", 0, -2)

    slider:SetScript("OnValueChanged", function(self, val)
        val = math.floor(val + 0.5)
        valText:SetText(tostring(val))
        setter(val)
        local tip = TS.modules["Tooltip"]
        if tip then tip:ResetCache() end
    end)
    slider:SetScript("OnShow", function(self)
        local v = getter()
        self:SetValue(v)
        valText:SetText(tostring(v))
    end)
    slider:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        if tooltip then GameTooltip:AddLine(tooltip, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    slider:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return container
end

-- ============================================================
--  Construction du panneau
-- ============================================================

local panel = nil

local function BuildPanel()
    panel = CreateFrame("Frame", "TomoSyncConfigPanel", UIParent, "BackdropTemplate")
    panel:SetSize(440, 420)
    panel:SetPoint("CENTER")
    panel:SetMovable(true)
    panel:EnableMouse(true)
    panel:RegisterForDrag("LeftButton")
    panel:SetScript("OnDragStart", panel.StartMoving)
    panel:SetScript("OnDragStop",  panel.StopMovingOrSizing)
    panel:SetFrameStrata("DIALOG")
    panel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    panel:SetBackdropBorderColor(0.8, 0.27, 1, 1)   -- bordure pourpre
    panel:Hide()

    -- Titre
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("|cFFCC44FFTomo|r|cFFFFFFFFSync|r |cFFAAAAAA— Paramètres|r")

    -- Fermeture
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() panel:Hide() end)

    -- Séparateur titre
    local sep1 = panel:CreateTexture(nil, "ARTWORK")
    sep1:SetSize(400, 2)
    sep1:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -44)
    sep1:SetColorTexture(0.8, 0.27, 1, 0.5)

    local db = TS.db.settings

    -- ── Section : Affichage tooltip ──────────────────────────
    local secTT = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    secTT:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -58)
    secTT:SetText("|cFFCC44FFAffichage dans le tooltip|r")

    local L = TomoSyncLocale

    CreateCheckbox(panel, TS:L("CFG_SHOW_BAGS"),    nil, 20, -78,
        function() return db.showBags    end,
        function(v) db.showBags    = v; if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end end)

    CreateCheckbox(panel, TS:L("CFG_SHOW_BANK"),    nil, 20, -106,
        function() return db.showBank    end,
        function(v) db.showBank    = v; if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end end)

    CreateCheckbox(panel, TS:L("CFG_SHOW_REAGENT"), nil, 20, -134,
        function() return db.showReagent end,
        function(v) db.showReagent = v; if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end end)

    CreateCheckbox(panel, TS:L("CFG_SHOW_EQUIP"),   nil, 20, -162,
        function() return db.showEquip   end,
        function(v) db.showEquip   = v; if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end end)

    CreateCheckbox(panel, TS:L("CFG_SHOW_TOTAL"),   nil, 20, -190,
        function() return db.showTotal   end,
        function(v) db.showTotal   = v; if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end end)

    -- ── Séparateur ───────────────────────────────────────────
    local sep2 = panel:CreateTexture(nil, "ARTWORK")
    sep2:SetSize(400, 1)
    sep2:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -222)
    sep2:SetColorTexture(1, 1, 1, 0.1)

    -- ── Section : Filtres ────────────────────────────────────
    local secFilter = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    secFilter:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -236)
    secFilter:SetText("|cFFCC44FFFiltres|r")

    CreateCheckbox(panel, TS:L("CFG_ONLY_REALM"),  nil, 20, -256,
        function() return db.onlyRealm  end,
        function(v) db.onlyRealm  = v; if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end end)

    -- ── Séparateur ───────────────────────────────────────────
    local sep3 = panel:CreateTexture(nil, "ARTWORK")
    sep3:SetSize(400, 1)
    sep3:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -294)
    sep3:SetColorTexture(1, 1, 1, 0.1)

    -- ── Slider seuil ─────────────────────────────────────────
    local secSlider = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    secSlider:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -308)
    secSlider:SetText("|cFFCC44FFSeuil|r")

    CreateSlider(panel, TS:L("CFG_THRESHOLD"), TS:L("CFG_THRESHOLD_TT"),
        0, 100, 1, 20, -328,
        function() return db.threshold or 0 end,
        function(v) db.threshold = v end)

    -- ── Séparateur ───────────────────────────────────────────
    local sep4 = panel:CreateTexture(nil, "ARTWORK")
    sep4:SetSize(400, 2)
    sep4:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -384)
    sep4:SetColorTexture(0.8, 0.27, 1, 0.4)

    -- ── Boutons bas de page ───────────────────────────────────

    -- Forcer un scan
    local scanBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    scanBtn:SetSize(160, 28)
    scanBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 20)
    scanBtn:SetText("Forcer un scan des sacs")
    scanBtn:SetScript("OnClick", function()
        local scanner = TS.modules["Scanner"]
        if scanner then
            scanner:ScanBags()
            scanner:ScanEquipped()
            TS:Print(TS:L("SCAN_BAGS_DONE"))
        end
    end)

    -- Effacer les données
    local clearBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearBtn:SetSize(180, 28)
    clearBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 20)
    clearBtn:SetText("|cFFFF4444Effacer toutes les données|r")
    clearBtn:SetScript("OnClick", function()
        TomoSyncDB = {}
        TS.db.global = TomoSyncDB
        TS.db.char   = { items = {} }
        TomoSyncDB[TS.realm] = { [TS.charName] = TS.db.char }
        if TS.modules.Tooltip then TS.modules.Tooltip:ResetCache() end
        TS:Print("Toutes les données supprimées.")
    end)

    tinsert(UISpecialFrames, "TomoSyncConfigPanel")
end

-- ============================================================
--  API publique
-- ============================================================

function Config:Toggle()
    if not panel then BuildPanel() end
    if panel:IsShown() then
        panel:Hide()
    else
        panel:Show()
    end
end
