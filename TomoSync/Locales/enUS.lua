-- TomoSync | English Locale (default fallback)
TomoSyncLocale = TomoSyncLocale or {}

local defaults = {
    ADDON_NAME      = "TomoSync",
    BAGS            = "Bags",
    BANK            = "Bank",
    REAGENT         = "Reagent",
    EQUIPPED        = "Equipped",
    TOTAL           = "Total",
    LAST_SCAN       = "Last scan",
    NEVER           = "Never",
    NO_DATA         = "No data",
    CFG_TITLE       = "TomoSync — Settings",
    CFG_SHOW_BAGS   = "Show bags",
    CFG_SHOW_BANK   = "Show bank",
    CFG_SHOW_REAGENT= "Show reagent bank",
    CFG_SHOW_EQUIP  = "Show equipped items",
    CFG_SHOW_TOTAL  = "Show total",
    CFG_ONLY_REALM  = "Same realm only",
    CFG_THRESHOLD   = "Minimum display threshold",
    CFG_THRESHOLD_TT= "Only show a character in the tooltip if their total count exceeds this value.",
    SCAN_BAGS_DONE  = "Bags scanned.",
    SCAN_BANK_DONE  = "Bank scanned.",
    SCAN_REAGENT_DONE = "Reagent bank scanned.",
    CMD_HELP        = "Commands: /tms scan — force a bag scan.",
}

for k, v in pairs(defaults) do
    if TomoSyncLocale[k] == nil then
        TomoSyncLocale[k] = v
    end
end
