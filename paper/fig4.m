clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename = 'Letter_A';

%% Alpha Contours plot parameters
pointSize = 15;
edgeWidth = 1.5; 
edgeColor = [.8 .8 .8];
figureCount = 0;
shapeColor = '#8cb4f4';
contourColor = '#1c4f99';
pointColor = 'yellow'; %the color used in the paper is '#919bb1'

%% cpp algorithm to find the Alpha Contours
%for Fig.4(e,f), we resample the point cloud by setting setResampleDistance(8) in contour_cpp
[cppContour, cppContourInner, boundaryCurve, seedPts, radius, pgon] = contour_cpp(mesh_dir,filename,false);

%% if there are no interior contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

%% exterior and interior contours
contours = [cppContour, cppContourInner];

%% pull overlapping contours in respective normal directions
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
holepts = seedPts;

%% find triangulation (Fig.4g)
[nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

%compute Laplacian
[L,M,nodes,triangles,allEdges,edgeToTriangle] = findLaplacian(nodes,triangles,boundaryCurve);

%% change shape and color for displaying Alpha shapes
shapeColor = '#72d6b9';
contourColor = '#016d6a';

%% display all curve points
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
scatter(nodes(:,1),-nodes(:,2), 35, 'o', 'fill', pointColor, 'MarkerEdgeColor', 'black', 'LineWidth', edgeWidth);
hold off; axis equal; axis off;
%exportgraphics(f1, strcat('./output/',filename,'_point_cloud.pdf'), 'ContentType','vector');

%% find Alpha shape
alpha = radius; %for Fig.4(c), where radius = 4.730351370021024 (automatically computed)
%alpha = 0.6*radius; %for Fig.4d
%alpha = radius; %for Fig.4f (the same as for Fig.4c), but now the sampling distance has doubled, so in contour_cpp use setResampleDistance(8);
shp = alphaShape(nodes(:,1),-nodes(:,2),alpha);
bf = boundaryFacets(shp); %bounding facets
T1 = alphaTriangulation(shp); %connectivity list

f2 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
plot(shp, 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
for i = 1:size(bf,1)
    plot([nodes(bf(i,1),1),nodes(bf(i,2),1)],[-nodes(bf(i,1),2),-nodes(bf(i,2),2)], 'LineWidth', edgeWidth, 'Color', contourColor);
end
% uncomment these lines to display the sketch curves: 
% for j = 1:numel(boundaryCurve)
%     plot(boundaryCurve{j}(:,1),-boundaryCurve{j}(:,2),'LineWidth',edgeWidth,'Color','black');
% end
hold off; axis equal; axis off;
%exportgraphics(f2, strcat('./output/',filename,'_point_cloud_alpha_shape.pdf'), 'ContentType','vector');