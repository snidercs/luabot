local class = require('luabot.class')
local FunctionalCommand = require('wpi.cmd.FunctionalCommand')

---@class InstantCommand : FunctionalCommand
---A command that runs instantly; it will initialize, execute once, and end on the same iteration
---of the scheduler. Users can either pass in a function and a set of requirements, or else subclass
---this command if desired.
local InstantCommand = class(FunctionalCommand)

---Initialize a new InstantCommand instance
---@param instance InstantCommand The instance to initialize
---@param toRun function|table Function or callable to run once
---@param ... Subsystem Subsystems this command requires
---@return InstantCommand instance Initialized instance
function InstantCommand.init(instance, toRun, ...)
    FunctionalCommand.init(
        instance,
        toRun,           -- onInit: run the function once
        nil,             -- onExecute: do nothing
        nil,             -- onEnd: do nothing
        function() return true end,  -- isFinished: always true (finishes immediately)
        ...              -- requirements
    )
    return instance
end

---Creates a new InstantCommand that runs the given function with the given requirements
---@param toRun function|table Function or callable to run once
---@param ... Subsystem Subsystems this command requires
---@return InstantCommand instance A new instant command instance
function InstantCommand.new(toRun, ...)
    local self = setmetatable({}, InstantCommand)
    return InstantCommand.init(self, toRun or function() end, ...)
end

return InstantCommand
