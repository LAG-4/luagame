-- Particle system — brick destruction, ball trails, explosions
local Particles = {}

local function configureEmissionArea(ps, shape, a, b)
    if ps.setEmissionArea then
        ps:setEmissionArea(shape, a or 0, b or a or 0, 0, false)
    elseif ps.setAreaSpread then
        ps:setAreaSpread(shape, a or 0, b or a or 0)
    end
end

local function configureGravity(ps, amount)
    if ps.setLinearAcceleration then
        ps:setLinearAcceleration(0, amount, 0, amount)
    elseif ps.setGravity then
        ps:setGravity(amount)
    end
end

local function configureSizes(ps, ...)
    if ps.setSizes then
        ps:setSizes(...)
    elseif ps.setSize then
        ps:setSize(...)
    end
end

local function configureColors(ps, ...)
    if ps.setColors then
        ps:setColors(...)
    elseif ps.setColor then
        ps:setColor(...)
    end
end

local function trackSystem(self, ps, life, x, y)
    table.insert(self.systems, {system = ps, life = life, x = x, y = y})
    while #self.systems > 80 do
        table.remove(self.systems, 1)
    end
end

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
    configureEmissionArea(ps, "uniform", 20, 10)
    ps:setDirection(-math.pi/2)
    ps:setSpread(math.pi)
    ps:setSpeed(50, 200)
    configureGravity(ps, 400)
    configureSizes(ps, 1, 2.5)
    configureColors(ps, color[1], color[2], color[3], 1, color[1]*0.5, color[2]*0.5, color[3]*0.5, 0)
    ps:emit(15 + math.random(10))
    trackSystem(self, ps, 1.0, x, y)
    return ps
end

function Particles:createBallTrail(ball)
    if not ball.particleTrail then
        ball.particleTrail = {}
    end
    table.insert(ball.particleTrail, {x = ball.x, y = ball.y})
    if #ball.particleTrail > 20 then
        table.remove(ball.particleTrail, 1)
    end
end

function Particles:drawBallTrail(ball)
    local positions = ball.particleTrail
    if not positions or #positions < 2 then return end

    for i, pos in ipairs(positions) do
        local progress = i / #positions
        local alpha = progress * 0.6
        local size = 4 + progress * 5
        love.graphics.setColor(0.9, 0.7, 0.3, alpha)
        love.graphics.circle("fill", pos.x, pos.y, size)
    end
end

function Particles:createHitSparks(x, y)
    local ps = love.graphics.newParticleSystem(self.whiteImage, 30)
    ps:setParticleLifetime(0.1, 0.3)
    ps:setEmissionRate(0)
    configureEmissionArea(ps, "uniform", 5, 5)
    ps:setDirection(0)
    ps:setSpread(math.pi * 2)
    ps:setSpeed(100, 300)
    configureGravity(ps, 200)
    configureSizes(ps, 0.5, 1.25)
    configureColors(ps, 1, 0.9, 0.5, 1, 1, 0.5, 0, 0)
    ps:emit(8 + math.random(5))
    trackSystem(self, ps, 0.4, x, y)
end

function Particles:createComboFire(x, y, combo)
    local count = math.min(20 + combo * 2, 40)
    local ps = love.graphics.newParticleSystem(self.whiteImage, count)
    ps:setParticleLifetime(0.3, 0.6)
    ps:setEmissionRate(0)
    configureEmissionArea(ps, "uniform", 10, 10)
    ps:setDirection(-math.pi/2)
    ps:setSpread(math.pi/2)
    ps:setSpeed(50 + combo * 5, 100 + combo * 10)
    configureGravity(ps, -100)
    configureSizes(ps, 1.25, 3.75)
    configureColors(ps, 1, 0.5 + combo * 0.02, 0, 1, 1, 0.2, 0, 0)
    ps:emit(count)
    trackSystem(self, ps, 0.8, x, y)
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
