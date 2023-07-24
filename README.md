This is a reference implementation of the 'Differential Operators on Sketches via Alpha Contours' by Mariia Myronova, William Neveu, and Mikhail Bessmeltsev, ACM Transactions on Graphics (SIGGRAPH 2023).

Structure of the repository:

```
AlphaContours/ -- C++ code of the main algorithm
SGP21_discreteOptimization-main/ -- a few files from https://github.com/llorz/SGP21_discreteOptimization with a minor change in their energy
algoB/ -- python code to compare with StrokeAggregator
paper/ -- Matlab scripts to reproduce figures in the paper
svg_to_matlab/ -- a Windows binary to convert .svg -> .m
```

# Main algorithm
Command line: 
```AlphaContours drawing.m [alpha]```

Drawing.m is a vector drawing in a vector format (see the inputs folder). You can convert your own svg to .m using the binary in the 'svg_to_matlab' folder.

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

# Building
We have only tried building under Windows, but the binary can be succefully run with wine under Mac. To build the C++ code
```cd AlphaContours
mkdir build
cd build
cmake ../
```

Then build the visual studio project as usual. Then move the binary, together with mpfr-6.dll and gmp-10.dll into AlphaContours/bin.

# Reference Binary
If you don't want to compile anything, [here](http://www-labs.iro.umontreal.ca/~bmpix/AlphaContours/AlphaContoursBinary.zip) is the reference binary for Windows.