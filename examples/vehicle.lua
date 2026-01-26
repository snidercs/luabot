---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

---Example usage of the class module
---This demonstrates the Objective-C style two-phase initialization pattern

local class = require('luabot.class')

-- Define a base class (like RobotBase)
local Vehicle = class.define()

function Vehicle.init(instance, name)
    print("Vehicle.init called for: " .. name)
    instance.name = name
    instance.speed = 0
    return instance
end

function Vehicle:accelerate(amount)
    self.speed = self.speed + amount
    print(self.name .. " speed: " .. self.speed)
end

function Vehicle:getSpeed()
    return self.speed
end

-- Derive a class (like TimedRobot from RobotBase)
local Car = class(Vehicle)

function Car.init(instance, name, wheels)
    -- Calls Vehicle.init automatically first
    Vehicle.init(instance, name)
    print("Car.init called")
    instance.wheels = wheels
    return instance
end

function Car.new(name, wheels)
    -- Two-phase: allocation then initialization
    local self = setmetatable({}, Car)
    return Car.init(self, name, wheels)
end

function Car:honk()
    print(self.name .. " goes BEEP BEEP!")
end

-- Derive another level (like MyRobot from TimedRobot)
local SportsCar = class(Car)

function SportsCar.init(instance, name, wheels, topSpeed)
    -- Chains through: Vehicle.init -> Car.init -> SportsCar.init
    Car.init(instance, name, wheels)
    print("SportsCar.init called")
    instance.topSpeed = topSpeed
    return instance
end

function SportsCar.new(name, wheels, topSpeed)
    local self = setmetatable({}, SportsCar)
    return SportsCar.init(self, name, wheels, topSpeed)
end

function SportsCar:turboBoost()
    self.speed = self.topSpeed
    print(self.name .. " TURBO BOOST to " .. self.speed .. "!")
end

-- Demo usage
print("\n=== Creating a SportsCar ===")
local ferrari = SportsCar.new("Ferrari", 4, 200)

print("\n=== Method calls ===")
ferrari:accelerate(50)
ferrari:honk()              -- Inherited from Car
ferrari:turboBoost()

print("\n=== Final state ===")
print("Name: " .. ferrari.name)
print("Wheels: " .. ferrari.wheels)
print("Speed: " .. ferrari:getSpeed())  -- Inherited from Vehicle
print("Top Speed: " .. ferrari.topSpeed)
