-- TomoSync | Localizzazione Italiana
if GetLocale() ~= "itIT" then return end

TomoSyncLocale = {
    ADDON_NAME      = "TomoSync",
    BAGS            = "Borse",
    BANK            = "Banca",
    REAGENT         = "Reagenti",
    EQUIPPED        = "Equipaggiato",
    TOTAL           = "Totale",
    LAST_SCAN       = "Ultima scansione",
    NEVER           = "Mai",
    NO_DATA         = "Nessun dato",
    -- Config
    CFG_TITLE       = "TomoSync — Impostazioni",
    CFG_SHOW_BAGS   = "Mostra borse",
    CFG_SHOW_BANK   = "Mostra banca",
    CFG_SHOW_REAGENT= "Mostra deposito reagenti",
    CFG_SHOW_EQUIP  = "Mostra oggetti equipaggiati",
    CFG_SHOW_TOTAL  = "Mostra totale",
    CFG_ONLY_REALM  = "Solo stesso reame",
    CFG_THRESHOLD   = "Soglia minima di visualizzazione",
    CFG_THRESHOLD_TT= "Mostra un personaggio nel tooltip solo se il suo totale supera questo valore.",
    -- Messaggi
    SCAN_BAGS_DONE  = "Borse scansionate.",
    SCAN_BANK_DONE  = "Banca scansionata.",
    SCAN_REAGENT_DONE = "Deposito reagenti scansionato.",
    CMD_HELP        = "Comandi: /tms scan — forzare una scansione delle borse.",
}
