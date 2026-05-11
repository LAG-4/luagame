-- Brainrot Arcade — Entry point
-- Canvas rendering at 1280x720, dark gothic aesthetic

local Config       = require("config")
local Timer        = require("lib.timer")
local Camera       = require("effects.camera")
local StateMachine = require("states.statemachine")
local Modifiers    = require("systems.modifiers")
local Popup        = require("ui.popup")
local Particles   = require("effects.particles")
local Shaders      = require("effects.shaders")
local Audio        = require("systems.audio")
local Save         = require("lib.save")

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
    particles      = Particles.new(),
    shader         = nil,
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

    local settings = Save.getSettings()
    if settings.fullscreen ~= false then
        love.window.setFullscreen(true, "desktop")
    end

    game.canvas = love.graphics.newCanvas(Config.GAME_WIDTH, Config.GAME_HEIGHT)
    game.canvas:setFilter("linear", "linear")

    game.fonts.main  = love.graphics.newFont(16)
    game.fonts.small = love.graphics.newFont(11)
    game.fonts.large = love.graphics.newFont(26)

    game.sounds.bonk  = love.audio.newSource("sounds/bonk.mp3", "static")
    game.sounds.punch = love.audio.newSource("sounds/punch.mp3", "static")
    game.sounds.fah   = love.audio.newSource("sounds/fah.mp3", "static")
    game.sounds.fah:setVolume(0.5)

    -- Phase 4: Audio manager with BGM
    game.audio = Audio.new(game.sounds, "assets/Virus Arcade Panic (1).mp3")
    game.audio:setMasterVolume(settings.volume or 0.8)
    game.audio:setBgmVolume((settings.volume or 0.8) * 0.65)
    game.audio:playBgm()

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

    -- White pixel for particles
    local whiteCanvas = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(whiteCanvas)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setCanvas()
    game.images.white = whiteCanvas

    -- CRT Shader
    game.shader = Shaders.new()

    sm = StateMachine.new({
        menu        = require("states.menu"),
        playing     = require("states.playing"),
        cardselect  = require("states.cardselect"),
        gameover    = require("states.gameover"),
        victory     = require("states.victory"),
        pause       = require("states.pause"),
        settings    = require("states.settings"),
        runsummary  = require("states.runsummary"),
    })

    sm:switch("menu", game, sm)
end

function love.update(dt)
    game.scanlineOffset = (game.scanlineOffset + dt * 50) % 4
    game.camera:update(dt, Config.SHAKE_DECAY_SPEED)
    game.timers:update(dt)
    game.particles:update(dt)
    sm:update(dt)
end

function love.keypressed(key)
    if key == "f11" then
        local fullscreen = not love.window.getFullscreen()
        love.window.setFullscreen(fullscreen, "desktop")
        Save.setSetting("fullscreen", fullscreen)
        return
    end
    sm:keypressed(key)
end

function love.joystickpressed(joystick, button)
    local key = "joystick" .. joystick:getID() .. "button" .. button
    if button == 0 then key = "space"  -- A button
    elseif button == 1 then key = "escape"  -- B button
    elseif button == 2 then key = nil  -- X button
    elseif button == 3 then key = nil  -- Y button
    end
    if key then sm:keypressed(key) end
end

function love.resize(w, h) end

function love.draw()
    local winW, winH = love.graphics.getDimensions()
    local settings = Save.getSettings()

    love.graphics.setCanvas(game.canvas)
    love.graphics.clear(Config.COLOR_BG[1], Config.COLOR_BG[2], Config.COLOR_BG[3], 1)
    love.graphics.origin()
    if settings.screenShake ~= false then
        game.camera:applyShake()
    end
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

    -- Apply CRT shader if enabled
    if settings.crtEffect and game.shader then
        game.shader:setBrainrot(game.brainrotLevel)
        game.shader:sendResolution(winW, winH)
        game.shader:sendTime(love.timer.getTime())
        game.shader:apply()
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(game.canvas, ox, oy, 0, scale, scale)

    if settings.crtEffect and game.shader then
        game.shader:reset()
    end

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
