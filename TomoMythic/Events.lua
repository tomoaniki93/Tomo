-- TomoMythic / Events.lua

local _, TM = ...

-- ── Event frame ───────────────────────────────────────────────────────────────
local EF = CreateFrame("Frame")
EF:RegisterEvent("ADDON_LOADED")
EF:RegisterEvent("PLAYER_LOGIN")
EF:RegisterEvent("PLAYER_ENTERING_WORLD")
EF:RegisterEvent("CHALLENGE_MODE_START")
EF:RegisterEvent("CHALLENGE_MODE_COMPLETED")
EF:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
EF:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
EF:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
EF:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
EF:RegisterEvent("SCENARIO_POI_UPDATE")
EF:SetScript("OnEvent", function(_, event, ...) TM:OnEvent(event, ...) end)

-- ── Ticker ────────────────────────────────────────────────────────────────────
TM._ticker = nil

function TM:StartTicker()
    if self._ticker then return end
    local function tick()
        TM._ticker = nil
        if C_ChallengeMode.IsChallengeModeActive() then
            TM:UpdateTimerBar()
            TM._ticker = C_Timer.NewTimer(TM.UPDATE_RATE, tick)
        end
    end
    self._ticker = C_Timer.NewTimer(self.UPDATE_RATE, tick)
end

function TM:StopTicker()
    if self._ticker then self._ticker:Cancel(); self._ticker = nil end
end

-- ── Event handler ─────────────────────────────────────────────────────────────
function TM:OnEvent(event, ...)
    -- ── ADDON_LOADED ──────────────────────────────────────────────────────────
    if event == "ADDON_LOADED" then
        local name = ...
        if name == "TomoMythic" then
            self:InitDB()
            self:BuildFrame()
            self:InitBlizzardSuppress()
            if self.db.showInterrupt then
                self:InitInterruptTracker()
            end
            local p = self.db.position
            self.Frame:ClearAllPoints()
            self.Frame:SetPoint(p.anchor, UIParent, p.relTo, p.x, p.y)
            self.Frame:SetScale(self.db.scale)
        end

    -- ── PLAYER_ENTERING_WORLD ─────────────────────────────────────────────────
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_MythicPlus.RequestMapInfo()
        self:OnInterruptEnterWorld()
        if C_ChallengeMode.IsChallengeModeActive() then
            -- Already in a key (reload inside dungeon)
            self:SuppressBlizzardUI()
            self:_LoadActiveKey()
            self:RefreshAll(false)
            self:ShowFrame()
            self:StartTicker()
        else
            self:RestoreBlizzardUI()
            self:HideFrame()
        end

    -- ── CHALLENGE_MODE_START ──────────────────────────────────────────────────
    elseif event == "CHALLENGE_MODE_START" then
        self.bossKillTimes = {}
        self.completionTime = nil
        self:SuppressBlizzardUI()
        self:_LoadActiveKey()
        self:RefreshAll(false)
        self:ShowFrame()
        self:StartTicker()

    -- ── CHALLENGE_MODE_COMPLETED ──────────────────────────────────────────────
    elseif event == "CHALLENGE_MODE_COMPLETED" then
        self:StopTicker()
        local info = C_ChallengeMode.GetChallengeCompletionInfo()
        self.completionTime = info and info.time or nil
        self:UpdateTimerBar(false)
        self:UpdateBossRows(false)
        self:UpdateBanner()
        self:LayoutFrame()
        -- Delay re-enabling Blizzard UI until player leaves instance
        -- (keep our frame visible with the completion summary)

    -- ── DEATHS ────────────────────────────────────────────────────────────────
    elseif event == "CHALLENGE_MODE_DEATH_COUNT_UPDATED" then
        self:UpdateHeader()

    -- ── SCENARIO (bosses / forces) ────────────────────────────────────────────
    elseif event == "SCENARIO_CRITERIA_UPDATE"
        or event == "SCENARIO_POI_UPDATE" then
        if C_ChallengeMode.IsChallengeModeActive() then
            self:UpdateBossRows()
            self:UpdateForcesBar()
            self:LayoutFrame()
        end

    -- ── KEYSTONE ──────────────────────────────────────────────────────────────
    elseif event == "CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN" then
        self:_AutoSlotKey()
    end
end

-- ── Internal helpers ──────────────────────────────────────────────────────────
function TM:_LoadActiveKey()
    self.mapID  = C_ChallengeMode.GetActiveChallengeMapID()
    self.level, self.affixes = C_ChallengeMode.GetActiveKeystoneInfo()
    local _, _, tl = C_ChallengeMode.GetMapUIInfo(self.mapID or 0)
    self.timeLimit  = tl or 1800
    self.chestTimes = {
        [1] = self.timeLimit,
        [2] = math.floor(self.timeLimit * 0.80),
    }
end

function TM:_AutoSlotKey()
    local idx = select(3, GetInstanceInfo())
    if idx ~= 8 and idx ~= 23 then return end
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local id = C_Container.GetContainerItemID(bag, slot)
            if id and C_Item.IsItemKeystoneByID(id) then
                C_Container.UseContainerItem(bag, slot)
                return
            end
        end
    end
end
