function [E, c0_boundary, c2_boundary,G,H,QQ] = minDirichlet(boundaryCurve, openCurve, regionBoundaries, indicesPerRegion, curveSize)
[lengths,~,tangents_cmplx,normals,normals_cmplx,allTangents,next,~] =  computeTangentsEtc(boundaryCurve,openCurve);
totalNVerts = sum(curveSize);
bigQ = sparse(2*totalNVerts,2*totalNVerts);

for k=1:numel(regionBoundaries)
    [G{k}, H{k}, QQ{k}] = computeMatricesForARegion(lengths,tangents_cmplx,normals,normals_cmplx,next,boundaryCurve,regionBoundaries{k},curveSize,openCurve);
    bigQ(indicesPerRegion{k},indicesPerRegion{k}) = bigQ(indicesPerRegion{k},indicesPerRegion{k})+QQ{k};
end

%fprintf("Matrices done, inverting\n");

bigQ(totalNVerts+1:end,totalNVerts+1:end) = bigQ(1:totalNVerts,1:totalNVerts);
A_full = speye(totalNVerts,2*totalNVerts);
A_full((totalNVerts^2+1):(totalNVerts+1):end) = allTangents.^2;
b_full = -allTangents.^4;
A_ext = sparse(3*totalNVerts,3*totalNVerts);
A_ext(1:2*totalNVerts,1:2*totalNVerts) = bigQ;
A_ext(1:2*totalNVerts,2*totalNVerts+1:end) = A_full';
A_ext(2*totalNVerts+1:end,1:2*totalNVerts) = A_full;
b_ext = sparse(3*totalNVerts,1);
b_ext(2*totalNVerts+1:end) = b_full;
sol = A_ext \ b_ext;
c0_boundary = sol(1:totalNVerts);
c2_boundary = sol((totalNVerts+1):2*totalNVerts);

%fprintf("Inversion done, computing energy\n");
%% Compute energy
energies = [];
for k=1:numel(regionBoundaries)-1
    c0_cut = c0_boundary(indicesPerRegion{k}); c2_cut = c2_boundary(indicesPerRegion{k});
    energies = [energies; c0_cut'*QQ{k}*c0_cut+c2_cut'*QQ{k}*c2_cut];
end

E = real(sum(energies));
end

