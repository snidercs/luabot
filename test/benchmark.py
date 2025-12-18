#!/usr/bin/env python3
"""
Benchmark comparison between plusone.lua and plusone.cpp
Uses Python's subprocess and time modules for accurate measurements
"""

import subprocess
import time
import statistics
import os
from pathlib import Path

SCRIPT_DIR = Path(__file__).parent
BUILD_DIR = SCRIPT_DIR.parent / "build"
RUNS = 10

def run_benchmark(cmd, env=None, runs=RUNS):
    """Run a command multiple times and return timing statistics"""
    times = []
    for i in range(runs):
        start = time.perf_counter()
        result = subprocess.run(
            cmd,
            env=env,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            check=True
        )
        end = time.perf_counter()
        elapsed = end - start
        times.append(elapsed)
        print(f"  Run {i+1:2d}: {elapsed:.4f}s")
    
    return {
        'times': times,
        'mean': statistics.mean(times),
        'median': statistics.median(times),
        'stdev': statistics.stdev(times) if len(times) > 1 else 0,
        'min': min(times),
        'max': max(times)
    }

def main():
    print("=" * 67)
    print("Benchmark: plusone.lua vs plusone.cpp")
    print("Iterations per run: 2,000,000")
    print(f"Number of runs: {RUNS}")
    print("=" * 67)
    print()
    
    # Check executables exist
    luabot = BUILD_DIR / "luabot"
    cpp_exe = BUILD_DIR / "test" / "plusone"
    
    if not luabot.exists():
        print(f"Error: {luabot} not found")
        return 1
    
    if not cpp_exe.exists():
        print(f"Building C++ version...")
        subprocess.run(["ninja", "-C", str(BUILD_DIR), "test/plusone"], check=True)
        print()
    
    # Set up environment for Lua
    lua_env = os.environ.copy()
    lua_path = f"{BUILD_DIR}/lua/?.lua;{BUILD_DIR}/lua/?/init.lua;;"
    lua_env['LUA_PATH'] = lua_path
    
    # Benchmark Lua
    print("Benchmarking Lua version...")
    lua_cmd = [str(luabot), str(SCRIPT_DIR / "plusone.lua")]
    lua_stats = run_benchmark(lua_cmd, env=lua_env)
    
    print()
    
    # Benchmark C++
    print("Benchmarking C++ version...")
    cpp_cmd = [str(cpp_exe)]
    cpp_stats = run_benchmark(cpp_cmd)
    
    # Print results
    print()
    print("=" * 67)
    print("Results:")
    print("=" * 67)
    print(f"{'Metric':<15} {'Lua':>12} {'C++':>12} {'Ratio':>12}")
    print("-" * 67)
    print(f"{'Mean':<15} {lua_stats['mean']:>11.4f}s {cpp_stats['mean']:>11.4f}s {lua_stats['mean']/cpp_stats['mean']:>11.2f}x")
    print(f"{'Median':<15} {lua_stats['median']:>11.4f}s {cpp_stats['median']:>11.4f}s {lua_stats['median']/cpp_stats['median']:>11.2f}x")
    print(f"{'Min':<15} {lua_stats['min']:>11.4f}s {cpp_stats['min']:>11.4f}s {lua_stats['min']/cpp_stats['min']:>11.2f}x")
    print(f"{'Max':<15} {lua_stats['max']:>11.4f}s {cpp_stats['max']:>11.4f}s {lua_stats['max']/cpp_stats['max']:>11.2f}x")
    print(f"{'Std Dev':<15} {lua_stats['stdev']:>11.4f}s {cpp_stats['stdev']:>11.4f}s")
    print("=" * 67)
    
    ratio = lua_stats['mean'] / cpp_stats['mean']
    if ratio < 1:
        print(f"Lua is {1/ratio:.2f}x faster than C++")
    elif ratio > 1:
        print(f"C++ is {ratio:.2f}x faster than Lua")
    else:
        print("Performance is roughly equal")
    print("=" * 67)
    
    return 0

if __name__ == "__main__":
    exit(main())
