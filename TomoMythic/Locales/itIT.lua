-- TomoMythic / Locales / itIT.lua

local _, TM = ...
if GetLocale() ~= "itIT" then return end
local L = TM.L

L.CMD_USAGE           = "|cFF55B400/tmt|r : configurazione  |  |cFF55B400unlock|r : sposta  |  |cFF55B400lock|r : blocca  |  |cFF55B400preview|r : anteprima"
L.UNLOCK_MSG          = "|cFF55B400TomoMythic|r: Riquadro sbloccato — trascina per riposizionare."
L.LOCK_MSG            = "|cFF55B400TomoMythic|r: Riquadro bloccato."
L.RESET_MSG           = "|cFF55B400TomoMythic|r: Posizione reimpostata."
L.UNKNOWN_CMD         = "|cFF55B400TomoMythic|r: Comando sconosciuto."

L.DUNGEON_UNKNOWN     = "Mitico+"
L.OVERTIME            = "TEMPO SCADUTO"
L.COMPLETED_ON_TIME   = "COMPLETATO"
L.COMPLETED_DEPLETED  = "FALLITO"

L.FORCES              = "FORZE"
L.FORCES_DONE         = "COMPLETO"

L.CHEST_1             = "In tempo"
L.CHEST_2             = "Bonus +2"

L.CONFIG_TITLE        = "TomoMythic"
L.CFG_SHOW_TIMER      = "Mostra barra del timer"
L.CFG_SHOW_FORCES     = "Mostra forze nemiche"
L.CFG_SHOW_BOSSES     = "Mostra timer dei boss"
L.CFG_HIDE_BLIZZARD   = "Nascondi tracker di Blizzard"
L.CFG_SHOW_INTERRUPT  = "Tracker interruzioni"
L.CFG_LOCK            = "Blocca riquadro"
L.CFG_SCALE           = "Scala"
L.CFG_ALPHA           = "Opacità sfondo"
L.CFG_RESET_POS       = "Reimposta posizione"
L.CFG_PREVIEW         = "Anteprima"
L.CFG_SECTION_DISPLAY = "Visualizzazione"
L.CFG_SECTION_FRAME   = "Riquadro"
L.CFG_SECTION_ACTIONS = "Azioni"

L.INTERRUPT_READY     = "Pronto"
L.CFG_SHOW_READY      = "Mostra pronto"
