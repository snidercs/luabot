
local mods = {
    'wpi.hal',

    'frc.livewindow.LiveWindow',
    'frc.smartdashboard.SmartDashboard',

    'frc.AddressableLED',
    'frc.DriverStation',
    'frc.Filesystem',
    'frc.GenericHID',
    'frc.Joystick',
    'frc.RobotBase',
    'frc.Timer',
    'frc.XboxController',
}

for _,m in ipairs (mods) do
    local _ = require (m)
end

local geometry_package = 'wpi.math.geometry'
local geometry = {
    'CoordinateAxis',
    'CoordinateSystem',
    'Pose2d',
    'Pose3d',
    'Quaternion',
    'Rotation2d',
    'Rotation3d',
    'Transform2d',
    'Transform3d',
    'Translation2d',
    'Translation3d',
    'Twist2d',
    'Twist3d',
}

for _,m in ipairs (geometry) do
    local mod = string.format ('%s.%s', geometry_package, m)
    print(mod)
    local _ = require (mod)
end
