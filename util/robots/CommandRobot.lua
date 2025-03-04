
local CommandScheduler = require ('frc2.command.CommandScheduler')
local TimedRobot = require ('frc.TimedRobot')
local XboxController = require ('frc.XboxController')

---@class MockRobot A mock robot to use in testing.
local MockRobot = TimedRobot.derive()

function MockRobot:robotInit()
    self.pad = XboxController.new (0)
    self.scheduler = CommandScheduler.getInstance()
end

function MockRobot:simulationInit()
end

function MockRobot:autonomousInit()
end

function MockRobot:teleopInit()
end

function MockRobot:disabledInit()
end

function MockRobot:testInit()
end

function MockRobot:teleopPeriodic()
end

dofile ('util/compat.lua')

function MockRobot:robotPeriodic()
    self.scheduler:run()
end

local function instantiate (timeout)
    timeout = tonumber(timeout) or 0.02
    local robot = TimedRobot.init ({}, timeout)
    setmetatable (robot, { __index = MockRobot })
    return robot
end

return {
    new = instantiate
}
