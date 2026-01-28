---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local hal = require('wpi.hal')
local GenericHID = require('wpi.frc.GenericHID')

-- Initialize HAL (required for DriverStation/GenericHID)
hal.initialize(500, 0)

-- Test GenericHID construction
do
    local hid = GenericHID.new(0)
    lu.assertNotNil(hid, 'GenericHID should be constructable')
    lu.assertEquals(hid:getPort(), 0, 'GenericHID port should be 0')
end

collectgarbage()

-- Test getRawButton returns false when no joystick connected
do
    local hid = GenericHID.new(0)
    local button = hid:getRawButton(1)
    lu.assertFalse(button, 'getRawButton should return false when no joystick')
end

collectgarbage()

-- Test getRawButtonPressed returns false when no joystick connected
do
    local hid = GenericHID.new(0)
    local pressed = hid:getRawButtonPressed(1)
    lu.assertFalse(pressed, 'getRawButtonPressed should return false when no joystick')
end

collectgarbage()

-- Test getRawButtonReleased returns false when no joystick connected
do
    local hid = GenericHID.new(0)
    local released = hid:getRawButtonReleased(1)
    lu.assertFalse(released, 'getRawButtonReleased should return false when no joystick')
end

collectgarbage()

-- Test getRawAxis returns 0.0 when no joystick connected
do
    local hid = GenericHID.new(0)
    local axis = hid:getRawAxis(0)
    lu.assertIsNumber(axis, 'getRawAxis should return a number')
    lu.assertEquals(axis, 0.0, 'getRawAxis should return 0.0 when no joystick')
end

collectgarbage()

-- Test getPOV returns -1 when no joystick connected
do
    local hid = GenericHID.new(0)
    local pov = hid:getPOV()
    lu.assertIsNumber(pov, 'getPOV should return a number')
    lu.assertEquals(pov, -1, 'getPOV should return -1 when no joystick')
    
    local pov1 = hid:getPOV(0)
    lu.assertEquals(pov1, -1, 'getPOV(0) should return -1 when no joystick')
end

collectgarbage()

-- Test getAxisCount returns 0 when no joystick connected
do
    local hid = GenericHID.new(0)
    local count = hid:getAxisCount()
    lu.assertIsNumber(count, 'getAxisCount should return a number')
    lu.assertEquals(count, 0, 'getAxisCount should return 0 when no joystick')
end

collectgarbage()

-- Test getPOVCount returns 0 when no joystick connected
do
    local hid = GenericHID.new(0)
    local count = hid:getPOVCount()
    lu.assertIsNumber(count, 'getPOVCount should return a number')
    lu.assertEquals(count, 0, 'getPOVCount should return 0 when no joystick')
end

collectgarbage()

-- Test getButtonCount returns 0 when no joystick connected
do
    local hid = GenericHID.new(0)
    local count = hid:getButtonCount()
    lu.assertIsNumber(count, 'getButtonCount should return a number')
    lu.assertEquals(count, 0, 'getButtonCount should return 0 when no joystick')
end

collectgarbage()

-- Test isConnected returns false when no joystick connected
do
    local hid = GenericHID.new(0)
    local connected = hid:isConnected()
    lu.assertFalse(connected, 'isConnected should return false when no joystick')
end

collectgarbage()

-- Test getType returns a number
do
    local hid = GenericHID.new(0)
    local hidType = hid:getType()
    lu.assertIsNumber(hidType, 'getType should return a number')
end

collectgarbage()

-- Test getName returns empty string when no joystick connected
do
    local hid = GenericHID.new(0)
    local name = hid:getName()
    lu.assertIsString(name, 'getName should return a string')
    lu.assertEquals(name, '', 'getName should return empty string when no joystick')
end

collectgarbage()

-- Test getAxisType returns a number
do
    local hid = GenericHID.new(0)
    local axisType = hid:getAxisType(0)
    lu.assertIsNumber(axisType, 'getAxisType should return a number')
end

collectgarbage()

-- Test setOutput doesn't crash (no way to verify without real hardware)
do
    local hid = GenericHID.new(0)
    hid:setOutput(1, true)
    lu.assertTrue(true, 'setOutput should not crash')
    
    hid:setOutput(1, false)
    lu.assertTrue(true, 'setOutput(false) should not crash')
end

collectgarbage()

-- Test setOutputs doesn't crash
do
    local hid = GenericHID.new(0)
    hid:setOutputs(0xFF)
    lu.assertTrue(true, 'setOutputs should not crash')
    
    hid:setOutputs(0)
    lu.assertTrue(true, 'setOutputs(0) should not crash')
end

collectgarbage()

-- Test setRumble doesn't crash
do
    local hid = GenericHID.new(0)
    hid:setRumble(GenericHID.RumbleType.kLeftRumble, 0.5)
    lu.assertTrue(true, 'setRumble left should not crash')
    
    hid:setRumble(GenericHID.RumbleType.kRightRumble, 0.75)
    lu.assertTrue(true, 'setRumble right should not crash')
    
    hid:setRumble(GenericHID.RumbleType.kBothRumble, 1.0)
    lu.assertTrue(true, 'setRumble both should not crash')
    
    hid:setRumble(GenericHID.RumbleType.kBothRumble, 0.0)
    lu.assertTrue(true, 'setRumble both off should not crash')
end

collectgarbage()

-- Test HIDType enum values
do
    lu.assertEquals(GenericHID.HIDType.kUnknown, -1, 'kUnknown should be -1')
    lu.assertEquals(GenericHID.HIDType.kXInputGamepad, 1, 'kXInputGamepad should be 1')
    lu.assertEquals(GenericHID.HIDType.kHIDJoystick, 20, 'kHIDJoystick should be 20')
end

collectgarbage()

-- Test RumbleType enum values
do
    lu.assertEquals(GenericHID.RumbleType.kLeftRumble, 0, 'kLeftRumble should be 0')
    lu.assertEquals(GenericHID.RumbleType.kRightRumble, 1, 'kRightRumble should be 1')
    lu.assertEquals(GenericHID.RumbleType.kBothRumble, 2, 'kBothRumble should be 2')
end

collectgarbage()

-- Test multiple GenericHID instances with different ports
do
    local hid0 = GenericHID.new(0)
    local hid1 = GenericHID.new(1)
    local hid5 = GenericHID.new(5)
    
    lu.assertEquals(hid0:getPort(), 0, 'hid0 port should be 0')
    lu.assertEquals(hid1:getPort(), 1, 'hid1 port should be 1')
    lu.assertEquals(hid5:getPort(), 5, 'hid5 port should be 5')
    
    lu.assertFalse(hid0:isConnected(), 'hid0 should not be connected')
    lu.assertFalse(hid1:isConnected(), 'hid1 should not be connected')
    lu.assertFalse(hid5:isConnected(), 'hid5 should not be connected')
end

collectgarbage()

-- Cleanup HAL
hal.shutdown()

print('TestGenericHID: All tests passed')
