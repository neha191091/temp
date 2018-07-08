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
using namespace std;

/*
 * 
 */

//const std::map<std::string, std::vector<float>> segColors = {
//        {"torso", {0.0, 255.0, 0.0}},
//        {"head", {0.0, 0.0, 255.0}}
//};

std::map<std::string, std::vector<float>> segColors = {
        {"torso", {0, 255, 0}},
        {"head", {0, 0, 255}},
        {"upper_left_arm", {255, 0, 0}},
        {"upper_right_arm", {100, 0, 0}},
        {"lower_left_arm", {255, 0, 255}},
        {"lower_right_arm", {100, 0, 100}},
        {"upper_left_leg", {255, 255, 0}},
        {"upper_right_leg", {100, 100, 0}},
        {"lower_left_leg", {0, 255, 255}},
        {"lower_right_leg", {0, 100, 100}}
};

int main(int argc, char** argv) 
{
    
    //Usage
    if (argc < 3) 
    {
        std::cerr << "Usage: " << argv[0] << " <source> <destination> <body_part>" << std::endl;
        return 1;
    }
    
    //Print source & destination
    
    char* inputFileName = argv[1];
    char* outputFileName = argv[2];
    std::string body_part= argv[3];
        
    //Read from the source file
    std::ifstream infile(inputFileName);
    if(!infile)
    {
        std::cout<<"File "<<inputFileName<<" not found!!!\n"<<endl;
        return -1;
    }
    
    std::string line;
    std::vector<std::vector<float>> matrix;
    char delimiter = ' ';
    int count = 0;
    while (std::getline(infile, line) && count<13)
    {
        count++;
    }
    while (std::getline(infile, line))
    {
        //parse into a matrix
        int pos = 0;
        char nextChar = line[0];
        float entry = 0;
        float shift = 10;
        float sign = 1;
        float multiplier = 1;
        std::vector<float> row;
        while(nextChar != '\0')
        {
            if(nextChar == delimiter)
            {
                row.push_back(entry);
                entry = 0;
                shift = 10;
                sign = 1;
                multiplier = 1;
            }
            else if(nextChar == '-')
            {
                sign = -1;
            }
            else if(nextChar == '.')
            {
                multiplier = 0.1;
                shift = 1;
            }
            else
            {
                entry = entry*shift + (float(nextChar)-48)*sign*multiplier;
                if(multiplier != 1)
                {
                    multiplier = multiplier/10;
                }                
            }
            nextChar = line[++pos];
        }
        row.push_back(entry);
        matrix.push_back(row);
    }
    
    //copy the original matrix
    std::vector<std::vector<float>> outmatrix;
    
    //Segment body part from a fully colored model
    for(int i=0; i<matrix.size(); i++)
    {
        for(int j=matrix[i].size()- 3; j<matrix[i].size(); j++)
        {
            if(matrix[i][j] < 50)
            {
                matrix[i][j] = 0;
            }
            else if((matrix[i][j] >= 50) && (matrix[i][j] < 177))
            {
                matrix[i][j] = 100;
            }
            else
            {
                matrix[i][j] = 255;
            }
        }
        
    }
    
    //Segment requisite part from a model with only the portion for the segment colored
    /*
    for(int i=0; i<matrix.size(); i++)
    {
        int j = matrix[i].size() -1;
        if(matrix[i][j] < 100)
        {
            matrix[i][j] = 0;
        }
        else
        {
            matrix[i][j] = 255;
        }
        
    }*/
    
    std::vector<float> avgvert = {0, 0, 0};
    int count_pts=0;
    
    //Record the needed segment and calculate the center of the matrix pixels
    if(body_part == "all")
    {
        outmatrix = matrix;
    }
    else
    {
        std::vector<float> value = segColors[body_part];
        
        std::cout<<"Body Part: "<<body_part.c_str()<<" : "<<value[0]<<","<<value[1]<<","<<value[2]<<std::endl;
        for(int i=0; i<matrix.size(); i++)
        {
            
            for(int j=matrix[i].size()- 3; j<matrix[i].size(); j++)
            {
                if(matrix[i][j] != value[j - matrix[i].size()+ 3])
                {
                    break;
                } 
                
                if(j == matrix[i].size()-1)
                {
                    for(int k=0; k<3; k++)
                    {
                        avgvert[k] += matrix[i][k];
                    }
                    std::cout<<matrix[i][matrix[i].size()-3]<<","<<matrix[i][matrix[i].size()-2]<<","<<matrix[i][matrix[i].size()-1]<<std::endl;
                    outmatrix.push_back(matrix[i]);
                    count_pts++;
                }
            }

        }
        for(int j=0; j<3; j++)
        {
            avgvert[j] /= outmatrix.size();
            std::cout<<"Centroid "<<j<<": "<<avgvert[j]<<std::endl;
        }
        
    }
    
    //Reset centroid to 0,0,0 ... Uncomment if you want centered body part
    avgvert = {0, 0, 0};
    
    
    //Write the result back    
    std::ofstream outfile(outputFileName);
    if(!outfile)
    {
        std::cout<<"File "<<outputFileName<<" not found and not created!!!\n"<<endl;
        return -1;
    }
    
    outfile << "ply" << std::endl;
    outfile << "format ascii 1.0" << std::endl;
    outfile << "element vertex " << outmatrix.size() << std::endl;
    outfile << "property float x" << std::endl;
    outfile << "property float y" << std::endl;
    outfile << "property float z" << std::endl;
    outfile << "property float nx" << std::endl;
    outfile << "property float ny" << std::endl;
    outfile << "property float nz" << std::endl;
    outfile << "property uchar red" << std::endl;
    outfile << "property uchar green" << std::endl;
    outfile << "property uchar blue" << std::endl;
    outfile << "end_header" << std::endl;
    
    for(int i=0; i<outmatrix.size(); i++)
    {
        outfile << outmatrix[i][0] - avgvert[0];
        for(int j=1; j<3; j++)
        {
            outfile << delimiter << outmatrix[i][j] - avgvert[j] ;
        }
        for(int j=3; j<outmatrix[i].size(); j++)
        {
            outfile << delimiter << outmatrix[i][j] ;
        }
        outfile<<endl;
    }
    
    
}

