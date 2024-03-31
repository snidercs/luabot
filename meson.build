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

c = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')
boost_dep = dependency ('boost', required : true)

luabot_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [])

luabot_internal_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [ boost_dep ])

subdir ('test')
