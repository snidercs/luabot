
local TimedRobot = require ('frc.TimedRobot')
local XboxController = require ('frc.XboxController')

---@class MockRobot A mock robot to use in testing.
local MockRobot = TimedRobot.derive()

function MockRobot:robotInit()
    self.pad = XboxController.new (0)
end

function MockRobot:simulationInit()
    print("MockRobot:simulationInit()")
end

function MockRobot:autonomousInit()
    print("MockRobot:autonomousInit()")
end

function MockRobot:teleopInit()
    print("MockRobot:teleopInit()")
end

function MockRobot:disabledInit()
    print("MockRobot:disabledInit()")
end

function MockRobot:testInit()
    print("MockRobot:testInit()")
end

local telopRan = false
function MockRobot:teleopPeriodic()
    if not telopRan then
        print("MockRobot:teleopPeriodic()")
        telopRan = true
    else
    end
end

local hasReportedDisconnected = false
function MockRobot:robotPeriodic()
    local pad = self.pad
    local disconnected = not pad:isConnected()

    if disconnected then
        if not hasReportedDisconnected then
            print("disconnected joystick")
            hasReportedDisconnected = true
        end
        return
    end

    if pad:getXButtonPressed() then
        print('pressed')
    elseif pad:getXButtonReleased() then
        print('released')
    end
end

local function instantiate (timeout)
    timeout = tonumber(timeout) or 0.02
    local robot = TimedRobot.init({}, timeout)
    setmetatable(robot, { __index = MockRobot })

    -- private member variables are possible in lua with a ctor as a closure.
    local tick = 0
    local initialized = false

    -- functions are first-class values and therefore can be synthesized in a
    -- closure providing read-only access.
    function robot:tick() return tick end
    function robot:initialized() return initialized end

    -- Half speed peridic callback
    -- robot:addPeriodic(function()
    --     tick = tick + 1
    --     if tick >= 200 then 
    --         robot:endCompetition()
    --     end
    -- end, timeout * 2.0)

    return robot
end

return {
    new = instantiate
}
