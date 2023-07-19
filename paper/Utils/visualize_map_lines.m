function visualize_map_lines(S1,S2,map,samples)

    X1 = S1.X(:,1);
    Y1 = S1.X(:,2);
    Z1 = S1.X(:,3);
    
    X2 = S2.X(:,1);
    Y2 = S2.X(:,2);
    Z2 = S2.X(:,3);

    g1 = normalize_function(0.1,0.99,Y2);
    %g2 = normalize_function(0.1,0.99,Z2);
    g2 = ones(size(Z2));
    g3 = normalize_function(0.1,0.99,X2);

    f1 = g1(map);
    f2 = g2(map);
    f3 = g3(map);

    % plot semi-transparent meshes
%     trimesh(S1.T, X1, Y1, Z1, ...
%         'FaceVertexCData', [f1 f2 f3], 'FaceColor','interp', ...
%         'FaceAlpha', 0.6, 'EdgeColor', 'none'); axis equal;

    scatter(X1, -Y1, 10, [f1 f2 f3],'filled');
    axis equal;
    
    xdiam = 3/2*(max(X2)-min(X2));
%     trimesh(S2.T, X2+xdiam, Y2, Z2, ...
%         'FaceVertexCData', [g1 g2 g3], 'FaceColor','interp', ...
%         'FaceAlpha', 0.6, 'EdgeColor', 'none'); axis equal;

    scatter(X2+xdiam, -Y2, 10, [g1 g2 g3], 'filled'); 
    axis equal;
    
    if (~isempty(samples))
        target_samples = map(samples);
        
        Xstart = X1(samples)'; Xend = X2(target_samples)';
        Ystart = Y1(samples)'; Yend = Y2(target_samples)';
        Zstart = Z1(samples)'; Zend = Z2(target_samples)';
        
        Xend = Xend+xdiam;
        Colors = [f1 f2 f3];
        ColorSet = Colors(samples,:);
        set(gca, 'ColorOrder', ColorSet);
        %set(gca,'ColorOrder', parula);
        plot3([Xstart; Xend], [Ystart; Yend], [Zstart; Zend]);
        %plot([Xstart; Xend], [Ystart; Yend]);
    end    
end

%          co = [1    0  0.4
%               0.8  0.2  0.5
%               0.6  0.4  0.6
%               0.4  0.6  0.7
%               0.2  0.8  0.8
%               0    1  0.9];