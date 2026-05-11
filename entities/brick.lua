-- Brick entity — dark gothic grunge style with meme names
local Config = require("config")
local Brick = {}

Brick.MEME_NAMES = {
    "SKIBIDI", "RIZZ GOD", "OHIO", "FANUM TAX", "GYATT",
    "SUS", "NO CAP", "BASED", "MID", "CRINGE",
    "MEWING", "NPC", "DELULU", "SIGMA", "W EDIT",
    "FAX", "VALID", "COPE", "L BOZO", "SLAY",
    "OP", "GOATED", "BUSSIN", "YEET", "RATIO",
}

function Brick.new(x, y, width, height, hp, colorIdx, nameIdx)
    return {
        x = x, y = y, width = width, height = height,
        hp = hp, maxHp = hp, active = true,
        colorIdx = colorIdx or 1, hitFlash = 0,
        name = Brick.MEME_NAMES[nameIdx or math.random(#Brick.MEME_NAMES)],
    }
end

function Brick.generateGrid(stage)
    local bricks = {}
    local rows = Config.BRICK_BASE_ROWS + stage
    local cols = Config.BRICK_COLS
    local totalW = Config.GAME_WIDTH - Config.BRICK_MARGIN_LEFT - Config.BRICK_MARGIN_RIGHT
    local brickW = totalW / cols
    local nc = 1

    for row = 1, rows do
        for col = 1, cols do
            if math.random() < Config.BRICK_SPAWN_CHANCE then
                local ci = ((row - 1) % #Config.BRICK_COLORS) + 1
                table.insert(bricks, Brick.new(
                    Config.BRICK_MARGIN_LEFT + (col - 1) * brickW,
                    Config.BRICK_TOP_OFFSET + (row - 1) * Config.BRICK_HEIGHT,
                    brickW - Config.BRICK_GAP,
                    Config.BRICK_HEIGHT - Config.BRICK_GAP,
                    row, ci, nc
                ))
                nc = (nc % #Brick.MEME_NAMES) + 1
            end
        end
    end
    return bricks
end

function Brick.countActive(bricks)
    local n = 0
    for _, b in ipairs(bricks) do if b.active then n = n + 1 end end
    return n
end

function Brick.updateAll(bricks, dt)
    for _, b in ipairs(bricks) do
        if b.hitFlash and b.hitFlash > 0 then 
            b.hitFlash = math.max(0, b.hitFlash - dt * 6) 
        end
    end
end

function Brick.draw(brick, font)
    if not brick.active then return end
    local c = Config.BRICK_COLORS[brick.colorIdx] or {0.5, 0.3, 0.3}
    local hpRatio = brick.hp / brick.maxHp
    local dim = 0.55 + 0.45 * hpRatio

    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", brick.x + 2, brick.y + 2,
                            brick.width, brick.height, 3, 3)

    -- Dark grunge body
    love.graphics.setColor(c[1]*dim*0.5, c[2]*dim*0.5, c[3]*dim*0.5)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height, 3, 3)

    -- Lighter top half (worn metal look)
    love.graphics.setColor(c[1]*dim*0.8, c[2]*dim*0.8, c[3]*dim*0.8)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height * 0.5, 3, 0)

    -- Hit flash
    if brick.hitFlash > 0 then
        love.graphics.setColor(1, 0.8, 0.6, brick.hitFlash * 0.7)
        love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height, 3, 3)
    end

    -- Meme name
    if font and brick.width > 40 then
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 1, 0.75 * dim)
        local tw = font:getWidth(brick.name)
        local th = font:getHeight()
        local sc = math.min(1, (brick.width - 8) / math.max(tw, 1))
        love.graphics.print(brick.name,
            brick.x + brick.width/2 - (tw*sc)/2,
            brick.y + brick.height/2 - (th*sc)/2, 0, sc, sc)
    end

    -- Border (dark, subtle)
    love.graphics.setColor(c[1]*0.3, c[2]*0.3, c[3]*0.3, 0.8 * dim)
    love.graphics.rectangle("line", brick.x, brick.y, brick.width, brick.height, 3, 3)

    -- Heavy industrial frame and bolts inspired by the reference block sheet.
    love.graphics.setColor(0.02, 0.018, 0.016, 0.9)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", brick.x + 1, brick.y + 1, brick.width - 2, brick.height - 2, 3, 3)
    love.graphics.setLineWidth(1)

    local boltR = math.max(2, math.min(4, brick.height * 0.12))
    local bx1, bx2 = brick.x + 8, brick.x + brick.width - 8
    local by1, by2 = brick.y + 7, brick.y + brick.height - 7
    love.graphics.setColor(0.02, 0.015, 0.012, 0.95)
    love.graphics.circle("fill", bx1, by1, boltR)
    love.graphics.circle("fill", bx2, by1, boltR)
    love.graphics.circle("fill", bx1, by2, boltR)
    love.graphics.circle("fill", bx2, by2, boltR)
    love.graphics.setColor(0.55, 0.48, 0.40, 0.35 * dim)
    love.graphics.circle("line", bx1, by1, boltR)
    love.graphics.circle("line", bx2, by1, boltR)
    love.graphics.circle("line", bx1, by2, boltR)
    love.graphics.circle("line", bx2, by2, boltR)

    love.graphics.setColor(0, 0, 0, 0.18)
    local crackSeed = brick.colorIdx * 13 + brick.maxHp * 7
    for i = 1, 3 do
        local x1 = brick.x + ((crackSeed + i * 19) % 80) / 80 * brick.width
        local y1 = brick.y + 6 + ((crackSeed + i * 11) % 20)
        love.graphics.line(x1, y1, x1 + 12, y1 + ((i % 2 == 0) and -5 or 5))
    end
end

return Brick
