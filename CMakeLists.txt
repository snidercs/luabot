# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.20.0)
project('luabot' VERSION 0.0.1)

option(LUABOT_BUILD_CONSOLE "Build the luabot console application" ON)
option(LUABOT_BUILD_TESTS "Build the unit tests" ON)

# Enable ccache if available
find_program(CCACHE_PROGRAM ccache)
if(CCACHE_PROGRAM)
    message(STATUS "Found ccache: ${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
else()
    message(STATUS "ccache not found")
endif()

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Generate version header
configure_file(
    ${CMAKE_SOURCE_DIR}/include/luabot/version.h.in
    ${CMAKE_BINARY_DIR}/include/luabot/version.h
    @ONLY
)

find_package(OpenCV QUIET)

set(WITH_JAVA OFF)
if(OpenCV_FOUND)
    set(WITH_CSCORE ON)
    message(STATUS "OpenCV found: enabling cscore")
else()
    set(WITH_CSCORE OFF)
    message(STATUS "OpenCV not found: disabling cscore")
endif()
set(WITH_PROTOBUF OFF)
set(WITH_TESTS OFF)
set(WITH_GUI ON)

if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release)
endif()

if(LUABOT_BUILD_CONSOLE)
    add_subdirectory(deps/allwpilib)
else()
    add_subdirectory(deps/allwpilib EXCLUDE_FROM_ALL)
endif()

find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(PARSE_PY ${CMAKE_SOURCE_DIR}/util/parse.py)

# Check if Python yaml module is available
execute_process(
    COMMAND ${Python3_EXECUTABLE} -c "import yaml"
    RESULT_VARIABLE YAML_CHECK_RESULT
    OUTPUT_QUIET
    ERROR_QUIET
)
if(NOT YAML_CHECK_RESULT EQUAL 0)
    message(FATAL_ERROR "Python yaml module not found. Please install 'pyyaml' with pip")
endif()

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

# 3rdparty/bin/* goes to cmake bin dir
install(DIRECTORY ${CMAKE_SOURCE_DIR}/3rdparty/bin/
    DESTINATION bin
    USE_SOURCE_PERMISSIONS)

# 3rdparty/lib/* goes to cmake lib dir
install(DIRECTORY ${CMAKE_SOURCE_DIR}/3rdparty/lib/
    DESTINATION lib)

# 3rdparty/include/* goes to cmake include dir
install(DIRECTORY ${CMAKE_SOURCE_DIR}/3rdparty/include/
    DESTINATION include)

# 3rdparty/share/* goes to cmake share dir
install(DIRECTORY ${CMAKE_SOURCE_DIR}/3rdparty/share/
    DESTINATION share)

# 3rdparty/linuxathena/* goes to cmake prefix slash linuxathena
install(DIRECTORY ${CMAKE_SOURCE_DIR}/3rdparty/linuxathena/
    DESTINATION linuxathena)

if(LUABOT_BUILD_CONSOLE)
    if(WIN32)
        find_library(LuaJIT NAMES lua51 PATHS "${CMAKE_SOURCE_DIR}/3rdparty/lib" REQUIRED NO_DEFAULT_PATH)
    else()
        find_library(LuaJIT NAMES luajit-5.1 PATHS "${CMAKE_SOURCE_DIR}/3rdparty/lib" REQUIRED NO_DEFAULT_PATH)
    endif()
    find_path(LuaJIT_INCLUDE_DIR
        NAMES luajit.h lua.h lua.hpp
        PATHS "${CMAKE_SOURCE_DIR}/3rdparty/include/luajit-2.1"
        REQUIRED NO_DEFAULT_PATH)

    add_executable(luabot
        src/console.c
        src/luabot.cpp)
    
    # Ensure console subsystem on Windows
    if(WIN32)
        set_target_properties(luabot PROPERTIES
            LINK_FLAGS "/SUBSYSTEM:CONSOLE")
    endif()
    
    add_dependencies(luabot generate_bindings)
    target_link_libraries(luabot PRIVATE 
        ${LuaJIT}
        wpilibc
        wpilibNewCommands
        hal
        ntcore
        wpiutil
        wpimath
        apriltag)
    if(NOT WITH_CSCORE)
        target_compile_definitions(luabot PRIVATE DYNAMIC_CAMERA_SERVER)
    endif()
    
    # Copy WPILib DLLs to binary directory on Windows
    if(WIN32)
        add_custom_command(TARGET luabot POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wpilibc>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wpilibNewCommands>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:hal>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wpimath>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wpiutil>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:wpinet>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:ntcore>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:halsim_gui>
                $<TARGET_FILE_DIR:luabot>
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                $<TARGET_FILE:halsim_ds_socket>
                $<TARGET_FILE_DIR:luabot>
            COMMENT "Copying WPILib and HAL simulation DLLs to binary directory"
        )
    endif()

    # Export symbols for FFI dlsym lookup
    if(WIN32)
        # On Windows, symbols from DLLs are already accessible
        # If needed, use /EXPORT flags or .def file for executable exports
        # set_target_properties(luabot PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
    elseif(APPLE)
        target_link_options(luabot PRIVATE -Wl,-export_dynamic)
    elseif(UNIX)
        target_link_options(luabot PRIVATE -Wl,--export-dynamic)
    endif()

    target_include_directories(luabot PRIVATE 
        ${CMAKE_BINARY_DIR}/include
        ${CMAKE_CURRENT_SOURCE_DIR}/include
        ${LuaJIT_INCLUDE_DIR})

    # Set RPATH for installed binary to match wpilib libraries
    set_target_properties(luabot PROPERTIES
        INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

    install(TARGETS luabot
        RUNTIME DESTINATION bin)
    
    # Enable testing
    if(LUABOT_BUILD_TESTS)
        enable_testing()
        add_subdirectory(test)
    endif()
endif()
