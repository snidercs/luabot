#include <frc/IterativeRobotBase.h>

static const int iterations = 2000000 * 2;

class PlusOne : public frc::IterativeRobotBase {
public:
    PlusOne() : frc::IterativeRobotBase (units::millisecond_t (20)) {}
    void StartCompetition() override {}
    void EndCompetition() override {}
    int process (int x) {
        LoopFunc();
        return x + 1;
    }
};

int main() {
    frc::RunHALInitialization();
    auto robot = std::make_unique<PlusOne>();
    int x      = 0;
    for (int i = 0; i < iterations; ++i) {
        x = robot->process (i);
    }
    (void) x;
    return 0;
}
