%first run python nsharpy. It will generate 'matlab_matrices'
clear
close all

input_name = 'bunny';

load(strcat('../inputs/',input_name)) %load Laplacian, Mass matrix and input points
%[V,D] = eigs(L,10,'smallestabs');
t = 10; %or t=100000 for heat eq
delta = zeros(size(L,1),1); % u_0
delta(18000) = 1;
prev = zeros(size(L,1),1); %for wave eq u_{k-1}
prev(16000) = -5;
%u = (M+t*L)\delta; %heat eq
u = (M+t*t*L)\(M*(2*delta-prev)); %wave eq
scatter(pts(:,1),-pts(:,2),10,u,'filled');
colormap parula
axis equal
axis off
%%
%comparison with actual laplacian
[V,F] = load_mesh(strcat('../processed/',input_name,'_unions.obj'));
L_gt = cotmatrix(V,F); %'ground truth' Laplacian
M_gt = massmatrix(V,F);
delta_gt = zeros(size(L_gt,1),1);
delta_gt(5748) = 1;
prev_gt = zeros(size(L_gt,1),1);
prev_gt(5747) = -5;
%u_gt = (M_gt+t*L_gt)\delta_gt;
u_gt = (M_gt+t*t*L_gt)\(M_gt*(2*delta_gt-prev_gt));
figure;
colormap parula
axis equal
axis off
options.face_vertex_color = u_gt;
%plot_mesh([V(:,1),-V(:,2),V(:,3)],F,options)
fig = tsurf(F,[V(:,1),-V(:,2),V(:,3)],'FaceColor','interp', 'FaceLighting','phong', 'EdgeColor','none');
set(fig,fphong,'FaceVertexCData',u_gt);
axis equal
axis off
