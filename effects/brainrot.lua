-- Brainrot escalation controller — Phase 3
-- Drives progressive visual/audio corruption based on brainrotLevel (0-10)
local Config = require("config")
local Brainrot = {}

-- Messages for different brainrot levels
Brainrot.MID_MESSAGES = {
    "Your combo is on FIRE 🔥",
    "WEIRD FLEX BUT OK",
    "NO THOUGHTS HEAD EMPTY",
    "SIR THIS IS A WENDY'S",
    "MAIN CHARACTER ENERGY",
    "IT'S GIVING... CHAOS",
    "POV: YOU'RE BRAINROTTING",
    "LIVING RENT FREE",
}

Brainrot.LATE_MESSAGES = {
    "AURA +1000 ✨",
    "GYATT LEVEL: MAXIMUM",
    "SIGMA GRINDSET ACTIVATED",
    "SKIBIDI TOILET DETECTED",
    "⚠️ SYSTEM OVERLOAD ⚠️",
    "DELULU IS THE SOLULU",
    "RATIO + L + COPE",
    "YOU JUST LOST THE GAME",
}

Brainrot.FAKE_NOTIFS = {
    "Windows: Your PC has a virus!",
    "Mom: Come eat dinner",
    "Discord: 99+ pings",
    "iPhone: Storage Full",
    "Duolingo: Spanish or vanish",
    "Your FBI agent is watching",
    "WiFi: Connected (no internet)",
    "McAfee: RENEW NOW!!!",
}

-- Get the current escalation tier
function Brainrot.getTier(level)
    if level <= 2 then return "early"
    elseif level <= 5 then return "mid"
    elseif level <= 8 then return "late"
    else return "endgame" end
end

-- Apply per-frame visual effects based on brainrot level
function Brainrot.drawEffects(level, time)
    if level <= 0 then return end
    local W, H = Config.GAME_WIDTH, Config.GAME_HEIGHT

    -- Mild red tint (increases with level)
    love.graphics.setColor(1, 0, 0, 0.01 * level)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- Mid-game: slight screen distortion (random offset lines)
    if level >= 3 then
        love.graphics.setColor(1, 1, 1, 0.02 * (level - 2))
        for i = 1, level - 2 do
            local lineY = (math.sin(time * 3 + i * 47) * 0.5 + 0.5) * H
            local offset = math.sin(time * 7 + i * 13) * (level - 2) * 2
            love.graphics.rectangle("fill", offset, lineY, W, 1)
        end
    end

    -- Late-game: color channel shift (poor man's chromatic aberration)
    if level >= 6 then
        local shift = (level - 5) * 0.008
        love.graphics.setColor(1, 0, 0, shift)
        love.graphics.rectangle("fill", -2, 0, W, H)
        love.graphics.setColor(0, 0, 1, shift)
        love.graphics.rectangle("fill", 2, 0, W, H)
    end

    -- Endgame: VHS tracking lines
    if level >= 9 then
        love.graphics.setColor(1, 1, 1, 0.04)
        local trackY = (time * 200) % H
        love.graphics.rectangle("fill", 0, trackY, W, 8)
        love.graphics.rectangle("fill", 0, trackY - H, W, 8)
    end
end

-- Called on combo milestones — returns a message or nil
function Brainrot.getComboMessage(combo, level)
    if level < 3 then return nil end

    if combo >= 5 and combo % 5 == 0 then
        if level >= 6 then
            return Brainrot.LATE_MESSAGES[math.random(#Brainrot.LATE_MESSAGES)]
        else
            return Brainrot.MID_MESSAGES[math.random(#Brainrot.MID_MESSAGES)]
        end
    end
    return nil
end

-- Should we spawn a fake notification? (random chance based on level)
function Brainrot.shouldSpawnNotif(level, dt)
    if level < 4 then return false end
    local chance = (level - 3) * 0.003 * dt  -- increases with level
    return math.random() < chance
end

-- Get a random fake notification message
function Brainrot.getRandomNotif()
    return Brainrot.FAKE_NOTIFS[math.random(#Brainrot.FAKE_NOTIFS)]
end

-- Get sound pitch modifier based on brainrot level
function Brainrot.getSoundPitch(level)
    if level <= 2 then return 1.0 end
    return 1.0 + (level - 2) * 0.05  -- gets slightly higher pitched
end

return Brainrot
