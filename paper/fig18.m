clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename = 'Toucan';

%% Alpha Contours plot parameters
pointSize = 15;
edgeWidth = 1.5; 
edgeColor = [.8 .8 .8];
figureCount = 0;
shapeColor = '#8cb4f4';
contourColor = '#1c4f99';

% to change the sampling: in contour_cpp change setResamplingDistance(n), where now n=4, to n=2, n=8
[cppContour, cppContourInner, boundaryCurve, seedPts, radius, pgon] = contour_cpp(mesh_dir,filename,false);
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
holepts = seedPts;
[nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

for rad = [radius/2, radius*2]
    [cppContour, cppContourInner, boundaryCurve, seedPts, ~, pgon] = contour_cpp(mesh_dir,filename,false,rad);
    [contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
    holepts = seedPts;
    [nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);
end