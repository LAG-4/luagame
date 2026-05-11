-- Main menu rebuilt around the supplied home-screen reference assets.
local Config = require("config")
local Save = require("lib.save")

local Menu = {}

local RED     = {0.88, 0.08, 0.05}
local ORANGE  = {0.95, 0.44, 0.06}
local GREEN   = {0.30, 0.86, 0.02}
local PURPLE  = {0.55, 0.18, 1.00}
local CREAM   = {0.82, 0.77, 0.68}
local MUTED   = {0.48, 0.44, 0.38}
local PANEL   = {0.015, 0.014, 0.013}
local BORDER  = {0.32, 0.26, 0.18}

local function rgba(color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function image(game, name)
    return game.images and game.images[name]
end

local function drawImageCover(img, x, y, w, h, alpha)
    if not img then return end
    local iw, ih = img:getDimensions()
    local scale = math.max(w / iw, h / ih)
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x + (w - iw * scale) / 2, y + (h - ih * scale) / 2, 0, scale, scale)
end

local function drawImageFit(img, x, y, w, h, alpha)
    if not img then return end
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function drawQuad(img, sx, sy, sw, sh, x, y, w, h, alpha)
    if not img then return end
    local quad = love.graphics.newQuad(sx, sy, sw, sh, img:getDimensions())
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, quad, x, y, 0, w / sw, h / sh)
end

local function drawProgressBar(x, y, w, h, amount, color)
    love.graphics.setColor(0.10, 0.10, 0.09, 0.95)
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("line", x, y, w, h, 2, 2)
    rgba(color, 0.88)
    love.graphics.rectangle("fill", x + 2, y + 2, math.max(0, (w - 4) * amount), h - 4, 1, 1)
end

local function drawPanel(game, x, y, w, h, title, accent)
    love.graphics.setColor(PANEL[1], PANEL[2], PANEL[3], 0.82)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", x + 4, y + 34, w - 8, h - 40, 2, 2)

    drawImageFit(image(game, "frame"), x - 12, y - 15, w + 24, h + 30, 0.28)
    if w >= 90 and h >= 48 then
        drawImageFit(image(game, "cornerTop"), x + w - 64, y - 8, 64, 48, 0.34)
        drawImageFit(image(game, "cornerBottom"), x - 7, y + h - 40, 50, 40, 0.30)
    end

    rgba(accent or BORDER, 0.85)
    love.graphics.setLineWidth(1.2)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
    love.graphics.setLineWidth(1)

    if title then
        love.graphics.setFont(game.fonts.menuSmall)
        rgba(accent or CREAM, 1)
        love.graphics.print(title, x + 16, y + 14)
        love.graphics.setColor(1, 1, 1, 0.08)
        love.graphics.rectangle("fill", x + 12, y + 39, w - 24, 1)
    end
end

local function drawStatBadge(game, x, y, w, h, label, value, accent, iconText)
    drawPanel(game, x, y, w, h, nil, accent)
    love.graphics.setFont(game.fonts.menuIcon)
    rgba(accent, 1)
    love.graphics.printf(iconText, x + 8, y + 15, 34, "center")

    love.graphics.setFont(game.fonts.menuTiny)
    rgba(accent, 1)
    love.graphics.printf(label, x + 44, y + 12, w - 52, "left")
    love.graphics.setFont(game.fonts.menuLarge)
    rgba(CREAM, 1)
    love.graphics.printf(tostring(value), x + 44, y + 29, w - 52, "left")
end

