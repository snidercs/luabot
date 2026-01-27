# CommandJoystick Implementation Plan

## Overview
Implement the command-based button binding system for flight joysticks (e.g., Logitech Extreme 3D Pro, Thrustmaster T.16000M). This allows users to bind joystick buttons to commands using triggers, enabling event-driven robot control patterns with flight-style controllers.

## Sources
- **Prompt**: `.github/prompts/commands-api.md`
- **Reference**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/CommandJoystick.java`
- **Base Class**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/CommandGenericHID.java`
- **Underlying HID**: `deps/allwpilib/wpilibj/src/main/java/edu/wpi/first/wpilibj/Joystick.java`
- **Trigger**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/Trigger.java`
- **EventLoop**: `deps/allwpilib/wpilibj/src/main/java/edu/wpi/first/wpilibj/event/EventLoop.java`

## Implementation Location
`bindings/wpi/cmd/button/CommandJoystick.lua`

## Dependencies (Must Implement First)
Same as CommandXboxController:
1. **EventLoop** - Pure Lua event loop system
2. **Trigger** - Event-driven command scheduling
3. **CommandGenericHID** - Base trigger factories with caching
4. **CommandScheduler button loop support** - Default event loop and polling

See [CommandXboxController.md](CommandXboxController.md) for detailed dependency specifications.

## CommandJoystick Implementation

### Class Structure
Pure Lua class using `luabot.class`, extends `CommandGenericHID`:
```lua
local class = require('luabot.class')
local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')
local Joystick = require('wpi.frc.Joystick')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

local CommandJoystick = class(CommandGenericHID)
```

### Instance Fields
- `_hid` - `Joystick` instance (port provided in constructor)

### Constructor
```lua
function CommandJoystick.init(self, port)
    CommandGenericHID.init(self, port)  -- Call parent constructor
    self._hid = Joystick.new(port)
