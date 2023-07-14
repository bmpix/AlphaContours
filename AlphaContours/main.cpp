#include "main.h"
#include "MatlabUtils.h"
#include "computeAlpha.h"
#include <ctime>

void printPoly(const Polygon_2& poly, std::string name)
{
	std::cout << name << " = [";
	for (const auto& p : poly)
	{
		std::cout << p.x() << ", -" << p.y() << "; ";
	}
	std::cout << "];" << std::endl;
}

bool ballContainsShortestPathBetweenPoints(double alpha, int i, double iPointIdx, int j, double jPointIdx, const std::vector<PointVec>& curves, const std::vector<std::vector<PointAtIndex>>& intersectionPts)
{
	auto isThisCurveSegmentInside = [&](int curveIdx, double segmentEnd1, double segmentEnd2)
	{
		int idxStart = std::ceil(std::min(segmentEnd1, segmentEnd2));
		int idxEnd = std::floor(std::max(segmentEnd1, segmentEnd2));
		bool outside = false;
		for (int k = idxStart; k <= idxEnd; ++k)
		{
			if (CGAL::squared_distance(curves[curveIdx][k], curves[i][iPointIdx]) > alpha * alpha)
			{
				outside = true;
				break;
			}
		}
		return !outside;
	};

	//check that the path between these points is entirely contained within an alpha-radius ball centered at (i,pointIdx)
	if (i == j)
	{
		return isThisCurveSegmentInside(i, iPointIdx, jPointIdx);
	}
	else
	{
		//check if there's an intersection point between these two curves inside the ball
		for (const auto& intPt : intersectionPts[i])
		{
			if ((intPt.intersectingCurve == j) && (CGAL::squared_distance(intPt.p, curves[i][iPointIdx]) < alpha * alpha))
			{
				//std::cout << "Found an intersection point at " << intPt.p << std::endl;
				//there is an intersection point between these curves
				//find the corresponding point on curve 
				bool foundCorrespondence = false;
				for (const auto& intPt2 : intersectionPts[j])
				{
					if (CGAL::squared_distance(intPt.p, intPt2.p) < 1e-10)
					{
						foundCorrespondence = true;
						return isThisCurveSegmentInside(i, iPointIdx, intPt.segmentIdx) && isThisCurveSegmentInside(j, jPointIdx, intPt2.segmentIdx);
					}
				}
				if (!foundCorrespondence)
				{
					std::cout << "BUG" << std::endl;
					return false;
				}
			}
		}
		return false;
	}
}

