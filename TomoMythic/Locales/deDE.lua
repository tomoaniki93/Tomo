-- TomoMythic / Locales / deDE.lua

local _, TM = ...
if GetLocale() ~= "deDE" then return end
local L = TM.L

L.CMD_USAGE           = "|cFF55B400/tmt|r : Einstellungen  |  |cFF55B400unlock|r : verschieben  |  |cFF55B400lock|r : sperren  |  |cFF55B400preview|r : Vorschau"
L.UNLOCK_MSG          = "|cFF55B400TomoMythic|r: Rahmen entsperrt — ziehen zum Verschieben."
L.LOCK_MSG            = "|cFF55B400TomoMythic|r: Rahmen gesperrt."
L.RESET_MSG           = "|cFF55B400TomoMythic|r: Position zurückgesetzt."
L.UNKNOWN_CMD         = "|cFF55B400TomoMythic|r: Unbekannter Befehl."

L.DUNGEON_UNKNOWN     = "Mythisch+"
L.OVERTIME            = "ÜBERZOGEN"
L.COMPLETED_ON_TIME   = "ABGESCHLOSSEN"
L.COMPLETED_DEPLETED  = "GESCHEITERT"

L.FORCES              = "KRÄFTE"
L.FORCES_DONE         = "KOMPLETT"

L.CHEST_1             = "Im Zeitlimit"
L.CHEST_2             = "Bonus +2"

L.CONFIG_TITLE        = "TomoMythic"
L.CFG_SHOW_TIMER      = "Timerleiste anzeigen"
L.CFG_SHOW_FORCES     = "Feindkräfte anzeigen"
L.CFG_SHOW_BOSSES     = "Boss-Timer anzeigen"
L.CFG_HIDE_BLIZZARD   = "Blizzard-Tracker ausblenden"
L.CFG_SHOW_INTERRUPT  = "Unterbrechungs-Tracker"
L.CFG_LOCK            = "Rahmen sperren"
L.CFG_SCALE           = "Skalierung"
L.CFG_ALPHA           = "Hintergrundtransparenz"
L.CFG_RESET_POS       = "Position zurücksetzen"
L.CFG_PREVIEW         = "Vorschau"
L.CFG_SECTION_DISPLAY = "Anzeige"
L.CFG_SECTION_FRAME   = "Rahmen"
L.CFG_SECTION_ACTIONS = "Aktionen"

L.INTERRUPT_READY     = "Bereit"
L.CFG_SHOW_READY      = "Bereit anzeigen"
