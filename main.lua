GAME_WIDTH = 800
GAME_HEIGHT = 600

STATE_PLAYING = 1
STATE_CARD_SELECT = 2
STATE_GAME_OVER = 3
STATE_VICTORY = 4

local font
local smallFont
local paddle, ball, bricks
local gameState, score, combo, stage
local cards, selectedCard
local brainrotLevel = 0
local scanlineOffset = 0
local shakeAmount = 0
local soundBonk, soundPunch, soundFah
local imgPaddle

function love.load()
    love.window.setTitle("Brainrot Arcade - Wireframe Prototype")
    love.window.setMode(GAME_WIDTH, GAME_HEIGHT)
    font = love.graphics.newFont(16)
    smallFont = love.graphics.newFont(12)
    soundBonk = love.audio.newSource("sounds/bonk.mp3", "static")
    soundPunch = love.audio.newSource("sounds/punch.mp3", "static")
    soundFah = love.audio.newSource("sounds/fah.mp3", "static")
    soundFah:setVolume(0.5)
    imgPaddle = love.graphics.newImage("assets/sahur.png")
    imgPaddle:setFilter("linear", "linear")
    local scale = 100 / imgPaddle:getWidth()
    imgScaled = love.graphics.newCanvas(100, imgPaddle:getHeight() * scale)
    love.graphics.setCanvas(imgScaled)
    love.graphics.draw(imgPaddle, 0, 0, 0, scale, scale)
    love.graphics.setCanvas()
    resetGame()
end

function resetGame()
    gameState = STATE_PLAYING
    score = 0
    combo = 0
    stage = 1
    brainrotLevel = 0
    cards = {}
    selectedCard = nil
    shakeAmount = 0

    paddle = {
        x = GAME_WIDTH / 2,
        y = GAME_HEIGHT - 40,
        width = 100,
        height = 15,
        speed = 400
    }
    if imgScaled then
        paddle.width = imgScaled:getWidth()
        paddle.height = imgScaled:getHeight()
    end

    ball = {
        x = GAME_WIDTH / 2,
        y = GAME_HEIGHT - 60,
        radius = 8,
        dx = 250,
        dy = -350,
        active = false
    }

    generateBricks()
end

function generateBricks()
    bricks = {}
    local rows = 4 + stage
    local cols = 8
    local brickWidth = (GAME_WIDTH - 40) / cols
    local brickHeight = 20

    for row = 1, rows do
        for col = 1, cols do
            if math.random() > 0.2 then
                table.insert(bricks, {
                    x = 20 + (col - 1) * brickWidth,
                    y = 50 + (row - 1) * brickHeight,
                    width = brickWidth - 2,
                    height = brickHeight - 2,
                    hp = row,
                    active = true
                })
            end
        end
    end
end

