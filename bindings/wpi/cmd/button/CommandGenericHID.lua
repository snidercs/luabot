---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local GenericHID = require('wpi.frc.GenericHID')
local Trigger = require('wpi.cmd.button.Trigger')

---@class CommandGenericHID
---@field private _hid GenericHID The underlying HID device
---@field private _buttonCache table<EventLoop, table<number, Trigger>> Cache of button triggers by loop and button index
---@field private _axisGreaterThanCache table<EventLoop, table<string, Trigger>> Cache of axis > threshold triggers
---@field private _axisLessThanCache table<EventLoop, table<string, Trigger>> Cache of axis < threshold triggers
---@field private _axisMagnitudeGreaterThanCache table<EventLoop, table<string, Trigger>> Cache of |axis| > threshold triggers
---@field private _povCache table<EventLoop, table<number, Trigger>> Cache of POV angle triggers
local CommandGenericHID = class()

---Initialize a new CommandGenericHID
---@param self CommandGenericHID
---@param port number The port index on the Driver Station
function CommandGenericHID.init(self, port)
    self._hid = GenericHID.new(port)
    self._buttonCache = {}
    self._axisGreaterThanCache = {}
    self._axisLessThanCache = {}
    self._axisMagnitudeGreaterThanCache = {}
    self._povCache = {}
end

---Create a new CommandGenericHID
---@param port number The port index on the Driver Station
---@return CommandGenericHID
function CommandGenericHID.new(port)
    local instance = setmetatable({}, CommandGenericHID)
    CommandGenericHID.init(instance, port)
    return instance
end

---Get the underlying GenericHID object
---@return GenericHID
function CommandGenericHID:getHID()
    return self._hid
end

