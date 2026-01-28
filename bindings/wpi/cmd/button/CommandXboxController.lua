---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')
local XboxController = require('wpi.frc.XboxController')

---@class CommandXboxController : CommandGenericHID
---@field private _hid XboxController The underlying Xbox controller
local CommandXboxController = class(CommandGenericHID)

---Initialize a new CommandXboxController
---@param self CommandXboxController
---@param port number The port index on the Driver Station
function CommandXboxController.init(self, port)
    CommandGenericHID.init(self, port)
    self._hid = XboxController.new(port)
end

---Create a new CommandXboxController
---@param port number The port index on the Driver Station
---@return CommandXboxController
function CommandXboxController.new(port)
    local instance = setmetatable({}, CommandXboxController)
    CommandXboxController.init(instance, port)
    return instance
end

---Get the underlying Xbox controller object
---@return XboxController
function CommandXboxController:getHID()
    return self._hid
end

-- Button trigger methods

---Create a trigger for the A button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:a(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kA, loop)
end

---Create a trigger for the B button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:b(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kB, loop)
end

---Create a trigger for the X button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:x(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kX, loop)
end

---Create a trigger for the Y button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:y(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kY, loop)
end

---Create a trigger for the left bumper
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:leftBumper(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kLeftBumper, loop)
end

---Create a trigger for the right bumper
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:rightBumper(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kRightBumper, loop)
end

---Create a trigger for the back button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:back(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kBack, loop)
end

---Create a trigger for the start button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:start(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kStart, loop)
end

---Create a trigger for the left stick button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:leftStick(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kLeftStick, loop)
end

---Create a trigger for the right stick button
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:rightStick(loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kRightStick, loop)
end

-- Axis trigger methods

---Create a trigger for the left trigger axis
---@param threshold? number The threshold value (default 0.5)
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:leftTrigger(threshold, loop)
    threshold = threshold or 0.5
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:axisGreaterThan(XboxController.Axis.kLeftTrigger, threshold, loop)
end

---Create a trigger for the right trigger axis
---@param threshold? number The threshold value (default 0.5)
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandXboxController:rightTrigger(threshold, loop)
    threshold = threshold or 0.5
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:axisGreaterThan(XboxController.Axis.kRightTrigger, threshold, loop)
end

-- Axis value passthrough methods

---Get the X axis value of left stick
---@return number The axis value (-1 to 1, right positive)
function CommandXboxController:getLeftX()
    return self._hid:getLeftX()
end

---Get the X axis value of right stick
---@return number The axis value (-1 to 1, right positive)
function CommandXboxController:getRightX()
    return self._hid:getRightX()
end

---Get the Y axis value of left stick
---@return number The axis value (-1 to 1, back positive)
function CommandXboxController:getLeftY()
    return self._hid:getLeftY()
end

---Get the Y axis value of right stick
---@return number The axis value (-1 to 1, back positive)
function CommandXboxController:getRightY()
    return self._hid:getRightY()
end

---Get the left trigger axis value
---@return number The axis value (0 to 1)
function CommandXboxController:getLeftTriggerAxis()
    return self._hid:getLeftTriggerAxis()
end

---Get the right trigger axis value
---@return number The axis value (0 to 1)
function CommandXboxController:getRightTriggerAxis()
    return self._hid:getRightTriggerAxis()
end

return CommandXboxController
