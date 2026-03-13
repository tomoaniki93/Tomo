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
    -- Onglets de catégorie globale
    L["TAB_PORTEURS"]     = "+ Téléporteurs"
    L["TAB_MAGE"]         = "+ Mage"
    -- Onglet Mage
    L["TELEPORTS"]        = "Téléportations"
    L["PORTALS"]          = "Portails"
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
elseif locale == "deDE" then
    -- Benutzeroberfläche
    L["TITLE"]            = "Porter"
    L["DUNGEONS"]         = "Dungeons"
    L["RAIDS"]            = "Raids"
    L["CURRENT"]          = "Aktuell"
    L["LEGACY"]           = "Legacy"
    L["NO_TELEPORT"]      = "Kein Teleporter verfügbar"
    L["NOT_LEARNED"]      = "Zauber nicht erlernt"
    L["CLOSE"]            = "Schließen"
    L["TOOLTIP_CLICK"]    = "Linksklick: Teleportieren"
    L["TOOLTIP_UNKNOWN"]  = "Zauber unbekannt oder nicht erlernt"
    L["SEASON"]           = "Saison"
    L["EXPANSION"]        = "Erweiterung"
    -- Globale Kategorie-Tabs
    L["TAB_PORTEURS"]     = "+ Teleporter"
    L["TAB_MAGE"]         = "+ Magier"
    -- Magier-Tab
    L["TELEPORTS"]        = "Teleportationen"
    L["PORTALS"]          = "Portale"
    -- Expansions
    L["TWW"]              = "The War Within"
    L["DRAGONFLIGHT"]     = "Dragonflight"
    L["SHADOWLANDS"]      = "Schattenlande"
    L["BFA"]              = "Schlacht um Azeroth"
    L["LEGION"]           = "Legion"
    L["WOD"]              = "Warlords of Draenor"
    L["MOP"]              = "Mists of Pandaria"
    L["CATA"]             = "Cataclysm"
    L["WOTLK"]            = "Wrath of the Lich King"
    L["TBC"]              = "The Burning Crusade"
elseif locale == "esES" then
    -- Interfaz Española
    L["TITLE"]            = "Porter"
    L["DUNGEONS"]         = "Mazmorras"
    L["RAIDS"]            = "Banda"
    L["CURRENT"]          = "Actual"
    L["LEGACY"]           = "Legado"
    L["NO_TELEPORT"]      = "Ningún teletransportador disponible"
    L["NOT_LEARNED"]      = "Hechizo no aprendido"
    L["CLOSE"]            = "Cerrar"
    L["TOOLTIP_CLICK"]    = "Clic izquierdo: Teletransportar"
    L["TOOLTIP_UNKNOWN"]  = "Hechizo desconocido o no aprendido"
    L["SEASON"]           = "Temporada"
    L["EXPANSION"]        = "Expansión"
    -- Pestañas de categoría global
    L["TAB_PORTEURS"]     = "+ Teletransportadores"
    L["TAB_MAGE"]         = "+ Mago"
    -- Pestaña Mago
    L["TELEPORTS"]        = "Teletransportaciones"
    L["PORTALS"]          = "Portales"
    -- Expansions
    L["TWW"]              = "La Guerra Interna"
    L["DRAGONFLIGHT"]     = "Vuelo de Dragón"
    L["SHADOWLANDS"]      = "Tierras Sombrías"
    L["BFA"]              = "Battle for Azeroth"
    L["LEGION"]           = "Legión"
    L["WOD"]              = "Señores de la Guerra de Draenor"
    L["MOP"]              = "Mists of Pandaria"
    L["CATA"]             = "Cataclysm"
    L["WOTLK"]            = "Wrath of the Lich King"
    L["TBC"]              = "The Burning Crusade"
elseif locale == "itIT" then
    -- Interfaccia
    L["TITLE"]            = "Porter"
    L["DUNGEONS"]         = "Dungeon"
    L["RAIDS"]            = "Incursioni"
    L["CURRENT"]          = "Attuale"
    L["LEGACY"]           = "Eredità"
    L["NO_TELEPORT"]      = "Nessun teletrasporto disponibile"
    L["NOT_LEARNED"]      = "Incantesimo non appreso"
    L["CLOSE"]            = "Chiudi"
    L["TOOLTIP_CLICK"]    = "Clic sinistro: Teletrasporto"
    L["TOOLTIP_UNKNOWN"]  = "Incantesimo sconosciuto o non appreso"
    L["SEASON"]           = "Stagione"
    L["EXPANSION"]        = "Espansione"
    -- Schede di categoria globale
    L["TAB_PORTEURS"]     = "+ Teletrasportatori"
    L["TAB_MAGE"]         = "+ Mago"
    -- Scheda Mago
    L["TELEPORTS"]        = "Teletrasporti"
    L["PORTALS"]          = "Portali"
    -- Espansioni
    L["TWW"]              = "La Guerra Interna"
    L["DRAGONFLIGHT"]     = "Il Volo del Drago"
    L["SHADOWLANDS"]      = "Terre dell'Ombra"
    L["BFA"]              = "Battle for Azeroth"
    L["LEGION"]           = "Legione"
    L["WOD"]              = "Signori della Guerra di Draenor"
    L["MOP"]              = "Nebbie di Pandaria"
    L["CATA"]             = "Cataclysm"
    L["WOTLK"]            = "Wrath of the Lich King"
    L["TBC"]              = "The Burning Crusade"
elseif locale == "ptBR" then
    -- Interface (Português - Brasil)
    L["TITLE"]            = "Porter"
    L["DUNGEONS"]         = "Masmorras"
    L["RAIDS"]            = "Raide"
    L["CURRENT"]          = "Atual"
    L["LEGACY"]           = "Legado"
    L["NO_TELEPORT"]      = "Nenhum teletransporte disponível"
    L["NOT_LEARNED"]      = "Magia não aprendida"
    L["CLOSE"]            = "Fechar"
    L["TOOLTIP_CLICK"]    = "Clique esquerdo: Teletransportar"
    L["TOOLTIP_UNKNOWN"]  = "Magia desconhecida ou não aprendida"
    L["SEASON"]           = "Temporada"
    L["EXPANSION"]        = "Expansão"
    -- Abas de categoria global
    L["TAB_PORTEURS"]     = "+ Teletransportadores"
    L["TAB_MAGE"]         = "+ Mago"
    -- Aba Mago
    L["TELEPORTS"]        = "Teletransportes"
    L["PORTALS"]          = "Portais"
    -- Expansões
    L["TWW"]              = "The War Within"
    L["DRAGONFLIGHT"]     = "Dragonflight"
    L["SHADOWLANDS"]      = "Terras das Sombras"
    L["BFA"]              = "Battle for Azeroth"
    L["LEGION"]           = "Legião"
    L["WOD"]              = "Senhores da Guerra de Draenor"
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
    -- Global category tabs
    L["TAB_PORTEURS"]     = "+ Teleporters"
    L["TAB_MAGE"]         = "+ Mage"
    -- Mage tab
    L["TELEPORTS"]        = "Teleports"
    L["PORTALS"]          = "Portals"
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
