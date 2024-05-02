local CoordinateAxis = require ('wpi.math.geometry.CoordinateAxis')

do
    assert (CoordinateAxis (1,2,3) ~= nil)
    assert (CoordinateAxis.N() ~= nil)
    assert (CoordinateAxis.S() ~= nil)
    assert (CoordinateAxis.E() ~= nil)
    assert (CoordinateAxis.W() ~= nil)
    assert (CoordinateAxis.U() ~= nil)
    assert (CoordinateAxis.D() ~= nil)
end
