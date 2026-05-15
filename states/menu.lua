local Config = require("config")
local Save = require("lib.save")
local Theme = require("ui.theme")

local Menu = {}

function Menu:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
    self.selected = 1
    self.notice = nil
    self.noticeTime = 0
    self.hotspots = {}
    self.buttons = {
        {label = "ENTER DUNGEON", sub = "ARCADE RUN", action = "play"},
        {label = "ENDLESS DESCENT", sub = "NO CAP MODE", action = "endless"},
    }
end

function Menu:update(dt)
    self.time = (self.time or 0) + dt
    if self.noticeTime > 0 then
        self.noticeTime = math.max(0, self.noticeTime - dt)
    end
end

function Menu:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    self.hotspots = {}

    Theme.background(game, 0.58)

    love.graphics.setColor(0.03, 0.01, 0.01, 0.42)
    love.graphics.rectangle("fill", 0, 0, W, H)

    self:drawTopRail()
    self:drawLeftCodex()
    self:drawHero()
    self:drawRightCodex()
    self:drawFooter()
end

function Menu:drawTopRail()
    local game = self.game
    local hs = Save.getHighScore()
    local hsEndless = Save.getHighScoreEndless()

    Theme.panel(18, 16, 316, 86, nil, game.fonts, {fill = {0.07, 0.055, 0.045, 0.98}})
    love.graphics.setColor(0, 0, 0, 0.88)
    love.graphics.rectangle("fill", 31, 27, 60, 60, 1, 1)
    Theme.brainIcon(game, 33, 29, 56, 0.95)
    Theme.text(game.fonts.menuSmall, "PLAYER", 108, 31, 190, "left", Theme.colors.bone)
    Theme.text(game.fonts.menuSmall, "LEVEL 1 CORRUPTED", 108, 54, 190, "left", Theme.colors.red)

    local stats = {
        {"CORRUPTION", 0, Theme.colors.red},
        {"MAX COMBO", 0, Config.COLOR_COMBO},
        {"DEEPEST LAYER", math.max(hsEndless, hs), Theme.colors.green},
    }
    for i, row in ipairs(stats) do
        local x = 360 + (i - 1) * 181
        Theme.panel(x, 20, 162, 78, row[1], game.fonts, {fill = {0.065, 0.05, 0.04, 0.98}})
        Theme.text(game.fonts.hudValue or game.fonts.menuLarge, tostring(row[2]), x, 56, 162, "center", row[3])
    end

    self:drawIconButton(942, 20, "O", "SETTINGS", "settings")
    self:drawIconButton(1050, 20, "X", "QUIT", "quit")
end

function Menu:drawIconButton(x, y, icon, label, action)
    local game = self.game
    Theme.panel(x, y, 92, 78, nil, game.fonts, {fill = {0.065, 0.05, 0.04, 0.98}})
    Theme.text(game.fonts.menuIcon, icon, x, y + 12, 92, "center", Theme.colors.bone)
    Theme.text(game.fonts.menuTiny, label, x, y + 52, 92, "center", Theme.colors.gold)
    table.insert(self.hotspots, {x = x, y = y, w = 92, h = 78, button = {action = action, label = label}})
end

function Menu:drawLeftCodex()
    local game = self.game
    Theme.panel(18, 126, 328, 318, nil, game.fonts, {redTop = true, fill = {0.07, 0.047, 0.036, 0.98}})
    Theme.logo(game, 51, 164, 258)
    Theme.text(game.fonts.menuArcade, "ARCADE", 18, 372, 328, "center", Theme.colors.green)

    Theme.panel(18, 468, 328, 154, "DAILY QUEST", game.fonts)
    Theme.text(game.fonts.menuSmall, "DESTROY 200 MEMES", 36, 528, 292, "center", Theme.colors.bone, 0.78)
    Theme.text(game.fonts.menuSmall, "WITHOUT DYING", 36, 552, 292, "center", Theme.colors.bone, 0.78)
    Theme.text(game.fonts.menuTiny, "REWARD: 500 GOLD", 36, 594, 292, "center", Theme.colors.gold)
end

