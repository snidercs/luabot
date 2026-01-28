---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local EventLoop = require('wpi.event.EventLoop')
local BooleanEvent = require('wpi.event.BooleanEvent')
local Debouncer = require('wpi.math.filter.Debouncer')

-- Test BooleanEvent construction
do
    local loop = EventLoop.new()
    local signal = function() return false end
    local event = BooleanEvent.new(loop, signal)
    
    lu.assertNotNil(event, 'BooleanEvent should be constructable')
    lu.assertFalse(event:getAsBoolean(), 'Initial state should be false')
end

collectgarbage()

-- Test BooleanEvent state updates on poll
do
    local loop = EventLoop.new()
    local state = false
    local signal = function() return state end
    local event = BooleanEvent.new(loop, signal)
    
    lu.assertFalse(event:getAsBoolean(), 'Initial state should be false')
    
    state = true
    loop:poll()
    lu.assertTrue(event:getAsBoolean(), 'State should be true after poll')
    
    state = false
    loop:poll()
    lu.assertFalse(event:getAsBoolean(), 'State should be false after poll')
end

collectgarbage()

-- Test ifHigh binding
do
    local loop = EventLoop.new()
    local state = false
    local signal = function() return state end
    local event = BooleanEvent.new(loop, signal)
    
    local actionCalled = false
    event:ifHigh(function()
        actionCalled = true
    end)
    
    loop:poll()
    lu.assertFalse(actionCalled, 'Action should not be called when state is false')
    
    state = true
    loop:poll()
    lu.assertTrue(actionCalled, 'Action should be called when state is true')
end

collectgarbage()

-- Test negate
do
    local loop = EventLoop.new()
    local state = false
    local signal = function() return state end
    local event = BooleanEvent.new(loop, signal)
    local negated = event:negate()
    
    lu.assertFalse(event:getAsBoolean(), 'Original event should be false')
    lu.assertTrue(negated:getAsBoolean(), 'Negated event should be true')
    
    state = true
    loop:poll()
    lu.assertTrue(event:getAsBoolean(), 'Original event should be true')
    lu.assertFalse(negated:getAsBoolean(), 'Negated event should be false')
end

collectgarbage()

-- Test and composition
do
    local loop = EventLoop.new()
    local state1 = false
    local state2 = false
    local event1 = BooleanEvent.new(loop, function() return state1 end)
    local event2 = BooleanEvent.new(loop, function() return state2 end)
    local composed = event1:opAnd(event2)
    
    loop:poll()
    lu.assertFalse(composed:getAsBoolean(), 'AND should be false when both false')
    
    state1 = true
    loop:poll()
    lu.assertFalse(composed:getAsBoolean(), 'AND should be false when only first true')
    
    state2 = true
    loop:poll()
    lu.assertTrue(composed:getAsBoolean(), 'AND should be true when both true')
    
    state1 = false
    loop:poll()
    lu.assertFalse(composed:getAsBoolean(), 'AND should be false when only second true')
end

collectgarbage()

-- Test or composition
do
    local loop = EventLoop.new()
    local state1 = false
    local state2 = false
    local event1 = BooleanEvent.new(loop, function() return state1 end)
    local event2 = BooleanEvent.new(loop, function() return state2 end)
    local composed = event1:opOr(event2)
    
    loop:poll()
    lu.assertFalse(composed:getAsBoolean(), 'OR should be false when both false')
    
    state1 = true
    loop:poll()
    lu.assertTrue(composed:getAsBoolean(), 'OR should be true when first true')
    
    state1 = false
    state2 = true
    loop:poll()
    lu.assertTrue(composed:getAsBoolean(), 'OR should be true when second true')
    
    state1 = true
    loop:poll()
    lu.assertTrue(composed:getAsBoolean(), 'OR should be true when both true')
end

collectgarbage()

-- Test rising edge
do
    local loop = EventLoop.new()
    local state = false
    local event = BooleanEvent.new(loop, function() return state end)
    local rising = event:rising()
    
    loop:poll()
    lu.assertFalse(rising:getAsBoolean(), 'Rising should be false initially')
    
    state = true
    loop:poll()
    lu.assertTrue(rising:getAsBoolean(), 'Rising should be true on false->true transition')
    
    loop:poll()
    lu.assertFalse(rising:getAsBoolean(), 'Rising should be false when staying true')
    
    state = false
    loop:poll()
    lu.assertFalse(rising:getAsBoolean(), 'Rising should be false on true->false transition')
end

collectgarbage()

-- Test falling edge
do
    local loop = EventLoop.new()
    local state = true
    local event = BooleanEvent.new(loop, function() return state end)
    local falling = event:falling()
    
    loop:poll()
    lu.assertFalse(falling:getAsBoolean(), 'Falling should be false initially')
    
    state = false
    loop:poll()
    lu.assertTrue(falling:getAsBoolean(), 'Falling should be true on true->false transition')
    
    loop:poll()
    lu.assertFalse(falling:getAsBoolean(), 'Falling should be false when staying false')
    
    state = true
    loop:poll()
    lu.assertFalse(falling:getAsBoolean(), 'Falling should be false on false->true transition')
end

collectgarbage()

-- Test debounce (basic functionality)
do
    local loop = EventLoop.new()
    local state = false
    local event = BooleanEvent.new(loop, function() return state end)
    local debounced = event:debounce(0.1, Debouncer.DebounceType.kRising)
    
    lu.assertNotNil(debounced, 'Debounced event should be created')
    lu.assertFalse(debounced:getAsBoolean(), 'Debounced event should be false initially')
end

collectgarbage()

-- Test composition with function
do
    local loop = EventLoop.new()
    local state1 = false
    local state2 = false
    local event = BooleanEvent.new(loop, function() return state1 end)
    local composed = event:opAnd(function() return state2 end)
    
    loop:poll()
    lu.assertFalse(composed:getAsBoolean(), 'Composed with function should work')
    
    state1 = true
    state2 = true
    loop:poll()
    lu.assertTrue(composed:getAsBoolean(), 'Composed with function should be true when both true')
end

collectgarbage()

print('TestBooleanEvent: All tests passed')
