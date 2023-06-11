cmake_minimum_required(VERSION 3.17)

project(cpp-template
    VERSION 0.1.0
    LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(spdlog REQUIRED)

include_directories(${PROJECT_SOURCE_DIR})
add_subdirectory(src)
