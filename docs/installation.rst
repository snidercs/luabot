Installation
============

Prerequisites
-------------

* CMake 3.20 or higher
* Ninja build system
* C++20 compatible compiler
* Git

Building from Source
--------------------

Clone the repository::

    git clone https://github.com/your-org/luabot.git
    cd luabot

Build the project::

    mkdir build
    cd build
    cmake -G Ninja ..
    ninja

Installing Dependencies
-----------------------

macOS
~~~~~

::

    brew install cmake ninja

Linux
~~~~~

::

    sudo apt-get install cmake ninja-build

Windows
~~~~~~~

Download and install CMake and Ninja from their official websites.

roboRIO
-------

Cross-compilation for roboRIO requires the FRC toolchain. See the build scripts in ``util/`` for details.

Verifying Installation
----------------------

Run the test suite::

    cd build
    ctest

Next Steps
----------

See :doc:`getting-started` to create your first robot program.
