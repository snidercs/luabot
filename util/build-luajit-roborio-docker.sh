#!/bin/sh

# This script builds LuaJIT for roboRIO using Docker and extracts the compiled artifacts.
# It creates a Docker image with the cross-compilation toolchain, builds LuaJIT inside
# the container, then copies the resulting binaries to the local dist/ directory.

outdir="`pwd`/3rdparty"

set -e
docker build . -t snidercs/luabot
docker create --name luajit_temp snidercs/luabot

mkdir -p "${outdir}"
rm -rf "${outdir}"/linuxathena

docker cp luajit_temp:/opt/luabot/linuxathena "${outdir}/linuxathena"
docker rm luajit_temp

exit 0
