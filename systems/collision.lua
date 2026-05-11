-- Collision detection — sidebar-aware boundaries
local Config = require("config")
local Collision = {}

function Collision.ballWalls(ball)
    local bounced = false
    -- Left wall = sidebar edge
    if ball.x - ball.radius < Config.PLAY_AREA_LEFT then
        ball.dx = math.abs(ball.dx)
        ball.x = Config.PLAY_AREA_LEFT + ball.radius
        bounced = true
    elseif ball.x + ball.radius > Config.GAME_WIDTH then
        ball.dx = -math.abs(ball.dx)
        ball.x = Config.GAME_WIDTH - ball.radius
        bounced = true
    end
    -- Top wall = below top bar
    if ball.y - ball.radius < Config.TOP_BAR_HEIGHT then
        ball.dy = math.abs(ball.dy)
        ball.y = Config.TOP_BAR_HEIGHT + ball.radius
        bounced = true
    end
    return bounced
end

function Collision.ballPaddle(ball, paddle)
    if ball.dy > 0 and
       ball.y + ball.radius > paddle.y and
       ball.y - ball.radius < paddle.y + paddle.height and
       ball.x > paddle.x - paddle.width/2 and
       ball.x < paddle.x + paddle.width/2 then
        ball.dy = -math.abs(ball.dy)
        ball.y = paddle.y - ball.radius
        local hitPos = (ball.x - paddle.x) / (paddle.width / 2)
        ball.dx = hitPos * Config.PADDLE_HIT_SPREAD
        return true
    end
    return false
end

function Collision.ballBrick(ball, brick, ghost)
    if not brick.active then return false end
    if ball.x + ball.radius > brick.x and
       ball.x - ball.radius < brick.x + brick.width and
       ball.y + ball.radius > brick.y and
       ball.y - ball.radius < brick.y + brick.height then
        if not ghost then
            local oL = (ball.x + ball.radius) - brick.x
            local oR = (brick.x + brick.width) - (ball.x - ball.radius)
            local oT = (ball.y + ball.radius) - brick.y
            local oB = (brick.y + brick.height) - (ball.y - ball.radius)
            if math.min(oL, oR) < math.min(oT, oB) then
                ball.dx = -ball.dx
            else
                ball.dy = -ball.dy
            end
        end
        return true
    end
    return false
end

function Collision.ballDead(ball)
    return ball.y > Config.GAME_HEIGHT + 30
end

return Collision
