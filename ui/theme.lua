-- Shared dark-fantasy brainrot UI primitives.
local Config = require("config")

local Theme = {}

Theme.colors = {
    panel = {0.095, 0.075, 0.055, 0.96},
    panelDark = {0.025, 0.018, 0.014, 0.95},
    panelWarm = {0.16, 0.115, 0.075, 0.96},
    gold = {0.78, 0.55, 0.22, 1},
    goldSoft = {0.48, 0.34, 0.17, 1},
    red = {0.70, 0.055, 0.045, 1},
    redDark = {0.22, 0.025, 0.02, 1},
    green = {0.18, 0.72, 0.22, 1},
    bone = {0.84, 0.79, 0.67, 1},
    muted = {0.48, 0.43, 0.36, 1},
    black = {0.015, 0.012, 0.01, 1},
}

local function color(c, alpha)
    love.graphics.setColor(c[1], c[2], c[3], alpha or c[4] or 1)
end

function Theme.color(c, alpha)
    color(c, alpha)
end

function Theme.cover(img, x, y, w, h, alpha)
    if not img then return end
    local iw, ih = img:getDimensions()
    local scale = math.max(w / iw, h / ih)
    color({1, 1, 1, alpha or 1})
    love.graphics.draw(img, x + (w - iw * scale) / 2, y + (h - ih * scale) / 2, 0, scale, scale)
end

function Theme.fit(img, x, y, w, h, alpha)
    if not img then return end
    local iw, ih = img:getDimensions()
    local scale = math.min(w / iw, h / ih)
    color({1, 1, 1, alpha or 1})
    love.graphics.draw(img, x + (w - iw * scale) / 2, y + (h - ih * scale) / 2, 0, scale, scale)
end

function Theme.quad(img, sx, sy, sw, sh, x, y, w, h, alpha)
    if not img then return end
    local quad = love.graphics.newQuad(sx, sy, sw, sh, img:getDimensions())
    color({1, 1, 1, alpha or 1})
    love.graphics.draw(img, quad, x, y, 0, w / sw, h / sh)
end

function Theme.text(font, text, x, y, w, align, c, alpha, shadow)
    love.graphics.setFont(font)
    if type(alpha) ~= "number" then alpha = 1 end
    if shadow ~= false then
        love.graphics.setColor(0, 0, 0, 0.82 * (alpha or 1))
        if w then
            love.graphics.printf(text, x + 2, y + 2, w, align or "left")
        else
            love.graphics.print(text, x + 2, y + 2)
        end
    end
    color(c or Theme.colors.bone, alpha)
    if w then
        love.graphics.printf(text, x, y, w, align or "left")
    else
        love.graphics.print(text, x, y)
    end
end

local function cornerCuts(x, y, w, h, size)
    size = size or 10
    love.graphics.line(x, y + size, x, y, x + size, y)
    love.graphics.line(x + w - size, y, x + w, y, x + w, y + size)
    love.graphics.line(x + w, y + h - size, x + w, y + h, x + w - size, y + h)
    love.graphics.line(x + size, y + h, x, y + h, x, y + h - size)
end

function Theme.panel(x, y, w, h, title, fonts, opts)
    opts = opts or {}
    local selected = opts.selected
    local border = opts.border or (selected and Theme.colors.red or Theme.colors.goldSoft)
    local fill = opts.fill or Theme.colors.panel

    love.graphics.setColor(0, 0, 0, opts.shadowAlpha or 0.64)
    love.graphics.rectangle("fill", x + 5, y + 6, w, h, 2, 2)

    color(fill)
    love.graphics.rectangle("fill", x, y, w, h, 2, 2)

    love.graphics.setColor(0.025, 0.018, 0.014, opts.insetAlpha or 0.82)
    local insetTop = title and 36 or 8
    love.graphics.rectangle("fill", x + 8, y + insetTop, w - 16, h - insetTop - 8, 1, 1)

    if opts.redTop then
        color(Theme.colors.redDark, 0.95)
        love.graphics.rectangle("fill", x + 6, y + 6, w - 12, 7)
        color(Theme.colors.red, 0.7)
        love.graphics.rectangle("fill", x + 6, y + 6, w - 12, 2)
    end

    color(border, selected and 1 or 0.92)
    love.graphics.setLineWidth(selected and 3 or 2)
    love.graphics.rectangle("line", x, y, w, h, 2, 2)
    cornerCuts(x + 4, y + 4, w - 8, h - 8, 12)
    love.graphics.setLineWidth(1)

    love.graphics.setColor(1, 0.86, 0.46, 0.12)
    love.graphics.rectangle("fill", x + 3, y + 3, w - 6, 1)
    love.graphics.setColor(0, 0, 0, 0.55)
    love.graphics.rectangle("fill", x + 3, y + h - 4, w - 6, 2)

    for _, p in ipairs({{x + 7, y + 7}, {x + w - 7, y + 7}, {x + 7, y + h - 7}, {x + w - 7, y + h - 7}}) do
        color(Theme.colors.black, 0.95)
        love.graphics.circle("fill", p[1], p[2], 2.6)
        color(border, 0.55)
        love.graphics.circle("line", p[1], p[2], 2.8)
    end

    if title then
        color(Theme.colors.panelWarm, 0.78)
        love.graphics.rectangle("fill", x + 7, y + 7, w - 14, 25)
        color(border, 0.30)
        love.graphics.line(x + 10, y + 32, x + w - 10, y + 32)
        Theme.text((fonts and (fonts.panelTitle or fonts.menuSmall or fonts.main)) or love.graphics.getFont(),
            title, x, y + 8, w, "center", opts.titleColor or Theme.colors.gold, 1)
    end
