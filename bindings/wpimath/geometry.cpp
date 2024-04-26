
#include <frc/geometry/CoordinateAxis.h>
#include <frc/geometry/Pose2d.h>
#include <frc/geometry/Rotation2d.h>
#include <frc/geometry/Transform2d.h>
#include <frc/geometry/Twist2d.h>

#include <iostream>

#include "../bindings.hpp"

#define BOT_FRC_POSE2D_CACHE 0

static_assert (sizeof (void*) == sizeof (frc::Pose2d*));

class Pose2dCache {
public:
    Pose2dCache() {
        _active.reserve (num_reserved);
        _avail.reserve (num_reserved);
        while (_avail.size() < num_reserved) {
            _avail.push_back (new frc::Pose2d());
        }
    }

    ~Pose2dCache() {
        for (auto ptr : _active)
            delete ptr;
        for (auto ptr : _avail)
            delete ptr;
        _active.clear();
        _avail.clear();
    }

    void recycle (frc::Pose2d* obj) {
        if (obj == nullptr)
            return;

        auto iter = std::find (_active.begin(), _active.end(), obj);
        if (iter != _active.end()) {
            _active.erase (iter);
        }

        _avail.push_back (obj);
    }

    /** Recycle an object. Must be a valid pointer. */
    void recycle (void* cptr) {
        recycle (static_cast<frc::Pose2d*> (cptr));
    }

    frc::Pose2d* construct() {
        if (_avail.size() > 0) {
            auto* ptr = _avail.back();
            *ptr      = {};
            _active.push_back (ptr);
            _avail.pop_back();
            return ptr;
        }

        _active.push_back (new frc::Pose2d());
        return _active.back();
    }

    std::size_t num_active() const noexcept { return _active.size(); }
    std::size_t num_available() const noexcept { return _avail.size(); }
    std::size_t size() const noexcept { return _active.size() + _avail.size(); }

    void free_unused() {
        while (_avail.size() > num_reserved) {
            auto ptr = _avail.back();
            _avail.pop_back();
            delete ptr;
        }
    }

    void print_stats() {
        std::cout
            << "active: " << (int) num_active()
            << "  avail: " << (int) num_available()
            << "  total: " << (int) size() << std::endl;
    }

private:
    enum { num_reserved = 512 };
    std::vector<frc::Pose2d*> _active, _avail;
};

static Pose2dCache s_pose2d;

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
    return &frc::CoordinateAxis::N();
}

const FrcCoordinateAxis* frcCoordinateAxisS() {
    return &frc::CoordinateAxis::S();
}

const FrcCoordinateAxis* frcCoordinateAxisE() {
    return &frc::CoordinateAxis::E();
}

const FrcCoordinateAxis* frcCoordinateAxisW() {
    return &frc::CoordinateAxis::W();
}

const FrcCoordinateAxis* frcCoordinateAxisU() {
    return &frc::CoordinateAxis::U();
}
const FrcCoordinateAxis* frcCoordinateAxisD() {
    return &frc::CoordinateAxis::D();
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
#if BOT_FRC_POSE2D_CACHE
    if (auto ptr = s_pose2d.construct()) {
#else
    if (auto ptr = new frc::Pose2d()) {
#endif
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
#if BOT_FRC_POSE2D_CACHE
    s_pose2d.recycle (self);
#else
    delete static_cast<frc::Pose2d*> (self);
#endif
}

// Extra
void frcPose2dCollect() {
#if BOT_FRC_POSE2D_CACHE
    s_pose2d.free_unused();
#endif
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
