# LuaBOT
A system for running LuaJIT powered FRC and other robots.

## Building

### Dependencies
* [Meson](https://mesonbuild.com) - Build system.
* [Python](https://www.python.org/) - Required by meson.
* [Boost](https://boost.org) - test suite headers for tests.

### Build and Run Tests
The steps here are for a Linux system but should work on any platform with C++ and boost available.

```bash
# run the setup/configure command. needs done once.
# called build is where binaries are produced.
meson setup build

# compile it
# the "-C build" is specifying that a sub directory
meson compile -C build

# test it
meson test -C build
```

_Note: the steps above might need additional options on a OSX or Windows, but the general concept is the same_
