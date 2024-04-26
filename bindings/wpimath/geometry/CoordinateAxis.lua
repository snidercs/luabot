local ffi = require ('ffi')

---CoordinateAxis wrapper
---@class CoordinateAxis
local CoordinateAxis = {}

ffi.cdef[[
typedef struct FrcCoordinateAxis FrcCoordinateAxis;

FrcCoordinateAxis* frcCoordinateAxisNew (double x, double y, double z);
void frcCoordinateAxisFree (FrcCoordinateAxis* self);

const FrcCoordinateAxis* frcCoordinateAxisN();
const FrcCoordinateAxis* frcCoordinateAxisS();
const FrcCoordinateAxis* frcCoordinateAxisE();
const FrcCoordinateAxis* frcCoordinateAxisW();
const FrcCoordinateAxis* frcCoordinateAxisU();
const FrcCoordinateAxis* frcCoordinateAxisD();
]]

local lib = ffi.load ('luabot-wpimath')

function CoordinateAxis.N() return lib.frcCoordinateAxisN() end
function CoordinateAxis.S() return lib.frcCoordinateAxisS() end
function CoordinateAxis.E() return lib.frcCoordinateAxisE() end
function CoordinateAxis.W() return lib.frcCoordinateAxisW() end
function CoordinateAxis.U() return lib.frcCoordinateAxisU() end
function CoordinateAxis.D() return lib.frcCoordinateAxisD() end

setmetatable (CoordinateAxis, {
    __call = function(T, x, y, z)
        x = tonumber(x) or 0
        y = tonumber(y) or 0
        z = tonumber(z) or 0
        local impl = lib.frcCoordinateAxisNew(x,y,z)
        return ffi.gc (impl, lib.frcCoordinateAxisFree)
    end
})

ffi.metatype ('FrcCoordinateAxis', { __index = CoordinateAxis })
return CoordinateAxis
