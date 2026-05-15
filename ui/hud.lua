local Config = require("config")
local Theme = require("ui.theme")

local HUD = {}

local function drawStat(game, label, value, y, color)
    local SW = Config.SIDEBAR_WIDTH
    Theme.text(game.fonts.menuTiny, label, 20, y, 95, "left", Theme.colors.muted)
    Theme.text(game.fonts.hudValue or game.fonts.main, tostring(value), 118, y - 4, 48, "right", color)
end

function HUD.draw(game, fonts)
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    local SW = Config.SIDEBAR_WIDTH

    love.graphics.setColor(0.045, 0.038, 0.032, 0.99)
    love.graphics.rectangle("fill", 0, 0, SW, H)
    love.graphics.setColor(0, 0, 0, 0.46)
    love.graphics.rectangle("fill", 6, 0, SW - 16, H)

    love.graphics.setColor(Config.COLOR_PANEL_BORDER[1], Config.COLOR_PANEL_BORDER[2], Config.COLOR_PANEL_BORDER[3], 0.95)
    love.graphics.rectangle("fill", SW - 5, 0, 3, H)
    love.graphics.setColor(Theme.colors.green[1], Theme.colors.green[2], Theme.colors.green[3], 0.34)
    love.graphics.rectangle("fill", SW - 8, 0, 1, H)
    love.graphics.setColor(0, 0, 0, 0.82)
    love.graphics.rectangle("fill", SW - 1, 0, 1, H)

    Theme.logo(game, 34, 34, 126, "brainOnly")
    Theme.text(game.fonts.menuArcade, "ARCADE", 0, 88, SW, "center", Theme.colors.green)

    local statsY = 120
    Theme.panel(12, statsY, SW - 24, 154, "HERO STATS", fonts, {fill = {0.075, 0.058, 0.045, 0.98}})
    drawStat(game, "SCORE", math.floor(game.score), statsY + 43, Theme.colors.bone)
    drawStat(game, "COMBO", math.floor(game.combo), statsY + 74, Config.COLOR_COMBO)
    drawStat(game, "CORRUPTION", game.brainrotLevel, statsY + 105, game.brainrotLevel > 0 and Theme.colors.red or Theme.colors.muted)

    local livesY = statsY + 166
    Theme.panel(12, livesY, SW - 24, 82, "VITALITY", fonts)
    for i = 1, Config.STARTING_LIVES do
        local x = 74 + (i - 1) * 26
        local active = i <= game.lives
        love.graphics.setColor(0, 0, 0, 0.85)
        love.graphics.circle("fill", x, livesY + 56, 8)
        love.graphics.setColor(active and Theme.colors.red or Theme.colors.muted)
        love.graphics.setLineWidth(3)
        love.graphics.circle("line", x, livesY + 56, 8)
        if active then
            love.graphics.setColor(Theme.colors.red[1], Theme.colors.red[2], Theme.colors.red[3], 0.35)
            love.graphics.circle("fill", x, livesY + 56, 5)
        end
        love.graphics.setLineWidth(1)
    end

    local mods = game.modifiers:getUnique()
    local modsY = livesY + 96
    Theme.panel(12, modsY, SW - 24, math.max(76, 48 + #mods * 24), "ACTIVE BUFFS", fonts)
    if #mods == 0 then
        Theme.text(game.fonts.menuTiny, "NONE", 12, modsY + 47, SW - 24, "center", Theme.colors.muted)
    else
        for i, name in ipairs(mods) do
            local count = game.modifiers:count(name)
            Theme.text(game.fonts.menuTiny, name, 22, modsY + 42 + (i - 1) * 23, SW - 44, "left", Theme.colors.bone)
            if count > 1 then
                Theme.text(game.fonts.menuTiny, "x" .. tostring(count), 22, modsY + 42 + (i - 1) * 23, SW - 44, "right", Config.COLOR_COMBO)
            end
        end
    end

    -- Top raid-frame bar.
    love.graphics.setColor(0.012, 0.01, 0.008, 0.94)
    love.graphics.rectangle("fill", SW, 0, W - SW, Config.TOP_BAR_HEIGHT)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.rectangle("fill", SW, Config.TOP_BAR_HEIGHT - 4, W - SW, 3)
    love.graphics.setColor(Theme.colors.red[1], Theme.colors.red[2], Theme.colors.red[3], 0.5)
    love.graphics.rectangle("fill", SW + 22, Config.TOP_BAR_HEIGHT - 9, W - SW - 44, 2)

    local playCenter = SW + (W - SW) / 2
    local stageText = game.isEndless and ("ENDLESS " .. game.stage) or ("STAGE " .. game.stage)
    local stageW = 124
    love.graphics.setColor(Theme.colors.panel[1], Theme.colors.panel[2], Theme.colors.panel[3], 0.98)
    love.graphics.polygon("fill",
        playCenter - stageW / 2, 0,
        playCenter + stageW / 2, 0,
        playCenter + stageW / 2, 44,
        playCenter, 55,
        playCenter - stageW / 2, 44)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER)
    love.graphics.setLineWidth(2)
    love.graphics.polygon("line",
        playCenter - stageW / 2, 0,
        playCenter + stageW / 2, 0,
        playCenter + stageW / 2, 44,
        playCenter, 55,
        playCenter - stageW / 2, 44)
    love.graphics.setLineWidth(1)
    Theme.text(game.fonts.panelTitle or fonts.main, stageText, playCenter - stageW / 2, 15, stageW, "center", Theme.colors.gold)

    if #mods > 0 then
        local modW, modH = 250, 64
        local mx = W - modW - 16
        local my = H - modH - 14
        Theme.panel(mx, my, modW, modH, "CURRENT RUNE", fonts, {redTop = true})
        Theme.text(game.fonts.menuSmall, mods[#mods], mx, my + 36, modW, "center", Theme.colors.green)
    end
end

return HUD
