# LuaBot Vendor Dependency

## Distribution Strategy
- GitHub releases with platform-specific zips
- Offline installer copies to `~/wpilib/2026/maven/` and `~/wpilib/2026/vendordeps/`
- No Maven hosting required

## Zip Structure

Each platform zip is self-contained:

```
luabot-{VERSION}-linuxathena.zip
├── include/
│   ├── luajit-2.1/           (from 3rdparty/linuxathena/include/)
│   └── luabot/               (from build/include/luabot/)
│       ├── ffi/
│       │   └── wpi/
│       └── *.ipp
├── lib/
│   └── libluajit-2.1.a       (from 3rdparty/linuxathena/lib/)
└── lua/                      (from build/lua/)
    ├── luabot/
    └── wpi/

luabot-{VERSION}-osxuniversal.zip
├── include/
│   ├── luajit-2.1/           (from 3rdparty/include/)
│   └── luabot/               (from build/include/luabot/)
├── lib/
│   └── libluajit-2.1.a       (from 3rdparty/lib/)
└── lua/

luabot-{VERSION}-windowsx86-64.zip
├── include/
│   ├── luajit-2.1/
│   └── luabot/
├── lib/
│   └── luajit-2.1.lib        (from 3rdparty/windows/lib/)
└── lua/
```

## Notes
- LuaJIT headers are platform-specific (pointer sizes, CPU features)
- Lua modules are platform-agnostic but included in each zip for simplicity
- C++ side is header-only (FFI wrappers in `luabot/ffi/`)
- LuaBot console application (future): teams compile from source, not distributed in vendordep
