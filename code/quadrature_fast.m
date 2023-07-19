function [r] = quadrature_fast(pts,lengths,regionBoundaries_k,openCurve,p_i)
    %returns f integrated on each element (pts[i],pts[i+1])
    %trapezoid integration, might have used matlab's trapz() as well
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
        fs = fundamentalSolutionIntegral(p_i,myPts,next_pts);
        if (size(fs,1)>size(lengths{boundaryIdx},1)) %remove the last element for open curves
            fs(end,:) = [];
        end        
        r = [r; fs*sgn];
    end
end