-- Ball entity — warm gold with dark gothic feel
local Config = require("config")
local Ball = {}

function Ball.new(x, y, dx, dy)
    return {
        x = x or (Config.PLAY_AREA_LEFT + Config.GAME_WIDTH) / 2,
        y = y or Config.PADDLE_Y - 25,
        radius = Config.BALL_RADIUS,
        dx = dx or 300, dy = dy or Config.BALL_INITIAL_DY,
        active = false, alive = true,
        ghostPasses = 0, trail = {}, particleTrail = {},
    }
end

function Ball.reset(ball, paddleX, paddleY)
    ball.x = paddleX
    ball.y = paddleY - 25
    ball.active = false
    ball.alive = true
    ball.trail = {}
    ball.particleTrail = {}
end

function Ball.launch(ball)
    ball.active = true
    ball.dy = Config.BALL_INITIAL_DY
    ball.dx = (math.random() - 0.5) * Config.BALL_LAUNCH_SPREAD
end

function Ball.update(ball, dt)
    if not ball.active then return end
    table.insert(ball.trail, 1, {x = ball.x, y = ball.y})
    if #ball.trail > 10 then table.remove(ball.trail) end
    Ball.enforceSpeedLimits(ball)
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
end

function Ball.draw(ball)
    if not ball.alive then return end
    for i, pos in ipairs(ball.trail) do
        local a = (1 - i / #ball.trail) * 0.12
        love.graphics.setColor(Config.COLOR_BALL[1], Config.COLOR_BALL[2], Config.COLOR_BALL[3], a)
        love.graphics.circle("fill", pos.x, pos.y, ball.radius * (1 - i * 0.06))
    end
    -- Glow
    love.graphics.setColor(Config.COLOR_BALL_GLOW)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius * 3)
    -- Core
    love.graphics.setColor(Config.COLOR_BALL)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
    -- Shine
    love.graphics.setColor(1, 1, 0.9, 0.45)
    love.graphics.circle("fill", ball.x - ball.radius*0.25, ball.y - ball.radius*0.25, ball.radius*0.3)
end

function Ball.enforceMinVerticalSpeed(ball)
    if math.abs(ball.dy) < Config.BALL_MIN_DY then
        ball.dy = (ball.dy >= 0 and 1 or -1) * Config.BALL_MIN_DY
    end
end

function Ball.enforceSpeedLimits(ball)
    Ball.enforceMinVerticalSpeed(ball)
    local speed = math.sqrt(ball.dx * ball.dx + ball.dy * ball.dy)
    if speed > Config.BALL_MAX_SPEED then
        local scale = Config.BALL_MAX_SPEED / speed
        ball.dx = ball.dx * scale
        ball.dy = ball.dy * scale
    end
end

return Ball
