# Command Framework Implementation Guide

## Architecture Overview
The LuaBot command framework is a **pure Lua implementation** of WPILib's command-based framework (frc2). This is NOT a wrapper around C++ code - it's a native Lua implementation that sits on top of the existing WPILib HAL and utilities, exactly like the Java wpilibNewCommands library does.

## Critical Design Rules

### Class Definition Requirements
- **ALWAYS use `luabot.class` for ALL command framework classes**
- Never use FFI or C++ wrappers for command logic
- Never use the old `derive()` pattern from RobotBase/TimedRobot (these predate `luabot.class` and will be migrated later)
- All user-facing classes must support inheritance via `local MyClass = class(BaseClass)`

### Reference Implementation Requirements
**ALWAYS check the corresponding Java implementation before implementing or modifying any wpi.cmd class.**

All Lua classes in `wpi.cmd` modules MUST reference their Java counterparts for:
- Method signatures and behavior
- Edge case handling
- Error conditions
- State management patterns
- Documentation of intended functionality

**Model after**: `deps/allwpilib/wpilibNewCommands/src/main/java/`
- `Command.java` - Lifecycle methods and requirements tracking
- `Subsystem.java` - Periodic callbacks and default commands
- `CommandScheduler.java` - Singleton scheduler with conflict resolution

The Java implementation is 100% pure Java sitting on WPILib HAL. Do the same in Lua - no C++ dependencies for command logic.

**Never make assumptions about behavior** - if unsure, read the Java source code to understand the correct implementation.

## Core Framework Classes

### Implementation Files
Create these as pure Lua source files in `bindings/wpi/cmd/` (NOT YAML bindings):

1. **Subsystem** (`bindings/wpi/cmd/Subsystem.lua`)
   - Pure Lua base class created with `luabot.class`
   - Methods to implement (defaults provided):
     - `periodic()` - Called every scheduler run (default: no-op)
     - `simulationPeriodic()` - Called in simulation (default: no-op)
     - `getName()` - Returns subsystem name (default: class name)
     - `setDefaultCommand(command)` - Sets the default command
     - `getDefaultCommand()` - Gets the default command
   - **Users derive using**: `local MySubsystem = class(Subsystem)` where `class = require('luabot.class')`
   - Override methods as needed in derived classes

2. **Command** (`bindings/wpi/cmd/Command.lua`)
   - Pure Lua base class created with `luabot.class`
   - Instance fields (set in `.init()`):
     - `_requirements` - Table/set of required subsystems
     - `_name` - Command name (private)
   - Methods to implement (defaults provided):
     - `initialize()` - Called once when scheduled (default: no-op)
     - `execute()` - Called repeatedly while running (default: no-op)
     - `end(interrupted)` - Called when finished/interrupted (default: no-op)
     - `isFinished()` - Returns true when done (default: false)
     - `getRequirements()` - Returns requirements table (default: empty)
     - `getName()` / `setName(name)` - Command naming
   - Methods provided by base:
     - `addRequirements(subsystems...)` - Add subsystem requirements
     - `getInterruptionBehavior()` - How to handle conflicts
   - **Users derive using**: `local MyCommand = class(Command)` where `class = require('luabot.class')`
   - Override lifecycle methods in derived classes

3. **CommandScheduler** (`bindings/wpi/cmd/CommandScheduler.lua`)
   - Pure Lua singleton implementation (uses `luabot.class` for structure)
   - Internal state (tables, set in `.init()`):
     - `_scheduledCommands` - Set of currently running commands
     - `_requirements` - Map of subsystem -> command using it
     - `_subsystems` - Map of subsystem -> default command
     - `_inRunLoop` - Flag to prevent scheduling during run
     - `_disabled` - Whether scheduler is disabled
   - Methods:
     - `getInstance()` - Get singleton instance (static)
     - `schedule(commands...)` - Schedule command(s)
     - `cancel(commands...)` - Cancel command(s)
     - `cancelAll()` - Cancel all commands
     - `run()` - **Main loop** - Run one scheduler iteration
     - `registerSubsystem(subsystems...)` - Register for periodic calls
     - `unregisterSubsystem(subsystems...)` - Unregister subsystem
     - `isScheduled(command)` - Check if command is running
     - `requiring(subsystem)` - Get command using subsystem
     - `enable()` / `disable()` - Enable/disable scheduler
   - Main `run()` logic (from Java implementation):
     1. Return early if scheduler is disabled
     2. Call `periodic()` on all registered subsystems
     3. In simulation mode: call `simulationPeriodic()` on all subsystems
     4. Poll event loop (for triggers - future Phase 3)
     5. For each scheduled command:
        - Call `execute()`
        - Check `isFinished()` after execute
        - If finished: call `done(false)` and unschedule, clear requirements
     6. Process any queued schedule/cancel operations (from calls during loop)
     7. Schedule default commands for unused subsystems (if not already scheduled)

