-- TomoPorter | TomoPorter.lua
-- Addon standalone — téléporteurs donjon/raid disponibles
-- Auteur : Tomo | Version 1.0.2
-- Thème : Cyan
--
-- /tmp  → ouvre/ferme la fenêtre

TomoPorter = TomoPorter or {}

local L    = TomoPorter.L
local Data = TomoPorter.Data

-- =========================================================
-- PALETTE CYAN
-- =========================================================
local CYAN = {
    bgMain      = { 0.04, 0.07, 0.10, 0.97 },
    bgTitleBar  = { 0.02, 0.05, 0.09, 1    },
    bgBtn       = { 0.05, 0.12, 0.18, 0.88 },
    bgBtnHover  = { 0.08, 0.25, 0.35, 1    },
    bgBtnOff    = { 0.04, 0.07, 0.10, 0.50 },
    bgTabActive = { 0.03, 0.28, 0.38, 1    },
    bgTabIdle   = { 0.04, 0.10, 0.15, 1    },
    bgSep       = { 0.05, 0.22, 0.30, 1    },
    border      = { 0.10, 0.55, 0.70, 0.80 },
    borderDim   = { 0.07, 0.30, 0.40, 0.60 },
    textMain    = { 1.00, 1.00, 1.00, 1    },
    textHeader  = { 0.30, 0.90, 1.00, 1    },
    textDim     = { 0.35, 0.60, 0.65, 1    },
    textTitle   = { 0.30, 0.90, 1.00, 1    },
    textTabOn   = { 0.20, 1.00, 1.00, 1    },
    textTabOff  = { 0.55, 0.75, 0.80, 1    },
}

-- =========================================================
-- DIMENSIONS
-- =========================================================
local CFG = {
    frameW  = 580,
    frameH  = 490,
    colW    = 255,
    colGap  = 20,
    btnH    = 30,
    btnPad  = 3,
    iconSz  = 22,
    tabH    = 22,
    headerH = 20,
}

-- =========================================================
-- LISTE GLOBALE DES BOUTONS TP (pour le refresh)
-- =========================================================
-- Chaque bouton créé est enregistré ici pour pouvoir être
-- rafraîchi par RefreshAllButtons() hors combat.
TomoPorter.allButtons = {}

-- =========================================================
-- HELPERS API
-- =========================================================

-- IsPlayerSpell est plus fiable qu'IsSpellKnown pour les téléporteurs
-- (pattern identique à TomoMod MythicKeys)
local function HasTeleport(spellID)
    if not spellID then return false end
    if IsPlayerSpell then return IsPlayerSpell(spellID) end
    return false
end

-- Récupère l'icône d'un sort avec pcall (valeurs secrètes TWW)
local function GetSpellIcon(spellID)
    if not spellID then return nil end
    if C_Spell and C_Spell.GetSpellTexture then
        local ok, tex = pcall(C_Spell.GetSpellTexture, spellID)
        if ok and tex then return tex end
    end
    if GetSpellTexture then
        local ok, tex = pcall(GetSpellTexture, spellID)
        if ok and tex then return tex end
    end
    return nil
end

