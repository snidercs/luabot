
local mods = {
    'frc.AddressableLED',
    'frc.DriverStation',
    'frc.Filesystem',
    'frc.GenericHID',
    'frc.IterativeRobotBase',
    'frc.Joystick',
    'frc.RobotBase',
    'frc.TimedRobot',
    'frc.Timer',
    'frc.Watchdog',
    'frc.XboxController',
    'frc.apriltag.AprilTag',
    'frc.apriltag',
    'frc.livewindow.LiveWindow',
    'frc.shuffleboard.Shuffleboard',
    'frc.smartdashboard.SmartDashboard',
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
