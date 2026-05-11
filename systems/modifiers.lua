-- Active modifier tracking — cards add effects here, game systems query them
local Modifiers = {}
Modifiers.__index = Modifiers

function Modifiers.new()
    return setmetatable({ _effects = {} }, Modifiers)
end

-- Add a modifier effect (string key). Duplicates are allowed (stacking).
function Modifiers:add(effect)
    table.insert(self._effects, effect)
end

-- Check if a modifier is active (at least one instance)
function Modifiers:has(effect)
    for _, e in ipairs(self._effects) do
        if e == effect then return true end
    end
    return false
end

-- Count how many times a modifier has been stacked
function Modifiers:count(effect)
    local n = 0
    for _, e in ipairs(self._effects) do
        if e == effect then n = n + 1 end
    end
    return n
end

-- Get all active effects (list of strings, may have duplicates)
function Modifiers:getAll()
    return self._effects
end

-- Get unique effect names
function Modifiers:getUnique()
    local seen, list = {}, {}
    for _, e in ipairs(self._effects) do
        if not seen[e] then
            seen[e] = true
            table.insert(list, e)
        end
    end
    return list
end

-- Remove all instances of an effect
function Modifiers:remove(effect)
    for i = #self._effects, 1, -1 do
        if self._effects[i] == effect then
            table.remove(self._effects, i)
        end
    end
end

-- Clear all modifiers (new run)
function Modifiers:clear()
    self._effects = {}
end

return Modifiers
