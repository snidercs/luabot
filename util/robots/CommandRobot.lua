---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local TimedRobot = require('wpi.frc.TimedRobot')
local CommandXboxController = require('wpi.cmd.button.CommandXboxController')
local CommandScheduler = require('wpi.cmd.CommandScheduler')
local Subsystem = require('wpi.cmd.Subsystem')
local RunCommand = require('wpi.cmd.RunCommand')
local InstantCommand = require('wpi.cmd.InstantCommand')

---@class DriveSubsystem : Subsystem Example drive subsystem
local DriveSubsystem = class(Subsystem)

function DriveSubsystem:periodic()
    -- Called periodically by the CommandScheduler
end

function DriveSubsystem:simulationPeriodic()
    -- Called periodically during simulation
end

function DriveSubsystem:drive(speed)
    -- Mock drive method
    if math.abs(speed) >= 0.052 then
        print(string.format('Driving at speed: %.2f', speed))
    end
end

function DriveSubsystem.new()
    local self = setmetatable({}, DriveSubsystem)
    Subsystem.init(self)
    self:setName('Drive')
    return self
end

---@class CommandRobot : TimedRobot A command-based robot example
local CommandRobot = class(TimedRobot)

function CommandRobot:robotInit()
    -- Initialize subsystems
    self.driveSubsystem = DriveSubsystem.new()
    
    -- Initialize operator interface
    self.pad = CommandXboxController.new(0)
    
    -- Get the command scheduler instance
    self.scheduler = CommandScheduler.getInstance()
    
    -- Register subsystems
    self.scheduler:registerSubsystem(self.driveSubsystem)
    
    -- Set default commands for subsystems
    local driveCommand = RunCommand.new(
        function()
            -- This runs continuously during teleop
            if self.pad:getHID():isConnected() then
                local speed = self.pad:getHID():getRawAxis(1)
                self.driveSubsystem:drive(speed)
            end
        end,
        self.driveSubsystem
    )
    self.scheduler:setDefaultCommand(self.driveSubsystem, driveCommand)
    
    -- Configure button bindings
    self:configureButtonBindings()
end

function CommandRobot:configureButtonBindings()
    -- X button triggers an instant command when pressed
    self.pad:x():onTrue(
        InstantCommand.new(function()
            print('X button pressed - instant command executed')
        end)
    )
    
    -- A button prints when pressed
    self.pad:a():onTrue(
        InstantCommand.new(function()
            print('A button pressed')
        end)
    )
end

function CommandRobot:robotPeriodic()
    -- Run the scheduler - this is critical for command-based framework
    -- Handles:
    -- - Polling buttons (via EventLoop which now supports deferred scheduling)
    -- - Scheduling newly-requested commands
    -- - Running scheduled commands
    -- - Removing finished/interrupted commands
    -- - Running subsystem periodic() methods
    self.scheduler:run()
end

function CommandRobot:simulationInit()
    print('CommandRobot:simulationInit()')
end

function CommandRobot:autonomousInit()
    print('CommandRobot:autonomousInit()')
    
    -- Create and schedule an autonomous command
    local autoCommand = InstantCommand.new(function()
        print('Autonomous command running')
    end)
    self.scheduler:schedule(autoCommand)
    self.autonomousCommand = autoCommand
end

function CommandRobot:autonomousPeriodic()
    -- CommandScheduler.run() in robotPeriodic handles command execution
end

function CommandRobot:teleopInit()
    print('CommandRobot:teleopInit()')
    
    -- Cancel autonomous command if still running
    if self.autonomousCommand then
        self.scheduler:cancel(self.autonomousCommand)
        self.autonomousCommand = nil
    end
end

function CommandRobot:teleopPeriodic()
    -- CommandScheduler.run() in robotPeriodic handles command execution
end

function CommandRobot:disabledInit()
    print('CommandRobot:disabledInit()')
end

function CommandRobot:disabledPeriodic()
    -- CommandScheduler.run() in robotPeriodic handles command execution
end

function CommandRobot:testInit()
    print('CommandRobot:testInit()')
    -- Cancel all commands in test mode
    self.scheduler:cancelAll()
end

function CommandRobot:testPeriodic()
    -- CommandScheduler.run() in robotPeriodic handles command execution
end

function CommandRobot.new(timeout)
    timeout = tonumber(timeout) or 0.02
    local robot = setmetatable({}, CommandRobot)
    TimedRobot.init(robot, timeout)
    return robot
end

return CommandRobot
