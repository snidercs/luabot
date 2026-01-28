local lu = require('luaunit')
local HAL = require('wpi.hal')

-- Initialize HAL for testing
HAL.initialize(500, 0)

local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')
local EventLoop = require('wpi.event.EventLoop')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

TestCommandGenericHID = {}

function TestCommandGenericHID:setUp()
    CommandScheduler.resetInstance()
    collectgarbage()
end

function TestCommandGenericHID:testCreation()
    local hid = CommandGenericHID.new(0)
    lu.assertNotNil(hid)
    lu.assertNotNil(hid:getHID())
end

function TestCommandGenericHID:testButtonTrigger()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:button(1)
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testButtonTriggerCaching()
    local hid = CommandGenericHID.new(0)
    local trigger1 = hid:button(1)
    local trigger2 = hid:button(1)
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testButtonTriggerDifferentLoops()
    local hid = CommandGenericHID.new(0)
    local loop1 = EventLoop.new()
    local loop2 = EventLoop.new()
    
    local trigger1 = hid:button(1, loop1)
    local trigger2 = hid:button(1, loop2)
    lu.assertNotEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testPOVTrigger()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:pov(0, 0)
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testPOVTriggerCaching()
    local hid = CommandGenericHID.new(0)
    local trigger1 = hid:pov(0, 90)
    local trigger2 = hid:pov(0, 90)
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testPOVConvenienceMethods()
    local hid = CommandGenericHID.new(0)
    lu.assertNotNil(hid:povUp())
    lu.assertNotNil(hid:povUpRight())
    lu.assertNotNil(hid:povRight())
    lu.assertNotNil(hid:povDownRight())
    lu.assertNotNil(hid:povDown())
    lu.assertNotNil(hid:povDownLeft())
    lu.assertNotNil(hid:povLeft())
    lu.assertNotNil(hid:povUpLeft())
    lu.assertNotNil(hid:povCenter())
end

function TestCommandGenericHID:testAxisGreaterThan()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:axisGreaterThan(0, 0.5)
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testAxisGreaterThanCaching()
    local hid = CommandGenericHID.new(0)
    local trigger1 = hid:axisGreaterThan(0, 0.5)
    local trigger2 = hid:axisGreaterThan(0, 0.5)
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testAxisLessThan()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:axisLessThan(0, 0.5)
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testAxisLessThanCaching()
    local hid = CommandGenericHID.new(0)
    local trigger1 = hid:axisLessThan(0, 0.5)
    local trigger2 = hid:axisLessThan(0, 0.5)
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testAxisMagnitudeGreaterThan()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:axisMagnitudeGreaterThan(0, 0.5)
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testAxisMagnitudeGreaterThanCaching()
    local hid = CommandGenericHID.new(0)
    local trigger1 = hid:axisMagnitudeGreaterThan(0, 0.5)
    local trigger2 = hid:axisMagnitudeGreaterThan(0, 0.5)
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testDifferentThresholdsNotCached()
    local hid = CommandGenericHID.new(0)
    local trigger1 = hid:axisGreaterThan(0, 0.5)
    local trigger2 = hid:axisGreaterThan(0, 0.7)
    lu.assertNotEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testGetRawAxis()
    local hid = CommandGenericHID.new(0)
    local value = hid:getRawAxis(0)
    lu.assertNotNil(value)
    lu.assertTrue(type(value) == 'number')
end

function TestCommandGenericHID:testIsConnected()
    local hid = CommandGenericHID.new(0)
    local connected = hid:isConnected()
    lu.assertTrue(type(connected) == 'boolean')
end

os.exit(lu.LuaUnit.run())
