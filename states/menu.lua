-- Main menu state
local Config = require("config")
local Menu = {}

function Menu:enter(game, sm)
    self.game = game
    self.sm = sm
end

function Menu:update(dt) end

function Menu:draw()
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)

    local font = self.game.fonts.main
    love.graphics.setFont(font)

    -- Title
    love.graphics.setColor(1, 0.3, 0.5)
    love.graphics.printf("BRAINROT ARCADE", 0, Config.GAME_HEIGHT / 2 - 80, Config.GAME_WIDTH, "center")

    love.graphics.setColor(0.5, 0.7, 1)
    love.graphics.printf("A Roguelite Brick Breaker", 0, Config.GAME_HEIGHT / 2 - 40, Config.GAME_WIDTH, "center")

    -- Options
    love.graphics.setColor(1, 1, 0.5)
    love.graphics.printf("Press ENTER to Start", 0, Config.GAME_HEIGHT / 2 + 40, Config.GAME_WIDTH, "center")

    love.graphics.setColor(0.6, 0.6, 0.6)
    love.graphics.printf("Press Q to Quit", 0, Config.GAME_HEIGHT / 2 + 80, Config.GAME_WIDTH, "center")
end

function Menu:keypressed(key)
    if key == "return" or key == "space" then
        self.sm:switch("playing", self.game, self.sm)
    elseif key == "q" then
        love.event.quit()
    end
end

return Menu
