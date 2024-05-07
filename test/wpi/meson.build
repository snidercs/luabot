
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
        workdir : lua_workdir,
        suite : 'wpi',
        env: luabot_env)
endforeach
