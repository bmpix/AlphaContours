#include "typedefs.h"

Eigen::Vector2d _toEig(std::complex<double> c)
{
	return Eigen::Vector2d(c.real(), c.imag());
}

Box findBoundingBox(const MyPolyline& poly)
{
	Box result;
	for (int i = 0; i < poly.size(); ++i)
	{
		result.xMin = std::min(result.xMin, poly[i].x());
		result.xMax = std::max(result.xMax, poly[i].x());
		result.yMin = std::min(result.yMin, poly[i].y());
		result.yMax = std::max(result.yMax, poly[i].y());
	}
	return result;
}

void bitwiseOr(BoolMatrix& lhs, const BoolMatrix& rhs)
{
#pragma omp parallel for
	for (int i = 0; i < lhs.rows(); ++i)
		for (int j = 0; j < lhs.cols(); ++j)
			lhs(i, j) = lhs(i, j) || rhs(i, j);
}

Eigen::Vector2d tangent(const MyPolyline& poly, int i)
{
	Eigen::Vector2d result = (i == poly.size() - 1 ? poly[i] - poly[i - 1] : poly[i + 1] - poly[i]);
	return result;
}

Kernel::Point_2 _cgal(const Eigen::Vector2d& p)
{
	return Kernel::Point_2(p.x(), p.y());
}
Kernel::Vector_2 _cgalv(const Eigen::Vector2d& v)
{
	return Kernel::Vector_2(v.x(), v.y());
}
;



