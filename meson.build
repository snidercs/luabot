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

luajit_proj = subproject ('luajit', required: true,
    default_options: [
        'default_library=static',
        'app=false',
        # 'luaname=luabot',
        # 'lua52compat=true',
        # 'jit=true',
        # 'ffi=true'
    ])
luajit_dep = luajit_proj.get_variable ('lua_dep')
luajit_h = luajit_proj.get_variable ('luajit_h')

subdir ('meson/allwpilib')

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

luabot_exe = executable ('luabot', [
        luajit_h, # ensure header gets generated
        'src/luabot.c'
    ],
    c_args: [ '-std=c99' ],
    cpp_args: ['-DLUA_USE_READLINE=@0@'.format(readline_dep.found() ? 1 : 0)],
    dependencies: [ wpilib_deps, luajit_dep, luabot_dep, readline_dep ], # ORDER
    link_with: [ ],
    # link_args: [ '-Wl,--export-dynamic' ], # needed to export ffi bindings.
    install: true)

subdir ('test')

subproject ('lanes', required: true)
