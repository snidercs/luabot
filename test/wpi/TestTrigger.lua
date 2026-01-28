---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local EventLoop = require('wpi.event.EventLoop')
local Trigger = require('wpi.cmd.button.Trigger')

TestTrigger = {}

-- Helper function to create a mock command
local function mockCommand()
    local cmd = {
        _scheduled = false,
        _canceled = false
    }
    
    function cmd:isScheduled()
        return self._scheduled
    end
    
    function cmd:cancel()
        self._canceled = true
        self._scheduled = false
    end
    
    return cmd
end

-- Helper function to create a mock scheduler
local function setupMockScheduler()
    local scheduled = {}
    
    package.loaded['wpi.cmd.CommandScheduler'] = {
        getInstance = function()
            return {
                schedule = function(self, cmd)
                    cmd._scheduled = true
                    scheduled[cmd] = true
                end,
                cancel = function(self, cmd)
                    cmd._scheduled = false
                    cmd._canceled = true
                    scheduled[cmd] = nil
                end,
                isScheduled = function(self, cmd)
                    return scheduled[cmd] == true
                end,
                getDefaultButtonLoop = function(self)
                    return EventLoop.new()
                end
            }
        end
    }
    
    return scheduled
end

function TestTrigger:testConstructorWithLoop()
    local loop = EventLoop.new()
    local condition = function() return true end
    local trigger = Trigger.new(loop, condition)
    
    lu.assertNotNil(trigger)
    lu.assertTrue(trigger:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testConstructorWithConditionOnly()
    setupMockScheduler()
    
    local condition = function() return false end
    local trigger = Trigger.new(condition)
    
    lu.assertNotNil(trigger)
    lu.assertFalse(trigger:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testConstructorRequiresCondition()
    local loop = EventLoop.new()
    
    lu.assertErrorMsgContains('condition', function()
        Trigger.new(loop, nil)
    end)
    
    collectgarbage()
end

function TestTrigger:testGetAsBoolean()
    local loop = EventLoop.new()
    local value = false
    local trigger = Trigger.new(loop, function() return value end)
    
    lu.assertFalse(trigger:getAsBoolean())
    
    value = true
    lu.assertTrue(trigger:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testOnTrue()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = false
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:onTrue(cmd)
    
    -- Initial poll - condition false
    loop:poll()
    lu.assertFalse(cmd._scheduled)
    
    -- Set condition true and poll - should schedule
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    
    -- Stays true - shouldn't schedule again
    cmd._scheduled = false
    loop:poll()
    lu.assertFalse(cmd._scheduled)
    
    collectgarbage()
end

function TestTrigger:testOnFalse()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = true
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:onFalse(cmd)
    
    -- Initial poll - condition true
    loop:poll()
    lu.assertFalse(cmd._scheduled)
    
    -- Set condition false and poll - should schedule
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    
    collectgarbage()
end

function TestTrigger:testOnChange()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = false
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:onChange(cmd)
    
    -- Initial poll - no change yet
    loop:poll()
    lu.assertFalse(cmd._scheduled)
    
    -- Change to true - should schedule
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    
    -- Reset and change back to false - should schedule again
    cmd._scheduled = false
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    
    collectgarbage()
end

function TestTrigger:testWhileTrue()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = false
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:whileTrue(cmd)
    
    -- Rising edge: should schedule
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    lu.assertFalse(cmd._canceled)
    
    -- Falling edge: should cancel
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._canceled)
    
    collectgarbage()
end

function TestTrigger:testWhileFalse()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = true
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:whileFalse(cmd)
    
    -- Falling edge: should schedule
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    lu.assertFalse(cmd._canceled)
    
    -- Rising edge: should cancel
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._canceled)
    
    collectgarbage()
end

function TestTrigger:testToggleOnTrue()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = false
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:toggleOnTrue(cmd)
    
    -- First true: schedule
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    
    -- False: no change
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    lu.assertFalse(cmd._canceled)
    
    -- True again: cancel (toggle)
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._canceled)
    
    collectgarbage()
end

function TestTrigger:testToggleOnFalse()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local conditionValue = true
    local trigger = Trigger.new(loop, function() return conditionValue end)
    local cmd = mockCommand()
    
    trigger:toggleOnFalse(cmd)
    
    -- First false: schedule
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    
    -- True: no change
    conditionValue = true
    loop:poll()
    lu.assertTrue(cmd._scheduled)
    lu.assertFalse(cmd._canceled)
    
    -- False again: cancel (toggle)
    conditionValue = false
    loop:poll()
    lu.assertTrue(cmd._canceled)
    
    collectgarbage()
end

