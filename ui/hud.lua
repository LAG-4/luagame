-- Gothic sidebar HUD — Blizzard Dark Fantasy style
local Config = require("config")
local HUD = {}

local function rgba(color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha or color[4] or 1)
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

local function drawStonePanel(x, y, w, h)
    -- Drop shadow
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", x + 4, y + 4, w, h, 2, 2)
    
    -- Stone base
    love.graphics.setColor(Config.COLOR_PANEL)
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)
    
    -- Inner inset (darker)
    love.graphics.setColor(0.04, 0.03, 0.02, 0.8)
    love.graphics.rectangle("fill", x + 6, y + 30, w - 12, h - 36, 2, 2)
    
    -- Gold bevel/border
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x, y, w, h, 2, 2)
    love.graphics.setLineWidth(1)
    
    -- Title area line
    love.graphics.setColor(Config.COLOR_PANEL_BORDER[1], Config.COLOR_PANEL_BORDER[2], Config.COLOR_PANEL_BORDER[3], 0.4)
    love.graphics.line(x + 6, y + 28, x + w - 6, y + 28)

    -- Corners (rivets)
    love.graphics.setColor(0.1, 0.08, 0.06)
    love.graphics.circle("fill", x + 4, y + 4, 2)
    love.graphics.circle("fill", x + w - 4, y + 4, 2)
    love.graphics.circle("fill", x + 4, y + h - 4, 2)
    love.graphics.circle("fill", x + w - 4, y + h - 4, 2)
end

