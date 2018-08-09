#g++ -std=c++11 -L/usr/lib -o run_graph run_graph.cpp -ltensorflow
#g++ -std=c++11 -L/usr/lib -o run_conv_graph run_conv_graph.cpp -ltensorflow -L/usr/local/cuda-8.0/lib64 -lopencv_calib3d -lopencv_contrib -lopencv_core -lopencv_features2d -lopencv_flann -lopencv_gpu -lopencv_highgui -lopencv_imgproc -lopencv_legacy -lopencv_ml -lopencv_objdetect -lopencv_photo -lopencv_stitching -lopencv_superres -lopencv_ts -lopencv_video -lopencv_videostab -lopencv_detection_based_tracker -lopencv_esm_panorama -lopencv_facedetect -lopencv_imuvstab -lopencv_tegra -lopencv_vstab -lcufft -lnpps -lnppi -lnppc -lcudart -latomic -ltbb -lrt -lpthread -lm -ldl -I/usr/include/opencv

CFLAGS = `pkg-config --cflags opencv`
LIBS = `pkg-config --libs opencv`

default: all

all: run_conv_graph run_graph

run_conv_graph: run_conv_graph.cpp 
	g++ -std=c++11 -L/usr/lib -o run_conv_graph run_conv_graph.cpp -ltensorflow $(CFLAGS) $(LIBS)

run_graph: run_graph.cpp
	g++ -std=c++11 -L/usr/lib -o run_graph run_graph.cpp -ltensorflow $(CFLAGS) $(LIBS)
