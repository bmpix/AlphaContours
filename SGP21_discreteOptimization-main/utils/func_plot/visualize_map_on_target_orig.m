function [] = visualize_map_on_target_orig(S1, S2, T12)
[g1,g2,g3] = set_mesh_color(S2);
    f1 = g1(T12);
    f2 = g2(T12);
    f3 = g3(T12);
    trimesh(S1.surface.TRIV, S1.surface.X, -S1.surface.Y, S1.surface.Z, ...
    'FaceVertexCData', [f1, f2, zeros(size(f3))],...
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
