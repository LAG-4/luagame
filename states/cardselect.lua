local Config = require("config")
local Cards  = require("data.cards")
local Ball   = require("entities.ball")
local Layouts = require("data.layouts")
local Theme = require("ui.theme")

local CardSelect = {}

function CardSelect:enter(game, sm)
    self.game = game
    self.sm = sm
    self.cards = Cards.generateHand(3)
    self.selected = 1
    self.time = 0
end

function CardSelect:update(dt) self.time = (self.time or 0) + dt end

function CardSelect:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    Theme.background(game, 0.64)

    love.graphics.setColor(0.16, 0.015, 0.012, 0.20)
    love.graphics.circle("fill", W / 2, H / 2 + 20, 270)
    Theme.text(game.fonts.large, "STAGE " .. (game.stage - 1) .. " CLEARED", 0, 54, W, "center", Theme.colors.gold)
    Theme.text(game.fonts.menuSmall, "CHOOSE A CURSED RUNE", 0, 100, W, "center", Theme.colors.bone, 0.72)
    Theme.text(game.fonts.menuTiny, "SCORE " .. math.floor(game.score), 0, 126, W, "center", Theme.colors.muted)

    local cardW, cardH = 286, 292
    local gap = 36
    local totalW = 3 * cardW + 2 * gap
    local startX = (W - totalW) / 2
    local y = 190

    for i, card in ipairs(self.cards) do
        local x = startX + (i - 1) * (cardW + gap)
        self:drawCard(card, i, x, y, cardW, cardH, self.selected == i)
    end

    Theme.text(game.fonts.menuTiny, "PRESS 1 / 2 / 3 OR CLICK A RUNE", 0, 535, W, "center", Theme.colors.muted)
end

function CardSelect:drawCard(card, index, x, y, w, h, selected)
    local game = self.game
    local ac = Config.BRICK_COLORS[((index - 1) % #Config.BRICK_COLORS) + 1]

    Theme.panel(x, y, w, h, nil, game.fonts, {
        selected = selected,
        redTop = selected,
        border = selected and Theme.colors.red or Theme.colors.goldSoft,
        fill = selected and {0.14, 0.055, 0.04, 0.98} or {0.075, 0.056, 0.042, 0.98},
    })

    love.graphics.setColor(ac[1], ac[2], ac[3], selected and 0.48 or 0.30)
    love.graphics.rectangle("fill", x + 10, y + 10, w - 20, 8, 1, 1)

    love.graphics.setColor(0, 0, 0, 0.72)
    love.graphics.rectangle("fill", x + 22, y + 42, 48, 48, 1, 1)
    love.graphics.setColor(Theme.colors.gold[1], Theme.colors.gold[2], Theme.colors.gold[3], 0.85)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", x + 22, y + 42, 48, 48, 1, 1)
    love.graphics.setLineWidth(1)
    Theme.text(game.fonts.menuLarge, tostring(index), x + 22, y + 52, 48, "center", Theme.colors.gold)

    Theme.text(game.fonts.menuLarge, card.name, x + 82, y + 49, w - 104, "left", Theme.colors.bone)

    love.graphics.setColor(0.018, 0.013, 0.010, 0.74)
    love.graphics.rectangle("fill", x + 20, y + 112, w - 40, 112, 1, 1)
    Theme.text(game.fonts.main, card.desc, x + 34, y + 130, w - 68, "center", Theme.colors.bone, 0.76)

    Theme.text(game.fonts.menuTiny, card.effect, x + 24, y + h - 50, w - 48, "right", {ac[1], ac[2], ac[3], 1}, selected and 1 or 0.78)
end

function CardSelect:choose(idx)
    if not self.cards[idx] then return end
    self.selected = idx
    Cards.apply(self.cards[idx], self.game)
    self.game.balls = { Ball.new() }
    self.game.bricks = Layouts.get(self.game.stage)
    self.sm:switch("playing", self.game, self.sm, false)
end

function CardSelect:keypressed(key)
    if key == "1" or key == "2" or key == "3" then
        self:choose(tonumber(key))
    elseif key == "left" or key == "a" then
        self.selected = ((self.selected - 2) % #self.cards) + 1
    elseif key == "right" or key == "d" then
        self.selected = (self.selected % #self.cards) + 1
    elseif key == "return" or key == "space" then
        self:choose(self.selected)
    end
end

function CardSelect:mousemoved(x, y, dx, dy)
    local W = Config.GAME_WIDTH
    local cardW, cardH = 286, 292
    local gap = 36
    local totalW = 3 * cardW + 2 * gap
    local startX = (W - totalW) / 2
    local cardY = 190

    for i = 1, #self.cards do
        local cx = startX + (i - 1) * (cardW + gap)
        if x >= cx and x <= cx + cardW and y >= cardY and y <= cardY + cardH then
            self.selected = i
            return
        end
    end
end

function CardSelect:mousepressed(x, y, button)
    if button == 1 then self:choose(self.selected) end
end

return CardSelect
