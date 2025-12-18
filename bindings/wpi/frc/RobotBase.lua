---RobotBase
---@class RobotBase
local RobotBase = {}

local ffi = require('ffi')

ffi.cdef[[
bool frcRobotBaseIsReal();
bool frcRobotBaseIsSimulation();
void frcRobotBaseInit();
int frcRunHalInitialization();
]]

local CC
pcall(function()
    CC = ffi.load('luabot-wpilibc', true)
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

function RobotBase:isAutonomousEnabled()
    return CC.frcDriverStationIsAutonomousEnabled()
end

function RobotBase:isTeleop()
    return CC.frcDriverStationIsTeleop()
end

function RobotBase:isTeleopEnabled()
    return CC.frcDriverStationIsTeleopEnabled()
end

function RobotBase:isTest()
    return CC.frcDriverStationIsTest()
end

function RobotBase:isTestEnabled()
    return CC.frcDriverStationIsTestEnabled()
end

function RobotBase.isReal()
    return CC.frcRobotBaseIsReal()
end

function RobotBase.isSimulation()
    return CC.frcRobotBaseIsSimulation()
end

local function derive()
    local T = {}
    for k, v in pairs(RobotBase) do T[k] = v end
    return T
end

---@return table instance An instance table
local function init(instance)
    -- CC.frcRunHalInitialization()
    -- CC.frcRobotBaseInit()
    return instance
end

return  {
    init = init,
    derive = derive,
    isSimulation = RobotBase.isSimulation,
    isReal = RobotBase.isReal
}
