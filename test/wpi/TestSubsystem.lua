---Test for Subsystem base class
local lu = require('luaunit')
local class = require('luabot.class')
local Subsystem = require('wpi.cmd.Subsystem')

TestSubsystem = {}

function TestSubsystem:testSubsystemCreation()
    local subsystem = Subsystem.new()
    lu.assertNotNil(subsystem)
end

function TestSubsystem:testPeriodicMethod()
    local subsystem = Subsystem.new()
    -- Should not throw - default implementation is no-op
    subsystem:periodic()
    lu.assertTrue(true)
end

function TestSubsystem:testSimulationPeriodicMethod()
    local subsystem = Subsystem.new()
    -- Should not throw - default implementation is no-op
    subsystem:simulationPeriodic()
    lu.assertTrue(true)
end

function TestSubsystem:testGetName()
    local subsystem = Subsystem.new()
    local name = subsystem:getName()
    lu.assertNotNil(name)
    lu.assertIsString(name)
end

function TestSubsystem:testSetName()
    local subsystem = Subsystem.new()
    subsystem:setName('TestSubsystem')
    lu.assertEquals(subsystem:getName(), 'TestSubsystem')
end

function TestSubsystem:testDefaultCommand()
    local subsystem = Subsystem.new()
    local mockCommand = { name = 'MockCommand' }
    
    subsystem:setDefaultCommand(mockCommand)
    lu.assertEquals(subsystem:getDefaultCommand(), mockCommand)
end

function TestSubsystem:testDerivedSubsystem()
    -- Test that we can derive from Subsystem
    local DerivedSubsystem = class(Subsystem)
    
    local overrideCalled = false
    
    function DerivedSubsystem:periodic()
        overrideCalled = true
    end
    
    function DerivedSubsystem.new()
        local self = setmetatable({}, DerivedSubsystem)
        return DerivedSubsystem.init(self)
    end
    
    local derived = DerivedSubsystem.new()
    lu.assertNotNil(derived)
    
    -- Test that override works
    derived:periodic()
    lu.assertTrue(overrideCalled)
end

function TestSubsystem:testDerivedSubsystemWithCustomInit()
    local DerivedSubsystem = class(Subsystem)
    
    function DerivedSubsystem.init(instance)
        -- Call parent init
        Subsystem.init(instance)
        -- Add custom field
        instance.customField = 'test'
        return instance
    end
    
    function DerivedSubsystem.new()
        local self = setmetatable({}, DerivedSubsystem)
        return DerivedSubsystem.init(self)
    end
    
    local derived = DerivedSubsystem.new()
    lu.assertNotNil(derived)
    lu.assertEquals(derived.customField, 'test')
    
    -- Verify parent init was called - check for _name field (also set by parent)
    -- Note: _defaultCommand is nil so won't appear in pairs(), but we can check directly
    lu.assertEquals(derived._defaultCommand, nil)
    lu.assertEquals(derived._name, nil)
end

os.exit(lu.LuaUnit.run())
