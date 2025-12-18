
local mods = {
    'wpi.clib.cscore',
    'wpi.clib.ntcore',
    'wpi.clib.wpiHal',

    'wpi.frc.AddressableLED',
    'wpi.frc.DriverStation',
    'wpi.frc.Filesystem',
    'wpi.frc.GenericHID',
    'wpi.frc.IterativeRobotBase',
    'wpi.frc.Joystick',
    'wpi.frc.RobotBase',
    'wpi.frc.TimedRobot',
    'wpi.frc.Timer',
    'wpi.frc.Watchdog',
    'wpi.frc.XboxController',
    'wpi.apriltag.AprilTag',
    'wpi.apriltag',
    'wpi.frc.livewindow.LiveWindow',
    'wpi.frc.shuffleboard.Shuffleboard',
    'wpi.frc.smartdashboard.SmartDashboard',
    'wpi.hal',
    'wpi.math.geometry.CoordinateAxis',
    'wpi.math.geometry.CoordinateSystem',
    'wpi.math.geometry.Pose2d',
    'wpi.math.geometry.Pose3d',
    'wpi.math.geometry.Quaternion',
    'wpi.math.geometry.Rotation2d',
    'wpi.math.geometry.Rotation3d',
    'wpi.math.geometry.Transform2d',
    'wpi.math.geometry.Transform3d',
    'wpi.math.geometry.Translation2d',
    'wpi.math.geometry.Translation3d',
    'wpi.math.geometry.Twist2d',
    'wpi.math.geometry.Twist3d'
}

for _,m in ipairs (mods) do
    local _ = require (m)
end
