function mesh = MeshInfoPointCloudLaplacian(X, M, L, numEigs)

mesh.X = X;
mesh.M = M;
mesh.L = L;
%mesh.T = T;
%[mesh.E2V, mesh.T2E, mesh.E2T, mesh.T2T] = connectivity(mesh.T);

%mesh.nf = size(mesh.T,1);
mesh.nv = size(mesh.X,1);
%mesh.ne = size(mesh.E2V,1);
numEigs = min(numEigs, mesh.nv);

% Normals and areas
%mesh.normal = cross(mesh.X(mesh.T(:,1),:) - mesh.X(mesh.T(:,2),:), mesh.X(mesh.T(:,1),:) - mesh.X(mesh.T(:,3),:));
mesh.area = diag(mesh.M);
%mesh.normal = mesh.normal./repmat(sqrt(sum(mesh.normal.^2, 2)), [1, 3]);

mesh.sqrt_area = sqrt(sum(mesh.area));

%A = sparse(mesh.T, repmat((1:mesh.nf)', [3,1]), repmat(mesh.area, [3,1]), mesh.nv, mesh.nf);
%mesh.Nv = A*mesh.normal;
%mesh.Nv = mesh.Nv./repmat(sqrt(sum(mesh.Nv.^2,2)), [1,3]);

% Edge length
%mesh.SqEdgeLength = sum((mesh.X(mesh.E2V(:,1),:) - mesh.X(mesh.E2V(:,2),:)).^2, 2);

% Eigenstuff
% [mesh.cotLaplacian, mesh.Av] = cotLaplacian(mesh.X, mesh.T);
mesh.ptclLaplacian = mesh.L;
mesh.ptclLaplacian = -mesh.ptclLaplacian;
mesh.Ae = M;

try
    [mesh.laplaceBasis, mesh.eigenvalues] = eigs(mesh.ptclLaplacian, mesh.Ae, numEigs, 1e-5);
    %eigs(L,numEigsSrc);
catch
    % In case of trouble make the laplacian definite
    [mesh.laplaceBasis, mesh.eigenvalues] = eigs(mesh.ptclLaplacian - 1e-8*speye(mesh.nv), mesh.Ae, numEigs, 'sm');
end
mesh.eigenvalues = diag(mesh.eigenvalues);

end