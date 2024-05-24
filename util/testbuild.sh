#!/bin/bash
set -ex

rm -rf buildt
meson setup buildt
meson compile -C buildt
meson test -C buildt
