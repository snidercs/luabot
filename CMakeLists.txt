cmake_minimum_required(VERSION 3.20.0)
project('luabot' VERSION 0.0.1)

option(LUABOT_BUILD_CONSOLE "Build the luabot console application" ON)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Generate version header
configure_file(
    ${CMAKE_SOURCE_DIR}/include/luabot/version.h.in
    ${CMAKE_BINARY_DIR}/include/luabot/version.h
    @ONLY
)

set(WITH_JAVA OFF)
set(WITH_CSCORE OFF)
set(WITH_PROTOBUF OFF)
set(WITH_TESTS OFF)
set(WITH_GUI ON)

if(LUABOT_BUILD_CONSOLE)
    add_subdirectory(deps/allwpilib)
else()
    add_subdirectory(deps/allwpilib EXCLUDE_FROM_ALL)
endif()

get_target_property(wpilibc_INCLUDE_DIRS wpilibc INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(wpiutil_INCLUDE_DIRS wpiutil INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(hal_INCLUDE_DIRS hal INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(ntcore_INCLUDE_DIRS ntcore INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(wpimath_INCLUDE_DIRS wpimath INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(apriltag_INCLUDE_DIRS apriltag INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(wpilibc_INCLUDE_DIRS wpilibc INTERFACE_INCLUDE_DIRECTORIES)
get_target_property(wpilibNewCommands_INCLUDE_DIRS wpilibNewCommands INTERFACE_INCLUDE_DIRECTORIES)
list(APPEND WPILIB_INCLUDES 
    ${hal_INCLUDE_DIRS} 
    ${wpilibc_INCLUDE_DIRS} 
    ${wpiutil_INCLUDE_DIRS} 
    ${ntcore_INCLUDE_DIRS}
    ${wpimath_INCLUDE_DIRS}
    ${apriltag_INCLUDE_DIRS}
    ${wpilibNewCommands_INCLUDE_DIRS})

find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(PARSE_PY ${CMAKE_SOURCE_DIR}/util/parse.py)
add_subdirectory(bindings)

# Install generated C++ binding headers
set(LUABOT_INCLUDE_DIR "include" CACHE STRING "Include directory to install headers and ffi binding code" )
install(DIRECTORY ${CMAKE_BINARY_DIR}/include/luabot
    DESTINATION "${LUABOT_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.ipp" PATTERN "*.cpp")

# Install source headers
install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/luabot
    DESTINATION "${LUABOT_INCLUDE_DIR}"
    FILES_MATCHING PATTERN "*.h" PATTERN "*.h.in" EXCLUDE)

# Install generated Lua binding sources
set(LUABOT_LUA_DIR "share/luajit-2.1" CACHE STRING "Sub path to install lua files" )
install(DIRECTORY ${CMAKE_BINARY_DIR}/lua/wpi
    DESTINATION "${LUABOT_LUA_DIR}"
    FILES_MATCHING PATTERN "*.lua")

if(LUABOT_BUILD_CONSOLE)
    find_library(LuaJIT NAMES luajit-5.1 PATHS "${CMAKE_SOURCE_DIR}/3rdparty/lib" REQUIRED)
    find_path(LuaJIT_INCLUDE_DIR
        NAMES luajit.h lua.h lua.hpp
        PATHS "${CMAKE_SOURCE_DIR}/3rdparty/include/luajit-2.1"
        REQUIRED)

    add_library(luabot-ffi STATIC
        src/ffi.cpp)

    if(NOT WITH_CSCORE)
        target_compile_definitions(luabot-ffi PRIVATE DYNAMIC_CAMERA_SERVER)
    endif()

    target_include_directories(luabot-ffi PUBLIC
        ${CMAKE_BINARY_DIR}/include
        ${LuaJIT_INCLUDE_DIR}
        ${WPILIB_INCLUDES})

    target_link_libraries(luabot-ffi PUBLIC
        wpilibc
        wpilibNewCommands
        hal
        ntcore
        wpiutil
        wpimath
        apriltag)

    add_dependencies(luabot-ffi generate_bindings)

    add_executable(luabot
        src/console.c
        src/luabot.cpp)

    target_link_libraries(luabot PRIVATE 
        ${LuaJIT}
        wpilibc
        wpilibNewCommands
        hal
        ntcore
        wpiutil
        wpimath
        apriltag)

    # Force load all symbols from static library for FFI dlsym lookup
    if(APPLE)
        target_link_options(luabot PRIVATE -Wl,-force_load,$<TARGET_FILE:luabot-ffi>)
        target_link_options(luabot PRIVATE -Wl,-export_dynamic)
    elseif(UNIX)
        target_link_options(luabot PRIVATE -Wl,--whole-archive $<TARGET_FILE:luabot-ffi> -Wl,--no-whole-archive)
        target_link_options(luabot PRIVATE -Wl,--export-dynamic)
    else()
        target_link_libraries(luabot PRIVATE luabot-ffi)
    endif()

    add_dependencies(luabot luabot-ffi)

    # Set RPATH for finding shared libraries
    set_target_properties(luabot PROPERTIES
        INSTALL_RPATH "@executable_path/../lib"
        BUILD_WITH_INSTALL_RPATH FALSE
        MACOSX_RPATH TRUE)

    target_include_directories(luabot PRIVATE 
        ${CMAKE_BINARY_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${LuaJIT_INCLUDE_DIR})

    install(TARGETS luabot
        RUNTIME DESTINATION bin)

    # Enable testing
    enable_testing()
    add_subdirectory(test)
endif()
