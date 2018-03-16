find_package(TensorflowCC REQUIRED)
find_package( OpenCV REQUIRED )
add_executable(example example.cpp)
# link the static Tensorflow library
#target_link_libraries(example TensorflowCC::Static)
# link the shared Tensorflow library
target_link_libraries(example TensorflowCC::Static
${OpenCV_LIBS})