end

function Theme.button(label, x, y, w, h, selected, fonts, opts)
    opts = opts or {}
    local disabled = opts.disabled
    local fill = selected and Theme.colors.redDark or {0.075, 0.055, 0.04, 0.98}
    if disabled then fill = {0.052, 0.044, 0.037, 0.95} end
    Theme.panel(x, y, w, h, nil, fonts, {
        selected = selected,
        fill = fill,
        border = disabled and Theme.colors.goldSoft or (selected and Theme.colors.red or Theme.colors.goldSoft),
        insetAlpha = 0.18,
        redTop = selected,
        shadowAlpha = 0.72,
    })

    if selected and not disabled then
        color(Theme.colors.red, 0.16 + 0.08 * math.sin(love.timer.getTime() * 6))
        love.graphics.rectangle("fill", x + 7, y + 7, w - 14, h - 14, 1, 1)
    end
    local font = (fonts and (fonts.menuButton or fonts.large or fonts.main)) or love.graphics.getFont()
    local textColor = disabled and Theme.colors.muted or (selected and Theme.colors.bone or Theme.colors.bone)
    Theme.text(font, label, x + 8, y + h / 2 - font:getHeight() / 2, w - 16, "center", textColor, disabled and 0.55 or 1)
end

function Theme.statRow(fonts, label, value, x, y, w, valueColor)
    Theme.text(fonts.menuTiny or fonts.small, label, x, y, w, "left", Theme.colors.muted)
    Theme.text(fonts.menuSmall or fonts.main, tostring(value), x, y - 2, w, "right", valueColor or Theme.colors.gold)
    color(Theme.colors.goldSoft, 0.22)
    love.graphics.line(x, y + 28, x + w, y + 28)
end

function Theme.background(game, mood)
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)
    Theme.cover(game.images and game.images.background, 0, 0, W, H, 0.78)
    love.graphics.setColor(0, 0, 0, mood or 0.68)
    love.graphics.rectangle("fill", 0, 0, W, H)
    Theme.cover(game.images and game.images.scratchedMetal, 0, 0, W, H, 0.20)

    love.graphics.setBlendMode("add")
    if game.images and game.images.glowingOverlays then
        Theme.quad(game.images.glowingOverlays, 520, 335, 440, 370, 370, 92, 560, 320, 0.08)
        Theme.quad(game.images.glowingOverlays, 90, 70, 420, 300, 760, 350, 390, 250, 0.06)
    end
    love.graphics.setBlendMode("alpha")

    love.graphics.setColor(0, 0, 0, 0.34)
    love.graphics.rectangle("fill", 0, 0, W, 28)
    love.graphics.rectangle("fill", 0, H - 34, W, 34)
end

function Theme.logo(game, x, y, w, mode)
    if game.images and game.images.brainrotLogo then
        Theme.quad(game.images.brainrotLogo, 270, 250, 1000, 360, x, y, w, w * 0.36, 1)
        if mode ~= "arcadeOnly" and mode ~= "brainOnly" and game.images.breakerLogo then
            Theme.quad(game.images.breakerLogo, 270, 350, 1000, 330, x + 2, y + w * 0.34, w * 0.98, w * 0.32, 0.96)
        end
    else
        Theme.text(game.fonts.large, "BRAINROT", x, y, w, "center", Theme.colors.red)
    end
    if mode == "arcade" or mode == "arcadeOnly" then
        Theme.text(game.fonts.menuArcade or game.fonts.small, "ARCADE", x, y + w * 0.32, w, "center", Theme.colors.green)
    end
end

function Theme.brainIcon(game, x, y, size, alpha)
    if game.images and game.images.brainLogo then
        Theme.quad(game.images.brainLogo, 470, 190, 620, 660, x, y, size, size, alpha or 1)
    else
        color(Theme.colors.green, alpha or 1)
        love.graphics.circle("fill", x + size / 2, y + size / 2, size / 2)
    end
end

return Theme
