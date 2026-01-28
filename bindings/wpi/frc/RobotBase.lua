---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local ffi = require('ffi')

---RobotBase
---@class RobotBase
local RobotBase = class()

ffi.cdef[[
bool frcRobotBaseIsReal();
bool frcRobotBaseIsSimulation();
void frcRobotBaseInit();
int frcRunHalInitialization();
]]

local CC
pcall(function()
    pcall(ffi.load, 'luabot-ffi', true)
    CC = ffi.C
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

---Initialize a RobotBase instance
---@param self RobotBase
function RobotBase.init(self)
    -- CC.frcRunHalInitialization()
    -- CC.frcRobotBaseInit()
end

---Create a new RobotBase instance
---@return RobotBase
function RobotBase.new()
    local instance = setmetatable({}, RobotBase)
    RobotBase.init(instance)
    return instance
end

return RobotBase
