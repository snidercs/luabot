---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local iterations = 2000000

local class = require('luabot.class')
local IterativeRobotBase = require('wpi.frc.IterativeRobotBase')
local hal = require ('wpi.hal')

---@class PlusOne : IterativeRobotBase A mock robot to use in testing.
local PlusOne = class(IterativeRobotBase)

---@return number
function PlusOne:process(x)
    self:loopFunc()
    return x + 1
end

local function instantiate()
    local robot = setmetatable({}, PlusOne)
    IterativeRobotBase.init(robot)
    return robot
end

local function main()
    hal.initialize (500, 0)
    local _ = 0
    local robot = instantiate()
    for i = 1, iterations do
        _ = robot:process(i)
    end

    hal.shutdown()
    return 0
end

os.exit(main())
