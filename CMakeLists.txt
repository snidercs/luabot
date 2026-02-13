# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

cmake_minimum_required(VERSION 3.20.0)
project(luabot VERSION 0.0.1)

option(LUABOT_BUILD_CONSOLE "Build the luabot console application" ON)
option(LUABOT_BUILD_TESTS "Build the unit tests" ON)
option(LUABOT_ROBORIO "Do special things for roboRIO" OFF)

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
set(CMAKE_POSITION_INDEPENDENT_CODE ON)
set(CMAKE_OSX_ARCHITECTURES arm64;x86_64)
set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
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
add_subdirectory(vendordep)

# Install generated C++ binding headers
set(LUABOT_INCLUDE_DIR "include" CACHE STRING "Include directory to install headers and ffi binding code" )
install(DIRECTORY ${CMAKE_BINARY_DIR}/include/luabot
    DESTINATION "${LUABOT_INCLUDE_DIR}"
    COMPONENT Core
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.ipp" PATTERN "*.cpp")

# Install source headers
install(DIRECTORY ${CMAKE_SOURCE_DIR}/include/luabot
    DESTINATION "${LUABOT_INCLUDE_DIR}"
    COMPONENT Core
    FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.h.in" EXCLUDE)

# Install generated Lua binding sources
set(LUABOT_LUA_DIR "share/luajit-2.1" CACHE STRING "Sub path to install lua files" )
install(DIRECTORY ${CMAKE_BINARY_DIR}/lua/wpi
    DESTINATION "${LUABOT_LUA_DIR}"
    COMPONENT Core
    FILES_MATCHING PATTERN "*.lua")
install(DIRECTORY ${CMAKE_BINARY_DIR}/lua/luabot
    DESTINATION "${LUABOT_LUA_DIR}"
    COMPONENT Core
    FILES_MATCHING PATTERN "*.lua")

set(LUABOT_3RDPARTY_DIR ${CMAKE_SOURCE_DIR}/3rdparty)
if(LUABOT_ROBORIO)
    set(LUABOT_3RDPARTY_DIR "${LUABOT_3RDPARTY_DIR}/linuxathena")
endif()

# 3rdparty/bin/* goes to cmake bin dir
install(DIRECTORY ${LUABOT_3RDPARTY_DIR}/bin/
    DESTINATION bin
    USE_SOURCE_PERMISSIONS
    COMPONENT Core)

# 3rdparty/lib/* goes to cmake lib dir
install(DIRECTORY ${LUABOT_3RDPARTY_DIR}/lib/
    DESTINATION lib
    COMPONENT Core)

# 3rdparty/include/* goes to cmake include dir
install(DIRECTORY ${LUABOT_3RDPARTY_DIR}/include/
    DESTINATION include
    COMPONENT Core)

# 3rdparty/share/* goes to cmake share dir
install(DIRECTORY ${LUABOT_3RDPARTY_DIR}/share/
    DESTINATION share
    COMPONENT Core)

if(LUABOT_BUILD_CONSOLE AND NOT LUABOT_ROBORIO)
    # 3rdparty/linuxathena/* goes to cmake prefix slash linuxathena
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/3rdparty/linuxathena/
        DESTINATION linuxathena
        COMPONENT Core)
endif()

if(LUABOT_BUILD_CONSOLE)
    if(WIN32)
        find_library(LuaJIT NAMES luajit PATHS "${CMAKE_SOURCE_DIR}/3rdparty/lib" REQUIRED NO_DEFAULT_PATH)
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
        RUNTIME DESTINATION bin
        COMPONENT Core)
    
    # Enable testing
    if(LUABOT_BUILD_TESTS)
        enable_testing()
        add_subdirectory(test)
    endif()
endif()

