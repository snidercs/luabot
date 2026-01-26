---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local ffi = require('ffi')

ffi.cdef [[
typedef struct FrcRotation2d FrcRotation2d;

FrcRotation2d* frcRotation2dNew (double radians);
FrcRotation2d* frcRotation2dNewWithCoords (double x, double y);

void frcRotation2dFree (FrcRotation2d* self);

bool frcRotation2dEquals(const FrcRotation2d* lhs, const FrcRotation2d* rhs);

double frcRotation2dRadians (const FrcRotation2d* self);
double frcRotation2dDegrees (const FrcRotation2d* self);
]]

-- FIXME: lib path shouldn't be hardcoded.
pcall(ffi.load, 'luabot-ffi', true)
local lib = ffi.C

---2d rotation.
---@class Rotation2d
local Rotation2d = {}

function Rotation2d:degrees() return lib.frcRotation2dDegrees (self) end
function Rotation2d:radians() return lib.frcRotation2dRadians (self) end

function Rotation2d.fromDegrees(degrees)
    return Rotation2d (degrees * math.pi / 180.0)
end

function Rotation2d.fromRadians(radians)
    return Rotation2d(radians)
end

function Rotation2d.fromRotations(rotations)
    return Rotation2d (rotations * 2.0 * math.pi)
end

local Rotation2d_mt = {
    __index = Rotation2d
}

setmetatable (Rotation2d, {
    __call = function(_, ...)
        local nargs = select('#', ...)
        local impl

        if nargs == 1 then
            local rads = tonumber (select (1, ...), 10)
            impl = lib.frcRotation2dNew (rads or 0.0)
        elseif nargs == 2 then
            local x = tonumber(select(1, ...), 10)
            local y = tonumber(select(2, ...), 10)
            impl = lib.frcRotation2dNewWithCoords (x or 0, y or 0)
        else
            impl = lib.frcRotation2dNew (0)
        end

        return ffi.gc (impl, lib.frcRotation2dFree)
    end
})

ffi.metatype ('FrcRotation2d', Rotation2d_mt)
return Rotation2d
