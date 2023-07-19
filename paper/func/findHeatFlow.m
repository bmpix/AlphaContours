function [] = findHeatFlow(L,M,X,T,edgeToTriangle,edgeWidth,filename)

%% number of vertices
n = size(X,1);

%% vertex index (place heat source)
i = 2393; %for Snail_more_pts
%i = 1112; %for turtle_more_pts

%% heat flow
u0 = zeros(n,1);
u0(i) = 1;
dt = 100;
u=u0;

T = edgeToTriangle; %to display the heat flow on sketch strokes; comment this line, if want to display over the sketch shape (Fig.7, Supplementary)

for i=1:5 
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    trimesh(T, X(:,1),-X(:,2), X(:,3), u,...
        'EdgeColor', 'interp', 'LineWidth', 1.75*edgeWidth);
    view(2);
    u = (M-L*dt)\(M*u);
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
%         exportgraphics(fig, strcat('./output/',filename,'_heat_flow_',num2str(i),'.pdf'), 'ContentType','vector');
%     end
end

end

