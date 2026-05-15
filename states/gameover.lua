local Config = require("config")
local Theme = require("ui.theme")
local GameOver = {}

function GameOver:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
end

function GameOver:update(dt) self.time = (self.time or 0) + dt end

function GameOver:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    Theme.background(game, 0.66)
    love.graphics.setColor(0.42, 0, 0, 0.22)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local cw, ch = 500, 360
    local cx, cy = W / 2 - cw / 2, H / 2 - ch / 2
    Theme.panel(cx, cy, cw, ch, "RUN ENDED", game.fonts, {redTop = true, selected = true})
    Theme.text(game.fonts.title, "GAME OVER", cx, cy + 52, cw, "center", Theme.colors.red)
    Theme.statRow(game.fonts, "FINAL SCORE", math.floor(game.score), cx + 72, cy + 142, cw - 144, Theme.colors.gold)
    Theme.statRow(game.fonts, "STAGE", game.stage, cx + 72, cy + 190, cw - 144, Theme.colors.bone)
    Theme.statRow(game.fonts, "CORRUPTION", game.brainrotLevel, cx + 72, cy + 238, cw - 144, Theme.colors.red)
    Theme.text(game.fonts.menuSmall, "R TO RESTART   M FOR SUMMARY", cx, cy + ch - 54, cw, "center", Theme.colors.bone, 0.75)
end

function GameOver:keypressed(key)
    if key == "r" or key == "return" then
        self.sm:switch("playing", self.game, self.sm, true, {endless = self.game.isEndless})
    elseif key == "m" then
        self.sm:switch("runsummary", self.game, self.sm)
    end
end

function GameOver:mousepressed(x, y, button)
    if button == 1 then
        self:keypressed("r")
    elseif button == 2 then
        self:keypressed("m")
    end
end

return GameOver
