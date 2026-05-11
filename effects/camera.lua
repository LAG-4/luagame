-- Camera effects: screen shake, flash
local Camera = {}
Camera.__index = Camera

function Camera.new()
    return setmetatable({
        shakeAmount = 0,
        flashColor  = nil,
        flashTimer  = 0,
    }, Camera)
end

function Camera:shake(amount)
    self.shakeAmount = math.max(self.shakeAmount, amount)
end

function Camera:flash(r, g, b, a, duration)
    self.flashColor = { r, g, b, a or 0.3 }
    self.flashTimer = duration or 0.1
end

function Camera:update(dt, decaySpeed)
    decaySpeed = decaySpeed or 10
    if self.shakeAmount > 0 then
        self.shakeAmount = math.max(0, self.shakeAmount - dt * decaySpeed)
    end
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then
            self.flashColor = nil
        end
    end
end

-- Call before drawing game content to apply shake offset
function Camera:applyShake()
    if self.shakeAmount > 0 then
        local sx = (math.random() - 0.5) * self.shakeAmount * 2
        local sy = (math.random() - 0.5) * self.shakeAmount * 2
        love.graphics.translate(sx, sy)
    end
end

-- Call after drawing game content to overlay flash
function Camera:drawFlash(width, height)
    if self.flashColor and self.flashTimer > 0 then
        love.graphics.setColor(self.flashColor)
        love.graphics.rectangle("fill", 0, 0, width, height)
    end
end

return Camera
