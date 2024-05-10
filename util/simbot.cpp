
#include <frc/TimedRobot.h>
#include <hal/Extensions.h>

class SimRobot : public frc::TimedRobot {
public:
    SimRobot() : frc::TimedRobot (std::chrono::milliseconds (20)) {}
};

int main() {
    // HAL_LoadOneExtension("halsim_gui");
    // HAL_LoadOneExtension("halsim_ds_socket");
    return frc::StartRobot<SimRobot>();
}
