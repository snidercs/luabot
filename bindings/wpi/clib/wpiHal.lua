local ffi = require ('ffi')

local SONAME = 'wpiHal'
local lib = nil

ffi.cdef[[
typedef int32_t HAL_Bool;

// hal/HALBase.h
enum HAL_RuntimeType {
    HAL_Runtime_RoboRIO,
    HAL_Runtime_RoboRIO2,
    HAL_Runtime_Simulation
};

HAL_Bool HAL_Initialize(int32_t timeout, int32_t mode);
void HAL_Shutdown();
void HAL_SimPeriodicBefore();
void HAL_SimPeriodicAfter();

// hal/FRCUsageReporting.h
int64_t HAL_Report(int32_t resource, int32_t instanceNumber, int32_t context, const char* feature);

// hal/DriverStationTypes.h
struct HAL_ControlWord {
    uint32_t enabled : 1;
    uint32_t autonomous : 1;
    uint32_t test : 1;
    uint32_t eStop : 1;
    uint32_t fmsAttached : 1;
    uint32_t dsAttached : 1;
    uint32_t control_reserved : 26;
};

// hal/DriverStation.h
typedef struct HAL_ControlWord HAL_ControlWord;
int32_t HAL_GetControlWord(HAL_ControlWord* controlWord);

void HAL_ObserveUserProgramStarting();
void HAL_ObserveUserProgramDisabled();
void HAL_ObserveUserProgramAutonomous();
void HAL_ObserveUserProgramTeleop();
void HAL_ObserveUserProgramTest();

// hal/Notifier.h
typedef int32_t HAL_Handle;
typedef HAL_Handle HAL_NotifierHandle;
HAL_NotifierHandle HAL_InitializeNotifier(int32_t* status);
void HAL_SetNotifierName(HAL_NotifierHandle notifierHandle, const char* name, int32_t* status);
void HAL_UpdateNotifierAlarm(HAL_NotifierHandle notifierHandle, uint64_t triggerTime, int32_t* status);
uint64_t HAL_WaitForNotifierAlarm(HAL_NotifierHandle notifierHandle, int32_t* status);
void HAL_StopNotifier(HAL_NotifierHandle notifierHandle, int32_t* status);

// hal/Extensions.h
int HAL_LoadOneExtension(const char* library);
void HAL_RunMain();
void HAL_ExitMain();
HAL_Bool HAL_HasMain();
]]

---Load the wpiHal shared library.
---@param global boolean? Set true to add to the `ffi.C` namespace
---@return ffi.namespace* clib The shared library ref
local function load (global)
    if not lib then
        lib = ffi.load (SONAME, global)
    end
    return lib
end

return { load = load }
