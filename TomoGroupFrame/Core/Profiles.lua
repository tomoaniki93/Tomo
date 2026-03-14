-- =====================================
-- Core/Profiles.lua
-- Système de profils TomoGroupFrame
-- Architecture identique à TomoMod_Profiles
-- =====================================

TGF_Profiles = {}
local P = TGF_Profiles

local EXCLUDED_KEYS = { ["_profiles"] = true }

-- =====================================
-- DEEP COPY / DEEP MERGE
-- =====================================

local function DeepCopy(src)
    if type(src) ~= "table" then return src end
    local copy = {}
    for k, v in pairs(src) do copy[k] = DeepCopy(v) end
    return copy
end

-- =====================================
-- SNAPSHOT / APPLY
-- =====================================

local function SnapshotSettings()
    local snap = {}
    for k, v in pairs(TomoGroupFrameDB) do
        if not EXCLUDED_KEYS[k] then snap[k] = DeepCopy(v) end
    end
    return snap
end

local function ApplySnapshot(snap)
    for k in pairs(TomoGroupFrameDB) do
        if not EXCLUDED_KEYS[k] then TomoGroupFrameDB[k] = nil end
    end
    for k, v in pairs(snap) do
        if not EXCLUDED_KEYS[k] then TomoGroupFrameDB[k] = DeepCopy(v) end
    end
    TGF_MergeTables(TomoGroupFrameDB, TGF_Defaults)
end

-- =====================================
-- DB INIT
-- =====================================

function P.EnsureProfilesDB()
    if not TomoGroupFrameDB._profiles then TomoGroupFrameDB._profiles = {} end
    local db = TomoGroupFrameDB._profiles

    if not db.named        then db.named        = {} end
    if not db.profileOrder then db.profileOrder = {} end
    if not db.specProfiles then db.specProfiles = {} end
    if not db.activeProfile then db.activeProfile = "Default" end

    if not db.named["Default"] then
        db.named["Default"] = SnapshotSettings()
    end

    local hasDefault = false
    for _, n in ipairs(db.profileOrder) do
        if n == "Default" then hasDefault = true; break end
    end
    if not hasDefault then
        table.insert(db.profileOrder, 1, "Default")
    end

    local inOrder = {}
    for _, n in ipairs(db.profileOrder) do inOrder[n] = true end
    for name in pairs(db.named) do
        if not inOrder[name] then
            table.insert(db.profileOrder, name)
        end
    end
end

-- =====================================
-- SPEC HELPERS
-- =====================================

function P.GetAllSpecs()
    local specs = {}
    local numSpecs = GetNumSpecializations and GetNumSpecializations() or 0
    for i = 1, numSpecs do
        local id, name, _, icon, role = GetSpecializationInfo(i)
        if id then
            table.insert(specs, { index = i, id = id, name = name, icon = icon, role = role })
        end
    end
    return specs
end

function P.GetCurrentSpecID()
    local idx = GetSpecialization and GetSpecialization()
    if not idx then return 0 end
    local id = GetSpecializationInfo(idx)
    return id or 0
end

-- =====================================
-- PROFILS NOMMÉS
-- =====================================

function P.GetActiveProfileName()
    P.EnsureProfilesDB()
    return TomoGroupFrameDB._profiles.activeProfile or "Default"
end

function P.GetProfileList()
    P.EnsureProfilesDB()
    return TomoGroupFrameDB._profiles.profileOrder, TomoGroupFrameDB._profiles.named
end

function P.AutoSaveActiveProfile()
    P.EnsureProfilesDB()
    local name = TomoGroupFrameDB._profiles.activeProfile or "Default"
    TomoGroupFrameDB._profiles.named[name] = SnapshotSettings()
end

function P.CreateNamedProfile(name)
    if not name or name:match("^%s*$") then return false, "Empty name" end
    name = name:match("^%s*(.-)%s*$")
    P.EnsureProfilesDB()
    local db = TomoGroupFrameDB._profiles

    P.AutoSaveActiveProfile()

    db.named[name] = SnapshotSettings()
    local found = false
    for _, n in ipairs(db.profileOrder) do
        if n == name then found = true; break end
    end
    if not found then
        table.insert(db.profileOrder, 2, name)
    end
    db.activeProfile = name
    return true
end