function generateCards()
    local cardPool = {
        { name = "MULTIBALL", desc = "Balls duplicate after 10 combo", effect = "multiball" },
        { name = "TINY PADDLE", desc = "Paddle 50% smaller but 3x score", effect = "tinyPaddle" },
        { name = "EXPLODING BRICKS", desc = "Bricks infect neighbors on death", effect = "exploding" },
        { name = "GHOST BALL", desc = "Balls pass through bricks once", effect = "ghostBall" },
        { name = "COMBO MAGNET", desc = "Combo builds 2x faster", effect = "comboMagnet" },
        { name = "GLITCH PADDLE", desc = "Paddle teleports randomly", effect = "glitchPaddle" },
    }

    cards = {}
    for i = 1, 3 do
        local card = cardPool[math.random(#cardPool)]
        table.insert(cards, {
            name = card.name,
            desc = card.desc,
            effect = card.effect
        })
    end
end

function love.update(dt)
    scanlineOffset = (scanlineOffset + dt * 50) % 4

    if shakeAmount > 0 then
        shakeAmount = math.max(0, shakeAmount - dt * 10)
    end

    if gameState == STATE_PLAYING then
        updateGame(dt)
    end
end

function updateGame(dt)
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        paddle.x = paddle.x + paddle.speed * dt
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        paddle.x = paddle.x - paddle.speed * dt
    end

    paddle.x = math.max(paddle.width / 2, math.min(GAME_WIDTH - paddle.width / 2, paddle.x))

    if not ball.active then
        if love.keyboard.isDown("space") or love.keyboard.isDown("return") then
            ball.active = true
            ball.dy = -350
            ball.dx = (math.random() - 0.5) * 200
        end
    else
        ball.x = ball.x + ball.dx * dt
        ball.y = ball.y + ball.dy * dt

        if ball.x - ball.radius < 0 or ball.x + ball.radius > GAME_WIDTH then
            ball.dx = -ball.dx
            ball.x = math.max(ball.radius, math.min(GAME_WIDTH - ball.radius, ball.x))
        end

        if ball.y - ball.radius < 0 then
            ball.dy = -ball.dy
            ball.y = ball.radius
        end

        if ball.y + ball.radius > paddle.y and
           ball.y - ball.radius < paddle.y + paddle.height and
           ball.x > paddle.x - paddle.width / 2 and
           ball.x < paddle.x + paddle.width / 2 then
            ball.dy = -math.abs(ball.dy)
            ball.y = paddle.y - ball.radius
            local hitPos = (ball.x - paddle.x) / (paddle.width / 2)
            ball.dx = hitPos * 300
            combo = combo + 1
            shakeAmount = 3
        end

        if ball.y > GAME_HEIGHT + 50 then
            if combo > 0 then
                ball.active = false
                ball.x = paddle.x
                ball.y = paddle.y - 30
                combo = 0
            else
                gameState = STATE_GAME_OVER
                if soundFah then soundFah:clone():play() end
            end
        end

        for i = #bricks, 1, -1 do
            local b = bricks[i]
            if b.active and
               ball.x + ball.radius > b.x and
               ball.x - ball.radius < b.x + b.width and
               ball.y + ball.radius > b.y and
               ball.y - ball.radius < b.y + b.height then

                local overlapLeft = (ball.x + ball.radius) - b.x
                local overlapRight = (b.x + b.width) - (ball.x - ball.radius)
                local overlapTop = (ball.y + ball.radius) - b.y
                local overlapBottom = (b.y + b.height) - (ball.y - ball.radius)

                local minOverlapX = math.min(overlapLeft, overlapRight)
                local minOverlapY = math.min(overlapTop, overlapBottom)

                if minOverlapX < minOverlapY then
                    ball.dx = -ball.dx
                else
                    ball.dy = -ball.dy
                end

                b.hp = b.hp - 1
                if b.hp <= 0 then
                    b.active = false
                    score = score + 100 * (1 + combo * 0.1)
                    shakeAmount = 5
                    if soundPunch then soundPunch:clone():play() end
                else
                    if soundBonk then soundBonk:clone():play() end
                end
                break
            end
        end

        local activeBricks = 0
        for _, b in ipairs(bricks) do
            if b.active then activeBricks = activeBricks + 1 end
        end

        if activeBricks == 0 then
            brainrotLevel = brainrotLevel + 1
            if stage >= 3 then
                gameState = STATE_VICTORY
            else
                stage = stage + 1
                generateCards()
                gameState = STATE_CARD_SELECT
            end
        end
    end
end

function love.keypressed(key)
    if gameState == STATE_CARD_SELECT then
        if key == "1" or key == "2" or key == "3" then
            local idx = tonumber(key)
            if cards[idx] then
                applyCard(cards[idx])
                ball.active = false
                ball.x = paddle.x
                ball.y = paddle.y - 30
                generateBricks()
                gameState = STATE_PLAYING
            end
        end
    elseif gameState == STATE_GAME_OVER or gameState == STATE_VICTORY then
        if key == "r" or key == "return" then
            resetGame()
        end
    end
end

function applyCard(card)
    if card.effect == "tinyPaddle" then
        paddle.width = paddle.width * 0.5
        score = score * 3
    elseif card.effect == "comboMagnet" then
        combo = combo + 5
    elseif card.effect == "glitchPaddle" then
        paddle.x = math.random(paddle.width, GAME_WIDTH - paddle.width)
    end
    score = score + 500
end

function love.draw()
    love.graphics.push()
    if shakeAmount > 0 then
        local shakeX = (math.random() - 0.5) * shakeAmount * 2
        local shakeY = (math.random() - 0.5) * shakeAmount * 2
        love.graphics.translate(shakeX, shakeY)
    end

    if gameState == STATE_PLAYING then
        drawGame()
    elseif gameState == STATE_CARD_SELECT then
        drawCards()
    elseif gameState == STATE_GAME_OVER then
        drawGameOver()
    elseif gameState == STATE_VICTORY then
        drawVictory()
    end

    love.graphics.pop()
    drawScanlines()
end

function drawGame()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(font)
    love.graphics.print("SCORE: " .. math.floor(score), 20, 20)
    love.graphics.print("COMBO: " .. combo, 20, 40)
    love.graphics.print("STAGE: " .. stage, GAME_WIDTH - 100, 20)
    love.graphics.print("BRAINROT: " .. brainrotLevel, GAME_WIDTH - 150, 40)

    love.graphics.setColor(1, 1, 1)
    if imgScaled then
        love.graphics.draw(imgScaled, paddle.x - paddle.width / 2, paddle.y)
    else
        love.graphics.setColor(0.3, 0.8, 1)
        love.graphics.rectangle("fill", paddle.x - paddle.width / 2, paddle.y, paddle.width, paddle.height)
    end

    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)

    for _, b in ipairs(bricks) do
        if b.active then
            local hue = (b.hp / 5)
            love.graphics.setColor(1 - hue * 0.5, 0.3 + hue * 0.5, 0.5)
            love.graphics.rectangle("fill", b.x, b.y, b.width, b.height)
            love.graphics.setColor(1, 1, 1, 0.5)
            love.graphics.rectangle("line", b.x, b.y, b.width, b.height)
        end
    end

    if not ball.active then
        love.graphics.setFont(font)
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.printf("PRESS SPACE TO LAUNCH", 0, GAME_HEIGHT / 2 - 20, GAME_WIDTH, "center")
    end
end

function drawCards()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 0.3)
    love.graphics.printf("=== STAGE COMPLETE ===", 0, 50, GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Choose a modifier card:", 0, 90, GAME_WIDTH, "center")

    for i, card in ipairs(cards) do
        local y = 150 + (i - 1) * 120

        love.graphics.setColor(0.2, 0.4, 0.6)
        love.graphics.rectangle("fill", GAME_WIDTH / 2 - 150, y, 300, 100)
        love.graphics.setColor(0.5, 0.7, 1)
        love.graphics.rectangle("line", GAME_WIDTH / 2 - 150, y, 300, 100)

        love.graphics.setColor(1, 1, 0.8)
        love.graphics.setFont(font)
        love.graphics.print("[" .. i .. "] " .. card.name, GAME_WIDTH / 2 - 130, y + 15)

        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.setFont(smallFont)
        love.graphics.print(card.desc, GAME_WIDTH / 2 - 130, y + 45)
    end
end

function drawGameOver()
    love.graphics.setBackgroundColor(0.2, 0.05, 0.05)
    love.graphics.setFont(font)
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("=== GAME OVER ===", 0, GAME_HEIGHT / 2 - 40, GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. math.floor(score), 0, GAME_HEIGHT / 2, GAME_WIDTH, "center")
    love.graphics.printf("Stage Reached: " .. stage, 0, GAME_HEIGHT / 2 + 30, GAME_WIDTH, "center")
    love.graphics.printf("Press R to restart", 0, GAME_HEIGHT / 2 + 80, GAME_WIDTH, "center")
end

function drawVictory()
    love.graphics.setBackgroundColor(0.1, 0.1, 0.3)
    love.graphics.setFont(font)
    love.graphics.setColor(0.3, 1, 0.5)
    love.graphics.printf("=== VICTORY ===", 0, GAME_HEIGHT / 2 - 40, GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. math.floor(score), 0, GAME_HEIGHT / 2, GAME_WIDTH, "center")
    love.graphics.printf("You survived the brainrot!", 0, GAME_HEIGHT / 2 + 40, GAME_WIDTH, "center")
    love.graphics.printf("Press R to play again", 0, GAME_HEIGHT / 2 + 80, GAME_WIDTH, "center")
end

function drawScanlines()
    love.graphics.setColor(0, 0, 0, 0.1)
    for y = scanlineOffset, GAME_HEIGHT, 4 do
        love.graphics.rectangle("fill", 0, y, GAME_WIDTH, 2)
    end

    if brainrotLevel > 0 then
        love.graphics.setColor(1, 0, 0, 0.02 * brainrotLevel)
        love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, GAME_HEIGHT)
    end

    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, 3, GAME_HEIGHT)
    love.graphics.rectangle("fill", GAME_WIDTH - 3, 0, 3, GAME_HEIGHT)
    love.graphics.rectangle("fill", 0, 0, GAME_WIDTH, 3)
    love.graphics.rectangle("fill", 0, GAME_HEIGHT - 3, GAME_WIDTH, 3)
end