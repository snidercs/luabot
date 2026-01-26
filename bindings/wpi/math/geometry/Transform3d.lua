---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

---Transform3d wrapper
---@class Transform3d
local Transform3d = {}

setmetatable (Transform3d, {
    __call = function() return {} end
})

return Transform3d
