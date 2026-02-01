Architecture
============

LuaBot is designed to bridge Lua scripting with WPILib's robot control framework.

System Overview
---------------

LuaBot consists of three main layers:

1. **C++ Core**: Robot lifecycle management and Lua state handling
2. **FFI Bindings**: LuaJIT FFI declarations for WPILib HAL and libraries
3. **Lua Runtime**: Class system, modules, and robot implementations

Components
----------

C++ Layer (src/, include/)
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The C++ layer handles:

* HAL initialization via ``frc::RunHALInitialization()``
* Lua state creation and management
* Robot lifecycle: ``robotInit()``, ``autonomousInit()``, ``teleopInit()``, etc.
* Exception handling and error reporting
* Simulation integration

Key files:

* ``src/luabot.cpp``: Main entry point, robot lifecycle
* ``src/console.c``: Interactive Lua REPL
* ``include/luabot/``: C++ headers

Binding Layer (bindings/)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Bindings are generated from YAML definitions:

* YAML files in ``bindings/`` describe WPILib APIs
* ``util/parse.py`` generates Lua and C++ code
* Output: ``build/lua/wpi/`` (Lua modules) and ``build/include/luabot/ffi/`` (C++ headers)

FFI pattern::

    local ffi = require('ffi')
    local C = require('wpi.clib.wpiHal').load(false)
    
    ffi.cdef[[
        // C declarations
    ]]

Lua Runtime (bindings/luabot/, build/lua/wpi/)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

The Lua runtime provides:

* ``luabot.class``: Class system with inheritance
* WPILib modules: ``wpi.frc.*``, ``wpi.hal.*``, ``wpi.command.*``, ``wpi.math.*``
* Package path configuration
* Module loading system

Class System
------------

LuaBot uses a custom class system for OOP::

    local class = require('luabot.class')
    local BaseClass = require('wpi.frc.BaseClass')
    
    local MyClass = class(BaseClass)
    
    function MyClass.init(instance)
        instance.value = 0
    end
    
    function MyClass:method()
        return self.value
    end

Design Principles
-----------------

1. **Match Java WPILib**: API design mirrors Java WPILib for familiarity
2. **No Workarounds**: Implement features as designed, no shortcuts
3. **Clean Separation**: C++ handles lifecycle, Lua handles logic
4. **Type Safety**: Use Lua type annotations for IDE support
5. **Error Handling**: Catch exceptions at thread boundaries, log via HAL

Thread Safety
-------------

* One ``lua_State*`` per robot instance
* Stored in Lua registry: ``LUA_REGISTRYINDEX["robot_instance"]``
* Use ``std::mutex`` for synchronization
* Never throw across thread boundaries

Build System
------------

* **CMake**: Project configuration and dependency management
* **Ninja**: Fast parallel builds
* **Generated code**: Bindings auto-generated during build
* **Cross-compilation**: Docker for roboRIO builds

File Organization
-----------------

::

    luabot/
    ├── src/               # C++ implementation
    ├── include/           # C++ headers
    ├── bindings/          # YAML definitions & Lua source
    ├── build/lua/wpi/     # Generated Lua modules
    ├── test/              # Unit tests
    ├── util/              # Build scripts & tools
    └── examples/          # Example robots

Simulation
----------

LuaBot integrates with WPILib simulation:

* Set ``HALSIM_EXTENSIONS`` for GUI/DS socket
* Use standard WPILib simulation tools
* Full HAL simulation support

For more details, see the inline documentation in the source code.