local function drawMenuButton(menu, button, index, x, y, w, h)
    local game = menu.game
    local selected = menu.selected == index
    local accent = selected and RED or BORDER
    local points = {
        x + 22, y,
        x + w - 24, y,
        x + w, y + h / 2,
        x + w - 24, y + h,
        x + 22, y + h,
        x, y + h / 2,
    }

    love.graphics.setColor(0, 0, 0, 0.58)
    love.graphics.polygon("fill", points)
    if selected then
        love.graphics.setColor(0.42, 0.02, 0.01, 0.88)
        love.graphics.polygon("fill", points)
        rgba(RED, 0.22 + 0.12 * math.sin(menu.time * 5))
        love.graphics.rectangle("fill", x + 28, y + 5, w - 58, h - 10, 2, 2)
    end

    rgba(accent, selected and 0.95 or 0.65)
    love.graphics.setLineWidth(selected and 2 or 1)
    love.graphics.polygon("line", points)
    love.graphics.setLineWidth(1)

    love.graphics.setFont(game.fonts.menuButton)
    rgba(selected and CREAM or {0.66, 0.61, 0.55}, button.disabled and 0.55 or 1)
    love.graphics.printf(button.label, x + 58, y + 12, w - 116, "center")

    love.graphics.setFont(game.fonts.menuIcon)
    rgba(selected and CREAM or MUTED, button.disabled and 0.45 or 0.95)
    love.graphics.printf(button.icon, x + w - 62, y + 11, 36, "center")

    table.insert(menu.hotspots, {x = x, y = y, w = w, h = h, button = button})
end

local function drawTopAction(menu, x, y, w, h, label, icon, action)
    local game = menu.game
    drawPanel(game, x, y, w, h, nil, BORDER)
    love.graphics.setFont(game.fonts.menuIcon)
    rgba(CREAM, 0.86)
    love.graphics.printf(icon, x, y + 13, w, "center")
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(CREAM, 0.8)
    love.graphics.printf(label, x, y + h - 22, w, "center")
    table.insert(menu.hotspots, {x = x, y = y, w = w, h = h, button = {action = action, label = label}})
end

local function drawNewsItem(game, x, y, w, title, body, date, accent, icon)
    love.graphics.setColor(0.02, 0.02, 0.018, 0.88)
    love.graphics.rectangle("fill", x, y, w, 68, 3, 3)
    love.graphics.setColor(1, 1, 1, 0.06)
    love.graphics.rectangle("line", x, y, w, 68, 3, 3)

    love.graphics.setFont(game.fonts.menuIcon)
    rgba(accent, 0.95)
    love.graphics.printf(icon, x + 8, y + 18, 44, "center")

    love.graphics.setFont(game.fonts.menuSmall)
    rgba(accent, 1)
    love.graphics.print(title, x + 62, y + 12)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(CREAM, 0.78)
    love.graphics.printf(body, x + 62, y + 31, w - 72, "left")
    rgba(MUTED, 0.82)
    love.graphics.print(date, x + 62, y + 50)
end

function Menu:enter(game, sm)
    self.game = game
    self.sm = sm
    self.time = 0
    self.selected = 1
    self.notice = nil
    self.noticeTime = 0
    self.hotspots = {}
    self.buttons = {
        {label = "PLAY ARCADE", icon = ">", action = "play"},
        {label = "STAGE SELECT", icon = "::", action = "soon", disabled = true},
        {label = "ENDLESS MODE", icon = "∞", action = "endless"},
        {label = "CUSTOM GAME", icon = "x", action = "soon", disabled = true},
        {label = "COLLECTION", icon = "o", action = "soon", disabled = true},
        {label = "SHOP", icon = "$", action = "soon", disabled = true},
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

    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)
    drawImageCover(image(game, "background"), 0, 0, W, H, 1)
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", 0, 0, W, H)
    drawImageCover(image(game, "scratchedMetal"), 0, 0, W, H, 0.12)

    drawQuad(image(game, "glowingOverlays"), 210, 80, 430, 220, 72, 106, 270, 128, 0.34)
    drawQuad(image(game, "glowingOverlays"), 520, 335, 440, 370, 430, 92, 470, 270, 0.28)
    drawQuad(image(game, "glowingOverlays"), 1080, 640, 360, 270, 980, 418, 270, 190, 0.22)
    drawImageFit(image(game, "bloodOverlay"), 430, 76, 430, 285, 0.16)

    drawQuad(image(game, "noThoughts"), 520, 145, 540, 690, 330, 95, 170, 180, 0.10)
    drawQuad(image(game, "iPutThePro"), 100, 120, 660, 620, 780, 126, 210, 170, 0.10)
    drawQuad(image(game, "iPutThePro"), 840, 220, 520, 650, 742, 206, 170, 170, 0.08)

    self:drawTopBar()
    self:drawLeftColumn()
    self:drawHero()
    self:drawRightColumn()
    self:drawFooter()
