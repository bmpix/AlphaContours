function [r] = quadrature(f,pts,lengths,regionBoundaries_k,openCurve)
    %returns f integrated on each element (pts[i],pts[i+1])
    %trapezoid integration, might have used matlab's trapz() as well
    K = 1000;
    r = [];
    for j=1:numel(regionBoundaries_k)
        boundaryIdx = regionBoundaries_k(j);
        sgn = sign(boundaryIdx);        
        boundaryIdx = abs(boundaryIdx);
        if (openCurve(boundaryIdx))
            sgn = 2*sgn;
        end
        myPts = pts{boundaryIdx};
        next_pts = circshift(myPts,-1,1);
        sampled_pts = zeros(size(myPts,1),2,K);
        for i=1:K
            sampled_pts(:,:,i) = myPts+((i-1)/(K-1))*(next_pts-myPts);
        end
        fx = f(sampled_pts(:,1,:),sampled_pts(:,2,:)); %NxK
        fx = squeeze(fx);
        if (size(fx,1)>size(lengths{boundaryIdx},1)) %remove the last element for open curves
            fx(end,:) = [];
        end
        r = [r; sgn*(sum(fx(:,2:end-1),2)+fx(:,1)./2+fx(:,end)./2).*lengths{boundaryIdx}./K];
    end
    %r_matlab = transpose(trapz(transpose(fx))).*lengths./K;
end