## Implementation Requirements

### Completed Features
The core framework classes are implemented with:
- Subsystem base class with `periodic()`, `simulationPeriodic()`, default commands
- Command base class with lifecycle methods (`initialize()`, `execute()`, `done()`, `isFinished()`)
- CommandScheduler singleton with scheduling, conflict resolution, and cancellation
- Requirements tracking and validation
- Interruption behavior support (`kCancelSelf=0`, `kCancelIncoming=1`)
- Basic unit tests for all three core classes

### Remaining Work
When extending the command framework:
- [ ] Add queue-based scheduling/cancellation in CommandScheduler to prevent concurrent modification during `run()` loop
- [ ] Implement simulation mode detection and `simulationPeriodic()` calls in scheduler
- [ ] Create integration test with realistic command-based robot
- [ ] Add example command-based robot to `examples/`
- [ ] Implement command group classes (Sequential, Parallel, etc.)
- [ ] Add trigger system for button bindings

## Implementation Details

### Command Lifecycle (from Java)
1. When `schedule()` called:
   - [x] Return early if scheduler is disabled
   - [x] Return early if command is already scheduled
   - [x] Check if requirements are available (not currently in use)
     - [x] If available: initialize and schedule immediately
     - [x] If not available: check interruption behavior of conflicting commands
       - [x] If any requiring command has `kCancelIncoming` (1): abort scheduling
       - [x] Otherwise: cancel all conflicting commands, then initialize and schedule
   - [x] Add to `scheduledCommands` set
   - [x] Mark subsystems as required in `requirements` map
   - [x] Call `initialize()` on command
   - [ ] **Note**: If called during `run()` loop, queue for later scheduling

2. During `run()`:
   Command Scheduler Behavior

### Scheduling Logic (follows Java CommandSchedulertton triggers - Phase 3)
   - [x] For each scheduled command:
     - [x] Call `execute()`
     - [x] Check `isFinished()` after execute
     - [x] If finished: call `done(false)`, remove from schedule, clear requirements
   - [ ] Process queued schedule/cancel operations (from step 1 note)
   - [x] Schedule default commands for unused subsystems (if not already scheduled)

3. When `cancel()` called:
   - [x] Return early if command not scheduled
   - [x] Call `done(true)` on command (interrupted)
   - [x] Remove from scheduled set
   - [x] Clear subsystem requirements
   - [ ] **Note**: If called during `run()` loop, queue for later cancellation

### Subsystem Management (from Java)
- [x] Subsystems register themselves (usually in constructor)
- [x] Scheduler maintains map of subsystem -> default command
- [x] During `run()`, schedule default command if subsystem is not in use
- [x] Call `periodic()` on all registered subsystems each iteration
- [x] In simulation: call `simulationPeriodic()` on all subsystems
- [ ] Default commands must require the subsystem they're set for (validation in Java)
- [ ] Default commands that are `kCancelIncoming` will warn but are allowed

### Singleton Pattern
```lua
local SingletonType = {}
local instance = nil

--- init and new not required since instantition is controlled in `getInstance()`
local function create()
  local inst = setmetatable({}, SingletonType)
  -- initialization steps
  return inst
end

function SingletonType.getInstance()
    if not instance then
        instance = create()
    end
    return instance
end
```

## File Structure
```
bindings/wpi/cmd/
├── Subsystem.lua         (pure Lua implementation)
├── Command.lua           (pure Lua implementation)
└── CommandScheduler.lua  (pure Lua implementation)

build/lua/wpi/cmd/        (copied by CMake)
├── Subsystem.lua         
├── Command.lua           
└── CommandScheduler.lua  

test/wpi/
└── TestCommand.lua       (new test)
```

