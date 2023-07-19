run(strcat(mesh_dir,filename,'_SA_cluster.m'));

nClusters = numel(cluster);

%% display clusters in different colors
% color clusters in random colors
red = rand(nClusters,1)*0.95;
blue = rand(nClusters,1)*0.95;
green = rand(nClusters,1)*0.95; 

f0 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
for m = 1:nClusters
    clusterToCurves = cluster{m};
    if ~isempty(clusterToCurves)
        for j = clusterToCurves
            plot(b{j}(:,1),-b{j}(:,2), 'Color', [red(m) blue(m) green(m)], 'LineWidth',edgeWidth);
        end
    end
end
hold off; axis equal; axis off;
%exportgraphics(f0, strcat('./output/',filename,'_colored_clusters.pdf'), 'ContentType','vector')

%% find contours of clusters
exteriorContours = cell(1,nClusters); 
for m = 1:nClusters
    %find curves that belong to a cluster
    clusterToCurves = cluster{m};
    if ~isempty(clusterToCurves)
        boundaryCurve = cell(1,size(clusterToCurves,2));
        openCurve = cell(1,size(clusterToCurves,2));
        for j = 1:size(clusterToCurves,2)
            boundaryCurve{j} = [boundaryCurve{j}; b{clusterToCurves(j)}];
            openCurve{j} = [openCurve{j}; true];
        end
        %find contour
        cppContour = contour_cpp_SA_upd(boundaryCurve,openCurve,true,mesh_dir,filename);
        %[cppContour, cppContourInner,~,~] = contour_cpp(mesh_dir,filename,'true');
        exteriorContours{m} = [exteriorContours{m}; cppContour{1}];
    else
        exteriorContours{m} = [exteriorContours{m}; []];
    end
end

nContours = numel(exteriorContours);

%% union of contours
polyUnion = polyshape();
for k = 1:nContours
    if ~isempty(exteriorContours{k})
        poly = polyshape(exteriorContours{k}(:,1), -exteriorContours{k}(:,2));
        polyUnion = union(polyUnion,poly);
    end
end

%% display contour union
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
plot(polyUnion, 'FaceColor', shapeColor, 'FaceAlpha', 1, 'EdgeColor', contourColor, 'LineWidth', 0.8*edgeWidth);
axis equal; axis off;
%exportgraphics(f1, strcat('./output/',filename,'_union.pdf'), 'ContentType','vector')

%% find triangulation of the outlined region
% T = triangulation(polyUnion);
% F = T.ConnectivityList;
% V = T.Points;

%% display mesh
%f2 = figure('units','normalized','outerposition',[0 0 1 1]);
% hold on
% scatter(V(:,1), V(:,2), 10, 'o','filled')
% trimesh(F, V(:,1), V(:,2), zeros(size(V,1),1), 'FaceColor', shapeColor, 'EdgeColor', 'none', 'LineWidth', edgeWidth);
% view(2); hold off; axis equal; axis off;
%exportgraphics(f2, strcat('./output/',filename,'_union_mesh.pdf'), 'ContentType','vector');

%% create .obj file
%meshFilename = strcat(filename,'.obj');
%writeOBJ(strcat(mesh_dir,meshFilename), F, V);