---Create a trigger for a button press
---@param button number The button index (1-based for Lua)
---@param loop? EventLoop The event loop to attach to (defaults to scheduler's button loop)
---@return Trigger
function CommandGenericHID:button(button, loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    -- Initialize cache for this loop if needed
    if not self._buttonCache[loop] then
        self._buttonCache[loop] = {}
    end
    
    -- Return cached trigger if it exists
    if self._buttonCache[loop][button] then
        return self._buttonCache[loop][button]
    end
    
    -- Create new trigger
    local trigger = Trigger.new(loop, function()
        return self._hid:getRawButton(button)
    end)
    
    self._buttonCache[loop][button] = trigger
    return trigger
end

---Create a trigger for a POV (hat switch) direction
---@param pov? number The POV index (default 0)
---@param angle number The POV angle in degrees (0=up, 90=right, 180=down, 270=left, -1=center)
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandGenericHID:pov(pov, angle, loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    pov = pov or 0
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    -- Create unique key for this POV+angle combination
    -- Use pov * 3600 + angle to allow -1 (center)
    local key = pov * 3600 + angle
    
    -- Initialize cache for this loop if needed
    if not self._povCache[loop] then
        self._povCache[loop] = {}
    end
    
    -- Return cached trigger if it exists
    if self._povCache[loop][key] then
        return self._povCache[loop][key]
    end
    
    -- Create new trigger
    local trigger = Trigger.new(loop, function()
        return self._hid:getPOV(pov) == angle
    end)
    
    self._povCache[loop][key] = trigger
    return trigger
end

---Convenience method for POV up (0 degrees)
---@return Trigger
function CommandGenericHID:povUp()
    return self:pov(0, 0)
end

---Convenience method for POV up-right (45 degrees)
---@return Trigger
function CommandGenericHID:povUpRight()
    return self:pov(0, 45)
end

---Convenience method for POV right (90 degrees)
---@return Trigger
function CommandGenericHID:povRight()
    return self:pov(0, 90)
end

---Convenience method for POV down-right (135 degrees)
---@return Trigger
function CommandGenericHID:povDownRight()
    return self:pov(0, 135)
end

---Convenience method for POV down (180 degrees)
---@return Trigger
function CommandGenericHID:povDown()
    return self:pov(0, 180)
end

---Convenience method for POV down-left (225 degrees)
---@return Trigger
function CommandGenericHID:povDownLeft()
    return self:pov(0, 225)
end

---Convenience method for POV left (270 degrees)
---@return Trigger
function CommandGenericHID:povLeft()
    return self:pov(0, 270)
end

---Convenience method for POV up-left (315 degrees)
---@return Trigger
function CommandGenericHID:povUpLeft()
    return self:pov(0, 315)
end

---Convenience method for POV center (not pressed)
---@return Trigger
function CommandGenericHID:povCenter()
    return self:pov(0, -1)
end

---Create a trigger that is true when axis value < threshold
---@param axis number The axis index (0-based)
---@param threshold number The threshold value
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandGenericHID:axisLessThan(axis, threshold, loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    -- Create unique string key for this axis+threshold combination
    local key = string.format('%d:%.6f', axis, threshold)
    
    -- Initialize cache for this loop if needed
    if not self._axisLessThanCache[loop] then
        self._axisLessThanCache[loop] = {}
    end
    
    -- Return cached trigger if it exists
    if self._axisLessThanCache[loop][key] then
        return self._axisLessThanCache[loop][key]
    end
    
    -- Create new trigger
    local trigger = Trigger.new(loop, function()
        return self._hid:getRawAxis(axis) < threshold
    end)
    
    self._axisLessThanCache[loop][key] = trigger
    return trigger
end

---Create a trigger that is true when axis value > threshold
---@param axis number The axis index (0-based)
---@param threshold number The threshold value
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandGenericHID:axisGreaterThan(axis, threshold, loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    -- Create unique string key for this axis+threshold combination
    local key = string.format('%d:%.6f', axis, threshold)
    
    -- Initialize cache for this loop if needed
    if not self._axisGreaterThanCache[loop] then
        self._axisGreaterThanCache[loop] = {}
    end
    
    -- Return cached trigger if it exists
    if self._axisGreaterThanCache[loop][key] then
        return self._axisGreaterThanCache[loop][key]
    end
    
    -- Create new trigger
    local trigger = Trigger.new(loop, function()
        return self._hid:getRawAxis(axis) > threshold
    end)
    
    self._axisGreaterThanCache[loop][key] = trigger
    return trigger
end

---Create a trigger that is true when |axis value| > threshold
---@param axis number The axis index (0-based)
---@param threshold number The threshold value
---@param loop? EventLoop The event loop to attach to
---@return Trigger
function CommandGenericHID:axisMagnitudeGreaterThan(axis, threshold, loop)
    local CommandScheduler = require('wpi.cmd.CommandScheduler')
    loop = loop or CommandScheduler.getInstance():getDefaultButtonLoop()
    
    -- Create unique string key for this axis+threshold combination
    local key = string.format('%d:%.6f', axis, threshold)
    
    -- Initialize cache for this loop if needed
    if not self._axisMagnitudeGreaterThanCache[loop] then
        self._axisMagnitudeGreaterThanCache[loop] = {}
    end
    
    -- Return cached trigger if it exists
    if self._axisMagnitudeGreaterThanCache[loop][key] then
        return self._axisMagnitudeGreaterThanCache[loop][key]
    end
    
    -- Create new trigger
    local trigger = Trigger.new(loop, function()
        return math.abs(self._hid:getRawAxis(axis)) > threshold
    end)
    
    self._axisMagnitudeGreaterThanCache[loop][key] = trigger
    return trigger
end

---Get the value of a raw axis
---@param axis number The axis index (0-based)
---@return number The axis value
function CommandGenericHID:getRawAxis(axis)
    return self._hid:getRawAxis(axis)
end

---Set the rumble output for the HID
---@param type number RumbleType (kLeftRumble or kRightRumble)
---@param value number The normalized value (0 to 1) to set the rumble to
function CommandGenericHID:setRumble(type, value)
    self._hid:setRumble(type, value)
end

---Check if the HID is connected
---@return boolean True if the HID is connected
function CommandGenericHID:isConnected()
    return self._hid:isConnected()
end

return CommandGenericHID
