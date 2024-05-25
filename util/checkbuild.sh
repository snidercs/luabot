#!/bin/bash
set -e
rm -rf tbuild && \
    meson setup tbuild &&
    meson compile -C tbuild &&
    meson test -C tbuild &&
    rm -rf tbuild
