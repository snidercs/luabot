-- A test program to try different ways of running an FRC robot in Lua.

local ffi = require('ffi')
local lanes = require('lanes').configure()
require ('frc.RobotBase')
require ('wpi.hal')

local robotModuleStr = 'robots.TestRobot'
if select('#',...) >= 1 then
    -- use command-line specified robot module to run
    robotModuleStr = tostring (select(1, ...))
end

local console = {}
function console.error (...)
    io.stderr:write ('[simbot] error: ')
    io.stderr:write(...)
    io.stderr:write('\n')
    io.stderr:flush()
end

do
    local ok, ret = pcall (ffi.load, 'luabot-wpilibc', true)
    if not ok then
        console.error (tostring (ret))
        os.exit(-1)
    end
end

local C = ffi.C

local function startrobot (module)
    local rok, e = pcall (function()
        package.path = package.path..';util/?.lua'
        require ('frc.RobotBase')
        local tffi = require('ffi')
        local _ = tffi.load ('luabot-wpilibc', true)
        tffi.C.frcRobotBaseInit()
        local T = require (module)
        local robot = T.new()
        local jit = require ('jit')
        jit.on(robot.startCompetition, true)

        robot:startCompetition()
    end)
    if not rok then
        console.error (tostring(e))
        io.stdout:flush()
    end
end

C.frcRunHalInitialization()

if C.HAL_HasMain() then
    local thrd = lanes.gen ("*", startrobot)(robotModuleStr)
    ffi.C.HAL_RunMain()
    C.HAL_Shutdown()
    local ok, err = thrd:join()
    if not ok then
        print(tostring(err))
    end
else
    startrobot(robotModuleStr)
end

C.HAL_Shutdown()
os.exit(0)
