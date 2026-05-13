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
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", brick.x + 4, brick.y + 4, brick.width, brick.height, 2, 2)

    -- Base Stone
    love.graphics.setColor(c[1]*dim*0.4, c[2]*dim*0.4, c[3]*dim*0.4)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height, 2, 2)

    -- Top/Left bevel (lighter)
    love.graphics.setColor(c[1]*dim*0.6, c[2]*dim*0.6, c[3]*dim*0.6)
    love.graphics.polygon("fill", brick.x, brick.y, brick.x + brick.width, brick.y, brick.x + brick.width - 4, brick.y + 4, brick.x + 4, brick.y + 4)
    love.graphics.polygon("fill", brick.x, brick.y, brick.x + 4, brick.y + 4, brick.x + 4, brick.y + brick.height - 4, brick.x, brick.y + brick.height)

    -- Bottom/Right bevel (darker)
    love.graphics.setColor(c[1]*dim*0.2, c[2]*dim*0.2, c[3]*dim*0.2)
    love.graphics.polygon("fill", brick.x, brick.y + brick.height, brick.x + brick.width, brick.y + brick.height, brick.x + brick.width - 4, brick.y + brick.height - 4, brick.x + 4, brick.y + brick.height - 4)
    love.graphics.polygon("fill", brick.x + brick.width, brick.y, brick.x + brick.width - 4, brick.y + 4, brick.x + brick.width - 4, brick.y + brick.height - 4, brick.x + brick.width, brick.y + brick.height)

    -- Inner dark area
    love.graphics.setColor(0.04, 0.03, 0.02, 0.85)
    love.graphics.rectangle("fill", brick.x + 4, brick.y + 4, brick.width - 8, brick.height - 8, 1, 1)

    -- Hit flash
    if brick.hitFlash > 0 then
        love.graphics.setColor(1, 0.8, 0.6, brick.hitFlash * 0.7)
        love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height, 2, 2)
    end

    -- Meme name with shadow (embossed look)
    if font and brick.width > 40 then
        love.graphics.setFont(font)
        local tw = font:getWidth(brick.name)
        local th = font:getHeight()
        local sc = math.min(1, (brick.width - 12) / math.max(tw, 1))
        local tx = brick.x + brick.width/2 - (tw*sc)/2
        local ty = brick.y + brick.height/2 - (th*sc)/2
        
        -- Text shadow
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.print(brick.name, tx + 2, ty + 2, 0, sc, sc)
        -- Text color
        love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.85 * dim)
        love.graphics.print(brick.name, tx, ty, 0, sc, sc)
    end

    -- Scratches/Cracks
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.setLineWidth(1)
    local crackSeed = brick.colorIdx * 13 + brick.maxHp * 7
    for i = 1, 2 + (brick.maxHp - brick.hp) do
        local cx = brick.x + 6 + ((crackSeed + i * 29) % (brick.width - 12))
        local cy = brick.y + 6 + ((crackSeed + i * 17) % (brick.height - 12))
        love.graphics.line(cx, cy, cx + 5, cy + 5)
    end
end

return Brick
