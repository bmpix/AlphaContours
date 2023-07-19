function [f] = dFundamentalSolution(centerX, centerY)
    function result = g(x,y)
        dx(:,:,1) = x-centerX;
        dx(:,:,2) = y-centerY;
        result = (-1./(2*pi*((x-centerX).^2+(y-centerY).^2))).*dx;
    end
 f = @g;
 %f = @(x,y)(-1/(2*pi*((x-centerX).^2+(y-centerY).^2))).*dx; %todo: check
end