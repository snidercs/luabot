---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local ffi = require('ffi')
local ntcore = require('wpi.clib.ntcore')
local wpiHal = require('wpi.clib.wpiHal')

local DriverStation = require('wpi.frc.DriverStation')
local LiveWindow = require('wpi.frc.livewindow.LiveWindow')
local RobotBase = require('wpi.frc.RobotBase')
local Shuffleboard = require('wpi.frc.shuffleboard.Shuffleboard')
local SmartDashboard = require('wpi.frc.smartdashboard.SmartDashboard')
local Watchdog = require('wpi.frc.Watchdog')

local kDefaultPeriod = 0.02 -- 20ms

local kNone = 0
local kDisabled = 1
local kAutonomous = 2
local kTeleop = 3
local kTest = 4

local isSimulation = RobotBase.isSimulation()

---
---@class IterativeRobotBase
local IterativeRobotBase = RobotBase.derive()

function IterativeRobotBase:robotInit() end

function IterativeRobotBase:driverStationConnected() end

function IterativeRobotBase:simulationInit() end

function IterativeRobotBase:disabledInit() end

function IterativeRobotBase:autonomousInit() end

function IterativeRobotBase:teleopInit() end

function IterativeRobotBase:testInit() end

function IterativeRobotBase:robotPeriodic() end

function IterativeRobotBase:simulationPeriodic() end

function IterativeRobotBase:disabledPeriodic() end

function IterativeRobotBase:autonomousPeriodic() end

function IterativeRobotBase:teleopPeriodic() end

function IterativeRobotBase:testPeriodic() end

function IterativeRobotBase:disabledExit() end

function IterativeRobotBase:autonomousExit() end

function IterativeRobotBase:teleopExit() end

function IterativeRobotBase:testExit() end

function IterativeRobotBase:setNetworkTablesFlushEnabled(enabled)
end

function IterativeRobotBase:enableLiveWindowInTest(testLW)
end

function IterativeRobotBase:isLiveWindowEnabledInTest()
end

function IterativeRobotBase:getPeriod()
end

---Perform one iteration.
function IterativeRobotBase:loopFunc()
end

local HC = wpiHal.load()
local NC = ntcore.load()

---@return table
local function init(obj, seconds)
    local impl = RobotBase.init(obj)

    local lwEnabledInTest = false
    local ntFlushEnabled = false
    local calledDsConnected = false
    local lastMode = 0
    local word = ffi.new('HAL_ControlWord')
    local period = tonumber(seconds) or kDefaultPeriod
    local watchdog = Watchdog.new(period)

    function impl:getPeriod() return period end

    function impl:setNetworkTablesFlushEnabled(enabled)
        ntFlushEnabled = enabled and true or false
    end

    local hasReportedLWTest = false
    function impl:enableLiveWindowInTest(testLW)
        testLW = testLW and true or false

        if impl:isTestEnabled() then
            error("Can't configure test mode while in test mode!")
        end

        if not hasReportedLWTest and testLW then
            -- HC.HAL_Report(HALUsageReporting::kResourceType_SmartDashboard,
            --               HALUsageReporting::kSmartDashboard_LiveWindow)
            HC.HAL_Report(43, 2, 0, nil)
            hasReportedLWTest = true;
        end

        lwEnabledInTest = testLW
    end

    function impl:isLiveWindowEnabledInTest() return lwEnabledInTest end

    function impl:loopFunc()
        DriverStation.refreshData()
        watchdog:reset()

        HC.HAL_GetControlWord(word)

        local mode = kNone
        if not (word.enabled == 1 and word.dsAttached == 1) then
            mode = kDisabled;
        elseif word.autonomous == 1 then
            mode = kAutonomous
        elseif not (word.autonomous == 1 or word.test == 1) then
            mode = kTeleop
        elseif word.test == 1 then
            mode = kTest
        end

        if not calledDsConnected and word.dsAttached == 1 then
            calledDsConnected = true
            self:driverStationConnected();
        end

        -- If mode changed, call mode exit and entry functions
        if lastMode ~= mode then
            if lastMode == kDisabled then
                self:disabledExit()
            elseif lastMode == kAutonomous then
                self:autonomousExit()
            elseif lastMode == kTeleop then
                self:teleopExit()
            elseif lastMode == kTest then
                if lwEnabledInTest then
                    LiveWindow.setEnabled(false)
                    Shuffleboard.disableActuatorWidgets()
                end
                self:testExit()
            end

            --  Call current mode's entry function
            if mode == kDisabled then
                self:disabledInit()
                watchdog:addEpoch("DisabledInit()");
            elseif mode == kAutonomous then
                self:autonomousInit()
                watchdog:addEpoch("AutonomousInit()");
            elseif mode == kTeleop then
                self:teleopInit()
                watchdog:addEpoch("TeleopInit()")
            elseif mode == kTest then
                if lwEnabledInTest then
                    LiveWindow.setEnabled(true)
                end
                self:testInit()
            end

            lastMode = mode
        end

        -- Call the appropriate function depending upon the current robot mode
        if (mode == kDisabled) then
            HC.HAL_ObserveUserProgramDisabled()
            self:disabledPeriodic()
            watchdog:addEpoch("DisabledPeriodic()")
        elseif mode == kAutonomous then
            HC.HAL_ObserveUserProgramAutonomous()
            self:autonomousPeriodic()
            watchdog:addEpoch("AutonmousPeriodic()")
        elseif mode == kTeleop then
            HC.HAL_ObserveUserProgramTeleop()
            self:teleopPeriodic()
            watchdog:addEpoch("TeleopPeriodic()")
        elseif mode == kTest then
            HC.HAL_ObserveUserProgramTest()
            self:testPeriodic()
            watchdog:addEpoch("TestPeriodic()")
        end

        self:robotPeriodic()
        watchdog:addEpoch("RobotPeriodic()")

        SmartDashboard.updateValues()

        watchdog:addEpoch("SmartDashboard.updateValues()")
        LiveWindow.updateValues()
        watchdog:addEpoch("LiveWindow.updateValues()")
        Shuffleboard.update()
        watchdog:addEpoch("Shuffleboard.update()")

        if isSimulation then
            HC.HAL_SimPeriodicBefore()
            self:simulationPeriodic()
            HC.HAL_SimPeriodicAfter()
            watchdog:addEpoch("simulationPeriodic()")
        end

        watchdog:disable()

        -- Flush NetworkTables
        if ntFlushEnabled then
            NC.NT_FlushLocal(NC.NT_GetDefaultInstance())
        end

        -- Warn on loop time overruns
        if watchdog:isExpired() then
            watchdog:printEpochs()
        end
    end

    return impl
end

---Derive this robot type.
---@return table
local function derive()
    local T = {}
    for k, v in pairs(IterativeRobotBase) do T[k] = v end
    return T
end

return {
    init = init,
    derive = derive
}
