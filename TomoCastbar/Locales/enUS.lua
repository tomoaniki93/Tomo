-- =====================================
-- enUS.lua — English (default) locale for TomoCastbar
-- =====================================

TomoCastbar_L = TomoCastbar_L or {}
local L = TomoCastbar_L

-- =====================================
-- GENERAL / INIT
-- =====================================
L["ADDON_LOADED"]           = "loaded. Type |cffd1b559/tcb|r to open config or |cffd1b559/tcb help|r for commands."
L["UNKNOWN_COMMAND"]        = "Unknown command. Type /tcb help for a list of commands."
L["ALL_RESET"]              = "All settings reset to defaults."
L["DB_RESET"]               = "Database reset to defaults."
L["UNIT_RESET"]             = "%s castbar reset to defaults."

-- =====================================
-- SLASH HELP
-- =====================================
L["HELP_HEADER"]            = "Commands:"
L["HELP_CONFIG"]            = "  /tcb \226\128\148 Open config panel"
L["HELP_LOCK"]              = "  /tcb lock \226\128\148 Toggle castbar lock/unlock (drag to move)"
L["HELP_RESET"]             = "  /tcb reset \226\128\148 Reset all settings to defaults"
L["HELP_RESET_PLAYER"]      = "  /tcb reset player \226\128\148 Reset player castbar"
L["HELP_RESET_TARGET"]      = "  /tcb reset target \226\128\148 Reset target castbar"
L["HELP_RESET_FOCUS"]       = "  /tcb reset focus \226\128\148 Reset focus castbar"
L["HELP_HELP"]              = "  /tcb help \226\128\148 Show this help"

-- =====================================
-- LOCK / UNLOCK
-- =====================================
L["CASTBARS_LOCKED"]        = "Castbars locked."
L["CASTBARS_UNLOCKED"]      = "Castbars unlocked \226\128\148 drag to reposition."
L["MOVE_LABEL"]             = "(Move)"

-- =====================================
-- CASTBAR PREVIEW
-- =====================================
L["PREVIEW_CASTBAR"]        = "Castbar (%s)"
L["INTERRUPTED"]            = "Interrupted"

-- =====================================
-- CONFIG — TITLE / FOOTER
-- =====================================
L["CONFIG_TITLE"]           = "|cffd1b559Tomo|r|cffffffffCastbar|r"
L["CONFIG_FOOTER"]          = "/tcb \226\128\148 toggle config  \194\183  /tcb lock \226\128\148 unlock castbars"
L["DB_NOT_INIT"]            = "Database not initialized yet."

-- =====================================
-- CONFIG — SIDEBAR
-- =====================================
L["CAT_GENERAL"]            = "General"
L["CAT_PLAYER"]             = "Player"
L["CAT_TARGET"]             = "Target"
L["CAT_FOCUS"]              = "Focus"

-- =====================================
-- CONFIG — SECTION HEADERS
-- =====================================
L["HEADER_GENERAL"]         = "General"
L["HEADER_TEXTURES"]        = "Textures"
L["HEADER_COLORS"]          = "Colors"
L["HEADER_UNIT_CASTBAR"]    = "%s Castbar"

-- =====================================
-- CONFIG — SUB LABELS
-- =====================================
L["SUBLABEL_FONTSIZE"]      = "Font Size"
L["SUBLABEL_DIMENSIONS"]    = "Dimensions"
L["SUBLABEL_DISPLAY"]       = "Display"
L["SUBLABEL_POSITION"]      = "Position"

-- =====================================
-- CONFIG — CHECKBOXES
-- =====================================
L["HIDE_BLIZZARD"]          = "Hide Blizzard Castbar"
L["CUSTOM_BORDER"]          = "Custom Border"
L["SHOW_SPARK"]             = "Show Spark"
L["SHOW_CHANNEL_TICKS"]     = "Show Channel Ticks"
L["ENABLE"]                 = "Enable"
L["SHOW_ICON"]              = "Show Icon"
L["SHOW_TIMER"]             = "Show Timer"
L["SHOW_LATENCY"]           = "Show Latency"

-- =====================================
-- CONFIG — DROPDOWNS
-- =====================================
L["BACKGROUND_MODE"]        = "Background"
L["BG_CUSTOM"]              = "Custom Texture"
L["BG_BLACK"]               = "Black"
L["BG_TRANSPARENT"]         = "Transparent"
L["BAR_TEXTURE"]            = "Bar Texture"
L["TEX_BLIZZARD"]           = "Blizzard"
L["TEX_SMOOTH"]             = "Smooth"
L["TEX_FLAT"]               = "Flat"

-- =====================================
-- CONFIG — SLIDERS
-- =====================================
L["SLIDER_SPARK_HEIGHT"]    = "Spark Height"
L["SLIDER_FONTSIZE"]        = "Font Size"
L["SLIDER_WIDTH"]           = "Width"
L["SLIDER_HEIGHT"]          = "Height"

-- =====================================
-- CONFIG — COLOR PICKERS
-- =====================================
L["COLOR_CAST"]             = "Cast Color"
L["COLOR_NI"]               = "Non-Interruptible Color"
L["COLOR_INTERRUPTED"]      = "Interrupted Color"

-- =====================================
-- CONFIG — BUTTONS
-- =====================================
L["RESET_ALL"]              = "Reset All to Defaults"
L["RESET_POSITION"]         = "Reset %s Position"

-- =====================================
-- CONFIG — INFO TEXT
-- =====================================
L["INFO_DRAG"]              = "Use /tcb lock to unlock castbars and drag them to reposition."
L["POSITION_RESET"]         = "%s position reset."
