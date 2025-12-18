# Build benchmark executables
add_executable(plusone plusone.cpp)
target_link_libraries(plusone PRIVATE wpilibc hal wpiutil)

# Set common environment for all tests
set(TEST_LUA_PATH "LUA_PATH=${CMAKE_BINARY_DIR}/lua/?.lua\;${CMAKE_BINARY_DIR}/lua/?/init.lua\;${CMAKE_SOURCE_DIR}/test/?.lua\;${CMAKE_SOURCE_DIR}/test/?/init.lua\;\;")

# Helper function to add Lua tests
function(luabot_add_lua_test test_name test_file)
    add_test(NAME ${test_name}
        COMMAND luabot ${CMAKE_SOURCE_DIR}/test/${test_file}
        WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/wpi)
    set_tests_properties(${test_name} PROPERTIES ENVIRONMENT "${TEST_LUA_PATH}")
endfunction()

# Add tests
luabot_add_lua_test(RequireAll requireall.lua)
luabot_add_lua_test(TestAddressableLED wpi/TestAddressableLED.lua)
luabot_add_lua_test(TestFilesystem wpi/TestFilesystem.lua)
luabot_add_lua_test(TestGeometry wpi/TestGeometry.lua)
luabot_add_lua_test(TestRobots wpi/TestRobots.lua)
luabot_add_lua_test(TestTimed wpi/TestTimed.lua)
