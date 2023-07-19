function int = computeInterpolation(L,n,m)

a = 1;
b = 0.1;

mu = 1000;
L(n,n) = L(n,n) + mu;
L(m,m) = L(m,m) + mu;

A = L;

B = zeros(length(L),1);
B(n,1) = B(n,1) + a*mu;
B(m,1) = B(m,1) + b*mu;

int = -A \ B;
int = full(int);

end
