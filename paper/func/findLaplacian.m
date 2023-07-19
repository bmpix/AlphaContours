function [L,M,X_ref,T_ref,edgesForCurves,edgeToTriangle] = findLaplacian(nodes,triangles,boundaryCurve)

%% compute cotLaplacian
X = nodes;
T = triangles;

L = cotmatrix(X,T);

% check eigs
%[V,D] = eigs(L,size(L,1));
%d_val = diag(D);

%% find if there are rows of zeros (if there are, some vertices are unreferenced)
L = full(L);
zero_rows = [];
for i = 1:size(L,1)
    if find(all(L(i,:)==0))
        zero_rows = [zero_rows; i];
    end
end

non_zero_rows = setdiff(1:size(L,1),zero_rows)';

% check, which vertices belong  towhich triangles
tri = [];
tri_with_vert = cell(size(X,1),1);
for i = 1:size(X,1)
    for j = 1:size(T,1)
        if i == T(j,1) || i == T(j,2) || i == T(j,3)
            tri_with_vert{i} = [tri_with_vert{i}; j];
            tri = [tri; j];
        end
    end
end

% coordinates of unreferenced vertices
X_unref = X(zero_rows,:);

% coordinates of referenced vertices
X_ref = X(non_zero_rows,:);

% find correct triangles
map_back = zeros(size(X,1),1);
map_back(non_zero_rows) = 1:size(non_zero_rows,1);

T_ref = map_back(T);

%% recompute Laplacian and mass matrix
L = cotmatrix(X_ref,T_ref);
M = massmatrix(X_ref,T_ref);

%% boundary curves to matrix
curves = [];
for i = 1:numel(boundaryCurve)
    curves = [curves; boundaryCurve{i}];
end

%% find edges between the curve points in new indices
radius = 2*averageDistance(boundaryCurve);
nCurves = numel(boundaryCurve);
new_pt_idx = cell(nCurves,1);
X_ref_temp = X_ref(:,[1,2]);
for i = 1:nCurves
    for j = 1:size(boundaryCurve{i},1)
        idxX = abs(boundaryCurve{i}(j,1) - X_ref_temp(:,1)) < 1e-2;
        idxY = abs(boundaryCurve{i}(j,2) - X_ref_temp(:,2)) < 1e-2;
        idx = find(idxX>0 & idxY>0);
        if size(idx,1) > 0
            dist = [];
            for k = 1:size(idx,1)
                dist = [dist; sqrt((X_ref_temp(idx(k),1)-boundaryCurve{i}(j,1)).^2 + (X_ref_temp(idx(k),2)-boundaryCurve{i}(j,2)).^2)];
            end
            [~, idx_dist] = sort(dist);
            new_pt_idx{i} = [new_pt_idx{i}; idx(idx_dist(1))];
            X_ref_temp(idx(idx_dist(1)),:) = NaN;
        end
    end
end

%% update boundaryCurve
boundaryCurveUpd = cell(1,nCurves);

for i = 1:nCurves
    boundaryCurveUpd{i} = [boundaryCurveUpd{i}; X_ref(new_pt_idx{i},[1,2])];
end

%% all curve points
curvePoints = [];
for i = 1:nCurves
    curvePoints = [curvePoints; boundaryCurveUpd{i}];
end


%% edges for curves in new indices
edgesForCurves = cell(1,nCurves);
for i = 1:nCurves
    for j = 1:size(new_pt_idx{i},1)-1
        edgesForCurves{i} = [edgesForCurves{i}; new_pt_idx{i}(j), new_pt_idx{i}(j+1)];
    end
end

%% convert edges to triangles
edgeToTriangle = [];
for i = 1:nCurves
    for j = 1:size(new_pt_idx{i},1)-1
        edgeToTriangle = [edgeToTriangle;  edgesForCurves{i}(j,:), edgesForCurves{i}(j,1)];
    end
end

%% display curves with their segments as thin triangles

% figure;
% hold on
% trimesh(edgeToTriangle, X_ref(:,1), -X_ref(:,2), 'LineWidth', edgeWidth);
% hold off; axis equal; axis off;
% figureCount = figureCount +1;

% figure;
% scatter(curvePoints(:,1), -curvePoints(:,2));
% hold on;
% for i = 1:nCurves
%     scatter(boundaryCurve{i}(:,1),-boundaryCurve{i}(:,2),5,'o','filled','red');
% end
% scatter(X_ref(:,1), -X_ref(:,2),20,'green','o');
% hold off; axis equal; axis off;

end

