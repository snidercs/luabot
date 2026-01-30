#!/usr/bin/env python3
# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

import os
import platform
import zipfile
from pathlib import Path

PLATFORMS = [
    "linuxathena",
    "windowsx86-64",
    "linuxx86-64",
    "osxuniversal"
]

def frc_platform():
    system = platform.system()
    machine = platform.machine()
    
    if system == 'Darwin':
        return 'osxuniversal'
    elif system == 'Linux':
        if machine in ('armv7l', 'armv7'):
            return 'linuxarm32'
        elif machine in ('aarch64', 'arm64'):
            return 'linuxarm64'
        else:
            return 'linuxx86-64'
    elif system == 'Windows':
        if machine in ('x86', 'i386', 'i686'):
            return 'windowsx86'
        else:
            return 'windowsx86-64'
    else:
        raise ValueError(f"Unsupported platform: {system} {machine}")

def artifact_platform(plat:str):
    frcplat = plat.strip()
    if frcplat == 'linuxx86-64': 
        return 'linux64'
    elif frcplat == 'linuxathena':
        return 'roborio'
    elif frcplat == 'osxuniversal':
        return 'mac'
    elif frcplat == 'windowsx86-64':
        return 'win64'
    else:
        raise ValueError(f"Unsupported artifact platform for {frcplat}")

def platform_is_build(platform:str):
    return platform.strip() == frc_platform()

def create_luajit_headers(version, output_dir):
    """Create single platform-independent luajit headers zip (headers are identical across platforms)"""
    include_dir = '3rdparty/include/luajit-2.1'
    zip_name = f"luajit-cpp-{version}-headers.zip"
    zip_path = Path(output_dir) / zip_name
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # zip the include_dir to the zip_path
    include_path = Path(include_dir)
    if not include_path.exists():
        print(f"Warning: {include_dir} does not exist, skipping")
        return None
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(include_path):
            for file in files:
                file_path = Path(root) / file
                # Put files directly at root, no include/ prefix
                arcname = file
                zipf.write(file_path, arcname)
    
    print(f"Created {zip_path}")
    return zip_path

