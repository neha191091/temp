/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   main.cpp
 * Author: neha
 *
 * Created on July 13, 2017, 10:16 AM
 */

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <vector>
#include <map>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <tensorflow/core/public/session.h>
#include <tensorflow/core/platform/env.h>
#include <tensorflow/core/graph/default_device.h>

using namespace std;
tensorflow::Session* session;

/*
 * 
 */

//const std::map<std::string, std::vector<float>> segColors = {
//        {"torso", {0.0, 255.0, 0.0}},
//        {"head", {0.0, 0.0, 255.0}}
//};

/*
std::map<int, std::vector<uchar>> segColors = {
        {0, {0, 255, 0}},	//torso
        {1, {0, 0, 255}},	//head
        {2, {255, 0, 0}},	//upper_left_arm
        {3, {100, 0, 0}},	//upper_right_arm
        {4, {255, 0, 255}},	//lower_left_arm
        {5, {100, 0, 100}},	//lower_right_arm
        {6, {255, 255, 0}},	//upper_left_leg
        {7, {100, 100, 0}},	//upper_right_leg
        {8, {0, 255, 255}},	//lower_left_leg
        {9, {0, 100, 100}}	//lower_right_leg
};
*/

std::map<int, cv::Vec3b> segColors = {
	{0, cv::Vec3b(0, 0, 0)},       //void
        {1, cv::Vec3b(0, 255, 0)},       //torso
        {2, cv::Vec3b(0, 0, 255)},       //head
        {3, cv::Vec3b(255, 0, 0)},       //upper_left_arm
        {4, cv::Vec3b(100, 0, 0)},       //upper_right_arm
        {5, cv::Vec3b(255, 0, 255)},     //lower_left_arm
        {6, cv::Vec3b(100, 0, 100)},     //lower_right_arm
        {7, cv::Vec3b(255, 255, 0)},     //upper_left_leg
        {8, cv::Vec3b(100, 100, 0)},     //upper_right_leg
        {9, cv::Vec3b(0, 255, 255)},     //lower_left_leg
        {10, cv::Vec3b(0, 100, 100)}     //lower_right_leg
};

bool isFileExist(char const* filename)
{
    std::ifstream file_tmp(filename);
    if (!file_tmp.is_open())
    {
        return false;
    }
    file_tmp.close();
    return true;
}

