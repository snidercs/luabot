
frc_cases = '''
    Filesystem
    Robots
    Timed
'''.split()

foreach t : frc_cases
    test (t, luabot_exe,
        args : files(t + 'Test.lua'),
        workdir : meson.project_source_root() / 'bindings',
        suite : 'wpi',
        env: luabot_env)
endforeach
