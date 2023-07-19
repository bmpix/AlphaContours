function rVal = display_progress(boundaryCurve, contours)
%DISPLAY_PROGRESS Summary of this function goes here
%   Detailed explanation goes here
rVal = true;

figure('name', 'display_progress');
hold on;
for i = 1:size(boundaryCurve,2)
        plot(boundaryCurve{i}(:,1), -boundaryCurve{i}(:,2), '.', 'MarkerSize', 4);
        line(boundaryCurve{i}(:,1), -boundaryCurve{i}(:,2), 'Color', 'blue', 'LineStyle', ':');
        axis equal
end
if nargin > 1
    if iscell(contours)
        for i = 1:size(contours,2)
            c = rand(1,3);
            %line(contours{i}(:,1), contours{i}(:,2), 'Color', '#D95319', 'LineStyle', ':', 'LineWidth', 1.2);
            line(contours{i}(:,1), -contours{i}(:,2), 'Color', c, 'LineStyle', ':', 'LineWidth', 1.2);
            plot(contours{i}(:,1), -contours{i}(:,2), '.', 'MarkerSize', 6, 'Color', c);
        end
    else
        c = rand(1,3);
        %line(contours(:,1), contours(:,2), 'Color', '#D95319', 'LineStyle', ':', 'LineWidth', 1.2);
        line(contours(:,1), -contours(:,2), 'Color', c, 'LineStyle', ':', 'LineWidth', 1.2);
        plot(contours(:,1), -contours(:,2), '.', 'MarkerSize', 6, 'Color', c);
        for i=1:size(contours,1)
            text(contours(i,1), -contours(i,2), int2str(i));
        end
    end
end
axis equal;
end

