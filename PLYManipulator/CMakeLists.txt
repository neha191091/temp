cmake_minimum_required(VERSION 3.5)

project(PLYManipulator)

set(PROJECT_INCLUDE_DIR ${PROJECT_SOURCE_DIR}/include)
set(PROJECT_SOURCE_DIR ${PROJECT_SOURCE_DIR}/src)

#include_directories(${PROJECT_INCLUDE_DIR})

file(GLOB PLYManipulator_SRCS ${PROJECT_SOURCE_DIR}/*.cpp)

add_executable(pLYManipulator ${PLYManipulator_SRCS})
target_link_libraries(pLYManipulator ${OpenCV_LIBS})
