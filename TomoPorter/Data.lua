-- TomoPorter | Data.lua
-- Base de données des téléporteurs de donjons et raids
-- SpellIDs validés — source : DB communautaire
--
-- Commande de vérification en jeu :
--   /run print(C_Spell.GetSpellName(SPELL_ID))

TomoPorter = TomoPorter or {}

-- Table de référence brute : mapID → { nom, spellID }
local RAW = {
    -- Wrath of the Lich King
    [556] = { "Pit of Saron",                           1254555 },

    -- Mists of Pandaria
    [2]   = { "Temple of the Jade Serpent",             131204  },
    [56]  = { "Stormstout Brewery",                     131205  },
    [57]  = { "Shado-Pan Monastery",                    131206  },
    [58]  = { "Siege of Niuzao Temple",                 131228  },
    [59]  = { "Gate of the Setting Sun",                131225  },
    [60]  = { "Mogu'shan Palace",                       131222  },
    [76]  = { "Scholomance",                            131232  },
    [77]  = { "Scarlet Halls",                          131231  },
    [78]  = { "Scarlet Monastery",                      131229  },

    -- Warlords of Draenor
    [161] = { "Bloodmaul Slag Mines",                   159895  },
    [163] = { "Auchindoun",                             159897  },
    [164] = { "Skyreach",                               159898  },
    [165] = { "Shadowmoon Burial Grounds",              159899  },
    [166] = { "Grimrail Depot",                         159900  },
    [167] = { "Upper Blackrock Spire",                  159902  },
    [168] = { "The Everbloom",                          159901  },
    [169] = { "Iron Docks",                             159896  },

    -- Legion
    [197] = { "Eye of Azshara",                         nil     },
    [198] = { "Darkheart Thicket",                      424163  },
    [199] = { "Black Rook Hold",                        424153  },
    [200] = { "Halls of Valor",                         393764  },
    [206] = { "Neltharion's Lair",                      410078  },
    [207] = { "Vault of the Wardens",                   nil     },
    [208] = { "Maw of Souls",                           nil     },
    [209] = { "The Arcway",                             nil     },
    [210] = { "Court of Stars",                         393766  },
    [227] = { "Return to Karazhan: Lower",              373262  },
    [233] = { "Cathedral of Eternal Night",             nil     },
    [234] = { "Return to Karazhan: Upper",              373262  },
    [239] = { "Seat of the Triumvirate",                1254551 },

    -- Battle for Azeroth
    [244] = { "Atal'Dazar",                             424187  },
    [245] = { "Freehold",                               410071  },
    [246] = { "Tol Dagor",                              nil     },
    [247] = { "The MOTHERLODE!!",                       nil     },
    [248] = { "Waycrest Manor",                         424167  },
    [249] = { "Kings' Rest",                            nil     },
    [250] = { "Temple of Sethraliss",                   nil     },
    [251] = { "The Underrot",                           410074  },
    [252] = { "Shrine of the Storm",                    nil     },
    [353] = { "Siege of Boralus",                       nil     },
    [369] = { "Operation: Mechagon - Junkyard",         373274  },
    [370] = { "Operation: Mechagon - Workshop",         373274  },

    -- Shadowlands
    [375] = { "Mists of Tirna Scithe",                  354464  },
    [376] = { "The Necrotic Wake",                      354462  },
    [377] = { "De Other Side",                          354468  },
    [378] = { "Halls of Atonement",                     354465  },
    [379] = { "Plaguefall",                             354463  },
    [380] = { "Sanguine Depths",                        354469  },
    [381] = { "Spires of Ascension",                    354466  },
    [382] = { "Theater of Pain",                        354467  },
    [391] = { "Tazavesh: Streets of Wonder",            367416  },
    [392] = { "Tazavesh: So'leah's Gambit",             367416  },

    -- Dragonflight
    [399] = { "Ruby Life Pools",                        393256  },
    [400] = { "The Nokhud Offensive",                   393262  },
    [401] = { "The Azure Vault",                        393279  },
    [402] = { "Algeth'ar Academy",                      393273  },
    [403] = { "Uldaman: Legacy of Tyr",                 393222  },
    [404] = { "Neltharus",                              393276  },
    [405] = { "Brackenhide Hollow",                     393267  },
    [406] = { "Halls of Infusion",                      393283  },
    [463] = { "Dawn of the Infinite: Galakrond's Fall", 424197  },
    [464] = { "Dawn of the Infinite: Murozond's Rise",  424197  },

    -- Cataclysm
    [438] = { "Vortex Pinnacle",                        410080  },
    [456] = { "Throne of the Tides",                    424142  },

    -- The War Within
    [499] = { "Priory of the Sacred Flame",             445444  },
    [500] = { "The Rookery",                            445443  },
    [501] = { "The Stonevault",                         445269  },
    [502] = { "City of Threads",                        445416  },
    [503] = { "Ara-Kara, City of Echoes",               445417  },
    [504] = { "Darkflame Cleft",                        445441  },
    [505] = { "The Dawnbreaker",                        445414  },
    [506] = { "Cinderbrew Meadery",                     445440  },
    [507] = { "Grim Batol",                             445424  },
    [525] = { "Operation: Floodgate",                   1216786 },
    [542] = { "Eco-Dome Al'dani",                       1237215 },

    -- Midnight (12.x — PTR)
    [557] = { "Windrunner Spire",                       1254840 },
    [558] = { "Magisters' Terrace",                     1254572 },
    [559] = { "Nexus-Point Xenas",                      1254563 },
    [560] = { "Maisara Caverns",                        1255247 },
}

