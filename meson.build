project ('luabot', ['cpp', 'c'], 
    version : '0.1.0',
    meson_version : '>= 1.4.0',
    license : 'MIT',
    default_options: [
        'b_ndebug=if-release',
        'buildtype=release',
        'cpp_std=c++20',
    ])
cmake = import ('cmake')

python_exe = import('python').find_installation ('python3', modules : [ 'yaml' ])

fs = import ('fs')
luajit_exe = find_program ('luajit')

parse_py = files ('util/parse.py')

c = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')

boost_dep = dependency ('boost', required : false)

roborio_root = fs.expanduser ('~/wpilib/2025/luabot/linuxathena')
roborio_libdirs = [ roborio_root / 'lib' ]
roborio_incdirs = include_directories (roborio_root / 'include')

# LuaJIT
if not meson.is_cross_build()
    # A meson-enabled LuaJIT is ok for the simulator ...
    luajit_proj = subproject ('luajit', required: true,
        default_options: [
            'app=true',
            'lua52compat=false',
            'jit=true',
            'ffi=true'
        ])
    luajit_dep = luajit_proj.get_variable ('lua_dep')
    luajit_h = luajit_proj.get_variable ('luajit_h')
else
    # but not trustworthy yet when cross-compiling. Therefore roborio uses an 
    # upstream LuatJIT installation.
    luajit_incdirs = include_directories (roborio_root / 'include' / 'luajit-2.1')
    luajit_libdirs = [ roborio_root / 'lib' ]
    c.check_header ('luajit.h', include_directories: luajit_incdirs, required: true)
    luajit_h = files(roborio_root / 'include' / 'luajit-2.1' / 'luajit.h')
    libluajit = cpp.find_library ('luajit-5.1', dirs: luajit_libdirs, required: true)
    luajit_dep = declare_dependency (
        include_directories: luajit_incdirs,
        dependencies: [ libluajit ]
    )
endif

# WPIlib
subdir ('meson/allwpilib')

# luabot deps
luabot_dep = declare_dependency (
    link_with : [],
    include_directories : [ include_directories ('./include') ],
    dependencies : [ luajit_dep ])

luabot_internal_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [ boost_dep ])

## readline
readline_dep = dependency('readline', required: false)
if not readline_dep.found()
    readline_dep = cpp.find_library ('readline', required: false)
endif

subdir ('src')
subdir ('bindings')

# luabot program
luabot_exe = executable ('luabot', [
        'src/luabot.c',
        luajit_h
    ],
    c_args: [ '-std=c99' ],
    cpp_args: ['-DLUA_USE_READLINE=@0@'.format(readline_dep.found() ? 1 : 0)],
    dependencies: [ wpilib_deps, luajit_dep, luabot_dep, readline_dep ], # ORDER
    link_with: [ ],
    # link_args: [ '-Wl,--export-dynamic' ], # needed to export ffi bindings.
    install: true)

if not get_option('test').disabled()
    subdir ('test')
endif

if not meson.is_cross_build()
    # lanes not yet supported when cross compiling.
    subproject ('lanes', required: true)
endif
