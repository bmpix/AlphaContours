function mesh = MeshInfoSteklovOperator(pointCoords, massMatrix, QQ, numEigs)

mesh.pointCoords = pointCoords;
mesh.massMatrix = massMatrix;
mesh.QQ = QQ;
mesh.nv = size(pointCoords,1);
mesh.steklovOperator = mesh.QQ;

[mesh.steklovBasis, mesh.eigenvalues] = eigs(mesh.steklovOperator, numEigs,'smallestabs');
mesh.eigenvalues = diag(mesh.eigenvalues);

end
