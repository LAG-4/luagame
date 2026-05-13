-- Main menu rebuilt around a Blizzard Dark Fantasy / Gothic aesthetic
local Config = require("config")
local Save = require("lib.save")

local Menu = {}

local function rgba(color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha or color[4] or 1)
end

local function image(game, name)
    return game.images and game.images[name]
end

local function drawImageFit(img, x, y, w, h, alpha)
    if not img then return end
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function drawImageCover(img, x, y, w, h, alpha)
    if not img then return end
    local iw, ih = img:getDimensions()
    local scale = math.max(w / iw, h / ih)
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x + (w - iw * scale) / 2, y + (h - ih * scale) / 2, 0, scale, scale)
end

local function drawQuad(img, sx, sy, sw, sh, x, y, w, h, alpha)
    if not img then return end
    local quad = love.graphics.newQuad(sx, sy, sw, sh, img:getDimensions())
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, quad, x, y, 0, w / sw, h / sh)
end

local function drawTextShadow(font, text, x, y, w, align, color)
    love.graphics.setFont(font)
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.8)
    if align then
        love.graphics.printf(text, x + 2, y + 2, w, align)
    else
        love.graphics.print(text, x + 2, y + 2)
    end
    -- Text
    rgba(color, 1)
    if align then
        love.graphics.printf(text, x, y, w, align)
    else
        love.graphics.print(text, x, y)
    end
end

local function drawStonePanel(x, y, w, h, title, game)
    -- Drop shadow
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x + 4, y + 4, w, h, 2, 2)
    
    -- Stone base
    love.graphics.setColor(Config.COLOR_PANEL)
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    
    -- Inner inset (darker)
    local insetY = title and y + 34 or y + 4
    local insetH = title and h - 40 or h - 8
    love.graphics.setColor(0.04, 0.03, 0.02, 0.8)
    love.graphics.rectangle("fill", x + 6, insetY, w - 12, insetH, 2, 2)
    
    -- Gold bevel/border
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 2, 2)
    love.graphics.setLineWidth(1)

    if title and game then
        love.graphics.setColor(Config.COLOR_PANEL_BORDER[1], Config.COLOR_PANEL_BORDER[2], Config.COLOR_PANEL_BORDER[3], 0.4)
        love.graphics.line(x + 6, y + 28, x + w - 6, y + 28)
        drawTextShadow(game.fonts.menuSmall or game.fonts.small, title, x, y + 8, w, "center", Config.COLOR_GOLD)
    end

    -- Corners (rivets)
    love.graphics.setColor(0.1, 0.08, 0.06)
    love.graphics.circle("fill", x + 4, y + 4, 3)
    love.graphics.circle("fill", x + w - 4, y + 4, 3)
    love.graphics.circle("fill", x + 4, y + h - 4, 3)
    love.graphics.circle("fill", x + w - 4, y + h - 4, 3)
end

local function drawStoneButton(menu, button, index, x, y, w, h)
    local game = menu.game
    local selected = menu.selected == index
    local bgColor = selected and {0.2, 0.05, 0.05} or {0.08, 0.07, 0.06}
    local borderColor = selected and Config.COLOR_ACCENT or Config.COLOR_PANEL_BORDER
    local textColor = selected and Config.COLOR_CREAM or Config.COLOR_MUTED

    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x + 4, y + 4, w, h, 4, 4)

    -- Base
    rgba(bgColor, 1)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)

    -- Highlight effect if selected
    if selected then
        rgba(Config.COLOR_ACCENT, 0.15 + 0.08 * math.sin(menu.time * 5))
        love.graphics.rectangle("fill", x + 2, y + 2, w - 4, h - 4, 2, 2)
    end

    -- Border
    rgba(borderColor, selected and 1 or 0.8)
    love.graphics.setLineWidth(selected and 3 or 2)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)
    love.graphics.setLineWidth(1)

    -- Label
    drawTextShadow(game.fonts.menuButton or game.fonts.large, button.label, x, y + h/2 - 14, w, "center", textColor)

    table.insert(menu.hotspots, {x = x, y = y, w = w, h = h, button = button})
end

local function drawTopAction(menu, x, y, w, h, label, icon, action)
    local game = menu.game
    drawStonePanel(x, y, w, h)
    drawTextShadow(game.fonts.menuIcon or game.fonts.large, icon, x, y + 10, w, "center", Config.COLOR_CREAM)
    drawTextShadow(game.fonts.menuTiny or game.fonts.small, label, x, y + h - 22, w, "center", Config.COLOR_GOLD)
    table.insert(menu.hotspots, {x = x, y = y, w = w, h = h, button = {action = action, label = label}})
end

