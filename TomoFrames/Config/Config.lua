-- =====================================
-- Config.lua — Configuration UI
-- TomoFrames v1.0.0
-- Amber accent: #f59e0b = { 0.961, 0.620, 0.043 }
-- =====================================

-- W is initialized lazily (Widgets.lua loads before this file)
local function W() return TomoFrames_Widgets end
local function DB() return TomoFramesDB end

local AMBER = "|cfff59e0b"

-- =====================================
-- SHARED HELPERS
-- =====================================

local function RefreshAll()
    if TomoFrames_UF  then TomoFrames_UF.RefreshAll() end
    if TomoFrames_BF  then TomoFrames_BF.RefreshAll() end
end

local function RefreshUnit(unit)
    if TomoFrames_UF and TomoFrames_UF.RefreshUnit then
        TomoFrames_UF.RefreshUnit(unit)
    end
end

-- =====================================
-- REUSABLE: build one unit's options tab
-- =====================================
local function BuildUnitTab(parent, unit, unitLabel)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB()[unit]
    if not db then
        local msg = c:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        msg:SetPoint("CENTER")
        msg:SetText("Pas de configuration pour " .. unit)
        c:SetHeight(60)
        return scroll
    end
    local y = -10

    -- Enable
    local _, ny = Wg.CreateSectionHeader(c, unitLabel, y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer " .. unitLabel, db.enabled, y, function(v)
        db.enabled = v
        if TomoFrames_UF then
            if v then TomoFrames_UF.ShowUnit(unit) else TomoFrames_UF.HideUnit(unit) end
        end
    end); y = ny

    -- Dimensions
    local _, ny = Wg.CreateSectionHeader(c, "Dimensions", y); y = ny
    local _, ny = Wg.CreateSlider(c, "Largeur", db.width, 80, 500, 5, y, function(v)
        db.width = v; RefreshUnit(unit)
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur totale", db.height, 16, 120, 2, y, function(v)
        db.height = v; RefreshUnit(unit)
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur santé", db.healthHeight, 10, 100, 2, y, function(v)
        db.healthHeight = v; RefreshUnit(unit)
    end); y = ny
    if db.powerHeight ~= nil then
        local _, ny = Wg.CreateSlider(c, "Hauteur ressource", db.powerHeight, 0, 30, 1, y, function(v)
            db.powerHeight = v; RefreshUnit(unit)
        end); y = ny
    end

    -- Display
    local _, ny = Wg.CreateSectionHeader(c, "Affichage", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher le nom", db.showName, y, function(v)
        db.showName = v; RefreshUnit(unit)
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher le niveau", db.showLevel, y, function(v)
        db.showLevel = v; RefreshUnit(unit)
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Texte de santé", db.showHealthText, y, function(v)
        db.showHealthText = v; RefreshUnit(unit)
    end); y = ny
    local _, ny = Wg.CreateDropdown(c, "Format de santé", {
        { text = "Actuelle + %",    value = "current_percent" },
        { text = "Actuelle",        value = "current" },
        { text = "Pourcentage",     value = "percent" },
        { text = "Actuelle / Max",  value = "current_max" },
        { text = "Déficit",         value = "deficit" },
    }, db.healthTextFormat or "percent", y, function(v)
        db.healthTextFormat = v; RefreshUnit(unit)
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Couleur de classe", db.useClassColor, y, function(v)
        db.useClassColor = v; RefreshUnit(unit)
    end); y = ny
    if db.useFactionColor ~= nil then
        local _, ny = Wg.CreateCheckbox(c, "Couleur de faction (cible)", db.useFactionColor, y, function(v)
            db.useFactionColor = v; RefreshUnit(unit)
        end); y = ny
    end
    if db.showAbsorb ~= nil then
        local _, ny = Wg.CreateCheckbox(c, "Barre d'absorption", db.showAbsorb, y, function(v)
            db.showAbsorb = v; RefreshUnit(unit)
        end); y = ny
    end
    if db.showThreat ~= nil then
        local _, ny = Wg.CreateCheckbox(c, "Indicateur de menace", db.showThreat, y, function(v)
            db.showThreat = v; RefreshUnit(unit)
        end); y = ny
    end

    -- Castbar
    if db.castbar then
        local cb = db.castbar
        local _, ny = Wg.CreateSectionHeader(c, "Barre de cast", y); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Activer la barre de cast", cb.enabled, y, function(v)
            cb.enabled = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateSlider(c, "Largeur", cb.width, 60, 500, 5, y, function(v)
            cb.width = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateSlider(c, "Hauteur", cb.height, 6, 40, 1, y, function(v)
            cb.height = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Afficher l'icône", cb.showIcon, y, function(v)
            cb.showIcon = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Afficher le timer", cb.showTimer, y, function(v)
            cb.showTimer = v; RefreshUnit(unit)
        end); y = ny
        if cb.showLatency ~= nil then
            local _, ny = Wg.CreateCheckbox(c, "Afficher la latence", cb.showLatency, y, function(v)
                cb.showLatency = v; RefreshUnit(unit)
            end); y = ny
        end
        local _, ny = Wg.CreateColorPicker(c, "Couleur de cast", cb.color, y, function(r, g, b)
            cb.color = { r=r, g=g, b=b }; RefreshUnit(unit)
        end); y = ny
    end

    -- Auras
    if db.auras then
        local au = db.auras
        local _, ny = Wg.CreateSectionHeader(c, "Auras / Debuffs", y); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Activer les auras", au.enabled, y, function(v)
            au.enabled = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateDropdown(c, "Type d'auras", {
            { text = "Debuffs",   value = "HARMFUL" },
            { text = "Buffs",     value = "HELPFUL" },
            { text = "Tous",      value = "ALL" },
        }, au.type or "HARMFUL", y, function(v)
            au.type = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateSlider(c, "Nombre max", au.maxAuras, 1, 16, 1, y, function(v)
            au.maxAuras = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateSlider(c, "Taille des icônes", au.size, 12, 48, 1, y, function(v)
            au.size = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Seulement mes auras", au.showOnlyMine, y, function(v)
            au.showOnlyMine = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Afficher la durée", au.showDuration, y, function(v)
            au.showDuration = v; RefreshUnit(unit)
        end); y = ny
    end

    -- Enemy Buffs (target only)
    if db.enemyBuffs then
        local eb = db.enemyBuffs
        local _, ny = Wg.CreateSectionHeader(c, "Buffs ennemis (cible)", y); y = ny
        local _, ny = Wg.CreateCheckbox(c, "Afficher les buffs ennemis", eb.enabled, y, function(v)
            eb.enabled = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateSlider(c, "Nombre max", eb.maxAuras, 1, 12, 1, y, function(v)
            eb.maxAuras = v; RefreshUnit(unit)
        end); y = ny
        local _, ny = Wg.CreateSlider(c, "Taille des icônes", eb.size, 12, 48, 1, y, function(v)
            eb.size = v; RefreshUnit(unit)
        end); y = ny
    end

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB: GLOBAL (enable, colors, font)
-- =====================================
local function BuildGlobalTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB()
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "TomoFrames", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer TomoFrames", db.enabled, y, function(v)
        db.enabled = v
        if v then
            if TomoFrames_UF then TomoFrames_UF.Initialize() end
            if TomoFrames_BF then TomoFrames_BF.Initialize() end
        else
            if TomoFrames_UF then TomoFrames_UF.Disable() end
        end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Masquer les frames Blizzard", db.hideBlizzardFrames, y, function(v)
        db.hideBlizzardFrames = v; RefreshAll()
    end); y = ny

    -- Global font size
    local _, ny = Wg.CreateSectionHeader(c, "Police", y); y = ny
    local _, ny = Wg.CreateSlider(c, "Taille de police globale", db.fontSize, 6, 24, 1, y, function(v)
        db.fontSize = v; RefreshAll()
    end); y = ny

    -- Castbar colors
    local _, ny = Wg.CreateSectionHeader(c, "Couleurs des barres de cast", y); y = ny
    local _, ny = Wg.CreateInfoText(c, "S'appliquent à toutes les barres de cast.", y); y = ny
    local _, ny = Wg.CreateColorPicker(c, "Cast interruptible", db.castbarColor, y, function(r, g, b)
        db.castbarColor = { r=r, g=g, b=b }; RefreshAll()
    end); y = ny
    local _, ny = Wg.CreateColorPicker(c, "Cast non-interruptible", db.castbarNIColor, y, function(r, g, b)
        db.castbarNIColor = { r=r, g=g, b=b }; RefreshAll()
    end); y = ny
    local _, ny = Wg.CreateColorPicker(c, "Interrompu", db.castbarInterruptColor, y, function(r, g, b)
        db.castbarInterruptColor = { r=r, g=g, b=b }; RefreshAll()
    end); y = ny

    -- Positioning
    local _, ny = Wg.CreateSectionHeader(c, "Repositionnement", y); y = ny
    local _, ny = Wg.CreateInfoText(c, "Utilisez /tf unlock pour déverrouiller et glisser les frames. /tf lock pour reverrouiller.", y); y = ny

    -- Boss frames
    local bf = db.bossFrames
    local _, ny = Wg.CreateSectionHeader(c, "Frames de boss", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer les frames de boss", bf.enabled, y, function(v)
        bf.enabled = v
        if TomoFrames_BF then
            if v then TomoFrames_BF.Initialize() else TomoFrames_BF.Disable() end
        end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Largeur des frames boss", bf.width, 80, 400, 5, y, function(v)
        bf.width = v
        if TomoFrames_BF then TomoFrames_BF.RefreshAll() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur des frames boss", bf.height, 12, 60, 2, y, function(v)
        bf.height = v
        if TomoFrames_BF then TomoFrames_BF.RefreshAll() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Espacement", bf.spacing, 0, 20, 1, y, function(v)
        bf.spacing = v
        if TomoFrames_BF then TomoFrames_BF.RefreshAll() end
    end); y = ny

    -- Reset
    local _, ny = Wg.CreateSeparator(c, y); y = ny
    local _, ny = Wg.CreateButton(c, "Réinitialiser tous les paramètres", 260, y, function()
        TomoFrames_ResetDB()
    end); y = ny - 20

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- MAIN CONFIG WINDOW
-- =====================================
local configFrame

local function BuildConfigWindow()
    local Wg = W()
    local f = CreateFrame("Frame", "TomoFramesConfig", UIParent, "BackdropTemplate")
    f:SetSize(540, 580)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
    f:Hide()

    -- Background
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetColorTexture(0.07, 0.06, 0.04, 0.97)

    -- Amber top accent line
    local topLine = f:CreateTexture(nil, "BORDER")
    topLine:SetPoint("TOPLEFT"); topLine:SetPoint("TOPRIGHT")
    topLine:SetHeight(2); topLine:SetColorTexture(0.961, 0.620, 0.043, 1)

    -- Title bar
    local titleBar = f:CreateTexture(nil, "ARTWORK")
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -2)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -2)
    titleBar:SetHeight(36); titleBar:SetColorTexture(0.11, 0.09, 0.05, 1)

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont("Interface\\AddOns\\TomoFrames\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    title:SetPoint("LEFT", f, "LEFT", 16, 0)
    title:SetPoint("TOP",  f, "TOP",  0, -10)
    title:SetText("|cfff59e0bTomo|rFrames  |cff555544v1.0.0|r")
    title:SetTextColor(0.92, 0.88, 0.80, 1)

    -- Close button
    local close = CreateFrame("Button", nil, f)
    close:SetSize(22, 22); close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -9)
    local closeText = close:CreateFontString(nil, "OVERLAY")
    closeText:SetFont("Interface\\AddOns\\TomoFrames\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    closeText:SetAllPoints(); closeText:SetText("×"); closeText:SetTextColor(0.6, 0.55, 0.45, 1)
    close:SetScript("OnClick", function() f:Hide() end)
    close:SetScript("OnEnter", function() closeText:SetTextColor(0.961, 0.620, 0.043, 1) end)
    close:SetScript("OnLeave", function() closeText:SetTextColor(0.6, 0.55, 0.45, 1) end)

    -- Content area
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -40)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)

    -- Tabs: Global + one per unit
    local tabs = {
        { key = "global",       label = "Global",   builder = function(p) return BuildGlobalTab(p) end },
        { key = "player",       label = "Joueur",   builder = function(p) return BuildUnitTab(p, "player",       "Joueur") end },
        { key = "target",       label = "Cible",    builder = function(p) return BuildUnitTab(p, "target",       "Cible") end },
        { key = "targettarget", label = "CdC",      builder = function(p) return BuildUnitTab(p, "targettarget", "Cible de la cible") end },
        { key = "focus",        label = "Focus",    builder = function(p) return BuildUnitTab(p, "focus",        "Focus") end },
        { key = "pet",          label = "Familier", builder = function(p) return BuildUnitTab(p, "pet",          "Familier") end },
    }

    local tabPanel = Wg.CreateTabPanel(content, tabs)
    tabPanel:SetAllPoints(content)

    -- Hint
    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont("Interface\\AddOns\\TomoFrames\\Assets\\Fonts\\Poppins-Medium.ttf", 9, "NONE")
    hint:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 6)
    hint:SetText("|cff555544/tf pour toggle  •  /tf unlock pour déplacer  •  /tf reset|r")

    return f
end

function TomoFrames_OpenConfig()
    if not configFrame then configFrame = BuildConfigWindow() end
    if configFrame:IsShown() then configFrame:Hide() else configFrame:Show() end
end

-- Register in WoW's Escape → Settings menu
local optionsFrame = CreateFrame("Frame", "TomoFramesOptionsFrame")
optionsFrame.name = "TomoFrames"
optionsFrame:SetScript("OnShow", function()
    if not configFrame then configFrame = BuildConfigWindow() end
    configFrame:SetParent(optionsFrame)
    configFrame:ClearAllPoints()
    configFrame:SetPoint("TOPLEFT"); configFrame:SetPoint("BOTTOMRIGHT"); configFrame:Show()
end)
if Settings and Settings.RegisterCanvasLayoutCategory then
    local cat = Settings.RegisterCanvasLayoutCategory(optionsFrame, "TomoFrames")
    Settings.RegisterAddOnCategory(cat)
else
    InterfaceOptions_AddCategory(optionsFrame)
end
