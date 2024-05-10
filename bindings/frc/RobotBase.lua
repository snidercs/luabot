local M = {}

---RobotBase
---@class RobotBase
local RobotBase = {}

local ffi = require('ffi')

ffi.cdef [[
bool frcRobotBaseIsReal();
bool frcRobotBaseIsSimulation();
void frcRobotBaseInit();
int frcRunHalInitialization();

int HALSIM_InitExtension();
]]

local CC
pcall(function()
    CC = ffi.load('luabot', true)
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

M.isReal = RobotBase.isReal

function RobotBase.isSimulation()
    return CC.frcRobotBaseIsSimulation()
end

M.isSimulation = RobotBase.isSimulation

local function derive()
    local T = {}
    for k, v in pairs(RobotBase) do T[k] = v end
    return T
end
M.derive = derive

local function init(instance)
    -- CC.frcRunHalInitialization()
    -- CC.frcRobotBaseInit()
    return instance
end
M.init = init

return M
