local ffi = require('ffi')
ffi.cdef [[
typedef void BOT_Simple;
BOT_Simple* bot_Simple_new();
void bot_Simple_free (BOT_Simple* self);
void bot_Simple_hello (BOT_Simple* self);
]]

-- FIXME: lib path shouldn't be hardcoded.
local lib = ffi.load('../build/test/libsimple.so')

local Simple = {}
local Simple_mt = {
    __index = Simple,
}

setmetatable (Simple, {
    __call = function()
        local s = {
            impl = ffi.gc (lib.bot_Simple_new(), lib.bot_Simple_free)
        }
        return setmetatable(s, Simple_mt)
    end
})

function Simple:hello()
    lib.bot_Simple_hello(self.impl) -- (self.impl)
end

return Simple
