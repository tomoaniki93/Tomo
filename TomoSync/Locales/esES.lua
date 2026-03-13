-- TomoSync | Localización Española
if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

TomoSyncLocale = {
    ADDON_NAME      = "TomoSync",
    BAGS            = "Bolsas",
    BANK            = "Banco",
    REAGENT         = "Reactivos",
    EQUIPPED        = "Equipado",
    TOTAL           = "Total",
    LAST_SCAN       = "Último escaneo",
    NEVER           = "Nunca",
    NO_DATA         = "Sin datos",
    -- Config
    CFG_TITLE       = "TomoSync — Configuración",
    CFG_SHOW_BAGS   = "Mostrar bolsas",
    CFG_SHOW_BANK   = "Mostrar banco",
    CFG_SHOW_REAGENT= "Mostrar banco de reactivos",
    CFG_SHOW_EQUIP  = "Mostrar objetos equipados",
    CFG_SHOW_TOTAL  = "Mostrar total",
    CFG_ONLY_REALM  = "Solo mismo reino",
    CFG_THRESHOLD   = "Umbral mínimo de visualización",
    CFG_THRESHOLD_TT= "Solo muestra un personaje en el tooltip si su total supera este valor.",
    -- Mensajes
    SCAN_BAGS_DONE  = "Bolsas escaneadas.",
    SCAN_BANK_DONE  = "Banco escaneado.",
    SCAN_REAGENT_DONE = "Banco de reactivos escaneado.",
    CMD_HELP        = "Comandos: /tms scan — forzar escaneo de bolsas.",
}