-- Raccourci : mapID → entry { name, spellID }
local function e(mapID)
    local d = RAW[mapID]
    if not d then return nil end
    return { name = d[1], spellID = d[2] }
end

-- Filtre les nil (entrées manquantes)
local function list(...)
    local t = {}
    for _, v in ipairs({...}) do
        if v then t[#t+1] = v end
    end
    return t
end

-- =========================================================
TomoPorter.Data = {

    -- ===================================================
    -- DONJONS
    -- ===================================================
    dungeons = {

        current = {
            {
                seasonLabel = "The War Within — Saison 2",
                entries = list(
                    e(525),   -- Operation: Floodgate
                    e(542),   -- Eco-Dome Al'dani
                    e(503),   -- Ara-Kara, City of Echoes
                    e(505),   -- The Dawnbreaker
                    e(499),   -- Priory of the Sacred Flame
                    e(391),   -- Tazavesh: Streets of Wonder
                    e(392),   -- Tazavesh: So'leah's Gambit
                    e(378)    -- Halls of Atonement
                ),
            },
        },

        legacy = {
            {
                expansion = "Midnight (PTR 12.x)",
                entries = list(
                    e(557),   -- Windrunner Spire
                    e(558),   -- Magisters' Terrace
                    e(559),   -- Nexus-Point Xenas
                    e(560)    -- Maisara Caverns
                ),
            },
            {
                expansion = "The War Within — Saison 1",
                entries = list(
                    e(503),   -- Ara-Kara, City of Echoes
                    e(502),   -- City of Threads
                    e(505),   -- The Dawnbreaker
                    e(501),   -- The Stonevault
                    e(499),   -- Priory of the Sacred Flame
                    e(504),   -- Darkflame Cleft
                    e(500),   -- The Rookery
                    e(506),   -- Cinderbrew Meadery
                    e(507)    -- Grim Batol
                ),
            },
            {
                expansion = "Dragonflight",
                entries = list(
                    e(399),   -- Ruby Life Pools
                    e(400),   -- The Nokhud Offensive
                    e(401),   -- The Azure Vault
                    e(402),   -- Algeth'ar Academy
                    e(403),   -- Uldaman: Legacy of Tyr
                    e(404),   -- Neltharus
                    e(405),   -- Brackenhide Hollow
                    e(406),   -- Halls of Infusion
                    e(463),   -- Dawn of the Infinite: Galakrond's Fall
                    e(464)    -- Dawn of the Infinite: Murozond's Rise
                ),
            },
            {
                expansion = "Shadowlands",
                entries = list(
                    e(375),   -- Mists of Tirna Scithe
                    e(376),   -- The Necrotic Wake
                    e(377),   -- De Other Side
                    e(378),   -- Halls of Atonement
                    e(379),   -- Plaguefall
                    e(380),   -- Sanguine Depths
                    e(381),   -- Spires of Ascension
                    e(382),   -- Theater of Pain
                    e(391),   -- Tazavesh: Streets of Wonder
                    e(392)    -- Tazavesh: So'leah's Gambit
                ),
            },
            {
                expansion = "Battle for Azeroth",
                entries = list(
                    e(244),   -- Atal'Dazar
                    e(245),   -- Freehold
                    e(246),   -- Tol Dagor
                    e(247),   -- The MOTHERLODE!!
                    e(248),   -- Waycrest Manor
                    e(249),   -- Kings' Rest
                    e(250),   -- Temple of Sethraliss
                    e(251),   -- The Underrot
                    e(252),   -- Shrine of the Storm
                    e(353),   -- Siege of Boralus
                    e(369),   -- Operation: Mechagon - Junkyard
                    e(370)    -- Operation: Mechagon - Workshop
                ),
            },
            {
                expansion = "Legion",
                entries = list(
                    e(197),   -- Eye of Azshara
                    e(198),   -- Darkheart Thicket
                    e(199),   -- Black Rook Hold
                    e(200),   -- Halls of Valor
                    e(206),   -- Neltharion's Lair
                    e(207),   -- Vault of the Wardens
                    e(208),   -- Maw of Souls
                    e(209),   -- The Arcway
                    e(210),   -- Court of Stars
                    e(227),   -- Return to Karazhan: Lower
                    e(233),   -- Cathedral of Eternal Night
                    e(234),   -- Return to Karazhan: Upper
                    e(239)    -- Seat of the Triumvirate
                ),
            },
            {
                expansion = "Warlords of Draenor",
                entries = list(
                    e(161),   -- Bloodmaul Slag Mines
                    e(163),   -- Auchindoun
                    e(164),   -- Skyreach
                    e(165),   -- Shadowmoon Burial Grounds
                    e(166),   -- Grimrail Depot
                    e(167),   -- Upper Blackrock Spire
                    e(168),   -- The Everbloom
                    e(169)    -- Iron Docks
                ),
            },
            {
                expansion = "Mists of Pandaria",
                entries = list(
                    e(2),     -- Temple of the Jade Serpent
                    e(56),    -- Stormstout Brewery
                    e(57),    -- Shado-Pan Monastery
                    e(58),    -- Siege of Niuzao Temple
                    e(59),    -- Gate of the Setting Sun
                    e(60),    -- Mogu'shan Palace
                    e(76),    -- Scholomance
                    e(77),    -- Scarlet Halls
                    e(78)     -- Scarlet Monastery
                ),
            },
            {
                expansion = "Cataclysm",
                entries = list(
                    e(438),   -- Vortex Pinnacle
                    e(456)    -- Throne of the Tides
                ),
            },
            {
                expansion = "Wrath of the Lich King",
                entries = list(
                    e(556)    -- Pit of Saron
                ),
            },
        },
    },

    -- ===================================================
    -- RAIDS (spellIDs non disponibles dans la DB source)
    -- ===================================================
    raids = {

        current = {
            {
                seasonLabel = "The War Within — Saison 2",
                entries = {
                    { name = "Liberation of Undermine",  spellID = 1226482 },
                    { name = "Manaforge Omega",          spellID = 1239155 },
                    { name = "Nerub-ar Palace",          spellID = nil },
                },
            },
        },

        legacy = {
            {
                expansion = "The War Within — Saison 1",
                entries = {
                },
            },
            {
                expansion = "Dragonflight",
                entries = {
                    { name = "Amirdrassil",                 spellID = nil },
                    { name = "Aberrus",                     spellID = nil },
                    { name = "Vault of the Incarnates",     spellID = nil },
                },
            },
            {
                expansion = "Shadowlands",
                entries = {
                    { name = "Sepulcher of the First Ones", spellID = nil },
                    { name = "Sanctum of Domination",       spellID = nil },
                    { name = "Castle Nathria",              spellID = nil },
                },
            },
            {
                expansion = "Battle for Azeroth",
                entries = {
                    { name = "Ny'alotha",                   spellID = nil },
                    { name = "The Eternal Palace",          spellID = nil },
                    { name = "Crucible of Storms",          spellID = nil },
                    { name = "Battle of Dazar'alor",        spellID = nil },
                    { name = "Uldir",                       spellID = nil },
                },
            },
        },
    },
}

function TomoPorter.Data:GetSection(category, tab)
    local cat = self[category]
    if not cat then return {} end
    return cat[tab] or {}
end
