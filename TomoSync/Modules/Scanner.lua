-- TomoSync | Modules/Scanner.lua
-- Scanne les sacs, la banque et les réactifs du personnage courant

local TS = TomoSync
local Scanner = {}
TS:RegisterModule("Scanner", Scanner)

-- ============================================================
--  Constantes BagIndex (retail)
-- ============================================================

local BAG_MIN  = 0   -- Backpack
local BAG_MAX  = 4   -- Bag 4
local BANK_MAIN        = -1  -- Enum.BagIndex.Bank
local BANK_BAG_MIN     = 5
local BANK_BAG_MAX     = 11
local REAGENT_BAG      = -3  -- Enum.BagIndex.Reagentbank

-- Slots équipement (1-19 = armure + armes, sans les sacs)
local EQUIP_FIRST = 1
local EQUIP_LAST  = 19

-- ============================================================
--  Utilitaire : ajoute count à une clé d'entrée item
-- ============================================================

local function AddToEntry(itemsTable, itemID, slot, count)
    if not itemID or itemID == 0 or not count or count == 0 then return end
    if not itemsTable[itemID] then
        itemsTable[itemID] = { bags = 0, bank = 0, reagent = 0, equip = 0 }
    end
    itemsTable[itemID][slot] = (itemsTable[itemID][slot] or 0) + count
end

-- ============================================================
--  Scanne un ensemble de sacs dans un slot donné ("bags", "bank", "reagent")
-- ============================================================

local function ScanBagRange(itemsTable, bagMin, bagMax, slot)
    for bagID = bagMin, bagMax do
        local numSlots = C_Container and C_Container.GetContainerNumSlots(bagID) or 0
        if numSlots and numSlots > 0 then
            for s = 1, numSlots do
                local info = C_Container and C_Container.GetContainerItemInfo(bagID, s)
                if info and info.itemID and info.stackCount and info.stackCount > 0 then
                    AddToEntry(itemsTable, info.itemID, slot, info.stackCount)
                end
            end
        end
    end
end

-- ============================================================
--  Scanne un seul bag (banque principale ou banque de réactifs)
-- ============================================================

local function ScanSingleBag(itemsTable, bagID, slot)
    local numSlots = C_Container and C_Container.GetContainerNumSlots(bagID) or 0
    if numSlots and numSlots > 0 then
        for s = 1, numSlots do
            local info = C_Container and C_Container.GetContainerItemInfo(bagID, s)
            if info and info.itemID and info.stackCount and info.stackCount > 0 then
                AddToEntry(itemsTable, info.itemID, slot, info.stackCount)
            end
        end
    end
end

-- ============================================================
--  API publique
-- ============================================================

function Scanner:ScanBags()
    if not TS.db or not TS.db.char then return end
    local items = TS.db.char.items
    -- Remet les comptes sacs à zéro avant de rescanner
    for id, data in pairs(items) do
        data.bags = 0
    end
    ScanBagRange(items, BAG_MIN, BAG_MAX, "bags")
    TS.db.char.lastScan = time()
    -- Nettoie les entrées vides
    for id, data in pairs(items) do
        if data.bags == 0 and data.bank == 0 and data.reagent == 0 and data.equip == 0 then
            items[id] = nil
        end
    end
    -- Invalide le cache tooltip
    local tooltip = TS.modules["Tooltip"]
    if tooltip then tooltip:ResetCache() end
end

function Scanner:ScanBank()
    if not TS.db or not TS.db.char then return end
    local items = TS.db.char.items
    for id, data in pairs(items) do
        data.bank = 0
    end
    -- Banque principale (slot -1)
    ScanSingleBag(items, BANK_MAIN, "bank")
    -- Sacs de banque équipés (5..11)
    ScanBagRange(items, BANK_BAG_MIN, BANK_BAG_MAX, "bank")
    TS.db.char.lastScan = time()
    local tooltip = TS.modules["Tooltip"]
    if tooltip then tooltip:ResetCache() end
end

function Scanner:ScanReagentBank()
    if not TS.db or not TS.db.char then return end
    local items = TS.db.char.items
    for id, data in pairs(items) do
        data.reagent = 0
    end
    ScanSingleBag(items, REAGENT_BAG, "reagent")
    TS.db.char.lastScan = time()
    local tooltip = TS.modules["Tooltip"]
    if tooltip then tooltip:ResetCache() end
end

function Scanner:ScanEquipped()
    if not TS.db or not TS.db.char then return end
    local items = TS.db.char.items
    for id, data in pairs(items) do
        data.equip = 0
    end
    for slot = EQUIP_FIRST, EQUIP_LAST do
        local link = GetInventoryItemLink("player", slot)
        if link then
            local itemID = TS:GetItemID(link)
            local count  = GetInventoryItemCount("player", slot) or 1
            if itemID then
                AddToEntry(items, itemID, "equip", count)
            end
        end
    end
    local tooltip = TS.modules["Tooltip"]
    if tooltip then tooltip:ResetCache() end
end

-- ============================================================
--  Événements
-- ============================================================

local scanFrame = CreateFrame("Frame", "TomoSyncScanFrame")

function Scanner:OnInitialize()
    scanFrame:RegisterEvent("BAG_UPDATE")
    scanFrame:RegisterEvent("BANKFRAME_OPENED")
    scanFrame:RegisterEvent("BANKFRAME_CLOSED")
    scanFrame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

    -- Pas d'événement REAGENTBANK_UPDATE en retail TWW
    -- Le rescan des réactifs est déclenché par BAG_UPDATE ou à l'ouverture de la banque

    scanFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "BAG_UPDATE" then
            -- Throttle : on ne scanne pas à chaque item déplacé
            if not self._bagTimer then
                self._bagTimer = C_Timer.NewTimer(0.5, function()
                    self._bagTimer = nil
                    Scanner:ScanBags()
                end)
            end

        elseif event == "BANKFRAME_OPENED" then
            Scanner.atBank = true
            C_Timer.After(0.5, function()
                Scanner:ScanBank()
                if C_Container and IsReagentBankUnlocked and IsReagentBankUnlocked() then
                    Scanner:ScanReagentBank()
                    TS:Print(TS:L("SCAN_REAGENT_DONE"))
                end
                TS:Print(TS:L("SCAN_BANK_DONE"))
            end)

        elseif event == "BANKFRAME_CLOSED" then
            Scanner.atBank = false

        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            Scanner:ScanEquipped()
        end
    end)
end

function Scanner:OnEnteringWorld()
    -- Scan initial des sacs et équipement au login
    C_Timer.After(1.0, function()
        Scanner:ScanBags()
        Scanner:ScanEquipped()
    end)
end
