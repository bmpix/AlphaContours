function [pulledContours, pulledContoursToPlot] = pullContours_cpp(curves,cppContour,cppContourInner,edgeWidth,filename)

%% create a cell with all the contours
contours = [cppContour, cppContourInner];
nContours = numel(contours);

inputContours = contours;

%% remove duplicate points
for i=1:numel(contours)
    segmentLength = contours{i}-circshift(contours{i},1,1);
    segmentLength = sum(segmentLength.^2,2);
    contours{i}(segmentLength<1e-8,:) = [];
end

%% display input contours
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
% for i=1:numel(contours)
%     plot(contours{i}(:,1),-contours{i}(:,2),'LineWidth',1);
%end
for i=1:numel(curves)
    plot(curves{i}(:,1),-curves{i}(:,2),'black','LineWidth',edgeWidth);
end
hold off; axis equal; axis off;
%exportgraphics(f1, strcat('./output/',filename,'_input.pdf'), 'ContentType','vector');


%% combine all contour points in one matrix
contourPts = [];
contourIdx = [];
for i = 1:nContours
    contourPts = [contourPts; contours{i}];
    contourIdx = [contourIdx; i*ones(size(contours{i},1),1), (1:size(contours{i},1))'];
end

%% pull contours
ptIdx = [];
for k = 1:nContours
    for i = 1:size(contours{k},1)
        idxX = abs(contours{k}(i,1)-contourPts(:,1)) < 1e-10;
        idxY = abs(contours{k}(i,2)-contourPts(:,2)) < 1e-10;
        ptIdx = find(idxX>0 & idxY>0); %two point indices
        contIdx = contourIdx(ptIdx); %two contour indices

        if size(ptIdx,1) == 2 %if there are two overlapping points, we pull each point in respective normal direction

            for j = 1:size(ptIdx,1)
                m = contIdx(j);
                n = contourIdx(ptIdx(j),2);
                t = tangentAtT(contours{m},n);
                normal = [-t(2), t(1)];
                normal = normal/norm(normal);
                contours{m}(n,:) = contours{m}(n,:)+0.1*normal;
            end
        end
    end
end

pulledContours = contours;

%% close pulled contours for plot
pulledContoursToPlot = cell(1,nContours);

for k = 1:nContours
    pulledContoursToPlot{k} = [pulledContoursToPlot{k}; pulledContours{k}; pulledContours{k}(1,:)];
end

%% display contours
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
% for i = 1:numel(curves)
%     plot(curves{i}(:,1), -curves{i}(:,2),'black','LineWidth',0.3)
% end
for k=1:nContours
    % initial contours
    %plot(inputContours{k}(:,1),-inputContours{k}(:,2),'green'); 
    % pulled contours
    plot(pulledContoursToPlot{k}(:,1),-pulledContoursToPlot{k}(:,2),'LineWidth',edgeWidth);
end
hold off; axis equal; axis off;
%exportgraphics(f2, strcat('./output/',filename,'_pulled_contours.pdf'), 'ContentType','vector');

% f3 = figure('units','normalized','outerposition',[0 0 1 1]);
% plot(pulledContoursToPlot{1}(:,1),-pulledContoursToPlot{1}(:,2),'LineWidth',edgeWidth);
% axis equal; axis off;
%% check for duplicates: should be none
% contourPoints =[];
% for i = 1:numel(contours)
%     contourPoints = [contourPoints; contours{i}];
% end

% %check if there any duplicates in contours
% duplicatedPts = [];
% for i = 1:size(contourPoints,1)
%     idX = abs(contourPoints(i,1)-contourPoints(:,1))<1e-10;
%     idY = abs(contourPoints(i,2)-contourPoints(:,2))<1e-10;
%     id = find(idX>0 & idY>0);
%     if size(id,1)>1 
%         duplicatedPts = [duplicatedPts; id];
%     end
% end

end
