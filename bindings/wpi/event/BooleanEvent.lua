---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local EventLoop = require('wpi.event.EventLoop')
local Debouncer = require('wpi.math.filter.Debouncer')

---@class BooleanEvent
---@field private _loop EventLoop The event loop that polls this event
---@field private _signal function The function that supplies the boolean signal
---@field private _state boolean The cached state from the last poll
local BooleanEvent = class()

---Initialize a new BooleanEvent
---@param self BooleanEvent
---@param loop EventLoop The loop that polls this event
---@param signal function The digital signal represented by this object (function returning boolean)
function BooleanEvent.init(self, loop, signal)
    if not loop then
        error('loop parameter is required for BooleanEvent')
    end
    if not signal then
        error('signal parameter is required for BooleanEvent')
    end
    
    self._loop = loop
    self._signal = signal
    self._state = signal()
    
    -- Bind to the loop to update state on each poll
    self._loop:bind(function()
        self._state = self._signal()
    end)
end

---Create a new BooleanEvent
---@param loop EventLoop The loop that polls this event
---@param signal function The digital signal (function returning boolean)
---@return BooleanEvent
function BooleanEvent.new(loop, signal)
    local instance = setmetatable({}, BooleanEvent)
    BooleanEvent.init(instance, loop, signal)
    return instance
end

---Returns the state of this signal (high or low) as of the last loop poll
---@return boolean True for high state, false for low state
function BooleanEvent:getAsBoolean()
    return self._state
end

---Bind an action to this event
---@param action function The action to run if this event is active
function BooleanEvent:ifHigh(action)
    self._loop:bind(function()
        if self._state then
            action()
        end
    end)
end

---Creates a new event that is active when this event is inactive
---@return BooleanEvent The negated event
function BooleanEvent:negate()
    return BooleanEvent.new(self._loop, function()
        return not self._state
    end)
end

---Composes this event with another, returning a new event active when both are active
---@param other function|BooleanEvent The event or function to compose with
---@return BooleanEvent The composed event
function BooleanEvent:opAnd(other)
    if not other then
        error('other parameter is required for and')
    end
    
    local otherFunc = type(other) == 'function' and other or function() return other:getAsBoolean() end
    
    return BooleanEvent.new(self._loop, function()
        return self._state and otherFunc()
    end)
end

---Composes this event with another, returning a new event active when either is active
---@param other function|BooleanEvent The event or function to compose with
---@return BooleanEvent The composed event
function BooleanEvent:opOr(other)
    if not other then
        error('other parameter is required for or')
    end
    
    local otherFunc = type(other) == 'function' and other or function() return other:getAsBoolean() end
    
    return BooleanEvent.new(self._loop, function()
        return self._state or otherFunc()
    end)
end

---Creates a new event that triggers when this one changes from false to true
---@return BooleanEvent The rising edge event
function BooleanEvent:rising()
    local previous = self._state
    
    return BooleanEvent.new(self._loop, function()
        local present = self._state
        local ret = not previous and present
        previous = present
        return ret
    end)
end

---Creates a new event that triggers when this one changes from true to false
---@return BooleanEvent The falling edge event
function BooleanEvent:falling()
    local previous = self._state
    
    return BooleanEvent.new(self._loop, function()
        local present = self._state
        local ret = previous and not present
        previous = present
        return ret
    end)
end

---Creates a new debounced event from this event
---@param seconds number The debounce period in seconds
---@param debounceType number? The debounce type (default: kRising)
---@return BooleanEvent The debounced event
function BooleanEvent:debounce(seconds, debounceType)
    debounceType = debounceType or Debouncer.DebounceType.kRising
    local debouncer = Debouncer.new(seconds, debounceType)
    
    return BooleanEvent.new(self._loop, function()
        return debouncer:calculate(self._state)
    end)
end

return BooleanEvent
