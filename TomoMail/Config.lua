-- TomoMail | Config.lua
-- Panneau de configuration accessible via /tomomail ou /tmail

TomoMailConfig = {}
local Config = TomoMailConfig
local TM     = TomoMail

-- ============================================================
--  Helpers UI
-- ============================================================

local function CreateCheckbox(parent, label, tooltip, x, y, getter, setter)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local txt = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    txt:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    txt:SetText(label)

    cb:SetScript("OnClick", function(self)
        setter(self:GetChecked())
    end)
    cb:SetScript("OnShow", function(self)
        self:SetChecked(getter())
    end)
    cb:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(label, 1, 1, 1)
        if tooltip then GameTooltip:AddLine(tooltip, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    cb:SetScript("OnLeave", function() GameTooltip:Hide() end)

    return cb
end

local function CreateSlider(parent, label, tooltip, min, max, step, x, y, getter, setter)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(220, 50)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

    local lbl = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    lbl:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
    lbl:SetText(label)

    -- Nom unique pour que GetName() ne retourne pas nil
    local sliderName = "TomoMailSlider_" .. label:gsub("%s", "_"):gsub("[^%%w_]", "")
    local slider = CreateFrame("Slider", sliderName, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -18)
    slider:SetWidth(200)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    -- Accès direct aux enfants plutôt que via _G
    slider.Low:SetText(tostring(min))
    slider.High:SetText(tostring(max))

    local valText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    valText:SetPoint("TOP", slider, "BOTTOM", 0, -2)

    slider:SetScript("OnValueChanged", function(self, val)
        val = math.floor(val + 0.5)
        valText:SetText(tostring(val))
        setter(val)
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
--  Création du panneau
-- ============================================================

local panel = nil

local function BuildPanel()
    panel = CreateFrame("Frame", "TomoMailConfigPanel", UIParent, "BackdropTemplate")
    panel:SetSize(420, 380)
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
    panel:SetBackdropBorderColor(1, 0.8, 0, 1)
    panel:Hide()

    -- === Barre de titre ===
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", panel, "TOPLEFT", 16, -16)
    title:SetText("|cFFFFCC00Tomo|r|cFFFFFFFFMail|r |cFFAAAAAA— Paramètres|r")

    -- === Fermeture ===
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -4, -4)
    closeBtn:SetScript("OnClick", function() panel:Hide() end)

    -- === Ligne de séparation ===
    local sep = panel:CreateTexture(nil, "ARTWORK")
    sep:SetSize(380, 2)
    sep:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -42)
    sep:SetColorTexture(1, 0.8, 0, 0.4)

    -- === Section : Affichage ===
    local secDisplay = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    secDisplay:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -56)
    secDisplay:SetText("|cFFFFCC00Affichage|r")

    local db = TM.db.profile

    CreateCheckbox(panel, TM:L("CFG_SHOW_ALTS"),  TM:L("CFG_SHOW_ALTS_TT"),  20, -78,
        function() return db.showAlts end,
        function(v) db.showAlts = v end)

    CreateCheckbox(panel, TM:L("CFG_SHOW_GUILD"), TM:L("CFG_SHOW_GUILD_TT"), 20, -108,
        function() return db.showGuild end,
        function(v) db.showGuild = v end)

    CreateCheckbox(panel, TM:L("CFG_GUILD_ONLINE"), TM:L("CFG_GUILD_ONLINE_TT"), 36, -136,
        function() return db.guildOnlineOnly end,
        function(v) db.guildOnlineOnly = v end)

    CreateCheckbox(panel, TM:L("CFG_SHOW_RECENT"), TM:L("CFG_SHOW_RECENT_TT"), 20, -166,
        function() return db.showRecent end,
        function(v) db.showRecent = v end)

    -- === Slider : nombre de récents ===
    local sep2 = panel:CreateTexture(nil, "ARTWORK")
    sep2:SetSize(380, 1)
    sep2:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -200)
    sep2:SetColorTexture(1, 1, 1, 0.1)

    CreateSlider(panel, TM:L("CFG_MAX_RECENT"), TM:L("CFG_MAX_RECENT_TT"),
        5, 25, 1, 20, -216,
        function() return db.maxRecent end,
        function(v)
            db.maxRecent = v
            -- Tronque si nécessaire
            while #db.recent > v do
                table.remove(db.recent)
            end
        end)

    -- === Section : Comportement ===
    local sep3 = panel:CreateTexture(nil, "ARTWORK")
    sep3:SetSize(380, 2)
    sep3:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -272)
    sep3:SetColorTexture(1, 0.8, 0, 0.4)

    local secBehav = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    secBehav:SetPoint("TOPLEFT", panel, "TOPLEFT", 20, -286)
    secBehav:SetText("|cFFFFCC00Comportement|r")

    CreateCheckbox(panel, TM:L("CFG_AUTOCOMPLETE"), TM:L("CFG_AUTOCOMPLETE_TT"), 20, -306,
        function() return db.useAutocomplete end,
        function(v)
            db.useAutocomplete = v
            if v then
                local qs = TM.modules["QuickSend"]
                if qs then qs:EnableAutocomplete() end
            end
        end)

    -- === Bouton : Effacer les récents ===
    local clearBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearBtn:SetSize(200, 28)
    clearBtn:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 20, 20)
    clearBtn:SetText("Effacer les récents")
    clearBtn:SetScript("OnClick", function()
        TM.db.profile.recent = {}
        TM:Print("Historique des récents effacé.")
    end)

    -- === Bouton : Effacer les alts ===
    local clearAltsBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearAltsBtn:SetSize(180, 28)
    clearAltsBtn:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 20)
    clearAltsBtn:SetText("Effacer tous les alts")
    clearAltsBtn:SetScript("OnClick", function()
        TM.db.global.alts = {}
        TM:RegisterCurrentChar()
        TM:Print("Liste des alts effacée. Personnage actuel re-enregistré.")
    end)

    -- Ferme avec Escape
    tinsert(UISpecialFrames, "TomoMailConfigPanel")
end

-- ============================================================
--  API publique
-- ============================================================

function Config:Toggle()
    if not panel then
        BuildPanel()
    end
    -- Recharge les valeurs à chaque ouverture
    if panel:IsShown() then
        panel:Hide()
    else
        -- Forcer la mise à jour des checkboxes/sliders
        for _, child in ipairs({ panel:GetChildren() }) do
            if child.GetChecked and child.SetChecked then
                -- Déclenche OnShow pour recharger la valeur
                local scripts = { child:GetScript("OnShow") }
                for _, fn in ipairs(scripts) do fn(child) end
            end
        end
        panel:Show()
    end
end
