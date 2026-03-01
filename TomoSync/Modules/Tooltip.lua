-- TomoSync | Modules/Tooltip.lua
-- Affiche les comptes d'objets par personnage dans les tooltips

local TS = TomoSync
local Tooltip = {}
TS:RegisterModule("Tooltip", Tooltip)

-- ============================================================
--  Cache tooltip (évite de recalculer à chaque survol)
-- ============================================================

local tooltipCache  = {}   -- [itemID] = { lines = {...}, total = N }
local CACHE_MAX_AGE = 5    -- secondes

function Tooltip:ResetCache()
    wipe(tooltipCache)
end

-- ============================================================
--  Formatage des nombres
-- ============================================================

local function Fmt(n)
    if not n or n == 0 then return nil end
    if BreakUpLargeNumbers then
        return tostring(BreakUpLargeNumbers(n))
    end
    return tostring(n)
end

-- ============================================================
--  Construction des lignes tooltip pour un itemID
-- ============================================================

local function BuildTooltipLines(itemID)
    local settings  = TS.db.settings
    local curRealm  = TS.realm
    local curChar   = TS.charName
    local db        = TS.db.global
    local threshold = settings.threshold or 0

    local lines = {}   -- { charName, class, total, bags, bank, reagent, equip, isCurrent }
    local grandTotal = 0

    -- Parcourt tous les royaumes / personnages
    for realm, chars in pairs(db) do
        if not settings.onlyRealm or realm == curRealm then
            for charName, entry in pairs(chars) do
                if type(entry) == "table" and entry.items then
                    local bags    = (settings.showBags    and entry.items[itemID] and entry.items[itemID].bags)    or 0
                    local bank    = (settings.showBank    and entry.items[itemID] and entry.items[itemID].bank)    or 0
                    local reagent = (settings.showReagent and entry.items[itemID] and entry.items[itemID].reagent) or 0
                    local equip   = (settings.showEquip   and entry.items[itemID] and entry.items[itemID].equip)   or 0
                    local total   = bags + bank + reagent + equip

                    if total > threshold then
                        table.insert(lines, {
                            charName  = charName,
                            realm     = realm,
                            class     = entry.class,
                            level     = entry.level or 0,
                            total     = total,
                            bags      = bags,
                            bank      = bank,
                            reagent   = reagent,
                            equip     = equip,
                            isCurrent = (charName == curChar and realm == curRealm),
                        })
                        grandTotal = grandTotal + total
                    end
                end
            end
        end
    end

    -- Tri : personnage courant en premier, puis par total décroissant
    table.sort(lines, function(a, b)
        if a.isCurrent ~= b.isCurrent then return a.isCurrent end
        return a.total > b.total
    end)

    return lines, grandTotal
end

-- ============================================================
--  Formatage d'une ligne tooltip
-- ============================================================

-- Construit la partie droite "(Sacs: X · Banque: Y · Réactifs: Z)"
local function BuildBreakdown(entry, settings)
    local parts = {}
    local L = TomoSyncLocale

    if settings.showBags    and entry.bags    and entry.bags    > 0 then
        table.insert(parts, (L and L.BAGS    or "Bags")    .. ": " .. Fmt(entry.bags))
    end
    if settings.showBank    and entry.bank    and entry.bank    > 0 then
        table.insert(parts, (L and L.BANK    or "Bank")    .. ": " .. Fmt(entry.bank))
    end
    if settings.showReagent and entry.reagent and entry.reagent > 0 then
        table.insert(parts, (L and L.REAGENT or "Reagent") .. ": " .. Fmt(entry.reagent))
    end
    if settings.showEquip   and entry.equip   and entry.equip   > 0 then
        table.insert(parts, (L and L.EQUIPPED or "Equipped") .. ": " .. Fmt(entry.equip))
    end

    if #parts == 0 then return "" end
    return TS.COLOR_GRAY .. "(" .. table.concat(parts, ", ") .. ")|r"
end

-- ============================================================
--  Ajout des lignes au tooltip
-- ============================================================

