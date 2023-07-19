function[] = heatFlowPointCloud(filename)

load(filename);

%% number of vertices
n = size(pts,1);

%% vertex index (heat source)
i = 2602; %for Snail_more_pts
%i = 3552; %for turtle_more_pts

%% heat slow
u0 = zeros(n,1);
u0(i) = 1;
dt = 100;
u=u0;

for i=1:5
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    scatter(pts(:,1), -pts(:,2), 27, u,'filled');
    view(2);
    u = (M+L*dt)\(M*u);
    if isMATLABReleaseOlderThan("R2022a")
        caxis([0 max(u)]);
    else
        clim([0 max(u)]);
    end
    hold off; axis off; axis equal;
    axis('tight');
    view(2);
    colormap parula;
%     if mod(i,5)==0
%         exportgraphics(fig, strcat('./output/',filename,'_heat_flow_point_cloud',num2str(i),'.pdf'), 'ContentType','vector');
%     end
end

end