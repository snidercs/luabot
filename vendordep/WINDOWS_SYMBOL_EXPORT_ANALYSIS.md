# Windows LuaJIT Symbol Export Analysis

## Issue Summary

When using the LuaBot.json vendordep in a WPILib C++ project on Windows, linking fails with unresolved external symbols for all LuaJIT API functions (`lua_gettop`, `lua_settop`, `lua_close`, etc.).

**Error Example:**
```
robot.obj : error LNK2019: unresolved external symbol lua_close referenced in function "void __cdecl luabot::detail::run_lua_robot(class std::mutex &,struct lua_State * *,char const *)"
scripting.obj : error LNK2001: unresolved external symbol lua_close
```

## Root Cause Analysis

### The Problem Chain

1. **LuaJIT Build Output** (`util/luajit.py`, lines 111-112)
   - LuaJIT's `msvcbuild.bat` produces: `lua51.lib` (static library)
   - Gets copied to: `3rdparty/lib/lua51.lib`
   - Built without symbol export declarations

2. **LuaBot's Internal Build** (`CMakeLists.txt`, line 135)
   - CMake finds library: `find_library(LuaJIT NAMES lua51 ...)`
   - **This works for local builds** because linking happens within same build tree
   - No symbol export declarations needed for internal linking

3. **Vendordep Packaging** (`vendordep/vendordep.py`, lines 102-107)
   - Script **renames** `lua51.lib` → `luajit.lib` during zip creation:
     ```python
     if file_path.suffix == '.lib':
         arcname = os.path.join(top_level_dir, 'lib', 'luajit.lib')
     ```
   - Rename alone doesn't add symbol exports

4. **Vendordep Declaration** (`vendordep/LuaBot.json.in`, line 49)
   - Declares: `"libName": "luajit"`
   - Tells GradleRIO to link against `luajit.lib`

### Why Symbols Are Unresolved

**On Windows, static library symbols must be explicitly exported** via:
- `/EXPORT` linker flags for each symbol
- Module Definition (.def) file during build
- Building as DLL (shared library) - symbols auto-exported

The `lua51.lib` produced by LuaJIT's `msvcbuild.bat` is a **static library with no export declarations**. Simply renaming it to `luajit.lib` doesn't change this.

When external projects (like FRC robot code) try to link against this renamed library, the linker can't find the symbol definitions because they were never exported.

### Why Local Builds Work

LuaBot's local CMake builds succeed because:
- The `luabot` executable is built in the same CMake project as the library dependency
- CMake's internal linking doesn't require Windows export declarations
- The linker can access symbols within the same build tree
- No symbol export boundary is crossed

## Solutions

### Option 1: Build LuaJIT as DLL (Recommended)

**Description:** Modify the build to produce a shared library (DLL) instead of static library.

**Changes Required:**
- Modify `util/luajit.py`:
  - Change Windows build to produce DLL instead of static lib
  - Update `msvcbuild.bat` call or create custom build script
- Update `vendordep/vendordep.py`:
  - Package both `luajit.dll` and `luajit.lib` (import library)
  - Handle DLL vs static library naming
- Modify `vendordep/LuaBot.json.in`:
  - Change line 51: `"sharedLibrary": true` for luajit-cpp dependency
- Update `CMakeLists.txt`:
  - Handle DLL for local builds
  - Copy DLL to output directory on Windows

**Pros:**
- Standard Windows practice for distributing libraries
- Symbols automatically exported from DLL
- Aligns with how most WPILib vendordeps work
- GradleRIO handles DLL deployment automatically
- No maintenance of export lists needed

**Cons:**
- Users must distribute DLL with robot code
- Slightly larger deployment size
- Requires building LuaJIT with different flags

**Implementation Complexity:** Medium

### Option 2: Module Definition File (.def)

**Description:** Create a `.def` file listing all exported symbols and rebuild static library with proper exports.

**Changes Required:**
- Create `vendordep/luajit.def`:
  - List all Lua API functions to export
  - Include lua_*, luaL_*, luaopen_* symbols
- Modify `util/luajit.py`:
  - Update Windows build to use `.def` file
  - Modify `msvcbuild.bat` or create wrapper script
- No changes to `LuaBot.json.in` (stays static)

**Example `.def` file structure:**
```def
LIBRARY luajit
EXPORTS
    lua_close
    lua_gettop
    lua_settop
    lua_checkstack
    ; ... (all ~100+ Lua API functions)
```

**Pros:**
- Keeps static linking model
- Smaller deployment (no separate DLL)
- Clean solution for symbol exports

