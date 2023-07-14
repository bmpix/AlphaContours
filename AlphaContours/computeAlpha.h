#pragma once
#include "typedefs.h"
double computeAlpha(const std::vector<MyPolyline>& myCurves, const std::vector<PointVec>& curves, const std::vector<std::vector<Kernel::Segment_2>>& curveSegments); //those are the same sets of curves, different formats for (my) convenience