-- Popup notification system for Phase 3: brainrot escalation
-- Spawns floating text, fake notifications, achievement banners
local Config = require("config")
local Popup = {}
Popup.__index = Popup

function Popup.new()
    return setmetatable({ items = {} }, Popup)
end

-- Spawn floating text at position
function Popup:text(x, y, text, color, size, duration)
    table.insert(self.items, {
        type     = "text",
        x        = x,
        y        = y,
        text     = text,
        color    = color or {1, 1, 1},
        size     = size or 1.0,
        duration = duration or 1.5,
        elapsed  = 0,
        vy       = -60,  -- float upward
    })
end

-- Spawn a notification banner (top or random position)
function Popup:banner(text, color, duration)
    table.insert(self.items, {
        type     = "banner",
        x        = Config.GAME_WIDTH / 2,
        y        = Config.GAME_HEIGHT / 2 + math.random(-80, 80),
        text     = text,
        color    = color or {1, 0.8, 0.2},
        duration = duration or 2.5,
        elapsed  = 0,
        scale    = 2.0,  -- starts big, shrinks
    })
end

-- Spawn a fake system notification
function Popup:fakeNotif(text, duration)
    local w = 280
    table.insert(self.items, {
        type     = "notif",
        x        = Config.GAME_WIDTH - w - 10 - math.random(0, 100),
        y        = math.random(60, Config.GAME_HEIGHT - 120),
        width    = w,
        text     = text,
        duration = duration or 3.0,
        elapsed  = 0,
    })
end

function Popup:update(dt)
    for i = #self.items, 1, -1 do
        local p = self.items[i]
        p.elapsed = p.elapsed + dt
        if p.type == "text" then
            p.y = p.y + p.vy * dt
        elseif p.type == "banner" then
            p.scale = math.max(1.0, p.scale - dt * 2)
        end
        if p.elapsed >= p.duration then
            table.remove(self.items, i)
        end
    end
end

function Popup:draw(font)
    for _, p in ipairs(self.items) do
        local alpha = 1.0
        local fadeStart = p.duration * 0.6
        if p.elapsed > fadeStart then
            alpha = 1.0 - (p.elapsed - fadeStart) / (p.duration - fadeStart)
        end

        if p.type == "text" then
            love.graphics.setFont(font)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            local sc = p.size * (1 + (1 - p.elapsed / p.duration) * 0.3)
            love.graphics.print(p.text, p.x, p.y, 0, sc, sc)

        elseif p.type == "banner" then
            love.graphics.setFont(font)
            love.graphics.setColor(p.color[1], p.color[2], p.color[3], alpha)
            local w = font:getWidth(p.text) * p.scale
            love.graphics.print(p.text, p.x - w / 2, p.y, 0, p.scale, p.scale)

        elseif p.type == "notif" then
            -- Fake notification box
            love.graphics.setColor(0.15, 0.15, 0.2, alpha * 0.9)
            love.graphics.rectangle("fill", p.x, p.y, p.width, 50, 6, 6)
            love.graphics.setColor(0.8, 0.3, 0.3, alpha * 0.6)
            love.graphics.rectangle("line", p.x, p.y, p.width, 50, 6, 6)
            love.graphics.setFont(font)
            love.graphics.setColor(1, 1, 1, alpha * 0.9)
            love.graphics.printf(p.text, p.x + 10, p.y + 15, p.width - 20, "left")
        end
    end
end

function Popup:clear()
    self.items = {}
end

return Popup
