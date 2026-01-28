---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')
local Joystick = require('wpi.frc.Joystick')

---@class CommandJoystick : CommandGenericHID
---@field private _hid Joystick The underlying joystick
local CommandJoystick = class(CommandGenericHID)

---Initialize a new CommandJoystick
---@param self CommandJoystick
---@param port number The port index on the Driver Station
function CommandJoystick.init(self, port)
    CommandGenericHID.init(self, port)
    self._hid = Joystick.new(port)
end

---Create a new CommandJoystick
---@param port number The port index on the Driver Station
---@return CommandJoystick
function CommandJoystick.new(port)
    local instance = setmetatable({}, CommandJoystick)
    CommandJoystick.init(instance, port)
    return instance
end

---Get the underlying joystick object
---@return Joystick
function CommandJoystick:getHID()
    return self._hid
end

-- Button trigger methods

---Create a trigger for the trigger button (button 1)
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandJoystick:trigger(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(Joystick.ButtonType.kTrigger, loop)
end

---Create a trigger for the top button (button 2)
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandJoystick:top(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(Joystick.ButtonType.kTop, loop)
end

-- Axis channel configuration methods

---Set the channel for the X axis
---@param channel number The axis channel (0-based)
function CommandJoystick:setXChannel(channel)
    self._hid:setXChannel(channel)
end

---Get the channel for the X axis
---@return number The axis channel
function CommandJoystick:getXChannel()
    return self._hid:getXChannel()
end

---Set the channel for the Y axis
---@param channel number The axis channel (0-based)
function CommandJoystick:setYChannel(channel)
    self._hid:setYChannel(channel)
end

---Get the channel for the Y axis
---@return number The axis channel
function CommandJoystick:getYChannel()
    return self._hid:getYChannel()
end

---Set the channel for the Z axis
---@param channel number The axis channel (0-based)
function CommandJoystick:setZChannel(channel)
    self._hid:setZChannel(channel)
end

---Get the channel for the Z axis
---@return number The axis channel
function CommandJoystick:getZChannel()
    return self._hid:getZChannel()
end

---Set the channel for the twist axis
---@param channel number The axis channel (0-based)
function CommandJoystick:setTwistChannel(channel)
    self._hid:setTwistChannel(channel)
end

---Get the channel for the twist axis
---@return number The axis channel
function CommandJoystick:getTwistChannel()
    return self._hid:getTwistChannel()
end

---Set the channel for the throttle axis
---@param channel number The axis channel (0-based)
function CommandJoystick:setThrottleChannel(channel)
    self._hid:setThrottleChannel(channel)
end

---Get the channel for the throttle axis
---@return number The axis channel
function CommandJoystick:getThrottleChannel()
    return self._hid:getThrottleChannel()
end

-- Axis value methods

---Get the X axis value
---@return number The axis value (-1 to 1, right positive)
function CommandJoystick:getX()
    return self._hid:getX()
end

---Get the Y axis value
---@return number The axis value (-1 to 1, back positive)
function CommandJoystick:getY()
    return self._hid:getY()
end

---Get the Z axis value
---@return number The axis value (-1 to 1, clockwise positive)
function CommandJoystick:getZ()
    return self._hid:getZ()
end

---Get the twist axis value
---@return number The axis value (-1 to 1, clockwise positive)
function CommandJoystick:getTwist()
    return self._hid:getTwist()
end

---Get the throttle axis value
---@return number The axis value (-1 to 1, forward negative)
function CommandJoystick:getThrottle()
    return self._hid:getThrottle()
end

-- Polar coordinate methods

---Get the magnitude of the joystick's position
---@return number The magnitude (0 to 1)
function CommandJoystick:getMagnitude()
    return self._hid:getMagnitude()
end

---Get the direction angle in radians
---@return number The angle in radians (0 = forward, clockwise positive)
function CommandJoystick:getDirectionRadians()
    return self._hid:getDirectionRadians()
end

---Get the direction angle in degrees
---@return number The angle in degrees (0 = forward, clockwise positive)
function CommandJoystick:getDirectionDegrees()
    return self._hid:getDirectionDegrees()
end

return CommandJoystick

