---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local hal = require('wpi.hal')

local Joystick = require('wpi.frc.Joystick')
local DriverStation = require('wpi.frc.DriverStation')
local RobotBase = require('wpi.frc.RobotBase')

hal.initialize(500, 1)
DriverStation.silenceJoystickConnectionWarning(true)
DriverStation.refreshData()

-- Reality Check / No construction
do
    assert(RobotBase.isReal() == false)
    assert(RobotBase.isSimulation() == true)
    local ok, err = pcall(function()
        local _ = RobotBase.new()
    end)
    assert(ok == false and #err > 0)
end

-- Joystick
do
    local j = Joystick.new(0)
    assert(type(j) == 'table', "should be table (pure Lua class)")
    j:setYChannel(2)
    assert(j:getYChannel() == 2, "should be 2")
    j:getX()

    -- Port range validation is now handled by HAL/DriverStation,
    -- not at construction time
    local j2 = Joystick.new(5)  -- Maximum valid port
    assert(j2 ~= nil, "Port 5 should be valid")

    -- Constructor requires port argument
    local res, _ = pcall(function()
        Joystick.new()
    end)
    assert(not res, "default ctor not allowed")
end

do -- no construction
    local IterativeRobotBase = require ('wpi.frc.IterativeRobotBase')
    local ok, err = pcall(function() 
        local _ = IterativeRobotBase.new (20)
    end)
    assert(ok == false)
end

do -- no construction
    local TimedRobot = require ('wpi.frc.TimedRobot')
    local ok, err = pcall(function()
        local _ = TimedRobot.new (20)
    end)
    assert(ok == false)
end

hal.shutdown()
