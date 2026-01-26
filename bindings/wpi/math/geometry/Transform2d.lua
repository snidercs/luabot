---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

---Transform2d wrapper
---@class Transform2d
local Transform2d = {}

setmetatable (Transform2d, {
    __call = function() return {} end
})

return Transform2d
