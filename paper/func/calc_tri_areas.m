function S_tri = calc_tri_areas(V,T)

for k=1:size(T,1)
    e1 = V(T(k,3),:) - V(T(k,1),:);
    e2 = V(T(k,2),:) - V(T(k,1),:);
    S(k) = 0.5*norm(cross(e1,e2));
end

S_tri = sum(S);

end
