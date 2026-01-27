# CommandGenericHID Implementation Plan

## Overview
Implement the CommandGenericHID base class, which provides trigger factory methods for any HID (Human Interface Device) controller. This is the foundation for controller-specific implementations like CommandXboxController and CommandJoystick, providing button, axis, and POV trigger creation with caching.

## Sources
- **Prompt**: `.github/prompts/commands-api.md`
- **Reference**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/CommandGenericHID.java`
- **Underlying HID**: `deps/allwpilib/wpilibj/src/main/java/edu/wpi/first/wpilibj/GenericHID.java`
- **Trigger**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/Trigger.java`
- **EventLoop**: `deps/allwpilib/wpilibj/src/main/java/edu/wpi/first/wpilibj/event/EventLoop.java`

## Implementation Location
`bindings/wpi/cmd/button/CommandGenericHID.lua`

## Architecture Context
CommandGenericHID sits between Trigger and controller-specific implementations, providing trigger factories:

```
EventLoop (polling)
    ↓
Trigger (state tracking)
    ↓
CommandGenericHID (trigger factories with caching)
    ↓
CommandXboxController / CommandJoystick (named button methods)
```

**Provides to**:
- `CommandXboxController` - Extends this for Xbox-specific buttons (A, B, triggers, etc.)
- `CommandJoystick` - Extends this for flight stick buttons (trigger, top)
- User code - Can be used directly for generic controllers

## Dependencies

### Required Before Implementation
1. **EventLoop** ([EventLoop.md](EventLoop.md)) - Polling infrastructure
2. **Trigger** ([Trigger.md](Trigger.md)) - State tracking and command binding
3. **CommandScheduler** ([../prompts/commands-api.md](../prompts/commands-api.md)) - Default button loop
4. **GenericHID** (existing) - Underlying HID wrapper (already in `wpi.frc.GenericHID`)

## CommandGenericHID Implementation

### Class Structure
Pure Lua class using `luabot.class`:
```lua
local class = require('luabot.class')
local GenericHID = require('wpi.frc.GenericHID')
local Trigger = require('wpi.cmd.button.Trigger')
local CommandScheduler = require('wpi.cmd.CommandScheduler')

local CommandGenericHID = class()
```

### Instance Fields
- `_hid` - Underlying `GenericHID` instance
- `_buttonCache` - Map of EventLoop → button index → Trigger
- `_axisLessThanCache` - Map of EventLoop → (axis, threshold) → Trigger
- `_axisGreaterThanCache` - Map of EventLoop → (axis, threshold) → Trigger
- `_axisMagnitudeGreaterThanCache` - Map of EventLoop → (axis, threshold) → Trigger
- `_povCache` - Map of EventLoop → pov key → Trigger

**Cache structure**: All caches are nested tables. Outer key is EventLoop instance, inner key depends on trigger type (button index, axis+threshold pair, or POV key).

### Constructor
```lua
function CommandGenericHID.init(self, port)
    self._hid = GenericHID.new(port)
    self._buttonCache = {}
    self._axisLessThanCache = {}
    self._axisGreaterThanCache = {}
    self._axisMagnitudeGreaterThanCache = {}
    self._povCache = {}
end

function CommandGenericHID.new(port)
    local instance = setmetatable({}, CommandGenericHID)
    CommandGenericHID.init(instance, port)
    return instance
end
```

### Core Methods

#### getHID()
Return the underlying GenericHID instance.

**Implementation**:
```lua
function CommandGenericHID:getHID()
    return self._hid
end
```

**Use case**: Subclasses override this to return more specific HID type (XboxController, Joystick).

### Button Trigger Methods

#### button(button, loop)
Create trigger for button press with specified event loop.

