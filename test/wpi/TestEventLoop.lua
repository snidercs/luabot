---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local EventLoop = require('wpi.event.EventLoop')

TestEventLoop = {}

function TestEventLoop:testConstruction()
    local loop = EventLoop.new()
    lu.assertNotNil(loop)
    collectgarbage()
end

function TestEventLoop:testBindAndPoll()
    local loop = EventLoop.new()
    local counter = 0
    
    loop:bind(function() counter = counter + 1 end)
    loop:bind(function() counter = counter + 2 end)
    
    loop:poll()
    lu.assertEquals(counter, 3)
    
    loop:poll()
    lu.assertEquals(counter, 6)
    
    collectgarbage()
end

function TestEventLoop:testExecutionOrder()
    local loop = EventLoop.new()
    local results = {}
    
    loop:bind(function() table.insert(results, 1) end)
    loop:bind(function() table.insert(results, 2) end)
    loop:bind(function() table.insert(results, 3) end)
    
    loop:poll()
    
    lu.assertEquals(#results, 3)
    lu.assertEquals(results[1], 1)
    lu.assertEquals(results[2], 2)
    lu.assertEquals(results[3], 3)
    
    collectgarbage()
end

function TestEventLoop:testCannotBindWhileRunning()
    local loop = EventLoop.new()
    local errorOccurred = false
    
    loop:bind(function()
        -- Try to bind during poll - should error
        local status, err = pcall(function()
            loop:bind(function() end)
        end)
        lu.assertFalse(status)
        lu.assertStrContains(err, 'while it is running')
        errorOccurred = true
    end)
    
    loop:poll()
    lu.assertTrue(errorOccurred)
    
    collectgarbage()
end

function TestEventLoop:testCannotClearWhileRunning()
    local loop = EventLoop.new()
    local errorOccurred = false
    
    loop:bind(function()
        local status, err = pcall(function()
            loop:clear()
        end)
        lu.assertFalse(status)
        lu.assertStrContains(err, 'while it is running')
        errorOccurred = true
    end)
    
    loop:poll()
    lu.assertTrue(errorOccurred)
    
    collectgarbage()
end

function TestEventLoop:testClear()
    local loop = EventLoop.new()
    local counter = 0
    
    loop:bind(function() counter = counter + 1 end)
    loop:poll()
    lu.assertEquals(counter, 1)
    
    loop:clear()
    loop:poll()
    lu.assertEquals(counter, 1)  -- Should not increment
    
    collectgarbage()
end

function TestEventLoop:testErrorInBinding()
    local loop = EventLoop.new()
    
    loop:bind(function()
        error('Test error')
    end)
    
    -- Error should propagate
    local status, err = pcall(function()
        loop:poll()
    end)
    lu.assertFalse(status)
    lu.assertStrContains(err, 'Test error')
    
    -- Loop should still be usable after error
    loop:clear()
    local executed = false
    loop:bind(function() executed = true end)
    loop:poll()
    lu.assertTrue(executed)
    
    collectgarbage()
end

function TestEventLoop:testMultiplePolls()
    local loop = EventLoop.new()
    local counter = 0
    
    loop:bind(function() counter = counter + 1 end)
    
    for i = 1, 10 do
        loop:poll()
    end
    
    lu.assertEquals(counter, 10)
    
    collectgarbage()
end

function TestEventLoop:testEmptyLoop()
    local loop = EventLoop.new()
    
    -- Should not error with no bindings
    loop:poll()
    loop:poll()
    
    collectgarbage()
end

function TestEventLoop:testMultipleBindings()
    local loop = EventLoop.new()
    local callOrder = {}
    
    -- Add many bindings
    for i = 1, 20 do
        loop:bind(function() table.insert(callOrder, i) end)
    end
    
    loop:poll()
    
    -- Verify all executed in order
    lu.assertEquals(#callOrder, 20)
    for i = 1, 20 do
        lu.assertEquals(callOrder[i], i)
    end
    
    collectgarbage()
end

function TestEventLoop:testClearAndRebind()
    local loop = EventLoop.new()
    local counter1 = 0
    local counter2 = 0
    
    loop:bind(function() counter1 = counter1 + 1 end)
    loop:poll()
    lu.assertEquals(counter1, 1)
    lu.assertEquals(counter2, 0)
    
    loop:clear()
    loop:bind(function() counter2 = counter2 + 1 end)
    loop:poll()
    lu.assertEquals(counter1, 1)  -- Should not increment
    lu.assertEquals(counter2, 1)  -- Should increment
    
    collectgarbage()
end

function TestEventLoop:testClosureCapture()
    local loop = EventLoop.new()
    local values = {}
    
    -- Test that closures capture variables correctly
    for i = 1, 5 do
        local captured = i  -- Capture value
        loop:bind(function()
            table.insert(values, captured)
        end)
    end
    
    loop:poll()
    
    lu.assertEquals(#values, 5)
    for i = 1, 5 do
        lu.assertEquals(values[i], i)
    end
    
    collectgarbage()
end

function TestEventLoop:testPartialErrorRecovery()
    local loop = EventLoop.new()
    local beforeError = false
    local afterError = false
    
    loop:bind(function() beforeError = true end)
    loop:bind(function() error('Test error') end)
    loop:bind(function() afterError = true end)
    
    -- Error should occur during poll
    local status = pcall(function()
        loop:poll()
    end)
    lu.assertFalse(status)
    
    -- First binding executed
    lu.assertTrue(beforeError)
    -- Third binding should not execute (error stops iteration)
    lu.assertFalse(afterError)
    
    collectgarbage()
end

os.exit(lu.LuaUnit.run())
