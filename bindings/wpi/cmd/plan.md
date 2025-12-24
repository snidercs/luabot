# Command Framework Pure Lua Implementation Plan

## Overview
Create a **pure Lua implementation** of the WPILib command-based framework (frc2), modeled after the Java implementation. This is NOT a wrapper around C++ - it's a native Lua implementation that uses the existing WPILib HAL and utilities underneath, just like the Java version does.

## Key Design Principle
The Java wpilibNewCommands is a pure Java library that sits on top of WPILib's HAL layer. We're doing the same thing in Lua - writing the command framework entirely in Lua, using the existing HAL/WPILib bindings we already have.

**All class definitions and inheritance MUST use** `luabot.class`.

## Important Note
**DO NOT use RobotBase, IterativeRobotBase, or TimedRobot as examples for the command framework!** These classes currently use a custom inheritance pattern (module tables with `derive()` functions) that predates the `luabot.class` system. They will be converted to use `luabot.class` later, but for now, the command framework should use `luabot.class` from the start as the canonical pattern.

## Architecture

### Core Classes (Phase 1 - Simple Framework)
These are pure Lua implementations, NOT YAML bindings:

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

## Implementation Strategy

### Phase 1 - Core Framework
Create the three fundamental classes with all essential functionality:

1. **Subsystem** - Base class for robot subsystems
   - [x] `periodic()` / `simulationPeriodic()` virtual methods
   - [x] Name management
   - [x] Default command support
   - [x] Automatic registration with scheduler (deferred to manual for now)

2. **Command** - Base class for robot commands  
   - [x] Lifecycle methods: `initialize()`, `execute()`, `done(interrupted)`, `isFinished()`
   - [x] Requirements management with `addRequirements()` / `getRequirements()`
   - [x] Name management
   - [x] Interruption behavior support (returns 0=kCancelSelf by default)
   - [x] Note: `done()` used instead of `end()` to avoid Lua keyword conflict

3. **CommandScheduler** - Singleton scheduler
   - [x] Singleton pattern with `getInstance()`
   - [x] Command scheduling with conflict resolution based on interruption behavior
   - [x] Command cancellation (individual and all)
   - [x] Main `run()` loop with proper sequencing
   - [x] Subsystem registration and periodic calling
   - [x] Default command management
   - [x] Enable/disable functionality
   - [ ] Queue-based scheduling/cancellation during run loop to avoid concurrent modification
   - [ ] Simulation mode support (calls `simulationPeriodic()`)

### Testing & Validation
- [x] Unit tests for all three classes
- [x] Lifecycle method override tests
- [x] Requirements conflict resolution tests
- [x] Default command tests
- [ ] Integration test with real command-based robot pattern (next step)
- [ ] Example robot in `examples/` (next step)

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
   - [x] Call `periodic()` on all registered subsystems
   - [ ] In simulation mode: also call `simulationPeriodic()` on subsystems
   - [ ] Poll event loop (for button triggers - Phase 3)
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
```

### Requirements Tracking
```lua
-- In Command:
function Command:addRequirements(...)
    local subsystems = {...}
    for _, subsystem in ipairs(subsystems) do
        self._requirements[subsystem] = true
    end
end

function Command:getRequirements()
    local reqs = {}
    for subsystem, _ in pairs(self._requirements) do
        table.insert(reqs, subsystem)
    end
    return reqs
end
```
### Virtual Methods
Commands and Subsystems use Lua's standard method override pattern via `luabot.class`.

### Memory Management
Commands can be owned by scheduler or user:
- CommandPtr in C++ uses move semantics
- LReference Implementation
**Model after**: `deps/allwpilib/wpilibNewCommands/src/main/java/`
- `Command.java` - Abstract base class with lifecycle methods
- `Subsystem.java` - Interface with default methods
- `CommandScheduler.java` - Singleton scheduler with run loop

**Key insight**: The Java version is 100% pure Java code sitting on top of WPILib HAL. It doesn't call into C++ for command logic. We do the same in Lua.

## Questions Resolved
1. ~~Should we wrap C++?~~ **No - pure Lua implementation**
2. ~~YAML bindings?~~ **No - regular Lua source files**
3. Requirements handling? **Lua tables, no FFI needed**
4. Singleton pattern? **Standard Lua singleton with instance variable**
5. SubsystemBase? **Not needed for phase 1 - just base Subsystem class**

## Success Criteria
Phase 1 is complete when:
- [ ] Can create Lua class derived from Subsystem
- [ ] Can create Lua class derived from Command  
- [ ] Scheduler.run() executes command lifecycle correctly
- [ ] Multiple commands respect subsystem requirements
- [ ] Default commands work
- [ ] Command cancellation works
- [ ] Test passes with real command-based robot pattern
- [ ] Can write a simple command-based robot in examples/
## File Structure
```
bindings/wpi/cmd/
├── Subsystem.yaml
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
- [ ] `RunCommand` - Wraps lambda/function
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
1. Should we expose CommandPtr or just raw Command pointers?
2. How to handle command ownership - Lua GC or explicit management?
3. Do we need SubsystemBase as well as Subsystem?
4. Should commands self-register requirements in constructor?

## Success Criteria
Phase 1 is complete when:
- [ ] Can create Lua class derived from Subsystem
- [ ] Can create Lua class derived from Command  
- [ ] Scheduler can run commands that require subsystems
- [ ] Lifecycle methods are called correctly
- [ ] Multiple commands respecting subsystem requirements
- [ ] Test passes with real command-based robot pattern
