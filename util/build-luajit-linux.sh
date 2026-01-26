#!/bin/sh
# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

# This script builds LuaJIT for macOS and roboRIO platforms.
# It compiles LuaJIT separately for x86_64 and ARM64 architectures, then combines
# them into a universal binary using lipo. After creating the macOS universal binary,
# it invokes the Docker build to cross-compile LuaJIT for the roboRIO platform.
# All build artifacts are placed in the dist/ directory.

outdir="`pwd`/3rdparty"
mkdir -p "$outdir"
rm -rf "$outdir"/*

set -e

cd deps/luajit
make amalg \
    XCFLAGS="-DLUAJIT_ENABLE_LUA52COMPAT=1" \
    BUILDMODE="static" \
    PREFIX="/opt/luabot"
make install PREFIX="$outdir"
make clean
cd ../..

exit 0
