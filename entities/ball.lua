-- Ball entity — supports multi-ball via list management
local Config = require("config")
local Ball = {}

function Ball.new(x, y, dx, dy)
    return {
        x      = x or Config.GAME_WIDTH / 2,
        y      = y or Config.GAME_HEIGHT - 60,
        radius = Config.BALL_RADIUS,
        dx     = dx or 250,
        dy     = dy or Config.BALL_INITIAL_DY,
        active = false,   -- false = resting on paddle
        alive  = true,    -- false = flagged for removal
        ghostPasses = 0,  -- for ghost-ball modifier
    }
end

function Ball.reset(ball, paddleX, paddleY)
    ball.x = paddleX
    ball.y = paddleY - 30
    ball.active = false
    ball.alive = true
end

function Ball.launch(ball)
    ball.active = true
    ball.dy = Config.BALL_INITIAL_DY
    ball.dx = (math.random() - 0.5) * Config.BALL_LAUNCH_SPREAD
end

function Ball.update(ball, dt)
    if not ball.active then return end
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt
end

function Ball.draw(ball)
    if not ball.alive then return end
    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.circle("fill", ball.x, ball.y, ball.radius)
end

-- Prevent near-horizontal bouncing
function Ball.enforceMinVerticalSpeed(ball)
    if math.abs(ball.dy) < Config.BALL_MIN_DY then
        ball.dy = (ball.dy >= 0 and 1 or -1) * Config.BALL_MIN_DY
    end
end

return Ball