-- =========================================================
-- REFRESH D'UN BOUTON (état owned/non owned)
-- Doit être appelé hors combat (InCombatLockdown check à l'appelant)
-- =========================================================
local function RefreshButton(btn)
    local spellID = btn.tpSpellID
    local owned   = HasTeleport(spellID)
    btn.tpOwned   = owned

    if owned then
        -- Active le cast sécurisé
        btn:SetAttribute("type",  "spell")
        btn:SetAttribute("spell", spellID)
        btn.tpBg:SetVertexColor(unpack(CYAN.bgBtn))
        btn.tpIcon:SetDesaturated(false)
        btn.tpIcon:SetAlpha(1)
        btn.tpLabel:SetTextColor(unpack(CYAN.textMain))
    else
        -- Désactive le cast sécurisé
        btn:SetAttribute("type",  nil)
        btn:SetAttribute("spell", nil)
        btn.tpBg:SetVertexColor(unpack(CYAN.bgBtnOff))
        btn.tpIcon:SetDesaturated(true)
        btn.tpIcon:SetAlpha(0.35)
        if spellID then
            btn.tpLabel:SetTextColor(unpack(CYAN.textDim))
        else
            btn.tpLabel:SetTextColor(0.40, 0.40, 0.40, 1)
        end
    end
end

-- Rafraîchit tous les boutons enregistrés (hors combat uniquement)
local function RefreshAllButtons()
    if InCombatLockdown() then return end
    for _, btn in ipairs(TomoPorter.allButtons) do
        if btn:IsVisible() or btn.tpSpellID then
            RefreshButton(btn)
        end
    end
end

-- =========================================================
-- HELPERS UI
-- =========================================================
local function SetBG(frame, r, g, b, a)
    local t = frame.bgTex or frame:CreateTexture(nil, "BACKGROUND")
    frame.bgTex = t
    t:SetAllPoints()
    t:SetTexture("Interface/Buttons/WHITE8X8")
    t:SetVertexColor(r, g, b, a)
end

-- =========================================================
-- CADRE PRINCIPAL
-- =========================================================
local function CreateMainFrame()
    local f = CreateFrame("Frame", "TomoPorterFrame", UIParent, "BackdropTemplate")
    f:SetSize(CFG.frameW, CFG.frameH)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetFrameStrata("DIALOG")
    f:Hide()

    f:SetBackdrop({
        bgFile   = "Interface/Buttons/WHITE8X8",
        edgeFile = "Interface/Buttons/WHITE8X8",
        edgeSize = 1,
    })
    f:SetBackdropColor(unpack(CYAN.bgMain))
    f:SetBackdropBorderColor(unpack(CYAN.border))

    -- Barre de titre
    local bar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    bar:SetPoint("TOPLEFT",  f, "TOPLEFT",   1, -1)
    bar:SetPoint("TOPRIGHT", f, "TOPRIGHT",  -1, -1)
    bar:SetHeight(26)
    bar:SetBackdrop({ bgFile = "Interface/Buttons/WHITE8X8",
                      edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1 })
    bar:SetBackdropColor(unpack(CYAN.bgTitleBar))
    bar:SetBackdropBorderColor(unpack(CYAN.borderDim))
    bar:EnableMouse(true)
    bar:RegisterForDrag("LeftButton")
    bar:SetScript("OnDragStart", function() f:StartMoving() end)
    bar:SetScript("OnDragStop",  function() f:StopMovingOrSizing() end)

    -- Trait cyan sous la titlebar
    local underline = f:CreateTexture(nil, "ARTWORK")
    underline:SetHeight(1)
    underline:SetPoint("TOPLEFT",  bar, "BOTTOMLEFT",  0, 0)
    underline:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    underline:SetTexture("Interface/Buttons/WHITE8X8")
    underline:SetVertexColor(unpack(CYAN.border))

    local ico = bar:CreateTexture(nil, "ARTWORK")
    ico:SetSize(18, 18)
    ico:SetPoint("LEFT", bar, "LEFT", 8, 0)
    ico:SetTexture(132161)

    local titleTxt = bar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleTxt:SetPoint("LEFT", ico, "RIGHT", 6, 0)
    titleTxt:SetText(L["TITLE"])
    titleTxt:SetTextColor(unpack(CYAN.textTitle))

    -- Bouton X
    local closeBtn = CreateFrame("Button", nil, bar)
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", bar, "RIGHT", -6, 0)
    SetBG(closeBtn, 0.55, 0.05, 0.05, 0.8)
    local xTxt = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    xTxt:SetAllPoints()
    xTxt:SetText("X")
    xTxt:SetTextColor(1, 0.6, 0.6, 1)
    closeBtn:SetScript("OnEnter", function() closeBtn.bgTex:SetVertexColor(0.85, 0.10, 0.10, 1) end)
    closeBtn:SetScript("OnLeave", function() closeBtn.bgTex:SetVertexColor(0.55, 0.05, 0.05, 0.8) end)
    closeBtn:SetScript("OnClick", function() f:Hide() end)

    -- Séparateur vertical central
    local vsep = f:CreateTexture(nil, "BACKGROUND")
    vsep:SetWidth(1)
    vsep:SetPoint("TOP",    f, "TOP",    0, -28)
    vsep:SetPoint("BOTTOM", f, "BOTTOM", 0, 6)
    vsep:SetTexture("Interface/Buttons/WHITE8X8")
    vsep:SetVertexColor(unpack(CYAN.borderDim))

    return f
end

-- =========================================================
-- BOUTON DE TÉLÉPORT
-- =========================================================
-- Pattern identique à TomoMod MythicKeys :
--   • SecureActionButtonTemplate TOUJOURS (pas conditionnel)
--   • RegisterForClicks("AnyUp", "AnyDown") obligatoire
--   • Attributs type/spell définis par RefreshButton() hors combat
--   • OnEnter/OnLeave : scripts non protégés, pas de problème
-- =========================================================
local function CreateTeleportButton(parent, entry, yOff)
    local spellID = entry.spellID

    -- Toujours SecureActionButtonTemplate + RegisterForClicks
    local btn = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:SetSize(CFG.colW - 6, CFG.btnH)
    btn:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -yOff)

    -- Données stockées sur le bouton (pattern TomoMod)
    btn.tpSpellID = spellID
    btn.tpOwned   = false

    -- Fond (référence stockée pour le refresh)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface/Buttons/WHITE8X8")
    bg:SetVertexColor(unpack(CYAN.bgBtnOff))  -- état initial : désactivé
    btn.tpBg = bg

    -- Ligne de bord bas
    local bline = btn:CreateTexture(nil, "BORDER")
    bline:SetHeight(1)
    bline:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  0, 0)
    bline:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", 0, 0)
    bline:SetTexture("Interface/Buttons/WHITE8X8")
    bline:SetVertexColor(unpack(CYAN.borderDim))

    -- Icône (référence stockée pour le refresh)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetSize(CFG.iconSz, CFG.iconSz)
    icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
    local tex = GetSpellIcon(spellID)
    if tex then
        icon:SetTexture(tex)
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    else
        icon:SetTexture("Interface/Icons/INV_Misc_QuestionMark")
    end
    icon:SetDesaturated(true)
    icon:SetAlpha(0.35)
    btn.tpIcon = icon

    -- Texte (référence stockée pour le refresh)
    local lbl = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    lbl:SetPoint("LEFT",  icon, "RIGHT", 5, 0)
    lbl:SetPoint("RIGHT", btn,  "RIGHT", -4, 0)
    lbl:SetJustifyH("LEFT")
    lbl:SetText(entry.name)
    lbl:SetTextColor(unpack(CYAN.textDim))
    btn.tpLabel = lbl

    -- Tooltip (OnEnter/OnLeave : non protégés, OK)
    btn:SetScript("OnEnter", function(self)
        if self.tpOwned then
            self.tpBg:SetVertexColor(unpack(CYAN.bgBtnHover))
        end
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if spellID then
            GameTooltip:SetSpellByID(spellID)
        else
            GameTooltip:AddLine(entry.name, 1, 1, 1)
            GameTooltip:AddLine("SpellID non disponible", 0.6, 0.3, 0.3)
        end
        if self.tpOwned then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["TOOLTIP_CLICK"], 0.5, 0.9, 1)
        else
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["TOOLTIP_UNKNOWN"], 0.5, 0.5, 0.5)
        end
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", function(self)
        if self.tpOwned then
            self.tpBg:SetVertexColor(unpack(CYAN.bgBtn))
        end
        GameTooltip:Hide()
    end)

    -- Enregistrement global pour RefreshAllButtons()
    table.insert(TomoPorter.allButtons, btn)

    -- Refresh immédiat si hors combat (définit les attributs sécurisés)
    if not InCombatLockdown() then
        RefreshButton(btn)
    end

    return btn
