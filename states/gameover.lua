-- Game over — dark gothic death card
local Config = require("config")
local GameOver = {}

function GameOver:enter(game, sm)
    self.game = game; self.sm = sm; self.time = 0
end

function GameOver:update(dt) self.time = (self.time or 0) + dt end

function GameOver:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    -- Blood red vignette
    love.graphics.setColor(0.4, 0, 0, 0.15)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Death card
    local cw, ch = 420, 310
    local cx, cy = W/2 - cw/2, H/2 - ch/2

    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", cx+4, cy+4, cw, ch, 10, 10)
    love.graphics.setColor(Config.COLOR_CARD_BG)
    love.graphics.rectangle("fill", cx, cy, cw, ch, 10, 10)
    love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2], Config.COLOR_ACCENT[3], 0.6)
    love.graphics.rectangle("fill", cx, cy, cw, 5, 10, 0)
    love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2], Config.COLOR_ACCENT[3], 0.5)
    love.graphics.rectangle("line", cx, cy, cw, ch, 10, 10)

    love.graphics.setFont(game.fonts.large)
    love.graphics.setColor(Config.COLOR_ACCENT)
    love.graphics.printf("GAME OVER", cx, cy + 25, cw, "center")

    love.graphics.setFont(game.fonts.main)
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.printf("Score: " .. math.floor(game.score), cx, cy + 80, cw, "center")
    love.graphics.setColor(Config.COLOR_COMBO)
    love.graphics.printf("Stage: " .. game.stage .. "  |  Combo Peak: " .. game.combo,
                         cx, cy + 110, cw, "center")
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.6)
    love.graphics.printf("Brainrot: " .. game.brainrotLevel, cx, cy + 140, cw, "center")

    local mods = game.modifiers:getUnique()
    if #mods > 0 then
        love.graphics.setFont(game.fonts.small)
        love.graphics.setColor(Config.COLOR_MUTED)
        love.graphics.printf("Build: " .. table.concat(mods, " + "), cx+20, cy+180, cw-40, "center")
    end

    love.graphics.setFont(game.fonts.main)
    local p = 0.4 + 0.4 * math.sin((self.time or 0) * 3)
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], p + 0.3)
    love.graphics.printf("R to Restart  |  M for Menu", cx, cy + ch - 45, cw, "center")
end

function GameOver:keypressed(key)
    if key == "r" or key == "return" then self.sm:switch("playing", self.game, self.sm, {endless = self.game.isEndless})
    elseif key == "m" then self.sm:switch("runsummary", self.game, self.sm) end
end

return GameOver