function TestTrigger:testAndComposition()
    local loop = EventLoop.new()
    local cond1 = false
    local cond2 = false
    
    local trigger1 = Trigger.new(loop, function() return cond1 end)
    local trigger2 = Trigger.new(loop, function() return cond2 end)
    
    local combined = trigger1:and_(trigger2)
    
    lu.assertFalse(combined:getAsBoolean())
    
    cond1 = true
    lu.assertFalse(combined:getAsBoolean())
    
    cond2 = true
    lu.assertTrue(combined:getAsBoolean())
    
    cond1 = false
    lu.assertFalse(combined:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testOrComposition()
    local loop = EventLoop.new()
    local cond1 = false
    local cond2 = false
    
    local trigger1 = Trigger.new(loop, function() return cond1 end)
    local trigger2 = Trigger.new(loop, function() return cond2 end)
    
    local combined = trigger1:or_(trigger2)
    
    lu.assertFalse(combined:getAsBoolean())
    
    cond1 = true
    lu.assertTrue(combined:getAsBoolean())
    
    cond1 = false
    cond2 = true
    lu.assertTrue(combined:getAsBoolean())
    
    cond1 = false
    cond2 = false
    lu.assertFalse(combined:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testNegate()
    local loop = EventLoop.new()
    local cond = false
    
    local trigger = Trigger.new(loop, function() return cond end)
    local negated = trigger:negate()
    
    lu.assertTrue(negated:getAsBoolean())
    
    cond = true
    lu.assertFalse(negated:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testMethodChaining()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local cond = false
    local trigger = Trigger.new(loop, function() return cond end)
    local cmd1 = mockCommand()
    local cmd2 = mockCommand()
    
    -- Should be able to chain
    local result = trigger:onTrue(cmd1):onFalse(cmd2)
    lu.assertEquals(result, trigger)
    
    collectgarbage()
end

function TestTrigger:testMultipleBindingsSameTrigger()
    local loop = EventLoop.new()
    setupMockScheduler()
    
    local cond = false
    local trigger = Trigger.new(loop, function() return cond end)
    local cmd1 = mockCommand()
    local cmd2 = mockCommand()
    
    trigger:onTrue(cmd1)
    trigger:onTrue(cmd2)
    
    -- Both should be scheduled on rising edge
    cond = true
    loop:poll()
    
    lu.assertTrue(cmd1._scheduled)
    lu.assertTrue(cmd2._scheduled)
    
    collectgarbage()
end

function TestTrigger:testComplexComposition()
    local loop = EventLoop.new()
    local a = false
    local b = false
    local c = false
    
    local triggerA = Trigger.new(loop, function() return a end)
    local triggerB = Trigger.new(loop, function() return b end)
    local triggerC = Trigger.new(loop, function() return c end)
    
    -- (A AND B) OR (NOT C)
    local complex = triggerA:and_(triggerB):or_(triggerC:negate())
    
    -- NOT C is true, so result should be true
    lu.assertTrue(complex:getAsBoolean())
    
    -- Set C to true, now NOT C is false
    c = true
    lu.assertFalse(complex:getAsBoolean())
    
    -- Set A and B to true, (A AND B) is true
    a = true
    b = true
    lu.assertTrue(complex:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testAndWithFunction()
    local loop = EventLoop.new()
    local cond1 = false
    local cond2 = false
    
    local trigger = Trigger.new(loop, function() return cond1 end)
    local combined = trigger:and_(function() return cond2 end)
    
    lu.assertFalse(combined:getAsBoolean())
    
    cond1 = true
    cond2 = true
    lu.assertTrue(combined:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testOrWithFunction()
    local loop = EventLoop.new()
    local cond1 = false
    local cond2 = false
    
    local trigger = Trigger.new(loop, function() return cond1 end)
    local combined = trigger:or_(function() return cond2 end)
    
    lu.assertFalse(combined:getAsBoolean())
    
    cond2 = true
    lu.assertTrue(combined:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testBindingErrorValidation()
    local loop = EventLoop.new()
    local trigger = Trigger.new(loop, function() return true end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:onTrue(nil)
    end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:onFalse(nil)
    end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:whileTrue(nil)
    end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:whileFalse(nil)
    end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:toggleOnTrue(nil)
    end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:toggleOnFalse(nil)
    end)
    
    lu.assertErrorMsgContains('command', function()
        trigger:onChange(nil)
    end)
    
    collectgarbage()
end

function TestTrigger:testDebounceRising()
    -- Mock timer
    local mockTime = 0.0
    package.loaded['wpi.frc.Timer'] = {
        getFPGATimestamp = function() return mockTime end
    }
    
    -- Force reload to use mocked timer
    package.loaded['wpi.math.filter.Debouncer'] = nil
    
    local loop = EventLoop.new()
    local cond = false
    local trigger = Trigger.new(loop, function() return cond end)
    
    -- Create debounced trigger with 0.5 second debounce
    local Debouncer = require('wpi.math.filter.Debouncer')
    
    mockTime = 0.0
    local debounced = trigger:debounce(0.5, Debouncer.DebounceType.kRising)
    
    -- Initial: false
    mockTime = 0.0
    lu.assertFalse(debounced:getAsBoolean())
    
    -- Condition goes true but not long enough
    cond = true
    mockTime = 0.0
    lu.assertFalse(debounced:getAsBoolean())
    
    mockTime = 0.3
    lu.assertFalse(debounced:getAsBoolean())
    
    -- After 0.5 seconds, should be true
    mockTime = 0.5
    lu.assertTrue(debounced:getAsBoolean())
    
    collectgarbage()
end

function TestTrigger:testDebounceDefault()
    -- Mock timer
    local mockTime = 0.0
    package.loaded['wpi.frc.Timer'] = {
        getFPGATimestamp = function() return mockTime end
    }
    
    -- Force reload to use mocked timer
    package.loaded['wpi.math.filter.Debouncer'] = nil
    
    local loop = EventLoop.new()
    local cond = false
    local trigger = Trigger.new(loop, function() return cond end)
    
    -- Default debounce type should be kRising
    mockTime = 0.0
    local debounced = trigger:debounce(0.5)
    
    mockTime = 0.0
    lu.assertFalse(debounced:getAsBoolean())
    
    cond = true
    mockTime = 0.0
    lu.assertFalse(debounced:getAsBoolean())
    
    mockTime = 0.5
    lu.assertTrue(debounced:getAsBoolean())
    
    collectgarbage()
end

os.exit(lu.LuaUnit.run())
