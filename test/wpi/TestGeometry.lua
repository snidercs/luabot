---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')

local CoordinateAxis = require ('wpi.math.geometry.CoordinateAxis')
local Pose2d = require('wpi.math.geometry.Pose2d')
local Rotation2d = require ('wpi.math.geometry.Rotation2d')

-- FIXME: type dependency loading is not handled yet.
require('wpi.math.geometry.Rotation2d')

do -- basics
    local p1, p2, p3 = Pose2d(), Pose2d(), Pose2d(100, 100, math.pi)
    lu.assertTrue(type(p1) == 'cdata', "should be cdata type")
    lu.assertTrue(p1:x() + p1:y() == 0, "should be zero")
    lu.assertTrue(p3:x() == 100 and p3:y() == 100, "should be 100")
    lu.assertTrue(p1:equals(p2), "should be equal")
    lu.assertTrue(not p1:equals(p3), "should not be equal")
end

collectgarbage()

do -- refs
    local p1, p2, p3 = Pose2d(), Pose2d(), Pose2d()
    lu.assertTrue(p1 ~= 3)
    lu.assertTrue(p1 == p1, "ref should be equal")
    lu.assertTrue(p1 ~= p2, "ref should not be equal")
    lu.assertTrue(p1 ~= p3, "ref should not be equal")
    lu.assertTrue(p2 ~= p3, "ref should not be equal")
end

collectgarbage()

do -- rotation / translation
    local p1 = Pose2d(100, 100, math.pi)
    lu.assertTrue(p1:translation() ~= nil)
    lu.assertTrue(p1:rotation():degrees() == 180, "should be 180 degrees")
    lu.assertTrue(p1:rotation():radians() == math.pi, "should be 'math.pi' radians")
end

collectgarbage()


do
    local r1, r2 = Rotation2d (math.pi), Rotation2d (.24, -.3)
    assert (r1:degrees() == 180, "should be 180 degrees")
    assert (r1:degrees() ~= r2:degrees())
end

do
    assert (CoordinateAxis (1,2,3) ~= nil)
    assert (CoordinateAxis.N() ~= nil)
    assert (CoordinateAxis.S() ~= nil)
    assert (CoordinateAxis.E() ~= nil)
    assert (CoordinateAxis.W() ~= nil)
    assert (CoordinateAxis.U() ~= nil)
    assert (CoordinateAxis.D() ~= nil)
end
