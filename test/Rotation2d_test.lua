local Rotation2d = require ('wpimath.geometry.Rotation2d')

do
    local r1, r2 = Rotation2d (math.pi), Rotation2d (.24, -.3)
    assert (r1:degrees() == 180, "should be 180 degrees")
    assert (r1:degrees() ~= r2:degrees())
end
