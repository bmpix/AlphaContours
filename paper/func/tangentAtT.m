function [v] = tangentAtT(curve,t)
X = curve(:,1);
Y = curve(:,2);
intVal = (mod(t,1) == 0);
v = zeros(numel(t),2);

Xnext = circshift(X,-1);
Ynext = circshift(Y,-1);
tInt = t(intVal);
v(intVal,:) = [Xnext(tInt) Ynext(tInt)] - [X(tInt) Y(tInt)];
if (any(t==size(X,1)))
    v(t==size(X,1),:) = [X(end) Y(end)] - [X(end-1) Y(end-1)];
end

%for the non-integer values of t:
tNext = ceil(t(~intVal));
tPrev = floor(t(~intVal));
v(~intVal,:) = [X(tNext) Y(tNext)] - [X(tPrev) Y(tPrev)];
end

