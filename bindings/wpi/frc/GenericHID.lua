---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local DriverStation = require('wpi.frc.DriverStation')
local bit = require('bit')
local wpiHal = require('wpi.clib.wpiHal').load(false)

---@class GenericHID
---Generic Human Interface Device (HID)
local GenericHID = class()

---@enum RumbleType
GenericHID.RumbleType = {
  kLeftRumble = 0,
  kRightRumble = 1,
  kBothRumble = 2
}

---@enum HIDType
GenericHID.HIDType = {
  kUnknown = -1,
  kXInputUnknown = 0,
  kXInputGamepad = 1,
  kXInputWheel = 2,
  kXInputArcadeStick = 3,
  kXInputFlightStick = 4,
  kXInputDancePad = 5,
  kXInputGuitar = 6,
  kXInputGuitar2 = 7,
  kXInputDrumKit = 8,
  kXInputGuitar3 = 11,
  kXInputArcadePad = 19,
  kHIDJoystick = 20,
  kHIDGamepad = 21,
  kHIDDriving = 22,
  kHIDFlight = 23,
  kHID1stPerson = 24
}

---Initialize a GenericHID device
---@param port number The joystick port (0-5)
function GenericHID.init(self, port)
  self._port = port
  self._outputs = 0
  self._leftRumble = 0
  self._rightRumble = 0
end

---Create a new GenericHID
---@param port number The joystick port (0-5)
---@return GenericHID
function GenericHID.new(port)
  local instance = setmetatable({}, GenericHID)
  GenericHID.init(instance, port)
  return instance
end

---Get the button value (starting at button 1)
---@param button number Button index (starting at 1)
---@return boolean True if the button is pressed
function GenericHID:getRawButton(button)
  return DriverStation.getStickButton(self._port, button)
end

---Whether the button was pressed since the last check
---@param button number The button index, beginning at 1
---@return boolean Whether the button was pressed since the last check
function GenericHID:getRawButtonPressed(button)
  return DriverStation.getStickButtonPressed(self._port, button)
end

---Whether the button was released since the last check
---@param button number The button index, beginning at 1
---@return boolean Whether the button was released since the last check
function GenericHID:getRawButtonReleased(button)
  return DriverStation.getStickButtonReleased(self._port, button)
end

---Get the value of the axis
---@param axis number The axis to read, starting at 0
---@return number The value of the axis
function GenericHID:getRawAxis(axis)
  return DriverStation.getStickAxis(self._port, axis)
end

---Get the angle in degrees of a POV on the HID
---@param pov number? The index of the POV to read (starting at 0), defaults to 0
---@return number The angle of the POV in degrees, or -1 if the POV is not pressed
function GenericHID:getPOV(pov)
  pov = pov or 0
  return DriverStation.getStickPOV(self._port, pov)
end

---Get the number of axes for the HID
---@return number The number of axes
function GenericHID:getAxisCount()
  return DriverStation.getStickAxisCount(self._port)
end

---Get the number of POVs for the HID
---@return number The number of POVs
function GenericHID:getPOVCount()
  return DriverStation.getStickPOVCount(self._port)
end

---Get the number of buttons for the HID
---@return number The number of buttons
function GenericHID:getButtonCount()
  return DriverStation.getStickButtonCount(self._port)
end

---Get if the HID is connected
---@return boolean True if the HID is connected
function GenericHID:isConnected()
  return DriverStation.isJoystickConnected(self._port)
end

---Get the type of the HID
---@return number The HIDType of the HID
function GenericHID:getType()
  return DriverStation.getJoystickType(self._port)
end

---Get the name of the HID
---@return string The name of the HID
function GenericHID:getName()
  return DriverStation.getJoystickName(self._port)
end

---Get the axis type of a joystick axis
---@param axis number The axis to read, starting at 0
---@return number The axis type
function GenericHID:getAxisType(axis)
  return DriverStation.getJoystickAxisType(self._port, axis)
end

---Get the port number of the HID
---@return number The port number
function GenericHID:getPort()
  return self._port
end

---Set a single HID output value
---@param outputNumber number The index of the output to set (1-32)
---@param value boolean The value to set the output to
function GenericHID:setOutput(outputNumber, value)  
  if value then
    self._outputs = bit.bor(self._outputs, bit.lshift(1, outputNumber - 1))
  else
    self._outputs = bit.band(self._outputs, bit.bnot(bit.lshift(1, outputNumber - 1)))
  end
  
  wpiHal.HAL_SetJoystickOutputs(self._port, self._outputs, self._leftRumble, self._rightRumble)
end

---Set all output values for the HID
---@param value number The 32 bit output value (1 bit for each output)
function GenericHID:setOutputs(value)
  self._outputs = value
  wpiHal.HAL_SetJoystickOutputs(self._port, self._outputs, self._leftRumble, self._rightRumble)
end

---Set the rumble output for the HID
---@param type number The RumbleType (kLeftRumble, kRightRumble, or kBothRumble)
---@param value number The normalized value (0 to 1) to set the rumble to
function GenericHID:setRumble(type, value)  
  -- Convert 0-1 to 0-65535 (0xFFFF)
  local rumbleValue = math.floor(value * 65535 + 0.5)
  
  if type == GenericHID.RumbleType.kLeftRumble then
    self._leftRumble = rumbleValue
  elseif type == GenericHID.RumbleType.kRightRumble then
    self._rightRumble = rumbleValue
  elseif type == GenericHID.RumbleType.kBothRumble then
    self._leftRumble = rumbleValue
    self._rightRumble = rumbleValue
  end
  
  wpiHal.HAL_SetJoystickOutputs(self._port, self._outputs, self._leftRumble, self._rightRumble)
end

return GenericHID
