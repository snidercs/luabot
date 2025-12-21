# Find all YAML files recursively
file(GLOB_RECURSE YAML_FILES 
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "*.yaml"
)

# List to track generated files
set(GENERATED_LUA_FILES "")

foreach(YAML_FILE ${YAML_FILES})
    # Get the directory part of the file path
    get_filename_component(YAML_DIR ${YAML_FILE} DIRECTORY)
    get_filename_component(YAML_NAME ${YAML_FILE} NAME_WE)
    
    # Create the output path in build/lua directory with same structure
    set(OUTPUT_DIR ${CMAKE_BINARY_DIR}/lua/${YAML_DIR})
    set(OUTPUT_FILE ${OUTPUT_DIR}/${YAML_NAME}.lua)
    
    # Ensure output directory exists
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    
    # Add custom command to process each YAML file
    add_custom_command(
        OUTPUT ${OUTPUT_FILE}
        COMMAND ${Python3_EXECUTABLE} ${PARSE_PY} 
            -f lua 
            -o ${OUTPUT_FILE}
            ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_FILE}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_FILE}
        COMMENT "Generating ${OUTPUT_FILE} from ${YAML_FILE}"
        VERBATIM
    )
    
    # Track generated files
    list(APPEND GENERATED_LUA_FILES ${OUTPUT_FILE})
endforeach()

# Generate C bindings from YAML files
set(GENERATED_C_FILES "")

foreach(YAML_FILE ${YAML_FILES})
    # Get the directory part of the file path
    get_filename_component(YAML_DIR ${YAML_FILE} DIRECTORY)
    get_filename_component(YAML_NAME ${YAML_FILE} NAME_WE)
    
    # Create the output path in build/include/luabot/ffi directory with same structure
    set(OUTPUT_DIR ${CMAKE_BINARY_DIR}/include/luabot/ffi/${YAML_DIR})
    set(OUTPUT_FILE ${OUTPUT_DIR}/${YAML_NAME}.cpp)
    
    # Ensure output directory exists
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    
    # Add custom command to process each YAML file
    add_custom_command(
        OUTPUT ${OUTPUT_FILE}
        COMMAND ${Python3_EXECUTABLE} ${PARSE_PY} 
            -f c 
            -o ${OUTPUT_FILE}
            ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_FILE}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${YAML_FILE}
        COMMENT "Generating ${OUTPUT_FILE} from ${YAML_FILE}"
        VERBATIM
    )
    
    # Track generated files
    list(APPEND GENERATED_C_FILES ${OUTPUT_FILE})
endforeach()

# Find all existing .lua files and copy them
file(GLOB_RECURSE LUA_SOURCE_FILES 
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "*.lua"
)

set(COPIED_LUA_FILES "")

