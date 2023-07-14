#ifndef _TYPEDEFS_H_
#define _TYPEDEFS_H_

#include <iostream>
#include <fstream>
#include <numeric>
#include <vector>
#include <array>
#include "Eigen/Core"
#include "Eigen/Dense"
#include <CGAL/Exact_predicates_exact_constructions_kernel.h>
#include <CGAL/Exact_predicates_inexact_constructions_kernel.h>
#include <CGAL/Arr_segment_traits_2.h>
#include <CGAL/Arr_polyline_traits_2.h>
#include <CGAL/Arrangement_2.h>
#include <CGAL/Arr_naive_point_location.h>
#include <CGAL/Arr_landmarks_point_location.h>
#include <CGAL/intersections.h>
#include <CGAL/Polygon_2_algorithms.h>
#include <CGAL/Polygon_2.h>
#include <CGAL/Segment_Delaunay_graph_2.h>
#include <CGAL/Segment_Delaunay_graph_filtered_traits_2.h>
#include <CGAL/Voronoi_diagram_2.h>
#include <CGAL/Segment_Delaunay_graph_adaptation_traits_2.h>
#include <CGAL/Segment_Delaunay_graph_filtered_traits_2.h>
#include <CGAL/Segment_Delaunay_graph_traits_2.h>
#include <CGAL/Segment_Delaunay_graph_adaptation_policies_2.h>
#include <CGAL/Intersections_2/Segment_2_Segment_2.h>
#include <CGAL/Polygon_with_holes_2.h>
#include <CGAL/Boolean_set_operations_2.h>

typedef std::vector<Eigen::Vector2d> MyPolyline;
typedef Eigen::Matrix<bool, Eigen::Dynamic, Eigen::Dynamic> BoolMatrix;

struct PointOnCurve
{
	int curve;
	double segmentIdx;
	Eigen::Vector2d p;
};

struct Box
{
	double xMin, xMax, yMin, yMax;
	Box() :xMin(std::numeric_limits<double>::max()), xMax(std::numeric_limits<double>::min()), yMin(std::numeric_limits<double>::max()), yMax(std::numeric_limits<double>::min())
	{}

	bool inside(const Eigen::Vector2d& p) const
	{
		return (p.x() > xMin) && (p.x() < xMax) && (p.y() < yMax) && (p.y() > yMin);
	}
	bool completelyOutside(const Eigen::Vector2d& p1, const Eigen::Vector2d& p2)
	{
		if ((p1.x() < xMin) && (p2.x() < xMin))
			return true;
		if ((p1.x() > xMax) && (p2.x() > xMax))
			return true;
		if ((p1.y() < yMin) && (p2.y() < yMin))
			return true;
		if ((p1.y() > yMax) && (p2.y() > yMax))
			return true;
		return false;
	}
};

Box findBoundingBox(const MyPolyline& poly);

Eigen::Vector2d _toEig(std::complex<double> c);
void bitwiseOr(BoolMatrix& lhs, const BoolMatrix& rhs);
Eigen::Vector2d tangent(const MyPolyline& poly, int i);

template <typename T>
T avg(const std::vector<T>& vec, T zero)
{
	T sum = zero;
	for (int i = 0; i < vec.size(); ++i)
		sum += vec[i];
	return sum / vec.size();
}


//copied from https://stackoverflow.com/questions/1719070/what-is-the-right-approach-when-using-stl-container-for-median-calculation, Alec Jacobson
// Could use pass by copy to avoid changing vector
template <typename T>
T median(std::vector<T> v)
{
	size_t n = v.size() / 2;
	std::nth_element(v.begin(), v.begin() + n, v.end());
	T vn = v[n];
	if (v.size() % 2 == 1)
	{
		return vn;
	}
	else
	{
		std::nth_element(v.begin(), v.begin() + n - 1, v.end());
		return 0.5 * (vn + v[n - 1]);
	}
}

typedef double                                             Number_type;
typedef CGAL::Exact_predicates_exact_constructions_kernel       Kernel;
typedef CGAL::Arr_segment_traits_2<Kernel>                Segment_traits;
typedef CGAL::Arr_polyline_traits_2<Segment_traits>       Traits;
typedef Traits::Point_2                               Point;
typedef Traits::Segment_2                                 Segment;
typedef Traits::Curve_2                                   Polyline;
typedef CGAL::Arrangement_2<Traits>                   Arrangement;

typedef CGAL::Exact_predicates_inexact_constructions_kernel       InexactKernel;
typedef typename Arrangement::Face_const_handle     Face_const_handle;
typedef CGAL::Segment_Delaunay_graph_filtered_traits_without_intersections_2<InexactKernel> Gt;
typedef CGAL::Segment_Delaunay_graph_2<Gt>  SDG2;
typedef CGAL::Polygon_2<InexactKernel> Polygon_2;
typedef CGAL::Polygon_with_holes_2<InexactKernel> Polygon_with_holes_2;

typedef std::vector<Point> PointVec;
struct PointAtIndex
{
	int intersectingCurve;
	double segmentIdx; //along my curve
	Kernel::Point_2 p;
};


Kernel::Point_2 _cgal(const Eigen::Vector2d& p);
Kernel::Vector_2 _cgalv(const Eigen::Vector2d& v);
#endif
