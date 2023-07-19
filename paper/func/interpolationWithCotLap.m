% X = [nodes, zeros(size(nodes,1),1)];
% T = triangles;
% 
% L = cotmatrix(X,T);

f = computeInterpolation(L);

figure;
scatter(X_ref(:,1), -X_ref(:,2),10,f,'filled')
colormap parula
axis equal; axis off;