# CommandXboxController Implementation Plan

## Overview
Implement the command-based button binding system for Xbox controllers. This allows users to bind controller buttons to commands using triggers, enabling event-driven robot control patterns.

## Sources
- **Prompt**: `.github/prompts/commands-api.md`
- **Reference**: `deps/allwpilib/wpilibNewCommands/src/generated/main/java/edu/wpi/first/wpilibj2/command/button/CommandXboxController.java`
- **Base Class**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/CommandGenericHID.java`
- **Trigger**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/Trigger.java`
- **EventLoop**: `deps/allwpilib/wpilibj/src/main/java/edu/wpi/first/wpilibj/event/EventLoop.java`

## Implementation Location
`bindings/wpi/cmd/button/CommandXboxController.lua`

## Dependencies (Must Implement First)

### 1. EventLoop (`bindings/wpi/event/EventLoop.lua`)
Pure Lua implementation of the event loop system:
- **Instance fields**:
  - `_bindings` - Array of bound functions
  - `_running` - Flag to prevent concurrent modification
- **Methods**:
  - `bind(action)` - Add a runnable to execute on poll
  - `poll()` - Execute all bound actions
  - `clear()` - Remove all bindings
- **Error handling**: Throw error if bind/clear called while running

### 2. Trigger (`bindings/wpi/cmd/button/Trigger.lua`)
Pure Lua base class for event-driven command scheduling:
- **Instance fields**:
  - `_condition` - Function that returns boolean (button state)
  - `_loop` - EventLoop instance to poll this trigger
- **Constructor**:
  - `Trigger.new(loop, condition)` - Create trigger with event loop and condition function
  - `Trigger.new(condition)` - Use CommandScheduler's default button loop
- **Binding methods** (schedule commands on state changes):
  - `onTrue(command)` - Schedule when condition goes false→true
  - `onFalse(command)` - Schedule when condition goes true→false
  - `whileTrue(command)` - Schedule on true, cancel on false
  - `whileFalse(command)` - Schedule on false, cancel on true
  - `toggleOnTrue(command)` - Toggle command scheduling on false→true
  - `toggleOnFalse(command)` - Toggle command scheduling on true→false
- **Composition methods**:
  - `and_(trigger)` - Logical AND with another trigger (note: `and_` to avoid Lua keyword)
  - `or_(trigger)` - Logical OR with another trigger
  - `negate()` - Logical NOT
- **Implementation note**: 
  - All binding methods return `self` for chaining
  - Use `addBinding(body)` internal method that tracks previous state
  - Body is called with `(previous, current)` state on each poll

### 3. CommandGenericHID (`bindings/wpi/cmd/button/CommandGenericHID.lua`)
Base class providing trigger factories for any HID device:
- **Instance fields**:
  - `_hid` - Underlying GenericHID/XboxController instance
  - `_buttonCache` - Map of EventLoop → button index → Trigger (for caching)
  - `_axisGreaterThanCache` - Map for axis threshold triggers
  - `_axisLessThanCache` - Map for axis threshold triggers
  - `_axisMagnitudeGreaterThanCache` - Map for axis magnitude triggers
  - `_povCache` - Map for POV angle triggers
- **Methods**:
  - `getHID()` - Return underlying HID object
  - `button(index, loop)` - Create trigger for button press (cached)
  - `pov(pov, angle, loop)` - Create trigger for POV angle
  - `axisGreaterThan(axis, threshold, loop)` - Trigger when axis > threshold
  - `axisLessThan(axis, threshold, loop)` - Trigger when axis < threshold
  - `axisMagnitudeGreaterThan(axis, threshold, loop)` - Trigger when |axis| > threshold
- **Caching behavior**: Each trigger created only once per (loop, button/axis) combination

### 4. CommandScheduler Button Loop Support
Add to existing `CommandScheduler`:
- **Instance field**:
  - `_defaultButtonLoop` - EventLoop instance for default button bindings
- **Methods**:
  - `getDefaultButtonLoop()` - Return the default event loop
- **Integration**:
  - In `run()` method: call `_defaultButtonLoop:poll()` after subsystem periodic calls
  - Initialize `_defaultButtonLoop` in constructor as `EventLoop.new()`

## CommandXboxController Implementation

### Class Structure
Pure Lua class using `luabot.class`, extends `CommandGenericHID`:
```lua
local class = require('luabot.class')
local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')
local XboxController = require('wpi.frc.XboxController')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

local CommandXboxController = class(CommandGenericHID)
```

### Instance Fields
- `_hid` - `XboxController` instance (port provided in constructor)

### Constructor
```lua
function CommandXboxController.init(self, port)
    CommandGenericHID.init(self, port)  -- Call parent constructor
    self._hid = XboxController.new(port)
end
```

### Button Trigger Methods
Each button provides two methods:
1. No EventLoop parameter - uses `CommandScheduler.getInstance():getDefaultButtonLoop()`
2. With EventLoop parameter - uses provided loop

**Buttons to implement** (all return `Trigger` instances):
- `a(loop)` / `a()` - A button (green)
- `b(loop)` / `b()` - B button (red)
- `x(loop)` / `x()` - X button (blue)
- `y(loop)` / `y()` - Y button (yellow)
- `leftBumper(loop)` / `leftBumper()` - Left bumper
- `rightBumper(loop)` / `rightBumper()` - Right bumper
- `back(loop)` / `back()` - Back button (select)
- `start(loop)` / `start()` - Start button
- `leftStick(loop)` / `leftStick()` - Left stick button (pressed)
- `rightStick(loop)` / `rightStick()` - Right stick button (pressed)

