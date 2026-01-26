---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

---CoordinateSystem wrapper
---@class CoordinateSystem
local CoordinateSystem = {}

setmetatable (CoordinateSystem, {
    __call = function() return {} end
})

return CoordinateSystem
