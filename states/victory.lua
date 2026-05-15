local Config = require("config")
local Theme = require("ui.theme")
local Victory = {}

function Victory:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
end

function Victory:update(dt) self.time = (self.time or 0) + dt end

function Victory:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    Theme.background(game, 0.60)
    love.graphics.setColor(0.02, 0.18, 0.03, 0.18)
    love.graphics.rectangle("fill", 0, 0, W, H)

    local cw, ch = 520, 360
    local cx, cy = W / 2 - cw / 2, H / 2 - ch / 2
    Theme.panel(cx, cy, cw, ch, "DUNGEON CLEARED", game.fonts, {border = Theme.colors.green, redTop = true})
    Theme.text(game.fonts.title, "VICTORY", cx, cy + 52, cw, "center", Theme.colors.green)
    Theme.statRow(game.fonts, "FINAL SCORE", math.floor(game.score), cx + 78, cy + 142, cw - 156, Theme.colors.gold)
    Theme.statRow(game.fonts, "BRAINROT LEVEL", game.brainrotLevel, cx + 78, cy + 190, cw - 156, Theme.colors.red)
    Theme.statRow(game.fonts, "LIVES LEFT", game.lives or 0, cx + 78, cy + 238, cw - 156, Theme.colors.bone)
    Theme.text(game.fonts.menuSmall, "R TO PLAY AGAIN   M FOR SUMMARY", cx, cy + ch - 54, cw, "center", Theme.colors.bone, 0.75)
end

function Victory:keypressed(key)
    if key == "r" or key == "return" then
        self.sm:switch("playing", self.game, self.sm, true, {endless = self.game.isEndless})
    elseif key == "m" then
        self.sm:switch("runsummary", self.game, self.sm)
    end
end

return Victory
