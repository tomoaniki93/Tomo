-- TomoMail | Modules/Contacts.lua
-- Bouton dropdown à côté du champ "À :" du courrier
-- Affiche : Mes Alts · Membres de guilde (par lettre) · Récents

local TM = TomoMail
local Contacts = {}
TM:RegisterModule("Contacts", Contacts)

-- ============================================================
--  Variables locales
-- ============================================================

local dropdownFrame   = nil
local contactButton   = nil
local isMailOpen      = false

-- Cache des membres de guilde groupés par lettre
-- { A = { {name,class,online}, ... }, B = {...}, ... }
local guildCache      = {}
local guildCacheTime  = 0
local GUILD_CACHE_TTL = 10  -- secondes

-- ============================================================
--  Helper : crée un info propre sans checkbox ni radio
-- ============================================================

local function NewInfo()
    local info = UIDropDownMenu_CreateInfo()
    info.notCheckable = true
    info.isNotRadio   = true
    return info
end

-- ============================================================
--  Construction du cache guilde groupé par lettre
-- ============================================================

local function BuildGuildCache()
    guildCache = {}
    if not IsInGuild() then return end

    if C_GuildInfo and C_GuildInfo.GuildRoster then
        C_GuildInfo.GuildRoster()
    end

    local player     = UnitName("player")
    local onlineOnly = TM.db.profile.guildOnlineOnly
    local numMembers = GetNumGuildMembers()

    for i = 1, numMembers do
        local name, _, _, lvl, _, _, _, _, isOnline, _, class = GetGuildRosterInfo(i)
        if name then
            local shortName = strsplit("-", name)
            if shortName ~= player then
                if not onlineOnly or isOnline then
                    local letter = shortName:sub(1, 1):upper()
                    if not guildCache[letter] then
                        guildCache[letter] = {}
                    end
                    table.insert(guildCache[letter], {
                        name   = shortName,
                        level  = lvl or 0,
                        class  = class,
                        online = isOnline,
                    })
                end
            end
        end
    end

    -- Trie chaque groupe par nom
    for _, group in pairs(guildCache) do
        table.sort(group, function(a, b)
            -- En ligne d'abord, puis alphabétique
            if a.online ~= b.online then return a.online end
            return a.name < b.name
        end)
    end

    guildCacheTime = GetTime()
end

local function GetGuildCache()
    if not guildCache or (GetTime() - guildCacheTime) > GUILD_CACHE_TTL then
        BuildGuildCache()
    end
    return guildCache
end

-- ============================================================
--  Initialisation
-- ============================================================

function Contacts:OnInitialize() end

function Contacts:OnMailShow()
    isMailOpen = true
    -- Invalide le cache à chaque ouverture
    guildCacheTime = 0
    self:CreateUI()
end

function Contacts:OnMailHide()
    isMailOpen = false
    if dropdownFrame then CloseDropDownMenus() end
end

-- ============================================================
--  Création du bouton UI
-- ============================================================

function Contacts:CreateUI()
    if not contactButton then
        contactButton = CreateFrame("Button", "TomoMailContactButton", SendMailFrame)
        contactButton:SetSize(26, 26)
        contactButton:SetPoint("LEFT", SendMailNameEditBox, "RIGHT", 2, 0)

        contactButton:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        contactButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Round", "ADD")
        contactButton:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")

        contactButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:AddLine("|cFFFFCC00TomoMail|r")
            GameTooltip:AddLine(TM:L("CONTACTS"), 1, 1, 1)
            GameTooltip:Show()
        end)
        contactButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
        contactButton:SetScript("OnClick", function(self)
            Contacts:ToggleDropdown(self)
        end)
    end

    contactButton:Show()

    if not dropdownFrame then
        dropdownFrame = CreateFrame("Frame", "TomoMailDropdown", UIParent, "UIDropDownMenuTemplate")
        dropdownFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
        UIDropDownMenu_Initialize(dropdownFrame, Contacts.BuildMenu, "MENU")
    end
