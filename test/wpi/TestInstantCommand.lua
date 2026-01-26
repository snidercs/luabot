---Test for InstantCommand
---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local class = require('luabot.class')
local Subsystem = require('wpi.cmd.Subsystem')
local InstantCommand = require('wpi.cmd.InstantCommand')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestInstantCommand = {}

function TestInstantCommand:setUp()
    CommandScheduler.resetInstance()
end

function TestInstantCommand:testBasicInstantCommand()
    local executed = false
    
    local cmd = InstantCommand.new(function()
        executed = true
    end)
    
    lu.assertNotNil(cmd)
    lu.assertFalse(executed)
    
    -- Should finish immediately
    lu.assertTrue(cmd:isFinished())
end

function TestInstantCommand:testInitializeRunsFunction()
    local initCount = 0
    
    local cmd = InstantCommand.new(function()
        initCount = initCount + 1
    end)
    
    lu.assertEquals(initCount, 0)
    
    cmd:initialize()
    lu.assertEquals(initCount, 1)
    
    -- Initialize again shouldn't happen in normal usage, but if it does...
    cmd:initialize()
    lu.assertEquals(initCount, 2)
end

function TestInstantCommand:testExecuteDoesNothing()
    local executeCount = 0
    
    local cmd = InstantCommand.new(function()
        executeCount = executeCount + 1
    end)
    
    cmd:initialize()
    lu.assertEquals(executeCount, 1)
    
    -- Execute should do nothing (count stays at 1)
    cmd:execute()
    lu.assertEquals(executeCount, 1)
    
    cmd:execute()
    lu.assertEquals(executeCount, 1)
end

function TestInstantCommand:testWithRequirements()
    local subsystem1 = Subsystem.new()
    local subsystem2 = Subsystem.new()
    
    local cmd = InstantCommand.new(
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

function TestInstantCommand:testSchedulerIntegration()
    local scheduler = CommandScheduler.getInstance()
    
    local executed = false
    
    local cmd = InstantCommand.new(function()
        executed = true
    end)
    
    scheduler:schedule(cmd)
    lu.assertTrue(executed)  -- Should execute on schedule (in initialize)
    lu.assertTrue(scheduler:isScheduled(cmd))
    
    -- One run() should finish it
    scheduler:run()
    lu.assertFalse(scheduler:isScheduled(cmd))
end

function TestInstantCommand:testNoArgumentConstructor()
    -- Should be able to create with no function (for subclassing)
    local cmd = InstantCommand.new()
    
    lu.assertNotNil(cmd)
    lu.assertTrue(cmd:isFinished())
    
    -- Should not crash
    cmd:initialize()
    cmd:execute()
    cmd:done(false)
end

function TestInstantCommand:testSubclassing()
    local MyInstantCommand = class(InstantCommand)
    local executed = false
    
    function MyInstantCommand.init(instance)
        InstantCommand.init(instance, function()
            executed = true
        end)
        return instance
    end
    
    function MyInstantCommand.new()
        local self = setmetatable({}, MyInstantCommand)
        return MyInstantCommand.init(self)
    end
    
    local cmd = MyInstantCommand.new()
    lu.assertFalse(executed)
    
    cmd:initialize()
    lu.assertTrue(executed)
    lu.assertTrue(cmd:isFinished())
end

function TestInstantCommand:testMultipleInstantCommands()
    local scheduler = CommandScheduler.getInstance()
    
    local count1 = 0
    local count2 = 0
    local count3 = 0
    
    local cmd1 = InstantCommand.new(function() count1 = count1 + 1 end)
    local cmd2 = InstantCommand.new(function() count2 = count2 + 1 end)
    local cmd3 = InstantCommand.new(function() count3 = count3 + 1 end)
    
    scheduler:schedule(cmd1, cmd2, cmd3)
    lu.assertEquals(count1, 1)
    lu.assertEquals(count2, 1)
    lu.assertEquals(count3, 1)
    
    scheduler:run()
    lu.assertFalse(scheduler:isScheduled(cmd1))
    lu.assertFalse(scheduler:isScheduled(cmd2))
    lu.assertFalse(scheduler:isScheduled(cmd3))
end

function TestInstantCommand:testWithCallableObject()
    local callable = setmetatable({called = false}, {
        __call = function(self) self.called = true end
    })
    
    local cmd = InstantCommand.new(callable)
    
    cmd:initialize()
    lu.assertTrue(callable.called)
    lu.assertTrue(cmd:isFinished())
end

os.exit(lu.LuaUnit.run())
