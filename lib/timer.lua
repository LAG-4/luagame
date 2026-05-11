local Timer = {}
Timer.__index = Timer

function Timer.new()
    return setmetatable({ _items = {}, _nextId = 1 }, Timer)
end

-- Call fn after `delay` seconds
function Timer:after(delay, fn)
    local id = self._nextId; self._nextId = id + 1
    table.insert(self._items, {
        id = id, type = "after", elapsed = 0, delay = delay, fn = fn
    })
    return id
end

-- Call fn every `interval` seconds, up to `count` times (nil = forever)
function Timer:every(interval, fn, count)
    local id = self._nextId; self._nextId = id + 1
    table.insert(self._items, {
        id = id, type = "every", elapsed = 0,
        interval = interval, fn = fn,
        limit = count or math.huge, ran = 0
    })
    return id
end

-- Linearly interpolate fields of `subject` toward `target` over `duration` seconds
function Timer:tween(duration, subject, target, onComplete)
    local id = self._nextId; self._nextId = id + 1
    local initial = {}
    for k in pairs(target) do initial[k] = subject[k] end
    table.insert(self._items, {
        id = id, type = "tween", elapsed = 0, duration = duration,
        subject = subject, target = target, initial = initial,
        onComplete = onComplete
    })
    return id
end

function Timer:cancel(id)
    for i, t in ipairs(self._items) do
        if t.id == id then table.remove(self._items, i); return end
    end
end

function Timer:clear()
    self._items = {}
end

function Timer:update(dt)
    for i = #self._items, 1, -1 do
        local t = self._items[i]
        t.elapsed = t.elapsed + dt
        local remove = false

        if t.type == "after" then
            if t.elapsed >= t.delay then t.fn(); remove = true end
        elseif t.type == "every" then
            while t.elapsed >= t.interval and t.ran < t.limit do
                t.elapsed = t.elapsed - t.interval
                t.fn(); t.ran = t.ran + 1
            end
            if t.ran >= t.limit then remove = true end
        elseif t.type == "tween" then
            local p = math.min(t.elapsed / t.duration, 1)
            for k, tv in pairs(t.target) do
                t.subject[k] = t.initial[k] + (tv - t.initial[k]) * p
            end
            if p >= 1 then
                if t.onComplete then t.onComplete() end
                remove = true
            end
        end

        if remove then table.remove(self._items, i) end
    end
end

return Timer
