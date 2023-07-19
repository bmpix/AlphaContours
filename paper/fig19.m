clear; close all; %clearvars;
addpath(genpath(pwd));
addpath(genpath('../SGP21_discreteOptimization-main/'));

mesh_dir = 'input/';

filename1 = "Hummingbird_11"; 
%filename1 = "Bird"; 
%filename1 = 'daisy_dashed';
%filename1 = "Rabbit_05"; 
%filename1 = "Wizard_06"; 
%filename1 = "Fox_07"; 
%filename1 = "Witch_08";
%filename1 = "Spider_Man_07";

%% Alpha Contours plot parameters
pointSize = 15;
edgeWidth = 1.5; 
edgeColor = [.8 .8 .8];
figureCount = 0;
shapeColor = '#8cb4f4';
contourColor = '#1c4f99';

%% FIRST SHAPE
%% run cpp algo to find the contours
% in contour_cpp, use the radius found by optimalFmap.m instead of automatically computed one:
[cppContour, cppContourInner, boundaryCurve, seedPts, radius, pgon] = contour_cpp(mesh_dir,filename1,false);

% if there are no inner contours, create an empty cell array
if ~exist('cppContourInner','var')
    cppContourInner = {};
end

%% pull overlapping contours in respective normal directions
[contours1, contoursToPlot1] = pullContours_cpp(boundaryCurve, cppContour, cppContourInner, edgeWidth, filename1);
holepts = seedPts;

%% find triangulation for our shape
[nodes1, triangles1, ~] = findTriangulationForCpp(contours1, contoursToPlot1, holepts, boundaryCurve, edgeWidth, filename1, shapeColor, contourColor);

%% or find alpha shape
% alpha = radius; %the same radius as for Alpha Contours
% shp1 = alphaShape(nodes1(:,1),-nodes1(:,2),alpha);
% bf1 = boundaryFacets(shp1); %bounding facets
% triangles1 = alphaTriangulation(shp1); %connectivity list
% 
%% display alpha shape
% f1 = figure('units','normalized','outerposition',[0 0 1 1]);
% hold on;
% plot(shp, 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
% for i = 1:size(bf1,1)
%     plot([nodes1(bf1(i,1),1),nodes1(bf1(i,2),1)],[-nodes1(bf1(i,1),2),-nodes1(bf1(i,2),2)], 'LineWidth', edgeWidth, 'Color', contourColor);
% end
% hold off; axis equal; axis off;
% %exportgraphics(f1, strcat('./output/',filename,'_alpha_shapes.pdf'), 'ContentType','vector');

%% compute Laplacian
[L,M,nodes1,triangles1,allEdges1,edgeToTriangle1] = findLaplacian(nodes1,triangles1,boundaryCurve);

%% create an .obj file of the sketch shape or Alpha shape depending on which one is used to find fmap
meshFilename1 = strcat(filename1,'.obj');
writeOBJ(strcat(mesh_dir,meshFilename1),nodes1,triangles1);

%% SECOND SHAPE
%% input second image
filename2 = strcat(filename1,'2');

%% run cpp algo to find the contours
[cppContour2,cppContourInner2,boundaryCurve2,seedPts2] = contour_cpp(mesh_dir,filename2,'true');

%% pull overlapping contours in respective normal directions
[contours2, contoursToPlot2] = pullContours_cpp(boundaryCurve2, cppContour2, cppContourInner2, edgeWidth, filename2);
holepts2 = seedPts2;

%% find triangulation for our shape
[nodes2, triangles2, edgeToTriangle] = findTriangulationForCpp(contours2, contoursToPlot2, holepts2, boundaryCurve2, edgeWidth, filename2, shapeColor, contourColor);

%% or find alpha shape
% alpha = radius; %the same radius as for Alpha Contours
% shp2 = alphaShape(nodes2(:,1),-nodes2(:,2),alpha);
% bf2 = boundaryFacets(shp2); %bounding facets
% triangles2 = alphaTriangulation(shp2); %connectivity list

%% display alpha shape
% f1 = figure('units','normalized','outerposition',[0 0 1 1]);
% hold on;
% plot(shp, 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
% for i = 1:size(bf2,1)
%     plot([nodes2(bf2(i,1),1),nodes2(bf2(i,2),1)],[-nodes2(bf2(i,1),2),-nodes2(bf2(i,2),2)], 'LineWidth', edgeWidth, 'Color', contourColor);
% end
% hold off; axis equal; axis off;
% %exportgraphics(f1, strcat('./output/',filename,'_alpha_shapes.pdf'), 'ContentType','vector');

%% compute Laplacian
[L2,M2,nodes2,triangles2,allEdges2,edgeToTriangle2] = findLaplacian(nodes2,triangles2,boundaryCurve2);

%% create an .obj file of the sketch shape or Alpha shape depending on which one is used to find fmap
meshFilename2 = strcat(filename2,'.obj');
writeOBJ(strcat(mesh_dir,meshFilename2),nodes2,triangles2);

%% FMAP
compute_fmap(mesh_dir,meshFilename1,meshFilename2,edgeToTriangle1,edgeToTriangle2,pointSize,filename1,edgeWidth,false)





