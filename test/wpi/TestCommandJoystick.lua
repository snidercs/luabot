---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local HAL = require('wpi.hal')

-- Initialize HAL for testing
HAL.initialize(500, 0)

local CommandJoystick = require('wpi.cmd.button.CommandJoystick')
local Joystick = require('wpi.frc.Joystick')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestCommandJoystick = {}

function TestCommandJoystick:setUp()
    CommandScheduler.resetInstance()
    collectgarbage()
end

function TestCommandJoystick:testCreation()
    local joystick = CommandJoystick.new(0)
    lu.assertNotNil(joystick)
    lu.assertNotNil(joystick:getHID())
end

function TestCommandJoystick:testButtonTriggers()
    local joystick = CommandJoystick.new(0)
    lu.assertNotNil(joystick:trigger())
    lu.assertNotNil(joystick:top())
end

function TestCommandJoystick:testButtonTriggerCaching()
    local joystick = CommandJoystick.new(0)
    local trigger1 = joystick:trigger()
    local trigger2 = joystick:trigger()
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandJoystick:testAxisChannelConfiguration()
    local joystick = CommandJoystick.new(0)
    
    -- Test setters and getters
    joystick:setXChannel(1)
    lu.assertEquals(joystick:getXChannel(), 1)
    
    joystick:setYChannel(2)
    lu.assertEquals(joystick:getYChannel(), 2)
    
    joystick:setZChannel(3)
    lu.assertEquals(joystick:getZChannel(), 3)
    
    joystick:setTwistChannel(4)
    lu.assertEquals(joystick:getTwistChannel(), 4)
    
    joystick:setThrottleChannel(5)
    lu.assertEquals(joystick:getThrottleChannel(), 5)
end

function TestCommandJoystick:testAxisValueMethods()
    local joystick = CommandJoystick.new(0)
    
    local x = joystick:getX()
    local y = joystick:getY()
    local z = joystick:getZ()
    local twist = joystick:getTwist()
    local throttle = joystick:getThrottle()
    
    lu.assertTrue(type(x) == 'number')
    lu.assertTrue(type(y) == 'number')
    lu.assertTrue(type(z) == 'number')
    lu.assertTrue(type(twist) == 'number')
    lu.assertTrue(type(throttle) == 'number')
end

function TestCommandJoystick:testPolarCoordinateMethods()
    local joystick = CommandJoystick.new(0)
    
    local magnitude = joystick:getMagnitude()
    local radians = joystick:getDirectionRadians()
    local degrees = joystick:getDirectionDegrees()
    
    lu.assertTrue(type(magnitude) == 'number')
    lu.assertTrue(type(radians) == 'number')
    lu.assertTrue(type(degrees) == 'number')
    
    -- Magnitude should be between 0 and 1
    lu.assertTrue(magnitude >= 0 and magnitude <= 1)
end

function TestCommandJoystick:testInheritsFromCommandGenericHID()
    local joystick = CommandJoystick.new(0)
    -- Should have inherited methods
    lu.assertNotNil(joystick:button(1))
    lu.assertNotNil(joystick:getRawAxis(0))
    lu.assertNotNil(joystick:isConnected())
end

os.exit(lu.LuaUnit.run())
