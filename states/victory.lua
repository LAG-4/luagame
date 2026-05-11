-- Victory state
local Config = require("config")
local Victory = {}

function Victory:enter(game, sm)
    self.game = game
    self.sm   = sm
end

function Victory:update(dt) end

function Victory:draw()
    local game = self.game
    love.graphics.setBackgroundColor(0.1, 0.1, 0.3)

    love.graphics.setFont(game.fonts.main)

    love.graphics.setColor(0.3, 1, 0.5)
    love.graphics.printf("=== VICTORY ===", 0, Config.GAME_HEIGHT / 2 - 40,
                         Config.GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Final Score: " .. math.floor(game.score),
                         0, Config.GAME_HEIGHT / 2, Config.GAME_WIDTH, "center")
    love.graphics.printf("You survived the brainrot!",
                         0, Config.GAME_HEIGHT / 2 + 40, Config.GAME_WIDTH, "center")

    love.graphics.printf("Press R to play again  |  Press M for menu",
                         0, Config.GAME_HEIGHT / 2 + 80, Config.GAME_WIDTH, "center")
end

function Victory:keypressed(key)
    if key == "r" or key == "return" then
        self.sm:switch("playing", self.game, self.sm)
    elseif key == "m" then
        self.sm:switch("menu", self.game, self.sm)
    end
end

return Victory
