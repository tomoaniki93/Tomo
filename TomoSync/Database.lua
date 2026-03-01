-- TomoSync | Database.lua

--[[
    Structure de TomoSyncDB (SavedVariables, globale) :
    TomoSyncDB = {
        ["Nom du Royaume"] = {
            ["NomDuPerso"] = {
                class    = "WARRIOR",
                level    = 80,
                lastScan = <timestamp>,
                -- items[itemID] = { bags=N, bank=N, reagent=N, equip=N }
                items    = {},
            },
        },
    }

    Structure de TomoSyncSettings (par personnage) :
    {
        showBags    = true,
        showBank    = true,
        showReagent = true,
        showEquip   = false,
        showTotal   = true,
        onlyRealm   = true,
        threshold   = 0,
    }
--]]

TomoSyncDB_Defaults = {
    showBags    = true,
    showBank    = true,
    showReagent = true,
    showEquip   = false,
    showTotal   = true,
    onlyRealm   = true,
    threshold   = 0,
}
