-- =====================================
-- Config.lua — Configuration UI
-- TomoSkins v1.0.0
-- Rose: #f43f5e = { 0.957, 0.247, 0.369 }
-- =====================================

local function W()  return TomoSkins_Widgets end
local function DB() return TomoSkinsDB end

-- =====================================
-- HELPERS
-- =====================================
local function Apply(module) if module and module.ApplySettings then module.ApplySettings() end end

-- =====================================
-- TAB 1 — CHARACTER SKIN
-- =====================================
local function BuildCharacterTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().characterSkin
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Fiche de personnage", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer le skin", db.enabled, y, function(v)
        db.enabled = v; Apply(TomoSkins_CS)
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Remplace l'interface de la fiche de personnage et d'inspection par un skin personnalisé.", y); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Options", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Skin : fiche de personnage", db.skinCharacter, y, function(v)
        db.skinCharacter = v; Apply(TomoSkins_CS)
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Skin : fenêtre d'inspection", db.skinInspect, y, function(v)
        db.skinInspect = v; Apply(TomoSkins_CS)
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher les informations d'objet", db.showItemInfo, y, function(v)
        db.showItemInfo = v; Apply(TomoSkins_CS)
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Enchantements Midnight (slots modifiés)", db.midnightEnchants ~= false, y, function(v)
        db.midnightEnchants = v; Apply(TomoSkins_CS)
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Les enchantements Midnight concernent les changements de slots de l'extension Midnight à venir.", y); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Dimensions", y); y = ny
    local _, ny = Wg.CreateSlider(c, "Échelle de la fenêtre", db.scale, 0.5, 2.0, 0.05, y, function(v)
        db.scale = v; Apply(TomoSkins_CS)
    end, "%.2f"); y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 2 — ACTION BARS
-- =====================================
local function BuildActionBarsTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().actionBarSkin
    local y = -10

    local BAR_LIST = {
        { key = "ActionButton",       label = "Barre d'action 1" },
        { key = "MultiBarBottomLeft", label = "Barre d'action 2 (bas gauche)" },
        { key = "MultiBarBottomRight",label = "Barre d'action 3 (bas droite)" },
        { key = "MultiBarRight",      label = "Barre d'action 4 (droite)" },
        { key = "MultiBarLeft",       label = "Barre d'action 5 (gauche)" },
        { key = "MultiBar5",          label = "Barre d'action 6" },
        { key = "MultiBar6",          label = "Barre d'action 7" },
        { key = "MultiBar7",          label = "Barre d'action 8" },
        { key = "PetActionButton",    label = "Barre de familier" },
        { key = "StanceButton",       label = "Barre de postures" },
    }

    local _, ny = Wg.CreateSectionHeader(c, "Skin des barres d'action", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer le skin des barres d'action", db.enabled, y, function(v)
        db.enabled = v
        if TomoSkins_ABS then TomoSkins_ABS.SetEnabled(v) end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Couleur de classe", db.useClassColor, y, function(v)
        db.useClassColor = v
        if TomoSkins_ABS then TomoSkins_ABS.UpdateColors() end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Révéler avec Shift", db.shiftReveal or false, y, function(v)
        db.shiftReveal = v
        if TomoSkins_ABS then TomoSkins_ABS.SetShiftReveal(v) end
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Avec Shift : révéler les boutons masqués en maintenant Shift.", y); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Opacité par barre", y); y = ny
    for _, bar in ipairs(BAR_LIST) do
        local key = bar.key
        local val = db.barOpacity[key] or 100
        local _, ny = Wg.CreateSlider(c, bar.label, val, 0, 100, 5, y, function(v)
            db.barOpacity[key] = v
            if TomoSkins_ABS then TomoSkins_ABS.UpdateBar(key) end
        end); y = ny
    end

    local _, ny = Wg.CreateSectionHeader(c, "Affichage au combat seulement", y); y = ny
    local _, ny = Wg.CreateInfoText(c, "Les barres cochées seront masquées hors combat et affichées en combat.", y); y = ny
    for _, bar in ipairs(BAR_LIST) do
        local key = bar.key
        local _, ny = Wg.CreateCheckbox(c, bar.label, db.combatShow[key] or false, y, function(v)
            db.combatShow[key] = v
            if TomoSkins_ABS then TomoSkins_ABS.ApplySettings() end
        end); y = ny
    end

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 3 — MINIMAP & INFO PANEL
-- =====================================
local function BuildMinimapTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local mm = DB().minimap
    local ip = DB().infoPanel
    local y = -10

    -- Minimap
    local _, ny = Wg.CreateSectionHeader(c, "Minimap", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer le skin de la minimap", mm.enabled, y, function(v)
        mm.enabled = v
        if v and TomoSkins_MM then TomoSkins_MM.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Taille (pixels)", mm.size, 150, 300, 10, y, function(v)
        mm.size = v
        if Minimap then Minimap:SetSize(v, v) end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Échelle", mm.scale, 0.5, 2.0, 0.1, y, function(v)
        mm.scale = v
        if TomoSkins_MM then TomoSkins_MM.ApplyScale() end
    end, "%.1f"); y = ny
    local _, ny = Wg.CreateDropdown(c, "Couleur de bordure", {
        { text = "Couleur de classe", value = "class" },
        { text = "Noir",              value = "black" },
    }, mm.borderColor, y, function(v)
        mm.borderColor = v
        if TomoSkins_MM then TomoSkins_MM.CreateBorder() end
    end); y = ny

    -- Info Panel
    local _, ny = Wg.CreateSectionHeader(c, "Panel d'informations", y); y = ny
    local _, ny = Wg.CreateInfoText(c, "Affiche une barre sous la minimap avec heure, coordonnées et durabilité.", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer le panel d'informations", ip.enabled, y, function(v)
        ip.enabled = v
        if v then
            if TomoSkins_IP then TomoSkins_IP.Initialize() end
        else
            if TomoSkins_IP then TomoSkins_IP.Hide() end
        end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher l'heure", ip.showTime, y, function(v)
        ip.showTime = v
        if TomoSkins_IP then TomoSkins_IP.Update() end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Format 24h", ip.use24Hour, y, function(v)
        ip.use24Hour = v
        if TomoSkins_IP then TomoSkins_IP.Update() end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Heure du serveur", ip.useServerTime, y, function(v)
        ip.useServerTime = v
        if TomoSkins_IP then TomoSkins_IP.Update() end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher les coordonnées", ip.showCoords ~= false, y, function(v)
        ip.showCoords = v
        if TomoSkins_IP then TomoSkins_IP.Update() end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher la durabilité", ip.showDurability ~= false, y, function(v)
        ip.showDurability = v
        if TomoSkins_IP then TomoSkins_IP.Update() end
    end); y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 4 — OBJECTIVE TRACKER
