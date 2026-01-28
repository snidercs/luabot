---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')

---@class EventLoop
---@field private _bindings function[] Table (array) of bound functions to execute on poll
---@field private _running boolean Flag indicating if loop is currently polling
local EventLoop = class()

---Initialize a new EventLoop instance
---@param self EventLoop
function EventLoop.init(self)
    self._bindings = {}
    self._running = false
end

---Create a new EventLoop instance
---@return EventLoop
function EventLoop.new()
    local instance = setmetatable({}, EventLoop)
    EventLoop.init(instance)
    return instance
end

---Bind a function to execute when the loop is polled.
---@param action function Function with no parameters to call on each poll
function EventLoop:bind(action)
    if self._running then
        error('Cannot bind EventLoop while it is running')
    end
    table.insert(self._bindings, action)
end

---Execute all bound actions in order.
function EventLoop:poll()
    self._running = true
    local success, err = pcall(function()
        for _, action in ipairs(self._bindings) do
            action()
        end
    end)
    self._running = false
    
    if not success then
        error(err, 0)
    end
end

---Remove all bound actions.
function EventLoop:clear()
    if self._running then
        error('Cannot clear EventLoop while it is running')
    end
    self._bindings = {}
end

return EventLoop
