X = nodes;
T = triangles;
edgeToTriangle = edgeToTriangle1;

%flip Laplacian
%L = -L;

%eigen stuff
[V,D] = eigs(L,size(L,1));
d_val = diag(D);

w = V(:,end-2); %for one component; changes depending on the number of separated components

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
trimesh(edgeToTriangle, X(:,1), -X(:,2), X(:,3), 'FaceVertexCData', w(:,1), 'FaceColor', 'none', 'EdgeColor', 'interp','LineWidth', 1.5*edgeWidth); %#19BABA
view(2);
%scatter(X_ref(:,1),-X_ref(:,2),10,w);
axis equal; axis off;
exportgraphics(f1, strcat('./output/',filename,'_Fiedler_vector.pdf'), 'ContentType','vector');