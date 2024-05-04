#include <cstring>
#include <wpi/SymbolExports.h>

// =============================================================================
#include <hal/HAL.h>

// =============================================================================
#include <frc/Filesystem.h>
extern "C" {
char* frcFilesystemGetLaunchDirectory() {
    auto str = frc::filesystem::GetLaunchDirectory();
    return strdup (str.c_str());
}

char* frcFilesystemGetOperatingDirectory() {
    auto str = frc::filesystem::GetOperatingDirectory();
    return strdup (str.c_str());
}

char* frcFilesystemGetDeployDirectory() {
    auto str = frc::filesystem::GetDeployDirectory();
    return strdup (str.c_str());
}
}

// =============================================================================
#include <frc/RobotBase.h>
extern "C" {
bool frcRobotBaseIsSimulation() {
    return frc::RobotBase::IsSimulation();
}

bool frcRobotBaseIsReal() {
    return frc::RobotBase::IsReal();
}

int frcRunHalInitialization() {
    return frc::RunHALInitialization();
}

void frcRobotBaseInit() {
}

}
