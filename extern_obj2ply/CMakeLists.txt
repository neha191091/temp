cmake_minimum_required(VERSION 3.5)

set(PROJECT_INCLUDE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/include)

set(PROJECT_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/src)

include_directories("${PROJECT_INCLUDE_DIR}")
file(GLOB obj2plyLib_SRCS ${PROJECT_SOURCE_DIR}/*.c)

add_library(obj2ply_lib ${obj2plyLib_SRCS})




find_package( OpenCV REQUIRED )
add_executable(example example.cpp)
# link the static Tensorflow library
#target_link_libraries(example TensorflowCC::Static)
# link the shared Tensorflow library
target_link_libraries(example ${OpenCV_LIBS} obj2ply_lib)
