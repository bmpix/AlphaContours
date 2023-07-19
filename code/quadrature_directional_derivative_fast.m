function [r] = quadrature_directional_derivative_fast(pts,lengths,normals,regionBoundaries_k,openCurve,p_i)
r = [];
for j=1:numel(regionBoundaries_k)
    boundaryIdx = regionBoundaries_k(j);
    sgn = sign(boundaryIdx);
    boundaryIdx = abs(boundaryIdx);
    if (~openCurve(boundaryIdx))
        myPts = pts{boundaryIdx};
        next_pts = circshift(myPts,-1,1);
        
        vv = next_pts-myPts;
        taux = vv(:,1);
        tauy = vv(:,2);
        nx = normals{boundaryIdx}(:,1);
        ny = normals{boundaryIdx}(:,2);
        
        funX = @(t)(-1/4).*nx.*pi.^(-1).*(taux.^2+tauy.^2).^(-1/2).*(2.*tauy.*atan((p_i(2).*taux+(-1).*myPts(:,2).*taux+...
            (-1).*p_i(1).*tauy+myPts(:,1).*tauy).^(-1).*((-1).*p_i(1).*taux+myPts(:,1).*taux+t.*taux.^2+(-1).*p_i(2).*tauy+myPts(:,2).*tauy+t.*tauy.^2))+...
            taux.*log(p_i(1).^2+p_i(2).^2+myPts(:,1).^2+myPts(:,2).^2+2.*myPts(:,1).*t.*taux+t.^2.*taux.^2+(-2).*p_i(1).*(myPts(:,1)+t.*taux)+2.*myPts(:,2).*t.*tauy+t.^2.*tauy.^2+(-2).*p_i(2).*(myPts(:,2)+t.*tauy)));
        funY = @(t)(-1/4).*ny.*pi.^(-1).*(taux.^2+tauy.^2).^(-1/2).*(2.*taux.*atan((( ...
            -1).*p_i(2).*taux+myPts(:,2).*taux+p_i(1).*tauy+(-1).*myPts(:,1).*tauy).^(-1).*((-1).* ...
            p_i(1).*taux+myPts(:,1).*taux+t.*taux.^2+(-1).*p_i(2).*tauy+myPts(:,2).*tauy+t.*tauy.^2) ...
            )+tauy.*log(p_i(1).^2+p_i(2).^2+myPts(:,1).^2+myPts(:,2).^2+2.*myPts(:,1).*t.*taux+t.^2.* ...
            taux.^2+(-2).*p_i(1).*(myPts(:,1)+t.*taux)+2.*myPts(:,2).*t.*tauy+t.^2.*tauy.^2+(-2) ...
            .*p_i(2).*(myPts(:,2)+t.*tauy)));
        
        dfs = funX(1)-funX(0) + funY(1)-funY(0);
        r = [r; sgn*dfs];
    else
        r = [r; zeros(size(lengths{j}))];
    end
    end
end