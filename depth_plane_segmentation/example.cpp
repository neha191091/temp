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
#include <opencv2/rgbd.hpp>
#include <opencv2/calib3d.hpp>

using namespace std;

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

cv::rgbd::RgbdPlane plane_computer;

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
    const std::string read_name = "depthImageSumit";
    const std::string save_name = "depthImageSumit";
    std::stringstream source_path;
    std::stringstream save_path;
    source_path << data_path << read_name << "/";
    save_path << data_path << save_name << "/";


    //Get camera parameters
    std::ifstream file_stream;
    const std::string seq_path = source_path.str() + "seq_cparam.txt";
    file_stream.open(seq_path.c_str());
    if (!file_stream.is_open()){
        std::cout<<"Not Found";
	throw;
    }
    else
	std::cout<<"Found\n";

    int image_width, image_height;
    float fovX, fovY;
    float cX, cY;
    std::ifstream cam_params_stream;
    cam_params_stream.open(seq_path.c_str());
    cam_params_stream >> image_width >> image_height;
    cam_params_stream >> fovX >> fovY;
    cam_params_stream >> cX >> cY;
    cam_params_stream.close();

    
    std::stringstream depth_file;
    const std::string depth_string =  "human_0_depth_";
    std::stringstream dep_mod_file;
    const std::string dep_mod_string =  "human_0_depth_mod_";
    std::stringstream color_file;
    const std::string color_string =  "human_0_rgb_";
    std::stringstream color_mod_file;
    const std::string color_mod_string =  "human_0_rgb_mod_";
    //depth_file << source_path.str() << "human_0_depth_0"<<"_0001"<< ".png";
    //color_file << source_path.str() << "human_0_rgb_0"<< ".png";
    
    //cv::namedWindow( "Display window", cv::WINDOW_AUTOSIZE );// Create a window for display.
    
    /// depth image of current frame
    cv::Mat depthImage;
    /// color image of current frame
    cv::Mat bgrImage;
    
    int count = 0;
    
    depth_file << source_path.str() << depth_string << count <<"_0001"<< ".png";
    dep_mod_file << save_path.str() << dep_mod_string << count << ".png";
    color_file << source_path.str() << color_string << count <<".png";
    color_mod_file << save_path.str() << color_mod_string << count << ".png";

    while(isFileExist(depth_file.str().c_str()))
    {
        std::cout<<depth_file.str()<<std::endl;

        depthImage = cv::imread(depth_file.str().c_str(),-1);
	bgrImage = cv::imread(depth_file.str().c_str(),1);

	//depthImage.convertTo(depthImage, CV_32FC1);

	cv::Mat_<unsigned char> plane_mask;
	std::vector<cv::Vec4f> plane_coefficients;
	cv::Mat_ < cv::Vec3f > outp(image_height, image_width);
	std::cout<<"image_height"<<image_height<<std::endl;
	std::cout<<"depth_height"<<depthImage.rows<<std::endl;
	std::cout<<"image_width"<<image_width<<std::endl;
	std::cout<<"depth_width"<<depthImage.cols<<std::endl;
  
  	// copying the data into the corresponding tensor
  	for (int y = 0; y < depthImage.rows; y++)
        {
            for (int x = 0; x < depthImage.cols; x++)
            {
                const float d = depthImage.at<unsigned short>(y, x);
		outp(y, x) = cv::Vec3f((x - cX) / fovX * d, (y - cY) / fovY * d, d);
                
                /*if (d > 1100 || d == 0){
                    
                    //std::cout<<"Init depth: "<<colorImg.at<float>(y, x)<<std::endl;
                    depthImage.at<unsigned short>(y, x) = 10000; 
                    //std::cout<<"Changed depth: "<<colorImg.at<float>(y, x)<<std::endl;
                }
                else
                {
                    depthImage.at<unsigned short>(y, x) = d;
                }*/

                //TODO: change clipping val
                //nearThresh = 400;
                //farThresh  = 10000;

            }
        }

	
	plane_computer(outp, plane_mask, plane_coefficients);
	std::cout<<"plane_mask size"<<plane_mask.size()<<std::endl;
	int count_non_plane = 0;

	for (int y = 0; y < plane_mask.rows; y++)
        {
            for (int x = 0; x < plane_mask.cols; x++)
            {
                const float p = plane_mask.at<unsigned short>(y, x);
                
                if (p!=255){
                    
                    //std::cout<<"Init depth: "<<colorImg.at<float>(y, x)<<std::endl;
                    depthImage.at<unsigned short>(y, x) = 10000; 
		    bgrImage.at<cv::Vec3b>(y, x) = cv::Vec3b(p, 0, 0);
                    //std::cout<<"Changed depth: "<<colorImg.at<float>(y, x)<<std::endl;
                }
		else
		{
		  count_non_plane++;
		}

                //TODO: change clipping val
                //nearThresh = 400;
                //farThresh  = 10000;

            }
        }
	std::cout<<"Non plane cnt: "<<count_non_plane<<std::endl;

	cv::imwrite(dep_mod_file.str().c_str(), depthImage);
	cv::imwrite(color_mod_file.str().c_str(), bgrImage);
        //cv::imshow( "Display window", depthImage );                   // Show our image inside it.

        count++;
        depth_file.str("");
        depth_file << source_path.str() << depth_string << count <<"_0001"<< ".png";
        dep_mod_file.str("");
        dep_mod_file << save_path.str() << dep_mod_string << count << ".png";
	color_file.str("");
	color_file << source_path.str() << color_string << count <<".png";
	color_mod_file.str("");
    	color_mod_file << save_path.str() << color_mod_string << count << ".png";
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
