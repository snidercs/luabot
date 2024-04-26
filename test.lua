
local ffi = require ('ffi')

ffi.cdef[[
typedef struct FrcJoystick FrcJoystick;

void frcJoystickFree (FrcJoystick* self);

FrcJoystick* frcJoystickNew(int port);
void frcJoystickSetXChannel(FrcJoystick* self, int channel);
void frcJoystickSetYChannel(FrcJoystick* self, int channel);
void frcJoystickSetZChannel(FrcJoystick* self, int channel);
void frcJoystickSetTwistChannel(FrcJoystick* self, int channel);
void frcJoystickSetThrottleChannel(FrcJoystick* self, int channel);
int frcJoystickGetXChannel(const FrcJoystick* self);
int frcJoystickGetYChannel(const FrcJoystick* self);
int frcJoystickGetZChannel(const FrcJoystick* self);
int frcJoystickGetTwistChannel(const FrcJoystick* self);
int frcJoystickGetThrottleChannel(const FrcJoystick* self);
double frcJoystickGetX(const FrcJoystick* self);
double frcJoystickGetY(const FrcJoystick* self);
double frcJoystickGetZ(const FrcJoystick* self);
double frcJoystickGetTwist(const FrcJoystick* self);
double frcJoystickGetThrottle(const FrcJoystick* self);
bool frcJoystickGetTrigger(const FrcJoystick* self);
bool frcJoystickGetTriggerPressed(FrcJoystick* self);
bool frcJoystickGetTriggerReleased(FrcJoystick* self);
bool frcJoystickGetTop(const FrcJoystick* self);
bool frcJoystickGetTopPressed(FrcJoystick* self);
bool frcJoystickGetTopReleased(FrcJoystick* self);

]]

local lib = ffi.load ('luabot-wpic')

local Joystick = {}
local Joystick_mt = {
    __index = Joystick
}

function Joystick:setXChannel(channel)
    lib.frcJoystickSetXChannel(self, channel)
end

function Joystick:setYChannel(channel)
    lib.frcJoystickSetYChannel(self, channel)
end

function Joystick:setZChannel(channel)
    lib.frcJoystickSetZChannel(self, channel)
end

function Joystick:setTwistChannel(channel)
    lib.frcJoystickSetTwistChannel(self, channel)
end

function Joystick:setThrottleChannel(channel)
    lib.frcJoystickSetThrottleChannel(self, channel)
end

function Joystick:getXChannel()
    return lib.frcJoystickGetXChannel(self)
end

function Joystick:getYChannel()
    return lib.frcJoystickGetYChannel(self)
end

function Joystick:getZChannel()
    return lib.frcJoystickGetZChannel(self)
end

function Joystick:getTwistChannel()
    return lib.frcJoystickGetTwistChannel(self)
end

function Joystick:getThrottleChannel()
    return lib.frcJoystickGetThrottleChannel(self)
end

function Joystick:getX()
    return lib.frcJoystickGetX(self)
end

function Joystick:getY()
    return lib.frcJoystickGetY(self)
end

function Joystick:getZ()
    return lib.frcJoystickGetZ(self)
end

function Joystick:getTwist()
    return lib.frcJoystickGetTwist(self)
end

function Joystick:getThrottle()
    return lib.frcJoystickGetThrottle(self)
end

function Joystick:getTrigger()
    return lib.frcJoystickGetTrigger(self)
end

function Joystick:getTriggerPressed()
    return lib.frcJoystickGetTriggerPressed(self)
end

function Joystick:getTriggerReleased()
    return lib.frcJoystickGetTriggerReleased(self)
end

function Joystick:getTop()
    return lib.frcJoystickGetTop(self)
end

function Joystick:getTopPressed()
    return lib.frcJoystickGetTopPressed(self)
end

function Joystick:getTopReleased()
    return lib.frcJoystickGetTopReleased(self)
end

ffi.metatype('FrcJoystick', Joystick_mt)
return Joystick

