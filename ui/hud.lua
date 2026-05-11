-- Gothic sidebar HUD — matching dark horror reference design
-- Left sidebar: title, stats (score/combo/brainrot), power ups, lives
-- Top bar: stage indicator
-- Bottom-right: active modifier display
local Config = require("config")
local HUD = {}

-- Draw a dark panel with bronze border
local function drawImageFit(img, x, y, w, h, alpha)
    if not img then return end
    love.graphics.setColor(1, 1, 1, alpha or 1)
    love.graphics.draw(img, x, y, 0, w / img:getWidth(), h / img:getHeight())
end

local function drawPanel(game, x, y, w, h, borderColor)
    love.graphics.setColor(Config.COLOR_PANEL)
    love.graphics.rectangle("fill", x, y, w, h, 4, 4)
    love.graphics.setColor(borderColor or Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("line", x, y, w, h, 4, 4)

    local frame = game.images and game.images.frame
    if frame then
        drawImageFit(frame, x - 12, y - 15, w + 24, h + 30, 0.28)
    end
    local topC = game.images and game.images.cornerTop
    local botC = game.images and game.images.cornerBottom
    if topC and botC and w >= 90 and h >= 48 then
        drawImageFit(topC, x + w - 40, y - 8, 40, 30, 0.34)
        drawImageFit(botC, x - 7, y + h - 25, 30, 25, 0.30)
    end
end

function HUD.draw(game, fonts)
    local W = Config.GAME_WIDTH
    local H = Config.GAME_HEIGHT
    local SW = Config.SIDEBAR_WIDTH

    -- ═══ LEFT SIDEBAR ═══
    -- Sidebar background
    love.graphics.setColor(Config.COLOR_HUD_BG)
    love.graphics.rectangle("fill", 0, 0, SW, H)
    -- Right edge border
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", SW - 1, 0, 2, H)

    -- Title area
    love.graphics.setFont(fonts.large)
    love.graphics.setColor(Config.COLOR_ACCENT)
    love.graphics.printf("BRAINROT", 8, 10, SW - 16, "center")
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.printf("BREAKER", 8, 38, SW - 16, "center")

    -- Divider
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", 12, 62, SW - 24, 1)

    -- ═══ STATS PANEL ═══
    drawPanel(game, 8, 70, SW - 16, 115)

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.print("STATS", 16, 76)

    -- Score
    love.graphics.setFont(fonts.main)
    love.graphics.setColor(Config.COLOR_SCORE)
    love.graphics.print("⬡ SCORE", 16, 96)
    love.graphics.setColor(Config.COLOR_HUD_TEXT)
    love.graphics.printf(tostring(math.floor(game.score)), 16, 96, SW - 36, "right")

    -- Combo
    love.graphics.setColor(Config.COLOR_COMBO)
    love.graphics.print("⚡ COMBO", 16, 120)
    love.graphics.setColor(Config.COLOR_HUD_TEXT)
    love.graphics.printf(tostring(game.combo), 16, 120, SW - 36, "right")

    -- Brainrot
    local br = game.brainrotLevel
    if br > 0 then
        love.graphics.setColor(0.7, 0.15 + br*0.03, 0.7, 0.9)
    else
        love.graphics.setColor(Config.COLOR_MUTED)
    end
    love.graphics.print("☠ BRAINROT", 16, 144)
    love.graphics.setColor(Config.COLOR_HUD_TEXT)
    love.graphics.printf(tostring(br), 16, 144, SW - 36, "right")

    -- Divider
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", 12, 195, SW - 24, 1)

    -- ═══ LIVES ═══
    love.graphics.setFont(fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.print("LIVES", 16, 204)
    love.graphics.setFont(fonts.main)
    local livesStr = ""
    for i = 1, Config.STARTING_LIVES do
        livesStr = livesStr .. (i <= game.lives and "♥ " or "♡ ")
    end
    love.graphics.setColor(Config.COLOR_LIVES)
    love.graphics.print(livesStr, 16, 222)

    -- Divider
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", 12, 248, SW - 24, 1)

    -- ═══ POWER UPS PANEL ═══
    local mods = game.modifiers:getUnique()
    drawPanel(game, 8, 256, SW - 16, math.max(40, #mods * 22 + 30))

    love.graphics.setFont(fonts.small)
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.print("POWER UPS", 16, 262)

    if #mods > 0 then
        for i, name in ipairs(mods) do
            local count = game.modifiers:count(name)
            love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.8)
            love.graphics.print("◆ " .. name, 16, 282 + (i-1)*22)
            if count > 1 then
                love.graphics.setColor(Config.COLOR_ACCENT2)
                love.graphics.printf(tostring(count), 16, 282 + (i-1)*22, SW - 36, "right")
            end
        end
    else
        love.graphics.setColor(Config.COLOR_MUTED)
        love.graphics.print("  None yet", 16, 282)
    end

    -- ═══ TOP BAR (over play area) ═══
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", SW, 0, W - SW, Config.TOP_BAR_HEIGHT)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", SW, Config.TOP_BAR_HEIGHT - 1, W - SW, 2)

    -- Stage indicator (centered in play area)
    local playCenter = SW + (W - SW) / 2
    love.graphics.setFont(fonts.main)
    local stageText = "STAGE " .. game.stage
    if game.isEndless then stageText = "∞ " .. stageText end
    local stw = fonts.main:getWidth(stageText) + 50

    drawPanel(game, playCenter - stw/2, 8, stw, 30, {Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2], Config.COLOR_ACCENT[3], 0.4})
    love.graphics.setColor(Config.COLOR_ACCENT)
    love.graphics.printf(stageText, SW, 13, W - SW, "center")

    -- ═══ BOTTOM-RIGHT ACTIVE MODIFIER ═══
    if #mods > 0 then
        local modW, modH = 240, 55
        local mx = W - modW - 10
        local my = H - modH - 10
        drawPanel(game, mx, my, modW, modH)

        love.graphics.setFont(fonts.small)
        love.graphics.setColor(Config.COLOR_GOLD)
        love.graphics.print("ACTIVE MODIFIER", mx + 10, my + 6)

        love.graphics.setFont(fonts.main)
        love.graphics.setColor(Config.COLOR_ACCENT)
        love.graphics.print(mods[#mods], mx + 10, my + 24)
    end
end

return HUD