-- =====================================
local function BuildObjectiveTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().objectiveTracker
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Suivi des objectifs", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer le skin du suivi", db.enabled, y, function(v)
        db.enabled = v
        if TomoSkins_OT then TomoSkins_OT.SetEnabled(v) end
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Ajoute un fond semi-transparent et une bordure au suivi des objectifs de quêtes.", y); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Apparence", y); y = ny
    local _, ny = Wg.CreateSlider(c, "Opacité du fond", db.bgAlpha, 0, 1, 0.05, y, function(v)
        db.bgAlpha = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end, "%.2f"); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher la bordure", db.showBorder, y, function(v)
        db.showBorder = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Masquer quand vide", db.hideWhenEmpty, y, function(v)
        db.hideWhenEmpty = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Tailles de police", y); y = ny
    local _, ny = Wg.CreateSlider(c, "En-tête", db.headerFontSize, 8, 20, 1, y, function(v)
        db.headerFontSize = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Catégorie", db.categoryFontSize, 8, 18, 1, y, function(v)
        db.categoryFontSize = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Titre de quête", db.questFontSize, 8, 18, 1, y, function(v)
        db.questFontSize = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Objectif", db.objectiveFontSize, 8, 16, 1, y, function(v)
        db.objectiveFontSize = v
        if TomoSkins_OT then TomoSkins_OT.ApplySettings() end
    end); y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 5 — RESET
