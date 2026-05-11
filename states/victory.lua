-- Victory — dark gothic gold triumph
local Config = require("config")
local Victory = {}

function Victory:enter(game, sm)
    self.game = game; self.sm = sm; self.time = 0
end

function Victory:update(dt) self.time = (self.time or 0) + dt end

function Victory:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    local cw, ch = 440, 320
    local cx, cy = W/2 - cw/2, H/2 - ch/2

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", cx+4, cy+4, cw, ch, 10, 10)
    love.graphics.setColor(Config.COLOR_CARD_BG)
    love.graphics.rectangle("fill", cx, cy, cw, ch, 10, 10)
    love.graphics.setColor(Config.COLOR_GOLD[1], Config.COLOR_GOLD[2], Config.COLOR_GOLD[3], 0.6)
    love.graphics.rectangle("fill", cx, cy, cw, 5, 10, 0)
    love.graphics.setColor(Config.COLOR_GOLD[1], Config.COLOR_GOLD[2], Config.COLOR_GOLD[3], 0.4)
    love.graphics.rectangle("line", cx, cy, cw, ch, 10, 10)

    love.graphics.setFont(game.fonts.large)
    love.graphics.setColor(0.3, 0.9, 0.3)
    love.graphics.printf("VICTORY!", cx, cy + 25, cw, "center")

    love.graphics.setFont(game.fonts.main)
    love.graphics.setColor(Config.COLOR_CREAM)
    love.graphics.printf("You survived the brainrot!", cx, cy + 75, cw, "center")
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.printf("Final Score: " .. math.floor(game.score), cx, cy + 115, cw, "center")
    love.graphics.setColor(Config.COLOR_COMBO)
    love.graphics.printf("Brainrot Level: " .. game.brainrotLevel, cx, cy + 145, cw, "center")
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.5)
    love.graphics.printf("Lives: " .. (game.lives or 0), cx, cy + 175, cw, "center")

    local mods = game.modifiers:getUnique()
    if #mods > 0 then
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(Config.COLOR_MUTED)
        love.graphics.printf("Build: " .. table.concat(mods, " + "), cx+20, cy+210, cw-40, "center")
    end

    love.graphics.setFont(game.fonts.main)
    local p = 0.4 + 0.4 * math.sin((self.time or 0) * 3)
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], p + 0.3)
    love.graphics.printf("R to Play Again  |  M for Menu", cx, cy + ch - 45, cw, "center")
end

function Victory:keypressed(key)
    if key == "r" or key == "return" then self.sm:switch("playing", self.game, self.sm, {endless = self.game.isEndless})
    elseif key == "m" then self.sm:switch("runsummary", self.game, self.sm) end
end

return Victory
