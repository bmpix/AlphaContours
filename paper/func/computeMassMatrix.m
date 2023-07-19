function [pointCoords,shiftedCoords,diffCoords,calcDistances,shiftedDistances,sumDistances,massMatrix] = computeMassMatrix(boundaryCurve)
%function [pointCoords,shiftedCoords,diffCoords,massMatrix] = computeMassMatrix(boundaryCurve)

for k=1:numel(boundaryCurve)
    %nv{k} = size(boundaryCurve{k});
    pointCoords{k} = [boundaryCurve{k}];
    shiftedCoords{k} = circshift(boundaryCurve{k},-1,1); 
    diffCoords{k} = shiftedCoords{k}-pointCoords{k};
    diffCoords{k}(end,:) = [];
    %massMatrix{k}=diag(0.5*sum(diffCoords{k}.^2,2));
    calcDistances{k} = sum(diffCoords{k}.^2,2);
    shiftedDistances{k} = circshift(calcDistances{k},-1,1);
    sumDistances{k} = shiftedDistances{k}+calcDistances{k};
    massMatrix{k}=diag(0.5*sum(sumDistances{k},2)); 
%     massMatrix{k} = eye(size(diffCoords{k},1));
end       

%N = cell2mat(nv);
%N = N(:,1:2:end);

end
