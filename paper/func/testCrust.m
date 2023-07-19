points = [];
for k = 1:numel(boundaryCurve)
    points = [points; boundaryCurve{k}];
end

P = points;
[CE,PC] = crust(P);

f1 = figure('units','normalized','outerposition',[0 0 1 1]);
%scatter(PC(:,1),PC(:,2));
hold on;
for i = 1:size(CE,1)
plot([PC(CE(i,1),1),PC(CE(i,2),1)],-[PC(CE(i,1),2),PC(CE(i,2),2)],'LineWidth', edgeWidth, 'Color', '#971D8A');
end
hold off; axis equal; axis off;
%exportgraphics(f1, strcat('./output/',filename,'_crust.pdf'), 'ContentType','vector');