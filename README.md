# LuaBOT
A system for running LuaJIT powered FRC and other robots.

## Building

### Dependencies
* [CMake](https://cmake.org) - Build system.
* [Python](https://www.python.org/) - Required for yaml parsing and benchmarking.
* [Ninja](https://ninja-build.org/) - Recommended. The build instructions assume you have it.

### Get the Code
This projected includes various dependencies as submodules. Make sure to either clone with submodules.
```bash
git clone https://github.com/snidercs/luabot --recurse-submodules
```

Or if you did a normal clone, initialize them

```bash
git submodule update --init --recursive
```

### Build and Run Tests
The steps here are for a Unix based system but should work on any platform with C++.

```bash
# Configure the build directory
cmake -Bbuild -GNinja -DCMAKE_BUILD_TYPE=Release

# Compile it
cmake --build build --config=Release

# Test it
ctest --test-dir=build
```
