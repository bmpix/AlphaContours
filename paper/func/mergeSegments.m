function [mergedSegments] = mergeSegments(segments)
%MERGESEGMENTS: if the active segments of a curve follow one another, merge
%them together

nCurves = size(segments,2);
for j=1:nCurves
    found = true;
    while found
        found = false;
        for i=1:size(segments{j},1)
            cont = find(segments{j}(:,1)==segments{j}(i,2)); %found a continuation?
            if (~isempty(cont))
                newSegment = [segments{j}(i,1) segments{j}(cont,2)];
                segments{j}(i,:) = newSegment;
                segments{j}(cont,:) = [];
                found = true;
                break;
            end
        end
    end
end
mergedSegments = segments;
end