function P.LoadNamedProfile(name)
    P.EnsureProfilesDB()
    local db = TomoGroupFrameDB._profiles
    local snap = db.named[name]
    if not snap then return false end

    P.AutoSaveActiveProfile()
    ApplySnapshot(snap)
    db.activeProfile = name
    return true
end

function P.DeleteNamedProfile(name)
    if name == "Default" then return false end
    P.EnsureProfilesDB()
    local db = TomoGroupFrameDB._profiles
    db.named[name] = nil
    for i, n in ipairs(db.profileOrder) do
        if n == name then table.remove(db.profileOrder, i); break end
    end
    for specID, pName in pairs(db.specProfiles) do
        if pName == name then db.specProfiles[specID] = nil end
    end
    if db.activeProfile == name then
        db.activeProfile = "Default"
    end
    return true
end

function P.RenameProfile(oldName, newName)
    if oldName == "Default" then return false, "Cannot rename Default" end
    if not newName or newName:match("^%s*$") then return false, "Empty name" end
    newName = newName:match("^%s*(.-)%s*$")
    P.EnsureProfilesDB()
    local db = TomoGroupFrameDB._profiles
    if not db.named[oldName] then return false, "Profile not found" end
    if db.named[newName] then return false, "Name already exists" end

    db.named[newName] = db.named[oldName]
    db.named[oldName] = nil
    for i, n in ipairs(db.profileOrder) do
        if n == oldName then db.profileOrder[i] = newName; break end
    end
    for specID, pName in pairs(db.specProfiles) do
        if pName == oldName then db.specProfiles[specID] = newName end
    end
    if db.activeProfile == oldName then db.activeProfile = newName end
    return true
end

function P.DuplicateProfile(fromName, toName)
    if not toName or toName:match("^%s*$") then return false, "Empty name" end
    toName = toName:match("^%s*(.-)%s*$")
    P.EnsureProfilesDB()
    local db = TomoGroupFrameDB._profiles
    local snap = db.named[fromName]
    if not snap then return false, "Source profile not found" end
    if db.named[toName] then return false, "Name already exists" end

    db.named[toName] = DeepCopy(snap)
    local found = false
    for i, n in ipairs(db.profileOrder) do
        if n == fromName then
            table.insert(db.profileOrder, i + 1, toName)
            found = true; break
        end
    end
    if not found then table.insert(db.profileOrder, toName) end
    return true
end

-- =====================================
-- SPEC → PROFIL NOMMÉ
-- =====================================

function P.AssignSpecToProfile(specID, profileName)
    P.EnsureProfilesDB()
    local db = TomoGroupFrameDB._profiles
    if not db.named[profileName] then return false end
    db.specProfiles[specID] = profileName
    return true
end

function P.UnassignSpec(specID)
    P.EnsureProfilesDB()
    TomoGroupFrameDB._profiles.specProfiles[specID] = nil
end

function P.GetSpecAssignedProfile(specID)
    P.EnsureProfilesDB()
    return TomoGroupFrameDB._profiles.specProfiles[specID]
end

function P.IsSpecProfilesEnabled()
    P.EnsureProfilesDB()
    for _ in pairs(TomoGroupFrameDB._profiles.specProfiles) do return true end
    return false
end

function P.EnableSpecProfiles()
    P.EnsureProfilesDB()
    local specID = P.GetCurrentSpecID()
    local active = P.GetActiveProfileName()
    if specID > 0 then P.AssignSpecToProfile(specID, active) end
end

function P.DisableSpecProfiles()
    P.EnsureProfilesDB()
    TomoGroupFrameDB._profiles.specProfiles = {}
end

-- =====================================
-- SPEC CHANGE HANDLER
-- =====================================

function P.OnSpecChanged(newSpecID)
    P.EnsureProfilesDB()
    if not P.IsSpecProfilesEnabled() then return false end
    if not newSpecID or newSpecID == 0 then return false end

    local targetName = P.GetSpecAssignedProfile(newSpecID)
    if not targetName then return false end

    local currentName = P.GetActiveProfileName()
    if currentName == targetName then return false end

    P.AutoSaveActiveProfile()
    local ok = P.LoadNamedProfile(targetName)
    if ok then return true end
    return false
end

function P.InitSpecTracking()
    P._lastSpecID = P.GetCurrentSpecID()
end
