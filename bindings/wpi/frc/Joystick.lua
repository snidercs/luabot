-- SPDX-FileCopyrightText: Michael Fisher @mfisher31
-- SPDX-License-Identifier: MIT

local class = require('luabot.class')
local GenericHID = require('wpi.frc.GenericHID')

---@class Joystick : GenericHID
---Handle input from Flight Joysticks connected to the Driver Station.
local Joystick = class(GenericHID)

-- Default axis channels
Joystick.kDefaultXChannel = 0
Joystick.kDefaultYChannel = 1
Joystick.kDefaultZChannel = 2
Joystick.kDefaultTwistChannel = 2
Joystick.kDefaultThrottleChannel = 3

---Joystick axis type mappings
Joystick.AxisType = {
    kX = 0,
    kY = 1,
    kZ = 2,
    kTwist = 3,
    kThrottle = 4
}

---Joystick button type mappings
Joystick.ButtonType = {
    kTrigger = 1,
    kTop = 2
}

---Construct an instance of a joystick.
---@param port number The port index on the Driver Station (0-5)
function Joystick.init(instance, port)
    if port == nil then
        error('Joystick port cannot be nil')
    end
    
    GenericHID.init(instance, port)
    
    -- Initialize axis channels to defaults
    instance._axes = {
        [Joystick.AxisType.kX] = Joystick.kDefaultXChannel,
        [Joystick.AxisType.kY] = Joystick.kDefaultYChannel,
        [Joystick.AxisType.kZ] = Joystick.kDefaultZChannel,
        [Joystick.AxisType.kTwist] = Joystick.kDefaultTwistChannel,
        [Joystick.AxisType.kThrottle] = Joystick.kDefaultThrottleChannel
    }
end

---Set the channel associated with the X axis.
---@param channel number The channel to set the axis to
function Joystick:setXChannel(channel)
    self._axes[Joystick.AxisType.kX] = channel
end

---Set the channel associated with the Y axis.
---@param channel number The channel to set the axis to
function Joystick:setYChannel(channel)
    self._axes[Joystick.AxisType.kY] = channel
end

---Set the channel associated with the Z axis.
---@param channel number The channel to set the axis to
function Joystick:setZChannel(channel)
    self._axes[Joystick.AxisType.kZ] = channel
end

---Set the channel associated with the twist axis.
---@param channel number The channel to set the axis to
function Joystick:setTwistChannel(channel)
    self._axes[Joystick.AxisType.kTwist] = channel
end

---Set the channel associated with the throttle axis.
---@param channel number The channel to set the axis to
function Joystick:setThrottleChannel(channel)
    self._axes[Joystick.AxisType.kThrottle] = channel
end

---Get the channel currently associated with the X axis.
---@return number The channel for the axis
function Joystick:getXChannel()
    return self._axes[Joystick.AxisType.kX]
end

---Get the channel currently associated with the Y axis.
---@return number The channel for the axis
function Joystick:getYChannel()
    return self._axes[Joystick.AxisType.kY]
end

---Get the channel currently associated with the Z axis.
---@return number The channel for the axis
function Joystick:getZChannel()
    return self._axes[Joystick.AxisType.kZ]
end

---Get the channel currently associated with the twist axis.
---@return number The channel for the axis
function Joystick:getTwistChannel()
    return self._axes[Joystick.AxisType.kTwist]
end

---Get the channel currently associated with the throttle axis.
---@return number The channel for the axis
function Joystick:getThrottleChannel()
    return self._axes[Joystick.AxisType.kThrottle]
end

---Get the X value of the joystick.
---This depends on the mapping of the joystick connected to the current port.
---On most joysticks, positive is to the right.
---@return number The X value of the joystick
function Joystick:getX()
    return self:getRawAxis(self._axes[Joystick.AxisType.kX])
end

---Get the Y value of the joystick.
---This depends on the mapping of the joystick connected to the current port.
---On most joysticks, positive is to the back.
---@return number The Y value of the joystick
function Joystick:getY()
    return self:getRawAxis(self._axes[Joystick.AxisType.kY])
end

---Get the Z position of the HID.
---@return number The z position
function Joystick:getZ()
    return self:getRawAxis(self._axes[Joystick.AxisType.kZ])
end

---Get the twist value of the current joystick.
---This depends on the mapping of the joystick connected to the current port.
---@return number The Twist value of the joystick
function Joystick:getTwist()
    return self:getRawAxis(self._axes[Joystick.AxisType.kTwist])
end

---Get the throttle value of the current joystick.
---This depends on the mapping of the joystick connected to the current port.
---@return number The Throttle value of the joystick
function Joystick:getThrottle()
    return self:getRawAxis(self._axes[Joystick.AxisType.kThrottle])
end

---Read the state of the trigger on the joystick.
---@return boolean The state of the trigger
function Joystick:getTrigger()
    return self:getRawButton(Joystick.ButtonType.kTrigger)
end

---Whether the trigger was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function Joystick:getTriggerPressed()
    return self:getRawButtonPressed(Joystick.ButtonType.kTrigger)
end

---Whether the trigger was released since the last check.
---@return boolean Whether the button was released since the last check
function Joystick:getTriggerReleased()
    return self:getRawButtonReleased(Joystick.ButtonType.kTrigger)
end

---Read the state of the top button on the joystick.
---@return boolean The state of the top button
function Joystick:getTop()
    return self:getRawButton(Joystick.ButtonType.kTop)
end

---Whether the top button was pressed since the last check.
---@return boolean Whether the button was pressed since the last check
function Joystick:getTopPressed()
    return self:getRawButtonPressed(Joystick.ButtonType.kTop)
end

---Whether the top button was released since the last check.
---@return boolean Whether the button was released since the last check
function Joystick:getTopReleased()
    return self:getRawButtonReleased(Joystick.ButtonType.kTop)
end

---Get the magnitude of the vector formed by the joystick's current position relative to its origin.
---@return number The magnitude of the direction vector
function Joystick:getMagnitude()
    local x = self:getX()
    local y = self:getY()
    return math.sqrt(x * x + y * y)
end

---Get the direction of the vector formed by the joystick and its origin in radians.
---0 is forward and clockwise is positive. (Straight right is π/2.)
---@return number The direction of the vector in radians
function Joystick:getDirectionRadians()
    -- https://docs.wpilib.org/en/stable/docs/software/basic-programming/coordinate-system.html#joystick-and-controller-coordinate-system
    -- It's rotated 90 degrees CCW (y is negated and the arguments are reversed)
    -- so that 0 radians is forward.
    return math.atan2(self:getX(), -self:getY())
end

---Get the direction of the vector formed by the joystick and its origin in degrees.
---0 is forward and clockwise is positive. (Straight right is 90.)
---@return number The direction of the vector in degrees
function Joystick:getDirectionDegrees()
    return math.deg(self:getDirectionRadians())
end

---Construct an instance of a joystick.
---@param port number The port index on the Driver Station (0-5)
---@return Joystick The new joystick instance
function Joystick.new(port)
    local obj = setmetatable({}, Joystick)
    Joystick.init(obj, port)
    return obj
end

return {
    kDefaultXChannel = Joystick.kDefaultXChannel,
    kDefaultYChannel = Joystick.kDefaultYChannel,
    kDefaultZChannel = Joystick.kDefaultZChannel,
    kDefaultTwistChannel = Joystick.kDefaultTwistChannel,
    kDefaultThrottleChannel = Joystick.kDefaultThrottleChannel,
    AxisType = Joystick.AxisType,
    ButtonType = Joystick.ButtonType,
    new = Joystick.new
}
