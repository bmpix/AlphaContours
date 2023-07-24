function [r] = quadrature_faster(pts,regionBoundaries_k,openCurve,all_p_i,curveSize)
    %returns f integrated on each element (pts[i],pts[i+1])
    %trapezoid integration, might have used matlab's trapz() as well
    r = [];
    for j=1:numel(regionBoundaries_k)
        boundaryIdx = regionBoundaries_k(j);
        sgn = sign(boundaryIdx);        
        boundaryIdx = abs(boundaryIdx);
        myPts = pts{boundaryIdx};
        next_pts = circshift(myPts,-1,1);     
        tau = next_pts-myPts;
        
        if (openCurve(boundaryIdx))
            sgn = 2*sgn;
            myPts(end,:) = [];
            tau(end,:) = [];
        end
        
        
        m = curveSize(boundaryIdx);
        n = size(all_p_i,1);
        a = repmat((tau(:,1).^2+tau(:,2).^2)',n,1);
        b = -2*all_p_i(:,1)*tau(:,1)'+(-2).*all_p_i(:,2)*tau(:,2)'+2.*repmat(myPts(:,2).*tau(:,2)+myPts(:,1).*tau(:,1),1,n)';
        c = repmat(all_p_i(:,1).^2+all_p_i(:,2).^2,1,m)+(-2)*all_p_i(:,1)*myPts(:,1)'+(-2)*all_p_i(:,2)*myPts(:,2)'+repmat((myPts(:,1).^2+myPts(:,2).^2)',n,1);
        dl = sqrt(a);
        fun = @(x)(-dl/(2*pi)).*((1/4).*a.^(-1).*((-4).*a.*x+2.*((-1).*b.^2+4.*a.*c).^(1/2).*atan(((-1).*b.^2+4.*a.*c).^(-1/2).*(b+2.*a.*x))+(b+2.*a.*x).*log(c+x.*(b+a.*x))));
        fs = fun(ones(n,m))-fun(zeros(n,m));      
        r = [r fs*sgn];
    end
end