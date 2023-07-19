%% Steklov operator: display eigenfunctions on contours

assert(numel(contours) == 1) %only works for a single contour

%remove duplicate points
for i=1:numel(contours)
    segmentLength = contours{i}-circshift(contours{i},1,1);
    segmentLength = sum(segmentLength.^2,2);
    contours{i}(segmentLength<1e-10,:) = [];
end

%visualize that single contour
% figure;
% hold on;
% scatter(contours{1}(:,1),-contours{1}(:,2),5,'black','filled'); %contour points
% scatter(contours{1}(1,1),-contours{1}(1,2),15,'blue','filled'); %contour starting point
% scatter(contours{1}(end,1),-contours{1}(end,2),15,'red','filled'); %countour endpoint
% hold off; axis equal; axis on;

openCurve = false(numel(contours),1);

[lengths,tangents,tangents_cmplx,normals,normals_cmplx,allTangents,next,curveSize] =  computeTangentsEtc(contours,openCurve);

%compute \hat{H}_{ij} and G_{ij} by numerically integrating the fundamental solution. 
%Notations agree with https://web.stanford.edu/class/energy281/BoundaryElementMethod.pdf
%we're assuming there is a single region now
regionBoundaries = 1:numel(contours);
regionBoundaries(1) = -1;
[G, H, QQ] = computeMatricesForARegion(lengths,tangents_cmplx,normals,normals_cmplx,next,contours,regionBoundaries,curveSize,openCurve);
%those QQ matrices should be like little laplacians

for k=1:numel(contours)
    [pointCoords,shiftedCoords,diffCoords,calcDistances,shiftedDistances,sumDistances,massMatrix] = computeMassMatrix(contours);
end

%% Steklov operator

numEigs = 100;

Src = MeshInfoSteklovOperator(pointCoords, massMatrix, QQ, numEigs);

%% Visualize eigenfunctions

fprintf('Visualizing results\n');

f = Src.steklovBasis;

%% interoplation business
curveVerts(1) = 1;
for k=1:numel(contours)
    curveVerts(k+1)=curveVerts(k)+curveSize(k);
end

for i=1:16 %in the paper: i = 2, 3, 4, 6, 8, 16
    f_interp = {};
    boundary_val = f(:,i);
    boundary_normal_val= G\(H*boundary_val);
    for k1 = 1:numel(boundaryCurve)
        for j=1:size(boundaryCurve{k1},1)
            
            p = boundaryCurve{k1}(j,:);
            
            vertexOnTheContour = false;
            for kk = 1:numel(contours)
                dd = contours{kk}-p;
                [val, idx] = min(sum(dd.^2,2)); %then the vertex is on the contour
                if (val < 1e-6)
                    vertexOnTheContour = true;
                    f_interp{k1}(j) = boundary_val(curveVerts(kk)+idx-1);
                    break;
                end
            end

            if ~vertexOnTheContour
                G_i = quadrature_fast(contours,lengths,regionBoundaries,openCurve,p);
                H_hat_i = quadrature_directional_derivative_fast(contours,lengths,normals,regionBoundaries,openCurve,p);
                f_interp{k1}(j) = dot(G_i,boundary_normal_val)-dot(H_hat_i,boundary_val);
            end
        end
    end

    %turn edges between curve points into triangles
    edgesForCurves = cell(1,numel(boundaryCurve));
    for k2 = 1:numel(boundaryCurve)
        for j = 1:size(boundaryCurve{k2},1)-1
            edgesForCurves{k2} = [edgesForCurves{k2}; j, j+1, j];
        end
    end

    f1 = figure('units','normalized','outerposition',[0 0 1 1]);
    hold on
    for k1=1:numel(boundaryCurve)
        trimesh(edgesForCurves{k1},boundaryCurve{k1}(:,1),-boundaryCurve{k1}(:,2),zeros(size(boundaryCurve{k1},1),1), 'FaceVertexCData', f_interp{k1}', 'FaceColor', 'none', 'EdgeColor', 'interp','LineWidth', 3.5*edgeWidth);
    end
    axis equal; axis off;
    
    % export image in vector format:
    %exportgraphics(f1, strcat('./output/Steklov/',filename, '_Steklov_eig_', num2str(i), '.pdf'), 'ContentType','vector');
    % export image as .png in high resolution:
    %exportgraphics(f1, strcat('./output/Steklov/',filename, '_Steklov_eig_', num2str(i), '.png'), 'Resolution',300);

end

return