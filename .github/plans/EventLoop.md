# EventLoop Implementation Plan

## Overview
Implement the EventLoop class, a declarative way to bind a set of actions to a loop and execute them when polled. This is a foundational component for the trigger-based command system, enabling event-driven programming patterns in LuaBot.

## Sources
- **Reference**: `deps/allwpilib/wpilibj/src/main/java/edu/wpi/first/wpilibj/event/EventLoop.java`

## Implementation Location
`bindings/wpi/event/EventLoop.lua`

## Architecture Context
EventLoop is a **pure Lua implementation** (not a YAML binding) that provides the polling infrastructure for the trigger system. It sits at the bottom of the event-driven command framework hierarchy:

```
EventLoop (polls bound actions)
    ↓
Trigger (tracks state changes, binds to EventLoop)
    ↓
CommandGenericHID (creates triggers for buttons/axes)
    ↓
CommandXboxController/CommandJoystick (convenience button methods)
```

**Used by**:
- `Trigger` - Binds state-change callbacks to event loops
- `CommandScheduler` - Maintains a default button loop, polls it each iteration
- User code - Can create custom event loops for specialized polling needs

## EventLoop Implementation

### Class Structure
Pure Lua class using `luabot.class`:
```lua
local class = require('luabot.class')
local EventLoop = class()
```

### Instance Fields
- `_bindings` - Table (array) of bound functions to execute on poll
- `_running` - Boolean flag indicating if loop is currently polling

**Design notes**:
- Use array-style table (`{fn1, fn2, fn3}`) for ordered execution
- `_running` prevents concurrent modification during poll

### Constructor
```lua
function EventLoop.init(self)
    self._bindings = {}
    self._running = false
end

function EventLoop.new()
    local instance = setmetatable({}, EventLoop)
    EventLoop.init(instance)
    return instance
end
```

### Methods

#### bind(action)
Add a function to execute when the loop is polled.

**Parameters**:
- `action` - Function with no parameters to call on each poll

**Behavior**:
- Append function to `_bindings` array
- Throw error if called while loop is running (concurrent modification protection)

**Implementation**:
```lua
function EventLoop:bind(action)
    if self._running then
        error("Cannot bind EventLoop while it is running")
    end
    table.insert(self._bindings, action)
end
```

**Error handling**: Must prevent modification during poll to avoid iteration issues

#### poll()
Execute all bound actions in order.

**Behavior**:
1. Set `_running = true`
2. Iterate through `_bindings`, call each function
3. Set `_running = false` (even if error occurs - use pcall or try/finally pattern)

**Implementation**:
```lua
function EventLoop:poll()
    self._running = true
    -- Use pcall to ensure _running is always reset
    local status, err = pcall(function()
        for _, action in ipairs(self._bindings) do
            action()
        end
    end)
    self._running = false
    
    -- Re-throw error if one occurred
    if not status then
        error(err)
    end
end
```

**Alternative implementation** (simpler, relies on Lua error handling):
```lua
function EventLoop:poll()
    local success, err
    self._running = true
    
    -- Execute all bindings
    for _, action in ipairs(self._bindings) do
        action()
    end
    
    self._running = false
end
```

**Note**: Lua's error handling will unwind the stack, but `_running` might not be reset if error occurs. Consider using pcall/xpcall for robustness, or document that errors in bindings will propagate.

#### clear()
Remove all bound actions.

**Behavior**:
- Clear `_bindings` array
- Throw error if called while loop is running

**Implementation**:
```lua
function EventLoop:clear()
    if self._running then
        error("Cannot clear EventLoop while it is running")
    end
    self._bindings = {}
end
```

## Key Design Decisions

### Why Pure Lua?
EventLoop has no dependencies on WPILib HAL or C++ code. It's pure logic for managing callbacks, perfect for a pure Lua implementation. The Java version is also pure Java with no native code.

### Concurrent Modification Protection
The `_running` flag prevents modifying bindings during poll:
- **Problem**: If a binding modifies `_bindings` during iteration, Lua's `ipairs` can skip or repeat elements
- **Solution**: Check `_running` in `bind()` and `clear()`, throw error if true
- **Java equivalent**: Uses `ConcurrentModificationException`

### Execution Order
Bindings execute in the order they were added (insertion order):
- Uses array-style table iteration with `ipairs`
- Important for deterministic behavior in trigger system