end

-- ============================================================
--  Menu principal (niveau 1)
-- ============================================================

function Contacts.BuildMenu(frame, level)
    if not level then level = 1 end
    local db = TM.db

    if level == 1 then
        local info = NewInfo()
        info.text    = "|cFFFFCC00" .. TM:L("CONTACTS") .. "|r"
        info.isTitle = true
        UIDropDownMenu_AddButton(info, level)

        if db.profile.showAlts then
            info = NewInfo()
            info.text     = TM:L("MY_ALTS")
            info.hasArrow = true
            info.value    = "ALTS"
            UIDropDownMenu_AddButton(info, level)
        end

        if db.profile.showGuild then
            info = NewInfo()
            info.text     = TM:L("GUILD_MEMBERS")
            info.hasArrow = true
            info.value    = "GUILD"
            UIDropDownMenu_AddButton(info, level)
        end

        if db.profile.showRecent then
            info = NewInfo()
            info.text     = TM:L("RECENT")
            info.hasArrow = true
            info.value    = "RECENT"
            UIDropDownMenu_AddButton(info, level)
        end

        info = NewInfo()
        info.disabled = true
        info.text     = " "
        UIDropDownMenu_AddButton(info, level)

        info = NewInfo()
        info.text = TM:L("SETTINGS")
        info.func = function()
            CloseDropDownMenus()
            if TomoMailConfig and TomoMailConfig.Toggle then
                TomoMailConfig:Toggle()
            end
        end
        UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        local v = UIDROPDOWNMENU_MENU_VALUE
        if v == "ALTS"   then Contacts:BuildAltsMenu(level)
        elseif v == "GUILD"  then Contacts:BuildGuildLetters(level)
        elseif v == "RECENT" then Contacts:BuildRecentMenu(level)
        elseif v:sub(1, 6) == "GUILD_" then
            -- Ne devrait pas arriver au niveau 2, mais sécurité
        end

    elseif level == 3 then
        local v = UIDROPDOWNMENU_MENU_VALUE
        if v:sub(1, 6) == "GUILD_" then
            local letter = v:sub(7)
            Contacts:BuildGuildMembersByLetter(level, letter)
        end
    end
end

-- ============================================================
--  Sous-menu : Mes Alts
-- ============================================================

function Contacts:BuildAltsMenu(level)
    local alts    = TM.db.global.alts
    local realm   = GetRealmName()
    local faction = UnitFactionGroup("player")
    local player  = UnitName("player")
    local sorted  = {}

    for _, entry in ipairs(alts) do
        local p, r, f, lvl, class = strsplit("|", entry)
        if r == realm and f == faction and p ~= player then
            table.insert(sorted, { name = p, level = tonumber(lvl) or 0, class = class })
        end
    end
    table.sort(sorted, function(a, b) return a.name < b.name end)

    local count = 0
    for _, alt in ipairs(sorted) do
        local color = TM:ClassColor(alt.class)
        local info  = NewInfo()
        info.text = string.format("%s%s|r |cFFAAAAAA(%d)|r", color, alt.name, alt.level)
        info.func = function()
            CloseDropDownMenus()
            TM:SetRecipient(alt.name)
        end
        UIDropDownMenu_AddButton(info, level)
        count = count + 1
    end

    if count == 0 then
        local info = NewInfo()
        info.text     = "|cFFAAAAAA" .. TM:L("NO_ALTS") .. "|r"
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
    end
end

-- ============================================================
--  Sous-menu guilde : liste des lettres (niveau 2)
-- ============================================================

