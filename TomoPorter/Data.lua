-- TomoPorter | Data.lua
-- Base de données des téléporteurs de donjons, raids et sorts de Mage
-- SpellIDs validés — source : Porter addon (communauté)
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
    [227] = { "Return to Karazhan",                     373262  },
    [233] = { "Cathedral of Eternal Night",             nil     },
    [234] = { "Return to Karazhan",                     373262  },
    [239] = { "Seat of the Triumvirate",                252631  }, -- corrigé (était 1254551)

    -- Battle for Azeroth
    [244] = { "Atal'Dazar",                             424187  },
    [245] = { "Freehold",                               410071  },
    [246] = { "Tol Dagor",                              nil     },
    [247] = { "The MOTHERLODE!!",                       272268  }, -- corrigé (était nil)
    [248] = { "Waycrest Manor",                         424167  },
    [249] = { "Kings' Rest",                            nil     },
    [250] = { "Temple of Sethraliss",                   nil     },
    [251] = { "The Underrot",                           410074  },
    [252] = { "Shrine of the Storm",                    nil     },
    [353] = { "Siege of Boralus",                       445418  }, -- corrigé (était nil)
    [369] = { "Operation: Mechagon",                    373274  },
    [370] = { "Operation: Mechagon",                    373274  },

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
    [463] = { "Dawn of the Infinite",                   424197  },
    [464] = { "Dawn of the Infinite",                   424197  },

    -- Dragonflight Raids
    [479] = { "Vault of the Incarnates",                432254  }, -- corrigé (était nil)
    [480] = { "Aberrus, the Shadowed Crucible",         432257  }, -- corrigé (était nil)
    [481] = { "Amirdrassil, the Dream's Hope",          432258  }, -- corrigé (était nil)

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

    -- Midnight (PTR 12.x)
    [557] = { "Windrunner Spire",                       1254400 }, -- corrigé (était 1254840)
    [558] = { "Magisters' Terrace",                     1254572 },
    [559] = { "Nexus-Point Xenas",                      1254563 },
    [560] = { "Maisara Caverns",                        1254559 }, -- corrigé (était 1255247)
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
                    e(560),   -- Maisara Caverns
                    e(556),   -- Pit of Saron
                    e(239)    -- Seat of the Triumvirate
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
                    e(463),   -- Dawn of the Infinite
                    e(464)    -- Dawn of the Infinite
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
    -- RAIDS
    -- ===================================================
    raids = {

        current = {
            {
                seasonLabel = "The War Within — Saison 2",
                entries = {
                    { name = "Liberation of Undermine",  spellID = 1226482 },
                    { name = "Manaforge Omega",          spellID = 1239155 },
                    { name = "Nerub-ar Palace",          spellID = nil     },
                },
            },
        },

        legacy = {
            {
                expansion = "The War Within — Saison 1",
                entries = {},
            },
            {
                expansion = "Dragonflight",
                entries = {
                    { name = "Amirdrassil, the Dream's Hope",    spellID = 432258 }, -- corrigé
                    { name = "Aberrus, the Shadowed Crucible",   spellID = 432257 }, -- corrigé
                    { name = "Vault of the Incarnates",          spellID = 432254 }, -- corrigé
                },
            },
            {
                expansion = "Shadowlands",
                entries = {
                    { name = "Sepulcher of the First Ones",      spellID = 373192 }, -- corrigé
                    { name = "Sanctum of Domination",            spellID = 373191 }, -- corrigé
                    { name = "Castle Nathria",                   spellID = 373190 }, -- corrigé
                },
            },
            {
                expansion = "Battle for Azeroth",
                entries = {
                    { name = "Ny'alotha",              spellID = nil },
                    { name = "The Eternal Palace",     spellID = nil },
                    { name = "Crucible of Storms",     spellID = nil },
                    { name = "Battle of Dazar'alor",   spellID = nil },
                    { name = "Uldir",                  spellID = nil },
                },
            },
        },
    },

    -- ===================================================
    -- MAGE — Téléportations & Portails (sorts de classe)
    -- Source : Porter addon — IDs validés in-game
    --
    -- [A] = Alliance uniquement   [H] = Horde uniquement
    -- Neutral = disponible pour les deux factions
    --
    -- Vérification en jeu :
    --   /run print(C_Spell.GetSpellName(SPELL_ID))
    -- ===================================================
    mage = {

        teleports = {
            {
                group = "Classic",
                entries = {
                    { name = "Stormwind [A]",     spellID = 3561  },
                    { name = "Ironforge [A]",     spellID = 3562  },
                    { name = "Darnassus [A]",     spellID = 3565  },
                    { name = "Orgrimmar [H]",     spellID = 3567  },
                    { name = "Undercity [H]",     spellID = 3563  },
                    { name = "Thunder Bluff [H]", spellID = 3566  },
                },
            },
            {
                group = "The Burning Crusade",
                entries = {
                    { name = "Exodar [A]",            spellID = 32271 },
                    { name = "Silvermoon [H]",         spellID = 32272 },
                    { name = "Shattrath [A]",          spellID = 33690 },
                    { name = "Shattrath [H]",          spellID = 35715 }, -- corrigé
                },
            },
            {
                group = "Wrath of the Lich King",
                entries = {
                    { name = "Dalaran — Northrend",    spellID = 53140  },
                    { name = "Ancient Dalaran",        spellID = 120145 }, -- ajouté
                },
            },
            {
                group = "Cataclysm",
                entries = {
                    { name = "Theramore [A]",          spellID = 49359 },
                    { name = "Stonard [H]",            spellID = 49358 },
                    { name = "Tol Barad [A]",          spellID = 88342 },
                    { name = "Tol Barad [H]",          spellID = 88344 },
                },
            },
            {
                group = "Mists of Pandaria",
                entries = {
                    { name = "Vale of Eternal Blossoms [A]", spellID = 132621 },
                    { name = "Vale of Eternal Blossoms [H]", spellID = 132627 }, -- corrigé
                },
            },
            {
                group = "Warlords of Draenor",
                entries = {
                    { name = "Stormshield [A]",        spellID = 176248 }, -- ajouté
                    { name = "Warspear [H]",           spellID = 176242 }, -- ajouté
                },
            },
            {
                group = "Legion",
                entries = {
                    { name = "Dalaran — Broken Isles", spellID = 224869 }, -- corrigé
                    { name = "Hall of the Guardian",   spellID = 193759 },
                },
            },
            {
                group = "Battle for Azeroth",
                entries = {
                    { name = "Boralus [A]",            spellID = 281403 },
                    { name = "Dazar'alor [H]",         spellID = 281404 },
                },
            },
            {
                group = "Shadowlands",
                entries = {
                    { name = "Oribos",                 spellID = 344587 }, -- corrigé
                },
            },
            {
                group = "Dragonflight",
                entries = {
                    { name = "Valdrakken",             spellID = 395277 },
                },
            },
            {
                group = "The War Within",
                entries = {
                    { name = "Dornogal",               spellID = 446540 }, -- corrigé
                },
            },
            {
                group = "Midnight (PTR 12.x)",
                entries = {
                    { name = "Silvermoon City",        spellID = 1259190 }, -- ajouté
                },
            },
        },

        portals = {
            {
                group = "Classic",
                entries = {
                    { name = "Stormwind [A]",     spellID = 10059 },
                    { name = "Ironforge [A]",     spellID = 11416 },
                    { name = "Darnassus [A]",     spellID = 11419 },
                    { name = "Orgrimmar [H]",     spellID = 11417 },
                    { name = "Undercity [H]",     spellID = 11418 },
                    { name = "Thunder Bluff [H]", spellID = 11420 },
                },
            },
            {
                group = "The Burning Crusade",
                entries = {
                    { name = "Exodar [A]",            spellID = 32266 },
                    { name = "Silvermoon [H]",         spellID = 32267 },
                    { name = "Shattrath [A]",          spellID = 33691 }, -- corrigé
                    { name = "Shattrath [H]",          spellID = 35717 },
                },
            },
            {
                group = "Wrath of the Lich King",
                entries = {
                    { name = "Dalaran — Northrend",    spellID = 53142  },
                    { name = "Ancient Dalaran",        spellID = 120146 }, -- ajouté
                },
            },
            {
                group = "Cataclysm",
                entries = {
                    { name = "Theramore [A]",          spellID = 49360 },
                    { name = "Stonard [H]",            spellID = 49361 },
                    { name = "Tol Barad [A]",          spellID = 88345 },
                    { name = "Tol Barad [H]",          spellID = 88346 },
                },
            },
            {
                group = "Mists of Pandaria",
                entries = {
                    { name = "Vale of Eternal Blossoms [A]", spellID = 132620 },
                    { name = "Vale of Eternal Blossoms [H]", spellID = 132626 }, -- corrigé
                },
            },
            {
                group = "Warlords of Draenor",
                entries = {
                    { name = "Stormshield [A]",        spellID = 176246 }, -- ajouté
                    { name = "Warspear [H]",           spellID = 176244 }, -- ajouté
                },
            },
            {
                group = "Legion",
                entries = {
                    { name = "Dalaran — Broken Isles", spellID = 224871 }, -- corrigé
                },
            },
            {
                group = "Battle for Azeroth",
                entries = {
                    { name = "Boralus [A]",            spellID = 281400 },
                    { name = "Dazar'alor [H]",         spellID = 281402 },
                },
            },
            {
                group = "Shadowlands",
                entries = {
                    { name = "Oribos",                 spellID = 344597 }, -- corrigé
                },
            },
            {
                group = "Dragonflight",
                entries = {
                    { name = "Valdrakken",             spellID = 395289 }, -- corrigé
                },
            },
            {
                group = "The War Within",
                entries = {
                    { name = "Dornogal",               spellID = 446534 }, -- corrigé
                },
            },
            {
                group = "Midnight (PTR 12.x)",
                entries = {
                    { name = "Silvermoon City",        spellID = 1259194 }, -- ajouté
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
