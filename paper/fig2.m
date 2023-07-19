clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename = 'Flower_fig4';

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
holepts = seedPts;

%% if there are no interior contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

%% exterior and interior contours
contours = [cppContour, cppContourInner];

%% pull overlapping contours in respective normal directions
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);

%% find triangulation
[nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

%% as an option for dispalying the sketch shape, plot polyshape bounded by Alpha contours
% f_poly = figure('units','normalized','outerposition',[0 0 1 1]);
% count = 1;
% for i=1:numel(contours)
%     polyX{count} = contours{i}(:,1);
%     polyY{count} = -contours{i}(:,2);
%     plot(contours{i}(:,1),-contours{i}(:,2),'LineWidth',edgeWidth,'Color',shapeColor);
%     count = count + 1;
% end
% pgon = polyshape(polyX,polyY);
% plot(pgon)
% axis equal; axis off;
% exportgraphics(f_poly, strcat('./output/',filename,'_2D_shape.pdf'), 'ContentType','vector');