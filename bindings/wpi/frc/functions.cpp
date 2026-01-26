// SPDX-FileCopyrightText: Michael Fisher @mfisher31
// SPDX-License-Identifier: MIT

#include <cstring>
#include <wpi/SymbolExports.h>

#include <luabot/luabot.h>

// =============================================================================
#include <hal/HAL.h>

// =============================================================================
#include <frc/Filesystem.h>
extern "C" {
LUABOT_EXPORT char* frcFilesystemGetLaunchDirectory() {
    auto str = frc::filesystem::GetLaunchDirectory();
    return strdup (str.c_str());
}

LUABOT_EXPORT char* frcFilesystemGetOperatingDirectory() {
    auto str = frc::filesystem::GetOperatingDirectory();
    return strdup (str.c_str());
}

LUABOT_EXPORT char* frcFilesystemGetDeployDirectory() {
    auto str = frc::filesystem::GetDeployDirectory();
    return strdup (str.c_str());
}
}

// =============================================================================
#include <frc/RobotBase.h>
extern "C" {
LUABOT_EXPORT bool frcRobotBaseIsSimulation() {
    return frc::RobotBase::IsSimulation();
}

LUABOT_EXPORT bool frcRobotBaseIsReal() {
    return frc::RobotBase::IsReal();
}

LUABOT_EXPORT int frcRunHALInitialization() {
    return frc::RunHALInitialization();
}

LUABOT_EXPORT void frcRobotBaseInit() {
    static bool hasInit = false;
    if (hasInit)
        return;
    hasInit = true;

    class InitBot : public frc::RobotBase {
    public:
        InitBot() {}
        ~InitBot() {}
        void StartCompetition() override {}
        void EndCompetition() override {}
    } init;
}
}
