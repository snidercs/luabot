---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local hal = require('wpi.hal')
local XboxController = require('wpi.frc.XboxController')

-- Initialize HAL (required for DriverStation/GenericHID)
hal.initialize(500, 0)

-- Test XboxController construction
do
    local controller = XboxController.new(0)
    lu.assertNotNil(controller, 'XboxController should be constructable')
    lu.assertEquals(controller:getPort(), 0, 'XboxController port should be 0')
end

collectgarbage()

-- Test Button enum values
do
    lu.assertEquals(XboxController.Button.kA, 1, 'Button.kA should be 1')
    lu.assertEquals(XboxController.Button.kB, 2, 'Button.kB should be 2')
    lu.assertEquals(XboxController.Button.kX, 3, 'Button.kX should be 3')
    lu.assertEquals(XboxController.Button.kY, 4, 'Button.kY should be 4')
    lu.assertEquals(XboxController.Button.kLeftBumper, 5, 'Button.kLeftBumper should be 5')
    lu.assertEquals(XboxController.Button.kRightBumper, 6, 'Button.kRightBumper should be 6')
    lu.assertEquals(XboxController.Button.kBack, 7, 'Button.kBack should be 7')
    lu.assertEquals(XboxController.Button.kStart, 8, 'Button.kStart should be 8')
    lu.assertEquals(XboxController.Button.kLeftStick, 9, 'Button.kLeftStick should be 9')
    lu.assertEquals(XboxController.Button.kRightStick, 10, 'Button.kRightStick should be 10')
end

collectgarbage()

-- Test Axis enum values
do
    lu.assertEquals(XboxController.Axis.kLeftX, 0, 'Axis.kLeftX should be 0')
    lu.assertEquals(XboxController.Axis.kRightX, 4, 'Axis.kRightX should be 4')
    lu.assertEquals(XboxController.Axis.kLeftY, 1, 'Axis.kLeftY should be 1')
    lu.assertEquals(XboxController.Axis.kRightY, 5, 'Axis.kRightY should be 5')
    lu.assertEquals(XboxController.Axis.kLeftTrigger, 2, 'Axis.kLeftTrigger should be 2')
    lu.assertEquals(XboxController.Axis.kRightTrigger, 3, 'Axis.kRightTrigger should be 3')
end

collectgarbage()

-- Test axis methods return numbers when no controller connected
do
    local controller = XboxController.new(1)
    
    local leftX = controller:getLeftX()
    lu.assertIsNumber(leftX, 'getLeftX should return a number')
    lu.assertEquals(leftX, 0.0, 'getLeftX should return 0.0 when no controller')
    
    local rightX = controller:getRightX()
    lu.assertIsNumber(rightX, 'getRightX should return a number')
    lu.assertEquals(rightX, 0.0, 'getRightX should return 0.0 when no controller')
    
    local leftY = controller:getLeftY()
    lu.assertIsNumber(leftY, 'getLeftY should return a number')
    lu.assertEquals(leftY, 0.0, 'getLeftY should return 0.0 when no controller')
    
    local rightY = controller:getRightY()
    lu.assertIsNumber(rightY, 'getRightY should return a number')
    lu.assertEquals(rightY, 0.0, 'getRightY should return 0.0 when no controller')
    
    local leftTrigger = controller:getLeftTriggerAxis()
    lu.assertIsNumber(leftTrigger, 'getLeftTriggerAxis should return a number')
    lu.assertEquals(leftTrigger, 0.0, 'getLeftTriggerAxis should return 0.0 when no controller')
    
    local rightTrigger = controller:getRightTriggerAxis()
    lu.assertIsNumber(rightTrigger, 'getRightTriggerAxis should return a number')
    lu.assertEquals(rightTrigger, 0.0, 'getRightTriggerAxis should return 0.0 when no controller')
end

collectgarbage()

-- Test A button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getAButton()
    lu.assertFalse(pressed, 'getAButton should return false when no controller')
    
    local justPressed = controller:getAButtonPressed()
    lu.assertFalse(justPressed, 'getAButtonPressed should return false when no controller')
    
    local justReleased = controller:getAButtonReleased()
    lu.assertFalse(justReleased, 'getAButtonReleased should return false when no controller')
end

collectgarbage()

-- Test B button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getBButton()
    lu.assertFalse(pressed, 'getBButton should return false when no controller')
    
    local justPressed = controller:getBButtonPressed()
    lu.assertFalse(justPressed, 'getBButtonPressed should return false when no controller')
    
    local justReleased = controller:getBButtonReleased()
    lu.assertFalse(justReleased, 'getBButtonReleased should return false when no controller')
