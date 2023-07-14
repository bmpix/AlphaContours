#include "computeAlpha.h"

bool findClosestIntersection(const Kernel::Segment_2& ab, const std::vector<MyPolyline>& myCurves, const std::vector<std::vector<Kernel::Segment_2>>& curveSegments, double& intersection)
{
	bool foundIntersection = false;
	double minIntersectionT = 1.0;
	for (int i = 0; i < myCurves.size(); ++i)
		for (int k = 1; k < myCurves[i].size(); ++k)
		{
			const auto& s = curveSegments[i][k - 1];

			//optimization
			const auto b1 = s.bbox(); const auto b2 = ab.bbox();
			if ((b1.xmax() < b2.xmin()) || (b2.xmax() < b1.xmin()) || (b1.ymax() < b2.ymin()) || (b2.ymax() < b1.ymin()))
				continue; //no intersection for sure

			auto result = CGAL::intersection(s, ab);
			if (result)
			{
				Kernel::Point_2* p = boost::get<Kernel::Point_2>(&*result);
				double intersectionT = sqrt(CGAL::to_double(CGAL::squared_distance(*p, ab.source()) / CGAL::squared_distance(ab.target(), ab.source())));
				if (intersectionT > 1e-7 && intersectionT < 1 - 1e-7)
				{
					minIntersectionT = std::min(intersectionT, minIntersectionT);
					foundIntersection = true;
				}
			}
		}

	if (foundIntersection)
		intersection = minIntersectionT;
	
	return foundIntersection;
}

double computeAlpha(const std::vector<MyPolyline>& myCurves, const std::vector<PointVec>& curves, const std::vector<std::vector<Kernel::Segment_2>>& curveSegments)
{
	//compute closest distance between samples -- that's the mininimum alpha we can take
	double maxSamplingDistSqr = std::numeric_limits<double>::min();
	for (int i=0; i<curves.size(); ++i)
		for (int j = 1; j < curves[i].size(); ++j)
		{
			double distSqr = CGAL::to_double((curves[i][j] - curves[i][j - 1]).squared_length());
			if (maxSamplingDistSqr < distSqr)
				maxSamplingDistSqr = distSqr;
		}

	const double maxSamplingDist = sqrt(maxSamplingDistSqr);
	std::cout << "Max sampling: " << maxSamplingDist << std::endl;

	//compute bbox diagonal -- that's the scale
	double xmin = std::numeric_limits<double>::max(), xmax = std::numeric_limits<double>::min();
	double ymin = xmin, ymax = xmax;
	for (int i = 0; i < curves.size(); ++i)
		for (int j = 0; j < curves[i].size(); ++j)
		{
			const auto& p = curves[i][j];
			double x = CGAL::to_double(p.x()), y = CGAL::to_double(p.y());
			xmin = std::min(x, xmin);
			xmax = std::max(x, xmax);
			ymin = std::min(y, ymin);
			ymax = std::max(y, ymax);
		}

	const double bboxDiag = sqrt(std::pow(xmax - xmin, 2.0) + std::pow(ymax - ymin, 2.0));
	std::cout << "Bbox diagonal: " << bboxDiag << std::endl;

	//compute average and median distance to the closest orthogonal intersection -- that's one statistic 
	const double maxIntersectionDist = 0.03 * bboxDiag;
	std::vector<std::vector<double>> orthoDistPerCurve(curves.size());

	#pragma omp parallel for
	for (int i = 0; i < curves.size(); ++i)
		for (int j = 0; j < curves[i].size(); ++j)
		{
			const auto& p = myCurves[i][j];
			Eigen::Vector2d tau = tangent(myCurves[i], j);
			Eigen::Vector2d n(tau.y(), -tau.x());
			n.normalize();
			Kernel::Segment_2 perpendicular(curves[i][j], curves[i][j] + _cgalv(n) * maxIntersectionDist);

			double intersectionT;
			if (findClosestIntersection(perpendicular, myCurves, curveSegments, intersectionT))
			{
				orthoDistPerCurve[i].push_back(intersectionT * maxIntersectionDist);
				//std::cout << "Pt : " << p << ", closestPt=" << curves[i][j] + _cgalv(n) * maxIntersectionDist * intersectionT << " dist = " << intersectionT * maxIntersectionDist << std::endl;
			}

			Kernel::Segment_2 minusPerpendicular(curves[i][j], curves[i][j] - _cgalv(n) * maxIntersectionDist);
			if (findClosestIntersection(minusPerpendicular, myCurves, curveSegments, intersectionT))
				orthoDistPerCurve[i].push_back(intersectionT * maxIntersectionDist);
		}

	std::vector<double> orthoDist;
	for (int i = 0; i < curves.size(); ++i)
		orthoDist.insert(orthoDist.end(), orthoDistPerCurve[i].begin(), orthoDistPerCurve[i].end());

	double avgOrthoDist = 0.0, medianOrthoDist = 0.0;
	if (!orthoDist.empty())
	{
		avgOrthoDist = avg(orthoDist, 0.0);
		medianOrthoDist = median(orthoDist);
	}
	std::cout << "Found " << orthoDist.size() << " orthogonal distances" << std::endl;

	std::cout << "Average orthogonal distance to the closest intersection: " << avgOrthoDist << std::endl;
	std::cout << "Median orthogonal distance to the closest intersection: " << medianOrthoDist << std::endl;

	//compute persistency

	return std::max(maxSamplingDist * 1.01, avgOrthoDist * 2);
}