-- Main menu — dark gothic horror, sidebar layout, multiple buttons
local Config = require("config")
local Menu = {}

function Menu:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
    self.selected = 1
    self.buttons = {
        { label = "PLAY ARCADE",   icon = "▶", action = "play" },
        { label = "ENDLESS MODE",  icon = "∞", action = "endless" },
        { label = "SETTINGS",      icon = "⚙", action = "settings" },
        { label = "QUIT",          icon = "✕", action = "quit" },
    }
end

function Menu:update(dt) self.time = (self.time or 0) + dt end

function Menu:draw()
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    love.graphics.setColor(0.025, 0.022, 0.021, 1)
    love.graphics.rectangle("fill", 0, 0, W, H)
    for i = 0, 26 do
        local x = i * 53
        love.graphics.setColor(0.09, 0.085, 0.075, 0.13)
        love.graphics.line(x, 0, x + 140, H)
    end
    love.graphics.setColor(0.45, 0.02, 0.015, 0.12)
    love.graphics.circle("fill", W * 0.52, H * 0.38, 185)
    love.graphics.setColor(0.02, 0.018, 0.016, 0.62)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Atmospheric bg text
    love.graphics.setFont(self.game.fonts.large)
    love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2], Config.COLOR_ACCENT[3], 0.03)
    love.graphics.print("NO THOUGHTS", 300, 100, -0.15, 2, 2)
    love.graphics.print("HEAD EMPTY", 600, 400, 0.1, 2.5, 2.5)
    love.graphics.print("BRAINROT", 200, 500, 0.2, 1.8, 1.8)

    -- Left panel (title area)
    love.graphics.setColor(Config.COLOR_PANEL[1], Config.COLOR_PANEL[2], Config.COLOR_PANEL[3], 0.78)
    love.graphics.rectangle("fill", 0, 0, 320, H)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", 318, 0, 2, H)

    -- Title
    love.graphics.setFont(self.game.fonts.large)
    love.graphics.setColor(Config.COLOR_ACCENT)
    love.graphics.printf("BRAINROT", 20, 60, 280, "center")
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.printf("BREAKER", 20, 95, 280, "center")

    love.graphics.setFont(self.game.fonts.main)
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.5)
    love.graphics.printf("ARCADE", 20, 130, 280, "center")

    -- Stats overview (in left panel)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", 20, 180, 280, 1)

    love.graphics.setFont(self.game.fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)

    local Save = require("lib.save")
    local hs = Save.getHighScore()
    local hsEndless = Save.getHighScoreEndless()
    love.graphics.print("HIGH SCORE: " .. hs, 20, 200)
    love.graphics.print("HIGH SCORE (ENDLESS): " .. hsEndless, 20, 218)
    love.graphics.print("v0.7 - Vertical Slice", 20, H - 25)

    -- Center: Buttons
    local btnW, btnH = 320, 48
    local startX = W / 2 - btnW / 2 + 30
    local startY = H / 2 - (#self.buttons * (btnH + 12)) / 2

    love.graphics.setFont(self.game.fonts.main)

    for i, btn in ipairs(self.buttons) do
        local y = startY + (i - 1) * (btnH + 12)
        local isSelected = (i == self.selected)

        -- Button shadow
        love.graphics.setColor(0, 0, 0, 0.4)
        love.graphics.rectangle("fill", startX + 3, y + 3, btnW, btnH, 6, 6)

        -- Button bg
        if isSelected then
            love.graphics.setColor(Config.COLOR_ACCENT[1]*0.3, Config.COLOR_ACCENT[2]*0.3,
                                   Config.COLOR_ACCENT[3]*0.3, 0.9)
        else
            love.graphics.setColor(Config.COLOR_CARD_BG)
        end
        love.graphics.rectangle("fill", startX, y, btnW, btnH, 6, 6)

        -- Border
        if isSelected then
            local pulse = 0.5 + 0.3 * math.sin((self.time or 0) * 4)
            love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2],
                                   Config.COLOR_ACCENT[3], 0.6 + pulse * 0.4)
        else
            love.graphics.setColor(Config.COLOR_PANEL_BORDER)
        end
        love.graphics.rectangle("line", startX, y, btnW, btnH, 6, 6)

        -- Icon
        love.graphics.setColor(isSelected and Config.COLOR_GOLD or Config.COLOR_MUTED)
        love.graphics.print(btn.icon, startX + 15, y + 13)

        -- Label
        love.graphics.setColor(isSelected and Config.COLOR_CREAM or Config.COLOR_MUTED)
        love.graphics.printf(btn.label, startX + 40, y + 14, btnW - 60, "left")

        -- Selection arrow
        if isSelected then
            love.graphics.setColor(Config.COLOR_ACCENT)
            love.graphics.printf("►", startX, y + 14, btnW - 15, "right")
        end
    end

    -- Right panel: tips
    love.graphics.setFont(self.game.fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.printf("TIP: BREAK FAST, THINK NEVER.", 0, H - 30, W, "center")
end

function Menu:keypressed(key)
    -- Gamepad navigation
    if key == "joystickup" or key == "joystick1up" then
        key = "up"
    elseif key == "joystickdown" or key == "joystick1down" then
        key = "down"
    elseif key == "joystick1button0" or key == "space" then
        key = "return"
    end

    if key == "up" or key == "w" then
        self.selected = ((self.selected - 2) % #self.buttons) + 1
    elseif key == "down" or key == "s" then
        self.selected = (self.selected % #self.buttons) + 1
    elseif key == "return" or key == "space" then
        local action = self.buttons[self.selected].action
        if action == "play" then
            self.sm:switch("playing", self.game, self.sm, {endless = false})
        elseif action == "endless" then
            self.sm:switch("playing", self.game, self.sm, {endless = true})
        elseif action == "settings" then
            self.sm:push("settings", self.game, self.sm)
        elseif action == "quit" then
            love.event.quit()
        end
    elseif key == "q" then
        love.event.quit()
    end
end

return Menu
