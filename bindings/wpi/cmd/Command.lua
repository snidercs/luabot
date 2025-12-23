local class = require('luabot.class')

---@class Command
---Base class for robot commands in the command-based framework.
---A command represents an action the robot should take, potentially requiring one or more subsystems.
---@field _requirements table<Subsystem, boolean> Set of required subsystems
---@field _name string|nil Command name
local Command = class()

---Initialize a new Command instance
---@param instance Command The instance to initialize
---@return Command instance Initialized instance
function Command.init(instance)
    instance._requirements = {}
    instance._name = nil
    return instance
end

---Creates a new Command instance
---@return Command instance A new command instance
function Command.new()
    local self = setmetatable({}, Command)
    return Command.init(self)
end

---Called once when the command is initially scheduled.
---Override this method to add custom initialization behavior.
function Command:initialize()
    -- Default implementation does nothing
end

---Called repeatedly while the command is scheduled.
---Override this method to add the main command logic.
function Command:execute()
    -- Default implementation does nothing
end

---Called when the command ends, either normally or by interruption.
---@param interrupted boolean True if the command was interrupted, false if it finished normally
function Command:_end(interrupted)
    -- Default implementation does nothing
end

---Returns whether this command has finished executing.
---@return boolean True if the command should end, false otherwise
function Command:isFinished()
    return false  -- Default: never finishes on its own
end

---Adds subsystems required by this command.
---@param ... Subsystem One or more subsystems to require
function Command:addRequirements(...)
    local subsystems = {...}
    for _, subsystem in ipairs(subsystems) do
        self._requirements[subsystem] = true
    end
end

---Gets the subsystems required by this command.
---@return Subsystem[] Array of required subsystems
function Command:getRequirements()
    local reqs = {}
    for subsystem, _ in pairs(self._requirements) do
        table.insert(reqs, subsystem)
    end
    return reqs
end

---Gets the name of this command.
---@return string name The name of the command
function Command:getName()
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

---Sets the name of this command.
---@param name string The new name for the command
function Command:setName(name)
    self._name = name
end

---Gets the interruption behavior of this command.
---@return number behavior Interruption behavior type (0 = kCancelSelf, 1 = kCancelIncoming)
function Command:getInterruptionBehavior()
    return 0  -- kCancelSelf - incoming command cancels this one
end

return Command
