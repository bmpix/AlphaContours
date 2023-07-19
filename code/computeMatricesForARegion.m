function [G, H, QQ] = computeMatricesForARegion(lengths,tangents_cmplx,normals,normals_cmplx,next,boundaryCurve,regionBoundaries,curveSize,openCurve)
n = 0;

for jSigned=regionBoundaries
    j = abs(jSigned);
    n = n + curveSize(j);
end

H_hat = zeros(n,n); %warning, dense matrix
G = zeros(n,n);
idx = 1;
Gdiag = [];
signs = [];
for jSigned=regionBoundaries
    j = abs(jSigned);
    sgn = sign(jSigned);
    all_p_i = 0.5*(boundaryCurve{j}+next{j});
    if (openCurve(j))
        all_p_i(end,:) = [];
    end
    
    %G(idx:idx+curveSize(j)-1,:) = quadrature_faster(boundaryCurve,regionBoundaries,openCurve,all_p_i);
    G(idx:idx+size(all_p_i,1)-1,:) = quadrature_faster(boundaryCurve,regionBoundaries,openCurve,all_p_i,curveSize);
    H_hat(idx:idx+size(all_p_i,1)-1,:) = quadrature_directional_derivative_faster(boundaryCurve,lengths,normals,regionBoundaries,openCurve,all_p_i,curveSize);
    
    for i=1:curveSize(j)
        %p_i = 0.5*(boundaryCurve{j}(i,:)+next{j}(i,:)); %collocation at the middle node of each element
        %cmpG(idx,:)=quadrature_fast(boundaryCurve,lengths,regionBoundaries,openCurve,p_i);
        %cmpH(idx,:)=quadrature_directional_derivative_fast(boundaryCurve,lengths,normals,regionBoundaries,openCurve,p_i);
        idx = idx + 1;
    end
    
    signs = [signs; ones(curveSize(j),1)*sgn];
    if openCurve(j)
        sgn = 2*sgn;
    end
    Gdiag = [Gdiag; sgn*lengths{j}./(2.0*pi).*(1.0-log(lengths{j}/2.0))];
end

%diagonal is a little dangeours from numerical stability point of view
%=> compute analytically
G(1:(n+1):end) = Gdiag;
H_hat(1:(n+1):end)=zeros(n,1);

idDiag = [];
for jSigned=regionBoundaries
    j = abs(jSigned);
    if (openCurve(j))
        idDiag = [idDiag; ones(curveSize(j),1)];
    else
        idDiag = [idDiag; 0.5*ones(curveSize(j),1)];
    end
end

H = H_hat + diag(idDiag);

all_tangents_for_this_region = [];
all_lengths_for_this_region = [];
all_normals_for_this_regions = [];
for jSigned=regionBoundaries
    j = abs(jSigned);
    all_tangents_for_this_region = [all_tangents_for_this_region; tangents_cmplx{j}];
    all_normals_for_this_regions = [all_normals_for_this_regions; normals_cmplx{j}];
    all_lengths_for_this_region = [all_lengths_for_this_region; lengths{j}];
end

Q = inv(G)*H;
M = signs.*diag(all_lengths_for_this_region);

%operator computing integral of the Dirichlet energy in the domain
%given function values on the boundary
QQ = M*Q;
QQ = 0.5*(QQ+QQ');
end

