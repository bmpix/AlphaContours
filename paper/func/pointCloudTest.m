load(strcat('./input/',filename,'.mat')) %load L, M and pts

Src = MeshInfoPointCloudLaplacian(pts, M, L, 200);

numEigs = 20;
%L = -L;

[laplaceBasis, eigenvalues] = eigs(L, M, numEigs, 1e-5);

f = laplaceBasis;

fprintf('Visualizing results\n');

figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
for i = 1:10
    subplot(2,5,i)
    f = Src.laplaceBasis(:,i);
    scatter(Src.X(:,1), -Src.X(:,2), 0.85*pointSize, f, 'filled')
    colormap parula
end
hold off; axis equal; axis off;

