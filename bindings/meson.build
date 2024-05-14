
luabot_luadir = get_option ('datadir') / 'luabot' / '1.0'
bindings_root = meson.project_source_root() / 'bindings'

subdir ('wpi')
subdir ('frc')

wpi_resources = run_command([python_exe, parse_py, '-l',
    meson.project_source_root() / 'bindings' ], 
    check: true).stdout().strip().split('\n')

custom_target (
    'lua',
    build_by_default: true,
    output: 'lua',
    input: wpi_resources,
    command : [ python_exe, parse_py, '-f', 'lua',
                '-b', bindings_root,
                '-o', '@OUTPUT@', '@INPUT@' ],
    install: true,
    install_dir: luabot_luadir
)

# custom_target (
#     'lua',
#     build_by_default: true,
#     output: 'lua',
#     input: wpi_yaml_files + wpi_lua_files + frc_yaml_files + frc_lua_files,
#     command : [ python_exe, parse_py, '-f', 'lua',
#                 '-b', bindings_root,
#                 '-o', '@OUTPUT@', '@INPUT@' ],
#     install: true,
#     install_dir: luabot_luadir
# )

# generate C wrapper code.
gen_cpp = []
foreach f : wpi_resources
    if not fs.name(f).endswith('yaml')
        continue
    endif

    name = fs.relative_to (f, meson.current_source_dir()).replace ('yaml','cpp')
    name = fs.as_posix(name)
    name = name.replace('/', '_')
    gen_cpp += custom_target (
        name,
        build_by_default: true,
        output: name,
        input : f,
        install: false,
        command : [ python_exe, parse_py, '-f', 'c',
                    '-o', '@OUTPUT@', '@INPUT@' ],
    )
endforeach

luabot_lib = library ('luabot',
    [ luabot_src_cpp_files, frc_cpp_files, wpi_cpp_files, gen_cpp ],
    dependencies: [ wpilibc_dep, wpimath_dep, apriltag_dep ],
    install: true
)
