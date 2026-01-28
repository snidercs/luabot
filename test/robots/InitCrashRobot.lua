---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local TimedRobot = require('wpi.frc.TimedRobot')
local XboxController = require('wpi.frc.XboxController')

---@class CrashInitRobot : TimedRobot A robot that crashes in robotInit()
local CrashInitRobot = class(TimedRobot)

function CrashInitRobot:robotInit()
    self.pad = XboxController.new (0)
    robot.crash()
end

function CrashInitRobot:simulationInit()
end

function CrashInitRobot:autonomousInit()
    print("CrashInitRobot:autonomousInit()")
end

function CrashInitRobot:teleopInit()
    print("CrashInitRobot:teleopInit()")
end

function CrashInitRobot:disabledInit()
    print("CrashInitRobot:disabledInit()")
end

function CrashInitRobot:testInit()
    print("CrashInitRobot:testInit()")
end

local telopRan = false
function CrashInitRobot:teleopPeriodic()
    if not telopRan then
        print("CrashInitRobot:teleopPeriodic()")
        telopRan = true
    else
    end
end

function CrashInitRobot:robotPeriodic()
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

local function instantiate(timeout)
    timeout = tonumber(timeout) or 0.02
    local robot = setmetatable({}, CrashInitRobot)
    TimedRobot.init(robot, timeout)

    -- private member variables are possible in lua with a ctor as a closure.
    local tick = 0
    local initialized = false

    -- functions are first-class values and therefore can be synthesized in a
    -- closure providing read-only access.
    function robot:tick() return tick end
    function robot:initialized() return initialized end

    return robot
end

return {
    new = instantiate
}
