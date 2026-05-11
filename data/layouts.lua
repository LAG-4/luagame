-- Stage-specific brick layouts — Phase 6
local Config = require("config")
local Layouts = {}

local function brickPattern(rows, cols, builder)
    local result = {}
    for row = 1, rows do
        for col = 1, cols do
            local b = builder(row, col, rows, cols)
            if b then table.insert(result, b) end
        end
    end
    return result
end

local function pos(col, row)
    local cellW = (Config.GAME_WIDTH - Config.BRICK_MARGIN_LEFT - Config.BRICK_MARGIN_RIGHT) / Config.BRICK_COLS
    local cellH = Config.BRICK_HEIGHT
    return {
        x = Config.BRICK_MARGIN_LEFT + (col - 1) * (cellW + Config.BRICK_GAP),
        y = Config.BRICK_TOP_OFFSET + (row - 1) * (cellH + Config.BRICK_GAP),
        w = cellW - Config.BRICK_GAP,
        h = cellH - Config.BRICK_GAP,
    }
end

Layouts.patterns = {
    -- Stage 1: Classic grid
    function()
        return brickPattern(4, 10, function(r, c)
            local p = pos(c, r)
            return {x = p.x, y = p.y, w = p.w, h = p.h, hp = 1, active = true}
        end)
    end,

    -- Stage 2: Checkerboard
    function()
        return brickPattern(5, 10, function(r, c)
            if (r + c) % 2 == 0 then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = 1, active = true}
            end
        end)
    end,

    -- Stage 3: Pyramids
    function()
        return brickPattern(6, 10, function(r, c)
            local left = 5 - math.floor(r / 2)
            local right = 5 + math.ceil(r / 2)
            if c >= left and c <= right then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = 1, active = true}
            end
        end)
    end,

    -- Stage 4: Hollow square
    function()
        return brickPattern(6, 10, function(r, c)
            if r == 1 or r == 6 or c == 1 or c == 10 then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = 1, active = true}
            end
        end)
    end,

    -- Stage 5: Diamond
    function()
        return brickPattern(8, 10, function(r, c)
            local midR, midC = 4.5, 5.5
            local dr = math.abs(r - midR)
            local dc = math.abs(c - midC)
            if dr + dc <= 5 then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = 1, active = true}
            end
        end)
    end,

    -- Stage 6: Columns with gaps
    function()
        return brickPattern(6, 10, function(r, c)
            if c % 3 ~= 0 then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = (r > 4) and 2 or 1, active = true}
            end
        end)
    end,

    -- Stage 7: Spiral
    function()
        return brickPattern(7, 10, function(r, c)
            local dist = math.min(r - 1, 8 - r, c - 1, 11 - c)
            if dist <= 2 then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = dist + 1, active = true}
            end
        end)
    end,

    -- Stage 8: X shape
    function()
        return brickPattern(8, 10, function(r, c)
            local dr = math.abs(r - 4.5)
            local dc = math.abs(c - 5.5)
            if math.abs(dr - dc) < 1.5 then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = (dr < 1) and 2 or 1, active = true}
            end
        end)
    end,

    -- Stage 9: Fortress (walls + pillars)
    function()
        return brickPattern(7, 10, function(r, c)
            local isWall = (c == 1 or c == 10 or c == 5 or c == 6)
            local isTop = (r == 1)
            if isWall or isTop then
                local p = pos(c, r)
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = isWall and 2 or 1, active = true}
            end
        end)
    end,

    -- Stage 10: Skull pattern
    function()
        return brickPattern(7, 10, function(r, c)
            local p = pos(c, r)
            local isSkull = false

            -- Skull outline
            local inBounds = (r >= 2 and r <= 7 and c >= 2 and c <= 9)

            -- Eyes
            if (r == 4 or r == 5) and (c == 3 or c == 8) then isSkull = false
            -- Skull shape
            elseif r == 2 and c >= 3 and c <= 8 then isSkull = true
            elseif r == 3 and (c == 2 or c == 9) then isSkull = true
            elseif r >= 4 and r <= 6 and (c == 2 or c == 9) then isSkull = true
            elseif r == 7 and c >= 2 and c <= 9 then isSkull = true
            else isSkull = false
            end

            if inBounds then
                return {x = p.x, y = p.y, w = p.w, h = p.h, hp = (r <= 3) and 2 or 1, active = true}
            end
        end)
    end,
}

-- Stage score targets (bonus for clearing above this)
Layouts.scoreTargets = {
    1000, 2000, 3500, 5000, 7000, 9000, 12000, 15000, 18000, 22000
}

function Layouts.get(stageNum)
    local idx = ((stageNum - 1) % #Layouts.patterns) + 1
    return Layouts.patterns[idx]()
end

function Layouts.getTarget(stageNum)
    if stageNum <= #Layouts.scoreTargets then
        return Layouts.scoreTargets[stageNum]
    end
    return Layouts.scoreTargets[#Layouts.scoreTargets] + (stageNum - #Layouts.scoreTargets) * 5000
end

return Layouts