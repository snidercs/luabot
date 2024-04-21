
## REUSE test
# Save for later.
# if reuse_program.found()
#   test('REUSE', reuse_program, 
#     args: [ '--root', meson.project_source_root(), 'lint' ], 
#     suite: 'metadata')
# endif

if boost_dep.found()

## Simple FFI test
simple = shared_module ('simple', '''
    Simple.cpp
'''.split(),
    install: false)

test ('Simple FFI', find_program('luajit'), 
    args : files('Simple_test.lua'),
    workdir : meson.current_source_dir())

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
