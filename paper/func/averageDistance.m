function [averageEdgeLength,maxEdgeLength] = averageDistance(X,Y)
%AVERAGE_DISTANCE Computes the average distance between 2 consecutive
%vertices

if nargin == 1
    % in this case, X is a cell array of Nx2 elements (has X and Y
    % coordinates for every curve).
    nCurves = size(X, 2);
    edgeLength = [];
    for i = 1:nCurves
        for j = 1:(size(X{i}, 1)-1)
            edgeLength = [edgeLength; norm(X{i}(j+1,:) - X{i}(j,:))];
        end
    end
    
    averageEdgeLength = mean(edgeLength);
    maxEdgeLength = max(edgeLength);
else
    %find number of curves
    nCurves = size(X,2);
    nPointsInCurve = cell(1,nCurves);
    
    %find number of points in each curve
    for i = 1:nCurves
        nPointsInCurve{i} = [nPointsInCurve{i}, size(X{i},1)];
    end
    
    %find lengths of all edges for all curves
    edgeLength = [];
    for i = 1:nCurves
        for j = 1:nPointsInCurve{i}-1
            edgeLength = [edgeLength; norm([X{i}(j+1) - X{i}(j), Y{i}(j+1) - Y{i}(j)])];
        end
    end
    
    averageEdgeLength = mean(edgeLength);
    maxEdgeLength = max(edgeLength);
    %dist = dist / (n-1);
end
end

