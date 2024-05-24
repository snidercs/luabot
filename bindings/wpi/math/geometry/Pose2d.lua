local ffi = require('ffi')

ffi.cdef [[
typedef struct FrcPose2d FrcPose2d;

typedef struct FrcRotation2d FrcRotation2d;
typedef struct FrcTransform2d FrcTransform2d;
typedef struct FrcTranslation2d FrcTranslation2d;
typedef struct FrcTwist2d FrcTwist2d;

FrcPose2d* frcPose2dNew (double x, double y, double r);
void frcPose2dFree (FrcPose2d* self);
void frcPose2dCollect();

FrcPose2d* frcPose2dPlus_Transform2d (const FrcPose2d* self, const FrcTransform2d* rhs);
FrcTransform2d* frcPose2dSub_Pose2d_Transform2d (const FrcPose2d* self, const FrcPose2d* other);
bool frcPose2dEquals(const FrcPose2d* lhs, const FrcPose2d* rhs);

const FrcTranslation2d* frcPose2dTranslation (const FrcPose2d* self);
double frcPose2dX(const FrcPose2d* self);
double frcPose2dY (const FrcPose2d* self);
const FrcRotation2d* frcPose2dRotation (const FrcPose2d* self);

FrcPose2d* frcPose2dMul_double (const FrcPose2d* self, double scalar);
FrcPose2d* frcPose2dDiv_double (const FrcPose2d* self, double scalar);

FrcPose2d* frcPose2dRotateBy (const FrcPose2d* self, const FrcRotation2d* r);
FrcPose2d* frcPose2dTransformBy (const FrcPose2d* self, const FrcTransform2d* other);
FrcPose2d* frcPose2dRelativeTo (const FrcPose2d* self, const FrcPose2d* other);

FrcPose2d* frcPose2dExp (const FrcPose2d* self, const FrcTwist2d* twist);
FrcTwist2d* frcPose2dLog (const FrcPose2d* self, const FrcPose2d* other);
]]

pcall(function()
    local _ = ffi.load('luabot-wpilibc', true)
end)

local C = ffi.C

---Represents a 2D pose containing translational and rotational elements.
---@class Pose2d
local Pose2d = {}

-- TODO: "Plus" Transform2d -> Pose2d
-- TODO: "Sub" Pose2d -> Transform2d

---Checks equality between this Pose2d and another object.
---@param other Pose2d
---@return boolean
function Pose2d:equals(other)
    return C.frcPose2dEquals(self, other)
end

---Returns the underlying translation.
---@return Translation2d
function Pose2d:translation()
    return C.frcPose2dTranslation(self)
end

---Returns the X component of the pose's translation.
---@return number
function Pose2d:x()
    return C.frcPose2dX(self)
end

---Returns the Y component of the pose's translation.
---@return number
function Pose2d:y()
    return C.frcPose2dY(self)
end

---Returns the underlying rotation.
---@return Rotation2d
function Pose2d:rotation()
    return C.frcPose2dRotation(self)
end

---Rotates the pose around the origin and returns the new pose.
---@param rotation Rotation2d The scalar.
---@return Pose2d "The rotated pose"
function Pose2d:rotateBy(rotation)
    return C.frcPose2dRotateBy(self, rotation)
end

---Transforms the pose by the given transformation and returns the new pose.
---@param transform Transform2d The transform to use
---@return Pose2d "The transformed pose"
function Pose2d:transformBy(transform)
    return C.frcPose2dTransformBy(self, transform)
end

---Returns the current pose relative to the given pose.
---
---This function can often be used for trajectory tracking or pose
---stabilization algorithms to get the error between the reference and the
---current pose.
---
---@param other Pose2d The pose that is the origin of the new coordinate frame.
---@return Pose2d "The current pose relative to the new origin pose."
function Pose2d:relativeTo(other)
    return C.frcPose2dRelativeTo(self, other)
end

---Obtain a new Pose2d from a (constant curvature) velocity.
---
---See https://file.tavsys.net/control/controls-engineering-in-frc.pdf section
---10.2 "Pose exponential" for a derivation.
---
---The twist is a change in pose in the robot's coordinate frame since the
---previous pose update. When the user runs exp() on the previous known
---field-relative pose with the argument being the twist, the user will
---receive the new field-relative pose.
---
---"Exp" represents the pose exponential, which is solving a differential
---equation moving the pose forward in time.
---
---@param twist Twist2d The change in pose in the robot's coordinate frame since the
---previous pose update. For example, if a non-holonomic robot moves forward
---0.01 meters and changes angle by 0.5 degrees since the previous pose
---update, the twist would be Twist2d{0.01_m, 0_m, 0.5_deg}.
---
---@return Pose2d "The new pose of the robot."
function Pose2d:exp(twist)
    return C.frcPose2dExp(self, twist)
end

---Returns a Twist2d that maps this pose to the end pose. If c is the output
---of a.Log(b), then a.Exp(c) would yield b.
---
---@param other Pose2d The end pose for the transformation.
---@return Twist2d "The twist that maps this to other."
function Pose2d:log(other)
    return C.frcPose2dLog(self, other)
end

local Pose2d_mt = {
    __index = Pose2d
}

-- Require dependencies only only once using a flagged closure.
local load_once = (function()
    local loaded = false
    return function(mods)
        if loaded then return end
        for _, mod in ipairs(mods) do
            require(mod)
        end
        loaded = true
    end
end)()

setmetatable(Pose2d, {
    requires = {
        'wpi.math.geometry.Rotation2d',
        'wpi.math.geometry.Translation2d',
        'wpi.math.geometry.Transform2d',
        'wpi.math.geometry.Twist2d'
    },
    __call = function(_, ...)
        local nargs = select('#', ...)
        local impl

        if nargs >= 2 then
            local x = tonumber(select(1, ...), 10)
            local y = tonumber(select(2, ...), 10)
            local z; if nargs >= 3 then z = tonumber(select(3, ...), 10) end
            impl = ffi.gc(C.frcPose2dNew(x or 0, y or 0, z or 0), C.frcPose2dFree)
        else
            impl = ffi.gc(C.frcPose2dNew(0, 0, 0), C.frcPose2dFree)
        end

        return impl
    end
})

ffi.metatype('FrcPose2d', Pose2d_mt)
return Pose2d
