# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(color_extractor_library VERSION 0.0.1 LANGUAGES C)

add_library(color_extractor SHARED
  "color_extractor.c"
)

set_target_properties(color_extractor PROPERTIES
  PUBLIC_HEADER color_extractor.h
  OUTPUT_NAME "color_extractor"
)

target_compile_definitions(color_extractor PUBLIC DART_SHARED_LIB)
