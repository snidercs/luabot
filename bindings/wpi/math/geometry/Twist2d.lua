---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local ffi = require('ffi')
ffi.cdef[[
typedef struct FrcTwist2d FrcTwist2d;
FrcTwist2d* frcTwist2dNew();
void frcTwist2dFree (FrcTwist2d* self);
bool frcTwist2dEquals (const FrcTwist2d* self, const FrcTwist2d* other);
]]

pcall(ffi.load, 'luabot-ffi', true)
local lib = ffi.C

---Twist2d wrapper
---@class Twist2d
local Twist2d = {}
local Twist2d_mt = {
    __index = Twist2d
}

function Twist2d:equals (other)
    return lib.frcTwist2dEquals (self, other)
end

setmetatable(Twist2d, {
    __call = function(_)
        return ffi.gc (lib.frcTwist2dNew(), lib.frcTwist2dFree)
    end
})

ffi.metatype ('FrcTwist2d', Twist2d_mt)
return Twist2d
