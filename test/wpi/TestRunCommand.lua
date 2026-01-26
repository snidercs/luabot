---Test for RunCommand
---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local class = require('luabot.class')
local Subsystem = require('wpi.cmd.Subsystem')
local RunCommand = require('wpi.cmd.RunCommand')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestRunCommand = {}

function TestRunCommand:setUp()
    CommandScheduler.resetInstance()
end

function TestRunCommand:testBasicRunCommand()
    local executeCount = 0
    
    local cmd = RunCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    lu.assertNotNil(cmd)
    lu.assertEquals(executeCount, 0)
    
    -- Should never finish on its own
    lu.assertFalse(cmd:isFinished())
end

function TestRunCommand:testInitializeDoesNothing()
    local executeCount = 0
    
    local cmd = RunCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    -- Initialize should not run the function
    cmd:initialize()
    lu.assertEquals(executeCount, 0)
end

function TestRunCommand:testExecuteRunsContinuously()
    local executeCount = 0
    
    local cmd = RunCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    cmd:initialize()
    lu.assertEquals(executeCount, 0)
    
    cmd:execute()
    lu.assertEquals(executeCount, 1)
    
    cmd:execute()
    lu.assertEquals(executeCount, 2)
    
    cmd:execute()
    lu.assertEquals(executeCount, 3)
    
    -- Should never finish on its own
    lu.assertFalse(cmd:isFinished())
end

function TestRunCommand:testWithRequirements()
    local subsystem1 = Subsystem.new()
    local subsystem2 = Subsystem.new()
    
    local cmd = RunCommand.new(
        function() end,
        subsystem1,
        subsystem2
    )
    
    local reqs = cmd:getRequirements()
    lu.assertEquals(#reqs, 2)
    
    -- Check that both subsystems are in requirements
    local hasSubsystem1 = false
    local hasSubsystem2 = false
    for _, subsystem in ipairs(reqs) do
        if subsystem == subsystem1 then hasSubsystem1 = true end
        if subsystem == subsystem2 then hasSubsystem2 = true end
    end
    lu.assertTrue(hasSubsystem1)
    lu.assertTrue(hasSubsystem2)
end

function TestRunCommand:testSchedulerIntegration()
    local scheduler = CommandScheduler.getInstance()
    
    local executeCount = 0
    
    local cmd = RunCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    scheduler:schedule(cmd)
    lu.assertEquals(executeCount, 0)  -- Initialize doesn't run it
    lu.assertTrue(scheduler:isScheduled(cmd))
    
    -- Each run() should execute once
    scheduler:run()
    lu.assertEquals(executeCount, 1)
    lu.assertTrue(scheduler:isScheduled(cmd))  -- Still running
    
    scheduler:run()
    lu.assertEquals(executeCount, 2)
    lu.assertTrue(scheduler:isScheduled(cmd))  -- Still running
    
    scheduler:run()
    lu.assertEquals(executeCount, 3)
    lu.assertTrue(scheduler:isScheduled(cmd))  -- Still running
end

function TestRunCommand:testMustBeCanceled()
    local scheduler = CommandScheduler.getInstance()
    
    local executeCount = 0
    
    local cmd = RunCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    scheduler:schedule(cmd)
    
    -- Run many times
    for i = 1, 10 do
        scheduler:run()
    end
    
    lu.assertEquals(executeCount, 10)
    lu.assertTrue(scheduler:isScheduled(cmd))  -- Still running!
    
    -- Must explicitly cancel
    scheduler:cancel(cmd)
    lu.assertFalse(scheduler:isScheduled(cmd))
end

function TestRunCommand:testNoArgumentConstructor()
    -- Should be able to create with no function (for subclassing)
    local cmd = RunCommand.new()
    
    lu.assertNotNil(cmd)
    lu.assertFalse(cmd:isFinished())
    
    -- Should not crash
    cmd:initialize()
    cmd:execute()
    cmd:done(false)
end

function TestRunCommand:testSubclassing()
    local MyRunCommand = class(RunCommand)
    local executeCount = 0
    
    function MyRunCommand.init(instance)
        RunCommand.init(instance, function()
            executeCount = executeCount + 1
        end)
        return instance
    end
    
    function MyRunCommand.new()
        local self = setmetatable({}, MyRunCommand)
        return MyRunCommand.init(self)
    end
    
    local cmd = MyRunCommand.new()
    lu.assertEquals(executeCount, 0)
    
    cmd:execute()
    lu.assertEquals(executeCount, 1)
    
    cmd:execute()
    lu.assertEquals(executeCount, 2)
    
    lu.assertFalse(cmd:isFinished())
end

function TestRunCommand:testWithCallableObject()
    local callable = setmetatable({count = 0}, {
        __call = function(self) self.count = self.count + 1 end
    })
    
    local cmd = RunCommand.new(callable)
    
    cmd:execute()
    lu.assertEquals(callable.count, 1)
    
    cmd:execute()
    lu.assertEquals(callable.count, 2)
    
    lu.assertFalse(cmd:isFinished())
end

function TestRunCommand:testInterruption()
    local scheduler = CommandScheduler.getInstance()
    
    local executeCount = 0
    local endCalled = false
    
    local cmd = RunCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    -- Override done to track if it's called
    local originalDone = cmd.done
    cmd.done = function(self, interrupted)
        endCalled = true
        originalDone(self, interrupted)
    end
    
    scheduler:schedule(cmd)
    scheduler:run()
    scheduler:run()
    
    lu.assertEquals(executeCount, 2)
    lu.assertFalse(endCalled)
    
    scheduler:cancel(cmd)
    lu.assertTrue(endCalled)
end

os.exit(lu.LuaUnit.run())
