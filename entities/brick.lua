-- Brick entity + grid generation
local Config = require("config")
local Brick = {}

function Brick.new(x, y, width, height, hp)
    return {
        x      = x,
        y      = y,
        width  = width,
        height = height,
        hp     = hp,
        maxHp  = hp,
        active = true,
    }
end

function Brick.generateGrid(stage)
    local bricks = {}
    local rows = Config.BRICK_BASE_ROWS + stage
    local cols = Config.BRICK_COLS
    local brickW = (Config.GAME_WIDTH - Config.BRICK_MARGIN) / cols

    for row = 1, rows do
        for col = 1, cols do
            if math.random() < Config.BRICK_SPAWN_CHANCE then
                table.insert(bricks, Brick.new(
                    (Config.BRICK_MARGIN / 2) + (col - 1) * brickW,
                    Config.BRICK_TOP_OFFSET + (row - 1) * Config.BRICK_HEIGHT,
                    brickW - Config.BRICK_GAP,
                    Config.BRICK_HEIGHT - Config.BRICK_GAP,
                    row
                ))
            end
        end
    end
    return bricks
end

function Brick.countActive(bricks)
    local n = 0
    for _, b in ipairs(bricks) do
        if b.active then n = n + 1 end
    end
    return n
end

function Brick.draw(brick)
    if not brick.active then return end
    local hue = brick.hp / 5
    love.graphics.setColor(1 - hue * 0.5, 0.3 + hue * 0.5, 0.5)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height)
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.rectangle("line", brick.x, brick.y, brick.width, brick.height)
end

return Brick
