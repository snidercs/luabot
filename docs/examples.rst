Examples
========

This page contains example robot implementations using LuaBot.

Basic Timed Robot
-----------------

A simple robot that prints messages during different phases:

.. code-block:: lua

    local TimedRobot = require('wpi.frc.TimedRobot')
    local class = require('luabot.class')

    local MyRobot = class(TimedRobot)

    function MyRobot.init(instance)
        instance.autonomousCounter = 0
    end

    function MyRobot:robotInit()
        print('Robot initialized')
    end

    function MyRobot:autonomousPeriodic()
        self.autonomousCounter = self.autonomousCounter + 1
        if self.autonomousCounter % 50 == 0 then
            print('Autonomous:', self.autonomousCounter / 50, 'seconds')
        end
    end

    return { new = function()
        local obj = setmetatable({}, MyRobot)
        MyRobot.init(obj)
        return obj
    end }

Tank Drive Robot
----------------

A differential drive robot with Xbox controller support::

    local TimedRobot = require('wpi.frc.TimedRobot')
    local XboxController = require('wpi.frc.XboxController')
    local class = require('luabot.class')

    local TankDriveRobot = class(TimedRobot)

    function TankDriveRobot.init(instance)
        instance.controller = XboxController.new(0)
        -- Motor controllers would be initialized here
    end

    function TankDriveRobot:robotInit()
        print('Tank drive robot initialized')
    end

    function TankDriveRobot:teleopPeriodic()
        local leftSpeed = self.controller:getLeftY()
        local rightSpeed = self.controller:getRightY()
        
        -- Apply speeds to motors
        -- self.leftMotor:set(leftSpeed)
        -- self.rightMotor:set(rightSpeed)
    end

    return { new = function()
        local obj = setmetatable({}, TankDriveRobot)
        TankDriveRobot.init(obj)
        return obj
    end }

Command-Based Robot
-------------------

Coming soon - examples using the command-based framework.

More Examples
-------------

Additional example robots can be found in the ``util/robots/`` directory of the repository.
