# Trigger Implementation Plan

## Overview
Implement the Trigger class, which provides an event-driven way to link commands to conditions (button presses, sensor readings, etc.). Triggers track state changes and automatically schedule/cancel commands based on condition transitions, enabling declarative robot programming patterns.

## Sources
- **Reference**: `deps/allwpilib/wpilibNewCommands/src/main/java/edu/wpi/first/wpilibj2/command/button/Trigger.java`

## Implementation Location
`bindings/wpi/cmd/button/Trigger.lua`

## Architecture Context
Trigger sits between EventLoop and command scheduling, providing state-change detection and command binding:

```
EventLoop (polls bound actions)
    ↓
Trigger (tracks condition state, detects changes)
    ↓
Command Binding Methods (onTrue, whileTrue, etc.)
    ↓
CommandScheduler (schedules/cancels commands)
```

**Used by**:
- `CommandGenericHID` - Creates triggers for button presses, axis thresholds, POV angles
- `CommandXboxController` - Named button triggers (a(), b(), leftBumper(), etc.)
- `CommandJoystick` - Named button triggers (trigger(), top())
- User code - Custom triggers for sensors, timers, complex conditions

## Dependencies

### Required Before Implementation
1. **EventLoop** ([EventLoop.md](EventLoop.md)) - Provides polling infrastructure
2. **Command** ([commands-api.md](../prompts/commands-api.md)) - Command interface for scheduling
3. **CommandScheduler** ([commands-api.md](../prompts/commands-api.md)) - Singleton for scheduling/canceling commands

## Trigger Implementation

### Class Structure
Pure Lua class using `luabot.class`:
```lua
local class = require('luabot.class')
local Trigger = class()
```

### Instance Fields
- `_condition` - Function that returns boolean (the condition to monitor)
- `_loop` - EventLoop instance that polls this trigger

**Design notes**:
- `_condition` is a callable: `function() return boolean end`
- `_loop` is the EventLoop that will call this trigger's polling logic

### Constructors

#### new(loop, condition)
Create trigger with explicit event loop:
```lua
function Trigger.new(loop, condition)
    local instance = setmetatable({}, Trigger)
    Trigger.init(instance, loop, condition)
    return instance
end

function Trigger.init(self, loop, condition)
    if not loop then
        error("loop parameter is required for Trigger")
    end
    if not condition then
        error("condition parameter is required for Trigger")
    end
    
    self._condition = condition
    self._loop = loop
end
```

#### new(condition)
Create trigger using CommandScheduler's default button loop:
```lua
-- Alternate constructor signature (handled in new)
function Trigger.new(loopOrCondition, optionalCondition)
    local instance = setmetatable({}, Trigger)
    
    if optionalCondition then
        -- Two argument form: new(loop, condition)
        Trigger.init(instance, loopOrCondition, optionalCondition)
    else
        -- One argument form: new(condition) - use default loop
        local CommandScheduler = require('wpi.cmd.CommandScheduler')
        local loop = CommandScheduler.getInstance():getDefaultButtonLoop()
        Trigger.init(instance, loop, loopOrCondition)
    end
    
    return instance
end
```

### Core Internal Method

#### addBinding(body)
Internal method to bind a state-change handler to the event loop.

**Parameters**:
- `body` - Function with signature `function(previous, current)` where both are booleans

**Behavior**:
1. Capture initial condition state
2. Bind a closure to the event loop that:
   - Evaluates current condition
   - Calls body with (previous, current)
   - Updates previous for next poll

**Implementation**:
```lua
function Trigger:addBinding(body)
    local previous = self._condition()
    
    self._loop:bind(function()
        local current = self._condition()
        body(previous, current)
        previous = current
    end)
end
```

**Why this works**: The closure captures `previous` in its environment, maintaining state across polls without instance storage.

### Command Binding Methods
All methods schedule/cancel commands based on state transitions and return `self` for chaining.

#### onTrue(command)
Schedule command when condition goes false → true.

