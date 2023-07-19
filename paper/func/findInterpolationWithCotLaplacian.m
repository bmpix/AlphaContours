function [] = findInterpolationWithCotLaplacian(nodes,triangles,L,edgeToTriangle,edgeWidth,filename)

X = nodes;
T = triangles;

%% chose two points
% for bear:
n = 7;
m = 1629;

% for turtle_more_pts:
%n = 3448;
%m = 2444;

% for Penguin:
%n = 3662;
%m = 1848;

w = computeInterpolation(L,n,m);

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;

%use this line to display interpolation over the sketch strokes:
trimesh(edgeToTriangle, X(:,1), -X(:,2), X(:,3), 'FaceVertexCData', w(:,1), 'FaceColor', 'none', 'EdgeColor', 'interp','LineWidth', edgeWidth+1);

%use this line to display interpolation over the sketch shape (Fig.8, Supplementary):
%trimesh(T, X(:,1), -X(:,2), X(:,3), 'FaceVertexCData', w(:,1), 'FaceColor', 'interp', 'EdgeColor', 'interp','LineWidth', edgeWidth+1);

scatter(X(n,1), -X(n,2), 500, w(n), 'o', 'filled', 'MarkerEdgeColor', 'black');
scatter(X(m,1), -X(m,2), 500, w(m), 'o', 'filled', 'MarkerEdgeColor', 'black');
view(2);

if isMATLABReleaseOlderThan("R2022a")
    caxis([-1 max(w)-0.15]);
else
    clim([-1 max(w)-0.15]); 
end

hold off; axis equal; axis off;
%exportgraphics(f1, strcat('./output/',filename,'_cotLaplacian_interpolation_with_pt.pdf'), 'ContentType','vector');

end