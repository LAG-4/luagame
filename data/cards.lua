-- Card pool definitions and hand generation
local Config = require("config")
local Cards = {}

-- Master card pool — each card has: name, desc, effect (string key)
Cards.pool = {
    { name = "MULTIBALL",       desc = "Balls duplicate after 10 combo",         effect = "multiball" },
    { name = "TINY PADDLE",    desc = "Paddle 50% smaller but 3x score",        effect = "tinyPaddle" },
    { name = "EXPLODING BRICKS", desc = "Bricks infect neighbors on death",     effect = "exploding" },
    { name = "GHOST BALL",     desc = "Balls pass through bricks once",          effect = "ghostBall" },
    { name = "COMBO MAGNET",   desc = "Combo builds 2x faster",                 effect = "comboMagnet" },
    { name = "GLITCH PADDLE",  desc = "Paddle teleports randomly",              effect = "glitchPaddle" },
}

-- Generate a hand of `count` random cards (no exact duplicates in one hand)
function Cards.generateHand(count)
    count = count or 3
    local hand = {}
    local used = {}

    while #hand < count and #hand < #Cards.pool do
        local idx = math.random(#Cards.pool)
        if not used[idx] then
            used[idx] = true
            local src = Cards.pool[idx]
            table.insert(hand, {
                name   = src.name,
                desc   = src.desc,
                effect = src.effect,
            })
        end
    end
    return hand
end

-- Apply a card's immediate effect to the game state
-- `game` is the shared game context table
function Cards.apply(card, game)
    -- Track the modifier for persistent effects
    game.modifiers:add(card.effect)

    -- Immediate effects
    if card.effect == "tinyPaddle" then
        game.paddle.width = game.paddle.width * 0.5
        game.score = game.score * 3
    elseif card.effect == "comboMagnet" then
        game.combo = game.combo + 5
    elseif card.effect == "glitchPaddle" then
        game.paddle.x = math.random(game.paddle.width, Config.GAME_WIDTH - game.paddle.width)
    end
    -- multiball, ghostBall, exploding are checked during gameplay (persistent)

    game.score = game.score + Config.CARD_BONUS_SCORE
end

return Cards