### Error Propagation
If a bound action throws an error:
- **Option 1**: Let error propagate (simpler, user sees error immediately)
- **Option 2**: Catch error, reset `_running`, re-throw (safer, ensures cleanup)
- **Recommendation**: Use pcall for robustness, document error behavior

## Integration with Trigger System

### How Triggers Use EventLoop
From [Trigger.lua](Trigger.md):
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

Each trigger binds a closure to its event loop that:
1. Evaluates condition (e.g., button pressed)
2. Compares to previous state
3. Calls binding body with state transition
4. Updates previous state for next poll

### How CommandScheduler Uses EventLoop
From [CommandScheduler.lua](../commands-api.md#commandscheduler-button-loop-support):
```lua
function CommandScheduler:run()
    -- ... subsystem periodic calls ...
    
    -- Poll button loop to process all trigger bindings
    self._defaultButtonLoop:poll()
    
    -- ... command execution ...
end
```

The scheduler's main loop calls `poll()` once per iteration, which fires all registered trigger callbacks.

## File Structure
```
bindings/wpi/event/
└── EventLoop.lua              (new - pure Lua)

build/lua/wpi/event/
└── EventLoop.lua              (copied by CMake)

test/wpi/
└── TestEventLoop.lua          (new)
```

### CMakeLists.txt Updates
Add to `bindings/CMakeLists.txt`:
```cmake
# Copy event directory
file(GLOB_RECURSE EVENT_LUA_FILES 
    "${CMAKE_CURRENT_SOURCE_DIR}/wpi/event/*.lua")
foreach(lua_file ${EVENT_LUA_FILES})
    file(RELATIVE_PATH rel_path 
        "${CMAKE_CURRENT_SOURCE_DIR}/wpi" 
        "${lua_file}")
    configure_file("${lua_file}" 
        "${LUA_OUTPUT_DIR}/wpi/${rel_path}" COPYONLY)
endforeach()
```

## Testing Strategy

### Unit Tests (`test/wpi/TestEventLoop.lua`)

#### Basic Functionality
```lua
function TestEventLoop:testBindAndPoll()
    local loop = EventLoop.new()
    local counter = 0
    
    loop:bind(function() counter = counter + 1 end)
    loop:bind(function() counter = counter + 2 end)
    
    loop:poll()
    lu.assertEquals(counter, 3)
    
    loop:poll()
    lu.assertEquals(counter, 6)
end
```

#### Execution Order
```lua
function TestEventLoop:testExecutionOrder()
    local loop = EventLoop.new()
    local results = {}
    
    loop:bind(function() table.insert(results, 1) end)
    loop:bind(function() table.insert(results, 2) end)
    loop:bind(function() table.insert(results, 3) end)
    
    loop:poll()
    
    lu.assertEquals(results[1], 1)
    lu.assertEquals(results[2], 2)
    lu.assertEquals(results[3], 3)
end
```

#### Concurrent Modification Protection
```lua
function TestEventLoop:testCannotBindWhileRunning()
    local loop = EventLoop.new()
    local innerLoop = loop  -- Capture for closure
    
    loop:bind(function()
        -- Try to bind during poll - should error
        lu.assertErrorMsgContains("while it is running", function()
            innerLoop:bind(function() end)
        end)
    end)
    
    loop:poll()  -- Should complete despite inner error
end

function TestEventLoop:testCannotClearWhileRunning()
    local loop = EventLoop.new()
    
    loop:bind(function()
        lu.assertErrorMsgContains("while it is running", function()
            loop:clear()
        end)
    end)
    
    loop:poll()
end
```

#### Clear Functionality
```lua
function TestEventLoop:testClear()
    local loop = EventLoop.new()
    local counter = 0
    
    loop:bind(function() counter = counter + 1 end)
    loop:poll()
    lu.assertEquals(counter, 1)
    
    loop:clear()
    loop:poll()
    lu.assertEquals(counter, 1)  -- Should not increment
end
```

#### Error Handling
```lua
function TestEventLoop:testErrorInBinding()
    local loop = EventLoop.new()
    local executed = false
    
    loop:bind(function()
        error("Test error")
    end)
    
    -- Error should propagate
    lu.assertError(function()
        loop:poll()
    end)
    
    -- Loop should still be usable after error
    loop:clear()
    loop:bind(function() executed = true end)
    loop:poll()
    lu.assertTrue(executed)
end
```

#### Multiple Polls
```lua
function TestEventLoop:testMultiplePolls()
    local loop = EventLoop.new()
    local counter = 0
    
    loop:bind(function() counter = counter + 1 end)
    
    for i = 1, 10 do
        loop:poll()
    end
    
    lu.assertEquals(counter, 10)
end
```

### Integration Test
Test with Trigger system (after Trigger is implemented):
```lua
function TestEventLoopIntegration:testWithTrigger()
    local loop = EventLoop.new()
    local buttonPressed = false
    local commandScheduled = false
    
    local trigger = Trigger.new(loop, function() 
        return buttonPressed 
    end)
    
    trigger:onTrue({
        schedule = function() 
            commandScheduled = true 
        end
    })
    
    -- Initial poll - button not pressed
    loop:poll()
    lu.assertFalse(commandScheduled)
    
    -- Press button and poll
    buttonPressed = true
    loop:poll()
    lu.assertTrue(commandScheduled)
end
```

## Usage Examples

### Basic Usage
```lua
local EventLoop = require('wpi.event.EventLoop')

local loop = EventLoop.new()

-- Bind actions
loop:bind(function()
    print("Action 1")
end)

loop:bind(function()
    print("Action 2")
end)

-- Execute all bindings
loop:poll()  -- Prints "Action 1\nAction 2"
loop:poll()  -- Prints again
```

### With Triggers (after Trigger implementation)
```lua
local EventLoop = require('wpi.event.EventLoop')
local Trigger = require('wpi.cmd.button.Trigger')

local loop = EventLoop.new()
local buttonPressed = false

local trigger = Trigger.new(loop, function()
    return buttonPressed
end)

trigger:onTrue(myCommand)

-- In robot loop
function robotPeriodic()
    loop:poll()  -- Processes all trigger state changes
end
```

### Custom Polling Schedule
```lua
-- Create separate event loop for slow-polling operations
local slowLoop = EventLoop.new()

slowLoop:bind(function()
    -- Expensive operation
    checkNetworkStatus()
end)

-- Poll at different rate than main loop
function robotPeriodic()
    if frameCount % 50 == 0 then  -- Every 50 frames
        slowLoop:poll()
    end
end
```

## Implementation Notes

### Lua-Specific Considerations

#### Table Iteration
Use `ipairs` for ordered iteration:
```lua
for _, action in ipairs(self._bindings) do
    action()
end
```
Not `pairs` (which has undefined order).

#### Error Handling
Lua errors unwind the stack, so consider:
```lua
function EventLoop:poll()
    self._running = true
    local success, err = pcall(function()
        for _, action in ipairs(self._bindings) do
            action()
        end
    end)
    self._running = false
    if not success then
        error(err)
    end
end
```

This ensures `_running` is reset even if binding throws error.

#### Memory Management
Bindings are kept alive by array reference. To prevent memory leaks:
- Call `clear()` when event loop is no longer needed
- Don't capture heavy objects in binding closures unnecessarily

### Performance Characteristics
- **Bind**: O(1) - table.insert at end
- **Poll**: O(n) - iterate all bindings
- **Clear**: O(1) - replace table reference

Expected usage: 10-100 bindings per loop, polled 50 times/second.

## Success Criteria
Implementation is complete when:
- [ ] EventLoop class created with `luabot.class`
- [ ] `bind()` adds functions to execute on poll
- [ ] `poll()` executes all bindings in order
- [ ] `clear()` removes all bindings
- [ ] Concurrent modification errors when bind/clear called during poll
- [ ] Error handling: errors in bindings propagate but don't corrupt state
- [ ] All unit tests pass
- [ ] Integration test with Trigger system works
- [ ] CMakeLists.txt updated to copy event directory
- [ ] Can use EventLoop as foundation for Trigger system

## Dependencies
**None** - EventLoop is a pure Lua utility with no external dependencies. Implement this first before Trigger, CommandGenericHID, etc.

## Dependents
These classes depend on EventLoop and should be implemented after:
1. [Trigger](Trigger.md) - Uses EventLoop to poll trigger conditions
2. [CommandScheduler button loop](../commands-api.md) - Creates default EventLoop instance
3. [CommandGenericHID](CommandXboxController.md#commandgenerichid) - Passes EventLoop to Trigger constructors
4. [CommandXboxController](CommandXboxController.md) - Uses default button loop
5. [CommandJoystick](CommandJoystick.md) - Uses default button loop