**Parameters**:
- `button` - Button index (1-based in Lua, or use button constants)
- `loop` - EventLoop instance (optional, defaults to scheduler's button loop)

**Returns**: Trigger that is true when button is pressed

**Caching**: Returns same Trigger instance for same (button, loop) pair

**Implementation**:
```lua
function CommandGenericHID:button(button, loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    -- Get or create cache for this loop
    if not self._buttonCache[loop] then
        self._buttonCache[loop] = {}
    end
    
    -- Get or create trigger for this button
    if not self._buttonCache[loop][button] then
        self._buttonCache[loop][button] = Trigger.new(loop, function()
            return self._hid:getRawButton(button)
        end)
    end
    
    return self._buttonCache[loop][button]
end
```

### POV (Hat Switch) Trigger Methods

#### pov(pov, angle, loop)
Create trigger for POV at specific angle.

**Parameters**:
- `pov` - POV index (0 for primary POV)
- `angle` - POV angle in degrees (0=up, 90=right, 180=down, 270=left, -1=center/not pressed)
- `loop` - EventLoop instance (optional)

**Returns**: Trigger that is true when POV is at specified angle

**Caching**: Uses composite key `pov * 3600 + angle` (angle can be -1, so multiply by 3600 not 360)

**Implementation**:
```lua
function CommandGenericHID:pov(pov, angle, loop)
    pov = pov or 0
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    if not self._povCache[loop] then
        self._povCache[loop] = {}
    end
    
    -- Create composite key (angle can be -1, so use 3600 instead of 360)
    local key = pov * 3600 + angle
    
    if not self._povCache[loop][key] then
        self._povCache[loop][key] = Trigger.new(loop, function()
            return self._hid:getPOV(pov) == angle
        end)
    end
    
    return self._povCache[loop][key]
end
```

#### Convenience POV Methods
These all use POV 0 with default loop:

```lua
function CommandGenericHID:povUp()
    return self:pov(0, 0)
end

function CommandGenericHID:povUpRight()
    return self:pov(0, 45)
end

function CommandGenericHID:povRight()
    return self:pov(0, 90)
end

function CommandGenericHID:povDownRight()
    return self:pov(0, 135)
end

function CommandGenericHID:povDown()
    return self:pov(0, 180)
end

function CommandGenericHID:povDownLeft()
    return self:pov(0, 225)
end

function CommandGenericHID:povLeft()
    return self:pov(0, 270)
end

function CommandGenericHID:povUpLeft()
    return self:pov(0, 315)
end

function CommandGenericHID:povCenter()
    return self:pov(0, -1)
end
```

### Axis Trigger Methods

#### axisLessThan(axis, threshold, loop)
Create trigger that is true when axis value < threshold.

**Parameters**:
- `axis` - Axis index (0-based)
- `threshold` - Value below which trigger is true
- `loop` - EventLoop instance (optional)

**Returns**: Trigger for axis < threshold

**Caching**: Key is table `{axis, threshold}` (need to handle table key properly)

**Implementation**:
```lua
function CommandGenericHID:axisLessThan(axis, threshold, loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    if not self._axisLessThanCache[loop] then
        self._axisLessThanCache[loop] = {}
    end
    
    -- Create string key for axis+threshold pair
    local key = string.format("%d:%.6f", axis, threshold)
    
    if not self._axisLessThanCache[loop][key] then
        self._axisLessThanCache[loop][key] = Trigger.new(loop, function()
            return self:getRawAxis(axis) < threshold
        end)
    end
    
    return self._axisLessThanCache[loop][key]
end
```

#### axisGreaterThan(axis, threshold, loop)
Create trigger that is true when axis value > threshold.

**Implementation**:
```lua
function CommandGenericHID:axisGreaterThan(axis, threshold, loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    if not self._axisGreaterThanCache[loop] then
        self._axisGreaterThanCache[loop] = {}
    end
    
    local key = string.format("%d:%.6f", axis, threshold)
    
    if not self._axisGreaterThanCache[loop][key] then
        self._axisGreaterThanCache[loop][key] = Trigger.new(loop, function()
            return self:getRawAxis(axis) > threshold
        end)
    end
    
    return self._axisGreaterThanCache[loop][key]
end
```

#### axisMagnitudeGreaterThan(axis, threshold, loop)
Create trigger that is true when |axis value| > threshold.

**Use case**: Detect movement in either direction (useful for deadbands)

**Implementation**:
```lua
function CommandGenericHID:axisMagnitudeGreaterThan(axis, threshold, loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    if not self._axisMagnitudeGreaterThanCache[loop] then
        self._axisMagnitudeGreaterThanCache[loop] = {}
    end
    
    local key = string.format("%d:%.6f", axis, threshold)
    
    if not self._axisMagnitudeGreaterThanCache[loop][key] then
        self._axisMagnitudeGreaterThanCache[loop][key] = Trigger.new(loop, function()
            return math.abs(self:getRawAxis(axis)) > threshold
        end)
    end
    
    return self._axisMagnitudeGreaterThanCache[loop][key]
end
```

### Utility Methods

#### getRawAxis(axis)
Get current axis value.

**Parameters**:
- `axis` - Axis index (0-based)

**Returns**: Axis value (typically -1.0 to 1.0)

**Implementation**:
```lua
function CommandGenericHID:getRawAxis(axis)
    return self._hid:getRawAxis(axis)
end
```

#### setRumble(type, value)
Set controller rumble/vibration.

**Parameters**:
- `type` - RumbleType (kLeftRumble or kRightRumble)
- `value` - Rumble intensity (0.0 to 1.0)

**Implementation**:
```lua
function CommandGenericHID:setRumble(type, value)
    self._hid:setRumble(type, value)
end
```

#### isConnected()
Check if controller is connected.

**Returns**: Boolean indicating connection status

**Implementation**:
```lua
function CommandGenericHID:isConnected()
    return self._hid:isConnected()
end
```

## Key Design Decisions

### Why Pure Lua?
CommandGenericHID is pure trigger factory logic with no HAL dependencies beyond the existing GenericHID binding. Like the Java version, it's just plumbing between HID state and triggers.

### Trigger Caching Strategy
**Why cache?**
- Performance: Don't recreate trigger objects on every call
- Consistency: Same physical button always returns same Trigger instance
- State preservation: Each trigger maintains its own previous state for edge detection

**Cache structure**:
- Outer key: EventLoop instance (different loops need different triggers)
- Inner key: Button/axis/POV identifier
- For axis triggers: Use string key `"axis:threshold"` to handle float thresholds

### POV Key Calculation
Java uses `pov * 3600 + angle` to create unique integer key:
- Allows angle = -1 (center/not pressed)
- POV 0, angle 0 → key 0
- POV 0, angle -1 → key -1
- POV 1, angle 90 → key 3690

Lua can use the same formula for consistency.

### Axis Threshold Keys
Float thresholds need special handling for cache keys:
- Can't use table as key directly (reference equality issues)
- Use string formatting: `string.format("%d:%.6f", axis, threshold)`
- Precision: 6 decimal places sufficient for joystick values

### Method Overloading Pattern
Java has overloads like `button(int)` and `button(int, EventLoop)`. Lua handles this with optional parameters and default values:
```lua
loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
```

## File Structure
```
bindings/wpi/cmd/button/
├── Trigger.lua                  (dependency)
├── CommandGenericHID.lua        (new - pure Lua)
├── CommandXboxController.lua    (extends this)
└── CommandJoystick.lua          (extends this)

build/lua/wpi/cmd/button/
├── Trigger.lua
├── CommandGenericHID.lua        (copied by CMake)
├── CommandXboxController.lua
└── CommandJoystick.lua

test/wpi/
└── TestCommandGenericHID.lua    (new)
```

## Testing Strategy

### Unit Tests (`test/wpi/TestCommandGenericHID.lua`)

#### Button Trigger Tests
```lua
function TestCommandGenericHID:testButton()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:button(1)
    
    lu.assertNotNil(trigger)
    lu.assertTrue(trigger._condition ~= nil)
end

function TestCommandGenericHID:testButtonCaching()
    local hid = CommandGenericHID.new(0)
    local loop = EventLoop.new()
    
    local trigger1 = hid:button(1, loop)
    local trigger2 = hid:button(1, loop)
    
    -- Same trigger instance returned
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testButtonDifferentLoops()
    local hid = CommandGenericHID.new(0)
    local loop1 = EventLoop.new()
    local loop2 = EventLoop.new()
    
    local trigger1 = hid:button(1, loop1)
    local trigger2 = hid:button(1, loop2)
    
    -- Different triggers for different loops
    lu.assertNotEquals(trigger1, trigger2)
end
```

#### POV Trigger Tests
```lua
function TestCommandGenericHID:testPOV()
    local hid = CommandGenericHID.new(0)
    
    local up = hid:povUp()
    local right = hid:povRight()
    local center = hid:povCenter()
    
    lu.assertNotNil(up)
    lu.assertNotNil(right)
    lu.assertNotNil(center)
end

function TestCommandGenericHID:testPOVCaching()
    local hid = CommandGenericHID.new(0)
    
    local up1 = hid:pov(0, 0)
    local up2 = hid:povUp()
    
    -- Should return same trigger
    lu.assertEquals(up1, up2)
end

function TestCommandGenericHID:testPOVNegativeAngle()
    local hid = CommandGenericHID.new(0)
    
    -- Center is angle -1
    local center = hid:pov(0, -1)
    lu.assertNotNil(center)
end
```

#### Axis Trigger Tests
```lua
function TestCommandGenericHID:testAxisGreaterThan()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:axisGreaterThan(0, 0.5)
    
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testAxisLessThan()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:axisLessThan(1, -0.3)
    
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testAxisMagnitudeGreaterThan()
    local hid = CommandGenericHID.new(0)
    local trigger = hid:axisMagnitudeGreaterThan(2, 0.1)
    
    lu.assertNotNil(trigger)
end

function TestCommandGenericHID:testAxisTriggerCaching()
    local hid = CommandGenericHID.new(0)
    
    local trigger1 = hid:axisGreaterThan(0, 0.5)
    local trigger2 = hid:axisGreaterThan(0, 0.5)
    
    -- Same threshold should return same trigger
    lu.assertEquals(trigger1, trigger2)
end

function TestCommandGenericHID:testAxisDifferentThresholds()
    local hid = CommandGenericHID.new(0)
    
    local trigger1 = hid:axisGreaterThan(0, 0.5)
    local trigger2 = hid:axisGreaterThan(0, 0.6)
    
    -- Different thresholds should return different triggers
    lu.assertNotEquals(trigger1, trigger2)
end
```

#### Utility Method Tests
```lua
function TestCommandGenericHID:testGetRawAxis()
    local hid = CommandGenericHID.new(0)
    
    -- Should delegate to underlying HID
    local value = hid:getRawAxis(0)
    lu.assertNotNil(value)
end

function TestCommandGenericHID:testGetHID()
    local hid = CommandGenericHID.new(0)
    local underlyingHID = hid:getHID()
    
    lu.assertNotNil(underlyingHID)
end

function TestCommandGenericHID:testIsConnected()
    local hid = CommandGenericHID.new(0)
    local connected = hid:isConnected()
    
    -- Should return boolean
    lu.assertTrue(type(connected) == 'boolean')
end
```

### Integration Tests
Test with actual subclasses:
```lua
function TestCommandGenericHIDIntegration:testWithXboxController()
    local controller = CommandXboxController.new(0)
    
    -- Should have access to base methods
    local button1 = controller:button(1)
    local axisTrigger = controller:axisGreaterThan(0, 0.5)
    
    lu.assertNotNil(button1)
    lu.assertNotNil(axisTrigger)
end
```

## Usage Examples

### Direct Usage (Generic Controller)
```lua
local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')

-- For controllers that don't have specific wrapper class
local genericController = CommandGenericHID.new(2)

-- Bind button 5 to command
genericController:button(5):whileTrue(shootCommand)

-- Bind axis threshold
genericController:axisGreaterThan(3, 0.7):onTrue(turboCommand)

-- Bind POV direction
genericController:povUp():onTrue(selectUpCommand)
```

### As Base Class (CommandXboxController extends this)
```lua
local class = require('luabot.class')
local CommandGenericHID = require('wpi.cmd.button.CommandGenericHID')
local XboxController = require('wpi.frc.XboxController')

local CommandXboxController = class(CommandGenericHID)

function CommandXboxController.init(self, port)
    CommandGenericHID.init(self, port)
    self._hid = XboxController.new(port)  -- Override with specific type
end

function CommandXboxController:a(loop)
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    -- Use inherited button() method
    return self:button(XboxController.Button.kA, loop)
end
```

### Multiple Event Loops
```lua
local slowLoop = EventLoop.new()
local controller = CommandGenericHID.new(0)

-- Button trigger on default loop
controller:button(1):onTrue(fastCommand)

-- Same button on different loop (creates separate trigger)
controller:button(1, slowLoop):onTrue(slowCommand)

-- In robot periodic
function robotPeriodic()
    CommandScheduler.getInstance():run()  -- Polls default loop
    if frameCount % 50 == 0 then
        slowLoop:poll()  -- Poll slow loop less frequently
    end
end
```

## Implementation Notes

### Cache Key Design
**Button cache**: Simple integer key (button index)
**POV cache**: Composite integer key `pov * 3600 + angle`
**Axis cache**: String key format `"axis:threshold"` to handle floats

Alternative approaches considered:
- Serialize to JSON string (too heavy)
- Use nested tables (more complex lookup)
- String formatting chosen for simplicity and performance

### Memory Considerations
Each cached trigger:
- Stores one closure (condition function)
- Stores reference to EventLoop
- Typical robot: 20-50 cached triggers total
- Memory overhead negligible (~1KB total)

### EventLoop Reference Management
Caches use EventLoop as key, which means:
- EventLoop instances must stay alive while triggers exist
- Typically not an issue (scheduler's default loop lives forever)
- Custom loops: user must ensure lifecycle management

### Float Comparison in Cache Keys
Threshold values formatted to 6 decimal places:
- Sufficient precision for joystick values (typically 0.0 to 1.0)
- Two calls with `0.5` and `0.500000` treated as same
- Avoids floating-point equality issues

### Inheritance Pattern
Subclasses override:
- `init()` to store more specific HID type
- `getHID()` to return that specific type
- Add named button methods that call inherited `button()`

## Success Criteria
Implementation is complete when:
- [ ] CommandGenericHID class created with `luabot.class`
- [ ] All cache structures implemented and working
- [ ] Button trigger creation with caching works
- [ ] POV trigger creation with all directions works
- [ ] All three axis trigger methods work (lessThan, greaterThan, magnitude)
- [ ] Cache properly distinguishes between different loops
- [ ] Cache properly distinguishes between different thresholds
- [ ] Utility methods (getRawAxis, setRumble, isConnected) delegate correctly
- [ ] All unit tests pass
- [ ] CommandXboxController can extend this successfully
- [ ] CommandJoystick can extend this successfully
- [ ] Documentation shows cache key strategy clearly

## Dependencies Summary
**Requires**:
1. [EventLoop](EventLoop.md) - Polling infrastructure
2. [Trigger](Trigger.md) - State tracking and command binding
3. [CommandScheduler](../prompts/commands-api.md) - Default button loop access
4. GenericHID (existing) - Underlying HID wrapper

**Enables**:
1. [CommandXboxController](CommandXboxController.md) - Xbox-specific button names
2. [CommandJoystick](CommandJoystick.md) - Flight stick button names
3. User robot code - Direct use for unsupported controllers
