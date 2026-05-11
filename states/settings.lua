-- Settings screen — Phase 6
local Config = require("config")
local Save = require("lib.save")
local Settings = {}

function Settings:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
    self.selected = 1
    self.settings = Save.getSettings()
end

function Settings:update(dt) self.time = (self.time or 0) + dt end

function Settings:draw()
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    -- Title
    love.graphics.setFont(self.game.fonts.large)
    love.graphics.setColor(Config.COLOR_ACCENT)
    love.graphics.printf("SETTINGS", 0, 60, W, "center")

    -- Options
    local options = {
        {label = "VOLUME", value = string.format("%.0f%%", self.settings.volume * 100), action = "volume"},
        {label = "CRT EFFECT", value = self.settings.crtEffect and "ON" or "OFF", action = "crt"},
        {label = "SCREEN SHAKE", value = self.settings.screenShake and "ON" or "OFF", action = "shake"},
        {label = "BACK", value = "", action = "back"},
    }

    local btnW, btnH = 300, 44
    local startX = W / 2 - btnW / 2
    local startY = H / 2 - (#options * (btnH + 10)) / 2

    love.graphics.setFont(self.game.fonts.main)
    local selIdx = 1

    for i, opt in ipairs(options) do
        local y = startY + (i - 1) * (btnH + 10)
        local isSelected = (i == self.selected)

        -- Button bg
        if isSelected then
            love.graphics.setColor(Config.COLOR_ACCENT[1]*0.3, Config.COLOR_ACCENT[2]*0.3, Config.COLOR_ACCENT[3]*0.3, 0.9)
        else
            love.graphics.setColor(Config.COLOR_CARD_BG)
        end
        love.graphics.rectangle("fill", startX, y, btnW, btnH, 6, 6)

        -- Border
        love.graphics.setColor(isSelected and Config.COLOR_ACCENT or Config.COLOR_PANEL_BORDER)
        love.graphics.rectangle("line", startX, y, btnW, btnH, 6, 6)

        -- Label
        love.graphics.setColor(isSelected and Config.COLOR_CREAM or Config.COLOR_MUTED)
        love.graphics.printf(opt.label, startX + 20, y + 12, 120, "left")

        -- Value
        if opt.value ~= "" then
            love.graphics.setColor(isSelected and Config.COLOR_GOLD or Config.COLOR_MUTED)
            love.graphics.printf(opt.value, startX + 140, y + 12, 100, "left")
        end
    end

    -- Instructions
    love.graphics.setFont(self.game.fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.printf("← → Change values | ENTER Select | ESC Back", 0, H - 40, W, "center")
end

function Settings:keypressed(key)
    local options = {
        {action = "volume"},
        {action = "crt"},
        {action = "shake"},
        {action = "back"},
    }

    if key == "up" or key == "w" then
        self.selected = ((self.selected - 2) % #options) + 1
    elseif key == "down" or key == "s" then
        self.selected = (self.selected % #options) + 1
    elseif key == "left" or key == "a" then
        self:adjustSetting(-1)
    elseif key == "right" or key == "d" then
        self:adjustSetting(1)
    elseif key == "return" or key == "space" then
        self:activateSetting()
    elseif key == "escape" then
        self.sm:pop()
    end
end

function Settings:adjustSetting(dir)
    local action = {
        "volume", "crt", "shake",
    }[self.selected]
    if not action then return end

    if action == "volume" then
        self.settings.volume = math.max(0, math.min(1, self.settings.volume + dir * 0.1))
        Save.setSetting("volume", self.settings.volume)
        self.game.audio:setMasterVolume(self.settings.volume)
    elseif action == "crt" then
        self.settings.crtEffect = not self.settings.crtEffect
        Save.setSetting("crtEffect", self.settings.crtEffect)
    elseif action == "shake" then
        self.settings.screenShake = not self.settings.screenShake
        Save.setSetting("screenShake", self.settings.screenShake)
    end
end

function Settings:activateSetting()
    if self.selected == #self.buttons then
        self.sm:pop()
    end
end

return Settings