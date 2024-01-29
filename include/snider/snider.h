#pragma once

#if __cplusplus

// clang-format off
/** Disables copy constructor and operator. */
#define SNIDER_DISABLE_COPY(ClassName)                   \
    ClassName (const ClassName&)            = delete;  \
    ClassName& operator= (const ClassName&) = delete;

/** Disables move constructor and operator. */
#define SNIDER_DISABLE_MOVE(ClassName)                   \
    ClassName (const ClassName&&)            = delete; \
    ClassName& operator= (const ClassName&&) = delete;
// clang-format on

namespace snider {
template <typename... T>
inline static void ignore (T&&...) noexcept {}
} // namespace snider

#endif // __cplusplus
