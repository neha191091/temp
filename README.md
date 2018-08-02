# Temporary Projects

Contains a lot of test and temporary code for larger projects.

## blender_scripts_render_plys   
Python script for generating depth images from 3d model using blender.
## matplotlib_helpers
Python scripts for animating matplotlib plots.
## color_all_registered_meshes
C++ script for coloring multiple preregistered ply 3D meshes given a corresponding colored mesh.
## opencv_change_and_save_depth
C++. OpenCV script for manipulating the values of a depth png.
## color_all_registered_meshes_obj2ply  
C++ script for coloring multiple preregistered obj 3D meshes given a corresponding colored mes
## opencv_check_version
C++ script to check OpenCV version.
## depth_plane_segmentation
C++ code for separating the background plane from the foreground in a depth image via threshold.
## PLYManipulator
C++ code for manipulating 3d human mesh to extract body part - see [human-segmentation](https://github.com/neha191091/human-segmentation)
## depth_test_train_disparity_human_seg
Python code for evaluating the disparity between the training and the real dataset for [human-segmentation](https://github.com/neha191091/human-segmentation). Can be modified for other data.
## extern_obj2ply
External C++ code for converting obj to ply
## test_change_workdir_docker
Test for changing workdir from Docker
## freeze_tensorflow_graph
Code for freezing tensorflow graph; [source](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/python/tools/freeze_graph.py)
## tf_opencv_run_a_tf_graph
C++ code for running a tensorflow graph. Depends on libtensorflow_all.so and tensorflow headers created/copied using [FloopCZ's instructions](https://github.com/FloopCZ/tensorflow_cc)
## MATLAB_packages_from_net
MATLAB visualization code; [source](https://www.mathworks.com/matlabcentral/fileexchange/52374-show-scroll-visualize-arbitrary-n-dimensional-arrays)
## visualize_grads
python script for visualizing gradient matrices for this project.
## test-c_api-tf-portability-1.2-1.3
code for testing portability of a graph trained and frozen in tf1.3 (create_graph.py) to the tf1.2.1 c_api. Particularly checks if creating the graph with tf.distributions in tf 1.3 prevents it from running in the tf 1.2.1 c_api. Success so far. Copy the command from Makefile and run it on the terminal to build the c++ source, running make will not work. Can be modified for running c_api for higher version tf graphs.
## aarch64-linux-test-c++
Testing C++ on aarchlinux machine. Run a.out on the aarch linux machine to test if C++ works.
