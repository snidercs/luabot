cmake_minimum_required(VERSION 3.20.0)
project('luabot' VERSION 0.0.1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_library(LuaJIT NAMES luajit-5.1 PATHS /opt/luabot/lib REQUIRED)
find_path(LuaJIT_INCLUDE_DIR
    NAMES luajit.h lua.h lua.hpp
    PATHS /opt/luabot/include/luajit-2.1
    REQUIRED)

add_executable(luabot
    src/console.c
    src/luabot.cpp)

target_link_libraries(luabot PRIVATE ${LuaJIT})
target_include_directories(luabot PRIVATE ${LuaJIT_INCLUDE_DIR})
