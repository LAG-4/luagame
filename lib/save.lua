-- Save/Load system — Phase 6: High scores and settings persistence
local Save = {}
local SAVE_PATH = "brainrot_arcade.dat"
local json = require("lib.json")

function Save.load()
    local data = {
        highScore = 0,
        highScoreEndless = 0,
        settings = {
            volume = 0.8,
            crtEffect = true,
            screenShake = true,
            fullscreen = true,
        }
    }

    local success, err = love.filesystem.getInfo(SAVE_PATH)
    if success then
        local loaded = love.filesystem.read(SAVE_PATH)
        local ok, decoded = pcall(json.decode, loaded)
        if ok and decoded then
            data.highScore = decoded.highScore or 0
            data.highScoreEndless = decoded.highScoreEndless or 0
            if decoded.settings then
                for k, v in pairs(decoded.settings) do
                    data.settings[k] = v
                end
            end
        end
    end
    return data
end

function Save.save(data)
    local serialized = json.encode(data)
    love.filesystem.write(SAVE_PATH, serialized)
end

function Save.getHighScore()
    local d = Save.load()
    return d.highScore
end

function Save.getHighScoreEndless()
    local d = Save.load()
    return d.highScoreEndless
end

function Save.trySetHighScore(score)
    if score > Save.getHighScore() then
        local d = Save.load()
        d.highScore = score
        Save.save(d)
        return true
    end
    return false
end

function Save.trySetHighScoreEndless(score)
    if score > Save.getHighScoreEndless() then
        local d = Save.load()
        d.highScoreEndless = score
        Save.save(d)
        return true
    end
    return false
end

function Save.getSettings()
    local d = Save.load()
    return d.settings
end

function Save.setSetting(key, value)
    local d = Save.load()
    d.settings[key] = value
    Save.save(d)
end

return Save