function HUD.draw(game, fonts)
    local W = Config.GAME_WIDTH
    local H = Config.GAME_HEIGHT
    local SW = Config.SIDEBAR_WIDTH

    -- ═══ LEFT SIDEBAR PILLAR ═══
    -- Pillar base
    love.graphics.setColor(Config.COLOR_HUD_BG)
    love.graphics.rectangle("fill", 0, 0, SW, H)
    
    -- Pillar border (thick gold/bronze edge)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", SW - 4, 0, 4, H)
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", SW - 1, 0, 1, H) -- deepest shadow on edge

    -- Title area using images or gothic text
    local logoW = SW - 32
    if game.images and game.images.brainrotLogo then
        -- Draw with shadow if possible, otherwise just draw
        love.graphics.setColor(1, 1, 1, 1)
        local iw, ih = game.images.brainrotLogo:getDimensions()
        local scale = logoW / iw
        love.graphics.draw(game.images.brainrotLogo, 16, 12, 0, scale, scale)
        
        iw, ih = game.images.breakerLogo:getDimensions()
        scale = (logoW * 0.8) / iw
        love.graphics.draw(game.images.breakerLogo, 24, 45, 0, scale, scale)
    else
        drawTextShadow(fonts.large, "BRAINROT", 8, 10, SW - 16, "center", Config.COLOR_ACCENT)
        drawTextShadow(fonts.main, "BREAKER", 8, 38, SW - 16, "center", Config.COLOR_MUTED)
    end

    drawTextShadow(game.fonts.menuArcade or fonts.small, "ARCADE", 0, 80, SW, "center", Config.COLOR_GREEN_BRIGHT)

    -- ═══ STATS PLAQUE ═══
    local statsY = 120
    drawStonePanel(12, statsY, SW - 24, 150)
    drawTextShadow(game.fonts.menuSmall or fonts.small, "HERO STATS", 12, statsY + 8, SW - 24, "center", Config.COLOR_GOLD)

    local function drawStatRow(y, label, value, color)
        drawTextShadow(game.fonts.menuTiny or fonts.small, label, 20, y, SW, nil, Config.COLOR_CREAM)
        drawTextShadow(fonts.main, tostring(value), 16, y - 2, SW - 40, "right", color)
    end

    drawStatRow(statsY + 40, "SCORE", math.floor(game.score), Config.COLOR_SCORE)
    drawStatRow(statsY + 70, "COMBO", game.combo, Config.COLOR_COMBO)
    
    local br = game.brainrotLevel
    local brColor = br > 0 and Config.COLOR_ACCENT or Config.COLOR_MUTED
    drawStatRow(statsY + 100, "CORRUPTION", br, brColor)

    -- ═══ LIVES ═══
    local livesY = statsY + 165
    drawStonePanel(12, livesY, SW - 24, 80)
    drawTextShadow(game.fonts.menuSmall or fonts.small, "VITALITY", 12, livesY + 8, SW - 24, "center", Config.COLOR_GOLD)
    
    love.graphics.setFont(game.fonts.menuIcon or fonts.large)
    local livesStr = ""
    for i = 1, Config.STARTING_LIVES do
        livesStr = livesStr .. (i <= game.lives and "O " or "X ") -- Orbs instead of hearts
    end
    drawTextShadow(game.fonts.menuIcon or fonts.large, livesStr, 12, livesY + 40, SW - 24, "center", Config.COLOR_ACCENT)

    -- ═══ POWER UPS PANEL ═══
    local mods = game.modifiers:getUnique()
    local pwY = livesY + 95
    drawStonePanel(12, pwY, SW - 24, math.max(70, #mods * 22 + 48))
    drawTextShadow(game.fonts.menuSmall or fonts.small, "ACTIVE BUFFS", 12, pwY + 8, SW - 24, "center", Config.COLOR_GOLD)

    if #mods > 0 then
        for i, name in ipairs(mods) do
            local count = game.modifiers:count(name)
            drawTextShadow(game.fonts.menuTiny or fonts.small, "◆ " .. name, 20, pwY + 40 + (i-1)*22, SW, nil, Config.COLOR_CREAM)
            if count > 1 then
                drawTextShadow(game.fonts.menuTiny or fonts.small, "x"..tostring(count), 20, pwY + 40 + (i-1)*22, SW - 40, "right", Config.COLOR_COMBO)
            end
        end
    else
        drawTextShadow(game.fonts.menuTiny or fonts.small, "NONE", 12, pwY + 40, SW - 24, "center", Config.COLOR_MUTED)
    end

    -- ═══ TOP BAR (over play area) ═══
    -- Dark gradient/bar at top
    love.graphics.setColor(0, 0, 0, 0.85)
    love.graphics.rectangle("fill", SW, 0, W - SW, Config.TOP_BAR_HEIGHT)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", SW, Config.TOP_BAR_HEIGHT - 4, W - SW, 4)
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", SW, Config.TOP_BAR_HEIGHT - 4, W - SW, 1)

    -- Stage indicator (centered in play area)
    local playCenter = SW + (W - SW) / 2
    local stageText = "STAGE " .. game.stage
    if game.isEndless then stageText = "ENDLESS " .. game.stage end
    local stw = (game.fonts.menuSmall or fonts.main):getWidth(stageText) + 60

    -- Banner dropping down
    love.graphics.setColor(Config.COLOR_PANEL)
    love.graphics.polygon("fill", 
        playCenter - stw/2, 0, 
        playCenter + stw/2, 0, 
        playCenter + stw/2, 45, 
        playCenter, 55, 
        playCenter - stw/2, 45)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line", 
        playCenter - stw/2, 0, 
        playCenter + stw/2, 0, 
        playCenter + stw/2, 45, 
        playCenter, 55, 
        playCenter - stw/2, 45)
    love.graphics.setLineWidth(1)
    
    drawTextShadow(game.fonts.menuSmall or fonts.main, stageText, playCenter - stw/2, 18, stw, "center", Config.COLOR_GOLD)

    -- ═══ BOTTOM-RIGHT ACTIVE MODIFIER ═══
    if #mods > 0 then
        local modW, modH = 260, 68
        local mx = W - modW - 15
        local my = H - modH - 15
        drawStonePanel(mx, my, modW, modH)
        drawTextShadow(game.fonts.menuSmall or fonts.small, "CURRENT RUNE", mx, my + 8, modW, "center", Config.COLOR_GOLD)
        drawTextShadow(game.fonts.menuSmall or fonts.main, mods[#mods], mx, my + 35, modW, "center", Config.COLOR_GREEN_BRIGHT)
    end
end

return HUD
