
foreach t : [ 'AddressableLED', 'CoordinateAxis', 'Pose2d', 'Rotation2d' ]
    test (t, luabot_exe,
        args : files(t + '_test.lua'),
        workdir : meson.project_source_root() / 'bindings',
        suite : 'wpi',
        env: luabot_env)
endforeach
