---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local lu = require('luaunit')

local Pose2d = require('wpi.math.geometry.Pose2d')
local Rotation2d = require('wpi.math.geometry.Rotation2d')
local Translation2d = require('wpi.math.geometry.Translation2d')
local Transform2d = require('wpi.math.geometry.Transform2d')
local Twist2d = require('wpi.math.geometry.Twist2d')

-- Helper for approximate equality
local function approxEqual(a, b, tolerance)
    tolerance = tolerance or 1e-9
    return math.abs(a - b) < tolerance
end

-- Test basic construction
do
    local p1 = Pose2d()
    lu.assertTrue(type(p1) == 'cdata', "should be cdata type")
    lu.assertEquals(p1:x(), 0, "default x should be 0")
    lu.assertEquals(p1:y(), 0, "default y should be 0")
    lu.assertEquals(p1:rotation():radians(), 0, "default rotation should be 0")
end

collectgarbage()

-- Test construction with parameters
do
    local p = Pose2d(3.5, 4.2, math.pi / 4)
    lu.assertEquals(p:x(), 3.5, "x should be 3.5")
    lu.assertEquals(p:y(), 4.2, "y should be 4.2")
    lu.assertTrue(approxEqual(p:rotation():radians(), math.pi / 4), "rotation should be pi/4")
end

collectgarbage()

-- Test equality
do
    local p1 = Pose2d(1, 2, 0.5)
    local p2 = Pose2d(1, 2, 0.5)
    local p3 = Pose2d(1, 2, 0.6)
    local p4 = Pose2d(2, 2, 0.5)

    lu.assertTrue(p1:equals(p2), "identical poses should be equal")
    lu.assertFalse(p1:equals(p3), "different rotations should not be equal")
    lu.assertFalse(p1:equals(p4), "different positions should not be equal")
end

collectgarbage()

-- Test reference inequality
do
    local p1 = Pose2d()
    local p2 = Pose2d()

    lu.assertTrue(p1 == p1, "same reference should be equal")
    lu.assertTrue(p1 ~= p2, "different references should not be equal")
end

collectgarbage()

-- Test translation and rotation getters
do
    local p = Pose2d(5, 10, math.pi / 2)

    lu.assertEquals(p:x(), 5, "x getter should return correct value")
    lu.assertEquals(p:y(), 10, "y getter should return correct value")

    local trans = p:translation()
    lu.assertNotNil(trans, "translation should not be nil")

    local rot = p:rotation()
    lu.assertNotNil(rot, "rotation should not be nil")
    lu.assertTrue(approxEqual(rot:radians(), math.pi / 2), "rotation should be pi/2")
    lu.assertTrue(approxEqual(rot:degrees(), 90), "rotation should be 90 degrees")
end

collectgarbage()

-- Test rotateBy
do
    local p = Pose2d(1, 0, 0)
    local rot = Rotation2d(math.pi / 2)
    local rotated = p:rotateBy(rot)

    lu.assertTrue(approxEqual(rotated:rotation():radians(), math.pi / 2, 1e-6),
        "rotation should increase by pi/2")
end

collectgarbage()

-- Test transformBy
do
    -- local initial = Pose2d(1, 2, 0)
    -- local transform = Transform2d.new(Translation2d.new(3, 4), Rotation2d(math.pi / 2))
    -- local transformed = initial:transformBy(transform)

    -- -- After transform, pose should be translated and rotated
    -- lu.assertNotNil(transformed, "transformed pose should not be nil")
    -- lu.assertTrue(approxEqual(transformed:rotation():radians(), math.pi / 2, 1e-6),
    --               "rotation should be pi/2 after transform")
end

collectgarbage()

-- Test relativeTo
do
    local pose = Pose2d(5, 7, math.pi / 4)
    local origin = Pose2d(3, 3, 0)
    local relative = pose:relativeTo(origin)

    lu.assertNotNil(relative, "relative pose should not be nil")
    -- The relative pose represents pose in the coordinate frame of origin
end

collectgarbage()

-- Test exp with twist (disabled)
do
    -- local initial = Pose2d(0, 0, 0)
    -- local twist = Twist2d(1, 0, 0)  -- Move forward 1 meter, no lateral, no rotation
    -- local result = initial:exp(twist)

    -- lu.assertNotNil(result, "exp result should not be nil")
    -- lu.assertTrue(approxEqual(result:x(), 1, 1e-6), "should move forward 1 meter")
    -- lu.assertTrue(approxEqual(result:y(), 0, 1e-6), "should not move laterally")
end

collectgarbage()

-- Test log - inverse of exp
do
    local start = Pose2d(0, 0, 0)
    local end_pose = Pose2d(2, 1, math.pi / 6)
    local twist = start:log(end_pose)

    lu.assertNotNil(twist, "log should return a twist")

    -- Applying exp with this twist should give us end_pose
    local reconstructed = start:exp(twist)
    lu.assertTrue(approxEqual(reconstructed:x(), end_pose:x(), 1e-6),
        "exp(log) should reconstruct x")
    lu.assertTrue(approxEqual(reconstructed:y(), end_pose:y(), 1e-6),
        "exp(log) should reconstruct y")
end

collectgarbage()

-- Test multiple poses don't interfere
do
    local poses = {}
    for i = 1, 10 do
        poses[i] = Pose2d(i, i * 2, i * 0.1)
    end

    for i = 1, 10 do
        lu.assertEquals(poses[i]:x(), i, "pose x should be independent")
        lu.assertEquals(poses[i]:y(), i * 2, "pose y should be independent")
    end
end

collectgarbage()

-- Test poses with extreme values
do
    local large = Pose2d(1e10, 1e10, math.pi)
    lu.assertEquals(large:x(), 1e10, "should handle large x values")
    lu.assertEquals(large:y(), 1e10, "should handle large y values")

    local negative = Pose2d(-100, -200, -math.pi)
    lu.assertEquals(negative:x(), -100, "should handle negative x")
    lu.assertEquals(negative:y(), -200, "should handle negative y")
end

collectgarbage()

-- Test rotation wrapping (disabled)
do
    -- local p1 = Pose2d(0, 0, 2 * math.pi)
    -- local p2 = Pose2d(0, 0, 0)
    -- -- Rotations should be normalized/equivalent
    -- lu.assertTrue(approxEqual(p1:rotation():radians(), p2:rotation():radians(), 1e-6),
    --               "2*pi should be equivalent to 0")
end

collectgarbage()

-- Test zero pose
do
    local zero = Pose2d(0, 0, 0)
    lu.assertEquals(zero:x(), 0)
    lu.assertEquals(zero:y(), 0)
    lu.assertEquals(zero:rotation():radians(), 0)
end

collectgarbage()
