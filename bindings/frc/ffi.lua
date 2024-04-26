local ffi = require ('ffi')

ffi.cdef [[
typedef struct FrcPose2d FrcPose2d;
typedef struct FrcRotation2d FrcRotation2d;
typedef struct FrcTransform2d FrcTransform2d;
typedef struct FrcTwist2d FrcTwist2d;
typedef struct FrcTranslation2d FrcTranslation2d;

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

return ffi
