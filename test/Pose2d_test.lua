local Pose2d = require('wpimath.geometry.Pose2d')
local gc = collectgarbage

collectgarbage = function(...)
    gc(...)
    Pose2d.collect()
end

do -- basics
    local p1, p2, p3 = Pose2d(), Pose2d(), Pose2d(100, 100, math.pi)
    assert(type(p1) == 'cdata', "should be cdata type")
    assert(p1:x() + p1:y() == 0, "should be zero")
    assert(p3:x() == 100 and p3:y() == 100, "should be 100")
    assert(p1:equals(p2), "should be equal")
    assert(not p1:equals(p3), "should not be equal")
end

collectgarbage()

do -- refs
    local p1, p2, p3 = Pose2d(), Pose2d(), Pose2d()
    assert(p1 ~= 3)
    assert(p1 == p1, "ref should be equal")
    assert(p1 ~= p2, "ref should not be equal")
    assert(p1 ~= p3, "ref should not be equal")
    assert(p2 ~= p3, "ref should not be equal")
end

collectgarbage()

do -- rotation / translation
    local p1 = Pose2d(100, 100, math.pi)
    assert(p1:translation() ~= nil)
    assert(p1:rotation():degrees() == 180, "should be 180 degrees")
    assert(p1:rotation():radians() == math.pi, "should be 'math.pi' radians")
end

collectgarbage()
