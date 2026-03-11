-- TomoPartyFrame Utils
-- Shared utility functions

local ADDON, ns = ...

-- Deep copy helper
function ns.DeepCopy(orig)
    local copy
    if type(orig) == "table" then
        copy = {}
        for k, v in pairs(orig) do
            copy[k] = ns.DeepCopy(v)
        end
    else
        copy = orig
    end
    return copy
end

-- Recursive merge: adds missing keys without overwriting
function ns.DeepMerge(target, source)
    for k, v in pairs(source) do
        if target[k] == nil then
            target[k] = ns.DeepCopy(v)
        elseif type(v) == "table" and type(target[k]) == "table" then
            ns.DeepMerge(target[k], v)
        end
    end
end
