---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')

local cscore = require('wpi.clib.cscore')
local ntcore = require('wpi.clib.ntcore')
local wpiHal = require('wpi.clib.wpiHal')

-- Test cscore load function
do
    local lib = cscore.load(false)
    if lib then
        lu.assertNotNil(lib.CS_EnumerateUsbCameras, "cscore should load c functions")
    end
end

collectgarbage()

-- Test ntcore load function
do
    local lib = ntcore.load(false)
    lu.assertNotNil(lib, "ntcore.load() should return a library")
end

collectgarbage()

-- Test wpiHal load function
do
    local lib = wpiHal.load(false)
    lu.assertNotNil(lib, "wpiHal.load() should return a library")
end

collectgarbage()

-- Test that multiple calls return same library
do

    local lib1 = wpiHal.load(false)
    local lib2 = wpiHal.load(false)
    lu.assertTrue(lib1 == lib2, "wpiHal.load() should return the same library on multiple calls")
end

collectgarbage()
