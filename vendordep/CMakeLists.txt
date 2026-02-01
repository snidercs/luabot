# SPDX-FileCopyrightText: Michael Fisher @mfisher31
# SPDX-License-Identifier: MIT

add_library(luabot-stub STATIC "${CMAKE_CURRENT_SOURCE_DIR}/stub.c")

# Clean vendordep artifacts on 'clean'
file(GLOB _vendordep_artifacts 
  "${CMAKE_CURRENT_BINARY_DIR}/*.zip"
  "${CMAKE_CURRENT_BINARY_DIR}/*.pom"
  "${CMAKE_CURRENT_BINARY_DIR}/*.json")
if(_vendordep_artifacts)
  set_directory_properties(PROPERTIES
    ADDITIONAL_CLEAN_FILES "${_vendordep_artifacts}")
endif()

# Generate vendordep zip artifacts on demand
add_custom_target(luabot-vendordep
  COMMAND ${Python3_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/vendordep.py
    --version ${PROJECT_VERSION}
    --build-dir ${PROJECT_BINARY_DIR}
    --source-dir ${PROJECT_SOURCE_DIR}
    --output-dir ${CMAKE_CURRENT_BINARY_DIR}
    --github-repo snidercs/luabot
  WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
  COMMENT "Generate vendordep zip artifacts")
