---RobotBase
---@class RobotBase
local RobotBase = {}

local ffi = require ('ffi')

ffi.cdef[[
bool frcRobotBaseIsReal();
bool frcRobotBaseIsSimulation();
void frcRobotBaseInit();
]]

local CC
pcall(function()
    CC = ffi.load ('luabot', true)
end)
if CC == nil then CC = ffi.C end

function RobotBase:startCompetition()
    error('mising implementation in frc.RobotBase: startCompetition')
end

function RobotBase:endCompetition()
    error('RobotBase mising implementation: startCompetition')
end

function RobotBase:isEnabled()
    return CC.frcDriverStationIsEnabled()
end

function RobotBase:isDisabled()
    return CC.frcDriverStationIsDisabled()
end

function RobotBase:isAutonomous()
    return CC.frcDriverStationIsAutonomous()
end

function RobotBase.isReal()
    return CC.frcRobotBaseIsReal()
end

function RobotBase.isSimulation()
    return CC.frcRobotBaseIsSimulation()
end

function RobotBase.init(instance)
    CC.frcRobotBaseInit()
    return instance
end

return RobotBase
