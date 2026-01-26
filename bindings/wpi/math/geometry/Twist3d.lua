---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local ffi = require('ffi')

ffi.cdef[[
typedef struct FrcTwist3d FrcTwist3d;
]]

pcall(ffi.load, 'luabot-ffi', true)
local lib = ffi.C

---Twist3d wrapper
---@class Twist3d
local Twist3d = {}
local Twist3d_mt = {
    __index = Twist3d
}

function Twist3d:equals (other)
    return lib.frcTwist3dEquals (self, other)
end

setmetatable(Twist3d, {
    __call = function(_)
        return ffi.gc (lib.frcTwist3dNew(), lib.frcTwist3dFree)
    end
})

ffi.metatype ('FrcTwist3d', Twist3d_mt)
return Twist3d