local function drawStatBadge(game, x, y, w, h, label, value, color)
    drawStonePanel(x, y, w, h)
    drawTextShadow(game.fonts.menuTiny or game.fonts.small, label, x, y + 8, w, "center", Config.COLOR_GOLD)
    drawTextShadow(game.fonts.menuLarge or game.fonts.large, tostring(value), x, y + 26, w, "center", color)
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
        {label = "ENTER DUNGEON (ARCADE)", action = "play"},
        {label = "DESCEND (ENDLESS)", action = "endless"},
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
    
    -- Dark textured background
    drawImageCover(image(game, "background"), 0, 0, W, H, 0.4)
    love.graphics.setColor(0, 0, 0, 0.75)
    love.graphics.rectangle("fill", 0, 0, W, H)
    drawImageCover(image(game, "scratchedMetal"), 0, 0, W, H, 0.25)

    -- Subtle red glowing overlays
    love.graphics.setBlendMode("add")
    drawQuad(image(game, "glowingOverlays"), 210, 80, 430, 220, 72, 106, 270, 128, 0.15)
    drawQuad(image(game, "glowingOverlays"), 520, 335, 440, 370, 430, 92, 470, 270, 0.15)
    love.graphics.setBlendMode("alpha")

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

    drawStonePanel(18, 18, 320, 78)
    
    -- Player avatar
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", 30, 26, 62, 62, 2, 2)
    drawQuad(image(game, "brainLogo"), 470, 190, 620, 660, 32, 28, 58, 58, 0.9)

    -- Player text
    drawTextShadow(game.fonts.menuSmall or game.fonts.small, "PLAYER", 108, 28, 200, "left", Config.COLOR_CREAM)
    drawTextShadow(game.fonts.menuSmall or game.fonts.small, "LEVEL 1 CORRUPTED", 108, 48, 200, "left", Config.COLOR_ACCENT)

    -- Stat badges
    drawStatBadge(game, 360, 22, 160, 70, "CORRUPTION", 0, Config.COLOR_ACCENT)
    drawStatBadge(game, 540, 22, 160, 70, "MAX COMBO", 0, Config.COLOR_COMBO)
    drawStatBadge(game, 720, 22, 160, 70, "DEEPEST LAYER", math.max(hsEndless, hs), Config.COLOR_GREEN_BRIGHT)

    -- Top action buttons
    drawTopAction(self, 940, 22, 92, 70, "SETTINGS", "O", "settings")
    drawTopAction(self, 1048, 22, 92, 70, "QUIT", "X", "quit")
end

function Menu:drawLeftColumn()
    local game = self.game

    drawStonePanel(18, 120, 320, 320)
    
    local logoW = 280
    if image(game, "brainrotLogo") then
        drawQuad(image(game, "brainrotLogo"), 270, 250, 1000, 360, 38, 140, logoW, logoW * 0.36, 1)
        drawQuad(image(game, "breakerLogo"), 270, 350, 1000, 330, 38, 140 + logoW * 0.36, logoW, logoW * 0.33, 0.96)
    else
        drawTextShadow(game.fonts.large, "BRAINROT", 18, 160, 320, "center", Config.COLOR_ACCENT)
        drawTextShadow(game.fonts.large, "BREAKER", 18, 210, 320, "center", Config.COLOR_GOLD)
    end
    
    drawTextShadow(game.fonts.menuArcade or game.fonts.small, "ARCADE", 18, 380, 320, "center", Config.COLOR_GREEN_BRIGHT)

    -- Daily Quest
    drawStonePanel(18, 460, 320, 160, "DAILY QUEST", game)
    drawTextShadow(game.fonts.menuTiny or game.fonts.small, "DESTROY 200 MEMES\nWITHOUT DYING", 36, 520, 280, "center", Config.COLOR_CREAM)
    drawTextShadow(game.fonts.menuTiny or game.fonts.small, "REWARD: 500 GOLD", 36, 580, 280, "center", Config.COLOR_GOLD)
end

function Menu:drawHero()
    local game = self.game

    -- Center Hero Graphic
    drawQuad(image(game, "character"), 420, 150, 700, 760, 456, 120, 370, 292, 0.95)

    -- Buttons
    local x, y, w, h = 404, 460, 464, 64
    for i, button in ipairs(self.buttons) do
        drawStoneButton(self, button, i, x, y + (i - 1) * 84, w, h)
    end
end

function Menu:drawRightColumn()
    local game = self.game
    local hs = Save.getHighScore()

    drawStonePanel(930, 120, 322, 280, "TOME OF RECORDS", game)
    local rows = {
        {"TOTAL SOULS", hs, Config.COLOR_ACCENT},
        {"MAX COMBO", 0, Config.COLOR_COMBO},
        {"CORRUPTION", 0, Config.COLOR_ACCENT},
        {"LAYERS CLEARED", "0 / 10", Config.COLOR_GREEN_BRIGHT},
    }
    
    for i, row in ipairs(rows) do
        local yy = 180 + (i - 1) * 45
        drawTextShadow(game.fonts.menuTiny or game.fonts.small, row[1], 952, yy, 280, "left", Config.COLOR_CREAM)
        drawTextShadow(game.fonts.menuSmall or game.fonts.small, tostring(row[2]), 952, yy - 4, 280, "right", row[3])
        love.graphics.setColor(Config.COLOR_PANEL_BORDER[1], Config.COLOR_PANEL_BORDER[2], Config.COLOR_PANEL_BORDER[3], 0.2)
        love.graphics.line(952, yy + 30, 1232, yy + 30)
    end

    drawStonePanel(930, 420, 322, 200, "ACTIVE RUNES", game)
    drawTextShadow(game.fonts.menuSmall or game.fonts.small, "NO ACTIVE RUNES", 930, 520, 322, "center", Config.COLOR_MUTED)
end

function Menu:drawFooter()
    local game = self.game
    local tip = self.noticeTime > 0 and self.notice or "RUNE TIP: BREAK FAST, THINK NEVER."
    local color = self.noticeTime > 0 and Config.COLOR_ACCENT or Config.COLOR_GOLD

    drawStonePanel(424, 664, 430, 42)
    drawTextShadow(game.fonts.menuTiny or game.fonts.small, tip, 424, 678, 430, "center", color)

    drawTextShadow(game.fonts.menuTiny or game.fonts.small, "v0.4 Gothic Edition", 20, 690, 200, "left", Config.COLOR_MUTED)
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
