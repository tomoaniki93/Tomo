-- =====================================
-- frFR.lua — French locale for TomoCastbar
-- Only loaded when GetLocale() == "frFR"
-- =====================================

if GetLocale() ~= "frFR" then return end

local L = TomoCastbar_L or {}
TomoCastbar_L = L

-- =====================================
-- GENERAL / INIT
-- =====================================
L["ADDON_LOADED"]           = "charg\195\169. Tapez |cffd1b559/tcb|r pour ouvrir la config ou |cffd1b559/tcb help|r pour les commandes."
L["UNKNOWN_COMMAND"]        = "Commande inconnue. Tapez /tcb help pour la liste des commandes."
L["ALL_RESET"]              = "Tous les param\195\168tres ont \195\169t\195\169 r\195\169initialis\195\169s."
L["DB_RESET"]               = "Base de donn\195\169es r\195\169initialis\195\169e."
L["UNIT_RESET"]             = "Barre d'incantation %s r\195\169initialis\195\169e."

-- =====================================
-- SLASH HELP
-- =====================================
L["HELP_HEADER"]            = "Commandes :"
L["HELP_CONFIG"]            = "  /tcb \226\128\148 Ouvrir le panneau de configuration"
L["HELP_LOCK"]              = "  /tcb lock \226\128\148 Verrouiller/d\195\169verrouiller les barres (glisser pour d\195\169placer)"
L["HELP_RESET"]             = "  /tcb reset \226\128\148 R\195\169initialiser tous les param\195\168tres"
L["HELP_RESET_PLAYER"]      = "  /tcb reset player \226\128\148 R\195\169initialiser la barre du joueur"
L["HELP_RESET_TARGET"]      = "  /tcb reset target \226\128\148 R\195\169initialiser la barre de la cible"
L["HELP_RESET_FOCUS"]       = "  /tcb reset focus \226\128\148 R\195\169initialiser la barre du focus"
L["HELP_HELP"]              = "  /tcb help \226\128\148 Afficher cette aide"

-- =====================================
-- LOCK / UNLOCK
-- =====================================
L["CASTBARS_LOCKED"]        = "Barres d'incantation verrouill\195\169es."
L["CASTBARS_UNLOCKED"]      = "Barres d'incantation d\195\169verrouill\195\169es \226\128\148 glissez pour repositionner."
L["MOVE_LABEL"]             = "(D\195\169placer)"

-- =====================================
-- CASTBAR PREVIEW
-- =====================================
L["PREVIEW_CASTBAR"]        = "Barre (%s)"
L["INTERRUPTED"]            = "Interrompu"

-- =====================================
-- CONFIG — TITLE / FOOTER
-- =====================================
L["CONFIG_TITLE"]           = "|cffd1b559Tomo|r|cffffffffCastbar|r"
L["CONFIG_FOOTER"]          = "/tcb \226\128\148 config  \194\183  /tcb lock \226\128\148 d\195\169verrouiller les barres"
L["DB_NOT_INIT"]            = "Base de donn\195\169es non initialis\195\169e."

-- =====================================
-- CONFIG — SIDEBAR
-- =====================================
L["CAT_GENERAL"]            = "G\195\169n\195\169ral"
L["CAT_PLAYER"]             = "Joueur"
L["CAT_TARGET"]             = "Cible"
L["CAT_FOCUS"]              = "Focus"

-- =====================================
-- CONFIG — SECTION HEADERS
-- =====================================
L["HEADER_GENERAL"]         = "G\195\169n\195\169ral"
L["HEADER_TEXTURES"]        = "Textures"
L["HEADER_COLORS"]          = "Couleurs"
L["HEADER_UNIT_CASTBAR"]    = "Barre %s"

-- =====================================
-- CONFIG — SUB LABELS
-- =====================================
L["SUBLABEL_FONTSIZE"]      = "Taille de police"
L["SUBLABEL_DIMENSIONS"]    = "Dimensions"
L["SUBLABEL_DISPLAY"]       = "Affichage"
L["SUBLABEL_POSITION"]      = "Position"

-- =====================================
-- CONFIG — CHECKBOXES
-- =====================================
L["HIDE_BLIZZARD"]          = "Masquer la barre Blizzard"
L["CUSTOM_BORDER"]          = "Bordure personnalis\195\169e"
L["SHOW_SPARK"]             = "Afficher l'\195\169tincelle"
L["SHOW_CHANNEL_TICKS"]     = "Afficher les ticks de canalisation"
L["ENABLE"]                 = "Activer"
L["SHOW_ICON"]              = "Afficher l'ic\195\180ne"
L["SHOW_TIMER"]             = "Afficher le chrono"

-- =====================================
-- CONFIG — DROPDOWNS
-- =====================================
L["BACKGROUND_MODE"]        = "Fond"
L["BG_CUSTOM"]              = "Texture custom"
L["BG_BLACK"]               = "Noir"
L["BG_TRANSPARENT"]         = "Transparent"
L["BAR_TEXTURE"]            = "Texture de barre"
L["TEX_BLIZZARD"]           = "Blizzard"
L["TEX_SMOOTH"]             = "Lisse"
L["TEX_FLAT"]               = "Plat"
L["SHOW_LATENCY"]           = "Afficher la latence"

-- =====================================
-- CONFIG — SLIDERS
-- =====================================
L["SLIDER_SPARK_HEIGHT"]    = "Hauteur de l'\195\169tincelle"
L["SLIDER_FONTSIZE"]        = "Taille de police"
L["SLIDER_WIDTH"]           = "Largeur"
L["SLIDER_HEIGHT"]          = "Hauteur"

-- =====================================
-- CONFIG — COLOR PICKERS
-- =====================================
L["COLOR_CAST"]             = "Couleur d'incantation"
L["COLOR_NI"]               = "Couleur non-interruptible"
L["COLOR_INTERRUPTED"]      = "Couleur d'interruption"

-- =====================================
-- CONFIG — BUTTONS
-- =====================================
L["RESET_ALL"]              = "R\195\169initialiser tout"
L["RESET_POSITION"]         = "R\195\169init. position %s"

-- =====================================
-- CONFIG — INFO TEXT
-- =====================================
L["INFO_DRAG"]              = "Utilisez /tcb lock pour d\195\169verrouiller les barres et les d\195\169placer."
L["POSITION_RESET"]         = "Position %s r\195\169initialis\195\169e."
