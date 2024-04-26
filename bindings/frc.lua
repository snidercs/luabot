
local function validate_robot(robot)
    return type(robot) == 'table', ''
end

local function startrobot(robot)
    do
        local valid, msg = validate_robot (robot)
        if not valid then error(msg, 1) end
    end

    print ("[bot] frc.startrobot ("..tostring(robot)..")")
    return 0
end

return {
    startrobot = startrobot
}
