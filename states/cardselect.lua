-- Card selection state (between stages)
local Config = require("config")
local Cards  = require("data.cards")
local Ball   = require("entities.ball")
local Brick  = require("entities.brick")

local CardSelect = {}

function CardSelect:enter(game, sm)
    self.game  = game
    self.sm    = sm
    self.cards = Cards.generateHand(3)
end

function CardSelect:update(dt) end

function CardSelect:draw()
    local game = self.game
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)

    love.graphics.setFont(game.fonts.main)
    love.graphics.setColor(1, 1, 0.3)
    love.graphics.printf("=== STAGE COMPLETE ===", 0, 50, Config.GAME_WIDTH, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Choose a modifier card:", 0, 90, Config.GAME_WIDTH, "center")

    for i, card in ipairs(self.cards) do
        local y = 150 + (i - 1) * 120

        love.graphics.setColor(0.2, 0.4, 0.6)
        love.graphics.rectangle("fill", Config.GAME_WIDTH / 2 - 150, y, 300, 100)
        love.graphics.setColor(0.5, 0.7, 1)
        love.graphics.rectangle("line", Config.GAME_WIDTH / 2 - 150, y, 300, 100)

        love.graphics.setColor(1, 1, 0.8)
        love.graphics.setFont(game.fonts.main)
        love.graphics.print("[" .. i .. "] " .. card.name, Config.GAME_WIDTH / 2 - 130, y + 15)

        love.graphics.setColor(0.8, 0.8, 0.8)
        love.graphics.setFont(game.fonts.small)
        love.graphics.print(card.desc, Config.GAME_WIDTH / 2 - 130, y + 45)
    end
end

function CardSelect:keypressed(key)
    if key == "1" or key == "2" or key == "3" then
        local idx = tonumber(key)
        if self.cards[idx] then
            local game = self.game
            Cards.apply(self.cards[idx], game)

            -- Reset ball(s) for next stage
            game.balls = { Ball.new() }

            -- Generate new bricks
            game.bricks = Brick.generateGrid(game.stage)

            -- Back to playing (without re-entering / resetting score)
            self.sm:switch("playing_continue", game, self.sm)
        end
    end
end

return CardSelect
