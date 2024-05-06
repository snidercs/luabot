local hal = require('wpi.hal')

local Joystick = require('frc.Joystick')
local DriverStation = require('frc.DriverStation')
local RobotBase = require('frc.RobotBase')

hal.initialize(500, 1)
DriverStation.silenceJoystickConnectionWarning(true)
DriverStation.refreshData()

-- Reality Check
do
    assert(RobotBase.isReal() == false)
    assert(RobotBase.isSimulation() == true)
    local ok, err = pcall(function()
        local _ = RobotBase()
    end)
    assert(ok == false and #err > 0)
end

-- Joystick
do
    local j = Joystick(0)
    assert(type(j) == 'cdata', "should be cdata")
    j:setYChannel(2)
    assert(j:getYChannel() == 2, "should be 2")
    j:getX()

    local res, _ = pcall(function()
        local _ = Joystick(10)
    end)
    assert(not res, "Port out of range")

    res, _ = pcall(function()
        Joystick()
    end)
    assert(not res, "default ctor not allowed")
end

do
    local IterativeRobotBase = require ('frc.IterativeRobotBase')
    local ok, err = pcall(function() 
        local _ = IterativeRobotBase (20)
    end)
    assert(ok == false)
end

do
    local TimedRobot = require ('frc.TimedRobot')
    local ok, err = pcall(function()
        local _ = TimedRobot (20)
    end)
    assert(ok == false)
end

hal.shutdown()
