-- Short-lived meme media overlays triggered by brick breaks.
-- Keeps video/audio distractions punchy without rewinding the same stream every hit.
local Config = require("config")

local Distractions = {}
Distractions.__index = Distractions

local function clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

local function videoSource(video)
    if not video or not video.getSource then return nil end
    local ok, source = pcall(video.getSource, video)
    if ok then return source end
    return nil
end

function Distractions.new(game)
    return setmetatable({
        game = game,
        active = nil,
        cooldowns = {},
    }, Distractions)
end

function Distractions:trigger(media)
    if not media then return end

    local now = love.timer.getTime()
    local id = media.name or media.label or tostring(media.src or media.video or media.sound)
    local cooldown = media.cooldown or 0.35
    if self.cooldowns[id] and self.cooldowns[id] > now then
        return
    end
    self.cooldowns[id] = now + cooldown

    if media.type == "audio" then
        if self.game.audio and media.soundName then
            self.game.audio:play(media.soundName, {volume = media.volume or 1.0, pitchVariance = 0.02})
        elseif media.src then
            media.src:stop()
            media.src:setVolume((media.volume or 1.0) * ((self.game.audio and self.game.audio.masterVolume) or 1))
            media.src:play()
        end
        return
    end

    if media.type == "image" then
        if self.game.audio and media.soundName then
            self.game.audio:play(media.soundName, {volume = media.volume or 1.0, pitchVariance = 0})
        elseif media.sound then
            media.sound:stop()
            media.sound:setVolume((media.volume or 1.0) * ((self.game.audio and self.game.audio.masterVolume) or 1))
            media.sound:play()
        end

        self.active = {
            id = id,
            kind = "image",
            image = media.image or media.src,
            startedAt = now,
            untilTime = now + (media.duration or 1.35),
            maxWidth = media.maxWidth or 360,
            maxHeight = media.maxHeight or 300,
        }
        return
    end

    if media.type ~= "video" then return end
    local video = media.video or media.src
    if not video then return end

    if self.active and self.active.id == id and self.active.untilTime > now then
        self.active.untilTime = now + (media.duration or 2.6)
        return
    end

    if self.active and self.active.video and self.active.video ~= video then
        pcall(self.active.video.pause, self.active.video)
    end

    pcall(video.rewind, video)
    local source = videoSource(video)
    if source then
        source:setVolume((media.volume or 0.95) * ((self.game.audio and self.game.audio.masterVolume) or 1))
    end
    pcall(video.play, video)

    self.active = {
        id = id,
        kind = "video",
        video = video,
        startedAt = now,
        untilTime = now + (media.duration or 2.6),
        maxWidth = media.maxWidth or 390,
        maxHeight = media.maxHeight or 260,
    }
end

function Distractions:update(dt)
    if not self.active then return end

    local now = love.timer.getTime()
    local video = self.active.video
    local playing = true
    if self.active.kind == "video" and video and video.isPlaying then
        local ok, isPlaying = pcall(video.isPlaying, video)
        playing = (not ok) or isPlaying
    end

    if now >= self.active.untilTime or not playing then
        if self.active.kind == "video" and video then pcall(video.pause, video) end
        self.active = nil
    end
end

function Distractions:draw()
    local active = self.active
    if not active then return end

    local drawable = active.kind == "image" and active.image or active.video
    if not drawable then return end
    local ok, vw, vh = pcall(drawable.getDimensions, drawable)
    if not ok or not vw or vw <= 0 or vh <= 0 then return end

    local now = love.timer.getTime()
    local fadeIn = clamp((now - active.startedAt) / 0.12, 0, 1)
    local fadeOut = clamp((active.untilTime - now) / 0.28, 0, 1)
    local alpha = math.min(fadeIn, fadeOut)
    if alpha <= 0 then return end

    local playW = Config.GAME_WIDTH - Config.PLAY_AREA_LEFT
    local scale = math.min(active.maxWidth / vw, active.maxHeight / vh)
    local drawW, drawH = vw * scale, vh * scale
    local cx = Config.PLAY_AREA_LEFT + playW * 0.5
    local cy = Config.TOP_BAR_HEIGHT + (Config.GAME_HEIGHT - Config.TOP_BAR_HEIGHT) * 0.56
    local wobble = math.sin(now * 26) * 3
    local dx = cx - drawW / 2 + wobble
    local dy = cy - drawH / 2 + math.cos(now * 21) * 2

    love.graphics.setColor(0, 0, 0, 0.78 * alpha)
    love.graphics.rectangle("fill", dx - 9, dy - 9, drawW + 18, drawH + 18, 2, 2)
    love.graphics.setColor(Config.COLOR_ACCENT[1], Config.COLOR_ACCENT[2], Config.COLOR_ACCENT[3], 0.75 * alpha)
    love.graphics.setLineWidth(3)
    love.graphics.rectangle("line", dx - 5, dy - 5, drawW + 10, drawH + 10, 2, 2)
    love.graphics.setColor(Config.COLOR_PANEL_BORDER[1], Config.COLOR_PANEL_BORDER[2], Config.COLOR_PANEL_BORDER[3], 0.55 * alpha)
    love.graphics.setLineWidth(1)
    love.graphics.rectangle("line", dx - 10, dy - 10, drawW + 20, drawH + 20, 2, 2)

    love.graphics.setColor(1, 1, 1, alpha)
    love.graphics.draw(drawable, dx, dy, 0, scale, scale)
end

return Distractions
