project ('luabot', ['cpp', 'c'], 
    version : '0.1.0',
    meson_version : '>= 1.4.0',
    license : 'MIT',
    default_options: [
        'b_ndebug=if-release',
        'buildtype=release',
        'c_std=c99',
        'cpp_std=c++20',
    ])


fs = import ('fs')
luajit_exe = find_program ('luajit')

parse_py = files ('util/parse.py')

c = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')
boost_dep = dependency ('boost', required : false)

luajit_dep   = dependency ('luajit', version: '>= 2.1', required: true)

hal_dep      = dependency ('hal', method: 'cmake', required: true)
ntcore_dep   = dependency ('ntcore', method: 'cmake', required: true)
wpiutil_dep  = dependency ('wpiutil', method: 'cmake', required: true)
wpimath_dep  = dependency ('wpimath', method: 'cmake', required: true)
wpilibc_dep  = dependency ('wpilibc', method: 'cmake', required: true)
apriltag_dep = dependency ('apriltag', method: 'cmake', required: true)
cameraserver_dep = dependency ('cameraserver', method: 'cmake', required: true)
cscore_dep   = dependency ('cscore', method: 'cmake', required: true)

luabot_dep = declare_dependency (
    link_with : [],
    include_directories : [ include_directories ('./include') ],
    dependencies : [])

luabot_internal_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [ boost_dep ])

readline_dep = dependency('readline')

subdir ('src')
luabot_exe = executable ('luabot', [
        'src/luabot.c'
    ],
    cpp_args: ['-DLUA_USE_READLINE=@0@'.format(readline_dep.found() ? 1 : 0)],
    dependencies: [luabot_dep, luajit_dep, readline_dep],
    install: true)

subdir ('bindings')
subdir ('test')

simbot_exe = executable ('simbot', [
        'util/simbot.cpp'
    ],
    dependencies: [wpilibc_dep])