foreach(LUA_FILE ${LUA_SOURCE_FILES})
    # Get the directory part of the file path
    get_filename_component(LUA_DIR ${LUA_FILE} DIRECTORY)
    get_filename_component(LUA_NAME ${LUA_FILE} NAME)
    
    # Create the output path in build/lua directory with same structure
    set(OUTPUT_DIR ${CMAKE_BINARY_DIR}/lua/${LUA_DIR})
    set(OUTPUT_FILE ${OUTPUT_DIR}/${LUA_NAME})
    
    # Ensure output directory exists
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    
    # Add custom command to copy the lua file
    add_custom_command(
        OUTPUT ${OUTPUT_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/${LUA_FILE}
            ${OUTPUT_FILE}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${LUA_FILE}
        COMMENT "Copying ${LUA_FILE} to ${OUTPUT_FILE}"
        VERBATIM
    )
    
    # Track copied files
    list(APPEND COPIED_LUA_FILES ${OUTPUT_FILE})
endforeach()

# Find all existing .cpp files and copy them
file(GLOB_RECURSE CPP_SOURCE_FILES 
    RELATIVE ${CMAKE_CURRENT_SOURCE_DIR}
    "*.cpp"
)

set(COPIED_CPP_FILES "")

foreach(CPP_FILE ${CPP_SOURCE_FILES})
    # Get the directory part of the file path
    get_filename_component(CPP_DIR ${CPP_FILE} DIRECTORY)
    get_filename_component(CPP_NAME ${CPP_FILE} NAME)
    
    # Create the output path in build/include/luabot/ffi directory with same structure
    set(OUTPUT_DIR ${CMAKE_BINARY_DIR}/include/luabot/ffi/${CPP_DIR})
    set(OUTPUT_FILE ${OUTPUT_DIR}/${CPP_NAME})
    
    # Ensure output directory exists
    file(MAKE_DIRECTORY ${OUTPUT_DIR})
    
    # Add custom command to copy the cpp file
    add_custom_command(
        OUTPUT ${OUTPUT_FILE}
        COMMAND ${CMAKE_COMMAND} -E copy
            ${CMAKE_CURRENT_SOURCE_DIR}/${CPP_FILE}
            ${OUTPUT_FILE}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${CPP_FILE}
        COMMENT "Copying ${CPP_FILE} to ${OUTPUT_FILE}"
        VERBATIM
    )
    
    # Track copied files
    list(APPEND COPIED_CPP_FILES ${OUTPUT_FILE})
endforeach()

# Collect all CPP files by top-level directory and generate .ipp headers
set(ALL_CPP_FILES ${GENERATED_C_FILES} ${COPIED_CPP_FILES})
set(IPP_DIRS "")
set(GENERATED_IPP_FILES "")

# Extract unique directories for .ipp generation
foreach(CPP_FILE ${ALL_CPP_FILES})
    # Get relative path from build/include/luabot/ffi/
    string(REGEX REPLACE "^${CMAKE_BINARY_DIR}/include/luabot/ffi/" "" REL_PATH ${CPP_FILE})
    # Get the first directory component
    string(REGEX REPLACE "/.*$" "" TOP_DIR ${REL_PATH})
    
    # For wpi, use subdirectories instead
    if(TOP_DIR STREQUAL "wpi")
        # Extract second-level directory
        string(REGEX REPLACE "^wpi/([^/]+)/.*$" "wpi/\\1" SUBDIR ${REL_PATH})
        if(SUBDIR MATCHES "^wpi/[^/]+$")
            list(APPEND IPP_DIRS ${SUBDIR})
        endif()
    else()
        list(APPEND IPP_DIRS ${TOP_DIR})
    endif()
endforeach()

# Remove duplicates
list(REMOVE_DUPLICATES IPP_DIRS)

# Generate .ipp file for each directory
foreach(IPP_DIR ${IPP_DIRS})
    # Determine output file name
    string(REPLACE "/" "_" IPP_NAME ${IPP_DIR})
    # Remove wpi_ prefix if present
    string(REGEX REPLACE "^wpi_" "" IPP_NAME ${IPP_NAME})
    set(IPP_FILE ${CMAKE_BINARY_DIR}/include/luabot/${IPP_NAME}.ipp)
    set(IPP_CONTENT "#pragma once\n// Auto-generated include file for ${IPP_DIR}\n\n")
    
    # Find all cpp files under this directory
    foreach(CPP_FILE ${ALL_CPP_FILES})
        string(REGEX REPLACE "^${CMAKE_BINARY_DIR}/include/luabot/ffi/" "" REL_PATH ${CPP_FILE})
        
        # Check if this file belongs to this directory
        if(REL_PATH MATCHES "^${IPP_DIR}/")
            # Make path relative to include/luabot/
            string(REGEX REPLACE "^${CMAKE_BINARY_DIR}/include/luabot/" "" INCLUDE_PATH ${CPP_FILE})
            string(APPEND IPP_CONTENT "#include <luabot/${INCLUDE_PATH}>\n")
        endif()
    endforeach()
    
    # Write the .ipp file
    file(GENERATE OUTPUT ${IPP_FILE} CONTENT ${IPP_CONTENT})
    list(APPEND GENERATED_IPP_FILES ${IPP_FILE})
endforeach()

# Create a target that depends on all generated files
add_custom_target(generate_bindings ALL
    DEPENDS ${GENERATED_LUA_FILES} ${GENERATED_C_FILES} ${COPIED_LUA_FILES} ${COPIED_CPP_FILES}
)
