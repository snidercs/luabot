project ('botlib', ['cpp', 'c'], 
    version : '0.1.0',
    meson_version : '>= 0.56.0',
    license : 'NA',
    default_options: [
        'b_ndebug=if-release',
        'buildtype=release',
        'c_std=c99',
        'cpp_std=c++17',
    ])

c = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')
boost_dep = dependency ('boost', required : true)

botlib_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [])

botlib_internal_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [ boost_dep ])

subdir ('test')
