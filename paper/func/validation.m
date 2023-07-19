clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

%actual paper inputs, in the order they appear
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

%filename = 'baobab_input'; %works
filename = 'bear'; %works
%filename = 'bear'; %new frame
%filename = 'BowTie'; %works 
%filename = 'bunny'; %works 
%filename = 'e12345'; %works 
%filename = 'eye_input'; %works 
%filename = 'fish'; %works 
%filename = 'Flower'; %works
%filename = 'Flower2'; %works
%filename = 'Giraffe'; %works
%filename = 'hand'; %works
%filename = 'Koala'; %works
%filename = 'omega'; %works
%filename = 'Penguin'; %works
%filename = 'Penguin'; %new frame
%filename = 'Pig01'; %works
%filename = 'Pig02'; %works
%filename = 'Shark'; %works
%filename = 'Toucan'; %works
%filename = 'Toucan2'; %new frame
%filename = 'Triceratops'; %works
%filename = 'tulip'; %works
%filename = 'dancer';
%filename = 'dancer2'; %new frame

%fmaps
%filename = 'daisy_dashed'; %fmap works
%filename = "turtle"; %fmap does not work
%filename = "Kettle"; %fmap does not work
%filename = "Bird"; %fmap works
%filename = "Flower_new1"; %fmap does not work
%filename = "Cockatiel"; %fmap does not work
%filename = "Hummingbird_11"; %fmap works
%filename = "Bear_003"; %fmap works
%filename = "Fox_07"; %fmap works
%filename = "Rabbit_05"; %fmap works
%filename = "Dirigible_012"; $fmap does not work
%filename = "Face_01"; %fmap does not work
%filename = "Raccoon_01"; %fmap does not work
%filename = "Wizard_06"; %03 fmap works
%filename = "Witch_08"; %02, 03, 04, 05, 07, 08 fmap works
%filename = "Spider_Man_07"; %02, 04, 05, 06, 07 fmap works

%ARAP deformation
%filename = "Rabbit_05";
%filename = "Fox_072";

%Steklov and Laplacian eigenfunctions
%filename = "Dragon4";
%filename = "circtest2";

%Alpha shapes
%filename = 'baobab_input';
%filename = "Cockatiel"; 
%filename = 'Kettle';
%filename = 'Witch_08';
%filename = 'Dirigible_01';
%filename = 'Face_01';
%filename = 'Art_freeform_DR_03_norm_full'; %boy with umbrella
%filename = 'Art_freeform_DR_05_norm_full'; %girl with blanket
%filename = 'Art_freeform_PB_09_norm_full'; %boy with dog
%filename = 'Ind_architecture_AST_05_norm_rough'; %building
%filename = 'Ind_architecture_AST_02_norm_full'; %building

%SA union 
%filename = 'dancer2';
%filename = 'Cockatiel2';
%filename = 'Koala';
%filename = 'Kettle_simp';
%filename = 'Witch_08'; %test

%algoB
%filename = 'bear';
%filename = 'Witch_08';
%filename = 'Koala';
%filename = 'BowTie';

%Crust
%filename = 'hand';
%filename = 'Toucan';
%filename = "Dragon4";
%filename = 'Face_01';
%filename = 'Art_freeform_AG_02_norm_rough'; %human figure
%filename = 'Dirigible_01'; 

%changing radius/sampling test
%filename = 'Art_freeform_PB_09_norm_full'; %too large
%filename = 'Art_freeform_DR_05_norm_full'; %too large
%filename = 'Toucan';

%fig.4 
%filename = 'Alpha';
%filename = 'E_letter';
%filename = 'Omega_new';
%filename = 'Omega_upd';
%filename = 'Letter_A';

%fig.2
%filename = 'Flower_upd';
%filename = 'Eye_realistic';
%filename = 'Flower_fig4_upd';

%fig.3
%filename = 'Body_cage_upd';

%Paper illustrations 
%filename = "Eye05";

%mesh_dir = './bigExamples/';
%filename = 'catvec'; %works
%filename = 'catevec_def'; %works
%filename = 'teapot'; %works %pictures exported
%filename = 'teapot';
%filename = 'baobab_input';

