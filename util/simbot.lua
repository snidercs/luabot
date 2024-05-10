-- A test program to try different ways of running an FRC robot in Lua.

local lanes = require('lanes')
local RobotBase = require ('frc.RobotBase')
require ('wpi.hal')
local ffi = require('ffi')

local robotModuleStr = 'MockRobot'
if select('#',...) >= 1 then
    -- use command-line specified robot module to run
    robotModuleStr = tostring (select(1, ...))
end

local CCC, ok, err


local console = {}
function console.error (...)
    io.stderr:write ('[simbot] error: ')
    io.stderr:write(...)
    io.stderr:write('\n')
    io.stderr:flush()
end

ok, CCC = pcall (ffi.load, 'luabot', true)
if not ok then
    console.error (tostring (CCC))
    os.exit(-1)
end

local function startrobot (module)
    local rok, e = pcall (function()
        package.path = package.path..';util/?.lua'
        require ('frc.RobotBase')
        local tffi = require('ffi')
        local _ = tffi.load ('luabot', true)
        tffi.C.frcRobotBaseInit()
        local T = require (module)
        local robot = T.new()
        robot:startCompetition()
    end)
    if not rok then
        io.stdout:write (tostring(e))
        io.stdout:flush()
    end
end

ffi.C.frcRunHalInitialization()

if ffi.C.HAL_HasMain() then
    local thrd = lanes.gen ("*", startrobot)(robotModuleStr)
    ffi.C.HAL_RunMain()
    ok, err = thrd:join()
    if not ok then
        print(tostring(err))
    end
else
    startrobot(robotModuleStr)
end

CCC.HAL_Shutdown()
os.exit(0)
