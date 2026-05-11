-- Collision detection & resolution
local Config = require("config")
local Collision = {}

-- Ball vs screen walls — returns true if bounced
function Collision.ballWalls(ball)
    local bounced = false
    -- Left / right walls
    if ball.x - ball.radius < 0 then
        ball.dx = math.abs(ball.dx)
        ball.x = ball.radius
        bounced = true
    elseif ball.x + ball.radius > Config.GAME_WIDTH then
        ball.dx = -math.abs(ball.dx)
        ball.x = Config.GAME_WIDTH - ball.radius
        bounced = true
    end
    -- Ceiling
    if ball.y - ball.radius < 0 then
        ball.dy = math.abs(ball.dy)
        ball.y = ball.radius
        bounced = true
    end
    return bounced
end

-- Ball vs paddle — returns true if hit
function Collision.ballPaddle(ball, paddle)
    if ball.y + ball.radius > paddle.y and
       ball.y - ball.radius < paddle.y + paddle.height and
       ball.x > paddle.x - paddle.width / 2 and
       ball.x < paddle.x + paddle.width / 2 then
        ball.dy = -math.abs(ball.dy)
        ball.y = paddle.y - ball.radius
        local hitPos = (ball.x - paddle.x) / (paddle.width / 2)
        ball.dx = hitPos * Config.PADDLE_HIT_SPREAD
        return true
    end
    return false
end

-- Ball vs single brick — returns true if hit
function Collision.ballBrick(ball, brick)
    if not brick.active then return false end
    if ball.x + ball.radius > brick.x and
       ball.x - ball.radius < brick.x + brick.width and
       ball.y + ball.radius > brick.y and
       ball.y - ball.radius < brick.y + brick.height then

        -- Determine which side was hit
        local overlapLeft   = (ball.x + ball.radius) - brick.x
        local overlapRight  = (brick.x + brick.width) - (ball.x - ball.radius)
        local overlapTop    = (ball.y + ball.radius) - brick.y
        local overlapBottom = (brick.y + brick.height) - (ball.y - ball.radius)

        local minX = math.min(overlapLeft, overlapRight)
        local minY = math.min(overlapTop, overlapBottom)

        if minX < minY then
            ball.dx = -ball.dx
        else
            ball.dy = -ball.dy
        end
        return true
    end
    return false
end

-- Check if ball fell off the bottom
function Collision.ballDead(ball)
    return ball.y > Config.GAME_HEIGHT + 50
end

return Collision
