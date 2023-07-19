function[] = heat_flow_raster(filename)

filename = strcat('input/',filename,'_rasterized.png');

img = imread(filename);

bwImg = 255-sum(img,3)/3;

%dilation raduis alpha is computed for the vector drawing, now it is a radius in pixels 
% for turtle_more_pts:
%alpha = 5.53235; 
% for Snail_more_pts:
alpha = 4.73819; 

se = strel("disk",ceil(alpha));
dilatedImg = imdilate(bwImg,se);
imshow(dilatedImg);

%if no dilation, assing:
%dilatedImg = bwImg;

narrowBand = dilatedImg > 10;

n = nnz(narrowBand);

G = binaryImageGraph(narrowBand,4);
L = -laplacian(G);
M = speye(n);

%for Snail_more_pts:
%i = 12000;
%for turtle_more pts:
i=17000; %do not remember index used in the paper

u0 = zeros(n,1);
u0(i) = 1;
dt = 1000;
u=u0;


for i=1:5 %1:50
    fig = figure('units','normalized','outerposition',[0 0 1 1]);
    imgTemp = zeros(size(dilatedImg));
    imgTemp(G.Nodes.PixelIndex) = u;
    %imshow(imgTemp);
    surf(imgTemp)
    shading interp
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

%further, the blue image background is removed using Photoshop
%to display the heat flow on the sketch strokes of the raster image, use mask in Photoshop
