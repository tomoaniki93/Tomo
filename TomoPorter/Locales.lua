-- TomoPorter | Locales.lua
-- Gestion des langues FR / EN

TomoPorter = TomoPorter or {}
local L = {}
TomoPorter.L = L

local locale = GetLocale()

if locale == "frFR" then
    -- Interface
    L["TITLE"]            = "Porter"
    L["DUNGEONS"]         = "Donjons"
    L["RAIDS"]            = "Raids"
    L["CURRENT"]          = "Actuel"
    L["LEGACY"]           = "Héritage"
    L["NO_TELEPORT"]      = "Aucun téléporteur disponible"
    L["NOT_LEARNED"]      = "Sort non appris"
    L["CLOSE"]            = "Fermer"
    L["TOOLTIP_CLICK"]    = "Clic gauche : Téléporter"
    L["TOOLTIP_UNKNOWN"]  = "Sort inconnu ou non appris"
    L["SEASON"]           = "Saison"
    L["EXPANSION"]        = "Extension"
    -- Expansions
    L["TWW"]              = "The War Within"
    L["DRAGONFLIGHT"]     = "Dragonflight"
    L["SHADOWLANDS"]      = "Ombreterre"
    L["BFA"]              = "Bataille pour Azeroth"
    L["LEGION"]           = "Légion"
    L["WOD"]              = "Warlords of Draenor"
    L["MOP"]              = "Mists of Pandaria"
    L["CATA"]             = "Cataclysm"
    L["WOTLK"]            = "Wrath of the Lich King"
    L["TBC"]              = "The Burning Crusade"
else
    -- Default: English
    L["TITLE"]            = "Porter"
    L["DUNGEONS"]         = "Dungeons"
    L["RAIDS"]            = "Raids"
    L["CURRENT"]          = "Current"
    L["LEGACY"]           = "Legacy"
    L["NO_TELEPORT"]      = "No teleport available"
    L["NOT_LEARNED"]      = "Spell not learned"
    L["CLOSE"]            = "Close"
    L["TOOLTIP_CLICK"]    = "Left click: Teleport"
    L["TOOLTIP_UNKNOWN"]  = "Unknown or unlearned spell"
    L["SEASON"]           = "Season"
    L["EXPANSION"]        = "Expansion"
    -- Expansions
    L["TWW"]              = "The War Within"
    L["DRAGONFLIGHT"]     = "Dragonflight"
    L["SHADOWLANDS"]      = "Shadowlands"
    L["BFA"]              = "Battle for Azeroth"
    L["LEGION"]           = "Legion"
    L["WOD"]              = "Warlords of Draenor"
    L["MOP"]              = "Mists of Pandaria"
    L["CATA"]             = "Cataclysm"
    L["WOTLK"]            = "Wrath of the Lich King"
    L["TBC"]              = "The Burning Crusade"
end