**Implementation pattern**:
```lua
function CommandXboxController:a(loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:button(XboxController.Button.kA, loop)
end
```

### Axis Trigger Methods
Trigger when analog axis exceeds threshold:

**Left trigger axis**:
- `leftTrigger(threshold, loop)` - Trigger when left trigger > threshold
- `leftTrigger(threshold)` - Use default loop
- `leftTrigger()` - Use threshold=0.5, default loop

**Right trigger axis**:
- `rightTrigger(threshold, loop)` - Trigger when right trigger > threshold
- `rightTrigger(threshold)` - Use default loop
- `rightTrigger()` - Use threshold=0.5, default loop

**Implementation**:
```lua
function CommandXboxController:leftTrigger(threshold, loop)
    threshold = threshold or 0.5
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    return self:axisGreaterThan(XboxController.Axis.kLeftTrigger, threshold, loop)
end
```

### Axis Value Passthrough Methods
Direct access to underlying XboxController axis values:
- `getLeftX()` - Left stick X axis (-1 to 1, right positive)
- `getRightX()` - Right stick X axis (-1 to 1, right positive)
- `getLeftY()` - Left stick Y axis (-1 to 1, back/up positive)
- `getRightY()` - Right stick Y axis (-1 to 1, back/up positive)
- `getLeftTriggerAxis()` - Left trigger (0 to 1)
- `getRightTriggerAxis()` - Right trigger (0 to 1)

**Implementation**: Delegate to `self._hid` methods

### Override getHID()
```lua
function CommandXboxController:getHID()
    return self._hid
end
```

## File Structure
```
bindings/wpi/
├── event/
│   └── EventLoop.lua            (new - pure Lua)
└── cmd/
    ├── CommandScheduler.lua     (modify - add button loop)
    └── button/
        ├── Trigger.lua          (new - pure Lua)
        ├── CommandGenericHID.lua (new - pure Lua)
        └── CommandXboxController.lua (new - pure Lua)

build/lua/wpi/                   (copied by CMake)
├── event/
│   └── EventLoop.lua
└── cmd/
    ├── CommandScheduler.lua
    └── button/
        ├── Trigger.lua
        ├── CommandGenericHID.lua
        └── CommandXboxController.lua

test/wpi/
├── TestEventLoop.lua            (new)
├── TestTrigger.lua              (new)
└── TestCommandXboxController.lua (new)
```

## Implementation Order
1. **EventLoop** - Simple runnable collection with poll mechanism
2. **Trigger** - State tracking and command binding logic
3. **CommandScheduler button loop** - Add default loop and polling
4. **CommandGenericHID** - Base trigger factories with caching
5. **CommandXboxController** - Xbox-specific button methods

## Testing Strategy

### Unit Tests
- **TestEventLoop.lua**:
  - Test bind/poll/clear
  - Verify concurrent modification errors
  - Test multiple bindings execution order
  
- **TestTrigger.lua**:
  - Test all binding methods (onTrue, whileTrue, etc.)
  - Test state transitions (false→true, true→false)
  - Test composition (and_, or_, negate)
  - Test command scheduling integration
  
- **TestCommandXboxController.lua**:
  - Test button trigger creation
  - Test axis trigger creation with thresholds
  - Test trigger caching (same trigger returned for same button)
  - Test axis value passthrough methods

### Integration Test
Create example robot that demonstrates:
- Button binding: A button → intake command
- Axis trigger: Right trigger > 0.5 → shoot command
- Toggle binding: B button toggles between two states
- Chaining: `controller:a():onTrue(command)` pattern

## Key Design Decisions

### Why Not FFI/C++?
Like the core command framework, this is pure Lua sitting on existing WPILib bindings. The Java implementation doesn't call C++ for trigger logic - it's all event-driven Java code. We do the same in Lua.

### Trigger Caching
CommandGenericHID caches triggers to ensure the same physical button always returns the same Trigger instance. This allows:
- Consistent behavior when binding multiple actions to same button
- Proper state tracking across multiple binding calls

### EventLoop Integration
The CommandScheduler polls its button loop once per iteration, which in turn polls all registered triggers. This is event-driven programming: we're not constantly checking button state in command code, but rather registering callbacks that fire on state changes.

### Method Chaining
All trigger binding methods return `self`, enabling fluent API:
```lua
controller:a():onTrue(intakeCommand):onFalse(stopCommand)
```

## Success Criteria
Implementation is complete when:
- [ ] EventLoop can bind and poll runnables
- [ ] Trigger can track state changes and schedule commands
- [ ] CommandScheduler polls button loop in run()
- [ ] CommandXboxController creates working button triggers
- [ ] Can write robot code: `controller:a():whileTrue(driveCommand)`
- [ ] Unit tests pass for all classes
- [ ] Integration test demonstrates realistic button binding usage

## Usage Example
```lua
local CommandXboxController = require('wpi.cmd.button.CommandXboxController')
local InstantCommand = require('wpi.cmd.InstantCommand')

function MyRobot:robotInit()
    self.controller = CommandXboxController.new(0)
    
    -- Bind A button to intake command
    self.controller:a():whileTrue(self.intakeSubsystem:getDefaultCommand())
    
    -- Bind right trigger to shoot when pressed > 0.7
    self.controller:rightTrigger(0.7):onTrue(
        InstantCommand.new(function() self:shoot() end)
    )
    
    -- Toggle autonomous mode with B button
    self.controller:b():toggleOnTrue(self.autoCommand)
end

function MyRobot:robotPeriodic()
    -- Scheduler automatically polls button loop
    CommandScheduler.getInstance():run()
end
```

