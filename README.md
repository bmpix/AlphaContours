# AlphaContours
A reference implementation of the Alpha Contours algorithm.

Command line: 
```AlphaContours drawing.m [alpha]```

Drawing.m is a vector drawing in a vector format (see the examples folder).

Alpha is the radius; when not specified, it is computed automatically. 

The binary produces two files, all in Matlab format:
- drawing_segments.m -- the segments added to the drawing
- drawing_contours.m -- the Alpha Contours. This file contains three Matlab variables: 
  - cppContour, a cell array containing exterior contours
  - cppContourInner, a cell array containing interior contours
  - seedPts, an array containing an arbitrary point inside each interior contour.

These variables can then be fed into Triangle library to triangulate the interior of the sketch shape, if necessary.

# Dependencies
CGAL (tested with 5.5)

Eigen3 (tested with 3.4.0)

CMake

# Reference Binary
For the C++ part of the code, [here](http://www-labs.iro.umontreal.ca/~bmpix/AlphaContours/AlphaContoursBinary.zip) is the reference binary for Windows.
