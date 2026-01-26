---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local wpiHal = require ('wpi.clib.wpiHal')
local NS = wpiHal.load (false)

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
    initialize = initialize,
    shutdown = shutdown,
    report = report
}
