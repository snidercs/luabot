---CoordinateSystem wrapper
---@class CoordinateSystem
local CoordinateSystem = {}

setmetatable (CoordinateSystem, {
    __call = function() return {} end
})

return CoordinateSystem
