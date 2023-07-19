function [normal] = normalAtT(curve,t,side)
tangent = tangentAtT(curve,t);
normal = [tangent(:,2), -tangent(:,1)];

if (nargin > 2)
    %keep the normal if the head of a vector is on the same side as the current point
    [curSide, ~] = getSide(curve,t,normal);
    if (curSide~=side)
        normal = -normal;
    end
end
end

