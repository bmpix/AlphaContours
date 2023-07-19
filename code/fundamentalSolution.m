function [f] = fundamentalSolution(centerX, centerY)
 f = @(x,y)((-1/(2*pi))*log(sqrt((x-centerX).^2+(y-centerY).^2)));
end