%mesh_dir = './newBigExamples/';
%filename = 'apple'; %works %fmap: symmetry flipping
%filename = 'apple_def'; %works
%filename = 'dog'; %works %pictures exported
%filename = 'face'; %does not work (sidedness bug)
%filename = 'lily'; %works %pictures exported
%filename = 'plant'; %works %pictures exported
%filename = 'plant_def'; %works with smaller radius
%filename = 'yoga'; %works %pictures exported

%Benchmark dataset test
%mesh_dir = './InputFromBenchmarkDataset/';
%filename = 'Art_freeform_AG_02_norm_rough'; %lifedrawing pose %works: setResampleDistance -> 25
% filename = 'Art_freeform_AG_05'; %girl's face %works: setResampleDistance -> 20
%filename = 'Art_freeform_AP_01'; %wizard %works: setResampleDistance -> 25
%filename = 'Art_freeform_AP_02_norm_rough'; %squirrel %works: setResampleDistance -> 25
% filename = 'Art_freeform_AP_03_norm_rough'; %bunny %works: setResampleDistance -> 25, fails for setResampleDistance -> 20
% filename = 'Art_freeform_AP_05'; %raccoon %works: setResampleDistance -> 22
% filename = 'Art_freeform_DR_01_norm_rough';%witch %works: setResampleDistance -> 6
%filename = 'Art_freeform_DR_02'; %airship %works: setResampleDistance -> 6
% filename = 'Art_freeform_DR_02_norm_rough';
%filename = 'Art_freeform_DR_03';
% filename = 'Art_freeform_DR_05';
% filename = 'Art_freeform_GL_01';
% filename = 'Art_freeform_GL_02_norm_rough';
% filename = 'Art_freeform_PB_01';
%include intersection points into boundaryCurve

%for plot
pointSize = 15;
edgeWidth = 1.5; %1.5 always, 1.3 for SA clusters
edgeColor = [.8 .8 .8];
figureCount = 0;
shapeColor = '#8cb4f4'; %'#a9ccff';%'#acc5fc'; %green: '#C5E6A1'; 
contourColor = '#1c4f99';%'#133e9c'; %green: '#252400';

%strokestrip statistics test
%strokestrip_stat_test

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

%pull overlapping contours in respective normal directions
[contours, contoursToPlot] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename);
holepts = seedPts;

%%plot polyshape bounded by Alpha contours
% f_poly = figure('units','normalized','outerposition',[0 0 1 1]);
% count = 1;
% for i=1:numel(contours)
%     polyX{count} = contours{i}(:,1);
%     polyY{count} = -contours{i}(:,2);
%     plot(contours{i}(:,1),-contours{i}(:,2),'LineWidth',2,'Color',[0 0 0]);
%     count = count + 1;
% end
% pgon = polyshape(polyX,polyY);
% plot(pgon)
% axis equal; axis off;
% exportgraphics(f_poly, strcat('./output/',filename,'_2D_shape.pdf'), 'ContentType','vector');
% S_tri = area(pgon); %area

%find triangulation
[nodes1, triangles1, ~] = findTriangulationForCpp(contours, contoursToPlot, holepts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor);

%Crust algorithm 
%testCrust;
%return;

%find contours for each cluster and find their union
%contourSA;
%return;

%find the unions of stroke contours using StrokeAggregator and StrokeStrip
algoBTest; %close the IDE, which opens .py file
%return;

%compute Laplacian
[L,M,nodes1,triangles1,allEdges1,edgeToTriangle1] = findLaplacian(nodes1,triangles1,boundaryCurve);

%create an .obj file 
%meshFilename1 = strcat(filename,'.obj');
%writeOBJ(strcat(mesh_dir,meshFilename1),nodes1,triangles1);

% figure;%('units','normalized','outerposition',[0 0 1 1]);
% hold on
% scatter(nodes1(:,1), -nodes1(:,2), 5, 'o','filled')
% for i = 1:size(nodes1,1)
%     t = text(nodes1(i,1), -nodes1(i,2), num2str(i), 'FontSize', 10);
% end
% %trimesh(edgeToTriangle1, nodes1(:,1), -nodes1(:,2), nodes1(:,3), 'LineWidth', edgeWidth, 'EdgeColor', 'black');
% view(2);
% hold off; axis equal; axis off;

