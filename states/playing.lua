-- Core gameplay — dark gothic, sidebar layout, Phase 4 audio, Phase 3 brainrot
local Config    = require("config")
local Ball      = require("entities.ball")
local Paddle    = require("entities.paddle")
local Brick     = require("entities.brick")
local Layouts   = require("data.layouts")
local Collision = require("systems.collision")
local Modifiers = require("systems.modifiers")
local Brainrot  = require("effects.brainrot")
local HUD       = require("ui.hud")

local Playing = {}

function Playing:enter(game, sm, freshStart, options)
    self.game = game
    self.sm   = sm
    options = options or {}
    local isEndless = options.endless or false

    if freshStart ~= false then
        game.score         = 0
        game.combo         = 0
        game.comboTimer    = 0  -- Time since last combo increase
        game.stage         = 1
        game.lives         = Config.STARTING_LIVES
        game.brainrotLevel = 0
        game.isEndless     = isEndless
        game.modifiers     = Modifiers.new()
        game.popups:clear()
        game.paddle = Paddle.new(game.images.paddleScaled)
        game.balls  = { Ball.new() }
        game.bricks = Layouts.get(game.stage)
    end
    -- Seed atmospheric text positions
    self.bgTexts = {}
    for i = 1, 6 do
        table.insert(self.bgTexts, {
            text = Config.BG_TEXTS[math.random(#Config.BG_TEXTS)],
            x = Config.PLAY_AREA_LEFT + math.random(100, 800),
            y = math.random(100, 600),
            rot = (math.random() - 0.5) * 0.6,
            scale = 1.5 + math.random() * 1.5,
        })
    end
    
    self.activeVideos = {}
end

function Playing:update(dt)
    local game = self.game
    local steps = math.max(1, math.ceil(dt / 0.008))
    local stepDt = dt / steps

    -- Update audio state
    game.audio:updateState(game.brainrotLevel, game.combo)

    -- Combo decay
    if game.combo > 0 then
        game.comboTimer = (game.comboTimer or 0) + dt
        if game.comboTimer > Config.COMBO_DECAY_TIME and game.combo > 0 then
            game.combo = math.max(0, game.combo - Config.COMBO_DECAY_RATE * dt)
            if game.combo == 0 then
                game.popups:banner("COMBO LOST", Config.COLOR_MUTED, 1.0)
            end
        end
    end

    -- Cleanup videos that finished playing
    for i = #(self.activeVideos or {}), 1, -1 do
        local vid = self.activeVideos[i]
        if not vid:isPlaying() then
            table.remove(self.activeVideos, i)
        end
    end

    Paddle.update(game.paddle, dt)
    Brick.updateAll(game.bricks, dt)
    game.popups:update(dt)

    if Brainrot.shouldSpawnNotif(game.brainrotLevel, dt) then
        game.popups:fakeNotif(Brainrot.getRandomNotif())
    end

    for i = #game.balls, 1, -1 do
        local ball = game.balls[i]
        if not ball.alive then
            table.remove(game.balls, i)
        elseif not ball.active then
            ball.x = game.paddle.x
            ball.y = game.paddle.y - 25
        else
            for _ = 1, steps do
                self:updateActiveBall(ball, stepDt)
                if not ball.alive then break end
            end

            if Collision.ballDead(ball) then
                if #game.balls > 1 then
                    ball.alive = false
                elseif game.modifiers:has("shieldRow") then
                    Ball.reset(ball, game.paddle.x, game.paddle.y)
                    game.modifiers:remove("shieldRow")
                    game.popups:banner("SHIELD USED!", {0.5, 0.8, 1.0})
                elseif game.modifiers:has("comboShield") and game.combo >= 5 then
                    Ball.reset(ball, game.paddle.x, game.paddle.y)
                    game.combo = 0
                    game.popups:banner("COMBO SAVE!", {0.2, 1, 0.5})
                else
                    game.lives = game.lives - 1
                    game.combo = 0
                    game.comboTimer = 0
                    if game.lives <= 0 then
                        game.audio:play("fah")
                        self.sm:switch("gameover", game, self.sm)
                        return
                    else
                        Ball.reset(ball, game.paddle.x, game.paddle.y)
                        game.camera:shake(8)
                        game.audio:play("fah", {volume = 0.7})
                        game.popups:banner("LIFE LOST! (" .. game.lives .. " left)",
                                          Config.COLOR_LIVES, 2.0)
                    end
                end
            end
        end
    end

    if #game.balls == 0 then game.balls = { Ball.new() } end

    if game.modifiers:has("brickRegen") then
        for _, b in ipairs(game.bricks) do
            if not b.active and math.random() < 0.002 then
                b.active = true; b.hp = 1; b.hitFlash = 1.0
            end
        end
    end

    if Brick.countActive(game.bricks) == 0 then
        game.brainrotLevel = game.brainrotLevel + 1

        if game.isEndless then
            -- Endless: keep going forever with escalating difficulty
            game.stage = game.stage + 1
            game.bricks = Layouts.get(game.stage)
            -- Make bricks harder in endless
            for _, b in ipairs(game.bricks) do
                b.hp = b.hp + math.floor(game.stage / 3)
                b.maxHp = b.hp
            end
            game.popups:banner("STAGE " .. game.stage, Config.COLOR_GOLD, 1.5)
        elseif game.stage >= Config.MAX_STAGES then
            self.sm:switch("victory", game, self.sm)
        else
            game.stage = game.stage + 1
            self.sm:switch("cardselect", game, self.sm)
        end
    end
end

function Playing:updateActiveBall(ball, dt)
    local game = self.game
    Ball.update(ball, dt)

    if game.modifiers:has("gravityWell") then
        self:applyGravityWell(ball, dt)
    end

    Collision.ballWalls(ball)
    Ball.enforceSpeedLimits(ball)

    if Collision.ballPaddle(ball, game.paddle) then
        local comboInc = game.modifiers:has("comboMagnet") and 2 or 1
        game.combo = game.combo + comboInc
        game.comboTimer = 0
        game.camera:shake(Config.SHAKE_PADDLE_HIT)
        game.particles:createHitSparks(ball.x, ball.y)
        Ball.enforceSpeedLimits(ball)

        game.audio:playCombo("bonk", game.combo)

        local msg = Brainrot.getComboMessage(game.combo, game.brainrotLevel)
        if msg then game.popups:banner(msg, {1, 0.6, 0.1}) end

        if game.modifiers:has("glitchPaddle") then
            game.paddle.x = math.random(
                math.floor(Config.PLAY_AREA_LEFT + game.paddle.width),
                math.floor(Config.GAME_WIDTH - game.paddle.width))
        end

        if game.modifiers:has("multiball") and game.combo > 0 and game.combo % 10 == 0 then
            self:spawnExtraBalls(ball)
            game.popups:banner("MULTIBALL!", {0.8, 0.2, 0.2})
        end
    end

    local isGhost = game.modifiers:has("ghostBall")
    local isPiercing = game.modifiers:has("piercingShot")
    local hitOne = false

    for j = #game.bricks, 1, -1 do
        local brick = game.bricks[j]
        if not hitOne or isGhost or isPiercing then
            if Collision.ballBrick(ball, brick, isGhost or isPiercing) then
                self:damageBrick(brick)
                hitOne = true
                Ball.enforceSpeedLimits(ball)
                if not isGhost and not isPiercing then break end
            end
        end
    end
end

function Playing:damageBrick(brick)
    local game = self.game
    brick.hp = brick.hp - 1
    brick.hitFlash = 1.0

    if brick.hp <= 0 then
        brick.active = false
        
        -- Media Trigger
        local media = game.mediaMappings[brick.name]
        if media then
            if media.type == "audio" then
                media.src:stop() -- restart if already playing
                media.src:play()
            elseif media.type == "video" then
                media.src:rewind()
                media.src:play()
                
                -- Check if not already in activeVideos
                local alreadyActive = false
                for _, v in ipairs(self.activeVideos) do
                    if v == media.src then alreadyActive = true break end
                end
                if not alreadyActive then
                    table.insert(self.activeVideos, media.src)
                end
            end
        end

        local mult = 1
        if game.modifiers:has("scoreFrenzy") then mult = mult * 3 end
        if game.modifiers:has("speedDemon") then mult = mult * 2 end
        local gained = math.floor(Config.SCORE_PER_BRICK
            * (1 + game.combo * Config.COMBO_SCORE_MULTIPLIER) * mult)
        game.score = game.score + gained
        game.camera:shake(Config.SHAKE_BRICK_DESTROY)

        local brickColor = Config.BRICK_COLORS[brick.colorIdx] or {0.7, 0.3, 0.2}
        game.particles:createBrickDebris(brick.x + brick.width/2, brick.y + brick.height/2, brickColor)
        game.popups:text(brick.x + brick.width/2, brick.y, "+" .. gained, Config.COLOR_GOLD, 0.7, 0.8)
        game.audio:playCombo("punch", game.combo)

        if game.modifiers:has("exploding") then self:explodeAdjacent(brick) end
        if game.modifiers:has("chainLightning") then self:chainLightning() end
    else
        game.audio:play("bonk", {volume = 0.6})
    end
end

function Playing:draw()
    local game = self.game
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT
    love.graphics.setBackgroundColor(Config.COLOR_BG_DARK)

    local function drawImageCover(img, x, y, w, h, alpha)
        if not img then return end
        local iw, ih = img:getDimensions()
        local scale = math.max(w / iw, h / ih)
        love.graphics.setColor(1, 1, 1, alpha or 1)
        love.graphics.draw(img, x + (w - iw * scale) / 2, y + (h - ih * scale) / 2, 0, scale, scale)
    end

    -- Dark textured background like menu
    drawImageCover(game.images.background, 0, 0, W, H, 1)
    love.graphics.setColor(0, 0, 0, 0.65)
    love.graphics.rectangle("fill", 0, 0, W, H)
    drawImageCover(game.images.scratchedMetal, 0, 0, W, H, 0.12)

    -- Gothic subtle atmospheric texture (no more sci-fi grid)
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", Config.PLAY_AREA_LEFT, Config.TOP_BAR_HEIGHT, W - Config.PLAY_AREA_LEFT, H - Config.TOP_BAR_HEIGHT)
    
    -- Center atmospheric glow
    love.graphics.setColor(0.15, 0.01, 0.01, 0.18)
    love.graphics.circle("fill", (Config.PLAY_AREA_LEFT + W) / 2, H / 2, 200)
    
    love.graphics.setColor(0, 0, 0, 0.45)
    love.graphics.rectangle("fill", Config.PLAY_AREA_LEFT, Config.TOP_BAR_HEIGHT, W - Config.PLAY_AREA_LEFT, H - Config.TOP_BAR_HEIGHT)

    local bloodOverlay = game.images.bloodOverlay
    if bloodOverlay then
        love.graphics.setColor(0.65, 0.04, 0.025, 0.14 + math.min(game.brainrotLevel, 8) * 0.012)
        love.graphics.draw(
            bloodOverlay,
            W - 500, Config.TOP_BAR_HEIGHT - 95,
            -0.05,
            560 / bloodOverlay:getWidth(),
            380 / bloodOverlay:getHeight()
        )
        love.graphics.setColor(0.55, 0.025, 0.02, 0.08 + math.min(game.brainrotLevel, 8) * 0.008)
        love.graphics.draw(
            bloodOverlay,
            Config.PLAY_AREA_LEFT + 35, H - 225,
            0.12,
            430 / bloodOverlay:getWidth(),
            280 / bloodOverlay:getHeight()
        )
    end

    -- Atmospheric background text (faded watermarks in play area)
    if self.bgTexts then
        love.graphics.setFont(game.fonts.large)
        for _, t in ipairs(self.bgTexts) do
            local alpha = 0.03 + game.brainrotLevel * 0.005
            love.graphics.setColor(Config.COLOR_RED_BRIGHT[1], Config.COLOR_RED_BRIGHT[2],
                                   Config.COLOR_RED_BRIGHT[3], alpha)
            love.graphics.print(t.text, t.x, t.y, t.rot, t.scale, t.scale)
        end
    end

    -- (Subtle grid removed for dark fantasy look)

    -- Bricks
    for _, brick in ipairs(game.bricks) do
        Brick.draw(brick, game.fonts.small)
    end

    Paddle.draw(game.paddle)

    for _, ball in ipairs(game.balls) do
        if ball.active then
            game.particles:createBallTrail(ball)
        end
        game.particles:drawBallTrail(ball)
        Ball.draw(ball)
    end

    game.particles:draw()

    -- Brainrot effects
    Brainrot.drawEffects(game.brainrotLevel, love.timer.getTime())

    -- Popups
    game.popups:draw(game.fonts.main)

    -- Launch prompt
    local hasInactive = false
    for _, ball in ipairs(game.balls) do
        if not ball.active then hasInactive = true; break end
    end
    if hasInactive then
        local cx = (Config.PLAY_AREA_LEFT + W) / 2
        local pulse = 0.5 + 0.5 * math.sin(love.timer.getTime() * 3)
        
        love.graphics.setFont(game.fonts.large)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf("PRESS SPACE", Config.PLAY_AREA_LEFT + 2, H/2 - 28, W - Config.PLAY_AREA_LEFT, "center")
        love.graphics.setColor(Config.COLOR_GOLD[1], Config.COLOR_GOLD[2], Config.COLOR_GOLD[3], 0.7 + 0.3 * pulse)
        love.graphics.printf("PRESS SPACE", Config.PLAY_AREA_LEFT, H/2 - 30, W - Config.PLAY_AREA_LEFT, "center")
        
        love.graphics.setFont(game.fonts.main)
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf("TO DESCEND", Config.PLAY_AREA_LEFT + 2, H/2 + 7, W - Config.PLAY_AREA_LEFT, "center")
        love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2], Config.COLOR_ACCENT[3], 0.6 + 0.4 * pulse)
        love.graphics.printf("TO DESCEND", Config.PLAY_AREA_LEFT, H/2 + 5, W - Config.PLAY_AREA_LEFT, "center")
    end

    -- Render active overlay videos
    if self.activeVideos and #self.activeVideos > 0 then
        local cx = (Config.PLAY_AREA_LEFT + W) / 2
        local cy = H / 2
        for _, vid in ipairs(self.activeVideos) do
            local vw, vh = vid:getDimensions()
            local vscale = math.min((W - Config.PLAY_AREA_LEFT - 100) / vw, (H - 100) / vh) * 0.9
            local drawW, drawH = vw * vscale, vh * vscale
            local dx = cx - drawW / 2
            local dy = cy - drawH / 2
            
            -- Dark fantasy border shadow
            love.graphics.setColor(0, 0, 0, 0.95)
            love.graphics.rectangle("fill", dx - 8, dy - 8, drawW + 16, drawH + 16, 4, 4)
            love.graphics.setColor(Config.COLOR_PANEL_BORDER)
            love.graphics.setLineWidth(4)
            love.graphics.rectangle("line", dx - 4, dy - 4, drawW + 8, drawH + 8, 4, 4)
            love.graphics.setLineWidth(1)
            
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(vid, dx, dy, 0, vscale, vscale)
        end
    end

    -- HUD last (sidebar + top bar drawn on top)
    HUD.draw(game, game.fonts)
