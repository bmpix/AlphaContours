function [boundaryCurve,openCurve,gapSegments,averageDistBtSamples,figureCount] = preprocessCurves(boundaryCurve,openCurve,resDist,pointSize,edgeWidth,edgeColor,filename,figureCount)

% flip curves
nCurves = numel(boundaryCurve);

% display curves
figure('units','normalized','outerposition',[0 0 1 1]);
for k = 1:nCurves
    hold on;
    line(boundaryCurve{k}(:,1), -boundaryCurve{k}(:,2), 'LineStyle', '-', 'LineWidth', edgeWidth, 'Color', edgeColor);
    scatter(boundaryCurve{k}(:,1), -boundaryCurve{k}(:,2), pointSize, 'o', 'filled');  
end
hold off; axis equal; axis off;
figureCount = figureCount+1;
exportgraphics(figure(figureCount), strcat('./output/',filename,'_original_curves.pdf'), 'ContentType','vector');


%merge curves "sharing" endpoints
[boundaryCurve,openCurve] = mergeCurvesSharingEndpoints(boundaryCurve,openCurve);

%split curves at sharp angles
boundaryCurve = splitSharpAngles(boundaryCurve);

% split self-intersecting curves. move the endpoints of new curves a tiny
% bit away from each other. save these 'tiny bits' into gapSegments
[boundaryCurve,gapSegments] = split_self_intersections(boundaryCurve);

% resample boundary curves
setResampleDistance(resDist);
for k = 1:size(boundaryCurve,2)
   boundaryCurve{k} = resample_polygon(boundaryCurve{k},[],getResampleDistance);
   sampleDistance = getResampleDistance/2;
   while size(boundaryCurve{k},1) <= 2
       boundaryCurve{k} = resample_polygon(boundaryCurve{k},[],sampleDistance);
       sampleDistance = sampleDistance/2;
   end    
end

% set the canvas dimensions
setGlobalCanvasSize(boundaryCurve);

% set a "bootstep step"
setBootstrapStep([-1,0]);

% decide on a fixed radius
averageDistBtSamples = averageDistance(boundaryCurve);
end

