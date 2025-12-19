#!/bin/sh

# This script cross-compiles LuaJIT for the roboRIO (ARM-based FRC robot controller).
# It builds LuaJIT in static mode with Lua 5.2 compatibility using the WPILib
# cross-compilation toolchain. The 32-bit host compiler is required for the
# amalgamated build process.

wpilib_year="2025"
prefix="/opt/luabot/linuxathena"

set -e

make amalg HOST_CC="gcc -m32" \
    CROSS=arm-frc${wpilib_year}-linux-gnueabi- \
    XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT=1" \
    BUILDMODE="static" \
    PREFIX="$prefix"
make install PREFIX="$prefix"

exit 0
