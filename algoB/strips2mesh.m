clear; close all;

path = 'inputs/tmp.svg';
path2 = split(path, '.');
path2 = path2{1};

contours = myLoadSVG(path);

nContours = size(contours,2);

h = 0.3;

% TODO try without resampling
for k = 1:nContours
    contours{k} = resample_polygon(contours{k}, [], h);
end

% contours -> polyshape
polygons = [];
for k = 1:nContours
    polygons = [polygons, polyshape(contours{k}(:,1), contours{k}(:,2))];
end

% union of intersecting contours
polyout = union(polygons);

% Triangulation of the contours
T = triangulation(polyout);

%size of each contour
%E = freeBoundary(T);

% Write mesh
meshFilename = strcat(path2,'.obj');
writeOBJ(meshFilename, T.Points, T.ConnectivityList);

%save(strcat(path2,'.mat'), 'E');

return;



% contourEdges = {};
% for k = 1:nContours
%     tmp = [];
%     for i = 1:size(contours{k},1)-1
%         tmp = [tmp; i, i+1];
%     end
%     tmp = [tmp; size(contours{k}, 1), 1];
%     contourEdges{k} = tmp;
% end
% 
% nodes = {};
% triangles = {};
% for k = 1:nContours
%     [tmpNodes, tmpTriangles] = triangulate(contours{k}, contourEdges{k}, []);
%     nodes{k} = tmpNodes;
%     triangles{k} = tmpTriangles;
% end

% figure;
% hold on
% for k = 1:nContours
%     scatter(nodes{k}(1,:), nodes{k}(2,:), 'o')
%     trimesh(triangles{k}', nodes{k}(1,:), nodes{k}(2,:))
%     scatter(envCurvePoints(:,1), envCurvePoints(:,2), 'or')
% end
% axis equal
% hold off

%return;



