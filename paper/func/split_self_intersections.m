function [new_bc,gapSegments] = split_self_intersections(bc)
%SPLIT_INTERSECTIONS Summary of this function goes here
%   Detailed explanation goes here
new_bc = bc;

%nCurves = size(bc,2);

k = 1;
gapSegments = {};
while k <= size(new_bc,2)
    nEdges = size(new_bc{k}, 1) - 1;
    flag_found_intersection = false;
    
    for e1 = 1:(nEdges-2)
        A = new_bc{k}(e1, :);
        B = new_bc{k}(e1+1, :);
        for e2 = (e1+2):nEdges
            C = new_bc{k}(e2, :);
            D = new_bc{k}(e2+1, :);
            
            if isParallel(A,B,C,D)
                continue;
            end
            
            if isIntersect(A,B,C,D)
                %split curve into 2
                flag_found_intersection = true;
                a = new_bc{k}(1:(e1+1), :);
                a(end,:) = a(end,:)+(a(end-1,:)-a(end,:))*1e-3;
                b = new_bc{k}((e1+1):end, :);
                b(1,:) = b(1,:)+(b(2,:)-b(1,:))*1e-3;
                gapSegments = [gapSegments; {[a(end,:);b(1,:)]}]; 
                new_bc{k} = a;
                new_bc{size(new_bc,2) + 1} = b;
                break;
            end
        end
        if flag_found_intersection
            break;
        end
    end
    k = k + 1;
end
end

function tmp = ccw(A,B,C)
    tmp = (C(2) - A(2)) * (B(1) - A(1)) > (B(2) - A(2)) * (C(1) - A(1));
end

function flag = isIntersect(A,B,C,D)
    flag = ccw(A,C,D) ~= ccw(B,C,D) && ccw(A,B,C) ~= ccw(A,B,D);
end

function flag = isParallel(A,B,C,D)
    v1 = [B-A 0];
    v2 = [D-C 0];
    c = cross(v1,v2);
    
    flag = abs(c(3)) < 1e-7;
end