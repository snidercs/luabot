local lanes = require('lanes')
local hal = require('wpi.hal')
local ffi = require('ffi')
require('frc.RobotBase')

local function run()
    local ffi = require('ffi')
    local ok, hal = pcall(require, 'hal')
    if not ok then
        print(tostring(hal))
        return
    end

    local TimedRobot = require('frc.TimedRobot')

    local function TimedRobotTest(dur, timeout)
        local robot = TimedRobot.init(
            setmetatable({}, { __index = TimedRobot }),
            timeout)

        local duration = tonumber(dur) or 100
        local tick = 0
        local initialized = false
        local teleopCalled = false

        function robot:tick() return tick end

        function robot:initialized() return initialized end

        function robot:duration() return duration end

        function robot:robotInit()
            print("robot:robotInit()")
            initialized = true
        end

        function robot:simulationInit()
            print("robot:simulationInit()")
        end

        function robot:disabledInit()
            print("init disabled")
        end

        function robot:teleopInit()
            print("robot:teleopInit()")
        end

        local telopRan = false
        function robot:teleopPeriodic()
            if not telopRan then
                print("periodic")
                telopRan = true
            else
            end
        end

        function robot:robotPeriodic()
            -- print("robotPeriodic()")
        end

        return robot
    end

    local robot
    local ok, err = pcall(function()
        print("starting robot in thread")
        robot = TimedRobotTest(100 * 2, 0.01)
        local tick = 0

        -- Test super class methods are present.
        -- assert(robot.isSimulation() == true)

        -- Half speed peridic callback
        robot:addPeriodic(function()
            tick = tick + 1
            if tick >= 200 then robot:endCompetition() end
        end, 0.02)

        robot:startCompetition()

        assert(robot:tick() == robot:duration())
        assert(robot:tick() == 100)
        assert(tick == 50, 'tick ~= 50 (actual=' .. tick .. ')')
        assert(not robot:initialized())
    end)

    if not ok then
        io.stdout:write(tostring(err) .. '\n')
        io.stdout:flush()
        robot:endCompetition()
        hal.C.HAL_ExitMain()
    end
end

local ok, CCC = pcall(ffi.load, 'luabot')
if not ok then
    print("error starting bot")
    os.exit(100)
end

CCC.frcRunHalInitialization()
CCC.frcRobotBaseInit()

local t = lanes.gen("*", run)()

if ffi.C.HAL_HasMain() then
    ffi.C.HAL_RunMain()
end

local ok, err = t:join()
if not ok then
    print(tostring(err))
end

hal.shutdown()
