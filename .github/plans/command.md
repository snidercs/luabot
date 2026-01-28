# Command Framework Implementation Plan

## Status

### ✅ Core Framework (Complete)
- [x] `Command` - Base command class with lifecycle methods
- [x] `CommandScheduler` - Singleton scheduler with deferred scheduling (matches Java design)
- [x] `Subsystem` - Base subsystem interface
- [x] `FunctionalCommand` - Command from function callbacks
- [x] `InstantCommand` - Command that runs once
- [x] `RunCommand` - Command that continuously executes a function

### ✅ Button/Trigger System (Complete)
- [x] `Trigger` - Base trigger class with binding methods
- [x] `CommandGenericHID` - Command-based generic HID wrapper
- [x] `CommandJoystick` - Command-based joystick wrapper
- [x] `CommandXboxController` - Command-based Xbox controller wrapper

### 🔄 Command Decorators & Utilities (TODO)

#### High Priority - Common Usage
- [ ] `SequentialCommandGroup` - Runs commands sequentially
- [ ] `ParallelCommandGroup` - Runs commands in parallel
- [ ] `ParallelRaceGroup` - Runs commands in parallel, finishes when first finishes
- [ ] `ParallelDeadlineGroup` - Runs commands in parallel, finishes when deadline finishes
- [ ] `RepeatCommand` - Repeats a command indefinitely
- [ ] `WaitCommand` - Waits for a specified duration
- [ ] `WaitUntilCommand` - Waits until a condition is true
- [ ] `PrintCommand` - Prints a message (useful for debugging)
- [ ] `ConditionalCommand` - Runs one of two commands based on a condition
- [ ] `SelectCommand` - Selects a command from a map based on a selector function

#### Medium Priority - Advanced Features
- [ ] `ProxyCommand` - Schedules another command when this one is scheduled
- [ ] `ScheduleCommand` - Schedules commands at specific times
- [ ] `WrapperCommand` - Wraps another command
- [ ] `DeferredCommand` - Defers command instantiation until scheduled
- [ ] `StartEndCommand` - Command with start and end callbacks
- [ ] `Commands` - Static utility methods for command composition (Java Commands class)

#### Low Priority - Specialized Commands
- [ ] `PIDCommand` - Command that uses a PID controller
- [ ] `PIDSubsystem` - Subsystem that uses a PID controller
- [ ] `ProfiledPIDCommand` - Command using profiled PID controller
- [ ] `ProfiledPIDSubsystem` - Subsystem using profiled PID controller
- [ ] `TrapezoidProfileCommand` - Command using trapezoidal motion profile
- [ ] `TrapezoidProfileSubsystem` - Subsystem using trapezoidal motion profile
- [ ] `RamseteCommand` - RAMSETE trajectory follower for differential drives
- [ ] `MecanumControllerCommand` - Trajectory follower for mecanum drives
- [ ] `SwerveControllerCommand` - Trajectory follower for swerve drives
- [ ] `NotifierCommand` - Command that runs at a fixed rate using Notifier

### 🔄 Button Triggers (TODO)
- [ ] `InternalButton` - Button backed by internal state
- [ ] `JoystickButton` - Button on a joystick
- [ ] `NetworkButton` - Button backed by NetworkTables
- [ ] `POVButton` - POV (D-pad) button on a joystick
- [ ] `RobotModeTriggers` - Triggers for robot mode changes (auto, teleop, etc.)

### 🔄 System Identification (TODO)
- [ ] `SysIdRoutine` - System identification routine for characterizing mechanisms

### 🔄 Subsystem Utilities (TODO)
- [ ] `SubsystemBase` - Convenience base class for subsystems (extends Subsystem)

## Implementation Notes

### Design Principles
- Match Java WPILib implementation as closely as possible
- No workarounds, shortcuts, or extra methods not in Java version
- Reference Java source code for architectural fidelity
- Use deferred scheduling pattern in CommandScheduler (not EventLoop)

### Dependencies Needed
Many commands require additional WPILib components:
- **PID/Profile commands**: Need `wpi.math.controller` (PIDController, ProfiledPIDController)
- **Trajectory commands**: Need `wpi.trajectory` and `wpi.kinematics`
- **Notifier commands**: Need `wpi.Notifier`
- **NetworkButton**: Need NetworkTables bindings

### Testing Strategy
Each implemented command should have:
- Unit test file in `test/wpi/TestCommandName.lua`
- Test registration in `test/CMakeLists.txt`
- Coverage of construction, execution, interruption, and edge cases
- Garbage collection verification

## Priority Order

1. **Command Groups** (Sequential, Parallel, Race, Deadline) - Most commonly used for complex behaviors
2. **Wait Commands** (WaitCommand, WaitUntilCommand) - Essential for timing-based logic
3. **Print/Conditional/Select** - Useful for debugging and logic flow
4. **Button Triggers** - Additional trigger sources beyond Trigger base class
5. **Wrapper/Deferred/Schedule** - Advanced command management
6. **PID/Profile Commands** - After math.controller bindings are complete
7. **Trajectory Commands** - After trajectory/kinematics bindings are complete
8. **Specialized** (SysId, Notifier, SubsystemBase) - As needed

## Example Robot Capabilities

### Current (with implemented commands)
```lua
-- Simple command-based robot with triggers
local driveCommand = RunCommand.new(function() drive() end, driveSubsystem)
controller:a():onTrue(InstantCommand.new(function() shoot() end))
controller:b():whileTrue(RunCommand.new(function() intake() end))
```

### After Command Groups
```lua
-- Multi-step autonomous
local auto = SequentialCommandGroup.new(
    InstantCommand.new(function() resetOdometry() end),
    ParallelDeadlineGroup.new(
        WaitCommand.new(2.0),
        RunCommand.new(function() driveForward() end)
    ),
    InstantCommand.new(function() shoot() end)
)
```

### After PID Commands
```lua
-- Closed-loop control
local armSubsystem = PIDSubsystem.new(pidController, function() return encoder:getPosition() end)
local driveDistance = PIDCommand.new(pidController, function() return odometry:getX() end, targetDistance)
```

### After Trajectory Commands
```lua
-- Path following
local trajectory = TrajectoryGenerator.generateTrajectory(waypoints, config)
local command = RamseteCommand.new(trajectory, odometry, controller, kinematics, driveSubsystem)
```
