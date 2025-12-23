---@module 'luabot.class'
---LuaBot class system for inheritance and object creation
local M = {}

---Module version number
M.version = 1

---Define a new base class
---@return table class A new class table with __index set to itself
local function define()
    local T = {}
    T.__index = T
    return T
end

---Derive a new class from a supertype with automatic init chaining
---@param supertype table The parent class to inherit from
---@return table class A new class that inherits from supertype
local function derive(supertype)
    if type(supertype) ~= 'table' then
        error('supertype must be a table')
    end

    local T = setmetatable (define(), { __index = supertype })

    -- If supertype has an init, wrap it to enable automatic chaining
    if supertype.init then
        local parent_init = supertype.init
        T.init = function(instance)
            -- Call parent init first, then allow derived class to override
            parent_init(instance)
            return instance
        end
    end

    return T
end

local M_mt = {}
---Define or derive a class type.
---@return table class The new or derived type table.
function M_mt.__call(_, arg)
    if arg == nil then
        -- No arguments: define a new base class
        return define()
    elseif type(arg) == "table" then
        -- Table argument: derive from parent class
        return derive(arg)
    else
        error("class() expects nil or a table, got '" .. type(arg) .. "'")
    end
end

return setmetatable(M, M_mt)
