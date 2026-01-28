local lu = require('luaunit')
local HAL = require('wpi.hal')

-- Initialize HAL for testing
HAL.initialize(500, 0)

local CommandXboxController = require('wpi.cmd.button.CommandXboxController')
local XboxController = require('wpi.frc.XboxController')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestCommandXboxController = {}

function TestCommandXboxController:setUp()
    CommandScheduler.resetInstance()
    collectgarbage()
end

function TestCommandXboxController:testCreation()
    local controller = CommandXboxController.new(0)
    lu.assertNotNil(controller)
    lu.assertNotNil(controller:getHID())
end

function TestCommandXboxController:testButtonTriggers()
    local controller = CommandXboxController.new(0)
    lu.assertNotNil(controller:a())
    lu.assertNotNil(controller:b())
    lu.assertNotNil(controller:x())
    lu.assertNotNil(controller:y())
    lu.assertNotNil(controller:leftBumper())
    lu.assertNotNil(controller:rightBumper())
    lu.assertNotNil(controller:back())
    lu.assertNotNil(controller:start())
    lu.assertNotNil(controller:leftStick())
    lu.assertNotNil(controller:rightStick())
end

function TestCommandXboxController:testButtonTriggerCaching()
    local controller = CommandXboxController.new(0)
    local trigger1 = controller:a()
    local trigger2 = controller:a()
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandXboxController:testAxisTriggers()
    local controller = CommandXboxController.new(0)
    lu.assertNotNil(controller:leftTrigger())
    lu.assertNotNil(controller:rightTrigger())
end

function TestCommandXboxController:testAxisTriggersWithThreshold()
    local controller = CommandXboxController.new(0)
    lu.assertNotNil(controller:leftTrigger(0.7))
    lu.assertNotNil(controller:rightTrigger(0.8))
end

function TestCommandXboxController:testAxisValueMethods()
    local controller = CommandXboxController.new(0)
    
    local leftX = controller:getLeftX()
    local rightX = controller:getRightX()
    local leftY = controller:getLeftY()
    local rightY = controller:getRightY()
    local leftTrigger = controller:getLeftTriggerAxis()
    local rightTrigger = controller:getRightTriggerAxis()
    
    lu.assertTrue(type(leftX) == 'number')
    lu.assertTrue(type(rightX) == 'number')
    lu.assertTrue(type(leftY) == 'number')
    lu.assertTrue(type(rightY) == 'number')
    lu.assertTrue(type(leftTrigger) == 'number')
    lu.assertTrue(type(rightTrigger) == 'number')
end

function TestCommandXboxController:testInheritsFromCommandGenericHID()
    local controller = CommandXboxController.new(0)
    -- Should have inherited methods
    lu.assertNotNil(controller:button(1))
    lu.assertNotNil(controller:getRawAxis(0))
    lu.assertNotNil(controller:isConnected())
end

os.exit(lu.LuaUnit.run())
