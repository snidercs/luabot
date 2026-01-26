#!/bin/sh
# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

# This script cross-compiles LuaJIT for the roboRIO (ARM-based FRC robot controller).
# It builds LuaJIT in static mode with Lua 5.2 compatibility using the WPILib
# cross-compilation toolchain. The 32-bit host compiler is required for the
# amalgamated build process.

wpilib_year="2026"
prefix="/opt/luabot/linuxathena"

outdir="`pwd`/3rdparty/linuxathena"
mkdir -p "$outdir"
rm -rf "$outdir"/*

set -e

cd deps/luajit
make amalg HOST_CC="gcc -m32" \
    CROSS=arm-frc${wpilib_year}-linux-gnueabi- \
    XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT=1" \
    BUILDMODE="static" \
    PREFIX="$prefix"
make install PREFIX="$outdir"
cd ../..

exit 0
