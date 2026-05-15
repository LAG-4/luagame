-- Brick entity — dark gothic grunge style with meme names
local Config = require("config")
local Brick = {}

Brick.MEME_NAMES = {
    "SKIBIDI", "RIZZ GOD", "OHIO", "FANUM TAX", "GYATT",
    "SUS", "NO CAP", "BASED", "MID", "CRINGE",
    "MEWING", "NPC", "DELULU", "SIGMA", "W EDIT",
    "FAX", "TUNG TUNG TUNG SAHUR", "COPE", "L BOZO", "SLAY",
    "OP", "GOATED", "BUSSIN", "YEET", "RATIO",
}

Brick.TIERS = {
    green = {hp = 1, color = {0.16, 0.54, 0.18}},
    yellow = {hp = 2, color = {0.66, 0.48, 0.12}},
    red = {hp = 4, color = {0.64, 0.08, 0.06}},
}

local function tierFromColorIdx(colorIdx)
    local cycle = ((colorIdx or 1) - 1) % 3
    if cycle == 0 then return "red" end
    if cycle == 1 then return "yellow" end
    return "green"
end

function Brick.tierForRow(row, rows)
    local ratio = row / math.max(rows or row, 1)
    if ratio <= 0.34 then return "red" end
    if ratio <= 0.72 then return "yellow" end
    return "green"
end

function Brick.new(x, y, width, height, hp, colorIdx, nameIdx, tier)
    tier = tier or tierFromColorIdx(colorIdx)
    local baseHp = hp or Brick.TIERS[tier].hp
    return {
        x = x, y = y, width = width, height = height,
        hp = baseHp, maxHp = baseHp, active = true,
        colorIdx = colorIdx or 1, hitFlash = 0,
        tier = tier,
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
                local tier = Brick.tierForRow(row, rows)
                local ci = tier == "red" and 1 or (tier == "yellow" and 2 or 3)
                table.insert(bricks, Brick.new(
                    Config.BRICK_MARGIN_LEFT + (col - 1) * brickW,
                    Config.BRICK_TOP_OFFSET + (row - 1) * Config.BRICK_HEIGHT,
                    brickW - Config.BRICK_GAP,
                    Config.BRICK_HEIGHT - Config.BRICK_GAP,
                    nil, ci, nc, tier
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
    local hpRatio = brick.hp / math.max(brick.maxHp, 1)
    local damage = 1 - hpRatio
    local tierColor = Brick.TIERS[brick.tier] and Brick.TIERS[brick.tier].color
    local weakColor = Brick.TIERS.green.color
    local c = tierColor or (Config.BRICK_COLORS[brick.colorIdx] or {0.5, 0.3, 0.3})
    if brick.tier ~= "green" then
        c = {
            c[1] * (1 - damage * 0.58) + weakColor[1] * damage * 0.58,
            c[2] * (1 - damage * 0.58) + weakColor[2] * damage * 0.58,
            c[3] * (1 - damage * 0.58) + weakColor[3] * damage * 0.58,
        }
    end
    local dim = 0.62 + 0.38 * hpRatio

    love.graphics.setColor(0, 0, 0, 0.84)
    love.graphics.rectangle("fill", brick.x + 3, brick.y + 4, brick.width, brick.height, 1, 1)

    love.graphics.setColor(c[1] * dim * 0.36, c[2] * dim * 0.32, c[3] * dim * 0.28, 1)
    love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height, 1, 1)

    love.graphics.setColor(c[1] * dim * 0.72, c[2] * dim * 0.62, c[3] * dim * 0.46, 0.85)
    love.graphics.rectangle("fill", brick.x + 3, brick.y + 3, brick.width - 6, 4)
    love.graphics.setColor(c[1] * dim * 0.22, c[2] * dim * 0.18, c[3] * dim * 0.15, 0.9)
    love.graphics.rectangle("fill", brick.x + 3, brick.y + brick.height - 6, brick.width - 6, 3)

    love.graphics.setColor(0.015, 0.012, 0.01, 0.86)
    love.graphics.rectangle("fill", brick.x + 7, brick.y + 8, brick.width - 14, brick.height - 14, 1, 1)

    love.graphics.setColor(c[1] * dim * 0.30, c[2] * dim * 0.22, c[3] * dim * 0.16, 0.42)
    love.graphics.polygon("fill",
        brick.x + 8, brick.y + brick.height - 8,
        brick.x + brick.width - 8, brick.y + brick.height - 8,
        brick.x + brick.width - 18, brick.y + 9,
        brick.x + 18, brick.y + 9)

    if brick.hitFlash > 0 then
        love.graphics.setColor(1, 0.8, 0.6, brick.hitFlash * 0.7)
        love.graphics.rectangle("fill", brick.x, brick.y, brick.width, brick.height, 1, 1)
    end

    if font and brick.width > 40 then
        love.graphics.setFont(font)
        local tw = font:getWidth(brick.name)
        local th = font:getHeight()
        local sc = math.min(1, (brick.width - 12) / math.max(tw, 1))
        local tx = brick.x + brick.width/2 - (tw*sc)/2
        local ty = brick.y + brick.height/2 - (th*sc)/2
        
        love.graphics.setColor(0, 0, 0, 0.9)
        love.graphics.print(brick.name, tx + 2, ty + 2, 0, sc, sc)
        love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.92 * dim)
        love.graphics.print(brick.name, tx, ty, 0, sc, sc)
    end

    love.graphics.setColor(0, 0, 0, 0.40 + damage * 0.30)
    love.graphics.setLineWidth(1)
    local crackSeed = brick.colorIdx * 13 + brick.maxHp * 7
    for i = 1, 2 + (brick.maxHp - brick.hp) * 2 do
        local cx = brick.x + 6 + ((crackSeed + i * 29) % (brick.width - 12))
        local cy = brick.y + 6 + ((crackSeed + i * 17) % (brick.height - 12))
        love.graphics.line(cx, cy, cx + 5 + damage * 6, cy + 5)
    end

    if brick.maxHp > 1 then
        love.graphics.setColor(0, 0, 0, 0.72)
        love.graphics.rectangle("fill", brick.x + 10, brick.y + brick.height - 7, brick.width - 20, 2)
        local barColor = brick.tier == "red" and Brick.TIERS.red.color or Brick.TIERS.yellow.color
        love.graphics.setColor(barColor[1], barColor[2], barColor[3], 0.85)
        love.graphics.rectangle("fill", brick.x + 10, brick.y + brick.height - 7, (brick.width - 20) * hpRatio, 2)
    end
end

return Brick
