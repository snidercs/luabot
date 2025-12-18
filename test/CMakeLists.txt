# Build benchmark executables
add_executable(plusone plusone.cpp)
target_link_libraries(plusone PRIVATE wpilibc hal wpiutil)

# Set common environment for all tests
set(TEST_LUA_PATH "LUA_PATH=${CMAKE_BINARY_DIR}/lua/?.lua\;${CMAKE_BINARY_DIR}/lua/?/init.lua\;${CMAKE_SOURCE_DIR}/test/?.lua\;${CMAKE_SOURCE_DIR}/test/?/init.lua\;\;")

# Add tests
add_test(NAME TestAddressableLED
    COMMAND luabot ${CMAKE_SOURCE_DIR}/test/wpi/TestAddressableLED.lua
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/wpi)

add_test(NAME TestFilesystem
    COMMAND luabot ${CMAKE_SOURCE_DIR}/test/wpi/TestFilesystem.lua
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/wpi)

add_test(NAME TestGeometry
    COMMAND luabot ${CMAKE_SOURCE_DIR}/test/wpi/TestGeometry.lua
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/wpi)

add_test(NAME TestRobots
    COMMAND luabot ${CMAKE_SOURCE_DIR}/test/wpi/TestRobots.lua
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/wpi)

add_test(NAME TestTimed
    COMMAND luabot ${CMAKE_SOURCE_DIR}/test/wpi/TestTimed.lua
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/test/wpi)

# Set environment for all tests
set_tests_properties(
    TestAddressableLED
    TestFilesystem
    TestGeometry
    TestRobots
    TestTimed
    PROPERTIES ENVIRONMENT "${TEST_LUA_PATH}")

