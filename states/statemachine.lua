-- State machine — manages game states with enter/exit/update/draw/keypressed
local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(states)
    return setmetatable({
        states  = states or {},
        current = nil,
        name    = nil,
    }, StateMachine)
end

function StateMachine:add(name, state)
    self.states[name] = state
end

function StateMachine:switch(name, ...)
    if self.current and self.current.exit then
        self.current:exit()
    end
    self.current = self.states[name]
    self.name = name
    if self.current and self.current.enter then
        self.current:enter(...)
    end
end

function StateMachine:update(dt)
    if self.current and self.current.update then
        self.current:update(dt)
    end
end

function StateMachine:draw()
    if self.current and self.current.draw then
        self.current:draw()
    end
end

function StateMachine:keypressed(key)
    if self.current and self.current.keypressed then
        self.current:keypressed(key)
    end
end

function StateMachine:getName()
    return self.name
end

return StateMachine