end

-- =========================================================
-- ONGLET (Current / Legacy)
-- =========================================================
local function CreateTab(parent, label)
    local btn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    btn:SetSize(86, CFG.tabH)
    btn:SetBackdrop({ bgFile   = "Interface/Buttons/WHITE8X8",
                      edgeFile = "Interface/Buttons/WHITE8X8", edgeSize = 1 })

    local txt = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    txt:SetAllPoints()
    txt:SetText(label)

    function btn:SetActive(active)
        if active then
            self:SetBackdropColor(unpack(CYAN.bgTabActive))
            self:SetBackdropBorderColor(unpack(CYAN.border))
            txt:SetTextColor(unpack(CYAN.textTabOn))
        else
            self:SetBackdropColor(unpack(CYAN.bgTabIdle))
            self:SetBackdropBorderColor(unpack(CYAN.borderDim))
            txt:SetTextColor(unpack(CYAN.textTabOff))
        end
    end

    btn:SetActive(false)
    return btn
end

-- =========================================================
-- EN-TÊTE DE GROUPE (expansion / saison)
-- =========================================================
local function CreateGroupHeader(parent, label, yOff)
    local bg = parent:CreateTexture(nil, "BACKGROUND")
    bg:SetSize(CFG.colW - 6, CFG.headerH)
    bg:SetPoint("TOPLEFT", parent, "TOPLEFT", 3, -yOff)
    bg:SetTexture("Interface/Buttons/WHITE8X8")
    bg:SetVertexColor(unpack(CYAN.bgSep))

    local accent = parent:CreateTexture(nil, "ARTWORK")
    accent:SetSize(2, CFG.headerH)
    accent:SetPoint("TOPLEFT", bg, "TOPLEFT", 0, 0)
    accent:SetTexture("Interface/Buttons/WHITE8X8")
    accent:SetVertexColor(unpack(CYAN.textHeader))

    local hdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hdr:SetPoint("TOPLEFT",     bg, "TOPLEFT",     6, 0)
    hdr:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", -4, 0)
    hdr:SetJustifyH("LEFT")
    hdr:SetText(label)
    hdr:SetTextColor(unpack(CYAN.textHeader))

    return CFG.headerH
