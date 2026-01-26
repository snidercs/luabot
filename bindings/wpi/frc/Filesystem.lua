---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local ffi = require ('ffi')

ffi.cdef[[
void free (void* ptr);
char* frcFilesystemGetLaunchDirectory();
char* frcFilesystemGetOperatingDirectory();
char* frcFilesystemGetDeployDirectory();
]]

pcall(ffi.load, 'luabot-wpilibc', true)

local C = ffi.C

local Filesystem = {}

---
---Obtains the current working path that the program was launched with.
---This is analogous to the `pwd` command on unix.
---
---@return string path The result of the current working path lookup.
---
function Filesystem.getLaunchDirectory()
    return ffi.string (ffi.gc (C.frcFilesystemGetLaunchDirectory(), C.free))
end

---
---Obtains the operating directory of the program. On the roboRIO, this
---is /home/lvuser. In simulation, it is where the simulation was launched
---from (`pwd`).
---
---@return string "The result of the operating directory lookup."
---
function Filesystem.getOperatingDirectory()
    return ffi.string (ffi.gc (C.frcFilesystemGetOperatingDirectory(), C.free))
end

---
---Obtains the deploy directory of the program, which is the remote location
---src/main/deploy is deployed to by default. On the roboRIO, this is
---/home/lvuser/deploy. In simulation, it is where the simulation was launched
---from, in the subdirectory "src/main/deploy" (`pwd`/src/main/deploy).
---
---@return string "The result of the operating directory lookup"
---
function Filesystem.getDeployDirectory()
    return ffi.string (ffi.gc (C.frcFilesystemGetDeployDirectory(), C.free))
end

return Filesystem
