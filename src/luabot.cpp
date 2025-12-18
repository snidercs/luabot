#include <cstring>
#include <iostream>
#include <luabot/version.h>

extern "C" {
#include "luajit.h"
}

extern "C" int luabot_console (int argc, char* argv[]);

namespace luabot {
enum class Command {
    none,
    deploy,
    sync
};

struct Options {
    bool version { false };
    Command command { Command::none };
};
} // namespace luabot

inline static const luabot::Options parse_options (int argc, char* argv[]) {
    luabot::Options opts;

    for (int i = 1; i < argc; ++i) {
        if (std::strcmp (argv[i], "--version") == 0 || std::strcmp (argv[i], "-v") == 0) {
            opts.version = true;
        }
    }

    return opts;
}

inline static void print_version() {
    std::cout << "LuaBot " << LUABOT_VERSION " -- Copyright 2024-2025 Michael Fisher @mfisher31" << std::endl
              << LUAJIT_VERSION " -- " LUAJIT_COPYRIGHT ". " LUAJIT_URL << std::endl;
}

int main (int argc, char* argv[]) {
    const auto opts = parse_options (argc, argv);

    if (opts.version) {
        print_version();
        return 0;
    }

    return luabot_console (argc, argv);
}
