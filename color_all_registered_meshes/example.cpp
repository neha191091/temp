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

std::vector<int> myIntParser(std::string line, char delimiter1 = ' ', char delimiter2 = '\t')
{
	//Use this instead of myFloatParserOld
	std::vector<int> row;
	std::istringstream iss(line);
	std::string word;
	while (std::getline(iss, word, delimiter1))
	{
		std::istringstream iss_in(word);
		std::string word_in;
		while (std::getline(iss_in, word_in, delimiter2))
		{	
			int entry = atoi(word_in.c_str());
			row.push_back(entry);
		}
		int entry = atoi(word_in.c_str());
		row.push_back(entry);
	}

	//int entry = atoi(word.c_str());
	//row.push_back(entry);
	return row;
}

std::vector<float> myFloatParser(std::string line, char delimiter1 = ' ', char delimiter2 = '\t')
{
	//Use this instead of myFloatParserOld
	std::vector<float> row;
	std::istringstream iss(line);
	std::string word;
	while (std::getline(iss, word, delimiter1))
	{
		std::istringstream iss_in(word);
		std::string word_in;
		while (std::getline(iss_in, word_in, delimiter2))
		{	
			float entry = atof(word_in.c_str());
			row.push_back(entry);
		}
		//float entry = atof(word_in.c_str());
		//row.push_back(entry);
	}

	float entry = atof(word.c_str());
	row.push_back(entry);
	return row;
}

/*std::vector<float> myFloatParser(std::string line, char delimiter1 = '\t', char delimiter2 = '\0')
{
	//Use this instead of myFloatParserOld
	std::vector<float> row;
	std::istringstream iss(line);
	std::string word;
	while (std::getline(iss, word, delimiter1))
	{
		float entry = atof(word.c_str());
		row.push_back(entry);
	}

	float entry = atof(word.c_str());
	row.push_back(entry);
	return row;
}*/

std::vector<float> myFloatParserOld(std::string line, char delimiter)
{
	// DEPRECATED: DONOT USE
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
		else if(nextChar == 'e' && line[pos+1] == '-')
		{
		entry = 0;
		nextChar = line[++pos];
		while((nextChar != '\0') && (nextChar != delimiter))
		{
			nextChar = line[++pos];
		}
		continue;
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
	return row;
}

int main(int argc, char** argv) 
{
    const std::string data_path = "/media/neha/ubuntu/data/SCAPE/scapecomp/";
    //const std::string recording_name = "correct_focal_png";
    const std::string input_mesh = "mesh001_colored.ply";
    const std::string op_label = "mesh";
    std::stringstream ip_basemesh_path;
    std::stringstream ip_path;
    std::stringstream op_new_path;
    ip_basemesh_path << data_path << input_mesh;
    
    
    int count = 0;

    ip_path << data_path << op_label << std::setfill('0') << std::setw(3) << count <<".ply";
    op_new_path << data_path << op_label << std::setfill('0') << std::setw(3) << count <<"_op_color.ply";

    std::ifstream basefile(ip_basemesh_path.str().c_str());
    if(!basefile)
    {
        std::cout<<"File "<<ip_basemesh_path.str().c_str()<<" not found!!!\n"<<endl;
        return -1;
    }
    std::string line;
    std::vector<std::string> lines;
    int num_vertices = 0;
    std::string num_vert_label ="element vertex";
    std::string end_header ="end_header";
    do
    {
	std::getline(basefile, line);
        std::cout<<line<<std::endl;
	if (line.find(num_vert_label) != std::string::npos) 
	{
		num_vertices = atoi(line.substr(num_vert_label.length()).c_str());
	}
	lines.push_back(line);
    }
    while(line.find(end_header) == std::string::npos);
    std::cout<<"num vertices: "<<num_vertices<<std::endl;
    int count_vert=0;
    std::vector<std::vector<float> > colorbasematrix;
    char delimiter = ' ';
    while (std::getline(basefile, line) && count_vert < num_vertices)
    {
        std::vector<float> row = myFloatParser(line, delimiter);
        colorbasematrix.push_back(row);
		count_vert++;
    }
    while(isFileExist(ip_path.str().c_str()))
    {	
	std::ifstream infile(ip_path.str().c_str());
	if(!infile)
	{
		std::cout<<"File "<<ip_path.str().c_str()<<" not found!!!\n"<<endl;
		return -1;
	}	
	else
	{
		std::cout<<"File "<<ip_path.str().c_str()<<endl;
	}
	std::ofstream outfile(op_new_path.str().c_str());
	if(!outfile)
	{
		std::cout<<"File "<<op_new_path.str().c_str()<<" not found and not created!!!\n"<<endl;
		return -1;
	}
	int it=0;
	while(std::getline(infile, line) && (line.find(end_header) == std::string::npos))
	{
		std::cout<<line<<std::endl;
		it++;
	}
	std::cout<<"till end_header "<<it<<std::endl;
	it=0;
	while(it<lines.size())
	{
		outfile << lines[it] <<std::endl;
		it++;
	}
	int count_vert=0;
	std::cout<<count<<std::endl;
	while(std::getline(infile, line))
	{

		if(count_vert < num_vertices)
		{	
			std::vector<float> row = myFloatParser(line, delimiter);
			/*
			//TODO: Remove the following block - test only
			for(int j=0; j<3; j++)
			{
			    outfile << row[j] << delimiter  ;
			}	
			*/		
			
        	for(int j=0; j<3; j++)
			{
			    outfile << row[j] << delimiter;
			}
			for(int j=3; j<colorbasematrix[count_vert].size()-1; j++)
			{
			    outfile << colorbasematrix[count_vert][j] << delimiter;
			}
			outfile<<endl;		
		}
		else
		{
			std::vector<float> row = myFloatParser(line, '\t', delimiter);
			for(int j=0; j<4; j++)
			{
			    outfile << row[j] << delimiter;
			}
			outfile<<endl;
			//outfile<<line;		
		}
		count_vert++;
	}
	
	count++;
	ip_path.str("");
	op_new_path.str("");
	ip_path << data_path << op_label << std::setfill('0') << std::setw(3) << count <<".ply";
	op_new_path << data_path << op_label << std::setfill('0') << std::setw(3) << count <<"_op_color.ply";
    }	
    
    return 0;
}
