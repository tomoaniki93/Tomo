-- TomoSync | Localização Portuguesa (Brasil)
if GetLocale() ~= "ptBR" then return end

TomoSyncLocale = {
    ADDON_NAME      = "TomoSync",
    BAGS            = "Bolsas",
    BANK            = "Banco",
    REAGENT         = "Reagentes",
    EQUIPPED        = "Equipado",
    TOTAL           = "Total",
    LAST_SCAN       = "Última varredura",
    NEVER           = "Nunca",
    NO_DATA         = "Sem dados",
    -- Config
    CFG_TITLE       = "TomoSync — Configurações",
    CFG_SHOW_BAGS   = "Mostrar bolsas",
    CFG_SHOW_BANK   = "Mostrar banco",
    CFG_SHOW_REAGENT= "Mostrar banco de reagentes",
    CFG_SHOW_EQUIP  = "Mostrar itens equipados",
    CFG_SHOW_TOTAL  = "Mostrar total",
    CFG_ONLY_REALM  = "Apenas mesmo reino",
    CFG_THRESHOLD   = "Limite mínimo de exibição",
    CFG_THRESHOLD_TT= "Exibe um personagem no tooltip apenas se seu total exceder este valor.",
    -- Mensagens
    SCAN_BAGS_DONE  = "Bolsas varridas.",
    SCAN_BANK_DONE  = "Banco varrido.",
    SCAN_REAGENT_DONE = "Banco de reagentes varrido.",
    CMD_HELP        = "Comandos: /tms scan — forçar uma varredura de bolsas.",
}
