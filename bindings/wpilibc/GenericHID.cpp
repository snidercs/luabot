
#include <cstdbool>
#include <iostream>

#include <frc/GenericHID.h>

#define tocxx(ct) ((frc::GenericHID*) ct)

extern "C" {

typedef void FrcGenericHID;

FrcGenericHID* frcGenericHIDNew (int port) {
    return (FrcGenericHID*) new frc::GenericHID (port);
}

void frcGenericHIDFree (FrcGenericHID* self) {
    delete tocxx (self);
}

bool frcGenericHIDGetRawButton (FrcGenericHID* self, int button) {
    return tocxx (self)->GetRawButton (button);
}

bool frcGenericHIDGetRawButtonPressed (FrcGenericHID* self, int button) {
    return tocxx (self)->GetRawButtonPressed (button);
}

bool frcGenericHIDGetRawButtonReleased (FrcGenericHID* self, int button) {
    return tocxx (self)->GetRawButtonReleased (button);
}

double frcGenericHIDGetRawAxis (FrcGenericHID* self, int axis) {
    return tocxx (self)->GetRawAxis (axis);
}

int frcGenericHIDGetPOV (FrcGenericHID* self, int pov) {
    return tocxx (self)->GetPOV (pov);
}

// int frcGenericHIDGetAxisCount (FrcGenericHID* self)
// int frcGenericHIDGetPOVCount (FrcGenericHID* self)
// int frcGenericHIDGetButtonCount (FrcGenericHID* self)

bool frcGenericHIDIsConnected (FrcGenericHID* self) {
    std::clog << "frcGenericHIDIsConnected\n";
    return tocxx (self)->IsConnected();
}

#if 0

BooleanEvent frcGenericHIDButton (FrcGenericHID* self, int button, EventLoop* loop)
BooleanEvent frcGenericHIDPOV (FrcGenericHID* self, int angle, EventLoop* loop)
BooleanEvent frcGenericHIDPOV (FrcGenericHID* self, int pov, int angle, EventLoop* loop)
BooleanEvent frcGenericHIDPOVUp (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVUpRight (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVRight (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVDownRight (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVDown (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVDownLeft (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVLeft (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVUpLeft (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDPOVCenter (FrcGenericHID* self, EventLoop* loop)
BooleanEvent frcGenericHIDAxisLessThan (FrcGenericHID* self, int axis, double threshold, EventLoop* loop)
BooleanEvent frcGenericHIDAxisGreaterThan (FrcGenericHID* self, int axis, double threshold, EventLoop* loop)

GenericHID::HIDType frcGenericHIDGetType (FrcGenericHID* self)
std::string frcGenericHIDGetName (FrcGenericHID* self)
int frcGenericHIDGetAxisType (FrcGenericHID* self, int axis)
int frcGenericHIDGetPort (FrcGenericHID* self)
void frcGenericHIDSetOutput (FrcGenericHID* self, int outputNumber, bool value)
void frcGenericHIDSetOutputs (FrcGenericHID* self, int value)
void frcGenericHIDSetRumble (FrcGenericHID* self, RumbleType type, double value)
#endif
}
