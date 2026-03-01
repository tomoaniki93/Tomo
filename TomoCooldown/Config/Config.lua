-- =====================================
-- Config.lua — Configuration UI
-- TomoCooldown v1.0.0
-- Cyan: #06b6d4 = { 0.024, 0.714, 0.831 }
-- =====================================

local function W()  return TomoCooldown_Widgets end
local function DB() return TomoCooldownDB end

-- =====================================
-- HELPERS
-- =====================================
local function ApplyRB()
    if TomoCooldown_RB and TomoCooldown_RB.ApplySettings then TomoCooldown_RB.ApplySettings() end
end
local function ApplyCDM()
    if TomoCooldown_CDM and TomoCooldown_CDM.ApplySettings then TomoCooldown_CDM.ApplySettings() end
end

-- =====================================
-- TAB 1 — COOLDOWN MANAGER
-- =====================================
local function BuildCooldownTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local cdm = DB().cooldownManager
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Cooldown Manager", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer le Cooldown Manager", cdm.enabled, y, function(v)
        cdm.enabled = v
        if TomoCooldown_CDM then TomoCooldown_CDM.SetEnabled(v) end
    end); y = ny

    local _, ny = Wg.CreateInfoText(c, "Affiche les cooldowns de sorts actifs directement sur les boutons d'action, avec alpha variable selon le contexte de combat.", y); y = ny

    local _, ny = Wg.CreateCheckbox(c, "Afficher les raccourcis clavier", cdm.showHotKey, y, function(v)
        cdm.showHotKey = v; ApplyCDM()
    end); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Alpha contextuel", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer l'alpha contextuel", cdm.combatAlpha, y, function(v)
        cdm.combatAlpha = v; ApplyCDM()
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Alpha en combat", cdm.alphaInCombat or 1.0, 0, 1, 0.05, y, function(v)
        cdm.alphaInCombat = v; ApplyCDM()
    end, "%.2f"); y = ny
    local _, ny = Wg.CreateSlider(c, "Alpha avec une cible", cdm.alphaWithTarget or 0.8, 0, 1, 0.05, y, function(v)
        cdm.alphaWithTarget = v; ApplyCDM()
    end, "%.2f"); y = ny
    local _, ny = Wg.CreateSlider(c, "Alpha hors combat", cdm.alphaOutOfCombat or 0.5, 0, 1, 0.05, y, function(v)
        cdm.alphaOutOfCombat = v; ApplyCDM()
    end, "%.2f"); y = ny

    local _, ny = Wg.CreateInfoText(c, "Positionnez les icônes via le mode Édition de WoW (Échap → Mode Édition).", y); y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 2 — RESOURCE BARS (général)
