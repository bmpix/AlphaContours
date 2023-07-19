function [nodes, triangles, edgeToTriangle] = findTriangulationForCpp(contours, contoursToPlot, holepts, curves, edgeWidth, filename, shapeColor, contourColor)

nCurves = numel(curves);
nContours = numel(contours);

%% append indices of points and curves to curvePoints
for i = 1:nCurves
    curves{i} = [curves{i}, i*ones(size(curves{i},1),1), (1:size(curves{i},1))']; %[x,y,curveIdx,pointIdx]
end

%% find all curve points
curvePoints = [];
for i = 1:numel(curves)
    curvePoints = [curvePoints; curves{i}];
end

%% find all contour points
contourPoints = [];
for i = 1:numel(contours)
    contourPoints = [contourPoints; contours{i}];
end

%% find contour points in indices of curve points
curvePointsTemp = curvePoints;
%find indices of contour points in curvePoints
idxContPt = size(curvePoints,1); %to each contour point that does not belong to curves, we assign a new index
pt_cur_idx = cell(1,nContours); %with coordinates
ptIdx = cell(1,nContours); %only indices
nonCurvePtsIdx = cell(nContours,1); %indices on noncontour points
nonCurvePts = []; %non-curve contour points
for i = 1:nContours
    for j = 1:size(contours{i},1)
        idxX = abs(contours{i}(j,1) - curvePointsTemp(:,1)) < 1e-10;
        idxY = abs(contours{i}(j,2) - curvePointsTemp(:,2)) < 1e-10;
        idx = find(idxX>0 & idxY>0);
        if ~isempty(idx)
            pt_cur_idx{i} = [pt_cur_idx{i}; curvePointsTemp(idx,:), idx];
            ptIdx{i} = [ptIdx{i}; idx];
            %curvePointsTemp(idx,:) = NaN;
        else
            idxContPt = idxContPt+1;
            pt_cur_idx{i} = [pt_cur_idx{i}; contours{i}(j,:), 0, 0, idxContPt];
            ptIdx{i} = [ptIdx{i}; idxContPt];
            nonCurvePtsIdx{i} = [nonCurvePtsIdx{i}; j];
            nonCurvePts = [nonCurvePts; contours{i}(j,:)];
        end
    end
end

%% find edges for contours

edges = cell(1,size(contours,2));
for i = 1:nContours
    for j = 1:size(contours{i},1)-1
        edges{i} = [edges{i}; ptIdx{i}(j), ptIdx{i}(j+1)];
    end
    edges{i} = [edges{i}; ptIdx{i}(end), ptIdx{i}(1)]; %to close each contour
end

%% find edges for curves

edgesForCurves = cell(1,nCurves);
idx = 0;
for i = 1:nCurves
    for j = 1:size(curves{i},1)-1
        edgesForCurves{i} = [edgesForCurves{i}; j+idx, j+1+idx];
    end
    idx = idx + size(edgesForCurves{i},1)+1;
end

%% append points and edges of all contours to one matrix

inputPoints = [];
contourEdges = [];
curveEdges = [];
contourPtsToAppend = [];
for i = 1:numel(contours)
    inputPoints = [inputPoints; contours{i}];
    contourEdges = [contourEdges; edges{i}];
    contourPtsToAppend = [contourPtsToAppend; contours{i}(nonCurvePtsIdx{i},:)];
end

for i = 1:nCurves
    curveEdges = [curveEdges; edgesForCurves{i}];
end

%% combine all edges together, remove duplicates

allEdges = [contourEdges; curveEdges];

%% find all points for triangulation

curPt = curvePoints(:,[1,2]);
allPointsToTriang = [curPt; contourPtsToAppend];

%% holes
holes = holepts;

%% triangulate
[nodes, triangles] = triangulate(allPointsToTriang,contourEdges,holes);
nodes = nodes';
triangles = triangles';

nodes = [nodes, zeros(size(nodes,1),1)];

%% display mesh
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on
trimesh(triangles, nodes(:,1), -nodes(:,2), 'LineWidth', edgeWidth);
hold off; axis equal; axis off;
%exportgraphics(f1, strcat('./output/',filename,'_mesh.pdf'), 'ContentType','vector');

%% display 2D shape
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on
trimesh(triangles, nodes(:,1), -nodes(:,2), nodes(:,3), 'FaceColor', shapeColor, 'EdgeColor', 'none');
for k = 1:nContours
    plot(contoursToPlot{k}(:,1),-contoursToPlot{k}(:,2),'LineWidth',edgeWidth,'Color', contourColor);
end
view(2);
hold off; axis equal; axis off;
%exportgraphics(f2, strcat('./output/',filename,'_2D_shape.pdf'), 'ContentType','vector');

%% display 2D shape and curves
% f3 = figure('units','normalized','outerposition',[0 0 1 1]);
% hold on
% trimesh(triangles, nodes(:,1), -nodes(:,2), nodes(:,3), 'FaceColor', shapeColor, 'EdgeColor', 'none');
% % for k = 1:nContours
% %     plot(contoursToPlot{k}(:,1),-contoursToPlot{k}(:,2),'LineWidth',0.75*edgeWidth,'Color', contourColor);
% % end
% for j = 1:nCurves
%     plot(curves{j}(:,1),-curves{j}(:,2),'LineWidth',edgeWidth,'Color','black');
% end
% view(2);
% hold off; axis equal; axis off;
% %exportgraphics(f3, strcat('./output/',filename,'_2D_shape_and_curves.pdf'), 'ContentType','vector');

%% for each seed point, find two closest points on different contours
for i = 1:size(holes,1)
    pt = holes(i,:);
    [~,dist] = dsearchn(pt,nodes(:,[1,2]));
    idx = find(abs(dist - min(dist))<1e-3);
end

%% find edges for curves
edgesForCurves = cell(1,nCurves);
idx = 0;
for i = 1:nCurves
    for j = 1:size(curves{i},1)-1
        edgesForCurves{i} = [edgesForCurves{i}; j+idx, j+1+idx];
    end
    idx = idx + size(edgesForCurves{i},1)+1;
end

allEdges = [];
for i = 1:nCurves
    allEdges = [allEdges; edgesForCurves{i}];
end

%% convert curve edges to thin triangles
edgeToTriangle = [];
for i = 1:nCurves
    for j = 1:size(curves{i},1)-1
        edgeToTriangle = [edgeToTriangle;  edgesForCurves{i}(j,:), edgesForCurves{i}(j,1)];
    end
end

%% display curves as trimesh 
% f4 = figure('units','normalized','outerposition',[0 0 1 1]);
% hold on
% trimesh(edgeToTriangle, nodes(:,1), -nodes(:,2), nodes(:,3), 'LineWidth', edgeWidth, 'EdgeColor', 'black');
% view(2);
% hold off; axis equal; axis off;
% % exportgraphics(f4, strcat('./output/',filename,'_meshToCurves.pdf'), 'ContentType','vector');

end
