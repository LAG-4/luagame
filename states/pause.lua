local Config = require("config")
local Theme = require("ui.theme")
local Pause = {}

function Pause:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
end

function Pause:update(dt) self.time = (self.time or 0) + dt end

function Pause:draw()
    local underneath = self.sm:getUnderneath()
    if underneath and underneath.draw then underneath:draw() end

    love.graphics.setColor(0, 0, 0, 0.72)
    love.graphics.rectangle("fill", 0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT)

    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    local cw, ch = 360, 210
    local cx, cy = W / 2 - cw / 2, H / 2 - ch / 2

    Theme.panel(cx, cy, cw, ch, "PAUSED", self.game.fonts, {redTop = true})
    Theme.text(self.game.fonts.large, "PAUSED", cx, cy + 54, cw, "center", Theme.colors.gold)
    Theme.text(self.game.fonts.menuSmall, "ESC TO RESUME", cx, cy + 116, cw, "center", Theme.colors.bone, 0.82)
    Theme.text(self.game.fonts.menuSmall, "M FOR MAIN MENU", cx, cy + 146, cw, "center", Theme.colors.muted)
end

function Pause:keypressed(key)
    if key == "escape" then
        self.sm:pop()
    elseif key == "m" then
        self.sm:pop()
        self.sm:switch("menu", self.game, self.sm)
    end
end

return Pause
