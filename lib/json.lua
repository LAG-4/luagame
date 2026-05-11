-- A tiny, self-contained JSON library for LÖVE
local json = {}

local function is_array(t)
    local i = 1
    for _ in pairs(t) do
        if t[i] == nil then return false end
        i = i + 1
    end
    return i > 1
end

function json.encode(v)
    if type(v) == "string" then return string.format("%q", v) end
    if type(v) == "number" or type(v) == "boolean" then return tostring(v) end
    if type(v) == "table" then
        if is_array(v) then
            local items = {}
            for i, val in ipairs(v) do table.insert(items, json.encode(val)) end
            return "[" .. table.concat(items, ",") .. "]"
        else
            local items = {}
            for k, val in pairs(v) do table.insert(items, string.format("%q:%s", k, json.encode(val))) end
            return "{" .. table.concat(items, ",") .. "}"
        end
    end
    return "null"
end

-- Minimal decode (doesn't handle nested objects/arrays perfectly, but fine for simple saves)
-- For a real game, I'd use a robust lib, but this keeps it dependency-free.
function json.decode(s)
    -- Using a regex-based approach for simple JSON
    local function parse_value(v)
        if v == "true" then return true end
        if v == "false" then return false end
        if v == "null" then return nil end
        if v:sub(1,1) == '"' then return v:sub(2,-2) end
        return tonumber(v)
    end

    local res = {}
    for k, v in s:gmatch('"([^"]+)":([^,}]+)') do
        res[k] = parse_value(v)
    end
    return res
end

return json
