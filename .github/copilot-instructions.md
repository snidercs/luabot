# LuaBot Copilot Instructions

## Project Overview
LuaBot is a Lua scripting environment for FRC (FIRST Robotics Competition) robots, built on top of WPILib. It enables robot programming using LuaJIT while maintaining full access to WPILib's HAL, command-based framework, and simulation capabilities.

## Technical Stack
- **Language**: C++20, Lua 5.1 (LuaJIT 2.1)
- **Framework**: WPILib (allwpilib)
- **FFI**: LuaJIT FFI for C/C++ interop
- **Build**: CMake, Ninja
- **Platforms**: macOS, Linux, Windows

## Architecture Principles

### C++ Side (src/, include/)
- Use modern C++20 features where appropriate
- Leverage WPILib patterns: HAL initialization, robot lifecycle management
- Exception handling: Catch exceptions at thread boundaries, log via `HAL_SendError`, handle gracefully
- Thread safety: Use `std::mutex` and `std::condition_variable` for synchronization
- Lua state management: One `lua_State*` per robot instance, stored in registry

### Lua Bindings (bindings/)
- Generated from YAML definitions using `util/parse.py`
- Output: `.lua` files in `build/lua/wpi/` and `.cpp` files for FFI declarations
- FFI pattern: Load shared libraries via `ffi.load()`, use `ffi.cdef()` for declarations
- Object-oriented Lua: Use `luabot.class` for class inheritance
- Module structure: Each module returns a table with methods and constructors

### Lua Runtime
- Package path: Set to include `build/lua/` for development
- Required modules: `wpi.frc.*`, `wpi.hal.*`, `wpi.command.*`, `wpi.math.*`
- Robot entry point: Lua file must return a module table with a `new()` function
- Robot instance: Must have `startCompetition()` method

## Coding Standards

### C++
- Use `snake_case` for functions and variables
- Use `PascalCase` for classes
- Prefer RAII and smart pointers
- Always handle Lua errors with `lua_pcall()`, check return codes
- Extract error messages with `lua_tostring()` before throwing

### Lua
- Use `PascalCase` for classes (e.g., `TimedRobot`, `XboxController`)
- Use `camelCase` for methods and variables
- Use `---@class` annotations for type hints
- Prefer single-quoted strings (`'string'`) over double-quoted strings (`"string"`), unless interpolation or escaping is needed
- Implement classes using the `derive()` pattern from base classes
- Store instance data in `self` table
- **Constructor patterns**: Inconsistent across modules (will be standardized later)
  - Some classes use `ClassName.new(...)` (e.g., `AddressableLED.new(1)`)
  - Others use direct call via `__call` metamethod (e.g., `Pose2d(1, 2, 3)`)
  - Check existing usage in `build/lua/wpi/` when writing tests

## Common Patterns

### Loading Lua C Libraries
```lua
local ffi = require('ffi')
local C = require('wpi.clib.wpiHal').load(false)
```

### Creating Lua Classes
```lua
local BaseClass = require('wpi.frc.BaseClass')
local MyClass = BaseClass.derive()

function MyClass:init()
    self.value = 0
end

return MyClass
```

### Exception Handling in C++
```cpp
try {
    // Lua operations
    if (lua_pcall(L, 0, 1, 0) != 0) {
        const char* err = lua_tostring(L, -1);
        std::string err_msg = err ? err : "unknown error";
        lua_close(L);
        throw std::runtime_error(err_msg);
    }
} catch (const std::exception& e) {
    auto hal_msg = std::string("[luabot]: ") + std::string(e.what());
    HAL_SendError(1, frc::err::Error, 0, hal_msg.c_str(), "", "", 1);
    // Handle gracefully - don't re-throw if at thread boundary
}
```

### Accessing Lua Registry
```cpp
// Store robot instance
lua_pushvalue(L, -1);
lua_setfield(L, LUA_REGISTRYINDEX, "robot_instance");

// Retrieve robot instance
lua_getfield(L, LUA_REGISTRYINDEX, "robot_instance");
```

## File Organization
- `src/luabot.cpp`: Main entry point, robot lifecycle, simulation initialization
- `src/console.c`: Interactive Lua REPL
- `bindings/`: YAML definitions for WPILib bindings
- `build/lua/wpi/`: Generated Lua modules
- `util/robots/`: Example robot implementations
- `test/`: Unit tests (Lua and C++)

## Build System
- Build directory: `build/` (generated)
- Generated bindings: `build/lua/wpi/` (Lua), `build/include/luabot/ffi/` (C++)
- Lua modules must be in package path at runtime
- Cross-compilation: Use Docker for roboRIO builds

## WPILib Integration
- Initialize HAL with `frc::RunHALInitialization()`
- Simulation: Set `HALSIM_EXTENSIONS` env var for GUI/DS socket
- Use `HAL_SendError()` for error reporting to Driver Station
- Respect robot lifecycle: `robotInit()`, `autonomousInit()`, `teleopInit()`, etc.
- Clean shutdown: `HAL_Shutdown()`, `HAL_ExitMain()`

## Testing
- Lua unit tests: Use `luaunit.lua` framework in `test/wpi/` directory
- C++ tests: Standard CMake test framework
- Purposefully test error conditions (missing modules, invalid robot files)
- Always verify clean error handling and shutdown
- **Per-class API testing**:
  - Create one test file per class: `test/wpi/TestClassName.lua`
  - Test construction, methods, edge cases, garbage collection
  - Use `lu.assertTrue()`, `lu.assertEquals()`, etc. for assertions
  - Call `collectgarbage()` between test blocks to verify cleanup
  - **Always add new test files to `test/CMakeLists.txt`** using `luabot_add_api_test(TestName wpi/TestFileName.lua)`
  - Example: `luabot_add_api_test(TestPose2d wpi/TestPose2d.lua)`

## Best Practices
- Never leak `lua_State*` - always close on error paths
- Check all Lua stack operations for success
- Provide clear error messages that help users debug their Lua code
- Log errors before propagating exceptions
- Respect thread boundaries - don't throw across threads
- Use WPILib abstractions over raw HAL when possible
