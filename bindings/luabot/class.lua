--- SPDX-FileCopyrightText: Michael Fisher @mfisher31
--- SPDX-License-Identifier: MIT

--- @module 'luabot.class'
--- LuaBot class system for inheritance and object creation
local M = {}

--- Module version number
M.version = 1

--- Define a new base class
--- @return table class A new class table with __index set to itself
local function define()
    local T = {}
    T.__index = T

    -- Default initializer
    function T.init(instance) return instance end

    -- Default constructor
    function T.new() return T.init(setmetatable({}, T)) end

    return T
end

--- Derive a new class from a supertype with automatic init chaining
--- @param supertype table The parent class to inherit from
--- @return table class A new class that inherits from supertype
local function derive(supertype)
    if type(supertype) ~= 'table' then
        error('supertype must be a table')
    end

    local T = setmetatable(define(), { __index = supertype })

    -- If supertype has an init, wrap it to enable automatic chaining
    if supertype.init and type(supertype.init) == 'function' then
        local parent_init = supertype.init
        T.init = function(instance)
            -- Call parent init first, then allow derived class to override
            parent_init(instance)
            return instance
        end
    end

    return T
end

--- Create a new instance of a class
--- @param T string|table Either a module name string to require, or a class table
--- @param ... any Arguments to pass to the class constructor
--- @return table instance A new instance of the class
local function new(T, ...)
    local Class = type(T) == 'string' and require(T) or T
    if type(Class) ~= 'table' or type(Class.new) ~= 'function' then
        error("Cannot instantiate a non-class type")
    end
    return Class.new(...)
end
M.new = new

local M_mt = {}
--- Define or derive a class type.
--- @return table class The new or derived type table.
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
