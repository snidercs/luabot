#pragma once

template <typename Obj, typename Ctp>
inline static Obj& toref (Ctp&& ptr) { return *((Obj*) ptr); }

template <typename Obj, typename Ctp>
inline static const Obj& toref (const Ctp&& ptr) { return *((const Obj*) ptr); }
