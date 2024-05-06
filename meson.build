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

parse_py = files('util/parse2.py')

c = meson.get_compiler ('c')
cpp = meson.get_compiler ('cpp')
boost_dep = dependency ('boost', required : false)

luabot_sdk_incdir = fs.expanduser ('~/SDKs/luabot/linux64/include')
luabot_sdk_includes = include_directories (
    fs.expanduser ('~/SDKs/luabot/linux64/include'),
    fs.expanduser ('~/SDKs/luabot/linux64/include/luajit-2.1')
)

luabot_sdk_libdir = fs.expanduser ('~/SDKs/luabot/linux64/lib')
luabot_sdk_libdirs = [ luabot_sdk_libdir ]

cpp.check_header ('luajit.h', required: true, 
    include_directories: luabot_sdk_includes)
libluajit = cpp.find_library ('luajit-5.1', required: true,
    dirs: [ luabot_sdk_libdirs ])

wpilib_include_root = fs.expanduser ('~/SDKs/luabot/linux64/include')

## NTCore
libntcore = cpp.find_library ('ntcore', dirs: [ luabot_sdk_libdirs ], required : true)
ntcore_dep = declare_dependency(
    include_directories: [ wpilib_include_root / 'ntcore'],
    dependencies: [libntcore]
)

## WPIlib HAL
libwpiHal = cpp.find_library ('wpiHal', dirs: [ luabot_sdk_libdirs ], required : true)
wpiHal_dep = declare_dependency (
    include_directories: [ wpilib_include_root / 'hal'],
    dependencies: [libwpiHal]
)

## WPIUtil
libwpiutil = cpp.find_library ('wpiutil', dirs: [ luabot_sdk_libdirs ], required : true)
wpiutil_dep = declare_dependency (
    include_directories: [ wpilib_include_root / 'wpiutil' ],
    dependencies: [libwpiutil]
)

## WPIMath
libwpimath = cpp.find_library ('wpimath', dirs: [ luabot_sdk_libdirs ], required : true)
wpimath_dep = declare_dependency (
    include_directories: [ wpilib_include_root / 'wpimath' ],
    dependencies: [libwpimath]
)

## WPIlib C
libwpilibc = cpp.find_library ('wpilibc', dirs: [ luabot_sdk_libdirs ], required : true)
wpilibc_dep = declare_dependency (
    include_directories: [
        fs.expanduser ('~/SDKs/luabot/linux64/include/wpilibc'),
        fs.expanduser ('~/SDKs/luabot/linux64/include/cscore')],
    dependencies: [ wpiHal_dep, ntcore_dep, wpiutil_dep, wpimath_dep, 
                    libwpilibc ]
)

## WPI Misc...
libapriltag = cpp.find_library ('apriltag', dirs: [ luabot_sdk_libdirs ], required : true)
libcameraserver = cpp.find_library ('cameraserver', dirs: [ luabot_sdk_libdirs ], required : true)
libcscore = cpp.find_library ('cscore', dirs: [ luabot_sdk_libdirs ], required : true)

libglass = cpp.find_library ('glass', dirs: [ luabot_sdk_libdirs ], required : true)
libglassnt = cpp.find_library ('glassnt', dirs: [ luabot_sdk_libdirs ], required : true)

libhalsim_ds_socket = cpp.find_library ('halsim_ds_socket', dirs: [ luabot_sdk_libdirs ], required : true)
libhalsim_gui = cpp.find_library ('halsim_gui', dirs: [ luabot_sdk_libdirs ], required : true)
libhalsim_ws_client = cpp.find_library ('halsim_ws_client', dirs: [ luabot_sdk_libdirs ], required : true)
libhalsim_ws_core = cpp.find_library ('halsim_ws_core', dirs: [ luabot_sdk_libdirs ], required : true)
libhalsim_ws_server = cpp.find_library ('halsim_ws_server', dirs: [ luabot_sdk_libdirs ], required : true)
libhalsim_xrp = cpp.find_library ('halsim_xrp', dirs: [ luabot_sdk_libdirs ], required : true)

libwpigui = cpp.find_library ('wpigui', dirs: [ luabot_sdk_libdirs ], required : true)

libwpilibNewCommands = cpp.find_library ('wpilibNewCommands', dirs: [ luabot_sdk_libdirs ], required : true)
libwpinet = cpp.find_library ('wpinet', dirs: [ luabot_sdk_libdirs ], required : true)
libromiVendordep = cpp.find_library ('romiVendordep', dirs: [ luabot_sdk_libdirs ], required : false)
libxrpVendordep = cpp.find_library ('xrpVendordep', dirs: [ luabot_sdk_libdirs ], required : false)

luabot_dep = declare_dependency (
    link_with : [],
    include_directories : [
        include_directories ('./include'),
        luabot_sdk_includes ],
    dependencies : [])

luabot_internal_dep = declare_dependency (
    link_with : [],
    include_directories : include_directories ('./include'),
    dependencies : [ boost_dep ])

readline_dep = dependency('readline')

luabot_exe = executable ('luabot', [
        'util/luabot/main.cpp'
    ],
    cpp_args: ['-DLUA_USE_READLINE=1'],
    dependencies: [luabot_dep, libluajit, readline_dep],
    install: true)

subdir ('src')
subdir ('bindings')
subdir ('test')
