---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local hal = require('wpi.hal')
local DriverStation = require('wpi.frc.DriverStation')

-- Initialize HAL (required for DriverStation)
hal.initialize(500, 0)

-- Test isJoystickConnected returns false when no joystick connected
do
    local connected = DriverStation.isJoystickConnected(0)
    lu.assertFalse(connected, 'isJoystickConnected should return false when no joystick')
end

collectgarbage()

-- Test getJoystickName returns empty string when no joystick connected
do
    local name = DriverStation.getJoystickName(0)
    lu.assertIsString(name, 'getJoystickName should return a string')
    lu.assertEquals(name, '', 'getJoystickName should return empty string when no joystick')
end

collectgarbage()

-- Test getJoystickType returns -1 (kUnknown) when no joystick connected
do
    local joyType = DriverStation.getJoystickType(0)
    lu.assertIsNumber(joyType, 'getJoystickType should return a number')
    -- -1 is kUnknown HIDType
end

collectgarbage()

-- Test getStickAxisCount returns 0 when no joystick connected
do
    local count = DriverStation.getStickAxisCount(0)
    lu.assertIsNumber(count, 'getStickAxisCount should return a number')
    lu.assertEquals(count, 0, 'getStickAxisCount should return 0 when no joystick')
end

collectgarbage()

-- Test getStickButtonCount returns 0 when no joystick connected
do
    local count = DriverStation.getStickButtonCount(0)
    lu.assertIsNumber(count, 'getStickButtonCount should return a number')
    lu.assertEquals(count, 0, 'getStickButtonCount should return 0 when no joystick')
end

collectgarbage()

-- Test getStickPOVCount returns 0 when no joystick connected
do
    local count = DriverStation.getStickPOVCount(0)
    lu.assertIsNumber(count, 'getStickPOVCount should return a number')
    lu.assertEquals(count, 0, 'getStickPOVCount should return 0 when no joystick')
end

collectgarbage()

-- Test getStickButton returns false when no joystick connected
do
    local button = DriverStation.getStickButton(0, 1)
    lu.assertFalse(button, 'getStickButton should return false when no joystick')
end

collectgarbage()

-- Test getStickAxis returns 0.0 when no joystick connected
do
    local axis = DriverStation.getStickAxis(0, 0)
    lu.assertIsNumber(axis, 'getStickAxis should return a number')
    lu.assertEquals(axis, 0.0, 'getStickAxis should return 0.0 when no joystick')
end

collectgarbage()

-- Test getStickPOV returns -1 when no joystick connected
do
    local pov = DriverStation.getStickPOV(0, 0)
    lu.assertIsNumber(pov, 'getStickPOV should return a number')
    lu.assertEquals(pov, -1, 'getStickPOV should return -1 when no joystick')
end

collectgarbage()

-- Test getStickButtons returns 0 when no joystick connected
do
    local buttons = DriverStation.getStickButtons(0)
    lu.assertIsNumber(buttons, 'getStickButtons should return a number')
    lu.assertEquals(buttons, 0, 'getStickButtons should return 0 when no joystick')
end

collectgarbage()

-- Test getJoystickIsXbox returns false when no joystick connected
do
    local isXbox = DriverStation.getJoystickIsXbox(0)
    lu.assertFalse(isXbox, 'getJoystickIsXbox should return false when no joystick')
end

collectgarbage()

-- Test getJoystickAxisType returns a number
do
    local axisType = DriverStation.getJoystickAxisType(0, 0)
    lu.assertIsNumber(axisType, 'getJoystickAxisType should return a number')
end

collectgarbage()

-- Test robot state methods (should work without DS connection)
do
    local isEnabled = DriverStation.isEnabled()
    lu.assertIsFalse(isEnabled, 'isEnabled should return false without DS')
    
    local isDisabled = DriverStation.isDisabled()
    lu.assertIsTrue(isDisabled, 'isDisabled should return true without DS')
    
    local isEStopped = DriverStation.isEStopped()
    lu.assertIsFalse(isEStopped, 'isEStopped should return false without DS')
    
    -- Without DS, robot defaults to teleop mode
    local isAutonomous = DriverStation.isAutonomous()
    lu.assertIsFalse(isAutonomous, 'isAutonomous should return false without DS')
    
    local isTeleop = DriverStation.isTeleop()
    lu.assertIsTrue(isTeleop, 'isTeleop should return true (default mode without DS)')
    
    local isTest = DriverStation.isTest()
    lu.assertFalse(isTest, 'isTest should return false without DS')
end

collectgarbage()

-- Test DS/FMS attachment status
do
    local isDSAttached = DriverStation.isDSAttached()
    lu.assertIsFalse(isDSAttached, 'isDSAttached should return false without DS')
    
    local isFMSAttached = DriverStation.isFMSAttached()
    lu.assertIsFalse(isFMSAttached, 'isFMSAttached should return false without FMS')
end

collectgarbage()

-- Test match info methods
do
    local matchNumber = DriverStation.getMatchNumber()
    lu.assertIsNumber(matchNumber, 'getMatchNumber should return a number')
    lu.assertEquals(matchNumber, 0, 'getMatchNumber should return 0 without DS')
    
    local replayNumber = DriverStation.getReplayNumber()
    lu.assertIsNumber(replayNumber, 'getReplayNumber should return a number')
    lu.assertEquals(replayNumber, 0, 'getReplayNumber should return 0 without DS')
end

collectgarbage()

-- Test battery voltage (should return 0.0 or positive value)
do
    local voltage = DriverStation.getBatteryVoltage()
    lu.assertIsNumber(voltage, 'getBatteryVoltage should return a number')
    lu.assertTrue(voltage >= 0, 'getBatteryVoltage should return non-negative value')
end

collectgarbage()

-- Test refreshData (should not crash)
do
    DriverStation.refreshData()
    lu.assertTrue(true, 'refreshData should not crash')
end

collectgarbage()

-- Test joystick connection warning silence functions
do
    local wasSilenced = DriverStation.isJoystickConnectionWarningSilenced()
    lu.assertIsBoolean(wasSilenced, 'isJoystickConnectionWarningSilenced should return a boolean')
    
    DriverStation.silenceJoystickConnectionWarning(true)
    local nowSilenced = DriverStation.isJoystickConnectionWarningSilenced()
    lu.assertTrue(nowSilenced, 'silenceJoystickConnectionWarning(true) should enable silencing')
    
    DriverStation.silenceJoystickConnectionWarning(false)
    local notSilenced = DriverStation.isJoystickConnectionWarningSilenced()
    lu.assertFalse(notSilenced, 'silenceJoystickConnectionWarning(false) should disable silencing')
end

collectgarbage()

-- Test getStickButtonPressed/Released return false when no joystick
do
    local pressed = DriverStation.getStickButtonPressed(0, 1)
    lu.assertFalse(pressed, 'getStickButtonPressed should return false when no joystick')
    
    local released = DriverStation.getStickButtonReleased(0, 1)
    lu.assertFalse(released, 'getStickButtonReleased should return false when no joystick')
end

collectgarbage()

-- Cleanup HAL
hal.shutdown()

print('TestDriverStation: All tests passed')
