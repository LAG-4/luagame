-- Game over state
local Config = require("config")
local GameOver = {}

function GameOver:enter(game, sm)
    self.game = game
    self.sm   = sm
end

function GameOver:update(dt) end

function GameOver:draw()
    local game = self.game
    love.graphics.setBackgroundColor(0.2, 0.05, 0.05)

    love.graphics.setFont(game.fonts.main)

    love.graphics.setColor(1, 0.3, 0.3)
    love.graphics.printf("=== GAME OVER ===", 0, Config.GAME_HEIGHT / 2 - 40,
                         Config.GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. math.floor(game.score),
                         0, Config.GAME_HEIGHT / 2, Config.GAME_WIDTH, "center")
    love.graphics.printf("Stage Reached: " .. game.stage,
                         0, Config.GAME_HEIGHT / 2 + 30, Config.GAME_WIDTH, "center")

    love.graphics.printf("Press R to restart  |  Press M for menu",
                         0, Config.GAME_HEIGHT / 2 + 80, Config.GAME_WIDTH, "center")
end

function GameOver:keypressed(key)
    if key == "r" or key == "return" then
        self.sm:switch("playing", self.game, self.sm)
    elseif key == "m" then
        self.sm:switch("menu", self.game, self.sm)
    end
end

return GameOver