function Contacts:BuildGuildLetters(level)
    if not IsInGuild() then
        local info = NewInfo()
        info.text     = "|cFFAAAAAA" .. TM:L("NO_GUILD") .. "|r"
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
        return
    end

    local cache = GetGuildCache()

    -- Collecte et trie les lettres disponibles
    local letters = {}
    local totalMembers = 0
    for letter, members in pairs(cache) do
        table.insert(letters, letter)
        totalMembers = totalMembers + #members
    end
    table.sort(letters)

    if #letters == 0 then
        local info = NewInfo()
        info.text     = "|cFFAAAAAA" .. TM:L("NO_GUILD_MEMBERS") .. "|r"
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
        return
    end

    -- En-tête : nombre total
    local header = NewInfo()
    local onlineCount = 0
    for _, m in pairs(cache) do
        for _, member in ipairs(m) do
            if member.online then onlineCount = onlineCount + 1 end
        end
    end
    header.text    = string.format("|cFFAAAAAA%d membres · %d connectés|r", totalMembers, onlineCount)
    header.isTitle = true
    UIDropDownMenu_AddButton(header, level)

    -- Une entrée par lettre
    for _, letter in ipairs(letters) do
        local members = cache[letter]
        local onlineInGroup = 0
        for _, m in ipairs(members) do
            if m.online then onlineInGroup = onlineInGroup + 1 end
        end

        local info = NewInfo()
        -- Lettre en jaune, compteur en gris, point vert si quelqu'un est connecté
        local dot = onlineInGroup > 0 and "|cFF00FF00●|r " or ""
        if onlineInGroup > 0 then
            info.text = string.format("%s|cFFFFCC00%s|r  |cFFAAAAAA(%d · %d ✔)|r",
                dot, letter, #members, onlineInGroup)
        else
            info.text = string.format("|cFFFFCC00%s|r  |cFFAAAAAA(%d)|r",
                letter, #members)
        end
        info.hasArrow = true
        info.value    = "GUILD_" .. letter
        UIDropDownMenu_AddButton(info, level)
    end
end

-- ============================================================
--  Sous-menu guilde : membres d'une lettre (niveau 3)
-- ============================================================

function Contacts:BuildGuildMembersByLetter(level, letter)
    local cache   = GetGuildCache()
    local members = cache[letter]

    if not members or #members == 0 then
        local info = NewInfo()
        info.text     = "|cFFAAAAAA(vide)|r"
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
        return
    end

    for _, m in ipairs(members) do
        local color = TM:ClassColor(m.class)
        local dot   = m.online and "|cFF00FF00●|r " or "|cFF555555●|r "
        local info  = NewInfo()
        info.text = dot .. string.format("%s%s|r", color, m.name)
        info.func = function()
            CloseDropDownMenus()
            TM:SetRecipient(m.name)
        end
        UIDropDownMenu_AddButton(info, level)
    end
end

-- ============================================================
--  Sous-menu : Récents
-- ============================================================

function Contacts:BuildRecentMenu(level)
    local recent = TM.db.profile.recent
    local count  = 0

    for _, entry in ipairs(recent) do
        local name = strsplit("|", entry)
        if name and name ~= "" then
            local info = NewInfo()
            info.text = name
            info.func = function()
                CloseDropDownMenus()
                TM:SetRecipient(name)
            end
            UIDropDownMenu_AddButton(info, level)
            count = count + 1
        end
    end

    if count == 0 then
        local info = NewInfo()
        info.text     = "|cFFAAAAAA" .. TM:L("NO_RECENT") .. "|r"
        info.disabled = true
        UIDropDownMenu_AddButton(info, level)
    end
end

-- ============================================================
--  Toggle du dropdown
-- ============================================================

function Contacts:ToggleDropdown(anchor)
    if dropdownFrame then
        -- Invalide le cache guilde avant chaque ouverture
        guildCacheTime = 0
        UIDropDownMenu_Initialize(dropdownFrame, Contacts.BuildMenu, "MENU")
        ToggleDropDownMenu(1, nil, dropdownFrame, anchor:GetName(), 0, 0)
    end
end
