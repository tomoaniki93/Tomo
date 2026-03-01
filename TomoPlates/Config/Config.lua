-- =====================================
-- Config.lua — Configuration UI
-- TomoPlates v1.0.0
-- Purple accent: #8b5cf6 = { 0.545, 0.361, 0.965 }
-- =====================================

local W = TomoPlates_Widgets  -- set after Widgets.lua loads

local ACCENT = "|cff8b5cf6"

-- =====================================
-- HELPERS
-- =====================================
local function DB() return TomoPlatesDB end

local function RefreshNP()
    if TomoPlates_NP then TomoPlates_NP.RefreshAll() end
end

local function ApplyNP()
    if TomoPlates_NP then TomoPlates_NP.ApplySettings() end
end

-- =====================================
-- TAB 1 — GÉNÉRAL
-- =====================================
local function BuildGeneralTab(parent)
    W = W or TomoPlates_Widgets
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB()
    local y = -10

    local _, ny = W.CreateSectionHeader(c, "Général", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Activer TomoPlates", db.enabled, y, function(v)
        db.enabled = v
        if TomoPlates_NP then
            if v then TomoPlates_NP.Enable() else TomoPlates_NP.Disable() end
        end
    end)
    y = ny

    local _, ny = W.CreateInfoText(c, "Remplace les nameplates Blizzard par un affichage personnalisé.", y)
    y = ny

    local _, ny = W.CreateSectionHeader(c, "Dimensions", y)
    y = ny

    local _, ny = W.CreateSlider(c, "Largeur", db.width, 60, 300, 5, y, function(v)
        db.width = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Hauteur (santé)", db.height, 6, 40, 1, y, function(v)
        db.height = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Taille du nom", db.nameFontSize or 11, 6, 20, 1, y, function(v)
        db.nameFontSize = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSectionHeader(c, "Affichage", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher le nom", db.showName, y, function(v)
        db.showName = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher le niveau", db.showLevel, y, function(v)
        db.showLevel = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher le texte de santé", db.showHealthText, y, function(v)
        db.showHealthText = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateDropdown(c, "Format de santé", {
        { text = "Pourcentage",           value = "percent" },
        { text = "Valeur actuelle",        value = "current" },
        { text = "Valeur + pourcentage",   value = "current_percent" },
    }, db.healthTextFormat or "current_percent", y, function(v)
        db.healthTextFormat = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher la classification (élite, rare…)", db.showClassification, y, function(v)
        db.showClassification = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher la barre d'absorption", db.showAbsorb ~= false, y, function(v)
        db.showAbsorb = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher la menace (contour)", db.showThreat, y, function(v)
        db.showThreat = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Couleurs de classe pour les joueurs ennemis", db.useClassColors, y, function(v)
        db.useClassColors = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSectionHeader(c, "Barre de cast", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher la barre de cast", db.showCastbar, y, function(v)
        db.showCastbar = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Hauteur de la barre de cast", db.castbarHeight, 4, 20, 1, y, function(v)
        db.castbarHeight = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Couleur de cast (interruptible)", db.castbarColor, y, function(r, g, b)
        db.castbarColor = { r = r, g = g, b = b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Couleur de cast (non-interruptible)", db.castbarUninterruptible, y, function(r, g, b)
        db.castbarUninterruptible = { r = r, g = g, b = b }; RefreshNP()
    end)
    y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 2 — AURAS
-- =====================================
local function BuildAurasTab(parent)
    W = W or TomoPlates_Widgets
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB()
    local y = -10

    local _, ny = W.CreateSectionHeader(c, "Debuffs (au-dessus du nom)", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher mes debuffs", db.showAuras, y, function(v)
        db.showAuras = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Taille des icônes", db.auraSize, 12, 36, 1, y, function(v)
        db.auraSize = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Nombre max d'auras", db.maxAuras, 1, 10, 1, y, function(v)
        db.maxAuras = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Seulement mes debuffs", db.showOnlyMyAuras, y, function(v)
        db.showOnlyMyAuras = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSectionHeader(c, "Buffs ennemis (à gauche de la barre)", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Afficher les buffs ennemis", db.showEnemyBuffs, y, function(v)
        db.showEnemyBuffs = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Taille des buffs ennemis", db.enemyBuffSize or 22, 12, 36, 1, y, function(v)
        db.enemyBuffSize = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateSlider(c, "Nombre max de buffs ennemis", db.maxEnemyBuffs or 4, 1, 8, 1, y, function(v)
        db.maxEnemyBuffs = v; RefreshNP()
    end)
    y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 3 — AVANCÉ (couleurs, alpha, stacking, tank)
-- =====================================
local function BuildAdvancedTab(parent)
    W = W or TomoPlates_Widgets
    local scroll = W.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB()
    local y = -10

    -- Alpha
    local _, ny = W.CreateSectionHeader(c, "Transparence", y)
    y = ny

    local _, ny = W.CreateSlider(c, "Alpha (cible sélectionnée)", db.selectedAlpha, 0.3, 1.0, 0.05, y, function(v)
        db.selectedAlpha = v
    end, "%.2f")
    y = ny

    local _, ny = W.CreateSlider(c, "Alpha (autres)", db.unselectedAlpha, 0.3, 1.0, 0.05, y, function(v)
        db.unselectedAlpha = v
    end, "%.2f")
    y = ny

    -- Stacking
    local _, ny = W.CreateSectionHeader(c, "Empilement des nameplates", y)
    y = ny

    local _, ny = W.CreateSlider(c, "Chevauchement vertical", db.overlapV or 1.05, 0.5, 3.0, 0.1, y, function(v)
        db.overlapV = v; ApplyNP()
    end, "%.1f")
    y = ny

    local _, ny = W.CreateSlider(c, "Marge haute (écran)", db.topInset or 0.065, 0.01, 0.5, 0.005, y, function(v)
        db.topInset = v; ApplyNP()
    end, "%.3f")
    y = ny

    -- Health colors
    local _, ny = W.CreateSectionHeader(c, "Couleurs de santé", y)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Hostile", db.colors.hostile, y, function(r, g, b)
        db.colors.hostile = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Neutre", db.colors.neutral, y, function(r, g, b)
        db.colors.neutral = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Allié", db.colors.friendly, y, function(r, g, b)
        db.colors.friendly = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Tapé (autre joueur)", db.colors.tapped, y, function(r, g, b)
        db.colors.tapped = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Focus", db.colors.focus, y, function(r, g, b)
        db.colors.focus = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    -- NPC type colors
    local _, ny = W.CreateSectionHeader(c, "Couleurs par type de PNJ", y)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Lanceur de sorts", db.colors.caster, y, function(r, g, b)
        db.colors.caster = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Mini-boss (élite + haut niveau)", db.colors.miniboss, y, function(r, g, b)
        db.colors.miniboss = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Ennemi en combat", db.colors.enemyInCombat, y, function(r, g, b)
        db.colors.enemyInCombat = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateInfoText(c, "Les ennemis hors combat sont assombris automatiquement (×0.60).", y)
    y = ny

    -- Classification colors
    local _, ny = W.CreateSectionHeader(c, "Couleurs de classification", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Utiliser les couleurs de classification", db.useClassificationColors, y, function(v)
        db.useClassificationColors = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Boss", db.colors.boss, y, function(r, g, b)
        db.colors.boss = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Élite", db.colors.elite, y, function(r, g, b)
        db.colors.elite = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Rare", db.colors.rare, y, function(r, g, b)
        db.colors.rare = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Normal", db.colors.normal, y, function(r, g, b)
        db.colors.normal = { r=r, g=g, b=b }; RefreshNP()
    end)
    y = ny

    -- Tank Mode
    local _, ny = W.CreateSectionHeader(c, "Mode Tank", y)
    y = ny

    local _, ny = W.CreateCheckbox(c, "Activer le mode tank (en instance)", db.tankMode, y, function(v)
        db.tankMode = v; RefreshNP()
    end)
    y = ny

    local _, ny = W.CreateInfoText(c, "Les barres changent de couleur selon la menace. En mode tank, le contour de menace est réduit à 50% d'opacité.", y)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Pas de menace (tank)", db.tankColors.noThreat, y, function(r, g, b)
        db.tankColors.noThreat = { r=r, g=g, b=b }
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Menace faible (tank)", db.tankColors.lowThreat, y, function(r, g, b)
        db.tankColors.lowThreat = { r=r, g=g, b=b }
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "Menace obtenue (tank)", db.tankColors.hasThreat, y, function(r, g, b)
        db.tankColors.hasThreat = { r=r, g=g, b=b }
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "DPS a l'aggro", db.tankColors.dpsHasAggro, y, function(r, g, b)
        db.tankColors.dpsHasAggro = { r=r, g=g, b=b }
    end)
    y = ny

    local _, ny = W.CreateColorPicker(c, "DPS proche de l'aggro", db.tankColors.dpsNearAggro, y, function(r, g, b)
        db.tankColors.dpsNearAggro = { r=r, g=g, b=b }
    end)
    y = ny

    -- Reset
    local _, ny = W.CreateSeparator(c, y)
    y = ny

    local _, ny = W.CreateButton(c, "Réinitialiser tous les paramètres", 240, y, function()
        TomoPlates_ResetDB()
    end)
    y = ny - 20

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- MAIN CONFIG WINDOW
-- =====================================
local configFrame

local function BuildConfigWindow()
    W = TomoPlates_Widgets

    -- Main window
    local f = CreateFrame("Frame", "TomoPlatesConfig", UIParent, "BackdropTemplate")
    f:SetSize(520, 560)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
    f:Hide()

    -- Background
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.08, 0.08, 0.10, 0.97)

    -- Top accent line (purple)
    local topLine = f:CreateTexture(nil, "BORDER")
    topLine:SetPoint("TOPLEFT",  f, "TOPLEFT",  0, 0)
    topLine:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
    topLine:SetHeight(2)
    topLine:SetColorTexture(0.545, 0.361, 0.965, 1)

    -- Border
    local border = f:CreateTexture(nil, "BORDER")
    border:SetAllPoints()

    -- Title bar
    local titleBar = f:CreateTexture(nil, "ARTWORK")
    titleBar:SetPoint("TOPLEFT",  f, "TOPLEFT",  0, -2)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -2)
    titleBar:SetHeight(36)
    titleBar:SetColorTexture(0.12, 0.12, 0.15, 1)

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont("Interface\\AddOns\\TomoPlates\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    title:SetPoint("LEFT", f, "LEFT", 16, 0)
    title:SetPoint("TOP",  f, "TOP",  0, -10)
    title:SetText("|cff8b5cf6Tomo|rPlates  |cff555566v1.0.0|r")
    title:SetTextColor(0.90, 0.90, 0.92, 1)

    -- Close button
    local close = CreateFrame("Button", nil, f)
    close:SetSize(22, 22)
    close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -9)
    local closeText = close:CreateFontString(nil, "OVERLAY")
    closeText:SetFont("Interface\\AddOns\\TomoPlates\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    closeText:SetAllPoints()
    closeText:SetText("×")
    closeText:SetTextColor(0.6, 0.6, 0.65, 1)
    close:SetScript("OnClick", function() f:Hide() end)
    close:SetScript("OnEnter", function() closeText:SetTextColor(0.9, 0.3, 0.3, 1) end)
    close:SetScript("OnLeave", function() closeText:SetTextColor(0.6, 0.6, 0.65, 1) end)

    -- Content area (below title bar)
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT",     f, "TOPLEFT",     8,  -40)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8,   8)

    -- Tabs
    local tabs = {
        { key = "general",  label = "Général",  builder = BuildGeneralTab  },
        { key = "auras",    label = "Auras",    builder = BuildAurasTab    },
        { key = "advanced", label = "Avancé",   builder = BuildAdvancedTab },
    }

    local tabPanel = W.CreateTabPanel(content, tabs)
    tabPanel:SetAllPoints(content)

    -- Hint
    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont("Interface\\AddOns\\TomoPlates\\Assets\\Fonts\\Poppins-Medium.ttf", 9, "NONE")
    hint:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 6)
    hint:SetText("|cff555566/tp pour toggle  •  /tp reset pour réinitialiser|r")

    return f
end

function TomoPlates_OpenConfig()
    W = TomoPlates_Widgets
    if not configFrame then
        configFrame = BuildConfigWindow()
    end
    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()
    end
end

-- Register in WoW's addon settings (Escape menu)
local optionsFrame = CreateFrame("Frame", "TomoPlatesOptionsFrame")
optionsFrame.name = "TomoPlates"
optionsFrame:SetScript("OnShow", function()
    if not configFrame then
        configFrame = BuildConfigWindow()
    end
    configFrame:SetParent(optionsFrame)
    configFrame:ClearAllPoints()
    configFrame:SetPoint("TOPLEFT", optionsFrame, "TOPLEFT", 0, 0)
    configFrame:SetPoint("BOTTOMRIGHT", optionsFrame, "BOTTOMRIGHT", 0, 0)
    configFrame:Show()
end)
if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(optionsFrame, "TomoPlates")
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(optionsFrame)
end