end

-- =========================================================
-- SCROLL FRAME
-- =========================================================
local function CreateScrollFrame(parent, x, y, w)
    local sf = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT",    parent, "TOPLEFT",    x, y)
    sf:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", x, 6)
    sf:SetWidth(w)

    local sb = sf.ScrollBar
    if sb then
        sb:SetWidth(8)
        sb:ClearAllPoints()
        sb:SetPoint("TOPRIGHT",    sf, "TOPRIGHT",    10, -16)
        sb:SetPoint("BOTTOMRIGHT", sf, "BOTTOMRIGHT", 10,  16)
        if sb.ScrollUpButton   then sb.ScrollUpButton:Hide()   end
        if sb.ScrollDownButton then sb.ScrollDownButton:Hide() end
    end

    local content = CreateFrame("Frame", nil, sf)
    content:SetWidth(w - 14)
    content:SetHeight(1)
    sf:SetScrollChild(content)

    return sf, content
end

-- =========================================================
-- POPULATION D'UNE COLONNE
-- =========================================================
local function PopulateColumn(scrollFrame, content, sections, isLegacy)
    local parent = content:GetParent()
    content:Hide()

    local newContent = CreateFrame("Frame", nil, parent)
    newContent:SetWidth(content:GetWidth())
    newContent:SetHeight(1)
    scrollFrame:SetScrollChild(newContent)
    scrollFrame:SetVerticalScroll(0)

    local yOff  = 2
    local count = 0

    for _, section in ipairs(sections) do
        local lbl = section.seasonLabel or section.expansion or ""

        if isLegacy and lbl ~= "" then
            local hUsed = CreateGroupHeader(newContent, lbl, yOff)
            yOff = yOff + hUsed + 3
        end

        for _, entry in ipairs(section.entries) do
            CreateTeleportButton(newContent, entry, yOff)
            yOff  = yOff + CFG.btnH + CFG.btnPad
            count = count + 1
        end

        if isLegacy then yOff = yOff + 6 end
    end

    if count == 0 then
        local empty = newContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        empty:SetPoint("TOP", newContent, "TOP", 0, -20)
        empty:SetText(L["NO_TELEPORT"])
        empty:SetTextColor(unpack(CYAN.textDim))
        yOff = 50
    end

    newContent:SetHeight(math.max(yOff, 10))
    return newContent
