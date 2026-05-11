-- Paddle entity — bronze gothic style
local Config = require("config")
local Paddle = {}

function Paddle.new(paddleImage)
    local p = {
        x = (Config.PLAY_AREA_LEFT + Config.GAME_WIDTH) / 2,
        y = Config.PADDLE_Y,
        width = Config.PADDLE_DEFAULT_WIDTH,
        height = Config.PADDLE_HEIGHT,
        speed = Config.PADDLE_SPEED,
        image = paddleImage,
    }
    if paddleImage then p.width = paddleImage:getWidth(); p.height = paddleImage:getHeight() end
    return p
end

function Paddle.reset(paddle)
    paddle.x = (Config.PLAY_AREA_LEFT + Config.GAME_WIDTH) / 2
end

function Paddle.update(paddle, dt)
    local left = love.keyboard.isDown("left", "a")
    local right = love.keyboard.isDown("right", "d")

    -- Gamepad support
    local joyX = 0
    for i = 1, love.joystick.getJoystickCount() do
        local joystick = love.joystick.getJoystick(i)
        if joystick then
            local axis = joystick:getAxis(1)  -- Left stick X
            if math.abs(axis) > 0.2 then
                joyX = axis
                break
            end
        end
    end

    local dx = 0
    if left and not right then dx = -Config.PADDLE_SPEED
    elseif right and not left then dx = Config.PADDLE_SPEED
    elseif joyX ~= 0 then dx = joyX * Config.PADDLE_SPEED
    end

    paddle.x = math.max(Config.PLAY_AREA_LEFT + paddle.width/2,
               math.min(Config.GAME_WIDTH - paddle.width/2, paddle.x + dx * dt))
end

function Paddle.draw(paddle)
    if paddle.image then
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(paddle.image, paddle.x - paddle.width/2, paddle.y)
    else
        -- Shadow
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", paddle.x - paddle.width/2 + 2, paddle.y + 3,
                                paddle.width, paddle.height, 5, 5)
        -- Glow
        love.graphics.setColor(Config.COLOR_PADDLE[1], Config.COLOR_PADDLE[2], Config.COLOR_PADDLE[3], 0.1)
        love.graphics.rectangle("fill", paddle.x - paddle.width/2 - 6, paddle.y - 6,
                                paddle.width + 12, paddle.height + 12, 10, 10)
        -- Body
        love.graphics.setColor(Config.COLOR_PADDLE)
        love.graphics.rectangle("fill", paddle.x - paddle.width/2, paddle.y,
                                paddle.width, paddle.height, 5, 5)
        -- Top highlight
        love.graphics.setColor(1, 0.9, 0.7, 0.2)
        love.graphics.rectangle("fill", paddle.x - paddle.width/2 + 3, paddle.y + 1,
                                paddle.width - 6, paddle.height * 0.4, 4, 4)
        -- Center groove
        love.graphics.setColor(0, 0, 0, 0.15)
        love.graphics.rectangle("fill", paddle.x - 20, paddle.y + paddle.height*0.3,
                                40, paddle.height*0.4, 2, 2)
    end
end

return Paddle
