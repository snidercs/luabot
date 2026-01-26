
#ifndef LUABOT_H
#define LUABOT_H

#ifdef __cplusplus
extern "C" {
#endif

// Define export macro for FFI functions on Windows
#ifdef _WIN32
#define LUABOT_EXPORT __declspec(dllexport)
#else
#define LUABOT_EXPORT
#endif

#ifdef __cplusplus
}
#endif

#endif
