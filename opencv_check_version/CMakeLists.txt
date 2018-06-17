find_package( OpenCV REQUIRED )
add_executable(opencv_version_check opencv_version_check.cpp)
# link the static Tensorflow library
#target_link_libraries(example TensorflowCC::Static)
# link the shared Tensorflow library
target_link_libraries(opencv_version_check ${OpenCV_LIBS})