end

function Playing:keypressed(key)
    local game = self.game
    if key == "space" or key == "return" then
        for _, ball in ipairs(game.balls) do
            if not ball.active then Ball.launch(ball); break end
        end
    elseif key == "escape" then
        self.sm:push("pause", game, self.sm)
    end
end

function Playing:mousemoved(x, y, dx, dy)
    local game = self.game
    if game and game.paddle then
        game.paddle.x = math.max(Config.PLAY_AREA_LEFT + game.paddle.width/2,
                   math.min(Config.GAME_WIDTH - game.paddle.width/2, x))
    end
end

function Playing:mousepressed(x, y, button)
    if button == 1 then
        for _, ball in ipairs(self.game.balls) do
            if not ball.active then Ball.launch(ball); break end
        end
    end
end

function Playing:spawnExtraBalls(source)
    local game = self.game
    if #game.balls >= 8 then return end
    for _ = 1, 2 do
        if #game.balls >= 8 then break end
        local nb = Ball.new(source.x, source.y)
        nb.active = true
        nb.dx = source.dx + (math.random() - 0.5) * 300
        nb.dy = source.dy + (math.random() - 0.5) * 150
        if game.modifiers:has("megaBall") then nb.radius = Config.BALL_RADIUS * 2 end
        Ball.enforceSpeedLimits(nb)
        table.insert(game.balls, nb)
    end
