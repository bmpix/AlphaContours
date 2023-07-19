clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename = "Witch_08";
%filename = 'Art_freeform_DR_05_norm_full'; %girl with blanket
%filename = 'Art_freeform_PB_09_norm_full'; %boy with dog

%inputs from Supplementary (Figs.1-5) in order of their appearance
%filename = "Hummingbird_112";
%filename = 'Flower_fig4';
%filename = 'Body_cage_upd';
%filename = 'Letter_A';
%filename = "Eye05";
%filename = 'Dragon4';
%filename = "Witch_08";
%filename = 'Art_freeform_DR_05_norm_full'; %girl with blanket
%filename = 'Art_freeform_PB_09_norm_full'; %boy with dog
%filename = 'dancer2';
%filename = 'Kettle_simp';
%filename = 'Koala';
%filename = 'bear';
%filename = 'hand';
%filename = 'Dirigible_01';
%filename = 'Art_freeform_AG_02_norm_rough'; %human figure
%filename = 'Toucan';
%filename = 'daisy_dashed';
%filename = "Fox_07";
%filename = "Rabbit_05";
%filename = "Witch_08";
%filename = "Spider_Man_07";
%filename = "Bird";
%filename = "Wizard_06";
%filename = "Fox_072";
%filename = "turtle_more_pts";
%filename = 'Snail_more_pts';
%filename = 'fish'; 
%filename = 'bear2';
%filename = 'Penguin';

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

% if there are no inner contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

%% pull overlapping contours in respective normal directions
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
holepts = seedPts;

%% find triangulation for our shape
[nodes, triangles, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

%% find the area of our shape
S_tri = calc_tri_areas(nodes,triangles);

%% Alpha Shapes plot parameters

shapeColor = '#72d6b9';
contourColor = '#016d6a';

%% find Alpha shape and its area

% find referenced vertices
[~,~,nodes_ref,~,~,~] = findLaplacian(nodes,triangles,boundaryCurve);

alpha = radius;
shp = alphaShape(nodes_ref(:,1),-nodes_ref(:,2),alpha);
bf = boundaryFacets(shp); %bounding facets
T = alphaTriangulation(shp); %connectivity list
S_al = area(shp); %area

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
plot(shp, 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
for i = 1:size(bf,1)
    plot([nodes_ref(bf(i,1),1),nodes_ref(bf(i,2),1)],[-nodes_ref(bf(i,1),2),-nodes_ref(bf(i,2),2)], 'LineWidth', edgeWidth, 'Color', contourColor);
end
% uncomment these lines to display the sketch curves: 
% for j = 1:numel(boundaryCurve)
%     plot(boundaryCurve{j}(:,1),-boundaryCurve{j}(:,2),'LineWidth',edgeWidth,'Color','black');
% end
hold off; axis equal; axis off;

% export image in vector format:
%exportgraphics(f1, strcat('./output/',filename,'_alpha_shapes.pdf'), 'ContentType','vector');

