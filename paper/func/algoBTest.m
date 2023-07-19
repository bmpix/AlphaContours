function [] = algoBTest(boundaryCurve, filename, mesh_dir, edgeWidth)

fullFilenameSvg = strcat(mesh_dir, filename, '.svg');

curDir = pwd;
cd '../algoB/';
if ispc
    command = "python";
elseif ismac
    setenv('PATH', [getenv('PATH') ':/usr/local/bin:/usr/bin:/bin']);
    command = '/Users/bmpix/opt/anaconda3/bin/python ';
end
ss = sprintf('%s algoB.py %s', command, fullFilenameSvg);
system(ss);
cd(curDir);

[V,F] = readOBJ(strcat(mesh_dir, filename, '_clusterstrips.obj'));
load(strcat(mesh_dir, filename, '_clusterstrips_contourEdges.mat'));

%mesh area
%S_tri_algoB = calc_tri_areas(V,F);

%% Visualize mesh
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on

%display curves
for i = 1:numel(boundaryCurve)
    plot(boundaryCurve{i}(:,1),-boundaryCurve{i}(:,2),'LineWidth', edgeWidth, 'Color', 'black'); %[0, 0, 0, 0.5]
end

%display contours of strip union
for i = 1:size(E,1)
    plot([V(E(i,1),1),V(E(i,2),1)]+max(V(:,1)),[-V(E(i,1),2),-V(E(i,2),2)]-max(V(:,2)), 'LineWidth', 2*edgeWidth, 'Color', '#C62AA1');
end

%display union of strips
trimesh(F, V(:,1)+max(V(:,1)), -V(:,2)-max(V(:,2)), zeros(size(V(:,1),1),1), 'LineWidth', edgeWidth, 'FaceColor', '#C62AA1', 'EdgeColor', 'none'); %blue: #5d9ffe
hold off; axis equal; axis off;

%exportgraphics(f1, strcat('./output/',filename,'_algoB_mesh.pdf'), 'ContentType','vector');

end