end

collectgarbage()

-- Test X button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getXButton()
    lu.assertFalse(pressed, 'getXButton should return false when no controller')
    
    local justPressed = controller:getXButtonPressed()
    lu.assertFalse(justPressed, 'getXButtonPressed should return false when no controller')
    
    local justReleased = controller:getXButtonReleased()
    lu.assertFalse(justReleased, 'getXButtonReleased should return false when no controller')
end

collectgarbage()

-- Test Y button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getYButton()
    lu.assertFalse(pressed, 'getYButton should return false when no controller')
    
    local justPressed = controller:getYButtonPressed()
    lu.assertFalse(justPressed, 'getYButtonPressed should return false when no controller')
    
    local justReleased = controller:getYButtonReleased()
    lu.assertFalse(justReleased, 'getYButtonReleased should return false when no controller')
end

collectgarbage()

-- Test left bumper methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getLeftBumperButton()
    lu.assertFalse(pressed, 'getLeftBumperButton should return false when no controller')
    
    local justPressed = controller:getLeftBumperButtonPressed()
    lu.assertFalse(justPressed, 'getLeftBumperButtonPressed should return false when no controller')
    
    local justReleased = controller:getLeftBumperButtonReleased()
    lu.assertFalse(justReleased, 'getLeftBumperButtonReleased should return false when no controller')
end

collectgarbage()

-- Test right bumper methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getRightBumperButton()
    lu.assertFalse(pressed, 'getRightBumperButton should return false when no controller')
    
    local justPressed = controller:getRightBumperButtonPressed()
    lu.assertFalse(justPressed, 'getRightBumperButtonPressed should return false when no controller')
    
    local justReleased = controller:getRightBumperButtonReleased()
    lu.assertFalse(justReleased, 'getRightBumperButtonReleased should return false when no controller')
end

collectgarbage()

-- Test back button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getBackButton()
    lu.assertFalse(pressed, 'getBackButton should return false when no controller')
    
    local justPressed = controller:getBackButtonPressed()
    lu.assertFalse(justPressed, 'getBackButtonPressed should return false when no controller')
    
    local justReleased = controller:getBackButtonReleased()
    lu.assertFalse(justReleased, 'getBackButtonReleased should return false when no controller')
end

collectgarbage()

-- Test start button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getStartButton()
    lu.assertFalse(pressed, 'getStartButton should return false when no controller')
    
    local justPressed = controller:getStartButtonPressed()
    lu.assertFalse(justPressed, 'getStartButtonPressed should return false when no controller')
    
    local justReleased = controller:getStartButtonReleased()
    lu.assertFalse(justReleased, 'getStartButtonReleased should return false when no controller')
end

collectgarbage()

-- Test left stick button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getLeftStickButton()
    lu.assertFalse(pressed, 'getLeftStickButton should return false when no controller')
    
    local justPressed = controller:getLeftStickButtonPressed()
    lu.assertFalse(justPressed, 'getLeftStickButtonPressed should return false when no controller')
    
    local justReleased = controller:getLeftStickButtonReleased()
    lu.assertFalse(justReleased, 'getLeftStickButtonReleased should return false when no controller')
end

collectgarbage()

-- Test right stick button methods
do
    local controller = XboxController.new(2)
    
    local pressed = controller:getRightStickButton()
    lu.assertFalse(pressed, 'getRightStickButton should return false when no controller')
    
    local justPressed = controller:getRightStickButtonPressed()
    lu.assertFalse(justPressed, 'getRightStickButtonPressed should return false when no controller')
    
    local justReleased = controller:getRightStickButtonReleased()
    lu.assertFalse(justReleased, 'getRightStickButtonReleased should return false when no controller')
end

collectgarbage()

-- Test that controller extends GenericHID
do
    local controller = XboxController.new(3)
    
    -- Should have GenericHID methods
    local port = controller:getPort()
    lu.assertEquals(port, 3, 'XboxController should have getPort() from GenericHID')
    
    local axisCount = controller:getAxisCount()
    lu.assertIsNumber(axisCount, 'XboxController should have getAxisCount() from GenericHID')
    
    local buttonCount = controller:getButtonCount()
    lu.assertIsNumber(buttonCount, 'XboxController should have getButtonCount() from GenericHID')
end

collectgarbage()

print('All XboxController tests passed!')
