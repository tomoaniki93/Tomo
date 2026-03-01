-- TomoSync | Localisation Française
if GetLocale() ~= "frFR" then return end

TomoSyncLocale = {
    ADDON_NAME      = "TomoSync",
    BAGS            = "Sacs",
    BANK            = "Banque",
    REAGENT         = "Réactifs",
    EQUIPPED        = "Équipé",
    TOTAL           = "Total",
    LAST_SCAN       = "Dernier scan",
    NEVER           = "Jamais",
    NO_DATA         = "Aucune donnée",
    -- Config
    CFG_TITLE       = "TomoSync — Paramètres",
    CFG_SHOW_BAGS   = "Afficher les sacs",
    CFG_SHOW_BANK   = "Afficher la banque",
    CFG_SHOW_REAGENT= "Afficher les réactifs",
    CFG_SHOW_EQUIP  = "Afficher les objets équipés",
    CFG_SHOW_TOTAL  = "Afficher le total",
    CFG_ONLY_REALM  = "Même royaume uniquement",
    CFG_THRESHOLD   = "Seuil minimum d'affichage",
    CFG_THRESHOLD_TT= "N'affiche un personnage dans le tooltip que si son total est supérieur à cette valeur.",
    -- Messages
    SCAN_BAGS_DONE  = "Sacs scannés.",
    SCAN_BANK_DONE  = "Banque scannée.",
    SCAN_REAGENT_DONE = "Réactifs scannés.",
    CMD_HELP        = "Commandes : /tms scan — forcer un scan des sacs.",
}