end

-- =========================================================
-- CONSTRUCTION D'UNE COLONNE
-- =========================================================
local function BuildColumn(parent, title, category, anchorFrame, anchorPoint, xOff)
    local colW = CFG.colW

    local hdr = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hdr:SetPoint("TOPLEFT", anchorFrame, anchorPoint, xOff + 3, -30)
    hdr:SetText(title)
    hdr:SetTextColor(unpack(CYAN.textHeader))

    local hline = parent:CreateTexture(nil, "ARTWORK")
    hline:SetHeight(1)
    hline:SetWidth(colW)
    hline:SetPoint("TOPLEFT", hdr, "BOTTOMLEFT", 0, -2)
    hline:SetTexture("Interface/Buttons/WHITE8X8")
    hline:SetVertexColor(unpack(CYAN.border))

    local tabCur = CreateTab(parent, L["CURRENT"])
    tabCur:SetPoint("TOPLEFT", anchorFrame, anchorPoint, xOff + 3, -50)

    local tabLeg = CreateTab(parent, L["LEGACY"])
    tabLeg:SetPoint("TOPLEFT", tabCur, "TOPRIGHT", 3, 0)

    local scrollFrame, contentRef = CreateScrollFrame(parent, xOff + 3, -76, colW)
    local currentContent = contentRef

    local tabActive = "current"

    local function Refresh()
        local isLeg = (tabActive == "legacy")
        local secs  = Data[category][isLeg and "legacy" or "current"]
        tabCur:SetActive(not isLeg)
        tabLeg:SetActive(isLeg)
        currentContent = PopulateColumn(scrollFrame, currentContent, secs, isLeg)
    end

    tabCur:SetScript("OnClick", function() tabActive = "current"; Refresh() end)
    tabLeg:SetScript("OnClick", function() tabActive = "legacy";  Refresh() end)

    tabCur:SetActive(true)
    local initSecs = Data[category]["current"]
    currentContent = PopulateColumn(scrollFrame, currentContent, initSecs, false)
end

-- =========================================================
-- BUILD UI
-- =========================================================
local function BuildUI()
    local f = CreateMainFrame()
    TomoPorter.frame = f

    BuildColumn(f, L["DUNGEONS"], "dungeons", f, "TOPLEFT", 0)
    BuildColumn(f, L["RAIDS"],    "raids",    f, "TOPLEFT", CFG.colW + CFG.colGap + 10)
end

-- =========================================================
-- SLASH COMMANDS
-- =========================================================
local function Toggle()
    local f = TomoPorter.frame
    if not f then return end
    if f:IsShown() then
        f:Hide()
    else
        f:Show()
        -- Refresh au Show si on sort juste du combat
        if not InCombatLockdown() then
            RefreshAllButtons()
        end
    end
end

SLASH_TOPORTER1 = "/tmp"
SlashCmdList["TOPORTER"] = function(msg)
    local cmd = (msg or ""):lower():match("^%s*(%S*)")
    if cmd == "help" or cmd == "?" then
        print("|cff00ddffTomoPorter|r  v1.0.2")
        print("  /tmp     — ouvre/ferme la fenêtre")
    else
        Toggle()
    end
end

-- =========================================================
-- EVENTS
-- =========================================================
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("SPELLS_CHANGED")       -- sort appris/oublié
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- sortie de combat

eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        BuildUI()
        print("|cff00ddffTomoPorter|r v1.0.2 chargé — |cff4db8cc/tmp|r pour ouvrir")
        self:UnregisterEvent("PLAYER_LOGIN")

    elseif event == "SPELLS_CHANGED" then
        -- Un sort a été appris ou oublié : mise à jour hors combat
        if not InCombatLockdown() then
            RefreshAllButtons()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Sortie de combat : on peut maintenant modifier les attributs sécurisés
        RefreshAllButtons()
    end
end)