## Dependencies
The command framework will use existing WPILib bindings:
- **`luabot.class`** - **REQUIRED** for all class definitions and inheritance
- No FFI/C++ dependencies needed!

## class Hierarchy
All classes use `luabot.class` callable pattern:
```lua
local class = require('luabot.class')

Command = class()              -- Base class created with class()
MyCommand = class(Command)     -- Derive using class(Parent)

Subsystem = class()            -- Base class
MySubsystem = class(Subsystem) -- Derive

CommandScheduler = class()     -- Singleton
```Coding Standards for Command Framework

### Required Dependencies
- **`luabot.class`** - MANDATORY for all class definitions and inheritance
- No FFI/C++ dependencies for command logic
- # Class Definition Pattern
Always use `luabot.class` for inheritance:
```lua
local class = require('luabot.class')

-- Base classes
local Command = class()
local Subsystem = class()

-- User derivation
local MyCommand = class(Command)
local MySubsystem = class(Subsystem)

-- Singleton pattern for CommandScheduler
local CommandScheduler = class()
local instance = nil
function CommandScheduler.getInstance()
    if not instance then
        instance = CommandScheduler.new()
    end
    return instance
endments) do
        table.insert(reqs, subsystem)
    end
    return reqs
end
```
### Virtual Methods
Commands and Subsystems use Lua's standard method override pattern via `luabot.class`.

### Memory Management
Commands can be owned by scheduler or user:
- CoMethod Override Pattern
- Commands and Subsystems provide virtual methods with default implementations
- Users override methods in derived classes using standard Lua method syntax
- Use `self` to access instance state
- Private fields use underscore prefix: `self._requirements`, `self._name`

### Memory Management
- Commands owned by scheduler during execution
- Lua GC handles cleanup when commands unscheduled
- No explicit memory management needed (unlike C++ CommandPtr)Subsystem.yaml
├── Command.yaml
└── CommandScheduler.yaml

build/lua/wpi/cmd/
├── Subsystem.lua      (generated)
├── Command.lua        (generated)
└── CommandScheduler.lua (generated)

test/wpi/
└── TestCommand.lua    (new test)
```

## Phase 2 (Future)
After basic framework works, add convenience commands. Each of these should model the Java implementations and also follow the same class hierarchy.
- [x] `FunctionalCommand` - Full lifecycle as functions
- [x] `InstantCommand` - Runs once then finishes
- [x] `RunCommand` - Wraps lambda/function
- [ ] `SequentialCommandGroup` - Run commands in sequence
- [ ] `ParallelCommandGroup` - Run commands in parallel
- [ ] `ParallelRaceGroup` - First to finish wins
- [ ] `ParallelDeadlineGroup` - Wait for deadline command

## Phase 3 (Future)
Add advanced features:
- Triggers for button bindings
- Command decorators (withTimeout, until, etc.)
- PrintCommand, WaitCommand
- Integration with SendableChooser

## Questions to Resolve
1. Extension Classes

### Convenience Commands (Implemented)
When creating new command types, model after Java implementations:
- `FunctionalCommand` - Accepts functions for each lifecycle method
- `InstantCommand` - Executes once and finishes immediately
- `RunCommand` - Wraps a single execute function

### Command Groups (Not Yet Implemented)
These should follow the same patterns when added:
- `SequentialCommandGroup` - Run commands in sequence
- `ParallelCommandGroup` - Run commands in parallel
- `ParallelRaceGroup` - First to finish wins
- `ParallelDeadlineGroup` - Wait for deadline command

### Advanced Features (Future)
- Triggers for button bindings (Phase 3)
- Command decorators: `withTimeout()`, `until()`, `repeatedly()`
- Utility commands: `PrintCommand`, `WaitCommand`
- SendableChooser integration

## Testing Requirements

### Unit Tests
- Create test file per class: `test/wpi/TestClassName.lua`
- Test construction, lifecycle methods, edge cases
- Verify garbage collection with `collectgarbage()`
- Add to `test/CMakeLists.txt` using `luabot_add_api_test()`

### Integration Tests
- Test realistic command-based robot patterns
- Verify subsystem requirement conflicts
- Test default command behavior
- Validate scheduler run loop sequencing