%find deformation
%find_deformation(nodes1,triangles1,edgeToTriangle1,filename,edgeWidth);
%return;

%Display Steklov eigenfunctions on contours
%close all;
%SteklovTest;

%visualize Laplacian eigs
%findLaplaceBasis(nodes1,L,edgeToTriangle1,edgeWidth,filename);

%visualize Fiedler vector
%findFiedlerVector(nodes1,triangles1,L,edgeToTriangle1,edgeWidth,filename);
%return;

%visualize interpolation with cotLaplacian
%findInterpolationWithCotLaplacian(nodes1,triangles1,L,edgeToTriangle1,edgeWidth,filename);
%return;

%find heat flow
findHeatFlow(L,M,nodes1,triangles1,edgeToTriangle1,edgeWidth,filename);
numericaltourfunc(nodes1,triangles1,edgeToTriangle1,edgeWidth,filename);
return;

%% matlab algorithm
% 
% % input sketch
% run(strcat(mesh_dir,filename,'.m'));
% 
% %Choose resampling distance
% resDist = 4;
% 
% %Choose Alpha Radius: f*averageDistBtSamples 
% f = 1.5;
% 
% %find contours;
% contour;
% 
% %find triangulation
% [nodes, triangles, allEdges1, edgeToTriangle,filename,figureCount] = findTriangulation(contours, holepts, boundaryCurve,edgeWidth,filename,figureCount);
% 
% %create an .obj file
% meshFilename1 = strcat(filename,'.obj');
% writeOBJ(strcat(mesh_dir,meshFilename1),nodes,triangles);
% 
% %test
% allEdges_source = allEdges1;
% allEdges_target = allEdges1;
% compute_fmap(mesh_dir,meshFilename1,meshFilename1,allEdges_source,allEdges_target,pointSize,filename,figureCount)

%% -----

%find area of a mesh
S_tri = calc_tri_areas(nodes1,triangles1);

% curPts = [];
% for k = 1:numel(boundaryCurve)
%     curPts = [curPts;boundaryCurve{k}];
% end
% nodes1 = curPts;

%change shape and color for displaying Alpha shapes
shapeColor = '#72d6b9';
contourColor = '#016d6a';