end

function Menu:drawTopBar()
    local game = self.game
    local hs = Save.getHighScore()
    local hsEndless = Save.getHighScoreEndless()

    drawPanel(game, 18, 18, 320, 78, nil, BORDER)
    love.graphics.setColor(0.03, 0.028, 0.024, 1)
    love.graphics.rectangle("fill", 32, 29, 58, 58, 4, 4)
    drawQuad(image(game, "brainLogo"), 470, 190, 620, 660, 25, 17, 74, 76, 0.96)

    love.graphics.setFont(game.fonts.menuSmall)
    rgba(CREAM, 1)
    love.graphics.print("SIGMA SKIBIDI", 108, 30)
    rgba(RED, 1)
    love.graphics.print("LEVEL 1 BRAINDEAD", 108, 51)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(MUTED, 1)
    love.graphics.print("420 / 1000 XP", 108, 70)
    drawProgressBar(108, 83, 204, 8, 0.42, RED)

    drawStatBadge(game, 430, 20, 130, 64, "BRAINROT", 0, RED, "@")
    drawStatBadge(game, 580, 20, 120, 64, "COMBO", 0, ORANGE, "^")
    drawStatBadge(game, 720, 20, 150, 64, "BEST STAGE", math.max(hsEndless, hs), GREEN, "|>")

    drawTopAction(self, 930, 20, 92, 70, "LEADERS", "[]", "soon")
    drawTopAction(self, 1038, 20, 92, 70, "SETTINGS", "*", "settings")
    drawTopAction(self, 1146, 20, 92, 70, "QUIT", "X", "quit")
end

function Menu:drawLeftColumn()
    local game = self.game

    drawQuad(image(game, "brainrotLogo"), 270, 250, 1000, 360, 28, 118, 315, 116, 1)
    drawQuad(image(game, "breakerLogo"), 270, 350, 1000, 330, 80, 210, 230, 82, 0.96)
    love.graphics.setFont(game.fonts.menuArcade)
    rgba(GREEN, 1)
    love.graphics.printf("ARCADE", 112, 284, 158, "center")

    drawPanel(game, 18, 318, 328, 130, "DAILY CHALLENGE", RED)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(CREAM, 0.9)
    love.graphics.printf("DESTROY 200 BLOCKS WITHOUT\nLOSING A BALL", 36, 358, 210, "left")
    rgba(MUTED, 1)
    love.graphics.print("REWARD", 36, 410)
    rgba(RED, 1)
    love.graphics.print("500 BRAINROT", 92, 410)
    drawProgressBar(36, 430, 282, 10, 0, RED)
    drawQuad(image(game, "brainLogo"), 470, 190, 620, 660, 258, 350, 54, 58, 0.95)
    rgba(CREAM, 0.75)
    love.graphics.print("23:59:59", 270, 338)

    drawPanel(game, 18, 470, 328, 168, "MODIFIERS", GREEN)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(GREEN, 1)
    love.graphics.printf("ACTIVE", 260, 490, 60, "right")
    love.graphics.setColor(0.02, 0.07, 0.01, 0.78)
    love.graphics.rectangle("fill", 34, 514, 296, 78, 3, 3)
    rgba(GREEN, 0.52)
    love.graphics.rectangle("line", 34, 514, 296, 78, 3, 3)
    drawQuad(image(game, "brainLogo"), 470, 190, 620, 660, 42, 516, 68, 72, 0.92)
    love.graphics.setFont(game.fonts.menuSmall)
    rgba(GREEN, 1)
    love.graphics.print("BRAINROT OVERDRIVE", 120, 532)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(CREAM, 0.75)
    love.graphics.print("BALL SPEED +25%", 120, 558)
    love.graphics.print("ALL MEMES TAKE MORE DAMAGE", 120, 576)

    love.graphics.setColor(0.015, 0.012, 0.015, 0.78)
    love.graphics.rectangle("fill", 34, 604, 296, 38, 3, 3)
    rgba(PURPLE, 1)
    love.graphics.print("CHAOS MODE", 120, 617)
    rgba(MUTED, 0.9)
    love.graphics.print("UNLOCK AT LEVEL 10", 214, 617)