end
```

### Named Button Trigger Methods
Flight joysticks typically have two named buttons (though they also have numbered buttons 1-N):

**Trigger button** (button 1 - the trigger on the joystick stick):
- `trigger(loop)` - Create trigger for trigger button with specified event loop
- `trigger()` - Use CommandScheduler's default button loop

**Top button** (button 2 - typically the button on top of the stick):
- `top(loop)` - Create trigger for top button with specified event loop
- `top()` - Use default button loop

**Implementation pattern**:
```lua
function CommandJoystick:trigger(loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(Joystick.ButtonType.kTrigger, loop)
end

function CommandJoystick:top(loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(Joystick.ButtonType.kTop, loop)
end
```

**Note**: Users can access other numbered buttons via inherited `button(index)` method from CommandGenericHID.

### Axis Channel Configuration Methods
Flight joysticks allow remapping which physical axis maps to logical axis values:

**Setters** (configure axis mappings):
- `setXChannel(channel)` - Set channel for X axis
- `setYChannel(channel)` - Set channel for Y axis
- `setZChannel(channel)` - Set channel for Z axis (rotation)
- `setTwistChannel(channel)` - Set channel for twist axis
- `setThrottleChannel(channel)` - Set channel for throttle axis

**Getters** (query current axis mappings):
- `getXChannel()` - Get channel mapped to X axis
- `getYChannel()` - Get channel mapped to Y axis
- `getZChannel()` - Get channel mapped to Z axis
- `getTwistChannel()` - Get channel mapped to twist axis
- `getThrottleChannel()` - Get channel mapped to throttle axis

**Implementation**: Delegate to `self._hid` methods
```lua
function CommandJoystick:setXChannel(channel)
    self._hid:setXChannel(channel)
end

function CommandJoystick:getXChannel()
    return self._hid:getXChannel()
end
-- ... similar for Y, Z, Twist, Throttle
```

### Axis Value Passthrough Methods
Direct access to joystick axis values:

**Linear axes**:
- `getX()` - X axis value (-1 to 1, right positive)
- `getY()` - Y axis value (-1 to 1, back/away positive)
- `getZ()` - Z axis value (-1 to 1, clockwise positive for twist/rotation)
- `getTwist()` - Twist axis value (alias for Z on many joysticks)
- `getThrottle()` - Throttle slider value (-1 to 1, typically forward is negative)

**Polar coordinates** (useful for holonomic drive):
- `getMagnitude()` - Magnitude of direction vector from center (0 to 1)
- `getDirectionRadians()` - Direction angle in radians (0 = forward, clockwise positive)
- `getDirectionDegrees()` - Direction angle in degrees (0 = forward, clockwise positive)

**Implementation**: Delegate to `self._hid` methods
```lua
function CommandJoystick:getX()
    return self._hid:getX()
end

function CommandJoystick:getMagnitude()
    return self._hid:getMagnitude()
end
-- ... similar for others
```

### Override getHID()
```lua
function CommandJoystick:getHID()
    return self._hid
end
```

## Key Differences from CommandXboxController

### Simpler Button API
- Only 2 named buttons (`trigger()`, `top()`) vs Xbox's 10+ named buttons
- Users access other buttons via inherited `button(index)` method
- No analog trigger axes like Xbox (L2/R2)

### Axis Configuration
- Flight joysticks have **configurable axis mappings** (not fixed like Xbox)
- Provides setter/getter methods for channel assignment
- Useful for different joystick models with different physical layouts

### Polar Coordinates
- Provides `getMagnitude()` and `getDirection*()` for holonomic drive
- Xbox doesn't expose these (though they could be calculated from X/Y)

### No POV Support
- Most flight joysticks don't have POV hat switches (or use them as additional buttons)
- POV triggers available via inherited `pov()` method from CommandGenericHID if needed

## File Structure
```
bindings/wpi/cmd/button/
├── CommandGenericHID.lua        (dependency)
├── Trigger.lua                  (dependency)
├── CommandXboxController.lua    (sibling implementation)
└── CommandJoystick.lua          (new - pure Lua)

build/lua/wpi/cmd/button/
├── CommandGenericHID.lua
├── Trigger.lua
├── CommandXboxController.lua
└── CommandJoystick.lua          (copied by CMake)

test/wpi/
└── TestCommandJoystick.lua      (new)
```

## Testing Strategy

### Unit Tests (`test/wpi/TestCommandJoystick.lua`)
- **Named button triggers**:
  - Test `trigger()` and `top()` return Trigger instances
  - Verify correct button indices are used
  - Test with custom event loop parameter
  
- **Axis channel configuration**:
  - Test setter/getter methods for all axes
  - Verify changes persist
  - Test with non-default channel assignments
  
- **Axis value passthrough**:
  - Test all linear axis getters (X, Y, Z, Twist, Throttle)
  - Test polar coordinate methods (Magnitude, Direction)
  - Verify values delegate to underlying Joystick
  
- **Trigger caching**:
  - Same trigger returned for same button/loop combination
  - Different loops produce different triggers

### Integration Test
Create example robot demonstrating:
- Trigger button → fire command
- Top button → toggle intake
- Throttle axis → scale drive speed
- Magnitude-based triggering: `joystick:axisGreaterThan(Joystick.AxisType.kThrottle, 0.5)`

## Usage Example
```lua
local CommandJoystick = require('wpi.cmd.button.CommandJoystick')
local InstantCommand = require('wpi.cmd.InstantCommand')

function MyRobot:robotInit()
    self.joystick = CommandJoystick.new(0)
    
    -- Bind trigger button to fire command
    self.joystick:trigger():whileTrue(self.shooterSubsystem:getFireCommand())
    
    -- Bind top button to toggle intake
    self.joystick:top():toggleOnTrue(self.intakeCommand)
    
    -- Bind button 3 (via generic button method) to reset
    self.joystick:button(3):onTrue(
        InstantCommand.new(function() self:resetPosition() end)
    )
    
    -- Configure custom axis mapping for specific joystick model
    self.joystick:setThrottleChannel(2)  -- Throttle is on axis 2
    self.joystick:setTwistChannel(3)     -- Twist is on axis 3
end

function MyRobot:teleopPeriodic()
    -- Use joystick axis values for driving
    local x = self.joystick:getX()
    local y = self.joystick:getY()
    local twist = self.joystick:getTwist()
    local throttle = self.joystick:getThrottle()
    
    self.driveSubsystem:arcadeDrive(y, twist, throttle)
    
    -- Or use polar coordinates for holonomic drive
    local magnitude = self.joystick:getMagnitude()
    local direction = self.joystick:getDirectionRadians()
    self.driveSubsystem:drivePolar(magnitude, direction, twist)
end
```

## Implementation Notes

### Joystick Hardware Variations
Different flight joystick models have different physical layouts:
- **Logitech Extreme 3D Pro**: X/Y on stick, twist on Z, throttle slider
- **Thrustmaster T.16000M**: X/Y on stick, twist on Z, throttle slider, many buttons
- **Generic flight stick**: May have different axis assignments

The axis channel configuration methods (`setXChannel()`, etc.) allow users to adapt to their specific hardware.

### Default Axis Channels
From the Java Joystick class:
- X axis → Channel 0
- Y axis → Channel 1
- Z axis → Channel 2
- Twist axis → Channel 2 (same as Z by default)
- Throttle axis → Channel 3

Users can override these defaults with the setter methods.

### Polar Coordinate System
The polar coordinate methods are useful for:
- **Holonomic drive**: Drive in direction joystick points with magnitude as speed
- **Deadband logic**: Ignore small magnitudes (< threshold)
- **Field-oriented driving**: Use direction for field-relative angles

Coordinate system details (from Java):
- 0 radians/degrees = forward (up on joystick)
- Positive rotation = clockwise
- Straight right = π/2 radians = 90 degrees

## Success Criteria
Implementation is complete when:
- [ ] CommandJoystick extends CommandGenericHID
- [ ] Named button triggers (`trigger()`, `top()`) work correctly
- [ ] Axis channel configuration methods function
- [ ] All axis value passthrough methods return correct values
- [ ] Polar coordinate methods work (`getMagnitude()`, `getDirection*()`)
- [ ] Trigger caching works via inherited behavior
- [ ] Unit tests pass
- [ ] Can write robot code with flight joystick button bindings
- [ ] Example demonstrates practical usage patterns

