-- Card selection — dark gothic card design
local Config = require("config")
local Cards  = require("data.cards")
local Ball   = require("entities.ball")
local Layouts = require("data.layouts")

local CardSelect = {}

function CardSelect:enter(game, sm)
    self.game  = game
    self.sm    = sm
    self.cards = Cards.generateHand(3)
    self.selected = nil
    self.time = 0
end

function CardSelect:update(dt) self.time = (self.time or 0) + dt end

function CardSelect:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    love.graphics.setColor(0.025, 0.022, 0.021, 1)
    love.graphics.rectangle("fill", 0, 0, W, H)
    love.graphics.setColor(0.45, 0.02, 0.015, 0.12)
    love.graphics.circle("fill", W / 2, H / 2, 260)
    love.graphics.setColor(0, 0, 0, 0.50)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Title
    love.graphics.setFont(game.fonts.large)
    love.graphics.setColor(Config.COLOR_GOLD)
    love.graphics.printf("STAGE " .. (game.stage - 1) .. " CLEARED", 0, 55, W, "center")

    love.graphics.setFont(game.fonts.main)
    love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.6)
    love.graphics.printf("Choose your modifier", 0, 95, W, "center")

    -- Score
    love.graphics.setColor(Config.COLOR_SCORE)
    love.graphics.printf("Score: " .. math.floor(game.score), 0, 125, W, "center")

    -- Cards
    local cardW, cardH = 280, 200
    local gap = 30
    local totalW = 3 * cardW + 2 * gap
    local startX = (W - totalW) / 2

    for i, card in ipairs(self.cards) do
        local x = startX + (i - 1) * (cardW + gap)
        local y = 180
        local isHover = (self.selected == i)

        -- Card shadow
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", x + 4, y + 4, cardW, cardH, 8, 8)

        -- Card body
        if isHover then
            love.graphics.setColor(Config.COLOR_ACCENT[1]*0.25, Config.COLOR_ACCENT[2]*0.15,
                                   Config.COLOR_ACCENT[3]*0.15, 0.95)
        else
            love.graphics.setColor(Config.COLOR_CARD_BG)
        end
        love.graphics.rectangle("fill", x, y, cardW, cardH, 8, 8)

        -- Color accent strip
        local ac = Config.BRICK_COLORS[((i - 1) % #Config.BRICK_COLORS) + 1]
        love.graphics.setColor(ac[1], ac[2], ac[3], 0.7)
        love.graphics.rectangle("fill", x, y, cardW, 5, 8, 0)

        -- Border
        if isHover then
            local p = 0.5 + 0.3 * math.sin((self.time or 0) * 5)
            love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2],
                                   Config.COLOR_ACCENT[3], 0.5 + p)
        else
            love.graphics.setColor(Config.COLOR_CARD_BORDER)
        end
        love.graphics.rectangle("line", x, y, cardW, cardH, 8, 8)

        -- Key badge
        love.graphics.setColor(Config.COLOR_GOLD[1], Config.COLOR_GOLD[2], Config.COLOR_GOLD[3], 0.2)
        love.graphics.rectangle("fill", x + 12, y + 18, 30, 30, 15, 15)
        love.graphics.setColor(Config.COLOR_GOLD)
        love.graphics.setFont(game.fonts.main)
        love.graphics.printf(tostring(i), x + 12, y + 23, 30, "center")

        -- Name
        love.graphics.setColor(Config.COLOR_CREAM)
        love.graphics.print(card.name, x + 52, y + 23)

        -- Description
        love.graphics.setColor(Config.COLOR_CREAM[1], Config.COLOR_CREAM[2], Config.COLOR_CREAM[3], 0.65)
        love.graphics.setFont(game.fonts.small)
        love.graphics.printf(card.desc, x + 15, y + 75, cardW - 30)

        -- Effect label
        love.graphics.setColor(ac[1], ac[2], ac[3], 0.4)
        love.graphics.printf(card.effect, x + 15, y + cardH - 30, cardW - 30, "right")
    end

    -- Instructions
    love.graphics.setFont(game.fonts.small)
    love.graphics.setColor(Config.COLOR_MUTED)
    love.graphics.printf("Press 1, 2, or 3 to select", 0, 420, W, "center")
end

function CardSelect:keypressed(key)
    if key == "1" or key == "2" or key == "3" then
        local idx = tonumber(key)
        if self.cards[idx] then
            self.selected = idx
            Cards.apply(self.cards[idx], self.game)
            self.game.balls = { Ball.new() }
            self.game.bricks = Layouts.get(self.game.stage)
            self.sm:switch("playing", self.game, self.sm, false)
        end
    end
end

function CardSelect:mousemoved(x, y, dx, dy)
    local W = Config.GAME_WIDTH
    local cardW, cardH = 280, 200
    local gap = 30
    local totalW = 3 * cardW + 2 * gap
    local startX = (W - totalW) / 2
    local cardY = 180

    self.selected = nil
    for i, card in ipairs(self.cards) do
        local cx = startX + (i - 1) * (cardW + gap)
        if x >= cx and x <= cx + cardW and y >= cardY and y <= cardY + cardH then
            self.selected = i
            break
        end
    end
end

function CardSelect:mousepressed(x, y, button)
    if button == 1 and self.selected then
        self:keypressed(tostring(self.selected))
    end
end

return CardSelect
