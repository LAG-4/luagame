-- Pause overlay state
local Config = require("config")
local Pause = {}

function Pause:enter(game, sm)
    self.game = game
    self.sm   = sm
end

function Pause:update(dt) end

function Pause:draw()
    local game = self.game

    -- Draw the playing state underneath (frozen)
    local playingState = self.sm.states["playing_continue"] or self.sm.states["playing"]
    if playingState and playingState.draw then
        playingState:draw()
    end

    -- Dim overlay
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT)

    -- Pause text
    love.graphics.setFont(game.fonts.main)

    love.graphics.setColor(1, 1, 0.5)
    love.graphics.printf("=== PAUSED ===", 0, Config.GAME_HEIGHT / 2 - 40,
                         Config.GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Press ESC to resume", 0, Config.GAME_HEIGHT / 2 + 10,
                         Config.GAME_WIDTH, "center")
    love.graphics.printf("Press M for main menu", 0, Config.GAME_HEIGHT / 2 + 40,
                         Config.GAME_WIDTH, "center")
end

function Pause:keypressed(key)
    if key == "escape" then
        self.sm:switch("playing_continue", self.game, self.sm)
    elseif key == "m" then
        self.sm:switch("menu", self.game, self.sm)
    end
end

return Pause
