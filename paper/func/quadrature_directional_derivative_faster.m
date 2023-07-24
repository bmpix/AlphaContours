function [r] = quadrature_directional_derivative_faster(pts,normals,regionBoundaries_k,openCurve,all_p_i,curveSize)
r = [];
for j=1:numel(regionBoundaries_k)
    boundaryIdx = regionBoundaries_k(j);
    sgn = sign(boundaryIdx);
    boundaryIdx = abs(boundaryIdx);
    myPts = pts{boundaryIdx};
    m = curveSize(boundaryIdx);
    n = size(all_p_i,1);
        
    if (~openCurve(boundaryIdx))
        
        next_pts = circshift(myPts,-1,1);
        
        vv = next_pts-myPts;
        taux = vv(:,1);
        tauy = vv(:,2);
        

        
        nx = repmat(normals{boundaryIdx}(:,1)',n,1);
        ny = repmat(normals{boundaryIdx}(:,2)',n,1);
        tauNormSq = repmat((taux.^2+tauy.^2)',n,1);    
        funX = @(t)(-1/4).*nx.*pi.^(-1).*tauNormSq.^(-1/2).*(2.*repmat(tauy',n,1).*atan((all_p_i(:,2)*taux'-all_p_i(:,1)*tauy'+repmat((myPts(:,1).*tauy-myPts(:,2).*taux)',n,1)).^(-1).*...
            (-all_p_i(:,1)*taux'-all_p_i(:,2)*tauy'+repmat((myPts(:,1).*taux+t.*taux.^2+myPts(:,2).*tauy+t.*tauy.^2)',n,1)))+...
        repmat(taux',n,1).*log(repmat(all_p_i(:,1).^2+all_p_i(:,2).^2,1,m)+repmat((myPts(:,1).^2+myPts(:,2).^2+2.*myPts(:,1).*t.*taux+t.^2.*taux.^2+2.*myPts(:,2).*t.*tauy+t.^2.*tauy.^2)',n,1)...
        -2*all_p_i(:,2)*(myPts(:,2)+t.*tauy)'-2*all_p_i(:,1)*(myPts(:,1)+t.*taux)'));
        funY = @(t)(-1/4).*ny.*pi.^(-1).*tauNormSq.^(-1/2).*(2.*repmat(taux',n,1).*atan(...
(all_p_i(:,1)*tauy'-all_p_i(:,2)*taux'+repmat((myPts(:,2).*taux-myPts(:,1).*tauy)',n,1)).^(-1).*(-all_p_i(:,1)*taux'-all_p_i(:,2)*tauy'+repmat((myPts(:,1).*taux+t.*taux.^2+myPts(:,2).*tauy+t.*tauy.^2)',n,1)))...
+repmat(tauy',n,1).*log(repmat(all_p_i(:,1).^2+all_p_i(:,2).^2,1,m)+repmat((myPts(:,1).^2+myPts(:,2).^2+2.*myPts(:,1).*t.*taux+t.^2.*taux.^2+2*myPts(:,2).*t.*tauy+t.^2.*tauy.^2)',n,1)-2*all_p_i(:,2)*(myPts(:,2)+t.*tauy)'-2*all_p_i(:,1)*(myPts(:,1)+t.*taux)'));
        
        dfs = funX(1)-funX(0) + funY(1)-funY(0);
        r = [r sgn*dfs];
    else
        r = [r zeros(n,m)];
    end
    end
end