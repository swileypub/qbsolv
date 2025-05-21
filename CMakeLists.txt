cmake_minimum_required(VERSION 3.16)
project(qbsolv LANGUAGES C CXX)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE "Release" CACHE STRING "Choose the type of build." FORCE)
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Release" "MinSizeRel" "RelWithDebInfo")
endif()

# Set output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")

# Compiler flags
if(CMAKE_C_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        "$<$<COMPILE_LANGUAGE:C>:-Wall;-Wextra;-std=gnu99>"
        "$<$<CONFIG:Debug>:-O0;-g3>"
        "$<$<CONFIG:Release>:-O3>"
    )
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "GNU|Clang")
    add_compile_options(
        "$<$<COMPILE_LANGUAGE:CXX>:-Wall;-Wextra;-std=gnu++11>"
        "$<$<CONFIG:Debug>:-O0;-g3>"
        "$<$<CONFIG:Release>:-O3>"
    )
endif()

# Static library
add_library(libqbsolv STATIC
    src/solver.cc
    src/util.cc
    src/dwsolv.cc
)
set_target_properties(libqbsolv PROPERTIES
    OUTPUT_NAME "qbsolv"
    PUBLIC_HEADER "${CMAKE_SOURCE_DIR}/include/qbsolv.h;${CMAKE_SOURCE_DIR}/src/dwsolv.h"
)
target_include_directories(libqbsolv PUBLIC
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include>
    $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>
    $<INSTALL_INTERFACE:include>
)

# Command line executable
if(QBSOLV_BUILD_CMD)
    add_executable(qbsolv
        cmd/main.c
        cmd/readqubo.c
    )
    # Ensure cmd and src directories are available for qbsolv
    target_include_directories(qbsolv PRIVATE
        ${CMAKE_SOURCE_DIR}/cmd
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/include
    )
    target_link_libraries(qbsolv PRIVATE libqbsolv)
endif()

# Testing
if(QBSOLV_BUILD_TESTS)
    include(FetchContent)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG release-1.12.1
    )
    
    # For Windows: Prevent overriding the parent project's compiler/linker settings
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    enable_testing()
    add_subdirectory(tests)
endif()