**Cons:**
- Must maintain export list (100+ functions)
- Must update when LuaJIT API changes
- Requires rebuilding LuaJIT with custom flags
- Non-standard for LuaJIT builds

**Implementation Complexity:** Medium-High

### Option 3: Export Wrapper DLL

**Description:** Create a thin wrapper DLL that re-exports all LuaJIT functions.

**Changes Required:**
- Create new `vendordep/luajit-wrapper.c`:
  - Load `lua51.lib` statically
  - Re-export all functions via DLL
- Update build system to compile wrapper
- Package wrapper DLL instead of static lib
- Set `"sharedLibrary": true` in vendordep JSON

**Example wrapper (partial):**
```c
#define LUA_BUILD_AS_DLL
#include <lua.h>

__declspec(dllexport) void lua_close(lua_State* L) {
    return lua_close_impl(L);  // Forward to static lib
}
// ... repeat for all functions
```

**Pros:**
- Maintains static LuaJIT build
- Adds clean export layer
- Can optimize/track calls if needed

**Cons:**
- High maintenance burden
- Must update for every LuaJIT API change
- Adds indirection layer (minimal performance impact)
- Complex to maintain

**Implementation Complexity:** High

### Option 4: Documentation Workaround (Temporary)

**Description:** Document the limitation and provide workaround instructions.

**Changes Required:**
- Update README.md with Windows vendordep limitations
- Document manual build/link process
- Add troubleshooting section

**Instructions for users:**
1. Build LuaJIT locally using build scripts
2. Configure GradleRIO to use local `lua51.lib`
3. Only use vendordep for headers and Lua modules

**Pros:**
- No code changes needed
- Quick to implement
- Allows vendordep development to continue

**Cons:**
- Defeats purpose of vendordep (easy consumption)
- Poor user experience
- Not a real solution

**Implementation Complexity:** Low (documentation only)

## Recommendation

**Implement Option 1 (DLL Distribution)**

This is the recommended solution because:

1. **Standard Practice**: DLLs are the standard way to distribute libraries on Windows
2. **Zero Maintenance**: Symbol exports are automatic, no lists to maintain
3. **WPILib Alignment**: Most vendordeps use shared libraries on Windows
4. **GradleRIO Support**: Built-in DLL deployment to robot
5. **Future-Proof**: Works with any LuaJIT version without updates
6. **Simpler Build**: Less complexity than .def file management

The only downside (DLL deployment) is already handled by the FRC build system and is standard practice for Windows FRC development.

## Implementation Notes

### For Option 1 (DLL Build)

**LuaJIT Build Changes:**
LuaJIT's build system doesn't have a simple DLL flag. You'll need to either:
- Modify `src/msvcbuild.bat` to link as DLL
- Create custom CMake build for LuaJIT on Windows
- Use existing LuaJIT DLL builds from external sources

**Recommended Approach:**
Replace the custom LuaJIT build with pre-built DLL distribution:
- Download official LuaJIT Windows DLL builds
- Package in vendordep
- Simplifies maintenance

### Testing

After implementing any solution:
1. Build vendordep artifacts on Windows
2. Create test WPILib C++ project
3. Add LuaBot.json vendordep
4. Verify link succeeds with Lua API calls
5. Test on robot/simulation

## Related Files

- `vendordep/LuaBot.json.in` - Vendordep configuration
- `vendordep/vendordep.py` - Packaging script
- `util/luajit.py` - LuaJIT build script
- `CMakeLists.txt` - Main build configuration (lines 135-137)

## References

- **LuaJIT Windows Build**: https://luajit.org/install.html#windows
- **MSVC Symbol Export**: https://docs.microsoft.com/en-us/cpp/build/exporting-from-a-dll
- **WPILib Vendordeps**: https://docs.wpilib.org/en/stable/docs/software/vscode-overview/3rd-party-libraries.html
- **GradleRIO Docs**: https://github.com/wpilibsuite/GradleRIO

## Question from Reporter

> Our vendordep script renames the *.lib from lua51.lib to luajit.lib, maybe this is the cause???

**Answer:** Yes, this is the root cause. The rename itself isn't the problem - the issue is that `lua51.lib` (the source) is a static library with no symbol exports. Renaming it doesn't add exports. Windows requires explicit symbol exports for external linking, which the LuaJIT static build doesn't provide.

The solution is not to avoid renaming, but rather to either:
- Build as DLL (symbols auto-exported)
- Add export declarations to static build (.def file)
- Use a wrapper that provides exports
