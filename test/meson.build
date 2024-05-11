
## REUSE test
# Save for later.
# if reuse_program.found()
#   test('REUSE', reuse_program, 
#     args: [ '--root', meson.project_source_root(), 'lint' ], 
#     suite: 'metadata')
# endif

bindings_root = meson.project_build_root() / 'bindings'
lua_path_pat = '@0@/?.lua;@0@/?/init.lua'

lua_path = 'LUA_PATH=?.lua;?/init.lua'
lua_path += ';' + lua_path_pat.format ('bindings')
lua_path += ';' + lua_path_pat.format (fs.stem(meson.project_build_root()) / 'bindings' / 'lua')
lua_path += ';' + lua_path_pat.format (meson.current_source_dir())
lua_path += ';' + lua_path_pat.format ('/usr/local/share/lua/5.1')

lua_workdir = meson.project_source_root()

if host_machine.system() == 'darwin'
    luabot_env = [
        'DYLD_LIBRARY_PATH=@0@:@1@:@2@'.format(bindings_root, '/opt/homebrew/lib', '/usr/local/lib'),
        lua_path
    ]
else
    luabot_env = [
        'LD_LIBRARY_PATH=@0@:@1@'.format(bindings_root, '/usr/local/lib'),
        lua_path
    ]
endif

foreach t : [ 'requireall' ]
    test (t, luabot_exe,
        args : files(t + '.lua'),
        workdir : lua_workdir,
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