**Implementation**:
```lua
function Trigger:onTrue(command)
    if not command then
        error("command is required for onTrue")
    end
    
    self:addBinding(function(previous, current)
        if not previous and current then
            local CommandScheduler = require('wpi.cmd.CommandScheduler')
            CommandScheduler.getInstance():schedule(command)
        end
    end)
    
    return self
end
```

#### onFalse(command)
Schedule command when condition goes true → false.

**Implementation**:
```lua
function Trigger:onFalse(command)
    if not command then
        error("command is required for onFalse")
    end
    
    self:addBinding(function(previous, current)
        if previous and not current then
            local CommandScheduler = require('wpi.cmd.CommandScheduler')
            CommandScheduler.getInstance():schedule(command)
        end
    end)
    
    return self
end
```

#### whileTrue(command)
Schedule command on false → true, cancel on true → false.

**Implementation**:
```lua
function Trigger:whileTrue(command)
    if not command then
        error("command is required for whileTrue")
    end
    
    self:addBinding(function(previous, current)
        local CommandScheduler = require('wpi.cmd.CommandScheduler')
        
        if not previous and current then
            -- Rising edge: schedule
            CommandScheduler.getInstance():schedule(command)
        elseif previous and not current then
            -- Falling edge: cancel
            CommandScheduler.getInstance():cancel(command)
        end
    end)
    
    return self
end
```

#### whileFalse(command)
Schedule command on true → false, cancel on false → true.

**Implementation**:
```lua
function Trigger:whileFalse(command)
    if not command then
        error("command is required for whileFalse")
    end
    
    self:addBinding(function(previous, current)
        local CommandScheduler = require('wpi.cmd.CommandScheduler')
        
        if previous and not current then
            -- Falling edge: schedule
            CommandScheduler.getInstance():schedule(command)
        elseif not previous and current then
            -- Rising edge: cancel
            CommandScheduler.getInstance():cancel(command)
        end
    end)
    
    return self
end
```

#### toggleOnTrue(command)
Toggle command scheduling when condition goes false → true.

**Implementation**:
```lua
function Trigger:toggleOnTrue(command)
    if not command then
        error("command is required for toggleOnTrue")
    end
    
    self:addBinding(function(previous, current)
        if not previous and current then
            local CommandScheduler = require('wpi.cmd.CommandScheduler')
            local scheduler = CommandScheduler.getInstance()
            
            if scheduler:isScheduled(command) then
                scheduler:cancel(command)
            else
                scheduler:schedule(command)
            end
        end
    end)
    
    return self
end
```

#### toggleOnFalse(command)
Toggle command scheduling when condition goes true → false.

**Implementation**:
```lua
function Trigger:toggleOnFalse(command)
    if not command then
        error("command is required for toggleOnFalse")
    end
    
    self:addBinding(function(previous, current)
        if previous and not current then
            local CommandScheduler = require('wpi.cmd.CommandScheduler')
            local scheduler = CommandScheduler.getInstance()
            
            if scheduler:isScheduled(command) then
                scheduler:cancel(command)
            else
                scheduler:schedule(command)
            end
        end
    end)
    
    return self
end
```

### Composition Methods
Create new triggers by combining conditions.

#### and_(trigger)
Logical AND with another trigger.

**Parameters**:
- `trigger` - Another Trigger or callable that returns boolean

**Returns**: New Trigger that is true when both conditions are true

**Implementation**:
```lua
function Trigger:and_(trigger)
    local otherCondition = trigger
    if type(trigger) == 'table' and trigger._condition then
        otherCondition = trigger._condition
    end
    
    return Trigger.new(self._loop, function()
        return self._condition() and otherCondition()
    end)
end
```

**Note**: Named `and_` to avoid Lua keyword conflict.

#### or_(trigger)
Logical OR with another trigger.

**Parameters**:
- `trigger` - Another Trigger or callable that returns boolean

**Returns**: New Trigger that is true when either condition is true

**Implementation**:
```lua
function Trigger:or_(trigger)
    local otherCondition = trigger
    if type(trigger) == 'table' and trigger._condition then
        otherCondition = trigger._condition
    end
    
    return Trigger.new(self._loop, function()
        return self._condition() or otherCondition()
    end)
end
```

