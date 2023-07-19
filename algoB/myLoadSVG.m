function [paths] = myLoadSVG(file)
%MYLOADSVG Loads svg outputed by Strokestrip (the _fit.svg ones).

paths = {};

xDoc = xmlread(file);
xPaths = xDoc.getElementsByTagName('path');

nPaths = xPaths.getLength;
for i = 0:(nPaths-1)
    p = xPaths.item(i).getAttribute('d');
    % p is a string, need to parse
    pSplit = split(p,' ');
    pSplit(1:3:end) = [];
    pSplit = str2num(pSplit);
    nPoints = (size(pSplit, 1)) / 2 + 1;
    tmpPath = reshape(pSplit, [2,nPoints-1])';
    % close path
    tmpPath(end+1,:) = tmpPath(1,:);
    paths{i+1} = tmpPath;
end
end

