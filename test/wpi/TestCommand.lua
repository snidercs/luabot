---Test for Command base class
local lu = require('luaunit')
local class = require('luabot.class')
local Command = require('wpi.cmd.Command')
local Subsystem = require('wpi.cmd.Subsystem')

TestCommand = {}

function TestCommand:testCommandCreation()
    local command = Command.new()
    lu.assertNotNil(command)
end

function TestCommand:testInitializeMethod()
    local command = Command.new()
    -- Should not throw - default implementation is no-op
    command:initialize()
    lu.assertTrue(true)
end

function TestCommand:testExecuteMethod()
    local command = Command.new()
    -- Should not throw - default implementation is no-op
    command:execute()
    lu.assertTrue(true)
end

function TestCommand:testEndMethod()
    local command = Command.new()
    -- Should not throw - default implementation is no-op
    command:done(false)
    command:done(true)
    lu.assertTrue(true)
end

function TestCommand:testIsFinished()
    local command = Command.new()
    -- Default should be false (never finishes)
    lu.assertFalse(command:isFinished())
end

function TestCommand:testGetName()
    local command = Command.new()
    local name = command:getName()
    lu.assertNotNil(name)
    lu.assertIsString(name)
end

function TestCommand:testSetName()
    local command = Command.new()
    command:setName('TestCommand')
    lu.assertEquals(command:getName(), 'TestCommand')
end

function TestCommand:testAddRequirements()
    local command = Command.new()
    local subsystem1 = Subsystem.new()
    local subsystem2 = Subsystem.new()
    
    command:addRequirements(subsystem1, subsystem2)
    
    local reqs = command:getRequirements()
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

function TestCommand:testGetRequirementsEmpty()
    local command = Command.new()
    local reqs = command:getRequirements()
    lu.assertEquals(#reqs, 0)
end

function TestCommand:testInterruptionBehavior()
    local command = Command.new()
    local behavior = command:getInterruptionBehavior()
    lu.assertEquals(behavior, 0)  -- kCancelSelf
end

function TestCommand:testDerivedCommand()
    -- Test that we can derive from Command
    local DerivedCommand = class(Command)
    
    local initializeCalled = false
    local executeCalled = false
    local endCalled = false
    local endInterrupted = nil
    
    function DerivedCommand:initialize()
        initializeCalled = true
    end
    
    function DerivedCommand:execute()
        executeCalled = true
    end
    
    function DerivedCommand:done(interrupted)
        endCalled = true
        endInterrupted = interrupted
    end
    
    function DerivedCommand:isFinished()
        return executeCalled  -- Finish after first execute
    end
    
    function DerivedCommand.new()
        local self = setmetatable({}, DerivedCommand)
        return DerivedCommand.init(self)
    end
    
    local derived = DerivedCommand.new()
    lu.assertNotNil(derived)
    
    -- Test lifecycle
    derived:initialize()
    lu.assertTrue(initializeCalled)
    
    derived:execute()
    lu.assertTrue(executeCalled)
    lu.assertTrue(derived:isFinished())
    
    derived:done(false)
    lu.assertTrue(endCalled)
    lu.assertFalse(endInterrupted)
end

function TestCommand:testDerivedCommandWithCustomInit()
    local DerivedCommand = class(Command)
    
    function DerivedCommand.init(instance)
        -- Call parent init
        Command.init(instance)
        -- Add custom field
        instance.customField = 'test'
        return instance
    end
    
    function DerivedCommand.new()
        local self = setmetatable({}, DerivedCommand)
        return DerivedCommand.init(self)
    end
    
    local derived = DerivedCommand.new()
    lu.assertNotNil(derived)
    lu.assertEquals(derived.customField, 'test')
    
    -- Verify parent init was called
    lu.assertNotNil(derived._requirements)
    lu.assertEquals(type(derived._requirements), 'table')
end

function TestCommand:testCommandWithRequirementsInInit()
    -- Test a command that adds requirements in init
    local subsystem = Subsystem.new()
    
    local MyCommand = class(Command)
    
    function MyCommand.init(instance, requiredSubsystem)
        Command.init(instance)
        instance:addRequirements(requiredSubsystem)
        return instance
    end
    
    function MyCommand.new(requiredSubsystem)
        local self = setmetatable({}, MyCommand)
        return MyCommand.init(self, requiredSubsystem)
    end
    
    local cmd = MyCommand.new(subsystem)
    local reqs = cmd:getRequirements()
    lu.assertEquals(#reqs, 1)
    lu.assertEquals(reqs[1], subsystem)
end

os.exit(lu.LuaUnit.run())
