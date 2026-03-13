-- TomoMythic / Locales / esES.lua

local _, TM = ...
if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end
local L = TM.L

L.CMD_USAGE           = "|cFF55B400/tmt|r : configuración  |  |cFF55B400unlock|r : mover  |  |cFF55B400lock|r : bloquear  |  |cFF55B400preview|r : vista previa"
L.UNLOCK_MSG          = "|cFF55B400TomoMythic|r: Marco desbloqueado — arrastra para reposicionar."
L.LOCK_MSG            = "|cFF55B400TomoMythic|r: Marco bloqueado."
L.RESET_MSG           = "|cFF55B400TomoMythic|r: Posición reiniciada."
L.UNKNOWN_CMD         = "|cFF55B400TomoMythic|r: Comando desconocido."

L.DUNGEON_UNKNOWN     = "Mítico+"
L.OVERTIME            = "TIEMPO AGOTADO"
L.COMPLETED_ON_TIME   = "COMPLETADO"
L.COMPLETED_DEPLETED  = "FRACASADO"

L.FORCES              = "FUERZAS"
L.FORCES_DONE         = "COMPLETO"

L.CHEST_1             = "En tiempo"
L.CHEST_2             = "Bono +2"

L.CONFIG_TITLE        = "TomoMythic"
L.CFG_SHOW_TIMER      = "Mostrar barra de tiempo"
L.CFG_SHOW_FORCES     = "Mostrar fuerzas enemigas"
L.CFG_SHOW_BOSSES     = "Mostrar temporizadores de jefe"
L.CFG_HIDE_BLIZZARD   = "Ocultar rastreador de Blizzard"
L.CFG_SHOW_INTERRUPT  = "Rastreador de interrupciones"
L.CFG_LOCK            = "Bloquear marco"
L.CFG_SCALE           = "Escala"
L.CFG_ALPHA           = "Opacidad de fondo"
L.CFG_RESET_POS       = "Reiniciar posición"
L.CFG_PREVIEW         = "Vista previa"
L.CFG_SECTION_DISPLAY = "Pantalla"
L.CFG_SECTION_FRAME   = "Marco"
L.CFG_SECTION_ACTIONS = "Acciones"

L.INTERRUPT_READY     = "Listo"
L.CFG_SHOW_READY      = "Mostrar listo"