-- =====================================
local function BuildResetTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "À propos", y); y = ny
    local _, ny = Wg.CreateInfoText(c,
        "TomoSkins v1.0.0 par TomoAniki\n\n" ..
        "Modules inclus :\n" ..
        "  • Character Skin — restyle de la fiche de personnage\n" ..
        "  • Action Bar Skin — opacité et couleurs des barres\n" ..
        "  • Minimap — forme carrée, bordure de classe\n" ..
        "  • Info Panel — heure, coords, durabilité\n" ..
        "  • Objective Tracker — fond et police personnalisés\n\n" ..
        "Extrait de TomoMod. Aucune dépendance externe.", y); y = ny

    local _, ny = Wg.CreateSeparator(c, y); y = ny
    local _, ny = Wg.CreateButton(c, "Réinitialiser tous les paramètres", 260, y, function()
        TomoSkins_ResetDB()
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
    local f = CreateFrame("Frame", "TomoSkinsConfig", UIParent, "BackdropTemplate")
    f:SetSize(530, 570)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
    f:Hide()

    -- Background (warm near-black)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetColorTexture(0.08, 0.05, 0.06, 0.97)

    -- Rose top accent line
    local topLine = f:CreateTexture(nil, "BORDER")
    topLine:SetPoint("TOPLEFT"); topLine:SetPoint("TOPRIGHT")
    topLine:SetHeight(2); topLine:SetColorTexture(0.957, 0.247, 0.369, 1)

    -- Title bar
    local titleBar = f:CreateTexture(nil, "ARTWORK")
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -2)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -2)
    titleBar:SetHeight(36); titleBar:SetColorTexture(0.12, 0.07, 0.08, 1)

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont("Interface\\AddOns\\TomoSkins\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    title:SetPoint("LEFT", f, "LEFT", 16, 0)
    title:SetPoint("TOP",  f, "TOP",  0, -10)
    title:SetText("|cfff43f5eTomo|rSkins  |cff553344v1.0.0|r")
    title:SetTextColor(0.95, 0.88, 0.90, 1)

    -- Close button
    local close = CreateFrame("Button", nil, f)
    close:SetSize(22, 22); close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -9)
    local closeTxt = close:CreateFontString(nil, "OVERLAY")
    closeTxt:SetFont("Interface\\AddOns\\TomoSkins\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    closeTxt:SetAllPoints(); closeTxt:SetText("×"); closeTxt:SetTextColor(0.55, 0.35, 0.40, 1)
    close:SetScript("OnClick", function() f:Hide() end)
    close:SetScript("OnEnter", function() closeTxt:SetTextColor(0.957, 0.247, 0.369, 1) end)
    close:SetScript("OnLeave", function() closeTxt:SetTextColor(0.55, 0.35, 0.40, 1) end)

    -- Content area
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -40)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)

    local tabs = {
        { key = "char",    label = "Personnage", builder = function(p) return BuildCharacterTab(p)  end },
        { key = "bars",    label = "Barres",     builder = function(p) return BuildActionBarsTab(p) end },
        { key = "minimap", label = "Minimap",    builder = function(p) return BuildMinimapTab(p)    end },
        { key = "tracker", label = "Objectifs",  builder = function(p) return BuildObjectiveTab(p)  end },
        { key = "about",   label = "À propos",   builder = function(p) return BuildResetTab(p)      end },
    }

    local tabPanel = Wg.CreateTabPanel(content, tabs)
    tabPanel:SetAllPoints(content)

    -- Hint
    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont("Interface\\AddOns\\TomoSkins\\Assets\\Fonts\\Poppins-Medium.ttf", 9, "NONE")
    hint:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 6)
    hint:SetText("|cff553344/ts pour toggle  •  /ts refresh  •  /ts reset|r")

    return f
end

function TomoSkins_OpenConfig()
    if not configFrame then configFrame = BuildConfigWindow() end
    if configFrame:IsShown() then configFrame:Hide() else configFrame:Show() end
end

-- Escape menu
local optionsFrame = CreateFrame("Frame", "TomoSkinsOptionsFrame")
optionsFrame.name = "TomoSkins"
optionsFrame:SetScript("OnShow", function()
    if not configFrame then configFrame = BuildConfigWindow() end
    configFrame:SetParent(optionsFrame)
    configFrame:ClearAllPoints()
    configFrame:SetPoint("TOPLEFT"); configFrame:SetPoint("BOTTOMRIGHT"); configFrame:Show()
end)
if Settings and Settings.RegisterCanvasLayoutCategory then
    local cat = Settings.RegisterCanvasLayoutCategory(optionsFrame, "TomoSkins")
    Settings.RegisterAddOnCategory(cat)
else
    InterfaceOptions_AddCategory(optionsFrame)
end
