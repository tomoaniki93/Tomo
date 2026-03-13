-- TomoMythic / Locales / ptBR.lua

local _, TM = ...
if GetLocale() ~= "ptBR" then return end
local L = TM.L

L.CMD_USAGE           = "|cFF55B400/tmt|r : configurações  |  |cFF55B400unlock|r : mover  |  |cFF55B400lock|r : travar  |  |cFF55B400preview|r : pré-visualizar"
L.UNLOCK_MSG          = "|cFF55B400TomoMythic|r: Moldura destravada — arraste para reposicionar."
L.LOCK_MSG            = "|cFF55B400TomoMythic|r: Moldura travada."
L.RESET_MSG           = "|cFF55B400TomoMythic|r: Posição redefinida."
L.UNKNOWN_CMD         = "|cFF55B400TomoMythic|r: Comando desconhecido."

L.DUNGEON_UNKNOWN     = "Mítico+"
L.OVERTIME            = "TEMPO ESGOTADO"
L.COMPLETED_ON_TIME   = "CONCLUÍDO"
L.COMPLETED_DEPLETED  = "FRACASSADO"

L.FORCES              = "FORÇAS"
L.FORCES_DONE         = "COMPLETO"

L.CHEST_1             = "No prazo"
L.CHEST_2             = "Bônus +2"

L.CONFIG_TITLE        = "TomoMythic"
L.CFG_SHOW_TIMER      = "Mostrar barra de tempo"
L.CFG_SHOW_FORCES     = "Mostrar forças inimigas"
L.CFG_SHOW_BOSSES     = "Mostrar temporizadores de chefe"
L.CFG_HIDE_BLIZZARD   = "Ocultar rastreador da Blizzard"
L.CFG_SHOW_INTERRUPT  = "Rastreador de interrupções"
L.CFG_LOCK            = "Travar moldura"
L.CFG_SCALE           = "Escala"
L.CFG_ALPHA           = "Opacidade do fundo"
L.CFG_RESET_POS       = "Redefinir posição"
L.CFG_PREVIEW         = "Pré-visualizar"
L.CFG_SECTION_DISPLAY = "Exibição"
L.CFG_SECTION_FRAME   = "Moldura"
L.CFG_SECTION_ACTIONS = "Ações"

L.INTERRUPT_READY     = "Pronto"
L.CFG_SHOW_READY      = "Mostrar pronto"