function Menu:drawHero()
    local game = self.game
    local pulse = 0.5 + 0.5 * math.sin(self.time * 2.8)

    love.graphics.setBlendMode("add")
    love.graphics.setColor(0.22, 0.08, 0.02, 0.16)
    love.graphics.circle("fill", 632, 282, 205)
    love.graphics.setColor(0.08, 0.42, 0.10, 0.12 + pulse * 0.06)
    love.graphics.circle("fill", 635, 275, 155)
    love.graphics.setBlendMode("alpha")

    if game.images and game.images.character then
        Theme.quad(game.images.character, 420, 150, 700, 760, 460, 118, 360, 292, 0.98)
    else
        Theme.brainIcon(game, 540, 160, 190, 1)
    end

    local btnX, btnY, btnW, btnH = 405, 462, 468, 68
    for i, button in ipairs(self.buttons) do
        local y = btnY + (i - 1) * 88
        Theme.button(button.label, btnX, y, btnW, btnH, self.selected == i, game.fonts, {disabled = i == 2 and false})
        Theme.text(game.fonts.menuTiny, button.sub, btnX, y + 47, btnW, "center", i == 1 and Theme.colors.gold or Theme.colors.muted, 0.95)
        table.insert(self.hotspots, {x = btnX, y = y, w = btnW, h = btnH, button = button})
    end
end

function Menu:drawRightCodex()
    local game = self.game
    local hs = Save.getHighScore()

    Theme.panel(930, 126, 324, 284, "TOME OF RECORDS", game.fonts)
    Theme.statRow(game.fonts, "TOTAL SOULS", hs, 952, 188, 278, Theme.colors.red)
    Theme.statRow(game.fonts, "MAX COMBO", 0, 952, 236, 278, Config.COLOR_COMBO)
    Theme.statRow(game.fonts, "CORRUPTION", 0, 952, 284, 278, Theme.colors.red)
    Theme.statRow(game.fonts, "LAYERS CLEARED", "0 / 10", 952, 332, 278, Theme.colors.green)

    Theme.panel(930, 436, 324, 188, "ACTIVE RUNES", game.fonts)
    Theme.text(game.fonts.menuSmall, "NO ACTIVE RUNES", 930, 526, 324, "center", Theme.colors.muted)
end

function Menu:drawFooter()
    local game = self.game
    local tip = self.noticeTime > 0 and self.notice or "RUNE TIP: BREAK FAST, THINK NEVER."
    local color = self.noticeTime > 0 and Theme.colors.red or Theme.colors.gold

    Theme.panel(420, 662, 440, 42, nil, game.fonts, {fill = {0.06, 0.045, 0.035, 0.96}, insetAlpha = 0.25})
    Theme.text(game.fonts.menuTiny, tip, 420, 677, 440, "center", color)
    Theme.text(game.fonts.menuTiny, "v0.4 Got Hit Edition", 20, 690, 220, "left", Theme.colors.muted, 0.75)
end

function Menu:activate(button)
    if not button then return end
    local action = button.action
    if self.game.audio then
        self.game.audio:play("bonk", {volume = 0.35})
    end

    if action == "play" then
        self.sm:switch("playing", self.game, self.sm, true, {endless = false})
    elseif action == "endless" then
        self.sm:switch("playing", self.game, self.sm, true, {endless = true})
    elseif action == "settings" then
        self.sm:push("settings", self.game, self.sm)
    elseif action == "quit" then
        love.event.quit()
    else
        self.notice = (button.label or "FEATURE") .. " SEALED"
        self.noticeTime = 1.6
    end
end

function Menu:keypressed(key)
    if key == "up" or key == "w" then
        self.selected = ((self.selected - 2) % #self.buttons) + 1
    elseif key == "down" or key == "s" then
        self.selected = (self.selected % #self.buttons) + 1
    elseif key == "return" or key == "space" then
        self:activate(self.buttons[self.selected])
    elseif key == "tab" then
        self:activate({action = "settings", label = "SETTINGS"})
    elseif key == "q" then
        self:activate({action = "quit", label = "QUIT"})
    end
end

function Menu:mousepressed(x, y, button)
    if button ~= 1 then return end
    for _, hotspot in ipairs(self.hotspots or {}) do
        if x >= hotspot.x and x <= hotspot.x + hotspot.w
            and y >= hotspot.y and y <= hotspot.y + hotspot.h then
            self:activate(hotspot.button)
            return
        end
    end
end

return Menu