**Note**: Named `or_` to avoid Lua keyword conflict.

#### negate()
Logical NOT of this trigger.

**Returns**: New Trigger that is true when this condition is false

**Implementation**:
```lua
function Trigger:negate()
    return Trigger.new(self._loop, function()
        return not self._condition()
    end)
end
```

### BooleanSupplier Interface

#### getAsBoolean()
Evaluate the condition immediately (not event-driven).

**Returns**: Current boolean value of condition

**Implementation**:
```lua
function Trigger:getAsBoolean()
    return self._condition()
end
```

**Use case**: Manual polling when event-driven isn't appropriate.

## Key Design Decisions

### Why Pure Lua?
Like EventLoop, Trigger has no HAL dependencies. It's pure event-driven logic that could work with any condition function. The Java implementation is also pure Java.

### State Tracking Pattern
Each binding maintains its own `previous` state via closure:
- **Advantage**: No instance storage needed, multiple bindings per trigger work independently
- **Advantage**: Thread-safe (each binding has isolated state)
- **Advantage**: Simple implementation

### Method Chaining
All binding methods return `self`, enabling fluent API:
```lua
trigger:onTrue(command1)
       :onFalse(command2)
       :whileTrue(command3)
```

Multiple bindings on same trigger are independent and all execute.

### Composition Creates New Triggers
`and_()`, `or_()`, `negate()` return **new** Trigger instances:
- Composed triggers share the same EventLoop
- Each has its own condition function combining the originals
- Enables complex conditions: `button.and_(sensor.negate()):onTrue(cmd)`

### Lua Keyword Avoidance
Java uses `and`, `or` as method names. Lua can't:
- `and` and `or` are reserved keywords
- Use `and_()` and `or_()` instead (trailing underscore convention)
- Document this prominently for users

## File Structure
```
bindings/wpi/cmd/button/
└── Trigger.lua                (new - pure Lua)

build/lua/wpi/cmd/button/
└── Trigger.lua                (copied by CMake)

test/wpi/
└── TestTrigger.lua            (new)
```

## Testing Strategy

### Unit Tests (`test/wpi/TestTrigger.lua`)

#### Constructor Tests
```lua
function TestTrigger:testConstructorWithLoop()
    local loop = EventLoop.new()
    local condition = function() return true end
    local trigger = Trigger.new(loop, condition)
    
    lu.assertTrue(trigger:getAsBoolean())
end

function TestTrigger:testConstructorWithDefaultLoop()
    local condition = function() return false end
    local trigger = Trigger.new(condition)
    
    lu.assertFalse(trigger:getAsBoolean())
end

function TestTrigger:testConstructorRequiresCondition()
    local loop = EventLoop.new()
    lu.assertError(function()
        Trigger.new(loop, nil)
    end)
end
```

#### onTrue Tests
```lua
function TestTrigger:testOnTrue()
    local loop = EventLoop.new()
    local conditionValue = false
    local trigger = Trigger.new(loop, function() return conditionValue end)
    
    local scheduled = false
    local mockCommand = { __scheduled = false }
    
    -- Mock CommandScheduler
    package.loaded['wpi.cmd.CommandScheduler'] = {
        getInstance = function()
            return {
                schedule = function(self, cmd)
                    scheduled = true
                end
            }
        end
    }
    
    trigger:onTrue(mockCommand)
    
    -- Initial poll - condition false
    loop:poll()
    lu.assertFalse(scheduled)
    
    -- Set condition true and poll
    conditionValue = true
    loop:poll()
    lu.assertTrue(scheduled)
    
    -- Stays true - shouldn't schedule again
    scheduled = false
    loop:poll()
    lu.assertFalse(scheduled)
end
```

