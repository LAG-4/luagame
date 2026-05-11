-- In-game HUD: score, combo, stage, brainrot level, active modifiers
local Config = require("config")
local HUD = {}

function HUD.draw(game, fonts)
    local font = fonts.main or love.graphics.getFont()
    local smallFont = fonts.small or font

    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("SCORE: " .. math.floor(game.score), 20, 20)
    love.graphics.print("COMBO: " .. game.combo, 20, 40)
    love.graphics.print("STAGE: " .. game.stage, Config.GAME_WIDTH - 100, 20)
    love.graphics.print("BRAINROT: " .. game.brainrotLevel, Config.GAME_WIDTH - 150, 40)

    -- Active modifiers display
    local mods = game.modifiers:getUnique()
    if #mods > 0 then
        love.graphics.setFont(smallFont)
        love.graphics.setColor(0.6, 1, 0.6, 0.8)
        for i, name in ipairs(mods) do
            love.graphics.print("● " .. name, 20, Config.GAME_HEIGHT - 20 * i - 5)
        end
    end
end

return HUD
