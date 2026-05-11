-- Pause overlay — dark gothic style
local Config = require("config")
local Pause = {}

function Pause:enter(game, sm)
    self.game = game; self.sm = sm; self.time = 0
end

function Pause:update(dt) self.time = (self.time or 0) + dt end

function Pause:draw()
    local underneath = self.sm:getUnderneath()
    if underneath and underneath.draw then underneath:draw() end

    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, Config.GAME_WIDTH, Config.GAME_HEIGHT)

    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    local cw, ch = 300, 160
    local cx, cy = W/2 - cw/2, H/2 - ch/2

    -- Panel
    love.graphics.setColor(Config.COLOR_CARD_BG)
    love.graphics.rectangle("fill", cx, cy, cw, ch, 8, 8)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("line", cx, cy, cw, ch, 8, 8)

    love.graphics.setFont(self.game.fonts.large)
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.printf("PAUSED", cx, cy + 20, cw, "center")

    love.graphics.setFont(self.game.fonts.main)
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.8)
    love.graphics.printf("ESC to resume", cx, cy + 75, cw, "center")
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.printf("M for menu", cx, cy + 105, cw, "center")
end

function Pause:keypressed(key)
    if key == "escape" then self.sm:pop()
    elseif key == "m" then self.sm:pop(); self.sm:switch("menu", self.game, self.sm) end
end

return Pause
