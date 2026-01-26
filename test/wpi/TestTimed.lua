---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local hal = require('wpi.hal')
local TimedRobot = require('wpi.frc.TimedRobot')

local function TimedRobotTest(dur, timeout)
    local Robot = TimedRobot.derive()
    local robot = TimedRobot.init(
        setmetatable({}, { __index = Robot }),
        timeout)

    local duration = tonumber(dur) or 100
    local tick = 0
    local initialized = false

    function robot:tick() return tick end

    function robot:initialized() return initialized end

    function robot:duration() return duration end

    function robot:robotInit()
        initialized = true
        self:setNetworkTablesFlushEnabled(false)
        self:enableLiveWindowInTest(false)
    end

    function robot:robotPeriodic()
        if tick >= duration then
            return
        end

        tick = tick + 1
        if tick == duration / 2 then
            robot:setNetworkTablesFlushEnabled(true)
            robot:enableLiveWindowInTest(true)
        end

        if tick >= duration then
            robot:endCompetition()
        end
    end

    return robot
end

hal.initialize(500, 0)

do
    local tick = 0
    local robot = assert(TimedRobotTest(100 * 1, 0.01))

    -- Test super class methods are present.
    assert(robot.isSimulation() == true)
    assert(robot:isEnabled() == false)
    assert(robot:isDisabled() == true)
    assert(robot:isTest() == false)
    assert(robot:isTestEnabled() == false)
    assert(robot:isAutonomous() == false)
    assert(robot:isAutonomousEnabled() == false)
    assert(robot:isTeleop() == true)
    assert(robot:isTeleopEnabled() == false)
    assert(robot:isTest() == false)
    assert(robot:isTestEnabled() == false)

    -- Half speed peridic callback
    robot:addPeriodic(function()
        tick = tick + 1
    end, 0.02)

    robot:startCompetition()

    assert(robot:tick() == robot:duration())
    assert(robot:tick() == 100)
    assert(tick == 50, 'tick ~= 50 (actual=' .. tick .. ')')
    assert(robot:initialized())
end

hal.shutdown()
