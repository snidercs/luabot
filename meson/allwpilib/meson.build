
frc_is_sim = not meson.is_cross_build()
frc_platform = frc_is_sim ? 'linuxx86-64' : 'linuxathena'
frc_buildtype = 'release'
frc_libdir = get_option ('frc-libs')
frc_libdir = fs.expanduser (frc_libdir)

wpilibc_dep = []
wpilib_sonames = '''
    cameraserver
    cscore
    wpiHal
    wpiutil
    ntcore
    wpilibc
    wpimath
    wpinet
    wpilibNewCommands
    apriltag
    pthread
    dl
'''.split()

wpilib_deps = []
foreach lib: wpilib_sonames
    wpilib_deps += cpp.find_library (lib, dirs: [frc_libdir], required: true)
endforeach

wpilib_deps += [declare_dependency (
    include_directories: fs.expanduser ('~/wpilib/2025/luabot/include')
)]
