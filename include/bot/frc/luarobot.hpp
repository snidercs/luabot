#pragma once

#include <frc/RobotBase.h>
#include <lua.hpp>

namespace bot {

class LuaRobot : public frc::RobotBase {
public:
    ~LuaRobot() {
        lua_close (_state);
    }

    void StartCompetition() override {
        luaL_loadfile (_state, file);
        lua_pcall (_state, 0, LUA_MULTRET, 0);
    }

protected:
    LuaRobot() {
        _state = luaL_newstate();
    }

private:
    lua_State* _state { nullptr };
};

} // namespace bot