#### whileTrue Tests
```lua
function TestTrigger:testWhileTrue()
    local loop = EventLoop.new()
    local conditionValue = false
    local trigger = Trigger.new(loop, function() return conditionValue end)
    
    local scheduled = false
    local canceled = false
    local mockCommand = {}
    
    package.loaded['wpi.cmd.CommandScheduler'] = {
        getInstance = function()
            return {
                schedule = function(self, cmd) scheduled = true end,
                cancel = function(self, cmd) canceled = true end
            }
        end
    }
    
    trigger:whileTrue(mockCommand)
    
    -- Rising edge: should schedule
    conditionValue = true
    loop:poll()
    lu.assertTrue(scheduled)
    
    -- Falling edge: should cancel
    scheduled = false
    conditionValue = false
    loop:poll()
    lu.assertFalse(scheduled)
    lu.assertTrue(canceled)
end
```

#### Composition Tests
```lua
function TestTrigger:testAnd()
    local loop = EventLoop.new()
    local cond1 = false
    local cond2 = false
    
    local trigger1 = Trigger.new(loop, function() return cond1 end)
    local trigger2 = Trigger.new(loop, function() return cond2 end)
    
    local combined = trigger1:and_(trigger2)
    
    lu.assertFalse(combined:getAsBoolean())
    
    cond1 = true
    lu.assertFalse(combined:getAsBoolean())
    
    cond2 = true
    lu.assertTrue(combined:getAsBoolean())
end

function TestTrigger:testOr()
    local loop = EventLoop.new()
    local cond1 = false
    local cond2 = false
    
    local trigger1 = Trigger.new(loop, function() return cond1 end)
    local trigger2 = Trigger.new(loop, function() return cond2 end)
    
    local combined = trigger1:or_(trigger2)
    
    lu.assertFalse(combined:getAsBoolean())
    
    cond1 = true
    lu.assertTrue(combined:getAsBoolean())
    
    cond1 = false
    cond2 = true
    lu.assertTrue(combined:getAsBoolean())
end

function TestTrigger:testNegate()
    local loop = EventLoop.new()
    local cond = false
    
    local trigger = Trigger.new(loop, function() return cond end)
    local negated = trigger:negate()
    
    lu.assertTrue(negated:getAsBoolean())
    
    cond = true
    lu.assertFalse(negated:getAsBoolean())
end
```

#### Method Chaining Tests
```lua
function TestTrigger:testChaining()
    local loop = EventLoop.new()
    local cond = false
    local trigger = Trigger.new(loop, function() return cond end)
    
    local onTrueCount = 0
    local onFalseCount = 0
    
    -- Chain multiple bindings
    trigger:onTrue({ schedule = function() onTrueCount = onTrueCount + 1 end })
           :onFalse({ schedule = function() onFalseCount = onFalseCount + 1 end })
    
    -- Should be able to chain
    lu.assertNotNil(trigger)
end
```

#### Toggle Tests
```lua
function TestTrigger:testToggleOnTrue()
    local loop = EventLoop.new()
    local cond = false
    local trigger = Trigger.new(loop, function() return cond end)
    
    local scheduled = false
    local mockCommand = {}
    
    package.loaded['wpi.cmd.CommandScheduler'] = {
        getInstance = function()
            return {
                schedule = function(self, cmd) scheduled = true end,
                cancel = function(self, cmd) scheduled = false end,
                isScheduled = function(self, cmd) return scheduled end
            }
        end
    }
    
    trigger:toggleOnTrue(mockCommand)
    
    -- First true: schedule
    cond = true
    loop:poll()
    lu.assertTrue(scheduled)
    
    -- False: no change
    cond = false
    loop:poll()
    lu.assertTrue(scheduled)
    
    -- True again: cancel
    cond = true
    loop:poll()
    lu.assertFalse(scheduled)
end
```

### Integration Tests
Test with CommandScheduler and real commands:
```lua
function TestTriggerIntegration:testWithRealScheduler()
    local scheduler = CommandScheduler.getInstance()
    local loop = scheduler:getDefaultButtonLoop()
    
    local buttonPressed = false
    local trigger = Trigger.new(loop, function() return buttonPressed end)
    
    local executed = false
    local command = InstantCommand.new(function() executed = true end)
    
    trigger:onTrue(command)
    
    -- Simulate button press
    buttonPressed = true
    scheduler:run()  -- Polls loop and executes commands
    
    lu.assertTrue(executed)
end
```

## Usage Examples

