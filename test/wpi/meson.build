
wpi_tests = '''
    AddressableLED
    Filesystem
    Geometry
    Robots
    Timed
'''.split()

foreach t : wpi_tests
    test (t, luabot_exe,
        args : files('Test' + t + '.lua'),
        workdir : meson.project_source_root() / 'bindings',
        suite : 'wpi',
        env: luabot_env)
endforeach
