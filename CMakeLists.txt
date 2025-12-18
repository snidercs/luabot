cmake_minimum_required(VERSION 3.20.0)
project('luabot' VERSION 0.0.1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(WITH_JAVA OFF)
set(WITH_CSCORE OFF)
set(WITH_PROTOBUF OFF)
set(WITH_TESTS OFF)
add_subdirectory(deps/allwpilib EXCLUDE_FROM_ALL)

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

find_library(LuaJIT NAMES luajit-5.1 PATHS /opt/luabot/lib REQUIRED)
find_path(LuaJIT_INCLUDE_DIR
    NAMES luajit.h lua.h lua.hpp
    PATHS /opt/luabot/include/luajit-2.1
    REQUIRED)

find_package(Python3 REQUIRED COMPONENTS Interpreter)
set(PARSE_PY ${CMAKE_SOURCE_DIR}/util/parse.py)
add_subdirectory(bindings)

add_library(luabot-ffi STATIC
    src/ffi.cpp)

if(NOT WITH_CSCORE)
    target_compile_definitions(luabot-ffi PRIVATE DYNAMIC_CAMERA_SERVER)
endif()

target_include_directories(luabot-ffi PUBLIC
    ${CMAKE_BINARY_DIR}/include
    ${LuaJIT_INCLUDE_DIR}
    ${WPILIB_INCLUDES})

# target_link_libraries(luabot-ffi PUBLIC
#     ${LuaJIT}
#     wpilibc
#     hal
#     ntcore
#     wpiutil)

add_dependencies(luabot-ffi generate_bindings)



# add_executable(luabot
#     src/console.c
#     src/luabot.cpp)

# target_link_libraries(luabot PRIVATE ${LuaJIT})
# target_include_directories(luabot PRIVATE 
#     ${LuaJIT_INCLUDE_DIR})