-- =====================================
local function BuildResourceTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().resourceBars
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Barres de ressource", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer les barres de ressource", db.enabled, y, function(v)
        db.enabled = v
        if TomoCooldown_RB then TomoCooldown_RB.SetEnabled(v) end
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Affiche une barre de ressource (mana, rage, énergie, etc.) adaptée à votre classe et spécialisation.", y); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Visibilité", y); y = ny
    local _, ny = Wg.CreateDropdown(c, "Mode de visibilité", {
        { text = "Toujours visible",    value = "always" },
        { text = "En combat",           value = "combat" },
        { text = "Avec une cible",      value = "target" },
        { text = "Caché",               value = "hidden" },
    }, db.visibilityMode or "always", y, function(v)
        db.visibilityMode = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Alpha en combat", db.combatAlpha or 1.0, 0, 1, 0.05, y, function(v)
        db.combatAlpha = v; ApplyRB()
    end, "%.2f"); y = ny
    local _, ny = Wg.CreateSlider(c, "Alpha hors combat", db.oocAlpha or 0.6, 0, 1, 0.05, y, function(v)
        db.oocAlpha = v; ApplyRB()
    end, "%.2f"); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Dimensions", y); y = ny
    local _, ny = Wg.CreateSlider(c, "Largeur", db.width or 260, 80, 600, 5, y, function(v)
        db.width = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur principale", db.primaryHeight or 16, 6, 40, 1, y, function(v)
        db.primaryHeight = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur secondaire", db.secondaryHeight or 12, 6, 30, 1, y, function(v)
        db.secondaryHeight = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Échelle globale", db.scale or 1.0, 0.5, 2.0, 0.05, y, function(v)
        db.scale = v; ApplyRB()
    end, "%.2f"); y = ny

    local _, ny = Wg.CreateSeparator(c, y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Synchroniser la largeur avec les cooldowns", db.syncWidthWithCooldowns or false, y, function(v)
        db.syncWidthWithCooldowns = v
        if v and TomoCooldown_RB then TomoCooldown_RB.SyncWidth() end
    end); y = ny
    local _, ny = Wg.CreateButton(c, "Synchroniser maintenant", 200, y, function()
        if TomoCooldown_RB then TomoCooldown_RB.SyncWidth() end
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Note : pour les Druides, une barre de mana secondaire s'affiche automatiquement sous forme de ours/félin.", y); y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 3 — TEXTE & POSITION
-- =====================================
local function BuildTextPosTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().resourceBars
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Texte", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Afficher le texte de ressource", db.showText, y, function(v)
        db.showText = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateDropdown(c, "Alignement", {
        { text = "Gauche",  value = "LEFT" },
        { text = "Centre",  value = "CENTER" },
        { text = "Droite",  value = "RIGHT" },
    }, db.textAlignment or "CENTER", y, function(v)
        db.textAlignment = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Taille de police", db.fontSize or 11, 7, 20, 1, y, function(v)
        db.fontSize = v; ApplyRB()
    end); y = ny
    local _, ny = Wg.CreateDropdown(c, "Police", {
        { text = "Poppins Medium",      value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-Medium.ttf" },
        { text = "Poppins SemiBold",    value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-SemiBold.ttf" },
        { text = "Poppins Bold",        value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-Bold.ttf" },
        { text = "Poppins Black",       value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-Black.ttf" },
        { text = "Expressway",          value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Expressway.TTF" },
        { text = "Accidental Pres.",    value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\accidental_pres.ttf" },
        { text = "Tomo",                value = "Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Tomo.ttf" },
        { text = "Friz Quadrata (WoW)", value = "Fonts\\FRIZQT__.TTF" },
        { text = "Arial Narrow (WoW)",  value = "Fonts\\ARIALN.TTF" },
        { text = "Morpheus (WoW)",      value = "Fonts\\MORPHEUS.TTF" },
    }, db.font, y, function(v)
        db.font = v; ApplyRB()
    end); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Position", y); y = ny
    local _, ny = Wg.CreateInfoText(c, "Utilisez /tc unlock pour déverrouiller et glisser les barres. /tc lock pour reverrouiller.", y); y = ny
    local _, ny = Wg.CreateButton(c, "Déverrouiller les barres", 200, y, function()
        if TomoCooldown_RB and TomoCooldown_RB.ToggleLock then TomoCooldown_RB.ToggleLock() end
        if TomoCooldown_SR and TomoCooldown_SR.ToggleLock then TomoCooldown_SR.ToggleLock() end
    end); y = ny
    local _, ny = Wg.CreateButton(c, "Réinitialiser la position", 200, y, function()
        DB().resourceBars.position = nil; ApplyRB()
        print("|cff06b6d4TomoCooldown|r : Position réinitialisée.")
    end); y = ny

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 4 — COULEURS DE RESSOURCES
-- =====================================
local function BuildColorsTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().resourceBars.colors
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Couleurs par ressource", y); y = ny
    local _, ny = Wg.CreateInfoText(c, "Chaque couleur s'applique à la barre de la ressource correspondante.", y); y = ny

    local entries = {
        { key = "mana",            label = "Mana" },
        { key = "rage",            label = "Rage" },
        { key = "energy",          label = "Énergie" },
        { key = "focus",           label = "Concentration" },
        { key = "runicPower",      label = "Puissance runique" },
        { key = "runesReady",      label = "Runes (prêtes)" },
        { key = "runes",           label = "Runes (recharge)" },
        { key = "soulShards",      label = "Tessons d'âme" },
        { key = "astralPower",     label = "Puissance astrale" },
        { key = "holyPower",       label = "Pouvoir sacré" },
        { key = "maelstrom",       label = "Maelström" },
        { key = "chi",             label = "Chi" },
        { key = "insanity",        label = "Démence" },
        { key = "fury",            label = "Furie" },
        { key = "comboPoints",     label = "Points de combo" },
        { key = "arcaneCharges",   label = "Charges arcaniques" },
        { key = "essence",         label = "Essence" },
        { key = "stagger",         label = "Instabilité (Moine)" },
        { key = "soulFragments",   label = "Fragments d'âme" },
        { key = "tipOfTheSpear",   label = "Pointe de lance" },
        { key = "maelstromWeapon", label = "Maelström (Arme)" },
    }

    for _, e in ipairs(entries) do
        if db[e.key] then
            local _, ny = Wg.CreateColorPicker(c, e.label, db[e.key], y, function(r, g, b)
                db[e.key].r = r; db[e.key].g = g; db[e.key].b = b; ApplyRB()
            end); y = ny
        end
    end

    c:SetHeight(math.abs(y) + 40)
    if scroll.UpdateScroll then scroll.UpdateScroll() end
    return scroll
end

-- =====================================
-- TAB 5 — SKYRIDING
-- =====================================
local function BuildSkyridingTab(parent)
    local Wg = W()
    local scroll = Wg.CreateScrollPanel(parent)
    local c = scroll.child
    local db = DB().skyRide
    local y = -10

    local _, ny = Wg.CreateSectionHeader(c, "Barre de Skyriding", y); y = ny
    local _, ny = Wg.CreateCheckbox(c, "Activer la barre de Skyriding", db.enabled, y, function(v)
        db.enabled = v
        if TomoCooldown_SR then
            if v then TomoCooldown_SR.Initialize() else TomoCooldown_SR.SetEnabled(false) end
        end
    end); y = ny
    local _, ny = Wg.CreateInfoText(c, "Affiche la vitesse et les sorts de vol (Dragonriding / Skyriding) lorsque vous êtes en vol dynamique.", y); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Dimensions", y); y = ny
    local _, ny = Wg.CreateSlider(c, "Largeur", db.width or 340, 100, 600, 5, y, function(v)
        db.width = v
        if TomoCooldown_SR and TomoCooldown_SR.ApplySettings then TomoCooldown_SR.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur (vitesse)", db.height or 20, 6, 40, 1, y, function(v)
        db.height = v
        if TomoCooldown_SR and TomoCooldown_SR.ApplySettings then TomoCooldown_SR.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Hauteur (combo points)", db.comboHeight or 5, 2, 20, 1, y, function(v)
        db.comboHeight = v
        if TomoCooldown_SR and TomoCooldown_SR.ApplySettings then TomoCooldown_SR.ApplySettings() end
    end); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Style", y); y = ny
    local _, ny = Wg.CreateColorPicker(c, "Couleur de la barre", db.barColor, y, function(r, g, b)
        db.barColor = { r=r, g=g, b=b }
        if TomoCooldown_SR and TomoCooldown_SR.ApplySettings then TomoCooldown_SR.ApplySettings() end
    end); y = ny
    local _, ny = Wg.CreateSlider(c, "Taille de police", db.fontSize or 12, 7, 20, 1, y, function(v)
        db.fontSize = v
        if TomoCooldown_SR and TomoCooldown_SR.ApplySettings then TomoCooldown_SR.ApplySettings() end
    end); y = ny

    local _, ny = Wg.CreateSectionHeader(c, "Position", y); y = ny
    local _, ny = Wg.CreateButton(c, "Déverrouiller la barre Skyriding", 220, y, function()
        if TomoCooldown_SR and TomoCooldown_SR.ToggleLock then TomoCooldown_SR.ToggleLock() end
    end); y = ny

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
    local f = CreateFrame("Frame", "TomoCooldownConfig", UIParent, "BackdropTemplate")
    f:SetSize(530, 570)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true); f:SetClampedToScreen(true); f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(s) s:StartMoving() end)
    f:SetScript("OnDragStop",  function(s) s:StopMovingOrSizing() end)
    f:Hide()

    -- Background (deep dark with subtle blue-green tint)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetColorTexture(0.04, 0.08, 0.09, 0.97)

    -- Cyan top accent line
    local topLine = f:CreateTexture(nil, "BORDER")
    topLine:SetPoint("TOPLEFT"); topLine:SetPoint("TOPRIGHT")
    topLine:SetHeight(2); topLine:SetColorTexture(0.024, 0.714, 0.831, 1)

    -- Title bar
    local titleBar = f:CreateTexture(nil, "ARTWORK")
    titleBar:SetPoint("TOPLEFT", f, "TOPLEFT", 0, -2)
    titleBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, -2)
    titleBar:SetHeight(36); titleBar:SetColorTexture(0.06, 0.12, 0.14, 1)

    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont("Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    title:SetPoint("LEFT", f, "LEFT", 16, 0)
    title:SetPoint("TOP",  f, "TOP",  0, -10)
    title:SetText("|cff06b6d4Tomo|rCooldown  |cff334455v1.0.0|r")
    title:SetTextColor(0.85, 0.95, 0.98, 1)

    -- Close button
    local close = CreateFrame("Button", nil, f)
    close:SetSize(22, 22); close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -8, -9)
    local closeText = close:CreateFontString(nil, "OVERLAY")
    closeText:SetFont("Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-SemiBold.ttf", 14, "NONE")
    closeText:SetAllPoints(); closeText:SetText("×"); closeText:SetTextColor(0.4, 0.6, 0.65, 1)
    close:SetScript("OnClick", function() f:Hide() end)
    close:SetScript("OnEnter", function() closeText:SetTextColor(0.024, 0.714, 0.831, 1) end)
    close:SetScript("OnLeave", function() closeText:SetTextColor(0.4, 0.6, 0.65, 1) end)

    -- Content area
    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", f, "TOPLEFT", 8, -40)
    content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -8, 8)

    local tabs = {
        { key = "cdm",      label = "Cooldowns",  builder = function(p) return BuildCooldownTab(p)   end },
        { key = "resource", label = "Ressources", builder = function(p) return BuildResourceTab(p)   end },
        { key = "textpos",  label = "Texte",      builder = function(p) return BuildTextPosTab(p)    end },
        { key = "colors",   label = "Couleurs",   builder = function(p) return BuildColorsTab(p)     end },
        { key = "sky",      label = "Skyriding",  builder = function(p) return BuildSkyridingTab(p)  end },
    }

    local tabPanel = Wg.CreateTabPanel(content, tabs)
    tabPanel:SetAllPoints(content)

    -- Reset button in corner
    local resetBtn = CreateFrame("Button", nil, f)
    resetBtn:SetSize(16, 16)
    resetBtn:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 10, 6)
    local resetTxt = resetBtn:CreateFontString(nil, "OVERLAY")
    resetTxt:SetFont("Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-Medium.ttf", 9, "NONE")
    resetTxt:SetAllPoints(); resetTxt:SetText("↺ Reset"); resetTxt:SetTextColor(0.3, 0.5, 0.55, 1)
    resetBtn:SetScript("OnClick", function() TomoCooldown_ResetDB() end)
    resetBtn:SetScript("OnEnter", function() resetTxt:SetTextColor(0.024, 0.714, 0.831, 1) end)
    resetBtn:SetScript("OnLeave", function() resetTxt:SetTextColor(0.3, 0.5, 0.55, 1) end)

    -- Hint
    local hint = f:CreateFontString(nil, "OVERLAY")
    hint:SetFont("Interface\\AddOns\\TomoCooldown\\Assets\\Fonts\\Poppins-Medium.ttf", 9, "NONE")
    hint:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -10, 6)
    hint:SetText("|cff334455/tc pour toggle  •  /tc unlock  •  /tc sky|r")

    return f
end

function TomoCooldown_OpenConfig()
    if not configFrame then configFrame = BuildConfigWindow() end
    if configFrame:IsShown() then configFrame:Hide() else configFrame:Show() end
end

-- Escape menu integration
local optionsFrame = CreateFrame("Frame", "TomoCooldownOptionsFrame")
optionsFrame.name = "TomoCooldown"
optionsFrame:SetScript("OnShow", function()
    if not configFrame then configFrame = BuildConfigWindow() end
    configFrame:SetParent(optionsFrame)
    configFrame:ClearAllPoints()
    configFrame:SetPoint("TOPLEFT"); configFrame:SetPoint("BOTTOMRIGHT"); configFrame:Show()
end)
if Settings and Settings.RegisterCanvasLayoutCategory then
    local cat = Settings.RegisterCanvasLayoutCategory(optionsFrame, "TomoCooldown")
    Settings.RegisterAddOnCategory(cat)
else
    InterfaceOptions_AddCategory(optionsFrame)
end
