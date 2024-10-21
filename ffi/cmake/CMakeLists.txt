cmake_minimum_required(VERSION 3.22.1)

# Set the project name
project(color_extractor)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add the library
add_library(color_extractor SHARED
    ../ffi/color_extractor.c
)

# Include directories
target_include_directories(color_extractor PRIVATE
    ../ffi
)

# Set compile options
target_compile_options(color_extractor PRIVATE
    -Wall
    -Wextra
    -Wpedantic
    -fvisibility=hidden
)

# Set properties for Android
set_target_properties(color_extractor PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/../android/app/src/main/jniLibs/${ANDROID_ABI}"
)

# Link against the log library on Android
if(ANDROID)
    find_library(log-lib log)
    target_link_libraries(color_extractor ${log-lib})
endif()

# Export the extract_dominant_colors function
set_target_properties(color_extractor PROPERTIES
    LINK_FLAGS "-Wl,--version-script=${CMAKE_CURRENT_SOURCE_DIR}/version_script.ld"
)
