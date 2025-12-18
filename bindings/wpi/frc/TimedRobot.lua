local ffi = require('ffi')
local C = require('wpi.clib.wpiHal').load(false)

local IterativeRobotBase = require('wpi.frc.IterativeRobotBase')
local RobotBase = require('wpi.frc.RobotBase')
local Timer = require('wpi.frc.Timer')

---@class TimedRobot
local TimedRobot = IterativeRobotBase.derive()

local function FRC_ReportError(format, ...)
    print(format)
end

local function FRC_CheckErrorStatus(status, format)
    if status < 0 then
        error(format)
    elseif status > 0 then
        FRC_ReportError(format)
    end
end

local function Callback(f, p)
    local period = assert(tonumber(p), "Not a number")
    return {
        func = f,
        period = period,
        expirationTime = Timer.getFPGATimestamp()
    }
end

function TimedRobot.addPeriodic(callback, period)
end

local function init(instance, timeout)
    local impl = IterativeRobotBase.init(instance)

    local status = ffi.new('int32_t[1]')
    local period = tonumber(timeout) or 0.02

    -- TODO: not efficient.
    local cbs = {}
    local callbacks = {
        pop = function()
            return table.remove(cbs, #cbs)
        end,
        push = function(c)
            table.insert(cbs, #cbs + 1, c)
        end,
        back = function()
            return cbs[#cbs]
        end
    }

    local notifier = C.HAL_InitializeNotifier(status);
    FRC_CheckErrorStatus(status[0], "InitializeNotifier");
    C.HAL_SetNotifierName(notifier, "TimedRobot", status);

    -- kResourceType_Framework, kFramework_Timed
    C.HAL_Report(22, 4, 0, nil);

    function impl:addPeriodic(f, p)
        callbacks.push(Callback(f, p))
    end

    function impl:startCompetition()
        impl:robotInit()

        if RobotBase.isSimulation() then
            impl:simulationInit()
        end

        -- Tell the DS that the robot is ready to be enabled
        print("\n********** Robot program startup complete **********")
        -- std::puts("\n********** Robot program startup complete **********");
        C.HAL_ObserveUserProgramStarting();

        -- Loop forever, calling the appropriate mode-dependent function
        local cursor = Timer.getFPGATimestamp()
        while true do
            status[0] = 0
            C.HAL_UpdateNotifierAlarm(
                notifier,
                cursor * 1e6,
                status)
            FRC_CheckErrorStatus(status[0], "UpdateNotifierAlarm");

            if status[0] ~= 0 then
                print("status: ", status[0])
                break
            end

            local curTime = C.HAL_WaitForNotifierAlarm(notifier, status)

            if curTime == 0 or status[0] ~= 0 then
                break
            end

            for _, c in ipairs(cbs) do
                if c.expirationTime * 1e6 < curTime then
                    c.func()
                    c.expirationTime = c.expirationTime + c.period
                end
            end

            cursor = cursor + period
        end
    end

    function impl:endCompetition()
        status[0] = 0
        C.HAL_StopNotifier(notifier, status)
    end

    impl:addPeriodic(function() impl:loopFunc() end, period)

    return impl
end

local function derive()
    local T = {}
    for k, v in pairs(TimedRobot) do T[k] = v end
    return T
end

return {
    derive = derive,
    init = init
}
