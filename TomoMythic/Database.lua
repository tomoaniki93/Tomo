-- TomoMythic / Database.lua

local _, TM = ...

TM.Defaults = {
    position     = { anchor = "TOPRIGHT", relTo = "TOPRIGHT", x = -20, y = -260 },
    scale        = 1.0,
    alpha        = 0.95,
    locked       = true,
    hideBlizzard = true,
    showTimer    = true,
    showForces   = true,
    showBosses   = true,
    interrupt    = {
        frameWidth      = 220,
        barHeight       = 28,
        locked          = false,
        showTitle       = true,
        growUp          = false,
        alpha           = 0.9,
        nameFontSize    = 0,
        readyFontSize   = 0,
        showReady       = true,
        showInDungeon   = true,
        showInRaid      = false,
        showInOpenWorld = true,
        showInArena     = false,
        showInBG        = false,
    },
}

function TM:InitDB()
    if not TomoMythicDB then TomoMythicDB = {} end
    local function fill(tbl, defs)
        for k, v in pairs(defs) do
            if tbl[k] == nil then
                tbl[k] = type(v) == "table" and CopyTable(v) or v
            elseif type(v) == "table" and type(tbl[k]) == "table" then
                fill(tbl[k], v)
            end
        end
    end
    fill(TomoMythicDB, self.Defaults)
    self.db = TomoMythicDB
end

function TM:SetPos(anchor, relTo, x, y)
    self.db.position.anchor = anchor
    self.db.position.relTo  = relTo
    self.db.position.x      = x
    self.db.position.y      = y
end
