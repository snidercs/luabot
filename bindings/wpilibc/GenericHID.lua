local ffi = require ('ffi')
ffi.cdef[[
typedef void FrcGenericHID;
FrcGenericHID* frcGenericHIDNew(int port);
void frcGenericHIDFree (FrcGenericHID* self);
bool frcGenericHIDGetRawButton (FrcGenericHID* self, int button);
bool frcGenericHIDGetRawButtonPressed (FrcGenericHID* self, int button);
bool frcGenericHIDGetRawButtonReleased (FrcGenericHID* self, int button);
double frcGenericHIDGetRawAxis (FrcGenericHID* self, int axis);
int frcGenericHIDGetPOV (FrcGenericHID* self, int pov);
int frcGenericHIDGetAxisCount (FrcGenericHID* self);
int frcGenericHIDGetPOVCount (FrcGenericHID* self);
int frcGenericHIDGetButtonCount (FrcGenericHID* self);
bool frcGenericHIDIsConnected (FrcGenericHID* self);
]]

-- FIXME: lib path shouldn't be hardcoded.
local lib = ffi.load ('../../build/bindings/libluabot-wpilibc.so')

local GenericHID = {}
local GenericHID_mt = {
    __index = GenericHID,
}

setmetatable (GenericHID, {
    __call = function(_, port)
        print (port, "port")
        local s = {
            impl = ffi.gc (lib.frcGenericHIDNew(port), lib.frcGenericHIDFree)
        }
        return setmetatable(s, GenericHID_mt)
    end
})

function GenericHID:getRawButton(button)
    print (type (self.impl))
    lib.frcGenericHIDGetRawButton(self.impl, button) -- (self.impl)
end

function GenericHID:isConnected()
    return lib.frcGenericHIDIsConnected (self.impl)
end

return GenericHID