local function AddLinesToTooltip(tooltip, itemID)
    if not TS.db or not TS.db.settings then return end

    -- Cache
    local cached = tooltipCache[itemID]
    if cached and (GetTime() - cached.time) < CACHE_MAX_AGE then
        -- Réutilise le cache
        for _, line in ipairs(cached.lines) do
            tooltip:AddDoubleLine(line.left, line.right, 1, 1, 1, 1, 1, 1)
        end
        if cached.totalLine then
            tooltip:AddDoubleLine(
                cached.totalLine.left,
                cached.totalLine.right,
                0.8, 0.27, 1,   -- pourpre gauche
                0.8, 0.27, 1    -- pourpre droite
            )
        end
        tooltip:Show()
        return
    end

    local lines, grandTotal = BuildTooltipLines(itemID)
    if #lines == 0 then return end

    local settings = TS.db.settings
    local L = TomoSyncLocale

    local cachedLines = {}

    -- Séparateur
    tooltip:AddLine(" ")

    -- Bloc : personnage courant séparé du reste
    local shownCurrent = false
    for _, entry in ipairs(lines) do
        local classColor = TS:ClassColor(entry.class)
        local nameStr

        if entry.isCurrent then
            -- Nom en couleur de classe + "(vous)"
            nameStr = classColor .. entry.charName .. "|r"
            shownCurrent = true
        else
            nameStr = classColor .. entry.charName .. "|r"
            -- Indicateur de royaume différent
            if entry.realm ~= TS.realm then
                nameStr = nameStr .. TS.COLOR_GRAY .. " [" .. entry.realm .. "]|r"
            end
        end

        -- Ligne courante uniquement sacs : affiche directement Bags: X, Bank: Y etc.
        if entry.isCurrent then
            -- Affiche chaque sous-catégorie sur sa propre ligne (style BagSync)
            if settings.showBags and entry.bags and entry.bags > 0 then
                local left  = TS.COLOR_GRAY .. (L and L.BAGS or "Bags") .. ":|r"
                local right = TS.COLOR_HEX .. Fmt(entry.bags) .. "|r"
                tooltip:AddDoubleLine(left, right, 1,1,1, 1,1,1)
                table.insert(cachedLines, { left = left, right = right })
            end
            if settings.showBank and entry.bank and entry.bank > 0 then
                local left  = TS.COLOR_GRAY .. (L and L.BANK or "Bank") .. ":|r"
                local right = TS.COLOR_HEX .. Fmt(entry.bank) .. "|r"
                tooltip:AddDoubleLine(left, right, 1,1,1, 1,1,1)
                table.insert(cachedLines, { left = left, right = right })
            end
            if settings.showReagent and entry.reagent and entry.reagent > 0 then
                local left  = TS.COLOR_GRAY .. (L and L.REAGENT or "Reagent") .. ":|r"
                local right = TS.COLOR_HEX .. Fmt(entry.reagent) .. "|r"
                tooltip:AddDoubleLine(left, right, 1,1,1, 1,1,1)
                table.insert(cachedLines, { left = left, right = right })
            end
            if settings.showEquip and entry.equip and entry.equip > 0 then
                local left  = TS.COLOR_GRAY .. (L and L.EQUIPPED or "Equipped") .. ":|r"
                local right = TS.COLOR_HEX .. Fmt(entry.equip) .. "|r"
                tooltip:AddDoubleLine(left, right, 1,1,1, 1,1,1)
                table.insert(cachedLines, { left = left, right = right })
            end
        else
            -- Autres alts : NomPerso    Total (Sacs: X, Banque: Y, Réactifs: Z)
            local breakdown = BuildBreakdown(entry, settings)
            local totalStr  = TS.COLOR_HEX .. Fmt(entry.total) .. "|r"
            if breakdown ~= "" then
                totalStr = totalStr .. " " .. breakdown
            end
            tooltip:AddDoubleLine(nameStr, totalStr, 1,1,1, 1,1,1)
            table.insert(cachedLines, { left = nameStr, right = totalStr })
        end
    end

    -- Ligne Total
    local totalLine = nil
    if settings.showTotal and grandTotal > 0 then
        local leftStr  = TS.COLOR_HEX .. (L and L.TOTAL or "Total") .. ":|r"
        local rightStr = TS.COLOR_HEX .. Fmt(grandTotal) .. "|r"
        tooltip:AddDoubleLine(leftStr, rightStr, 0.8, 0.27, 1, 0.8, 0.27, 1)
        totalLine = { left = leftStr, right = rightStr }
    end

    tooltip:Show()

    -- Met en cache
    tooltipCache[itemID] = {
        time      = GetTime(),
        lines     = cachedLines,
        totalLine = totalLine,
    }
end

-- ============================================================
--  Hook du tooltip
-- ============================================================

function Tooltip:OnInitialize()
    -- Hook sur SetItem (survol d'item dans les sacs, inventaire, etc.)
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
        -- Retail TWW : méthode moderne
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data)
            if not TS.db then return end
            local itemID = data and data.id
            if not itemID or itemID == 0 then return end
            AddLinesToTooltip(tt, itemID)
        end)
    else
        -- Fallback : hook classique
        hooksecurefunc(GameTooltip, "SetItem", function(tt)
            if not TS.db then return end
            local _, link = tt:GetItem()
            if not link then return end
            local itemID = TS:GetItemID(link)
            if itemID then
                AddLinesToTooltip(tt, itemID)
            end
        end)
    end

    -- Aussi sur SetHyperlink (liens dans le chat, etc.)
    hooksecurefunc(GameTooltip, "SetHyperlink", function(tt, link)
        if not TS.db then return end
        if not link or link:sub(1, 4) ~= "item" then return end
        local itemID = TS:GetItemID(link)
        if itemID then
            AddLinesToTooltip(tt, itemID)
        end
    end)

    -- Réinitialise le cache quand le tooltip est masqué
    GameTooltip:HookScript("OnHide", function()
        -- Ne vide pas le cache ici (on veut le garder quelques secondes)
    end)
end