# CPack
set(CPACK_PACKAGE_NAME "luabot")
set(CPACK_PACKAGE_VENDOR "LuaBot")
set(CPACK_PACKAGE_CONTACT "LuaBot Developers")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "${LUABOT_DESCRIPTION_SUMMARY}")
set(CPACK_PACKAGE_VERSION "${PROJECT_VERSION}")
set(CPACK_PACKAGE_VERSION_MAJOR "${PROJECT_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR "${PROJECT_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH "${PROJECT_VERSION_PATCH}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY "LuaBot")
set(CPACK_RESOURCE_FILE_README "${PROJECT_SOURCE_DIR}/LICENSES/MIT.txt")
set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSES/MIT.txt")

if(LUABOT_BUILD_CONSOLE)
    if(LINUX)
        set(LUABOT_SYSTEM_NAME "linux")
        string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" LUABOT_PROCESSOR)
        set(CPACK_GENERATOR "DEB")
        set(CPACK_ARCHIVE_COMPONENT_INSTALL OFF)
        set(CPACK_PACKAGING_INSTALL_PREFIX "/usr")
        set(CPACK_DEBIAN_PACKAGE_DEPENDS "libfreetype6;libx11-6;libxext6;libxrandr2;libxinerama1;libxcursor1;libcurl4;libgl1;libstdc++6")
    elseif(APPLE)
        set(LUABOT_SYSTEM_NAME "macos")
        set(LUABOT_PROCESSOR "universal")
        set(CPACK_GENERATOR "productbuild")
        set(CPACK_COMPONENT_INSTALL ON)
        set(CPACK_SET_DESTDIR OFF)
        set(CPACK_PACKAGING_INSTALL_PREFIX "/opt/luabot")
        set(CPACK_PRODUCTBUILD_IDENTIFIER "org.luabot.installer")
    elseif(WIN32)
        set(CPACK_NSIS_PACKAGE_NAME "LuaBot")
        set(LUABOT_SYSTEM_NAME "windows")
        string(TOLOWER "${CMAKE_SYSTEM_PROCESSOR}" LUABOT_PROCESSOR)
        set(CPACK_GENERATOR "NSIS")
        set(CPACK_SET_DESTDIR OFF)
        set(CPACK_PACKAGE_INSTALL_DIRECTORY "LuaBot")
        set(CPACK_COMPONENT_INSTALL ON)
        set(CPACK_PACKAGING_INSTALL_PREFIX "/")
        set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
        set(CPACK_NSIS_MODIFY_PATH OFF)
    endif()
    
    set(LUABOT_PACKAGE_FILE_NAME "${PROJECT_NAME}-${CPACK_PACKAGE_VERSION}-${LUABOT_SYSTEM_NAME}-${LUABOT_PROCESSOR}")
else()
    set(CPACK_GENERATOR "ZIP")
    set(CPACK_PACKAGING_INSTALL_PREFIX "/")
    set(CPACK_ARCHIVE_COMPONENT_INSTALL OFF)

    if(LUABOT_ROBORIO)
        set(LUABOT_SYSTEM_NAME "linuxathena")
    elseif(LINUX)
        set(LUABOT_SYSTEM_NAME "linuxx86-64")
    elseif(APPLE)
        set(LUABOT_SYSTEM_NAME "osxuniversal")
    elseif(WIN32)
        set(LUABOT_SYSTEM_NAME "windowsx86-64")
    endif()

    set(LUABOT_PACKAGE_FILE_NAME "${PROJECT_NAME}-${PROJECT_VERSION}-${LUABOT_SYSTEM_NAME}")
endif()

set(LUABOT_GENERATOR ${CPACK_GENERATOR})
message(STATUS "Using CPack generator: ${LUABOT_GENERATOR}")
set(CPACK_PACKAGE_FILE_NAME "${LUABOT_PACKAGE_FILE_NAME}")

include(CPack)

add_custom_target(installer
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${PROJECT_BINARY_DIR}/_CPack_Packages"
    COMMAND ${CMAKE_COMMAND} --build "${PROJECT_BINARY_DIR}" --target package
    COMMAND ${CMAKE_COMMAND} -E rm -rf "${PROJECT_BINARY_DIR}/_CPack_Packages"
    COMMENT "Cleaning CPack staging and building package"
    VERBATIM
    USES_TERMINAL)
