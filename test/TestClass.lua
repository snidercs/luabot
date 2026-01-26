---SPDX-FileCopyrightText: Michael Fisher @mfisher31
---SPDX-License-Identifier: MIT

---Unit tests for the class module
local lu = require('luaunit')
local class = require('luabot.class')

TestClassDefine = {}

function TestClassDefine:testDefineCreatesTable()
    local MyClass = class()
    lu.assertNotNil(MyClass)
    lu.assertEquals(type(MyClass), "table")
end

function TestClassDefine:testDefineHasIndexMetamethod()
    local MyClass = class()
    lu.assertEquals(MyClass.__index, MyClass)
end

function TestClassDefine:testDefineCanAddMethods()
    local MyClass = class()
    
    function MyClass:getValue()
        return self.value
    end
    
    function MyClass.new(value)
        local self = setmetatable({}, MyClass)
        self.value = value
        return self
    end
    
    local obj = MyClass.new(42)
    lu.assertEquals(obj:getValue(), 42)
end

function TestClassDefine:testDefineCanHaveInitFunction()
    local MyClass = class()
    
    function MyClass.init(instance)
        instance.initialized = true
        return instance
    end
    
    function MyClass.new()
        local self = setmetatable({}, MyClass)
        return MyClass.init(self)
    end
    
    local obj = MyClass.new()
    lu.assertTrue(obj.initialized)
end

TestClassDerive = {}

function TestClassDerive:testDeriveCreatesTable()
    local Base = class()
    local Derived = class(Base)
    lu.assertNotNil(Derived)
    lu.assertEquals(type(Derived), "table")
end

function TestClassDerive:testDeriveInheritsFromBase()
    local Base = class()
    
    function Base:baseMethod()
        return "base"
    end
    
    local Derived = class(Base)
    
    function Derived.new()
        return setmetatable({}, Derived)
    end
    
    local obj = Derived.new()
    lu.assertEquals(obj:baseMethod(), "base")
end

function TestClassDerive:testDeriveCanOverrideMethods()
    local Base = class()
    
    function Base:getValue()
        return "base"
    end
    
    local Derived = class(Base)
    
    function Derived:getValue()
        return "derived"
    end
    
    function Derived.new()
        return setmetatable({}, Derived)
    end
    
    local obj = Derived.new()
    lu.assertEquals(obj:getValue(), "derived")
end

function TestClassDerive:testDeriveWithoutInitNoChaining()
    local Base = class()
    
    function Base.new()
        local self = setmetatable({}, Base)
        self.base_created = true
        return self
    end
    
    local Derived = class(Base)
    
    function Derived.new()
        local self = setmetatable({}, Derived)
        self.derived_created = true
        return self
    end
    
    local obj = Derived.new()
    lu.assertTrue(obj.derived_created)
    lu.assertNil(obj.base_created)  -- No automatic chaining without init
end

TestClassInitChaining = {}

function TestClassInitChaining:testInitChainsToParent()
    local Base = class()
    
    function Base.init(instance)
        instance.base_init = true
        return instance
    end
    
    local Derived = class(Base)
    
    function Derived.init(instance)
        -- Call parent init first (automatically wrapped)
        Base.init(instance)
        instance.derived_init = true
        return instance
    end
    
    function Derived.new()
        local self = setmetatable({}, Derived)
        return Derived.init(self)
    end
    
    local obj = Derived.new()
    lu.assertTrue(obj.base_init)
    lu.assertTrue(obj.derived_init)
end

function TestClassInitChaining:testMultiLevelInitChaining()
    local Base = class()
    
    function Base.init(instance)
        instance.base_init = true
        return instance
    end
    
    local Middle = class(Base)
    
    function Middle.init(instance)
        Base.init(instance)
        instance.middle_init = true
        return instance
    end
    
    local Derived = class(Middle)
    
    function Derived.init(instance)
        Middle.init(instance)
        instance.derived_init = true
        return instance
    end
    
    function Derived.new()
        local self = setmetatable({}, Derived)
        return Derived.init(self)
    end
    
    local obj = Derived.new()
    lu.assertTrue(obj.base_init)
    lu.assertTrue(obj.middle_init)
    lu.assertTrue(obj.derived_init)
end

function TestClassInitChaining:testInitWithParameters()
    local Base = class()
    
    function Base.init(instance, name)
        instance.name = name
        return instance
    end
    
    local Derived = class(Base)
    
    function Derived.init(instance, name, value)
        Base.init(instance, name)
        instance.value = value
        return instance
    end
    
    function Derived.new(name, value)
        local self = setmetatable({}, Derived)
        return Derived.init(self, name, value)
    end
    
    local obj = Derived.new("test", 42)
    lu.assertEquals(obj.name, "test")
    lu.assertEquals(obj.value, 42)
end

function TestClassInitChaining:testInitCanModifyState()
    local Base = class()
    
    function Base.init(instance)
        instance.counter = 0
        return instance
    end
    
    local Derived = class(Base)
    
    function Derived.init(instance)
        Base.init(instance)
        instance.counter = instance.counter + 10
        return instance
    end
    
    function Derived.new()
        local self = setmetatable({}, Derived)
        return Derived.init(self)
    end
    
    local obj = Derived.new()
    lu.assertEquals(obj.counter, 10)
end

function TestClassInitChaining:testInitResolvesToParentWhenNotDefined()
    local Base = class()
    
    function Base.init(instance)
        instance.base_initialized = true
        instance.value = 42
        return instance
    end
    
    local Derived = class(Base)
    -- Note: Derived does NOT define its own init()
    
    function Derived.new()
        local self = setmetatable({}, Derived)
        return Derived.init(self)  -- Should resolve to Base.init via __index
    end
    
    local obj = Derived.new()
    lu.assertTrue(obj.base_initialized)
    lu.assertEquals(obj.value, 42)
end

TestClassErrors = {}

function TestClassErrors:testErrorOnInvalidArgument()
    lu.assertErrorMsgContains("class() expects nil or a table", function()
        class("string")
    end)
    
    lu.assertErrorMsgContains("class() expects nil or a table", function()
        class(42)
    end)
    
    lu.assertErrorMsgContains("class() expects nil or a table", function()
        class(function() end)
    end)
end

TestClassInstanceBehavior = {}

function TestClassInstanceBehavior:testMultipleInstancesIndependent()
    local MyClass = class()
    
    function MyClass.init(instance, value)
        instance.value = value
        return instance
    end
    
    function MyClass.new(value)
        local self = setmetatable({}, MyClass)
        return MyClass.init(self, value)
    end
    
    local obj1 = MyClass.new(10)
    local obj2 = MyClass.new(20)
    
    lu.assertEquals(obj1.value, 10)
    lu.assertEquals(obj2.value, 20)
    
    obj1.value = 99
    lu.assertEquals(obj1.value, 99)
    lu.assertEquals(obj2.value, 20)  -- obj2 unchanged
end

function TestClassInstanceBehavior:testGarbageCollection()
    local MyClass = class()
    
    function MyClass.new()
        local self = setmetatable({}, MyClass)
        self.data = {}
        return self
    end
    
    local obj = MyClass.new()
    local weak_ref = setmetatable({obj}, {__mode = "v"})
    
    lu.assertNotNil(weak_ref[1])
    obj = nil
    collectgarbage()
    lu.assertNil(weak_ref[1])  -- Object should be collected
end

TestClassVersion = {}

function TestClassVersion:testVersionExists()
    lu.assertNotNil(class.version)
    lu.assertEquals(type(class.version), "number")
    lu.assertEquals(class.version, 1)
end

-- Run tests
os.exit(lu.LuaUnit.run())
