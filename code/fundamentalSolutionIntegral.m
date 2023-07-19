function [r] = fundamentalSolutionIntegral(p_i,boundaryCurve,next)
tau = next-boundaryCurve;
n = size(boundaryCurve,1);
a = tau(:,1).^2+tau(:,2).^2;
b = ((-2).*p_i(1).*tau(:,1)+2.*boundaryCurve(:,1).*tau(:,1)+(-2).*p_i(2).*tau(:,2)+2.*boundaryCurve(:,2).*tau(:,2));
c = p_i(1).^2+p_i(2).^2+(-2).*p_i(1).*boundaryCurve(:,1)+boundaryCurve(:,1).^2+(-2).*p_i(2).*boundaryCurve(:,2)+boundaryCurve(:,2).^2;
dl = sqrt(a);
fun = @(x)(-dl/(2*pi)).*((1/4).*a.^(-1).*((-4).*a.*x+2.*((-1).*b.^2+4.*a.*c).^(1/2).*atan(((-1).*b.^2+4.*a.*c).^(-1/2).*(b+2.*a.*x))+(b+2.*a.*x).*log(c+x.*(b+a.*x))));
r = fun(ones(n,1))-fun(zeros(n,1));
end