def create_luajit_libs(version, platform, output_dir):
    """Create luajit-cpp-{version}-{platform}static.zip with libraries and share files"""
    base_dir = '3rdparty' if platform_is_build(platform) else f'3rdparty/{platform}'
    zip_name = f"luajit-cpp-{version}-{platform}static.zip"
    zip_path = Path(output_dir) / zip_name
    top_level_dir = f"luajit-{version}-{platform}"
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    base_path = Path(base_dir)
    if not base_path.exists():
        print(f"Warning: {base_dir} does not exist, skipping")
        return None
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add library files (*.a, *.lib) to lib/
        lib_dir = base_path / 'lib'
        if lib_dir.exists():
            for file_path in lib_dir.rglob('*'):
                if file_path.is_file() and file_path.suffix in ['.a', '.lib'] and 'luajit' in file_path.name.lower():
                    # Rename to standard name: libluajit.a (Unix) or luajit.lib (Windows)
                    if file_path.suffix == '.a':
                        arcname = os.path.join(top_level_dir, 'lib', 'libluajit.a')
                    else:  # .lib
                        arcname = os.path.join(top_level_dir, 'lib', 'luajit.lib')
                    zipf.write(file_path, Path(arcname))
                    break  # Only add the first matching file

    # Create debug zip with libluajitd.a (GradleRIO requires debug zips)
    import shutil
    debug_zip_name = f"{zip_path.stem}debug.zip"
    debug_zip_path = zip_path.parent / debug_zip_name
    
    # Create debug zip with renamed library
    with zipfile.ZipFile(debug_zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add library files as libluajitd.a (Unix) or luajitd.lib (Windows) for debug
        lib_dir = base_path / 'lib'
        if lib_dir.exists():
            for file_path in lib_dir.rglob('*'):
                if file_path.is_file() and file_path.suffix in ['.a', '.lib'] and 'luajit' in file_path.name.lower():
                    if file_path.suffix == '.a':
                        arcname = os.path.join(top_level_dir, 'lib', 'libluajitd.a')
                    else:  # .lib
                        arcname = os.path.join(top_level_dir, 'lib', 'luajitd.lib')
                    zipf.write(file_path, Path(arcname))
                    break  # Only add the first matching file

    print(f"Created {debug_zip_path}")
    print(f"Created {zip_path}")
    return zip_path

def create_luabot_headers(version, build_dir, source_dir, output_dir):
    """Create luabot-cpp-{version}-headers.zip with headers from build/include and include/"""
    zip_name = f"luabot-cpp-{version}-headers.zip"
    zip_path = Path(output_dir) / zip_name
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add headers from build/include
        build_include = Path(build_dir) / 'include'
        if build_include.exists():
            for root, dirs, files in os.walk(build_include):
                for file in files:
                    if not file.endswith('.in'):
                        file_path = Path(root) / file
                        rel_path = file_path.relative_to(build_include)
                        arcname = rel_path
                        zipf.write(file_path, arcname)
        
        # Add headers from include/
        source_include = Path(source_dir) / 'include'
        if source_include.exists():
            for root, dirs, files in os.walk(source_include):
                for file in files:
                    if not file.endswith('.in'):
                        file_path = Path(root) / file
                        rel_path = file_path.relative_to(source_include)
                        arcname = rel_path
                        zipf.write(file_path, arcname)
    
    print(f"Created {zip_path}")
    return zip_path

def create_luabot_libs(version, platform, build_dir, output_dir):
    """Create luabot-cpp-{version}-{platform}static.zip with stub library"""
    zip_name = f"luabot-cpp-{version}-{platform}static.zip"
    zip_path = Path(output_dir) / zip_name
    top_level_dir = f"luabot-{version}-{platform}"
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Determine library source path based on platform
    if platform == 'linuxathena':
        lib_source = Path('3rdparty/linuxathena/lib')
    else:
        lib_source = Path(build_dir) / 'vendordep'
    
    if not lib_source.exists():
        print(f"Warning: {lib_source} does not exist, skipping")
        return None
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add library files (*.a, *.lib) to lib/
        if lib_source.exists():
            for file_path in lib_source.rglob('*'):
                if file_path.is_file() and file_path.suffix in ['.a', '.lib'] and 'luabot' in file_path.name.lower():
                    # Rename to standard name: libluabot-stub.a (Unix) or luabot-stub.lib (Windows)
                    if file_path.suffix == '.a':
                        arcname = os.path.join(top_level_dir, 'lib', 'libluabot-stub.a')
                    else:  # .lib
                        arcname = os.path.join(top_level_dir, 'lib', 'luabot-stub.lib')
                    zipf.write(file_path, Path(arcname))
                    break  # Only add the first matching file

    # Create debug zip with renamed library (GradleRIO requires debug zips)
    debug_zip_name = f"{zip_path.stem}debug.zip"
    debug_zip_path = zip_path.parent / debug_zip_name
    
    with zipfile.ZipFile(debug_zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add library files as libluabot-stubd.a (Unix) or luabot-stubd.lib (Windows) for debug
        if lib_source.exists():
            for file_path in lib_source.rglob('*'):
                if file_path.is_file() and file_path.suffix in ['.a', '.lib'] and 'luabot' in file_path.name.lower():
                    if file_path.suffix == '.a':
                        arcname = os.path.join(top_level_dir, 'lib', 'libluabot-stubd.a')
                    else:  # .lib
                        arcname = os.path.join(top_level_dir, 'lib', 'luabot-stubd.lib')
                    zipf.write(file_path, Path(arcname))
                    break  # Only add the first matching file
    
    print(f"Created {debug_zip_path}")
    print(f"Created {zip_path}")
    return zip_path

def create_lua_bindings(version, build_dir, output_dir):
    """Create luabot-lua-{version}-modules.zip with WPILib Lua bindings"""
    zip_name = f"luabot-lua-{version}-modules.zip"
    zip_path = Path(output_dir) / zip_name
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    lua_source = Path(build_dir) / 'lua'
    
    if not lua_source.exists():
        print(f"Warning: {lua_source} does not exist, skipping Lua bindings")
        return None
    
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add all Lua files from build/lua/wpi and build/lua/luabot
        for root, dirs, files in os.walk(lua_source):
            for file in files:
                file_path = Path(root) / file
                rel_path = file_path.relative_to(lua_source)
                zipf.write(file_path, rel_path)
    
    print(f"Created {zip_path}")
    return zip_path

def generate_pom (version, file, artifact_id, output_dir):
    """Generate POM files from template"""
    template_path = Path(file)
    
    if not template_path.exists():
        print(f"Warning: {template_path} does not exist, skipping POM generation")
        return None
    
    # Read template
    with open(template_path, 'r') as f:
        template_content = f.read()
    
    # Replace version placeholder
    pom_content = template_content.replace('@PROJECT_VERSION@', version)
    pom_content = pom_content.replace('@ARTIFACT_ID@', artifact_id)
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Write POM file
    pom_path = Path(output_dir) / f'{artifact_id}-{version}.pom'
    with open(pom_path, 'w') as f:
        f.write(pom_content)
    
    print(f"Created {pom_path}")
    return pom_path

def generate_luabot_json(version, github_repo, source_dir, output_dir):
    """Generate LuaBot.json from template"""
    template_path = Path(source_dir) / 'vendordep' / 'LuaBot.json.in'
    
    if not template_path.exists():
        print(f"Warning: {template_path} does not exist, skipping LuaBot.json generation")
        return None
    
    # Read template
    with open(template_path, 'r') as f:
        template_content = f.read()
    
    # Replace @VAR@ style placeholders (CMake @ONLY mode)
    json_content = template_content.replace('@PROJECT_VERSION@', version)
    json_content = json_content.replace('@GITHUB_REPO@', github_repo)
    
    # Ensure output directory exists
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Write JSON file
    json_path = Path(output_dir) / 'LuaBot.json'
    with open(json_path, 'w') as f:
        f.write(json_content)
    
    print(f"Created {json_path}")
    return json_path

def install_artifact(artifact_id, version, output_dir):
    maven_dir =  os.path.expanduser ('~/wpilib/2026/maven/org/luabot')
    artifact_dir = os.path.join (maven_dir, artifact_id, version)
    
    Path(artifact_dir).mkdir(parents=True, exist_ok=True)
    
    # Find and copy matching files
    source_path = Path(output_dir)
    pattern = f"{artifact_id}-{version}*.*"
    
    import shutil
    for file_path in source_path.glob(pattern):
        if file_path.is_file():
            dest_path = Path(artifact_dir) / file_path.name
            shutil.copy2(file_path, dest_path)
            print(f"Installed {file_path.name} to {artifact_dir}")

def create_stub_libs(artifact_name, version, platform, output_dir):
    """Create stub/empty library zips for platforms without local builds"""
    zip_name = f"{artifact_name}-{version}-{platform}static.zip"
    zip_path = Path(output_dir) / zip_name
    top_level_dir = f"{artifact_name.replace('-cpp', '')}-{version}-{platform}"
    
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    # Create empty zip with directory structure
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        # Add empty lib directory
        zipf.writestr(f"{top_level_dir}/lib/.keep", "")
    
    # Create debug variant
    debug_zip_name = f"{zip_path.stem}debug.zip"
    debug_zip_path = zip_path.parent / debug_zip_name
    
    with zipfile.ZipFile(debug_zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        zipf.writestr(f"{top_level_dir}/lib/.keep", "")
    
    print(f"Created stub {zip_path}")
    print(f"Created stub {debug_zip_path}")
    return zip_path

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Create WPILib vendordep ZIP files for LuaBot')
    parser.add_argument('--version', required=True, help='Version string (e.g., 0.0.1)')
    parser.add_argument('--build-dir', default='build', help='Build directory (default: build)')
    parser.add_argument('--source-dir', default='.', help='Source directory (default: .)')
    parser.add_argument('--output-dir', default='build/vendordep', help='Output directory for ZIP files (default: build)')
    parser.add_argument('--github-repo', default='snidercs/luabot', help='GitHub repository (default: snidercs/luabot)')
    parser.add_argument('--install', action='store_true', help='Install to maven directory structure. This option will also build stubs when needed (default: false)')
    parser.add_argument('--stubs', action='store_true', help='Generate stub zips for platforms without local builds (for local dev/testing)')
    
    args = parser.parse_args()
    
    # Generate LuaBot.json
    generate_luabot_json(args.version, args.github_repo, args.source_dir, args.output_dir)
    
    # Create headers zip
    create_luabot_headers (args.version, args.build_dir, args.source_dir, args.output_dir)
    generate_pom(args.version, 
        os.path.join (args.source_dir, 'vendordep', 'luabot.pom.in'), 
        'luabot-cpp', args.output_dir)

    luajit_version = '2.1'
    # Create single headers zip (platform-independent)
    create_luajit_headers(luajit_version, args.output_dir)
    create_lua_bindings(args.version, args.build_dir, args.output_dir)

    # Generate single POM for luajit-cpp
    pom_template = os.path.join(args.source_dir, 'vendordep', 'luajit.pom.in')
    generate_pom(luajit_version, pom_template, 'luajit-cpp', args.output_dir)
    
    # Create platform-specific library zips
    built_platforms = list(set([frc_platform(), 'linuxathena']))
    for platform in built_platforms:
        create_luajit_libs(luajit_version, platform, args.output_dir)
        create_luabot_libs(args.version, platform, args.build_dir, args.output_dir)
    
    # Create stub zips for platforms we don't have binaries for (only if --stubs)
    if args.stubs or args.install:
        missing_platforms = [p for p in PLATFORMS if p not in built_platforms]
        for platform in missing_platforms:
            create_stub_libs('luajit-cpp', luajit_version, platform, args.output_dir)
            create_stub_libs('luabot-cpp', args.version, platform, args.output_dir)

    if args.install:
        install_artifact('luabot-cpp', args.version, args.output_dir)
        install_artifact('luabot-lua', args.version, args.output_dir)
        install_artifact('luajit-cpp', luajit_version, args.output_dir)

if __name__ == '__main__':
    main()
