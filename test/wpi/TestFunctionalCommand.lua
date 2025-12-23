---Test for FunctionalCommand
local lu = require('luaunit')
local class = require('luabot.class')
local Subsystem = require('wpi.cmd.Subsystem')
local FunctionalCommand = require('wpi.cmd.FunctionalCommand')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestFunctionalCommand = {}

function TestFunctionalCommand:setUp()
    CommandScheduler.resetInstance()
end

function TestFunctionalCommand:testConstructorWithAllFunctions()
    local initCalled = false
    local executeCalled = false
    local endCalled = false
    local endInterrupted = nil
    local finishCount = 0
    
    local cmd = FunctionalCommand.new(
        function() initCalled = true end,
        function() executeCalled = true end,
        function(interrupted) 
            endCalled = true 
            endInterrupted = interrupted
        end,
        function() 
            finishCount = finishCount + 1
            return finishCount >= 2
        end
    )
    
    lu.assertNotNil(cmd)
    lu.assertFalse(initCalled)
    
    cmd:initialize()
    lu.assertTrue(initCalled)
    
    lu.assertFalse(cmd:isFinished())  -- finishCount = 1
    cmd:execute()
    lu.assertTrue(executeCalled)
    lu.assertTrue(cmd:isFinished())  -- finishCount = 2
    
    cmd:done(false)
    lu.assertTrue(endCalled)
    lu.assertFalse(endInterrupted)
end

function TestFunctionalCommand:testConstructorWithNilFunctions()
    local cmd = FunctionalCommand.new(nil, nil, nil, nil)
    
    lu.assertNotNil(cmd)
    
    -- Should not crash when calling lifecycle methods
    cmd:initialize()
    cmd:execute()
    cmd:done(false)
    lu.assertFalse(cmd:isFinished())
end

function TestFunctionalCommand:testWithRequirements()
    local subsystem1 = Subsystem.new()
    local subsystem2 = Subsystem.new()
    
    local cmd = FunctionalCommand.new(
        function() end,
        function() end,
        function(interrupted) end,
        function() return false end,
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

function TestFunctionalCommand:testSchedulerIntegration()
    local scheduler = CommandScheduler.getInstance()
    
    local initCalled = false
    local executeCount = 0
    local endCalled = false
    
    local cmd = FunctionalCommand.new(
        function() initCalled = true end,
        function() executeCount = executeCount + 1 end,
        function(interrupted) endCalled = true end,
        function() return executeCount >= 3 end
    )
    
    scheduler:schedule(cmd)
    lu.assertTrue(initCalled)
    lu.assertTrue(scheduler:isScheduled(cmd))
    
    scheduler:run()  -- execute #1
    lu.assertEquals(executeCount, 1)
    lu.assertTrue(scheduler:isScheduled(cmd))
    
    scheduler:run()  -- execute #2
    lu.assertEquals(executeCount, 2)
    lu.assertTrue(scheduler:isScheduled(cmd))
    
    scheduler:run()  -- execute #3, then finish
    lu.assertEquals(executeCount, 3)
    lu.assertTrue(endCalled)
    lu.assertFalse(scheduler:isScheduled(cmd))
end

function TestFunctionalCommand:testInterruption()
    local scheduler = CommandScheduler.getInstance()
    
    local endInterrupted = nil
    
    local cmd = FunctionalCommand.new(
        function() end,
        function() end,
        function(interrupted) endInterrupted = interrupted end,
        function() return false end  -- Never finishes on its own
    )
    
    scheduler:schedule(cmd)
    scheduler:run()
    
    lu.assertNil(endInterrupted)
    
    scheduler:cancel(cmd)
    lu.assertTrue(endInterrupted)
end

function TestFunctionalCommand:testOnlyInitAndIsFinished()
    local initCalled = false
    
    local cmd = FunctionalCommand.new(
        function() initCalled = true end,
        nil,
        nil,
        function() return true end  -- Finishes immediately
    )
    
    cmd:initialize()
    lu.assertTrue(initCalled)
    lu.assertTrue(cmd:isFinished())
    
    cmd:execute()  -- Should not crash
    cmd:done(false)  -- Should not crash
end

function TestFunctionalCommand:testExecuteCounter()
    local count = 0
    
    local cmd = FunctionalCommand.new(
        nil,
        function() count = count + 1 end,
        nil,
        function() return count >= 5 end
    )
    
    lu.assertEquals(count, 0)
    lu.assertFalse(cmd:isFinished())
    
    for i = 1, 4 do
        cmd:execute()
        lu.assertEquals(count, i)
        lu.assertFalse(cmd:isFinished())
    end
    
    cmd:execute()
    lu.assertEquals(count, 5)
    lu.assertTrue(cmd:isFinished())
end

function TestFunctionalCommand:testWithCallableObjects()
    -- Test with callable tables (objects with __call metamethod)
    local initCallable = setmetatable({called = false}, {
        __call = function(self) self.called = true end
    })
    
    local executeCallable = setmetatable({count = 0}, {
        __call = function(self) self.count = self.count + 1 end
    })
    
    local endCallable = setmetatable({interrupted = nil}, {
        __call = function(self, interrupted) self.interrupted = interrupted end
    })
    
    local finishCallable = setmetatable({threshold = 3}, {
        __call = function(self) return executeCallable.count >= self.threshold end
    })
    
    local cmd = FunctionalCommand.new(
        initCallable,
        executeCallable,
        endCallable,
        finishCallable
    )
    
    cmd:initialize()
    lu.assertTrue(initCallable.called)
    
    lu.assertFalse(cmd:isFinished())
    cmd:execute()
    lu.assertEquals(executeCallable.count, 1)
    
    cmd:execute()
    cmd:execute()
    lu.assertEquals(executeCallable.count, 3)
    lu.assertTrue(cmd:isFinished())
    
    cmd:done(true)
    lu.assertTrue(endCallable.interrupted)
end

os.exit(lu.LuaUnit.run())
