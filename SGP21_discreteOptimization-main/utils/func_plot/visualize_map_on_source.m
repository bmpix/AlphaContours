function [] = visualize_map_on_source(S1, S2, T12, edgeToTriangle,pointSize,edgeWidth,landmarks)
[g1,g2,g3] = set_mesh_color(S2);

    %diplay vertices an edges of a mesh
    hold on;
    for i = 1:size(landmarks,1)
        scatter3(S2.surface.X(landmarks(i)), -S2.surface.Y(landmarks(i)), S2.surface.Z(landmarks(i)), ...
            3*pointSize, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', [g1(landmarks(i)), g2(landmarks(i)), g3(landmarks(i))]);
    end

    %comment these two lines to display fmap on the sketch shape:
    tr = edgeToTriangle;
    S2.surface.TRIV = tr;

    trimesh(S2.surface.TRIV, S2.surface.X, -S2.surface.Y, S2.surface.Z, ...
        'FaceVertexCData', [g1, g2, zeros(size(g3))],...
        'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth',0.75*edgeWidth);
    colormap("parula");
    hold off; axis equal; axis off;
end


function [g1,g2,g3] = set_mesh_color(S)

% for Fig.6 of Supplementary, uncomment one of the following lines depending on the input:
%n = 3; %for Hummingbird_11, Bird, Fox_07, Spider_Man_07
%n = 5; %for daisy_dashed, Rabbit_05, Wizard_06, Witch_08

g1 = normalize_function(0,1,S.surface.X);
%g1 = normalize_function(0,1,sin(S.surface.X*n)); %for Fig.6 of Supplementary
g2 = normalize_function(0,1,S.surface.Y);
%g2 = normalize_function(0,1,sin(S.surface.Y*n)); %for Fig.6 of Supplementary
g3 = normalize_function(0,1,S.surface.Z);
g1 = reshape(g1,[],1);
g2 = reshape(g2,[],1);
g3 = zeros(size(g2));

end

