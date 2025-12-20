#include <chrono>
#include <cstring>
#include <iostream>
#include <luabot/version.h>
#include <thread>

#include <lua.hpp>
#include <luabot/luabot.hpp>

// #include <frc/Errors.h>
// #include <frc/RobotBase.h>
// #include <hal/DriverStation.h>
// #include <hal/Extensions.h>
// #include <hal/HALBase.h>
// #include <hal/Main.h>
// #include <wpi/condition_variable.h>
// #include <wpi/mutex.h>

extern "C" int luabot_console (int argc, char* argv[]);

namespace luabot {
enum class Command {
    none,
    sim
};

struct Options {
    bool version { false };
    Command command { Command::none };
    const char* lua_file { nullptr };
};

inline static void init_simulation() {
    // Load halsim_gui if HALSIM_EXTENSIONS is not already set
    // User can override with environment variable
    auto extensions = std::getenv ("HALSIM_EXTENSIONS");
    if (nullptr == extensions || strlen (extensions) == 0) {
        setenv ("HALSIM_EXTENSIONS", "halsim_ds_socket:halsim_gui", 1);
    }

    if (nullptr != extensions)
        std::free (extensions);
}


inline static const luabot::Options parse_options (int argc, char* argv[]) {
    luabot::Options opts;

    for (int i = 1; i < argc; ++i) {
        if (std::strcmp (argv[i], "--version") == 0 || std::strcmp (argv[i], "-v") == 0) {
            opts.version = true;
        } else if (std::strcmp (argv[i], "sim") == 0) {
            opts.command = luabot::Command::sim;
            // Next argument should be the lua file
            if (i + 1 < argc) {
                opts.lua_file = argv[i + 1];
            }
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
    try {
    using namespace luabot;

    const auto opts = parse_options (argc, argv);

    if (opts.version) {
        print_version();
        return 0;
    }

    if (opts.command == luabot::Command::sim) {
        if (! opts.lua_file) {
            std::cerr << "Error: sim command requires a Lua file argument" << std::endl;
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
} catch (const std::exception& e) {
    std::cout << "unhandled: " << e.what() << std::endl;
    return 1;
}
}

#include <luabot/math.ipp>
#include <luabot/command.ipp>
#include <luabot/frc.ipp>
#include <luabot/apriltag.ipp>
