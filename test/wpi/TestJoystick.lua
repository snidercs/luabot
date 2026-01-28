---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local hal = require('wpi.hal')
local Joystick = require('wpi.frc.Joystick')

-- Initialize HAL (required for DriverStation/GenericHID)
hal.initialize(500, 0)

-- Test Joystick construction
do
    local joystick = Joystick.new(0)
    lu.assertNotNil(joystick, 'Joystick should be constructable')
    lu.assertEquals(joystick:getPort(), 0, 'Joystick port should be 0')
end

collectgarbage()

-- Test default channel constants
do
    lu.assertEquals(Joystick.kDefaultXChannel, 0, 'kDefaultXChannel should be 0')
    lu.assertEquals(Joystick.kDefaultYChannel, 1, 'kDefaultYChannel should be 1')
    lu.assertEquals(Joystick.kDefaultZChannel, 2, 'kDefaultZChannel should be 2')
    lu.assertEquals(Joystick.kDefaultTwistChannel, 2, 'kDefaultTwistChannel should be 2')
    lu.assertEquals(Joystick.kDefaultThrottleChannel, 3, 'kDefaultThrottleChannel should be 3')
end

collectgarbage()

-- Test AxisType enum values
do
    lu.assertEquals(Joystick.AxisType.kX, 0, 'AxisType.kX should be 0')
    lu.assertEquals(Joystick.AxisType.kY, 1, 'AxisType.kY should be 1')
    lu.assertEquals(Joystick.AxisType.kZ, 2, 'AxisType.kZ should be 2')
    lu.assertEquals(Joystick.AxisType.kTwist, 3, 'AxisType.kTwist should be 3')
    lu.assertEquals(Joystick.AxisType.kThrottle, 4, 'AxisType.kThrottle should be 4')
end

collectgarbage()

-- Test ButtonType enum values
do
    lu.assertEquals(Joystick.ButtonType.kTrigger, 1, 'ButtonType.kTrigger should be 1')
    lu.assertEquals(Joystick.ButtonType.kTop, 2, 'ButtonType.kTop should be 2')
end

collectgarbage()

-- Test default axis channel initialization
do
    local joystick = Joystick.new(1)
    
    lu.assertEquals(joystick:getXChannel(), 0, 'Default X channel should be 0')
    lu.assertEquals(joystick:getYChannel(), 1, 'Default Y channel should be 1')
    lu.assertEquals(joystick:getZChannel(), 2, 'Default Z channel should be 2')
    lu.assertEquals(joystick:getTwistChannel(), 2, 'Default Twist channel should be 2')
    lu.assertEquals(joystick:getThrottleChannel(), 3, 'Default Throttle channel should be 3')
end

collectgarbage()

-- Test axis channel setters and getters
do
    local joystick = Joystick.new(1)
    
    joystick:setXChannel(5)
    lu.assertEquals(joystick:getXChannel(), 5, 'setXChannel/getXChannel should work')
    
    joystick:setYChannel(4)
    lu.assertEquals(joystick:getYChannel(), 4, 'setYChannel/getYChannel should work')
    
    joystick:setZChannel(3)
    lu.assertEquals(joystick:getZChannel(), 3, 'setZChannel/getZChannel should work')
    
    joystick:setTwistChannel(2)
    lu.assertEquals(joystick:getTwistChannel(), 2, 'setTwistChannel/getTwistChannel should work')
    
    joystick:setThrottleChannel(1)
    lu.assertEquals(joystick:getThrottleChannel(), 1, 'setThrottleChannel/getThrottleChannel should work')
end

collectgarbage()

-- Test axis value methods return numbers when no joystick connected
do
    local joystick = Joystick.new(2)
    
    local x = joystick:getX()
    lu.assertIsNumber(x, 'getX should return a number')
    lu.assertEquals(x, 0.0, 'getX should return 0.0 when no joystick')
    
    local y = joystick:getY()
    lu.assertIsNumber(y, 'getY should return a number')
    lu.assertEquals(y, 0.0, 'getY should return 0.0 when no joystick')
    
    local z = joystick:getZ()
    lu.assertIsNumber(z, 'getZ should return a number')
    lu.assertEquals(z, 0.0, 'getZ should return 0.0 when no joystick')
    
    local twist = joystick:getTwist()
    lu.assertIsNumber(twist, 'getTwist should return a number')
    lu.assertEquals(twist, 0.0, 'getTwist should return 0.0 when no joystick')
    
    local throttle = joystick:getThrottle()
    lu.assertIsNumber(throttle, 'getThrottle should return a number')
    lu.assertEquals(throttle, 0.0, 'getThrottle should return 0.0 when no joystick')
end

collectgarbage()

