-- Paddle entity
local Config = require("config")
local Paddle = {}

function Paddle.new(paddleImage)
    local p = {
        x      = Config.GAME_WIDTH / 2,
        y      = Config.GAME_HEIGHT - Config.PADDLE_Y_OFFSET,
        width  = Config.PADDLE_DEFAULT_WIDTH,
        height = Config.PADDLE_HEIGHT,
        speed  = Config.PADDLE_SPEED,
        image  = paddleImage,
    }
    if paddleImage then
        p.width  = paddleImage:getWidth()
        p.height = paddleImage:getHeight()
    end
    return p
end

function Paddle.reset(paddle)
    paddle.x = Config.GAME_WIDTH / 2
end

function Paddle.update(paddle, dt)
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        paddle.x = paddle.x + paddle.speed * dt
    end
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        paddle.x = paddle.x - paddle.speed * dt
    end
    paddle.x = math.max(paddle.width / 2, math.min(Config.GAME_WIDTH - paddle.width / 2, paddle.x))
end

function Paddle.draw(paddle)
    love.graphics.setColor(1, 1, 1)
    if paddle.image then
        love.graphics.draw(paddle.image, paddle.x - paddle.width / 2, paddle.y)
    else
        love.graphics.setColor(0.3, 0.8, 1)
        love.graphics.rectangle("fill", paddle.x - paddle.width / 2, paddle.y,
                                paddle.width, paddle.height)
    end
end

return Paddle
