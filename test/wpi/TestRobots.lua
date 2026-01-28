---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local hal = require('wpi.hal')

local Joystick = require('wpi.frc.Joystick')
local DriverStation = require('wpi.frc.DriverStation')
local RobotBase = require('wpi.frc.RobotBase')

hal.initialize(500, 1)
DriverStation.silenceJoystickConnectionWarning(true)
DriverStation.refreshData()

-- Reality Check / Abstract base class
do
    assert(RobotBase.isReal() == false)
    assert(RobotBase.isSimulation() == true)
    -- RobotBase can be constructed but will error if you try to use abstract methods
    local rb = RobotBase.new()
    assert(rb ~= nil, "RobotBase should be constructable")
    local ok, err = pcall(function()
        rb:startCompetition()  -- This should error - abstract method
    end)
    assert(ok == false and #err > 0, "startCompetition should error on abstract base")
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

do -- IterativeRobotBase is constructable
    local IterativeRobotBase = require('wpi.frc.IterativeRobotBase')
    local irb = IterativeRobotBase.new(20)
    assert(irb ~= nil, "IterativeRobotBase should be constructable")
    -- But calling abstract method should error
    local ok, err = pcall(function() 
        irb:startCompetition()
    end)
    assert(ok == false, "startCompetition should error on base class")
end

do -- TimedRobot is constructable
    local TimedRobot = require('wpi.frc.TimedRobot')
    local tr = TimedRobot.new(20)
    assert(tr ~= nil, "TimedRobot should be constructable")
    -- TimedRobot actually implements startCompetition, so it won't error
    -- but we can verify it exists
    assert(type(tr.startCompetition) == 'function', "should have startCompetition")
end

hal.shutdown()
