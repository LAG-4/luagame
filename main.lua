-- Brainrot Arcade — Entry point
-- Phase 1 refactored: modular architecture, state machine, entity lists, modifier system

local Config       = require("config")
local Timer        = require("lib.timer")
local Camera       = require("effects.camera")
local StateMachine = require("states.statemachine")
local Modifiers    = require("systems.modifiers")
local Ball         = require("entities.ball")
local Paddle       = require("entities.paddle")
local Brick        = require("entities.brick")
local Collision    = require("systems.collision")
local HUD          = require("ui.hud")

-- Game context — shared across all states
local game = {
    score          = 0,
    combo          = 0,
    stage          = 1,
    brainrotLevel  = 0,
    balls          = {},
    paddle         = nil,
    bricks         = {},
    modifiers      = Modifiers.new(),
    timers         = Timer.new(),
    camera         = Camera.new(),
    scanlineOffset = 0,
    fonts          = {},
    sounds         = {},
    images         = {},
}

local sm  -- state machine

-- PlayingContinue — same as Playing but doesn't reset the run
local PlayingContinue = {}

function PlayingContinue:enter(g, stateMachine)
    self.game = g
    self.sm   = stateMachine
    -- Do NOT reset score/combo/stage/modifiers — just continue playing
end

function PlayingContinue:update(dt)
    -- Reuse Playing's update logic
    local playing = sm.states["playing"]
    playing.game = self.game
    playing.sm   = self.sm
    playing:update(dt)
end

function PlayingContinue:draw()
    local playing = sm.states["playing"]
    playing.game = self.game
    playing.sm   = self.sm
    playing:draw()
end

function PlayingContinue:keypressed(key)
    local playing = sm.states["playing"]
    playing.game = self.game
    playing.sm   = self.sm
    playing:keypressed(key)
end

--------------------------------------------------------------------
-- LÖVE callbacks
--------------------------------------------------------------------

function love.load()
    love.window.setTitle("Brainrot Arcade")
    love.window.setMode(Config.GAME_WIDTH, Config.GAME_HEIGHT)

    -- Fonts
    game.fonts.main  = love.graphics.newFont(16)
    game.fonts.small = love.graphics.newFont(12)

    -- Sounds
    game.sounds.bonk  = love.audio.newSource("sounds/bonk.mp3", "static")
    game.sounds.punch = love.audio.newSource("sounds/punch.mp3", "static")
    game.sounds.fah   = love.audio.newSource("sounds/fah.mp3", "static")
    game.sounds.fah:setVolume(0.5)

    -- Paddle image
    local imgPaddle = love.graphics.newImage("assets/sahur.png")
    imgPaddle:setFilter("linear", "linear")
    local scale = 100 / imgPaddle:getWidth()
    local scaledCanvas = love.graphics.newCanvas(100, imgPaddle:getHeight() * scale)
    love.graphics.setCanvas(scaledCanvas)
    love.graphics.draw(imgPaddle, 0, 0, 0, scale, scale)
    love.graphics.setCanvas()
    game.images.paddleRaw    = imgPaddle
    game.images.paddleScaled = scaledCanvas

    -- Build state machine
    sm = StateMachine.new({
        menu             = require("states.menu"),
        playing          = require("states.playing"),
        playing_continue = PlayingContinue,
        cardselect       = require("states.cardselect"),
        gameover         = require("states.gameover"),
        victory          = require("states.victory"),
        pause            = require("states.pause"),
    })

    sm:switch("menu", game, sm)
end

function love.update(dt)
    -- Global timers
    game.scanlineOffset = (game.scanlineOffset + dt * 50) % 4
    game.camera:update(dt, Config.SHAKE_DECAY_SPEED)
    game.timers:update(dt)

    -- Delegate to current state
    sm:update(dt)
end

function love.keypressed(key)
    -- Global: fullscreen toggle
    if key == "f11" or key == "f" then
        local fs = not love.window.getFullscreen()
        love.window.setFullscreen(fs)
        if not fs then
            love.window.setMode(Config.GAME_WIDTH, Config.GAME_HEIGHT)
        end
        return
    end

    sm:keypressed(key)
end

function love.draw()
    local w, h = love.graphics.getDimensions()
    local scaleX = w / Config.GAME_WIDTH
    local scaleY = h / Config.GAME_HEIGHT
    local scale  = math.min(scaleX, scaleY)
    local offsetX = (w - Config.GAME_WIDTH * scale) / 2
    local offsetY = (h - Config.GAME_HEIGHT * scale) / 2

    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)

    -- Camera shake
    game.camera:applyShake()

    -- Current state draws
    sm:draw()

    -- Camera flash overlay
    game.camera:drawFlash(Config.GAME_WIDTH, Config.GAME_HEIGHT)

    love.graphics.pop()

    -- CRT scanlines (drawn in screen space)
    drawScanlines()
end

--------------------------------------------------------------------
-- CRT scanline overlay (kept in main for now, will move to effects/)
--------------------------------------------------------------------

function drawScanlines()
    local w, h = love.graphics.getDimensions()

    love.graphics.setColor(0, 0, 0, 0.1)
    for y = game.scanlineOffset, h, 4 do
        love.graphics.rectangle("fill", 0, y, w, 2)
    end

    -- Brainrot tint
    if game.brainrotLevel > 0 then
        love.graphics.setColor(1, 0, 0, 0.02 * game.brainrotLevel)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end

    -- CRT border
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, 3, h)
    love.graphics.rectangle("fill", w - 3, 0, 3, h)
    love.graphics.rectangle("fill", 0, 0, w, 3)
    love.graphics.rectangle("fill", 0, h - 3, w, 3)
end