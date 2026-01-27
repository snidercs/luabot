// SPDX-FileCopyrightText: Michael Fisher @mfisher31
// SPDX-License-Identifier: MIT

#ifndef LUABOT_H
#define LUABOT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdlib.h>
#include <string.h>

#include <lua.h>

// Define export macro for FFI functions on Windows
#ifdef _WIN32
#    define LUABOT_EXPORT __declspec (dllexport)
#else
#    define LUABOT_EXPORT
#endif

#ifndef LUABOT_DEFAULT_PATH
#    define LUABOT_DEFAULT_PATH                                                       \
        "./?.lua;./?/init.lua;"                                                       \
        "/opt/luabot/share/luajit-2.1/?.lua;/opt/luabot/share/luajit-2.1/?/init.lua;" \
        "/opt/luabot/share/lua/5.1/?.lua;/opt/luabot/share/lua/5.1/?/init.lua"
#endif

static void luabot_set_default_paths (lua_State* L) {
    char* epath = getenv ("LUA_PATH");
    if (epath == NULL || strlen (epath) == 0) {
        lua_getglobal (L, "package");
        lua_pushstring (L, LUABOT_DEFAULT_PATH);
        lua_setfield (L, -2, "path");
        lua_pop (L, 1);
    }
}

#ifdef __cplusplus
}
#endif

#endif
