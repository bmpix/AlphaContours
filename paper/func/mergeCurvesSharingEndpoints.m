function [boundaryCurve,openCurve] = mergeCurvesSharingEndpoints(boundaryCurve,openCurve)
flagMergedCurves = true;
%if curves have the same endpoint, merge them

while flagMergedCurves
    flagMergedCurves = false;
    nCurves = numel(boundaryCurve);
    for i = 1:nCurves-1
        for j = i+1:nCurves
            threshold = 1e-10;
            dist00 = norm(boundaryCurve{i}(1,:) - boundaryCurve{j}(1,:));
            dist01 = norm(boundaryCurve{i}(1,:) - boundaryCurve{j}(end,:));
            dist10 = norm(boundaryCurve{i}(end,:) - boundaryCurve{j}(1,:));
            dist11 = norm(boundaryCurve{i}(end,:) - boundaryCurve{j}(end,:));
            if min([dist00,dist01,dist10,dist11])<threshold
                flipJ = (dist01 < threshold) || (dist11 < threshold);
                flipI = (dist01 < threshold) || (dist00 < threshold);
                if flipI
                    boundaryCurve{i} = flip(boundaryCurve{i},1);
                end
                if flipJ
                    boundaryCurve{j} = flip(boundaryCurve{j},1);
                end
                boundaryCurve{i} = [boundaryCurve{i}; boundaryCurve{j}(2:end,:)];
                boundaryCurve{j} = [];
                openCurve(j) = [];
                boundaryCurve = boundaryCurve(~cellfun(@isempty, boundaryCurve));
                flagMergedCurves = true;
                break;
            end
        end
        if flagMergedCurves
            break;
        end
    end
end

end