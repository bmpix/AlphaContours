function [newBoundaryCurve] = splitSharpAngles(boundaryCurve)
newBoundaryCurve = [];
for i=1:numel(boundaryCurve)
    curveSize = size(boundaryCurve{i},1);
    shr = circshift(boundaryCurve{i},1,1);
    shl = circshift(boundaryCurve{i},-1,1);
    x = dot(boundaryCurve{i}-shr,shl-boundaryCurve{i},2);
    x(1) = 0; x(end) = 0;
    splitVerts = find(x<0);
    splitVerts = sort(splitVerts);
    idx = [1; splitVerts; curveSize];
    for j=1:numel(idx)-1
        if (idx(j+1)-idx(j)>2)
            newBoundaryCurve = [newBoundaryCurve; {boundaryCurve{i}(idx(j):idx(j+1),:)}];
            if (j~=numel(idx)-1)
                newBoundaryCurve{end}(end,:) = newBoundaryCurve{end}(end-1,:)+(newBoundaryCurve{end}(end,:)-newBoundaryCurve{end}(end-1,:))*(1-1e-3);
            end
            if (j~=1)
                newBoundaryCurve{end}(1,:) = newBoundaryCurve{end}(2,:)-(newBoundaryCurve{end}(2,:)-newBoundaryCurve{end}(1,:))*(1-1e-3);
            end
        end
    end
end
newBoundaryCurve = newBoundaryCurve';
end