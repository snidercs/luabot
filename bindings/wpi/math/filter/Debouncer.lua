---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

local class = require('luabot.class')
local Timer = require('wpi.frc.Timer')

---@class Debouncer
---@field private _debounceTimeSeconds number The number of seconds the value must change from baseline
---@field private _debounceType number Type of debouncing (kRising, kFalling, kBoth)
---@field private _baseline boolean The baseline value
---@field private _prevTimeSeconds number The previous timestamp
local Debouncer = class()

---Debounce type constants
Debouncer.DebounceType = {
    kRising = 0,   -- Rising edge
    kFalling = 1,  -- Falling edge
    kBoth = 2      -- Both rising and falling edges
}

---Initialize a new Debouncer instance
---@param self Debouncer
---@param debounceTime number The number of seconds the value must change from baseline
---@param debounceType number|nil Which type of state change (default: kRising)
function Debouncer.init(self, debounceTime, debounceType)
    self._debounceTimeSeconds = debounceTime
    self._debounceType = debounceType or Debouncer.DebounceType.kRising
    
    self:resetTimer()
    
    self._baseline = (self._debounceType == Debouncer.DebounceType.kFalling)
end

---Create a new Debouncer
---@param debounceTime number The number of seconds the value must change from baseline
---@param debounceType number|nil Which type of state change (default: kRising)
---@return Debouncer
function Debouncer.new(debounceTime, debounceType)
    local instance = setmetatable({}, Debouncer)
    Debouncer.init(instance, debounceTime, debounceType)
    return instance
end

---Reset the internal timer
function Debouncer:resetTimer()
    self._prevTimeSeconds = Timer.getFPGATimestamp()
end

---Check if the debounce time has elapsed
---@return boolean True if enough time has passed
function Debouncer:hasElapsed()
    return Timer.getFPGATimestamp() - self._prevTimeSeconds >= self._debounceTimeSeconds
end

---Applies the debouncer to the input stream
---@param input boolean The current value of the input stream
---@return boolean The debounced value of the input stream
function Debouncer:calculate(input)
    if input == self._baseline then
        self:resetTimer()
    end
    
    if self:hasElapsed() then
        if self._debounceType == Debouncer.DebounceType.kBoth then
            self._baseline = input
            self:resetTimer()
        end
        return input
    else
        return self._baseline
    end
end

---Sets the time to debounce
---@param time number The number of seconds the value must change from baseline
function Debouncer:setDebounceTime(time)
    self._debounceTimeSeconds = time
end

---Gets the time to debounce
---@return number The number of seconds the value must change from baseline
function Debouncer:getDebounceTime()
    return self._debounceTimeSeconds
end

---Sets the debounce type
---@param debounceType number Which type of state change the debouncing will be performed on
function Debouncer:setDebounceType(debounceType)
    self._debounceType = debounceType
    self._baseline = (self._debounceType == Debouncer.DebounceType.kFalling)
end

---Gets the debounce type
---@return number Which type of state change the debouncing will be performed on
function Debouncer:getDebounceType()
    return self._debounceType
end

return Debouncer