end

function Playing:explodeAdjacent(deadBrick)
    for _, b in ipairs(self.game.bricks) do
        if b.active then
            local dx = math.abs((b.x+b.width/2)-(deadBrick.x+deadBrick.width/2))
            local dy = math.abs((b.y+b.height/2)-(deadBrick.y+deadBrick.height/2))
            if dx < deadBrick.width*1.2 and dy < deadBrick.height*1.2 and b ~= deadBrick then
                b.hp = b.hp - 1; b.hitFlash = 1.0
                if b.hp <= 0 then b.active = false; self.game.score = self.game.score + Config.SCORE_PER_BRICK * 0.5 end
            end
        end
    end
end

function Playing:chainLightning()
    local active = {}
    for _, b in ipairs(self.game.bricks) do if b.active then table.insert(active, b) end end
    if #active > 0 then
        local t = active[math.random(#active)]
        t.hp = t.hp - 1; t.hitFlash = 1.0
        if t.hp <= 0 then t.active = false; self.game.score = self.game.score + Config.SCORE_PER_BRICK * 0.5 end
    end
end

function Playing:applyGravityWell(ball, dt)
    local nd, nb = math.huge, nil
    for _, b in ipairs(self.game.bricks) do
        if b.active then
            local bx, by = b.x+b.width/2, b.y+b.height/2
            local d = math.sqrt((ball.x-bx)^2+(ball.y-by)^2)
            if d < nd then nd = d; nb = b end
        end
    end
    if nb and nd < 250 then
        local bx, by = nb.x+nb.width/2, nb.y+nb.height/2
        local s = 100*(1-nd/250)
        ball.dx = ball.dx + (bx-ball.x)/nd*s*dt
        ball.dy = ball.dy + (by-ball.y)/nd*s*dt
    end
end

return Playing
