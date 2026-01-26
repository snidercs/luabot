---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local TimedRobot = require ('wpi.frc.TimedRobot')
local XboxController = require ('wpi.frc.XboxController')

---@class MockRobot A mock robot to use in testing.
local MockRobot = TimedRobot.derive()

function MockRobot:robotInit()
    self.pad = XboxController.new (0)
end

function MockRobot:simulationInit()
    print("MockRobot:simulationInit()")
end

function MockRobot:autonomousInit()
    print("MockRobot:autonomousInit()")
end

function MockRobot:teleopInit()
    print("MockRobot:teleopInit()")
end

function MockRobot:disabledInit()
    print("MockRobot:disabledInit()")
end

function MockRobot:testInit()
    print("MockRobot:testInit()")
end

local telopRan = false
function MockRobot:teleopPeriodic()
    if not telopRan then
        print("MockRobot:teleopPeriodic()")
        telopRan = true
    else
    end
end

function MockRobot:robotPeriodic()
    local pad = self.pad
    if not pad:isConnected() then return end

    if pad:getXButtonPressed() then
        print('X pressed')
    elseif pad:getXButtonReleased() then
        print('X released')
    end

    local val = pad:getRawAxis(0)
    if math.abs(val) >= 0.052 then print (val) end
end

local function instantiate (timeout)
    timeout = tonumber(timeout) or 0.02
    local robot = TimedRobot.init ({}, timeout)
    setmetatable (robot, { __index = MockRobot })

    -- private member variables are possible in lua with a ctor as a closure.
    local tick = 0
    local initialized = false

    -- functions are first-class values and therefore can be synthesized in a
    -- closure providing read-only access.
    function robot:tick() return tick end
    function robot:initialized() return initialized end

    -- Half speed peridic callback
    -- robot:addPeriodic(function()
    --     tick = tick + 1
    --     if tick >= 200 then 
    --         robot:endCompetition()
    --     end
    -- end, timeout * 2.0)

    return robot
end

return {
    new = instantiate
}
