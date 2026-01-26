---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local iterations = 2000000

local IterativeRobotBase = require('wpi.frc.IterativeRobotBase')
local ffi = require ('ffi')

---@class PlusOne A mock robot to use in testing.
local PlusOne = IterativeRobotBase.derive()

---@return number
function PlusOne:process(x)
    self:loopFunc()
    return x + 1
end

local function instantiate()
    local robot = IterativeRobotBase.init({})
    setmetatable(robot, { __index = PlusOne })
    return robot
end

local function main()
    ffi.C.frcRunHalInitialization()
    ffi.C.frcRobotBaseInit()
    local _ = 0
    local robot = instantiate()
    for i = 1, iterations do
        _ = robot:process(i)
    end

    ffi.C.HAL_Shutdown()
    return 0
end

os.exit(main())
