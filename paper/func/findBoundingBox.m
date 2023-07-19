function [xmin,xmax,ymin,ymax] = findBoundingBox(curves)
 allPts = []; 
 for i=1:numel(curves)
  allPts = [allPts; curves{i}];
 end
 xmin = min(allPts(:,1));
 xmax = max(allPts(:,1));
 ymin = min(allPts(:,2));
 ymax = max(allPts(:,2));
end