-- TomoSync | Core.lua

local ADDON_NAME = "TomoSync"
local L          = TomoSyncLocale

-- ============================================================
--  Namespace global
-- ============================================================

TomoSync = {
    version  = "1.0.0",
    modules  = {},
    db       = nil,   -- { global = TomoSyncDB, settings = TomoSyncSettings, char = current char entry }
    realm    = nil,
    charName = nil,
}

local TS = TomoSync

-- ============================================================
--  Constantes de couleur Pourpre
-- ============================================================

TS.COLOR      = "CC44FF"           -- pourpre principal
TS.COLOR_HEX  = "|cFFCC44FF"      -- préfixe couleur
TS.COLOR_GRAY = "|cFFAAAAAA"       -- gris secondaire
TS.COLOR_WHITE= "|cFFFFFFFF"

-- ============================================================
--  Utilitaires
-- ============================================================

function TS:RegisterModule(name, obj)
    self.modules[name] = obj
    obj.name = name
end

function TS:L(key)
    return (L and L[key]) or key
end

function TS:Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage(TS.COLOR_HEX .. "TomoSync|r " .. (msg or ""))
end

function TS:ClassColor(class)
    if class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[class] then
        local c = RAID_CLASS_COLORS[class]
        return string.format("|cFF%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
    end
    return "|cFFFFFFFF"
end

-- Extrait itemID depuis un lien ou un itemID direct
function TS:GetItemID(link)
    if not link then return nil end
    if type(link) == "number" then return link end
    return tonumber(link:match("item:(%d+)"))
end

-- ============================================================
--  Initialisation de la base de données
-- ============================================================

local function MergeDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if type(v) == "table" then
            if type(target[k]) ~= "table" then target[k] = {} end
            MergeDefaults(target[k], v)
        elseif target[k] == nil then
            target[k] = v
        end
    end
end

local function InitDB()
    if type(TomoSyncDB) ~= "table" then
        TomoSyncDB = {}
    end

    TS.realm    = GetRealmName()
    TS.charName = UnitName("player")

    -- Entrée du personnage courant
    if not TomoSyncDB[TS.realm] then
        TomoSyncDB[TS.realm] = {}
    end
    if not TomoSyncDB[TS.realm][TS.charName] then
        TomoSyncDB[TS.realm][TS.charName] = { items = {} }
    end

    local charEntry = TomoSyncDB[TS.realm][TS.charName]
    if not charEntry.items then charEntry.items = {} end

    -- Settings par personnage — stockés dans TomoSyncDB (déclaré en SavedVariables)
    -- pour garantir leur persistance. L'ancienne clé globale _G["TomoSyncSettings_*"]
    -- n'était pas dans le .toc et ne survivait pas aux redémarrages du jeu.
    if type(charEntry.settings) ~= "table" then
        charEntry.settings = {}
    end
    MergeDefaults(charEntry.settings, TomoSyncDB_Defaults)

    -- Met à jour les infos du personnage
    local _, class = UnitClass("player")
    charEntry.class = class
    charEntry.level = UnitLevel("player")

    TS.db = {
        global   = TomoSyncDB,
        settings = charEntry.settings,
        char     = charEntry,
    }
end

-- ============================================================
--  Accesseurs DB
-- ============================================================

-- Retourne l'entrée d'un personnage donné (ou nil)
function TS:GetCharEntry(realm, charName)
    local db = self.db and self.db.global
    if not db then return nil end
    return db[realm] and db[realm][charName]
end

-- Retourne le total d'un itemID pour un personnage
function TS:GetCharItemCount(entry, itemID, showBags, showBank, showReagent, showEquip)
    if not entry or not entry.items then return 0 end
    local data = entry.items[itemID]
    if not data then return 0 end
    local total = 0
    if showBags    and data.bags    then total = total + data.bags    end
    if showBank    and data.bank    then total = total + data.bank    end
    if showReagent and data.reagent then total = total + data.reagent end
    if showEquip   and data.equip   then total = total + data.equip   end
    return total
end

-- ============================================================
--  Frame principale et événements
-- ============================================================

local frame = CreateFrame("Frame", "TomoSyncFrame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local name = ...
        if name == ADDON_NAME then
            InitDB()
            for _, mod in pairs(TS.modules) do
                if mod.OnInitialize then mod:OnInitialize() end
            end
            TS:Print("v" .. TS.version .. " chargé. |cFFCC44FF/tms|r pour les options.")
            self:UnregisterEvent("ADDON_LOADED")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        if TS.db then
            local _, class = UnitClass("player")
            TS.db.char.class = class
            TS.db.char.level = UnitLevel("player")
        end
        for _, mod in pairs(TS.modules) do
            if mod.OnEnteringWorld then mod:OnEnteringWorld() end
        end

    elseif event == "PLAYER_LEVEL_UP" then
        if TS.db then
            TS.db.char.level = UnitLevel("player")
        end
    end
end)

-- ============================================================
--  Commandes slash
-- ============================================================

SLASH_TOMOSYNC1 = "/tomosync"
SLASH_TOMOSYNC2 = "/tms"

SlashCmdList["TOMOSYNC"] = function(msg)
    local cmd = msg and msg:lower():match("^%s*(%S*)") or ""
    if cmd == "scan" then
        local scanner = TS.modules["Scanner"]
        if scanner then
            scanner:ScanBags()
            TS:Print(TS:L("SCAN_BAGS_DONE"))
        end
    else
        if TomoSyncConfig and TomoSyncConfig.Toggle then
            TomoSyncConfig:Toggle()
        end
    end
end
