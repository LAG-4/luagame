-- Card pool definitions — Phase 2: 15 cards with all effects implemented
local Config = require("config")
local Cards = {}

Cards.pool = {
    -- Original 6
    { name = "MULTIBALL",        desc = "Spawn 2 extra balls every 10 combo",       effect = "multiball" },
    { name = "TINY PADDLE",      desc = "Paddle 50% smaller but 3x score",          effect = "tinyPaddle" },
    { name = "EXPLODING BRICKS", desc = "Bricks damage neighbors on death",         effect = "exploding" },
    { name = "GHOST BALL",       desc = "Balls phase through bricks",               effect = "ghostBall" },
    { name = "COMBO MAGNET",     desc = "Combo builds 2x faster",                   effect = "comboMagnet" },
    { name = "GLITCH PADDLE",    desc = "Paddle teleports on hit",                  effect = "glitchPaddle" },
    -- New Phase 2 cards
    { name = "MEGA BALL",        desc = "Ball size doubled, smash everything",       effect = "megaBall" },
    { name = "SPEED DEMON",      desc = "Ball 40% faster, 2x score",                effect = "speedDemon" },
    { name = "WIDE PADDLE",      desc = "Paddle 60% wider, easier catches",         effect = "widePaddle" },
    { name = "SCORE FRENZY",     desc = "All scoring tripled",                       effect = "scoreFrenzy" },
    { name = "CHAIN LIGHTNING",  desc = "Destroying a brick zaps another",           effect = "chainLightning" },
    { name = "SHIELD",           desc = "Survive one ball death (consumed)",         effect = "shieldRow" },
    { name = "BRICK REGEN",      desc = "Dead bricks respawn for bonus score",       effect = "brickRegen" },
    { name = "GRAVITY WELL",     desc = "Ball curves toward nearest brick",          effect = "gravityWell" },
    { name = "PIERCING SHOT",    desc = "Ball destroys bricks in a line",            effect = "piercingShot" },
    { name = "COMBO SHIELD",    desc = "Combo 5+ saves you from death",             effect = "comboShield" },
    { name = "EXTRA LIFE",      desc = "Gain one extra life",                        effect = "extraLife" },
}

function Cards.generateHand(count)
    count = count or 3
    local hand, used = {}, {}
    while #hand < count and #hand < #Cards.pool do
        local idx = math.random(#Cards.pool)
        if not used[idx] then
            used[idx] = true
            local src = Cards.pool[idx]
            table.insert(hand, { name = src.name, desc = src.desc, effect = src.effect })
        end
    end
    return hand
end

function Cards.apply(card, game)
    game.modifiers:add(card.effect)

    -- Immediate effects
    if card.effect == "tinyPaddle" then
        game.paddle.width = game.paddle.width * 0.5
        game.score = game.score * 3
    elseif card.effect == "comboMagnet" then
        game.combo = game.combo + 5
    elseif card.effect == "glitchPaddle" then
        game.paddle.x = math.random(math.floor(game.paddle.width), math.floor(Config.GAME_WIDTH - game.paddle.width))
    elseif card.effect == "megaBall" then
        for _, ball in ipairs(game.balls) do
            ball.radius = Config.BALL_RADIUS * 2
        end
    elseif card.effect == "speedDemon" then
        for _, ball in ipairs(game.balls) do
            ball.dx = ball.dx * 1.4
            ball.dy = ball.dy * 1.4
        end
    elseif card.effect == "widePaddle" then
        game.paddle.width = game.paddle.width * 1.6
    elseif card.effect == "extraLife" then
        game.lives = (game.lives or Config.STARTING_LIVES) + 1
    end

    game.score = game.score + Config.CARD_BONUS_SCORE
end

return Cards
