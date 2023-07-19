function [] = visualize_map_on_target(S1, S2, T12, edgeToTriangle, pointSize, edgeWidth, landmarks)
[g1,g2,g3] = set_mesh_color(S2);
    f1 = g1(T12);
    f2 = g2(T12);
    f3 = zeros(size(T12));
    %diplay vertices an edges of a mesh
    hold on;
    for i = 1:size(landmarks,1)
        scatter3(S1.surface.X(landmarks(i)), -S1.surface.Y(landmarks(i)), S1.surface.Z(landmarks(i)), ...
            3*pointSize, 'MarkerEdgeColor', 'none', 'MarkerFaceColor', [f1(landmarks(i)), f2(landmarks(i)), f3(landmarks(i))]);
    end

    %comment these two lines to display fmap on the sketch shape:
    tr = edgeToTriangle;
    S1.surface.TRIV = tr;
    
    trimesh(S1.surface.TRIV, S1.surface.X, -S1.surface.Y, S1.surface.Z, ...
        'FaceVertexCData', [f1, f2, zeros(size(f3))],...
        'FaceColor', 'interp', 'EdgeColor', 'interp', 'LineWidth', 0.75*edgeWidth); 
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
g3 = reshape(g3,[],1);

end

