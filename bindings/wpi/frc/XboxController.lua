-- SPDX-FileCopyrightText: Michael Fisher @mfisher31
-- SPDX-License-Identifier: MIT

local class = require('luabot.class')
local GenericHID = require('wpi.frc.GenericHID')

---@class XboxController : GenericHID
---Handles input from Xbox controllers connected to the Driver Station.
local XboxController = class(GenericHID)

---Xbox controller button mappings
XboxController.Button = {
    kA = 1,
    kB = 2,
    kX = 3,
    kY = 4,
    kLeftBumper = 5,
    kRightBumper = 6,
    kBack = 7,
    kStart = 8,
    kLeftStick = 9,
    kRightStick = 10
}

---Xbox controller axis mappings
XboxController.Axis = {
    kLeftX = 0,
    kRightX = 4,
    kLeftY = 1,
    kRightY = 5,
    kLeftTrigger = 2,
    kRightTrigger = 3
}

---Construct an instance of an Xbox controller.
---@param port number The port index on the Driver Station (0-5)
function XboxController.init(instance, port)
    if port == nil then
        error('XboxController port cannot be nil')
    end
    
    GenericHID.init(instance, port)
    -- Report usage (would need HAL binding)
end

---Get the X axis value of left side of the controller. Right is positive.
---@return number The axis value
function XboxController:getLeftX()
    return self:getRawAxis(XboxController.Axis.kLeftX)
end

---Get the X axis value of right side of the controller. Right is positive.
---@return number The axis value
function XboxController:getRightX()
    return self:getRawAxis(XboxController.Axis.kRightX)
end

---Get the Y axis value of left side of the controller. Back is positive.
---@return number The axis value
function XboxController:getLeftY()
    return self:getRawAxis(XboxController.Axis.kLeftY)
end

---Get the Y axis value of right side of the controller. Back is positive.
---@return number The axis value
function XboxController:getRightY()
    return self:getRawAxis(XboxController.Axis.kRightY)
end

---Get the left trigger axis value of the controller.
---Note that this axis is bound to the range of [0, 1] as opposed to the usual [-1, 1].
---@return number The axis value
function XboxController:getLeftTriggerAxis()
    return self:getRawAxis(XboxController.Axis.kLeftTrigger)
end

---Get the right trigger axis value of the controller.
---Note that this axis is bound to the range of [0, 1] as opposed to the usual [-1, 1].
---@return number The axis value
function XboxController:getRightTriggerAxis()
    return self:getRawAxis(XboxController.Axis.kRightTrigger)
end

---Read the value of the A button on the controller.
---@return boolean The state of the button
function XboxController:getAButton()
    return self:getRawButton(XboxController.Button.kA)
end

---Whether the A button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getAButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kA)
end

---Whether the A button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getAButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kA)
end

---Read the value of the B button on the controller.
---@return boolean The state of the button
function XboxController:getBButton()
    return self:getRawButton(XboxController.Button.kB)
end

---Whether the B button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getBButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kB)
end

---Whether the B button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getBButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kB)
end

---Read the value of the X button on the controller.
---@return boolean The state of the button
function XboxController:getXButton()
    return self:getRawButton(XboxController.Button.kX)
end

---Whether the X button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getXButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kX)
end

---Whether the X button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getXButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kX)
end

---Read the value of the Y button on the controller.
---@return boolean The state of the button
function XboxController:getYButton()
    return self:getRawButton(XboxController.Button.kY)
end

---Whether the Y button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getYButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kY)
end

---Whether the Y button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getYButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kY)
end

---Read the value of the left bumper button on the controller.
---@return boolean The state of the button
function XboxController:getLeftBumperButton()
    return self:getRawButton(XboxController.Button.kLeftBumper)
end

---Whether the left bumper button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getLeftBumperButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kLeftBumper)
end

---Whether the left bumper button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getLeftBumperButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kLeftBumper)
end

---Read the value of the right bumper button on the controller.
---@return boolean The state of the button
function XboxController:getRightBumperButton()
    return self:getRawButton(XboxController.Button.kRightBumper)
end

---Whether the right bumper button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getRightBumperButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kRightBumper)
end

---Whether the right bumper button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getRightBumperButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kRightBumper)
end

---Read the value of the back button on the controller.
---@return boolean The state of the button
function XboxController:getBackButton()
    return self:getRawButton(XboxController.Button.kBack)
end

---Whether the back button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getBackButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kBack)
end

---Whether the back button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getBackButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kBack)
end

---Read the value of the start button on the controller.
---@return boolean The state of the button
function XboxController:getStartButton()
    return self:getRawButton(XboxController.Button.kStart)
end

---Whether the start button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getStartButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kStart)
end

---Whether the start button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getStartButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kStart)
end

---Read the value of the left stick button on the controller.
---@return boolean The state of the button
function XboxController:getLeftStickButton()
    return self:getRawButton(XboxController.Button.kLeftStick)
end

---Whether the left stick button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getLeftStickButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kLeftStick)
end

---Whether the left stick button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getLeftStickButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kLeftStick)
end

---Read the value of the right stick button on the controller.
---@return boolean The state of the button
function XboxController:getRightStickButton()
    return self:getRawButton(XboxController.Button.kRightStick)
end

---Whether the right stick button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function XboxController:getRightStickButtonPressed()
    return self:getRawButtonPressed(XboxController.Button.kRightStick)
end

---Whether the right stick button was released since the last check.
---@return boolean Whether the button was released since the last check
function XboxController:getRightStickButtonReleased()
    return self:getRawButtonReleased(XboxController.Button.kRightStick)
end

---Construct an instance of an Xbox controller.
---@param port number The port index on the Driver Station (0-5)
---@return XboxController The new Xbox controller instance
function XboxController.new(port)
    local obj = setmetatable({}, XboxController)
    XboxController.init(obj, port)
    return obj
end

return {
    Button = XboxController.Button,
    Axis = XboxController.Axis,
    new = XboxController.new
}
