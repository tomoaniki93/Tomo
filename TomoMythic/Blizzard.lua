-- TomoMythic / Blizzard.lua
-- Completely suppresses every piece of Blizzard UI related to Mythic+.
-- Nothing is simply hidden — frames are hooked so Blizzard can't re-show them.

local _, TM = ...

-- ── List of all Blizzard frames to suppress in M+ ─────────────────────────────
-- Each entry: global name (string) or resolver function() → frame
local BLIZZARD_FRAMES = {
    -- Challenge / Scenario tracker embedded in the objective tracker
    "ScenarioFrame",
    "ScenarioTrackerProgressBar",

    -- The M+ block inside ObjectiveTrackerFrame
    function() return ObjectiveTrackerFrame and ObjectiveTrackerFrame.CHALLENGE_BLOCK end,
    function() return ObjectiveTrackerFrame and ObjectiveTrackerFrame.BONUS_OBJECTIVE_TRACKER_MODULE end,

    -- Scenario stage frame (shows at instance entry)
    "ScenarioStageBlock",
    function() return ScenarioObjectiveTracker end,

    -- The actual challenge-mode objective tracker block
    function()
        if ObjectiveTrackerFrame and ObjectiveTrackerFrame.CHALLENGE_BLOCK then
            return ObjectiveTrackerFrame.CHALLENGE_BLOCK
        end
    end,
}

-- ObjectiveTracker modules that handle challenge / scenario / bonus
local BLIZZARD_OT_MODULES = {
    "CHALLENGE_BLOCK",
    "SCENARIO_CONTENT_TRACKER_MODULE",
    "BONUS_OBJECTIVE_TRACKER_MODULE",
    "UI_WIDGET_SCENARIO_TRACKER_MODULE",
}

-- ── Internal suppression state ────────────────────────────────────────────────
TM._blizzHooked   = false
TM._inChallenge   = false

-- ── Hook a frame so Show() is a no-op while we're suppressing ────────────────
local function HookHide(frame, name)
    if not frame or frame._tmHooked then return end
    frame._tmHooked = true
    frame:Hide()
    hooksecurefunc(frame, "Show", function(f)
        if TM._inChallenge then f:Hide() end
    end)
end

-- ── Also hook SetShown ────────────────────────────────────────────────────────
local function HookSetShown(frame)
    if not frame or frame._tmShownHooked then return end
    frame._tmShownHooked = true
    hooksecurefunc(frame, "SetShown", function(f, val)
        if TM._inChallenge and val then f:Hide() end
    end)
end

-- ── Apply suppression to the ObjectiveTracker modules ────────────────────────
local function SuppressOTModules()
    local OT = ObjectiveTrackerFrame
    if not OT then return end

    -- Hide the whole tracker in M+
    HookHide(OT, "ObjectiveTrackerFrame")
    HookSetShown(OT)

    -- Individually suppress M+ specific blocks
    for _, modKey in ipairs(BLIZZARD_OT_MODULES) do
        local mod = OT[modKey]
        if mod then
            HookHide(mod, modKey)
            HookSetShown(mod)
            -- Also hide their header / content containers if present
            if mod.Header   then HookHide(mod.Header) end
            if mod.contents then HookHide(mod.contents) end
        end
    end
end

-- ── Apply suppression to the named / resolved frames ─────────────────────────
local function SuppressNamedFrames()
    for _, entry in ipairs(BLIZZARD_FRAMES) do
        local frame
        if type(entry) == "string" then
            frame = _G[entry]
        elseif type(entry) == "function" then
            local ok, result = pcall(entry)
            if ok then frame = result end
        end
        if frame then HookHide(frame, tostring(entry)) end
    end
end

-- ── Main entry: call when entering challenge mode ─────────────────────────────
function TM:SuppressBlizzardUI()
    TM._inChallenge = true
    SuppressOTModules()
    SuppressNamedFrames()

    -- Belt-and-suspenders: re-apply every 2s for the first 10s in case Blizzard
    -- initialises its frames late (scenario tracker does this).
    local attempts = 0
    local function retry()
        attempts = attempts + 1
        SuppressOTModules()
        SuppressNamedFrames()
        if attempts < 5 then
            C_Timer.After(2, retry)
        end
    end
    C_Timer.After(1, retry)
end

-- ── Restore when leaving challenge mode ──────────────────────────────────────
-- We only flip the flag; hooks remain but will no longer force-hide.
function TM:RestoreBlizzardUI()
    TM._inChallenge = false
    -- Blizzard will re-show its frames naturally via its own event flow.
    -- We simply stop interfering.
end

-- ── One-time setup on addon load ─────────────────────────────────────────────
function TM:InitBlizzardSuppress()
    if TM._blizzHooked then return end
    TM._blizzHooked = true

    -- Hook ObjectiveTrackerFrame.Show globally (it gets called on every
    -- PLAYER_ENTERING_WORLD regardless of instance type).
    if ObjectiveTrackerFrame then
        HookHide(ObjectiveTrackerFrame, "OTF_global")
        -- But allow it outside M+ — handled by TM._inChallenge flag
        -- We need to undo the "always hide" from HookHide, so re-hook properly:
        ObjectiveTrackerFrame._tmHooked = false  -- reset
        hooksecurefunc(ObjectiveTrackerFrame, "Show", function(f)
            if TM._inChallenge then f:Hide() end
        end)
    end

    -- UIWidgets that Blizzard uses for the scenario progress bar
    if UIWidgetBelowMinimapContainerFrame then
        hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "Show", function(f)
            if TM._inChallenge then f:Hide() end
        end)
    end

    -- ScenarioObjectiveTracker (separate frame in some builds)
    if ScenarioObjectiveTracker then
        hooksecurefunc(ScenarioObjectiveTracker, "Show", function(f)
            if TM._inChallenge then f:Hide() end
        end)
    end
end
