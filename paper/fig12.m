clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename = 'Dragon4';

%% Alpha Contours plot parameters
pointSize = 15;
edgeWidth = 1.5; 
edgeColor = [.8 .8 .8];
figureCount = 0;
shapeColor = '#8cb4f4';
contourColor = '#1c4f99';

%% cpp algorithm
%find contours
[cppContour, cppContourInner, boundaryCurve, seedPts, radius, pgon] = contour_cpp(mesh_dir,filename,false);

%if there are no inner contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

if strcmp(filename,'Dragon4') %for Dragon, we only use the exterior contour
    cppContourInner = {};
    seedPts = [];
end

contours = [cppContour, cppContourInner];

%% pull overlapping contours in respective normal directions
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
holepts = seedPts;

%% Display Steklov eigenfunctions on contours
%close all;
SteklovTest;

%% find triangulation
[nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

%% compute Laplacian
[L,~,nodes,~,~,edgeToTriangle] = findLaplacian(nodes,triangles,boundaryCurve);

%% visualize Laplacian eigs
findLaplaceBasis(nodes,L,edgeToTriangle,edgeWidth,filename);
