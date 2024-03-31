project ('luabot', ['cpp', 'c'], 
    version : '0.1.0',
    meson_version : '>= 1.3.1',
    license : 'MIT',
    default_options: [
        'b_ndebug=if-release',
        'buildtype=release',
        'c_std=c99',
        'cpp_std=c++20',
    ])

fs = import ('fs')
c = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')
boost_dep = dependency ('boost', required : false)

luabot_sdk_includes = include_directories (
    fs.expanduser ('~/SDKs/luabot/linux64/include'),
    fs.expanduser ('~/SDKs/luabot/linux64/include/luajit-2.1')
)
luabot_sdk_libdirs = [ fs.expanduser ('~/SDKs/luabot/linux64/lib') ]

cpp.check_header ('luajit.h', required: true, 
    include_directories: luabot_sdk_includes)
cpp.find_library ('luajit-5.1', required: true,
    dirs: [ luabot_sdk_libdirs ])

luabot_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [])

luabot_internal_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [ boost_dep ])

luabot_exe = executable ('luabot', [
    'util/luabot/main.cpp'
])

subdir ('test')
