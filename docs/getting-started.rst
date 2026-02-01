Getting Started
===============

Creating Your First Robot
--------------------------

LuaBot robots are written as Lua modules that extend the ``TimedRobot`` base class.

Basic Robot Structure
~~~~~~~~~~~~~~~~~~~~~

Create a file named ``robot.lua``:

.. code-block:: lua

    local TimedRobot = require('wpi.frc.TimedRobot')
    local class = require('luabot.class')

    local MyRobot = class(TimedRobot)

    function MyRobot.init(instance)
        -- Initialize your robot here
    end

    function MyRobot.new()
        local obj = setmetatable({}, MyRobot)
        MyRobot.init(obj)
        return obj
    end

    function MyRobot:robotInit()
        print('Robot initialized!')
    end

    function MyRobot:autonomousInit()
        print('Autonomous mode started')
    end

    function MyRobot:autonomousPeriodic()
        -- Autonomous periodic code
    end

    function MyRobot:teleopInit()
        print('Teleop mode started')
    end

    function MyRobot:teleopPeriodic()
        -- Teleop periodic code
    end

    return MyRobot

Running Your Robot
------------------

To run your robot in simulation::

    luabot path/to/robot.lua

Using Controllers
-----------------

Example with an Xbox controller::

    local XboxController = require('wpi.frc.XboxController')

    function MyRobot.init(instance)
        instance.controller = XboxController.new(0)
    end

    function MyRobot:teleopPeriodic()
        local leftY = self.controller:getLeftY()
        local rightY = self.controller:getRightY()
        -- Use joystick values to control motors
    end

Next Steps
----------

* See :doc:`examples` for more complete robot examples
* Explore the API reference for available WPILib modules
