
## REUSE test
# Save for later.
# if reuse_program.found()
#   test('REUSE', reuse_program, 
#     args: [ '--root', meson.project_source_root(), 'lint' ], 
#     suite: 'metadata')
# endif

if boost_dep.found()

## Unit Tests
botlib_unit_test_sources = '''
    basics.cpp
    testmain.cpp
'''.split()

unit = executable ('test-botlib',
    botlib_unit_test_sources,
    dependencies : [ botlib_internal_dep ],
    gnu_symbol_visibility : 'hidden',
    cpp_args : [])

botlib_unit_tests = '''
    Basics
'''.split()

foreach t : botlib_unit_tests
    test (t, unit, args : [ '-t', t ])
endforeach

endif
