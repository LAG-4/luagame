-- State machine with push/pop support for overlay states (pause)
local StateMachine = {}
StateMachine.__index = StateMachine

function StateMachine.new(states)
    return setmetatable({
        states  = states or {},
        current = nil,
        name    = nil,
        _stack  = {},
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

-- Push current state onto stack and switch to new one (for overlays like pause)
function StateMachine:push(name, ...)
    table.insert(self._stack, { state = self.current, name = self.name })
    self.current = self.states[name]
    self.name = name
    if self.current and self.current.enter then
        self.current:enter(...)
    end
end

-- Pop back to previous state (no enter/exit called on restored state)
function StateMachine:pop()
    if #self._stack > 0 then
        if self.current and self.current.exit then
            self.current:exit()
        end
        local prev = table.remove(self._stack)
        self.current = prev.state
        self.name = prev.name
    end
end

-- Get the state underneath the current one (for drawing in overlay states)
function StateMachine:getUnderneath()
    if #self._stack > 0 then
        return self._stack[#self._stack].state
    end
    return nil
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

function StateMachine:mousepressed(x, y, button)
    if self.current and self.current.mousepressed then
        self.current:mousepressed(x, y, button)
    end
end

return StateMachine
