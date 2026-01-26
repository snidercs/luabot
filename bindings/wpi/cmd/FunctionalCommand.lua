---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local Command = require('wpi.cmd.Command')

---@class FunctionalCommand : Command
---A command that allows passing in functions (or any callable objects) for each lifecycle method.
---This is useful for quickly creating commands without having to subclass Command.
---@field private _onInit function|table
---@field private _onExecute function|table
---@field private _onEnd function|table
---@field private _isFinished function|table
local FunctionalCommand = class(Command)

---Initialize a new FunctionalCommand instance
---@param instance FunctionalCommand The instance to initialize
---@param onInit function|table Function or callable to call when command is initialized
---@param onExecute function|table Function or callable to call repeatedly while command is running
---@param onEnd function|table Function or callable to call when command ends (takes interrupted boolean)
---@param isFinished function|table Function or callable that returns true when command should end
---@param ... Subsystem Subsystems this command requires
---@return FunctionalCommand instance Initialized instance
function FunctionalCommand.init(instance, onInit, onExecute, onEnd, isFinished, ...)
    Command.init(instance)
    instance._onInit = onInit
    instance._onExecute = onExecute
    instance._onEnd = onEnd
    instance._isFinished = isFinished
    
    -- Add requirements
    if select('#', ...) > 0 then
        instance:addRequirements(...)
    end
    
    return instance
end

---Creates a new FunctionalCommand instance
---@param onInit function|table Function or callable to call when command is initialized
---@param onExecute function|table Function or callable to call repeatedly while command is running
---@param onEnd function|table Function or callable to call when command ends (takes interrupted boolean)
---@param isFinished function|table Function or callable that returns true when command should end
---@param ... Subsystem Subsystems this command requires
---@return FunctionalCommand instance A new functional command instance
function FunctionalCommand.new(onInit, onExecute, onEnd, isFinished, ...)
    local self = setmetatable({}, FunctionalCommand)
    return FunctionalCommand.init(self, onInit, onExecute, onEnd, isFinished, ...)
end

---Called once when the command is initially scheduled
function FunctionalCommand:initialize()
    if self._onInit then
        self._onInit()
    end
end

---Called repeatedly while the command is scheduled
function FunctionalCommand:execute()
    if self._onExecute then
        self._onExecute()
    end
end

---Called when the command ends, either normally or by interruption
---@param interrupted boolean True if the command was interrupted, false if it finished normally
function FunctionalCommand:done(interrupted)
    if self._onEnd then
        self._onEnd(interrupted)
    end
end

---Returns whether this command has finished executing
---@return boolean True if the command should end, false otherwise
function FunctionalCommand:isFinished()
    if self._isFinished then
        return self._isFinished()
    end
    return false
end

return FunctionalCommand
