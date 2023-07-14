#pragma once
#include <Eigen/Sparse>
#include <fstream>

namespace MatlabImport {
	typedef std::pair<int, int> Edge;
	typedef std::vector<Edge> EdgeList;
	typedef std::array<double, 2> Vector;
	void readElement(std::ifstream& f, double& el);
	void readElement(std::ifstream& f, int& el);
	void readElement(std::ifstream& f, std::pair<int, int>& el);
	void readElement(std::ifstream& f, std::array<double, 2>& el);
	template <typename T, size_t Size>
	void readElement(std::ifstream& f, Eigen::Vector<T, Size>& el)
	{
		for (size_t i = 0; i < Size; ++i)
			f >> el[i];
	}

	template <typename T>
	std::vector<T> loadVectorFromMatlab(std::ifstream& f)
	{
		std::string line;
		while (line == "")
			std::getline(f, line); //read off the variable name and ignore it
		int size = 0;
		f >> size;
		std::vector<T> result(size);
		for (int i = 0; i < size; ++i)
		{
			readElement(f, result[i]);
		}
		return result;
	}

	template <typename T> 
	T loadScalarFromMatlab(std::ifstream& f)
	{
		std::string line;
		while (line == "")
			std::getline(f, line); //read off the variable name and ignore it
		T result;
		f >> result;
		return result;
	}
}