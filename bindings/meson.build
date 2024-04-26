
wpilibc_lib = library ('luabot-wpilibc', '''
        wpilibc/GenericHID.cpp
    '''.split(),
    dependencies: [wpilibc_dep])

wpimath_lib = library ('luabot-wpimath', '''
        wpimath/geometry.cpp
    '''.split(),
    dependencies: [wpimath_dep],
    install: true
)
