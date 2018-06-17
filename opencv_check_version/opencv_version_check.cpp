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


#include <iostream>
#include <opencv2/opencv.hpp>

int main(int argc, char** argv) 
{
    std::cout << "Hello, Your OpenCV version is "<< CV_VERSION << std::endl;
    std::cout << "The major version is: " << CV_MAJOR_VERSION << std::endl;
    std::cout << "The minor version is: " << CV_MINOR_VERSION << std::endl;
    std::cout << "Subminor version : " << CV_SUBMINOR_VERSION << std::endl;
    return 0;
}