int main(int argc, char** argv) 
{
    
    const std::string data_path = "../data/";
    //const std::string recording_name = "correct_focal_png";
    const std::string read_name = "real_data_tests";
    const std::string save_name = "real_data_tests";
    std::stringstream source_path;
    std::stringstream save_path;
    source_path << data_path << read_name << "/";
    save_path << data_path << save_name << "/";

    //****TEST
    cv::Mat bgrImage;
    bgrImage=cv::imread("sweet_peppers.jpg", CV_LOAD_IMAGE_UNCHANGED);
    	

    
    std::stringstream depth_file;
    const std::string depth_string =  "human_0_depth_";
    std::stringstream pred_file;
    const std::string pred_string =  "human_0_pred_";
    //depth_file << source_path.str() << "human_0_depth_0"<<"_0001"<< ".png";
    //color_file << source_path.str() << "human_0_rgb_0"<< ".png";
    
    //cv::namedWindow( "Display window", cv::WINDOW_AUTOSIZE );// Create a window for display.
    
    /// predicted color image of current frame
    //cv::Mat bgrImage;
    /// depth image of current frame
    cv::Mat depthImage;
    
    int count = 0;
    
    depth_file << source_path.str() << depth_string << count <<"_0001"<< ".png";
    pred_file << save_path.str() << pred_string << count << ".png";
    
    const string network = "../SaveFiles/Frozen_Graph.pb";

    tensorflow::SessionOptions opts;
    tensorflow::GPUOptions *gpu_opts = new tensorflow::GPUOptions();

    opts.config.set_allow_soft_placement(false); // Allow mixing CPU and GPU data
    gpu_opts->set_allow_growth(true);            // Don't hog the full GPU at once
    opts.config.set_allocated_gpu_options(gpu_opts);

    tensorflow::Status status = tensorflow::NewSession(opts, &session);
    if(!status.ok()) cerr << "Could not create new sessions: " << status.error_message() << endl;

    tensorflow::GraphDef graph_def;
    status = tensorflow::ReadBinaryProto(tensorflow::Env::Default(), network, &graph_def);
    if(!status.ok()) cerr << "Could not read Proto File: " << status.error_message() << endl;

    status = session->Create(graph_def);
    if(!status.ok()) cerr << "Could not create graph " << status.error_message() << endl;

    size_t batch_size = 1;
    
    while(isFileExist(depth_file.str().c_str()))
    {
        std::cout<<depth_file.str()<<std::endl;

        depthImage = cv::imread(depth_file.str().c_str(),-1);
        cv::resize(depthImage, depthImage, depthImage.size() / 4, 0, 0, cv::INTER_AREA);
        int width = depthImage.size().width;
        int height = depthImage.size().height;
        int depth = depthImage.channels();

        int bytes_per_sample_in = width * height * depth * sizeof(float);
        int bytes_per_sample_out = width * height * sizeof(int);

        // Build 4-dim Tensor for input and get Eigen mapping
        tensorflow::TensorShape shape({batch_size, height, width, depth});
        tensorflow::Tensor tensor(tensorflow::DT_FLOAT, shape);
        std::vector<pair<string, tensorflow::Tensor> > input({ {"depths",tensor} });
	
	depthImage.convertTo(depthImage, CV_32FC1);

        auto mapping_in = tensor.tensor<float, 4>();
	const float * source_data = (float*) depthImage.data;
  
  	// copying the data into the corresponding tensor
  	for (int y = 0; y < height; ++y) {
    		const float* source_row = source_data + (y * width * depth);
    		for (int x = 0; x < width; ++x) {
     	 		const float* source_pixel = source_row + (x * depth);
      			for (int c = 0; c < depth; ++c) {
  				const float* source_value = source_pixel + c;
				if(*source_value > 10000){
					mapping_in(0, y, x, c) = 10000;
				}
				else{
  					mapping_in(0, y, x, c) = *source_value;
				}
      			}
    		}
  	}
	//memcpy(&mapping_in(0,0,0,0), depthImage.data, bytes_per_sample_in);
	std::cout<<"depth map"<<depthImage<<std::endl;
	std::cout<<"input tensor debug string: "<<tensor.SummarizeValue(100)<<std::endl;

	std::vector< string > output( {"SegmentationNet/predictions"} );
        std::vector<tensorflow::Tensor> cae_out;

        tensorflow::Status status = session->Run(input, output, {}, &cae_out);
        if(!status.ok()) throw runtime_error("Could not run graph: " + status.error_message());
        std::cout<<"Ran Network"<<std::endl;
        tensorflow::TensorShape prediction_shape({height, width});
        tensorflow::Tensor prediction_tensor(tensorflow::DT_INT64, prediction_shape);
        if(!prediction_tensor.CopyFrom(cae_out[0], prediction_shape))
        {
                LOG(ERROR) << "Unsuccessfully reshaped image features tensor [" << cae_out[0].DebugString() << "] to [1, 196, 512]";
                return false;
        }
        std::cout<<"output tensor debug string: "<<prediction_tensor.SummarizeValue(100)<<std::endl;

        auto mapping_out = prediction_tensor.tensor<long long int,2>();
        //std::cout<<"mpping out debug string: "<<mapping_out.SummarizeValue(100)<<std::endl;
	std::cout<<"Mapping out defined from prediction"<<std::endl;
        //cv::Mat m(height, width, CV_16UC(3));
	cv::Mat rgbMatrix(height,width,CV_8UC3,cv::Scalar(0,0,0));
	std::cout<<"rgbMatrix rows: "<<rgbMatrix.rows<<" rgbMatrix cols: "<<rgbMatrix.cols<<std::endl;
	for (int i = 0; i < rgbMatrix.rows; i++)
  		for (int j = 0; j < rgbMatrix.cols; j++){
			int label = (int)mapping_out(i,j);
			if(mapping_in(0,i,j,0) >= 10000)
				label = 0;
			std::cout<<", "<<label;
    			cv::Vec3b rgb = segColors[label];
			//std::cout<<"("<<rgb[0]<<","<<rgb[1]<<","<<rgb[2]<<") ;";
      			rgbMatrix.at<cv::Vec3b>(i,j) = rgb;
		}
        //std::cout<<"matrix m defined\n"<<m<<std::endl;
        //memcpy(m.data, &mapping_out(0,0), bytes_per_sample_out);
        std::cout<<"Copy tensor to mat"<<std::endl;
	cv::resize(rgbMatrix, rgbMatrix, rgbMatrix.size() * 4, 0, 0, cv::INTER_NEAREST);
        cv::imwrite(pred_file.str().c_str(), rgbMatrix);
        //cv::imshow( "Display window", depthImage );                   // Show our image inside it.

        count++;
        depth_file.str("");
        depth_file << source_path.str() << depth_string << count <<"_0002"<< ".png";
        pred_file.str("");
        pred_file << save_path.str() << pred_string << count << ".png";
    }	
    
    /*
    tensorflow::Session* session;
    tensorflow::Status status = tensorflow::NewSession(tensorflow::SessionOptions(), &session);
    if (!status.ok()) {
        cout << status.ToString() << "\n";
        return 1;
    }
    */
    
    cout << "Session successfully created.\n";
    return 0;
}
