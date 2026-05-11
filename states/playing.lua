-- Core gameplay state
local Config    = require("config")
local Ball      = require("entities.ball")
local Paddle    = require("entities.paddle")
local Brick     = require("entities.brick")
local Collision = require("systems.collision")
local Modifiers = require("systems.modifiers")
local HUD       = require("ui.hud")

local Playing = {}

function Playing:enter(game, sm)
    self.game = game
    self.sm   = sm

    -- Fresh run
    game.score         = 0
    game.combo         = 0
    game.stage         = 1
    game.brainrotLevel = 0
    game.modifiers     = Modifiers.new()

    game.paddle = Paddle.new(game.images.paddleScaled)
    game.balls  = { Ball.new() }
    game.bricks = Brick.generateGrid(game.stage)
end

function Playing:update(dt)
    local game = self.game

    -- Update paddle
    Paddle.update(game.paddle, dt)

    -- Update all balls
    local anyActive = false
    for i = #game.balls, 1, -1 do
        local ball = game.balls[i]
        if not ball.alive then
            table.remove(game.balls, i)
        else
            -- Follow paddle if not launched
            if not ball.active then
                ball.x = game.paddle.x
                ball.y = game.paddle.y - 30
            else
                Ball.update(ball, dt)
                anyActive = true

                -- Wall collisions
                Collision.ballWalls(ball)

                -- Paddle collision
                if Collision.ballPaddle(ball, game.paddle) then
                    game.combo = game.combo + 1
                    game.camera:shake(Config.SHAKE_PADDLE_HIT)
                    Ball.enforceMinVerticalSpeed(ball)
                end

                -- Brick collisions
                for j = #game.bricks, 1, -1 do
                    local brick = game.bricks[j]
                    if Collision.ballBrick(ball, brick) then
                        brick.hp = brick.hp - 1
                        if brick.hp <= 0 then
                            brick.active = false
                            game.score = game.score + Config.SCORE_PER_BRICK * (1 + game.combo * Config.COMBO_SCORE_MULTIPLIER)
                            game.camera:shake(Config.SHAKE_BRICK_DESTROY)
                            if game.sounds.punch then
                                game.sounds.punch:clone():play()
                            end
                        else
                            if game.sounds.bonk then
                                game.sounds.bonk:clone():play()
                            end
                        end
                        break  -- only one brick per ball per frame
                    end
                end

                -- Ball death
                if Collision.ballDead(ball) then
                    if #game.balls > 1 then
                        -- Multi-ball: just remove this one
                        ball.alive = false
                    elseif game.combo > 0 then
                        -- Last ball, but combo saves you
                        Ball.reset(ball, game.paddle.x, game.paddle.y)
                        game.combo = 0
                    else
                        -- Game over
                        if game.sounds.fah then
                            game.sounds.fah:clone():play()
                        end
                        self.sm:switch("gameover", game, self.sm)
                        return
                    end
                end
            end
        end
    end

    -- If no balls left (shouldn't happen normally, but safety)
    if #game.balls == 0 then
        game.balls = { Ball.new() }
    end

    -- Check stage clear
    if Brick.countActive(game.bricks) == 0 then
        game.brainrotLevel = game.brainrotLevel + 1
        if game.stage >= Config.MAX_STAGES then
            self.sm:switch("victory", game, self.sm)
        else
            game.stage = game.stage + 1
            self.sm:switch("cardselect", game, self.sm)
        end
    end
end

function Playing:draw()
    local game = self.game
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)

    -- Draw bricks
    for _, brick in ipairs(game.bricks) do
        Brick.draw(brick)
    end

    -- Draw paddle
    Paddle.draw(game.paddle)

    -- Draw balls
    for _, ball in ipairs(game.balls) do
        Ball.draw(ball)
    end

    -- Launch prompt
    local hasInactive = false
    for _, ball in ipairs(game.balls) do
        if not ball.active then hasInactive = true; break end
    end
    if hasInactive then
        love.graphics.setFont(game.fonts.main)
        love.graphics.setColor(1, 1, 0.5)
        love.graphics.printf("PRESS SPACE TO LAUNCH", 0, Config.GAME_HEIGHT / 2 - 20,
                             Config.GAME_WIDTH, "center")
    end

    -- HUD
    HUD.draw(game, game.fonts)
end

function Playing:keypressed(key)
    local game = self.game
    if key == "space" or key == "return" then
        for _, ball in ipairs(game.balls) do
            if not ball.active then
                Ball.launch(ball)
                break  -- launch one at a time
            end
        end
    elseif key == "escape" then
        self.sm:switch("pause", game, self.sm)
    end
end

return Playing
