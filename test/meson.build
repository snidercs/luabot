
## REUSE test
# Save for later.
# if reuse_program.found()
#   test('REUSE', reuse_program, 
#     args: [ '--root', meson.project_source_root(), 'lint' ], 
#     suite: 'metadata')
# endif

luabot_env = [
    'LD_LIBRARY_PATH=@0@'.format(meson.project_build_root() / 'bindings')
]

foreach t : [ 'CoordinateAxis', 'Pose2d', 'Rotation2d']
    test (t, luabot_exe,
        args : files(t + '_test.lua'),
        workdir : meson.project_source_root() / 'bindings',
        suite : 'frc',
        env: luabot_env)
endforeach

if boost_dep.found()

## Unit Tests
luabot_unit_test_sources = '''
    basics.cpp
    testmain.cpp
'''.split()

unit = executable ('test-luabot',
    luabot_unit_test_sources,
    dependencies : [ luabot_internal_dep ],
    gnu_symbol_visibility : 'hidden',
    cpp_args : [])

luabot_unit_tests = '''
    Basics
'''.split()

foreach t : luabot_unit_tests
    test (t, unit, args : [ '-t', t ])
endforeach

endif
