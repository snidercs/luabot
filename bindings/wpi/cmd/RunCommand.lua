local class = require('luabot.class')
local FunctionalCommand = require('wpi.cmd.FunctionalCommand')

---@class RunCommand : FunctionalCommand
---A command that runs a function continuously. Has no end condition as-is; either subclass it or
---use decorators like withTimeout() or until() to give it one.
---If you only wish to execute a function once, use InstantCommand.
local RunCommand = class(FunctionalCommand)

---Initialize a new RunCommand instance
---@param instance RunCommand The instance to initialize
---@param toRun function|table Function or callable to run continuously
---@param ... Subsystem Subsystems this command requires
---@return RunCommand instance Initialized instance
function RunCommand.init(instance, toRun, ...)
    FunctionalCommand.init(
        instance,
        nil,             -- onInit: do nothing
        toRun,           -- onExecute: run the function continuously
        nil,             -- onEnd: do nothing
        function() return false end,  -- isFinished: never finishes on its own
        ...              -- requirements
    )
    return instance
end

---Creates a new RunCommand that runs the given function continuously with the given requirements
---@param toRun function|table Function or callable to run continuously
---@param ... Subsystem Subsystems this command requires
---@return RunCommand instance A new run command instance
function RunCommand.new(toRun, ...)
    local self = setmetatable({}, RunCommand)
    return RunCommand.init(self, toRun or function() end, ...)
end

return RunCommand
