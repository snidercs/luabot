#!/usr/bin/env python3
"""
LuaJIT build script for cross-platform builds.
Builds LuaJIT and installs it to the 3rdparty directory.
"""

import argparse
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path


class LuaJITBuilder:
    def __init__(self, root_dir: Path):
        self.root_dir = root_dir
        self.luajit_src_dir = root_dir / 'deps' / 'luajit' / 'src'
        self.thirdparty_dir = root_dir / '3rdparty'
        self.system = platform.system()
        
    def clean(self):
        """Remove previous 3rdparty directory."""
        if self.thirdparty_dir.exists():
            print(f'Cleaning {self.thirdparty_dir}...')
            shutil.rmtree(self.thirdparty_dir)
            
    def create_directories(self):
        """Create 3rdparty directory structure."""
        dirs = [
            self.thirdparty_dir,
            self.thirdparty_dir / 'bin',
            self.thirdparty_dir / 'lib',
            self.thirdparty_dir / 'include' / 'luajit-2.1',
            self.thirdparty_dir / 'share' / 'lua' / 'luajit-2.1' / 'jit',
        ]
        
        for dir_path in dirs:
            dir_path.mkdir(parents=True, exist_ok=True)
            print(f'Created {dir_path}')
            
    def build_windows(self):
        """Build LuaJIT on Windows using MSVC."""
        print('Building LuaJIT for Windows...')
        
        # Run msvcbuild.bat with lua52compat and static options
        build_script = self.luajit_src_dir / 'msvcbuild.bat'
        if not build_script.exists():
            raise FileNotFoundError(f'Build script not found: {build_script}')
            
        # Execute in the src directory
        result = subprocess.run(
            ['cmd', '/c', 'msvcbuild.bat', 'lua52compat', 'static'],
            cwd=self.luajit_src_dir,
            check=True
        )
        
        if result.returncode != 0:
            raise RuntimeError('LuaJIT build failed')
            
        print('LuaJIT build completed successfully')
        
    def build_unix(self):
        """Build LuaJIT on Unix-like systems (Linux, macOS)."""
        print(f'Building LuaJIT for {self.system}...')
        
        # Run make with appropriate options
        make_args = ['make', 'XCFLAGS=-DLUAJIT_ENABLE_LUA52COMPAT']
        
        result = subprocess.run(
            make_args,
            cwd=self.luajit_src_dir,
            check=True
        )
        
        if result.returncode != 0:
            raise RuntimeError('LuaJIT build failed')
            
        print('LuaJIT build completed successfully')
        
    def build(self):
        """Build LuaJIT based on the current platform."""
        if self.system == 'Windows':
            self.build_windows()
        elif self.system in ('Linux', 'Darwin'):
            self.build_unix()
        else:
            raise NotImplementedError(f'Platform {self.system} is not supported')
            
    def install_windows(self):
        """Install LuaJIT build artifacts on Windows."""
        print('Installing LuaJIT artifacts...')
        
        # Copy executables
        shutil.copy2(
            self.luajit_src_dir / 'luajit.exe',
            self.thirdparty_dir / 'bin' / 'luajit.exe'
        )
        
        # Copy static library
        shutil.copy2(
            self.luajit_src_dir / 'lua51.lib',
            self.thirdparty_dir / 'lib' / 'lua51.lib'
        )
        
        # Copy headers
        headers = ['lua.h', 'lualib.h', 'lauxlib.h', 'luaconf.h', 'luajit.h', 'lua.hpp']
        for header in headers:
            shutil.copy2(
                self.luajit_src_dir / header,
                self.thirdparty_dir / 'include' / 'luajit-2.1' / header
            )
            
        # Copy jit Lua files
        jit_src_dir = self.luajit_src_dir / 'jit'
        jit_dest_dir = self.thirdparty_dir / 'share' / 'lua' / 'luajit-2.1' / 'jit'
        
        for lua_file in jit_src_dir.glob('*.lua'):
            shutil.copy2(lua_file, jit_dest_dir / lua_file.name)
            
        print('Installation completed successfully')
        
    def install_unix(self):
        """Install LuaJIT build artifacts on Unix-like systems."""
        print('Installing LuaJIT artifacts...')
        
        # Copy executable
        shutil.copy2(
            self.luajit_src_dir / 'luajit',
            self.thirdparty_dir / 'bin' / 'luajit'
        )
        
        # Make it executable
        os.chmod(self.thirdparty_dir / 'bin' / 'luajit', 0o755)
        
        # Copy static library
        shutil.copy2(
            self.luajit_src_dir / 'libluajit.a',
            self.thirdparty_dir / 'lib' / 'libluajit.a'
        )
        
        # Copy headers
        headers = ['lua.h', 'lualib.h', 'lauxlib.h', 'luaconf.h', 'luajit.h', 'lua.hpp']
        for header in headers:
            shutil.copy2(
                self.luajit_src_dir / header,
                self.thirdparty_dir / 'include' / 'luajit-2.1' / header
            )
            
        # Copy jit Lua files
        jit_src_dir = self.luajit_src_dir / 'jit'
        jit_dest_dir = self.thirdparty_dir / 'share' / 'lua' / 'luajit-2.1' / 'jit'
        
        for lua_file in jit_src_dir.glob('*.lua'):
            shutil.copy2(lua_file, jit_dest_dir / lua_file.name)
            
        print('Installation completed successfully')
        
    def install(self):
        """Install LuaJIT based on the current platform."""
        if self.system == 'Windows':
            self.install_windows()
        elif self.system in ('Linux', 'Darwin'):
            self.install_unix()
        else:
            raise NotImplementedError(f'Platform {self.system} is not supported')
            
    def run(self, clean: bool = True):
        """Run the complete build and install process."""
        if clean:
            self.clean()
            
        self.create_directories()
        self.build()
        self.install()
        
        print()
        print('=== Build results copied to 3rdparty ===')


def main():
    parser = argparse.ArgumentParser(
        description='Build and install LuaJIT to 3rdparty directory'
    )
    parser.add_argument(
        '--no-clean',
        action='store_true',
        help='Do not clean the 3rdparty directory before building'
    )
    parser.add_argument(
        '--root',
        type=Path,
        default=None,
        help='Root directory of the project (default: parent of util directory)'
    )
    
    args = parser.parse_args()
    
    # Determine root directory
    if args.root:
        root_dir = args.root
    else:
        # Assume script is in util/ directory
        script_dir = Path(__file__).resolve().parent
        root_dir = script_dir.parent
        
    print(f'Project root: {root_dir}')
    print(f'Platform: {platform.system()}')
    print()
    
    try:
        builder = LuaJITBuilder(root_dir)
        builder.run(clean=not args.no_clean)
        return 0
    except Exception as e:
        print(f'Error: {e}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    sys.exit(main())
