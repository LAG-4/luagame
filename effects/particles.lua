-- Particle system — brick destruction, ball trails, explosions
local Particles = {}

function Particles.new()
    -- Create a simple white pixel
    local whiteCanvas = love.graphics.newCanvas(4, 4)
    love.graphics.setCanvas(whiteCanvas)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setCanvas()

    return setmetatable({
        systems = {},
        emitters = {},
        whiteImage = whiteCanvas,
    }, {__index = Particles})
end

function Particles:clear()
    self.systems = {}
    self.emitters = {}
end

function Particles:createBrickDebris(x, y, color)
    local ps = love.graphics.newParticleSystem(self.whiteImage, 50)
    ps:setParticleLifetime(0.4, 0.8)
    ps:setEmissionRate(0)
    ps:setAreaShape("rectangle", 20, 10)
    ps:setDirection(-math.pi/2, math.pi/2)
    ps:setSpeed(50, 200)
    ps:setGravity(400)
    ps:setSize(4, 10)
    ps:setColor(color[1], color[2], color[3], 1, color[1]*0.5, color[2]*0.5, color[3]*0.5, 0)
    ps:emit(15 + math.random(10))
    table.insert(self.systems, {system = ps, life = 1.0, x = x, y = y})
    return ps
end

function Particles:createBallTrail(ball)
    if not ball.trail then
        ball.trail = {x = ball.x, y = ball.y, positions = {}}
    end
    table.insert(ball.trail.positions, {x = ball.x, y = ball.y, alpha = 1.0})
    if #ball.trail.positions > 20 then
        table.remove(ball.trail.positions, 1)
    end
end

function Particles:drawBallTrail(ball)
    if not ball.trail or #ball.trail.positions < 2 then return end
    for i, pos in ipairs(ball.trail.positions) do
        local alpha = i / #ball.trail.positions * 0.6
        local size = 4 + (i / #ball.trail.positions) * 5
        love.graphics.setColor(0.9, 0.7, 0.3, alpha)
        love.graphics.circle("fill", pos.x, pos.y, size)
    end
end

function Particles:createHitSparks(x, y)
    local ps = love.graphics.newParticleSystem(self.whiteImage, 30)
    ps:setParticleLifetime(0.1, 0.3)
    ps:setEmissionRate(0)
    ps:setAreaShape("circle", 5)
    ps:setDirection(0, math.pi * 2)
    ps:setSpeed(100, 300)
    ps:setGravity(200)
    ps:setSize(2, 5)
    ps:setColor(1, 0.9, 0.5, 1, 1, 0.5, 0, 0)
    ps:emit(8 + math.random(5))
    table.insert(self.systems, {system = ps, life = 0.4, x = x, y = y})
end

function Particles:createComboFire(x, y, combo)
    local count = math.min(20 + combo * 2, 40)
    local ps = love.graphics.newParticleSystem(self.whiteImage, count)
    ps:setParticleLifetime(0.3, 0.6)
    ps:setEmissionRate(0)
    ps:setAreaShape("circle", 10)
    ps:setDirection(-math.pi/2, 0)
    ps:setSpeed(50 + combo * 5, 100 + combo * 10)
    ps:setGravity(-100)
    ps:setSize(5, 15)
    ps:setColor(1, 0.5 + combo * 0.02, 0, 1, 1, 0.2, 0, 0)
    ps:emit(count)
    table.insert(self.systems, {system = ps, life = 0.8, x = x, y = y})
end

function Particles:update(dt)
    for i = #self.systems, 1, -1 do
        local e = self.systems[i]
        e.life = e.life - dt
        if e.life > 0 then
            e.system:update(dt)
        else
            table.remove(self.systems, i)
        end
    end
end

function Particles:draw()
    for _, e in ipairs(self.systems) do
        love.graphics.draw(e.system, e.x, e.y)
    end
end

return Particles