int main(int argc, char* argv[])
{
	clock_t beginTime = clock();
	std::string filename;
	double alpha;
	bool impreciseJunctions = false;
	if (argc < 2)
	{
		std::cout << "USAGE: alphacontours.exe filename.m [alpha] [-j]";
		std::cout << "-j: makes junctions imprecise. Might be better for functional maps, but the area becomes larger" << std::endl;
		return -1;
	}
	else 
	{
		filename = argv[1];
		if (argc > 2)
			alpha = std::atof(argv[2]);
		else
		{
			alpha = -1.0; //need to compute
		}

		if ((argc == 4) && (std::string(argv[3]) == std::string("-j")))
		{
			std::cout << "Imprecise junctions: ON" << std::endl;
			impreciseJunctions = true;
		}

		std::cout << "Loading " << filename << ", alpha = " << alpha << std::endl;
	}

	std::ifstream f(filename);
	if (!f.good() || !f.is_open())
	{
		std::cout << "File not found" << std::endl;
		return -1;
	}

	int nCurves = MatlabImport::loadScalarFromMatlab<int>(f);
	std::vector<MyPolyline> myCurves(nCurves);
	for (int i = 0; i < nCurves; ++i)
		myCurves[i] = MatlabImport::loadVectorFromMatlab<Eigen::Vector2d>(f);
	f.close();

	std::cout << "Loaded " << nCurves << " curves" << std::endl;

	//convert to cgal
	Traits traits;
	auto polyline_construct = traits.construct_curve_2_object();


	std::vector<PointVec> curves(nCurves);

	Arrangement arr;
	for (int i = 0; i < nCurves; ++i)
	{
		for (int j = 0; j < myCurves[i].size(); ++j)
			curves[i].push_back(Point(myCurves[i][j][0], myCurves[i][j][1]));
	}

	std::vector<std::vector<Kernel::Segment_2>> curveSegments(nCurves);
	for (int i = 0; i < nCurves; ++i)
		for (int k1 = 1; k1 < curves[i].size(); ++k1)
			curveSegments[i].push_back(Kernel::Segment_2(_cgal(myCurves[i][k1 - 1]), _cgal(myCurves[i][k1])));

	if (alpha < 0) //need to compute
	{
		alpha = computeAlpha(myCurves, curves, curveSegments);
		std::cout << "Computed an automatic alpha: " << alpha << std::endl;
	}


	//now compute interesections
	std::vector<std::vector<PointAtIndex>> intersectionPts(nCurves); //per curve

	for (int i = 0; i < nCurves; ++i)
		for (int j = 0; j < i; ++j)
		{
			for (int k1 = 1; k1 < curves[i].size(); ++k1)
			{
				const auto& s1 = curveSegments[i][k1 - 1];
				for (int k2 = 1; k2 < curves[j].size(); ++k2)
				{
					const auto& s2 = curveSegments[j][k2 - 1];

					//optimization
					const auto b1 = s1.bbox(); const auto b2 = s2.bbox();
					if ((b1.xmax() < b2.xmin()) || (b2.xmax() < b1.xmin()) || (b1.ymax() < b2.ymin()) || (b2.ymax() < b1.ymin()))
						continue; //no intersection for sure

					auto result = CGAL::intersection(s1, s2);
					if (result)
					{
						Kernel::Point_2* p = boost::get<Kernel::Point_2>(&*result);
						double sI = sqrt(CGAL::to_double(CGAL::squared_distance(*p, _cgal(myCurves[i][k1 - 1])) / CGAL::squared_distance(s1.target(), s1.source())));
						double sJ = sqrt(CGAL::to_double(CGAL::squared_distance(*p, _cgal(myCurves[j][k2 - 1])) / CGAL::squared_distance(s2.target(), s2.source())));
						double segmentIdxI = k1 - 1 + sI;
						double segmentIdxJ = k2 - 1 + sJ;

						if (sI < 1e-10 || sI>1 - 1e-10 || sJ < 1e-10 || sJ>1 - 1e-10)
							continue;

						PointAtIndex intPt1;
						intPt1.intersectingCurve = j;
						intPt1.p = *p;
						intPt1.segmentIdx = segmentIdxI;
						intersectionPts[i].push_back(intPt1);

						PointAtIndex intPt2;
						intPt2.intersectingCurve = i;
						intPt2.p = *p;
						intPt2.segmentIdx = segmentIdxJ;
						intersectionPts[j].push_back(intPt2);
					}
				}
			}
		}

	int count = 0;
	for (int i = 0; i < intersectionPts.size(); ++i)
	{
		/*std::cout << "Curve " << i << std::endl;
		for (int j = 0; j < intersectionPts[i].size(); ++j)
			std::cout << intersectionPts[i][j].p << " at " << intersectionPts[i][j].segmentIdx << std::endl*/
		count += intersectionPts[i].size();
	}

	std::cout << "Found " << count << " intersection points" << std::endl;

	for (int i = 0; i < nCurves; ++i)
	{
		std::sort(intersectionPts[i].begin(), intersectionPts[i].end(), [](const PointAtIndex& a, const PointAtIndex& b) {return a.segmentIdx < b.segmentIdx; });
		//insert intersection points
		for (int j = 0; j < intersectionPts[i].size(); ++j)
		{
			const auto& intPt = intersectionPts[i][j];
			curves[i].insert(curves[i].begin() + std::ceil(intPt.segmentIdx) + j, intPt.p);
		}
	}

	
	std::vector<std::vector<Segment>> segmentsPerCurve(nCurves);
	//find extra segments
	#pragma omp parallel for
	for (int i = 0; i < nCurves; ++i)
	{
		for (auto endPt : { (size_t)0, curves[i].size() - 1 })
		{
			Kernel::Vector_2 tangent;
			if (curves[i].size() < 2)
				continue;

			if (endPt == 0)
				tangent = curves[i][0] - curves[i][1];
			else
				tangent = curves[i].back() - curves[i][curves[i].size() - 2];


			//connect with all the points within alpha range
			typedef std::pair<Segment, double> SA; //segment and its angle
			std::vector<SA> segmentsToAdd;
			for (int j = 0; j < nCurves; ++j)
			{
				/*if (i == j)
					continue;*/

				for (int k = 0; k < curves[j].size(); ++k)
				{
					double sqLen = CGAL::to_double((curves[i][endPt] - curves[j][k]).squared_length());
					if ((sqLen < alpha * alpha) && (sqLen>1e-10))
					{
						Segment newSegment(curves[i][endPt], curves[j][k]);
						if (!impreciseJunctions && ballContainsShortestPathBetweenPoints(alpha, i, endPt, j, k, curves, intersectionPts))
						{
							continue; //not adding anything
						}

						//segments.push_back(newSegment);
						//continue;
						Kernel::Vector_2 sVec(newSegment);

						auto _to3d = [](const Kernel::Vector_2& v) {	return Kernel::Vector_3(v.x(), v.y(), 0.0);	};
						double angle = atan2(CGAL::to_double(CGAL::cross_product(_to3d(tangent), _to3d(sVec)).z()), CGAL::to_double(CGAL::scalar_product(tangent, sVec)));
						if (angle < 1e-10)
							angle += 2 * 3.14159265;
						segmentsToAdd.push_back({ newSegment,angle });
					}
				}
			}

			if (!segmentsToAdd.empty())
			{
				std::sort(segmentsToAdd.begin(), segmentsToAdd.end(), [](const SA& left, const SA& right) {return left.second < right.second; });
				size_t idxMinAngle = 0, idxMaxAngle = segmentsToAdd.size() - 1;
				auto does_intersect = [&curves](const Kernel::Segment_2& s)
				{
					typedef Kernel::Vector_2  Vector;
					Kernel::Segment_2 sShorter(s.source() + Vector(s) * 1e-10, s.target() - Vector(s) * 1e-10);
					for (int i = 0; i < curves.size(); ++i)
					{
						for (int k = 0; k + 1 < curves[i].size(); ++k)
						{
							if (CGAL::intersection(Kernel::Segment_2(curves[i][k], curves[i][k + 1]), sShorter))
								return true;
						}
						//if (CGAL::intersection(curves[i],sShorter))
						//	return true;
					}
					return false;
				};

				while (idxMinAngle < segmentsToAdd.size())
				{
					if (!does_intersect(segmentsToAdd[idxMinAngle].first))
					{
						segmentsPerCurve[i].push_back(segmentsToAdd[idxMinAngle].first);
						break;
					}
					idxMinAngle++;
				}
				while (idxMaxAngle > idxMinAngle)
				{
					if (!does_intersect(segmentsToAdd[idxMaxAngle].first))
					{
						segmentsPerCurve[i].push_back(segmentsToAdd[idxMaxAngle].first);
						break;
					}
					idxMaxAngle--;
				}
			}
		}
	}

	std::vector<Segment> segments;
	for (int i = 0; i < nCurves; ++i)
	{
		segments.insert(segments.end(), segmentsPerCurve[i].begin(), segmentsPerCurve[i].end());
	}

	std::string filenameSegments = filename;
	filenameSegments.erase(filenameSegments.begin() + filenameSegments.length() - 2, filenameSegments.end());
	filenameSegments += "_segments.m";
	std::ofstream fSegments(filenameSegments);
	fSegments << "segmentsStart = [";
	for (const auto& s : segments)
	{
		fSegments << s.source().x() << ", " << s.source().y() << "; ";
	}
	fSegments << "];" << std::endl;
	fSegments << "segmentsEnd = [";
	for (const auto& s : segments)
	{
		fSegments << s.target().x() << ", " << s.target().y() << "; ";
	}
	fSegments << "];" << std::endl;
	fSegments.close();


	for (int i = 0; i < nCurves; ++i)
	{
		for (int j = 1; j < curves[i].size(); ++j)
			segments.push_back(Segment(curves[i][j - 1], curves[i][j]));
	}

	CGAL::insert(arr, segments.begin(), segments.end());
	std::cout << "Added " << segments.size() << " segments" << std::endl;

	std::string filenameOut = filename;
	filenameOut.erase(filenameOut.begin() + filenameOut.length() - 2, filenameOut.end());
	filenameOut += "_contours.m";

	std::ofstream fOut(filenameOut);
	fOut << std::setprecision(std::numeric_limits<double>::digits10 + 1);
	fOut << "radius = " << alpha << ";" << std::endl;
	auto face = arr.unbounded_face();
	int idxOuter = 1;
	for (auto it = face->inner_ccbs_begin(); it != face->inner_ccbs_end(); ++it)
	{
		fOut << "cppContour{" << idxOuter << "} = [";
		auto curr = *it;
		fOut << curr->source()->point() << "; ";
		do fOut << curr->target()->point() << ";";
		while (++curr != *it);
		fOut << "];" << std::endl;
		idxOuter++;
	}



	auto _inexact = [](const Point& p)
	{
		return InexactKernel::Point_2(CGAL::to_double(p.x()), CGAL::to_double(p.y()));
	};

	auto _exact = [](const InexactKernel::Point_2& p)
	{
		return Point(p.x(), p.y());
	};

	typedef CGAL::Arr_landmarks_point_location<Arrangement> Smarter_pl;
	Smarter_pl pl(arr);
	std::vector<Point> seedPts;
	//now find all the seed points

	for (auto fit = arr.faces_begin(); fit != arr.faces_end(); ++fit)
	{
		if (fit->is_unbounded())
			continue;

		
		Polygon_2 outerPoly;
		std::vector<Polygon_2> holes;

		std::vector<InexactKernel::Point_2> polyPts;
		std::vector<std::pair<size_t, size_t>> indices; //segment vertex indices
		
		for (size_t boundaryType: { 0,1 }) //outer, inner
		{
			auto begin = fit->outer_ccbs_begin();
			auto end = fit->outer_ccbs_end();

			if (boundaryType == 1)
			{
				begin = fit->inner_ccbs_begin();
				end = fit->inner_ccbs_end();
			}

			
			for (auto it = begin; it != end; ++it)
			{
				auto curr = *it;

				std::vector<InexactKernel::Point_2> boundaryVerts;
				size_t firstIdx = polyPts.size();
				do
				{
					polyPts.push_back(_inexact(curr->target()->point()));
					boundaryVerts.push_back(_inexact(curr->target()->point()));
				} while (++curr != *it);

				if (!boundaryVerts.empty())
				{
					if (boundaryType == 0) //we're looking at the outer boundary, there's normally only one
						outerPoly = Polygon_2(boundaryVerts.begin(), boundaryVerts.end());
					else
						holes.push_back(Polygon_2(boundaryVerts.begin(), boundaryVerts.end()));
				}

				for (int i = 0; i < boundaryVerts.size(); ++i)
				{
					indices.push_back({ polyPts.size() - boundaryVerts.size() + i,polyPts.size() - boundaryVerts.size() + (i + 1) % boundaryVerts.size() });
				}
			}
		}

		Polygon_with_holes_2 polytmp(outerPoly, holes.begin(), holes.end());
		InexactKernel::FT area;
		CGAL::area_2(polytmp.outer_boundary().begin(), polytmp.outer_boundary().end(), area);
		for (const auto& hole : polytmp.holes())
		{
			decltype(area) tmpArea;
			CGAL::area_2(hole.begin(), hole.end(), tmpArea);
			area -= tmpArea;
		}
		if (area < alpha * alpha * 3.14)
			continue;

		SDG2 sdg;
		typedef CGAL::Segment_Delaunay_graph_degeneracy_removal_policy_2<SDG2> AP;
		typedef CGAL::Segment_Delaunay_graph_adaptation_traits_2<SDG2> AT;
		typedef CGAL::Voronoi_diagram_2<SDG2, AT, AP> VD;
		VD vd;

		sdg.insert_segments(polyPts.begin(), polyPts.end(), indices.begin(), indices.end());
		vd.insert(sdg.input_sites_begin(), sdg.input_sites_end());

		double maxSqrDist = alpha * alpha; //euclidean distance to the boundary of the polygon
		Point furthestPoint;

		for (auto vit = vd.vertices_begin(); vit != vd.vertices_end(); ++vit)
		{
			//known bug: sometimes this crashes :(
			if (/*!vit->is_valid() || */std::isnan(vit->point().x())) //i don't know why this happens
				continue;

			auto obj = pl.locate(_exact(vit->point()));
			const Face_const_handle* f = boost::get<Face_const_handle>(&obj);
			auto fff = *fit;
			if (f == nullptr || *f != Face_const_handle(fit))
				continue; //point is outside

			//auto os = CGAL::oriented_side(vit->point(), polytmp);
			//if (os != CGAL::POSITIVE)
			//	continue;

			double sqrDist = std::numeric_limits<double>::max();

			//todo: fix this, you can get distance immediately. sqrDist is almost always equal to cheapMinSqrDist, except for a few corner cases

			double cheapMinSqrDist = std::numeric_limits<double>::max();
			for (int j = 0; j < 3; ++j)
			{
				const auto& v = vit->dual()->vertex(j)->site();
				if (v.is_point())
					cheapMinSqrDist = std::min(CGAL::squared_distance(v.point(), vit->point()), cheapMinSqrDist);
				else
					cheapMinSqrDist = std::min(std::min(CGAL::squared_distance(v.segment().vertex(0), vit->point()), cheapMinSqrDist), CGAL::squared_distance(v.segment().vertex(1), vit->point()));

			}

			sqrDist = cheapMinSqrDist;

			for (const auto& p : polyPts)
			{
				if (sqrDist < maxSqrDist) //it only will get smaller, we're finding the minimum
					break;

				double tmpDist = CGAL::squared_distance(p, vit->point());

				if (tmpDist < sqrDist)
					sqrDist = tmpDist;
			}



			if (sqrDist > maxSqrDist)
			{
				maxSqrDist = sqrDist;
				furthestPoint = _exact(vit->point());
			}
		}

		//std::cout << "Consdering point " << furthestPoint << std::endl;
		if (maxSqrDist > alpha * alpha)
		{
			std::cout << "Found a cell with center at " << furthestPoint << ", distSqr = " << maxSqrDist << std::endl;
			seedPts.push_back(furthestPoint);
		}
	}

	clock_t endTime = clock();
	double elapsed_secs = double(endTime - beginTime) / CLOCKS_PER_SEC;
	std::cout << "Time elapsed: " << elapsed_secs << " sec" << std::endl;

	int idxInner = 1;
	for (const auto& p : seedPts)
	{
		auto obj = pl.locate(p);

		const Face_const_handle* f = boost::get<Face_const_handle>(&obj);
		if (f != nullptr)
		{
			for (auto it = (*f)->outer_ccbs_begin(); it != (*f)->outer_ccbs_end(); ++it)
			{
				fOut << "cppContourInner{" << idxInner << "} = [";
				auto curr = *it;
				fOut << curr->source()->point() << "; ";
				do fOut << curr->target()->point() << ";";
				while (++curr != *it);
				fOut << "];" << std::endl;
				idxInner++;
			}
			for (auto it = (*f)->inner_ccbs_begin(); it != (*f)->inner_ccbs_end(); ++it)
			{
				fOut << "cppContour{" << idxOuter << "} = [";
				auto curr = *it;
				fOut << curr->source()->point() << "; ";
				do fOut << curr->target()->point() << ";";
				while (++curr != *it);
				fOut << "];" << std::endl;
				idxOuter++;
			}
		}
		else
		{
			std::cout << "Cannot locate point " << p << std::endl;
		}
	}

	fOut << "seedPts = [";
	for (const auto& p : seedPts)
	{
		fOut << std::fixed << p.x() << ", " << p.y() << "; ";
	}
	fOut << "];" << std::endl;
	fOut.close();
	std::cout << "Done" << std::endl;
	return 0;
}