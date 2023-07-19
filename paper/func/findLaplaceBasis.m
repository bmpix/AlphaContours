function findLaplaceBasis(nodes,L,edgeToTriangle,edgeWidth,filename)

numEigs = 100;

%eigen stuff
[V,D] = eigs(L,numEigs,'smallestabs');
d_val = diag(D);

for i = 1:16 %in the paper: i = 2, 3, 4, 6, 8, 16
    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    trimesh(edgeToTriangle, nodes(:,1), -nodes(:,2), nodes(:,3), 'FaceVertexCData', V(:,i), 'FaceColor', 'none', 'EdgeColor', 'interp','LineWidth', 3.5*edgeWidth); 
    view(2);
    axis equal; axis off;
    % export image in vector format:
    %exportgraphics(f1, strcat('./output/Laplacian/', filename, '_Laplacian_eig_', num2str(i), '.pdf'), 'ContentType','vector');
    % export image as .png in high resolution:
    %exportgraphics(f1, strcat('./output/Laplacian/', filename, '_Laplacian_eig_', num2str(i), '.png'), 'Resolution', 300); 
end

end


