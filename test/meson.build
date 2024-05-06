
## REUSE test
# Save for later.
# if reuse_program.found()
#   test('REUSE', reuse_program, 
#     args: [ '--root', meson.project_source_root(), 'lint' ], 
#     suite: 'metadata')
# endif

bindings_root = meson.project_build_root() / 'bindings'
bindings_src_root = meson.project_source_root() / 'bindings'
lua_path_pat = '@0@/?.lua'

lua_path = 'LUA_PATH=@0@'.format (lua_path_pat.format (bindings_root / 'lua'))
lua_path += ';' + lua_path_pat.format (bindings_root / 'lua')
lua_path += ';' + lua_path_pat.format (meson.current_source_dir())

luabot_env = [
    'LD_LIBRARY_PATH=@0@;@1@'.format(bindings_root, luabot_sdk_libdir),
    lua_path
]

foreach t : [ 'requireall' ]
    test (t, luabot_exe,
        args : files(t + '.lua'),
        workdir : meson.project_source_root() / 'bindings',
        suite : 'frc',
        env: luabot_env)
endforeach

subdir('wpi')

if boost_dep.found()

## Unit Tests
luabot_unit_test_sources = '''
    basics.cpp
    main.cpp
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
