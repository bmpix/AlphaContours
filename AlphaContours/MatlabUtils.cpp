#include <Eigen/Sparse>
#include <fstream>

namespace MatlabImport {

	void readElement(std::ifstream& f, double& el)
	{
		f >> el;
	}

	void readElement(std::ifstream& f, int& el)
	{
		f >> el;
	}

	void readElement(std::ifstream& f, std::pair<int, int>& el)
	{
		f >> el.first >> el.second;
	}

	void readElement(std::ifstream& f, std::array<double, 2>& el)
	{
		f >> el[0] >> el[1];
	}

	//void loadMatlabStufffForNonlinearOptimization(std::string frame_field_file, Eigen::VectorXd& phi, Eigen::VectorXd& d_theta1, Eigen::VectorXd& theta2, double& wA, double& wB, double& wS, double& antialign, SpMat& ddtheta2_dtheta2, SpMat& dtheta1_ddtheta1,
	//	SpMat& ddtheta2_ddtheta1, std::vector<std::pair<int, int>>& edges_bfs, std::vector<int>& roots_bfs, std::vector<int>& pixelind_bfs, std::vector<int>& ind_of_zero_gradients_BFS, EdgeList& Tree,
	//	EdgeList& dualEdgeInd, EdgeList& alledges_bfs, std::vector<int>& myBFSorder, EdgeList& G, std::vector<double>& g_theta_BFS, std::vector<int>& PixelIndex, SpMat& finalA, Eigen::VectorXd& finalb)
	//{
	//	//order of variables in the file: phi, d_theta1, theta2, wA, wB, wS, ddtheta2_dtheta2, dtheta1_ddtheta1,ddtheta2_ddtheta1, edges_bfs
	//	//roots_bfs, pixelind_bfs, ind_of_zero_gradients_BFS, Tree, dualedgeInd, alledges_bfs, narrowBand, myBFSorder, G, g_theta_BFS

	//	auto _toEig = [](const std::vector<double>& vec)
	//	{
	//		Eigen::VectorXd vecEigen(vec.size());
	//		for (int i = 0; i < vec.size(); ++i)
	//			vecEigen[i] = vec[i];
	//		return vecEigen;
	//	};


	//	std::ifstream f(frame_field_file);
	//	if (!f.good())
	//	{
	//		std::cout << "ERROR: frame field file not found" << std::endl;
	//		return;
	//	}

	//	using namespace std::complex_literals;


	//	phi = _toEig(loadVectorFromMatlab<double>(f));
	//	d_theta1 = _toEig(loadVectorFromMatlab<double>(f));
	//	theta2 = _toEig(loadVectorFromMatlab<double>(f));
	//	wA = loadScalarFromMatlab(f);
	//	wB = loadScalarFromMatlab(f);
	//	wS = loadScalarFromMatlab(f);
	//	antialign = loadScalarFromMatlab(f);
	//	loadSparseMatrixFromMatlab(f, ddtheta2_dtheta2);
	//	loadSparseMatrixFromMatlab(f, dtheta1_ddtheta1);
	//	loadSparseMatrixFromMatlab(f, ddtheta2_ddtheta1);
	//	edges_bfs = loadVectorFromMatlab<Edge>(f);
	//	roots_bfs = loadVectorFromMatlab<int>(f);
	//	pixelind_bfs = loadVectorFromMatlab<int>(f);
	//	ind_of_zero_gradients_BFS = loadVectorFromMatlab<int>(f);
	//	Tree = loadVectorFromMatlab<Edge>(f);
	//	dualEdgeInd = loadVectorFromMatlab<Edge>(f);
	//	alledges_bfs = loadVectorFromMatlab<Edge>(f);
	//	myBFSorder = loadVectorFromMatlab<int>(f);
	//	G = loadVectorFromMatlab<Edge>(f);
	//	PixelIndex = loadVectorFromMatlab<int>(f);
	//	g_theta_BFS = loadVectorFromMatlab<double>(f);
	//	loadSparseMatrixFromMatlab(f, finalA);
	//	finalb = _toEig(loadVectorFromMatlab<double>(f));
	//}

	
}