### Basic Button Binding
```lua
local Trigger = require('wpi.cmd.button.Trigger')
local controller = XboxController.new(0)

-- Manual trigger creation (usually done by CommandXboxController)
local loop = CommandScheduler.getInstance():getDefaultButtonLoop()
local aButton = Trigger.new(loop, function()
    return controller:getAButton()
end)

aButton:onTrue(intakeCommand)
```

### Custom Condition Trigger
```lua
-- Trigger based on sensor reading
local temperatureTrigger = Trigger.new(function()
    return robot.sensor:getTemperature() > 80.0
end)

temperatureTrigger:onTrue(
    InstantCommand.new(function()
        print("Warning: Temperature high!")
    end)
)
```

### Complex Composition
```lua
local aButton = controller:a()
local bButton = controller:b()
local sensor = Trigger.new(function() return robot:sensorActive() end)

-- Complex condition: (A AND B) OR (NOT sensor)
local complex = aButton:and_(bButton):or_(sensor:negate())

complex:whileTrue(specialCommand)
```

### Multiple Bindings on Same Trigger
```lua
local trigger = controller:a()

-- All three execute independently
trigger:onTrue(command1)        -- Schedule on rising edge
trigger:onFalse(command2)       -- Schedule on falling edge  
trigger:whileTrue(command3)     -- Hold while pressed
```

### Toggle Pattern
```lua
-- Toggle between two modes with one button
local modeButton = controller:b()

modeButton:toggleOnTrue(autoAimCommand)
-- Press: starts auto-aim
-- Press again: stops auto-aim
```

## Implementation Notes

### Closure Memory Considerations
Each binding captures `previous` in closure:
- Memory overhead: One boolean per binding (~1 byte)
- Expected usage: 10-50 bindings per robot
- Not a concern for typical FRC applications

### Command Lifecycle Integration
Trigger doesn't own commands, only schedules them:
- Commands managed by CommandScheduler
- Multiple triggers can schedule same command
- CommandScheduler handles conflicts via requirements

### EventLoop Binding Timing
Bindings are added immediately when trigger methods called:
- `trigger:onTrue(cmd)` calls `addBinding()` which calls `loop:bind()`
- Condition starts being polled on next `loop:poll()`
- Initial `previous` state captured at binding time

### Error Handling
All binding methods validate command parameter:
- Throw error if nil (fail fast)
- Better than silent no-op or deferred error

### Lua Keyword Workaround
Document prominently:
```lua
-- Correct:
trigger:and_(otherTrigger)
trigger:or_(otherTrigger)

-- Wrong (syntax error):
trigger:and(otherTrigger)  -- 'and' is keyword
trigger:or(otherTrigger)   -- 'or' is keyword
```

Alternative considered: Use `And()`, `Or()` (capital letters), but underscore suffix is clearer.

## Success Criteria
Implementation is complete when:
- [ ] Trigger class created with `luabot.class`
- [ ] Two constructor forms work (with/without loop parameter)
- [ ] All six binding methods implemented (onTrue, onFalse, whileTrue, whileFalse, toggleOnTrue, toggleOnFalse)
- [ ] All three composition methods work (and_, or_, negate)
- [ ] getAsBoolean() returns current condition value
- [ ] Method chaining works (all binding methods return self)
- [ ] Multiple bindings on same trigger execute independently
- [ ] State tracking via closure works correctly
- [ ] All unit tests pass
- [ ] Integration test with CommandScheduler works
- [ ] Documentation includes Lua keyword workaround

## Dependencies Summary
**Requires**:
1. [EventLoop](EventLoop.md) - Polling infrastructure (implement first)
2. [Command](../prompts/commands-api.md) - Command interface (already exists)
3. [CommandScheduler](../prompts/commands-api.md) - schedule/cancel/isScheduled methods (already exists)

**Enables**:
1. [CommandGenericHID](CommandXboxController.md#commandgenerichid) - Button/axis trigger factories
2. [CommandXboxController](CommandXboxController.md) - Named button triggers
3. [CommandJoystick](CommandJoystick.md) - Flight stick button triggers
4. User robot code - Custom condition triggers
