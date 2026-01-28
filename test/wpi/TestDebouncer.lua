---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')
local Debouncer = require('wpi.math.filter.Debouncer')

TestDebouncer = {}

-- Mock timer for testing
local mockTime = 0.0

-- Override Timer.getFPGATimestamp for testing
package.loaded['wpi.frc.Timer'] = {
    getFPGATimestamp = function()
        return mockTime
    end
}

function TestDebouncer:setUp()
    -- Reset mock time before each test
    mockTime = 0.0
    -- Force reload to pick up mock
    package.loaded['wpi.math.filter.Debouncer'] = nil
    Debouncer = require('wpi.math.filter.Debouncer')
end

function TestDebouncer:testConstructorRisingDefault()
    local debouncer = Debouncer.new(0.5)
    
    lu.assertNotNil(debouncer)
    lu.assertEquals(debouncer:getDebounceTime(), 0.5)
    lu.assertEquals(debouncer:getDebounceType(), Debouncer.DebounceType.kRising)
    
    collectgarbage()
end

function TestDebouncer:testConstructorWithType()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kFalling)
    
    lu.assertEquals(debouncer:getDebounceTime(), 0.5)
    lu.assertEquals(debouncer:getDebounceType(), Debouncer.DebounceType.kFalling)
    
    collectgarbage()
end

function TestDebouncer:testRisingEdgeDebounce()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kRising)
    
    -- Initial state: false (baseline for kRising)
    lu.assertFalse(debouncer:calculate(false))
    
    -- Input goes high, but not long enough
    mockTime = 0.1
    lu.assertFalse(debouncer:calculate(true))
    
    mockTime = 0.3
    lu.assertFalse(debouncer:calculate(true))
    
    -- After 0.5 seconds, should return true
    mockTime = 0.5
    lu.assertTrue(debouncer:calculate(true))
    
    -- Should stay true
    mockTime = 1.0
    lu.assertTrue(debouncer:calculate(true))
    
    collectgarbage()
end

function TestDebouncer:testFallingEdgeDebounce()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kFalling)
    
    -- Initial state: true (baseline for kFalling)
    lu.assertTrue(debouncer:calculate(true))
    
    -- Input goes low, but not long enough
    mockTime = 0.1
    lu.assertTrue(debouncer:calculate(false))
    
    mockTime = 0.3
    lu.assertTrue(debouncer:calculate(false))
    
    -- After 0.5 seconds, should return false
    mockTime = 0.5
    lu.assertFalse(debouncer:calculate(false))
    
    -- Should stay false
    mockTime = 1.0
    lu.assertFalse(debouncer:calculate(false))
    
    collectgarbage()
end

function TestDebouncer:testBothEdgesDebounce()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kBoth)
    
    -- Initial state: false (baseline for kBoth starts as kFalling=true, but let's start from false)
    mockTime = 0.0
    lu.assertFalse(debouncer:calculate(false))
    
    -- Rising edge: goes high, wait for debounce
    mockTime = 0.1
    lu.assertFalse(debouncer:calculate(true))
    
    mockTime = 0.5
    lu.assertTrue(debouncer:calculate(true))
    
    -- Falling edge: goes low, wait for debounce
    mockTime = 0.6
    lu.assertTrue(debouncer:calculate(false))
    
    mockTime = 1.1
    lu.assertFalse(debouncer:calculate(false))
    
    collectgarbage()
end

function TestDebouncer:testResetOnBaselineReturn()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kRising)
    
    mockTime = 0.0
    debouncer:calculate(false)
    
    -- Start rising edge
    mockTime = 0.3
    lu.assertFalse(debouncer:calculate(true))
    
    -- Return to baseline - should reset timer
    mockTime = 0.4
    lu.assertFalse(debouncer:calculate(false))
    
    -- Try rising edge again - should need full 0.5 seconds from reset
    mockTime = 0.5
    lu.assertFalse(debouncer:calculate(true))
    
    mockTime = 0.9
    lu.assertTrue(debouncer:calculate(true))
    
    collectgarbage()
end

function TestDebouncer:testSetDebounceTime()
    local debouncer = Debouncer.new(0.5)
    
    lu.assertEquals(debouncer:getDebounceTime(), 0.5)
    
    debouncer:setDebounceTime(1.0)
    lu.assertEquals(debouncer:getDebounceTime(), 1.0)
    
    collectgarbage()
end

function TestDebouncer:testSetDebounceType()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kRising)
    
    lu.assertEquals(debouncer:getDebounceType(), Debouncer.DebounceType.kRising)
    
    debouncer:setDebounceType(Debouncer.DebounceType.kFalling)
    lu.assertEquals(debouncer:getDebounceType(), Debouncer.DebounceType.kFalling)
    
    collectgarbage()
end

function TestDebouncer:testDebounceTypeConstants()
    lu.assertEquals(Debouncer.DebounceType.kRising, 0)
    lu.assertEquals(Debouncer.DebounceType.kFalling, 1)
    lu.assertEquals(Debouncer.DebounceType.kBoth, 2)
end

function TestDebouncer:testQuickOscillation()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kRising)
    
    mockTime = 0.0
    debouncer:calculate(false)
    
    -- Rapidly oscillate - should never debounce
    for i = 1, 10 do
        mockTime = i * 0.04  -- Every 40ms
        local input = (i % 2 == 0)
        lu.assertFalse(debouncer:calculate(input))
    end
    
    collectgarbage()
end

function TestDebouncer:testImmediateStableInput()
    local debouncer = Debouncer.new(0.5, Debouncer.DebounceType.kRising)
    
    mockTime = 0.0
    lu.assertFalse(debouncer:calculate(false))
    
    -- Immediate jump to true and stay there
    mockTime = 0.0
    lu.assertFalse(debouncer:calculate(true))
    
    mockTime = 0.5
    lu.assertTrue(debouncer:calculate(true))
    
    collectgarbage()
end

function TestDebouncer:testZeroDebounceTime()
    local debouncer = Debouncer.new(0.0, Debouncer.DebounceType.kRising)
    
    mockTime = 0.0
    lu.assertFalse(debouncer:calculate(false))
    
    -- With zero debounce, should change immediately
    mockTime = 0.0
    lu.assertTrue(debouncer:calculate(true))
    
    collectgarbage()
end

function TestDebouncer:testLongDebounceTime()
    local debouncer = Debouncer.new(5.0, Debouncer.DebounceType.kRising)
    
    mockTime = 0.0
    lu.assertFalse(debouncer:calculate(false))
    
    -- Start rising edge
    mockTime = 1.0
    lu.assertFalse(debouncer:calculate(true))
    
    mockTime = 4.9
    lu.assertFalse(debouncer:calculate(true))
    
    mockTime = 5.0
    lu.assertTrue(debouncer:calculate(true))
    
    collectgarbage()
end

os.exit(lu.LuaUnit.run())
