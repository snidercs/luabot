local class = require('luabot.class')

---@class Subsystem
---Base class for robot subsystems.
---Subsystems are the basic unit of robot organization in the command-based framework.
---A subsystem defines the hardware and methods for a specific mechanism or capability of the robot.
---@field _defaultCommand Command|nil
---@field _name string|nil
local Subsystem = class()

---Initialize a new Subsystem instance
---@param instance Subsystem The instance to initialize
---@return Subsystem instance Initialized instance
function Subsystem.init(instance)
    instance._defaultCommand = nil
    instance._name = nil
    
    -- Register this subsystem with the scheduler (will be implemented later)
    -- local CommandScheduler = require('wpi.cmd.CommandScheduler')
    -- CommandScheduler.getInstance():registerSubsystem(instance)
    
    return instance
end

---Creates a new Subsystem instance
---@return Subsystem instance A new subsystem instance
function Subsystem.new()
    local self = setmetatable({}, Subsystem)
    return Subsystem.init(self)
end

---This method is called periodically by the CommandScheduler.
---Override this method to add custom periodic behavior for this subsystem.
function Subsystem:periodic()
    -- Default implementation does nothing
end

---This method is called periodically by the CommandScheduler during simulation.
---Override this method to add custom simulation behavior for this subsystem.
function Subsystem:simulationPeriodic()
    -- Default implementation does nothing
end

---Gets the name of this subsystem.
---@return string The name of the subsystem
function Subsystem:getName()
    if self._name then
        return self._name
    end
    -- Return class name by default
    local mt = getmetatable(self)
    if mt and mt.__name then
        return mt.__name
    end
    return tostring(self)
end

---Sets the name of this subsystem.
---@param name string The new name for the subsystem
function Subsystem:setName(name)
    self._name = name
end

---Sets the default command for this subsystem.
---The default command will be automatically scheduled when no other command requiring this subsystem is running.
---@param command Command|nil The command to set as default, or nil to clear the default command
function Subsystem:setDefaultCommand(command)
    self._defaultCommand = command
    -- Will be implemented when CommandScheduler is ready
    -- local CommandScheduler = require('wpi.cmd.CommandScheduler')
    -- CommandScheduler.getInstance():setDefaultCommand(self, command)
end

---Gets the default command for this subsystem.
---@return Command|nil The default command, or nil if no default is set
function Subsystem:getDefaultCommand()
    return self._defaultCommand
end

---Gets the command currently requiring this subsystem.
---@return Command|nil The command currently using this subsystem, or nil if none
function Subsystem:getCurrentCommand()
    -- Will be implemented when CommandScheduler is ready
    -- local CommandScheduler = require('wpi.cmd.CommandScheduler')
    -- return CommandScheduler.getInstance():requiring(self)
    return nil
end

return Subsystem
