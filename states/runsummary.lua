-- Run summary screen — shows stats after game over/victory
local Config = require("config")
local Save = require("lib.save")
local RunSummary = {}

function RunSummary:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
    self.selected = 1

    -- Save high score
    if game.isEndless then
        Save.trySetHighScoreEndless(game.score)
    else
        Save.trySetHighScore(game.score)
    end

    self.buttons = {
        { label = "MAIN MENU", action = "menu" },
        { label = "PLAY AGAIN", action = "play" },
    }
end

function RunSummary:update(dt) self.time = (self.time or 0) + dt end

function RunSummary:draw()
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    -- Title
    love.graphics.setFont(self.game.fonts.large)
    love.graphics.setColor(Config.COLOR_ACCENT)
    love.graphics.printf("RUN SUMMARY", 0, 50, W, "center")

    -- Stats panel
    local panelX, panelY = W/2 - 200, 120
    local panelW, panelH = 400, 320

    love.graphics.setColor(Config.COLOR_PANEL)
    love.graphics.rectangle("fill", panelX, panelY, panelW, panelH, 8, 8)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("line", panelX, panelY, panelW, panelH, 8, 8)

    love.graphics.setFont(self.game.fonts.main)
    local stats = {
        {label = "FINAL SCORE", value = self.game.score},
        {label = "STAGE REACHED", value = self.game.stage or 1},
        {label = "BRAINROT LEVEL", value = self.game.brainrotLevel or 0},
        {label = "LIVES REMAINING", value = self.game.lives or 0},
    }

    local y = panelY + 30
    for _, stat in ipairs(stats) do
        love.graphics.setColor(Config.COLOR_CREAM)
        love.graphics.printf(stat.label, panelX + 20, y, 180, "left")
        love.graphics.setColor(Config.COLOR_GOLD)
        love.graphics.printf(tostring(stat.value), panelX + 220, y, 150, "right")
        y = y + 40
    end

    -- Active modifiers
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", panelX + 20, y, panelW - 40, 1)
    y = y + 20

    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.printf("MODIFIERS USED:", panelX + 20, y, panelW - 40, "left")
    y = y + 25

    local mods = self.game.modifiers:getList()
    if #mods == 0 then
        love.graphics.setColor(Config.COLOR_MUTED)
        love.graphics.printf("None", panelX + 30, y, panelW - 60, "left")
    else
        for i, mod in ipairs(mods) do
            love.graphics.setColor(Config.COLOR_ACCENT)
            love.graphics.printf(mod, panelX + 30, y + (i-1)*22, panelW - 60, "left")
        end
    end

    -- Buttons
    local btnW, btnH = 180, 44
    local startX = W/2 - btnW - 10
    local startY = panelY + panelH + 30

    love.graphics.setFont(self.game.fonts.main)
    for i, btn in ipairs(self.buttons) do
        local y = startY + (i-1)*(btnH+10)
        local isSelected = (i == self.selected)

        love.graphics.setColor(isSelected and Config.COLOR_ACCENT or Config.COLOR_CARD_BG)
        love.graphics.rectangle("fill", startX + (i-1)*(btnW+20), y, btnW, btnH, 6, 6)
        love.graphics.setColor(isSelected and Config.COLOR_ACCENT or Config.COLOR_PANEL_BORDER)
        love.graphics.rectangle("line", startX + (i-1)*(btnW+20), y, btnW, btnH, 6, 6)

        love.graphics.setColor(isSelected and Config.COLOR_CREAM or Config.COLOR_MUTED)
        love.graphics.printf(btn.label, startX + (i-1)*(btnW+20) + 10, y + 14, btnW - 20, "center")
    end
end

function RunSummary:keypressed(key)
    if key == "up" or key == "w" then
        self.selected = ((self.selected - 2) % #self.buttons) + 1
    elseif key == "down" or key == "s" then
        self.selected = (self.selected % #self.buttons) + 1
    elseif key == "return" or key == "space" then
        local action = self.buttons[self.selected].action
        if action == "menu" then
            self.sm:switch("menu", self.game, self.sm)
        elseif action == "play" then
            self.sm:switch("playing", self.game, self.sm, {endless = self.game.isEndless})
        end
    end
end

return RunSummary