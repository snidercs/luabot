[![REUSE](https://github.com/snidercs/luabot/actions/workflows/reuse.yaml/badge.svg)](https://github.com/snidercs/luabot/actions/workflows/reuse.yaml) [![Build](https://github.com/snidercs/luabot/actions/workflows/build.yaml/badge.svg)](https://github.com/snidercs/luabot/actions/workflows/build.yaml)

# LuaBot
A system for running LuaJIT powered FRC and other robots.

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
