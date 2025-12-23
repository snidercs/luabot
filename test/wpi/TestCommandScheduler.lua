---Test for CommandScheduler
local lu = require('luaunit')
local class = require('luabot.class')
local Command = require('wpi.cmd.Command')
local Subsystem = require('wpi.cmd.Subsystem')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestCommandScheduler = {}

function TestCommandScheduler:setUp()
    -- Reset singleton before each test
    CommandScheduler.resetInstance()
end

function TestCommandScheduler:testSingletonPattern()
    local scheduler1 = CommandScheduler.getInstance()
    local scheduler2 = CommandScheduler.getInstance()
    lu.assertEquals(scheduler1, scheduler2)
end

function TestCommandScheduler:testRegisterSubsystem()
    local scheduler = CommandScheduler.getInstance()
    local subsystem = Subsystem.new()

    scheduler:registerSubsystem(subsystem)
    -- Should not throw
    lu.assertTrue(true)
end

function TestCommandScheduler:testScheduleCommand()
    local scheduler = CommandScheduler.getInstance()
    local command = Command.new()

    scheduler:schedule(command)
    lu.assertTrue(scheduler:isScheduled(command))
end

function TestCommandScheduler:testCancelCommand()
    local scheduler = CommandScheduler.getInstance()
    local command = Command.new()

    scheduler:schedule(command)
    lu.assertTrue(scheduler:isScheduled(command))

    scheduler:cancel(command)
    lu.assertFalse(scheduler:isScheduled(command))
end

function TestCommandScheduler:testCancelAll()
    local scheduler = CommandScheduler.getInstance()
    local command1 = Command.new()
    local command2 = Command.new()

    scheduler:schedule(command1, command2)
    lu.assertTrue(scheduler:isScheduled(command1))
    lu.assertTrue(scheduler:isScheduled(command2))

    scheduler:cancelAll()
    lu.assertFalse(scheduler:isScheduled(command1))
    lu.assertFalse(scheduler:isScheduled(command2))
end

function TestCommandScheduler:testCommandLifecycle()
    local scheduler = CommandScheduler.getInstance()

    local MyCommand = class(Command)
    local initCalled = false
    local executeCalled = false
    local doneCalled = false
    local wasInterrupted = nil

    function MyCommand:initialize()
        initCalled = true
    end

    function MyCommand:execute()
        executeCalled = true
    end

    function MyCommand:done(interrupted)
        doneCalled = true
        wasInterrupted = interrupted
    end

    function MyCommand:isFinished()
        return executeCalled -- Finish after first execute
    end

    function MyCommand.new()
        local self = setmetatable({}, MyCommand)
        return MyCommand.init(self)
    end

    local command = MyCommand.new()

    scheduler:schedule(command)
    lu.assertTrue(initCalled)
    lu.assertTrue(scheduler:isScheduled(command))

    scheduler:run()
    lu.assertTrue(executeCalled)
    lu.assertTrue(doneCalled)
    lu.assertFalse(wasInterrupted)
    lu.assertFalse(scheduler:isScheduled(command))
end

function TestCommandScheduler:testSubsystemRequirements()
    local scheduler = CommandScheduler.getInstance()
    local subsystem = Subsystem.new()

    local MyCommand = class(Command)

    function MyCommand.init(instance)
        Command.init(instance)
        instance:addRequirements(subsystem)
        return instance
    end

    function MyCommand.new()
        local self = setmetatable({}, MyCommand)
        return MyCommand.init(self)
    end

    local command = MyCommand.new()
    scheduler:schedule(command)

    lu.assertEquals(scheduler:requiring(subsystem), command)
end

function TestCommandScheduler:testConflictingRequirements()
    local scheduler = CommandScheduler.getInstance()
    local subsystem = Subsystem.new()

    local MyCommand = class(Command)
    local command1DoneCalled = false
    local command1Interrupted = nil

    function MyCommand.init(instance)
        Command.init(instance)
        instance:addRequirements(subsystem)
        instance.isCommand1 = false
        return instance
    end

    function MyCommand:done(interrupted)
        if self.isCommand1 then
            command1DoneCalled = true
            command1Interrupted = interrupted
        end
    end

    function MyCommand.new()
        local self = setmetatable({}, MyCommand)
        return MyCommand.init(self)
    end

    local command1 = MyCommand.new()
    command1.isCommand1 = true
    local command2 = MyCommand.new()

    scheduler:schedule(command1)
    lu.assertTrue(scheduler:isScheduled(command1))

    -- Scheduling command2 should cancel command1 (default behavior)
    scheduler:schedule(command2)
    lu.assertFalse(scheduler:isScheduled(command1))
    lu.assertTrue(scheduler:isScheduled(command2))
    lu.assertTrue(command1DoneCalled)
    lu.assertTrue(command1Interrupted)
end

function TestCommandScheduler:testDefaultCommand()
    local scheduler = CommandScheduler.getInstance()
    local subsystem = Subsystem.new()

    local defaultCommand = Command.new()
    scheduler:setDefaultCommand(subsystem, defaultCommand)

    scheduler:run()

    -- Default command should be scheduled when subsystem is not in use
    lu.assertTrue(scheduler:isScheduled(defaultCommand))
end

function TestCommandScheduler:testDefaultCommandNotScheduledWhenInUse()
    local scheduler = CommandScheduler.getInstance()
    local subsystem = Subsystem.new()

    local MyCommand = class(Command)

    function MyCommand.init(instance)
        Command.init(instance)
        instance:addRequirements(subsystem)
        return instance
    end

    function MyCommand.new()
        local self = setmetatable({}, MyCommand)
        return MyCommand.init(self)
    end

    local defaultCommand = MyCommand.new()
    local activeCommand = MyCommand.new()

    scheduler:setDefaultCommand(subsystem, defaultCommand)
    scheduler:schedule(activeCommand)

    scheduler:run()

    -- Default should not be scheduled while active command is using subsystem
    lu.assertTrue(scheduler:isScheduled(activeCommand))
    -- Note: defaultCommand won't be scheduled separately because activeCommand has the subsystem
end

function TestCommandScheduler:testSubsystemPeriodic()
    local scheduler = CommandScheduler.getInstance()

    local MySubsystem = class(Subsystem)
    local periodicCalled = false

    function MySubsystem:periodic()
        periodicCalled = true
    end

    function MySubsystem.new()
        local self = setmetatable({}, MySubsystem)
        return MySubsystem.init(self)
    end

    local subsystem = MySubsystem.new()
    scheduler:registerSubsystem(subsystem)

    scheduler:run()
    lu.assertTrue(periodicCalled)
end

function TestCommandScheduler:testDisableScheduler()
    local scheduler = CommandScheduler.getInstance()
    local command = Command.new()

    scheduler:disable()
    scheduler:schedule(command)

    -- Command should NOT be scheduled when scheduler is disabled
    lu.assertFalse(scheduler:isScheduled(command))
    
    local executeCalled = false
    local MyCommand = class(Command)
    function MyCommand:execute()
        executeCalled = true
    end
    
    function MyCommand.new()
        local self = setmetatable({}, MyCommand)
        return MyCommand.init(self)
    end
    
    local testCommand = MyCommand.new()
    scheduler:schedule(testCommand)
    scheduler:run()
    
    lu.assertFalse(executeCalled)
    
    scheduler:enable()
    scheduler:schedule(testCommand)  -- Now it should schedule
    scheduler:run()
    lu.assertTrue(executeCalled)
end

os.exit(lu.LuaUnit.run('TestCommandScheduler'))
