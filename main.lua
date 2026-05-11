-- Brainrot Arcade — Entry point
-- Canvas rendering at 1280x720, dark gothic aesthetic

local Config       = require("config")
local Timer        = require("lib.timer")
local Camera       = require("effects.camera")
local StateMachine = require("states.statemachine")
local Modifiers    = require("systems.modifiers")
local Popup        = require("ui.popup")
local Audio        = require("systems.audio")

local game = {
    score          = 0,
    combo          = 0,
    stage          = 1,
    lives          = Config.STARTING_LIVES,
    brainrotLevel  = 0,
    balls          = {},
    paddle         = nil,
    bricks         = {},
    modifiers      = Modifiers.new(),
    timers         = Timer.new(),
    camera         = Camera.new(),
    popups         = Popup.new(),
    audio          = nil,
    scanlineOffset = 0,
    fonts          = {},
    sounds         = {},
    images         = {},
    canvas         = nil,
}

local sm

function love.load()
    love.window.setTitle("Brainrot Arcade")

    game.canvas = love.graphics.newCanvas(Config.GAME_WIDTH, Config.GAME_HEIGHT)
    game.canvas:setFilter("linear", "linear")

    game.fonts.main  = love.graphics.newFont(16)
    game.fonts.small = love.graphics.newFont(11)
    game.fonts.large = love.graphics.newFont(26)

    game.sounds.bonk  = love.audio.newSource("sounds/bonk.mp3", "static")
    game.sounds.punch = love.audio.newSource("sounds/punch.mp3", "static")
    game.sounds.fah   = love.audio.newSource("sounds/fah.mp3", "static")
    game.sounds.fah:setVolume(0.5)

    -- Phase 4: Audio manager
    game.audio = Audio.new(game.sounds)

    -- Paddle image
    local imgPaddle = love.graphics.newImage("assets/sahur.png")
    imgPaddle:setFilter("linear", "linear")
    local scale = 140 / imgPaddle:getWidth()
    local scaledCanvas = love.graphics.newCanvas(140, math.floor(imgPaddle:getHeight() * scale))
    love.graphics.setCanvas(scaledCanvas)
    love.graphics.clear(0, 0, 0, 0)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(imgPaddle, 0, 0, 0, scale, scale)
    love.graphics.setCanvas()
    game.images.paddleRaw    = imgPaddle
    game.images.paddleScaled = scaledCanvas

    sm = StateMachine.new({
        menu       = require("states.menu"),
        playing    = require("states.playing"),
        cardselect = require("states.cardselect"),
        gameover   = require("states.gameover"),
        victory    = require("states.victory"),
        pause      = require("states.pause"),
    })

    sm:switch("menu", game, sm)
end

function love.update(dt)
    game.scanlineOffset = (game.scanlineOffset + dt * 50) % 4
    game.camera:update(dt, Config.SHAKE_DECAY_SPEED)
    game.timers:update(dt)
    sm:update(dt)
end

function love.keypressed(key)
    if key == "f11" then
        love.window.setFullscreen(not love.window.getFullscreen(), "desktop")
        return
    end
    sm:keypressed(key)
end

function love.resize(w, h) end

function love.draw()
    local winW, winH = love.graphics.getDimensions()

    love.graphics.setCanvas(game.canvas)
    love.graphics.clear(Config.COLOR_BG[1], Config.COLOR_BG[2], Config.COLOR_BG[3], 1)
    love.graphics.origin()
    game.camera:applyShake()
    sm:draw()
    game.camera:drawFlash(Config.GAME_WIDTH, Config.GAME_HEIGHT)
    love.graphics.setCanvas()

    local scaleX = winW / Config.GAME_WIDTH
    local scaleY = winH / Config.GAME_HEIGHT
    local scale  = math.min(scaleX, scaleY)
    local ox = math.floor((winW - Config.GAME_WIDTH * scale) / 2)
    local oy = math.floor((winH - Config.GAME_HEIGHT * scale) / 2)

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, winW, winH)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(game.canvas, ox, oy, 0, scale, scale)

    drawScanlines(winW, winH)
end

function drawScanlines(w, h)
    love.graphics.setColor(0, 0, 0, 0.05)
    for y = game.scanlineOffset, h, 4 do
        love.graphics.rectangle("fill", 0, y, w, 2)
    end
    if game.brainrotLevel > 0 then
        love.graphics.setColor(0.6, 0, 0, 0.01 * game.brainrotLevel)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    -- CRT border vignette
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, 3, h)
    love.graphics.rectangle("fill", w - 3, 0, 3, h)
    love.graphics.rectangle("fill", 0, 0, w, 3)
    love.graphics.rectangle("fill", 0, h - 3, w, 3)
end