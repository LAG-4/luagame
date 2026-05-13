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
    videos         = {},
    mediaMappings  = {},
    canvas         = nil,
}

local sm

local function loadImage(path)
    local ok, image = pcall(love.graphics.newImage, path)
    if not ok then return nil end
    image:setFilter("linear", "linear")
    return image
end

local function getCanvasTransform()
    local winW, winH = love.graphics.getDimensions()
    local scaleX = winW / Config.GAME_WIDTH
    local scaleY = winH / Config.GAME_HEIGHT
    local scale  = math.min(scaleX, scaleY)
    local ox = math.floor((winW - Config.GAME_WIDTH * scale) / 2)
    local oy = math.floor((winH - Config.GAME_HEIGHT * scale) / 2)
    return winW, winH, scale, ox, oy
end

function love.load()
    love.window.setTitle("Brainrot Arcade")

    local settings = Save.getSettings()
    if settings.fullscreen ~= false then
        love.window.setFullscreen(true, "desktop")
    end

    local renderScale = Config.RENDER_SCALE or 1
    game.canvas = love.graphics.newCanvas(
        Config.GAME_WIDTH * renderScale,
        Config.GAME_HEIGHT * renderScale
    )
    game.canvas:setFilter("linear", "linear")

    local function loadFont(path, size)
        local ok, f = pcall(love.graphics.newFont, path, math.floor(size))
        if ok then return f end
        -- fallback to default
        return love.graphics.newFont(math.floor(size))
    end

    game.fonts.main       = loadFont("assets/fonts/Rajdhani-Regular.ttf", 18)
    game.fonts.small      = loadFont("assets/fonts/ShareTechMono-Regular.ttf", 13)
    game.fonts.large      = loadFont("assets/fonts/BlackOpsOne-Regular.ttf", 34)
    game.fonts.menuTiny   = loadFont("assets/fonts/Rajdhani-Regular.ttf", 13)
    game.fonts.menuSmall  = loadFont("assets/fonts/Rajdhani-SemiBold.ttf", 16)
    game.fonts.menuLarge  = loadFont("assets/fonts/Rajdhani-Bold.ttf", 22)
    game.fonts.menuButton = loadFont("assets/fonts/Rajdhani-Bold.ttf", 26)
    game.fonts.menuArcade = loadFont("assets/fonts/PressStart2P-Regular.ttf", 20)
    game.fonts.menuIcon   = loadFont("assets/fonts/ShareTechMono-Regular.ttf", 20)
    game.fonts.title      = loadFont("assets/fonts/Creepster-Regular.ttf", 52)
    game.fonts.stats      = loadFont("assets/fonts/ShareTechMono-Regular.ttf", 20)
    game.fonts.pixel      = loadFont("assets/fonts/PressStart2P-Regular.ttf", 14)

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

    game.images.background      = loadImage("assets/background image.png")
    game.images.homeReference   = loadImage("assets/home screen.png")
    game.images.bloodOverlay    = loadImage("assets/blood splatter overlay.png")
    game.images.scratchedMetal  = loadImage("assets/scratched metal overlay.png")
    game.images.brainLogo       = loadImage("assets/brain logo.png")
    game.images.brainrotLogo    = loadImage("assets/brainrot.png")
    game.images.breakerLogo     = loadImage("assets/breaker.png")
    game.images.character       = loadImage("assets/character 1.png")
    game.images.frame           = loadImage("assets/frame.png")
    game.images.glowingOverlays = loadImage("assets/glowing overlays.png")
    game.images.noThoughts      = loadImage("assets/no thoughts empty head.png")
    game.images.iPutThePro      = loadImage("assets/i put the pro.png")
    game.images.cornerTop       = loadImage("assets/metallic corner bracket top.png")
    game.images.cornerBottom    = loadImage("assets/metallic corner bracket bottom.png")

    -- White pixel for particles
    local whiteCanvas = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(whiteCanvas)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setCanvas()
    game.images.white = whiteCanvas

    -- Media triggers (Meme sounds and videos)
    local sahurSoundOk, sahurSound = pcall(love.audio.newSource, "assets/tung-tung-tung-tung-sahur.mp3", "static")
    if sahurSoundOk then
        game.sounds.sahur = sahurSound
        game.mediaMappings["TUNG TUNG TUNG SAHUR"] = { type = "audio", src = game.sounds.sahur }
    end

    local skibidiVideoOk, skibidiVideo = pcall(love.graphics.newVideo, "assets/skibidi bop yes yes yes yes (original video).ogv")
    if skibidiVideoOk then
        game.videos.skibidi = skibidiVideo
        game.mediaMappings["SKIBIDI"] = { type = "video", src = game.videos.skibidi }
    end

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

function love.mousepressed(x, y, button)
    if not sm or not sm.mousepressed then return end
    local _, _, scale, ox, oy = getCanvasTransform()
    local gx = (x - ox) / scale
    local gy = (y - oy) / scale
    if gx >= 0 and gx <= Config.GAME_WIDTH and gy >= 0 and gy <= Config.GAME_HEIGHT then
        sm:mousepressed(gx, gy, button)
    end
end

function love.mousemoved(x, y, dx, dy, istouch)
    if not sm or not sm.mousemoved then return end
    local _, _, scale, ox, oy = getCanvasTransform()
    local gx = (x - ox) / scale
    local gy = (y - oy) / scale
    local gdx = dx / scale
    local gdy = dy / scale
    sm:mousemoved(gx, gy, gdx, gdy, istouch)
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
    local settings = Save.getSettings()
    local winW, winH, scale, ox, oy = getCanvasTransform()
    local renderScale = Config.RENDER_SCALE or 1
    local sharpUiState = sm and (sm.name == "menu" or sm.name == "settings")

    love.graphics.setCanvas(game.canvas)
    love.graphics.clear(Config.COLOR_BG[1], Config.COLOR_BG[2], Config.COLOR_BG[3], 1)
    love.graphics.origin()
    love.graphics.scale(renderScale, renderScale)
    if settings.screenShake ~= false then
        game.camera:applyShake()
    end
    sm:draw()
    game.camera:drawFlash(Config.GAME_WIDTH, Config.GAME_HEIGHT)
    love.graphics.setCanvas()
    love.graphics.origin()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, winW, winH)

    -- Apply CRT shader if enabled
    if settings.crtEffect and not sharpUiState and game.shader then
        game.shader:setBrainrot(game.brainrotLevel)
        game.shader:sendResolution(winW, winH)
        game.shader:sendTime(love.timer.getTime())
        game.shader:apply()
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(game.canvas, ox, oy, 0, scale / renderScale, scale / renderScale)

    if settings.crtEffect and not sharpUiState and game.shader then
        game.shader:reset()
    end

    if settings.crtEffect and not sharpUiState then
        drawScanlines(winW, winH)
    end
end

function drawScanlines(w, h)
    love.graphics.setColor(0, 0, 0, 0.018)
    for y = game.scanlineOffset, h, 6 do
        love.graphics.rectangle("fill", 0, y, w, 1)
    end
    if game.brainrotLevel > 0 then
        love.graphics.setColor(0.6, 0, 0, 0.004 * game.brainrotLevel)
        love.graphics.rectangle("fill", 0, 0, w, h)
    end
    -- CRT border vignette
    love.graphics.setColor(0, 0, 0, 0.24)
    love.graphics.rectangle("fill", 0, 0, 3, h)
    love.graphics.rectangle("fill", w - 3, 0, 3, h)
    love.graphics.rectangle("fill", 0, 0, w, 3)
    love.graphics.rectangle("fill", 0, h - 3, w, 3)
end
