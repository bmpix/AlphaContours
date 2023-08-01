function [E] = meshAndFmap(command,pathToExe,mesh_dir,filename,filename2,curvesFilename,curvesFilename2,boundaryCurve,boundaryCurve2,edgeWidth,shapeColor,contourColor,pointSize,radius,quiet)
ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename, radius);
contoursFilename1 = strcat(mesh_dir,filename,"_curves_contours.m");
%delete contoursFilename1
%system(ss);
%run(contoursFilename1);

% if ~exist('seedPts','var')
%     E = inf; %alpha contours crashed
%     return;
% end

nodes1 = [];
for k=1:numel(boundaryCurve)
    nodes1 = [nodes1;boundaryCurve{k}];
end
shp1 = alphaShape(nodes1(:,1),-nodes1(:,2),radius);
bf1 = boundaryFacets(shp1); %bounding facets
triangles1 = alphaTriangulation(shp1); %connectivity list
[~,~,nodes1,triangles1,~,edgeToTriangle1] = findLaplacian(nodes1,triangles1,boundaryCurve);

% contours = [cppContour, cppContourInner];
% %pull overlapping contours in respective normal directions
% [contours, contoursToPlot] = pullContours_cpp(cppContour, cppContourInner, edgeWidth, filename,true);
% [nodes1, triangles1, ~] = findTriangulationForCpp(contours, contoursToPlot, seedPts, boundaryCurve, edgeWidth, filename, shapeColor, contourColor, true);
% [~,~,nodes1,triangles1,~,edgeToTriangle1] = findLaplacian(nodes1,triangles1,boundaryCurve);
meshFilename1 = strcat(filename,'.obj');
writeOBJ(strcat(mesh_dir,meshFilename1),nodes1,triangles1);

%clear contours gapSegments nodes triangles cppContour cppContourInner contours seedPts

ss = sprintf('%s\"%s\" %s %f', command, pathToExe, curvesFilename2, radius);
contoursFilename2 = strcat(mesh_dir,filename2,"_curves_contours.m");
%delete contoursFilename2
%system(ss);
%run(contoursFilename2);

nodes2 = [];
for k=1:numel(boundaryCurve2)
    nodes2 = [nodes2;boundaryCurve2{k}];
end
shp2 = alphaShape(nodes2(:,1),-nodes2(:,2),radius);
bf2 = boundaryFacets(shp2); %bounding facets
triangles2 = alphaTriangulation(shp2); %connectivity list
[~,~,nodes2,triangles2,~,edgeToTriangle2] = findLaplacian(nodes2,triangles2,boundaryCurve2);

% if ~exist('seedPts','var')
%     E = inf; %alpha contours crashed
%     return;
% end
% 
% if ~exist('cppContourInner','var')
%     cppContourInner = [];
% end
% contours = [cppContour, cppContourInner];
% %pull overlapping contours in respective normal directions
% [contours, contoursToPlot] = pullContours_cpp(cppContour, cppContourInner, edgeWidth, filename,true);
% [nodes2, triangles2, ~] = findTriangulationForCpp(contours, contoursToPlot, seedPts, boundaryCurve2, edgeWidth, filename, shapeColor, contourColor, true);
% [~,~,nodes2,triangles2,~,edgeToTriangle2] = findLaplacian(nodes2,triangles2,boundaryCurve2);
meshFilename2 = strcat(filename2,'.obj');
writeOBJ(strcat(mesh_dir,meshFilename2),nodes2,triangles2);

E = compute_fmap(mesh_dir,meshFilename1,meshFilename2,edgeToTriangle1,edgeToTriangle2,pointSize,filename,edgeWidth,quiet);
end

