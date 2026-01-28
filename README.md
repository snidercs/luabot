[![REUSE](https://github.com/snidercs/luabot/actions/workflows/reuse.yaml/badge.svg)](https://github.com/snidercs/luabot/actions/workflows/reuse.yaml) [![Build](https://github.com/snidercs/luabot/actions/workflows/build.yaml/badge.svg)](https://github.com/snidercs/luabot/actions/workflows/build.yaml)

# LuaBot
A system for running LuaJIT powered FRC and other robots.

## Why LuaBot?

**Easier than Java/Python. Faster than C++.**

LuaBot brings the best of both worlds to FRC robot programming:

### Performance
- **Faster than C++**: Benchmark tests show Lua 1.33x faster than C++ for typical robot code patterns
- **LuaJIT magic**: JIT compilation to native code with runtime trace optimization
- **Zero-copy FFI**: Direct C struct access without marshaling overhead
- **Optimized hot paths**: JIT specializes code paths at runtime better than static compilation

### Simplicity
- **Less boilersome**: No `public class`, `package` declarations, or verbose imports
- **Cleaner syntax**: More concise than Java/C++, more structured than Python
- **Dynamic typing**: Faster prototyping without type declaration overhead
- **Simple class system**: `local MyClass = class(BaseClass)` - that's it
- **Direct FFI access**: `ffi.load()` and `ffi.cdef()` for zero-ceremony C interop

### FRC-Optimized
- **Command-based framework**: Full WPILib command framework with triggers and subsystems
- **Hardware abstraction**: Complete HAL bindings for all FRC devices
- **Simulation support**: Full simulator integration with Glass and Driver Station
- **No compile times**: Edit code and run immediately - perfect for rapid iteration
- **Interactive REPL**: Debug and test code live while your robot is running

### Real Results
```lua
-- Benchmark: 2M iterations of robot periodic code
-- Lua:  1.50s
-- C++:  2.00s
-- Result: Lua is 1.33x faster
```

For FRC teams, this means faster iteration, easier debugging, and better runtime performance - a genuine win across all dimensions.

## Building

### Dependencies
* [CMake](https://cmake.org) - Build system.
* [Python](https://www.python.org/) - Required for yaml parsing and benchmarking.
* [Ninja](https://ninja-build.org/) - Recommended. The build instructions assume you have it.
* [Docker](https://docker.com) - Required to cross-compile LuaJIT for roboRIO
* [CCache](https://ccache.dev/) - Recommended for faster rebuilds.

### Get the Code
This projected includes various dependencies as submodules. Make sure to either clone with submodules.
```bash
git clone https://github.com/snidercs/luabot --recurse-submodules
```

Or if you did a normal clone, initialize them

```bash
git submodule update --init --recursive
```
### LuaJIT
LuaJIT needs built outside of cmake. We have scripting for that.
**Linux**
```bash
sh util/build-luajit-linux.sh
```
**macOS**
```bash
sh util/build-luajit-macos.sh
```
**Windows**
_TODO: coming soon..._

### YAML Python
Your system might not have the yaml library for Python.

### Build and Run Tests
The steps here are for a Unix based system but should work on any platform with C++.

```bash
# Configure the build directory
cmake -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release

# Compile it
ninja -C build

# Test it
ninja -C build test
```
