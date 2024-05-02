
local function startrobot (robot)
    if robot == nil then
        error ('`robot` cannot be nil')
    end
    if type(robot.startCompetition) ~= 'function' then
        error ("`robot` does not implement frc.RobotBase.startRobot")
    end

    robot:startCompetition()
end

return {
    startrobot = startrobot
}
