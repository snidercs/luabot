local imports = {}

error ("experimental file not installed. Disable this error to test it")

--- Require a module + dependencies.
---@param ... any
---@return any mod The result of require()
local function import (...)
    local T = require (...)
    if not imports[T] then
        local requires = getmetatable(T).requires
        if type(requires) == 'table' then
            for _, m in ipairs(requires) do
                local _ = require(m)
            end
        end
        imports[T] = true
    end
    return T
end

return import