%find Alpha shape and its area
alpha = radius;
shp = alphaShape(nodes1(:,1),-nodes1(:,2),alpha);
bf = boundaryFacets(shp); %bounding facets
T1 = alphaTriangulation(shp); %connectivity list
S_al = area(shp); %area

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
plot(shp, 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
for i = 1:size(bf,1)
    plot([nodes1(bf(i,1),1),nodes1(bf(i,2),1)],[-nodes1(bf(i,1),2),-nodes1(bf(i,2),2)], 'LineWidth', edgeWidth, 'Color', contourColor);
end
% uncomment these lines to display the sketch curves: 
% for j = 1:numel(boundaryCurve)
%     plot(boundaryCurve{j}(:,1),-boundaryCurve{j}(:,2),'LineWidth',edgeWidth,'Color','black');
% end
hold off; axis equal; axis off;
exportgraphics(f1, strcat('./output/',filename,'_alpha_shapes.pdf'), 'ContentType','vector');
%return

%create an .obj file of the sketch shape or Alpha shape depending on
%which one is used to find fmap
meshFilename1 = strcat(filename,'.obj');
writeOBJ(strcat(mesh_dir,meshFilename1),nodes1,triangles1);


%Display eigenfunctions of point cloud Laplacian (works for turtle_more_pts and Snail_more_pts)
%pointCloudTest;

%Heat flow for point cloud (works for turtle_more_pts and Snail_more_pts)
%heatFlowPointCloud;
%return;

%Interpolation with point cloud laplacian (works for turtle_more_pts and Snail_more_pts)
%interpolationPointCloudLap;


%% matlab algo

% %clean previous curves
boundaryCurve = [];
openCurve = [];
contours = [];
gapSegments = [];
nodes = [];
triangles = [];
cppContour = [];
cppContourInner = [];
contours = [];

% %input a deformed sketch
%filename = strcat(filename,'_def1');

% run(strcat(mesh_dir,filename,'.m'));
% 
% %Choose resampling distance
% resDist = 4;
% 
% %Choose Alpha Radius: f*averageDistBtSamples 
% f = 2;
% 
% %find contours;
% contour;
% 
% %find triangulation
% [nodes, triangles, allEdges2, edgeToTriangle, filename, figureCount] = findTriangulation(contours, holepts, boundaryCurve, edgeWidth, filename, figureCount);
% 
% %create an .obj file
% meshFilename2 = strcat(filename,'.obj');
% writeOBJ(strcat(mesh_dir,meshFilename2),nodes,triangles);

%% cpp algo

% input second frame
filename2 = strcat(filename,'2');

%find contours
[cppContour2,cppContourInner2,boundaryCurve2,seedPts2] = contour_cpp(mesh_dir,filename2,'true');

%pull overlapping contours in respective normal directions
[contours2, contoursToPlot2] = pullContours_cpp(boundaryCurve2, cppContour2, cppContourInner2, edgeWidth, filename);
holepts2 = seedPts2;

%find triangulation
[nodes2, triangles2, edgeToTriangle] = findTriangulationForCpp(contours2, contoursToPlot2, holepts2, boundaryCurve2, edgeWidth, filename, shapeColor, contourColor);

%compute Laplacian
[L2,M2,nodes2,triangles2,allEdges2,edgeToTriangle2] = findLaplacian(nodes2,triangles2,boundaryCurve2);

%create an .obj file
% meshFilename2 = strcat(filename2,'.obj');
% writeOBJ(strcat(mesh_dir,meshFilename2),nodes2,triangles2);

%find alpha shape and its area
alpha = radius;
shp = alphaShape(nodes2(:,1),-nodes2(:,2),alpha);
bf = boundaryFacets(shp); %bounding facets
T2 = alphaTriangulation(shp); %connectivity list
S_al = area(shp);

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
plot(shp, 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
for i = 1:size(bf,1)
    plot([nodes2(bf(i,1),1),nodes2(bf(i,2),1)],[-nodes2(bf(i,1),2),-nodes2(bf(i,2),2)], 'LineWidth', edgeWidth, 'Color', contourColor);
end
% for j = 1:numel(boundaryCurve)
%     plot(boundaryCurve{j}(:,1),-boundaryCurve{j}(:,2),'LineWidth',edgeWidth,'Color','black');
% end
hold off; axis equal; axis off;
exportgraphics(f1, strcat('./output/',filename,'2_alpha_shapes.pdf'), 'ContentType','vector');
%return

%create an .obj file 
meshFilename2 = strcat(filename,'2.obj');
writeOBJ(strcat(mesh_dir,meshFilename2),nodes2,triangles2);


% figure;%('units','normalized','outerposition',[0 0 1 1]);
% hold on
% scatter(nodes1(:,1), -nodes1(:,2), 5, 'o','filled')
% for i = 1:size(nodes1,1)
%     t = text(nodes1(i,1), -nodes1(i,2), num2str(i), 'FontSize', 8);
% end
% trimesh(edgeToTriangle1, nodes1(:,1), -nodes1(:,2), nodes1(:,3), 'LineWidth', edgeWidth, 'EdgeColor', 'black');
% view(2);
% hold off; axis equal; axis off;
% 
% figure;
% hold on
% scatter(nodes2(:,1), -nodes2(:,2), 5, 'o','filled')
% for i = 1:size(nodes2,1)
%     t = text(nodes2(i,1), -nodes2(i,2), num2str(i), 'FontSize', 8);
% end
% trimesh(edgeToTriangle2, nodes2(:,1), -nodes2(:,2), nodes2(:,3), 'LineWidth', edgeWidth, 'EdgeColor', 'black');
% view(2);
% hold off; axis equal; axis off;

%meshFilename1 = "Hummingbird_01";
%meshFilename2 = "Hummingbird_012";
%fmaps
%allEdges_source = allEdges1;
%allEdges_target = allEdges2;
%compute_fmap(mesh_dir,meshFilename1,meshFilename2,allEdges_source,allEdges_target,pointSize,filename,figureCount)
%compute_fmap_orig(mesh_dir,meshFilename1,meshFilename2);
compute_fmap(mesh_dir,meshFilename1,meshFilename2,edgeToTriangle1,edgeToTriangle2,pointSize,filename,edgeWidth,false)


