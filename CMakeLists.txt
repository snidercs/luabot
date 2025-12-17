cmake_minimum_required(VERSION 3.20.0)
project('luabot' VERSION 0.0.1)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(WPILib_INCLUDE_DIRS PUBLIC
    deps/allwpilib/wpilibcIntegrationTests/src/main/native/include
    deps/allwpilib/wpiutil/src/test/native/include
    deps/allwpilib/wpiutil/src/main/native/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/mpack/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/memory/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/sigslot/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/expected/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/argparse/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/debugging/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/llvm/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/json/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/fmtlib/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/nanopb/include
    deps/allwpilib/wpiutil/src/main/native/thirdparty/protobuf/include
    deps/allwpilib/wpilibc/src/generated/main/native/include
    deps/allwpilib/wpilibc/src/test/native/include
    deps/allwpilib/wpilibc/src/generate/main/native/include
    deps/allwpilib/wpilibc/src/main/native/include
    deps/allwpilib/wpilibNewCommands/src/generated/main/native/include
    deps/allwpilib/wpilibNewCommands/src/generate/main/native/include
    deps/allwpilib/wpilibNewCommands/src/main/native/include
    deps/allwpilib/apriltag/src/main/native/include
    deps/allwpilib/apriltag/src/main/native/thirdparty/apriltag/include
    deps/allwpilib/wpinet/src/main/native/include
    deps/allwpilib/wpinet/src/main/native/thirdparty/tcpsockets/include
    deps/allwpilib/wpinet/src/main/native/thirdparty/libuv/include
    deps/allwpilib/wpimath/src/test/native/include
    deps/allwpilib/wpimath/src/main/native/include
    deps/allwpilib/wpimath/src/main/native/thirdparty/gcem/include
    deps/allwpilib/wpimath/src/main/native/thirdparty/eigen/include
    deps/allwpilib/wpimath/src/main/native/thirdparty/sleipnir/include
    deps/allwpilib/hal/src/generated/main/native/include
    deps/allwpilib/hal/src/main/native/include
    deps/allwpilib/sysid/src/main/native/include
    deps/allwpilib/crossConnIntegrationTests/src/main/native/include
    deps/allwpilib/xrpVendordep/src/main/native/include
    deps/allwpilib/fieldImages/src/main/native/include
    deps/allwpilib/simulation/halsim_xrp/src/main/native/include
    deps/allwpilib/simulation/halsim_ws_client/src/main/native/include
    deps/allwpilib/simulation/halsim_ws_core/src/main/native/include
    deps/allwpilib/simulation/halsim_ds_socket/src/main/native/include
    deps/allwpilib/simulation/halsim_gui/src/main/native/include
    deps/allwpilib/simulation/halsim_ws_server/src/test/native/include
    deps/allwpilib/simulation/halsim_ws_server/src/main/native/include
    deps/allwpilib/glass/src/libnt/native/include
    deps/allwpilib/glass/src/lib/native/include
    deps/allwpilib/wpical/src/main/native/include
    deps/allwpilib/wpical/src/main/native/thirdparty/libdogleg/include
    deps/allwpilib/wpical/src/main/native/thirdparty/mrcal_java/include
    deps/allwpilib/wpical/src/main/native/thirdparty/mrcal/include
    deps/allwpilib/romiVendordep/src/main/native/include
    deps/allwpilib/ntcore/src/generated/main/native/include
    deps/allwpilib/ntcore/src/generate/main/native/include
    deps/allwpilib/ntcore/src/main/native/include
    deps/allwpilib/cscore/src/main/native/include
    deps/allwpilib/ntcoreffi/src/main/native/include
    deps/allwpilib/wpigui/src/main/native/include
    deps/allwpilib/cameraserver/src/main/native/include
)

find_library(LuaJIT NAMES luajit-5.1 PATHS /opt/luabot/lib REQUIRED)
find_path(LuaJIT_INCLUDE_DIR
    NAMES luajit.h lua.h lua.hpp
    PATHS /opt/luabot/include/luajit-2.1
    REQUIRED)

add_library(luabot-ffi STATIC)
target_include_directories(luabot-ffi PRIVATE 
    ${WPILib_INCLUDE_DIRS})
target_sources(luabot-ffi PRIVATE
    bindings/frc/functions.cpp)

add_executable(luabot
    src/console.c
    src/luabot.cpp)

target_link_libraries(luabot PRIVATE ${LuaJIT})
target_include_directories(luabot PRIVATE 
    ${LuaJIT_INCLUDE_DIR})