-- Test trigger button methods
do
    local joystick = Joystick.new(3)
    
    local pressed = joystick:getTrigger()
    lu.assertFalse(pressed, 'getTrigger should return false when no joystick')
    
    local justPressed = joystick:getTriggerPressed()
    lu.assertFalse(justPressed, 'getTriggerPressed should return false when no joystick')
    
    local justReleased = joystick:getTriggerReleased()
    lu.assertFalse(justReleased, 'getTriggerReleased should return false when no joystick')
end

collectgarbage()

-- Test top button methods
do
    local joystick = Joystick.new(3)
    
    local pressed = joystick:getTop()
    lu.assertFalse(pressed, 'getTop should return false when no joystick')
    
    local justPressed = joystick:getTopPressed()
    lu.assertFalse(justPressed, 'getTopPressed should return false when no joystick')
    
    local justReleased = joystick:getTopReleased()
    lu.assertFalse(justReleased, 'getTopReleased should return false when no joystick')
end

collectgarbage()

-- Test getMagnitude returns 0 when no joystick
do
    local joystick = Joystick.new(4)
    
    local magnitude = joystick:getMagnitude()
    lu.assertIsNumber(magnitude, 'getMagnitude should return a number')
    lu.assertEquals(magnitude, 0.0, 'getMagnitude should return 0.0 when no joystick')
end

collectgarbage()

-- Test getMagnitude calculation
do
    -- We can't set joystick values without simulation, but we can test the math
    -- by checking that magnitude is sqrt(x^2 + y^2)
    -- When no joystick: x=0, y=0, so magnitude should be 0
    local joystick = Joystick.new(4)
    local mag = joystick:getMagnitude()
    local x = joystick:getX()
    local y = joystick:getY()
    local expectedMag = math.sqrt(x*x + y*y)
    lu.assertAlmostEquals(mag, expectedMag, 0.001, 'getMagnitude should equal sqrt(x^2 + y^2)')
end

collectgarbage()

-- Test getDirectionRadians returns a number
do
    local joystick = Joystick.new(4)
    
    local direction = joystick:getDirectionRadians()
    lu.assertIsNumber(direction, 'getDirectionRadians should return a number')
end

collectgarbage()

-- Test getDirectionDegrees returns a number
do
    local joystick = Joystick.new(4)
    
    local direction = joystick:getDirectionDegrees()
    lu.assertIsNumber(direction, 'getDirectionDegrees should return a number')
end

collectgarbage()

-- Test direction conversion from radians to degrees
do
    local joystick = Joystick.new(4)
    
    local radians = joystick:getDirectionRadians()
    local degrees = joystick:getDirectionDegrees()
    
    -- Verify conversion: degrees should equal radians * 180/pi
    local expectedDegrees = math.deg(radians)
    lu.assertAlmostEquals(degrees, expectedDegrees, 0.001, 
        'getDirectionDegrees should equal math.deg(getDirectionRadians())')
end

collectgarbage()

-- Test that joystick extends GenericHID
do
    local joystick = Joystick.new(5)
    
    -- Should have GenericHID methods
    local port = joystick:getPort()
    lu.assertEquals(port, 5, 'Joystick should have getPort() from GenericHID')
    
    local axisCount = joystick:getAxisCount()
    lu.assertIsNumber(axisCount, 'Joystick should have getAxisCount() from GenericHID')
    
    local buttonCount = joystick:getButtonCount()
    lu.assertIsNumber(buttonCount, 'Joystick should have getButtonCount() from GenericHID')
    
    local pov = joystick:getPOV()
    lu.assertIsNumber(pov, 'Joystick should have getPOV() from GenericHID')
end

collectgarbage()

-- Test that axis channels are independent per instance
do
    local joy1 = Joystick.new(1)
    local joy2 = Joystick.new(2)
    
    joy1:setXChannel(10)
    joy2:setXChannel(20)
    
    lu.assertEquals(joy1:getXChannel(), 10, 'joy1 X channel should be 10')
    lu.assertEquals(joy2:getXChannel(), 20, 'joy2 X channel should be 20')
end

collectgarbage()

-- Test axis channel configuration affects axis reading
-- (Can't fully test without simulation, but we can verify the channels are used)
do
    local joystick = Joystick.new(3)
    
    -- Set custom channels
    joystick:setXChannel(4)
    joystick:setYChannel(3)
    
    -- Verify channels are set
    lu.assertEquals(joystick:getXChannel(), 4, 'Custom X channel should be 4')
    lu.assertEquals(joystick:getYChannel(), 3, 'Custom Y channel should be 3')
    
    -- Calling getX/getY should use the custom channels
    -- (will return 0.0 since no joystick, but at least it doesn't crash)
    local x = joystick:getX()
    local y = joystick:getY()
    lu.assertIsNumber(x, 'getX should work with custom channel')
    lu.assertIsNumber(y, 'getY should work with custom channel')
end

collectgarbage()

print('All Joystick tests passed!')
