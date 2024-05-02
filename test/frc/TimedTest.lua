local hal = require ('wpi.hal')
local TimedRobot = require ('frc.TimedRobot')

local function TimedRobotTest (dur, timeout)
    local robot = TimedRobot.init (
        setmetatable({}, { __index = TimedRobot }),
        timeout)

    local duration = tonumber(dur) or 100
    local tick = 0

    function robot:tick() return tick end
    function robot:duration() return duration end

    function robot:robotPeriodic()
        if tick >= duration then
            return
        end

        tick = tick + 1

        if tick >= duration then
            robot:endCompetition()
        end
    end

    return robot
end

hal.initialize (500, 0)

do
    local tick = 0
    local robot = TimedRobotTest (100 * 1, 0.01)
    
    -- Test super class methods are present.
    assert(robot.isSimulation() == true)

    -- Half speed peridic callback
    robot:addPeriodic (function()
        tick = tick + 1
    end, 0.02)

    robot:startCompetition()

    assert(robot:tick() == robot:duration())
    assert(robot:tick() == 100)
    assert(tick == 50, 'tick ~= 50 (actual='..tick..')')
end

hal.shutdown()
