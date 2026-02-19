// SPDX-FileCopyrightText: Michael Fisher @mfisher31
// SPDX-License-Identifier: MIT

#include <cstdlib>
#include <cstring>
#include <iostream>

#include <luabot/luabot.hpp>
#include <luabot/version.h>

#if defined(NDEBUG) || defined(_NDEBUG)
#    define LUABOT_SIM_EXTENSIONS "halsim_ds_socket:halsim_gui"
#else
#    define LUABOT_SIM_EXTENSIONS "halsim_ds_socketd:halsim_guid"
#endif

extern "C" int luabot_console (int argc, char* argv[]);

namespace luabot {
enum class Command {
    none,
    sim
};

struct Options {
    bool version { false };
    Command command { Command::none };
    std::string lua_file;
};

inline static void init_simulation() {
    // Load halsim_gui if HALSIM_EXTENSIONS is not already set
    // User can override with environment variable
    auto extensions = std::getenv ("HALSIM_EXTENSIONS");
    if (nullptr == extensions || strlen (extensions) == 0) {
#ifdef _WIN32
        _putenv_s ("HALSIM_EXTENSIONS", LUABOT_SIM_EXTENSIONS);
#else
        setenv ("HALSIM_EXTENSIONS", LUABOT_SIM_EXTENSIONS, 1);
#endif
    }
}

inline static const luabot::Options parse_options (int argc, char* argv[]) {
    luabot::Options opts;

    for (int i = 1; i < argc; ++i) {
        if (std::strcmp (argv[i], "--version") == 0 || std::strcmp (argv[i], "-v") == 0) {
            opts.version = true;
        } else if (std::strcmp (argv[i], "sim") == 0) {
            opts.command = luabot::Command::sim;
            if (i + 1 < argc && argv[i + 1][0] != '-')
                opts.lua_file = argv[i + 1];
            else
                opts.lua_file = "robot.lua";
        }
    }

    return opts;
}

inline static void print_version() {
    std::cout << "LuaBot " << LUABOT_VERSION " -- Copyright 2024-2025 Michael Fisher @mfisher31" << std::endl
              << LUAJIT_VERSION " -- " LUAJIT_COPYRIGHT ". " LUAJIT_URL << std::endl;
}

} // namespace luabot

int main (int argc, char* argv[]) {
    using namespace luabot;

    const auto opts = parse_options (argc, argv);

    if (opts.version) {
        print_version();
        return 0;
    }

    if (opts.command == luabot::Command::sim) {
        if (opts.lua_file.empty()) {
            std::cerr << "Error: sim command requires a Lua file to be specified" << std::endl;
            std::cerr << "Usage: luabot sim <robot.lua>" << std::endl;
            return 1;
        }
        init_simulation();
        try {
            return luabot::start_robot (opts.lua_file);
        } catch (const std::exception&) {
            return 1;
        }
    }

    return luabot_console (argc, argv);
}

#include <luabot/wpi/apriltag.ipp>
#include <luabot/wpi/frc.ipp>
#include <luabot/wpi/math.ipp>
