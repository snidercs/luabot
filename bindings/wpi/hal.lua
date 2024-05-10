local ffi = require ('ffi')

ffi.cdef[[
typedef signed int int32_t;
typedef signed long int64_t;
typedef int32_t HAL_Bool;

// hal/HALBase.h
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

local NS = ffi.load ('wpiHal', true)

---
---Call this to start up HAL. This is required for robot programs.
---
---This must be called before any other HAL functions. Failure to do so will
---result in undefined behavior, and likely segmentation faults. This means that
---any statically initialized variables in a program MUST call this function in
---their constructors if they want to use other HAL calls.
---
---The common parameters are 500 for timeout and 0 for mode.
---
---This function is safe to call from any thread, and as many times as you wish.
---It internally guards from any reentrancy.
---
---The applicable modes are:
---  0: Try to kill an existing HAL from another program, if not successful,
---error.
---  1: Force kill a HAL from another program.
---  2: Just warn if another hal exists and cannot be killed. Will likely result
---in undefined behavior.
---
---@param timeout integer the initialization timeout (ms)
---@param mode    integer the initialization mode (see remarks)
---@return boolean status true if initialization was successful, otherwise false.
local function initialize (timeout, mode)
    timeout = tonumber (timeout) or 500
    mode = tonumber (mode) or 0
    return NS.HAL_Initialize (timeout, mode)
end

---
---Call this to shut down HAL.
---
---This must be called at termination of the robot program to avoid potential
---segmentation faults with simulation extensions at exit.
local function shutdown()
    NS.HAL_Shutdown()
end

---
---Reports a hardware usage to the HAL.
---
---@param resource integer the used resource
---@param instance integer the instance of the resource
---@param context integer  a user specified context index
---@param feature string   a user specified feature string
---@return integer index the index of the added value in NetComm
local function report(resource, instance, context, feature)
    return NS.HAL_Report (resource, instance, context, feature)
end


------
return {
    C = ffi.load ('wpiHal', true),
    initialize = initialize,
    shutdown = shutdown,
    report = report
}
