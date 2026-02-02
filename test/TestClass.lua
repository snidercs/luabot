--- SPDX-FileCopyrightText: Michael Fisher @mfisher31
--- SPDX-License-Identifier: MIT

--- Unit tests for the class module
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

TestClassDefaultConstruction = {}

function TestClassDefaultConstruction:testDefaultNewExists()
    local MyClass = class()
    lu.assertNotNil(MyClass.new)
    lu.assertEquals(type(MyClass.new), "function")
end

function TestClassDefaultConstruction:testDefaultNewCreatesInstance()
    local MyClass = class()
    local obj = MyClass.new()
    
    lu.assertNotNil(obj)
    lu.assertEquals(type(obj), "table")
end

function TestClassDefaultConstruction:testDefaultNewSetsMetatable()
    local MyClass = class()
    local obj = MyClass.new()
    
    -- Verify metatable is set correctly
    lu.assertEquals(getmetatable(obj), MyClass)
    lu.assertEquals(getmetatable(obj).__index, MyClass)
end

function TestClassDefaultConstruction:testDefaultNewCallsInit()
    local MyClass = class()
    local init_called = false
    
    -- Override init to track if it's called
    function MyClass.init(instance)
        init_called = true
        instance.init_value = 42
        return instance
    end
    
    local obj = MyClass.new()
    lu.assertTrue(init_called)
    lu.assertEquals(obj.init_value, 42)
end

function TestClassDefaultConstruction:testDefaultInitReturnsInstance()
    local MyClass = class()
    
    -- Default init should return the instance unchanged
    local instance = setmetatable({}, MyClass)
    local result = MyClass.init(instance)
    
    lu.assertEquals(result, instance)
end

function TestClassDefaultConstruction:testCanOverrideDefaultNew()
    local MyClass = class()
    
    -- Override default new with custom constructor
    function MyClass.new(value)
        local self = setmetatable({}, MyClass)
        self.value = value
        return self
    end
    
    local obj = MyClass.new(100)
    lu.assertEquals(obj.value, 100)
end

function TestClassDefaultConstruction:testMultipleInstancesAreIndependent()
    local MyClass = class()
    
    function MyClass.init(instance)
        instance.counter = 0
        return instance
    end
    
    local obj1 = MyClass.new()
    local obj2 = MyClass.new()
    
    obj1.counter = 10
    obj2.counter = 20
    
    lu.assertEquals(obj1.counter, 10)
    lu.assertEquals(obj2.counter, 20)
end

function TestClassDefaultConstruction:testInstanceCanCallClassMethods()
    local MyClass = class()
    
    function MyClass:increment()
        self.value = (self.value or 0) + 1
    end
    
    function MyClass:getValue()
        return self.value or 0
    end
    
    local obj = MyClass.new()
    lu.assertEquals(obj:getValue(), 0)
    
    obj:increment()
    lu.assertEquals(obj:getValue(), 1)
    
    obj:increment()
    lu.assertEquals(obj:getValue(), 2)
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

TestClassNew = {}

function TestClassNew:testNewFunctionExists()
    lu.assertNotNil(class.new)
    lu.assertEquals(type(class.new), "function")
end

function TestClassNew:testNewWithClassTable()
    local MyClass = class()
    
    function MyClass.init(instance)
        instance.created = true
        return instance
    end
    
    local obj = class.new(MyClass)
    
    lu.assertNotNil(obj)
    lu.assertTrue(obj.created)
    lu.assertEquals(getmetatable(obj), MyClass)
end

function TestClassNew:testNewWithArguments()
    local MyClass = class()
    
    function MyClass.new(value1, value2)
        local self = setmetatable({}, MyClass)
        self.value1 = value1
        self.value2 = value2
        return self
    end
    
    local obj = class.new(MyClass, 42, "hello")
    
    lu.assertEquals(obj.value1, 42)
    lu.assertEquals(obj.value2, "hello")
end

function TestClassNew:testNewEquivalentToDirectCall()
    local MyClass = class()
    
    function MyClass.init(instance)
        instance.counter = 0
        return instance
    end
    
    local obj1 = class.new(MyClass)
    local obj2 = MyClass.new()
    
    -- Both should have the same structure
    lu.assertNotNil(obj1.counter)
    lu.assertNotNil(obj2.counter)
    lu.assertEquals(obj1.counter, obj2.counter)
    lu.assertEquals(getmetatable(obj1), getmetatable(obj2))
end

function TestClassNew:testNewWithModuleString()
    -- Create a temporary module for testing
    local test_module_path = 'test_temp_class_module'
    
    -- Define a test class in package.preload
    package.preload[test_module_path] = function()
        local TestClass = class()
        function TestClass.init(instance)
            instance.from_module = true
            return instance
        end
        return TestClass
    end
    
    local obj = class.new(test_module_path)
    
    lu.assertNotNil(obj)
    lu.assertTrue(obj.from_module)
    
    -- Clean up
    package.preload[test_module_path] = nil
    package.loaded[test_module_path] = nil
end

function TestClassNew:testNewWithModuleStringAndArguments()
    local test_module_path = 'test_temp_class_module_args'
    
    package.preload[test_module_path] = function()
        local TestClass = class()
        function TestClass.new(x, y)
            local self = setmetatable({}, TestClass)
            self.x = x
            self.y = y
            return self
        end
        return TestClass
    end
    
    local obj = class.new(test_module_path, 10, 20)
    
    lu.assertEquals(obj.x, 10)
    lu.assertEquals(obj.y, 20)
    
    -- Clean up
    package.preload[test_module_path] = nil
    package.loaded[test_module_path] = nil
end

function TestClassNew:testNewErrorOnNonTable()
    lu.assertErrorMsgContains("Cannot instantiate a non-class type", function()
        class.new(42)
    end)
    
    lu.assertErrorMsgContains("Cannot instantiate a non-class type", function()
        class.new(function() end)
    end)
end

function TestClassNew:testNewErrorOnTableWithoutNew()
    local not_a_class = { some_field = true }
    
    lu.assertErrorMsgContains("Cannot instantiate a non-class type", function()
        class.new(not_a_class)
    end)
end

function TestClassNew:testNewErrorOnInvalidModule()
    lu.assertError(function()
        class.new('this_module_does_not_exist_xyz123')
    end)
end

function TestClassNew:testNewWithDerivedClass()
    local Base = class()
    function Base.init(instance)
        instance.base_init = true
        return instance
    end
    
    local Derived = class(Base)
    function Derived.init(instance)
        Base.init(instance)
        instance.derived_init = true
        return instance
    end
    
    local obj = class.new(Derived)
    
    lu.assertTrue(obj.base_init)
    lu.assertTrue(obj.derived_init)
end

TestClassVersion = {}

function TestClassVersion:testVersionExists()
    lu.assertNotNil(class.version)
    lu.assertEquals(type(class.version), "number")
    lu.assertEquals(class.version, 1)
end

-- Run tests
os.exit(lu.LuaUnit.run())
