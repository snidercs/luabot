#include <frc/geometry/CoordinateAxis.h>
#include <frc/geometry/Pose2d.h>
#include <frc/geometry/Rotation2d.h>
#include <frc/geometry/Transform2d.h>
#include <frc/geometry/Twist2d.h>

static_assert (sizeof (void*) == sizeof (frc::Pose2d*));

template <typename Obj, typename Ctp>
inline static Obj& toref (Ctp&& ptr) { return *((Obj*) ptr); }

template <typename Obj, typename Ctp>
inline static const Obj& toref (const Ctp&& ptr) { return *((const Obj*) ptr); }

extern "C" {

//==============================================================================
typedef void FrcCoordinateAxis;

FrcCoordinateAxis* frcCoordinateAxisNew (double x, double y, double z) {
    return new frc::CoordinateAxis (x, y, z);
}

void frcCoordinateAxisFree (FrcCoordinateAxis* self) {
    delete (frc::CoordinateAxis*) self;
}

const FrcCoordinateAxis* frcCoordinateAxisN() {
    return new frc::CoordinateAxis (frc::CoordinateAxis::N());
}

const FrcCoordinateAxis* frcCoordinateAxisS() {
    return new frc::CoordinateAxis (frc::CoordinateAxis::S());
}

const FrcCoordinateAxis* frcCoordinateAxisE() {
    return new frc::CoordinateAxis (frc::CoordinateAxis::E());
}

const FrcCoordinateAxis* frcCoordinateAxisW() {
    return new frc::CoordinateAxis (frc::CoordinateAxis::W());
}

const FrcCoordinateAxis* frcCoordinateAxisU() {
    return new frc::CoordinateAxis (frc::CoordinateAxis::U());
}
const FrcCoordinateAxis* frcCoordinateAxisD() {
    return new frc::CoordinateAxis (frc::CoordinateAxis::D());
}

//==============================================================================
typedef void FrcRotation2d;

FrcRotation2d* frcRotation2dNew (double radians) {
    return (FrcRotation2d*) new frc::Rotation2d (units::radian_t (radians));
}

FrcRotation2d* frcRotation2dNewWithCoords (double x, double y) {
    return (FrcRotation2d*) new frc::Rotation2d (x, y);
}

void frcRotation2dFree (FrcRotation2d* self) {
    delete (frc::Rotation2d*) self;
}

bool frcRotation2dEquals (const FrcRotation2d* lhs, const FrcRotation2d* rhs) {
    return ((frc::Rotation2d*) lhs)->operator== (*((frc::Rotation2d*) rhs));
}

double frcRotation2dRadians (const FrcRotation2d* self) {
    return ((const frc::Rotation2d*) self)->Radians().value();
}

double frcRotation2dDegrees (const FrcRotation2d* self) {
    return ((const frc::Rotation2d*) self)->Degrees().value();
}

//==============================================================================
typedef void FrcTranslation2d;

//==============================================================================
typedef void FrcTransform2d;

//==============================================================================
typedef void FrcTwist2d;

FrcTwist2d* frcTwist2dNew() {
    return new frc::Twist2d();
}

void frcTwist2dFree (FrcTwist2d* self) {
    delete (frc::Twist2d*) self;
}

bool frcTwist2dEquals (const FrcTwist2d* self, const FrcTwist2d* other) {
    auto& a = *static_cast<const frc::Twist2d*> (self);
    auto& b = *static_cast<const frc::Twist2d*> (other);
    return a == b;
}

void frcTwist2dSet_dx (const FrcTwist2d* self, double meters) {
    ((frc::Twist2d*) self)->dx = units::meter_t (meters);
}

void frcTwist2dSet_dy (const FrcTwist2d* self, double meters) {
    ((frc::Twist2d*) self)->dy = units::meter_t (meters);
}

void frcTwist2dSet_dtheta (const FrcTwist2d* self, double radians) {
    ((frc::Twist2d*) self)->dtheta = units::radian_t (radians);
}

//==============================================================================
typedef void FrcPose2d;

// constexpr Pose2d() = default;
// constexpr Pose2d(Translation2d translation, Rotation2d rotation);
// constexpr Pose2d(units::meter_t x, units::meter_t y, Rotation2d rotation);
FrcPose2d* frcPose2dNew (double x, double y, double r) {
    if (auto ptr = new frc::Pose2d()) {
        frc::Rotation2d rot { units::angle::radian_t { r } };
        *ptr = { units::meter_t (x),
                 units::meter_t (y),
                 rot };
        return ptr;
    }

    return nullptr;
}

// ~Pose2d()
void frcPose2dFree (FrcPose2d* self) {
    delete static_cast<frc::Pose2d*> (self);
}

// constexpr Pose2d operator+(const Transform2d& other) const;
FrcPose2d* frcPose2dPlus_Transform2d (const frc::Pose2d* self, const FrcTransform2d* rhs) {
    auto& a = *static_cast<const frc::Pose2d*> (self);
    auto& b = *static_cast<const frc::Transform2d*> (rhs);
    return new frc::Pose2d (a + b);
}

// Transform2d operator-(const Pose2d& other) const;
FrcTransform2d* frcPose2dSub_Pose2d_Transform2d (const FrcPose2d* self, const FrcPose2d* other) {
    auto& a = *static_cast<const frc::Pose2d*> (self);
    auto& b = *static_cast<const frc::Pose2d*> (other);
    return new frc::Transform2d (a - b);
}

// bool operator==(const Pose2d&) const = default;
bool frcPose2dEquals (const FrcPose2d* lhs, const FrcPose2d* rhs) {
    auto& a = *static_cast<const frc::Pose2d*> (lhs);
    auto& b = *static_cast<const frc::Pose2d*> (rhs);
    return a == b;
}

// constexpr const Translation2d& Translation() const { return m_translation; }
const FrcTranslation2d* frcPose2dTranslation (const FrcPose2d* self) {
    return &((const frc::Pose2d*) self)->Translation();
}

// constexpr units::meter_t X() const { return m_translation.X(); }
double frcPose2dX (const FrcPose2d* self) {
    return ((const frc::Pose2d*) self)->X().value();
}

// constexpr units::meter_t Y() const { return m_translation.Y(); }
double frcPose2dY (const FrcPose2d* self) {
    return ((const frc::Pose2d*) self)->Y().value();
}

// constexpr const Rotation2d& Rotation() const { return m_rotation; }
const FrcRotation2d* frcPose2dRotation (const FrcPose2d* self) {
    return &((const frc::Pose2d*) self)->Rotation();
}

// constexpr Pose2d operator*(double scalar) const;
FrcPose2d* frcPose2dMul_double (const FrcPose2d* self, double scalar) {
    auto& pose = *static_cast<const frc::Pose2d*> (self);
    return (FrcPose2d*) new frc::Pose2d (pose.operator* (scalar));
}

// constexpr Pose2d operator/(double scalar) const;
FrcPose2d* frcPose2dDiv_double (const FrcPose2d* self, double scalar) {
    auto& pose = *static_cast<const frc::Pose2d*> (self);
    return (FrcPose2d*) new frc::Pose2d (pose.operator/ (scalar));
}

// constexpr Pose2d RotateBy(const Rotation2d& other) const;
FrcPose2d* frcPose2dRotateBy (const FrcPose2d* self, const FrcRotation2d* r) {
    auto& pose = *static_cast<const frc::Pose2d*> (self);
    auto& rot  = *static_cast<const frc::Rotation2d*> (r);
    return (FrcPose2d*) new frc::Pose2d (pose.RotateBy (rot));
}

// constexpr Pose2d TransformBy(const Transform2d& other) const;
FrcPose2d* frcPose2dTransformBy (const FrcPose2d* self, const FrcTransform2d* other) {
    auto& pose = *static_cast<const frc::Pose2d*> (self);
    auto& tf   = *static_cast<const frc::Transform2d*> (other);
    return (FrcPose2d*) new frc::Pose2d (pose.TransformBy (tf));
}

// Pose2d RelativeTo(const Pose2d& other) const;
FrcPose2d* frcPose2dRelativeTo (const FrcPose2d* self, const FrcPose2d* other) {
    auto& pose = *static_cast<const frc::Pose2d*> (self);
    auto& rel  = *static_cast<const frc::Pose2d*> (other);
    return (FrcPose2d*) new frc::Pose2d (pose.RelativeTo (rel));
}

// Pose2d Exp(const Twist2d& twist) const;
FrcPose2d* frcPose2dExp (const FrcPose2d* self, const FrcTwist2d* twist) {
    auto& a = *static_cast<const frc::Pose2d*> (self);
    auto& b = *static_cast<const frc::Twist2d*> (twist);
    return new frc::Pose2d (a.Exp (b));
}

// Twist2d Log(const Pose2d& end) const;
FrcTwist2d* frcPose2dLog (const FrcPose2d* self, const FrcPose2d* other) {
    auto& a = *static_cast<const frc::Pose2d*> (self);
    auto& b = *static_cast<const frc::Pose2d*> (other);
    return new frc::Twist2d (a.Log (b));
}

// Pose2d Nearest(std::span<const Pose2d> poses) const;
// Pose2d Nearest(std::initializer_list<Pose2d> poses) const;
}
