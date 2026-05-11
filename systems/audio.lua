-- Audio manager — Phase 4: dynamic pitch, volume, combo scaling
local Config = require("config")
local Audio = {}
Audio.__index = Audio

function Audio.new(sounds)
    return setmetatable({
        sounds = sounds or {},
        comboMultiplier = 1.0,
        brainrotPitch = 1.0,
        masterVolume = 1.0,
    }, Audio)
end

-- Play a sound with dynamic pitch/volume based on game state
function Audio:play(name, opts)
    opts = opts or {}
    local src = self.sounds[name]
    if not src then return end

    local clone = src:clone()
    local pitch = (opts.pitch or 1.0) * self.brainrotPitch
    local volume = (opts.volume or 1.0) * self.masterVolume

    -- Add slight random variation for organic feel
    pitch = pitch + (math.random() - 0.5) * 0.08
    volume = math.min(1.0, volume)

    clone:setPitch(math.max(0.5, math.min(2.0, pitch)))
    clone:setVolume(volume)
    clone:play()
    return clone
end

-- Play with combo-scaled pitch (higher combo = higher pitch)
function Audio:playCombo(name, combo, opts)
    opts = opts or {}
    local comboPitch = 1.0 + math.min(combo, 30) * 0.015
    opts.pitch = (opts.pitch or 1.0) * comboPitch
    return self:play(name, opts)
end

-- Update audio state based on game state
function Audio:updateState(brainrotLevel, combo)
    -- Brainrot increases pitch slightly
    self.brainrotPitch = 1.0 + (brainrotLevel or 0) * 0.03
    self.comboMultiplier = 1.0 + math.min(combo or 0, 30) * 0.01
end

function Audio:setMasterVolume(vol)
    self.masterVolume = math.max(0, math.min(1, vol))
end

return Audio
