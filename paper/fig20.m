clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

%paper inputs, in the order they appear
%filename = 'Snail_more_pts';
filename = "turtle_more_pts";

%% Alpha Contours plot parameters
pointSize = 15;
edgeWidth = 1.5; 
edgeColor = [.8 .8 .8];
figureCount = 0;
shapeColor = '#8cb4f4';
contourColor = '#1c4f99';

%% cpp algorithm
% find contours
[cppContour, cppContourInner, boundaryCurve, seedPts, radius, pgon] = contour_cpp(mesh_dir,filename,false);

% if there are no inner contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

%% pull overlapping contours in respective normal directions
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
holepts = seedPts;

%% find triangulation
[nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

%% compute Laplacian
%[L,M,nodes,triangles,allEdges,edgeToTriangle] = findLaplacian(nodes,triangles,boundaryCurve);

%% find heat flow on sketch stokes
%findHeatFlow(L,M,nodes,triangles,edgeToTriangle,edgeWidth,filename);

%% find heat flow for point cloud
%heatFlowPointCloud(filename);

%% find heat flow on a raster image
heat_flow_raster(filename);