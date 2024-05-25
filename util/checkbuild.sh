#!/bin/bash
set -ex

[ -z "$(which ccache)" ] || ccache -C

rm -rf tbuild && \
    meson setup tbuild && \
    meson compile -C tbuild && \
    meson test -C tbuild && \
    rm -rf tbuild
