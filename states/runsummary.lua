local Config = require("config")
local Save = require("lib.save")
local Theme = require("ui.theme")
local RunSummary = {}

function RunSummary:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
    self.selected = 1

    if game.isEndless then
        Save.trySetHighScoreEndless(game.score)
    else
        Save.trySetHighScore(game.score)
    end

    self.buttons = {
        {label = "MAIN MENU", action = "menu"},
        {label = "RUN IT BACK", action = "play"},
    }
end

function RunSummary:update(dt) self.time = (self.time or 0) + dt end

function RunSummary:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    Theme.background(game, 0.62)

    Theme.text(game.fonts.title, "RUN SUMMARY", 0, 54, W, "center", Theme.colors.gold)
    local panelW, panelH = 520, 340
    local panelX, panelY = W / 2 - panelW / 2, 138
    Theme.panel(panelX, panelY, panelW, panelH, "TOME ENTRY", game.fonts, {redTop = true})

    Theme.statRow(game.fonts, "FINAL SCORE", math.floor(game.score), panelX + 70, panelY + 62, panelW - 140, Theme.colors.gold)
    Theme.statRow(game.fonts, "STAGE REACHED", game.stage or 1, panelX + 70, panelY + 110, panelW - 140, Theme.colors.bone)
    Theme.statRow(game.fonts, "CORRUPTION", game.brainrotLevel or 0, panelX + 70, panelY + 158, panelW - 140, Theme.colors.red)
    Theme.statRow(game.fonts, "VITALITY", game.lives or 0, panelX + 70, panelY + 206, panelW - 140, Theme.colors.green)

    local mods = game.modifiers:getUnique()
    local modText = #mods == 0 and "NO RUNES EQUIPPED" or table.concat(mods, " + ")
    Theme.text(game.fonts.menuTiny, modText, panelX + 42, panelY + 278, panelW - 84, "center", #mods == 0 and Theme.colors.muted or Theme.colors.bone, 0.82)

    local btnW, btnH = 220, 58
    local startX = W / 2 - btnW - 16
    local y = panelY + panelH + 34
    for i, btn in ipairs(self.buttons) do
        local x = startX + (i - 1) * (btnW + 32)
        Theme.button(btn.label, x, y, btnW, btnH, self.selected == i, game.fonts)
    end
end

function RunSummary:keypressed(key)
    if key == "left" or key == "a" or key == "up" or key == "w" then
        self.selected = ((self.selected - 2) % #self.buttons) + 1
    elseif key == "right" or key == "d" or key == "down" or key == "s" then
        self.selected = (self.selected % #self.buttons) + 1
    elseif key == "return" or key == "space" then
        local action = self.buttons[self.selected].action
        if action == "menu" then
            self.sm:switch("menu", self.game, self.sm)
        elseif action == "play" then
            self.sm:switch("playing", self.game, self.sm, true, {endless = self.game.isEndless})
        end
    end
end

return RunSummary
