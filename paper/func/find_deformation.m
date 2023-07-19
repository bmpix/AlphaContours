function U = find_deformation(nodes,triangles,edgeToTriangle,filename,edgeWidth)

close all;

%% display input
f1 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on
trimesh(edgeToTriangle, nodes(:,1), -nodes(:,2), nodes(:,3), 'LineWidth', edgeWidth, 'EdgeColor', 'black');
view(2);
hold off; axis equal; axis off;
%exportgraphics(f1, strcat('./output/arap/',filename,'_arap_deform_input.pdf'), 'ContentType','vector');

%% find coordiantes of vertices after deformation
nodes3D = nodes;

%% inputs

% % Rabbit_05
b10 = 237; %left ear
b11 = 99; %right ear
b20 = [926:4:950]'; %head
b = [b10;b11;b20]; % all handles

% Fox_072
% b10 = 1304; %nose
% b11 = 269; %tale
% b12 = 1342; %neck
% b13 = [1128,1060]'; %ears
% b14 = 728; %728; %paw
% b15 = 1215; %1940; %back
% b16 = 944; %chest
% b17 = 2896; %paw
% b20 = [1864:3:1876,844:3:854,1595:3:1608]'; %fixed handles
% b = [b10;b11;b12;b13;b14;b15;b16;b17;b20]; %all handles

%% new input deformation

% % Rabbit_05
% bc10 = nodes3D(b10,:) + [-100,20,0]; %left ear 
% bc11 = nodes3D(b11,:) + [-80,-50,0]; %right ear 
% bc20 = nodes3D(b20,:);

% Fox_072
bc10 = nodes3D(b10,:) + [30,-50,0]; %nose 
bc11 = nodes3D(b11,:) + [45,55,0]; %tale
bc12 = nodes3D(b12,:) + [30,-50,0]; %neck 
bc13 = nodes3D(b13,:) + [30,-50,0]; %ears 
bc14 = nodes3D(b14,:) + [-30,0,0]; %paw
bc15 = nodes3D(b15,:) + [25,-35,0]; %back
bc16 = nodes3D(b16,:) + [20,-45,0]; %chest
bc17 = nodes3D(b17,:) + [0,-5,0]; %paw
bc20 = nodes3D(b20,:); %fixed handles


%% deformation

% Rabbit_05
bc = [bc10;bc11;bc20];

% % Fox_072
%bc = [bc10;bc11;bc12;bc13;bc14;bc15;bc16;bc17;bc20];

[U,data,SS,R] = arap(nodes3D, triangles, b, bc);

% display deformed mesh:
f2 = figure('units','normalized','outerposition',[0 0 1 1]);
hold on;
trimesh(edgeToTriangle, U(:,1), -U(:,2), U(:,3), ...
         'FaceColor', 'none', 'EdgeColor', 'black', 'LineWidth', edgeWidth); 

% display handles:

% Rabbit_05
scatter(bc10(:,1),-bc10(:,2), 200,'o','fill','yellow','MarkerEdgeColor','black','LineWidth',edgeWidth);
scatter(bc11(:,1),-bc11(:,2), 200,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
scatter(bc20(:,1),-bc20(:,2), 200,'o','fill','red','MarkerEdgeColor','black','LineWidth',edgeWidth);

% % Fox_072
% scatter(bc10(:,1),-bc10(:,2), 320,'o','fill','yellow','MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc11(:,1),-bc11(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc12(:,1),-bc12(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc13(:,1),-bc13(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc14(:,1),-bc14(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc15(:,1),-bc15(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc16(:,1),-bc16(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc17(:,1),-bc17(:,2), 320,'o','fill','yellow', 'MarkerEdgeColor','black','LineWidth',edgeWidth);
% scatter(bc20(:,1),-bc20(:,2), 320,'o','fill','red','MarkerEdgeColor','black','LineWidth',edgeWidth);

hold off; axis equal; axis off;
%exportgraphics(f2, strcat('./output/arap/',filename,'_arap_deform_output.pdf'), 'ContentType','vector');

end