---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')

---@class Trigger
---@field private _condition function Function that returns boolean (the condition to monitor)
---@field private _loop EventLoop EventLoop instance that polls this trigger
local Trigger = class()

---Initialize a new Trigger instance
---@param self Trigger
---@param loop EventLoop The loop instance that polls this trigger
---@param condition function The condition represented by this trigger
function Trigger.init(self, loop, condition)
    if not loop then
        error('loop parameter is required for Trigger')
    end
    if not condition then
        error('condition parameter is required for Trigger')
    end
    
    self._condition = condition
    self._loop = loop
end

---Create a new trigger based on the given condition.
---@param loopOrCondition EventLoop|function The loop instance or condition function
---@param optionalCondition function|nil The condition if loop was provided
---@return Trigger
function Trigger.new(loopOrCondition, ...)
    local instance = setmetatable({}, Trigger)
    local nargs = select('#', ...)
    
    if nargs > 0 then
        -- Two argument form: new(loop, condition)
        local optionalCondition = select(1, ...)
        Trigger.init(instance, loopOrCondition, optionalCondition)
    else
        -- One argument form: new(condition) - use default loop
        -- Validate condition first
        if not loopOrCondition then
            error('condition parameter is required for Trigger')
        end
        local CommandScheduler = require('wpi.cmd.CommandScheduler')
        local loop = CommandScheduler.getInstance():getDefaultButtonLoop()
        Trigger.init(instance, loop, loopOrCondition)
    end
    
    return instance
end

---Adds a binding to the EventLoop.
---@param body function Function with signature function(previous, current)
function Trigger:addBinding(body)
    local previous = self._condition()
    
    self._loop:bind(function()
        local current = self._condition()
        body(previous, current)
        previous = current
    end)
end

---Starts the command when the condition changes.
---@param command Command The command to start
---@return Trigger This trigger, so calls can be chained
function Trigger:onChange(command)
    if not command then
        error('command is required for onChange')
    end
    
    self:addBinding(function(previous, current)
        if previous ~= current then
            self._loop:defer(function()
                local CommandScheduler = require('wpi.cmd.CommandScheduler')
                CommandScheduler.getInstance():schedule(command)
            end)
        end
    end)
    
    return self
end

---Starts the given command whenever the condition changes from false to true.
---@param command Command The command to start
---@return Trigger This trigger, so calls can be chained
function Trigger:onTrue(command)
    if not command then
        error('command is required for onTrue')
    end
    
    self:addBinding(function(previous, current)
        if not previous and current then
            self._loop:defer(function()
                local CommandScheduler = require('wpi.cmd.CommandScheduler')
                CommandScheduler.getInstance():schedule(command)
            end)
        end
    end)
    
    return self
end

---Starts the given command whenever the condition changes from true to false.
---@param command Command The command to start
---@return Trigger This trigger, so calls can be chained
function Trigger:onFalse(command)
    if not command then
        error('command is required for onFalse')
    end
    
    self:addBinding(function(previous, current)
        if previous and not current then
            self._loop:defer(function()
                local CommandScheduler = require('wpi.cmd.CommandScheduler')
                CommandScheduler.getInstance():schedule(command)
            end)
        end
    end)
    
    return self
end

---Starts the given command when the condition changes to true and cancels it when the condition changes to false.
---Doesn't re-start the command if it ends while the condition is still true.
---@param command Command The command to start
---@return Trigger This trigger, so calls can be chained
function Trigger:whileTrue(command)
    if not command then
        error('command is required for whileTrue')
    end
    
    self:addBinding(function(previous, current)
        if not previous and current then
            self._loop:defer(function()
                local CommandScheduler = require('wpi.cmd.CommandScheduler')
                CommandScheduler.getInstance():schedule(command)
            end)
        elseif previous and not current then
            self._loop:defer(function()
                command:cancel()
            end)
        end
    end)
    
    return self
end

---Starts the given command when the condition changes to false and cancels it when the condition changes to true.
---Doesn't re-start the command if it ends while the condition is still false.
---@param command Command The command to start
---@return Trigger This trigger, so calls can be chained
function Trigger:whileFalse(command)
    if not command then
        error('command is required for whileFalse')
    end
    
    self:addBinding(function(previous, current)
        if previous and not current then
            self._loop:defer(function()
                local CommandScheduler = require('wpi.cmd.CommandScheduler')
                CommandScheduler.getInstance():schedule(command)
            end)
        elseif not previous and current then
            self._loop:defer(function()
                command:cancel()
            end)
        end
    end)
    
    return self
end

---Toggles a command when the condition changes from false to true.
---@param command Command The command to toggle
---@return Trigger This trigger, so calls can be chained
function Trigger:toggleOnTrue(command)
    if not command then
        error('command is required for toggleOnTrue')
    end
    
    self:addBinding(function(previous, current)
        if not previous and current then
            self._loop:defer(function()
                if command:isScheduled() then
                    command:cancel()
                else
                    local CommandScheduler = require('wpi.cmd.CommandScheduler')
                    CommandScheduler.getInstance():schedule(command)
                end
            end)
        end
    end)
    
    return self
end

---Toggles a command when the condition changes from true to false.
---@param command Command The command to toggle
---@return Trigger This trigger, so calls can be chained
function Trigger:toggleOnFalse(command)
    if not command then
        error('command is required for toggleOnFalse')
    end
    
    self:addBinding(function(previous, current)
        if previous and not current then
            self._loop:defer(function()
                if command:isScheduled() then
                    command:cancel()
                else
                    local CommandScheduler = require('wpi.cmd.CommandScheduler')
                    CommandScheduler.getInstance():schedule(command)
                end
            end)
        end
    end)
    
    return self
end

---Evaluate the condition immediately (BooleanSupplier interface).
---@return boolean Current boolean value of condition
function Trigger:getAsBoolean()
    return self._condition()
end

---Composes two triggers with logical AND.
---@param trigger Trigger|function The condition to compose with
---@return Trigger A trigger which is active when both component triggers are active
function Trigger:and_(trigger)
    local otherCondition = trigger
    if type(trigger) == 'table' and trigger.getAsBoolean then
        otherCondition = function() return trigger:getAsBoolean() end
    end
    
    return Trigger.new(self._loop, function()
        return self._condition() and otherCondition()
    end)
end

---Composes two triggers with logical OR.
---@param trigger Trigger|function The condition to compose with
---@return Trigger A trigger which is active when either component trigger is active
function Trigger:or_(trigger)
    local otherCondition = trigger
    if type(trigger) == 'table' and trigger.getAsBoolean then
        otherCondition = function() return trigger:getAsBoolean() end
    end
    
    return Trigger.new(self._loop, function()
        return self._condition() or otherCondition()
    end)
end

---Creates a new trigger that is active when this trigger is inactive, i.e. that acts as the negation of this trigger.
---@return Trigger The negated trigger
function Trigger:negate()
    return Trigger.new(self._loop, function()
        return not self._condition()
    end)
end

---Creates a new debounced trigger from this trigger - it will become active when this trigger has been active for longer than the specified period.
---@param seconds number The debounce period
---@param debounceType number|nil The debounce type (default: kRising)
---@return Trigger The debounced trigger
function Trigger:debounce(seconds, debounceType)
    local Debouncer = require('wpi.math.filter.Debouncer')
    local debouncer = Debouncer.new(seconds, debounceType)
    
    return Trigger.new(self._loop, function()
        return debouncer:calculate(self._condition())
    end)
end

return Trigger
