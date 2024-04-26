---RobotBase
---@class RobotBase
local RobotBase = {}

local ffi = require ('ffi')

ffi.cdef[[
bool frcRobotBaseIsReal();
bool frcRobotBaseIsSimmulation();
]]

local lib = ffi.load ('luabot-wpilibc')

function RobotBase.isReal()
    return lib.frcRobotBaseIsReal()
end

function RobotBase.isSimulation()
    return lib.frcRobotBaseIsSimulation()
end

return RobotBase
