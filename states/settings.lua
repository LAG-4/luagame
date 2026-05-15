-- Settings screen styled to match the reference gothic panels.
local Config = require("config")
local Save = require("lib.save")
local Settings = {}

local function drawImageCover(img, x, y, w, h, alpha)
    if not img then return end
    local iw, ih = img:getDimensions()
    local scale = math.max(w / iw, h / ih)
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x + (w - iw * scale) / 2, y + (h - ih * scale) / 2, 0, scale, scale)
end

local function drawPanel(x, y, w, h, title, fonts)
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", x + 4, y + 4, w, h, 2, 2)
    love.graphics.setColor(Config.COLOR_PANEL)
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    love.graphics.setColor(0.04, 0.03, 0.02, 0.86)
    love.graphics.rectangle("fill", x + 8, y + 38, w - 16, h - 46, 2, 2)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 2, 2)
    love.graphics.setLineWidth(1)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER[1], Config.COLOR_PANEL_BORDER[2], Config.COLOR_PANEL_BORDER[3], 0.35)
    love.graphics.line(x + 8, y + 32, x + w - 8, y + 32)

    if title then
        love.graphics.setFont(fonts.panelTitle or fonts.main)
        love.graphics.setColor(Config.COLOR_GOLD)
        love.graphics.printf(title, x, y + 9, w, "center")
    end
end

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

    drawImageCover(self.game.images and self.game.images.background, 0, 0, W, H, 0.55)
    love.graphics.setColor(0, 0, 0, 0.74)
    love.graphics.rectangle("fill", 0, 0, W, H)
    drawImageCover(self.game.images and self.game.images.scratchedMetal, 0, 0, W, H, 0.18)

    local options = {
        {label = "VOLUME", value = string.format("%.0f%%", self.settings.volume * 100), action = "volume"},
        {label = "CRT EFFECT", value = self.settings.crtEffect and "ON" or "OFF", action = "crt"},
        {label = "SCREEN SHAKE", value = self.settings.screenShake and "ON" or "OFF", action = "shake"},
        {label = "FULLSCREEN", value = self.settings.fullscreen and "ON" or "OFF", action = "fullscreen"},
        {label = "BACK", value = "", action = "back"},
    }

    local panelW, panelH = 420, 360
    local panelX, panelY = W / 2 - panelW / 2, H / 2 - panelH / 2
    drawPanel(panelX, panelY, panelW, panelH, "SETTINGS", self.game.fonts)

    local btnW, btnH = 332, 42
    local startX = W / 2 - btnW / 2
    local startY = panelY + 64

    love.graphics.setFont(self.game.fonts.menuSmall or self.game.fonts.main)
    for i, opt in ipairs(options) do
        local y = startY + (i - 1) * (btnH + 10)
        local isSelected = (i == self.selected)

        if isSelected then
            love.graphics.setColor(0.24, 0.045, 0.04, 0.96)
        else
            love.graphics.setColor(0.075, 0.06, 0.05, 0.98)
        end
        love.graphics.rectangle("fill", startX, y, btnW, btnH, 2, 2)

        love.graphics.setColor(isSelected and Config.COLOR_ACCENT or Config.COLOR_PANEL_BORDER)
        love.graphics.setLineWidth(isSelected and 3 or 1)
        love.graphics.rectangle("line", startX, y, btnW, btnH, 2, 2)
        love.graphics.setLineWidth(1)

        love.graphics.setColor(isSelected and Config.COLOR_CREAM or Config.COLOR_MUTED)
        love.graphics.printf(opt.label, startX + 18, y + 11, 160, "left")

        if opt.value ~= "" then
            love.graphics.setColor(isSelected and Config.COLOR_GOLD or Config.COLOR_MUTED)
            love.graphics.printf(opt.value, startX + 185, y + 11, 120, "right")
        end
    end

    love.graphics.setFont(self.game.fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.printf("LEFT / RIGHT TO CHANGE   ENTER TO SELECT   ESC TO BACK", panelX, panelY + panelH - 36, panelW, "center")
end

function Settings:keypressed(key)
    local options = self:getOptions()

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
    local actions = {"volume", "crt", "shake", "fullscreen"}
    local action = actions[self.selected]
    if not action then return end

    if action == "volume" then
        self.settings.volume = math.max(0, math.min(1, self.settings.volume + dir * 0.1))
        Save.setSetting("volume", self.settings.volume)
        self.game.audio:setMasterVolume(self.settings.volume)
        self.game.audio:setBgmVolume(self.settings.volume * 0.65)
    elseif action == "crt" then
        self.settings.crtEffect = not self.settings.crtEffect
        Save.setSetting("crtEffect", self.settings.crtEffect)
    elseif action == "shake" then
        self.settings.screenShake = not self.settings.screenShake
        Save.setSetting("screenShake", self.settings.screenShake)
    elseif action == "fullscreen" then
        self.settings.fullscreen = not self.settings.fullscreen
        love.window.setFullscreen(self.settings.fullscreen, "desktop")
        Save.setSetting("fullscreen", self.settings.fullscreen)
    end
end

function Settings:activateSetting()
    if self.selected == #self:getOptions() then
        self.sm:pop()
    end
end

function Settings:getOptions()
    return {
        {action = "volume"},
        {action = "crt"},
        {action = "shake"},
        {action = "fullscreen"},
        {action = "back"},
    }
end

return Settings
