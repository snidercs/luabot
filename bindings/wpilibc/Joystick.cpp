#include <frc/Joystick.h>

typedef void FrcJoystick;

FrcJoystick* frcJoystickNew (int port) {
    return new frc::Joystick (port);
}
