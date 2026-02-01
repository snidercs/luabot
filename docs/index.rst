Welcome to LuaBot's Documentation
===================================

LuaBot is a Lua scripting environment for FRC (FIRST Robotics Competition) robots, built on top of WPILib. It enables robot programming using LuaJIT while maintaining full access to WPILib's HAL, command-based framework, and simulation capabilities.

Features
--------

* **Modern Lua Support**: Powered by LuaJIT 2.1 for high-performance scripting
* **Full WPILib Integration**: Access to HAL, command-based framework, and simulation
* **FFI Bindings**: Direct C/C++ interoperability via LuaJIT FFI
* **Cross-Platform**: Supports macOS, Linux, Windows, and roboRIO
* **Object-Oriented**: Class system with inheritance for clean robot code
* **Type Safety**: Lua type annotations for better IDE support

Quick Start
-----------

Getting Started with LuaBot::

    -- Example robot implementation
    local TimedRobot = require('wpi.frc.TimedRobot')
    local XboxController = require('wpi.frc.XboxController')
    local class = require('luabot.class')

    local MyRobot = class(TimedRobot)

    function MyRobot.init(instance)
        instance.controller = XboxController.new(0)
    end

    function MyRobot:robotInit()
        print('Robot initialized!')
    end

    function MyRobot:teleopPeriodic()
        -- Your teleop code here
    end

    return {
        new = function()
            local obj = setmetatable({}, MyRobot)
            MyRobot.init(obj)
            return obj
        end
    }

Technical Stack
---------------

* **Language**: C++20, Lua 5.1 (LuaJIT 2.1)
* **Framework**: WPILib (allwpilib)
* **FFI**: LuaJIT FFI for C/C++ interop
* **Build System**: CMake, Ninja
* **Platforms**: macOS, Linux, Windows, roboRIO

Contents
--------

.. toctree::
   :maxdepth: 2
   :caption: User Guide

   installation
   getting-started
   examples

.. toctree::
   :maxdepth: 2
   :caption: Development

   contributing
   architecture

Indices and tables
==================

* :ref:`genindex`
* :ref:`search`