end

function Menu:drawHero()
    local game = self.game
    drawQuad(image(game, "character"), 420, 150, 700, 760, 456, 82, 370, 292, 0.98)

    local x, y, w, h = 404, 358, 464, 44
    for i, button in ipairs(self.buttons) do
        drawMenuButton(self, button, i, x, y + (i - 1) * 52, w, h)
    end
end

function Menu:drawRightColumn()
    local game = self.game
    local hs = Save.getHighScore()
    local hsEndless = Save.getHighScoreEndless()

    drawPanel(game, 930, 118, 322, 246, "LATEST NEWS", RED)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(RED, 1)
    love.graphics.printf("VIEW ALL", 1168, 140, 60, "right")
    drawNewsItem(game, 946, 168, 292, "UPDATE 1.2", "NEW MEMES, MODIFIERS\n& CHAOS MODE", "MAY 15, 2024", RED, "@")
    drawNewsItem(game, 946, 246, 292, "NEW MODIFIER", "BRAINROT OVERDRIVE\nIS NOW LIVE!", "MAY 10, 2024", GREEN, ":)")

    drawPanel(game, 930, 394, 322, 204, "STATS OVERVIEW", GREEN)
    local rows = {
        {"@", "TOTAL SCORE", hs, RED},
        {"^", "TOTAL COMBO", 0, ORANGE},
        {"@", "TOTAL BRAINROT", 0, RED},
        {"|>", "STAGES CLEARED", "0 / 50", GREEN},
        {"^", "BEST COMBO", 0, ORANGE},
    }
    for i, row in ipairs(rows) do
        local yy = 432 + (i - 1) * 31
        love.graphics.setFont(game.fonts.menuTiny)
        rgba(row[4], 1)
        love.graphics.print(row[1], 952, yy)
        rgba(CREAM, 0.72)
        love.graphics.print(row[2], 986, yy)
        rgba(CREAM, 0.92)
        love.graphics.printf(tostring(row[3]), 1120, yy, 104, "right")
        love.graphics.setColor(1, 1, 1, 0.06)
        love.graphics.rectangle("fill", 952, yy + 22, 272, 1)
    end

    drawPanel(game, 998, 628, 254, 48, nil, PURPLE)
    love.graphics.setFont(game.fonts.menuSmall)
    rgba(PURPLE, 1)
    love.graphics.printf("JOIN OUR DISCORD", 1035, 645, 180, "center")
    love.graphics.setFont(game.fonts.menuIcon)
    love.graphics.print("D", 1018, 641)
end

function Menu:drawFooter()
    local game = self.game
    local tip = self.noticeTime > 0 and self.notice or "TIP: BREAK FAST, THINK NEVER."
    local accent = self.noticeTime > 0 and RED or BORDER

    drawPanel(game, 424, 664, 430, 42, nil, accent)
    love.graphics.setFont(game.fonts.menuTiny)
    rgba(CREAM, 0.56)
    love.graphics.printf(tip, 448, 678, 382, "center")

    local socials = {{"TK", 54}, {"IG", 142}, {"YT", 230}}
    for _, item in ipairs(socials) do
        drawPanel(game, item[2], 650, 58, 42, nil, BORDER)
        love.graphics.setFont(game.fonts.menuTiny)
        rgba(CREAM, 0.8)
        love.graphics.printf(item[1], item[2], 664, 58, "center")
    end

    love.graphics.setFont(game.fonts.menuTiny)
    rgba(MUTED, 0.72)
    love.graphics.print("v0.3 - Phase 3", 38, 700)
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
        self.notice = (button.label or "FEATURE") .. " COMING SOON"
        self.noticeTime = 1.6
    end
end

function Menu:keypressed(key)
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
