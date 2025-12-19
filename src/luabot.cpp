#include <chrono>
#include <cstring>
#include <iostream>
#include <luabot/version.h>
#include <thread>

#include <lua.hpp>

#include <frc/Errors.h>
#include <frc/RobotBase.h>
#include <hal/DriverStation.h>
#include <hal/Extensions.h>
#include <hal/HALBase.h>
#include <hal/Main.h>
#include <wpi/condition_variable.h>
#include <wpi/mutex.h>

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

namespace detail {
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

void run_lua_robot (wpi::mutex& m, lua_State** L_ptr, const char* lua_file) {
    try {
        lua_State* L = luaL_newstate();
        luaL_openlibs (L);

        {
            std::scoped_lock lock { m };
            *L_ptr = L;
        }

        // Load and execute the Lua file as a module
        if (luaL_loadfile (L, lua_file) != 0) {
            const char* err = lua_tostring (L, -1);
            std::string err_msg = err ? err : "unknown error";
            lua_close (L);
            throw std::runtime_error (err_msg);
        }

        // Execute the file - should return a table
        if (lua_pcall (L, 0, 1, 0) != 0) {
            const char* err = lua_tostring (L, -1);
            std::string err_msg = err ? err : "unknown error";
            // std::cerr << "[luabot]: " << err_msg << std::endl;
            lua_close (L);
            throw std::runtime_error (err_msg);// ("failed to create module");
        }

        // The module should return a table
        if (! lua_istable (L, -1)) {
            std::cerr << "Error: Lua file must return a table with a 'new' function" << std::endl;
            lua_close (L);
            throw std::runtime_error ("Module did not return a table");
        }

        // Get the 'new' function from the returned table
        lua_getfield (L, -1, "new");
        if (! lua_isfunction (L, -1)) {
            // std::cerr << "Error: Module table must have a 'new' function" << std::endl;
            lua_close (L);
            throw std::runtime_error ("Module table missing 'new' function");
        }

        // Call module.new() to create the robot instance
        if (lua_pcall (L, 0, 1, 0) != 0) {
            const char* err = lua_tostring (L, -1);
            std::string err_msg = err ? err : "unknown error";
            // std::cerr << "Error calling new(): " << err_msg << std::endl;
            lua_close (L);
            throw std::runtime_error (err_msg);
        }

        // Store the robot instance in the registry to keep it alive
        lua_pushvalue (L, -1); // Duplicate the robot instance
        lua_setfield (L, LUA_REGISTRYINDEX, "robot_instance");

        // Now we have the robot instance on the stack
        // Get the startCompetition method
        lua_getfield (L, -1, "startCompetition");
        if (! lua_isfunction (L, -1)) {
            // std::cerr << "Error: Robot instance must have a startCompetition method" << std::endl;
            lua_close (L);
            throw std::runtime_error ("Robot missing startCompetition method");
        }

        // Push the robot instance as 'self' for the method call
        lua_pushvalue (L, -2); // Duplicate the robot instance

        // Call instance:startCompetition()
        if (lua_pcall (L, 1, 0, 0) != 0) {
            const char* err = lua_tostring (L, -1);
            std::string err_msg = err ? err : "unknown error";
            // std::cerr << "Error in startCompetition: " << err << std::endl;
            lua_close (L);
            throw std::runtime_error (err_msg);
        }

        // Don't close L here - keep it alive for endCompetition

    } catch (const std::exception& e) {
        auto hal_msg = std::string("[luabot]: ") + std::string (e.what());
        HAL_SendError (1, frc::err::Error, 0, hal_msg.c_str(), "", "", 1);
        throw;
    }
}

} // namespace detail

int start_robot (const char* lua_file) {
    int halInit = frc::RunHALInitialization();
    if (halInit != 0) {
        return halInit;
    }

    static wpi::mutex m;
    static wpi::condition_variable cv;
    static lua_State* L = nullptr;
    static bool exited  = false;

    if (HAL_HasMain()) {
        std::thread thr ([lua_file] {
            try {
                detail::run_lua_robot (m, &L, lua_file);
            } catch (...) {
                HAL_ExitMain();
                {
                    std::scoped_lock lock { m };
                    L      = nullptr;
                    exited = true;
                }
                cv.notify_all();
                throw;
            }

            HAL_ExitMain();
            {
                std::scoped_lock lock { m };
                L      = nullptr;
                exited = true;
            }
            cv.notify_all();
        });

        HAL_RunMain();

        // Signal loop to exit - call endCompetition on the robot instance
        if (L != nullptr) {
            // Get the robot instance from the registry
            lua_getfield (L, LUA_REGISTRYINDEX, "robot_instance");
            if (lua_istable (L, -1)) {
                // Get the endCompetition method
                lua_getfield (L, -1, "endCompetition");
                if (lua_isfunction (L, -1)) {
                    // Push the robot instance as 'self'
                    lua_pushvalue (L, -2);
                    // Call instance:endCompetition()
                    lua_pcall (L, 1, 0, 0);
                }
            }
        }

        // Prefer to join, but detach to exit if it doesn't exit in a timely manner
        using namespace std::chrono_literals;
        std::unique_lock lock { m };
        if (cv.wait_for (lock, 1s, [] { return exited; })) {
            thr.join();
        } else {
            thr.detach();
        }

        // Clean up Lua state
        if (L) {
            lua_close (L);
        }
    } else {
        detail::run_lua_robot (m, &L, lua_file);
    }

#ifndef __FRC_ROBORIO__
    frc::impl::ResetMotorSafety();
#endif
    HAL_Shutdown();

    return 0;
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
        detail::init_simulation();
        try {
            return luabot::start_robot (opts.lua_file);
        } catch (const std::exception&) {
            return 1;
        }
    }

    return luabot_console (argc, argv);
}
