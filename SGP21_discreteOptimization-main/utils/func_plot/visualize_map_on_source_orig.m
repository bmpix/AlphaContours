function [] = visualize_map_on_source_orig(S1, S2, T12)
[g1,g2,g3] = set_mesh_color(S2);
    f1 = g1(T12);
    f2 = g2(T12);
    f3 = zeros(size(T12));
    trimesh(S2.surface.TRIV, S2.surface.X, -S2.surface.Y, S2.surface.Z, ...
    'FaceVertexCData', [g1, g2, zeros(size(g3))],...
    'FaceColor', 'interp', 'EdgeColor', 'none'); axis equal; axis off; 
end


function [g1,g2,g3] = set_mesh_color(S)
g1 = normalize_function(0,1,S.surface.X);
g2 = normalize_function(0,1,S.surface.Y);
g3 = normalize_function(0,1,S.surface.Z);
g1 = reshape(g1,[],1);
g2 = reshape(g2,[],1);
g3 = reshape(g3,[],1);
end
