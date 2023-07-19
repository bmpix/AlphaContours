function [] = findFiedlerVector(nodes,triangles,L,edgeToTriangle,edgeWidth,filename)

edgeWidth = 4; 

X = nodes;
T = triangles;

% flip Laplacian (if needed)
%L = -L;

% eigen stuff
[V,D] = eigs(L,10,'smallestabs');
d_val = diag(D);

%% visualize Fiedler vector

% for the Fiedler vector, function index  changes depending on the number of separated components: 
% for bear: idx = 8;
% for fish: idx = 4;
% for Snail_more_pts: idx = 7;

idx = 7;
w = V(:,idx); 

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
trimesh(edgeToTriangle, X(:,1), -X(:,2), X(:,3), 'FaceVertexCData', w(:,1), 'FaceColor', 'none', 'EdgeColor', 'interp','LineWidth', edgeWidth) %#19BABA
view(2);
axis equal; axis off;
exportgraphics(f1, strcat('./output/',filename,'_Fiedler_vector.pdf'), 'ContentType','vector');

end

